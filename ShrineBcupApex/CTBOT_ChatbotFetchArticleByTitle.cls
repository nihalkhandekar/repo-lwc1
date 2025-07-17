/**
 * @name        : CTBOT_ChatbotFetchArticleByTitle
 * @description : Contains a single Invocable method to retrieve a single article by title
 * @depends     : Knowledge, CTBOT User with Permission set - CTBOT Service Permissions
 * @author      : Slalom
 * @createddate : 11/2020
 * @Modification log:
 * 
 **/
public with sharing class CTBOT_ChatbotFetchArticleByTitle {
    @InvocableMethod(label='Step 1: Fetch a single knowledge article for Chatbot')
    public static List<ResponsesOutput> getKnowledgeArticles(List<ResponsesInput> responsesInput){
        List<ResponsesOutput> toReturn = new List<ResponsesOutput>();
        List<Knowledge__kav> theArticles = new List<Knowledge__kav>();

        if(!String.isBlank(responsesInput[0].title)){
            if(String.escapeSingleQuotes(responsesInput[0].title) == 'Get Support' && !String.isBlank(responsesInput[0].agencyOrigination)){
                theArticles = Database.query(CTBOT_Utilities.buildArticleQuery('WHERE DialogTag__c LIKE \'%' + responsesInput[0].title + '%\'' + ' AND RelatedAgency__c = \'' + responsesInput[0].agencyOrigination + '\''));
            }else{
                theArticles = Database.query(CTBOT_Utilities.buildArticleQuery('WHERE Title = \'' + String.escapeSingleQuotes(responsesInput[0].title) + '\''));
    
            }
        }
        ResponsesOutput theOutput = new ResponsesOutput();
        theOutput.theArticles = theArticles;
        toReturn.add(theOutput);

        return toReturn;
    }

    public class ResponsesInput {
        @InvocableVariable(label='Title of the article to display content body' description='Change Source to Value then populate Custom Value with the Title of the Article you want displayed as content when the user arrives here.' required=true)
        public String title;
        @InvocableVariable(label='Agency Origination (optional)' required=false)
        public String agencyOrigination;
    }

    public class ResponsesOutput {
        @InvocableVariable
        public List<Knowledge__kav> theArticles;
    }
}