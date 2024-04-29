trigger WhenOppChangeSetStageAsClosedWon on Opportunity (before Update) {
    if(trigger.isBefore && trigger.isUpdate){
        for(Opportunity opp : trigger.new){
        opp.StageName = 'Closed Won';
    }
  }  
}