public class OppLineItemPDFUpdateEmail {
public Opportunity_Line_Item_Custom__c opli {get; set;}
public List<Opportunity_Line_Item_Custom__c> ListOPLI {get; set;}
Public String Subject {get; set;}
Public String EmailBody {get; set;}
public List<string> toAdd{get;set;}
Public String ccAddress {get; set;}
public Id opliId {get; set;}
public Set<Id> IdSet = new Set<Id>();
public ApexPages.StandardSetController StdController;
Public List<String> toAddressList {get; set;}
Public String myEmail {get; set;}
Public String newtoAddress {get; set;} 
public String message {get; set;}

    
    public OppLineItemPDFUpdateEmail(ApexPages.StandardSetController Controller) {
    this.StdController = Controller;
    ListOPLI = new List<Opportunity_Line_Item_Custom__c>();
    //toAdd = new List<string> ();
    for(Opportunity_Line_Item_Custom__c opli : (list<Opportunity_Line_Item_Custom__c>)StdController.getSelected()){
        IdSet.add(opli.id);
        }
    ListOPLI = [select id, name, Contact__c, Sales_Price__c, Quantity__c, Total_price__c, Contact__r.name, Contact__r.Email from Opportunity_Line_Item_Custom__c where id =: IdSet];
    system.debug(ListOPLI);
    
    ccAddress = Userinfo.getUserEmail();
    Subject = 'Opportunity line item update '; 
    EmailBody = 'Dear User,<br/><br/>'
                +'Greetings from our organization!!<br/><br/>'
                +'Please find the Opportunity Line Item Details as follows:<br/><br/>'
                +'For any clarification, kindly get in touch with us.<br/><br/><br/>'
                +'Thanks & Regards<br/>'
                +'Sales head<br/>'
                +'NK <br/><br/><br/>'
                + '<table border="2" style="border-collapse: collapse"><tr><th>Opp Line Item Name</th><th>Sales Price</th><th>Quantity</th><th>Total</th></tr>';
        //iterate over list and output columns/data into table rows//
        toAdd = new List<string>();
        for(Opportunity_Line_Item_Custom__c oppLi : ListOPLI){
        //Mapping of Stored data in local variables//
           String OppName = oppLi.Name; 
           Double SalesPrice = oppLi.Sales_Price__c;
           Double Quantity = oppLi.Quantity__c;
           Double Total = oppLi.Total_price__c;
           String JEmail = oppLi.Contact__r.Email;
         myEmail= JEmail;
         toAdd.add(myEmail);
         newtoAddress = string.join(toAdd, ',');          
        EmailBody += '<tr><td>' + OppName + '</td><td>' + SalesPrice + '</td><td>' + Quantity + '</td><td>' + Total + '</td></tr> ';    
                  
        }
       EmailBody += '</table>';                             
 }
 
     public PageReference sendingEmail(){ 
     List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity_Line_Item_Custom__c op :ListOPLI){
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(op.Contact__r.Email);
        semail.setToAddresses(sendTo); 
        String[] sendingTocAdd = new String[]{ccAddress};
        semail.setCcAddresses(sendingTocAdd ); 
        semail.setSubject(Subject);
        semail.setHtmlBody(EmailBody);
        emails.add(semail);
        }
        Messaging.sendEmail(emails);
        message='Email Sent !!!';
        return null;
    }
}