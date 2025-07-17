/**
 * @name        : CTBOT_ChatbotFetchMultipleArticles
 * @description : Contains a single Invocable method to retrieve top 3 articles found by using customer supplied input 
 * that results in an out of domain intent in the chatbot. 
 * @depends     : Knowledge, CTBOT User with Permission set - CTBOT Service Permissions
 * @author      : Slalom
 * @createddate : 11/2020
 * @Modification log:
 * 06/18/2021: CT-BOT-172 single character search issue resolved, try/catch return empty articles array when exception handled
    TO-DO: 
    - Support for promoted search terms
 **/
public with sharing class CTBOT_ChatbotFetchMultipleArticles {
    @InvocableMethod(label='Search the Salesforce Knowledge base with customer input to return the top 3 articles as buttons')
    public static List<ResponsesOutput> getMultipleArticles(List<ResponsesInput> responsesInput){
        ResponsesOutput theOutput = new ResponsesOutput();
        List<ResponsesOutput> toReturn = new List<ResponsesOutput>();
        Id CTBOTKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId();

        //Escape single quotes to prevent injection
        String sKeyword = String.escapeSingleQuotes(responsesInput[0].lastCustomerInput);

       // Build the SOSL query
        String sQuery = 'FIND \'' + sKeyword + '\' IN ALL FIELDS RETURNING Knowledge__kav(Id, Title, UrlName, ArticleBody__c WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND RecordTypeID = \'' + CTBOTKnowledgeRecordTypeId + '\') WITH SNIPPET (target_length=255) LIMIT 3';

        // Perform the SOSL search
        try {
            Search.SearchResults searchResults = Search.find(sQuery);
            // Use search results to get the list of articles
            List<Search.SearchResult> articlelist = new List<Search.SearchResult>();
            articlelist = searchResults.get('Knowledge__kav');
    
            List<Knowledge__kav> articlesFound = new List<Knowledge__kav>();
            // Loop through all the articles to get article info
            for (Search.SearchResult searchResult : articlelist){
                Knowledge__kav article = (Knowledge__kav) searchResult.getSObject();
                articlesFound.add(article);
            }
    
            theOutput.theArticles = articlesFound;
            toReturn.add(theOutput);

        } catch (Exception e) {
            theOutput.theArticles = new List<Knowledge__kav>();
            theOutput.hasErrors = true;
            toReturn.add(theOutput);
        }

        return toReturn;
    }

    public class ResponsesInput {
        @InvocableVariable(required=true)
        public String lastCustomerInput;
    }

    public class ResponsesOutput {
        @InvocableVariable
        public List<Knowledge__kav> theArticles;
        @InvocableVariable
        public Boolean hasErrors;
    }
}