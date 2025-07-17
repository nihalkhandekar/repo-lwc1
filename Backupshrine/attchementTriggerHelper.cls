/* @AUTHOR:  Sarita
* @DATE:    06/04/2021   
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita                            06/04/2021                         Created the first version
* Shreya                            28/10/2021                         BRS-7224 | Nintex Attachment conversions 
*********************************************************************************************/
public with sharing class attchementTriggerHelper {
    /**
     * @desc: Convert Filing output attachment to file
     */
    public static void convertAttachmentToFiles(List<Attachment> listAttachments) {
        User currUser = [
            SELECT Bypass_trigger__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED
        ];

        if(System.Label.brs_DisableCloning == 'False' && !currUser.Bypass_trigger__c && listAttachments != null && !listAttachments.isEmpty()) {
            List<Id> listRecordIds = new List<Id>();
            for(Attachment attachment :listAttachments) {
                listRecordIds.add(attachment.ParentId);
            }

            Map<Id, sObject> listRecords = getRecords(listRecordIds);
            Map<Id, String> filingFilesList = getRecordFiles(listRecordIds);
            Map<String, Id> mapTitleParentId = new Map<String, Id>();
            
            List<ContentVersion> listContentVersion = new List<ContentVersion>();
            List<sObject> listRecordsToUpdate = new List<sObject>();
            List<id> ackids=new List<id>();
            
            for(Attachment attachment :listAttachments) {
                Id filingId=attachment.ParentId;
                sObject record = listRecords.get(attachment.ParentId);
                String filingOutputName = UCCFileMerge.getFilingOutputName(record);
                String filingOutputNameMap= filingOutputName + '%'; 
                List<ContentDocumentLink> FinalistContent =[Select Id,ContentDocument.title, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:filingId AND (NOT ContentDocument.title LIKE :System.Label.Rejection_N_Comparable) AND (NOT ContentDocument.title LIKE :System.Label.Acceptance_N_Comparable) and ContentDocument.title LIKE :filingOutputNameMap WITH SECURITY_ENFORCED];

                if(FinalistContent.isEmpty())
                {
                    if(String.isNotBlank(filingOutputName)&& attachment.Name.startsWith(filingOutputName) && (filingFilesList.isEmpty()||filingFilesList.get(attachment.ParentId).removeEnd('.pdf') != filingOutputName)) { 
                        listContentVersion.add(new ContentVersion(
                            ContentLocation = 'S',
                            Origin = 'C',
                            PathOnClient = attachment.Name,
                            Title = attachment.Name,
                            VersionData = attachment.Body
                        ));
    
                        if(record instanceof Business_Filing__c ||  record instanceof Certficate__c)
                        {
                            if(record.get('Is_Nintex_Created__c') == false)
                            {
                                record.put('Is_Nintex_Created__c',true);
                                listRecordsToUpdate.add(record);
                            }
                        }
                        mapTitleParentId.put(attachment.Name, attachment.ParentId);
                        //BRS-7929 | Nintex UCC API: if attachment created
                        if(record instanceof UCC_Filing__c && System.Label.brs_FilingAPI == record.get('Filing_Source__c')) {
                            record.put('isDocAttached__c', true);
                            record.put('Is_Nintex_Created__c',true);
                            listRecordsToUpdate.add(record);
                            ackids.add(record.id);
                        }
                    }
                }

                //BRS-7225 | Nintex UCC API Bulk Filing Receipt : if doc got generated
                if(record instanceof Bulk_Payment__c && (record.get('Batch_Status__c') == 'Payment Processed' || record.get('Batch_Status__c') == 'Failed' || record.get('Batch_Status__c') == 'Transaction Initiated')) {
                    record.put('Batch_Status__c', 'Receipt Generated');
                    listRecordsToUpdate.add(record);
                }
            }

            
            if(!listRecordsToUpdate.isEmpty()) {	
                update listRecordsToUpdate;	
            }

             
            if(!listContentVersion.isEmpty() && BRS_SecurityUtility.checkDMLAccess(listContentVersion, 'insert')) {	
                insert listContentVersion;
                createRecordLinks(listContentVersion, mapTitleParentId);
            }
            if(!ackids.isempty())
            {
               Database.executeBatch(new UCCBulkFilingAck(ackids), 100);
            }
        }
    }
    @testvisible
    private static void createRecordLinks(List<ContentVersion> listContentVersion, Map<String, Id> mapTitleParentId) {
        List<ContentDocumentLink> listLinks = new List<ContentDocumentLink>();

        for(ContentVersion version :[
            SELECT Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :listContentVersion WITH SECURITY_ENFORCED
        ]) {
            listLinks.add(new ContentDocumentLink(
                ContentDocumentId = version.ContentDocumentId,
                LinkedEntityId = mapTitleParentId.get(version.Title), //Add attachment parentId
                ShareType = 'V', //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                Visibility = 'AllUsers' //AllUsers, InternalUsers, SharedUsers
            ));
        }

        Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(listLinks, 'insert');
        if(!listLinks.isEmpty() && accessCheck) {	
            insert listLinks;	
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
    @TestVisible
    private static Map<Id, String> getRecordFiles(List<Id> listRecordIds) {
        Map<Id,Id> docIdParentId = new  Map<Id,Id>();
        for(ContentDocumentLink contentInst : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :listRecordIds WITH SECURITY_ENFORCED
        ]) {
            docIdParentId.put(contentInst.ContentDocumentId, contentInst.LinkedEntityId);
        }

        Map<Id, String> filingFilesList = new Map<Id,String>();
        for(ContentVersion conVer : [
            SELECT Title, VersionData,ContentDocumentId 
            FROM ContentVersion 
            WHERE ContentDocumentId IN: docIdParentId.keySet() 
                AND FileExtension = 'pdf' WITH SECURITY_ENFORCED
        ]) {
            String fileTitle = conVer.Title.endswith('.pdf') ? conver.Title : conver.Title + System.Label.PDF_Type_Extension;
            filingFilesList.put(docIdParentId.get(conVer.ContentDocumentId), fileTitle);
        }

        return filingFilesList;
    }
}