/*********************************************************************************************
     * NAME:  VerificationServiceCls
     * DESCRIPTION: Service class for Email Verification Process. 
     *
     * @AUTHOR: Devesh Murdiya
     * @DATE: 07/22/2020
     *
     *
     * MODIFICATION LOG:
     * DEVELOPER                         DATE                               DESCRIPTION
     * _____________________________________________________________________________________________
     * Devesh Murdiya                    07/22/2020                         Created the first version
     *
    *************************************************************************************************/
    public without sharing class EmailVerificationServiceCls {
        /********************************************************************************************
            METHOD NAME    : generateVerificationLink
            DESCRIPTION    : generate the verification link.
            RETURN TYPE    : ResponseWrapper
            PARAMETER      : Subscription__c
        ********************************************************************************************/
        public static ResponseWrapper generateVerificationLink(Subscription__c subscriptionObj) {
            ResponseWrapper response = new ResponseWrapper();
            if(subscriptionObj != null && subscriptionObj.Subscription_Status__c == 'Pending Verification'){
                String param = GenerateBaseEncodingCls.encodeURL(subscriptionObj.Id,subscriptionObj.Email__c,subscriptionObj.Signup_Date__c+Integer.valueOf(System.Label.Email_Verification_Expiration_Days));
                response.verificationStatus = 'Verification Requested';
                response.url = System.Label.Recovery_VerificationSite + 'language='+subscriptionObj.Language__c+'&id=' + param;
                sendEmail(response.url,subscriptionObj.Email__c,getEmailTemplate(subscriptionObj.Language__c));
                return response;
            }
            else{
                response.verificationStatus = 'Verification Not Required';
                return response;
            }
        }
        /********************************************************************************************
            METHOD NAME    : retriveURLParam
            DESCRIPTION    : retrieve the verification link and process it.
            RETURN TYPE    : ResponseWrapper
            PARAMETER      : String
        ********************************************************************************************/
        public static ResponseWrapper retriveURLParam(String verificationLink) {
            ResponseWrapper response = new ResponseWrapper();
            EmailVerificationParamWrapper wrapper;
            try{
                wrapper = GenerateBaseEncodingCls.decodeURL(verificationLink);
            }
            catch(Exception e){
                response.verificationStatus = 'Invalid Url';
            }
            if(wrapper != null){
                Subscription__c subscriptionObj = getSuscriptionRecord(wrapper.recordId,wrapper.emailAddress);
                if(subscriptionObj != null){
                    if(subscriptionObj.Subscription_Status__c != 'Active'){
                        if(wrapper.expirationDate >= System.today()){
                            response.verificationStatus = setSuscriptionRecord(subscriptionObj,'Active');
                            response.verificationStatus = 'Verification Success';
                        }
                        else if(wrapper.expirationDate < System.today()){
                            response.verificationStatus = setSuscriptionRecord(subscriptionObj,'InActive');
                            response.verificationStatus = 'Verification Expired';
                        }
                        else{
                            response.verificationStatus = 'Invalid Url';
                        }                   
                    }
                    else{
                        response.verificationStatus = 'Verification Already Done';
                        response.url = wrapper.emailAddress;                        
                    }
                }
                else{
                    response.verificationStatus = 'Invalid Url';
                }
            }
            else{
                response.verificationStatus = 'Invalid Url';
            }
            return response;
        }
        /********************************************************************************************
            METHOD NAME    : getSuscriptionRecord
            DESCRIPTION    : Method will retrieve the Subscription Record.
            RETURN TYPE    : Subscription__c
            PARAMETER      : String,String
        ********************************************************************************************/
        public static Subscription__c getSuscriptionRecord(String recordId, String emailAddress) {
            String query = NotificationServiceCls.setQuery('Subscription__c');
            Subscription__c subscriptionObj;
            if(recordId != null){
                query = query+' WHERE Email__c =\'' + emailAddress + '\' AND Id =\''+ recordId + '\' Limit 1';
            }
            else{
                query = query+' WHERE Email__c =\'' + emailAddress + '\' Limit 1';
            }
            try{
                subscriptionObj = Database.query(query);
            }
            catch(QueryException qe){
                qe.getMessage();
            }
            return subscriptionObj;
        }
        /********************************************************************************************
            METHOD NAME    : setSuscriptionRecord
            DESCRIPTION    : Method will retrieve the Subscription Record.
            RETURN TYPE    : String
            PARAMETER      : Subscription__c,String
        ********************************************************************************************/
        public static String setSuscriptionRecord(Subscription__c subscriptionObj, String status) {
            subscriptionObj.Subscription_Status__c = status;
            if(subscriptionObj.Subscription_Status__c == 'Active'){
                subscriptionObj.Email_Verified__c = true;
            }    
            return NotificationServiceCls.updateRecord(new List<Subscription__c>{subscriptionObj});
        }
        /********************************************************************************************
            DESCRIPTION    : Wrapper class for Response capturing.
        ********************************************************************************************/   
        public class ResponseWrapper{
            public String verificationStatus;
            public String url;
        }
        /********************************************************************************************
            METHOD NAME    : getEmailTemplate
            DESCRIPTION    : Method will retrieve the Email Template.
            RETURN TYPE    : String
            PARAMETER      : String
        ********************************************************************************************/
        public static EmailTemplate getEmailTemplate(String languageCode) {
            if(languageCode == 'es'){
                return [ select Id, Subject, HtmlValue, Body from EmailTemplate where developername ='Notification_Sign_up_Verification_Email_Spanish' limit 1 ];
            }
            else{
                return [ select Id, Subject, HtmlValue, Body from EmailTemplate where developername ='Notification_Sign_up_Verification_Email' limit 1 ];
            }
        }
        /********************************************************************************************
            METHOD NAME    : sendEmail
            DESCRIPTION    : Method will send the custim email.
            RETURN TYPE    : void
            PARAMETER      : String,String,EmailTemplate
        ********************************************************************************************/
        public static void sendEmail(String url, string emailId, EmailTemplate emailTemplate) {
            String subject = emailTemplate.Subject;
            subject = subject.replace('{!$Label.Email_Verification_Header}', Label.Email_Verification_Header);
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!$Label.Email_Verification_Link}',url);
            
            String plainBody = emailTemplate.Body;
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
            email.setOrgWideEmailAddressId(System.Label.Email_Verification_Sender);
            email.setToAddresses(new list<String>{emailId});
            email.setSaveAsActivity(true);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            Messaging.sendEmail(new Messaging.SingleEmailmessage[]{email});
      }
    }