public without sharing class CTBOT_GetMenuButtonsForRelatedArticles{

    @InvocableMethod(label='Get Menu Buttons' description='Takes in query params and returns list of menu button params')
    public static List<Response> getMenuOptions(List<Request> request){
        try{
            Request thisRequest = request[0];

            //Break params out so we can work with them
            CTBOT_SitecoreConfusedSearch.Input searchParams= new CTBOT_SitecoreConfusedSearch.Input();
            searchParams.agency = thisRequest.agency;
            searchParams.numberOfResults = thisRequest.numberOfResults;
            searchParams.routableId = thisRequest.routableId;
            searchParams.utterance = thisRequest.utterance;

            //Instantiate a list of requests to send to sitecoreSearch
            List<CTBOT_SitecoreConfusedSearch.Input> requestList = new List<CTBOT_SitecoreConfusedSearch.Input>();
            requestList.add(searchParams);

            String keyword = String.isBlank(thisRequest.utterance) ? thisRequest.lastArticleTitle : thisRequest.utterance;

            //Hit the sitecore API.  Pass the result to the getResponse method and return the response.
            if(Test.isRunningTest()){
                //If running test, we cannot make a callout and it's not worth mocking the class.  We just want to test that an exception
                //is handled correctly as the other method is tested individually and thoroughly.
                throw new System.CalloutException('Test Exception thrown');
            }else{
                return getResponse(CTBOT_SitecoreConfusedSearch.searchSitecore(requestList), keyword);
            }
        }catch(System.CalloutException e){

            //Log an error for the event.
            Error_Log__c log = new Error_Log__c();

            log.Application_Type__c = 'BOS';
            log.Class_Name__c = 'CTBOT_SitecoreGetMenuButtonsForRelatedArticles';
            log.Class_Method__c = 'getMenuOptions()';
            log.Error_Message__c = 
                'CTBOT:: The bot experienced an exception while retrieving data from Sitecore via Mulesoft.  \n ' +
                'Exception:: ' + e.getMessage() + '\n';
            log.User_Info__c = UserInfo.getUserId();
            log.Stack_Trace__c = e.getStackTraceString();
            insert log;

            //For Exceptions, return an empty response, and let the bot handle it.
            Response responseLine = new Response();
            responseLine.relatedArticles = new List<CTBOT_SitecoreAPIService.RelatedItem>();
            responseLine.Articles = new List<CTBOT_SitecoreAPIService.SitecoreItem>();
            responseLine.articleContent = 'I\'m sorry, wasn\'t able to retrieve the information you\'re looking for right now. I\'ve let the team know about this error and they\'ll address it soon.';
            responseLine.articleTitle = 'Sitecore Exception';
            responseLine.noArticlesFound = true;
            List<Response> response = new List<Response>();
            response.add(responseLine);
            return response;
        }

    }
    
    public static List<Response> getResponse(List<CTBOT_SitecoreConfusedSearch.Output> searchResponse, String utterance) {
        //Instantiate instances of variables we need to work with
        List<Response> response = new List<Response>();
        Response responseLine = new Response();

        //Get the SitecoreItems we got back from the search
        List<CTBOT_SitecoreAPIService.SitecoreItem> sitecoreItemList = new List<CTBOT_SitecoreAPIService.SitecoreItem>();
        List<CTBOT_SitecoreAPIService.RelatedItem> menuOptionList = new List<CTBOT_SitecoreAPIService.RelatedItem>();

        //If an utterance was provided, we assume this is a mid-chat query
        if(String.isNotBlank(utterance) && searchResponse.size() > 0){
            //Itterate over all articles returned
            for(CTBOT_SitecoreAPIService.SitecoreItem article : searchResponse[0].sitecoreItems){

                //Add the item to the list of articles to send back iwth the response
                sitecoreItemList.add(article);

                //New menuButton to store in response
                CTBOT_SitecoreAPIService.RelatedItem menuOption = new CTBOT_SitecoreAPIService.RelatedItem();
                menuOption.Id = article.Id;
                menuOption.chatbotTitle = article.chatbotTitle;
                menuOptionList.add(menuOption);
            }

            //Add data to response
            responseLine.Articles = sitecoreItemList;
            responseLine.relatedArticles = menuOptionList;
        
            //If an utterance is not provided, we assume this is a start of chat situation and process for welcome details
        }else if(!searchResponse[0].sitecoreItems.isEmpty()){
            //Get the index we care about.  There should only be one in this situation
            System.debug(JSON.serializePretty(searchResponse));
            CTBOT_SitecoreAPIService.SitecoreItem article = searchResponse[0].sitecoreItems[0];

            //Store the data we care about  
            menuOptionList = article.relatedItems;
            responseLine.articleTitle = article.chatbotTitle;
            responseLine.articleContent = article.chatbotContent;
        }

        //If no sitecore articles are returned, set the flag to say so.  
        //The bot needs to act on that flag so users aren't left puzzled.
        if(!searchResponse[0].sitecoreItems.isEmpty()){
            responseLine.Articles = sitecoreItemList;
            responseLine.relatedArticles = menuOptionList;
            responseLine.noArticlesFound = false;
        }else{
            //ToDo: update copy here.
            responseLine.articleTitle = 'No Articles Found :(';
            responseLine.articleContent = 'Unfortunatly, we couldn\'t find anything helpful.';
            responseLine.noArticlesFound = true;
        }

        //Add the line to the response.
        response.add(responseLine);
        
        //Return data to caller.
        return response;
    }

    public class Request {

        @InvocableVariable(label='Utterance' description='The utterance to search Sitecore with' required=false)
        public String utterance;

        @InvocableVariable(label='Last Selected Article Title' description='This will be used when confused is triggered by a menu selection that was not an article... Example: "Get Support"' required=false)
        public String lastArticleTitle;

        @InvocableVariable(label='Origination Agency' description='The agency to filter by' required=true)
        public String agency;
    
        @InvocableVariable(label='Number Of Results' description='Number of results to return from Sitecore' required=true)
        public Integer numberOfResults;
    
        @InvocableVariable(label='RoutableId' description='The ID of the chat transcript' required=true)
        public Id routableId;
    } 

    public class Response {
        @InvocableVariable(label='Menu Options' description='')
        public List<CTBOT_SitecoreAPIService.RelatedItem> relatedArticles;

        @InvocableVariable(label='Articles' description='This will be an empty list if no utternace was provided')
        public List<CTBOT_SitecoreAPIService.SitecoreItem> articles;

        @InvocableVariable(label='Article Content' description='If you are expecting welcome details to come back.  This variable will cntain the welcome messabge')
        public String articleContent;   

        @InvocableVariable(label='Article Title' description='If you are expecting welcome details to come back.  This variale will contain the title for the welcome menu')
        public String articleTitle;

        @InvocableVariable(label='Articles Found?' description='If no menu buttons were created thsi will be false')
        public Boolean noArticlesFound = false;
    }
}