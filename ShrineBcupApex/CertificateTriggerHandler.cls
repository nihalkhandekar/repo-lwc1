/**********************************************************************************************
    CLASS NAME : CertificateTriggerHandler
    DESCRIPTION : Trigger Handler class on Certficate__c.
    DATE : 08th April, 2021
***********************************************************************************************/
public with sharing class CertificateTriggerHandler implements TriggerInterface {
    public void beforeInsert(List<SObject> newItems) {
        if(QnA_CheckRecursive.runCertificateBeforeInsertOnce()) {     
            CertificateTriggerHelper.updateFilingFee(newItems,null); 
            CertificateTriggerHelper.checkAccountForNoRecord(newItems);
            CertificateTriggerHelper.validateCertificateype(newItems,null);
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if(QnA_CheckRecursive.runCertificateBeforeUpdateOnce()) {
            CertificateTriggerHelper.updateFilingFee((List<Certficate__c>) newItems.values(), (Map<Id, Certficate__c>) oldItems); 
            CertificateTriggerHelper.checkPaymentVerification(newItems.values(),oldItems);
            CertificateTriggerHelper.validateCertificateype(newItems.values(),oldItems);
        }
    }

    public void beforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {  

    }
    
    public void afterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
        if(QnA_CheckRecursive.runCertificateAfterInsertOnce()) {
            CertificateTriggerHelper.updateRegistertionDateandMailingAddress(newRecordsList);
            BRS_PaymentUtility.rollUpFilingFees(newRecordsList);
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if(QnA_CheckRecursive.runCertificateAfterUpdateOnce()) {
            List<sObject> filingRecordsList = new List<SObject>();
            filingRecordsList.addAll(oldItems.values());
            filingRecordsList.addAll(newItems.values());
            BRS_PaymentUtility.rollUpFilingFees(filingRecordsList);
			BRS_PaymentUtility.refundForRejectedFilings(newItems.values(),oldItems);
            CertificateTriggerHelper.refundRejectedOnlineFilings(newItems.values(), oldItems);
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        BRS_PaymentUtility.rollUpFilingFees(oldItems.values());
    }
 
    public void afterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {        
    
    }
}