/*********************************************************************************************
* NAME:  BRSFIEmailNotification
* DESCRIPTION: This class is used to send Email notifications to users.
*
* @AUTHOR: Aparna
* @DATE: 07/20/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                       DATE                               DESCRIPTION
* -------------------------------------------------------------------------------------------
* Aparna                        07/20/2021                       Created the first version
*********************************************************************************************/
public with sharing class BRSFIEmailNotification {
    public static final String className='BRSFIEmailNotification';
    public static final String severity='Medium';
    public static final String objectNameBusiness='Work_Order__c';

    @InvocableMethod
    public static void sendPaymentConfirmationEmail(List<RequestsInfo> RequestsInfo){
        if(!System.isBatch()){
            try{
                Work_Order__c workOrderRec = RequestsInfo[0].workOrderRec;               
                OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
                
                Work_Order__c workOrderEmail = [SELECT Id, Source__c, Total_Hold_Amount__c, Customer__c, Customer__r.Name, Customer__r.Email, 
                                              Foreign_Investigation__c, Foreign_Investigation__r.Name, Foreign_Investigation__r.Business_Name__c 
                                              FROM Work_Order__c WHERE Id=: workOrderRec.Id WITH SECURITY_ENFORCED];
                
                EmailTemplate emailTemplateRec = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                                  WHERE DeveloperName =: System.label.ForeignInvestigationConfirmationTemplate];
                
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, workOrderEmail.Id);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                String emailHtmlBody = email.getHtmlBody();
                
                if(workOrderEmail.Source__c == System.Label.brs_FilingOnline){
                    List<string> to = new List<string>();
                    if(workOrderEmail.Customer__r.Email!=null){
                        to.add(workOrderEmail.Customer__r.Email);
                    }
                    email.setToAddresses(to);
                }
                if(owa!=null){
                    email.setOrgWideEmailAddressId(owa.Id);
                }
				
                email.setTemplateId(emailTemplateRec.Id);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.setHtmlBody(emailHtmlBody);   
				email.setWhatId(workOrderEmail.id);
                email.setSaveAsActivity(false);
                                                
                if(email.getToAddresses()!=null && email.getToAddresses().size()>0){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
            }catch(Exception e){
                BOS_Utility.ExceptionHandler(className,'sendPaymentConfirmationEmail',objectNameBusiness,null,severity,e,null);
            }  
        }
    }
    public without sharing class RequestsInfo {
        @InvocableVariable
        public Work_Order__c workOrderRec;
    } 
}