/******************************************************************************************************
* NAME:  		BRS_AnnualReport_RecreateDoc_Batch
* DESCRIPTION:  This batch class is a part of BRS-8105 to create Nintex files for a set of 
                Annual Reports. This is planned for one time use.
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		15th Dec, 2021
*******************************************************************************************************/

global class BRS_AnnualReport_RecreateDoc_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Date startDate = null;
    public Date endDate = null;
    public String query = '';

    public BRS_AnnualReport_RecreateDoc_Batch() {
        
        /*endDate = Date.newInstance(2021, 12, 10);
        startDate = Date.newInstance(2021, 11, 10);
        query = 'SELECT Id, Name, Type__c FROM Business_Filing__c WHERE Status__c = \'Approved\' AND Filing_Type__c = \'Annual Report\' AND ';
        query += 'Source__c = \'Online\' AND Filing_Date__c >= :startDate AND Filing_Date__c <= :endDate AND Due_Year__c = \'2021\'';*/

        query = 'SELECT Id, Name, Body, ParentId FROM Attachment WHERE CreatedDate >= 2023-01-01T00:00:00Z AND Name LIKE \'%Annual Report%\'';
 
    }

    public BRS_AnnualReport_RecreateDoc_Batch(String sQuery) {
        
        //endDate = endDt;
        //startDate = startDt;
        query = sQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Attachment> scope) {
        /*String obj = SchemaUtility.getObjectFromId(scope[0].Id).getName();
        Map<String, List<Loop__DDP__c>> mapFilingTypeTemplates = NintexDocumentGeneration.getBulkTemplates(obj);
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        Loop.loopMessage lm = new Loop.LoopMessage();

        //Collect all business filing ids
        Set<Id> bizFilingIds = (new Map<Id,SObject>(scope)).keySet();

        for(Business_Filing__c record : scope){
            Loop__DDP__c ddpPackage = mapFilingTypeTemplates.get(record.Type__c).get(0);
            listRequests.add(
                    new Loop.LoopMessage.loopMessageRequest(record.Id,
                                                            ddpPackage.Id,
                                                            new Map<String, String> {
                                                                'deploy' => ddpPackage.Loop__Custom_Integration_Options__r[0].Id
                                                            }
                    )
            );
        }

        lm.requests.addAll(listRequests);                  
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {                 
            String response = lm.sendAllRequests();                    
        } */  
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> listLinks = new List<ContentDocumentLink>();
        Map<String, String> mapTitleParentId = new Map<String, String>();
        Map<id,attachment> filingidsmap=new Map<id,attachment>();
        for(Attachment att : scope) {
            filingidsmap.put(att.ParentId,att); 
        }
        
        List<business_Filing__c> filinglist=[SELECT Id,Name, 
      (SELECT ContentDocumentId, LinkedEntityId,ContentDocument.Title, ContentDocument.ContentSize 
       FROM ContentDocumentLinks) 
FROM Business_Filing__c where Type__c='Annual Report' and status__c='Approved' and  LastModifiedDate >= 2023-01-01T00:00:00Z and id IN:filingidsmap.keySet()];
        
        for(Business_Filing__c bus:filinglist)
        {
            if(bus.ContentDocumentLinks.isEmpty() && filingidsmap.containsKey(bus.id))
            {
                Attachment att=filingidsmap.get(bus.id);
                      listContentVersion.add(new ContentVersion(
                ContentLocation = System.Label.Content_Location,
                PathOnClient = att.Name.split('.pdf')[0] + System.Label.PDF_Type_Extension,
                Title = att.Name.split('.pdf')[0],
                VersionData = att.Body
            ));

            mapTitleParentId.put(att.Name.split('.pdf')[0], att.ParentId);
            System.debug('parentid :: ' + att.ParentId);
            }
        }
        
        if(!listContentVersion.isEmpty()) {
            insert listContentVersion;
        }

        for(ContentVersion version : [SELECT Title, ContentDocumentId FROM ContentVersion WHERE Id IN :listContentVersion]) {
            listLinks.add(new ContentDocumentLink(
                ContentDocumentId = version.ContentDocumentId,
                LinkedEntityId = mapTitleParentId.get(version.Title), //Add attachment parentId
                ShareType = 'V', //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                Visibility = 'AllUsers' //AllUsers, InternalUsers, SharedUsers
            ));
        }

        if(!listLinks.isEmpty()) {
            insert listLinks;
        }
    }

    public void finish(Database.BatchableContext bc) {}
}