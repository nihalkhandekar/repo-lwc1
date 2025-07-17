/* DESCRIPTION: This class contains methods to search businesses for online enquiry.
*
* @AUTHOR:  Priyanka
* @DATE:    5/10/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka                         5/10/2021                         Created the first version
*********************************************************************************************/
public without sharing class BRS_ReqCopyController {
    
    public static Final String className='BRS_ReqCopyController';
    
    // wrapper class
    public class filingDataWrapper{
        @Auraenabled 
        public String filingId;
        @Auraenabled 
        public String accId;
        @Auraenabled 
        public String filingNo;
        @Auraenabled 
        public String filingType;
        @Auraenabled 
        public String filingDate;
        @Auraenabled 
        public String copyType;
        @Auraenabled 
        public Id certId;
        @Auraenabled 
        public Decimal amount;
        @Auraenabled 
        public boolean isExpediteCopy;
    }
    
    public class filingDataAndIsDocAvailableWrap{
        @Auraenabled 
        public List<filingDataWrapper> filingDataList;
        @Auraenabled 
        public Boolean noDocPresent;
    }
    
    public class workOrderNoDocWrapper{
        @Auraenabled 
        public String workOrderId;
        @Auraenabled 
        public Boolean noDocPresent;  
        @Auraenabled 
        public Boolean isOnlyPlainCopies;  
    }
    
    public class filingAttachWrapper{
        @Auraenabled 
        public String filingId;
        @Auraenabled 
        public String attachUrl;
    }
/********************************************************************************************
METHOD NAME    : getBusinessFilings
DESCRIPTION    : to get the business filings associated to the specific business
RETURN TYPE    : NA
Author         : Priyanka Sharma
********************************************************************************************/
    @AuraEnabled    
    public static filingDataAndIsDocAvailableWrap getBusinessFilings(String accountId){
        try{
            filingDataAndIsDocAvailableWrap filingDataAndIsDocWrap = new filingDataAndIsDocAvailableWrap();
            List<filingDataWrapper> filingDataList = new List<filingDataWrapper>();
            if(accountId!=null){
               //Integer limitNumber = (Integer)[Select Search_Object__c,Search_Limit__c,Include_Filters__c,Inner_Query_Limit__c,Download_Limit__c,Search_Object_fields__c,DeveloperName from BRS_online_enquiry__mdt where DeveloperName ='Copy_Request_Business_Filing' limit 1].Search_Limit__c;
                List<Business_Filing__c> businessfilingList =[Select id,Account__c, name, type__c, filing_date__c,Sdoc_Filing_Number__c from Business_Filing__c where status__c =: System.Label.Approved and Account__c =: accountId ORDER BY filing_date__c DESC]; // 
                if(!businessfilingList.isEmpty()){
                    Set<Id> busFiIdList  = new Set<Id>();
                    Boolean noDocPresent = false;
                    for(Business_Filing__c filingObj : businessfilingList){
                        filingDataWrapper filingDataObj = new filingDataWrapper();
                        filingDataObj.filingId  = filingObj.Id;
                        filingDataObj.accId  = filingObj.Account__c;
                        filingDataObj.filingNo  = filingObj.Sdoc_Filing_Number__c;
                        filingDataObj.filingType  = filingObj.type__c;
                        Date dt =  filingObj.filing_date__c !=null?filingObj.filing_date__c:null;
                        if(dt!=null){
                            DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                            String fieldValue = dtime.format('MM/dd/yyyy');  
                            filingDataObj.filingDate = fieldValue; 
                        }             
                        filingDataList.add(filingDataObj);
                        busFiIdList.add(filingObj.Id);
                    }
                    Map<Id,Attachment> filingDocMap = getAttachments(busFiIdList);                
                    Map<Id, ContentVersion> filingFilesMap = getRelatedFilesInformation(busFiIdList);
                    for(Id parentId :busFiIdList) {
                        if(filingDocMap.get(parentId)==null && filingFilesMap.get(parentId)==null){
                            noDocPresent = true;
                            break;
                        }
                    }
                    filingDataAndIsDocWrap.filingDataList = filingDataList;
                    filingDataAndIsDocWrap.noDocPresent = noDocPresent;
                }            
            }
            return filingDataAndIsDocWrap;
        }
        catch(exception ex){
            BOS_Utility.ExceptionHandler(className, 'getBusinessFilings', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /********************************************************************************************
    METHOD NAME    : createCertificateRecords
    DESCRIPTION    : method to create other request and other request details records based on the filings selected by the user
    RETURN TYPE    : workOrderNoDocWrapper
    Author         : Priyanka Sharma
    ********************************************************************************************/
    @AuraEnabled    
    public static workOrderNoDocWrapper createCertificateRecords(String filingData, String workOrderId, List<String> filingIdList, Integer amount, Boolean isUCC, Integer expeditedFee ){
        workOrderNoDocWrapper workOrderDocMap = new workOrderNoDocWrapper();
        Map<Id,Copy_Request_Details__c> filingIdMap = new Map<Id,Copy_Request_Details__c>();
        List<filingDataWrapper> filingIdWrapList  = new List<filingDataWrapper>();
        
        if(String.isNotBlank(filingData)) {  
            filingIdWrapList = (List<BRS_ReqCopyController.filingDataWrapper>) JSON.deserialize(filingData, List<BRS_ReqCopyController.filingDataWrapper>.class);
        
            if(filingIdWrapList != null && !filingIdWrapList.isEmpty()) {
                Id loggedInUser = [
                    SELECT ContactId 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()
                ].ContactId;
                
                List<Copy_Request_Details__c> certListToInsert = new List<Copy_Request_Details__c>();
                List<Copy_Request_Details__c> certListToDelete = new List<Copy_Request_Details__c>();
                Boolean noDocPresent = false;   
                Boolean isOnlyPlainCopies = true; 
                Id certificateRecordType = isUCC 
                    ? SchemaUtility.getRecordTypes('Certficate__c').get('UCC_Copy_Request')
                    : SchemaUtility.getRecordTypes('Certficate__c').get('Business_Copy_Request');
                Id copyRequestRecordType = isUCC
                    ? SchemaUtility.getRecordTypes('Copy_Request_Details__c').get('UCC_Filling_Request')
                    : SchemaUtility.getRecordTypes('Copy_Request_Details__c').get('Business_Filling_Request');
                
                //insert
                if(workOrderId == null) {
                    Certficate__c otherRequestRecord = new Certficate__c(
                        RecordTypeId = certificateRecordType,
                        Filing_Fee__c = amount,
                        status__c = System.Label.In_Progress_Label,
                        Expedited_Service_Fee__c = expeditedFee,
                        Include_Expedited_Service__c = expeditedFee != null && expeditedFee != 0,
                        Total_Fee__c = amount + expeditedFee
                    );

                    insert otherRequestRecord;
                    workOrderId = otherRequestRecord.Id;
                }
                //update
                else {
                    Certficate__c certObj = [
                        SELECT id, Total_Fee__c, Filing_Fee__c, Include_Expedited_Service__c, Expedited_Service_Fee__c
                        FROM Certficate__c
                        WHERE id =:workOrderId
                    ];
                        
                    if(certObj.Filing_Fee__c != amount || certObj.Expedited_Service_Fee__c != expeditedFee) {
                        certObj.Filing_Fee__c = amount;
                        certObj.Expedited_Service_Fee__c = expeditedFee;
                        certObj.Include_Expedited_Service__c = certObj.Expedited_Service_Fee__c != null && certObj.Expedited_Service_Fee__c != 0;
                        certObj.Total_Fee__c = amount + expeditedFee;
                        
                        update certObj;
                    }
                }

                for(Copy_Request_Details__c certObj : [
                    SELECT Id, Business_Filing__c,Account__c,Filing_Number__c,Filing_Type__c,Number_of_Copies__c,Date_Created_Format__c,Copy_Type__c 
                    FROM Copy_Request_Details__c
                    WHERE Other_Request__c =:workOrderId
                ]) {
                    filingIdMap.put(certObj.Business_Filing__c, certObj);
                }
                    
                
                //1. UCC copy details
                if(isUCC) {
                    for(Copy_Request_Details__c certObj : [
                        SELECT Id, UCC_Filing__c, UCC_Filing_Number__c, Copy_Type__c,Number_of_Copies__c 
                        FROM Copy_Request_Details__c 
                        WHERE Other_Request__c =:workOrderId
                    ]) {
                        filingIdMap.put(certObj.UCC_Filing__c, certObj);
                    }
                    
                    for(filingDataWrapper busFiWrapObj :filingIdWrapList) {
                        Copy_Request_Details__c certObj = new Copy_Request_Details__c(
                            Id = busFiWrapObj.certId,
                            RecordTypeId = copyRequestRecordType,
                            
                            UCC_Filing__c = busFiWrapObj.filingId,
                            Copy_Type__c = busFiWrapObj.copyType,
                            Amount__c = busFiWrapObj.amount,
                            Number_of_Copies__c = 1,
                            Is_Expedite_Copy__c = busFiWrapObj.isExpediteCopy != null ? busFiWrapObj.isExpediteCopy : false
                        );

                        if(busFiWrapObj.certId == null) {
                            certObj.Other_Request__c = workOrderId;
                        }
                        certListToInsert.add(certObj);

                        if(busFiWrapObj.copyType == 'Certified' && isOnlyPlainCopies) {
                            isOnlyPlainCopies = false;
                        }
                        if(filingIdMap.get(certObj.UCC_Filing__c) == null) {
                            filingIdMap.put(certObj.UCC_Filing__c, certObj);
                        }
                    }
                }
                //2. Biz Copy Details
                else {
                    for(filingDataWrapper busFiWrapObj  : filingIdWrapList){
                        Copy_Request_Details__c certObj = new Copy_Request_Details__c(
                            Id = busFiWrapObj.certId,
                            RecordTypeId = copyRequestRecordType,
                            
                            Business_Filing__c = busFiWrapObj.filingId, 
                            Copy_Type__c = busFiWrapObj.copyType,
                            Amount__c = busFiWrapObj.amount,
                            Account__c = busFiWrapObj.accId,
                            Number_of_Copies__c = 1,
                            Is_Expedite_Copy__c = busFiWrapObj.isExpediteCopy != null ? busFiWrapObj.isExpediteCopy : false
                        );
    
                        if(busFiWrapObj.certId == null) {
                            certObj.Other_Request__c = workOrderId;
                        }
                        certListToInsert.add(certObj);
    
                        if(busFiWrapObj.copyType =='Certified' && isOnlyPlainCopies) {
                            isOnlyPlainCopies = false;
                        }
    
                        if(filingIdMap.get(certObj.Business_Filing__c) == null) {
                            filingIdMap.put(certObj.Business_Filing__c, certObj); 
                        }
                    }
                }
                    
                for(Id str: filingIdList) {
                    if(filingIdMap.get(str) != null) {
                        certListToDelete.add(filingIdMap.get(str));
                        filingIdMap.remove(str);
                    }
                }
                
                Map<Id,Attachment> filingDocMap = getAttachments(filingIdMap.keySet()); 
                Map<Id,ContentVersion> filingFileMap = getRelatedFiles(filingIdMap.keySet());
                
                if((filingDocMap!=null && !filingDocMap.isEmpty()) || !filingFileMap.isEmpty()){
                    for(Id parentId :filingIdMap.keySet()) {
                        if(filingDocMap.get(parentId) == null && filingFileMap.get(parentId) == null) {                        
                            noDocPresent = true;
                            break;
                        }
                    }
                } else {
                    noDocPresent = true;
                }
                    
                workOrderDocMap.workOrderId = workOrderId;
                workOrderDocMap.noDocPresent = noDocPresent;
                workOrderDocMap.isOnlyPlainCopies = isOnlyPlainCopies;
                upsert certListToInsert;
                delete certListToDelete;
            }
        }

        return workOrderDocMap;
    }
    
/********************************************************************************************
METHOD NAME    : getSelectedBusinessFilings
DESCRIPTION    : method to return the details of selected filings when coming back to selecr filing screen (e.g from edit)
RETURN TYPE    : List<filingDataWrapper>
Author         : Priyanka Sharma
********************************************************************************************/
    @AuraEnabled    
    public static List<filingDataWrapper> getSelectedBusinessFilings(String workOrderId, Boolean isUCC){
        try{
            List<filingDataWrapper> filingDataList = new List<filingDataWrapper>();
            if(workOrderId!=null){
                if(!isUCC){
                    List<Copy_Request_Details__c> certList = [Select id,Business_Filing__c,Is_Expedite_Copy__c,Filing_Number__c,Filing_Type__c,Number_of_Copies__c,Date_Created_Format__c,Copy_Type__c,Amount__c,Account__c from Copy_Request_Details__c where Other_Request__c =:workOrderId ];                
                    
                    if(!certList.isEmpty()){
                        
                        for(Copy_Request_Details__c filingObj : certList){
                            filingDataWrapper filingDataObj = new filingDataWrapper();
                            filingDataObj.filingId  = filingObj.Business_Filing__c;
                            filingDataObj.filingNo  = filingObj.Filing_Number__c;
                            filingDataObj.filingType  = filingObj.Filing_Type__c;
                            filingDataObj.filingDate  = filingObj.Date_Created_Format__c;
                            filingDataObj.copyType  = filingObj.Copy_Type__c;
                            filingDataObj.certId = filingObj.Id;
                            filingDataObj.amount = filingObj.amount__c;
							filingDataObj.accId = filingObj.Account__c;
                            filingDataObj.isExpediteCopy = filingObj.Is_Expedite_Copy__c;
                            filingDataList.add(filingDataObj);                    
                        }
                        
                    }
                }
                else{
                    List<Copy_Request_Details__c> certRecList =[Select id,UCC_Filing__c,Is_Expedite_Copy__c,UCC_Filing_Number__c, Copy_Type__c,Amount__c from Copy_Request_Details__c where Other_Request__c =:workOrderId ]; // where status__c =: System.Label.Approved
                    if(!certRecList.isEmpty()){
                        
                        for(Copy_Request_Details__c filingObj : certRecList){
                            filingDataWrapper filingDataObj = new filingDataWrapper();
                            filingDataObj.filingId  = filingObj.UCC_Filing__c;
                            filingDataObj.filingNo  = filingObj.UCC_Filing_Number__c;
                            filingDataObj.copyType  = filingObj.Copy_Type__c;
                            filingDataObj.certId = filingObj.Id;
                            filingDataObj.amount = filingObj.amount__c;
                            filingDataObj.isExpediteCopy = filingObj.Is_Expedite_Copy__c;
                            filingDataList.add(filingDataObj);                    
                        }
                        
                    }
                }
                
            }
            return filingDataList;
        }
        catch(exception ex){
            BOS_Utility.ExceptionHandler(className, 'getSelectedBusinessFilings', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
/********************************************************************************************
METHOD NAME    : getBusinessFiDocs
DESCRIPTION    : method to return the attachments to be displayed on the confirmation screen.
RETURN TYPE    : List<filingAttachWrapper> 
Author         : Priyanka Sharma
********************************************************************************************/    
    @AuraEnabled    
    public static List<filingAttachWrapper> getBusinessFiDocs(String workOrderId){
        try{
            List<filingAttachWrapper> filingAttachWrapperList = new List<filingAttachWrapper>();
            if(workOrderId!=null){
                Map<Id, String> mapBusfiNumber= new Map<Id, String>();
                Map<Id, String> mapUCCfiNumber= new Map<Id, String>();
                List<Id> busFiIdList  = new List<Id>();
                List<Id> uccFiIdList  = new List<Id>();
                Set<Id> FiIdList  = new set<Id>();
                List<Copy_Request_Details__c> certRecList =[Select id,Business_Filing__c,Filing_Number__c,UCC_Filing__c,UCC_Filing_Number__c, Copy_Type__c from Copy_Request_Details__c where Other_Request__c =:workOrderId ]; // where status__c =: System.Label.Approved
                if(!certRecList.isEmpty()){                
                    for(Copy_Request_Details__c filingObj : certRecList){
                        if(filingObj.Business_Filing__c!=null){
                            busFiIdList.add(filingObj.Business_Filing__c);
                            FiIdList.add(filingObj.Business_Filing__c);
                            mapBusfiNumber.put(filingObj.Business_Filing__c,filingObj.Filing_Number__c);
                        }
                        else{
                            uccFiIdList.add(filingObj.UCC_Filing__c); 
                            FiIdList.add(filingObj.UCC_Filing__c);                   
                            mapUCCfiNumber.put(filingObj.UCC_Filing__c,filingObj.UCC_Filing_Number__c);
                        }
                    }
                    String query ='SELECT Id, ParentId,name FROM Attachment ' ;               
                    if(busFiIdList!=null && !busFiIdList.isEmpty()){
                        query += 'WHERE ParentId IN :busFiIdList';
                    } 
                    else{
                        query += 'WHERE ParentId IN :uccFiIdList';
                    }
                    //List<attachment> attachList = Database.query(query);
                    /*Map<Id, ContentVersion> relatedFiles = BRS_ReqCopyController.getRelatedFiles();
                    if(!attachList.isEmpty()){
                        for(Attachment attachment : attachList) {
                            if(!attachment.Name.Contains(System.Label.BRS_Acceptance_Notice)){
                                filingAttachWrapper filingAttachObj = new filingAttachWrapper();
                                if(!busFiIdList.isEmpty()){
                                    filingAttachObj.filingId = mapBusfiNumber.get(attachment.ParentId);
                                } 
                                else{
                                    filingAttachObj.filingId = mapUCCfiNumber.get(attachment.ParentId);
                                }
                                
                                filingAttachObj.attachUrl = System.Label.AttachmentDownloadLink + attachment.Id;
                                filingAttachWrapperList.add(filingAttachObj);
                            }
                        }
                    }*/
                    //List<attachment> attachList = Database.query(query);
                    Map<Id, ContentVersion> relatedFiles = BRS_ReqCopyController.getRelatedFiles(FiIdList);
                    if(!relatedFiles.isEmpty()){
                        for(ContentVersion conVer : relatedFiles.values()) {
                            //if(!conVer.Name.Contains(System.Label.BRS_Acceptance_Notice)){
                                filingAttachWrapper filingAttachObj = new filingAttachWrapper();
                                if(!busFiIdList.isEmpty()){
                                    filingAttachObj.filingId = conVer.Title.subStringBefore('-');
                                } 
                                else{
                                    filingAttachObj.filingId =conVer.Title.subStringBefore('-');
                                }
                                
                                filingAttachObj.attachUrl = System.Label.BRS_File_Download_URL + conVer.ContentDocumentId;
                                filingAttachWrapperList.add(filingAttachObj);
                            //}
                        }
                    }
                }
            }
            return filingAttachWrapperList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getBusinessFiDocs', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
/********************************************************************************************
METHOD NAME    : getAttachments
DESCRIPTION    : method to fetch attachments of the related parent, skipping acceptance notice
RETURN TYPE    : Map<Id, Attachment> 
Author         : Priyanka Sharma   
********************************************************************************************/       
    public static Map<Id, Attachment> getAttachments(Set<Id> certificateIds) {
        try{
            Map<Id, Attachment> mapCertIdAttachmentId = new Map<Id, Attachment>();
            
            for(Attachment attachment : [
                SELECT Id, ParentId, Body,Name,ContentType
                FROM Attachment
                WHERE ParentId IN :certificateIds
            ]) {
                String sObjName = attachment.ParentId.getSObjectType().getDescribe().getName();
                if(sObjName!='Certficate__c' && !attachment.Name.Contains(System.Label.BRS_Acceptance_Notice)){
                    mapCertIdAttachmentId.put(attachment.ParentId, attachment);
                }
                else if(sObjName=='Certficate__c'){
                    mapCertIdAttachmentId.put(attachment.Id, attachment);
                }
            }
            System.debug('***mapCertIdAttachmentId'+mapCertIdAttachmentId);
            return mapCertIdAttachmentId;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getAttachments', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
	/********************************************************************************************
	METHOD NAME    : getRelatedFiles
	DESCRIPTION    : method to fetch files of the related parent, skipping acceptance notice
	RETURN TYPE    : Map<Id, ContentVersion> 
	Author         : Tamkanat
	********************************************************************************************/       
	 public static Map<Id, ContentVersion> getRelatedFiles(Set<Id> parentIds) {
        try{
            Map<Id, ContentVersion> mapParentVsFile = new Map<Id, ContentVersion>();
            List<Id> contentDocumentIds = new List<Id>();
            Map<Id, Id> contentDocIdParentIdMap = new Map<Id, Id>();
            Map<Id, String> contentDocIdParentNameMap = new Map<Id, String>();
            for(ContentDocumentLink  contentLink: [SELECT LinkedEntityId,LinkedEntity.name, Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:parentIds]){
                contentDocumentIds.add(contentLink.ContentDocumentId);
                contentDocIdParentIdMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntityId);
                contentDocIdParentNameMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntity.name);
            }
           // List<ContentVersion> contVersionList = [SELECT ContentDocumentId,VersionData, Id, Title FROM ContentVersion where ContentDocumentId IN :contentDocumentIds and FileType = 'PDF'];
                for(ContentVersion contVersion: [SELECT ContentDocumentId,VersionData, Id, Title FROM ContentVersion where ContentDocumentId IN :contentDocumentIds and FileType = 'PDF']){
                    if(!contVersion.Title.Contains(System.Label.BRS_Acceptance_Notice) && contentDocIdParentIdMap.keySet().contains(contVersion.ContentDocumentId) && contVersion.Title.Contains(contentDocIdParentNameMap.get(contVersion.ContentDocumentId).Substringafter('-'))){
                        mapParentVsFile.put(contentDocIdParentIdMap.get(contVersion.ContentDocumentId),contVersion);
                    }
                }     
            return mapParentVsFile;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getRelatedFiles', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public without sharing class copyRequestsInfo {
        @InvocableVariable
        public Id workOrderID;
        @InvocableVariable
        public String flowName;
        @InvocableVariable
        public Boolean isUCC;
        @InvocableVariable
        public String toAddress;
        @InvocableVariable
        public Boolean attachDocs;
        @InvocableVariable
        public String loggedInUserName;
    } 
    
    /********************************************************************************************
    METHOD NAME    : sendemail
    DESCRIPTION    : method to send email to the loggedin user once they reach to confirmation screen
    RETURN TYPE    : NA
    Author         : Priyanka Sharma
        *@update   : BRS-7722 | Send email after some delay
    ********************************************************************************************/
    @InvocableMethod(label = 'Send email for copy request & request for info')
    public static void sendemail(List<copyRequestsInfo> results) {
        if(results != null && !results.isEmpty() && results[0].workOrderID != null) {
            Certficate__c request = [
                SELECT Id, RecordType.DeveloperName, Business__c,Status__c,Work_Order__r.Customer__r.Name,
                    (
                        SELECT Id,Copy_Type__c, Business_Filing__c,Mark_Filing__c, Business_Filing__r.Sdoc_Filing_Number__c, UCC_Filing_Number__c, UCC_Filing__c 
                        FROM Copy_Request_Details__r
                    )
                FROM Certficate__c
                WHERE Id = :results[0].workOrderID
            ];
            
            //BRS-7766 | Delete temp account share for Nintex
            UCCFileMerge.deleteAccountShare(request.Business__c);
                
            //1. Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
            //2. Get filing attachments
            List<Messaging.EmailFileAttachment> listAttachments = new List<Messaging.EmailFileAttachment>();
            List<Id> contentVersionIds = new List<Id>();
            Set<Id> setFilingIds = new Set<Id> {
                request.Id
            };
   
            //3. from ContentVersion or from attachment | BO compatibility w/ s-doc
            Map<String,Boolean> isAttachPresentMap = new Map<String,Boolean>();     
            for(Attachment doc: getAttachments(setFilingIds).values()) {
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType(doc.ContentType);
                attach.setFileName(doc.Name);
                attach.setInline(false);
                attach.Body = doc.Body;
                listAttachments.add(attach);
                isAttachPresentMap.put(doc.Name,true);
            }

            for(ContentVersion doc: getRelatedFiles(setFilingIds).values()) {
                if(!isAttachPresentMap.containsKey(doc.Title)) {
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setFileName(doc.Title);
                    attach.setInline(false);
                    attach.Body = doc.versiondata;

                    listAttachments.add(attach);
                    contentVersionIds.add(doc.Id);
                }
            } 
            //4. For Copy Request
            Set<Id> plainReqIds = new  Set<Id>();
            Set<Id> crtiReqIds = new  Set<Id>();
            Set<Id> certDetailReqIds = new  Set<Id>();
            if('UCC_Copy_Request'.equalsIgnoreCase(request.RecordType.DeveloperName) || 'Business_Copy_Request'.equalsIgnoreCase(request.RecordType.DeveloperName)) {
                Boolean isUcc = 'UCC_Copy_Request'.equalsIgnoreCase(request.RecordType.DeveloperName);
            if(request.Status__c == 'Approved'){
                for(Copy_Request_Details__c detail : request.Copy_Request_Details__r) {
                    setFilingIds.add(detail.Id);
                    if(detail.Copy_Type__c == 'Plain'){
                        if(detail.Business_Filing__c!=null){
                            plainReqIds.add(detail.Business_Filing__c);
                            certDetailReqIds.add(detail.Business_Filing__c);
                        }else if(detail.Mark_Filing__c!=null){
                            plainReqIds.add(detail.Mark_Filing__c);
                            certDetailReqIds.add(detail.Mark_Filing__c);
                        }else if(detail.UCC_Filing__c!=null){
                            plainReqIds.add(detail.UCC_Filing__c);
                            certDetailReqIds.add(detail.UCC_Filing__c);
                        }
                    }else{
                        crtiReqIds.add(detail.Id);
                        certDetailReqIds.add(detail.Id);
                    }
                }
            }
                if(!certDetailReqIds.isEmpty()){
                    for(ContentVersion doc: getRelatedFiles(certDetailReqIds).values()) {
                        if(!isAttachPresentMap.containsKey(doc.Title)) {
                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                            List<String> donNameList = new List<String>();
                            if(doc.Title.contains('.pdf')){
                                attach.setFileName(doc.Title);
                            }else{
                                attach.setFileName(doc.Title+'.pdf');
                            }
                            attach.setInline(false);
                            attach.Body = doc.versiondata;
        
                            listAttachments.add(attach);
                            isAttachPresentMap.put(doc.Title,true);
                        }
                    }
                }
                List<Attachment> attachedFilescopyreq = new List<Attachment>();
                if(!certDetailReqIds.isEmpty()){
                    attachedFilescopyreq = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId =:certDetailReqIds and  ContentType = 'application/pdf' and (NOT Name  like '%Acceptance%')];   
                }
                if(!attachedFilescopyreq.isEmpty()){
                    for(Attachment attRec: attachedFilescopyreq){
                        if(!isAttachPresentMap.containsKey(attRec.Name) && !isAttachPresentMap.containsKey(attRec.Name.removeEnd('.pdf'))) {
                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                            attach.setFileName(attRec.Name);
                            attach.setBody(attRec.body);
                            attach.setContentType(attRec.ContentType);
                            attach.setInline(false);
                            listAttachments.add(attach);
                        }
                    }
                }
                String body = '<br><br>' // add first name last name
                    + (
                        !listAttachments.isEmpty()
                        ? System.Label.Copy_Request_Email_Attach_Msg+'<br/><br/>'
                        : System.Label.Copy_Request_Email_Mail_Msg+'<br/><br/>'
                    )
                    + '<b>'+System.Label.Copy_Request_Email_Copy_Header +'</b><br/><br/>'
                    + '<html><table height="400" width="550"><tr><th style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;" align="left">'
                    + System.Label.Copy_Request_Email_Table_Header 
                    + '</th><th style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;" align="left">'
                    + System.Label.No_of_copies + '</th>';

                for(Copy_Request_Details__c detail : request.Copy_Request_Details__r) {
                    if(isUcc) {
                        body += '<tr><td style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;" >'
                            + detail.UCC_Filing_Number__c 
                            + '</td><td style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;" >1</td></tr>';
                    } else {
                        body += '<tr><td style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;">'
                        + detail.Business_Filing__r.Sdoc_Filing_Number__c 
                        + '</td><td style= "border-bottom: 1px solid black;border-top: 1px solid black; border-collapse: collapse;">1</td></tr>';
                    }
                }
                    
                body += '</table></html><br><br>' + System.Label.Copy_Request_Email_Footer;
                
                //4.1. Email template
                EmailTemplate emailTemplateRec =  [
                    SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Request_For_Copy_Email'
                ];
                
                email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, request.Id);
                String emailBody = email.getHtmlBody();
                emailBody = emailBody.replace('[Body]', body);
                emailBody = emailBody.replace('[Name]', request.Work_Order__r.Customer__r.Name);
                email.setHtmlBody(emailBody);
            }
            //5. RFI
            else if('Request_for_Information'.equalsIgnoreCase(request.RecordType.DeveloperName)) { //RFI
                EmailTemplate emailTemplateRec =  [
                    SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                    FROM EmailTemplate 
                    WHERE DeveloperName = 'BRS_Request_For_Information'
                ];
				Certficate__c cert = [SELECT Work_Order__r.Customer__r.Name
                FROM Certficate__c 
                WHERE Id = :request.Id limit 1];

                email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, request.Id);
                email.setTemplateId(emailTemplateRec.Id);
                email.setSaveAsActivity(false);
                email.setPlainTextBody(emailTemplateRec.Body);
				String emailBody = email.getHtmlBody();
                emailBody = emailBody.replace('[Name]', cert.Work_Order__r.Customer__r.Name);
                email.setHtmlBody(emailBody);
            }

            //6. Set email information
            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            email.setOrgWideEmailAddressId(owa.Id);
            email.setWhatId(request.Id);
            email.setReplyTo(System.Label.BRS_Online_Enquiry_Email);

            if(!listAttachments.isEmpty()) {
                email.setFileAttachments(listAttachments);
            }
			 if(contentVersionIds!=null){
                        email.setEntityAttachments(contentVersionIds);
                    }
            //7. Sender address
            List<String> toAddress = new List<String>{[
                SELECT Work_Order__r.Customer__r.Email
                FROM Certficate__c 
                WHERE Id = :request.Id
            ].Work_Order__r.Customer__r.Email};
            
            if(!toAddress.isEmpty()) {
                email.setToAddresses(toAddress);
                Messaging.sendEmail(new List<messaging.SingleEmailMessage> { email });
            }
        }
    }
    
/********************************************************************************************
METHOD NAME    : checkFilingNo
DESCRIPTION    : method to check if the entered ucc filing number is present in the system or not
RETURN TYPE    : filingDataWrapper
Author         : Priyanka Sharma
********************************************************************************************/
    @Auraenabled
    public static filingDataAndIsDocAvailableWrap checkFilingNo(String filingNo, String copyType, Decimal amount){
        filingDataAndIsDocAvailableWrap filingDataAndIsDocWrap = new filingDataAndIsDocAvailableWrap();
        List<filingDataWrapper> filingDataList = new List<filingDataWrapper>();
        try{
            List<UCC_Filing__c> filingRec = new List<UCC_Filing__c>();
            filingRec = [Select id,Filing_Number__c,(Select id from attachments) from UCC_Filing__c where Filing_Number__c=:filingNo and status__c =:System.Label.Approved LIMIT 1];
            if(!filingRec.isEmpty()){     
                for(UCC_Filing__c filingObj : filingRec){
                    filingDataWrapper filingData = new filingDataWrapper();
                    filingData.filingId = filingObj.Id;
                    filingData.filingNo = filingObj.Filing_Number__c;
                    filingData.copyType = copyType;
                    filingData.amount = amount;
                    if(filingObj.getSObjects('attachments')==null){
                        filingDataAndIsDocWrap.noDocPresent = true;
                    }
                    else{
                        filingDataAndIsDocWrap.noDocPresent = false;
                    }
                    filingDataList.add(filingData);
                }
            }            
        
        filingDataAndIsDocWrap.filingDataList = filingDataList; 
        return filingDataAndIsDocWrap;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'checkFilingNo', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static Map<Id, ContentVersion> getRelatedFilesInformation(Set<Id> parentIds) {
        try{
            Map<Id, ContentVersion> mapParentVsFile = new Map<Id, ContentVersion>();
            List<Id> contentDocumentIds = new List<Id>();
            Map<Id, Id> contentDocIdParentIdMap = new Map<Id, Id>();
            Map<Id, String> contentDocIdParentNameMap = new Map<Id, String>();
            for(ContentDocumentLink  contentLink: [SELECT LinkedEntityId,LinkedEntity.name, Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:parentIds]){
                contentDocumentIds.add(contentLink.ContentDocumentId);
                contentDocIdParentIdMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntityId);
                contentDocIdParentNameMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntity.name);
            }
                for(ContentVersion contVersion: [SELECT ContentDocumentId, Id, Title FROM ContentVersion where ContentDocumentId IN :contentDocumentIds and FileType = 'PDF']){
                    if(!contVersion.Title.Contains(System.Label.BRS_Acceptance_Notice) && contentDocIdParentIdMap.keySet().contains(contVersion.ContentDocumentId) && contVersion.Title.Contains(contentDocIdParentNameMap.get(contVersion.ContentDocumentId).Substringafter('-'))){
                        mapParentVsFile.put(contentDocIdParentIdMap.get(contVersion.ContentDocumentId),contVersion);
                    }
                }     
            return mapParentVsFile;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getRelatedFiles', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}