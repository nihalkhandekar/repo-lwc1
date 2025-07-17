/*********************************************************************************************
 * NAME:  brs_MarkExpirationBatch 
 * DESCRIPTION: Batch class to update Mark object with expiration status when expiration date passed.
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 06/30/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     06/30/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class brs_MarkExpirationBatch implements Database.Batchable<sObject> {
    public static Final String className = 'brs_MarkExpirationBatch ';
    public static Final String methodName = 'updateMarkStatus';
    public static Final String objectName = 'Mark__c';
    public String query = '';
    public Date today = Date.today();
    
    global brs_MarkExpirationBatch(String strQuery)
    {
        query  = strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       /** collect the batches of records or objects to be passed to execute **/
      return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Mark__c> markList) {
        try
        {
            List<Mark__c> updateMarkLst = new List<Mark__c>();
            List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
            if(!markList.IsEmpty())
            {
                for(Mark__c mk : markList)
                {
                    mk.Status__c = system.label.Label_Expired;
                    updateMarkLst.add(mk); 
                }
            }
            if(!updateMarkLst.IsEmpty())
            {
                Database.SaveResult[] markUpdateSuccessList = Database.update(updateMarkLst, false);
                for(Integer i=0;i<markUpdateSuccessList .size();i++){
                     if (!markUpdateSuccessList.get(i).isSuccess()){
                       Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, updateMarkLst.get(i).Id, BOS_Utility.sSeverity, null, system.label.brs_MarkExpirationBatch_Error + updateMarkLst.get(i).Id);
                       errorFilingLst.add(err);
                    }
                }
            }
        }catch (Exception e) {
            BOS_Utility.errorRecordLogger(className, methodName, objectName, null, BOS_Utility.sSeverity, e, null);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}