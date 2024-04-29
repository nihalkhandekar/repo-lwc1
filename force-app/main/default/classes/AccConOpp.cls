public class AccConOpp {
    public Account acc{get; set;}
    public Contact con{get; set;}
    public Opportunity opp{get; set;}
    
    // constructor //
    public AccConOpp(){
        acc= new Account(); //initialize the Account obj //
        con= new Contact(); //initialize the Contact obj //
        opp= new Opportunity(); //initialize the Opportunity obj //
    }
   // Method //
   public PageReference SaveAllRecords(){
       insert acc;
       con.AccountId = acc.Id; //Mapping//
       opp.AccountId = acc.Id;
       insert con;
       opp.AccountId = con.AccountId;
       opp.ContactId = con.Id;
       insert opp;

      PageReference pNext = new PageReference('/apex/AccConOpp?id='+acc.id +con.id +opp.id);
       pNext.setRedirect(true);
       return pNext; 
   }
      public PageReference CancelAllRecords(){
      PageReference pNext = new PageReference('/');
       pNext.setRedirect(true);
       return pNext; 
   } 
    
}