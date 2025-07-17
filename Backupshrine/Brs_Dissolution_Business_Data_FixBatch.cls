public without sharing class Brs_Dissolution_Business_Data_FixBatch implements Database.Batchable<sObject>,schedulable {
    public String query;
          public Database.QueryLocator start(Database.BatchableContext BC){
              query = 'Select id,Name,Status__c,Business_Type__c,Annual_Report_Due_Date__c,Annual_report_past_due_date__c,Sub_Status__c from Account where Business_Type__c IN (\'LLC\',\'LLP\',\'Limited Partnership\',\'Stock\',\'Non-Stock\') AND status__c IN (\'Dissolved\',\'Cancelled\',\'Revoked\',\'Forfeited\')';
        return Database.getQueryLocator(query);
   }
    public void execute(Database.BatchableContext BC, List < Account > accList){
        List<Account> acclistdata=new  List<Account>();
		Map<id,Account> accMap=new Map<id,Account>(accList);
        Set<Business_Filing__c> deletedList=new Set<Business_Filing__c>();
        Map<id,List<Business_Filing__c>> accountIdToFilingMap=new Map<id,List<Business_Filing__c>>();
		List<Business_Filing__c> filingdata=[Select id,Account__c,Status__c from Business_Filing__c where Account__c IN:accMap.keySet() and Type__c='Annual Report' and Status__c NOT IN ('Approved','Rejected')];
        List<Business_Filing__c> finalFilingList=new List<Business_Filing__c>(); 
        
        for(Business_Filing__c bus:filingdata)
        {
            if(accountIdToFilingMap.containsKey(bus.Account__c))
            {
                finalFilingList=accountIdToFilingMap.get(bus.Account__c);
                finalFilingList.add(bus);
                accountIdToFilingMap.put(bus.Account__c,finalFilingList);
            }
            else
            {
                finalFilingList.add(bus);
                accountIdToFilingMap.put(bus.Account__c,finalFilingList);
            }
        }
        for(Account acc:acclist)
        {
            if(((acc.Business_Type__c == 'Non-Stock' || acc.Business_Type__c == 'Stock') && acc.Status__c == 'Forfeited') || ((acc.Business_Type__c == 'LLC' || acc.Business_Type__c == 'LLP' || acc.Business_Type__c == 'Limited Partnership') && (acc.Status__c == 'Dissolved' || acc.Status__c == 'Cancelled' || acc.Status__c == 'Revoked')))
            {
            if(acc.Annual_Report_Due_Date__c !=null || acc.Annual_report_past_due_date__c !=null)
            {
                acc.Annual_Report_Due_Date__c=null;
                acc.Annual_report_past_due_date__c=null;  
            }
            if(acc.Sub_Status__c!=null)
            {
                acc.Sub_Status__c=null;
            }
            acclistdata.add(acc);
             if(accountIdToFilingMap.containsKey(acc.id))
             {
                 deletedList.addAll(accountIdToFilingMap.get(acc.id));
             }
            }
        }
        Map<Id, String> FailerAccountIds = new Map<Id, String>();
        Set<Id> successAccountIds = new Set<Id>();
        Map<Id, String> FailerAccountIds1 = new Map<Id, String>();
        Set<Id> successAccountIds1 = new Set<Id>();
        if(!acclistdata.isempty())
        {
               Database.SaveResult[] dmlResponse = Database.update(acclistdata, false);
                            for (Integer i = 0; i < dmlResponse.size(); i++) {
                    if (dmlResponse.get(i).isSuccess()) {
                        successAccountIds.add(dmlResponse.get(i).getId());
                    } else if (!dmlResponse.get(i).isSuccess()) {
                        // DML operation failed
                        Database.Error error = dmlResponse.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        acclistdata.get(i);
                        FailerAccountIds.put(acclistdata.get(i).Id, failedDML);
                    }
                }
        }
       if(!deletedList.isempty())
       {
           List<Business_Filing__c> finalDeletedList=new List<Business_Filing__c>(deletedList);
               delete  finalDeletedList;           
       }
        }
       public void finish(Database.BatchableContext BC){
   }
   public void execute(SchedulableContext sc) {
    Database.executeBatch(new Brs_Dissolution_Business_Data_FixBatch(), 200);
}
}