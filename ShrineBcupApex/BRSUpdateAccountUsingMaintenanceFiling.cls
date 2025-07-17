/*********************************************************************************************
 * NAME:  BRSUpdateAccountUsingMaintenanceFiling
 * DESCRIPTION: Batch class to update account/principal/agent on business filing effective date for LLC business
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 02/23/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     02/23/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class BRSUpdateAccountUsingMaintenanceFiling implements Database.Batchable<sObject>,Database.Stateful {
    public static Final String className = 'BRSUpdateAccountUsingMaintenanceFiling';
    public static Final String methodName = 'BusinessMaintenance';
    public static Final String objectName = 'Business_Filing__c';
    public String query = '';
    public List<Id> businessFilingId= new List<Id>();
    public Integer priorDayCount = Integer.valueOf(system.label.brs_updateMaintenanceFilings_Days);
    public Date today = Date.today();
    public Date priorDay = Date.today().addDays(priorDayCount);
    public List<String> filingStatus = new List<String>{system.label.Label_Pending_Filing_1,system.label.BRS_FilingStatus_Approved};
    global BRSUpdateAccountUsingMaintenanceFiling(String strQuery)
    {
        query  = strQuery;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       /** collect the batches of records or objects to be passed to execute **/
      return Database.getQueryLocator(query);
   }
    public void execute(Database.BatchableContext BC,List<Business_Filing__c> busFilingList) {
       // List<Update_SObject_Automation__mdt> configLst = [Select Id, MasterLabel, DeveloperName, Business_Filing_Type__c, Status_Value__c, Target_Object__c from Update_SObject_Automation__mdt];
        map<String,List<maintenanceFilingUpdateWrapper>> maintenanceFilingMap = new map<String,List<maintenanceFilingUpdateWrapper>>();
        List<Account> accLst = new List<Account>();
        set<String> busFileIds = new set<String>();
        List<Temp_History__c> TempRecs = new List<Temp_History__c>();
        Map<String,List<Principal__c>> insertPrincipal = new Map<String,List<Principal__c>>();
        List<Principal__c> deletePrincipal = new List<Principal__c>();
        List<Agent__c> insertAgent = new List<Agent__c>();
        List<Agent__c> updateAgentAddress = new List<Agent__c>();
        List<Agent__c> deleteAgent = new List<Agent__c>();
        List<Agent__c> deleteResAgent = new List<Agent__c>();
        Map<String,String> deleteChangedAgentFilingMap = new Map<String,String>();
        Map<String,Agent__c> insertChangedAgentFilingMap = new Map<String,Agent__c>();
        Map<String,String> deleteAgentFilingMap = new Map<String,String>();
        Map<String,Account> deleteAgentAccUpdateMap = new Map<String,Account>();
        Map<String,Account> deleteAgentAccUpdateOldMap = new Map<String,Account>();
        Map<String,String> deleteAgentAccFilingMap = new Map<String,String>();
        Map<String,Agent__c> updateAgentAddressfilingOldMap = new Map<String,Agent__c>();
        Map<String,String> updateAgentAddressFilingMap = new Map<String,String>();
        map<String,Account> accMap = new map<String,Account>();
        map<String,Account> accFilingOldMap = new map<String,Account>();
        map<String,set<String>> accFilingMap = new map<String,set<String>>();
        map<String,String> filingAccMap = new map<String,String>();
        set<String> busFileIds2 = new set<String>();
        List<Business_History__c> busHistoryRecs = new List<Business_History__c>();
        Set<Id> actItemsAccounts = new Set<Id>();
        Map<String,maintenanceFilingUpdateWrapper> checkDuplicateMap=new Map<String,maintenanceFilingUpdateWrapper>();
        for(Update_SObject_Automation__mdt config : [Select Id, MasterLabel, DeveloperName, Business_Filing_Type__c, Status_Value__c, Target_Object__c from Update_SObject_Automation__mdt])
        {
            List<maintenanceFilingUpdateWrapper> maintenanceFileLst = new List<maintenanceFilingUpdateWrapper>();
            for(Business_Filing__c busFile : busFilingList)
            {    
                if(config.Business_Filing_Type__c == busFile.Type__c)
                {
                    maintenanceFilingUpdateWrapper maintenanceFile = new maintenanceFilingUpdateWrapper();
                    maintenanceFile.busFilingId = busFile.Id;
                    maintenanceFile.busId = busFile.Account__c;
                    maintenanceFile.tarObj = config.Target_Object__c;
                    maintenanceFile.statusValue = config.Status_Value__c+'-'+busFile.Account__r.Status__c;
                    maintenanceFile.filingType = config.Business_Filing_Type__c;
                    maintenanceFile.checkDuplicate= config.Business_Filing_Type__c+'-'+busFile.Account__c; 
                    if(!checkDuplicateMap.containsKey(config.Business_Filing_Type__c+'-'+busFile.Account__c))
                    {
                        checkDuplicateMap.Put(config.Business_Filing_Type__c+'-'+busFile.Account__c,maintenanceFile);
                        maintenanceFileLst.add(maintenanceFile);
                    }
                }
            }
            maintenanceFilingMap.put(config.Business_Filing_Type__c,maintenanceFileLst);
        }
        for(String str : maintenanceFilingMap.keySet())
        {
            List<maintenanceFilingUpdateWrapper> maintenanceFileLst2 = maintenanceFilingMap.get(str);
            for(maintenanceFilingUpdateWrapper file : maintenanceFileLst2)
            {  
               if(file.filingType == system.label.Withdrawal_Label ||
                file.filingType == system.label.Renunciation_Status_Report ||
                file.filingType == system.label.Dissolution_Label)
                {
                    Account acc = new Account(Id=file.busId,Status__c=file.statusValue.substringBefore('-'));
                    accLst.add(acc);
                    actItemsAccounts.add(acc.Id);
                    if(!accFilingMap.keyset().contains(file.busId))
                    {
                        set<String> filingIds = new set<String>();
                        filingIds.add(file.busFilingId);
                        accFilingMap.put(file.busId,filingIds);
                    }
                    else
                    {
                        set<String> filingIds1 = accFilingMap.get(file.busId);
                        filingIds1.add(file.busFilingId);
                        accFilingMap.remove(file.busId);
                        accFilingMap.put(file.busId,filingIds1);
                    }
                    filingAccMap.put(file.busFilingId,file.busId);
                    accFilingOldMap.put(file.busId,new Account(Id=file.busId,Status__c=file.statusValue.substringAfter('-')));
                }
                else if(file.filingType == system.label.Conversion_Label||
                    file.filingType == system.label.Merger_Label||
                    file.filingType == system.label.Domestication_Label)
                {
                    busFileIds2.add(file.busFilingId);
                }
                else
                {
                   busFileIds.add(file.busFilingId); 
                }
            }
        }
        if(!busFileIds.IsEmpty())
        {
           String queryString = 'Select id, Name, Title__c,Principal__c, Designation__c, Agent__c,NAICS_Code__c,NAICS_Code_New__c,Business_Name_New__c,Business_Name__c,Business_Name_in_state_country__c,';
           queryString+='Agent__r.Business_City__c, Agent__r.Business_Street_Address_1__c, Agent__r.Business_Street_Address_2__c, Agent__r.Business_Zip_Code__c , Agent__r.Business_State__c, Agent__r.Business_Country__c,';
           queryString+='Agent__r.Business_InternationalAddress__c, Agent__r.Residence_City__c, Agent__r.Residence_Street_Address_1__c, Agent__r.Residence_Street_Address_2__c, Agent__r.Residence_Zip_Code__c, Agent__r.Residence_State__c ,';
           queryString+='Agent__r.Residence_Country__c, Agent__r.Mailing_City__c, Agent__r.Mailing_Street_Address_1__c, Agent__r.Mailing_Street_Address_2__c, Agent__r.Mailing_Zip_Code__c, Agent__r.Mailing_State__c ,Agent__r.Mailing_Country__c,';
           queryString+='Account__r.BillingCity, Account__r.BillingCountry, Account__r.BillingPostalCode,Account__r.BillingState,Account__r.BillingStreet, Account__r.Billing_Unit__c,';
           queryString+='Account__r.Jurisdiction_International_address__c, Account__r.Mailing_International_Address__c, Account__r.Mailing_Jurisdiction_BusinessCity__c,Account__r.Mailing_Jurisdiction_BusinessState__c,Account__r.Mailing_Jurisdiction_BusinessStreet__c, Account__r.Mailing_Jurisdiction_BusinessUnit__c,Account__r.Mailing_Jurisdiction_BusinessZipCode__c,Account__r.Mailing_Jurisdiction_Country__c,';
           queryString+='Account__r.Office_Jurisdiction_BusinessCity__c, Account__r.Office_Jurisdiction_BusinessState__c, Account__r.Office_Jurisdiction_BusinessStreet__c,Account__r.Office_Jurisdiction_BusinessUnit__c,Account__r.Office_Jurisdiction_BusinessZipCode__c, Account__r.Office_in_Jurisdiction_Country__c,Account__r.Principle_Office_International_Address__c,';
           queryString+='Account__r.ShippingCity, Account__r.ShippingCountry, Account__r.ShippingPostalCode,Account__r.ShippingState,Account__r.ShippingStreet, Account__r.Shipping_Unit__c,';
           queryString+='Business_ID__c, Business_ID__r.AccountNumber, Account__c,Account__r.Sub_status__c,Account__r.AccountNumber, FirstName__c,temp_type__c,';
           queryString+='LastName__c, Name__c, Email__c, Business_Filing__c,Business_Filing__r.Type__c,Business_Filing__r.Status__c,Business_Filing__r.Business_Type__c, Business_InternationalAddress__c,';
           queryString+='Residence_InternationalAddress__c, Created_From_Agent__c,Business_City__c, Business_Country__c, Business_State__c,';
           queryString+='Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,';
           queryString+='Mailing_City__c, Change_Type__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c,Business_Id__r.Sub_status__c,';
           queryString+='Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,Principal_Title__c, Residence_State__c, Residence_City__c,';
           queryString+='Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c,';
           queryString+='Billing_City_New__c, Billing_Country_New__c, BillingPostalCode_New__c, BillingState_New__c,BillingStreet_New__c,Business_Name_in_state_country_New__c,';
           queryString+='ShippingCity_New__c,Phone__c, Shipping_Country_New__c,Type__c, ShippingPostalCode_New__c, ShippingState_New__c,ShippingStreet_New__c,Principle_Office_International_Address_N__c,';
           queryString+='Office_Jurisdiction_BusinessZipCode_New__c, Office_Jurisdiction_BusinessStreet_New__c, Office_Jurisdiction_BusinessState_New__c, Office_Jurisdiction_BusinessCity_New__c,Jurisdiction_International_address_New__c,';
           queryString+='Mailing_Jurisdiction_BusinessZipCode_New__c,Email_New__c,Business_Email_Address__c, Mailing_Jurisdiction_BusinessStreet_New__c, Mailing_Jurisdiction_BusinessState_New__c, Mailing_Jurisdiction_BusinessCity_New__c,Mailing_International_Address_New__c,';
           queryString+='Residence_Country__c from Temp_History__c';

           String whereClause = ' Where Business_Filing__c in: busFileIds' ;
           queryString = queryString + whereClause;
           TempRecs = Database.query(queryString);
           if (!TempRecs.IsEmpty()) {
               for(Temp_History__c rec : TempRecs)
               {
                   if(rec.Type__c == system.label.Principal && rec.Business_Filing__r.Type__c == system.label.brs_BusinessMaintenanceMainFLow_InterimNoticeFlowTitle2 && rec.Business_Filing__r.Business_Type__c==system.label.LLC && rec.Business_Filing__r.Status__c == system.label.Label_Pending_Filing_1)
                   {
                       Principal__c pr = new Principal__c();
                       if(rec.Change_Type__c == system.label.brs_maintenance_tempCreated)
                       {
                           pr.Business_City__c = rec.Business_City__c;
                           pr.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                           pr.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                           pr.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                           pr.Business_State__c = rec.Business_State__c;
                           pr.Business_Country__c = rec.Business_Country__c;
                           pr.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                           if(rec.Principal_Title__c != null)
                               pr.Principal_Title__c = rec.Principal_Title__c;
                           else
                               pr.Principal_Title__c = rec.Title__c;
                           pr.FirstName__c = rec.FirstName__c;
                           pr.LastName__c = rec.LastName__c;
                           pr.Name__c = rec.Name__c;
                           if(rec.Email__c != null)
                               pr.Email__c = rec.Email__c;
                           pr.Residence_City__c = rec.Residence_City__c;
                           pr.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                           pr.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                           pr.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                           pr.Residence_State__c = rec.Residence_State__c;
                           pr.Residence_Country__c = rec.Residence_Country__c;
                           pr.Residence_InternationalAddress__c = rec.Residence_InternationalAddress__c;
                           pr.Principal_Account_ID__c = rec.Business_Id__c;
                           pr.Business_ID__c = rec.Business_Id__c;
                           if(!insertPrincipal.keyset().contains(rec.Business_Filing__c))
                           {
                               List<Principal__c> principalList2 = new List<Principal__c>();
                               principalList2.add(pr);
                               insertPrincipal.put(rec.Business_Filing__c,principalList2);
                           }
                           else
                           {
                               List<Principal__c> principalList = insertPrincipal.get(rec.Business_Filing__c);
                               principalList.add(pr);
                               insertPrincipal.remove(rec.Business_Filing__c);
                               insertPrincipal.put(rec.Business_Filing__c,principalList);
                           }
                       } else if(rec.Change_Type__c == system.label.Deleted && rec.Principal__c != null)
                       {
                           pr.Id = rec.Principal__c;
                           deletePrincipal.add(pr);
                       }
                   }
                   else if(rec.Type__c == system.label.Agent)
                   {   
                       Agent__c ag = new Agent__c();
                       if(rec.Business_Filing__r.Type__c == system.label.brs_AgentAddressChange_FilingType  && rec.Business_Filing__r.Business_Type__c== system.label.LLC && rec.Agent__c != null && rec.Business_Filing__r.Status__c == system.label.Label_Pending_Filing_1)
                       {
                           Agent__c oldAg = new Agent__c();
                           ag.Id = rec.Agent__c;
                           oldAg.Business_City__c = rec.Agent__r.Business_City__c;
                           if(rec.Business_City__c != null)
                               ag.Business_City__c = rec.Business_City__c;
                           oldAg.Business_Street_Address_1__c = rec.Agent__r.Business_Street_Address_1__c;
                           if(rec.Business_Street_Address_1__c != null)
                               ag.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                           oldAg.Business_Street_Address_2__c = rec.Agent__r.Business_Street_Address_2__c;
                           if(rec.Business_Street_Address_2__c != null)
                               ag.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                           oldAg.Business_Zip_Code__c = rec.Agent__r.Business_Zip_Code__c;
                           if(rec.Business_Zip_Code__c != null)
                               ag.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                           oldAg.Business_State__c = rec.Agent__r.Business_State__c;
                           if(rec.Business_State__c != null)
                               ag.Business_State__c = rec.Business_State__c;
                           oldAg.Business_Country__c = rec.Agent__r.Business_Country__c;
                           if(rec.Business_Country__c != null)
                               ag.Business_Country__c = rec.Business_Country__c;
                           oldAg.Business_InternationalAddress__c = rec.Agent__r.Business_InternationalAddress__c;
                           if(rec.Business_InternationalAddress__c != null)
                               ag.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                           oldAg.Residence_City__c = rec.Agent__r.Residence_City__c;
                           if(rec.Residence_City__c != null)
                               ag.Residence_City__c = rec.Residence_City__c;
                           oldAg.Residence_Street_Address_1__c = rec.Agent__r.Residence_Street_Address_1__c;
                           if(rec.Residence_Street_Address_1__c != null)
                               ag.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                           oldAg.Residence_Street_Address_2__c = rec.Agent__r.Residence_Street_Address_2__c;
                           if(rec.Residence_Street_Address_2__c != null)
                               ag.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                           oldAg.Residence_Zip_Code__c = rec.Agent__r.Residence_Zip_Code__c;
                           if(rec.Residence_Zip_Code__c != null)
                               ag.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                           oldAg.Residence_State__c = rec.Agent__r.Residence_State__c;
                           if(rec.Residence_State__c != null)
                               ag.Residence_State__c = rec.Residence_State__c;
                           oldAg.Residence_Country__c = rec.Agent__r.Residence_Country__c;
                           if(rec.Residence_Country__c != null)
                               ag.Residence_Country__c = rec.Residence_Country__c;
                           oldAg.Mailing_City__c = rec.Agent__r.Mailing_City__c;
                           if(rec.Mailing_City__c != null)
                               ag.Mailing_City__c = rec.Mailing_City__c;
                           oldAg.Mailing_Street_Address_1__c = rec.Agent__r.Mailing_Street_Address_1__c;
                           if(rec.Mailing_Street_Address_1__c != null)
                               ag.Mailing_Street_Address_1__c = rec.Mailing_Street_Address_1__c;
                           oldAg.Mailing_Street_Address_2__c = rec.Agent__r.Mailing_Street_Address_2__c;
                           if(rec.Mailing_Street_Address_2__c != null)
                               ag.Mailing_Street_Address_2__c = rec.Mailing_Street_Address_2__c;
                           oldAg.Mailing_Zip_Code__c = rec.Agent__r.Mailing_Zip_Code__c;
                           if(rec.Mailing_Zip_Code__c != null)
                               ag.Mailing_Zip_Code__c = rec.Mailing_Zip_Code__c;
                           oldAg.Mailing_State__c = rec.Agent__r.Mailing_State__c;
                           if(rec.Mailing_State__c != null)
                               ag.Mailing_State__c = rec.Mailing_State__c;
                           oldAg.Mailing_Country__c = rec.Agent__r.Mailing_Country__c;
                           if(rec.Mailing_Country__c != null)
                               ag.Mailing_Country__c = rec.Mailing_Country__c;
                           updateAgentAddress.add(ag);
                           updateAgentAddressFilingMap.put(rec.Agent__c,rec.Business_Filing__c);
                           updateAgentAddressfilingOldMap.put(rec.Business_Filing__c,oldAg);
                       }
                       else if(rec.Business_Filing__r.Type__c == system.label.brs_AgentChange_FilingType && rec.Business_Filing__r.Business_Type__c== system.label.LLC && rec.Business_Filing__r.Status__c == system.label.Label_Pending_Filing_1)
                       { 
                           if(rec.Change_Type__c == system.label.brs_maintenance_tempCreated)
                           {
                               ag.Agent_Phone__c = rec.Phone__c;
                               ag.Type__c = rec.temp_type__c;    //BRS-4378
                               ag.FirstName__c = rec.FirstName__c;
                               ag.LastName__c = rec.LastName__c;
                               ag.Name__c = rec.Name__c;
                               ag.Email__c = rec.Email__c;
                               ag.Business_City__c = rec.Business_City__c;
                               ag.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                               ag.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                               ag.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                               ag.Business_State__c = rec.Business_State__c;
                               ag.Business_Country__c = rec.Business_Country__c;
                               ag.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                               ag.Residence_City__c = rec.Residence_City__c;
                               ag.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                               ag.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                               ag.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                               ag.Residence_State__c = rec.Residence_State__c;
                               ag.Residence_Country__c = rec.Residence_Country__c;
                               ag.Mailing_City__c = rec.Mailing_City__c;
                               ag.Mailing_Street_Address_1__c = rec.Mailing_Street_Address_1__c;
                               ag.Mailing_Street_Address_2__c = rec.Mailing_Street_Address_2__c;
                               ag.Mailing_Zip_Code__c = rec.Mailing_Zip_Code__c;
                               ag.Mailing_State__c = rec.Mailing_State__c;
                               ag.Mailing_Country__c = rec.Mailing_Country__c;
                               ag.Agent_Account_ID__c = rec.temp_type__c== System.label.Business_Comparable?rec.Account__c:null;
                               ag.Business_ID__c = rec.Business_Id__c;
                               insertChangedAgentFilingMap.put(rec.Business_Filing__c,ag);
                           } else if(rec.Change_Type__c == system.label.Deleted && rec.Agent__c != null)
                           {
                               ag.Id = rec.Agent__c;
                               deleteAgent.add(ag);
                               deleteChangedAgentFilingMap.put(rec.Agent__c,rec.Business_Filing__c);
                           }
                       }
                       else if(rec.Business_Filing__r.Type__c == system.label.brs_AgentResignation && rec.Business_Filing__r.Status__c == system.label.BRS_FilingStatus_Approved && rec.Agent__c != null)
                       {
                               List<Agent__c> ag2 = [Select id from Agent__c where Business_ID__c =: rec.Business_ID__c and id =: rec.Agent__c limit 1];
                               if(!ag2.IsEmpty())
                               {
                                   // Added sub status on account if the agents resigns. After 30 days account sub status is set to 'Ready for dissolution' : ref BRS-3141
                                   Account acc3 = new Account(Id=rec.Business_ID__c,Sub_status__c=System.Label.Ready_for_dissolution,Reason_for_Administrative_Dissolution__c = system.label.Failure_to_appoint_or_maintain_an_agent_for_service);
                                   deleteAgentAccUpdateMap.put(rec.Business_Filing__c,acc3);
                                   Account acc4 = new Account(Id=rec.Business_ID__c,Sub_status__c=rec.Business_Id__r.Sub_status__c);
                                   deleteAgentAccUpdateOldMap.put(rec.Business_Filing__c,acc4);
                                   deleteAgentAccFilingMap.put(rec.Business_ID__c,rec.Business_Filing__c);
                               }
                               ag.Id = rec.Agent__c;
                               deleteResAgent.add(ag);
                               deleteAgentFilingMap.put(rec.Agent__c,rec.Business_Filing__c);
                       }
                   }
                   else if(rec.Type__c == system.label.Account && rec.Account__c != null && rec.Business_Filing__r.Status__c == system.label.Label_Pending_Filing_1)
                   {
                        if(!accFilingMap.keyset().contains(rec.Account__c))
                        {
                            set<String> filingIds = new set<String>();
                            filingIds.add(rec.Business_Filing__c);
                            accFilingMap.put(rec.Account__c,filingIds);
                        }
                        else
                        {
                            set<String> filingIds1 = accFilingMap.get(rec.Account__c);
                            filingIds1.add(rec.Business_Filing__c);
                            accFilingMap.remove(rec.Account__c);
                            accFilingMap.put(rec.Account__c,filingIds1);
                        }
                       filingAccMap.put(rec.Business_Filing__c,rec.Account__c);
                       Account acc2 = new Account();
                       Account oldAcc = new Account();
                       if (rec.Business_Filing__r.Type__c == system.label.brs_NAICSChange_FilingType && rec.Business_Filing__r.Business_Type__c== system.label.LLC)
                       {
                           if(!accMap.Keyset().Contains(rec.Account__c))
                           {
                               acc2.Id = rec.Account__c;
                               acc2.NAICS_Code__c = rec.NAICS_Code_New__c;
                               oldAcc.Id = rec.Account__c;
                               oldAcc.NAICS_Code__c = rec.NAICS_Code__c;
                           }
                           else
                           {
                               acc2 = accMap.get(rec.Account__c);
                               acc2.NAICS_Code__c = rec.NAICS_Code_New__c;
                               accMap.remove(rec.Account__c);
                               oldAcc = accFilingOldMap.get(rec.Account__c);
                               oldAcc.NAICS_Code__c = rec.NAICS_Code__c;
                               accFilingOldMap.remove(rec.Account__c);
                           }
                           accMap.put(rec.Account__c,acc2);
                           accFilingOldMap.put(rec.Account__c,oldAcc);
                       }
                       else if (rec.Business_Filing__r.Type__c == system.label.brs_EmailChange_FilingType && rec.Business_Filing__r.Business_Type__c== system.label.LLC)
                       {
                           if(!accMap.Keyset().Contains(rec.Account__c))
                           {
                               acc2.Id = rec.Account__c;
                               acc2.Business_Email_Address__c = rec.Email_New__c;
                               oldAcc.Id = rec.Account__c;
                               oldAcc.Business_Email_Address__c = rec.Business_Email_Address__c;
                           }
                           else
                           {
                               acc2 = accMap.get(rec.Account__c);
                               acc2.Business_Email_Address__c = rec.Email_New__c;
                               accMap.remove(rec.Account__c);
                               oldAcc = accFilingOldMap.get(rec.Account__c);
                               oldAcc.Business_Email_Address__c = rec.Business_Email_Address__c;
                               accFilingOldMap.remove(rec.Account__c);
                           }
                           accMap.put(rec.Account__c,acc2);
                           accFilingOldMap.put(rec.Account__c,oldAcc);
                       }
                       else if (rec.Business_Filing__r.Type__c == system.label.brs_name_change_amendment_flow && rec.Business_Filing__r.Business_Type__c== system.label.LLC)
                       {
                           if(!accMap.Keyset().Contains(rec.Account__c))
                           {
                               acc2.Id = rec.Account__c;
                               acc2.Name = rec.Business_Name_New__c;
                               if(rec.Business_Name_in_state_country_New__c != null)
                                   acc2.Business_Name_in_state_country__c = rec.Business_Name_in_state_country_New__c;
                               oldAcc.Id = rec.Account__c;
                               oldAcc.Name = rec.Business_Name__c;
                               if(rec.Business_Name_in_state_country__c != null)
                                   oldAcc.Business_Name_in_state_country__c = rec.Business_Name_in_state_country__c;
                           }
                           else
                           {
                               acc2 = accMap.get(rec.Account__c);
                               acc2.Name = rec.Business_Name_New__c;
                               if(rec.Business_Name_in_state_country_New__c != null)
                                   acc2.Business_Name_in_state_country__c = rec.Business_Name_in_state_country_New__c;
                               accMap.remove(rec.Account__c);
                               oldAcc = accFilingOldMap.get(rec.Account__c);
                               oldAcc.Name = rec.Business_Name__c;
                               if(rec.Business_Name_in_state_country__c != null)
                                   oldAcc.Business_Name_in_state_country__c = rec.Business_Name_in_state_country__c;
                               accFilingOldMap.remove(rec.Account__c);
                           }
                           accMap.put(rec.Account__c,acc2);
                           accFilingOldMap.put(rec.Account__c,oldAcc);
                       }
                       else if (rec.Business_Filing__r.Type__c == system.label.brs_maintenance_Address2 && rec.Business_Filing__r.Business_Type__c== system.label.LLC)
                       {
                           if(!accMap.Keyset().Contains(rec.Account__c))
                           {
                               acc2.Id = rec.Account__c;
                               oldAcc.BillingCity = rec.Account__r.BillingCity;
                               if(rec.Billing_City_New__c != null)
                                   acc2.BillingCity = rec.Billing_City_New__c;
                               oldAcc.BillingCountry = rec.Account__r.BillingCountry;
                               if(rec.Billing_Country_New__c != null)
                                   acc2.BillingCountry = rec.Billing_Country_New__c;
                               oldAcc.BillingPostalCode = rec.Account__r.BillingPostalCode;
                               if(rec.BillingPostalCode_New__c!= null)
                                   acc2.BillingPostalCode = rec.BillingPostalCode_New__c;
                               oldAcc.BillingState = rec.Account__r.BillingState;
                               if(rec.BillingState_New__c != null)
                                   acc2.BillingState = rec.BillingState_New__c;
                               oldAcc.BillingStreet = rec.Account__r.BillingStreet;
                               if(rec.BillingStreet_New__c != null)    
                                   acc2.BillingStreet = rec.BillingStreet_New__c;
                               oldAcc.ShippingCity = rec.Account__r.ShippingCity;
                               if(rec.ShippingCity_New__c != null)    
                                   acc2.ShippingCity = rec.ShippingCity_New__c;
                               oldAcc.ShippingCountry = rec.Account__r.ShippingCountry;
                               if(rec.Shipping_Country_New__c != null)
                                   acc2.ShippingCountry = rec.Shipping_Country_New__c;
                               oldAcc.ShippingPostalCode = rec.Account__r.ShippingPostalCode;
                               if(rec.ShippingPostalCode_New__c != null)
                                   acc2.ShippingPostalCode = rec.ShippingPostalCode_New__c;
                               oldAcc.ShippingState = rec.Account__r.ShippingState;
                               if(rec.ShippingState_New__c != null)
                                   acc2.ShippingState = rec.ShippingState_New__c;
                               oldAcc.ShippingStreet = rec.Account__r.ShippingStreet;
                               if(rec.ShippingStreet_New__c != null)
                                   acc2.ShippingStreet = rec.ShippingStreet_New__c;
                               oldAcc.Principle_Office_International_Address__c = rec.Account__r.Principle_Office_International_Address__c;
                               if(rec.Principle_Office_International_Address_N__c != null)
                                   acc2.Principle_Office_International_Address__c = rec.Principle_Office_International_Address_N__c;
                               oldAcc.Office_Jurisdiction_BusinessZipCode__c = rec.Account__r.Office_Jurisdiction_BusinessZipCode__c;
                               if(rec.Office_Jurisdiction_BusinessZipCode_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessZipCode__c = rec.Office_Jurisdiction_BusinessZipCode_New__c;
                               oldAcc.Office_Jurisdiction_BusinessStreet__c = rec.Account__r.Office_Jurisdiction_BusinessStreet__c;
                               if(rec.Office_Jurisdiction_BusinessStreet_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessStreet__c = rec.Office_Jurisdiction_BusinessStreet_New__c;
                               oldAcc.Office_Jurisdiction_BusinessState__c = rec.Account__r.Office_Jurisdiction_BusinessState__c;
                               if(rec.Office_Jurisdiction_BusinessState_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessState__c = rec.Office_Jurisdiction_BusinessState_New__c;
                               oldAcc.Office_Jurisdiction_BusinessCity__c = rec.Account__r.Office_Jurisdiction_BusinessCity__c;
                               if(rec.Office_Jurisdiction_BusinessCity_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessCity__c = rec.Office_Jurisdiction_BusinessCity_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessZipCode__c = rec.Account__r.Mailing_Jurisdiction_BusinessZipCode__c;
                               if(rec.Mailing_Jurisdiction_BusinessZipCode_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessZipCode__c = rec.Mailing_Jurisdiction_BusinessZipCode_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessStreet__c = rec.Account__r.Mailing_Jurisdiction_BusinessStreet__c;
                               if(rec.Mailing_Jurisdiction_BusinessStreet_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessStreet__c = rec.Mailing_Jurisdiction_BusinessStreet_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessState__c = rec.Account__r.Mailing_Jurisdiction_BusinessState__c;
                               if(rec.Mailing_Jurisdiction_BusinessState_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessState__c = rec.Mailing_Jurisdiction_BusinessState_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessCity__c = rec.Account__r.Mailing_Jurisdiction_BusinessCity__c;
                               if(rec.Mailing_Jurisdiction_BusinessCity_New__c != null)    
                                   acc2.Mailing_Jurisdiction_BusinessCity__c = rec.Mailing_Jurisdiction_BusinessCity_New__c;
                               oldAcc.Mailing_International_Address__c = rec.Account__r.Mailing_International_Address__c;
                               if(rec.Mailing_International_Address_New__c != null)
                                   acc2.Mailing_International_Address__c = rec.Mailing_International_Address_New__c;
                               oldAcc.Jurisdiction_International_address__c = rec.Account__r.Jurisdiction_International_address__c;
                               if(rec.Jurisdiction_International_address_New__c != null)
                                   acc2.Jurisdiction_International_address__c = rec.Jurisdiction_International_address_New__c;
                           }
                           else
                           {
                               acc2 = accMap.get(rec.Account__c);
                               oldAcc = accFilingOldMap.get(rec.Account__c);
                               oldAcc.BillingCity = rec.Account__r.BillingCity;
                               if(rec.Billing_City_New__c != null)
                                   acc2.BillingCity = rec.Billing_City_New__c;
                               oldAcc.BillingCountry = rec.Account__r.BillingCountry;
                               if(rec.Billing_Country_New__c != null)
                                   acc2.BillingCountry = rec.Billing_Country_New__c;
                               oldAcc.BillingPostalCode = rec.Account__r.BillingPostalCode;
                               if(rec.BillingPostalCode_New__c!= null)
                                   acc2.BillingPostalCode = rec.BillingPostalCode_New__c;
                               oldAcc.BillingState = rec.Account__r.BillingState;
                               if(rec.BillingState_New__c != null)
                                   acc2.BillingState = rec.BillingState_New__c;
                               oldAcc.BillingStreet = rec.Account__r.BillingStreet;
                               if(rec.BillingStreet_New__c != null)    
                                   acc2.BillingStreet = rec.BillingStreet_New__c;
                               oldAcc.ShippingCity = rec.Account__r.ShippingCity;
                               if(rec.ShippingCity_New__c != null)    
                                   acc2.ShippingCity = rec.ShippingCity_New__c;
                               oldAcc.ShippingCountry = rec.Account__r.ShippingCountry;
                               if(rec.Shipping_Country_New__c != null)
                                   acc2.ShippingCountry = rec.Shipping_Country_New__c;
                               oldAcc.ShippingPostalCode = rec.Account__r.ShippingPostalCode;
                               if(rec.ShippingPostalCode_New__c != null)
                                   acc2.ShippingPostalCode = rec.ShippingPostalCode_New__c;
                               oldAcc.ShippingState = rec.Account__r.ShippingState;
                               if(rec.ShippingState_New__c != null)
                                   acc2.ShippingState = rec.ShippingState_New__c;
                               oldAcc.ShippingStreet = rec.Account__r.ShippingStreet;
                               if(rec.ShippingStreet_New__c != null)
                                   acc2.ShippingStreet = rec.ShippingStreet_New__c;
                               oldAcc.Principle_Office_International_Address__c = rec.Account__r.Principle_Office_International_Address__c;
                               if(rec.Principle_Office_International_Address_N__c != null)
                                   acc2.Principle_Office_International_Address__c = rec.Principle_Office_International_Address_N__c;
                               oldAcc.Office_Jurisdiction_BusinessZipCode__c = rec.Account__r.Office_Jurisdiction_BusinessZipCode__c;
                               if(rec.Office_Jurisdiction_BusinessZipCode_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessZipCode__c = rec.Office_Jurisdiction_BusinessZipCode_New__c;
                               oldAcc.Office_Jurisdiction_BusinessStreet__c = rec.Account__r.Office_Jurisdiction_BusinessStreet__c;
                               if(rec.Office_Jurisdiction_BusinessStreet_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessStreet__c = rec.Office_Jurisdiction_BusinessStreet_New__c;
                               oldAcc.Office_Jurisdiction_BusinessState__c = rec.Account__r.Office_Jurisdiction_BusinessState__c;
                               if(rec.Office_Jurisdiction_BusinessState_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessState__c = rec.Office_Jurisdiction_BusinessState_New__c;
                               oldAcc.Office_Jurisdiction_BusinessCity__c = rec.Account__r.Office_Jurisdiction_BusinessCity__c;
                               if(rec.Office_Jurisdiction_BusinessCity_New__c != null)
                                   acc2.Office_Jurisdiction_BusinessCity__c = rec.Office_Jurisdiction_BusinessCity_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessZipCode__c = rec.Account__r.Mailing_Jurisdiction_BusinessZipCode__c;
                               if(rec.Mailing_Jurisdiction_BusinessZipCode_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessZipCode__c = rec.Mailing_Jurisdiction_BusinessZipCode_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessStreet__c = rec.Account__r.Mailing_Jurisdiction_BusinessStreet__c;
                               if(rec.Mailing_Jurisdiction_BusinessStreet_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessStreet__c = rec.Mailing_Jurisdiction_BusinessStreet_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessState__c = rec.Account__r.Mailing_Jurisdiction_BusinessState__c;
                               if(rec.Mailing_Jurisdiction_BusinessState_New__c != null)
                                   acc2.Mailing_Jurisdiction_BusinessState__c = rec.Mailing_Jurisdiction_BusinessState_New__c;
                               oldAcc.Mailing_Jurisdiction_BusinessCity__c = rec.Account__r.Mailing_Jurisdiction_BusinessCity__c;
                               if(rec.Mailing_Jurisdiction_BusinessCity_New__c != null)    
                                   acc2.Mailing_Jurisdiction_BusinessCity__c = rec.Mailing_Jurisdiction_BusinessCity_New__c;
                               oldAcc.Mailing_International_Address__c = rec.Account__r.Mailing_International_Address__c;
                               if(rec.Mailing_International_Address_New__c != null)
                                   acc2.Mailing_International_Address__c = rec.Mailing_International_Address_New__c;
                               oldAcc.Jurisdiction_International_address__c = rec.Account__r.Jurisdiction_International_address__c;
                               if(rec.Jurisdiction_International_address_New__c != null)
                                   acc2.Jurisdiction_International_address__c = rec.Jurisdiction_International_address_New__c;
                               accMap.remove(rec.Account__c);
                               accFilingOldMap.remove(rec.Account__c);
                           }
                           accMap.put(rec.Account__c,acc2);
                           accFilingOldMap.put(rec.Account__c,oldAcc);
                       }
                       
                   }
               }
               for(Account acc: accMap.values())
               {
                   accLst.add(acc);
               }
           }
        }
        if(!busFileIds2.IsEmpty())
        {
            String queryString2 = 'SELECT Business_Filing__c,Business_Filing__r.Type__c,Business_Filing__r.Citizenship__c,Business_Filing__r.Status__c,Id,Merging_Business__c,Name,Old_Business_Type__c,Status__c,Surviving_Business__c,Surviving_Business__r.Citizenship__c,Merging_Business__r.Citizenship__c,Surviving_Business__r.Business_Type__c,Merging_Business__r.Business_Type__c,Surviving_Business__r.Status__c,Merging_Business__r.Status__c FROM Business_History__c';
            String whereClause2 = ' Where Business_Filing__c in: busFileIds2' ;
            queryString2 = queryString2 + whereClause2;
            busHistoryRecs = Database.query(queryString2);
            if (!busHistoryRecs.IsEmpty()) {
                for(Business_History__c rec : busHistoryRecs)
                {
                    //Domestication
                    if(rec.Business_Filing__r.Type__c == System.Label.Domestication_Label && rec.Business_Filing__r.Status__c == System.Label.Label_Pending_Filing_1)
                    {
                        if(rec.Merging_Business__c != null)
                        {
                            Account oldBus = new Account(id=rec.Merging_Business__c);
                            if(rec.Merging_Business__r.Citizenship__c == System.Label.Domestic && rec.Merging_Business__r.Business_Type__c != System.Label.General_Partnerships_Comparable)
                            {
                                oldBus.Status__c = System.label.brs_Domestication_Redomesticated;
                            }
                            else if(rec.Merging_Business__r.Citizenship__c == System.Label.Domestic && rec.Merging_Business__r.Business_Type__c == System.Label.General_Partnerships_Comparable)
                            {
                                oldBus.Status__c = System.label.brsStatus_Recorded;
                            }
                            else if(rec.Merging_Business__r.Citizenship__c == System.Label.Foreign && rec.Merging_Business__r.Status__c == System.Label.Pending_Domestication_Label)
                            {
                                oldBus.Status__c = System.label.Cancelled;
                            }
                            accLst.add(oldBus);
                            accFilingMap = processmap(accFilingMap,rec.Merging_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Merging_Business__c);
                            accFilingOldMap.put(rec.Merging_Business__c,new Account(Id=rec.Merging_Business__c,Status__c = rec.Merging_Business__r.Status__c));  
                        }
                        if(rec.Surviving_Business__c != null)
                        {
                            Account newBus = new Account(id=rec.Surviving_Business__c);
                            if(rec.Surviving_Business__r.Citizenship__c == System.Label.Domestic && rec.Surviving_Business__r.Status__c == System.Label.brs_Domistication_Accepted_Domestication_Pending)
                            {
                                newBus.Status__c = System.label.Active;
                            }
                            accLst.add(newBus);
                            accFilingMap = processmap(accFilingMap,rec.Surviving_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Surviving_Business__c);
                            accFilingOldMap.put(rec.Surviving_Business__c,new Account(Id=rec.Surviving_Business__c,Status__c = rec.Surviving_Business__r.Status__c));  
                        }
                    }
                    if(rec.Business_Filing__r.Type__c == System.Label.Conversion_Label && rec.Business_Filing__r.Status__c == System.Label.Label_Pending_Filing_1)
                    {
                        if(rec.Merging_Business__c != null)
                        {
                            Account oldBus = new Account(id=rec.Merging_Business__c);
                            // Domestic to Domestic
                            if(rec.Merging_Business__c == rec.Surviving_Business__c && rec.Merging_Business__r.Business_Type__c != System.Label.General_Partnerships_Comparable)
                            {
                                oldBus.Status__c = System.label.ACTIVE;
                            }
                            else if(rec.Merging_Business__c == rec.Surviving_Business__c && rec.Merging_Business__r.Business_Type__c == System.Label.General_Partnerships_Comparable)
                            {
                                oldBus.Status__c = System.label.brsStatus_Recorded;
                            }
                            else if(rec.Business_Filing__r.Citizenship__c == System.Label.Foreign && rec.Merging_Business__r.Status__c == System.label.Pending_Con_Label)
                            {
                                oldBus.Status__c = System.label.brsstatusConvertedOut;
                            } 
                            else if(rec.Business_Filing__r.Citizenship__c == System.Label.Domestic && rec.Merging_Business__r.Status__c != System.Label.brs_BusFileStatusCancelled && rec.Merging_Business__r.Status__c == System.label.Pending_Con_Label)
                            {
                                oldBus.Status__c = System.label.brs_BusFileStatusCancelled;
                            }

                            accLst.add(oldBus);
                            accFilingMap = processmap(accFilingMap,rec.Merging_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Merging_Business__c);
                            accFilingOldMap.put(rec.Merging_Business__c,new Account(Id=rec.Merging_Business__c,Status__c = rec.Merging_Business__r.Status__c));  
                        }
                        if(rec.Surviving_Business__c != null && rec.Merging_Business__c != rec.Surviving_Business__c)
                        {
                            Account newBus = new Account(id=rec.Surviving_Business__c);
                            if(rec.Surviving_Business__r.Citizenship__c == System.Label.Domestic && rec.Surviving_Business__r.Status__c == System.Label.brsstatus_conversionPending
                                && rec.Surviving_Business__r.Business_Type__c != System.Label.General_Partnerships_Comparable)
                            {
                                newBus.Status__c = System.label.Active;
                            } else if(rec.Surviving_Business__r.Citizenship__c == System.Label.Domestic && rec.Surviving_Business__r.Status__c == System.Label.brsstatus_conversionPending
                                && rec.Surviving_Business__r.Business_Type__c == System.Label.General_Partnerships_Comparable)
                            {
                                newBus.Status__c = System.label.brsStatus_Recorded;
                            }
                            accLst.add(newBus);
                            accFilingMap = processmap(accFilingMap,rec.Surviving_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Surviving_Business__c);
                            accFilingOldMap.put(rec.Surviving_Business__c,new Account(Id=rec.Surviving_Business__c,Status__c = rec.Surviving_Business__r.Status__c));  
                        }
                    }if(rec.Business_Filing__r.Type__c == 'Merger' && rec.Business_Filing__r.Status__c == System.Label.Label_Pending_Filing_1)
                        {
                        if(rec.Merging_Business__c != null)
                        {
                            Account oldBus = new Account(id=rec.Merging_Business__c);
                            if(rec.Merging_Business__r.Business_Type__c != System.Label.General_Partnerships_Comparable &&  rec.Merging_Business__r.Business_Type__c!='Unauthorized')
                            {
                                oldBus.Status__c = 'Merged';
                            }
                            else if(rec.Merging_Business__r.Citizenship__c == System.Label.Domestic && rec.Merging_Business__r.Business_Type__c == System.Label.General_Partnerships_Comparable)
                            {
                                oldBus.Status__c = System.label.brsStatus_Recorded;
                            }
                            else if(rec.Merging_Business__r.Citizenship__c == System.Label.Foreign && rec.Merging_Business__r.Business_Type__c == 'Unauthorized')
                            {
                                oldBus.Status__c = '';
                            }
                            accLst.add(oldBus);
                            accFilingMap = processmap(accFilingMap,rec.Merging_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Merging_Business__c);
                            accFilingOldMap.put(rec.Merging_Business__c,new Account(Id=rec.Merging_Business__c,Status__c = rec.Merging_Business__r.Status__c));  
                        }
                        if(rec.Surviving_Business__c != null)
                        {
                            Account newBus = new Account(id=rec.Surviving_Business__c);
                           
                            accFilingMap = processmap(accFilingMap,rec.Surviving_Business__c,rec.Business_Filing__c);
                            filingAccMap.put(rec.Business_Filing__c,rec.Surviving_Business__c);
                            accFilingOldMap.put(rec.Surviving_Business__c,new Account(Id=rec.Surviving_Business__c,Status__c = rec.Surviving_Business__r.Status__c));  
                        }
                    }
                }
            }
        }
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3809
        * Change(s)/Modification(s) Description : Added roll back savepoint and changing the database dml to standard dml.
        * Change(s)/Modification(s) Made on : 2021-04-30
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Savepoint sp;
        try {
           sp = Database.setSavepoint();
           set<String> principalSuccessSet = new set<String>();
           set<String> principalInsSuccessSet = new set<String>();
           set<String> principalInsAccSet = new set<String>();
           set<String> busFileUpdateFailedErrorSetId = new set<String>();
           Map<String,String> principalInsUniqueKeySet = new Map<String,String>();
           set<String> principalErrorSet = new set<String>();
           set<String> principalSet = new set<String>();
           Map<String,String> errorDeleteFilingSet = new Map<String,String>();
           List<Principal__c> undeletePrincipal = new List<Principal__c>();
           List<Principal__c> deleteInsPrincipal = new List<Principal__c>();
           List<Principal__c> insertPrincipals = new List<Principal__c>();
           List<Agent__c> undeleteAgentLst = new List<Agent__c>();
           List<Agent__c> deleteAgentLst = new List<Agent__c>();
           List<Account> accUndoUpdateLst = new List<Account>();
           List<Agent__c> agentUndoUpdateLst = new List<Agent__c>();
           Map<String,List<Principal__c>> successPrincipalFilingMap = new Map<String,List<Principal__c>>();
           Map<String,List<Principal__c>> successInsPrincipalFilingMap = new Map<String,List<Principal__c>>();
           Map<String,String> successAgentResFilingMap = new Map<String,String>();
           Map<String,String> successAgentChangeFilingMap = new Map<String,String>();
           Map<String,String> successAgentChangeInsertFilingMap = new Map<String,String>();
           Map<String,String> successAgentAddressUpdateFilingMap = new Map<String,String>();
           Map<String,String> successAgentResAccountFilingMap = new Map<String,String>();
           Map<String,String> successAccountUpdateFilingMap = new Map<String,String>();
           List<Account> updateAccountWithAgentSubStatus = new List<Account>();
           List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
           set<String> filingIds = new set<String>();
           Integer successCount=0;
           Integer errorCount=0;
           List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
           //Interim Notice Processing
           if ((!deletePrincipal.IsEmpty() || !insertPrincipal.IsEmpty()) && Schema.SObjectType.Principal__c.isAccessible()) {
               if (!deletePrincipal.IsEmpty())
               {
                   Database.DeleteResult[] principalDelSuccessList = Database.delete(deletePrincipal, false);
                   for(Integer i=0;i<principalDelSuccessList.size();i++){
                       if (principalDelSuccessList.get(i).isSuccess()){
                           principalSuccessSet.add(principalDelSuccessList.get(i).getId());
                           successCount = successCount + 1;
                       } else if (!principalDelSuccessList.get(i).isSuccess()){
                           principalErrorSet.add(deletePrincipal.get(i).Id);
                           errorCount = errorCount + 1;
                       }
                   }

                   Batch_Job_Logs__c createLog1 = new Batch_Job_Logs__c ();
                   createLog1.Class_Name__c = className;
                   createLog1.Job_Operation__c = System.Label.Batch_Delete;
                   createLog1.Job_Configuration_Name__c = 'Business Filing Automation';
                   createLog1.Success_Record_Count__c = successCount;
                   createLog1.Error_Record_Count__c = errorCount;
                   createLog1.Object_Name__c = (deletePrincipal.get(0).Id).getSObjectType().getDescribe().getName();
                   lstAppErrorLogs.add(createLog1);

                   if(!principalSuccessSet.IsEmpty())
                       principalSet.addAll(principalSuccessSet);
                   if(!principalErrorSet.IsEmpty())
                       principalSet.addAll(principalErrorSet);
                   List<Temp_History__c> principalTempLst = [Select Id, Business_Filing__c, Principal__c,Principal_ID_Information__c from Temp_History__c where Principal_ID_Information__c in: principalSet];
                   for(Temp_History__c temp : principalTempLst)
                   {
                       if(principalSuccessSet.contains(temp.Principal_ID_Information__c))
                       {
                           if(!successPrincipalFilingMap.keyset().contains(temp.Business_Filing__c))
                           {
                               List<Principal__c> principalList2 = new List<Principal__c>();
                               principalList2.add(new Principal__c(id=temp.Principal_ID_Information__c));
                               successPrincipalFilingMap.put(temp.Business_Filing__c,principalList2);
                           }
                           else
                           {
                               List<Principal__c> principalList = successPrincipalFilingMap.get(temp.Business_Filing__c);
                               principalList.add(new Principal__c(id=temp.Principal_ID_Information__c));
                               successPrincipalFilingMap.remove(temp.Business_Filing__c);
                               successPrincipalFilingMap.put(temp.Business_Filing__c,principalList);
                           }
                       }
                       else
                           errorDeleteFilingSet.put(temp.Business_Filing__c,temp.Principal_ID_Information__c);
                   }
                   if(!errorDeleteFilingSet.IsEmpty())
                   {
                       for(String str : errorDeleteFilingSet.keyset())
                       {
                           if(successPrincipalFilingMap.keyset().contains(str))
                           {
                               List<Principal__c> principalList1 = successPrincipalFilingMap.get(str);
                               successPrincipalFilingMap.remove(str);
                               undeletePrincipal.addall(principalList1);
                               Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, str, BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Principal_Delete_Error_Message +errorDeleteFilingSet.get(str));
                               errorFilingLst.add(err);
                           }
                       }
                   }
               }
               if(!insertPrincipal.IsEmpty())
               {
                   if(!errorDeleteFilingSet.IsEmpty())
                   {
                       for(String str : insertPrincipal.keySet())
                       {
                           
                            if(errorDeleteFilingSet.keyset().contains(str))
                                insertPrincipal.remove(str);
                            else
                            {
                                if(!successPrincipalFilingMap.keyset().contains(str))
                                    filingIds.add(str);
                                else
                                   insertPrincipals.addAll(insertPrincipal.get(str));
                            }
                       }
                   }
                   else
                   {
                       for(String str : insertPrincipal.keySet())
                          insertPrincipals.addAll(insertPrincipal.get(str)); 
                   }
                   if(!insertPrincipals.IsEmpty())
                   {
                       successCount=0;
           			   errorCount=0;
                       Database.SaveResult[] principalInsertSuccessList = Database.Insert(insertPrincipals, false);
                       for(Integer i=0;i<principalInsertSuccessList.size();i++){
                           if (principalInsertSuccessList.get(i).isSuccess()) 
                           {
                               principalInsSuccessSet.add(principalInsertSuccessList.get(i).getId());
                               successCount = successCount + 1;
                           }
                           else if (!principalInsertSuccessList.get(i).isSuccess()){
                               errorCount = errorCount + 1;
                           } 
                       }

                       Batch_Job_Logs__c createLog2 = new Batch_Job_Logs__c ();
                       createLog2.Class_Name__c = className;
                       createLog2.Job_Operation__c = 'Insert';
                       createLog2.Job_Configuration_Name__c = 'Business Filing Automation';
                       createLog2.Success_Record_Count__c = successCount;
                       createLog2.Error_Record_Count__c = errorCount;
                       createLog2.Object_Name__c = (insertPrincipals.get(0).Id).getSObjectType().getDescribe().getName();
                       lstAppErrorLogs.add(createLog2);

                       List<Principal__c> insPrincipal = [Select Id,Business_ID__c,Name__c,Email__c,Residence_Street_Address_1__c,Principal_Title__c,Residence_InternationalAddress__c,Business_Street_Address_1__c From Principal__c where Id in: principalInsSuccessSet];
                       for(Principal__c pr2 : insPrincipal)
                       {
                           String Key = pr2.Business_ID__c + ' ' + pr2.Name__c + ' ' + pr2.Principal_Title__c;
                           If(pr2.Email__c != null)
                               Key += ' ' + pr2.Email__c;
                           If(pr2.Residence_Street_Address_1__c != null)
                               Key += ' ' + pr2.Residence_Street_Address_1__c;
                           If(pr2.Residence_InternationalAddress__c != null)
                               Key += ' ' + pr2.Residence_InternationalAddress__c;
                           If(pr2.Business_Street_Address_1__c != null)
                               Key += ' ' + pr2.Business_Street_Address_1__c;
                           
                           principalInsUniqueKeySet.put(Key,pr2.Id);
                           principalInsAccSet.add(pr2.Business_ID__c);
                       }       
                       List<Temp_History__c> principalTempLst = [Select Id,Title__c,Business_Filing__c,Name__c,Email__c,Business_Id__c,Residence_Street_Address_1__c,Business_Street_Address_1__c,Residence_InternationalAddress__c from Temp_History__c
                                                               where Business_Filing__c in: insertPrincipal.keySet() and Business_Id__c in: principalInsAccSet and Change_Type__c = 'Created'];
                       for(Temp_History__c temp : principalTempLst)
                       {
                           String key2 = temp.Business_ID__c + ' ' + temp.Name__c + ' ' + temp.Title__c;
                           If(temp.Email__c != null)
                               key2 += ' ' + temp.Email__c;
                           If(temp.Residence_Street_Address_1__c != null)
                               key2 += ' ' + temp.Residence_Street_Address_1__c;
                           If(temp.Residence_InternationalAddress__c != null)
                               key2 += ' ' + temp.Residence_InternationalAddress__c;
                           If(temp.Business_Street_Address_1__c != null)
                               key2 += ' ' + temp.Business_Street_Address_1__c;
                           
                           if(principalInsUniqueKeySet.keyset().contains(key2))
                           {
                               if(!successInsPrincipalFilingMap.keyset().contains(temp.Business_Filing__c))
                               {
                                   List<Principal__c> principalList2 = new List<Principal__c>();
                                   principalList2.add(new Principal__c(id=principalInsUniqueKeySet.get(key2)));
                                   successInsPrincipalFilingMap.put(temp.Business_Filing__c,principalList2);
                               }
                               else
                               {
                                   List<Principal__c> principalList = successInsPrincipalFilingMap.get(temp.Business_Filing__c);
                                   principalList.add(new Principal__c(id=principalInsUniqueKeySet.get(key2)));
                                   successInsPrincipalFilingMap.remove(temp.Business_Filing__c);
                                   successInsPrincipalFilingMap.put(temp.Business_Filing__c,principalList);
                               }
                           }
                       }
                       for(string str : insertPrincipal.keyset())
                       {
                           if(successInsPrincipalFilingMap.keyset().contains(str))
                           {
                               if(insertPrincipal.get(str).size() != successInsPrincipalFilingMap.get(str).size())
                               {
                                   List<Principal__c> principalList2 = successInsPrincipalFilingMap.get(str);
                                   deleteInsPrincipal.addAll(principalList2);
                                   successInsPrincipalFilingMap.remove(str);
                                   Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, str, BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Principal_Insert_Error_Message);
                                   errorFilingLst.add(err);
                                   if(successPrincipalFilingMap.keyset().contains(str))
                                   {
                                       List<Principal__c> principalList1 = successPrincipalFilingMap.get(str);
                                       undeletePrincipal.addAll(principalList1);
                                   }
                               }
                           }
                           else
                           {
                               if(successPrincipalFilingMap.keyset().contains(str))
                               {
                                   List<Principal__c> principalList1 = successPrincipalFilingMap.get(str);
                                   undeletePrincipal.addAll(principalList1);
                               }
                           }
                       }
                   }
                   if(!successInsPrincipalFilingMap.IsEmpty())
                   filingIds.addALL(successInsPrincipalFilingMap.keyset());
               }
               else 
                   filingIds.addALL(successPrincipalFilingMap.keyset());
           }
           //Agent Resignation Processing
           if (!deleteResAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible()) {
               successCount=0;
           	   errorCount=0;
               Database.DeleteResult[] agentResSuccessList = Database.delete(deleteResAgent, false);
               for(Integer i=0;i<agentResSuccessList.size();i++){
                   if (agentResSuccessList.get(i).isSuccess()){
                       successAgentResFilingMap.put(deleteAgentFilingMap.get(agentResSuccessList.get(i).getId()),agentResSuccessList.get(i).getId());
                       successCount = successCount + 1;
                   }else if (!agentResSuccessList.get(i).isSuccess()){
                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, deleteAgentFilingMap.get(deleteResAgent.get(i).Id), BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Agent_Delete_Error_Message + deleteResAgent.get(i).Id);
                       errorFilingLst.add(err);
                       errorCount = errorCount + 1;
                    }
               }

               Batch_Job_Logs__c createLog3 = new Batch_Job_Logs__c ();
               createLog3.Class_Name__c = className;
               createLog3.Job_Operation__c = System.Label.Batch_Delete;
               createLog3.Job_Configuration_Name__c = 'Business Filing Automation';
               createLog3.Success_Record_Count__c = successCount;
               createLog3.Error_Record_Count__c = errorCount;
               createLog3.Object_Name__c = (deleteResAgent.get(0).Id).getSObjectType().getDescribe().getName();
               lstAppErrorLogs.add(createLog3);

               if(!successAgentResFilingMap.IsEmpty())
               {
                   for(String str : successAgentResFilingMap.keySet())
                   {
                       if (deleteAgentAccUpdateMap.keyset().contains(str))
                           updateAccountWithAgentSubStatus.add(deleteAgentAccUpdateMap.get(str));
                       else
                           filingIds.add(str);
                   }
                   if(!updateAccountWithAgentSubStatus.IsEmpty())
                   {
                       successCount=0;
           	   		   errorCount=0;
                       Database.SaveResult[] accAgentResUpdateSuccessList = Database.update(updateAccountWithAgentSubStatus, false);
                       for(Integer i=0;i<accAgentResUpdateSuccessList.size();i++){
                           if (accAgentResUpdateSuccessList.get(i).isSuccess()){
                               successAgentResAccountFilingMap.put(deleteAgentAccFilingMap.get(accAgentResUpdateSuccessList.get(i).getId()),accAgentResUpdateSuccessList.get(i).getId());
                               successCount = successCount + 1;
                           }else if (!accAgentResUpdateSuccessList.get(i).isSuccess()){
                               Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, deleteAgentAccFilingMap.get(updateAccountWithAgentSubStatus.get(i).Id), BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Account_SubStatus_Update_Error_Message +updateAccountWithAgentSubStatus.get(i).Id);
                               errorFilingLst.add(err);
                               undeleteAgentLst.add(new Agent__c(Id=successAgentResFilingMap.get(deleteAgentAccFilingMap.get(updateAccountWithAgentSubStatus.get(i).Id))));
                               errorCount = errorCount + 1;
                            }
                       }

                       Batch_Job_Logs__c createLog4 = new Batch_Job_Logs__c ();
                       createLog4.Class_Name__c = className;
                       createLog4.Job_Operation__c = System.Label.Batch_Update;
                       createLog4.Job_Configuration_Name__c = 'Business Filing Automation';
                       createLog4.Success_Record_Count__c = successCount;
                       createLog4.Error_Record_Count__c = errorCount;
                       createLog4.Object_Name__c = (updateAccountWithAgentSubStatus.get(0).Id).getSObjectType().getDescribe().getName();
                       lstAppErrorLogs.add(createLog4);
                       
                       if(!successAgentResAccountFilingMap.IsEmpty())
                           filingIds.addALL(successAgentResAccountFilingMap.keyset());
                   }
               }
              
           }
           
           //Change Agent Address Processing
           if (!updateAgentAddress.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible()) {
               successCount=0;
           	   errorCount=0;
               Database.SaveResult[] agentAddressChangeSuccessList = Database.update(updateAgentAddress, false);
               for(Integer i=0;i<agentAddressChangeSuccessList.size();i++){
                   if (agentAddressChangeSuccessList.get(i).isSuccess()){
                       successAgentAddressUpdateFilingMap.put(updateAgentAddressFilingMap.get(agentAddressChangeSuccessList.get(i).getId()),agentAddressChangeSuccessList.get(i).getId());
                       successCount = successCount + 1;
                   }
                   else if (!agentAddressChangeSuccessList.get(i).isSuccess())
                   {
                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, updateAgentAddressFilingMap.get(updateAgentAddress.get(i).Id), BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Agent_Update_Error_Message + updateAgentAddress.get(i).Id);
                       errorFilingLst.add(err);
                       errorCount = errorCount + 1;
                   }   
               }

               Batch_Job_Logs__c createLog5 = new Batch_Job_Logs__c ();
               createLog5.Class_Name__c = className;
               createLog5.Job_Operation__c = System.Label.Batch_Update;
               createLog5.Job_Configuration_Name__c = 'Business Filing Automation';
               createLog5.Success_Record_Count__c = successCount;
               createLog5.Error_Record_Count__c = errorCount;
               createLog5.Object_Name__c = (updateAgentAddress.get(0).Id).getSObjectType().getDescribe().getName();
               lstAppErrorLogs.add(createLog5);

               if(!successAgentAddressUpdateFilingMap.IsEmpty())
                   filingIds.addALL(successAgentAddressUpdateFilingMap.keyset());
           }
           
           //Change Agent Maintenance Processing
           if (!deleteAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible()) {
               successCount=0;
           	   errorCount=0;
               Database.DeleteResult[] agentChangeSuccessList = Database.delete(deleteAgent, false);
               for(Integer i=0;i<agentChangeSuccessList.size();i++){
                   if (agentChangeSuccessList.get(i).isSuccess()){
                       successAgentChangeFilingMap.put(deleteChangedAgentFilingMap.get(agentChangeSuccessList.get(i).getId()),agentChangeSuccessList.get(i).getId());
                       successCount = successCount + 1;
                   }
                   else if (!agentChangeSuccessList.get(i).isSuccess()) 
                   {
                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, deleteChangedAgentFilingMap.get(deleteResAgent.get(i).Id), BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Agent_Delete_Error_Message +deleteResAgent.get(i).Id);
                       errorFilingLst.add(err);
                       errorCount = errorCount + 1;
                   }   
               }

               Batch_Job_Logs__c createLog6 = new Batch_Job_Logs__c ();
               createLog6.Class_Name__c = className;
               createLog6.Job_Operation__c = System.Label.Batch_Delete;
               createLog6.Job_Configuration_Name__c = 'Business Filing Automation';
               createLog6.Success_Record_Count__c = successCount;
               createLog6.Error_Record_Count__c = errorCount;
               createLog6.Object_Name__c = (deleteAgent.get(0).Id).getSObjectType().getDescribe().getName();
               lstAppErrorLogs.add(createLog6);

               if(!successAgentChangeFilingMap.IsEmpty())
               {
                   for(String str : insertChangedAgentFilingMap.keyset())
                   {
                       if(!successAgentChangeFilingMap.keyset().contains(str))
                           insertChangedAgentFilingMap.remove(str);
                   }
                   if(!insertChangedAgentFilingMap.IsEmpty())
                   {
                       successCount=0;
           	   		   errorCount=0;
                       Database.SaveResult[] changedAgentInsertSuccessList = Database.Insert(insertChangedAgentFilingMap.values(), false);
                       for(Integer i=0;i<changedAgentInsertSuccessList.size();i++)
                       {
                           Agent__c ag = insertChangedAgentFilingMap.values().get(i);
                           if (changedAgentInsertSuccessList.get(i).isSuccess()) 
                           {
                               successCount = successCount + 1;
                               for(String key : insertChangedAgentFilingMap.keyset())
                               {
                                   if(ag == insertChangedAgentFilingMap.get(key))
                                   {
                                       successAgentChangeInsertFilingMap.put(key,changedAgentInsertSuccessList.get(i).getId());
                                       break;
                                   }
                               }
                           }
                           else if (!changedAgentInsertSuccessList.get(i).isSuccess()) 
                           {
                               errorCount = errorCount + 1;
                               for(String key : insertChangedAgentFilingMap.keyset())
                               {
                                   if(ag == insertChangedAgentFilingMap.get(key))
                                   {
                                       undeleteAgentLst.add(new Agent__c(Id=successAgentChangeFilingMap.get(key)));
                                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, key, BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Agent_Insert_Error_Message);
                                       errorFilingLst.add(err);
                                       break;
                                   }
                               }
                           }
                       }

                       Batch_Job_Logs__c createLog7 = new Batch_Job_Logs__c ();
                       createLog7.Class_Name__c = className;
                       createLog7.Job_Operation__c = 'Insert';
                       createLog7.Job_Configuration_Name__c = 'Business Filing Automation';
                       createLog7.Success_Record_Count__c = successCount;
                       createLog7.Error_Record_Count__c = errorCount;
                       createLog7.Object_Name__c = ((insertChangedAgentFilingMap.values()).get(0).Id).getSObjectType().getDescribe().getName();
                       lstAppErrorLogs.add(createLog7);

                       if(!successAgentChangeInsertFilingMap.IsEmpty())
                           filingIds.addALL(successAgentChangeInsertFilingMap.keyset());
                   }
               }
           }
           
           // Processing of Voluntary Dissolution Flows, NAICS Change, Business Email Address Change, Name Change Amendment And Business Address Change
           if(!accLst.IsEmpty() && Schema.SObjectType.Account.isAccessible())
           {
               successCount=0;
           	   errorCount=0;
               Database.SaveResult[] accUpdateSuccessList = Database.update(accLst, false);
               for(Integer i=0;i<accUpdateSuccessList.size();i++)
               {
                   if (accUpdateSuccessList.get(i).isSuccess()) 
                   {
                       successCount = successCount + 1;
                       for(String str : accFilingMap.get(accUpdateSuccessList.get(i).getId()))
                           successAccountUpdateFilingMap.put(str,accUpdateSuccessList.get(i).getId());
                   } 
                   else if (!accUpdateSuccessList.get(i).isSuccess()) 
                   {
                       errorCount = errorCount + 1;
                       for(string str : accFilingMap.get(accLst.get(i).Id))
                       {
                            Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, str, BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Account_Update_Error_Message +accLst.get(i).Id);
                            errorFilingLst.add(err);
                       }
                   }
               }

               Batch_Job_Logs__c createLog8 = new Batch_Job_Logs__c ();
               createLog8.Class_Name__c = className;
               createLog8.Job_Operation__c = System.Label.Batch_Update;
               createLog8.Job_Configuration_Name__c = 'Business Filing Automation';
               createLog8.Success_Record_Count__c = successCount;
               createLog8.Error_Record_Count__c = errorCount;
               createLog8.Object_Name__c = (accLst.get(0).Id).getSObjectType().getDescribe().getName();
               lstAppErrorLogs.add(createLog8);

               if(!successAccountUpdateFilingMap.IsEmpty())
                   filingIds.addALL(successAccountUpdateFilingMap.keyset());
           }
           if(!filingIds.IsEmpty())
           {
               List<Business_Filing__c> busFileUpdate = new List<Business_Filing__c>();
               List<Business_Filing__c> busFile = [Select id,Status__c,Type__c,Business_Type__c,Source__c,Work_Order__r.Customer__c,Work_Order__r.Customer__r.Email,Account__r.Business_Email_Address__c from Business_Filing__c where id in: filingIds and (Status__c =: system.label.Label_Pending_Filing_1 or (Account__r.Status__c =: system.label.Withdrawn and Account__r.Citizenship__c =: system.label.Foreign and Account__r.Business_Type__c =: system.label.LLC))];
			   Map<Id,Business_Filing__c> businessFilingMap = new Map<Id,Business_Filing__c>();
               List<Business_Filing__c> businessFilingEmailList = new List<Business_Filing__c>();
               for(Business_Filing__c bus : busFile )
               {
                    if(bus.status__c == system.label.Label_Pending_Filing_1)
                        bus.Status__c = system.label.BRS_FilingStatus_Approved;
                    busFileUpdate.add(bus);
				    businessFilingMap.put(bus.Id,bus);
               }
               if(!busFileUpdate.IsEmpty())
               {
                   successCount=0;
           	   	   errorCount=0;
                   Database.SaveResult[] busFileUpdateSuccessList = Database.update(busFileUpdate, false);
                   for(Integer i=0;i<busFileUpdateSuccessList.size();i++)
                   {
                       if (!busFileUpdateSuccessList.get(i).isSuccess()) 
                       {
                           errorCount = errorCount + 1;
                           if(successInsPrincipalFilingMap.keyset().contains(busFileUpdate.get(i).Id))
                           {
                               List<Principal__c> principalList2 = successInsPrincipalFilingMap.get(busFileUpdate.get(i).Id);
                               deleteInsPrincipal.addAll(principalList2);
                           }
                           if(successPrincipalFilingMap.keyset().contains(busFileUpdate.get(i).Id))
                           {
                               List<Principal__c> principalList1 = successPrincipalFilingMap.get(busFileUpdate.get(i).Id);
                               undeletePrincipal.addAll(principalList1);
                           }
                           if(successAgentResFilingMap.keyset().contains(busFileUpdate.get(i).Id))
                               undeleteAgentLst.add(new Agent__c(Id=successAgentResFilingMap.get(busFileUpdate.get(i).Id)));
                           if(deleteAgentAccUpdateOldMap.keyset().contains(busFileUpdate.get(i).Id))
                               accUndoUpdateLst.add(deleteAgentAccUpdateOldMap.get(busFileUpdate.get(i).Id));
                           if(updateAgentAddressfilingOldMap.keyset().contains(busFileUpdate.get(i).Id))
                               agentUndoUpdateLst.add(updateAgentAddressfilingOldMap.get(busFileUpdate.get(i).Id));
                           if(successAgentChangeFilingMap.keyset().contains(busFileUpdate.get(i).Id))
                               undeleteAgentLst.add(new Agent__c(Id=successAgentChangeFilingMap.get(busFileUpdate.get(i).Id)));
                           if(successAgentChangeInsertFilingMap.keyset().contains(busFileUpdate.get(i).Id))
                               deleteAgentLst.add(new Agent__c(Id=successAgentChangeInsertFilingMap.get(busFileUpdate.get(i).Id)));
                           if(filingAccMap.keyset().contains(busFileUpdate.get(i).Id))
                           {
                               if(accFilingOldMap.keyset().contains(filingAccMap.get(busFileUpdate.get(i).Id)) && accFilingOldMap.get(filingAccMap.get(busFileUpdate.get(i).Id)) != null)
                               {
                                   if(!accUndoUpdateLst.contains(accFilingOldMap.get(filingAccMap.get(busFileUpdate.get(i).Id))))
                                       accUndoUpdateLst.add(accFilingOldMap.get(filingAccMap.get(busFileUpdate.get(i).Id)));
                               }
                           }
                           Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, busFileUpdate.get(i).Id, BOS_Utility.sSeverity, null, system.label.Maintenance_Filing_Business_Filing_Update_Error_Message +busFileUpdate.get(i).Id);
                           errorFilingLst.add(err);
                       }
                        else{
                            successCount = successCount + 1;
                            if(businessFilingMap.keySet().contains(busFileUpdateSuccessList.get(i).Id)){
                                businessFilingEmailList.add(businessFilingMap.get(busFileUpdateSuccessList.get(i).Id));
                                businessFilingId.add(busFileUpdateSuccessList.get(i).Id);
                            }
                       }                       
                   }

                   Batch_Job_Logs__c createLog9 = new Batch_Job_Logs__c ();
                   createLog9.Class_Name__c = className;
                   createLog9.Job_Operation__c = System.Label.Batch_Update;
                   createLog9.Job_Configuration_Name__c = 'Business Filing Automation';
                   createLog9.Success_Record_Count__c = successCount;
                   createLog9.Error_Record_Count__c = errorCount;
                   createLog9.Object_Name__c = (busFileUpdate.get(0).Id).getSObjectType().getDescribe().getName();
                   lstAppErrorLogs.add(createLog9);
               } 
           }

           if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
               Database.SaveResult[] resultLst = new List<Database.SaveResult>();
               resultLst = Database.insert(lstAppErrorLogs,false);
           }
              
           //Rollback the maintenance processing if fail at any step
           if(!deleteInsPrincipal.IsEmpty())
               Database.delete(deleteInsPrincipal,false);
           if(!undeletePrincipal.IsEmpty())
               Database.undelete(undeletePrincipal,false);
           if(!undeleteAgentLst.IsEmpty())
               Database.undelete(undeleteAgentLst,false);
           if(!accUndoUpdateLst.IsEmpty())
               Database.Update(accUndoUpdateLst,false);
           if(!agentUndoUpdateLst.IsEmpty())
               Database.Update(agentUndoUpdateLst,false);
           if(!deleteAgentLst.IsEmpty())
               Database.delete(deleteAgentLst,false);
            if(!actItemsAccounts.IsEmpty())
            brs_ActionItemUtility.deleteAccountActionitems(actItemsAccounts);
           if(!errorFilingLst.IsEmpty())
               BOS_Utility.insertErrorRecordLst(errorFilingLst);
       } catch (Exception e) {
           Database.rollback(sp);
           BOS_Utility.errorRecordLogger(className, methodName, objectName, null, BOS_Utility.sSeverity, e, null);
       }
        
        
    }
    global void finish(Database.BatchableContext BC) {
        List<id> filingids=new List<id>();
        List<Business_Filing__c> newbusinessFilingList=[Select id,Status__c,Pending_Filing_Status__c from Business_Filing__c where id IN : businessFilingId];
        for(Business_Filing__c bus:newbusinessFilingList)
        {
            if(!bus.Pending_Filing_Status__c)
            {
                filingids.add(bus.id);
            }
        }
         if(!filingids.isEmpty())
        {
            Database.executeBatch(new NintexBatchGeneration(filingids, UCCFilingAcknowledgement.Operation.MAINTENANCE), 10);
        }
    }
     public class maintenanceFilingUpdateWrapper{
       @AuraEnabled public String busFilingId {get;set;}
       @AuraEnabled public String tarObj {get;set;}
       @AuraEnabled public String statusValue {get;set;}
       @AuraEnabled public String filingType {get;set;}
       @AuraEnabled public String busId {get;set;}
       @AuraEnabled public String checkDuplicate {get;set;}
   }

   public map<String,set<String>> processmap(map<String,set<String>> accFilingMap2,String key, string busFileId)
   {
        if(!accFilingMap2.keyset().contains(key))
        {
            set<String> filingIds = new set<String>();
            filingIds.add(busFileId);
            accFilingMap2.put(key,filingIds);
        }
        else
        {
            set<String> filingIds1 = accFilingMap2.get(key);
            filingIds1.add(busFileId);
            accFilingMap2.remove(key);
            accFilingMap2.put(key,filingIds1);
        }
        return accFilingMap2;
   }
   
}