public with sharing class CTBOT_ArticleLevelFeedback {

    private static final String MAIN_MENU = 'Main Menu';
    @testVisible private static Boolean isTest = false;
    @testVisible private static Boolean throwError = false;
    
    @AuraEnabled
    public static void submitFeedback(String articleId, String chatKey, Integer feedbackValue) {
        try {
            
            List<Bot_Article_Feedback__c> feedbackRecords = [
                SELECT Value__c
                FROM Bot_Article_Feedback__c
                WHERE Chat_Key__c = :chatKey
                AND Sitecore_ID__c = :articleId
            ];

            if (feedbackRecords.isEmpty()) {
                Bot_Article_Feedback__c feedback = new Bot_Article_Feedback__c();
                feedback.Sitecore_ID__c = articleId;
                feedback.Chat_Key__c = chatKey;
                feedback.Value__c = feedbackValue;
                insert feedback;
            }

            if (throwError) Bot_Article_Feedback__c testError = feedbackRecords[0]; // Causes null pointer exception

        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException('An error occurred when submitting feedback in CTBOT_ArticleLevelFeedback: ' + e.getMessage());
            auraException.setMessage('An error occurred when submitting feedback in CTBOT_ArticleLevelFeedback: ' + e.getMessage());
            throw auraException;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getMainMenuIds() {
        try {
            List<String> sitecoreIdList = new List<String>();

            if (throwError) String testError = sitecoreIdList[0]; // Causes null pointer exception

            List<Robin_Dynamic_Dialog__mdt> metadataRecords = [
                SELECT MasterLabel
                FROM Robin_Dynamic_Dialog__mdt
                WHERE Dialog_Name__c = :MAIN_MENU
            ];

            if (metadataRecords.size() > 0 || isTest) {
                metadataRecords = !isTest ? metadataRecords : new List<Robin_Dynamic_Dialog__mdt>{ 
                    new Robin_Dynamic_Dialog__mdt(
                        MasterLabel = 'EEB72F59-8689-4AF7-A0FA-3C7ED7F6FE5D',
                        Dialog_Name__c = 'Test Dialog',
                        Fallback_ID__c = 'test1234'
                    )
                };
            }

            for (Robin_Dynamic_Dialog__mdt record : metadataRecords) {
                sitecoreIdList.add(record.MasterLabel);
            }

            return sitecoreIdList;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException('An error occurred when getting Main Menu IDs in CTBOT_ArticleLevelFeedback: ' + e.getMessage());
            auraException.setMessage('An error occurred when getting Main Menu IDs in CTBOT_ArticleLevelFeedback: ' + e.getMessage());
            throw auraException;
        }
    }
}