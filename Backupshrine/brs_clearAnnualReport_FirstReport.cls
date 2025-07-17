Public without sharing class brs_clearAnnualReport_FirstReport implements Database.Batchable<sObject> {
      public String query;
      public List <String> businessTypes = new List <String> {System.Label.businessTypeLLC, System.Label.businessTypeLLP,System.Label.Limited_Partnership_Comparable, System.Label.Stock, System.Label.Non_Stock, System.Label.Business_Type_BCORP};
          
      public brs_clearAnnualReport_FirstReport()
      {
          query='select id,Name,Sub_status__c,(select Id,Account__c,CreatedDate from business_filings__r where Filing_Type__c =\'Annual Report\' and Status__c IN (\'Due\',\'Past Due\')) from Account where status__c=\'Active\' and Business_Type__c IN (\'Stock\',\'Non-Stock\',\'B Corp\') and Sub_status__c Not IN (\'First Report Due\',\'First Report Past Due\') and ID IN (select Account__c from business_filing__c where Filing_Type__c =\'Organization and First Report\' and Status__c IN (\'Due\',\'Past Due\')) and ID IN (select Account__c from business_filing__c where Filing_Type__c =\'Annual Report\' and Status__c IN (\'Due\',\'Past Due\'))';
      }
      public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
   }
       public void execute(Database.BatchableContext BC, List < Account > accList){
            List<id> accids=new List<id>();
            List<Business_Filing__c> buslist=new List<Business_Filing__c>();
           	List<id> checkduplicateList=new List<id>();
            List<Account> newAcclist=new List<Account>();
            for(Account acc:accList)
            {
                   accids.add(acc.id);
	               if(!acc.business_filings__r.isempty())
	               {
	                 for(Business_Filing__c bus:acc.business_filings__r)
	                 {
	
	                   if(!checkduplicateList.contains(bus.id))
	                   {
	                     buslist.add(bus);
                         checkduplicateList.add(bus.id);
	                   }	
	                 }
                    }    
	        }

             for(business_filing__c bus:[select Account__c,Account__r.Sub_status__c,Account__r.Annual_Report_Processing_Year__c,due_date__c from business_filing__c where Type__c='First Report' and Status__c IN ('Due','Past Due') and Account__c IN:accids])
             {
				if(bus.Account__r.Sub_status__c == 'Annual Report Due' || bus.Account__r.Sub_status__c == 'Annual Report Past Due')
				{
					if(bus.due_date__c <System.Today())
					{
						bus.Account__r.Sub_status__c = 'First Report Past Due';
						bus.Account__r.Annual_Report_Processing_Year__c=null;
						newAcclist.add(bus.Account__r);
					}
					else
					{
  						bus.Account__r.Sub_status__c = 'First Report Due';
  						bus.Account__r.Annual_Report_Processing_Year__c=null;
  						newAcclist.add(bus.Account__r);
					}
				}
				else
				{
  					bus.Account__r.Annual_Report_Processing_Year__c=null;
  					newAcclist.add(bus.Account__r);
				}
			}

		if(!newAcclist.isempty())
		{
			update newAcclist;
		}
		if(!buslist.isempty())
		{
		delete buslist;
		}
    }
       public void finish(Database.BatchableContext BC){
       
   }
    }