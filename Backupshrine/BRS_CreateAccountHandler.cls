/*****************************************************************************************************
 * NAME:  BRS_CreateAccountHandler
 * DESCRIPTION: create account record
 *
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------------------------------
 * Priyanka                         3/24/2021                         Formation flow access for CT user
 ******************************************************************************************************/
public with sharing class BRS_CreateAccountHandler  implements TriggerInterface{
     /**
     * called on before Insert event
     */
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
        BRS_CreateAccountTriggerHelper.creatAcc(newRecordsList);
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