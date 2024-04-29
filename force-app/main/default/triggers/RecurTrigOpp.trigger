trigger RecurTrigOpp on Opportunity (before insert) {
    list<Opportunity> oppList = new list<Opportunity>();
    if (trigger.isBefore && trigger.isInsert && !checkBox.value){
        checkBox.value = true;
        for(Opportunity opp : trigger.new){
            Opportunity op = new Opportunity();
            op.Name = 'repeat';
            op.CloseDate = system.today()+7;
            op.StageName = 'Prospecting';  
            oppList.add(op);
        }
    }
    system.debug(oppList);
    insert oppList;
}