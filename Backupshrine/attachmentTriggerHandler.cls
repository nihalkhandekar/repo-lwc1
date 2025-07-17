/* @AUTHOR:  Sarita
* @DATE:    06/04/2021   
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita                            06/04/2021                           Created the first version
*********************************************************************************************/
public with sharing class attachmentTriggerHandler implements TriggerInterface{
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
        attchementTriggerHelper.convertAttachmentToFiles(newRecordsList);
        
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