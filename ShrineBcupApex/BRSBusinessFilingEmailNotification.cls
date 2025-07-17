/*********************************************************************************************
* NAME:  BRSBusinessFilingEmailNotification
* DESCRIPTION: This class is used to send Email notifications to users.
*
* @AUTHOR: Rabbani
* @DATE: 03/06/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                         DESCRIPTION
* ----------------------------------------------------------------------------
* Rabbani                    	03/06/2021                       Created the first version
* Shreya                        28/10/2021                       BRS-7224 | Nintex files are generated as Attachments   
*********************************************************************************************/
public without sharing class BRSBusinessFilingEmailNotification {
    @InvocableMethod
    public static void sendBusinessFilingEmail(List<RequestsInfo> RequestsInfo) {
		if(!System.isBatch()) {
            Business_Filing__c businessFilingRec = RequestsInfo[0].businessFilingRec;
            //1. get email template
            String emailTemplateName = getEmailTemplate(businessFilingRec, RequestsInfo[0].isFromFlow);
            List<id> ContentDocumentids = new List<id>();
			Id BusinessFilingId= businessFilingRec.id;
            if(emailTemplateName != null) {
                //2. get attachments | BRS-8131 | to optimize query calls over large dataset
                String filingOutputName = UCCFileMerge.getFilingOutputName(businessFilingRec);
                Set<String> setFileNames = new Set<String> {
                    businessFilingRec.Sdoc_Filing_Number__c + ' - ' + System.Label.BRS_Acceptance_Notice + System.Label.PDF_Type_Extension,
                    System.Label.brs_RejectionNotice + System.Label.PDF_Type_Extension,
                    filingOutputName,
                    filingOutputName + System.Label.PDF_Type_Extension
                };
                
                List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
                for(Attachment attachment: [
                    SELECT Id, Name, Body, ContentType 
                    FROM Attachment 
                    WHERE ParentId =:businessFilingRec.Id 
                        AND Name IN :setFileNames WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate DESC
                ]) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(attachment.Name);
                    efa.setBody(attachment.body);
                    efa.setContentType(attachment.ContentType);
                    efa.setInline(false);

                    attachmentList.add(efa);
                }
                for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:BusinessFilingId and ContentDocument.Title IN :setFileNames WITH SECURITY_ENFORCED])
                {
                    ContentDocumentids.add(CDLink.ContentDocumentid);  
                }
                for ( ContentVersion cversion : [SELECT title,PathOnClient,versiondata FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids])
                {
                   blob WOCFbody = cversion.versiondata;
                   Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
                   efa1.setFileName(cversion.title);
                   efa1.setBody(WOCFbody);
                   attachmentList.add(efa1); 
                }
                //3. get email template
                EmailTemplate emailTemplateRec = [
                    SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                    FROM EmailTemplate
                    WHERE DeveloperName = :emailTemplateName
                ];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                //3.1. for agent
				List<Agent__c> agentDetails = new List<Agent__c>();
                if(emailTemplateName == System.Label.Business_Notice_of_Agent_Resignation && businessFilingRec.Account__c != null){
                    agentDetails = [
                        SELECT Id,Name__c,Business_ID__c 
                        FROM Agent__c
                        WHERE Business_ID__c =:businessFilingRec.Account__c WITH SECURITY_ENFORCED 
                    ];
                }

                if(emailTemplateName == System.Label.Business_Notice_of_Agent_Resignation && !agentDetails.isEmpty()) {
                    email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, agentDetails[0].Id);
                } else {
                    email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, businessFilingRec.Id);
                }

                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
            
                //4. Sender email
                List<string> to = new List<string>();
                Business_Filing__c businessemail = [
                    SELECT id, Work_Order__r.Customer__c, Work_Order__r.Customer__r.Email,
                        Account__r.Business_Email_Address__c 
                    FROM Business_Filing__c 
                    WHERE Id=: businessFilingRec.Id WITH SECURITY_ENFORCED 
                ];
                
                if(System.Label.brs_FilingOnline.equalsIgnoreCase(businessFilingRec.Source__c) 
                    && String.isNotBlank(businessemail.Account__r.Business_Email_Address__c)
                ) {
                    to.add(businessemail.Account__r.Business_Email_Address__c);
                }
                
                if(String.isNotBlank(businessemail.Work_Order__r.Customer__r.Email)) {
                    to.add(businessemail.Work_Order__r.Customer__r.Email);
                }

                //5. Set email details
                OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
                email.setOrgWideEmailAddressId(owa.Id);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                
                email.setTemplateId(emailTemplateRec.Id);
                email.setSaveAsActivity(false);
                
                //5.1. Set attachments
                if(System.Label.Label_Pending_Filing_1.equalsIgnoreCase(businessFilingRec.Status__c) || System.Label.Approved.equalsIgnoreCase(businessFilingRec.Status__c) || System.Label.BRS_FilingStatus_Rejected.equalsIgnoreCase(businessFilingRec.Status__c)) {
					if(!attachmentList.isEmpty()) {
						email.setFileAttachments(attachmentList);
					}
				}

                if(!to.isEmpty()) {
                    email.setToAddresses(to);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
            }
        }    
    }

    private static String getEmailTemplate(Business_Filing__c filing, Boolean isFromFlow) {
        String emailTemplateName;
        
        //1. Approved - agent resignation
        if(System.Label.Approved.equalsIgnoreCase(filing.Status__c) && !System.Label.Agent_Resignation_Label.equalsIgnoreCase(filing.Type__c)) {
            Set<String> setBusinessCorps = new Set<String> {
                System.Label.Stock,
                System.Label.Non_Stock,
                System.Label.B_Corp
            };

            //1.1 | BFR + corp
            emailTemplateName = System.Label.Business_Formation_Comparable.equalsIgnoreCase(filing.Type__c) && setBusinessCorps.contains(filing.Business_Type__c)
                ? System.Label.Business_Registration_Acceptance_Email_with_link
                : System.Label.Business_Registration_Acceptance_Email;
        } 

        //2. Approved & agent resignation
        else if(System.Label.Approved.equalsIgnoreCase(filing.Status__c) && System.Label.Agent_Resignation_Label.equalsIgnoreCase(filing.Type__c)) {
            emailTemplateName = System.Label.Business_Notice_of_Agent_Resignation;
        }

        //3. Pending Filing (~Approved - doc)
        else if(System.Label.Label_Pending_Filing.equalsIgnoreCase(filing.Status__c)) {
            emailTemplateName = System.Label.BRS_Pending_Pending_Filing_Email;
        } 
        
        //4. Agent acceptance pending
        else if(System.Label.BRS_Submitted_Agent_acceptance_pending.equalsIgnoreCase(filing.Status__c)  ) {
            emailTemplateName = System.Label.Business_Registration_Submitted_Agent_acceptance_pending;
        }
        
        else if(isFromFlow != null && !isFromFlow) {
            //5. Rejection    
            if(System.Label.BRS_FilingStatus_Rejected.equalsIgnoreCase(filing.Status__c)) {
                emailTemplateName = System.Label.Business_Registration_Rejectance_Email;
            } 
            
            //6. Agency review pending
            else if(System.Label.BRS_FilingStatus_Pending.equalsIgnoreCase(filing.Status__c)
            || filing.Status__c ==  'Submitted - Intake pending') {
                emailTemplateName = System.Label.Business_Registration_Submitted_Agency_review_pending;
            }
        }

        return emailTemplateName;
    }

    public static List<Messaging.EmailFileAttachment> getEmailAttachments(Id filingId, String filingOutputName) {
        List<Messaging.EmailFileAttachment> listEmailAttachments = new List<Messaging.EmailFileAttachment>();
        Set<String> setFileNames = new Set<String> {
            filingOutputName,
            filingOutputName + System.Label.PDF_Type_Extension
        };
        List<id> ContentDocumentids = new List<id>();
        for(Attachment attachment: [
            SELECT Id, Name, Body, ContentType 
            FROM Attachment 
            WHERE ParentId = :filingId 
                AND 
                (
                    Name LIKE :System.Label.Acceptance_N_Comparable 
                    OR 
                    Name LIKE :System.Label.Rejection_N_Comparable 
                    OR 
                    Name = :(filingOutputName + System.Label.PDF_Type_Extension)
                ) WITH SECURITY_ENFORCED 
            ORDER BY CreatedDate DESC
        ]) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attachment.Name);
            efa.setBody(attachment.body);
            efa.setContentType(attachment.ContentType);
            efa.setInline(false);
            
            listEmailAttachments.add(efa);
        }
        for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:filingId and ContentDocument.Title IN :setFileNames WITH SECURITY_ENFORCED limit 1])
        {
             ContentDocumentids.add(CDLink.ContentDocumentid);  
        }
        for ( ContentVersion cversion : [SELECT title,PathOnClient,versiondata FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids])
        {
             blob WOCFbody = cversion.versiondata;
             Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
             efa1.setFileName(cversion.title);
             efa1.setBody(WOCFbody);
             listEmailAttachments.add(efa1); 
        }

        return listEmailAttachments;
    }

    public without sharing class RequestsInfo {
        @InvocableVariable
        public Business_Filing__c businessFilingRec;
        @InvocableVariable
        public Boolean isFromFlow;
    } 
}