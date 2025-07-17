/*********************************************************************************************
* DESCRIPTION: Bulk Payment trigger helper class
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*  Tamkanat                      10/12/2021                         Created the first version
*********************************************************************************************/
public class Bulk_PaymentTriggerHelper {
	public static void generateEmails(List<Bulk_Payment__c> newbulkPaymentList,Map<Id, SObject> oldbulkPayments)
    {
        //Pull attachments for the current set of bulk payments so complete ones
        //are not accidently grabbed, convert them to email attachements, create
        //an email and attach to email then send email. Mark bulk payment as 
        //email sent which represents 'complete'
        //--------------------------------------------------
        
        Map<id,Attachment> bpId2attachment = new Map<id,Attachment>();
        for(Attachment attch: [Select Name, Body, ParentId, ContentType from Attachment where ParentId in : newbulkPaymentList])
        {
            bpId2attachment.put(attch.ParentId,attch);
        }
        
        EmailTemplate et =[Select id from EmailTemplate where DeveloperName = 'UCC_Filing_Bulk_Receipt' limit 1];
 		OrgWideEmailAddress owa = [SELECT id, DisplayName, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address =: System.Label.BRS_sotsOrgWideEmailAddr limit 1];
             
        List<Messaging.SingleEmailMessage> emails2Send = new List<Messaging.SingleEmailMessage>();
        for(Bulk_Payment__c bp: newbulkPaymentList)
        {
            Bulk_Payment__c bulkPaymentObj = oldbulkPayments!=null? (Bulk_Payment__c)oldbulkPayments.get(bp.Id):null;
            if(bpId2attachment.keyset().contains(bp.id) && bp.Batch_Status__c == 'Receipt Generated' && bulkPaymentObj.Batch_Status__c != bp.Batch_Status__c)
            {
                Attachment doc = bpId2attachment.get(bp.id);
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType(doc.ContentType);
                attach.setFileName(doc.Name);
                attach.setInline(false);
                attach.Body = doc.Body;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(bp.Contact__c);
                mail.setTemplateID(et.Id);
                //mail.setWhatId(<object id here>);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{attach});
                emails2Send.add(mail);
                
                bp.Batch_Status__c = 'Email Generated';
            }
        }
        Messaging.sendEmail(emails2Send);
    }
}