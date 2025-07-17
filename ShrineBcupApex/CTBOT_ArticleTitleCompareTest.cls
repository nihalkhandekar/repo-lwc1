@isTest
private class CTBOT_ArticleTitleCompareTest {
    @isTest
    static void testCompareTitlesNoRedirect() {
        // create method input
        CTBOT_SitecoreAPIService.RelatedItem relatedItem = new CTBOT_SitecoreAPIService.RelatedItem();
        relatedItem.chatbotTitle = 'How does it work?';
        relatedItem.id = 'cc6a31a4-b720-40fb-adf1-4e3ecc5e76a4';

        CTBOT_ArticleTitleCompare.Input input = new CTBOT_ArticleTitleCompare.Input();
        input.articleTitlesToCompare = 'How does it work?,,How is Shared Work different from regular unemployment?,,Who does the plan cover?,,How Do I Apply for Shared Work?';
        input.relatedItem = relatedItem;

        List<CTBOT_ArticleTitleCompare.Output> output = CTBOT_ArticleTitleCompare.compareTitles(new List<CTBOT_ArticleTitleCompare.Input>{input});
        System.assertEquals(false, output[0].isRedirectSelection);
    }

    @isTest
    static void testCompareTitlesRedirect() {
        // create method input
        CTBOT_SitecoreAPIService.RelatedItem relatedItem = new CTBOT_SitecoreAPIService.RelatedItem();
        relatedItem.chatbotTitle = 'Personal Vaccine Support';
        relatedItem.id = 'aa9f0f5c-0412-4b4c-85e6-ef6dcd4a4d47';

        CTBOT_ArticleTitleCompare.Input input = new CTBOT_ArticleTitleCompare.Input();
        input.articleTitlesToCompare = 'How does it work?,,How is Shared Work different from regular unemployment?,,Who does the plan cover?,,How Do I Apply for Shared Work?';
        input.relatedItem = relatedItem;

        List<CTBOT_ArticleTitleCompare.Output> output = CTBOT_ArticleTitleCompare.compareTitles(new List<CTBOT_ArticleTitleCompare.Input>{input});
        System.assertEquals(true, output[0].isRedirectSelection);
    }
}