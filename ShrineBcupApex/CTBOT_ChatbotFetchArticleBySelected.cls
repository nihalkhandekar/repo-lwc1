/**
 * @name        : CTBOT_ChatbotFetchArticleBySelected
 * @description : Contains a single Invocable method to retrieve a list of articles that have a DialogTag that matches a previously selected article from the chatbot
 * @depends     : Knowledge, CTBOT User with Permission set - CTBOT Service Permissions
 * @author      : Slalom
 * @createddate : 11/2020
 * @Modification log:
 * 
    TO-DO:
    - Exception handling
 **/
public with sharing class CTBOT_ChatbotFetchArticleBySelected {
    @InvocableMethod(label='Step 3: Fetch knowledge articles where dialog tag contains previously selected article title to display as buttons.')
    public static List<ResponsesOutput> getKnowledgeArticles(List<ResponsesInput> responsesInput){
        List<ResponsesOutput> toReturn = new List<ResponsesOutput>();
        List<Knowledge__kav> theArticles = new List<Knowledge__kav>();

        if(!String.isBlank(responsesInput[0].selectedArticle.Title)){
            theArticles = Database.query(CTBOT_Utilities.buildArticleQuery('WHERE DialogTag__c LIKE \'%' + String.escapeSingleQuotes(responsesInput[0].selectedArticle.Title) + '%\''));
        }

        ResponsesOutput theOutput = new ResponsesOutput();
        theOutput.theArticles = theArticles;
        toReturn.add(theOutput);

        return toReturn;
    }

    public class ResponsesInput {
        @InvocableVariable(label='Find dialog tags that match and display as buttons' description='Set Variable Name to Article (Object).' required=true)
        public Knowledge__kav selectedArticle;
    }

    public class ResponsesOutput {
        @InvocableVariable
        public List<Knowledge__kav> theArticles;
    }
}