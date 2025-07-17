@isTest
private class CTBOT_ArticleTitleAssignmentTest {
    @isTest
    static void testAssignTitle() {
        // create method input
        CTBOT_SitecoreAPIService.RelatedItem relatedItem = new CTBOT_SitecoreAPIService.RelatedItem();
        relatedItem.chatbotTitle = 'What is the Shared Work Program?';

        CTBOT_ArticleTitleAssignment.Input input = new CTBOT_ArticleTitleAssignment.Input();
        input.relatedItem = relatedItem;

        List<String> output = CTBOT_ArticleTitleAssignment.assignTitle(new List<CTBOT_ArticleTitleAssignment.Input>{input});
    }
}