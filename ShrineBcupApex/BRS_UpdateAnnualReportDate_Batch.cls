public without sharing class BRS_UpdateAnnualReportDate_Batch implements Database.Batchable<sobject> {
    public String query;
        public Database.QueryLocator start(Database.BatchableContext BC) {     
		query='select id,Type__c,Filing_date__c,Account__c,status__c,Account__r.Annual_Report_Due_Date__c, Account__r.Annual_report_past_due_date__c from Business_Filing__c where Type__c=\'Reinstatement\' and status__c=\'Approved\' and Account__r.status__c=\'Active\' order by filing_date__c desc';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List < Business_Filing__c > reinstatementlist) {
    Map<id,String> mapToIdentifyAnnualReport=new Map<id,String>();
    for(Business_Filing__c bus:reinstatementlist)
    {
	if(!mapToIdentifyAnnualReport.containsKey(bus.Account__c))
	{
		 mapToIdentifyAnnualReport.put(bus.Account__c,String.valueOf(bus.filing_date__c.Year()));
		
	}		
    }
        List<Business_Filing__c> AnnualReportList=[Select Due_Date__c,Type__c,Status__c,Due_Year__c,Account__c,Account__r.Business_Type__c,Account__r.Citizenship__c,Account__r.Annual_Report_Past_Due_Date__c,Account__r.Annual_Report_Due_Date__c,Filing_Date__c,CreatedDate from Business_Filing__c where  Account__c IN:mapToIdentifyAnnualReport.keySet() and Type__c = 'Annual Report' AND Due_year__c !=null AND Status__c IN ('Due','Past Due') ORDER BY Due_year__c ASC];
        List<Business_Filing__c> deletingList=new List<Business_Filing__c>();
        List<Account> updatingList=new List<Account>();
        Map<id,String> mapToUpdateAccount=new Map<id,String>();
        for(Business_Filing__c bus:AnnualReportList)
        {
            
	      if(bus.Due_year__c <= mapToIdentifyAnnualReport.get(bus.Account__c))
	      {
		     deletingList.add(bus);
	      }
          else
	      {
		    if(!mapToUpdateAccount.containsKey(bus.Account__c))
		    {	
		      if(bus.Account__r.Annual_Report_Due_Date__c.Year() == Integer.valueOf(bus.Due_Year__c))
		     {
			    mapToUpdateAccount.put(bus.Account__c,bus.Due_Year__c);
		     }
              else
              {
                  mapToUpdateAccount.put(bus.Account__c,bus.Due_Year__c);
                  Account acc = new Account(Id=bus.Account__c,Annual_Report_Due_Date__c=bus.Due_Date__c,Annual_Report_Past_Due_Date__c=bus.Due_Date__c);
                  updatingList.add(acc);
              }
		   }
	     }	
}
        if(!deletingList.isEmpty())
        {
            delete deletingList;
        }
          if(!updatingList.isEmpty())
        {
            update updatingList;
        }
      
    }
    public void finish(Database.BatchableContext BC) {}

}