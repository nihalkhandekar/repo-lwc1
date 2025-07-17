/*********************************************************************************************
 * NAME:  BRSMostRecentFilingDateBatch
 * DESCRIPTION: Batch class to update account with most recent filing date from business filing
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 06/28/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     06/28/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class BRSMostRecentFilingDateBatch implements Database.Batchable<sObject> {
    public static Final String className = 'BRSMostRecentFilingDateBatch';
    public static Final String methodName = 'BRSMostRecentFilingDateBatch';
    public static Final String objectName = 'Account';
    public List<String> statuses = new List<String>{system.label.brs_BusinessReservationStatus,system.label.brsStatus_ReservedCancel,system.label.BRS_FilingStatus_Rejected,system.label.brs_BusFileStatusRemoved,system.label.brs_BusFileStatusExpired,system.label.brs_BusFileStatusExpiredReservation,system.label.brs_BusFileStatusRegistered,system.label.brs_BusFileStatusCancelled,system.label.Withdrawn,system.label.DISSOLVED_STATUS,system.label.Renunciated,system.label.Revoked_Label,system.label.Forfeited};
    public String query = '';
    global BRSMostRecentFilingDateBatch(String strQuery)
    {
        query  = strQuery;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       /** collect the batches of records or objects to be passed to execute **/
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<Account> accList) {
        try{
        set<String> accUpdateIdSet = new set<String>();
        map<String,Account> accUpdateIdMap = new map<String,Account>();
        map<Account,String> accUpdateIdMap2 = new map<Account,String>();
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        for(Account acc : accList)
        {
            accUpdateIdSet.add(acc.Id);
        }
        if(!accUpdateIdSet.IsEmpty())
        {
            List<Business_Filing__c> lstBusFile = [Select Id, Filing_Date__c,Account__c,Type__c From Business_Filing__c where Account__c in: accUpdateIdSet and Status__c =: System.Label.Approved And Type__c =: system.label.Annual_Report_Comparable And Filing_Date__c != null];
            if(!lstBusFile.IsEmpty())
            {
                for(Business_Filing__c busFile : lstBusFile)
                {
                    if(accUpdateIdSet.contains(busFile.Account__c))
                    {
                        if(!accUpdateIdMap.keyset().contains(busFile.Account__c))
                        {
                            Account acc = new Account(Id=busFile.Account__c,Most_Recent_Filing_Date__c=busFile.Filing_Date__c);
                            accUpdateIdMap.put(busFile.Account__c,acc);
                            accUpdateIdMap2.put(acc,busFile.Account__c);

                        }
                        else
                        {
                            Account acc2 = accUpdateIdMap.get(busFile.Account__c);
                            if(busFile.Filing_Date__c > acc2.Most_Recent_Filing_Date__c)
                            {
                                accUpdateIdMap.remove(busFile.Account__c);
                                Account acc3 = new Account(Id=busFile.Account__c,Most_Recent_Filing_Date__c=busFile.Filing_Date__c);
                                accUpdateIdMap.put(busFile.Account__c,acc3);
                                accUpdateIdMap2.put(acc3,busFile.Account__c);
                            }
                        }
                    }
                }
            }
            if(!accUpdateIdMap.IsEmpty())
            {
                Database.SaveResult[] accUpdateSuccessList = Database.update(accUpdateIdMap.values(), false);
                for(Integer i=0;i<accUpdateSuccessList.size();i++)
                {
                   if(!accUpdateSuccessList.get(i).isSuccess()) 
                   {
                      
                        Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, accUpdateIdMap2.get(accUpdateIdMap.values().get(i)), BOS_Utility.sSeverity, null, system.label.BRSMostRecentFilingDateBatchError +accUpdateIdMap2.get(accUpdateIdMap.values().get(i)));
                        errorFilingLst.add(err);
                   }
                }
            }
            if(!errorFilingLst.IsEmpty())
               BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, methodName, objectName, null, null, ex, ex.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}