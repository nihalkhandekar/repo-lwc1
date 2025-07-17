/*********************************************************************************************
 * NAME:  BRS_SendNotificationBusinessFiling
 * DESCRIPTION: Batch class to send email/sms based on annual report status.
 *
 * @AUTHOR: Avinash Shukla
 * @DATE: 2021-03-31
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Avinash Shukla                   2021-03-31                         Created the first version
 *
*************************************************************************************************/
public without sharing class BRS_SendNotificationBusinessFiling implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public string query = '';
    public string activeAccountStatus = '';
    public Map<String, EmailTemplate> etNameToEt;
    public List<OrgWideEmailAddress> owa;
    public Set<string> emailTemplatesName;
    public Set<string> annualReportStatuses;
    public String account_SID;
    public List<String> accBusinessTypeExceptLLC;
    public static final string CLASSNAME = 'BRS_SendNotificationBusinessFiling';
    public string dynamicCommunityURL = '';
    public string dynamicCommunityRedirectURL = '';
    public Date days30Passed;
    public Date days60Passed;
    public Date days90Passed;
    public Date days30Prior;
    public Date days15Prior;
    public Date llcFirstNotificationDate;
    public Date llcSecondNotificationDate;
    Date llcstartDate;
    Date llcstartDate45day;
    String arDue;
    String arPastDue;
    List<Date> annualDueLLC;
    List<Date> annualDue;
    List<Date> annualDuepast;

    public BRS_SendNotificationBusinessFiling() {
        arDue = system.Label.Annual_report_due2;
        arPastDue = System.Label.Annual_report_past_due;
        llcstartDate = Date.newInstance(Date.Today().year(), 1, 1);
        llcstartDate45day = Date.newInstance(Date.Today().year(), 1, 1).addDays(45);
        days15Prior = Date.today().addDays(15);
        days30Prior = Date.today().addDays(30);
        days30Passed = Date.today().addDays(-30);
        days60Passed = Date.today().addDays(-60);
        days90Passed = Date.today().addDays(-90);
        annualDueLLC = new List<Date>{llcstartDate,llcstartDate45day};
        annualDue = new List<Date>{days15Prior,days30Prior,Date.today()};
        annualDuepast = new List<Date>{days30Passed,days60Passed,days90Passed};


        System.debug('annualDueLLC'+annualDueLLC);
        System.debug('annualDue'+annualDue);
        System.debug('annualDuepast'+annualDuepast);

        List<Network> networks = new List<Network>();
        String networkName = System.Label.Community_Name;
        networks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE name = :networkName];

        //BRS-6671 | Labels do not work with substringafter. Use hardcoding
        if(!networks.isEmpty()) {
            //For sandbox/prod - diff urls
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

            String URl = Network.getLoginUrl(networks.get(0).Id);
            dynamicCommunityRedirectURL = isSandbox 
                ? URl.replace(URl.substringAfter('.com/'),System.Label.Redirect_URL)
                : URl.replace(URl.substringAfter('.gov/'),System.Label.Redirect_URL);
            dynamicCommunityURL = isSandbox 
                ? URl.replace(URl.substringAfter('.com/'),System.Label.AR_FR_Email_URL_Params)
                : URl.replace(URl.substringAfter('.gov/'),System.Label.AR_FR_Email_URL_Params);
            dynamicCommunityURL = dynamicCommunityRedirectURL + dynamicCommunityURL;
        }

        activeAccountStatus = label.ACTIVE;
        accBusinessTypeExceptLLC = new List<String> {Label.LLP, Label.Business_Type_BCORP, Label.Non_Stock, Label.Stock, System.Label.Limited_Partnership};
        annualReportStatuses = new Set<String>(Label.Report_Due_Annual_Statuses.split(System.Label.PIPELINE_SEPARATOR));
        Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig(Label.Twilio_API);
        account_SID = accountInfo.API_Key__c;
        owa = new List<OrgWideEmailAddress>();
        owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address = : System.label.BRS_sotsOrgWideEmailAddr limit 1];
        etNameToEt = new Map<String, EmailTemplate>();
        emailTemplatesName = new Set<String>(Label.annual_report_email_templates.split(System.Label.PIPELINE_SEPARATOR));
        for (EmailTemplate etObj : [Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName IN : emailTemplatesName]) {
            etNameToEt.put(etObj.Name, etObj);
        }
        query = 'Select Id, Name, Business_Email_Address__c, Business_Type__c, Sub_status__c, AccountNumber, Status__c, Annual_report_past_due_date__c, (SELECT Id, AccountId, Account.Name, Account.Business_Email_Address__c, ContactId, Contact.Due_date_reminders_email_notification__c , Contact.Due_date_reminders_sms_notification__c, Contact.Phone, Contact.Email, IsActive FROM AccountContactRelations WHERE IsActive = true) from Account WHERE Status__c =: activeAccountStatus AND Business_Email_Address__c != NULL AND Annual_report_past_due_date__c != NULL AND Business_Type__c !=\'LLC\' AND ((Sub_status__c =: arDue AND Annual_report_past_due_date__c in:annualDue ) OR (Sub_status__c =: arPastDue AND Annual_report_past_due_date__c in:annualDuepast ))';
   
 
}
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> lstAccount) {
        try{
            Integer batchCount = 0;
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            for (Account accObj : lstAccount) {
                String uniqueUrl = dynamicCommunityURL +  accObj.id;
                Boolean isAnnualReportPast = false;
                Boolean isAnnualReportDue = false;
                Boolean isAnnualReportDueToday = false;
                String[] toAddress = new List<String>();
                List<String> toNum = new List<String>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if (accObj.Sub_status__c == Label.Annual_report_due2) {
                Date dueDate = accObj.Annual_report_past_due_date__c;
                    if (dueDate == Date.today()) {
                        isAnnualReportDueToday = true;
                    } else {
                        isAnnualReportDue = true;
                    }
                } else if (accObj.Sub_status__c == Label.Account_Annual_report_past_due) {
                    isAnnualReportPast = true;
                }
                if(String.isNotBlank(accObj.Business_Email_Address__c)){
                    toAddress.add(accObj.Business_Email_Address__c);
                }
                if (!accObj.AccountContactRelations.isEmpty()) {
                    for (AccountContactRelation acrObj : accObj.AccountContactRelations) {
                        if (acrObj.Contact.Due_date_reminders_email_notification__c && acrObj.Contact.Email != NULL) {
                            toAddress.add(acrObj.Contact.Email);
                        }
                        if (acrObj.Contact.Due_date_reminders_sms_notification__c) {
                            toNum.add(acrObj.Contact.Phone);
                        }
                    }
                }

                for (String phNum : toNum) {
                    String SMSBody = '';
                    if (isAnnualReportDueToday) {
                        SMSBody = Label.Annual_report_due_today_sms_template;
                        SMSBody = SMSBody.replace(Label.Account_Name, accObj.Name);
                        SMSBody = SMSBody.replace(Label.Filing_URL, uniqueUrl);
                    } else if (isAnnualReportDue) {
                        if (accObj.Business_Type__c == label.LLC) {
                            Date startDate = Date.newInstance(Date.Today().year(), 1, 1);
                            String counter = System.label.AnnualLLPReminderDateCounters;
                            String[] count = counter.split(',');
                            String daysBetween =  String.valueOf(startDate.daysBetween(Date.today()));
                            if ((Date.today().month() == 1 && Date.today().day() == 1) || (count.contains(daysBetween))) {
                                SMSBody = Label.annual_report_due_sms_template;
                                SMSBody = SMSBody.replace(Label.Account_Name, accObj.Name);
                                SMSBody = SMSBody.replace(Label.Filing_URL, uniqueUrl);
                            }
                        } else if (accBusinessTypeExceptLLC.contains(accObj.Business_Type__c)) {
                            String val  = System.label.AnnualBusinessTypeExceptLLCDateCounters;
                            Boolean isOtherConditionTrue = false;
                            String[] counter = val.split(',');
                            if (counter != null && counter.size() > 0) {
                                for (String day : counter) {
                             Date cdate = accObj.Annual_report_past_due_date__c;
                             Integer count = Integer.valueOf(day);
                             cdate = cdate.addDays(count);
                        if(cdate == Date.today()){
                            isOtherConditionTrue=true;
                            break;
                        }
                              }
                           }
                          if (isOtherConditionTrue==true) {
                                SMSBody = Label.annual_report_due_sms_template;
                                SMSBody = SMSBody.replace(Label.Account_Name, accObj.Name);
                                SMSBody = SMSBody.replace(Label.Filing_URL, uniqueUrl);
                            }
                        }
                    } else if (isAnnualReportPast) {
                        String counter = System.label.AnnualReportReminderDateCounters;
                        String[] count = counter.split(',');
                        Date cdate = accObj.Annual_report_past_due_date__c;

                        String daysBetween =  String.valueOf( cdate.daysBetween(Date.today()));
                        if (count.contains(daysBetween)) {
                            SMSBody = Label.Annual_report_due_past_sms_template;
                            SMSBody = SMSBody.replace(System.Label.Account_Name, accObj.Name);
                            SMSBody = SMSBody.replace(System.Label.Filing_URL, uniqueUrl);
                        }
                    }
                    if (!String.isEmpty(SMSBody)) {
                        BOSTwilioSMSService.WrapperResult resultWrap = BOSTwilioSMSService.sendSMS(account_SID, phNum, SMSBody);
                    }
                }
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                for (String str : toAddress) {
                    
                    if (isAnnualReportDueToday) {
                        messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(Label.Annual_report_due_today), new string[] {str},dynamicCommunityURL));
                    } else if (isAnnualReportDue) {
                        if (accObj.Business_Type__c == label.LLC) {
                            Date startDate = Date.newInstance(Date.Today().year(), 1, 1);
                            String counter = System.label.AnnualLLPReminderDateCounters;
                            String[] count = counter.split(',');
                            String daysBetween =  String.valueOf(startDate.daysBetween(Date.today()));

                            if ((Date.today().month() == 1 && Date.today().day() == 1) || (count.contains(daysBetween))) {
                                messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(Label.Annual_report_due2), new string[] {str},dynamicCommunityURL));
                            }
                        } else if (accBusinessTypeExceptLLC.contains(accObj.Business_Type__c)) {
                            String val  = System.label.AnnualBusinessTypeExceptLLCDateCounters;
                            Boolean isOtherConditionTrue = false;
                            String[] counter = val.split(',');
                            if (counter != null && counter.size() > 0) {
                                for (String day : counter) {
                                    Date cdate = accObj.Annual_report_past_due_date__c;
                                    Integer count = Integer.valueOf(day);
                                    cdate = cdate.addDays(count);
                                    if (cdate == Date.today()) {
                                        isOtherConditionTrue = true;
                                    }
                                }
                            }
                            if (isOtherConditionTrue==true) {
                           messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(Label.Annual_report_due2), new string[] {str},dynamicCommunityURL));
                            }
                        }
                    } else if (isAnnualReportPast) {
                        String counter = System.label.AnnualReportReminderDateCounters;
                        String[] count = counter.split(',');
                        Date cdate = accObj.Annual_report_past_due_date__c;

                        String daysBetween =  String.valueOf(cdate.daysBetween(Date.today()));
                        if (count.contains(daysBetween)) {
                            messages.add(getEmail(accObj, owa.get(0), etNameToEt.get(Label.Account_Annual_report_past_due), new string[] {str},dynamicCommunityURL));
                        }
                    }
                    Messaging.sendEmail(messages);                    
                }
                batchCount = messages.size();
            }
            // Create log for number of records
            Batch_Job_Logs__c createLog = new Batch_Job_Logs__c ();
            createLog.Class_Name__c = CLASSNAME;
            createLog.Job_Operation__c = 'Send Notification';
            createLog.Job_Configuration_Name__c = 'Annual Report Due Notification';
            createLog.Success_Record_Count__c = batchCount;
            createLog.Object_Name__c = 'Account';
            lstAppErrorLogs.add(createLog);

            if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
                Database.SaveResult[] resultLst = new List<Database.SaveResult>();
                resultLst = Database.insert(lstAppErrorLogs,false);
            }
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(CLASSNAME, 'execute', '', null, BOS_Utility.sSeverity, ex, null);
        }
    }
    public void finish(Database.BatchableContext BC) {
        // Batch executed.
    }
    public static Messaging.SingleEmailMessage getEmail(Account accObj, OrgWideEmailAddress owa, EmailTemplate etObj, String[] toaddresses,String dynamicCommunityURL) {
        Boolean isDuedatePassed = false;
        Date dt = accObj.Annual_report_past_due_date__c;
        if(dt < Date.today()){
            isDuedatePassed = true;
        }
        String dueDate = dt.format();
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
        htmlBody = htmlBody.replace(Label.report_Type, Label.report_type_Annual);
        htmlBody = htmlBody.replace(Label.Filing_URL, uniqueUrl);
        email.setHtmlBody(htmlBody);
        email.setToAddresses(toaddresses);
        return email;
    }
}