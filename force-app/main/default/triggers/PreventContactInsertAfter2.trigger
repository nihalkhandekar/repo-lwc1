trigger PreventContactInsertAfter2 on Contact (before insert) {
    Set<Id> accIdSet = new Set<Id>();
    if(trigger.isBefore && trigger.isInsert){
        for(Contact con : trigger.new){
            if(con.AccountId != null){
               accIdSet.add(con.AccountId); 
            }
        }     
    }
    Map<Id, Integer> ContactCountMap = new Map<Id, Integer>();
    //Aggregate Query//
    List<AggregateResult> aggList = [select AccountId, count(Id) ContactCount from Contact where AccountId =: accIdSet group by AccountId];
    
    for(AggregateResult agg : aggList){
        ContactCountMap.put((Id)agg.get('AccountId'), (Integer)agg.get('ContactCount'));//here we have accountId & contacts count//
    }
    
    if(!trigger.new.isEmpty()){
        for(Contact c : trigger.new){
            if(c.AccountId != null && ContactCountMap.get(c.AccountId) >= 2){
              c.addError('More than 2 Contacts are not allowed for an Account');  
            } 
        }
    }
}