trigger LeadRatingCold on Lead (before insert) {
    for(Lead l : Trigger.new){
        if(l.LeadSource == 'Web'){
            l.Rating = 'Cold';
        }
        else{
           l.Rating = 'Hot'; 
        }
    }

}