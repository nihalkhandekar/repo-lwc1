public without sharing class CTBOT_GetUserIdFromTranscript {
    //Transcript fields to be retrieved when a transcript record is requrested
    static final String TRANSCRIPT_FIELDS = 'Id, Context_User_Id__c, ContactId';
    
    //Either gets a transcript, or sets a transcript dependeing on if an Id or object is provided
    @invocableMethod(label='Get User and Contact Id From Transcript')
    public static List<RequestOutput> getUserIdFromTranscript(List<RequestInput> requestInput){

        //pull the element we need out and set up useful variables
        RequestInput request = requestInput[0];
        RequestOutput output = new RequestOutput();

        //Make sure the bot provided a transcriptId
        if(String.isNotBlank(request.transcriptId)){
            //Set some useful variables, escapte single quotes on query input for security
            List<LiveChatTranscript> transcriptList = new List<LiveChatTranscript>();
            String escapedTranscriptId = String.escapeSingleQuotes(request.transcriptId);

            //Generate the query string needed to get the transcript requested
            String queryString = 'SELECT ' + TRANSCRIPT_FIELDS + ' FROM LiveChatTranscript WHERE Id = :escapedTranscriptId'; 
            
            try{
                //Get the transcript
                transcriptList = Database.query(queryString);
            }catch(QueryException qe){
                //swallow the exception.  The input was probably blank on purpose.
            }

            
            //Check if the query returned anything.  If empty, the Id was malformed or jsut does not exist.
            if(!transcriptList.isEmpty()){
                //Set the transcript in the response output
                output.contextUserId = transcriptList[0].Context_User_Id__c;
                output.contactId = transcriptList[0].ContactId;
            }else{
                output.contextUserId = '';
                output.contactId = '';
            }
        }

        List<RequestOutput> requestOutput = new List<requestOutput>();
        requestOutput.add(output);
        return requestOutput;
    }

    //Pass in a transcript object to set the related transcript record.  Leave blank to retrieve it/
    public class RequestInput{
        @InvocableVariable(label='Routable Id' description='This is the Id of the transcript for the current chat session' required=false)
        public String transcriptId;
    }

    //The action will return the contextUserId if one is found on the transcript record.
    public class RequestOutput{
        @InvocableVariable(label='Context User Id' description='If the UserId is populated on the transcript, it will be returned here' required=false)
        public String contextUserId;

        @InvocableVariable(label='Contact Id' description='If the UserId is populated on the transcript, this is the related Contact' required=false)
        public String contactId;
    }
}