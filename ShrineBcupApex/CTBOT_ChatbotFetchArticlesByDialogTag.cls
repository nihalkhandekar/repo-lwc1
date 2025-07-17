/**
 * @name        : CTBOT_ChatbotFetchArticlesByDialogTag
 * @description : Contains a single Invocable method to retrieve a list of articles by DialogTag
 * @depends     : Knowledge, CTBOT User with Permission set - CTBOT Service Permissions
 * @author      : Slalom
 * @createddate : 11/2020
 * @Modification log:
 * 
    TO-DO:
    - Exception handling
 **/
public with sharing class CTBOT_ChatbotFetchArticlesByDialogTag {
    @InvocableMethod(label='Step 2: Fetch knowledge articles by dialog tag to display as buttons.')
    public static List<ResponsesOutput> getKnowledgeArticles(List<ResponsesInput> responsesInput){
        List<ResponsesOutput> toReturn = new List<ResponsesOutput>();
        List<Knowledge__kav> theArticles = new List<Knowledge__kav>();

        if(!String.isBlank(responsesInput[0].dialogTag)){
            theArticles = Database.query(CTBOT_Utilities.buildArticleQuery('WHERE DialogTag__c LIKE \'%' + String.escapeSingleQuotes(responsesInput[0].dialogTag) + '%\''));
        }
        //system.debug('All articles I can see: ' + [SELECT Id, Title, DialogTag__c FROM Knowledge__kav]);
        ResponsesOutput theOutput = new ResponsesOutput();
        theOutput.theArticles = theArticles;
        toReturn.add(theOutput);

        return toReturn;
    }

    public class ResponsesInput {
        @InvocableVariable(label='Dialog Tag' description='Change Source to Value then populate Custom Value with the 1 Dialog Tag that articles must have to show up as choices.' required=true)
        public String dialogTag;
    }

    public class ResponsesOutput {
        @InvocableVariable
        public List<Knowledge__kav> theArticles;
    }
}