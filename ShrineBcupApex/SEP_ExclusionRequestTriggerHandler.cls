/* DESCRIPTION: Handler class for DCP staff trigger on Consent object, used to calculate end date, 
start date, removal date & set Send mail field as true  
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                            10-Sep-2021                      Created First Version
***************************************************************************************************/
public with sharing class SEP_ExclusionRequestTriggerHandler implements TriggerInterface{
    /**
     * called on before insert event
     */
    public void beforeInsert(List<SObject> newItems) {
        system.debug('Inside before insert method ');
        SEP_ExclusionRequestTriggerHelper.processRecords(newItems,null,'CREATE');
    }
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        system.debug('Inside before update method ');
        SEP_ExclusionRequestTriggerHelper.processRecords(newItems.values(),oldItems,'UPDATE');
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