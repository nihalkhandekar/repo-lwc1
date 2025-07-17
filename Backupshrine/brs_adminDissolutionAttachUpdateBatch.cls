global class brs_adminDissolutionAttachUpdateBatch implements Database.Batchable<sObject>,Database.Stateful,schedulable{
    //BRS-8557
    public List<Id> listFilingIds=new List<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying 
        String query1 = 'Select id,name,work_Order__c,Work_order__r.Received_Date__c,Filing_Time__c,Filing_Date__c,Business_Type__c,(SELECT parentId,OldValue, NewValue,CreatedDate FROM Histories)  from Business_Filing__c where TYPE__c IN (\'Business Formation\',\'Business Registration\') and Work_Order__r.Received_Date__c >=2023-10-25T19:00:00.362+05:30 and  Work_Order__r.Received_Date__c <=2023-11-14T11:00:00.362+05:30 and Source__c=\'Online\' and Status__c=\'Approved\'';
        return Database.getQueryLocator(query1);
    }
    global void execute(Database.BatchableContext BC, List<Business_Filing__c> scope) {
		List<Business_Filing__c> newBuslist=new List<Business_Filing__c>();
        List<Work_Order__c> newWorklist=new List<Work_Order__c>();
        List<cHistory> listHistory=new List<cHistory>();
        for(Business_Filing__c bus:scope)
        {
            if(Test.isRunningTest())
            {
                listFilingIds.add(bus.id);
                cHistory historydata=new cHistory();
                historydata.Oldvalue='In-Progress';
                historydata.NewValue='Submitted - Agent acceptance pending';
                historydata.createddate=System.now();
                historydata.parentId=bus.id;
                listHistory.add(historydata);
            }
             if(!Test.isRunningTest())
            {
               for(Business_Filing__History his:bus.Histories)
              {
              cHistory historydata=new cHistory();
              historydata.Oldvalue=String.valueOf(his.OldValue);
              historydata.NewValue=String.valueOf(his.NewValue);
              historydata.createddate=his.CreatedDate;
              historydata.parentId=his.ParentId;
              listHistory.add(historydata);
              }
            }
      }
        for(Business_Filing__c bus:scope)
        {
            for(cHistory warp:listHistory)
            {
              DateTime dT = warp.Createddate;
              Date historydate = Date.newInstance(dT.year(), dT.month(), dT.day());
            if(warp.ParentId ==bus.id && (warp.OldValue == 'In-Progress' && warp.NewValue == 'Submitted - Agent acceptance pending' || warp.OldValue == 'In-Progress' && warp.NewValue == 'Approved' || warp.OldValue == 'In-Progress' && warp.NewValue == 'Submitted - Agency review pending'))  
            {
             if(warp.Createddate != bus.Work_order__r.Received_Date__c)
             {
                bus.Work_order__r.Received_Date__c=warp.Createddate;
                newWorklist.add(bus.Work_order__r);
                if(historydate !=bus.Filing_Date__c)
                {
                    bus.Filing_Date__c=historydate;
                }
                bus.Filing_Time__c=warp.Createddate.time();
                newBuslist.add(bus);  
                listFilingIds.add(bus.id);
            }
            else if(historydate !=bus.Filing_Date__c)
            {
                bus.Filing_Date__c=historydate;
                bus.Filing_Time__c=warp.Createddate.time();
                newBuslist.add(bus);
                listFilingIds.add(bus.id);
            }
          }
          
            }
        }
        if(!newWorklist.isEmpty())
        {
            Update newWorklist;
        }
            if(!newBuslist.isEmpty())
            {
                Update newBuslist;
            }

        if(!listFilingIds.isEmpty())
        {
        Map<Id,Business_Filing__c> mapdata=new Map<Id,Business_Filing__c>(scope);
        List<Attachment> linkedAttachments = [SELECT Id,ParentId FROM Attachment WHERE ParentId in: listFilingIds];
        if(!linkedAttachments.isEmpty()){
            delete linkedAttachments;
        }
        List<id> ContentDocumentListId=new List<id>();
        List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize , ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension  FROM ContentDocumentLink where LinkedEntityId in:listFilingIds];
        if(!documentDetails.isEmpty()){
            for(ContentDocumentLink documentLink:documentDetails)
            {
                ContentDocumentListId.add(documentLink.ContentDocumentId);
            }
            List<ContentDocument> ContentDocumentListData=[SELECT Id FROM ContentDocument WHERE Id in:ContentDocumentListId];
            delete ContentDocumentListData;
        }
        }
    }
        global class cHistory{
        public String OldValue;
        public String NewValue;
        public datetime Createddate;
        public Id parentId;
    }
    global void finish(Database.BatchableContext BC) { 
         if(!listFilingIds.IsEmpty() && !test.isRunningTest()){
        Database.executeBatch(new NintexBatchGeneration(listFilingIds, UCCFilingAcknowledgement.Operation.FORMATION), 10);
         }
    }
        public void execute(SchedulableContext sc) {
        Database.executeBatch(new brs_adminDissolutionAttachUpdateBatch(), 50);
    }
}