@isTest
private class CTBOT_ChatbotGetAgencyOrigination_TEST {

    private static final User ctbotUser = [SELECT Id FROM User
        WHERE FederationIdentifier = 'ctbot.user@ct.gov.ctds' AND IsActive = TRUE AND UserType = 'Standard'
        LIMIT 1
    ];

    @isTest
    static void getAgencyOriginationBOS() {
        String agency = 'BOS';
        String originationUrl = System.Label.CTBOT_Chatbot_Environment != 'PROD'
            ? Bot_Agency_Origination__mdt.getInstance(agency).Origination_Test_URL__c
            : Bot_Agency_Origination__mdt.getInstance(agency).Origination_URL__c;
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript(originationUrl);

        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput> outputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput>();
        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput> inputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput>();

        CTBOT_ChatbotGetAgencyOrigination.ResponsesInput input = new CTBOT_ChatbotGetAgencyOrigination.ResponsesInput();
        input.chatKey = testChatKey;
        inputList.add(input);

        Test.startTest();
        System.runAs(ctbotUser) {
            outputList = CTBOT_ChatbotGetAgencyOrigination.getAgencyOrigination(inputList);
        }
        Test.stopTest();

        System.assertEquals(agency, outputList[0].agencyOrigination);
    }

    @isTest
    // Fails Test
    static void getAgencyOriginationOtherUnknown() {
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript('https://portal.ct.gov');

        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput> outputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput>();
        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput> inputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput>();

        CTBOT_ChatbotGetAgencyOrigination.ResponsesInput input = new CTBOT_ChatbotGetAgencyOrigination.ResponsesInput();
        input.chatKey = testChatKey;
        inputList.add(input);

        Test.startTest();
        System.runAs(ctbotUser) {
            outputList = CTBOT_ChatbotGetAgencyOrigination.getAgencyOrigination(inputList);
        }
        Test.stopTest();

        System.assertEquals(null, outputList[0].agencyOrigination);
    }

    @isTest
    static void testDCPAgencyWithAlternateDivisionIDs() {
        String originationUrl = '';
        if (System.Label.CTBOT_Chatbot_Environment != 'PROD') {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance('DCP').Origination_Test_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance('DCP').Agency_Subdirectory__c +
                '/' +
                Bot_Agency_Division__mdt.getInstance('Food_and_Standards_Division').Division_URL__c +
                '/Food--Standards/File-a-Complaint';
        } else {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance('DCP').Origination_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance('DCP').Agency_Subdirectory__c +
                '/' +
                Bot_Agency_Division__mdt.getInstance('Food_and_Standards_Division').Division_URL__c +
                '/Food--Standards/File-a-Complaint';
        }
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript(originationUrl);

        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput> outputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput>();
        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput> inputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput>();
        CTBOT_ChatbotGetAgencyOrigination.ResponsesInput input = new CTBOT_ChatbotGetAgencyOrigination.ResponsesInput();
        input.chatKey = testChatKey;
        inputList.add(input);

        Test.startTest();
        System.runAs(ctbotUser) {
            outputList = CTBOT_ChatbotGetAgencyOrigination.getAgencyOrigination(inputList);
        }
        Test.stopTest();

        System.assertEquals('Food and Standards', outputList[0].DCP_Division);
    }

    @isTest
    static void testDCPAgencyWithSingleDivisionID() {
        String originationUrl = '';
        if (System.Label.CTBOT_Chatbot_Environment != 'PROD') {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance('DCP').Origination_Test_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance('DCP').Agency_Subdirectory__c +
                '/' +
                Bot_Agency_Division__mdt.getInstance('Gaming_Division').Division_URL__c;
        } else {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance('DCP').Origination_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance('DCP').Agency_Subdirectory__c +
                '/' +
                Bot_Agency_Division__mdt.getInstance('Gaming_Division').Division_URL__c;
        }
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript(originationUrl);

        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput> outputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput>();
        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput> inputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput>();
        CTBOT_ChatbotGetAgencyOrigination.ResponsesInput input = new CTBOT_ChatbotGetAgencyOrigination.ResponsesInput();
        input.chatKey = testChatKey;
        inputList.add(input);

        Test.startTest();
        System.runAs(ctbotUser) {
            outputList = CTBOT_ChatbotGetAgencyOrigination.getAgencyOrigination(inputList);
        }
        Test.stopTest();

        System.assertEquals('Gaming', outputList[0].DCP_Division);
    }

    @isTest
    static void testDivisionUrlLikeAgency() {
        String originationUrl = '';
        String agency = 'Cannabis';
        if (System.Label.CTBOT_Chatbot_Environment != 'PROD') {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance(agency).Origination_Test_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance(agency).Agency_Subdirectory__c;
        } else {
            originationUrl =
                Bot_Agency_Origination__mdt.getInstance(agency).Origination_URL__c +
                '/' +
                Bot_Agency_Origination__mdt.getInstance(agency).Agency_Subdirectory__c;
        }
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript(originationUrl);

        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput> outputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesOutput>();
        List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput> inputList = new List<CTBOT_ChatbotGetAgencyOrigination.ResponsesInput>();
        CTBOT_ChatbotGetAgencyOrigination.ResponsesInput input = new CTBOT_ChatbotGetAgencyOrigination.ResponsesInput();
        input.chatKey = testChatKey;
        inputList.add(input);

        Test.startTest();
        System.runAs(ctbotUser) {
            outputList = CTBOT_ChatbotGetAgencyOrigination.getAgencyOrigination(inputList);
        }
        Test.stopTest();

        System.assertEquals(agency, outputList[0].agencyOrigination);
    }
}