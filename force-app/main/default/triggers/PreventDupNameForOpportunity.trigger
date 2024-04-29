trigger PreventDupNameForOpportunity on Opportunity (before insert, before update) {
    List<Opportunity> oppList = new List<Opportunity> ();
    oppList = [select id, name from Opportunity];
    for(Opportunity opp : trigger.new){
        for(Opportunity op : oppList){
            if(opp.Name == op.Name){
                opp.Name.addError('Duplicate Name Found!!');
            }  
        }        
    }
}