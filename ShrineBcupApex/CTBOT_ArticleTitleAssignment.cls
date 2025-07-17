public with sharing class CTBOT_ArticleTitleAssignment {
    
    @InvocableMethod(label='Assign an article\'s title to a variable')
    public static List<String> assignTitle(List<Input> inputs) {
        return new List<String>{ inputs[0].relatedItem.chatbotTitle };
    }

    public class Input {
        @InvocableVariable(label='Related Sitecore Article' description='A related article selection' required=true)
        public CTBOT_SitecoreAPIService.RelatedItem relatedItem;
    }
}