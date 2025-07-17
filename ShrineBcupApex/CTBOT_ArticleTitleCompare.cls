public with sharing class CTBOT_ArticleTitleCompare {
    
    @InvocableMethod(label='Compare selected option with returned titles from Sitecore')
    public static List<Output> compareTitles(List<Input> inputs) {
        System.debug('relateditem: ' + inputs[0].relatedItem);
        System.debug('articleTitlesToCompare: ' + inputs[0].articleTitlesToCompare);
        Output output = new Output();
        List<String> titles = inputs[0].articleTitlesToCompare?.split(',,');

        output.isRedirectSelection = titles != null && titles.contains(inputs[0].relatedItem.chatbotTitle) ? false : true;

        return new List<Output>{ output };
    }

    public class Input {
        @InvocableVariable(label='Related Sitecore Article' description='A related article selection' required=true)
        public CTBOT_SitecoreAPIService.RelatedItem relatedItem;

        @InvocableVariable(label='Articles To Compare' description='Related articles to compare with user selection' required=false)
        public String articleTitlesToCompare;
    }

    public class Output {
        @InvocableVariable(label='Is Redirect Selection' description='Whether the user needs to be redirected or not' required=false)
        public Boolean isRedirectSelection;
    }
}