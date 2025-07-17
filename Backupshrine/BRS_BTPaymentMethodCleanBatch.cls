/******************************************************************************************************
* NAME:  		BRS_BTPaymentMethodCleanBatch
* DESCRIPTION:  This batch class is a part of BRS-8397 to delete invalid Blackthorn payment methods
                and delete valid payment methods if they are not checked as default.
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		4th Jan, 2022
*******************************************************************************************************/
global class BRS_BTPaymentMethodCleanBatch implements Database.Batchable<sObject>, Schedulable {
    public String contactRecType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
    public String query = 'SELECT Id, (SELECT Id, bt_stripe__Remove_from_Stripe__c, bt_stripe__Payment_Method_Status__c FROM bt_stripe__Payment_Methods__r WHERE bt_stripe__Default_Payment_Method__c = false) FROM Contact WHERE RecordTypeId = :contactRecType';

    public BRS_BTPaymentMethodCleanBatch() {

    }

    public BRS_BTPaymentMethodCleanBatch(String q) {
        if(String.isNotBlank(q)) {
            query = q;
        } 
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<bt_stripe__Payment_Method__c> setOfPMsToDelete = new List<bt_stripe__Payment_Method__c>();
        List<bt_stripe__Payment_Method__c> setOfValidPMs = new List<bt_stripe__Payment_Method__c>();

        //Identify all invalid cards and valid cards in contact
        //delete all except default cards.

        for(Contact c : scope) {
            
            if(c.bt_stripe__Payment_Methods__r.size() > 0) {
                for(bt_stripe__Payment_Method__c paymentMethod : c.bt_stripe__Payment_Methods__r) {
                if(paymentMethod.bt_stripe__Payment_Method_Status__c == 'Valid') {
                        paymentMethod.bt_stripe__Remove_from_Stripe__c = true;
                        setOfValidPMs.add(paymentMethod);
                    }
                }
            }
        }
            for(Contact c : scope) {
            if(c.bt_stripe__Payment_Methods__r.size() >= 10) {
                for(bt_stripe__Payment_Method__c paymentMethod : c.bt_stripe__Payment_Methods__r) {
                    if(paymentMethod.bt_stripe__Payment_Method_Status__c == 'Invalid'){
                        setOfPMsToDelete.add(paymentMethod);
                    }
                }
            }
        }

        if(!setOfPMsToDelete.isEmpty()) {
            delete setOfPMsToDelete;
        }
        if(!setOfValidPMs.isEmpty())
        {
            ID jobID = System.enqueueJob(new BRS_BTPaymentMethodQueueable(setOfValidPMs));
        }   

    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc){
        Database.executebatch(this,100); 
    }
}