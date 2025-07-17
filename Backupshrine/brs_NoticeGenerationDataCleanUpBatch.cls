global class brs_NoticeGenerationDataCleanUpBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
    public date dateAfter;
    public Set<Id> bfilingIds=new Set<Id>();
    public  brs_NoticeGenerationDataCleanUpBatch(Date recordsCreatedDate){
        dateAfter = recordsCreatedDate;
    }
    public  brs_NoticeGenerationDataCleanUpBatch(Set<Id> recordIds){
        bfilingIds = recordIds;
    }
    global void execute(SchedulableContext sc){
        Database.executebatch(this,10); 
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Date dateAfter = date.newinstance(2021, 11, 10);
        String query = 'SELECT Id, Status__c,(SELECT Id, Name FROM Attachments WHERE Name LIKE \'%Acceptance Notice.pdf\' OR Name = \'Rejection Notice.pdf\') FROM Business_Filing__c WHERE Status__c IN (\'Approved\', \'Rejected\')'; 
        
        if(dateAfter !=null){
            query= query+' AND Source__c = \'Online\' AND Type__c IN (\'Business Registration\' , \'Business Formation\', \'Change of Business Address\') AND CreatedDate >=: dateAfter';
        }else{
            query= query+' AND ID IN:bfilingIds';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Business_Filing__c> scope) {
        Map<String, List<Loop__DDP__c>> mapFilingTypeTemplates = NintexDocumentGeneration.getBulkTemplates(scope[0].Id);
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        Loop.loopMessage lm = new Loop.LoopMessage();
        for(Business_Filing__c record: scope){
            if(record.Attachments.isEmpty()) {
                if(mapFilingTypeTemplates.get(record.Status__c)!=null){
                Loop__DDP__c ddpPackage = mapFilingTypeTemplates.get(record.Status__c).get(0);
                listRequests.add(new Loop.LoopMessage.loopMessageRequest(record.Id,ddpPackage.Id,new Map<String, String> {'deploy' => ddpPackage.Loop__Custom_Integration_Options__r[0].Id}));
            }
            }
        }
        lm.requests.addAll(listRequests);                  
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {                 
            String response = lm.sendAllRequests();                    
        }
    }
    global void finish(Database.BatchableContext BC) { 
    }
}