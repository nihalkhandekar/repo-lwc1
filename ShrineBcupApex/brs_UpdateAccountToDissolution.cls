/*********************************************************************************************
 * NAME:  brs_UpdateAccountToDissolution
 * DESCRIPTION: Batch class to send email/sms based on first report due or past due..
 *
 * @AUTHOR: Avinash Shukla
 * @DATE: 2021-05-12
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Avinash Shukla                   2021-05-12                         Created the first version
 *
*************************************************************************************************/
public without sharing class brs_UpdateAccountToDissolution implements Database.Batchable<sObject>, Schedulable {
    public string query = '';
    public string businessFilingStatus = '';
    public string activeBusinessStatus = '';
    public Set<String> accountStatuses;
    public Set<String> accountSubStatuses;
    public Set<String> accountNotInSubStatuses;
    public Set<String> bFSubStatuses;
    public static final string CLASSNAME = 'brs_UpdateAccountToDissolution';

    public brs_UpdateAccountToDissolution(){
        businessFilingStatus = System.label.PastDue;
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-6451
        * Change(s)/Modification(s) Description : Added condition to perform dissolution only on active accounts.
        * Change(s)/Modification(s) Made on : 12-08-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        activeBusinessStatus = System.label.ACTIVE;
        accountStatuses = new Set<String>{System.label.Account_Active_Annual_Report_past_due, System.label.Account_Active_First_Report_past_due};
        accountSubStatuses = new Set<String>{System.label.Annual_report_past_due_Comparable,System.label.First_report_past_due_Comparable,System.label.First_Report_Due_Comparable,System.label.Annual_Report_Due1_Comparable};
        accountNotInSubStatuses = new Set<String>{System.label.Ready_for_dissolution_Comparable};
        bFSubStatuses = new Set<String>{System.Label.Annual_Report_Comparable,System.Label.BRS_First_Report};
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-6451
        * Change(s)/Modification(s) Description : Added condition to perform dissolution only on active accounts.
        * Change(s)/Modification(s) Made on : 12-08-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        query = 'Select Id, Name, Sub_status__c,Business_Type__c, Status__c, Days_passed_since_sub_status_changed__c, (Select Id, Status__c, Type__c, Filing_Date__c, Due_Date__c from Business_Filings__r WHERE Status__c=:businessFilingStatus AND Type__c IN : bFSubStatuses Order By Due_Date__c ASC) From Account WHERE Sub_Status__c IN : accountSubStatuses AND Sub_Status__c NOT IN : accountNotInSubStatuses AND Status__c =:activeBusinessStatus AND Days_passed_since_sub_status_changed__c >= ';
        query = query + Integer.valueOf(System.label.Elapsed_Days_from_Past_Due);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> lstAccount) {
        try{
            Integer successCount=0;
            Integer errorCount=0;
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            Database.SaveResult[] srList = new List<Database.SaveResult>();
            List<Account> acToUpdate = new List<Account>();
            for (Account accObj : lstAccount) {
                boolean isModified = false;
                if((accOBJ.Business_Type__c == 'LLC'||accOBJ.Business_Type__c == 'LLP' || accOBJ.Business_Type__c == 'Limited Partnership' || accOBJ.Business_Type__c == 'Stock' || accOBJ.Business_Type__c =='B Corp') && accObj.Days_passed_since_sub_status_changed__c >= Integer.valueOf(System.label.Elapsed_Days_from_Past_Due)){
                    accObj.Sub_Status__c = System.label.Ready_for_dissolution_Comparable;
                    isModified = true;
                }
                else
                {
                    if(accOBJ.Business_Type__c == 'Non-Stock' && accObj.Days_passed_since_sub_status_changed__c >= 730){
                    accObj.Sub_Status__c = System.label.Ready_for_dissolution_Comparable;
                    isModified = true;
                    }
                }
                if(isModified){
                    acToUpdate.add(accObj);
                }
            }
            if(!acToUpdate.isEmpty()){
                // Adding database.update.to pass success records.
                srList = Database.update(acToUpdate,false);
                for(Integer i=0;i<srList.size();i++){
                    if (srList.get(i).isSuccess()){
                        successCount = successCount + 1;
                    }
                    else if (!srList.get(i).isSuccess()){
                        errorCount = errorCount + 1;
                    }
                }
            }
            Batch_Job_Logs__c createLog = new Batch_Job_Logs__c ();
            createLog.Class_Name__c = CLASSNAME;
            createLog.Job_Operation__c = System.Label.Batch_Update;
            createLog.Job_Configuration_Name__c = 'Account Dissolution Batch';
            createLog.Success_Record_Count__c = successCount;
            createLog.Error_Record_Count__c = errorCount;
            createLog.Object_Name__c = (acToUpdate.get(0).Id).getSObjectType().getDescribe().getName();
            lstAppErrorLogs.add(createLog);
            
            if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
               Database.SaveResult[] resultLst = new List<Database.SaveResult>();
               resultLst = Database.insert(lstAppErrorLogs,false);
           	}

            BOS_Utility.ExceptionHandlerForBatches(CLASSNAME,null,'execute',srList,acToUpdate);
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(CLASSNAME,'execute','',null,BOS_Utility.sSeverity,ex,null);
        }
    }
    public void finish(Database.BatchableContext BC) {
        // Batch executed.
    }
    public void execute(SchedulableContext sc){
        Database.executeBatch(new brs_UpdateAccountToDissolution());
    }
}