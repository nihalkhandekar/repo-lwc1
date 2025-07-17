@isTest
public with sharing class CTBOT_SitecoreAPIService_TEST {

    private static final User ctbotUser = [SELECT Id FROM User
        WHERE FederationIdentifier = 'ctbot.user@ct.gov.ctds' AND IsActive = TRUE AND UserType = 'Standard'
        LIMIT 1];

    @testSetup
    static void makeData() {
        CTBOT_TestDataFactory.createTestChatTranscript('https://www.test.com');
    }

    @isTest
    static void testInitializeSitecoreServiceExceptions() {
        
        //Set of request types we expect to have an exception for the given params

        List<CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem> feedbackList = new List<CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem>();
        feedbackList.add(new CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem());

        //param object to pass unti method under test
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();

        //itterate over request types.
        for(CTBOT_SitecoreAPIService.RequestType type : CTBOT_SitecoreAPIService.RequestType.values()){
            if(type == CTBOT_SitecoreAPIService.RequestType.CONFUSED){
                continue;
            }
            
            //set up data for testing and checking results
            String exceptionThrown = null;

            paramObject.keywords = 'not null';
            paramObject.category = 'not null';
            paramObject.contentId = (type == CTBOT_SitecoreAPIService.RequestType.CONTENT_ID) ? '' : 'not null';
            paramObject.numberOfResults = 1;
            paramObject.pageSize = '1';
            paramObject.feedbackRequest = (type == CTBOT_SitecoreAPIService.RequestType.FEEDBACK) ? null : feedbackList;

            //call method under test and if an exception is thrown, store it so we can make sure the RIGHT exception was thrown
            try {
                CTBOT_SitecoreAPIService.initializeSitecoreService(type, paramObject);

            } catch (CTBOT_SitecoreAPIService.SitecoreAPIServiceException e) {
                exceptionThrown = e.getMessage();
            }

            //Check that an exception was thrown AND that the exception was thrown fro the right reason.
            System.assertNotEquals(null, exceptionThrown, 'Expected an exception to be thrown for ' + type + ' but no exception was thrown');
            System.assertEquals(true, exceptionThrown.contains('passed to'), 'An exception was thrown, but for the wrong reasn. ' + exceptionThrown);
        }
    }

    @isTest
    static void testGetMetadataRecordsException() {
        try {
            CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
            Test.setMock(HttpCalloutMock.class, mockInstance);
            System.runAs(ctbotUser) {
                Test.startTest();
                CTBOT_SitecoreAPIService.initializeSitecoreService(null, null);
                Test.stopTest();
            }
        } catch (CTBOT_SitecoreAPIService.SitecoreAPIServiceException e) {
            System.assertEquals('No metadata records found for Sitecore service.', e.getMessage());
        }
    }

    @isTest
    static void testGetSessionToken() {
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        Test.setMock(HttpCalloutMock.class, mockInstance);
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreService(null, null);
            System.assertEquals('Test Metadata', CTBOT_SitecoreAPIService.metadataRecord.MasterLabel);
            Test.stopTest();
        }

        mockInstance.returnError = true;
        try {
            CTBOT_SitecoreAPIService.initializeSitecoreService(null, null);
        } catch (CTBOT_SitecoreAPIService.SitecoreAPIServiceException e) {
            System.assert(e.getMessage().contains('Error from Sitecore authorization endpoint with status code of 404'));
        }
    }

    @isTest
    static void testFormatConfusedRequest() {
        CTBOT_SitecoreAPIService.RequestType confusedType = CTBOT_SitecoreAPIService.RequestType.CONFUSED;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();

        paramObject.keywords = 'test+keywords';
        paramObject.numberOfResults = 3;
        Test.setMock(HttpCalloutMock.class, mockInstance);
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreService(confusedType, paramObject);
            HttpRequest testRequest = CTBOT_SitecoreAPIService.formatRequest();
            Test.stopTest();
            System.assert(testRequest.getEndpoint().contains('https://www.test.com/confused?keyword=test+keywords'));
            System.assertEquals('GET', testRequest.getMethod());
            System.assert(testRequest.getHeader('Authorization').contains('Bearer'));
            System.assertEquals('application/x-www-form-urlencoded', testRequest.getHeader('Content-Type'));
        }
    }

    @isTest
    static void testFormatContentIdRequest() {
        CTBOT_SitecoreAPIService.RequestType contentIdType = CTBOT_SitecoreAPIService.RequestType.CONTENT_ID;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();

        paramObject.contentId = 'testId';
        Test.setMock(HttpCalloutMock.class, mockInstance);
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreService(contentIdType, paramObject);
            HttpRequest testRequest = CTBOT_SitecoreAPIService.formatRequest();
            Test.stopTest();
            System.assertEquals(testRequest.getEndpoint(), 'https://www.test.com/ContentId/testId');
            System.assertEquals('GET', testRequest.getMethod());
            System.assert(testRequest.getHeader('Authorization').contains('Bearer'));
            System.assertEquals('application/x-www-form-urlencoded', testRequest.getHeader('Content-Type'));
        }
    }

    @isTest
    static void testFormatFeedbackRequest() {
        CTBOT_SitecoreAPIService.RequestType feedbackType = CTBOT_SitecoreAPIService.RequestType.FEEDBACK;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem testItem = new CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem();
        List<CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem> testFeedbackItems = new List<CTBOT_SitecoreArticleFeedback.SitecoreFeedbackItem>();
        
        testItem.KbArticleId = '{testid}';
        testItem.ArticleRatingChange = 1;
        testFeedbackItems.add(testItem);
        paramObject.feedbackRequest = testFeedbackItems;
        Test.setMock(HttpCalloutMock.class, mockInstance);
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreService(feedbackType, paramObject);
            HttpRequest testRequest = CTBOT_SitecoreAPIService.formatRequest();
            Test.stopTest();
            System.assertEquals(testRequest.getEndpoint(), 'https://www.test.com/feedback');
            System.assertEquals('POST', testRequest.getMethod());
            System.assert(testRequest.getHeader('Authorization').contains('Bearer'));
            System.assertEquals('application/json', testRequest.getHeader('Content-Type'));
        }
    }

    @isTest
    static void testSendRequest() {
        CTBOT_SitecoreAPIService.RequestType contentIdType = CTBOT_SitecoreAPIService.RequestType.CONTENT_ID;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();

        Test.setMock(HttpCalloutMock.class, mockInstance);
        paramObject.contentId = 'testId';
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreService(contentIdType, paramObject);
            HttpResponse testResponse = CTBOT_SitecoreAPIService.sendRequest();
            Test.stopTest();
            System.assertEquals(200, testResponse.getStatusCode());
        }
    }

    @isTest
    static void testHandleResult() {
        CTBOT_SitecoreAPIService testService = new CTBOT_SitecoreAPIService();
        Metadata.DeployCallbackContext testContext = new Metadata.DeployCallbackContext();
        Metadata.DeployResult testResultSuccess = new Metadata.DeployResult();
        testResultSuccess.status = Metadata.DeployStatus.SUCCEEDED;
        Metadata.DeployResult testResultFail = new Metadata.DeployResult();
        testResultFail.status = Metadata.DeployStatus.FAILED;

        testService.handleResult(testResultSuccess, testContext);
        try {
            testService.handleResult(testResultFail, testContext);
        } catch (CTBOT_SitecoreAPIService.SitecoreAPIServiceException e) {
            System.assert(e.getMessage().contains('Error updating custom metadata'));
        }
    }

    @isTest
    private static void testInitializeSitecoreServiceBatch() {
        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        Test.setMock(HttpCalloutMock.class, mockInstance);
        System.runAs(ctbotUser) {
            Test.startTest();
            CTBOT_SitecoreAPIService.initializeSitecoreServiceBatch();
            Test.stopTest();
        }
   }
}