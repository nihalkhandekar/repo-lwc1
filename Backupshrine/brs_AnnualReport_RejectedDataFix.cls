public class brs_AnnualReport_RejectedDataFix implements Database.Batchable<sObject>{
    public String query;
               public Database.QueryLocator start(Database.BatchableContext BC){
               query = 'select id,name, (select id,Is_Rejected_Instantiated__c,Status__c,Filing_Date__c,CreatedDate,Account__c,Type__c,Due_Date__c, Due_Year__c from Business_Filings__r where Type__c=\'Annual Report\' and Status__c IN (\'Approved\',\'Rejected\') and Due_Date__c !=null) from Account where id IN ( select Account__c from Business_Filing__c where Type__c=\'Annual Report\' and Is_Rejected_Instantiated__c=false and status__c=\'Rejected\' and Account__r.status__c=\'Active\')';
         return Database.getQueryLocator(query);
    }
        public void execute(Database.BatchableContext BC, List < Account > accList){
         Map<id,Map<String,List<Business_Filing__c>>> TotalMap=new Map<id,Map<String,List<Business_Filing__c>>>();
         Map<String,List<Business_Filing__c>> IterateMap= new Map<String,List<Business_Filing__c>>();
           List<Id> currentBatchSuccessIds = new List<Id>();
         List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
         for(Account acc:accList)
         {
             
             Map<String,List<Business_Filing__c>> FinalMap= new Map<String,List<Business_Filing__c>>();
             for(Business_Filing__c bus:acc.Business_Filings__r)
             {
                 List<Business_Filing__c> finalFilingList=new List<Business_Filing__c>();
                 if(FinalMap.containsKey(bus.Due_Year__c))
                 {
                 finalFilingList=FinalMap.get(bus.Due_Year__c);
                 finalFilingList.add(bus);
                 FinalMap.put(bus.Due_Year__c,finalFilingList);
                 }
                 else
                 {
                 finalFilingList.add(bus);
                 FinalMap.put(bus.Due_Year__c,finalFilingList);
                 }
             }
             TotalMap.put(acc.Id, FinalMap);
             
         }
         Map<id,List<business_Filing__c>> updatedrejectListmap=new Map<id,List<business_Filing__c>>();
         List<business_Filing__c> UpdatedRejectedfilingList=new List<business_Filing__c>();
         for(account acc:accList)
         {
             IterateMap=TotalMap.get(acc.id);
             for(String str:IterateMap.keySet())
             {
                 List<business_Filing__c> filingList=new List<business_Filing__c>();
                 List<business_Filing__c> RejectedfilingList=new List<business_Filing__c>();
                 List<DateTime> dlist = new List<DateTime>();
                 Map<datetime,business_Filing__c> filingDateMap=new Map<datetime,business_Filing__c>();
                  Integer Approvedcount=0;
                  Integer Rejectedcount=0;
                 filingList=IterateMap.get(str);
                 for(Business_Filing__c bus:filingList)
                 {
                     if(bus.Status__c == 'Approved')
                     {
                         Approvedcount++;
                     }
                     else if(bus.Status__c == 'Rejected')
                     {
                         Rejectedcount++;
                         RejectedfilingList.add(bus);
                     }
                 }
                 if(Approvedcount >=1 && Rejectedcount>0)
                 {
                     for(Business_Filing__c bus:RejectedfilingList)
                     {
                         if(bus.Is_Rejected_Instantiated__c ==false)
                         {
                             bus.Is_Rejected_Instantiated__c=true;
                             UpdatedRejectedfilingList.add(bus);
                         }  
                     }
                 }
                 else if(Approvedcount == 0 && Rejectedcount>1)
                 {
                      for(Business_Filing__c bus:RejectedfilingList)
                     {                       
                             filingDateMap.put(bus.createddate,bus);
                     }
                 }
                 if(!filingDateMap.isEmpty())
                 {
                for(datetime da1:filingDateMap.keySet())
                 {
                     dlist.add(da1);
                 }
                 dlist.sort();
                 dlist.remove(dlist.size()-1);
                 for(datetime da2:dlist)
                 {
                     Business_Filing__c bussinessfiling=filingDateMap.get(da2);
                         if(bussinessfiling.Is_Rejected_Instantiated__c ==false)
                         {
                             bussinessfiling.Is_Rejected_Instantiated__c=true;
                                 UpdatedRejectedfilingList.add(bussinessfiling);
   
                         } 
                 }
                 } 
             }
         }
         
         Database.SaveResult[] bfresult=Database.update(UpdatedRejectedfilingList, false);
         for(Database.SaveResult res : bfresult){
             if (res.isSuccess()) {
                 currentBatchSuccessIds.add(res.getId());//Add Success Ids
             }else {
                 String error='ERROR: Id:'+res.getId();
                 for(Database.Error err : res.getErrors()){
                     error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                 }
                 Error_Log__c err = BOS_Utility.errorRecordLogger('brs_AnnualReport_RejectedDataFix', 'Execute', 'Business_Filing__c', res.getId(), BOS_Utility.sSeverity, null, error);
                 errorFilingLst.add(err);
             }
         }
        if(!errorFilingLst.IsEmpty()){
             BOS_Utility.insertErrorRecordLst(errorFilingLst);
         }    
     }
         public void finish(Database.BatchableContext BC){
    }
 }