/*********************************************************************************************
 * NAME:  BRS_MassMailingBatch
 * DESCRIPTION: Batch class to send annual report reminder emails for LLC businesses.
 * @AUTHOR: Tamkanat
 * @DATE: 1st Nov 2021
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Tamkanat                        2021-11-01                         Created the first version
*************************************************************************************************/

public with sharing class BRS_MassMailingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public static final string CLASSNAME = 'BRS_MassMailingBatch';
    public string dynamicCommunityURL = '';
    public string dynamicCommunityRedirectURL = '';
    private Date fromDate;
    private Date toDate;
    private String uniqueBatchName;
    
    @InvocableMethod
    public static void getMailingConfig(List<Requests> Requests) {
        
        BRS_MassMailingBatch mailBatch = new BRS_MassMailingBatch(Requests[0]);
        Database.executeBatch(mailBatch,30);
    }

    public with sharing class Requests {
        @InvocableVariable
        public Date fromDate;
        @InvocableVariable
        public Date toDate;
        @InvocableVariable
        public String uniqueName;
    }   

    public BRS_MassMailingBatch(Requests req) {
        fromDate = req.fromDate;
        toDate = req.toDate;
        uniqueBatchName = req.uniqueName;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String arDue = System.Label.Annual_report_due2;
        String arPastDue = System.Label.Annual_report_past_due;
        String activeAccountStatus = label.ACTIVE;
        
        String query = 'Select Id, Name, Business_Email_Address__c, Business_Type__c, Sub_status__c, AccountNumber, Status__c, Annual_report_past_due_date__c,Date_Registration__c, (SELECT Id, AccountId, Account.Name, Account.Business_Email_Address__c, ContactId, Contact.Due_date_reminders_email_notification__c , Contact.Due_date_reminders_sms_notification__c, Contact.Phone, Contact.Email, IsActive FROM AccountContactRelations WHERE IsActive = true),(select Id, Account__c,Batch_Name__c,Status_Code__c from Mass_Mailing_Results__r) from Account WHERE Status__c =: activeAccountStatus AND Business_Email_Address__c != NULL AND Annual_report_past_due_date__c != NULL AND Business_Type__c =\'LLC\' AND Invalid_Email_on_Account_Contact__c!=true AND ((Sub_status__c =:arDue) OR (Sub_status__c =: arPastDue)) AND Date_Registration__c>=:fromDate AND Date_Registration__c<=:toDate AND Annual_report_past_due_date__c < NEXT_YEAR';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> lstAccount) {
       
            List<Account> finalAccountList = new List<Account>();
            List<Account> updateAccounts = new List<Account>();
            List<Mass_Mailing_Result__c> mailResponses = new List<Mass_Mailing_Result__c>();
            Set<Id> contactIds = new Set<Id>(); // To capture contact ids with invalid emails.
			
			List<Network> networks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE name = :System.Label.Community_Name Limit 1];

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

            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.label.BRS_sotsOrgWideEmailAddr);
            Map<String, EmailTemplate> etNameToEt = new Map<String, EmailTemplate>();
            Set<string> emailTemplatesName = new Set<String>(Label.annual_report_email_templates.split(System.Label.PIPELINE_SEPARATOR));
            for (EmailTemplate etObj : [Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName IN : emailTemplatesName]) {
                etNameToEt.put(etObj.Name, etObj);
            }
           
            for (Account accObj : lstAccount) {
                Boolean mailAlreadySent = false;
                if(!accObj.Mass_Mailing_Results__r.isEmpty()){
                    for(Mass_Mailing_Result__c mailResult:accObj.Mass_Mailing_Results__r){
                        if(mailResult.Batch_Name__c==uniqueBatchName && (mailResult.Status_Code__c==202 || mailResult.Status_Code__c==250)){
                            mailAlreadySent = true;
                        }
                    }
                }else{
                    mailAlreadySent = false;
                }
                //If mail is not sent add in list of accounts to send emails.
                if(!mailAlreadySent){
                    finalAccountList.add(accObj);
                }
            }

            if(!finalAccountList.isEmpty()){
                for (Account accObj : finalAccountList) {
                    String uniqueUrl = dynamicCommunityURL +  accObj.id;
                    Boolean isAnnualReportPast = false;
                    Boolean isAnnualReportDue = false;
                    Boolean isAnnualReportDueToday = false;
                    
                    String[] toAddress = new List<String>();

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
                        SendGridv3 sendgrid = new SendGridv3();
                        SendGridv3.SendGridResponse response = sendgrid.validate(accObj.Business_Email_Address__c);
                        System.debug('Code: '+response.code+'Reponse: '+response.message);
                        Object resObj = JSON.deserializeUntyped(response.message);
                        Map<String, Object> resMap = (Map<String, Object>) resObj;
                        Map<String, Object> resMapResult = (Map<String, Object>) resMap.get('result');
                        String verdict = String.valueOf(resMapResult.get('verdict'));
                        System.debug('verdict222*****:'+String.valueOf(verdict));
                        if(verdict=='Invalid'){
                            accObj.Invalid_Email_on_Account_Contact__c=true;
                            updateAccounts.add(accObj);
                        } else {
                            toAddress.add(accObj.Business_Email_Address__c);
                        }
                    }
                    if (!accObj.AccountContactRelations.isEmpty()) {
                        for (AccountContactRelation acrObj : accObj.AccountContactRelations) {
                            if (acrObj.Contact.Due_date_reminders_email_notification__c && acrObj.Contact.Email != NULL && !toAddress.contains(acrObj.Contact.Email)) {
                                SendGridv3 sendgrid = new SendGridv3();
                                SendGridv3.SendGridResponse response = sendgrid.validate(acrObj.Contact.Email);
                                System.debug('Code: '+response.code+'Reponse: '+response.message);
                                Object resObj = JSON.deserializeUntyped(response.message);
                                Map<String, Object> resMap = (Map<String, Object>) resObj;
                                Map<String, Object> resMapResult = (Map<String, Object>) resMap.get('result');
                                String verdict = String.valueOf(resMapResult.get('verdict'));
                                if(verdict=='Invalid'){
                                    contactIds.add(acrObj.ContactId);
                                } else {
                                    toAddress.add(acrObj.Contact.Email);
                                }
                            }
                        }
                    }

                    Email[] messages = new List<Email>();
                    if(!toAddress.isEmpty()){
                        if (isAnnualReportDueToday) {
                            messages.add(getEmail(accObj, owa, etNameToEt.get(Label.Annual_report_due_today),toAddress,dynamicCommunityURL));
                        } else if (isAnnualReportDue) {
                            messages.add(getEmail(accObj, owa, etNameToEt.get(Label.Annual_report_due2), toAddress,dynamicCommunityURL));
                            
                        } else if (isAnnualReportPast) {
                            messages.add(getEmail(accObj, owa, etNameToEt.get(Label.Account_Annual_report_past_due), toAddress,dynamicCommunityURL));
                            
                        }
        
                        for (Email sendgridEmail : messages) {
                            SendGridv3 sendgrid = new SendGridv3();
                            SendGridv3.SendGridResponse response = sendgrid.send(sendgridEmail);
							String errorMessage='';
                            if(response.message.contains('errors')){
                                Object resObj = JSON.deserializeUntyped(response.message);
                                Map<String, Object> resMap = (Map<String, Object>) resObj;
                                List<Object> resMapResult = (List<Object>) resMap.get('errors');
                                Map<String, Object> resMap22 = (Map<String, Object>)resMapResult[0];
                                errorMessage = 'Error: '+String.valueOf(resMap22.get('message'));
                            }
                            System.debug('Code: '+response.code+'Reponse: '+response.message);
                           
                            Mass_Mailing_Result__c res = new Mass_Mailing_Result__c();
                            res.Account__c = accObj.Id;
                            res.Batch_Name__c = uniqueBatchName;
                            res.Status_Code__c = response.code;
                            if(response.code==202 || response.code==250){
                                res.Response__c = 'Success';
                            }else{
                                res.Response__c = errorMessage;
                            }
                            mailResponses.add(res);
                        }
                    }
                    
                }
                
            }

            if(!contactIds.isEmpty()){
                List<Contact> invalidContacts = [select Id, Invalid_Email__c from Contact where Id IN :contactIds];
                if(!invalidContacts.isEmpty()){
                    for(Contact con: invalidContacts){
                        con.Invalid_Email__c = true;
                    }
                    update invalidContacts;
                }
            }            
            
            if(!updateAccounts.isEmpty()){
                update updateAccounts;
            }
            if(!mailResponses.isEmpty()){
                insert mailResponses;
            }

    }

    public void finish(Database.BatchableContext BC) {
        // Batch executed.  
    }

    // Method to create an Email.
    public static Email getEmail(Account accObj, OrgWideEmailAddress owa, EmailTemplate etObj, String[] toaddresses,String dynamicCommunityURL) {
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

        Email sendgridEmail = new Email();
        sendgridEmail.addTo(toaddresses);
        sendgridEmail.setFrom(owa.Address);
        sendgridEmail.setFromName(owa.DisplayName);
        sendgridEmail.setSubject(email.getSubject());
        sendgridEmail.setHtml(htmlBody);

        return sendgridEmail;
    }
}