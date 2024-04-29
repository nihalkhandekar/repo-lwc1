trigger CaseOriginTrigger on Case (before insert) {
    for(Case c : Trigger.new){
        if(c.Origin == 'Email'){
            c.Status = 'New';
            c.Priority = 'Medium';
        }
    }
}