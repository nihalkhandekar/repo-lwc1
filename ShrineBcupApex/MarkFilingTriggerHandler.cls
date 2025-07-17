public class MarkFilingTriggerHandler implements TriggerInterface{
  public void beforeInsert(List<SObject> newItems) {
          
        MarkFilingTriggerHelper.updateFilingFee(newItems,null); 
       
     // MarkFilingTriggerHelper.validatePaymentmethodSource(newItems);
      MarkFilingTriggerHelper.previousNameState(newItems);
       MarkFilingTriggerHelper.updateClassofGoods(newItems);
       
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     // MarkFilingTriggerHelper.validatePaymentmethodSource(newItems.values());
        MarkFilingTriggerHelper.updateFilingFee(newItems.values(),oldItems); 
        MarkFilingTriggerHelper.checkPaymentVerification(newItems.values(),oldItems);
        MarkFilingTriggerHelper.previousNameState(newItems.values());
       
        
    }

    public void beforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {  

    }
    
    public void afterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
      MarkFilingTriggerHelper.updateFilingNumberandDate(newRecordsList);
        BRS_PaymentUtility.rollUpFilingFees(newRecordsList);
        
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      
        List<sObject> filingRecordsList = new List<SObject>();
        filingRecordsList.addAll(oldItems.values());
        filingRecordsList.addAll(newItems.values());
        BRS_PaymentUtility.rollUpFilingFees(filingRecordsList);
      //  BRS_PaymentUtility.refundForRejectedMarkFilings(newItems.values(), oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        BRS_PaymentUtility.rollUpFilingFees(oldItems.values());
    }
 
    public void afterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {        
    
    }
  }