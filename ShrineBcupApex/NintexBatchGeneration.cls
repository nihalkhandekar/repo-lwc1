/********************************************************************************************
* DESCRIPTION: Nintex document generation
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        17/9/2021                   BRS-7025 | Bulk doc generation for admin dissolution
* Rabbani                       12/12/2021                  Maintenance Filing - Pending => Approved
* Himanshi                      12/12/2021                  UCC Bulk Filing doc gen
* Shreya                        7/1/2022                    Business Rejection
*********************************************************************************************/
public with sharing class NintexBatchGeneration implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private List<Id> listRecordIds; //record ids for which to create docs
    private UCCFilingAcknowledgement.Operation operationType; //for future | based on operation type, do further processing

    //Generate Filing Output | Update if additional types to be supported
    private List<UCCFilingAcknowledgement.Operation> listFO = new List<UCCFilingAcknowledgement.Operation> {
        UCCFilingAcknowledgement.Operation.ADMIN_DISSOLUTION,
        UCCFilingAcknowledgement.Operation.API,
        UCCFilingAcknowledgement.Operation.MAINTENANCE,
        UCCFilingAcknowledgement.Operation.FORMATION
    };
    //Generate Filing Notice
    private List<UCCFilingAcknowledgement.Operation> listFN = new List<UCCFilingAcknowledgement.Operation> {
        UCCFilingAcknowledgement.Operation.MAINTENANCE,
        UCCFilingAcknowledgement.Operation.REJECTION,
        UCCFilingAcknowledgement.Operation.FORMATION
    };

    public NintexBatchGeneration(List<Id> listRecordIds, UCCFilingAcknowledgement.Operation opr) {
        this.listRecordIds = listRecordIds;
        this.operationType = opr;
    }

    public Iterable<sObject> start(Database.BatchableContext bc) { //Iterable<sObject> | 50k limits
        if(listRecordIds != null && !listRecordIds.isEmpty()) {
            String obj = SchemaUtility.getObjectFromId(listRecordIds.get(0)).getName();
    
            return Database.getQueryLocator(
                'SELECT Id, Type__c, Status__c' //add more fields if required
                +' FROM ' + obj
                +' WHERE Id IN :listRecordIds'
            );
        }

        return null;
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> records){
        generateNintexDocs(records);
    }

    /**
     * @update: Support callout, rejection notice generation | To-Do future
     *      [Can add more operations]
     */
    public void finish(Database.BatchableContext bc) {
        furtherProcessing();   
    }

    /**
     * @desc: Create sdoc attachment from sdocId
     * 
     * 1. Admin Dissolution & 2 Bulk UCC => FO
     * 3. Maintenance FO & FN
     * 4. Rejection => FN
     */
    @TestVisible
    private void generateNintexDocs(List<sObject> listRecords) {
        Loop.loopMessage lm = new Loop.LoopMessage();
        
        String obj = SchemaUtility.getObjectFromId(listRecordIds.get(0)).getName();
        Map<String, List<Loop__DDP__c>> mapNintexTemplates = NintexDocumentGeneration.getBulkTemplates(obj);
        
        for(sObject record :listRecords) { 
            //1,2, 3 | Filing Outputs
            if(listFO.contains(operationType) && !Test.isRunningTest()) {
                lm.requests.addAll(NintexDocumentGeneration.getFilingOutputRequests(record, mapNintexTemplates.get(String.valueOf(record.get('Type__c')))));
            }

            //3, 4 | Acceptance/Rejection Letters
            if(listFN.contains(operationType) && !Test.isRunningTest()) {
                lm.requests.addAll(NintexDocumentGeneration.getNoticeRequest(record, mapNintexTemplates.get(String.valueOf(record.get('Status__c'))).get(0)));
            }
        }

        // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {
            String response = lm.sendAllRequests();
        }
    }

    /**
     * @desc: Future processing required
     */
    @TestVisible
    private void furtherProcessing() {
        switch on this.operationType {
            //1. Rejection Notice
            when REJECTION {
                System.enqueueJob(new brs_BatchRefundQueueable(new Set<Id>(listRecordIds)));
    
                BRS_Utility.sendBulkEmails([
                    SELECT Id,status__c, Source__c,Account__r.Business_Email_Address__c,Business_Type__c,Work_Order__r.Customer__r.Email,Type__c 
                    FROM Business_filing__c
                    WHERE Id IN :listRecordIds WITH SECURITY_ENFORCED
                ]);
            }
            //2. Biz Maintenance
            when MAINTENANCE {
                if(!listRecordIds.isEmpty()) {
                    BRS_Utility.sendBulkEmails([
                        SELECT id,status__c,Type__c,source__c,Account__r.Business_Email_Address__c,Business_Type__c,Work_Order__r.Customer__r.Email 
                        FROM Business_filing__c 
                        WHERE Id IN :listRecordIds WITH SECURITY_ENFORCED
                    ]);
                }
            }
            //3. Send ACK attachment to filer | Chained - no callout till attachment is generated - 100 gives timeout issues
            /*when API {
                Database.executeBatch(new UCCBulkFilingAck(listRecordIds), 50);
            }*/
            //4. nop
        }
    }
}