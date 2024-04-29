trigger CreateOppWhenAccCreated on Account (after insert) {
    List<Opportunity> oppList = new List<Opportunity>();
    for(Account acc : Trigger.new){
        Opportunity opp = new Opportunity();
        opp.Name = acc.Name;
        opp.CloseDate = System.today()+7;
        opp.StageName = 'Prospecting';  
        opp.AccountId = acc.Id;
        oppList.add(opp);
    }
    insert oppList;
}