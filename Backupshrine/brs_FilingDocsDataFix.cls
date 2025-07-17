public class brs_FilingDocsDataFix implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public Set<Id> filingsWithoutAttachments = new Set<Id>();
    public Set<Id> filingsWithoutFiles = new Set<Id>();
    public String filingObjectName;
    public Date DateAfter;
    public Boolean isAttachment;
    public Boolean getSize;
    public String query;
    public Set<Id> filingIdsSet;
    public List <String> IncludeTypeList = new List <String> {'Annual Report','First Report','Interim Notice', 'Change of NAICS Code', 'Change of Email Address', 'Change of Agent Address',
        'Business Name Reservation','Name Change Amendment','Agent Resignation', 'Business Formation', 'Business Registration', 'Change of Business Address','Change of Agent'};
            public List <String> ExcludeFilingType = new List <String> {'Certificate of Trust','Statement Of Partnership Authority','Certificate of Limited Partnership','Certificate of Registration','Subsequent Appointment of Statutory Agent'};
                public brs_FilingDocsDataFix(String filingObjectName,Date dateAfter,Boolean isAttachment,Boolean getSize){
                    this.filingObjectName = filingObjectName;
                    this.DateAfter = dateAfter;
                    this.isAttachment = isAttachment;
                    this.getSize = getSize;
                    String query;
                    if(filingObjectName == 'Business_Filing__c'){
                        query = 'SELECT Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c,(SELECT Id,Name FROM Attachments),(SELECT ContentDocument.Title FROM ContentDocumentLinks) FROM Business_Filing__c WHERE LastModifiedDate >=: dateAfter AND Status__c IN (\'Approved\') AND Work_Order__r.Source__c != \'API\' AND Work_Order__c != null AND Type__c NOT IN(\'Mass Agent Change – Name\',\'Mass Agent Change – Address\',\'Administrative Dissolution\') AND Type__c IN:IncludeTypeList AND Filing_Type__c NOT IN:ExcludeFilingType';
                    }else if(filingObjectName == 'UCC_Filing__c'){
                        query = 'SELECT Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Amendment_Type__c,Status__c,Work_Order__c,Type__c,Other_File_Type_Name__c,(SELECT Id,Name FROM Attachments),(SELECT ContentDocument.Title FROM ContentDocumentLinks) FROM UCC_Filing__c WHERE LastModifiedDate >=: dateAfter AND Status__c IN (\'Approved\') AND Work_Order__r.Source__c != \'API\' AND Work_Order__c != null';
                    }
                    this.query = query;
                }
    public brs_FilingDocsDataFix(String filingObjectName,String query,Boolean isAttachment,Boolean getSize){
        this.filingObjectName = filingObjectName;
        this.isAttachment = isAttachment;
        this.getSize = getSize;        
        this.query = query;
    }
    public brs_FilingDocsDataFix(String filingObjectName,Set<Id> filingIdsSet,Boolean isAttachment,Boolean getSize){
        this.filingObjectName = filingObjectName;
        this.isAttachment = isAttachment;
        this.getSize = getSize; 
        this.filingIdsSet = filingIdsSet;
        String query;
        if(filingObjectName == 'Business_Filing__c'){
            query = 'SELECT Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c,(SELECT Id,Name FROM Attachments),(SELECT ContentDocument.Title FROM ContentDocumentLinks) FROM Business_Filing__c WHERE LastModifiedDate >=: dateAfter AND Status__c IN (\'Approved\') AND Work_Order__r.Source__c != \'API\' AND Work_Order__c != null AND Type__c NOT IN(\'Mass Agent Change – Name\',\'Mass Agent Change – Address\',\'Administrative Dissolution\') AND Type__c IN:IncludeTypeList AND Filing_Type__c NOT IN:ExcludeFilingType AND Id IN:filingIdsSet';
        }else if(filingObjectName == 'UCC_Filing__c'){
            query = 'SELECT Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Amendment_Type__c,Status__c,Work_Order__c,Type__c,Other_File_Type_Name__c,(SELECT Id,Name FROM Attachments),(SELECT ContentDocument.Title FROM ContentDocumentLinks) FROM UCC_Filing__c WHERE LastModifiedDate >=: dateAfter AND Status__c IN (\'Approved\') AND Work_Order__r.Source__c != \'API\' AND Work_Order__c != null AND Id IN:filingIdsSet';
        }       
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying 
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Set<Id> batchfilingsWithoutAttachments = new Set<Id>();
        Set<Id> batchfilingsWithoutFiles = new Set<Id>();   
        Map<String,String> outputNameAndAttachment = new Map<String,String>();
        Map<String,String> cvToCreateMap = new Map<String,String>();
        Set<Id> AttachmentIds =new Set<Id>();
        List<ContentVersion> conVerList = new List<ContentVersion>();
        for(sObject filing:scope){        
            Boolean isOutputAttachment = false;
            Boolean isNoticeAttachment = false;
            Boolean isOutputFile = false;
            String outputName = UCCFileMerge.getFilingOutputName(filing);
            System.debug('OutputName:::'+outputName);
            String noticeName = filing.get('Sdoc_Filing_Number__c')+' - '+System.Label.BRS_Acceptance_Notice;
            System.debug('NoticeName:::'+noticeName);
            //Check if Attachment is Present
            if(filing.getSobjects('Attachments')==null || filing.getSobjects('Attachments').isEmpty()){
                batchfilingsWithoutAttachments.add(filing.Id);
            }else{
                for(Attachment att: (List<Attachment>) filing.getSobjects('Attachments')){
                    System.debug('AttachmentName:::'+att.Name);
                    if(att.Name.contains(outputName)){
                        isOutputAttachment = true;
                        if(!getSize){
                            outputNameAndAttachment.put(outputName,att.Id);
                        }
                    }else if(att.Name.contains(noticeName)){
                        isNoticeAttachment = true;
                    }
                }
                if(!(isOutputAttachment && isNoticeAttachment)){
                    batchfilingsWithoutAttachments.add(filing.Id);
                }
            }
            //Check if Files are there 
            if(filing.getSobjects('ContentDocumentLinks')==null || filing.getSobjects('ContentDocumentLinks').isEmpty()){      
                batchfilingsWithoutFiles.add(filing.Id);
                if(isOutputAttachment && !getSize && !isAttachment){                   
                    cvToCreateMap.put(filing.Id,outputName);
                    AttachmentIds.add(outputNameAndAttachment.get(outputName));
                }
            }else{
                if(isOutputAttachment){
                    for(ContentDocumentLink cdl:(List<ContentDocumentLink>) filing.getSobjects('ContentDocumentLinks')){
                        if(cdl.ContentDocument.Title.contains(outputName)){                            
                            isOutputFile = true;
                            break;
                        }
                    }
                    if(!isOutputFile){                      
                        batchfilingsWithoutFiles.add(filing.Id);
                        if(!getSize && !isAttachment){                            
                            cvToCreateMap.put(filing.Id,outputName);
                            AttachmentIds.add(outputNameAndAttachment.get(outputName));
                        }
                    }
                    
                }
            }  
        }
        if(!getSize && !isAttachment && !cvToCreateMap.isEmpty()){
            Map<Id,Attachment> attMap=new Map<Id,Attachment>([SELECT Id,Name,Body,ParentId FROM Attachment where Id IN:AttachmentIds]);
            for(Id filingId:cvToCreateMap.keyset()){
                ContentVersion fileVersion = new ContentVersion(
                    ContentLocation = System.Label.Content_Location,
                    PathOnClient = cvToCreateMap.get(filingId) + System.Label.PDF_Type_Extension, 
                    Title = cvToCreateMap.get(filingId),
                    VersionData = attMap.get(outputNameAndAttachment.get(cvToCreateMap.get(filingId))).Body
                );
                conVerList.add(fileVersion);
            }
            insert conVerList;
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv:[ SELECT ContentDocumentId,Title FROM ContentVersion WHERE Id IN: conVerList]){
                cdlList.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId = attMap.get(outputNameAndAttachment.get(cv.Title)).ParentId
                ));
            }
            insert cdlList;
        }
        filingsWithoutAttachments.addAll(batchfilingsWithoutAttachments);
        filingsWithoutFiles.addAll(batchfilingsWithoutFiles);
    }
    
    public void finish(Database.BatchableContext BC) { 
        if(getSize){
            if(isAttachment){
                System.debug('ATTACHMENT IDS:'+filingsWithoutAttachments);
                System.debug('ATTACHMENTS SIZE:'+filingsWithoutAttachments.size());
            }else{
                System.debug('FILES IDS:'+filingsWithoutFiles);
                System.debug('FILES SIZE:'+filingsWithoutFiles.size());	
            }
        }else{
            if(isAttachment){
                String IdString ='';
                if(filingsWithoutAttachments.size()>0){            
                    for(Id filingId: filingsWithoutAttachments){
                        IdString =  IdString+','+filingId;  
                    }
                }
                NintexBatchDocGeneration ninDG = new NintexBatchDocGeneration(filingObjectName,IdString); 
                if(!test.isRunningTest()){
                Database.executeBatch(ninDG,100);
                }
            }         
        }    
    }
}