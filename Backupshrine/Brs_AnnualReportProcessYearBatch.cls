// ONE TIME SCRIPT TO UPDATE THE ANNUAL PROCESSING YEAR IN ACCOUNT

Public without sharing class Brs_AnnualReportProcessYearBatch implements Database.Batchable <sObject> {
    public String query;
      public List <String> businessTypes = new List <String> {System.Label.businessTypeLLC, System.Label.businessTypeLLP,System.Label.Limited_Partnership_Comparable, System.Label.Stock, System.Label.Non_Stock, System.Label.Business_Type_BCORP};
          
     public Brs_AnnualReportProcessYearBatch(String querystr)
      {
          query = querystr;
      }
      public Brs_AnnualReportProcessYearBatch()
      {
          query ='Select id,name,sub_status__c,Business_Type__c,Citizenship__c,Annual_Report_Processing_Year__c,Date_Registration__c,Annual_Report_Due_Date__c,(select Account__c from Business_Filings__r where Type__c = \'Annual Report\' and Due_Year__c =\'2024\' limit 1) from Account where Status__c =\'Active\' and Annual_Report_Due_Date__c >=2023-01-01 and Annual_Report_Due_Date__c <=2023-12-31 and Id NOT IN (select Account__c from Business_Filing__c where Type__c = \'Annual Report\' and Status__c IN (\'In-Progress\',\'Due\',\'Past Due\',\'Rejected\',\'Approved\',\'Submitted - Agency review pending\',\'Submitted - Agent acceptance pending\',\'Submitted - intake pending\',\'\') and Due_Year__c =\'2023\') and Sub_status__c NOT IN (\'First report past due\',\'First report due\') AND Business_Type__c IN : businessTypes';
      }
      public Database.QueryLocator start(Database.BatchableContext BC){
        String accountRecordType = System.Label.ActionItem_AccountRecordType;
        String FirstReport = System.Label.First_Report_Label;
        String approved = system.label.Approved;
        return Database.getQueryLocator(query);
   }
       public void execute(Database.BatchableContext BC, List < Account > accList){
       List<Business_Filing__c> businessFilingList=new List<Business_Filing__c> ();
       List<Account> accountList=new List<Account> ();
       for(account acc:acclist)
       {
         if(!acc.Business_Filings__r.isEmpty())
         {
		  if(acc.Annual_Report_Processing_Year__c == 2024)
          {
			Business_Filing__c businessFiling = new Business_Filing__c();
			businessFiling.Type__c = System.Label.Annual_Report_Label;
			businessFiling.Account__c = acc.Id;
			businessFiling.Business_Type__c  = acc.Business_Type__c;
			businessFiling.Filing_Type__c = System.Label.Annual_Report_Label;
			if(acc.Annual_Report_Due_Date__c > System.Today())
			{
				businessFiling.Status__c = System.Label.Due;
				if(acc.sub_status__c != 'Ready for dissolution')
				{
			    acc.sub_status__c='Annual Report due';
				accountList.add(acc);
				
				}
		  
		}
		else
		{
			businessFiling.Status__c = 'past due';
		   if(acc.sub_status__c != 'Ready for dissolution')
		   {
			    acc.sub_status__c='Annual Report past due';
				accountList.add(acc);
		   }
		}
           businessFiling.Citizenship__c = acc.Citizenship__c;
           businessFiling.Due_Date__c= acc.Annual_Report_Due_Date__c;
           businessFilingList.add(businessFiling);
      }

    }
    else
    {

		Business_Filing__c businessFiling1 = new Business_Filing__c();
		businessFiling1.Type__c = System.Label.Annual_Report_Label;
		businessFiling1.Account__c = acc.Id;
	    businessFiling1.Business_Type__c  = acc.Business_Type__c;
	    businessFiling1.Filing_Type__c = System.Label.Annual_Report_Label;
		if(acc.Annual_Report_Due_Date__c > System.Today())
		{
			businessFiling1.Status__c = System.Label.Due;
		 if(acc.sub_status__c != 'Ready for dissolution')
		   {
			    acc.sub_status__c='Annual Report due';	
		   }
		   acc.Annual_Report_Processing_Year__c=2024;
		   accountList.add(acc);
		  
		}
		else
		{
			businessFiling1.Status__c = 'past due';
		   if(acc.sub_status__c != 'Ready for dissolution')
		   {
			    acc.sub_status__c='Annual Report past due';
				
		   }
		   		acc.Annual_Report_Processing_Year__c=2024;
				accountList.add(acc);
		}

	    businessFiling1.Citizenship__c = acc.Citizenship__c;
	    businessFiling1.Due_Date__c= acc.Annual_Report_Due_Date__c;
	    businessFilingList.add(businessFiling1);	
	   
	    Business_Filing__c businessFiling2 = new Business_Filing__c();
	    businessFiling2.Type__c = System.Label.Annual_Report_Label;
	    businessFiling2.Account__c = acc.Id;
	    businessFiling2.Business_Type__c  = acc.Business_Type__c;
	    businessFiling2.Filing_Type__c = System.Label.Annual_Report_Label;
	    businessFiling2.Status__c = System.Label.Due;
	    businessFiling2.Citizenship__c = acc.Citizenship__c;
	    businessFiling2.Due_Date__c= Date.newInstance(2024,acc.Annual_Report_Due_Date__c.Month(),acc.Annual_Report_Due_Date__c.day());
	    businessFilingList.add(businessFiling2);
    }
}
      if(!accountList.isEmpty())
      {
	    Update accountList;
      }
      if(!businessFilingList.isEmpty())
      {
	    insert businessFilingList;
      }

    }
   public void finish(Database.BatchableContext BC){
   }
    }