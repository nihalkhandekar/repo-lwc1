public with sharing class ForeignInvestigationTriggerHandler implements TriggerInterface{
    
     /**
     * called on before Insert event
     */
    public void beforeInsert(List<SObject> newItems) {
        ForeignInvestigationTriggerHelper.duplicateFICheck(newItems, null);
        ForeignInvestigationTriggerHelper.updateBusinessFields(newItems, null);
        ForeignInvestigationTriggerHelper.updateCaseStatus(newItems, null);
    }
    
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ForeignInvestigationTriggerHelper.duplicateFICheck(newItems.values(), oldItems);
        ForeignInvestigationTriggerHelper.updateBusinessFields(newItems.values(), oldItems);
        ForeignInvestigationTriggerHelper.updateCaseStatus(newItems.values(), oldItems);
    }
 
     /**
     * called on before delete event
     */
    public void beforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {        
    }
    
     /**
     * called on afer insert event
     */
    public void afterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {   
        ForeignInvestigationTriggerHelper.createPaymentLineItems(newRecordsList, null);     
    }
    
    /**
     * called on afer update event
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ForeignInvestigationTriggerHelper.createPaymentLineItems(newItems.values(), oldItems);
        ForeignInvestigationTriggerHelper.createBTPaymentSchedule(newItems, oldItems);
        ForeignInvestigationTriggerHelper.cancelPaymentSchedule(newItems.values());
    }
    
    /**
     * called on afer delete event
     */
    public void afterDelete(Map<Id, SObject> oldItems) {
    }
    
    /**
     * called on afer undelete event
     */
    public void afterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {        
    }
}