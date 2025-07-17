/*********************************************************************************************
* NAME:  SEP_ContactDetailTriggerHandler
* DESCRIPTION: SEP Contact Detail trigger handler class
*
* @AUTHOR:   Sandeep Joshi  
* @DATE: 09/03/2021
**
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*  Sandeep Joshi              09/03/2021                         Created the first version
*********************************************************************************************/
public with sharing class SEP_ContactDetailTriggerHandler implements TriggerInterface{    
    /**
     * called on before Insert event
     */
    public void beforeInsert(List<SObject> newItems) {
        SEP_ContactDetailEmailPhoneModifier.CheckEmailPhoneNumber(newItems);
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
        SEP_ContactDetailTriggerHelper.sendVerificationMessages(newRecordsList);
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