/*********************************************************************************************
 * NAME:  brs_SendFirstReportNotifications
 * DESCRIPTION: Batch class to send email/sms based on first report due or past due..
 *
 * @AUTHOR: Avinash Shukla
 * @DATE: 2021-03-31
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Avinash Shukla                   2021-05-11                         Created the first version
 *
*************************************************************************************************/
public with sharing class brs_SendFirstReportNotifications implements Database.Batchable<sObject>, Database.Stateful {

    public string query = '';
    public string activeAccountStatus = '';
    public Map<String, EmailTemplate> etNameToEt;
    public List<OrgWideEmailAddress> owa;
    public Set<string> emailTemplatesName;
    public Set<string> firstReportSubStatuses;
    public Set<string> firstReportApprovedStatus;
    public Set<String> accBusinessTypeForFirstReport;
    public string firstReport = System.Label.BRS_First_Report;
    public static final string CLASSNAME = 'brs_SendFirstReportNotifications';
    public string dynamicCommunityURL = '';
    public string dynamicCommunityRedirectURL = '';


    public brs_SendFirstReportNotifications() {
        List<Network> networks = new List<Network>();
        String networkName = System.Label.Community_Name;
        networks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE name = :networkName];
        
        //BRS-6671 | Labels do not work with substringafter. Use hardcoding
        if(!networks.isEmpty()){
            //For sandbox/prod - diff urls
            String communityDomain = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox
                ? '.com/'
                : '.gov/';

            String URl = Network.getLoginUrl(networks.get(0).Id);
            dynamicCommunityRedirectURL = URl.replace(URl.substringAfter(communityDomain),System.Label.Redirect_URL);
            dynamicCommunityURL = URl.replace(URl.substringAfter(communityDomain),System.Label.AR_FR_Email_URL_Params);
            dynamicCommunityURL = dynamicCommunityRedirectURL + dynamicCommunityURL;
        }
        
        activeAccountStatus = System.Label.ACTIVE;
        firstReportApprovedStatus = new Set<String> {System.Label.BRS_FilingStatus_Approved};
        accBusinessTypeForFirstReport = new Set<String> {System.Label.Business_Type_BCORP, System.Label.Non_Stock, System.Label.Stock};
        firstReportSubStatuses = new Set<String>(System.Label.First_report_sub_statuses.split(System.Label.PIPELINE_SEPARATOR));
        owa = new List<OrgWideEmailAddress>();
        owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address = : System.label.BRS_sotsOrgWideEmailAddr limit 1];
        etNameToEt = new Map<String, EmailTemplate>();
        emailTemplatesName = new Set<String>(System.Label.First_Report_Templates.split(System.Label.PIPELINE_SEPARATOR));
        for (EmailTemplate etObj : [Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName IN : emailTemplatesName]) {
            etNameToEt.put(etObj.Name, etObj);
        }
        system.debug('etNameToEt ::: ' + etNameToEt);
        query = 'Select Id, Name, Business_Email_Address__c, AccountNumber, Business_Type__c, Sub_status__c, Status__c, Annual_report_past_due_date__c, Date_Registration__c, (SELECT Id, AccountId, Account.Name, Contact.Email, Account.Business_Email_Address__c, ContactId, Contact.Due_date_reminders_email_notification__c, IsActive FROM AccountContactRelations WHERE IsActive = true), (SELECT Id, Filing_Date__c, Type__c, Due_Date__c, Status__c, Owner.FirstName FROM Business_Filings__r WHERE Status__c NOT IN : firstReportApprovedStatus AND Type__c =: firstReport Order by CreatedDate ASC LIMIT 1) from Account WHERE Status__c =: activeAccountStatus AND Business_Email_Address__c != NULL AND Sub_status__c IN : firstReportSubStatuses AND Business_Type__c IN : accBusinessTypeForFirstReport WITH SECURITY_ENFORCED';
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> lstAccount) {
        try{
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            for (Account accObj : lstAccount) {
                Business_filing__c oBf;
                Boolean isFirstReportPast = false;
                Boolean isFirstReportDue = false;
                Boolean isFirstReportDueToday = false;
                String[] toAddress = new List<String>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if (accObj.Sub_status__c == System.Label.BRS_First_Rep_Due) {
                    if(!accObj.Business_Filings__r.isEmpty()){
                        oBf = accObj.Business_Filings__r;
                        if(oBf.Due_Date__c == Date.today()){
                            isFirstReportDueToday = true;
                        } else {
                            isFirstReportDue = true;
                        }
                    }
                } else if (accObj.Sub_status__c == System.Label.First_report_past_due) {
                    if(!accObj.Business_Filings__r.isEmpty()){
                        oBf = accObj.Business_Filings__r;
                    }
                    isFirstReportPast = true;
                }
                if(String.isNotBlank(accObj.Business_Email_Address__c)){
                    toAddress.add(accObj.Business_Email_Address__c);
                }

                if (!accObj.AccountContactRelations.isEmpty()) {
                    for (AccountContactRelation acrObj : accObj.AccountContactRelations) {
                        if (acrObj.Contact.Due_date_reminders_email_notification__c && acrObj.Contact.Email != NULL) {
                            toAddress.add(acrObj.Contact.Email);
                        }
                    }
                }
                for (String str : toAddress) {
                    
                    if(oBf != NULL && oBf.Due_Date__c != NULL){
                        if (isFirstReportDueToday) {
                            messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(System.Label.FR_Due_Today_Email_Template), new string[] {str},oBf,dynamicCommunityURL));
                        } else if (isFirstReportDue) {
                            if(Date.Today().daysBetween(oBf.Due_Date__c) == Integer.ValueOf(System.Label.FR_Due_IN_30)){
                                messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(System.Label.FR_30_Due_Email_Template), new string[] {str},oBf,dynamicCommunityURL));
                            } else if(Date.Today().daysBetween(oBf.Due_Date__c) == Integer.ValueOf(System.Label.FR_Due_IN_60)){
                                messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(System.Label.FR_60_Due_Email_Template), new string[] {str},oBf,dynamicCommunityURL));
                            }
                        } else if (isFirstReportPast) {
                            if(oBf != NULL && oBf.Due_Date__c != NULL){
                                if(oBf.Due_Date__c.daysBetween(Date.today()) == Integer.ValueOf(System.Label.FR_Due_Past_30) || oBf.Due_Date__c.daysBetween(Date.today()) == Integer.ValueOf(System.Label.FR_Due_Past_60) || oBf.Due_Date__c.daysBetween(Date.today()) == Integer.ValueOf(System.Label.FR_Due_Past_90)){
                                    messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(System.Label.FR_Past_Due_Email_Template), new string[] {str},oBf,dynamicCommunityURL));
                                }
                            }
                        }
                    }
                    
                    
                }
            }

            if(!messages.isEmpty()){
                // Create log for number of records
                Batch_Job_Logs__c createLog = new Batch_Job_Logs__c ();
                createLog.Class_Name__c = CLASSNAME;
                createLog.Job_Operation__c = 'Send Notification';
                createLog.Job_Configuration_Name__c = 'First Report Due Notification';
                createLog.Success_Record_Count__c = messages.size();
                createLog.Object_Name__c = 'Account';
                lstAppErrorLogs.add(createLog);

                if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
                    Database.SaveResult[] resultLst = new List<Database.SaveResult>();
                    resultLst = Database.insert(lstAppErrorLogs,false);
                }

                Messaging.sendEmail(messages);
            }            
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(CLASSNAME,'execute','',null,BOS_Utility.sSeverity,ex,null);
        }
    }
    public void finish(Database.BatchableContext BC) {
        // Batch executed.
    }
    public static Messaging.SingleEmailMessage getEmail(Account accObj, OrgWideEmailAddress owa, EmailTemplate etObj, String[] toaddresses, Business_filing__c oBf, String dynamicCommunityURL) {
        Boolean isDuedatePassed = false;
        Datetime dt = oBf.Due_Date__c;
        if(dt < Date.today()){
            isDuedatePassed = true;
        }
        String dueDate = dt.format(System.Label.Date_Format);
        String uniqueUrl = dynamicCommunityURL +  accObj.id;
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(etObj.Id, null, null);
        String htmlBody = email.getHtmlBody();
        if (owa != null) {
            email.setOrgWideEmailAddressId(owa.Id);
        }

        email.setTemplateId(etObj.Id);
        htmlBody = htmlBody.replace(Label.Account_Name, accObj.Name);
        htmlBody = htmlBody.replace(Label.Template_businessId_Identifier, accObj.AccountNumber);
        if(isDuedatePassed){
            htmlBody = htmlBody.replace(Label.is_Was, Label.Due_date_is_passed);
        } else {
            htmlBody = htmlBody.replace(Label.is_Was, Label.Due_Date_in_Future);
        }
        htmlBody = htmlBody.replace(Label.Report_Due_Date, dueDate);
        htmlBody = htmlBody.replace(Label.FR_email_template_Owner_Name, oBf.Owner.FirstName);
        htmlBody = htmlBody.replace(Label.Filing_URL, uniqueUrl);
        htmlBody = htmlBody.replace(Label.report_Type, Label.report_type_First_Report);
        email.setHtmlBody(htmlBody);
        email.setToAddresses(toaddresses);
        return email;
    }
}