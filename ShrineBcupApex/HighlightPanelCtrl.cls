public with sharing class HighlightPanelCtrl {
    @AuraEnabled
    public static Contact getContactDetails(String sessionId) {
        String sessionContactId = '';
        sessionContactId = [SELECT ContactId FROM LiveChatTranscript WHERE id =:sessionId].ContactId;

        if (String.isNotBlank(sessionContactId)) {
            return [
                SELECT Id, Email, Phone
                FROM Contact
                WHERE Id = :sessionContactId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        } else {
            Contact emptyContact = new Contact();
            return emptyContact;
        }
    }
}