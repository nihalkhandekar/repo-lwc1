/* @AUTHOR:  Priyanka
* @DATE:    3/25/2021 
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka                         3/25/2021                           Created the first version
*********************************************************************************************/
public with sharing class ContentDocumentLinkTriggerHelper {
    public static final string BRS_UpdateContentDocTypeTriggerHelperLabel = 'ContentDocumentLinkTriggerHelper';
    public static final String updateDocTypeLabel = 'updateDocType';
    public static void updateDocType(List<sObject> cvObjList){
        List<Id> uccList = new List<Id>();
        List<Id> bfList = new List<Id>();
        List<Id> cdlList = new List<Id>();
        List<Id> certiList = new List<Id>();
        List<Id> conVerList = new List<Id>();
        Map<Id,Id> cdLinkIdMap = new Map<Id,Id>();
        Map<Id,String> cdDocTypeMap = new Map<Id,String>();
        for(sObject sobj: cvObjList){
            
            ContentDocumentLink cvObj = (ContentDocumentLink)sobj;
            String sObjName = cvObj.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjName == 'UCC_Filing__c' || sObjName == 'Business_Filing__c' || sObjName == 'Certficate__c')
            {
                cdlList.add(cvObj.ContentDocumentId);
                cdLinkIdMap.put(cvObj.LinkedEntityId,cvObj.ContentDocumentId);
            }
            if(sObjName=='UCC_Filing__c'){
                uccList.add(cvObj.LinkedEntityId);
            }
            if(sObjName=='Business_Filing__c'){
                bfList.add(cvObj.LinkedEntityId);
            }
            if(sObjName=='Certficate__c'){
                certiList.add(cvObj.LinkedEntityId);
            }
        }
        List<ContentVersion> csListToUpdate = new List<ContentVersion>();
        if(!cdlList.isEmpty()){
            csListToUpdate=   [Select id,Document_Type__c,ContentDocumentId from ContentVersion where ContentDocumentId in : cdlList AND ContentDocument.FileType!='SNOTE' WITH SECURITY_ENFORCED];
        }
         
        List<UCC_Filing__c> uccFilingList = new List<UCC_Filing__c>();
        if(!uccList.isEmpty()){
            uccFilingList = [Select id, Type__c,Status__c from UCC_Filing__c where id in :uccList WITH SECURITY_ENFORCED];
        }
            
        List<Business_Filing__c> busFilingList = new List<Business_Filing__c>();
        if(!bfList.isEmpty()){
             busFilingList =    [Select id, Type__c,Status__c from Business_Filing__c where id in : bfList WITH SECURITY_ENFORCED];
        }
		List<SObject> SObjectList = new List<SObject>();
		SObjectList.addAll(uccFilingList);
        SObjectList.addAll(busFilingList);
        List<Certficate__c> certificateList = new List<Certficate__c>();
        if(!certiList.isEmpty()){
             certificateList = [Select id, Certificate_Type__c from Certficate__c where id in : certiList WITH SECURITY_ENFORCED];
        }
        
        if(!SObjectList.isEmpty() && SObjectList.size()>0){
            for(SObject SObj : SObjectList){
                String sObjName = SObj.Id.getSObjectType().getDescribe().getName();
                if(sObjName=='UCC_Filing__c'){
                    UCC_Filing__c Objvar = (UCC_Filing__c)SObj;
                }
                if(sObjName=='Business_Filing__c'){
                    Business_Filing__c Objvar = (Business_Filing__c)SObj;
                }
                Id objId = (Id)SObj.get('Id');
                if(SObj.get('Status__c')==System.Label.Approved){
                    cdDocTypeMap.put(cdLinkIdMap.get(objId),System.Label.Acceptance_Letter);
                }
                else if(SObj.get('Status__c')==System.Label.Rejected){
                    cdDocTypeMap.put(cdLinkIdMap.get(objId),System.Label.Rejection_Letter);
                }
                else{
                    if(SObj.get('Type__c')!=null){ 
                        String status = (String) SObj.get('Type__c');
                        cdDocTypeMap.put(cdLinkIdMap.get(objId),status);
                    }
                }
            }
        }
        if(!certificateList.isEmpty() && certificateList.size()>0){
            for(Certficate__c certObj : certificateList){
                if(certObj.Certificate_Type__c!=null){
                    cdDocTypeMap.put(cdLinkIdMap.get(certObj.Id),certObj.Certificate_Type__c +' ' +System.Label.Certificate_of_Legal_Existence);
                }
            }
        }
        for(ContentVersion cvObj : csListToUpdate){
            cvObj.Document_Type__c = cdDocTypeMap.get(cvObj.ContentDocumentId);
        }
        try{
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(csListToUpdate, 'update');
            if(bAccessCheck){
            	update csListToUpdate;
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(BRS_UpdateContentDocTypeTriggerHelperLabel, updateDocTypeLabel,null,null,null,ex,ex.getMessage());
        }
    }
    public static void provideAccessForCommunityUsers(List<sObject> NewList){
         for(sObject sObjInst: NewList){
            ContentDocumentLink cvObj = (ContentDocumentLink)sObjInst;
            cvObj.Visibility = 'AllUsers';
         }
     }
     public static void deleteAttachmentAfterInsert(List<sObject> cvObjList) {
        try{
            Map<id,String> ContentVersionTitleMap=new Map<id,String>();
            Map<id,String> attachmentNameMap=new Map<id,String>();
            Map<id,Attachment> attachmentMap=new Map<id,Attachment>();
            Set<Id> newSet = new Set<Id>();
            List<id> filingids=new List<id>();
            for(sObject sobj: cvObjList) {
             ContentDocumentLink cvObj = (ContentDocumentLink)sobj;
             String objectName = cvObj.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(ObjectName == 'Business_Filing__c' || ObjectName == 'UCC_Filing__c' || ObjectName == 'Certficate__c')
           {  
              filingids.add(cvObj.LinkedEntityId);
           }
           
    }
    if(!filingids.isEmpty())
    {
      Map<Id, sObject> listRecords = getRecords(filingids);
      for(Id ids:filingids)
      {
              sObject record = listRecords.get(ids);
              String filingOutputName = UCCFileMerge.getFilingOutputName(record);
              String finalTitle = filingOutputName.endswith('.pdf') ? filingOutputName : filingOutputName + System.Label.PDF_Type_Extension;
              ContentVersionTitleMap.put(Ids,finalTitle);
      }
            List<Attachment> deletionListAttachment=new List<Attachment>();
            for(Attachment att:[select id,parentId,Name from Attachment where parentId IN:ContentVersionTitleMap.keySet() AND (NOT Name LIKE :System.Label.Rejection_N_Comparable) AND (NOT Name LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED])
            {
              String AttachmentName = att.Name.endswith('.pdf') ? att.Name : att.Name + System.Label.PDF_Type_Extension;
               if(AttachmentName == ContentVersionTitleMap.get(att.parentId))
               {
                   deletionListAttachment.add(att);
               }
               else
               {
                  attachmentNameMap.put(att.parentId,att.Name);
                  attachmentMap.put(att.parentId,att);
                  newSet.add(att.parentId);
               }
            }
        if(!newSet.isEmpty())
        {
            
            for(ContentDocumentLink con:[Select Id,ContentDocument.title, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:newSet AND (NOT ContentDocument.title LIKE :System.Label.Rejection_N_Comparable) AND (NOT ContentDocument.title LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED])
            {
              String finaldataTitle = con.ContentDocument.title.endswith('.pdf') ? con.ContentDocument.title : con.ContentDocument.title + System.Label.PDF_Type_Extension;
              if(finaldataTitle == attachmentNameMap.get(con.LinkedEntityId))
              {
                  deletionListAttachment.add(attachmentMap.get(con.LinkedEntityId));
              }
            }
        }
            if(!deletionListAttachment.isEmpty())
            {
              delete deletionListAttachment;
            }
    }
             }
        catch(Exception ex){
        BOS_Utility.ExceptionHandler('ContentDocumentLinkTriggerHelper', 'deleteAttachmentAfterInsert',null,null,null,ex,ex.getMessage());
    }  
}
private static Map<Id, sObject> getRecords(List<Id> listRecordIds) {
    String obj = SchemaUtility.getObjectFromId(listRecordIds.get(0)).getName();
    return new Map<Id, sObject>(Database.query(
        'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
        +' FROM ' + obj
        +' WHERE Id IN :listRecordIds WITH SECURITY_ENFORCED'
    ));
}
}