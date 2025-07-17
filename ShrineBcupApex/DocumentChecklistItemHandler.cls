public class DocumentChecklistItemHandler {
    public static void handleBeforeInsertOrUpdate(List<DocumentChecklistItem> newRecords, Map<Id, DocumentChecklistItem> oldMap) {
        Integer nextSequence = 1;
        String currentYear = String.valueOf(Date.today().year());

        List<DocumentChecklistItem> latestCertificates = [
            SELECT Certificate_Number__c 
            FROM DocumentChecklistItem 
            WHERE Certificate_Number__c != null 
              AND Certificate_Number__c LIKE :currentYear + '-%'  WITH SECURITY_ENFORCED
            ORDER BY Certificate_Number__c DESC 
            LIMIT 1 
        ];

        if (!latestCertificates.isEmpty()) {
            String lastCertificate = latestCertificates[0].Certificate_Number__c;
            String numericPart = lastCertificate.substring(5);
            nextSequence = Integer.valueOf(numericPart) + 1;
        }

        for (DocumentChecklistItem doc : newRecords) {
            DocumentChecklistItem oldDoc = (oldMap != null) ? oldMap.get(doc.Id) : null;
            
            Boolean statusChangedToAccepted = (oldDoc == null || (oldDoc.Status != 'Accepted' && doc.Status == 'Accepted'));
            Boolean fieldsUpdated = (oldDoc != null && (
                oldDoc.Country__c != doc.Country__c ||
                oldDoc.Fees__c != doc.Fees__c ||
                oldDoc.SOTS_Certified_copy_number__c != doc.SOTS_Certified_copy_number__c ||
                oldDoc.ParentRecordId != doc.ParentRecordId ||
                oldDoc.Hague_Status__c != doc.Hague_Status__c
            ));
            
             // Update certificate number if status is changed to Accepted or relevant fields are updated
            if ((statusChangedToAccepted || fieldsUpdated)) {
                doc.Certificate_Number__c = currentYear + '-' + padLeftWithZeros(nextSequence);
                nextSequence++;
            }
            
            if (statusChangedToAccepted) {
                doc.ApprovedDate__c = DateTime.now();
            }

            if (Trigger.isInsert && doc.Status == 'Accepted' && doc.Certificate_Number__c == null) {
                
                doc.Certificate_Number__c = currentYear + '-' + padLeftWithZeros(nextSequence);
                doc.ApprovedDate__c = DateTime.now();
                nextSequence++;
            }
        }
    }


    private static String padLeftWithZeros(Integer num) {
        String padded = String.valueOf(num);
        while (padded.length() < 5) {
            padded = '0' + padded;
        }
        return padded;
    }

    public static void handleAfterUpdate(List<DocumentChecklistItem> newRecords, Map<Id, DocumentChecklistItem> oldMap) {
        // Collect IDs of records where specified fields have changed
        Set<Id> changedRecordIds = new Set<Id>();
    
        for (DocumentChecklistItem newDoc : newRecords) {
            DocumentChecklistItem oldDoc = oldMap.get(newDoc.Id);
    
            if (oldDoc != null && (
                newDoc.Country__c != oldDoc.Country__c ||
                newDoc.Fees__c != oldDoc.Fees__c ||
                newDoc.SOTS_Certified_copy_number__c != oldDoc.SOTS_Certified_copy_number__c ||
                newDoc.ParentRecordId != oldDoc.ParentRecordId ||
                newDoc.Hague_Status__c != oldDoc.Hague_Status__c)
            ) {
                changedRecordIds.add(newDoc.Id);
            }
        }
    
        // If no records with changes, exit the method early
        if (changedRecordIds.isEmpty()) {
            return;
        }
    
        // Query related ContentDocumentLinks for changed records
        List<ContentDocumentLink> documentLinks = [
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :changedRecordIds WITH SECURITY_ENFORCED
        ];
    
        // Collect ContentDocument IDs
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
    
        // If there are no associated ContentDocuments, exit early
        if (contentDocumentIds.isEmpty()) {
            return;
        }
    
        // Define the base file name to match
        String fileName = 'Apostille_Document';
    
        // Query ContentVersion for matching ContentDocuments
        List<ContentVersion> matchingVersions = [
            SELECT Id, ContentDocumentId, Title 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
              AND Title LIKE :('%' + fileName + '%') WITH SECURITY_ENFORCED
        ];
    
        // Filter ContentDocument IDs based on matching ContentVersion records
        Set<Id> filteredContentDocumentIds = new Set<Id>();
        for (ContentVersion version : matchingVersions) {
            filteredContentDocumentIds.add(version.ContentDocumentId);
        }
    
        // If there are no filtered ContentDocuments, exit early
        if (filteredContentDocumentIds.isEmpty()) {
            return;
        }
    
        // Delete the filtered ContentDocuments
        try {
            List<ContentDocument> documentsToDelete = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id IN :filteredContentDocumentIds WITH SECURITY_ENFORCED
            ];
    
            if (!documentsToDelete.isEmpty()) {
              Database.delete(documentsToDelete, AccessLevel.USER_MODE);
            }
        } catch (Exception ex) {
            System.debug('Error during ContentDocument deletion: ' + ex.getMessage());
        }
    }
}