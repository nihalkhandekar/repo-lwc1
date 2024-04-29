trigger OppStageChangedUpdate on Opportunity (before update) {
    for(Opportunity op : trigger.new){
        Opportunity opp = trigger.OldMap.get(op.id);
        
        if(op.StageName != opp.StageName){
            op.Description = 'Stage Name Has Changed from '+opp.StageName+ 'To '+op.StageName;
        }
    }

}