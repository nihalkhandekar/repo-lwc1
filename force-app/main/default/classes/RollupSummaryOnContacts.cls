public class RollupSummaryOnContacts {
    public static void AfterInsertMethod (List<Contact> NewConList){    //this is new list which is receiving new values
        Set<Id> accIds = new Set<Id>();
        List<Account> AccountsToBeUpdated = new List<Account>();
        
        for(Contact con : NewConList){    //here we are fetching one by one values from list to con 
            if(con.AccountId != null){
            accIds.add(con.AccountId);    //And adding account ids of contacts in a set 
        }    
    }
    	AccountsToBeUpdated = AccTotalSalary(accIds);
    	if(!AccountsToBeUpdated.isEmpty()) {
                update AccountsToBeUpdated;
        }
    }  
    //Update Method//
    public static void AfterUpdateMethod (List<Contact> ConNewList, Map<Id,Contact> OldConMap){
    	Set<Id> accIds = new Set<Id>();
        List<Account> AccountsToBeUpdated = new List<Account>();
		
        for(Contact con : ConNewList){
            if(con.AccountId != null && con.Salary_Trigger__c != OldConMap.get(con.Id).Salary_Trigger__c){
                accIds.add(con.AccountId);
            }
        }  
        AccountsToBeUpdated = AccTotalSalary(accIds);
        if(!AccountsToBeUpdated.isEmpty()) {
                update AccountsToBeUpdated;
        }
    }
    //Delete Method//
    public static void AfterDeleteMethod(List<Contact> ConOldList){
       Set<Id> accIds = new Set<Id>(); 
       List<Account> AccountsToBeUpdated = new List<Account>();
        
       for(Contact con : ConOldList){
           if(con.AccountId != null){
               accIds.add(con.AccountId);
           } 
        }
        AccountsToBeUpdated = AccTotalSalary(accIds);
        if(!AccountsToBeUpdated.isEmpty()){
            update AccountsToBeUpdated;
        }
    }
   
	//Main Method//
    public static List<Account> AccTotalSalary(Set<Id> accIds){
		List<Account> AccountsToBeUpdated = new List<Account> ();
        Map<Id, Decimal> AccIdToTotalSal = new Map<Id, Decimal>(); //Khali Map to store id and total amount for account obj//
        
        for(Contact con: [select id, Salary_Trigger__c, AccountId from Contact where AccountId IN : accIds]){
			Decimal totalSal = 0;
            if(AccIdToTotalSal.ContainsKey(con.AccountId)){
              totalSal = AccIdToTotalSal.get(con.AccountId);  
            }
            if(con.Salary_Trigger__c != null){
               totalSal = totalSal + con.Salary_Trigger__c;
            }
           AccIdToTotalSal.put(con.AccountId, totalSal);   //Now Map contains Contact k andr ki AccId and total salary ka value // 
        }		
        //Now checking if Map is having any value//
	        if(!AccIdToTotalSal.isEmpty()){
            //We need to iterate based on key----keySet returns all the keys of the map//
                for(Id i : AccIdToTotalSal.KeySet()){
                  Account acc = new Account();
                    acc.id = i;
                    acc.TotalSalary_Trigger__c = AccIdToTotalSal.get(i);  //getting value of particular key in map// 
               		AccountsToBeUpdated.add(acc);
                }
        }
           return AccountsToBeUpdated; 
    }
}