/******************************************************************************************************
* NAME:  		BRS_AnnualReport_DataCleanUp_Batch
* DESCRIPTION:  This batch class is a part of BRS-8105 to delete attachments and files for a set of 
                Annual Reports. This is planned for one time use.
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		15th Dec, 2021
*******************************************************************************************************/

global class BRS_AnnualReport_DataCleanUp_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Date startDate = null;
    public Date endDate = null;
    public String query = '';

    public BRS_AnnualReport_DataCleanUp_Batch() {
        
        endDate = Date.newInstance(2021, 12, 10);
        startDate = Date.newInstance(2021, 11, 10);
        query = 'SELECT Id, Name, Type__c FROM Business_Filing__c WHERE Status__c = \'Approved\' AND Filing_Type__c = \'Annual Report\' AND ';
        query += 'Source__c = \'Online\' AND Filing_Date__c >= :startDate AND Filing_Date__c <= :endDate AND Due_Year__c = \'2021\'';
 
    }

    public BRS_AnnualReport_DataCleanUp_Batch(Date startDt, Date endDt, String sQuery) {
        
        endDate = endDt;
        startDate = startDt;
        query = sQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Business_Filing__c> scope) {
        Set<Id> contentDocIds = new Set<Id>();

        //Collect all business filing ids
        Set<Id> bizFilingIds = (new Map<Id,SObject>(scope)).keySet();

        //Delete Attachments on Records
        List<Attachment> linkedAttachments = [SELECT Id, ParentId 
                                              FROM Attachment 
                                              WHERE ParentId IN: bizFilingIds AND
                                                    Name LIKE '%Annual Report%'];

        if(!linkedAttachments.isEmpty()){
            delete linkedAttachments;
        }

        for (ContentDocumentLink cdLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :bizFilingIds]) {
            contentDocIds.add(cdLink.ContentDocumentId);
        }

        if(!contentDocIds.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id IN:contentDocIds AND Title LIKE '%Annual Report%'];
        }
    }

    public void finish(Database.BatchableContext bc) {}
}