public with sharing class SAP_FileUploaderClass {
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> fetchFiles(Id recordId) {
        // First, get the ContentDocumentId(s) linked to the record
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        
        // Extract ContentDocumentIds into a list
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        // Then, get the ContentVersion(s) using those ContentDocumentIds
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        if (!contentDocumentIds.isEmpty()) {
            contentVersions = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
            ];
        }
        
        return contentVersions;
    }


    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
    
        List<ID> documentIds = new List<ID>();
        for (ContentDocumentLink link : documentLinks) {
            documentIds.add(link.ContentDocumentId);
        }
    
        Map<ID, String> documentMap = new Map<ID, String>();
        List<ContentVersion> versions = [
            SELECT ContentDocumentId, Title 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :documentIds
            AND IsLatest = true
        ];
    
        for (ContentVersion version : versions) {
            documentMap.put(version.ContentDocumentId, version.Title); // Use ContentDocumentId as key
        }
        return documentMap;
    }
    
    
    @AuraEnabled
    public static List<String> uploadFiles(List<FileInfo> fileInfos) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (FileInfo fileInfo : fileInfos) {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(fileInfo.base64);
            cv.Title = fileInfo.filename;
            cv.PathOnClient = fileInfo.filename;
            contentVersions.add(cv);
        }
        
        try {
            Database.insert(contentVersions);
            
            List<Id> contentDocumentIds = new List<Id>();
            for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
                contentDocumentIds.add(cv.ContentDocumentId);
            }
            
            return contentDocumentIds;
        } catch (Exception e) {
            System.debug('Exception in uploadFiles: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error uploading files: ' + e.getMessage());
        }
    }
    
    public class FileInfo {
        @AuraEnabled public String base64 {get; set;}
        @AuraEnabled public String filename {get; set;}
    }
    
    @AuraEnabled
    public static void deleteFile(String fileId) {
            try {
                ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Id = :fileId LIMIT 1];
                Database.delete(doc);
                // Find the ContentDocumentLink by file ID
                List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id = :fileId LIMIT 1];
    
                if (docLinks.size() > 0) {
                    ContentDocumentLink docLink = docLinks[0];
                    String contentDocumentId = docLink.ContentDocumentId;
    
                    // Delete the ContentDocumentLink record
                    Database.delete(docLink);
                    
                }
           		 } catch (Exception e) {
               			throw new AuraHandledException('Error deleting file: ' + e.getMessage());
            }
        }


    
}