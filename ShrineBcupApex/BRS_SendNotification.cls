/***********************************************************************************************
* DESCRIPTION: This class contains methods to send email functionality for ObtainCertificate
*
* @AUTHOR:  Pooja
* @DATE:    4/4/2021 
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Pooja                         4/4/2021                          Created the first version* Tamkanat
* Shreya                        21/10/21                            BRS-7224 | Nintex email handling - send emails after delay
*********************************************************************************************/
public with sharing class BRS_SendNotification {
    @InvocableMethod(Label = 'Send Other Request Email')
    public static void sendemail(List<Requests> results){
        List<id> ContentDocumentids = new List<id>();
        set<id> filingids=new set<id>();
        if(results != null && !results.isEmpty() && results.get(0).accId != null) {
            //1. Get certs under this temp history
            List<Certficate__c> listCertificates = [
                SELECT Id,Name, Certificate_Type__c,
                    Business__r.Name, Work_Order__r.Total_Hold_Amount__c
                FROM Certficate__c
                WHERE Business__c = :results.get(0).accId
                    AND Work_Order__c = :results.get(0).workOrderId 
                    WITH SECURITY_ENFORCED
            ];
			
            //2. get fee map
            Map<String, Decimal> certificateFeeMap = new Map<String, Decimal>();                          
            for(Master_Fee__c fee : BRS_Utility.getAllcerts(results.get(0).accId)){
                certificateFeeMap.put(fee.Filing_Type__c, fee.Amount__c);
            }
            
            //4. Email attachments
            List<Messaging.EmailFileAttachment> listAttachments = new List<Messaging.EmailFileAttachment>();
            for(Attachment doc: [
                SELECT Id, Name, Body,ParentId, ContentType 
                FROM Attachment 
                WHERE ParentId =: listCertificates 
                WITH SECURITY_ENFORCED
            ]) {
                filingids.add(doc.ParentId);
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType(doc.ContentType);
                attach.setFileName(doc.Name);
                attach.setInline(false);
                attach.Body = doc.Body;
                
                listAttachments.add(attach);
            }

            for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid IN :filingids AND (NOT ContentDocument.title LIKE :System.Label.Rejection_N_Comparable) AND (NOT ContentDocument.title LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED])
            {
                ContentDocumentids.add(CDLink.ContentDocumentid);
            }
            for ( ContentVersion cversion : [SELECT title,PathOnClient,versiondata FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids])
            {
               blob WOCFbody = cversion.versiondata;
               Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
               efa1.setFileName(cversion.title);
               efa1.setBody(WOCFbody);
               listAttachments.add(efa1);
            }
            //3. get Email template
            EmailTemplate emailTemplate = Wizard_Utlity.getEmailTemplate(
                System.Label.Certificate_of_Legal_Existence_Template, 
                UserInfo.getLanguage() //to-check in AutomatedProcess User context
            );

            //3.1. Update email template text
            String businessName;
            Decimal totalFilingFee;
            String body = System.Label.BRS_Obtian_cert_internal_table_header;
            
            for(Certficate__c cert :listCertificates) {
                String firstRow = System.Label.BRS_Obtian_cert_internal_table_row.replace(System.Label.BRS_Obtian_cert_internal_table_row_type, cert.Certificate_Type__c);
                firstRow = firstRow.replace(System.Label.BRS_Obtian_cert_internal_table_row_fee, '$'+
                    String.valueOf(
                        certificateFeeMap.containsKey(cert.Certificate_Type__c) ? certificateFeeMap.get(cert.Certificate_Type__c) : 0
                    )
                );
                body += firstRow;
                
                totalFilingFee = cert.Work_Order__r.Total_Hold_Amount__c;
                businessName = cert.Business__r.Name; //get business name
            }
            body += System.Label.BRS_Obtian_cert_internal_table_footer.replace(System.Label.BRS_Obtian_cert_internal_table_totalAmount, '$'+String.valueOf(totalFilingFee));
            
            //4. BRS-2798 | BRS-5657 | Email to be send to logged in user
            List<String> toAddresses = new List<String>();
            List<User> listUsers = [
                SELECT Contact_Email_Address__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                    AND Contact_Email_Address__c != null 
                    WITH SECURITY_ENFORCED
            ];
            if(!listUsers.isEmpty()) {
                toAddresses.add(listUsers.get(0).Contact_Email_Address__c);
            }

            //5. Apex Single email message
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, null);
            mail.setUseSignature(false);
            mail.setSubject(emailTemplate.Subject);//Set Subject
            
            String htmlValue = mail.getHtmlBody();
            htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_firstName, Userinfo.getName());
            htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_busines, 'for '+businessName);
            htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_cert, body);
            mail.setHtmlBody(htmlValue);//Set HTML Body
            mail.setFileAttachments(listAttachments);//Set File Attachment

            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            mail.setOrgWideEmailAddressId(owa.Id);
            
            //6. send emails
            if(!toAddresses.isEmpty()) {
                mail.setToAddresses(toAddresses); //Set To Email Address
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //Send Email
            }
        }
    }
   
    public with sharing class Requests {
        @InvocableVariable
        public Id accId;
        @InvocableVariable
        public Id workOrderId;
        @InvocableVariable //unused
        public Business_filing__c busFilObj;
        @InvocableVariable //unused
        public string totalCertFee;
        @InvocableVariable //unused
        public string businessType;
    }  
}