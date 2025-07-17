/*********************************************************************************************
* NAME:  BRS_UCC_EmailNotification
* DESCRIPTION: This class is used to send Email notifications to users.
*
* @AUTHOR: Tamkanat
* @DATE: 02/24/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Tamkanat                    	02/24/2020                       Created the first version
* Shreya                        14/10/2021                       BRS-7504 | Nintex online flows
*********************************************************************************************/
public with sharing class BRS_UCC_EmailNotification {
    /*
    * Description:      Invoable method called from process builder to check the status of filing record and send appropriate email with attachment.
    * Param 1:          Filing record.
    *
    * Author Info:
    *******************************************************************************
    * Tamkanat Fatima                02/24/2020              First Version.
    * @update : Shreya | BRS-7223 | Nintex
    */
    @InvocableMethod(label = 'Send UCC Filing Email')
    public static void sendUCCEmail(List<Requests> Requests) {
        UCC_Filing__c filing = Requests[0].filingRec;
        
        //1. Get email template
        String emailTemplateName = getEmailTemplate(filing);

        if(String.isNotBlank(emailTemplateName)) {                
            //2. Add attachments if approved/rejected
            List<Messaging.EmailFileAttachment> listEmailAttachments;
            
            if(System.Label.Approved.equalsIgnoreCase(filing.Status__c) || System.Label.BRS_FilingStatus_Rejected.equalsIgnoreCase(filing.Status__c)) { //include documents
                String filingOutputName = UCCFileMerge.getFilingOutputName(filing);                     
                listEmailAttachments = BRSBusinessFilingEmailNotification.getEmailAttachments(filing.Id, filingOutputName); 
            }

            //4. Generate email
            sendEmail(emailTemplateName, filing, listEmailAttachments);
        }
    }

    private static void sendEmail(String emailTemplateName, UCC_Filing__c filing, List<Messaging.EmailFileAttachment> listEmailAttachments) {
        //4.1 Get email template
        EmailTemplate emailTemplateRec = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
        ];
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, filing.Id);
        email.setTemplateId(emailTemplateRec.Id);
        email.setSaveAsActivity(false);

        Work_Order__c workOrder = [
            SELECT Id, Customer__c, Customer__r.Email 
            FROM Work_Order__c 
            WHERE Id = :filing.Work_Order__c 
            WITH SECURITY_ENFORCED
        ];
        
        //4.3 Set receiver email
        List<String> listAddresses = new List<String>();

        if(workOrder.Customer__r.Email != null){
            listAddresses.add(workOrder.Customer__r.Email);
            email.setTargetObjectId(workOrder.Customer__c);
        }
        
        //4.4. Set sender email
        OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
        if(owa != null) {
            email.setOrgWideEmailAddressId(owa.Id);
        }

        //4.5 Add files & attachments
        if(listEmailAttachments!=null && !listEmailAttachments.isEmpty()) {
            email.setFileAttachments(listEmailAttachments);
        }

        //4.6 send email
        if(!listAddresses.isEmpty()) {
            email.setToAddresses(listAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    private static String getEmailTemplate(UCC_Filing__c filing) {
        String emailTemplateName;
        
        if(System.Label.BRS_FilingStatus_Approved.equalsIgnoreCase(filing.Status__c)) {
            emailTemplateName = System.Label.BRS_FilingStatus_ApprovedEmailTemplate;
        } else if(System.Label.BRS_FilingStatus_Pending.equalsIgnoreCase(filing.Status__c)) {
            emailTemplateName = System.Label.BRS_FilingStatus_PendingEmailTemplate;
        } else if(System.Label.BRS_FilingStatus_Rejected.equalsIgnoreCase(filing.Status__c)) {
            emailTemplateName = System.Label.BRS_FilingStatus_RejectedEmailTemplate;
        }
        
        return emailTemplateName;
    }

    public without sharing class Requests {
        @InvocableVariable(label = 'UCC Filing Record')
        public UCC_Filing__c filingRec;
    }   
}