public without sharing class SAP_DocumentChecklistItemCreator2 {

    
    
// @AuraEnabled(cacheable=false)    
// public static String createDocumentChecklistItemsLwc(String documentsJson, Id recordId, String destinationCountry) {
// try {
//     // Validate inputs
//     if (String.isBlank(documentsJson) || recordId == null || String.isBlank(destinationCountry)) {
//         throw new AuraHandledException('Required parameters are missing');
//     }

//     System.debug('JSON Input: ' + documentsJson);

//     // Parse the JSON documents
//     List<DocumentWrapper> documents = (List<DocumentWrapper>)JSON.deserialize(documentsJson, List<DocumentWrapper>.class);
//     System.debug('Parsed Documents: ' + documents);

//     // Step 1: Delete all existing Document Checklist Items for the recordId
//     List<DocumentChecklistItem> itemsToDelete = [
//         SELECT Id
//         FROM DocumentChecklistItem
//         WHERE ParentRecordId = :recordId
//     ];

//     if (!itemsToDelete.isEmpty()) {
//         try {
//             delete itemsToDelete;
//             System.debug('Deleted ' + itemsToDelete.size() + ' existing Document Checklist Items.');
//         } catch (Exception e) {
//             System.debug('Error deleting existing Document Checklist Items: ' + e.getMessage());
//             throw new AuraHandledException('Error deleting existing Document Checklist Items: ' + e.getMessage());
//         }
//     }

//     // Step 2: Get all document type labels from the JSON
//     Set<String> documentTypeLabels = new Set<String>();
//     for (DocumentWrapper doc : documents) {
//         documentTypeLabels.add(doc.typeOfDocument);
//     }

//     // Step 3: Query document types based on labels in the JSON
//     Map<String, Id> documentTypeMap = new Map<String, Id>();
//     for (DocumentType docType : [
//         SELECT Id, MasterLabel 
//         FROM DocumentType 
//         WHERE MasterLabel IN :documentTypeLabels
//     ]) {
//         documentTypeMap.put(docType.MasterLabel, docType.Id);
//     }

//     // Step 4: Prepare lists for new records to insert
//     List<DocumentChecklistItem> itemsToInsert = new List<DocumentChecklistItem>();

//     // Step 5: Create new Document Checklist Items
//     for (DocumentWrapper doc : documents) {
//         // Handle null or empty values with default values
//         String countryValue = String.isNotBlank(doc.destinationCountry) ? doc.destinationCountry : destinationCountry;
//         String hagueStatus = String.isNotBlank(doc.hague) ? doc.hague : 'No';
//         String personName = String.isNotBlank(doc.personName) ? doc.personName : 'Unknown Person';
//         Decimal feeValue = String.isNotBlank(doc.fee) ? Decimal.valueOf(doc.fee) : 0.00;
//         String selectedContactID = String.isNotBlank(doc.selectedContactID) ? doc.selectedContactID : null;
//         String rejectionReason = String.isNotBlank(doc.rejectionReason) ? doc.rejectionReason : '';
//         String status =  String.isNotBlank(doc.status) ? doc.status : 'In Progress';

//         System.debug('selectedId is ==>>'+ selectedContactID);
//         Id documentTypeId = documentTypeMap.get(doc.typeOfDocument);
//         if (documentTypeId == null) {
//             System.debug('Warning: DocumentTypeId not found for type: ' + doc.typeOfDocument);
//             continue;
//         }

//         // Create new Document Checklist Item
//         DocumentChecklistItem newItem = new DocumentChecklistItem(
//             SAP_country__c = countryValue,
//             Name = personName,
//             SAP_Fees__c = feeValue,
//             Status = status,
//             DocumentTypeId = documentTypeId,
//             ParentRecordId = recordId,
//             SAP_Hague_Status__c = hagueStatus,
//             SAP_Signed_By__c = selectedContactID,
//             SAP_Rejection_Reason__c = rejectionReason
//         );
//         itemsToInsert.add(newItem);
//     }

//     // Step 6: Insert new Document Checklist Items
//     if (!itemsToInsert.isEmpty()) {
//         try {
//             insert itemsToInsert;
//             System.debug('Inserted ' + itemsToInsert.size() + ' new Document Checklist Items.');
//         } catch (Exception e) {
//             System.debug('Error inserting new Document Checklist Items: ' + e.getMessage());
//             throw new AuraHandledException('Error inserting new Document Checklist Items: ' + e.getMessage());
//         }
//     }

//     return 'Success';
// } catch (Exception e) {
//     System.debug('Error in createDocumentChecklistItemsLwc: ' + e.getMessage() + '\n' + e.getStackTraceString());
//     throw new AuraHandledException('Error processing document checklist items: ' + e.getMessage());
// }
// }


// public class DocumentWrapper {
//     @AuraEnabled public String typeOfDocument { get; set; }
//     @AuraEnabled public String destinationCountry { get; set; }
//     @AuraEnabled public String hague { get; set; }
//     @AuraEnabled public String status { get; set; }
//     @AuraEnabled public String personName { get; set; }
//     @AuraEnabled public String fee { get; set; }
//     @AuraEnabled public String selectedContactID { get; set; }
//     @AuraEnabled public String rejectionReason { get; set; }
// }


@AuraEnabled(cacheable=false)    
public static String createDocumentChecklistItemsLwc(String documentsJson, Id recordId, String destinationCountry) {
    try {
        // Validate inputs
        if (String.isBlank(documentsJson) || recordId == null || String.isBlank(destinationCountry)) {
            throw new AuraHandledException('Required parameters are missing');
        }

           System.debug('JSON Input: ' + documentsJson);

        // Parse the JSON documents
        List<DocumentWrapper> documents = (List<DocumentWrapper>)JSON.deserialize(documentsJson, List<DocumentWrapper>.class);

           System.debug('Parsed Documents: ' + documents);

        
        // Get document type map for lookups
        Set<String> documentTypeLabels = new Set<String>();
        for (DocumentWrapper doc : documents) {
            if (String.isNotBlank(doc.typeOfDocument)) {
                documentTypeLabels.add(doc.typeOfDocument);
            }
        }
        
        Map<String, Id> documentTypeMap = new Map<String, Id>();
        for (DocumentType docType : [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel IN :documentTypeLabels]) {
            documentTypeMap.put(docType.MasterLabel, docType.Id);
        }

        // Prepare records for upsert
        List<DocumentChecklistItem> itemsToUpsert = new List<DocumentChecklistItem>();
        
        for (DocumentWrapper doc : documents) {
            // Get DocumentTypeId if typeOfDocument is provided
            Id documentTypeId = String.isNotBlank(doc.typeOfDocument) ? documentTypeMap.get(doc.typeOfDocument) : null;
            
            DocumentChecklistItem item = new DocumentChecklistItem(
                Id = doc.id?.startsWith('0dd') ? Id.valueOf(doc.id) : null,  // Only use as Id if it's a valid Salesforce Id
                ParentRecordId = recordId,
                DocumentTypeId = documentTypeId,
                SAP_country__c = String.isNotBlank(doc.destinationCountry) ? doc.destinationCountry : destinationCountry,
                Name = String.isNotBlank(doc.personName) ? doc.personName : 'Unknown Person',
                SAP_Fees__c = String.isNotBlank(doc.fee) ? Decimal.valueOf(doc.fee) : 0.00,
                Status = String.isNotBlank(doc.status) ? doc.status : 'In Progress',
                SAP_Hague_Status__c = String.isNotBlank(doc.hague) ? doc.hague : 'No',
                Signed_By__c = String.isNotBlank(doc.selectedContactID) ? doc.selectedContactID : null,
                SAP_Rejection_Reason__c = String.isNotBlank(doc.rejectionReason) ? doc.rejectionReason : ''
            );
            itemsToUpsert.add(item);
            System.debug('itemToUpsert =>: '+itemsToUpsert);
        }

        if (!itemsToUpsert.isEmpty()) {
            upsert itemsToUpsert;
        }

        return 'Success';
    } catch (Exception e) {
        System.debug('Error in createDocumentChecklistItemsLwc: ' + e.getMessage() + '\n' + e.getStackTraceString());
        throw new AuraHandledException('Error processing document checklist items: ' + e.getMessage());
    }
}

public class DocumentWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String typeOfDocument { get; set; }
    @AuraEnabled public String destinationCountry { get; set; }
    @AuraEnabled public String hague { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String personName { get; set; }
    @AuraEnabled public String fee { get; set; }
    @AuraEnabled public String selectedContactID { get; set; }
    @AuraEnabled public String rejectionReason { get; set; }
    // Added other fields from JSON
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String signedByPosition { get; set; }
    @AuraEnabled public String signedByName { get; set; }
    @AuraEnabled public Boolean isExpedited { get; set; }
    @AuraEnabled public String feeDisplay { get; set; }
    @AuraEnabled public String expediteFee { get; set; }
    @AuraEnabled public String country { get; set; }
    @AuraEnabled public String baseFee { get; set; }
}

}