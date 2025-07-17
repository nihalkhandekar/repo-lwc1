public with sharing class ContactTriggerHandler implements TriggerInterface {
    public void beforeInsert(List<SObject> newItems) {

    }
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

        

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

        
               
    }
    /**
     * called on afer update event
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ContactTriggerHelper.validateGovernmentUser(newItems.values(),oldItems);
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