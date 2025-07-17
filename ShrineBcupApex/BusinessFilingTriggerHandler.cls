public with sharing class BusinessFilingTriggerHandler  implements TriggerInterface{
    
     /**
     * called on before Insert event
     */
    public void beforeInsert(List<SObject> newItems) {  
		if(QnA_CheckRecursive.runbusinessFilingBeforeInsertOnce()) {	
        BusinessFilingTriggerHelper.checkOldFilingForFormations(newItems,null);
			BusinessFilingTriggerHelper.updateCitizenship(newItems,null);
         BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems,null);
      BusinessFilingTriggerHelper.createBusinessFilingRecordType(newItems);
       BusinessFilingTriggerHelper.updateEffectiveDate(newItems,null);
      BusinessFilingTriggerHelper.updateEffectiveDateAndTime(newItems,null);
      BusinessFilingTriggerHelper.updateIntakeFlowToProcesss(newItems);
      BusinessFilingTriggerHelper.updateFilingTimeFromWorkorder(newItems);
      
		}	        
    }
    /**
     * called on before update event
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		BusinessFilingTriggerHelper.updateEffectiveDate(newItems.values(),null);
            BusinessFilingTriggerHelper.updatePendingFilingCheckbox(newItems.values(),oldItems);
    if(!Auth.CommunitiesUtil.isGuestUser()){
    BusinessFilingTriggerHelper.updateAnnualReportDueDateOnRejection(newItems.values(),null);
    }
         BusinessFilingTriggerHelper.updateFilingTimeFromWorkorder(newItems.values());
    if(QnA_CheckRecursive.runbusinessFilingBeforeUpdateOnce()) {
			BusinessFilingTriggerHelper.updateTotalShare(newItems.values(),oldItems); 
			BusinessFilingTriggerHelper.checkPaymentVerification(newItems.values(),oldItems);
			BusinessFilingTriggerHelper.updateCitizenship(newItems.values(),oldItems);
			BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems.values(),oldItems);
      BusinessFilingTriggerHelper.updateEffectiveDateAndTime(newItems.values(),oldItems);
      BusinessFilingTriggerHelper.updateIntakeFlowToProcesss(newItems.values());
      BusinessFilingTriggerHelper.updateAgentCertifiedCopyURLField(newItems,oldItems);
    
     
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
		if(QnA_CheckRecursive.runbusinessFilingAfterInsertOnce()) {
			BRS_PaymentUtility.rollUpFilingFees(newRecordsList);
			/**
			* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3070
			* Change(s)/Modification(s) Description : Added update logic on account - Annual due date and filing date field.
			* Change(s)/Modification(s) Made on : 2021-04-02
			* Change(s)/Modification(s) Made by : Avinash Shukla
			*/
			/**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4397
      * Change(s)/Modification(s) Description : Changes made for method calling as parameters have changes
      * Change(s)/Modification(s) Made on : 2021-05-20
      * Change(s)/Modification(s) Made by : Avinash Shukla
      */
      BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, new Map<Id,sObject>(),true);
			BusinessFilingTriggerHelper.updateAccountPin(newRecordsList,null);
      /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Updated latest filing date on account for approved/rejected filings
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-06-28
    * Change(s)/Modification(s) Made by : Rahul Sharma
    */
      BusinessFilingTriggerHelper.processMostRecentFilingDate(newItems,null);
      BusinessFilingTriggerHelper.updateForfeitureDate(newRecordsList);
      BusinessFilingTriggerHelper.updateIsRejectedInstiatedForAnnualReport(newRecordsList);

    }
    }
    /**
     * called on afer update event
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            BusinessFilingTriggerHelper.createNameHistoryTableRecs(newItems,oldItems);
            BusinessFilingTriggerHelper.createForeignInvestigationCase(newItems.values(),oldItems);
            BusinessFilingTriggerHelper.processWithdrwalUpdates(newItems.values());
            BusinessFilingTriggerHelper.updateAdminstrativeDissolutionText(newItems.values(),oldItems);
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3070
        * Change(s)/Modification(s) Description : Added update logic on account - Annual due date and filing date field.
        * Change(s)/Modification(s) Made on : 2021-04-02
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        BusinessFilingTriggerHelper.processMaintenanceFilings(newItems,oldItems);
        BusinessFilingTriggerHelper.updateJurdictionStateorTerritory(newItems.values(),oldItems);
		if(QnA_CheckRecursive.runbusinessFilingAfterUpdateOnce()) {
			/**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4397
      * Change(s)/Modification(s) Description : Changes made for method calling as parameters have changes
      * Change(s)/Modification(s) Made on : 2021-05-20
      * Change(s)/Modification(s) Made by : Avinash Shukla
      */      
			List<sObject> filingRecordsList = new List<SObject>();
			filingRecordsList.addAll(oldItems.values());
			filingRecordsList.addAll(newItems.values());
       if(!Auth.CommunitiesUtil.isGuestUser()){
               BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems,oldItems,false);
               BRS_PaymentUtility.rollUpFilingFees(filingRecordsList); 
               BusinessFilingTriggerHelper.rejectAccountOnFilingReject(newItems.values());
          }
			BusinessFilingTriggerHelper.updateAccountPin(newItems.values(),oldItems);
			BRS_PaymentUtility.refundForRejectedFilings(newItems.values(),oldItems);
      BusinessFilingTriggerHelper.updateReservedAccountsForRejectedFilings(newItems.values(),oldItems);
      BusinessFilingTriggerHelper.LinkBusinessOnApproval(newItems.values(),oldItems);
      BusinessFilingTriggerHelper.refundRejectedOnlineFilings(newItems.values(), oldItems);
      BusinessFilingTriggerHelper.updateReservedAccountForIntake(newItems.values(),oldItems); 
      BusinessFilingTriggerHelper.updateAgentEmailAddress(newItems.values(),oldItems);
      /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Updated latest filing date on account for approved/rejected filings
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-06-28
    * Change(s)/Modification(s) Made by : Rahul Sharma
    */
      BusinessFilingTriggerHelper.processMostRecentFilingDate(newItems,oldItems);

		}
    }
    /**
     * called on afer delete event
     */
    public void afterDelete(Map<Id, SObject> oldItems) {
		BRS_PaymentUtility.rollUpFilingFees(oldItems.values());
    }
    /**
     * called on afer undelete event
     */
    public void afterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {        
    }
}