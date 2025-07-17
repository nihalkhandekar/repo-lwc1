@isTest
public class CTBOT_GetUserIdFromTranscriptTest {
    private static final String MALFORMED_TRANSCRIPT_ID = 'sadjklf*&^dsflk3';
    private static final String ORIGINATION_URL = 'test.origination.url.gov';
    
    private static CTBOT_GetUserIdFromTranscript.RequestInput requestInput = new CTBOT_GetUserIdFromTranscript.RequestInput();
    private static CTBOT_GetUserIdFromTranscript.RequestOutput requestOutput = new CTBOT_GetUserIdFromTranscript.RequestOutput();
    private static List<CTBOT_GetUserIdFromTranscript.RequestInput> request = new List<CTBOT_GetUserIdFromTranscript.RequestInput>();
    private static List<CTBOT_GetUserIdFromTranscript.RequestOutput> response = new List<CTBOT_GetUserIdFromTranscript.RequestOutput>();

    @TestSetup
    static void makeData(){

        //Create test Transcript needed.
        String chatKey = CTBOT_TestDataFactory.createTestChatTranscript(ORIGINATION_URL);
    }

    //Makes sure ifa malformed Id is passed in, an empty string is still returned so the bot does not end the chat
    @isTest 
    static void invalidTranscriptIdTest(){
        
        Boolean exceptionCaught = false;
        
        requestInput.transcriptId = MALFORMED_TRANSCRIPT_ID;
        request.add(requestInput);

        test.startTest();
        response = CTBOT_GetUserIdFromTranscript.getUserIdFromTranscript(request);
        test.stopTest();

        System.assertEquals('', response[0].contextUserId, 'Expected \'\' to be returned but got' + response[0].contextUserId);
    }

    //Makes sure the correct user Id is returned.
    @isTest 
    static void getUserIdFromTranscriptTest(){        
        LiveChatTranscript transcript = [SELECT Id, Context_User_Id__c FROM LiveChatTranscript LIMIT 1];
        transcript.Context_User_Id__c = UserInfo.getUserId();
        update transcript;

        System.debug('Transcript: ' + JSON.serialize(transcript));
        
        requestInput.transcriptId = transcript.Id;
        request.add(requestInput);

        Test.startTest();
        response = CTBOT_GetUserIdFromTranscript.getUserIdFromTranscript(request);
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), response[0].contextUserId, 'Expected the id returned to match the running user, but it did not.');
    }

    @isTest 
    static void idReturnedZeroTranscriptRecordsTEst(){
        LiveChatTranscript transcript = [SELECT Id, ChatKey, Context_User_Id__c FROM LiveChatTranscript LIMIT 1];
        String transcriptId = transcript.Id;
        String chatKey = transcript.ChatKey;
        delete transcript;

        String contextUserId = null;

        requestInput.transcriptId = chatKey;
        request.add(requestInput);

        Test.startTest();
        response = CTBOT_GetUserIdFromTranscript.getUserIdFromTranscript(request);
        Test.stopTest();

        System.assertEquals('', response[0].contextUserId, 'Expected to get an empty string back because the transcript was deleted, but the string was not empty.');
    }

    @isTest
    static void runAsBotIntegrationUserTest(){
        //ToDo write a test that runs as the bot user (the context user for Robin) 
        //so we can tell if it's permission to the apex class has been reduced by mistake
    }
}