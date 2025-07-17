public without sharing class InterOrgTransferHelper {

    @TestVisible private static Boolean isTest = false;
    @TestVisible private static String requestLabel;
    @TestVisible private static InterOrgDetailWrapper continuationState;
    
    public class InterOrgDetailWrapper {
        @AuraEnabled public Inter_Org_Transfer_Detail__mdt metadata;
        @AuraEnabled public LiveChatTranscript transcript;
        @AuraEnabled public String transferOriginationName;
        @AuraEnabled public String transferUrl;
    }

    @AuraEnabled
    public static InterOrgDetailWrapper getDetails(String org, String chatKey) {
        try {

            System.debug('chatKey: ' + chatKey);

            List<Inter_Org_Transfer_Detail__mdt> metadataRecords = [
                SELECT baseLiveAgentContentURL__c, baseLiveAgentURL__c, Base_URL__c, eswLiveAgentDevName__c, MasterLabel,
                Deployment_API_Name__c, buttonId__c, deploymentId__c, Org_ID__c, Site_URL__c, Redirect_URL__c, Create_Case__c
                FROM Inter_Org_Transfer_Detail__mdt 
                WHERE MasterLabel = :org 
                LIMIT 1
            ];

            LiveChatTranscript transcript = [
                SELECT Body, ChatKey, Status, RequestTime, StartTime, EndTime, EndedBy, WaitTime, ChatDuration,
                Transfers_to_Agent__c, Origination__c, Location, Browser, IpAddress, BrowserLanguage, Platform, ReferrerUri,
                ScreenResolution, VisitorNetwork, UserAgent, AverageResponseTimeVisitor, AverageResponseTimeOperator,
                MaxResponseTimeVisitor, MaxResponseTimeOperator, VisitorMessageCount, OperatorMessageCount,
                Contact.FirstName, Contact.LastName, Contact.Email, Iframe_Origination__c
                FROM LiveChatTranscript
                WHERE ChatKey = :chatKey
                LIMIT 1
            ];

            CTBOT_ChatbotGetAgencyOrigination.AgencyDto agencyDto = CTBOT_ChatbotGetAgencyOrigination.parseOrigination(transcript.Origination__c);
            String transferOriginationName = agencyDto.agencyName;

            if (isTest) {
                metadataRecords = new List<Inter_Org_Transfer_Detail__mdt>{new Inter_Org_Transfer_Detail__mdt(
                    MasterLabel = 'Test Metadata',
                    Endpoint__c = 'https://www.test.com'
                )};
            }

            InterOrgDetailWrapper wrapper = new InterOrgDetailWrapper();
            wrapper.metadata = metadataRecords[0];
            wrapper.transcript = transcript;
            wrapper.transferOriginationName = transferOriginationName;
            wrapper.transferUrl = transcript.Origination__c.contains('?') ? 
                transcript.Origination__c.split('\\?')[0] : transcript.Origination__c;
            wrapper.transferUrl = transcript.Iframe_Origination__c != null ? 
                transcript.Iframe_Origination__c.split('\\?')[0] : wrapper.transferUrl;

            System.debug('wrapper: ' + wrapper);

            return wrapper;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException('An error occurred when getting details' 
                + ' from InterOrgTransferHelper: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString());
            auraException.setMessage('An error occurred when getting details' 
                + ' from InterOrgTransferHelper: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString());
            throw auraException;
        }
    }

    @AuraEnabled(continuation = true cacheable = true) 
    public static Object checkForContact(String firstName, String lastName, String email, String JSONDetails) {
        InterOrgDetailWrapper details = (InterOrgDetailWrapper)JSON.deserialize(JSONDetails, InterOrgDetailWrapper.class);
        System.debug('details from checkForContact: ' + details);
        System.debug('firstName from checkForContact: ' + firstName);
        System.debug('lastName from checkForContact: ' + lastName);
        System.debug('email from checkForContact: ' + email);
        Continuation con = new Continuation(40);
        con.continuationMethod = 'callback';

        InterOrgChatCallout.beginInterOrgChatCallout(details.metadata.MasterLabel, 'GET', 
            '/services/data/v51.0/query/?q=SELECT+Id+FROM+Contact+WHERE+FirstName+=+\'' + firstName
            + '\'+AND+LastName+=+\'' + lastName + '\'+AND+Email+=+\'' + email + '\'', null);
        HttpRequest req = InterOrgChatCallout.getRequest();
        requestLabel = con.addHttpRequest(req);
        continuationState = details;
        con.state = continuationState;
        return con;
    }

    @AuraEnabled(cacheable = true)
    public static List<Object> callback(List<String> labels, Object state) {
        HttpResponse response = Continuation.getResponse(labels[0]);
        InterOrgDetailWrapper details = (InterOrgDetailWrapper)state;
        String result = response.getBody();
        Id foundContactId;

        JSONParser parser = JSON.createParser(response.getBody());
        Integer totalContacts;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                parser.nextValue();
                if (parser.getCurrentName() == 'totalSize') {
                    totalContacts = parser.getIntegerValue();
                } else if (parser.getCurrentName() == 'records') {
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                            parser.nextValue();
                            if (parser.getCurrentName() == 'attributes') {
                                parser.skipChildren();
                            } else if (parser.getCurrentName() == 'Id') {
                                foundContactId = parser.getIdValue();
                                break;
                            }
                        } else if (parser.getCurrentToken() == JSONToken.START_OBJECT) continue;
                    }
                }
            } 
        }

        List<Object> objects = sendTranscript(JSON.serialize(details), totalContacts, foundContactId);

        System.debug('response: ' + response.getBody());
        System.debug('objects: ' + objects);
        System.debug('totalContacts: ' + totalContacts);
        System.debug('foundContactId: ' + foundContactId);

        return objects;
    }

    @AuraEnabled
    public static List<Object> sendTranscript(String JSONDetails, Integer totalContacts, Id foundContactId) {
        InterOrgDetailWrapper details = (InterOrgDetailWrapper)JSON.deserialize(JSONDetails, InterOrgDetailWrapper.class);
        InterOrgChatCallout.JSONRequest JSONBody = new InterOrgChatCallout.JSONRequest();
        if (totalContacts == 0) {
            JSONBody = constructJSON(details, null);
        } else JSONBody = constructJSON(details, foundContactId);

        InterOrgChatCallout.beginInterOrgChatCallout(details.metadata.MasterLabel, 'POST', 
            '/services/data/v51.0/composite/', JSONBody);
        HttpResponse calloutResponse = InterOrgChatCallout.sendRequest();

        return new List<Object>{
            calloutResponse.getStatusCode(), 
            calloutResponse.getBody(), 
            JSON.serialize(JSONBody, true).replace('_customFieldEnd', '__c')
        };
    }

    private static InterOrgChatCallout.JSONRequest constructJSON(InterOrgDetailWrapper details, Id contactId) {
        
        // Construct JSON request
        InterOrgChatCallout.JSONRequest request = new InterOrgChatCallout.JSONRequest();
        InterOrgChatCallout.JSONCompositeRequest contactRequest = new InterOrgChatCallout.JSONCompositeRequest();
        InterOrgChatCallout.JSONCompositeRequest visitorRequest = new InterOrgChatCallout.JSONCompositeRequest();
        InterOrgChatCallout.JSONCompositeRequest transcriptRequest = new InterOrgChatCallout.JSONCompositeRequest();
        InterOrgChatCallout.JSONBody transcriptBody = new InterOrgChatCallout.JSONBody();
        InterOrgChatCallout.JSONBody visitorBody = new InterOrgChatCallout.JSONBody();
        InterOrgChatCallout.JSONBody contactBody = new InterOrgChatCallout.JSONBody();

        request.compositeRequest = new List<InterOrgChatCallout.JSONCompositeRequest>{visitorRequest};

        // Set the transcript body
        transcriptBody.Body = details.transcript.Body;
        transcriptBody.ChatKey = details.transcript.ChatKey;
        transcriptBody.Status = details.transcript.Status;
        transcriptBody.RequestTime = details.transcript.RequestTime;
        transcriptBody.StartTime = details.transcript.StartTime;
        transcriptBody.EndTime = details.transcript.EndTime;
        transcriptBody.EndedBy = details.transcript.EndedBy;
        transcriptBody.Visitor_URL_customFieldEnd = details.transcript.Visitor_URL__c;
        transcriptBody.Location = details.transcript.Location;
        transcriptBody.Browser = details.transcript.Browser;
        transcriptBody.IpAddress = details.transcript.IpAddress;
        transcriptBody.BrowserLanguage = details.transcript.BrowserLanguage;
        transcriptBody.Platform = details.transcript.Platform;
        transcriptBody.ReferrerUri = details.transcript.ReferrerUri;
        transcriptBody.ScreenResolution = details.transcript.ScreenResolution;
        transcriptBody.VisitorNetwork = details.transcript.VisitorNetwork;
        transcriptBody.UserAgent = details.transcript.UserAgent;
        transcriptBody.AverageResponseTimeVisitor = details.transcript.AverageResponseTimeVisitor;
        transcriptBody.AverageResponseTimeOperator = details.transcript.AverageResponseTimeOperator;
        transcriptBody.MaxResponseTimeVisitor = details.transcript.MaxResponseTimeVisitor;
        transcriptBody.MaxResponseTimeOperator = details.transcript.MaxResponseTimeOperator;
        transcriptBody.VisitorMessageCount = details.transcript.VisitorMessageCount;
        transcriptBody.OperatorMessageCount = details.transcript.OperatorMessageCount;
        transcriptBody.LiveChatVisitorId = '@{visitor.id}';

        // Construct the transcript
        transcriptRequest.method = 'POST';
        transcriptRequest.referenceId = 'transcript';
        transcriptRequest.url = '/services/data/v51.0/sobjects/LiveChatTranscript';
        transcriptRequest.body = transcriptBody;

        // Add the LiveChatVisitor
        visitorRequest.method = 'POST';
        visitorRequest.referenceId = 'visitor';
        visitorRequest.url = '/services/data/v51.0/sobjects/LiveChatVisitor';
        visitorRequest.body = visitorBody;

        // Create a contact?
        if (contactId == null) {
            request.compositeRequest.add(contactRequest);

            contactBody.FirstName = details.transcript.Contact.FirstName;
            contactBody.LastName = details.transcript.Contact.LastName;
            contactBody.Email = details.transcript.Contact.Email;
            contactRequest.method = 'POST';
            contactRequest.referenceId = 'contact';
            contactRequest.url = '/services/data/v51.0/sobjects/Contact';
            contactRequest.body = contactBody;

            transcriptBody.ContactId = '@{contact.id}';
        } else transcriptBody.ContactId = contactId;

        request.compositeRequest.add(transcriptRequest);

        return request;
    }

    @InvocableMethod(label='Get Visitor URL' description='Gets the URL the chat originated from')
    public static List<String> getVisitorUrl(List<Id> transcripts) {
        
        LiveChatTranscript transcript = [
            SELECT Visitor_URL__c
            FROM LiveChatTranscript
            WHERE Id 
            IN :transcripts
            LIMIT 1
        ];

        return new List<String>{ new URL(transcript.Visitor_URL__c).getHost() };
    }
}