/*********************************************************************************************
 * NAME:  brs_AdminDissolutionBatch
 * DESCRIPTION: Batch class to update reason of dissolution and correct sub status of legacy accounts
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 07/20/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     07/20/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class brs_AdminDissolutionBatch implements Database.Batchable<sObject> {
    public static Final String className = 'brs_AdminDissolutionBatch';
    public static Final String methodName = 'updateReasonOfDissolutionOnAccount';
    public static Final String objectName = 'Account';
    public String query = '';
    public List<String> statuses = new List<String>{system.label.brs_BusinessReservationStatus,system.label.brsStatus_ReservedCancel,system.label.BRS_FilingStatus_Rejected,system.label.brs_BusFileStatusRemoved,system.label.brs_BusFileStatusExpired,system.label.brs_BusFileStatusExpiredReservation,system.label.brs_BusFileStatusRegistered,system.label.brs_BusFileStatusCancelled,system.label.Withdrawn,system.label.DISSOLVED_STATUS,system.label.Renunciated,system.label.Revoked_Label,system.label.Forfeited};
    public List<String> substatuses = new List<String> {system.label.Admin_Dissolution_Initiated_Label,system.label.brs_AgentResign_AccountSubStatus,system.label.No_Agent,system.label.Account_Annual_report_past_due,system.label.First_report_past_due};
   
    global brs_AdminDissolutionBatch(String strQuery)
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
        List<String> fileType = new List<String>{system.label.Annual_Report,system.label.First_Report};
        for(Account acc : accList)
        {
            if(acc.sub_status__c == system.label.brs_AgentResign_AccountSubStatus)
            {
                accReasonUpdateIdSet.add(acc.Id);
                accUpdateIdMap3.put(acc.Id,acc);
            }
            else
            {
                accSubStatusUpdateIdSet.add(acc.Id);
                accUpdateIdMap4.put(acc.Id,acc);
            }
        }
        if(!accReasonUpdateIdSet.IsEmpty() || !accSubStatusUpdateIdSet.IsEmpty())
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
                        accSubStatusUpdateIdSet.add(str);
                    }
                    else
                    {
                        Account acc = new Account(Id = str, Reason_for_Administrative_Dissolution__c = system.label.Failure_to_appoint_or_maintain_an_agent_for_service);
                        accUpdateIdMap.put(str,acc);
                        accUpdateIdMap2.put(acc,str);
                    }
                        
                }
                else
                    accSubStatusUpdateIdSet.add(str);
            } 
            if(!accSubStatusUpdateIdSet.IsEmpty()){
                List<Business_Filing__c> lstBusFile = [Select Id,Date_Intend_Forfeited__c,Due_Date__c,status__c,Filing_Type__c, Filing_Date__c,Account__c,Account__r.Citizenship__c,Account__r.Sub_Status__c,Type__c From Business_Filing__c where Account__c in: accSubStatusUpdateIdSet and ((Type__c In: fileType and Status__c =: system.label.Past_Due and Due_Date__c != null) or (Filing_Type__c =: system.label.Notice_of_Intent_to_Dissolve_Revoke_Label and Date_Intend_Forfeited__c != null))];
                if(!lstBusFile.IsEmpty())
                {
                    for(Business_Filing__c busFile : lstBusFile)
                    {
                        if(!accUpdateIdMap.keyset().contains(busFile.Account__c)){
                        Account acc = new Account();
                        if(busFile.Type__c == system.label.Annual_Report && system.today() >= busFile.Due_Date__c.addDays(365) && busFile.Account__r.Sub_Status__c == system.label.brs_AgentResign_AccountSubStatus)
                           acc = new Account(Id = busFile.Account__c, Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_AnnualReportReason);
                        else if(busFile.Type__c == system.label.First_Report && system.today() >= busFile.Due_Date__c.addDays(365) && busFile.Account__r.Sub_Status__c == system.label.brs_AgentResign_AccountSubStatus)
                            acc = new Account(Id = busFile.Account__c, Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_FirstReportReason);
                        else if(busFile.Filing_Type__c == system.label.Notice_of_Intent_to_Dissolve_Revoke_Label && system.today() < busFile.Date_Intend_Forfeited__c && (busFile.Account__r.Sub_Status__c == system.label.No_Agent || busFile.Account__r.Sub_Status__c == system.label.Account_Annual_report_past_due || busFile.Account__r.Sub_Status__c == system.label.First_report_past_due))
                        {
                            acc = new Account(Id = busFile.Account__c, Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label);
                            accReasonUpdateIdSet2.add(busFile.Account__c);
                        }
                        else if(busFile.Filing_Type__c == system.label.Notice_of_Intent_to_Dissolve_Revoke_Label && system.today() > busFile.Date_Intend_Forfeited__c && busFile.Account__r.Sub_Status__c == system.label.Admin_Dissolution_Initiated_Label && busFile.Account__r.Citizenship__c != null)
                        {
                            if(busFile.Account__r.Citizenship__c == system.label.brs_maintenance_domestic)
                                acc = new Account(Id = busFile.Account__c, Sub_Status__c = system.label.brs_AdminDissolveReady_for_Forfeiture);
                            else if(busFile.Account__r.Citizenship__c == system.label.Foreign)
                                acc = new Account(Id = busFile.Account__c, Sub_Status__c = system.label.brs_AdminDissolveReady_for_Revocation);
                            accReasonUpdateIdSet2.add(busFile.Account__c);
                        }
                        if(acc.Id != null)
                        {
                            accUpdateIdMap.put(busFile.Account__c,acc);
                            accUpdateIdMap2.put(acc,busFile.Account__c);
                        }
                        }
                    }
                }
            }
            if(!accReasonUpdateIdSet2.IsEmpty())
            {
                List<Agent__c> agLst2 = [Select id,Business_ID__c from Agent__c where Business_ID__c != null and Business_ID__c in: accReasonUpdateIdSet2];
                if(!agLst2.IsEmpty())
                {
                    for(Agent__c ag : agLst2)
                    {
                        accUpdateIdSet3.add(ag.Business_ID__c);
                    }
                }
                for(String str : accReasonUpdateIdSet2)
                {
                    if(!accUpdateIdSet3.contains(str))
                    {
                        Account accOld = accUpdateIdMap4.get(str);
                        if(accOld.citizenship__c == system.label.domestic && accOld.business_type__c == system.label.LLP && accOld.BillingState == system.label.CT)
                        {
                            //nothing
                        }else
                        {
                            Account acc = accUpdateIdMap.get(str);
                            accUpdateIdMap2.remove(acc);
                            accUpdateIdMap.remove(str);
                            acc.Reason_for_Administrative_Dissolution__c = system.label.Failure_to_appoint_or_maintain_an_agent_for_service;
                            accUpdateIdMap.put(str,acc);
                            accUpdateIdMap2.put(acc,str);
                            accReasonUpdateIdSet2.remove(str);
                        }
                    }
                }
                if(!accReasonUpdateIdSet2.IsEmpty())
                {
                    List<Business_Filing__c> lstBusFile2 = [Select Id,Date_Intend_Forfeited__c,Due_Date__c,status__c,Filing_Type__c, Filing_Date__c,Account__c,Account__r.Citizenship__c,Account__r.Sub_Status__c,Type__c From Business_Filing__c where Account__c in: accReasonUpdateIdSet2 and Type__c In: fileType and Status__c =: system.label.Past_Due and Due_Date__c != null];
                    if(!lstBusFile2.IsEmpty())
                    {
                        for(Business_Filing__c busFile : lstBusFile2)
                        {
                            Account acc = accUpdateIdMap.get(busFile.Account__c);
                            accUpdateIdMap2.remove(acc);
                            accUpdateIdMap.remove(busFile.Account__c);
                            if(busFile.Type__c == system.label.Annual_Report && system.today() > busFile.Due_Date__c.addDays(365) && (busFile.Account__r.Sub_Status__c == system.label.No_Agent || busFile.Account__r.Sub_Status__c == system.label.Account_Annual_report_past_due || busFile.Account__r.Sub_Status__c == system.label.First_report_past_due || busFile.Account__r.Sub_Status__c == system.label.Admin_Dissolution_Initiated_Label))
                                acc.Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_AnnualReportReason;
                            else if(busFile.Type__c == system.label.First_Report && system.today() > busFile.Due_Date__c.addDays(365) && (busFile.Account__r.Sub_Status__c == system.label.No_Agent || busFile.Account__r.Sub_Status__c == system.label.Account_Annual_report_past_due || busFile.Account__r.Sub_Status__c == system.label.First_report_past_due || busFile.Account__r.Sub_Status__c == system.label.Admin_Dissolution_Initiated_Label))
                                acc.Reason_for_Administrative_Dissolution__c = system.label.brs_AdminDissolve_FirstReportReason;
                            accUpdateIdMap.put(busFile.Account__c,acc);
                            accUpdateIdMap2.put(acc,busFile.Account__c);
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
                        Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, accUpdateIdMap2.get(accUpdateIdMap.values().get(i)), BOS_Utility.sSeverity, null, system.label.brs_AdminDissolveBatchError +accUpdateIdMap2.get(accUpdateIdMap.values().get(i)));
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