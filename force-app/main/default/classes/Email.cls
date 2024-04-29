public class Email {
public string message{get;set;}
Public Id OppId {get;set;}
Public Opportunity_Custom__c opp {get; set;}
Public String Subject {get; set;}
Public String EmailBody {get; set;}
public string toAddress{get;set;}
Public String ccAddress {get; set;} 
  //===Constructor===//
    public Email(){
    OppId = ApexPages.CurrentPage().getParameters().get('id');   
    opp  = [select id, name, Contact__c, Contact__r.name, Contact__r.Email, Expected_Revenue__c from Opportunity_Custom__c where id =: OppId ];
    toAddress = opp.Contact__r.Email;   
    ccAddress = Userinfo.getUserEmail();
    Subject = 'Opportunity Details: '+opp.name;   
    EmailBody = ('Dear '+opp.Contact__r.name+',<br/><br/>'
                +'Greetings from our organization!!<br/><br/>'
                +'Please find the recent Opportunity Details as follows:<br/>'
                +'Opportunity Name: '+opp.name+'<br/>'
                +'Expected Revenue: '+opp.Expected_Revenue__c+'<br/><br/>'
                +'For any clarification, kindly get in touch with us.<br/><br/><br/>'
                +'Thanks & Regards<br/>'
                +'Sales head<br/>'
                +'NK');
    }
 ////========Email Send Button Method==============///////   
    public PageReference sendingEmail(){
    
     PageReference PDF = new PageReference('/apex/OppLineItemPDF?id=' + OppId);
        Blob b = PDF.getContent();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setBody(b);
        attachment.setFileName('OPPLineItem PDF');
        attachment.setInline(false);
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{toAddress};
        semail.setToAddresses(sendingTo);
        String[] sendingTocAdd = new String[]{ccAddress};
        semail.setCcAddresses(sendingTocAdd ); 
        semail.setSubject(Subject);
        semail.setHtmlBody(EmailBody);
        semail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        message='Email Sent !!!';
        return null;
    }

}