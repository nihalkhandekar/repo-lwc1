public with sharing class CTBOT_SitecoreArticleSearchById {

    private static final String ID_END = '~ID_END~';
    
    @InvocableMethod(label='Search for a specific article in Sitecore')
    public static List<Output> searchById(List<Input> inputs) {
        Integer counter = inputs[0].displayCount; 
        Integer displayFrequency = inputs[0].displayFrequency;
        Output output = new Output();
        output.buttons = new List<CTBOT_SitecoreAPIService.RelatedItem>();
        List<String> otherMenuOptions = inputs[0].otherOptions == null ? null : inputs[0].otherOptions.split(',,');
        List<String> finalMenuOptions = inputs[0].finalOptions == null ? null : inputs[0].finalOptions.split(',,');
        CTBOT_SitecoreAPIService.SitecoreItem itemToReturn = new CTBOT_SitecoreAPIService.SitecoreItem();
        List<CTBOT_SitecoreAPIService.RelatedItem> buttons = new List<CTBOT_SitecoreAPIService.RelatedItem>();
        CTBOT_SitecoreAPIService.RequestType request = CTBOT_SitecoreAPIService.RequestType.CONTENT_ID;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();
        Boolean finalOptionsAdded = false;
        paramObject.contentId = inputs[0].articleId == null ? inputs[0].relatedItem?.id : inputs[0].articleId;
        paramObject.routableId = inputs[0].routableId;
        CTBOT_SitecoreAPIService.initializeSitecoreService(request, paramObject);
        HttpResponse response = CTBOT_SitecoreAPIService.sendRequest();
        String responseBody = response.getBody();
        CTBOT_SitecoreAPIService.SitecoreResponse parsedResponse = (CTBOT_SitecoreAPIService.SitecoreResponse)JSON.deserialize(responseBody, CTBOT_SitecoreAPIService.SitecoreResponse.class);
        if (parsedResponse?.items != null) {
            CTBOT_SitecoreAPIService.SitecoreItem firstResult = parsedResponse.items[0];
            firstResult.chatbotContent = firstResult.chatbotContent;
            firstResult.chatbotContent = firstResult.id + ID_END + firstResult.chatbotContent;
            output.sitecoreItem = firstResult;
            if (firstResult.relatedItems != null) {
                output.buttons = firstResult.relatedItems;
                String articleTitles = '';
                for (CTBOT_SitecoreAPIService.RelatedItem article : firstResult.relatedItems) {
                    articleTitles = articleTitles + article.chatbotTitle + ',,';
                }
                articleTitles = articleTitles.removeEnd(',,');
                output.articleTitlesToCompare = articleTitles;
                output.relatedArticlesFound = true;
            } else {
                output.buttons = finalMenuOptions == null ? null : addOptions(finalMenuOptions);
                output.relatedArticlesFound = false;
                finalOptionsAdded = true;
            }
            output.articleContent = firstResult.chatbotContent;
        }

        if (!finalOptionsAdded && displayFrequency != null && counter == displayFrequency && otherMenuOptions != null) {
            output.buttons.addAll(addOptions(otherMenuOptions));
        }

        output.mainMenuDisplayFrequency = inputs[0]?.displayFrequency;

        return new List<Output>{ output };
    }

    public static List<CTBOT_SitecoreAPIService.RelatedItem> addOptions(List<String> options) {
        List<CTBOT_SitecoreAPIService.RelatedItem> optionsToReturn = new List<CTBOT_SitecoreAPIService.RelatedItem>();
        for (String option : options) {
            CTBOT_SitecoreAPIService.RelatedItem extraOption = new CTBOT_SitecoreAPIService.RelatedItem();
            extraOption.chatbotTitle = option.trim();
            optionsToReturn.add(extraOption);
        }
        return optionsToReturn;
    }

    public class Input {
        @InvocableVariable(label='Article ID' description='The unique article ID in Sitecore' required=false)
        public String articleId;

        @InvocableVariable(label='Related Sitecore Article' description='A related article selection' required=false)
        public CTBOT_SitecoreAPIService.RelatedItem relatedItem;

        @InvocableVariable(label='Other Menu Options' description='Options to display at the end of the list of articles returned' required=false)
        public String otherOptions;

        @InvocableVariable(label='Final Menu Options' description='Options to display when there are no more related articles' required=false)
        public String finalOptions;

        @InvocableVariable(label='Main Menu Display Counter' description='Determines whether to display the Main Menu and other options above' required=false)
        public Integer displayCount;

        @InvocableVariable(label='Display Main Menu Every X' description='How frequently the Main Menu and other options should appear' required=false)
        public Integer displayFrequency;

        @InvocableVariable(label='RoutableId' description='The ID of the chat transcript')
        public Id routableId;
    }

    public class Output {
        @InvocableVariable(label='Returned Sitecore Article' description='The article from Sitecore')
        public CTBOT_SitecoreAPIService.SitecoreItem sitecoreItem;

        @InvocableVariable(label='Related Sitecore Articles' description='A list of related articles')
        public List<CTBOT_SitecoreAPIService.RelatedItem> buttons;

        @InvocableVariable(label='Articles To Compare' description='Related articles to compare with user selection')
        public String articleTitlesToCompare;

        @InvocableVariable(label='Related Articles Found' description='Indicates whether or not related content has been found')
        public Boolean relatedArticlesFound;

        @InvocableVariable(label='Main Menu Display Frequency' description='How frequently the Main Menu and other options should appear')
        public Integer mainMenuDisplayFrequency;

        @InvocableVariable(label='Article Content' description='Content for the article returned if content exists')
        public String articleContent;
    }
}