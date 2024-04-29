trigger RollupOnContact on Contact (after insert, after update, after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert){
        RollupSummaryOnContacts.AfterInsertMethod(Trigger.New);
        }
        else if(trigger.isUpdate){
        RollupSummaryOnContacts.AfterUpdateMethod(Trigger.new, Trigger.OldMap);
        }
        else if(trigger.isDelete){
        RollupSummaryOnContacts.AfterDeleteMethod(Trigger.Old);   
        }
    }
}