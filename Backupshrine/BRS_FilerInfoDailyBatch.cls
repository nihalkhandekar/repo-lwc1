public with sharing class BRS_FilerInfoDailyBatch implements Database.Batchable<sObject>, Schedulable{
    public BRS_FilerInfoDailyBatch() {

    }
	
	// method implemented from Schedulable interface
    public void execute(SchedulableContext sc){
        Database.executebatch(this,10); 
    }
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Date checkDate = Date.valueOf(System.Label.Filer_Info_Email_Date);
        String query ='Select Id, Name, Email,Filer_Information_email_sent__c from User where DAY_ONLY(CreatedDate)='+System.Label.Filer_Info_Email_Date +' AND Profile.name= \'CT Community User\' AND Filer_Information_email_sent__c!=true';
        System.debug('query:'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User> userList) {
        String dynamicURL;
        List<User> updateUsers = new List<User>();
        List<Network> networks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE name = :System.Label.Community_Name Limit 1];
        if(!networks.isEmpty()) {
            String URl = Network.getLoginUrl(networks.get(0).Id);
            System.debug('URl: '+URl);
            dynamicURL = URl.replace(URl.substringAfter('business/'),'s/AccountDashboard');
            System.debug('dynamicURL: '+dynamicURL);
        }

        OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.label.BRS_sotsOrgWideEmailAddr);
        EmailTemplate emailTemp =[Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName = 'Customer_Info_Template'];

        for(User usr: userList){
            if(usr.Email!=null){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemp.Id, null, null);
                String htmlBody = email.getHtmlBody();
                if (owa != null) {
                    email.setOrgWideEmailAddressId(owa.Id);
                }
                email.setTemplateId(emailTemp.Id);
                htmlBody = htmlBody.replace('[User_Name]', usr.Name);
                htmlBody = htmlBody.replace('dashboardURL', dynamicURL);
                email.setHtmlBody(htmlBody);
                string[] to = new string[] {usr.Email};
                email.setToAddresses(to);
                if(email.getToAddresses().size()>0){
                    Messaging.SendEmailResult [] mailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    System.debug('Email result ' + mailResult[0].IsSuccess()); 
                    if(mailResult[0].IsSuccess()==true){
                        usr.Filer_Information_email_sent__c = true;
                        updateUsers.add(usr);
                    }
                }
            }
        }

        if(!updateUsers.isEmpty()){
            update updateUsers;
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Batch executed.  
    }
}