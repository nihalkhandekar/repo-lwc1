public class NotesController {
    @AuraEnabled
    public static void createNote(String title, String description, Id workOrderId) {
        AEC_Notes__c newNote = new AEC_Notes__c(
            Name = title,
            Description__c = description,
            Work_Order__c = workOrderId
        );
        insert newNote;
        
    }
    @AuraEnabled (cacheable=true)
    public static WorkOrder getWorkNumber(string recordId){
        try {
            WorkOrder WO = [select id, WorkOrderNumber from WorkOrder where id = :  recordId];
            return WO;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}