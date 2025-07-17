public without sharing class DocumentChecklistItemCreator {
public class FlowInput {
    @InvocableVariable(required=true)
    public String jsonData;

    @InvocableVariable(required=true)
    public String individualApplicationId;

    @InvocableVariable(required=true)
    public String destinationCountry;

    @InvocableVariable(required=false)
    public String selectedHagueStatus;
}

@InvocableMethod(label='Create or Update Document Checklist Items' description='Creates or Updates Document Checklist Items from JSON data and associates them with an Individual Application')
public static void createDocumentChecklistItems(List<FlowInput> flowInputs) {
    // Input validation
    if (flowInputs == null || flowInputs.isEmpty()) {
        System.debug('ERROR: No flow inputs provided');
        return;
    }

    // Extract input parameters
    FlowInput input = flowInputs[0];
    String jsonInput = input.jsonData;
    System.debug('json input: ' + jsonInput);
    String applicationIdString = input.individualApplicationId;
    String defaultDestinationCountry = input.destinationCountry;
    String selectedHagueStatus = input.selectedHagueStatus;

    // Validate and convert the applicationId string to an Id
    Id applicationId;
    try {
        applicationId = Id.valueOf(applicationIdString);
        System.debug('Validated Application ID: ' + applicationId);
    } catch (StringException e) {
        System.debug('ERROR: Invalid Individual Application Id provided. ' + e.getMessage());
        return;
    }

    // Deserialize JSON input
    List<DocumentChecklistItemWrapper> wrappers;
    try {
        wrappers = (List<DocumentChecklistItemWrapper>)
            JSON.deserialize(jsonInput, List<DocumentChecklistItemWrapper>.class);
        System.debug('Deserialized Wrappers Count: ' + wrappers.size());
    } catch (Exception e) {
        System.debug('ERROR: JSON Deserialization failed: ' + e.getMessage());
        throw new AuraHandledException('Error parsing input JSON: ' + e.getMessage());
    }

    // Fetch existing items for the application
    List<DocumentChecklistItem> existingItems = [
        SELECT Id, DocumentTypeId, Name, SOTS_Certified_copy_number__c, country__c,
               (SELECT ContentDocumentId FROM ContentDocumentLinks)
        FROM DocumentChecklistItem
        WHERE ParentRecordId = :applicationId WITH SECURITY_ENFORCED
    ];
    System.debug('Existing Items Count: ' + existingItems.size());

    // Prepare a set of ContentDocumentIds linked to existing items
    Set<Id> existingContentDocumentIds = new Set<Id>();
    for (DocumentChecklistItem item : existingItems) {
        for (ContentDocumentLink link : item.ContentDocumentLinks) {
            existingContentDocumentIds.add(link.ContentDocumentId);
        }
    }

    // Query ContentDocumentLinks based on ContentDocumentIds
    Map<String, ContentDocumentLink> existingLinksMap = new Map<String, ContentDocumentLink>();
    if (!existingContentDocumentIds.isEmpty()) {
        for (ContentDocumentLink link : [
            SELECT ContentDocumentID, LinkedEntity.Type, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentID IN :existingContentDocumentIds
        ]) {
            String key = link.ContentDocumentId + '-' + link.LinkedEntityId;
            existingLinksMap.put(key, link);
        }
    }

    // Process wrappers and prepare DML lists
    List<DocumentChecklistItem> itemsToInsert = new List<DocumentChecklistItem>();
    List<DocumentChecklistItem> itemsToUpdate = new List<DocumentChecklistItem>();
    List<ContentDocumentLink> documentLinksToCreate = new List<ContentDocumentLink>();
    Set<Id> inputItemIds = new Set<Id>();

    for (DocumentChecklistItemWrapper wrapper : wrappers) {
        System.debug('Processing Wrapper: ' + JSON.serialize(wrapper));

        // Determine if this is an update or insert
        boolean isUpdate = String.isNotBlank(wrapper.id) && String.valueOf(wrapper.id).length() > 3;
        System.debug('isUpdate: ' + isUpdate);

        if (isUpdate) {
            inputItemIds.add(Id.valueOf(wrapper.id));
        }

        // Determine country based on destinationCountrySameString
        String countryValue;
        if (wrapper.destinationCountrySameString == 'yes') {
            countryValue = wrapper.country;
        } else {
            countryValue = wrapper.destinationCountry;
        }

        String hagueStatus = getHagueStatus(wrapper.hague, selectedHagueStatus);

        // Get document type ID
        Id documentTypeId = getDocumentTypeId(wrapper.typeOfDocument);

        // Find or create DocumentChecklistItem
        DocumentChecklistItem existingItem = isUpdate
            ? findExistingItem(existingItems, wrapper, documentTypeId)
            : null;
        System.debug('Existing Item Found: ' + existingItem);

        if (existingItem != null) {
            System.debug('Existing Item Found: ' + existingItem.Id);
            itemsToUpdate.add(existingItem);
            if (wrapper.uploadedFiles != null && !wrapper.uploadedFiles.isEmpty()) {
                for (Map<String, String> uploadedFile : wrapper.uploadedFiles) {
                    String documentId = uploadedFile.get('documentId');

                    if (!existingContentDocumentIds.contains(documentId)) {
                        ContentDocumentLink link = new ContentDocumentLink(
                            ContentDocumentId = documentId,
                            LinkedEntityId = existingItem.Id,
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                        );
                        documentLinksToCreate.add(link);
                    }
                }
            }
        } else {
            DocumentChecklistItem newItem = createNewDocumentChecklistItem(
                wrapper, countryValue, hagueStatus, documentTypeId, applicationId);
            itemsToInsert.add(newItem);
        }
    }

    // Identify records to delete
    List<DocumentChecklistItem> itemsToDelete = new List<DocumentChecklistItem>();
    for (DocumentChecklistItem existingItem : existingItems) {
        if (!inputItemIds.contains(existingItem.Id)) {
            itemsToDelete.add(existingItem);
        }
    }

    // Perform DML operations
    Savepoint sp = Database.setSavepoint();
    try {
        if (!itemsToUpdate.isEmpty()) {
            Database.update(itemsToUpdate, AccessLevel.USER_MODE);
        }

        if (!documentLinksToCreate.isEmpty()) {
            Database.insert(documentLinksToCreate, AccessLevel.USER_MODE);
        }

        if (!itemsToInsert.isEmpty()) {
            Database.insert(itemsToInsert, AccessLevel.USER_MODE);

            // Prepare document links for insertion
            List<ContentDocumentLink> finalDocumentLinksToCreate = new List<ContentDocumentLink>();

            // Map to track which new items correspond to which wrapper
            Map<String, DocumentChecklistItem> newItemsByWrapper = new Map<String, DocumentChecklistItem>();
            for (DocumentChecklistItem newItem : itemsToInsert) {
                for (DocumentChecklistItemWrapper wrapper : wrappers) {
                    if (wrapper.typeOfDocument == 'SOTS Certified Copies' &&
                        newItem.SOTS_Certified_copy_number__c == wrapper.copyNumber &&
                        newItem.country__c == (wrapper.destinationCountrySameString == 'yes' ? wrapper.country : wrapper.destinationCountry)) {
                        newItemsByWrapper.put(wrapper.copyNumber, newItem);
                        break;
                    }
                }
            }

            // Create document links
            for (DocumentChecklistItemWrapper wrapper : wrappers) {
                if (wrapper.uploadedFiles != null && !wrapper.uploadedFiles.isEmpty()) {
                    DocumentChecklistItem correspondingItem = newItemsByWrapper.get(wrapper.copyNumber);

                    if (correspondingItem != null) {
                        for (Map<String, String> uploadedFile : wrapper.uploadedFiles) {
                            String documentId = uploadedFile.get('documentId');

                            ContentDocumentLink link = new ContentDocumentLink(
                                ContentDocumentId = documentId,
                                LinkedEntityId = correspondingItem.Id,
                                ShareType = 'V',
                                Visibility = 'AllUsers'
                            );
                            finalDocumentLinksToCreate.add(link);
                        }
                    }
                }
            }

            // Insert document links
            if (!finalDocumentLinksToCreate.isEmpty()) {
                Database.insert(finalDocumentLinksToCreate, AccessLevel.USER_MODE);
            }
        }

        if (!itemsToDelete.isEmpty()) {
            Database.delete(itemsToDelete, AccessLevel.USER_MODE);
        }

        System.debug('Operation Completed Successfully');
    } catch (Exception e) {
        Database.rollback(sp);
        System.debug('ERROR: ' + e.getMessage());
        throw new AuraHandledException('Error processing Document Checklist Items: ' + e.getMessage());
    }
}

// Helper method to get DocumentTypeId based on document type label
private static Id getDocumentTypeId(String documentTypeLabel) {
    if (String.isNotBlank(documentTypeLabel)) {
        DocumentType documentType = [
            SELECT Id
            FROM DocumentType
            WHERE MasterLabel = :documentTypeLabel WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return documentType != null ? documentType.Id : null;
    }
    return null;
}

// Helper method to find existing item
private static DocumentChecklistItem findExistingItem(
    List<DocumentChecklistItem> existingItems,
    DocumentChecklistItemWrapper wrapper,
    Id documentTypeId
) {
    for (DocumentChecklistItem existingItem : existingItems) {
        if (existingItem.Id == wrapper.id) {
            Decimal baseFee = Decimal.valueOf(wrapper.baseFee != null ? wrapper.baseFee : '0.00');
            if (wrapper.isExpedited) {
                baseFee = baseFee + 50.00;
            }
            existingItem.Fees__c = baseFee;

            // Update country based on destinationCountrySameString
            String countryValue = wrapper.destinationCountrySameString == 'yes' ?
                wrapper.country : wrapper.destinationCountry;
            if (String.isNotBlank(countryValue) && existingItem.country__c != countryValue) {
                existingItem.country__c = countryValue;
            }

            if (String.isNotBlank(wrapper.personName) &&
                existingItem.Name != wrapper.personName) {
                existingItem.Name = wrapper.personName;
            }
            if (documentTypeId != null && existingItem.DocumentTypeId != documentTypeId) {
                existingItem.DocumentTypeId = documentTypeId;
            }
            if (wrapper.typeOfDocument == 'SOTS Certified Copies') {
                if (String.isNotBlank(wrapper.copyNumber) &&
                    existingItem.SOTS_Certified_copy_number__c != wrapper.copyNumber) {
                    existingItem.SOTS_Certified_copy_number__c = wrapper.copyNumber;
                }
            }

            return existingItem;
        }
    }
    return null;
}

// Helper method to create a new DocumentChecklistItem
private static DocumentChecklistItem createNewDocumentChecklistItem(
    DocumentChecklistItemWrapper wrapper,
    String countryValue,
    String hagueStatus,
    Id documentTypeId,
    Id applicationId
) {
    System.debug('Call the Class');
    String personName = String.isNotBlank(wrapper.personName) ? wrapper.personName : 'Test';
    String copyNumber = String.isNotBlank(wrapper.copyNumber) ? wrapper.copyNumber : '';

    Decimal feeValue = Decimal.valueOf(wrapper.baseFee != null ? wrapper.baseFee : '0.00');
    System.debug('Calculated Fees for Wrapper: ' + wrapper.baseFee);

    if (wrapper.isExpedited) {
        feeValue = feeValue + 50.00;
    }
    System.debug('Calculated Fees for Wrapper: ' + feeValue);

    return new DocumentChecklistItem(
        country__c = countryValue,
        Name = personName,
        Requester_Name__c = personName,
        Fees__c = feeValue,
        Status = 'Submitted',
        DocumentTypeId = documentTypeId,
        ParentRecordId = applicationId,
        Hague_Status__c = hagueStatus,
        SOTS_Certified_copy_number__c = copyNumber
    );
}

// Helper method to determine Hague Status
private static String getHagueStatus(String wrapperHague, String selectedHagueStatus) {
    String hagueStatus = String.isNotBlank(wrapperHague) ? wrapperHague :
        (selectedHagueStatus != null ? selectedHagueStatus : 'true');
    return (hagueStatus.equalsIgnoreCase('true') || hagueStatus.equalsIgnoreCase('Yes')) ? 'Yes' : 'No';
}

public class DocumentChecklistItemWrapper {
    public String id;
    public String typeOfDocument;
    public String destinationCountry;
    public String country;
    public String destinationCountrySameString;
    public String hague;
    public String personName;
    public String baseFee;
    public String fee;
    public Boolean isExpedited;
    public List<Map<String, String>> uploadedFiles;
    public String copyNumber;
}

@AuraEnabled(cacheable=false)
public static String createDocumentChecklistItemsLwc(String documentsJson, Id recordId, String destinationCountry) {
    try {
        if (String.isBlank(documentsJson) || recordId == null || String.isBlank(destinationCountry)) {
            throw new AuraHandledException('Required parameters are missing');
        }

        List<DocumentWrapper> documents = (List<DocumentWrapper>)JSON.deserialize(documentsJson, List<DocumentWrapper>.class);

        Set<Id> inputDocumentIds = new Set<Id>();
        for (DocumentWrapper doc : documents) {
            if (String.isNotBlank(doc.id) && doc.id.startsWith('0dd')) {
                inputDocumentIds.add(Id.valueOf(doc.id));
            }
        }

        List<DocumentChecklistItem> existingItems = [
            SELECT Id
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :recordId WITH SECURITY_ENFORCED
        ];

        List<DocumentChecklistItem> itemsToDelete = new List<DocumentChecklistItem>();
        for (DocumentChecklistItem existingItem : existingItems) {
            if (!inputDocumentIds.contains(existingItem.Id)) {
                itemsToDelete.add(existingItem);
            }
        }

        if (!itemsToDelete.isEmpty()) {
            Database.delete(itemsToDelete, AccessLevel.USER_MODE);
        }

        Set<String> documentTypeLabels = new Set<String>();
        for (DocumentWrapper doc : documents) {
            if (String.isNotBlank(doc.typeOfDocument)) {
                documentTypeLabels.add(doc.typeOfDocument);
            }
        }

        Map<String, Id> documentTypeMap = new Map<String, Id>();
        for (DocumentType docType : [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel IN :documentTypeLabels WITH SECURITY_ENFORCED]) {
            documentTypeMap.put(docType.MasterLabel, docType.Id);
        }

        Map<String, Id> personNameToItemIdMap = new Map<String, Id>();
        List<DocumentChecklistItem> itemsToUpsert = new List<DocumentChecklistItem>();
        for (DocumentWrapper doc : documents) {
            Id documentTypeId = String.isNotBlank(doc.typeOfDocument) ? documentTypeMap.get(doc.typeOfDocument) : null;

            DocumentChecklistItem item = new DocumentChecklistItem(
                Id = doc.id?.startsWith('0dd') ? Id.valueOf(doc.id) : null,
                ParentRecordId = recordId,
                Name = String.isNotBlank(doc.personName) ? doc.personName : 'Unknown Person',
                country__c = (destinationCountry == 'yes') ? doc.country : doc.destinationCountry,
                Fees__c = String.isNotBlank(doc.fee) ? Decimal.valueOf(doc.fee) : 0.00,
                BaseFees__c = String.isNotBlank(doc.baseFee) ? Decimal.valueOf(doc.baseFee) : 0.00,
                Status = String.isNotBlank(doc.status) ? doc.status : 'In Progress',
                Hague_Status__c = String.isNotBlank(doc.hague) ? doc.hague : '',
                Signed_By__c = String.isNotBlank(doc.selectedContactID) ? doc.selectedContactID : null,
                Rejection_Reason__c = String.isNotBlank(doc.customRejectionReason) ? doc.customRejectionReason : '',
                RejectionReason__c = String.isNotBlank(doc.rejectionReason) ? doc.rejectionReason : '',
                Signing_Authority__c = String.isNotBlank(doc.autority) ? doc.autority : null,
                Start_Term__c = String.isNotBlank(doc.termStart) ? convertToSalesforceDateFormat(doc.termStart) : null,
                End_Term__c = String.isNotBlank(doc.termEnd) ? convertToSalesforceDateFormat(doc.termEnd) : null,
                DocumentTypeId = documentTypeId,
                SOTS_Certified_copy_number__c =  String.isNotBlank(doc.copyNumber) ? doc.copyNumber : null
            );
            itemsToUpsert.add(item);
        }

        if (!itemsToUpsert.isEmpty()) {
            Database.upsert(itemsToUpsert, AccessLevel.USER_MODE);
        }

        for (DocumentChecklistItem item : [SELECT Id, Name FROM DocumentChecklistItem WHERE ParentRecordId = :recordId WITH SECURITY_ENFORCED]) {
            if (String.isNotBlank(item.Name)) {
                personNameToItemIdMap.put(item.Name, item.Id);
            }
        }

        Set<Id> checklistItemIds = new Set<Id>(personNameToItemIdMap.values());
        Map<Id, Set<Id>> existingLinksMap = new Map<Id, Set<Id>>();

        for (ContentDocumentLink link : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :checklistItemIds WITH SECURITY_ENFORCED
        ]) {
            if (!existingLinksMap.containsKey(link.LinkedEntityId)) {
                existingLinksMap.put(link.LinkedEntityId, new Set<Id>());
            }
            existingLinksMap.get(link.LinkedEntityId).add(link.ContentDocumentId);
        }

        List<ContentDocumentLink> documentLinksToCreate = new List<ContentDocumentLink>();
for (DocumentWrapper doc : documents) {
    String resolvedPersonName = String.isNotBlank(doc.personName) ? doc.personName : 'Unknown Person';
    Id checklistItemId = personNameToItemIdMap.get(resolvedPersonName);

    if (checklistItemId != null && String.isNotBlank(doc.contentDocumentId)) {
        if (!existingLinksMap.containsKey(checklistItemId) || !existingLinksMap.get(checklistItemId).contains(Id.valueOf(doc.contentDocumentId))) {
            ContentDocumentLink link = new ContentDocumentLink(
                ContentDocumentId = doc.contentDocumentId,
                LinkedEntityId = checklistItemId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            documentLinksToCreate.add(link);
        }
    } else {
        system.debug('Skipping link creation for document: ' + doc.contentDocumentId + ', personName: ' + doc.personName);
    }
}

if (!documentLinksToCreate.isEmpty()) {
    Database.insert(documentLinksToCreate, AccessLevel.USER_MODE);
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
            @AuraEnabled public String customRejectionReason {get; set;}
            @AuraEnabled public String autority { get; set; }
            // Added other fields from JSON
            @AuraEnabled public String type { get; set; }
            @AuraEnabled public String signedByPosition { get; set; }
            @AuraEnabled public String signedByName { get; set; }
            @AuraEnabled public Boolean isExpedited { get; set; }
            @AuraEnabled public String feeDisplay { get; set; }
            @AuraEnabled public String expediteFee { get; set; }
            @AuraEnabled public String country { get; set; }
            @AuraEnabled public String baseFee { get; set; }
            @AuraEnabled public String termStart { get; set; }
            @AuraEnabled public String termEnd { get; set; }
            @AuraEnabled public String contentDocumentId {get; set;}
            @AuraEnabled public List<Map<String, String>> uploadedFiles { get; set; }
            @AuraEnabled public String copyNumber {get; set;}
        }

     public static Date convertToSalesforceDateFormat(String inputDate) {

        if (String.isNotBlank(inputDate)) {
            // Split the input date into month, day, and year
            List<String> dateParts = inputDate.split('/');

            if (dateParts.size() == 3) {
                // Extract and format the date parts
                Integer month = Integer.valueOf(dateParts[0]);
                Integer day = Integer.valueOf(dateParts[1]);
                Integer year = Integer.valueOf(dateParts[2]);

                // Return the date in Salesforce standard format (YYYY-MM-DD)
               return Date.newInstance(year, month, day);            }
        }
        // Return null if the input is not in a valid format
        return null;
    }

}