public with sharing class BRS_FilerInfoOneTimeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    public BRS_FilerInfoOneTimeBatch() {

    }
    // method implemented from Schedulable interface
    public void execute(SchedulableContext sc){
        Database.executebatch(this,100); 
    }

    public Iterable<sObject> start(Database.BatchableContext BC) {
        //Date checkDate = Date.valueOf(System.Label.Filer_Info_Email_Date);
        //List<User> commUsers = [select Id,Name, ContactId, Profile.name from user where Profile.Name = 'CT Community User'];
        List<Contact> finalContacts = new List<Contact>();
        List<Contact> commContacts = [Select Id,Name,AccountId, Email,RecordType.DeveloperName, (select Id from Work_Orders__r) from Contact where Id IN (select ContactId from User where Profile.Name = 'CT Community User') AND RecordType.DeveloperName='Enterprise'];
        for(Contact con : commContacts){
            if(!con.Work_Orders__r.isEmpty() && con.Work_Orders__r.size()>10){
                finalContacts.add(con);
            }
        }
        //String query ='Select Id, Name, Email,Filer_Information_email_sent__c from User where DAY_ONLY(CreatedDate)='+System.Label.Filer_Info_Email_Date +' AND Profile.name= \'CT Community User\' AND Filer_Information_email_sent__c!=true';
        //System.debug('query:'+query);
        return finalContacts;
    }

    public void execute(Database.BatchableContext BC, List<Contact> contactList){
        if(!contactList.isEmpty()){
            String dynamicURL;
            List<Mass_Mailing_Result__c> mailResponses = new List<Mass_Mailing_Result__c>();
            List<Network> networks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE name = :System.Label.Community_Name Limit 1];
            if(!networks.isEmpty()) {
                String URl = Network.getLoginUrl(networks.get(0).Id);
                System.debug('URl: '+URl);
                dynamicURL = URl.replace(URl.substringAfter('business/'),'s/AccountDashboard');
                System.debug('dynamicURL: '+dynamicURL);
            }

            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.label.BRS_sotsOrgWideEmailAddr);
            EmailTemplate emailTemp =[Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName = 'Customer_Info_Template'];

            Email[] messages = new List<Email>();
            for(Contact con: contactList){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemp.Id, null, null);
                String htmlBody = email.getHtmlBody();
                if (owa != null) {
                    email.setOrgWideEmailAddressId(owa.Id);
                }
                email.setTemplateId(emailTemp.Id);
                htmlBody = htmlBody.replace('[User_Name]', con.Name);
                htmlBody = htmlBody.replace('dashboardURL', dynamicURL);
                htmlBody = htmlBody.replace('you can give us', 'you can now give us');
                email.setHtmlBody(htmlBody);
                string[] toaddresses = new string[] {con.Email};
                email.setToAddresses(toaddresses);

                if(!toaddresses.isEmpty()){
                    Email sendgridEmail = new Email();
                    sendgridEmail.addTo(toaddresses);
                    sendgridEmail.setFrom(owa.Address);
                    System.debug('owa.DisplayName: '+owa.DisplayName);
                    sendgridEmail.setFromName(owa.DisplayName);
                    sendgridEmail.setSubject(email.getSubject());
                    sendgridEmail.setHtml(htmlBody);
                    //messages.add(sendgridEmail);

                    SendGridv3 sendgrid = new SendGridv3();
                    SendGridv3.SendGridResponse response = sendgrid.send(sendgridEmail);
                    String errorMessage='';
                    if(response.message.contains('errors')){
                        Object resObj = JSON.deserializeUntyped(response.message);
                        Map<String, Object> resMap = (Map<String, Object>) resObj;
                        System.debug('resMap: '+resMap);
                        List<Object> resMapResult = (List<Object>) resMap.get('errors');
                        System.debug('resMapResult: '+resMapResult[0]);
                        Map<String, Object> resMap22 = (Map<String, Object>)resMapResult[0];
                        System.debug('resMap22: '+resMap22);
                        errorMessage = 'Error: '+String.valueOf(resMap22.get('message'));
                    }
                    System.debug('Code: '+response.code+'Reponse: '+response.message);
                    System.debug('Header: '+response.headerMessage);
                   
                    Mass_Mailing_Result__c res = new Mass_Mailing_Result__c();
                    res.Account__c = con.AccountId;
                    res.Batch_Name__c = 'One Time Filer Info Batch';
                    res.Status_Code__c = response.code;
                    if(response.code==202 || response.code==250){
                        res.Response__c = 'Success';
                    }else{
                        res.Response__c = errorMessage;
                    }
                    mailResponses.add(res);
                }
            }

            if(!mailResponses.isEmpty()){
                insert mailResponses;
            }
        }
    }

    public void finish(Database.BatchableContext BC){

    }
}