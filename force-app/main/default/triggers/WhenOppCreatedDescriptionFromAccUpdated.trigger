trigger WhenOppCreatedDescriptionFromAccUpdated on Opportunity (before insert) {
Set<Id> IdSet = new Set<Id>();
    for(Opportunity opp : trigger.new){
        if(String.isNotBlank(opp.AccountId)){
           IdSet.add(opp.AccountId); 
        }
    }
    
    Map<Id, Account> AccMap = new Map<Id, Account>([select id, name, Description from Account where id IN : IdSet]);
    
    for(Opportunity op : trigger.new){
        if(op.AccountId != null && AccMap.containsKey(op.AccountId)){
            op.Description = AccMap.get(op.AccountId).Description;
        }
    }
}