/*********************************************************************************************
* NAME:  brs_accountTriggerHandler
* DESCRIPTION: Account trigger handler class
*
* @AUTHOR: Aparna Shahapurkar
* @DATE: 01/13/2021
**
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*  Aparna Shahapurkar              01/13/2021                         Created the first version
*********************************************************************************************/
public with sharing class AccountTriggerHandler implements TriggerInterface{ 
       
    /**
     * called on before Insert event
     */
    public void beforeInsert(List<SObject> newItems) {
        AccountTriggerHelper.updateAccountBackendName(newItems, null);
        if (QnA_CheckRecursive.runbusinessFilingBeforeInsertOnce()) {
            AccountTriggerHelper.setNameForForeignMerger(newItems);            
            AccountTriggerHelper.checkForDuplicates(newItems, null);
            AccountTriggerHelper.setBillingCityIndexed(newItems);
        AccountTriggerHelper.updateMailingAddressSameasBusiness(newItems, null);
        AccountTriggerHelper.validateStateValue(newItems,null);
        AccountTriggerHelper.validateOfficeAndMailingState(newItems,null);
		}
    }
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AccountTriggerHelper.updateAccountBackendName(newItems.values(), oldItems);
        if (QnA_CheckRecursive.runbusinessFilingBeforeUpdateOnce()) {            
            AccountTriggerHelper.checkForDuplicates(newItems.values(), oldItems);
            AccountTriggerHelper.setBillingCityIndexed(newItems.values());
            AccountTriggerHelper.updateMailingAddressSameasBusiness(newItems.values(), oldItems);
            AccountTriggerHelper.updateAdmindissolutionAddress(newItems.values(), oldItems);
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
         if (QnA_CheckRecursive.runAccountAfterUpdateOnce()) {
            AccountTriggerHelper.createNameHistoryTableRecs(newItems,oldItems);            
        }
        AccountTriggerHelper.createFirstReport(newItems,oldItems);
        //BRS-7785 | Capture account address on foreign investigation record
        AccountTriggerHelper.cloneForeignInvestigation(newItems, oldItems);
        AccountTriggerHelper.validateStateValue(newItems.values(),oldItems);
        AccountTriggerHelper.validateOfficeAndMailingState(newItems.values(),oldItems);
        if(!System.isBatch()){
            AccountTriggerHelper.deleteActionItems(newItems, oldItems);
        }
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