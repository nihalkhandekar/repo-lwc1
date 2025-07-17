@isTest
public with sharing class InterOrgTransferHelperTest {

    @testSetup
    private static void testSetup() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@gmail.com');
        insert new List<sObject>{visitor, testContact};

        String originationUrl = 'https://';
        if (System.Label.CTBOT_Chatbot_Environment != 'PROD') {
            originationUrl += Bot_Agency_Origination__mdt.getInstance('CTPL').Origination_Test_URL__c + '/s/?language=en_US';
        } else {
            originationUrl += Bot_Agency_Origination__mdt.getInstance('CTPL').Origination_URL__c + '/s/?language=en_US';
        }
        LiveChatTranscript transcript = new LiveChatTranscript(Body = 'This is a test', Visitor_URL__c = 'https://www.test.com',
            ContactId = testContact.Id, LiveChatVisitorId = visitor.Id, ChatKey = 'testChatKey', 
            Origination__c = originationUrl);
        insert transcript;
    }
    
    @isTest
    static void testGetDetails() {
        try {
            InterOrgTransferHelper.InterOrgDetailWrapper wrapper = InterOrgTransferHelper.getDetails('Test', 'Test');   
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('An error occurred when getting details from InterOrgTransferHelper'));
        }

        InterOrgTransferHelper.isTest = true;
        InterOrgChatCallout.isTest = true;
        InterOrgTransferHelper.InterOrgDetailWrapper wrapper = InterOrgTransferHelper.getDetails('Test', 'testChatKey');
        System.assertEquals('This is a test', wrapper.transcript.Body);
        System.assertEquals('CTPL', wrapper.transferOriginationName);
    }

    @isTest
    static void testExistingContactCallout() {
        InterOrgChatCalloutMock.createContact = false;
        List<Object> result = sendTestCallout();

        JSONParser parser = JSON.createParser((String)result[1]);
        Integer totalContacts;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'totalSize') {
                parser.nextValue();
                totalContacts = parser.getIntegerValue();
            } 
        }

        // Assert 1 contact found in destination (i.e., do not create a contact)
        System.assert(totalContacts == 1);
    }

    @isTest
    static void testNoContact() {
        InterOrgChatCalloutMock.createContact = true;
        List<Object> result = sendTestCallout();

        JSONParser parser = JSON.createParser((String)result[1]);
        Integer totalContacts;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'totalSize') {
                parser.nextValue();
                totalContacts = parser.getIntegerValue();
            } 
        }

        // Assert no contacts found in destination (i.e., create a contact)
        System.assert(totalContacts == 0);
    }

    @isTest
    static void testGetVisitorUrl() {
        LiveChatTranscript transcript = [
            SELECT Id 
            FROM LiveChatTranscript
            LIMIT 1
        ];

        List<String> result = InterOrgTransferHelper.getVisitorUrl(new List<Id>{transcript.Id});
        System.assertEquals('www.test.com', result[0]);
    }

    private static List<Object> sendTestCallout() {
        InterOrgChatCallout.isTest = true;
        String JSONDetails = '{ "metadata": { "MasterLabel": "Test" }, "transcript": {} }';
        Continuation con = (Continuation)InterOrgTransferHelper.checkForContact('Test', 'Test', 'test@gmail.com', JSONDetails);

        Map<String, HttpRequest> requests = con.getRequests();
        System.assert(requests.size() == 1);

        HttpResponse response = InterOrgChatCalloutMock.respond(requests.get(new List<String>(requests.keySet())[0]));
        Test.setContinuationResponse(InterOrgTransferHelper.requestLabel, response);
        List<String> labels = new List<String>{ InterOrgTransferHelper.requestLabel };
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());

        Test.startTest();
        List<Object> result = InterOrgTransferHelper.callback(labels, InterOrgTransferHelper.continuationState);
        Test.stopTest();

        return result;
    }
}