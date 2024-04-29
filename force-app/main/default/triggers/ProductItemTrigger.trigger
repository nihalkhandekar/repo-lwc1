trigger ProductItemTrigger on ProductItem (after insert, after update, after delete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            //ProductItemTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap);
        }
    }
}