@isTest
private class ChatbotValidateAuthStatusTest {

    @testSetup
    static void makeData() {
        LiveChatVisitor testVisitor = new LiveChatVisitor();
        String varRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@gmail.com', recordTypeId = varRecordTypeId, LeadSource = 'Chat');
        List<SObject> objectsToInsert = new List<SObject>{ testVisitor, testContact };
        insert objectsToInsert;

        LiveChatTranscript testTranscript = new LiveChatTranscript(
            ContactId = testContact.Id, 
            LiveChatVisitorId = testVisitor.Id,
            ChatKey = 'testkey'
        );
        insert testTranscript;
    }

    @isTest
    static void testContactExists() {
        List<List<Object>> objects = beginTest('SIGNIN-STATUS');
        ChatbotValidateAuthStatus.ResponsesOutput output = (ChatbotValidateAuthStatus.ResponsesOutput)objects[1][0];
        System.assertEquals('VGVzdCBUZXN0', output.token);
        System.assertEquals(false, output.greetUser);
        
        LiveChatTranscript transcript = [
            SELECT User_Authenticated__c
            FROM LiveChatTranscript
            WHERE ChatKey = 'testkey'
            LIMIT 1
        ];
        System.assertEquals(true, transcript.User_Authenticated__c);
    }

    @isTest
    static void testContactDoesNotExist() {
        LiveChatTranscript transcript = [
            SELECT ContactId
            FROM LiveChatTranscript
            WHERE ChatKey = 'testkey'
            LIMIT 1
        ];
        transcript.ContactId = null;
        update transcript;

        List<List<Object>> objects = beginTest('SIGNIN-STATUS');
        ChatbotValidateAuthStatus.ResponsesOutput output = (ChatbotValidateAuthStatus.ResponsesOutput)objects[1][0];

        System.assertEquals(true, output.greetUser);

        LiveChatTranscript updatedTranscript = [
            SELECT User_Authenticated__c, ContactId
            FROM LiveChatTranscript
            WHERE ChatKey = 'testkey'
            LIMIT 1
        ];
        System.assertEquals(true, updatedTranscript.User_Authenticated__c);
        System.assert(updatedTranscript.ContactId != null);
    }

    @isTest
    static void testFalseAuthEvent() {
        List<List<Object>> objects = beginTest('test');
        ChatbotValidateAuthStatus.ResponsesOutput output = (ChatbotValidateAuthStatus.ResponsesOutput)objects[1][0];

        System.assertEquals(false, output.isAuthEvent);
    }

    @isTest
    static void testBlankInput() {
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript('https://business.ct.gov');
        ChatbotValidateAuthStatus.ResponsesInput loginInput = new ChatbotValidateAuthStatus.ResponsesInput();
        loginInput.lastCustomerInput = '';
       
        LiveChatTranscript transcript = [
            SELECT User_Authenticated__c
            FROM LiveChatTranscript
            WHERE ChatKey = '123'
            LIMIT 1
        ];
        System.assertEquals(false, transcript.User_Authenticated__c);
    }

   private static List<List<Object>> beginTest(String authMessageSub) {
        ChatbotValidateAuthStatus.ResponsesInput loginInput = new ChatbotValidateAuthStatus.ResponsesInput();
        // AltCustId is Base64 encoded version of "Test Test"
        loginInput.lastCustomerInput = '{"[' + authMessageSub + ']":{"AltCustId":"VGVzdCBUZXN0","ActionType":"login",'
            + '"AuthStatus":"authenticated","Name":"Test Test","ActionId":' 
            + Math.round(Math.random() * 1000000) 
            + '},"ChatKey":"testkey"}';
        List<ChatbotValidateAuthStatus.ResponsesInput> input = new List<ChatbotValidateAuthStatus.ResponsesInput>{ loginInput };
        List<ChatbotValidateAuthStatus.ResponsesOutput> lstLoginOutput = ChatbotValidateAuthStatus.validateAuthStatus(input);
        return new List<List<Object>>{ input, lstLoginOutput };
    }
}