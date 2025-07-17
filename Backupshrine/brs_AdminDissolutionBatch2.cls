/*********************************************************************************************
 * NAME:  brs_AdminDissolutionBatch2
 * DESCRIPTION: Batch class to update reason of dissolution and correct sub status of legacy accounts
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 08/30/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     08/30/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class brs_AdminDissolutionBatch2 implements Database.Batchable<sObject> {
    public static Final String className = 'brs_AdminDissolutionBatch';
    public static Final String methodName = 'updateReasonOfDissolutionOnAccount';
    public static Final String objectName = 'Account';
    public String query = '';
    public List<String> statuses = new List<String>{system.label.ACTIVE};
    public List<String> substatuses = new List<String> {system.label.Admin_Dissolution_Initiated_Label,system.label.brs_AgentResign_AccountSubStatus,system.label.No_Agent,system.label.Account_Annual_report_past_due,system.label.First_report_past_due,system.label.brs_AdminDissolveReady_for_Revocation,system.label.brs_AdminDissolveReady_for_Forfeiture};
   
    global brs_AdminDissolutionBatch2(String strQuery)
    {
        query  = strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Account> accList) {
       try{
        set<String> accReasonUpdateIdSet = new set<String>();
        set<String> accReasonUpdateIdSet2 = new set<String>();
        set<String> accSubStatusUpdateIdSet = new set<String>();
        set<String> accUpdateIdSet2 = new set<String>();
        set<String> accUpdateIdSet3 = new set<String>();
        map<String,Account> accUpdateIdMap3 = new map<String,Account>();
        map<String,Account> accUpdateIdMap4 = new map<String,Account>();
        map<String,Account> accUpdateIdMap = new map<String,Account>();
        map<Account,String> accUpdateIdMap2 = new map<Account,String>();
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        map<String,Account> accLstMap = new map<String,Account>();
        map<Account,String> accLstMap2 = new map<Account,String>();
        set<Id> excludeAnnual = new set<Id>();
        set<Id> excludeFirst = new set<Id>();
        List<String> fileType = new List<String>{system.label.Annual_Report,system.label.First_Report};
        List<String> reportStatus = new List<String>{system.label.Past_Due,system.label.Rejected,system.label.Approved};
        for(Account acc : accList)
        {
            accReasonUpdateIdSet.add(acc.Id);
            accUpdateIdMap3.put(acc.Id,acc);
        }
        if(!accReasonUpdateIdSet.IsEmpty())
        {
            List<Business_Filing__c> lstBusFile3 = [Select Id,Date_Intend_Forfeited__c,Due_Date__c,status__c,Filing_Type__c, Filing_Date__c,Account__c,Account__r.Citizenship__c,Account__r.Sub_Status__c,Type__c From Business_Filing__c where Account__c in: accReasonUpdateIdSet and Type__c In: fileType and Status__c IN: reportStatus and Due_Date__c != null ORDER BY Due_Date__c DESC,CreatedDate DESC];
            if(!lstBusFile3.IsEmpty())
            {
                for(Business_Filing__c busFile : lstBusFile3)
                {   
                    if(accReasonUpdateIdSet.contains(busFile.Account__c) && busFile.Type__c == system.label.Annual_Report && system.today() >= busFile.Due_Date__c.addDays(365) && !accLstMap.keyset().contains(busFile.Account__c) && !excludeAnnual.contains(busFile.Account__c))
                    {
                        if(busFile.Status__c != system.label.Approved){
                        Account acc2 = new Account(Id = busFile.Account__c, Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_AnnualReportReason);
                        accLstMap.put(busFile.Account__c,acc2);
                        accLstMap2.put(acc2,busFile.Account__c);
                        accReasonUpdateIdSet.remove(busFile.Account__c);
                        }else{
                            excludeAnnual.add(busFile.Account__c);
                        }
                    } 
                }
                if(!accReasonUpdateIdSet.IsEmpty())
                {
                    for(Business_Filing__c busFile : lstBusFile3)
                    {
                        if(accReasonUpdateIdSet.contains(busFile.Account__c) && busFile.Type__c == system.label.First_Report && system.today() >= busFile.Due_Date__c.addDays(365) && !accLstMap.keyset().contains(busFile.Account__c) && !excludeFirst.contains(busFile.Account__c))
                        {
                            if(busFile.Status__c != system.label.Approved){
                            Account acc2 = new Account(Id = busFile.Account__c, Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_FirstReportReason);
                            accLstMap.put(busFile.Account__c,acc2);
                            accLstMap2.put(acc2,busFile.Account__c);
                            accReasonUpdateIdSet.remove(busFile.Account__c);
                            }else{
                                excludeFirst.add(busFile.Account__c);   
                            }
                        }
                    }
                }
            }
        }
        if(!accReasonUpdateIdSet.IsEmpty())
        {   
            List<Agent__c> agLst = [Select id,Business_ID__c from Agent__c where Business_ID__c != null and Business_ID__c in: accReasonUpdateIdSet];
            if(!agLst.IsEmpty())
            {
                for(Agent__c ag : agLst)
                {
                    accUpdateIdSet2.add(ag.Business_ID__c);
                }
            }
            for(String str : accReasonUpdateIdSet)
            {
                if(!accUpdateIdSet2.contains(str))
                {
                    Account accOld = accUpdateIdMap3.get(str);
                    if(accOld.citizenship__c == system.label.domestic && accOld.business_type__c == system.label.LLP && accOld.BillingState == system.label.CT)
                    {
                        //do nothing
                    }
                    else
                    {
                        Account acc = new Account(Id = str, Reason_for_Administrative_Dissolution__c = system.label.Failure_to_appoint_or_maintain_an_agent_for_service);
                        accLstMap.put(str,acc);
                        accLstMap2.put(acc,str);
                    }
                        
                }                               
            } 
        }
        if(!accLstMap.IsEmpty())
        {
            Database.SaveResult[] accUpdateSuccessList = Database.update(accLstMap.values(), false);
            for(Database.SaveResult res : accUpdateSuccessList){
                if (!res.isSuccess()) {
                    String error='ERROR: Id:'+res.getId();
                    for(Database.Error err : res.getErrors()){
                        error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                    }
                    Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, res.getId(), BOS_Utility.sSeverity, null, error);
                    errorFilingLst.add(err);               
                }
            }
        
            if(!errorFilingLst.IsEmpty())
            BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }
        }
        catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, methodName, objectName, null, null, ex, ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}