trigger RecTriggerCon on Contact (before insert, after insert) {

    /*if(trigger.isBefore && trigger.isInsert && RecTriggerCon.flag ){
        RecTriggerCon.flag = false;
        RecTriggerCon.onInsertCon(Trigger.new);    
    }*/
    
    if(trigger.isAfter && trigger.isInsert){
        if(RecTriggerCon.flag){
          RecTriggerCon.flag = false;
          RecTriggerCon.onInsertCon(Trigger.new);  
        }
    }
}