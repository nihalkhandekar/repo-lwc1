global without sharing class BRS_SendNotificationtoAgentBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    public static Final String className = 'BRS_SendNotificationtoAgentBatch';
    private List<Id> listRejectedFilings = new List<Id>();
    
    /********************************************************************************************
        METHOD NAME    : start
        DESCRIPTION    : Batch start Method
        RETURN TYPE    : Database.QueryLocator
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Status__c, Business_Type__c, Citizenship__c,'
                + 'Agent_Selection__c, Agent_Confirmation_Notification__c,Account__r.name,Agent_Email_Address__c,Agent_Id__c,Agent_Phone_Number_Formatted__c, Agent_Confirmation_Hours_Left__c,Type__c'
            + ' FROM Business_Filing__c'
            + ' WHERE Agent_Confirmation_Hours_Left__c != null'
            + ' AND Agent_Confirmation_Notification__c != null'
            + ' AND Status__c =\'Submitted - Agent acceptance pending\''
            + ' AND Agent_Id__c != null'
        );
    }
    
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext, List<Business_Filing__c>
    ********************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Business_Filing__c> busfiList) {
        List<Business_Filing__c> sendRemindersToList = new List<Business_Filing__c>();
        List<Business_Filing__c> updateStatusList = new List<Business_Filing__c>();
        try{
            for (Business_Filing__c busfi :busfiList) {
                Date agentConfirmationDate =  busfi.Agent_Confirmation_Notification__c.dateGMT();
                if(busfi.status__c == System.Label.Submitted_Agent_acceptance_pending 
                    && 
                    (
                        agentConfirmationDate.addDays(2) >=System.now().dateGMT() 
                        && busfi.Agent_Confirmation_Hours_Left__c  == 48
                    ) 
                    || 
                    (
                        agentConfirmationDate.addDays(3) >=System.now().dateGMT() 
                        && 
                        busfi.Agent_Confirmation_Hours_Left__c==24
                    )
                ) {
                    sendRemindersToList.add(busfi);
                } else if(busfi.status__c == System.Label.Submitted_Agent_acceptance_pending
                    && agentConfirmationDate.addDays(4) >= System.now().dateGMT()
                    && busfi.Agent_Confirmation_Hours_Left__c <=0
                ){
                    updateStatusList.add(busfi);
                }
            }
            callSendMessage(sendRemindersToList);
            sendEmail(sendRemindersToList);
            updateStatus(updateStatusList);
        } catch(Exception ex) {
            BOS_Utility.ExceptionHandler(className, null,null,null,null,ex,ex.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : finish
        DESCRIPTION    : Batch finish method to update the notification status to sent for action items.
        RETURN TYPE    : void
        PARAMETER      : Database.BatchableContext
    ********************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        //BRS-4262 | Create rejection notice to be emailed
        if(!listRejectedFilings.isEmpty()) {
            Database.executeBatch(new NintexBatchGeneration(listRejectedFilings, UCCFilingAcknowledgement.Operation.REJECTION));
        }
    }

    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : SchedulableContext
    ********************************************************************************************/
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BRS_SendNotificationtoAgentBatch(),200);
    }
    
    public void callSendMessage(List<Business_filing__c> filingList){
        try{
            for(Business_filing__c busFi : filingList){
                String encryptedAgentId = BRS_SendNotificationtoAgent.encrypt(busFi.Agent_Id__c);
                String encryptedFilingId = BRS_SendNotificationtoAgent.encrypt(busFi.Id);
                String encrytAccepted = BRS_SendNotificationtoAgent.encrypt(System.Label.Accepted);
                String encrytDeclined = BRS_SendNotificationtoAgent.encrypt(System.Label.Declined);
                String pageURL = System.Label.Current_Env_Community_URL+'?AgentId='+encryptedAgentId+'&FilingId='+encryptedFilingId;
                String acceptedURL = pageURL+'&Selection='+encrytAccepted;
                String declinedURL = pageURL+'&Selection='+encrytDeclined;
                
                
                String SMSMessageBody = busFi.Account__r.name + ' ' + System.Label.Accept_Appointment + ' ' +acceptedURL+'\n'+'\n' + System.Label.Decline_appointment+' ' +declinedURL;
                String phoneNumber = System.Label.US_Region_code+ busFi.Agent_Phone_Number_Formatted__c;
                Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
                String account_SID = accountInfo.API_Key__c;
                BOSTwilioSMSService.WrapperResult resultWrap = BOSTwilioSMSService.sendSMS(account_SID,phoneNumber, SMSMessageBody);
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, null,null,null,null,ex,ex.getMessage());
        }
        
    }
    public void sendEmail(List<Business_filing__c> filingList){
        try{
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplateRec =  [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName='BRS_Agent_Appointment_Reminder'];
            for(Business_filing__c busFi : filingList){
                Messaging.SingleEmailMessage email =  Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, busFi.Id);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                String htmlBody = email.getHtmlBody();
                
                string[] to = new string[] {busFi.Agent_Email_Address__c};
                    email.setToAddresses(to);
                
                
                if(owa!=null){
                    email.setOrgWideEmailAddressId(owa.Id);
                }
                email.setTemplateId(emailTemplateRec.Id);
                
                String encryptedAgentId;
                encryptedAgentId = BRS_SendNotificationtoAgent.encrypt(busFi.Agent_Id__c);
                
                
                String encryptedFilingId = BRS_SendNotificationtoAgent.encrypt(busFi.id);
                String encrytAccepted = BRS_SendNotificationtoAgent.encrypt(System.Label.Accepted);
                String encrytDeclined = BRS_SendNotificationtoAgent.encrypt(System.Label.Declined);
                String pageURL = System.label.Current_Env_Community_URL+'?AgentId='+encryptedAgentId+'&FilingId='+encryptedFilingId;
                String acceptedURL = pageURL+'&Selection='+encrytAccepted;
                String declinedURL = pageURL+'&Selection='+encrytDeclined;
                htmlBody = htmlBody.replace(System.Label.Accept,System.Label.URL_Prefix+acceptedURL+System.Label.Accept_Suffix);
                htmlBody = htmlBody.replace(System.Label.Decline,System.Label.URL_Prefix+declinedURL+System.Label.Decline_Suffix);
                email.setHtmlBody(htmlBody);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.setWhatId(busFi.id);
                email.setSaveAsActivity(false);
                system.debug('sending emails ' +busFi);
                if(busFi.Agent_Email_Address__c!=null && email.getToAddresses().size()>0){
                    lstMails.add(email);
                }
            } 
            if(!lstMails.isEmpty()){
                // Create log for number of records
                Batch_Job_Logs__c createLog = new Batch_Job_Logs__c ();
                createLog.Class_Name__c = className;
                createLog.Job_Operation__c = 'Send Notification';
                createLog.Job_Configuration_Name__c = className;
                createLog.Success_Record_Count__c = lstMails.size();
                createLog.Object_Name__c = 'Agent';
                lstAppErrorLogs.add(createLog);

                if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
                    Database.SaveResult[] resultLst = new List<Database.SaveResult>();
                    resultLst = Database.insert(lstAppErrorLogs,false);
                }

                Messaging.sendEmail(lstMails);
            }  
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, null,null,null,null,ex,ex.getMessage());
        }
    }
    
    /**
     * @update : BRS-4262 | Shreya 
     *  When agent rejects, and auto rejection - create rejection notice
     */
    public void updateStatus(List<Business_filing__c> filingList) {
        Map<Id, Business_filing__c> mapRejectedFilings = new Map<Id, Business_filing__c>();

        for(Business_filing__c busFi : filingList) {
            if(
                busFi.Status__c == System.Label.Submitted_Agent_acceptance_pending 
                && 
                (
                    busFi.Type__c == System.Label.Business_Formation_Label
                    || 
                    busFi.Type__c == System.Label.Business_Registration_Label
                ) 
                && 
                (
                    (
                        busFi.Citizenship__c  == System.Label.Domestic 
                        && 
                        (
                            busFi.Business_Type__c  == System.Label.Non_Stock 
                            || 
                            busFi.Business_Type__c  == System.Label.Stock 
                            || 
                            busFi.Business_Type__c  == System.Label.B_Corp 
                            || 
                            busFi.Business_Type__c  == System.Label.LLP
                        )
                    ) 
                    || 
                    busFi.Citizenship__c == System.Label.Foreign
                )
            ) {
                busFi.Status__c = System.Label.Submitted_Agency_review_pending;
                busFi.Agent_Selection__c = System.Label.Rejected_No_Reply; //BRS-3932
            }
            else if(
                busFi.Status__c == System.Label.Submitted_Agent_acceptance_pending 
                && 
                (
                    busFi.Type__c == System.Label.Annual_Report 
                    || 
                    busFi.Type__c == System.Label.First_Report 
                    || 
                    busFi.Type__c == System.Label.Label_Change_Agent 
                    || 
                    busFi.Type__c == System.Label.Business_Formation_Label
                )
                || 
                (
                    busFi.Citizenship__c == System.Label.Domestic 
                    &&
                    busFi.Business_Type__c == System.Label.LLC
                )
            ) {
                busFi.Status__c =  System.Label.Rejected; //BRS-4262 | Nintex
                busFi.Reason_for_Rejection__c =  System.Label.RejectionReasonAgentNoResponse;
                busFi.Agent_Selection__c =  System.Label.Rejected_No_Reply; //BRS-3932

                mapRejectedFilings.put(busFi.Id, busFi);
            }
        }
            
        if(!mapRejectedFilings.isEmpty()){
            Database.update(mapRejectedFilings.values(), false);
            this.listRejectedFilings = new List<Id>(mapRejectedFilings.keySet());
        }
    }
}