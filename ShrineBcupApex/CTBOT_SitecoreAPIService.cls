public with sharing class CTBOT_SitecoreAPIService {

    public class SitecoreAPIServiceException extends Exception {}
    public static HttpRequest request = new HttpRequest();
    private static String endpoint;
    private static String query;
    private static SitecoreServiceParam params;
    private static RequestType typeOfRequest;
    private static Environment environmentType;
    @testVisible private static Sitecore_API_Service__mdt metadataRecord;
    @testVisible private static Id jobId;
    @testVisible private static boolean isTest;
    private static Boolean metadataUpdateRequired = false;
    @testVisible private static Integer tokenRefreshInterval = 4;
    private static final String ADMIN_USER = 'deployment user';

    public class SitecoreServiceParam {
        public String agency;
        public String keywords;
        public String contentId;
        public String category;
        public String sortBy;
        public Id routableId;
        public String pageSize;
        public Integer numberOfResults;
        public List<CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem> feedbackRequest;
    }

    public enum Environment { STAGE, UAT, PROD }
    public enum RequestType { CONFUSED, CONTENT_ID, FEEDBACK }
    
    @future(callout = true)
    public static void initializeSitecoreServiceBatch() {
        initializeSitecoreServiceUtil(null, null);
    }

    public static void initializeSitecoreService(RequestType request, SitecoreServiceParam paramObject) {
        initializeSitecoreServiceUtil(request, paramObject);
    }

    public static void initializeSitecoreServiceUtil(RequestType request, SitecoreServiceParam paramObject) {
        if (request == RequestType.CONTENT_ID && String.isEmpty(paramObject.contentId)) {
            throw new SitecoreAPIServiceException('No content ID passed to content ID search.');
        } else if (request == RequestType.FEEDBACK && paramObject.feedbackRequest == null) {
            throw new SitecoreAPIServiceException('No request passed to feedback callout.');
        }

        environmentType = Environment.valueOf(Label.CTBOT_Chatbot_Environment);
        typeOfRequest = request;
        params = paramObject;
        getMetadataRecords();
    }

    private static void getMetadataRecords() {
        String environment = Test.isRunningTest() ? 'test' : String.valueOf(environmentType);
        List<Sitecore_API_Service__mdt> metadataRecords = [
            SELECT Confused_State_Endpoint__c, Content_ID_Endpoint__c, Feedback_Endpoint__c,
            Session_Valid_From__c, Keyword_Endpoint__c, Session_Token__c
            FROM Sitecore_API_Service__mdt
            WHERE MasterLabel = :environment
            LIMIT 1
        ];
        if (metadataRecords.size() > 0 || Test.isRunningTest()) {
            metadataRecord = !Test.isRunningTest() ? metadataRecords[0] : new Sitecore_API_Service__mdt(
                MasterLabel = 'Test Metadata',
                Confused_State_Endpoint__c = 'https://www.test.com/confused',
                Content_ID_Endpoint__c = 'https://www.test.com/ContentId',
                Feedback_Endpoint__c = 'https://www.test.com/feedback',
                Session_Token__c = 'test',
                Session_Valid_From__c = System.now().addHours(-tokenRefreshInterval)
            );
        } else if (metadataRecords.size() == 0) {
            throw new SitecoreAPIServiceException('No metadata records found for Sitecore service.');
        }
        if (metadataRecord.Session_Token__c == null || 
            metadataRecord.Session_Valid_From__c.addHours(tokenRefreshInterval).getTime() <= System.now().getTime()){
            getSessionToken();
        }
    }

    public static void getSessionToken() {
        HttpRequest request = new HttpRequest();
        String endpoint = 'callout:Sitecore_' + String.valueOf(environmentType);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Length', '0');
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            metadataRecord.Session_Token__c = response.getBody().remove('"');
            metadataRecord.Session_Valid_From__c = System.now();

            // Save metadata update until end of transaction unless running when bot starts
            metadataUpdateRequired = true;
            if (params == null) updateMetadata();
        } else throw new SitecoreAPIServiceException(
            'Error from Sitecore authorization endpoint with status code of ' + response.getStatusCode() 
            + '. Error message: ' + response.getBody()
        );
    }

    private static void updateMetadata() {
        Metadata.CustomMetadata recordToUpdate = new Metadata.CustomMetadata();
        recordToUpdate.fullName = 'Sitecore_API_Service.' + String.valueOf(environmentType);
        recordToUpdate.label = String.valueOf(environmentType);
        Metadata.CustomMetadataValue token = new Metadata.CustomMetadataValue();
        token.field = 'Session_Token__c';
        token.value = metadataRecord.Session_Token__c;
        recordToUpdate.values.add(token);
        Metadata.CustomMetadataValue timestamp = new Metadata.CustomMetadataValue();
        timestamp.field = 'Session_Valid_From__c';
        timestamp.value = metadataRecord.Session_Valid_From__c;
        recordToUpdate.values.add(timestamp);

        Metadata.DeployContainer container = new Metadata.DeployContainer();
        container.addMetadata(recordToUpdate);
        CTBOT_SitecoreDeployCallback callback = new CTBOT_SitecoreDeployCallback();
        jobId = Test.isRunningTest() ? '00300000003T2PGAA0' : Metadata.Operations.enqueueDeployment(container, callback);
    }

    public static HttpRequest formatRequest() {
        Bot_Agency_Origination__mdt originationRecord = params.agency != null ? Bot_Agency_Origination__mdt.getInstance(params.agency.toUpperCase()) : null;
            if (originationRecord != null || Test.isRunningTest()) {
                originationRecord = !Test.isRunningTest() ? originationRecord : new Bot_Agency_Origination__mdt(
                MasterLabel = 'Test Origination',
                Agency_Subdirectory__c = 'Test',
                Is_Service_Category__c = true,
                Origination_Test_URL__c = 'www.test.com',
                Origination_URL__c = 'www.test.com',
                Sitecore_Entity_Name__c = 'test'
            );
        }

        if (metadataRecord != null && typeOfRequest != null) {
            String endpoint;
            String agency = (originationRecord != null && originationRecord.Is_Service_Category__c ? 
                originationRecord.Sitecore_Entity_Name__c : params.agency == null ? '' : params.agency);
            Integer isServiceCategory = (originationRecord != null && originationRecord.Is_Service_Category__c ? 1 : 0);
            switch on typeOfRequest {
                when CONFUSED {
                    endpoint = metadataRecord.Confused_State_Endpoint__c + 
                    '?keyword=' + (params.keywords == null ? '' : params.keywords) +
                    '&category=&sortBy=&agency=' + agency + 
                    '&resultsreturned=' + params.numberOfResults + '&pageNumber=1' + 
                    '&servicecategory=' + isServiceCategory +
                    '&isBotMode=true';
                }

                when CONTENT_ID {
                    if (metadataRecord.Content_ID_Endpoint__c.contains('ct-sf-sitecore') ||
                        metadataRecord.Content_ID_Endpoint__c.contains('www.test.com')) {
                       // Code for MuleSoft Endpoints
                        endpoint = metadataRecord.Content_ID_Endpoint__c + '/' +
                        (params.contentId == null ? '' : params.contentId);
                    }
                    else {
                        // Code for Direct Calls to Sitecore Endpoints
                        endpoint = metadataRecord.Content_ID_Endpoint__c + 
                        '?keyword=' + (params.keywords == null ? '' : params.keywords) +
                        '&category=&sortBy=&agency=' + agency + 
                        '&resultsreturned=' + params.numberOfResults + '&pageNumber=1' + 
                        '&servicecategory=' + isServiceCategory +
                        '&contentId=' + 
                        (params.contentId == null ? '' : params.contentId);
    
                    }
                }

                when FEEDBACK {
                    endpoint = metadataRecord.Feedback_Endpoint__c;
                    request.setBody(JSON.serialize(params.feedbackRequest));
                }
            }

            request.setEndpoint(endpoint);
            request.setMethod(typeOfRequest == RequestType.FEEDBACK ? 'POST' : 'GET');
            request.setHeader('Authorization', 'Bearer ' + metadataRecord.Session_Token__c);
            if (typeOfRequest != RequestType.FEEDBACK) {
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            } else {
                request.setHeader('Content-Type', 'application/json');
            }
        }
        return request;
    }

    public static HttpResponse sendRequest() {
        Http http = new Http();
        request = formatRequest();
        Long stampBeforeRequest = System.now().getTime();
        HttpResponse response = http.send(request);
        Long stampAfterRequest = System.now().getTime();
        updateRecords(stampBeforeRequest, stampAfterRequest);
        checkApiLimits();
        return response;
    }

    public static void updateRecords(Long stampBeforeRequest, Long stampAfterRequest) {
        List<LiveChatTranscript> transcripts = [
            SELECT Id, Server_Round_trip_Times__c, Total_API_calls__c
            FROM LiveChatTranscript
            WHERE Id = :params.routableId
            WITH USER_MODE
        ];
        if (Test.isRunningTest()) {
            transcripts = [
                SELECT Id, Server_Round_trip_Times__c, Total_API_calls__c
                FROM LiveChatTranscript
                WHERE ChatKey = '123'
            ];
        }
        if (transcripts.size() > 0) {
            Long totalTime = stampAfterRequest - stampBeforeRequest;
            String roundTripValue = transcripts[0].Server_Round_trip_Times__c;
            transcripts[0].Server_Round_trip_Times__c = roundTripValue == null ? '' + totalTime : roundTripValue + ', ' + totalTime;
            Decimal apiCallValue = transcripts[0].Total_API_calls__c;
            transcripts[0].Total_API_calls__c = apiCallValue == null ? 1 : apiCallValue + 1;
            update as User transcripts;
        }
        if (metadataUpdateRequired) updateMetadata();
    }

    public static void checkApiLimits() {
        Decimal randomNum = Math.random();
        Decimal percentage = 0.35;

        // Don't check the limits every time so performance isn't degraded
        if (randomNum < percentage || Test.isRunningTest()) {
            Map<String, System.OrgLimit> limitsMap = OrgLimits.getMap();
            System.OrgLimit limitObject = limitsMap.get('DailyApiRequests');
            if (limitObject.getLimit() - limitObject.getValue() < 40000 || Test.isRunningTest()) {
                List<User> admins = [
                    SELECT Id
                    FROM User
                    WHERE Name = :ADMIN_USER AND IsActive = true AND UserType = 'Standard'
                    WITH USER_MODE
                ];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ admins[0]?.Id });
                mail.setSenderDisplayName('Robin Chatbot Warning');
                mail.setSubject('Org API limits almost reached');
                mail.setPlainTextBody('API daily limits have almost been reached. Current usage: ' + limitObject.getValue()
                    + '. Max calls: ' + limitObject.getLimit());
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            }
        }
    }

    public void handleResult(Metadata.DeployResult result,
        Metadata.DeployCallbackContext context) {
        if (result.status != Metadata.DeployStatus.SUCCEEDED) {
            throw new SitecoreAPIServiceException('Error updating custom metadata: ' + result);
        }
    }

    // Classes for JSON Parsing

    public class SitecoreResponse {
        public RequestObject request;
        public List<SitecoreItem> items;
    }

    public class RequestObject {
        public String keyword;
        public String category;
        public String agencyStartPath;
        public Integer totalResults;
        public Integer maxResults;
        public Integer currentPage;
    }

    public class SitecoreItem {
        public String tagTitle;
        public String tagTeaser;
        public String tagDescription;
        public String tagDate;
        public String tagAgency;
        public String matchSnippetText;
        public String chatbotTitle;
        public String chatbotContent;
        public String keywords;
        public Boolean chatbotOnly;
        public Decimal articleRatingPositive;
        public Decimal articleRatingNegative;
        public Decimal searchRelevancyPositive;
        public Decimal searchRelevancyNegative;
        public List<RelatedItem> relatedItems;
        public String name;
        public String metaTitle;
        public String metaDescription;
        public String metaKeywords;
        public String id;
        public String dateModified;
        public String url;
        public String path;
        public String parentId;
    }

    public class RelatedItem {
        public String id;
        public String chatbotTitle;
    }
}