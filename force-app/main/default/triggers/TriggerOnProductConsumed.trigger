trigger TriggerOnProductConsumed on ProductConsumed (before insert,after insert, after update, after delete) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        ProductConsumedTriggerHandler.productConsumedUnitPrice(Trigger.new);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        ProductConsumedTriggerHandler.PopulateSubtotalPrice(Trigger.new);
        ProductConsumedTriggerHandler.updateAdditionalItemConsumedQuantity(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        ProductConsumedTriggerHandler.PopulateSubtotalPrice(Trigger.old);
    }
}