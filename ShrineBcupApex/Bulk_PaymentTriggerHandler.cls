/*********************************************************************************************
* NAME:  Bulk_PaymentTriggerHandler
* DESCRIPTION: Bulk Payment trigger handler class
*
* @AUTHOR: Himanshi Mayal
* @DATE: 10/12/2021
**
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*  Tamkanat                      10/12/2021                         Created the first version
*********************************************************************************************/
public class Bulk_PaymentTriggerHandler implements TriggerInterface{
	/**
     * called on before Insert event
     */
    public void beforeInsert(List<SObject> newItems) {
    }
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
	if(QnA_CheckRecursive.runbulkPaymentBeforeUpdateRun()) {
            Bulk_PaymentTriggerHelper.generateEmails(newItems.values(),oldItems);
        }
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