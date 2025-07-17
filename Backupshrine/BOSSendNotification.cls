/*********************************************************************************************
 * NAME:  BOSSendNotification
 * DESCRIPTION: Batch class to send the actionItems(email/SMS). 
 *
 * @AUTHOR: Pooja Dubey
 * @DATE: 09/16/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Pooja/Tamkanat                   09/16/2020                         Created the first version
 *
*************************************************************************************************/
global with sharing class BOSSendNotification implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {

    //Static Variables
    global String query;
    global String account_SID;
    global List<Action_Item__c> actionItemList = new List<Action_Item__c>();
    global List<Action_Item__c> actionItemSentList = new List<Action_Item__c>();
    global Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
    global List<Checklist_language_mapping__mdt> textContentList = new List<Checklist_language_mapping__mdt>();
    global String blankSpace=' ';
    global String className='BOSSendNotification';
    global String objName='Action_Item__c';
    global String severity='High';
    global Integer numberOfDays = Integer.valueOf(System.Label.Notification_LLC_End_Month);
    /********************************************************************************************
        METHOD NAME    : BOSSendactionItem
        DESCRIPTION    : Batch Constructor (Get the actionItem records for batch processing)
        RETURN TYPE    : void
        PARAMETER      : void
    ********************************************************************************************/
    global BOSSendNotification(String accountSID){
        account_SID = accountSID;
        String dateValue = String.valueOf(System.today()); 
        // query = 'SELECT Name,Contact__c,Credential_Contact_Name__c,Cred_Type_Real_Time__c,Status__c,Action_Item_Name__c,Account__c, Account__r.Name,Account__r.Status__c,Account__r.Business_Sub_Type__c, Credential__c,Credential__r.Name,Credential_Type__c,Credential_Business_Individual_Name__c, Description__c, Due_Date__c,Link_URL__c,Notification_Status__c,Agency__c FROM Action_Item__c';
        query = 'SELECT Name,Contact__c,Credential_Contact_Name__c,Cred_Type_Real_Time__c,Status__c,Action_Item_Name__c,Account__c, Account__r.Name,Account__r.Status__c,Account__r.Business_Sub_Type__c, Credential__c,Credential__r.Name,Credential_Type__c,Credential_Business_Individual_Name__c, Description__c, Due_Date__c,Link_URL__c,Notification_Status__c,Agency__c FROM Action_Item__c WHERE Status__c !=\'Completed\' AND Notification_Status__c !=\'Sent\' AND Due_Date__c>='+dateValue;
        
        List<EmailTemplate> batchEmailList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name='Batch Email'];
        for(EmailTemplate emailtemp: batchEmailList){
            emailTemplateMap.put(emailtemp.DeveloperName, emailtemp);
        }
        
        textContentList = [Select MasterLabel,value__c,language__c,DeveloperName From Checklist_language_mapping__mdt where MasterLabel=:System.Label.SMS_Content Order By DeveloperName];
    }
    
    /********************************************************************************************
        METHOD NAME    : start
        DESCRIPTION    : Batch start Method
        RETURN TYPE    : Database.QueryLocator
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /** collect the batches of records or objects to be passed to execute **/
        return Database.getQueryLocator(query);
    }
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext, List<Action_Item__c>
    ********************************************************************************************/
    public void execute(Database.BatchableContext BC, List<Action_Item__c> actionItemScope) {
        Map<Id, List<Id>> credentailAccountIdMap = new Map<Id, List<Id>>();
        Set<Id> credentialIds = new Set<Id>();
        List<Id> contactIDList = new List<Id>();
        Map<Id,String> contactLaguageMap = new Map<Id,String>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address =: System.label.CT_BOS limit 1];
        for(Action_Item__c actionItem : actionItemScope){
            if(actionItem.Account__c!=null && actionItem.Contact__c != Null){
                contactIDList.add(actionItem.Contact__c);
            }
            if(actionItem.Credential__c!=null){
                credentialIds.add(actionItem.Credential__c);
            }
        }
        
        /**  get Language of User from Contact**/
        List<Contact> contactList;
        if(contactIDList.size()>0){
            contactList = [select Id,Name,Email,Due_date_reminders_email_notification__c,Due_date_reminders_sms_notification__c,Phone,
                           (select Id, LanguageLocaleKey from Users) from Contact where Id IN:contactIDList];
            for(Contact con: contactList){
                if(con.Users.size()>0){
                    contactLaguageMap.put(con.Id,con.Users[0].LanguageLocaleKey);
                }
            }
        }
        
        /** Send notification **/
        try{
			List<Contact_Credential_Relationship__c> ccrList = [SELECT Contact__c,Contact__r.Name,Contact__r.Id,Contact__r.Phone,Contact__r.Due_date_reminders_email_notification__c,Contact__r.Due_date_reminders_sms_notification__c,Contact__r.Email, Credential__c FROM Contact_Credential_Relationship__c 
                                                                    WHERE Credential__c IN: credentialIds];
            List<Account_Credential_Relationship__c> acrList = [SELECT Account__c,Contact__c,Contact__r.Name,Contact__r.Id,Contact__r.Phone,Contact__r.Due_date_reminders_email_notification__c,Contact__r.Due_date_reminders_sms_notification__c,Contact__r.Email,Credential__c FROM Account_Credential_Relationship__c 
                                                                WHERE Credential__c IN: credentialIds];
            for(Action_Item__c actionItem : actionItemScope){
                EmailTemplate emailTemplate;
                EmailTemplate spanishTemplate;
                EmailTemplate englishTemplate;
                String SMSMessageBody;
                String SMSEnglish;
                String SMSSpanish;
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                /**If Account is present send the Annual Filing Report communication based on Business designation.**/
                if(actionItem.Account__c!=null && actionItem.Status__c == 'Open' && actionItem.Account__r.Status__c == System.Label.ACTIVE){
                    if(actionItem.Due_Date__c >= System.today() && actionItem.Due_Date__c <= System.today().addDays(numberOfDays)){
                        email.setWhatId(actionItem.Id);
                        spanishTemplate = emailTemplateMap.get(System.Label.BatchEmail_ARF_LLC_Spanish);
                        englishTemplate = emailTemplateMap.get(System.Label.BatchEmail_ARF_LLC);
                        for(Checklist_language_mapping__mdt content: textContentList){
                            if(content.language__c == System.Label.LanguageCode_English){
                                if(content.DeveloperName==System.Label.SMS_Notif_1){
                                    SMSEnglish = content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_2){
                                    SMSEnglish+=blankSpace+actionItem.Account__r.Name+content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_3){
                                    SMSEnglish+=blankSpace+actionItem.Due_Date__c.format()+content.value__c;
                                }
                            }
                            else if(content.language__c == System.Label.LanguageCode_Spanish){
                                if(content.DeveloperName==System.Label.SMS_Notif_1_es){
                                    SMSSpanish = content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_2_es){
                                    SMSSpanish+=blankSpace+actionItem.Account__r.Name+content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_3_es){
                                    SMSSpanish+=blankSpace+actionItem.Due_Date__c.format()+content.value__c;
                                }
                            }
                        }
                    }
                }
                
                /** If credential is present, send the credential action required communication 30 days prior to Due Date.**/
                if(actionItem.Credential__c!=null){
                    if(actionItem.Due_Date__c >= System.today() && actionItem.Due_Date__c <= System.today().addDays(numberOfDays)){
                        email.setWhatId(actionItem.Id);
                        spanishTemplate = emailTemplateMap.get(System.Label.BatchEmail_Credential_Spanish);
                        englishTemplate = emailTemplateMap.get(System.Label.BatchEmail_Credential);
                        for(Checklist_language_mapping__mdt content: textContentList){
                            if(content.language__c == System.Label.LanguageCode_English){
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_1){
                                    SMSEnglish = content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_2){
                                    SMSEnglish+=blankSpace+actionItem.Credential_Contact_Name__c+blankSpace+content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_3){
                                    SMSEnglish+=blankSpace+actionItem.Cred_Type_Real_Time__c+blankSpace+actionItem.Action_Item_Name__c+content.value__c;
                                }
                            }
                            else if(content.language__c == System.Label.LanguageCode_Spanish){
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_1_es){
                                    SMSSpanish = content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_2_es){
                                    SMSSpanish+=blankSpace+actionItem.Credential_Contact_Name__c+blankSpace+content.value__c;
                                }
                                if(content.DeveloperName==System.Label.SMS_Notif_Cred_3_es){
                                    SMSSpanish+=blankSpace+actionItem.Cred_Type_Real_Time__c+blankSpace+actionItem.Action_Item_Name__c+content.value__c;
                                }
                            }
                        }
                    }  
                }
                
                system.debug('SMSSpanish**: '+SMSSpanish);
                system.debug('SMSEnglish**: '+SMSEnglish);
                
                Set<Contact> contacts = new Set<Contact>();
                if(contactList != Null){
                    for(Contact con : contactList){
                        if(actionItem.Contact__c == con.Id){
                            contacts.add(con);
                        }
                	}
                }
                for(Account_Credential_Relationship__c acr: acrList){
                    if(actionItem.Credential__c == acr.Credential__c){
                        contacts.add(acr.Contact__r);
                    }
                }
                for(Contact_Credential_Relationship__c ccr: ccrList){
                    if(actionItem.Credential__c == ccr.Credential__c){
                        contacts.add(ccr.Contact__r);
                    }
                }
                if(contacts.size()>0){
					contacts.remove(null);
                    for(Contact con: contacts){
                        String userLanguage;
                        if(contactLaguageMap != Null && contactLaguageMap.containsKey(con.Id)){
                            userLanguage = contactLaguageMap.get(con.Id);
                        }
                        
                        if(con.Due_date_reminders_email_notification__c == true){
                            if(userLanguage == System.Label.LanguageCode_Spanish){
                                emailTemplate = spanishTemplate;
                            }else{
                                emailTemplate = englishTemplate;
                            }
                            string[] to = new string[] {con.Email};
                                email.setToAddresses(to);
                            email.setTargetObjectId(con.Id);
                        }
                        
                        /** Send SMS **/
                        if(account_SID != null && !String.isBlank(account_SID) && con.Due_date_reminders_sms_notification__c==true && con.Phone!= null){
                            if(userLanguage == System.Label.LanguageCode_Spanish){
                                SMSMessageBody = SMSSpanish;
                            }else{
                                SMSMessageBody = SMSEnglish;
                            }
                            system.debug('SMS on**'+ con.Phone + 'Message: '+SMSMessageBody);
                            if(SMSMessageBody!=null){
                                BOSTwilioSMSService.sendSMS(account_SID, con.Phone, SMSMessageBody);
                                actionItemSentList.add(actionItem);
                            }
                        } 
                    }
                }
                
                if(!owa.isEmpty()){
                    email.setOrgWideEmailAddressId(owa[0].id);
                }
                if(emailTemplate!=null){
                    email.setTemplateId(emailTemplate.Id);
                    if(email.getToAddresses()!=null){
                        messages.add(email);
                        actionItemSentList.add(actionItem);
                    }
                }
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'execute',objName,null,severity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : SchedulableContext
    ********************************************************************************************/
    global void execute(SchedulableContext sc) {
        Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
        account_SID = accountInfo.API_Key__c;
        Database.executeBatch(new BOSSendNotification(account_SID));
    }
    /********************************************************************************************
        METHOD NAME    : finish
        DESCRIPTION    : Batch finish method to update the notification status to sent for action items.
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        
        Set<Action_Item__c> uniqueActionItems = new Set<Action_Item__c>();
        List<Action_Item__c> updateList = new List<Action_Item__c>();
        uniqueActionItems.addAll(actionItemSentList);
        updateList.addAll(uniqueActionItems);
        for(Action_Item__c accItem: updateList) {
            accItem.Notification_Status__c=System.Label.Action_Item_Status_Sent;
        }
       try{
			if(!updateList.isEmpty())
            {
                update updateList;
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'finish',objName,null,severity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
 }