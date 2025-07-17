/*********************************************************************************************
 * NAME:  brs_DateForfeitureBatch
 * DESCRIPTION: Batch class to update date of forfeiture from business filing
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 07/27/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     07/27/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class brs_DateForfeitureBatch implements Database.Batchable<sObject> {
    public static Final String className = 'brs_DateForfeitureBatch';
    public static Final String methodName = 'updateForfeitureOnAccount';
    public static Final String objectName = 'Account';
    public String query = '';
    public List<String> filingTypes = new List<String>{system.label.Notice_of_Intent_to_Dissolve_Revoke_Label};
    public List<String> filingTypes2 = new List<String>{system.label.brs_Reinstatement};
    public List<String> statuses = new List<String>{system.label.ACTIVE};
    public List<String> filingStatus = new List<String>{system.label.BRS_FilingStatus_Approved};    
    global brs_DateForfeitureBatch(String strQuery)
    {
        query  = strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Business_Filing__c> busFileListBatch) {
        try{
            Map<String,Business_Filing__c> accFilingMap =new Map<String,Business_Filing__c>();
            Map<String,Business_Filing__c> accReinstatementFilingMap =new Map<String,Business_Filing__c>();
            Map<String,Business_Filing__c> accIntentFilingMap =new Map<String,Business_Filing__c>();
            Map<String,Date> accDateMap =new Map<String,Date>();
            map<String,Account> accLstMap = new map<String,Account>();
            map<Account,String> accLstMap2 = new map<Account,String>();
            set<String> accUpdateIdSet3 = new set<String>();
            map<String,Account> accUpdateIdMap4 = new map<String,Account>();
            List<String> fileType = new List<String>{system.label.Annual_Report,system.label.First_Report};
            List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
            set<String> accUpdateIdSet2 = new set<String>();
            for(Business_Filing__c businessfiling : busFileListBatch){
                if(!accFilingMap.keyset().contains(businessfiling.Account__c))
                {
                    accFilingMap.put(businessfiling.Account__c,businessfiling);
                }
                else
                {
                    Business_Filing__c busFile = accFilingMap.get(businessfiling.Account__c);
                    if(busFile.Filing_Date__c < businessfiling.Filing_Date__c)
                    {
                    accFilingMap.remove(businessfiling.Account__c);
                    accFilingMap.put(businessfiling.Account__c,businessfiling);
                    }
                }
            }
            if(!accFilingMap.IsEmpty())
            {
                for(String str : accFilingMap.keyset())
                {
                    Business_Filing__c busFile2 = accFilingMap.get(str);
                    if(busFile2.filing_type__c == system.label.Notice_of_Intent_to_Dissolve_Revoke_Label)
                        accIntentFilingMap.put(str,busFile2);
                    else if(busFile2.type__c == system.label.brs_Reinstatement)
                        accReinstatementFilingMap.put(str,busFile2);
                }
            }
            if(!accReinstatementFilingMap.IsEmpty())
            {
                List<Business_Filing__c> lstBusFile3 = [Select Id,Date_Intend_Forfeited__c,Due_Date__c,status__c,Filing_Type__c, Filing_Date__c,Account__c,Account__r.Citizenship__c,Account__r.Sub_Status__c,Type__c From Business_Filing__c where Account__c in: accReinstatementFilingMap.keyset() and Type__c In: fileType and Status__c =: system.label.Past_Due and Due_Date__c != null];
                if(!lstBusFile3.IsEmpty())
                {
                    for(Business_Filing__c busFile : lstBusFile3)
                    {
                        if(accReinstatementFilingMap.keyset().contains(busFile.Account__c) && busFile.Type__c == system.label.Annual_Report && system.today() >= busFile.Due_Date__c.addDays(365) && !accLstMap.keyset().contains(busFile.Account__c))
                        {
                            Account acc2 = new Account(id=busFile.Account__c,Sub_Status__c = system.label.Ready_for_dissolution_Comparable);
                            accLstMap.put(busFile.Account__c,acc2);
                            accLstMap2.put(acc2,busFile.Account__c);
                            accReinstatementFilingMap.remove(busFile.Account__c);
                        } 
                    }
                    if(!accReinstatementFilingMap.IsEmpty())
                    {
                        for(Business_Filing__c busFile : lstBusFile3)
                        {
                            if(accReinstatementFilingMap.keyset().contains(busFile.Account__c) && busFile.Type__c == system.label.First_Report && system.today() >= busFile.Due_Date__c.addDays(365) && !accLstMap.keyset().contains(busFile.Account__c))
                            {
                                Account acc2 = new Account(id=busFile.Account__c,Sub_Status__c = system.label.Ready_for_dissolution_Comparable);
                                accLstMap.put(busFile.Account__c,acc2);
                                accLstMap2.put(acc2,busFile.Account__c);
                                accReinstatementFilingMap.remove(busFile.Account__c);
                            }
                        }
                    }
                }
                if(!accReinstatementFilingMap.IsEmpty())
                {   
                     List<Account> accLst = [Select Id, Date_Intend_Forfeited__c,Status__c,Sub_Status__c,Citizenship__c,business_type__c,BillingState from Account where id in : accReinstatementFilingMap.keyset()];
                    if(!accLst.IsEmpty())
                    {
                        for(Account acc : accLst)
                        {
                                accUpdateIdMap4.put(acc.Id,acc);
                        }
                    }
                    List<Agent__c> agLst = [Select id,Business_ID__c from Agent__c where Business_ID__c != null and Business_ID__c in: accReinstatementFilingMap.keyset()];
                    if(!agLst.IsEmpty())
                    {
                        for(Agent__c ag : agLst)
                        {
                            accUpdateIdSet2.add(ag.Business_ID__c);
                        }
                    }
                    for(String str : accReinstatementFilingMap.keyset())
                    {
                        if(!accUpdateIdSet2.contains(str))
                        {
                            Account accOld = accUpdateIdMap4.get(str);
                            if(accOld.citizenship__c == system.label.domestic && accOld.business_type__c == system.label.LLP && accOld.BillingState == system.label.CT)
                            {
                                //do nothing
                            }
                            else
                            {
                                Account acc = new Account(Id = str, sub_status__c = system.label.Ready_for_dissolution_Comparable);
                                accLstMap.put(str,acc);
                                accLstMap2.put(acc,str);
                            }
                                
                        }                               
                    } 
                }
            }
            if(!accIntentFilingMap.IsEmpty())
            {
                for(String str : accIntentFilingMap.keyset())
                {
                    Business_Filing__c busfile = accIntentFilingMap.get(str);
                    List<Business_Filing__c> busFileList3 = new List<Business_Filing__c>();
                    busFileList3.add(busfile);
                    Date forfeiteDate = null;
                    for(Business_Filing__c bus : busFileList3)
                    {
                        forfeiteDate = forfeiteDate == null && bus != null &&bus.Date_Intend_Forfeited__c != null ? bus.Date_Intend_Forfeited__c : (forfeiteDate < bus.Date_Intend_Forfeited__c ? bus.Date_Intend_Forfeited__c : forfeiteDate);
                    }
                    accDateMap.put(str,forfeiteDate);
                }
            }
            if(!accDateMap.IsEmpty())
            {
                List<Account> accLst = [Select Id, Date_Intend_Forfeited__c,Status__c,Sub_Status__c,Citizenship__c,business_type__c,BillingState from Account where id in : accDateMap.keyset()];
                if(!accLst.IsEmpty())
                {
                    for(Account acc : accLst)
                    {
                        if(acc.Sub_Status__c == system.label.Admin_Dissolution_Initiated_Label)
                        {
                            Account acc2 = new Account(id=acc.Id);
                            if(accDateMap.get(acc.Id) < system.today())
                            {
                                if(acc.Citizenship__c == system.label.brs_maintenance_domestic)
                                    acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Forfeiture;
                                else if(acc.Citizenship__c == system.label.Foreign)
                                    acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Revocation;
                            }
                            acc2.Date_Intend_Forfeited__c = accDateMap.get(acc.Id);
                            accLstMap.put(acc.Id,acc2);
                            accLstMap2.put(acc2,acc.Id);
                            accDateMap.remove(acc.Id);
                        }
                        else
                        {
                            accUpdateIdMap4.put(acc.Id,acc);
                        }
                     }
                 }
                 if(!accDateMap.IsEmpty())
                 {
                     List<Agent__c> agLst2 = [Select id,Business_ID__c from Agent__c where Business_ID__c != null and Business_ID__c in: accDateMap.keySet()];
                     if(!agLst2.IsEmpty())
                     {
                        for(Agent__c ag : agLst2)
                        {
                            accUpdateIdSet3.add(ag.Business_ID__c);
                        }
                     }
                     for(String str : accDateMap.keySet())
                     {
                        if(!accUpdateIdSet3.contains(str))
                        {
                            Account accOld = accUpdateIdMap4.get(str);
                            if(accOld.citizenship__c == system.label.domestic && accOld.business_type__c == system.label.LLP && accOld.BillingState == system.label.CT)
                            {
                                //nothing
                            }
                            else
                            {
                                Account acc2 = new Account(id=str);
                                if(accDateMap.get(str) < system.today())
                                {
                                    if(accOld.Citizenship__c == system.label.brs_maintenance_domestic)
                                        acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Forfeiture;
                                    else if(accOld.Citizenship__c == system.label.Foreign)
                                        acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Revocation;
                                }
                                else
                                    acc2.Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label;
                                acc2.Date_Intend_Forfeited__c = accDateMap.get(str);
                                accLstMap.put(str,acc2);
                                accLstMap2.put(acc2,str);
                                accDateMap.remove(str);
                            }
                        }
                     }
                 }
                 if(!accDateMap.IsEmpty())
                 {
                    List<Business_Filing__c> lstBusFile2 = [Select Id,Date_Intend_Forfeited__c,Due_Date__c,status__c,Filing_Type__c, Filing_Date__c,Account__c,Account__r.Citizenship__c,Account__r.Sub_Status__c,Type__c From Business_Filing__c where Account__c in: accDateMap.keyset() and Type__c In: fileType and Status__c =: system.label.Past_Due and Due_Date__c != null];
                    if(!lstBusFile2.IsEmpty())
                    {
                        for(Business_Filing__c busFile : lstBusFile2)
                        {
                            Account accOld = accUpdateIdMap4.get(busFile.Account__c);
                            if((busFile.Type__c == system.label.Annual_Report || busFile.Type__c == system.label.First_Report) && system.today() >= busFile.Due_Date__c.addDays(365) && !accLstMap.keyset().contains(busFile.Account__c))
                            {
                                Account acc2 = new Account(id=busFile.Account__c);
                                if(accDateMap.get(busFile.Account__c) < system.today())
                                {
                                    if(accOld.Citizenship__c == system.label.brs_maintenance_domestic)
                                        acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Forfeiture;
                                    else if(accOld.Citizenship__c == system.label.Foreign)
                                        acc2.Sub_Status__c = system.label.brs_AdminDissolveReady_for_Revocation;
                                }
                                else
                                    acc2.Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label;
                                acc2.Date_Intend_Forfeited__c = accDateMap.get(busFile.Account__c);
                                accLstMap.put(busFile.Account__c,acc2);
                                accLstMap2.put(acc2,busFile.Account__c);
                            }
                        }
                    }
                }
            }
            if(!accLstMap.IsEmpty())
            {
               Database.SaveResult[] accChangeSuccessList = Database.update(accLstMap.values(), false);
               for(Integer i=0;i<accChangeSuccessList.size();i++){
                   if (!accChangeSuccessList.get(i).isSuccess())
                   {
                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, accLstMap2.get(accLstMap.values().get(i)), BOS_Utility.sSeverity, null, system.label.AdminDissolve_Filing_Update_Error_Message + accLstMap2.get(accLstMap.values().get(i)));
                       errorFilingLst.add(err);
                   }   
               }
            }
            if(!errorFilingLst.IsEmpty())
               BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, methodName, objectName, null, null, ex, ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}