public with sharing class CTBOT_SitecoreArticleFeedback {

    @testVisible private static Integer responseCode;
    
    @InvocableMethod(label='Send article-level feedback to Sitecore' description='Gathers article-level feedback collected during a session and sends it to Sitecore')
    public static void sendFeedback(List<Input> inputs) {
        if (inputs[0].feedbackRecords == null) return;
        
        List<SitecoreFeedbackItem> feedbackItems = new List<SitecoreFeedbackItem>();
        CTBOT_SitecoreAPIService.RequestType request = CTBOT_SitecoreAPIService.RequestType.FEEDBACK;
        CTBOT_SitecoreAPIService.SitecoreServiceParam paramObject = new CTBOT_SitecoreAPIService.SitecoreServiceParam();

        for (Bot_Article_Feedback__c feedbackItem : inputs[0].feedbackRecords) {
            SitecoreFeedbackItem item = new SitecoreFeedbackItem();
            item.KbArticleId = '{' + feedbackItem.Sitecore_ID__c + '}';
            item.ArticleRatingChange = Integer.valueOf(feedbackItem.Value__c);
            feedbackItems.add(item);
        }

        paramObject.feedbackRequest = feedbackItems;
        CTBOT_SitecoreAPIService.initializeSitecoreService(request, paramObject);
        HttpResponse response = CTBOT_SitecoreAPIService.sendRequest();
        responseCode = response.getStatusCode();
        deleteFeedbackRecords();
    }

    @future
    public static void deleteFeedbackRecords() {
        List<Bot_Article_Feedback__c> recordsToDelete = [
            SELECT Id
            FROM Bot_Article_Feedback__c
        ];

        delete recordsToDelete;
    }

    public class Input {
        @InvocableVariable
        public List<Bot_Article_Feedback__c> feedbackRecords;
    }

    public class SitecoreFeedbackItem {
        public String KbArticleId;
        public Integer ArticleRatingChange;
    }
}