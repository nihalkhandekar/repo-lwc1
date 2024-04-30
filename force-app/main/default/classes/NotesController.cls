public class NotesController {
    @AuraEnabled
    list<AEC_Notes__c> newNotes = new list<AEC_Notes__c>();
    public static void createNote(String title, String description, Id workOrderId) {
        AEC_Notes__c newNote = new AEC_Notes__c(
            Name = title,
            Description__c = description,
            Work_Order__c = workOrderId
        );
        newNotes.add(newNote);
        insert newNotes;
        system.debug('newNotes'+ newNotes);
        
    }
    /* Testing notes changes from new branch*/
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