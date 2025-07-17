global class BRS_BatchtoUpdateARMergedRecords implements Database.Batchable<sObject>,Database.Stateful {
    private Set<id> filingIds;
    public List<Id> listFilingIds=new List<Id>();
    public BRS_BatchtoUpdateARMergedRecords(Set<id> filingIds){
        this.filingIds=filingIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying 
        String query = 'Select Id,Name,Filing_Number__c,Sdoc_Filing_Number__c,Filing_Type__c,Type__c,Status__c from Business_Filing__c where Type__c = \'Annual Report\' AND Status__c=\'Approved\' AND Id IN:filingIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Business_Filing__c> scope) {
        Map<id,String> mapForFilingType=new Map<id,String>();
        Map<id,String> mapForAccepatance=new Map<id,String>();
        for(Business_Filing__c busdata:scope)
        {
            String filingType = UCCFileMerge.getFilingOutputName(busdata);
            String finalTitle = filingType.endswith('.pdf') ? filingType : filingType + System.Label.PDF_Type_Extension;
            mapForFilingType.put(busdata.id,finalTitle);
            mapForAccepatance.put(busdata.id,busdata.Sdoc_Filing_Number__c+ ' - Acceptance Notice.pdf');
        }
        //Process Filing Type
        Map<Id,Business_Filing__c> mapdata=new Map<Id,Business_Filing__c>(scope);
        //Delete Attachments File to Records
        List<Attachment> deleteAttachments=new List<Attachment>();
        List<Attachment> linkedAttachments = [SELECT Id,Name,ParentId FROM Attachment WHERE ParentId in: mapdata.keySet()];
        for(Attachment attach:linkedAttachments)
        {
            if(attach.Name == mapForFilingType.get(attach.ParentId) || attach.Name == mapForAccepatance.get(attach.ParentId))
            {
                deleteAttachments.add(attach);
            }
        }
        if(!deleteAttachments.isEmpty()){
            delete deleteAttachments;
        }
        
        List<id> ContentDocumentListId=new List<id>();
        List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize , ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension  FROM ContentDocumentLink where LinkedEntityId in:mapdata.keySet()];
        if(!documentDetails.isEmpty()){
            for(ContentDocumentLink documentLink:documentDetails)
            {
                if(documentLink.ContentDocument.Title == mapForFilingType.get(documentLink.LinkedEntityId))
                {
                    ContentDocumentListId.add(documentLink.ContentDocumentId);
                }
            }
            List<ContentDocument> ContentDocumentListData=[SELECT Id FROM ContentDocument WHERE Id in:ContentDocumentListId];
            delete ContentDocumentListData;
        }
        listFilingIds.addAll(mapdata.keySet());
    }
    global void finish(Database.BatchableContext BC) { 
        //Create New Nintex Attachments
         if(!listFilingIds.IsEmpty() && !test.isRunningTest()){
        Database.executeBatch(new NintexBatchGeneration(listFilingIds, UCCFilingAcknowledgement.Operation.MAINTENANCE), 10);
         }
        //Files will get created automatically from attachment trigger
    }
}