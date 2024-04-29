public class CustomEmail {
Public Quote_Custom__c QT{get; set;}
Public String Subject {get; set;}
Public String EmailBody {get; set;}
Public String ToAddress {get; set;}
Public String ccAddress {get; set;}
Public Id OppId {get;set;}
Public List<String> EmailAddresses {get; set;}
Public List<String> CCAddresses {get; set;}

//===Constructor===//
    public CustomEmail (){
    QT  = new Quote_Custom__c();
    OppId = ApexPages.CurrentPage().getParameters().get('id');   
    QT  = [select id, name, Contact__c, Contact__r.name, Contact__r.email from Quote_Custom__c ];
    ToAddress= QT.Contact__r.email;
    //ccAddress= Userinfo.getUserEmail();  
    Subject = 'Quote Details: '+QT.name;   
    EmailBody = ('Dear '+QT.Contact__r.name+',<br/><br/>'
                +'Greetings from our organization!!<br/><br/>'
                +'Please find the recent Opportunity Details as follows:<br/>'
                +'Opportunity Name: '+QT.name+'<br/>'
                +'For any clarification, kindly get in touch with us.<br/><br/><br/>'
                +'Thanks & Regards<br/>'
                +'Sales head<br/>'
                +'NK');
    List<Messaging.SingleEmailMessage> EmailObjs = new List<Messaging.SingleEmailMessage> ();
    }
//===Email Send Method===//    
    public PageReference SendEmail() {
    List<Messaging.SingleEmailMessage> EmailObjs = new List<Messaging.SingleEmailMessage> ();    
    Messaging.SingleEmailMessage EmailObj = new Messaging.SingleEmailMessage();
    String[] sendingToAdd = new String[]{ToAddress};
    EmailObj.SetToAddresses(sendingToAdd);
    //String[] sendingTocAdd = new String[]{ccAddress};
    //EmailObj.SetCcAddresses(sendingTocAdd);
    EmailObj.SetSubject(Subject);
    EmailObj.SetHtmlBody(EmailBody); 
    EmailObjs.add(EmailObj);
    Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {EmailObj});
    return null;
    }
}