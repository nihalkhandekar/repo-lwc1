/*********************************************************************************************
* NAME:  SEP_ContactDetailTriggerHelper
* DESCRIPTION: SEP Contact Detail trigger Helper class
*
* @AUTHOR:   Sandeep Joshi  
* @DATE: 09/03/2021
**
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*  Sandeep Joshi              09/03/2021                         Created the first version
*********************************************************************************************/
public without sharing class SEP_ContactDetailTriggerHelper {

    public static final String sSeverity = 'Medium';


    /********************************************************************************************
        METHOD NAME    : sendVerificationMessages
        DESCRIPTION    : method used to send Verification message to alternate email/phone      
        PARAMETER      : list of SEP_Contact_Detail__c
    ********************************************************************************************/
  
    public static void sendVerificationMessages(List<SEP_Contact_Detail__c> newTriggerList){
        try{
            List<SEP_Contact_Detail__c> lstOfRecordsHavingAlternateEmails = new List<SEP_Contact_Detail__c>();
            for(SEP_Contact_Detail__c objRec : newTriggerList){
                if(objRec.Email_Address__c != null && objRec.IsPrimary__c != true){
                    lstOfRecordsHavingAlternateEmails.add(objRec);
                   // SendVerificationEmail(objRec.Id, objRec.Email_Address__c);
                }else if(objRec.Phone_number__c != null){
                    SendVerificationSMS(objRec.Phone_number__c, objRec.Id); 
                }
            }
            
            if(lstOfRecordsHavingAlternateEmails.size() > 0){
                SendVerificationEmail(null, null,lstOfRecordsHavingAlternateEmails);
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
            SEP_Utility.SEPExceptionHandler('SEP_ContactDetailTriggerHelper','sendVerificationMessages',null,null,sSeverity,e,null);
           
        }
    }

    /********************************************************************************************
        METHOD NAME    : SendVerificationSMS
        DESCRIPTION    : method used to send Verification SMS to alternate phone        
        PARAMETER      : String of phone number and Record id
    ********************************************************************************************/

    @future(callout=true)
    private static void SendVerificationSMS(String strPhoneNumber, String strRecordId) {
        Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
        String account_SID = accountInfo.API_Key__c;
        String SMSMessageBody;
        String strLink;
        String strApiName = 'IsVerified__c';
        try {
            string value=System.label.SEP_EncryptionKey;
            Blob key = EncodingUtil.base64Decode(value);
            Blob recordId = Blob.valueOf(strRecordId);
            Blob encryptedRecordId = Crypto.encryptWithManagedIV('AES128', key, recordId);
            String strEncryptedRecordId = EncodingUtil.base64Encode(encryptedRecordId);
            SEP_Contact_Detail__c objContactRec=[SELECT id, SEP_Exclusion_Consent__r.First_Name__c, SEP_Exclusion_Consent__r.Last_Name__c, Language_Preference__c  FROM SEP_Contact_Detail__c WHERE id =:strRecordId ] ;
            Map<String, SEP_SMS_Verification_Text__mdt> mapSMSTextContent = new Map<String, SEP_SMS_Verification_Text__mdt>();
            String sLanguageKey = (objContactRec.Language_Preference__c == 'E') ? 'English' : 'Spanish';
            for(SEP_SMS_Verification_Text__mdt sepSMSTextContent :[Select MasterLabel,Value__c,Language__c,DeveloperName From SEP_SMS_Verification_Text__mdt Where Language__c = :sLanguageKey]) {
                mapSMSTextContent.put(sepSMSTextContent.MasterLabel, sepSMSTextContent);
            }
            Date todaysDate = System.today();
            Blob todayDate = Blob.valueOf(String.valueof(todaysDate));
            Blob encryptedDate = Crypto.encryptWithManagedIV('AES128', key, todayDate);
            String strEncryptedDate = EncodingUtil.base64Encode(encryptedDate);
            
            Blob fieldApi = Blob.valueOf(strApiName);
            Blob encryptedFieldApi = Crypto.encryptWithManagedIV('AES128', key, fieldApi);
            String strEncryptedFieldApi = EncodingUtil.base64Encode(encryptedFieldApi);
            
            Network lstNetwork = [SELECT Id,Name,UrlPathPrefix FROM Network WHERE Name = 'Self Exclusion Portal' LIMIT 1];
            string strCommunityURL=Network.getLoginUrl(lstNetwork.Id);
            strCommunityURL = strCommunityURL.substring(0,strCommunityURL.length()-5);
            system.debug(strCommunityURL);
            strlink=strCommunityURL+'verification?RecordId='+strEncryptedRecordId+'&Date='+strEncryptedDate+'&Api='+strEncryptedFieldApi;
            //SMSMessageBody = System.label.Email_Verification_Hello_Content+' '+objContactRec.SEP_Exclusion_Consent__r.First_Name__c+ ' '+objContactRec.SEP_Exclusion_Consent__r.Last_Name__c +', '+'\n'+System.label.SEP_SMSLinkVerificationText1+strlink+'\n'+System.label.SEP_SMSLinkVerificationText2+'\n'+System.label.SEP_SMSLinkVerificationText3;
            String sSeparator = (objContactRec.Language_Preference__c == 'E') ? ', ' : ': ';
            SMSMessageBody = mapSMSTextContent.get('SMSBodyHello').Value__c + ' ' + objContactRec.SEP_Exclusion_Consent__r.First_Name__c+ ' '+objContactRec.SEP_Exclusion_Consent__r.Last_Name__c  + sSeparator + '\n' + mapSMSTextContent.get('SMSBodyText1').Value__c + strlink + '\n' + mapSMSTextContent.get('SMSBodyText2').Value__c + '\n' + mapSMSTextContent.get('SMSBodyText3').Value__c;
            BOSTwilioSMSService.WrapperResult resultWrap = BOSTwilioSMSService.sendSMS(account_SID,strPhoneNumber, SMSMessageBody);

            
        } catch (Exception e) {
            System.debug(e.getMessage());
            SEP_Utility.SEPExceptionHandler('SEP_ContactDetailTriggerHelper','SendVerificationSMS',null,null,sSeverity,e,null);
           
        }
    }

      /********************************************************************************************
        METHOD NAME    : SendVerificationEmail
        DESCRIPTION    : method used to send Verification Email to alternate Email      
        PARAMETER      : String of phone number and Record id
    ********************************************************************************************/
    public static void SendVerificationEmail(String strRecordId, String strToAddress ,List<SEP_Contact_Detail__c> lstofRecords){
     
        Map<String,SEP_Contact_Detail__c> MapOfIdAndRecords = new Map<String,SEP_Contact_Detail__c>();

        List<String> lstContactRecordIds = new List<String>();
        for( SEP_Contact_Detail__c objContactRecord: lstofRecords){
            lstContactRecordIds.add(objContactRecord.id);
        }

        List<SEP_Contact_Detail__c> lstofExistingContactRecords = new List<SEP_Contact_Detail__c>();
        lstofExistingContactRecords = [SELECT id,SEP_Exclusion_Consent__r.First_Name__c,SEP_Exclusion_Consent__r.Last_Name__c,SEP_Exclusion_Consent__r.Language_Preference__c  FROM SEP_Contact_Detail__c where id in:lstContactRecordIds ];
        
        for( SEP_Contact_Detail__c objConDetails: lstofExistingContactRecords){
            MapOfIdAndRecords.put(objConDetails.id,objConDetails);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(SEP_Contact_Detail__c ObjContactDetailsRecords : lstofRecords)
        {
            List<string> toAddress = new List<string>();
            toAddress.add(ObjContactDetailsRecords.Email_Address__c);
            String strFieldApi='IsVerified__c';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(toAddress);
            message.plainTextBody = 'Verify Your account';
            string value= System.label.SEP_EncryptionKey;
            //string value='1234567890654321';
            // SEP_Contact_Detail__c objContactRec = [SELECT id,SEP_Exclusion_Consent__r.First_Name__c,SEP_Exclusion_Consent__r.Last_Name__c,SEP_Exclusion_Consent__r.Language_Preference__c  FROM SEP_Contact_Detail__c WHERE id =: ObjContactDetailsRecords.id ] ;
            SEP_Contact_Detail__c objContactRec = MapOfIdAndRecords.get(ObjContactDetailsRecords.id);
            String sLanguageKey = (objContactRec.SEP_Exclusion_Consent__r.Language_Preference__c == 'E') ? 'English' : 'Spanish';
            Map<String,SEP_Alternate_Email_Text__mdt> sepTextContentMap = new Map<String,SEP_Alternate_Email_Text__mdt>();
            for(SEP_Alternate_Email_Text__mdt sepTextContent : [Select MasterLabel,Value__c,Language__c,DeveloperName From SEP_Alternate_Email_Text__mdt Where Language__c = :sLanguageKey]) {
                sepTextContentMap.put(sepTextContent.MasterLabel, sepTextContent);
            }
            message.setSubject(sepTextContentMap.get('EmailSubject').Value__c);
            Blob key = EncodingUtil.base64Decode(value);
            Blob recordId = Blob.valueOf(ObjContactDetailsRecords.id);
            Blob encryptedRecordId = Crypto.encryptWithManagedIV('AES128', key, recordId);
            String strEncryptedRecordId = EncodingUtil.base64Encode(encryptedRecordId);
            Date todaysDate = System.today();
            Blob todayDate = Blob.valueOf(String.valueof(todaysDate));
            Blob encryptedDate = Crypto.encryptWithManagedIV('AES128', key, todayDate);
            String strEncryptedDate = EncodingUtil.base64Encode(encryptedDate);
            
            Blob fieldApi = Blob.valueOf(strFieldApi);
            Blob encryptedFieldApi = Crypto.encryptWithManagedIV('AES128', key, fieldApi);
            String strEncryptedFieldApi = EncodingUtil.base64Encode(encryptedFieldApi);
            //String link='https://sepdev001-service-ct.cs32.force.com/SEPortal/s/sepemailverification?RecordId='+strEncryptedRecordId+'&Date='+strEncryptedDate+'&Api='+strEncryptedFieldApi;
            Network lstNetwork = [SELECT Id,Name,UrlPathPrefix FROM Network WHERE Name = 'Self Exclusion Portal' LIMIT 1];
            string strCommunityURL=Network.getLoginUrl(lstNetwork.Id);
            strCommunityURL = strCommunityURL.substring(0,strCommunityURL.length()-5);
            system.debug(strCommunityURL);
            String link=strCommunityURL+'verification?RecordId='+strEncryptedRecordId+'&Date='+strEncryptedDate+'&Api='+strEncryptedFieldApi;
    
            string strFinalLink= '<a href='+link+'>'+sepTextContentMap.get('EmailVerificationLinkText').Value__c+'</a>';
            String htmlBody = sepTextContentMap.get('EmailHello').Value__c +' '+objContactRec.SEP_Exclusion_Consent__r.First_Name__c+ ' '+objContactRec.SEP_Exclusion_Consent__r.Last_Name__c+', <br/><br/>';
            htmlBody = htmlBody + sepTextContentMap.get('EmailBody').Value__c +' '+strFinalLink;
            htmlBody = htmlBody+'<br/>' + sepTextContentMap.get('EmailExpirationText').Value__c;
            htmlBody = htmlBody+'<br/><br/>'+ sepTextContentMap.get('EmailThankYou').Value__c;
            htmlBody = htmlBody+'<br/>'+ sepTextContentMap.get('EmailSignature').Value__c;
            message.htmlbody = htmlBody;
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :System.Label.SEPOrgWideEmailAddress];
            if(owea!=null && owea.size()>0){
                 message.setOrgWideEmailAddressId(owea[0].id); 
            }  
            allmsg.add(message);
        }

        
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
            System.debug('Results:::: '+results);
            Messaging.SendEmailResult er =(Messaging.SendEmailResult) JSON.deserialize('{}', Messaging.SendEmailResult.class);
            System.debug('er:: ' +er);
            if (results[0].success) 
            {
                System.debug('The email was sent successfully');
            } else {
                try{

                }catch (Exception e) {
                SEP_Utility.SEPExceptionHandler('SEP_ContactDetailTriggerHelper','SendVerificationEmail',null,null,sSeverity,e,results[0].errors[0].message);
                }
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
            
        } catch (Exception e) {
            SEP_Utility.SEPExceptionHandler('SEP_ContactDetailTriggerHelper','SendVerificationEmail',null,null,sSeverity,e,null);

        }
    }
   
}