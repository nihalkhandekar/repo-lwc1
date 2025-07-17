/******************************************************************************************************
* NAME:  		BRS_FI_PayScheduleNotificationBatch
* DESCRIPTION:  This batch class is to notify the customer if their monthly payment schedule was 
                captured successfully or not. If successful, it also updates the fields on 
                Foreign Investigation
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		10th Aug, 2021
*******************************************************************************************************/

public class BRS_FI_PayScheduleNotificationBatch implements Database.Batchable<sObject>, Schedulable {
    public List<String> lstTemplateNames = new List<String>{System.Label.Foreign_Investigation_Monthly_Payment_Failure, System.Label.Foreign_Investigation_Monthly_Payment_Notification};
    public Map<String, EmailTemplate> mapStrToTemp = new Map<String, EmailTemplate>();
    public Id owa;  //org wide email address
    
    public String query = 'SELECT Id, CreatedDate, bt_stripe__Related_Contact__c, bt_stripe__Related_Contact__r.Email, bt_stripe__Payment_Status__c, bt_stripe__Transaction_Status__c, bt_stripe__Amount__c, bt_stripe__Processed_Date__c, bt_stripe__Transaction_Type__c, '
                                + 'bt_stripe__Payment_Schedule__c, bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c, bt_stripe__Payment_Schedule__r.bt_stripe__Balance_Paid__c, '
                                + 'bt_stripe__Payment_Schedule__r.bt_stripe__Balance_Due__c, bt_stripe__Payment_Schedule__r.bt_stripe__Status__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__c, '
                                + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Payments_Made_to_Date__c '
                            + 'FROM bt_stripe__Transaction__c '
                            + 'WHERE bt_stripe__Payment_Schedule__c != null AND '
                                + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__c != null AND '
                                + 'bt_stripe__Payment_Schedule__r.bt_stripe__Status__c != \'Canceled\' AND '
                                + 'DAY_ONLY(bt_stripe__Processed_Date__c) = TODAY AND '
                                + 'bt_stripe__Transaction_Status__c != \'Open\' AND '
                                + 'bt_stripe__Transaction_Type__c = \'Normal\' AND '
                                + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Auto_payment_plan__c = true AND '
                                + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.First_Payment_Done__c = true '
                            + 'ORDER BY CreatedDate ASC';

    public BRS_FI_PayScheduleNotificationBatch() {
        owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address =: System.Label.BRS_sotsOrgWideEmailAddr LIMIT 1].Id;

        for(EmailTemplate emailTemp : [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName IN :lstTemplateNames]) {
            mapStrToTemp.put(emailTemp.DeveloperName, emailTemp);
        }
    }

    public BRS_FI_PayScheduleNotificationBatch(String inpQuery) {
        this.query = inpQuery;

        owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address =: System.Label.BRS_sotsOrgWideEmailAddr LIMIT 1].Id;

        for(EmailTemplate emailTemp : [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName IN :lstTemplateNames]) {
            mapStrToTemp.put(emailTemp.DeveloperName, emailTemp);
        }
    }

    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext bc, List<bt_stripe__Transaction__c> lstTxn) {
        Map<Id, Foreign_Investigation__c> mapFI = new Map<Id, Foreign_Investigation__c>();
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        Map<Id, bt_stripe__Transaction__c> mapTxn = new Map<Id, bt_stripe__Transaction__c>();
        Map<Id, EmailTemplate> mapTxnIdToEmailTemp = new Map<Id, EmailTemplate>();

        // segregate transactions based on success and failure and prepare data to update and template to notify
        for (bt_stripe__Transaction__c txn : lstTxn) {
            Decimal paymentMade = 0;
            mapTxn.put(txn.Id, txn);

            if(txn.bt_stripe__Transaction_Status__c == System.Label.BRS_Status_Value_Completed && txn.bt_stripe__Payment_Status__c == System.Label.Captured_Value) {
                mapTxnIdToEmailTemp.put(txn.Id, mapStrToTemp.get(System.Label.Foreign_Investigation_Monthly_Payment_Notification));
                paymentMade = txn.bt_stripe__Amount__c;
            }
            else if(txn.bt_stripe__Transaction_Status__c == System.Label.Status_Value_Failed_Comparable && txn.bt_stripe__Payment_Status__c == System.Label.Status_Value_Uncaptured_Comparable) {
                mapTxnIdToEmailTemp.put(txn.Id, mapStrToTemp.get(System.Label.Foreign_Investigation_Monthly_Payment_Failure));
            }
                        
            if(!mapFI.isEmpty() && mapFI.containsKey(txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__c)) {
                Foreign_Investigation__c forInvExist = mapFI.get(txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__c);
                forInvExist.Payments_Made_to_Date__c += paymentMade;
                forInvExist.Months_Paid__c += (paymentMade != null && paymentMade != 0) ? 1 : 0;
                forInvExist.Due_Date__c = txn.bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c;
                mapFI.put(forInvExist.Id, forInvExist);
            }
            else {
                Foreign_Investigation__c forInv = new Foreign_Investigation__c(Id = txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__c);            
                forInv.Payments_Made_to_Date__c = txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Payments_Made_to_Date__c + paymentMade; 
                forInv.Months_Paid__c = (txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c != null) ? 
                                            txn.bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c + 1 :
                                                1;
                forInv.Due_Date__c = txn.bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c;
                mapFI.put(forInv.Id, forInv);
            }
        }

        if(!mapFI.isEmpty()) {
            update mapFI.values();

            //prepare and send email to the contact for a failed or successful transaction with updated Foreign Investigation data
            for (Id txnId : mapTxnIdToEmailTemp.keySet()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail = Messaging.renderStoredEmailTemplate(mapTxnIdToEmailTemp.get(txnId).Id, null, mapTxn.get(txnId).bt_stripe__Payment_Schedule__r.Foreign_Investigation__c);
                String[] toAddresses = new String[] {mapTxn.get(txnId).bt_stripe__Related_Contact__r.Email};
                mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(owa);
                mail.setUseSignature(false);
                lstMails.add(mail);
            }

            if(!lstMails.isEmpty()) {
                Messaging.sendEmail(lstMails);
            }
        }
    }

    public void finish (Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc){
        Database.executebatch(this,100); 
    }
}