public without sharing class ChatbotEmbeddedServiceMsgHandler {
    @testVisible
    static final String SITECORE_INIT_MSG = '[REDIR-DLOG-MSG]';
    @testVisible
    static final String CUST_SIGNIN_STATUS = '[CUST-SIGNIN-STATUS]';

    @InvocableMethod(label='Process Confused Last Customer Input')
    public static List<ResponseOutput> processMessage(List<ResponseInput> responseInput) {
        ResponseOutput output = new ResponseOutput();
        String chasitorMsg = (String.isNotBlank(responseInput[0].lastCustomerInput)
            ? responseInput[0].lastCustomerInput
            : ''); //.replace('\"', '')
        //If a contextUserId was passed in from the Bot, set the output so it is not cleared by the apex action.
        if (!String.isBlank(responseInput[0].contextUserId)) {
            output.contextUserId = responseInput[0].contextUserId;
        }
        //If prechat contact was set, set the output so it is not cleared by the apex action.
        if (!String.isBlank(responseInput[0].contactId)) {
            output.contactId = responseInput[0].contactId;
        }
        //if the bot is aware of a context user, make sure we don't lose it in confused state.
        if ((responseInput[0].contextUserRecord != null) && String.isNotBlank(responseInput[0].contextUserRecord.Id)) {
            output.contextUserRecord = responseInput[0].contextUserRecord;
        }

        //Process sitecore init string
        if (chasitorMsg.contains(SITECORE_INIT_MSG)) {
            output.isConfused = false;
            // Deserialize message from site
            Object result = JSON.deserializeUntyped(chasitorMsg);

            if (result instanceof Map<String, Object>) {
                Map<String, Object> resultMap = (Map<String, Object>) result;
                Map<String, Object> data = (Map<String, Object>) resultMap.get(SITECORE_INIT_MSG);

                output.dialogName = (String) data.get('redir-dlog');
            }
            //Process Auth string
        } else if (chasitorMsg.contains(CUST_SIGNIN_STATUS)) {
            Object message = JSON.deserializeUntyped(chasitorMsg);
            Map<String, Object> data = (Map<String, Object>) message;
            Map<String, Object> payload = (Map<String, Object>) data.get(CUST_SIGNIN_STATUS);

            output.isConfused = false;
            output.contextUserId = String.isNotEmpty((String) payload.get('customerId'))
                ? (String) payload.get('customerId')
                : '';
            output.dialogName = String.isNotEmpty((String) payload.get('ActionType'))
                ? (String) payload.get('ActionType')
                : '';

            if (String.isNotBlank(output.contextUserId)) {
                output.contextUserRecord = [
                    SELECT Id, FirstName, LastName, UserName, ContactId
                    FROM User
                    WHERE Id = :output.contextUserId
                ];
            }

            //Experimental update transcript contact.
            output.contactId = String.isNotEmpty(output.contextUserId)
                ? getContactIdForContextUser(output.contextUserId)
                : '';
            if (String.isNotEmpty(output.contactId) && !String.isBlank((String) data.get('ChatKey'))) {
                List<LiveChatTranscript> transcriptList = getTranscriptByChatKey((String) data.get('ChatKey'));
                if (!transcriptList.isEmpty()) {
                    transcriptList[0].ContactId = output.contactId;
                    if (!String.isBlank(output.contextUserId) && String.isBlank(transcriptList[0].Context_User_Id__c)) {
                        transcriptList[0].Context_User_Id__c = output.contextUserId;
                    }

                    update transcriptList[0];
                }
            }
        } else {
            output.isConfused = true;
        }

        return new List<ResponseOutput>{ output };
    }

    //Gets ContactId for the context user
    @testVisible
    private static String getContactIdForContextUser(String contextUserId) {
        try {
            return [SELECT Id, ContactId FROM User WHERE Id = :contextUserId].ContactId;
        } catch (QueryException e) {
            return '';
        }
    }

    //Gets the transcript for the chat session
    @testVisible
    private static List<LiveChatTranscript> getTranscriptByChatKey(String chatKey) {
        List<LiveChatTranscript> transcriptList = new List<LiveChatTranscript>();
        transcriptList = [
            SELECT Id, ContactId, Context_User_Id__c, ChatKey
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey
        ];
        return transcriptList;
    }

    public class ResponseInput {
        @InvocableVariable(
            label='Context User Id'
            description='Pass the \'UserId\' variable in here so it is not cleared'
            required=false
        )
        public String contextUserId;
        @InvocableVariable(
            label='Contact Id'
            description='Pass the \'ContactId\' variable in here so it is not cleared'
            required=false
        )
        public String contactId;
        @InvocableVariable(required=false)
        public String lastCustomerInput;
        @InvocableVariable(
            label='Context User Record'
            description='If the bot is aware of a context user, pass it in here'
            required=false
        )
        public User contextUserRecord;
    }

    public class ResponseOutput {
        @InvocableVariable(required=true)
        public Boolean isConfused;
        @InvocableVariable(required=false)
        public String dialogName;
        @InvocableVariable(
            label='Context User Id'
            description='If provided, the id of the context user will be here.'
            required=false
        )
        public String contextUserId;
        @InvocableVariable(
            label='Contact Id'
            description='The Contact identified on the context user\'s User-Record'
            Required=false
        )
        public String contactId;
        @InvocableVariable(
            label='User Record'
            description='If authenticated, the user record is returned for the bot to use as needed'
            required=false
        )
        public User contextUserRecord;
    }
}