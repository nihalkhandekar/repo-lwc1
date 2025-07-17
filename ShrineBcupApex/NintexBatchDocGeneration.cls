/********************************************************************************************
* DESCRIPTION: Everyday batch to handle nintex failures
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        15/01/2022                  R7 | BRS-8589 | Batch generation for UCC, Biz & OtherRequest
*********************************************************************************************/
public with sharing class NintexBatchDocGeneration implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private Set<String> setFilingIds;
    private String obj; //which obj to process

    //1. handle ad-hoc failures
    public NintexBatchDocGeneration(String obj, String recordIds) {
        this.obj = obj;
        this.setFilingIds = new Set<String>(recordIds.split(','));
    }

    //1. handle everyday failures
    public NintexBatchDocGeneration(String obj) {
        this.obj = obj;
        this.setFilingIds = new Set<String>();
    }

    //--------- SCHEDULER -------------
    public void execute(SchedulableContext sc) {
        if(!setFilingIds.isEmpty()) {
            Database.executeBatch(new NintexBatchDocGeneration(this.obj, String.join(new List<String>(setFilingIds), ',')), 100);
        } else {
            Database.executeBatch(new NintexBatchDocGeneration(this.obj), 100);
        }
    }

    //------------- BATCH --------------
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',') 
                + ',Work_Order__r.Source__c, RecordType.Name,'
                +'('+
                    + 'SELECT Id, Name'
                    + ' FROM Attachments'
                +')'
                + (
                    this.obj == 'Certficate__c' 
                    ? (
                        ',('
                        + ' SELECT Id'
                            + ' FROM Copy_Request_Details__r'
                            + ' WHERE Copy_Type__c = \'Certified\''
                        + ')'
                    )
                    : ''
                )
            + ' FROM ' + this.obj
            + ' WHERE Status__c IN (\'Approved\', \'Rejected\')'
                + ' AND Work_Order__r.Source__c != \'API\''
                + (
                    setFilingIds != null && !setFilingIds.isEmpty()
                    ? ' AND Id IN :setFilingIds AND Is_Nintex_Created__c = false'
                    : ' AND LastModifiedDate = YESTERDAY AND Is_Nintex_Created__c = false'
                )
        );
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
        Map<String, List<Loop__DDP__c>> mapNintexTemplates = NintexDocumentGeneration.getBulkTemplates(this.obj);
        //2.5 | Copy request
        List<sObject> listCopyRequests = new List<sObject>();
        
        for(sObject record :listRecords) {
            //1. Check attachments
            List<Attachment> listAttachments = (List<Attachment>) record.getSobjects('Attachments');
            
            List<String> listAttachmentNames = new List<String>();
            if(listAttachments != null && !listAttachments.isEmpty()) { //no file uploaded & both to be generated   
                for(Attachment attach : listAttachments) {  
                    listAttachmentNames.add(attach.Name);
                }
            }
            String filingType = UCCFileMerge.getFilingType(record);
            //2. check if we need filing output
            String status = String.valueOf(record.get('Status__c'));
            if(isGenerateFilingOutput(record, status, listAttachmentNames)) {
                if(filingType !='Mass Agent Change – Name' && filingType !='Mass Agent Change – Address')
                {
                    lm.requests.addAll(NintexDocumentGeneration.getFilingOutputRequests(record, mapNintexTemplates.get(filingType)));
                    setFilingIds.add(record.Id);
                }
            }

            //2.5 check for Certified copy request
            if(isCertifiedCopyRequest(record, status)) {
                listCopyRequests.add(record);
            }

            //3. if Acceptance/Rejection Letters
            if(isGenerateFilingNotice(record, status, listAttachmentNames)) {
                if(filingType !='Mass Agent Change – Name' && filingType !='Mass Agent Change – Address')
                {
                    lm.requests.addAll(NintexDocumentGeneration.getNoticeRequest(record, mapNintexTemplates.get(status).get(0)));
                    setFilingIds.add(record.Id);
                }
            }
        }

        //2.5 copy request
        if(!listCopyRequests.isEmpty()) {
            Loop__DDP__c certifiedTemplate = NintexDocumentGeneration.getBulkTemplates('Copy_Request_Details__c').get('Certified').get(0);
            
            for(Copy_Request_Details__c copyDetail :[
                SELECT Id, Copy_Type__c, Other_Request__c,
                    Business_Filing__c, Business_Filing__r.Type__c, Business_Filing__r.Sdoc_Filing_Number__c, Business_Filing__r.Filing_Type__c,
                    UCC_Filing__c, UCC_Filing__r.Type__c, UCC_Filing__r.Sdoc_Filing_Number__c, UCC_Filing__r.Amendment_Type__c, UCC_Filing__r.Other_File_Type_Name__c,
                    Mark_Filing__c, Mark_Filing__r.Filing_Type__c, Mark_Filing__r.Sdoc_Filing_Number__c,
                    (
                        SELECT Id
                        FROM Attachments
                        WHERE Name LIKE '% - Certified Copy.pdf'
                    )
                FROM Copy_Request_Details__c
                WHERE Copy_Type__c = :System.Label.certified
                    AND Other_Request__c IN :listCopyRequests
            ]) {
                
                if(copyDetail.Attachments.isEmpty()) {
                    List<Loop.loopMessage.loopMessageRequest> listRequests = NintexDocumentGeneration.getCertifiedRequests(copyDetail, certifiedTemplate);

                    if(listRequests != null && !listRequests.isEmpty()) {
                        lm.requests.addAll(
                            listRequests      
                        );

                        setFilingIds.add(copyDetail.Other_Request__c);
                    }
                }
            }
        }

        // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {
            String response = lm.sendAllRequests();
            System.debug('response:' + response);
        }
    }

    //2. Filing output
    private Boolean isGenerateFilingOutput(sObject record, String status, List<String> listAttachmentNames) {
        return System.Label.Approved.equalsIgnoreCase(status)
            && 
            !listAttachmentNames.contains(UCCFileMerge.getFilingOutputName(record) + System.Label.PDF_Type_Extension)
            &&
            !(
                record instanceof Certficate__c
                &&
                String.valueOf(record.getSobject('RecordType').get('Name')).endswith('Copy Request')
            ); //add check for Biz & UCC Online copy request;
    }

    //2.5 copy request
    private Boolean isCertifiedCopyRequest(sObject record, String status) {
        return record instanceof Certficate__c
            && record.getSobjects('Copy_Request_Details__r') != null
            && !record.getSobjects('Copy_Request_Details__r').isEmpty();
    }

    //3. Acceptance/Rejection
    private Boolean isGenerateFilingNotice(sObject record, String status, List<String> listAttachmentNames) {
        String filingNo = record instanceof Certficate__c
            ? String.valueOf(record.get('Name'))
            : String.valueOf(record.get('Sdoc_Filing_Number__c'));

        return 
            (
                (
                    System.Label.Approved.equalsIgnoreCase(status) 
                    &&
                    !listAttachmentNames.contains(filingNo + ' - ' + System.Label.BRS_Acceptance_Notice + System.Label.PDF_Type_Extension)
                )
                || 
                (
                    System.Label.Rejected.equalsIgnoreCase(status)
                    &&
                    !listAttachmentNames.contains(System.Label.brs_RejectionNotice + System.Label.PDF_Type_Extension)
                )
            )
            &&
            !(
                record instanceof Business_Filing__c
                &&
                System.Label.Administrative_Dissolution_Label == record.get('Type__c')
            ); //admin dissolution
    }

    /**
     * @desc: Future processing required
     * => Send emails
     */
    @TestVisible
    private void furtherProcessing() {
        //Adding a 10min email delay
        String sceduledTime = '0 ' + (System.now().addMinutes(10)).minute() + ' ' + System.now().hour() + ' * * ?';

        if(!Test.isRunningTest() && !setFilingIds.isEmpty()) {
            System.schedule(this.obj + ' Batch Email' + System.now().format(), sceduledTime, new SendBatchEmails(this.obj, setFilingIds));
        }
    }
}