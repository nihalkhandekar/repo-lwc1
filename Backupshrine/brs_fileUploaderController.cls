/* DESCRIPTION: This class is used to get UCC related info records and perform DML operations on them.
*
* @AUTHOR: Priyanka Sharma
* @DATE:   2020-12-02
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka Sharma                  2020-12-02                   Created the first version
*********************************************************************************************/
public without sharing class brs_fileUploaderController {
     public static Final String className='brs_fileUploaderController';
     private static final String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
	 public without sharing class ConsolidatedDocDetails{
        @AuraEnabled
        public List<contentDocDetails> contentDocDetailsList;
        @AuraEnabled
        public Long consolidatedDocSize;
     }
    public without sharing class contentDocDetails{
         @AuraEnabled
        public String documentName;
         @AuraEnabled
        public Id documentId;
         @AuraEnabled
        public String docSize;
         @AuraEnabled
        public Id docVersionId;
         @AuraEnabled
        public String docURL;
        @AuraEnabled
        public string fileUrl{get;set;}
        @AuraEnabled
        public string downloadUrl{get;set;}
		@AuraEnabled
        public string base64String{get;set;}
    }
    @AuraEnabled
    public static String deleteDocuments(String docId){
        try{
            if(!String.isBlank(docId)){
            delete [SELECT Id FROM ContentDocument WHERE Id=:docId];
             }
            return System.Label.SUCCESS_MESSAGE;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,'deleteDocuments',null,null,BOS_Utility.sSeverity,ex,null);
             Throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<contentDocDetails> getDocuments(Id recId,String fileValue){
        String strQuery;
        String whereClaus;
        try{
            List<contentDocDetails> contentDocDetailsList = new List<contentDocDetails>();
          	List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize , ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension  FROM ContentDocumentLink where LinkedEntityId =:recId];
            Set<ID> ContentDocumentIds = new Set<ID>();
            for(ContentDocumentLink contentInst : documentDetails){
                ContentDocumentIds.add(contentInst.ContentDocumentId);
            }
            List<ContentVersion> conDocVersionList=new List<ContentVersion>();
            strQuery='Select ContentDocumentId,Title,File_Type_fileupload__c,VersionData FROM ContentVersion ';
            if(fileValue!=null && fileValue!='')
            {
                whereClaus =  'where ContentDocumentId IN: ContentDocumentIds AND File_Type_fileupload__c=:fileValue';
            }
            else{
                whereClaus = ' where ContentDocumentId IN: ContentDocumentIds';
            }
            strQuery = strQuery  + whereClaus;
            ContentDistribution distribution=new ContentDistribution();
            conDocVersionList = Database.query(strQuery);
            if(!documentDetails.isEmpty()){
                for(ContentDocumentLink doc: documentDetails){
                    for(ContentVersion conVer : conDocVersionList){
                        if(doc.ContentDocumentId == conVer.ContentDocumentId){
                            contentDocDetails docDetails = new contentDocDetails();
                            docDetails.documentId = doc.ContentDocumentId;
                            docDetails.documentName = doc.ContentDocument.Title + '.'+ doc.ContentDocument.FileExtension;
                            docDetails.docSize = FileSizeToString(doc.ContentDocument.ContentSize);
                            docDetails.docVersionId = doc.ContentDocument.LatestPublishedVersionId;  
                            docDetails.docURL = brs_fileUploaderController.getURL(doc.ContentDocument.LatestPublishedVersionId);
                            distribution=contentVersionTriggerHelper.createContentDistribution(conVer);
                            for(ContentDistribution distribution1:[Select id,PdfDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentVersionId =:conVer.id])
                            {
                                docDetails.downloadUrl =distribution1.PdfDownloadUrl;
                                docDetails.fileUrl =distribution1.DistributionPublicUrl;
                            }
                            contentDocDetailsList.add(docDetails);
                        }
                    
                    }
                }
            }
            return contentDocDetailsList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,'getDocuments',null,null,BOS_Utility.sSeverity,ex,null);
             Throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static String getURL(Id versionId){
        try{
            String contentDocUrl=QnA_Constants.EMPTY_STRING;
            String domainName =  System.Url.getOrgDomainUrl().toExternalForm();
          	domainName = domainName.remove(System.Label.Remove_MySalesforce);
            String docURL = System.Label.Content_Doc_URL;
            contentDocUrl = domainName+docURL+versionId;
            return contentDocUrl;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,'getURL',null,null,BOS_Utility.sSeverity,ex,null);
            return null;
        }
    }
    public static String fileSizeToString(Long Value)
        {
            if (Value < 1024){
              return string.valueOf(Value)+' ' + System.Label.Bytes;
            }else if (Value >= 1024 && Value < (1024*1024))
            {
              Decimal kb = Decimal.valueOf(Value);
              kb = kb.divide(1024,2);
              return string.valueOf(kb)+' ' + System.Label.KB;
            }
            else if (Value >= (1024*1024) && Value < (1024*1024*1024))
            {
              Decimal mb = Decimal.valueOf(Value);
              mb = mb.divide((1024*1024),2);
              return string.valueOf(mb) +' ' + System.Label.MB;
            }
            else
            {
              Decimal gb = Decimal.valueOf(Value);
              gb = gb.divide((1024*1024*1024),2);
             
              return string.valueOf(gb) +' ' +System.Label.GB;
            }    
        } 
	
	@AuraEnabled
    public static ConsolidatedDocDetails getAllDocumentsSize(Id recId,String fileValue){
        try{
            Long consolidatedSize = 0;
            ConsolidatedDocDetails consolidatedDetails = new ConsolidatedDocDetails();
            List<contentDocDetails> contentDocDetailsList = new List<contentDocDetails>();
            List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.ContentSize,ContentDocument.Title , LinkedEntityId,ContentDocument.FileExtension,ContentDocument.LatestPublishedVersionId  FROM ContentDocumentLink where LinkedEntityId =:recId];
            Set<ID> ContentDocumentIds = new Set<ID>();
            if(!documentDetails.isEmpty()){
                for(ContentDocumentLink contentInst : documentDetails){
                    ContentDocumentIds.add(contentInst.ContentDocumentId);
                }
            }
            
            List<ContentVersion> conDocVersionList=new List<ContentVersion>();
            String strQuery='Select ContentDocumentId,Title,File_Type_fileupload__c,VersionData FROM ContentVersion ';
            String whereClaus;
            if(fileValue!=null && fileValue!='')
            {
                whereClaus =  'where ContentDocumentId IN: ContentDocumentIds AND File_Type_fileupload__c=:fileValue';
            }
            else{
                whereClaus = ' where ContentDocumentId IN: ContentDocumentIds';
            }
            strQuery = strQuery  + whereClaus;
            conDocVersionList = Database.query(strQuery);
			ContentDistribution distribution=new ContentDistribution();
            if(!documentDetails.isEmpty()){
                for(ContentDocumentLink doc: documentDetails){
                    consolidatedSize+=doc.ContentDocument.ContentSize;
                    for(ContentVersion conVer : conDocVersionList){
                        if(doc.ContentDocumentId == conVer.ContentDocumentId){
                            contentDocDetails docDetails = new contentDocDetails();
                            docDetails.documentId = doc.ContentDocumentId;
                            docDetails.documentName = doc.ContentDocument.Title + '.'+ doc.ContentDocument.FileExtension;
                            docDetails.docSize = FileSizeToString(doc.ContentDocument.ContentSize);
                            docDetails.docVersionId = doc.ContentDocument.LatestPublishedVersionId;  
                            docDetails.docURL = brs_fileUploaderController.getURL(doc.ContentDocument.LatestPublishedVersionId);
                            docDetails.base64String = EncodingUtil.base64Encode(conVer.VersionData);
							distribution=contentVersionTriggerHelper.createContentDistribution(conVer);
                            for(ContentDistribution distribution1:[Select id,PdfDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentVersionId =:conVer.id])
                            {
                                docDetails.downloadUrl =distribution1.PdfDownloadUrl;
                                docDetails.fileUrl =distribution1.DistributionPublicUrl;
                            }
                            contentDocDetailsList.add(docDetails);
                        }
                    
                    }
                    consolidatedDetails.consolidatedDocSize = consolidatedSize;
                    consolidatedDetails.contentDocDetailsList =  contentDocDetailsList;
                }
            }
            return consolidatedDetails;
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,'getAllDocumentsSize',null,null,BOS_Utility.sSeverity,ex,null);
             Throw new AuraHandledException(ex.getMessage());
        }
       
    }
    
}