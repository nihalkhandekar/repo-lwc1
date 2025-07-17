@isTest
public with sharing class ChatbotEmbeddedServiceMsgHandlerTest {
    private static ChatbotEmbeddedServiceMsgHandler.ResponseInput responseInput = new ChatbotEmbeddedServiceMsgHandler.ResponseInput();
    private static ChatbotEmbeddedServiceMsgHandler.ResponseOutput responseOutput = new ChatbotEmbeddedServiceMsgHandler.ResponseOutput();
    private static List<ChatbotEmbeddedServiceMsgHandler.ResponseOutput> response = new List<ChatbotEmbeddedServiceMsgHandler.ResponseOutput>();
    private static List<ChatbotEmbeddedServiceMsgHandler.ResponseInput> request = new List<ChatbotEmbeddedServiceMsgHandler.ResponseInput>();

    private static final String SITECORE_INIT_EVT = 'S1C2 Se33ss In123it';
    private static final String SITECORE_INIT_STRING = '{"[REDIR-DLOG-MSG]":{"redir-dlog":"S1C2 Se33ss In123it"}}';
    private static final String CUST_SIGNIN_STRING = '{"[CUST-SIGNIN-STATUS]":{"customerId":"005r0000007bhtOAAQ","ActionType":"login","AuthStatus":"authenticated","Name":" ","ActionId":1664375737201}}';
    private static final String ORIGINATION_URL = 'sub.domain.gov';

    private static LiveChatTranscript transcript = new LiveChatTranscript();
    private static User testUser = new User();
    private static Contact testContact = new Contact();

    private static final User ctbotUser = [SELECT Id FROM User
        WHERE FederationIdentifier = 'ctbot.user@ct.gov.ctds' AND IsActive = TRUE AND UserType = 'Standard'
        LIMIT 1
    ];

    @TestSetup
    static void makeData() {
        UserRole userRole = [
            SELECT Id, DeveloperName
            FROM UserRole
            WHERE DeveloperName = 'System_Admin'
            LIMIT 1
        ];
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userAdmin = new User(
            Username = 'system.admin' + randomInt + '@example.com',
            Email = 'system.admin@example.com',
            FirstName = 'System',
            LastName = 'Admin',
            Alias = 'sysadmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            Bypass_trigger__c = true,
            ProfileId = adminProfile.Id,
            UserRoleId = userRole.Id
        );
        insert userAdmin;

        List<PermissionSet> permissionSetList = [
            SELECT Id, Label
            FROM PermissionSet
            WHERE Name = 'CTBOT_Service_Permissions'
        ];
        if (!permissionSetList.isEmpty()) {
            PermissionSetAssignment permissionSetAssignmentRecord = new PermissionSetAssignment(
                PermissionSetId = permissionSetList[0].id,
                AssigneeId = userAdmin.Id
            );
            insert permissionSetAssignmentRecord;
        }

        System.runAs(userAdmin) {
            testUser = CTBOT_TestDataFactory.createCommunityUsr_PermissionSet('Test Account Name', 'Test Contact Name');

            String chatKey = CTBOT_TestDataFactory.createTestChatTranscript(ORIGINATION_URL);
            transcript = [SELECT Id, ChatKey FROM LiveChatTranscript WHERE ChatKey = :chatKey];
            transcript.Context_User_Id__c = testUser.Id;
            transcript.ContactId = testUser.ContactId;
            update transcript;
        }
    }

    @isTest
    static void getTranscriptByChatKeyTest() {
        List<LiveChatTranscript> transcriptList = [
            SELECT Id, Context_User_Id__c, ContactId, ChatKey
            FROM LiveChatTranscript
            WHERE ContactId != NULL
            LIMIT 1
        ];
        String chatKey = transcriptList[0].ChatKey;

        transcriptList.clear();
        Test.startTest();
        System.runAs(ctbotUser) {
            transcriptList = ChatbotEmbeddedServiceMsgHandler.getTranscriptByChatKey(chatKey);
        }
        Test.stopTest();

        System.assertEquals(1, transcriptList.size(), 'expected only one transcript to be returned');
        System.assertEquals(
            chatKey,
            transcriptList[0].ChatKey,
            'The method returned the wrong transcript for the chatkey provided'
        );
    }

    @isTest
    static void getContactForContextUserTest() {
        List<User> testUser = [SELECT Id, ContactId FROM User LIMIT 1];
        String contactId;

        Test.startTest();
        System.runAs(ctbotUser) {
            contactId = ChatbotEmbeddedServiceMsgHandler.getContactIdForContextUser(testUser[0].Id);
        }
        Test.stopTest();

        System.assertEquals(
            testUser[0].ContactId,
            contactId,
            'The method returned the wrong contact Id for the user Id passed in.'
        );
    }

    @isTest
    static void updateTranscriptTest() {
        List<LiveChatTranscript> transcriptList = [
            SELECT Id, Context_User_Id__c, ContactId, ChatKey
            FROM LiveChatTranscript
            WHERE ContactId != NULL
            LIMIT 1
        ];
        List<User> testUser = [SELECT Id, ContactId FROM User WHERE Id = :transcriptList[0].Context_User_Id__c LIMIT 1];
        List<Contact> testContact = [SELECT Id FROM Contact WHERE Id = :transcriptList[0].ContactId LIMIT 1];

        final String CUST_SIGNIN_STRING_AUTH =
            '{"[CUST-SIGNIN-STATUS]":{"customerId":"' +
            String.valueOf(transcriptList[0].ContactId) +
            '","ActionType":"login","AuthStatus":"authenticated","Name":" ","ActionId":1664375737201},"ChatKey":"' +
            transcriptList[0].ChatKey +
            '"}';
        Map<String, Object> signinObject = (Map<String, Object>) JSON.deserializeUntyped(CUST_SIGNIN_STRING_AUTH);
        Map<String, Object> signinPayload = (Map<String, Object>) signinObject.get('[CUST-SIGNIN-STATUS]');

        responseInput.contextUserId = testUser[0].Id;
        responseInput.contactId = testContact[0].Id;

        signinPayload.put('customerId', testUser[0].id);
        signinPayload.put('contactId', testContact[0].Id);
        signinPayload.put('chatKey', transcriptList[0].ChatKey);
        signinObject.put('[CUST-SIGNIN-STATUS]', signinPayload);

        responseInput.lastCustomerInput = JSON.serialize(signinObject);

        request.add(responseInput);

        transcriptList[0].ContactId = null;
        transcriptList[0].Context_User_Id__c = null;
        update transcriptList[0];

        Test.startTest();
        System.runAs(ctbotUser) {
            response = ChatbotEmbeddedServiceMsgHandler.processMessage(request);
        }

        List<LiveChatTranscript> updatedTranscriptList = [
            SELECT Id, ContactId, Context_User_Id__c
            FROM LiveChatTranscript
            WHERE Id = :transcriptList[0].Id
        ];

        Test.stopTest();

        System.assertEquals(
            responseInput.contextUserId,
            updatedTranscriptList[0].Context_User_Id__c,
            'Expected the userId to be written to the transcript but it was not'
        );
        System.assertEquals(
            responseInput.contactId,
            updatedTranscriptList[0].ContactId,
            'Expected the Contact Id to be written to the transcript but it was not'
        );
    }

    @isTest
    static void preserveContextDataTest() {
        List<LiveChatTranscript> transcriptList = [
            SELECT Id, Context_User_Id__c, ContactId
            FROM LiveChatTranscript
            WHERE ContactId != NULL
            LIMIT 1
        ];
        List<Contact> testContact = [SELECT Id FROM Contact LIMIT 1];
        List<User> testUser = [SELECT Id, ContactId FROM User LIMIT 1];

        responseInput.contextUserId = testUser[0].Id;
        responseInput.contactId = transcriptList[0].ContactId;
        request.add(responseInput);

        System.assertEquals(
            1,
            transcriptList.size(),
            'Expected only one test transcript to be returned but more than one was.  Check your test data generation'
        );
        System.assertEquals(
            1,
            testUser.size(),
            'Expected only 1 user to be returned but more were.  Check your test data'
        );

        Test.startTest();
        System.runAs(ctbotUser) {
            response = ChatbotEmbeddedServiceMsgHandler.processMessage(request);
        }
        Test.stopTest();

        System.assertEquals(
            testUser[0].Id,
            response[0].contextUserId,
            'Expected the userID to persist, but it did not'
        );
        System.assertEquals(
            testContact[0].Id,
            response[0].contactId,
            'Expected the ContactId to persist, but it did not'
        );
    }

    @isTest
    static void siteCoreInitTest() {
        responseInput.lastCustomerInput = ChatbotEmbeddedServiceMsgHandlerTest.SITECORE_INIT_STRING;
        request.add(responseInput);

        Test.startTest();
        System.runAs(ctbotUser) {
            response = ChatbotEmbeddedServiceMsgHandler.processMessage(request);
        }
        Test.stopTest();

        System.assertEquals(
            SITECORE_INIT_EVT,
            response[0].dialogName,
            'Expected the dialogName to be that which is provided from the embedded service but it was not.'
        );
        System.assertEquals(
            false,
            response[0].isConfused,
            'Expected confused state to be set to false, but it was not'
        );
    }

    @isTest
    static void signinStatusTest() {
        Map<String, Object> signinObject = (Map<String, Object>) JSON.deserializeUntyped(CUST_SIGNIN_STRING);
        Map<String, Object> signinPayload = (Map<String, Object>) signinObject.get('[CUST-SIGNIN-STATUS]');

        List<LiveChatTranscript> transcriptList = [
            SELECT Id, Context_User_Id__c, ChatKey, ContactId
            FROM LiveChatTranscript
            LIMIT 1
        ];
        List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :transcriptList[0].Context_User_Id__c];

        System.assertEquals(
            1,
            userList.size(),
            'Expected only 1 user to be returned but 0 or more than 1 were.  Check test data generation'
        );
        System.assertEquals(
            1,
            transcriptList.size(),
            'Expected only one test transcript to be returned but more than one was.  Check your test data generation'
        );

        signinPayload.put('customerId', transcriptList[0].Context_User_Id__c);
        signinPayload.put('chatKey', transcriptList[0].ChatKey);

        signinObject.put('[CUST-SIGNIN-STATUS]', signinPayload);

        responseInput.lastCustomerInput = JSON.serialize(signinObject);
        request.add(responseInput);

        Test.startTest();
        System.runAs(ctbotUser) {
            response = ChatbotEmbeddedServiceMsgHandler.processMessage(request);
        }
        Test.stopTest();

        System.assertEquals(
            userList[0].Id,
            response[0].contextUserId,
            'Expected the contedxtUserId to match the running userId but it did not'
        );
        System.assertEquals(
            false,
            response[0].isConfused,
            'Expected the confused state to be set to false, but it was not.'
        );
        System.assertEquals(
            userList[0].Id,
            response[0].contextUserRecord.Id,
            'Expected the response to contain the user record for the id passed in, but it did not'
        );
    }
}