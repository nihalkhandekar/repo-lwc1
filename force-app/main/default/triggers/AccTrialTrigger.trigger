trigger AccTrialTrigger on Account (before insert, after insert, before update, before delete) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
           AccTrialTrigger.method1(Trigger.new); 
        }
        
        /*if(Trigger.isAfter){
           AccTrialTrigger.method2(Trigger.new);
        }*/
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
           AccTrialTrigger.method3(Trigger.new, Trigger.oldMap); 
        }
    }
}