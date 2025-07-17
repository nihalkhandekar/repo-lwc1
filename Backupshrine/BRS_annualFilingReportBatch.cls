/* DESCRIPTION: This class use to create annual filing records
*
* @AUTHOR:  Shaik Rabbani
* @DATE:    2/1/2021
*s
*
* MODIFICATION LOG:
* DEVELOPER                             DATE                        DESCRIPTION
* ----------------------------------------------------------------------------
* Shaik Rabbani                         2/1/2021                    Created the first version
* Pooja Dubey                           3/20/2021                   Bug fix and BRS-1892
*********************************************************************************************/
global without sharing class BRS_annualFilingReportBatch implements Database.Batchable < sObject > , Database.Stateful, schedulable {
    global final Date date1;
    global final Date date2;
    global Integer currentYear;
    global List < Business_Filing__c > businessFilingList = new List < Business_Filing__c > ();
    //global List <SObject> businessFilingList = new List<SObject>();
    global Map < Id, Id > accountAnnualFilingMap = new Map < Id, Id > ();
    global Map < Id, Date > firstFilingMap = new Map < Id, Date > ();
    public static final string CLASSNAME = 'BRS_annualFilingReportBatch';
    //Adding Change for FR AND AR report creation. Adding record type in the business filing.
    public List<RecordType> rcId = new List<RecordType>();
    public List<Id> acRecIds;
    public String query;
    public integer PrevYr;
    public List <String> businessTypes = new List <String> {System.Label.businessTypeLLC, System.Label.businessTypeLLP,System.Label.Limited_Partnership_Comparable, System.Label.Stock, System.Label.Non_Stock, System.Label.Business_Type_BCORP};

	global BRS_annualFilingReportBatch(Integer yearvalue, string querystr) {
        query = querystr;
        currentYear = yearvalue;
    }
    /********************************************************************************************
        METHOD NAME    : BRS_annualFilingReportBatch
        DESCRIPTION    : Batch Constructor (Get the current year for batch processing)
        RETURN TYPE    :
        PARAMETER      :
    ********************************************************************************************/
    global BRS_annualFilingReportBatch(Integer yearvalue,Boolean runbatchCurrentYearAccount) {
        String accountRecordType = System.Label.ActionItem_AccountRecordType;
        String FirstReport = System.Label.First_Report_Label;
        String AnnualReport = System.Label.Annual_Report_Label;
        String approved = system.label.Approved;
        Integer PrevYr = yearvalue - 1;
        currentYear = yearvalue;
        date1 = DATE.newInstance(yearvalue, 1, 1);
        date2 = DATE.newInstance(yearvalue, 12, 31);
        rcId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = : Label.Business_Filing_API_Name AND Name = : Label.Annual_First_recordtype_label];
        
         if(runbatchCurrentYearAccount == true)
         {
             query = 'SELECT Id,Status__c,Date_Registration__c,Sub_status__c,Business_Type__c,Citizenship__c,Annual_Report_Processing_Year__c,CreatedDate,Name,(Select Due_Date__c,Type__c,Status__c,Filing_Date__c,CreatedDate from Business_Filings__r where (Type__c =:FirstReport AND Status__c=:approved) OR (Due_Date__c >=:date1 AND Due_Date__c<=:date2 AND Type__c =:AnnualReport)) FROM Account where recordType.Name =:accountRecordType And Status__c=\'Active\' And Citizenship__c IN (\'Domestic\',\'Foreign\') AND Business_Type__c IN : businessTypes AND Date_Registration__c!=null AND (Annual_Report_Processing_Year__c = NULL OR Annual_Report_Processing_Year__c = ' + PrevYr + ') AND sub_status__c not in (\'First report past due\',\'First report due\') LIMIT ' + Integer.valueOf(System.Label.Annual_Filing_Batch_Size_Configurable);
         }
        else
        {
             query = 'SELECT Id,Status__c,Date_Registration__c,Sub_status__c,Business_Type__c,Citizenship__c,Annual_Report_Processing_Year__c,CreatedDate,Name,(Select Due_Date__c,Type__c,Status__c,Filing_Date__c,CreatedDate from Business_Filings__r where (Type__c =:FirstReport AND Status__c=:approved) OR (Due_Date__c >=:date1 AND Due_Date__c<=:date2 AND Type__c =:AnnualReport)) FROM Account where recordType.Name =:accountRecordType And Status__c=\'Active\' And Citizenship__c IN (\'Domestic\',\'Foreign\') AND Business_Type__c IN : businessTypes AND Date_Registration__c!=null AND  Annual_Report_Processing_Year__c = ' + PrevYr + ' AND sub_status__c not in (\'First report past due\',\'First report due\') LIMIT ' + Integer.valueOf(System.Label.Annual_Filing_Batch_Size_Configurable);
        }
    }

    global BRS_annualFilingReportBatch(Integer yearvalue, List<Id> acIds) {
        acRecIds = new List<Id>();
        if (!acIds.isEmpty()) {
            acRecIds = acIds;
        }
        String accountRecordType = System.Label.ActionItem_AccountRecordType;
        String FirstReport = System.Label.First_Report_Label;
        String AnnualReport = System.Label.Annual_Report_Label;
        String approved = system.label.Approved;
        currentYear = yearvalue;
        date1 = DATE.newInstance(yearvalue, 1, 1);
        date2 = DATE.newInstance(yearvalue, 12, 31);
        rcId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = : Label.Business_Filing_API_Name AND Name = : Label.Annual_First_recordtype_label];

        query = 'SELECT Id,Status__c,Date_Registration__c,Sub_status__c,Business_Type__c,Citizenship__c,Annual_Report_Processing_Year__c,CreatedDate,Name,(Select Due_Date__c,Type__c,Status__c,Filing_Date__c,CreatedDate from Business_Filings__r where (Type__c =:FirstReport AND Status__c=:approved) OR (Due_Date__c >=:date1 AND Due_Date__c<=:date2 AND Type__c =:AnnualReport)) FROM Account where recordType.Name =:accountRecordType And Status__c=\'Active\' And Citizenship__c IN (\'Domestic\',\'Foreign\') AND Business_Type__c IN : businessTypes AND Date_Registration__c!=null AND Id IN : acRecIds';
    }

    /********************************************************************************************
        METHOD NAME    : start
        DESCRIPTION    : Batch start Method
        RETURN TYPE    : Database.QueryLocator
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accountRecordType = System.Label.ActionItem_AccountRecordType;
        String FirstReport = System.Label.First_Report_Label;
        String AnnualReport = System.Label.Annual_Report_Label;
        String approved = system.label.Approved;
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Adding field in query
        * Change(s)/Modification(s) Description : Adding field sub-status in query to avoid creation of annual report if the first report is due. The annual report after the first report is to  be created via process builder
        * Change(s)/Modification(s) Made on : 2021-04-21
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: UAT FIx
        * Change(s)/Modification(s) Description : Adding logic to m
        * Change(s)/Modification(s) Made on :
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        return Database.getQueryLocator(query);
    }
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext, List<Account>
    ********************************************************************************************/
    global void execute(Database.BatchableContext BC, List < Account > accList) {
        List<Account> accontsTobeUpdated = new List<Account>();
        Map<String, Id> busFilingToAccountId = new Map<String, Id>();
        Map<Id, String> failedBusFilingToAccountId = new Map<Id, String>();
        Map<Id, Map<String, String>> acOldMap = new Map<Id, Map<String, String>>();
        Map<Id, Boolean> firstReportCheckMap= new Map<Id, Boolean>();
        List<Id> accids=new List<Id>();
        for (Account acc : accList) {
            accids.add(acc.id);
            for (Business_Filing__c business : acc.Business_Filings__r) {
                if (business.Type__c == System.Label.First_Report_Label) {
                    firstFilingMap.put(acc.id, business.Filing_Date__c);
                } else {
                    accountAnnualFilingMap.put(acc.id, business.id);
                }
            }
        }
        for(Account acc:[Select id,(Select id from Business_Filings__r where Type__c='First Report' and Status__c In ('due','Past due') and Status__c !='Approved') from Account where id IN:accids])
        {
          if(acc.Business_Filings__r.isempty())
          {
             firstReportCheckMap.put(acc.id,true);
          }
        }
        for (Account acc : accList) {
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Adding condition to not creat AR if the First report is due or past due
            * Change(s)/Modification(s) Description : Adding condition to not creat AR if the First report is due or past due
            * Change(s)/Modification(s) Made on : 2021-04-21
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if (acc.Date_Registration__c != null && acc.Date_Registration__c.year() <= currentYear  && acc.Status__c == 'Active' && !accountAnnualFilingMap.containsKey(acc.Id) && acc.Sub_status__c != Label.First_Report_Due && acc.Sub_status__c != Label.First_report_past_due && firstReportCheckMap.get(acc.id) == true) {
                Business_Filing__c businessFiling = new Business_Filing__c();
                businessFiling.Type__c = System.Label.Annual_Report_Label;
                businessFiling.Account__c = acc.Id;
                if (!rcId.isEmpty()) {
                    businessFiling.recordTypeId = rcId.get(0).Id;
                }
                businessFiling.Business_Type__c  = acc.Business_Type__c;
                businessFiling.Filing_Type__c = System.Label.Annual_Report_Label;
                businessFiling.Status__c = System.Label.Due;
                businessFiling.Citizenship__c = acc.Citizenship__c;
                businessFiling.Batch_Created__c = true;
                createBusinessFiling(acc, businessFiling, currentYear);
                String key = String.valueOf(currentYear) + '-' + acc.Id;
                busFilingToAccountId.put(key, acc.Id);
                Map<String, String> oldValues = new Map<String, String>();
                oldValues.put('Sub_status__c', acc.Sub_status__c);
                String yearVal = acc.Annual_Report_Processing_Year__c != NULL ? String.valueOf(acc.Annual_Report_Processing_Year__c) : '';
                oldValues.put('Annual_Report_Processing_Year__c', yearVal);
                acOldMap.put(acc.Id, oldValues);
                /** update account status **/
                if(acc.Sub_status__c == NULL){
                    acc.Sub_status__c = system.label.Annual_Report_Due1;
                }
                acc.Annual_Report_Processing_Year__c = currentYear;
                accontsTobeUpdated.add(acc);
            }
        }
        Set<Id> successAccountIds = new Set<Id>();
        Set<Id> rollingBackAccounts = new Set<Id>();
        List<Business_Filing__c> successFilings = new List<Business_Filing__c>();
        try {
            Map<Id, String> FailerAccountIds = new Map<Id, String>();
            if (!accontsTobeUpdated.isEmpty()) {
                Database.SaveResult[] dmlResponse = Database.update(accontsTobeUpdated, false);
                for (Integer i = 0; i < dmlResponse.size(); i++) {
                    if (dmlResponse.get(i).isSuccess()) {
                        successAccountIds.add(dmlResponse.get(i).getId());
                    } else if (!dmlResponse.get(i).isSuccess()) {
                        // DML operation failed
                        Database.Error error = dmlResponse.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        accontsTobeUpdated.get(i);//failed record from the list
                        FailerAccountIds.put(accontsTobeUpdated.get(i).Id, failedDML);
                    }
                }
            }
            if(!businessFilingList.isEmpty() && !successAccountIds.isEmpty()){
                BusinessFilingTriggerHelper.updateFilingTypeAndFee(businessFilingList,New Map<ID,SObject>());
                List<Business_Filing__c> lstBfToInsert = new List<business_filing__c>();
                for(business_filing__c obf : businessFilingList){
                    if(successAccountIds.contains(obf.Account__c)){
                        lstBfToInsert.add(obf);
                    }
                }
                if(!lstBfToInsert.isEmpty()){
                    rollingBackAccounts = successAccountIds;
                    Database.SaveResult[] dmlResponse = Database.insert(lstBfToInsert,false);
                    for (Integer i = 0; i < dmlResponse.size(); i++) {
                        if (!dmlResponse.get(i).isSuccess()) {
                            // DML operation failed
                            Database.Error error = dmlResponse.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            String key = String.valueOf(currentYear) +'-'+ lstBfToInsert.get(i).Account__c;
                            lstBfToInsert.get(i);//failed record from the list
                            failedBusFilingToAccountId.put(busFilingToAccountId.get(key), failedDML);
                        }else{
                            successFilings.add(lstBfToInsert.get(i));
                        }      
                    }
                }
                if(!successFilings.isEmpty() && System.isBatch()){
                    brs_ActionItemUtility.createActionItem(successFilings);
                }
            }
            if(!failedBusFilingToAccountId.isEmpty()){
                List<Account> accRollBack = new List<Account>();
                For(Id acId : failedBusFilingToAccountId.keySet()){
                    if(acOldMap.containsKey(acId)){
                        Account acToRollBack = new Account(Id=acId);
                        Map<String,String> oldValues = acOldMap.get(acId);
                        for(String fieldName : oldValues.keySet()){
                            if(fieldName == 'Annual_Report_Processing_Year__c') {
                                String yearStr = oldValues.get(fieldName);
                                if(!String.isEmpty(yearStr)){
                                    acToRollBack.put(fieldName,Integer.valueOf(oldValues.get(fieldName)));
                                } else{
                                    acToRollBack.put(fieldName,null);
                                }
                            }
                            else{
                                acToRollBack.put(fieldName,oldValues.get(fieldName));
                            }
                        }
                        accRollBack.add(acToRollBack);
                    }
                    FailerAccountIds.put(acId, failedBusFilingToAccountId.get(acId));
                }
                Database.SaveResult[] dmlResponseACC = Database.update(accRollBack);
                for (Integer i = 0; i < dmlResponseACC.size(); i++) {
                    if (!dmlResponseACC.get(i).isSuccess()) {
                        // DML operation failed
                        Database.Error error = dmlResponseACC.get(i).getErrors().get(0);
                    }
                }
            }
            if(!FailerAccountIds.isEmpty()){
                //Insert failed record in bulk with message
                //public static Error_Log__c errorRecordLogger(String sClass,String sClassMethod, String objectName, String recId, String sSeverity, String e, String sAddlErrorInfo){
                List<Error_Log__c> errLogToInsert = new List<Error_Log__c>();
                for(String acId :FailerAccountIds.keySet()){
                    Error_Log__c er = BOS_Utility.errorRecordLogger(CLASSNAME,'Execute','Account',acId,'Medium',null,FailerAccountIds.get(acId));
                    errLogToInsert.add(er);
                }
                BOS_Utility.insertErrorRecordLst(errLogToInsert);
                businessFilingList.clear();
            }
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(CLASSNAME, 'createAnnualFiling', '', null, BOS_Utility.sSeverity, e, null);
        }
    }

    /********************************************************************************************
        METHOD NAME    : finish
        DESCRIPTION    : Batch finish method to update the notification status to sent for action items.
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global void finish(Database.BatchableContext BC) {}

    /** createBusinessFiling  **/
    public void createBusinessFiling(Account acc, Business_Filing__c businessFiling, Integer yearvalue) {
        Database.SaveResult[] srList = new List<Database.SaveResult>();
        Date d = acc.Date_Registration__c;
        if ((acc.Citizenship__c == System.Label.Domestic || acc.Citizenship__c == System.Label.Foreign) && acc.Business_Type__c == System.Label.businessTypeLLC) {
            businessFiling.Due_Date__c = DATE.newInstance(yearvalue, 3, 31);
        }
        if ((acc.Citizenship__c == System.Label.Domestic || acc.Citizenship__c == System.Label.Foreign) && (acc.Business_Type__c == System.Label.businessTypeLLP || acc.Business_Type__c == System.Label.Limited_Partnership_Comparable)) {
            IF(d.month() == 2 && d.day() == 29) {
                businessFiling.Due_Date__c = DATE.newInstance(yearvalue, 2, 28);
            }
            else {
                businessFiling.Due_Date__c = DATE.newInstance(yearvalue, d.month(), d.day());
            }
        }
        if (acc.Citizenship__c == System.Label.Domestic && (acc.Business_Type__c == System.Label.Stock || acc.Business_Type__c == System.Label.Non_Stock || acc.Business_Type__c == System.Label.Business_Type_BCORP)) {

            if (firstFilingMap.get(acc.id) == null || firstFilingMap.get(acc.id) < Date.newInstance(2020, 01, 01)) {
                if (d.month() == 2 && d.day() == 29) {
                    businessFiling.Due_Date__c = DATE.newInstance(yearvalue, 2, 28);
                } else {
                    businessFiling.Due_Date__c = DATE.newInstance(yearvalue, d.month(), d.day());
                }
            } else {
                Date da = firstFilingMap.get(acc.id);

                IF(da.month() == 2 && da.day() == 29) {
                    businessFiling.Due_Date__c = DATE.newInstance(yearvalue, 2, 28);
                }
                else {
                    businessFiling.Due_Date__c = DATE.newInstance(yearvalue, da.month(), da.day());
                }
            }
        }
         if (((acc.Citizenship__c == System.Label.Foreign) && (acc.Business_Type__c == System.Label.Stock || acc.Business_Type__c == System.Label.Non_Stock)) || test.isRunningTest()) {
            IF(d.month() == 2 && d.day() == 29) {
                businessFiling.Due_Date__c = DATE.newInstance(yearvalue, 2, 28);
            }
            else {
                businessFiling.Due_Date__c = DATE.newInstance(yearvalue, d.month(), d.day());
            }
        }
        // Adding recordtypeId
        if (!rcId.isEmpty()) {
            businessFiling.recordTypeId = rcId.get(0).Id;
        }
        businessFilingList.add(businessFiling);
        if (!System.isBatch()) {
            try {
                if (!businessFilingList.isEmpty()) {
                    //Old Code
                    srList = Database.insert(businessFilingList, false);
                }
                BOS_Utility.ExceptionHandlerForBatches(className, null, 'execute', srList,null);
            } catch (Exception ex) {
                BOS_Utility.ExceptionHandler(CLASSNAME, 'createAnnualFiling', '', null, BOS_Utility.sSeverity, ex, null);
            }
        }
    }

    @AuraEnabled
    public static Date getBusinessFiling(String accountId, Boolean isMaintainanceFlowOrNot) {
        String FirstReport = System.Label.First_Report_Label;
        List<String> yearList = new List<String> {string.valueOf(system.today().year()), string.valueOf(system.today().addyears(1).year()) };
        Account acccount = [SELECT Id, Status__c, Date_Registration__c, Business_Type__c,
                            Citizenship__c, CreatedDate,
                            Name, (Select Due_Date__c, Type__c, Status__c, Filing_Date__c, CreatedDate
                                   FROM Business_Filings__r
                                   WHERE Type__c = : system.label.Annual_Report
                                           AND Due_Year__c IN: yearList)
                            FROM Account
                            WHERE id = : accountId];
        Date finaldate;

        if (acccount.business_filings__r != null && acccount.business_filings__r.size()>0) {
            for (Business_Filing__c filing : acccount.business_filings__r) {
                if (filing.Due_Date__c >= system.today()) {
                    finaldate = filing.Due_Date__c;
                } else {
                    finaldate = filing.Due_Date__c.addYears(1);
                }
            }
        } else {
            Date dataofformation = acccount.Date_Registration__c;
            finaldate = DATE.newInstance(dataofformation.year() + 1, dataofformation.month(), dataofformation.day());
        }

        return finaldate;

    }

    public static List<Business_Filing__c> getFirstFiling(String accountId) {
        return [Select Due_Date__c, Type__c, Status__c, Filing_Date__c, CreatedDate
                FROM Business_Filing__c
                WHERE Type__c = : system.label.First_Report_Label
                                And Account__c = : accountId];
    }

    @InvocableMethod
    public static void createAnnualFiling(List<Id> businessFilingId) {
        if (!businessFilingId.isEmpty()) {
            List<Business_Filing__c> firstFilings = new List<Business_Filing__c>();
            Map < Id, Date > firstBusinessFilingMap = new Map < Id, Date > ();
            Account account = [SELECT Id, Status__c, Sub_status__c,Date_Registration__c,Reason_for_Administrative_Dissolution__c, Business_Type__c,
                               Citizenship__c, CreatedDate, Name,
                               (Select Due_Date__c, Type__c, Status__c, Filing_Date__c, CreatedDate
                                FROM Business_Filings__r
                                WHERE Type__c = : system.label.Annual_Report and Status__c !='Rejected')
                               FROM Account
                               WHERE id = : businessFilingId[0]];
            if (account.Citizenship__c == System.Label.Domestic) {
                firstFilings = getFirstFiling(businessFilingId[0]);
                for (Business_Filing__c business : firstFilings) {
                    firstBusinessFilingMap.put(account.id, business.Filing_Date__c);
                }
            }
            integer count = 0, approvecount = 0,futurecount =0;
            if (account.Business_Filings__r.isEmpty()) {
                Business_Filing__c businessFiling = new Business_Filing__c();
                businessFiling.Type__c = System.Label.Annual_Report_Label;
                businessFiling.Account__c = businessFilingId[0];
                businessFiling.Business_Type__c = account.Business_Type__c;
                // Adding new field prepopulation.
                businessFiling.Filing_Type__c = System.Label.Annual_Report_Label;
                businessFiling.Status__c = System.Label.Due;
                businessFiling.Citizenship__c = account.Citizenship__c;
                /** update account status **/
                account.Sub_status__c = system.label.Annual_Report_Due1;
                if(account.Reason_for_Administrative_Dissolution__c !=null)
                {
                    account.Reason_for_Administrative_Dissolution__c=null;
                }
                account.Annual_Report_Processing_Year__c = system.today().addYears(1).year();
                BRS_annualFilingReportBatch brs = new BRS_annualFilingReportBatch(system.today().year(),true);
                brs.firstFilingMap = firstBusinessFilingMap;
                brs.createBusinessFiling(account, businessFiling, system.today().addYears(1).year() );
            } else {
                for (Business_Filing__c filing : account.Business_Filings__r) {
                    if (filing.Status__c != system.label.Approved) {
                        if(filing.Due_Date__c < System.today())
                        {
                           count++;
                        }
                        else
                        {
                            futurecount++;
                        }
                    } else {
                        approvecount++;
                    }
                }
            }


            try {
                if(!account.Business_Filings__r.isEmpty())
                {
                if(count == 0 && Futurecount == 0 && account.Business_Filings__r.size() == approvecount)
                {
                       account.Sub_status__c = QNA_COnstants.EMPTY_STRING;
                       if(account.Reason_for_Administrative_Dissolution__c !=null)
                       {
                           account.Reason_for_Administrative_Dissolution__c=null;
                       }
                }
                else if(account.Sub_status__c == System.label.Admin_Dissolution_Initiated_Label)
                {
                    if(count > 0)
	                {
		               account.Sub_status__c =system.label.Admin_Dissolution_Initiated_Label;
	                }
		           else if(count == 0 && futurecount >0)
		           {
		             account.Sub_status__c =system.label.Annual_Report_Due1;
                     if(account.Reason_for_Administrative_Dissolution__c !=null)
                     {
                         account.Reason_for_Administrative_Dissolution__c=null;
                     }
		           }
                }
                else{
                    if(count >=2)
                    {
                      account.Sub_status__c = system.label.Ready_for_dissolution;
                    }
                   else if(count == 1){
                    account.Sub_status__c = system.label.Annual_Report_Past_Due;
                   }
                  else if(count == 0 && futurecount >0)
                  {
                   account.Sub_status__c =system.label.Annual_Report_Due1;
                   if(account.Reason_for_Administrative_Dissolution__c !=null)
                   {
                       account.Reason_for_Administrative_Dissolution__c=null;
                   }
                  } 
                }
                }
                update account;
            } catch (Exception ex) {
                BOS_Utility.ExceptionHandler(CLASSNAME, 'createAnnualFiling', '', null, BOS_Utility.sSeverity, ex, null);
            }
        }

    }
    
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : SchedulableContext
    ********************************************************************************************/
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BRS_annualFilingReportBatch(system.today().year(),true), 200);
    }
}