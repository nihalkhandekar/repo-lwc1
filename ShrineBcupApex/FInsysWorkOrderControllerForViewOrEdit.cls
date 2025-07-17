public with sharing class FInsysWorkOrderControllerForViewOrEdit {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getActivityData() {
        List<Map<String, Object>> activityDataList = new List<Map<String, Object>>();

        for (FinSys_Activity_SubActivity__mdt record : [
            SELECT Activity__c, Sub_Activity__c, Program_Code__c
            FROM FinSys_Activity_SubActivity__mdt
        ]) {
            Map<String, Object> activityData = new Map<String, Object>();
            activityData.put('activity', record.Activity__c);
            activityData.put('subActivity', record.Sub_Activity__c);
            activityData.put('programCode', record.Program_Code__c);
            activityDataList.add(activityData);
        }

        return activityDataList;
    }


    @AuraEnabled
    public static List<Contact> searchContacts(String searchName) {
        if (String.isBlank(searchName)) {
            return null; // Return null if the search string is invalid or less than 3 characters
        }
        
        // Get the Record Type ID for "FinSys Customers"
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers' LIMIT 1].Id;

        // Query matching contacts by name, filtering by the specific record type
        List<Contact> contacts = [
            SELECT Id, Salutation, FirstName, LastName, MiddleName, Suffix, Organization__c , MailingStreet, MailingAddress2__c, MailingCity, MailingState, 
            MailingPostalCode, MailingCountry,  Deliquent__c, Email, Phone	
            FROM Contact 
            WHERE Name LIKE :('%' + searchName + '%')
            AND RecordTypeId = :recordTypeId
        ];
        
        // Return null if no contacts found, otherwise return the list
        return contacts.isEmpty() ? null : contacts;
    }

    @AuraEnabled
    public static Map<String, Object> createWorkOrder(String workOrderDataJson) {
        try {
            // Deserialize JSON string to a Map for easy access
            Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(workOrderDataJson);

            // Extract customer details from the input
            String selectedCustomerId = (String) workOrderData.get('selectedCustomerId');
            String batchId;
            Contact customer;
            Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');
            Map<String, Object> addressDetails = (Map<String, Object>) customerDetails.get('address');
            
            String recordId = (String) workOrderData.get('recordId');
            if (!String.isBlank(recordId)) {
                 // Extract and validate the default activity
                batchId = (String) workOrderData.get('defaultActivity');
                String defaultActivity = (String) workOrderData.get('defaultActivity');
                if (String.isBlank(defaultActivity)) {
                    throw new AuraHandledException('Default activity is required to create a work order.');
                }

                // Query the Batch__c record for the default activity
                Batch__c batch = [
                    SELECT Id, Name, Batch_Status__c, Batch_Name__c
                    FROM Batch__c
                    WHERE Id = :defaultActivity
                    LIMIT 1
                ];

                // Validate the batch status
                if (batch.Batch_Status__c == 'Sealed') {
                    throw new AuraHandledException(
                        'Batch "' + batch.Name + '" for activity "' + batch.Batch_Name__c + '" is sealed. Please reopen the batch to proceed.'
                    );
                }

                // Assign the batch ID to work order data
                workOrderData.put('defaultBatchId', batch.Id);


                 // Determine whether to update or create a contact
                
                if (!String.isBlank(selectedCustomerId)) {
                    // Use the provided JSON details to link an existing contact to the work order without fetching from the database
                    customer = new Contact(
                        Id = selectedCustomerId,
                        FirstName = (String) customerDetails.get('firstName'),
                        MiddleName = (String) customerDetails.get('middleInitial'),
                        LastName = (String) customerDetails.get('lastName'),
                        Organization__c = (String) customerDetails.get('organizationName'),
                        Email = (String) customerDetails.get('emailAddress'),
                        Phone = (String) customerDetails.get('phoneNumber'),
                        MailingStreet = (String) addressDetails.get('street'),
                        MailingAddress2__c = (String) addressDetails.get('address2'),
                        MailingCity = (String) addressDetails.get('city'),
                        MailingState = (String) addressDetails.get('state'),
                        MailingPostalCode = (String) addressDetails.get('zipCode'),
                        MailingCountry = (String) addressDetails.get('country')
                    );
                } 

            }
            else{
                   // Extract and validate the default activity
                    String defaultActivity = (String) workOrderData.get('defaultActivity');
                    if (String.isBlank(defaultActivity)) {
                        throw new AuraHandledException('Default activity is required to create a work order.');
                    }

                    // Query Batch__c to find an existing batch for the default activity created today
                    Batch__c existingBatch;
                    try {
                        existingBatch = [
                            SELECT Id, Name, Batch_Status__c, Batch_Name__c
                            FROM Batch__c
                            WHERE Batch_Name__c = :defaultActivity
                            AND CreatedDate = TODAY
                            LIMIT 1
                        ];
                    } catch (Exception e) {
                        System.debug('Error querying Batch__c: ' + e.getMessage());
                    }

                    // Check if a batch exists
                    if (existingBatch == null) {
                        // Create a new batch for the activity if none exists
                        Batch__c newBatch = new Batch__c();
                        newBatch.Batch_Name__c = defaultActivity;
                        newBatch.Name = defaultActivity;
                        newBatch.Batch_Status__c = 'Open';
                        insert newBatch;

                        System.debug('Created new batch for activity: ' + defaultActivity + ' - ' + newBatch);

                        // Assign new batch ID to work order data
                        workOrderData.put('defaultBatchId', newBatch.Id);
                        batchId = newBatch.Id;
                    } else {
                        // Process the existing batch
                        if (existingBatch.Batch_Status__c == 'Sealed') {
                            throw new AuraHandledException(
                                'Batch "' + existingBatch.Name + '" for activity "' + existingBatch.Batch_Name__c + '" is sealed. Please reopen the batch to proceed.'
                            );
                        }
                        // Assign existing batch ID to work order data
                        workOrderData.put('defaultBatchId', existingBatch.Id);
                        batchId = existingBatch.Id;
                    }

                    System.debug('Default Batch ID: ' + batchId);

                    if (!String.isBlank(selectedCustomerId)) {
                        // Use the provided JSON details to link an existing contact to the work order without fetching from the database
                        customer = new Contact(
                            Id = selectedCustomerId,
                            FirstName = (String) customerDetails.get('firstName'),
                            MiddleName = (String) customerDetails.get('middleInitial'),
                            LastName = (String) customerDetails.get('lastName'),
                            Organization__c = (String) customerDetails.get('organizationName'),
                            Email = (String) customerDetails.get('emailAddress'),
                            Phone = (String) customerDetails.get('phoneNumber'),
                            MailingStreet = (String) addressDetails.get('street'),
                            MailingAddress2__c = (String) addressDetails.get('address2'),
                            MailingCity = (String) addressDetails.get('city'),
                            MailingState = (String) addressDetails.get('state'),
                            MailingPostalCode = (String) addressDetails.get('zipCode'),
                            MailingCountry = (String) addressDetails.get('country')
                        );
                    } else {
                        // Create a new contact if no selectedCustomerId is provided
                        customer = createNewContact(customerDetails, addressDetails);
                    }

            }
    
            // Get work order result map
            Map<String, Object> workOrderResult = createWorkOrderForCustomer(customer, workOrderData);

            // Extract ID and Sequence Number
            Id workOrderId = (Id) workOrderResult.get('id');

            List<Object> rawTransactions = (List<Object>) workOrderData.get('transactions');
            List<Object> rawPayments = (List<Object>) workOrderData.get('payments');
            String transactionType = (String) workOrderData.get('transactionType');
            
            
            processTransactionsAndPayments(rawTransactions, rawPayments, workOrderId, batchId, transactionType);

            uploadAndLinkDocuments(workOrderData, workOrderId);

            IndividualApplication insertedRecord = [SELECT Id, Sequence_Number__c FROM IndividualApplication WHERE Id = :workOrderId LIMIT 1];
            workOrderResult.put('sequenceNumber', insertedRecord.Sequence_Number__c);

            return workOrderResult;
    
        } catch (AuraHandledException ahe) {
            throw ahe; // Rethrow handled exceptions with meaningful messages
        } catch (Exception e) {
            System.debug('Error in createWorkOrder: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    // Helper method to create a new contact
    private static Contact createNewContact(Map<String, Object> customerDetails, Map<String, Object> addressDetails) {
        Contact newCustomer = new Contact();
        newCustomer.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers' LIMIT 1].Id;
        newCustomer.FirstName = (String) customerDetails.get('firstName');
        newCustomer.MiddleName = (String) customerDetails.get('middleInitial');
        newCustomer.LastName = (String) customerDetails.get('lastName');
        newCustomer.Organization__c = (String) customerDetails.get('organizationName');
        newCustomer.Email = (String) customerDetails.get('emailAddress');
        newCustomer.Phone = (String) customerDetails.get('phoneNumber');
        newCustomer.MailingStreet = (String) addressDetails.get('street');
        newCustomer.MailingAddress2__c = (String) addressDetails.get('address2');
        newCustomer.MailingCity = (String) addressDetails.get('city');
        newCustomer.MailingState = (String) addressDetails.get('state');
        newCustomer.MailingPostalCode = (String) addressDetails.get('zipCode');
        newCustomer.MailingCountry = (String) addressDetails.get('country');

        insert newCustomer;
        System.debug('Created new customer: ' + newCustomer);

        return newCustomer;
    }

    // Helper method to create a work order for a customer
    private static  Map<String, Object> createWorkOrderForCustomer(Contact customer, Map<String, Object> workOrderData) {
        // Check if a recordId exists in workOrderData to determine whether to update or insert
        String recordId = (String) workOrderData.get('recordId');
        IndividualApplication individualAppWorkOrder;

        if (String.isNotBlank(recordId)) {
            // Fetch existing work order for update
            individualAppWorkOrder = [
                SELECT Id, Destination__c, LicenseTypeId, Category, Contact__c,
                    Last_Name__c, Middle_Name__c, First_Name__c, Address_Line_1__c,
                    Suite_Apartment_Floor__c, City__c, State__c, Country__c,
                    Zip_Code__c, Organization_Name__c, Email_Address__c, Sequence_Number__c,
                    Cell_Phone_Number__c, Work_Order_Status__c, Work_Order_Comments__c
                FROM IndividualApplication
                WHERE Id = :recordId
                LIMIT 1
            ];
            System.debug('Updating existing work order: ' + individualAppWorkOrder);
        } else {
            // Create new work order
            individualAppWorkOrder = new IndividualApplication();
            individualAppWorkOrder.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' AND DeveloperName = 'FinSys' LIMIT 1].Id;
            // Map work order-specific fields
            individualAppWorkOrder.Destination__c = 'Destination';
            individualAppWorkOrder.LicenseTypeId = '0eh3S0000003Ix2QAE';
            individualAppWorkOrder.Category = 'License';
            System.debug('Creating new work order');
        }

        // Map fields from the passed customer object
        individualAppWorkOrder.Contact__c = customer.Id; // Link the Contact ID without updating it
        individualAppWorkOrder.Last_Name__c = customer.LastName;
        individualAppWorkOrder.Middle_Name__c = customer.MiddleName;
        individualAppWorkOrder.First_Name__c = customer.FirstName;
        individualAppWorkOrder.Organization_Name__c = customer.Organization__c;
        individualAppWorkOrder.Email_Address__c = customer.Email;
        individualAppWorkOrder.Cell_Phone_Number__c = customer.Phone;
        individualAppWorkOrder.Address_Line_1__c = customer.MailingStreet;
        individualAppWorkOrder.Suite_Apartment_Floor__c = customer.MailingAddress2__c;
        individualAppWorkOrder.City__c = customer.MailingCity;
        individualAppWorkOrder.State__c = customer.MailingState;
        individualAppWorkOrder.Country__c = customer.MailingCountry;
        individualAppWorkOrder.Zip_Code__c = customer.MailingPostalCode;

        
        individualAppWorkOrder.Work_Order_Status__c = (String) workOrderData.get('workOrderStatus');
        individualAppWorkOrder.Work_Order_Comments__c = (String) workOrderData.get('comment');

        // Perform Insert or Update
        if (String.isNotBlank(recordId)) {
            update individualAppWorkOrder; // Update existing work order
            System.debug('Updated work order: ' + individualAppWorkOrder);
        } else {
            insert individualAppWorkOrder; // Insert new work order
            System.debug('Inserted new work order: ' + individualAppWorkOrder);
        }

        return new Map<String, Object>{
            'id' => individualAppWorkOrder.Id,
            'sequenceNumber' => individualAppWorkOrder.Sequence_Number__c
        };
    }
    
    private static void processTransactionsAndPayments(
        List<Object> transactions,
        List<Object> payments,
        Id workOrderId,
        Id batchId,
        String transactionType
    ) {
        if (transactions == null || transactions.isEmpty()) {
            System.debug('No transactions provided.');
            return;
        }
        if (payments == null || payments.isEmpty()) {
            System.debug('No payments provided.');
            return;
        }

        List<RegulatoryTrxnFee> feesToInsert = new List<RegulatoryTrxnFee>();
        List<RegulatoryTrxnFeeItem> feeItemsToInsert = new List<RegulatoryTrxnFeeItem>();
        List<Activity__c> activitiesToInsert = new List<Activity__c>();
        List<ActivityTransactionItemMapping__c> mappingsToInsert = new List<ActivityTransactionItemMapping__c>();

        Map<String, Id> tempActivityIdToSfIdMap = new Map<String, Id>();
        Map<String, Id> tempFeeIdToSfIdMap = new Map<String, Id>();

        // Step 1: Insert Transaction Fees
        for (Object paymentObj : payments) {
            if (!(paymentObj instanceof Map<String, Object>)) {
                System.debug('Skipping invalid payment format.');
                continue;
            }

            Map<String, Object> paymentData = (Map<String, Object>) paymentObj;

            RegulatoryTrxnFee fee = new RegulatoryTrxnFee();
            fee.Batch_Look_Up__c = batchId;
            fee.Payment_Collection__c = (String) paymentData.get('paymentCollection');
            fee.Payment_Type__c = (String) paymentData.get('paymentType');
            fee.Card_Type__c = (String) paymentData.get('cardType');
            if (paymentData.containsKey('cardDigit') && paymentData.get('cardDigit') != null) {
                fee.Card_Number__c = Decimal.valueOf(String.valueOf(paymentData.get('cardDigit')));
            }
            if (paymentData.containsKey('ckNumber') && paymentData.get('ckNumber') != null) {
                fee.CK_Number__c = Decimal.valueOf(String.valueOf(paymentData.get('ckNumber')));
            }
            if (paymentData.containsKey('serialNumber') && paymentData.get('serialNumber') != null) {
                fee.Money_Order_Number__c = Decimal.valueOf(String.valueOf(paymentData.get('serialNumber')));
            }
            fee.Transaction_Date__c = paymentData.containsKey('transactionDate') 
                ? Date.valueOf(String.valueOf(paymentData.get('transactionDate'))) 
                : null;

            fee.ParentRecordId = workOrderId;
            fee.Status = 'Draft';
            feesToInsert.add(fee);

            String tempFeeId = (String) paymentData.get('Id');
            tempFeeIdToSfIdMap.put(tempFeeId, null);
        }

        insert feesToInsert;

        for (Integer i = 0; i < feesToInsert.size(); i++) {
            Map<String, Object> paymentData = (Map<String, Object>) payments[i];
            String tempFeeId = (String) paymentData.get('Id');
            tempFeeIdToSfIdMap.put(tempFeeId, feesToInsert[i].Id);
        }

        // Step 2: Insert Transaction Fee Items
        for (Object paymentObj : payments) {
            if (!(paymentObj instanceof Map<String, Object>)) {
                System.debug('Skipping invalid payment format.');
                continue;
            }

            Map<String, Object> paymentData = (Map<String, Object>) paymentObj;

            RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
            feeItem.RegulatoryTrxnFeeId = tempFeeIdToSfIdMap.get((String) paymentData.get('Id'));
            feeItem.Name = tempFeeIdToSfIdMap.get((String) paymentData.get('Id'));
            feeItem.FeeAmount = paymentData.containsKey('paymentAmount') 
                ? Decimal.valueOf(String.valueOf(paymentData.get('paymentAmount'))) 
                : null;

            feeItemsToInsert.add(feeItem);
        }

        insert feeItemsToInsert;

        // Step 3: Insert Activities
        for (Object trxObj : transactions) {
            if (!(trxObj instanceof Map<String, Object>)) {
                System.debug('Skipping invalid transaction format.');
                continue;
            }

            Map<String, Object> trxData = (Map<String, Object>) trxObj;

            Activity__c activity = new Activity__c();
            activity.Activity_Name__c = (String) trxData.get('activity');
            activity.Sub_Activity_Name__c = (String) trxData.get('activityCode');
            activity.Program_Name__c = (String) trxData.get('programCode');
            activity.FeeAmount__c = trxData.containsKey('feeAmount') 
                ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount'))) 
                : null;
            activity.TransactionDate__c = trxData.containsKey('transactionDate') 
                ? Date.valueOf(String.valueOf(trxData.get('transactionDate'))) 
                : null;
            activity.TaxExempt__c = trxData.containsKey('taxExempt') ? (Boolean) trxData.get('taxExempt') : false;
            activity.Individual_Application__c = workOrderId;

            activitiesToInsert.add(activity);

            String tempActivityId = (String) trxData.get('Id');
            tempActivityIdToSfIdMap.put(tempActivityId, null);
        }

        insert activitiesToInsert;

        for (Integer i = 0; i < activitiesToInsert.size(); i++) {
            Map<String, Object> trxData = (Map<String, Object>) transactions[i];
            String tempActivityId = (String) trxData.get('Id');
            tempActivityIdToSfIdMap.put(tempActivityId, activitiesToInsert[i].Id);
        }

        // Step 4: Insert Mappings
        for (Object paymentObj : payments) {
            if (!(paymentObj instanceof Map<String, Object>)) {
                System.debug('Skipping invalid payment format.');
                continue;
            }

            Map<String, Object> paymentData = (Map<String, Object>) paymentObj;
            String tempActivityId = (String) paymentData.get('activities'); // Single activity ID

            String tempFeeId = (String) paymentData.get('Id');

            if (tempActivityId != null) {
                ActivityTransactionItemMapping__c mapping = new ActivityTransactionItemMapping__c();
                mapping.Activity__c = tempActivityIdToSfIdMap.get(tempActivityId);
                mapping.Regulatory_Transaction_Fee__c = tempFeeIdToSfIdMap.get(tempFeeId);
                mapping.Transaction_Type__c = transactionType;

                mappingsToInsert.add(mapping);
            }
        }

        insert mappingsToInsert;

        System.debug('Inserted Fees: ' + feesToInsert);
        System.debug('Inserted Fee Items: ' + feeItemsToInsert);
        System.debug('Inserted Activities: ' + activitiesToInsert);
        System.debug('Inserted Mappings: ' + mappingsToInsert);
    }

    private static void uploadAndLinkDocuments(Map<String, Object> workOrderData, Id individualApplicationId) {
        try {
            // Step 1: Delete documents specified in deletedFiles
            if (workOrderData.containsKey('deletedFiles')) {
                List<Object> rawDeletedFileIds = (List<Object>) workOrderData.get('deletedFiles');
                List<String> deletedFileIds = new List<String>();
    
                for (Object fileId : rawDeletedFileIds) {
                    deletedFileIds.add((String) fileId);
                }
    
                if (!deletedFileIds.isEmpty()) {
                    List<ContentDocumentLink> linksToDelete = [
                        SELECT Id, ContentDocumentId
                        FROM ContentDocumentLink
                        WHERE ContentDocumentId IN :deletedFileIds
                        AND LinkedEntityId = :individualApplicationId
                    ];
                    delete linksToDelete;
                    System.debug('Deleted ContentDocumentLinks: ' + linksToDelete);
                }
            }
    
            // Step 2: Handle new and updated documents
            List<ContentVersion> contentVersionsToInsertOrUpdate = new List<ContentVersion>();
            Map<String, String> documentToTypeMap = new Map<String, String>(); // ContentDocumentId -> docType mapping
    
            // Query existing documents linked to the application
            Map<String, ContentDocumentLink> existingLinksMap = new Map<String, ContentDocumentLink>();
            List<ContentDocumentLink> existingLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :individualApplicationId
            ];
            for (ContentDocumentLink link : existingLinks) {
                existingLinksMap.put(link.ContentDocumentId, link);
            }
    
            // Process documents
            if (workOrderData.containsKey('documents')) {
                List<Object> documents = (List<Object>) workOrderData.get('documents');
                for (Object docObj : documents) {
                    Map<String, Object> document = (Map<String, Object>) docObj;
    
                    if (document != null) {
                        String docType = (String) document.get('docType');
                        String existingDocId = document.containsKey('documentId') ? (String) document.get('documentId') : null;
    
                        // Retrieve nested `docFile` object
                        Map<String, Object> docFile = document.containsKey('docFile') ? (Map<String, Object>) document.get('docFile') : null;
    
                        if (docFile != null) {
                            String fileName = (String) docFile.get('fileName');
                            String base64Data = (String) docFile.get('base64Data');
                            String contentType = (String) docFile.get('contentType');
    
                            // Validate base64Data and fileName
                            if (String.isNotBlank(base64Data) && String.isNotBlank(fileName)) {
                                // Create or update ContentVersion
                                ContentVersion contentVersion = new ContentVersion();
                                contentVersion.Title = fileName;
                                contentVersion.PathOnClient = fileName;
                                contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
    
                                if (existingDocId != null && existingLinksMap.containsKey(existingDocId)) {
                                    // Update existing document by linking new version
                                    contentVersion.ContentDocumentId = existingDocId;
                                }
                                contentVersionsToInsertOrUpdate.add(contentVersion);
                                documentToTypeMap.put(existingDocId != null ? existingDocId : contentVersion.Id, docType);
                            } else {
                                System.debug('Skipping document due to missing base64Data or fileName: ' + document);
                            }
                        } else {
                            System.debug('Skipping document due to missing docFile object: ' + document);
                        }
                    } else {
                        System.debug('Skipping invalid document: ' + document);
                    }
                }
            }
    
            // Upsert ContentVersion records
            if (!contentVersionsToInsertOrUpdate.isEmpty()) {
                insert contentVersionsToInsertOrUpdate;
                System.debug('Inserted ContentVersions: ' + contentVersionsToInsertOrUpdate);
    
                // Fetch newly created ContentDocuments for linking
                List<ContentDocument> contentDocuments = [
                    SELECT Id
                    FROM ContentDocument
                    WHERE Id IN (
                        SELECT ContentDocumentId
                        FROM ContentVersion
                        WHERE Id IN :contentVersionsToInsertOrUpdate
                    )
                ];
    
                // Step 3: Link documents and associate docType
                List<ContentDocumentLink> documentLinksToInsert = new List<ContentDocumentLink>();
                for (ContentDocument contentDocument : contentDocuments) {
                    if (!existingLinksMap.containsKey(contentDocument.Id)) {
                        ContentDocumentLink link = new ContentDocumentLink();
                        link.ContentDocumentId = contentDocument.Id;
                        link.LinkedEntityId = individualApplicationId;
                        link.ShareType = 'I';
                        link.Visibility = 'AllUsers';
                        documentLinksToInsert.add(link);
                    }
                    // Debug docType association
                    System.debug('Linked ContentDocument: ' + contentDocument.Id + ' with docType: ' + documentToTypeMap.get(contentDocument.Id));
                }
    
                if (!documentLinksToInsert.isEmpty()) {
                    insert documentLinksToInsert;
                    System.debug('Inserted ContentDocumentLinks: ' + documentLinksToInsert);
                }
            }
        } catch (Exception e) {
            System.debug('Error in uploadAndLinkDocuments: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while uploading and linking documents: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> getWorkOrderDetailsOld(String requestData) {
        try {
            // Deserialize the input JSON string
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String workOrderId = (String) params.get('workOrderId');
            String activityId = (String) params.get('activityId');
            String transactionType = (String) params.get('transactionType');
    
            if (String.isBlank(workOrderId)) {
                throw new AuraHandledException('Work Order ID is required.');
            }
            if (String.isBlank(activityId)) {
                throw new AuraHandledException('Activity ID is required.');
            }
    
            // Fetch the work order
            IndividualApplication workOrder = [
                SELECT Id, Destination__c, LicenseTypeId, Category, Contact__c,
                       Last_Name__c, Middle_Name__c, First_Name__c, Address_Line_1__c,
                       Suite_Apartment_Floor__c, City__c, State__c, Country__c, Zip_Code__c,
                       Organization_Name__c, Email_Address__c, Cell_Phone_Number__c,
                       Work_Order_Status__c, Work_Order_Comments__c
                FROM IndividualApplication
                WHERE Id = :workOrderId
                LIMIT 1
            ];
    
            // Fetch all related activities (transactions)
            List<Activity__c> activities = [
                SELECT Id, Activity_Name__c, Sub_Activity_Name__c, Program_Name__c, FeeAmount__c,
                       TaxExempt__c, TransactionDate__c
                FROM Activity__c
                WHERE Id = :activityId
            ];
    
           // Fetch Payment IDs and corresponding Activity IDs from ActivityTransactionItemMapping__c
        Map<Id, Id> paymentToActivityMap = new Map<Id, Id>();
        List<ActivityTransactionItemMapping__c> mappings = [
            SELECT Regulatory_Transaction_Fee__c, Activity__c, Transaction_Type__c
            FROM ActivityTransactionItemMapping__c
            WHERE Activity__c = :activityId
        ];

        // Separate mappings for "New Transaction" and "Refund Transaction"
        Map<Id, Id> refundTransactionMap = new Map<Id, Id>(); // Refund Transaction Fee -> Activity
        for (ActivityTransactionItemMapping__c mapping : mappings) {
            if (mapping.Transaction_Type__c == 'New Transaction' && mapping.Regulatory_Transaction_Fee__c != null) {
                paymentToActivityMap.put(mapping.Regulatory_Transaction_Fee__c, mapping.Activity__c);
            } else if (mapping.Transaction_Type__c == 'Refund Transaction' && mapping.Regulatory_Transaction_Fee__c != null) {
                refundTransactionMap.put(mapping.Regulatory_Transaction_Fee__c, mapping.Activity__c);
            }
        }

        // Fetch Payments (New Transactions) from RegulatoryTrxnFee using the Payment IDs
        List<RegulatoryTrxnFee> payments = new List<RegulatoryTrxnFee>();
        Set<String> batchIds = new Set<String>();
        if (!paymentToActivityMap.isEmpty()) {
            payments = [
                SELECT Id, Payment_Collection__c, Payment_Type__c, Card_Type__c, Card_Number__c, Batch_Look_Up__c,
                       Money_Order_Number__c, CK_Number__c, TotalFeeAmount, Status, Transaction_Date__c
                FROM RegulatoryTrxnFee
                WHERE Id IN :paymentToActivityMap.keySet()
            ];

            for (RegulatoryTrxnFee payment : payments) {
                if (payment.Batch_Look_Up__c != null) {
                    batchIds.add(payment.Batch_Look_Up__c);
                }
            }
        }

        // Refund Transaction Flow
        List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
        if (transactionType == 'Refund Transaction' && !refundTransactionMap.isEmpty()) {
            List<RegulatoryTrxnFee> refundPayments = [
                SELECT Id, Payment_Collection__c, Refund_Amount__c, Refund_Method__c, Refund_Voucher_ID__c,
                Date_of_Refund__c, Related_to_Transaction__c
                FROM RegulatoryTrxnFee
                WHERE Id IN :refundTransactionMap.keySet()
            ];

            for (RegulatoryTrxnFee refundPayment : refundPayments) {
                refundTransactions.add(new Map<String, Object>{
                    'id' => refundPayment.Id,
                    'originalTransactionId' => refundPayment.Related_to_Transaction__c,
                    'refundPaymentMethod' => refundPayment.Refund_Method__c,
                    'refundAmount' => refundPayment.Refund_Amount__c,
                    'refundDate' => refundPayment.Date_of_Refund__c
                });
            }
        }
    
            // Fetch documents linked to the work order
            List<ContentDocumentLink> documentLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title,
                       ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :workOrderId
            ];
    
            // Map document links to FileInfo objects
            List<FileInfo> documentList = new List<FileInfo>();
            for (ContentDocumentLink link : documentLinks) {
                FileInfo fileInfo = new FileInfo(
                    link.ContentDocument.Title,
                    link.ContentDocumentId,
                    link.ContentDocument.LatestPublishedVersionId,
                    link.Id
                );
                documentList.add(fileInfo);
            }
    
            // Prepare the response
            Map<String, Object> response = new Map<String, Object>();
    
            // Add Work Order details
            response.put('workOrder', new Map<String, Object>{
                'id' => workOrder.Id,
                'destination' => workOrder.Destination__c,
                'licenseTypeId' => workOrder.LicenseTypeId,
                'category' => workOrder.Category,
                'contactId' => workOrder.Contact__c,
                'lastName' => workOrder.Last_Name__c,
                'middleName' => workOrder.Middle_Name__c,
                'firstName' => workOrder.First_Name__c,
                'addressLine1' => workOrder.Address_Line_1__c,
                'suiteApartmentFloor' => workOrder.Suite_Apartment_Floor__c,
                'city' => workOrder.City__c,
                'state' => workOrder.State__c,
                'country' => workOrder.Country__c,
                'zipCode' => workOrder.Zip_Code__c,
                'organizationName' => workOrder.Organization_Name__c,
                'emailAddress' => workOrder.Email_Address__c,
                'phoneNumber' => workOrder.Cell_Phone_Number__c,
                'status' => workOrder.Work_Order_Status__c,
                'comments' => workOrder.Work_Order_Comments__c
            });
    
            // Add activities as transactions
            List<Map<String, Object>> transactionList = new List<Map<String, Object>>();
            for (Activity__c activity : activities) {
                transactionList.add(new Map<String, Object>{
                    'id' => activity.Id,
                    'activity' => activity.Activity_Name__c,
                    'activityCode' => activity.Sub_Activity_Name__c,
                    'programCode' => activity.Program_Name__c,
                    'feeAmount' => activity.FeeAmount__c,
                    'taxExempt' => activity.TaxExempt__c,
                    'transactionDate' => activity.TransactionDate__c
                });
            }
            response.put('transactions', transactionList);
    
            // Add payments to the response, including activityId
            List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
            for (RegulatoryTrxnFee payment : payments) {
                paymentList.add(new Map<String, Object>{
                    'id' => payment.Id,
                    'paymentCollection' => payment.Payment_Collection__c,
                    'paymentType' => payment.Payment_Type__c,
                    'cardType' => payment.Card_Type__c,
                    'cardDigit' => payment.Card_Number__c,
                    'serialNumber' => payment.Money_Order_Number__c,
                    'ckNumber' => payment.CK_Number__c,
                    'paymentAmount' => payment.TotalFeeAmount,
                    'transactionDate' => payment.Transaction_Date__c,
                    'status' => payment.Status,
                    'activityId' => paymentToActivityMap.get(payment.Id) // Include the mapped activityId
                });
            }
            response.put('payments', paymentList);

            // Add batchID (single value, or empty if no batch IDs exist)
            response.put('batchID', batchIds.isEmpty() ? null : batchIds.iterator().next());
    
            // Add documents
            if (transactionType == 'Refund Transaction') {
                // Add refund transaction details
                response.put('refundTransactions', refundTransactions);
            }else{
                response.put('documents', documentList);
            }
    
            return response;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> getWorkOrderDetails(String requestData) {
        try {
            // Log start of processing
            System.debug('### START: Processing requestData: ' + requestData);
        
            // Deserialize the input JSON string
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String workOrderId = (String) params.get('workOrderId');
        
            System.debug('### PARAMS: workOrderId = ' + workOrderId);
        
            if (String.isBlank(workOrderId)) {
                System.debug('### ERROR: Work Order ID is blank');
                throw new AuraHandledException('Work Order ID is required.');
            }
        
            // Fetch the work order
            IndividualApplication workOrder = [
                SELECT Id, Contact__c, Last_Name__c, Middle_Name__c, First_Name__c
                FROM IndividualApplication
                WHERE Sequence_Number__c  = :workOrderId
                LIMIT 1
            ];
            System.debug('### FETCHED WorkOrder: ' + workOrder);
        
            // Fetch all RegulatoryTrxnFee records
            List<RegulatoryTrxnFee> AllFee = [
                SELECT Id, ParentRecord.Id, Payment_Type__c, CreatedDate, Amount__c
                FROM RegulatoryTrxnFee
                WHERE ParentRecord.Id = :workOrder.Id
            ];
            System.debug('### FETCHED AllFee Records Count: ' + AllFee.size());
            System.debug('### AllFee Records: ' + AllFee);
        
            // Store RegulatoryTrxnFee IDs in a Set
            Set<Id> AllFeeIdSet = new Set<Id>();
            for (RegulatoryTrxnFee a : AllFee) {
                AllFeeIdSet.add(a.Id);
            }
            System.debug('### AllFeeIdSet: ' + AllFeeIdSet);
        
            // Fetch related ActivityTransactionItemMapping__c records
            List<ActivityTransactionItemMapping__c> FetchAllJunctionObjects = [
                SELECT Id, Regulatory_Transaction_Fee__c, Activity__c, Activity__r.Activity_Name__c
                FROM ActivityTransactionItemMapping__c
                WHERE Regulatory_Transaction_Fee__c IN :AllFeeIdSet
            ];
            System.debug('### FETCHED FetchAllJunctionObjects Count: ' + FetchAllJunctionObjects.size());
            System.debug('### FetchAllJunctionObjects: ' + FetchAllJunctionObjects);
        
            // Prepare the response
            Map<String, Object> response = new Map<String, Object>();
        
            // Add Work Order details
            response.put('workOrder', new Map<String, Object>{
                'id' => workOrder.Id,
                'lastName' => workOrder.Last_Name__c,
                'firstName' => workOrder.First_Name__c,
                'MiddleName' => workOrder.Middle_Name__c
            });
            System.debug('### RESPONSE: Added workOrder details');
        
            // Add Fee Details (Handle multiple fees appropriately)
            List<Map<String, Object>> feeDetails = new List<Map<String, Object>>();
            for (RegulatoryTrxnFee fee : AllFee) {
                feeDetails.add(new Map<String, Object>{
                    'PaymentType' => fee.Payment_Type__c,
                    'Amount' => fee.Amount__c
                });
            }
            response.put('Fees', feeDetails);
            System.debug('### RESPONSE: Added Fee details, Count: ' + feeDetails.size());
        
            // Add Activity Details (Handle multiple activities appropriately)
            List<Map<String, Object>> activityDetails = new List<Map<String, Object>>();
            for (ActivityTransactionItemMapping__c activity : FetchAllJunctionObjects) {
                activityDetails.add(new Map<String, Object>{
                    'ActivityId' => activity.Activity__c,
                    'ActivityName' => activity.Activity__r != null ? activity.Activity__r.Activity_Name__c : null
                });
            }
            response.put('Activities', activityDetails);
            System.debug('### RESPONSE: Added Activity details, Count: ' + activityDetails.size());
        
            System.debug('### FINAL RESPONSE: ' + response);
        
            return response;
        
        } catch (Exception e) {
            System.debug('### ERROR: ' + e.getMessage());
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }
        
        
    }
    
    @AuraEnabled
    public static Map<String, Object> updateWorkOrder(String workOrderDataJson) {
        try {
            // Deserialize the JSON input
            Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(workOrderDataJson);
            String batchId = (String) workOrderData.get('batchId');
            String workOrderId = (String) workOrderData.get('recordId');
            Id activityId = (String) workOrderData.get('activityId');
    
            // Step 1: Check Batch Status
            if (String.isNotBlank(batchId)) {
                Batch__c batch = [
                    SELECT Id, Batch_Status__c
                    FROM Batch__c
                    WHERE Id = :batchId
                    LIMIT 1
                ];
    
                if (batch.Batch_Status__c == 'Closed') {
                    throw new AuraHandledException('Batch is closed. Please open the batch to make changes.');
                }
            }
    
            // Step 2: Update Work Order
            String selectedCustomerId = (String) workOrderData.get('selectedCustomerId');
            Contact customer = [
                SELECT Id, LastName, FirstName, MiddleName, Organization__c, Email, Phone,
                        MailingStreet, MailingAddress2__c, MailingCity, MailingState, MailingCountry, MailingPostalCode
                FROM Contact
                WHERE Id = :selectedCustomerId
                LIMIT 1
            ];
            Map<String, Object> workOrderResult = createWorkOrderForCustomer(customer, workOrderData);
    
            // Step 3: Update Activities
            List<Object> rawTransactions = (List<Object>) workOrderData.get('transactions');
            if (rawTransactions != null && !rawTransactions.isEmpty()) {
                updateActivities(rawTransactions, activityId);
            }
    
            uploadAndLinkDocuments(workOrderData, workOrderId);
    
            return workOrderResult;
        } catch (Exception e) {
            System.debug('Error updating Work Order: ' + e.getMessage());
            throw new AuraHandledException('Error updating Work Order: ' + e.getMessage());
        }
    }

    private static void updateActivities(List<Object> transactionDataList, Id activityId) {
        try {
            List<Activity__c> activitiesToUpdate = new List<Activity__c>();
    
            for (Object trxObj : transactionDataList) {
                if (!(trxObj instanceof Map<String, Object>)) {
                    System.debug('Skipping invalid transaction format.');
                    continue;
                }
    
                Map<String, Object> trxData = (Map<String, Object>) trxObj;
                String transactionId = (String) trxData.get('Id');
    
                if (String.isNotBlank(transactionId)) {
                    // Fetch the existing activity for update
                    Activity__c activity = [
                        SELECT Id, Activity_Name__c, Sub_Activity_Name__c, Program_Name__c, FeeAmount__c,
                               TaxExempt__c, TransactionDate__c, Individual_Application__c
                        FROM Activity__c
                        WHERE Id = :activityId
                        LIMIT 1
                    ];
    
                    // Map fields from the transaction data
                    activity.Activity_Name__c = (String) trxData.get('activity');
                    activity.Sub_Activity_Name__c = (String) trxData.get('activityCode');
                    activity.Program_Name__c = (String) trxData.get('programCode');
                    activity.FeeAmount__c = trxData.containsKey('feeAmount') 
                        ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount'))) 
                        : null;
                    activity.TransactionDate__c = trxData.containsKey('transactionDate') 
                        ? Date.valueOf(String.valueOf(trxData.get('transactionDate'))) 
                        : null;
                    activity.TaxExempt__c = trxData.containsKey('taxExempt') ? (Boolean) trxData.get('taxExempt') : false;
    
                    activitiesToUpdate.add(activity);
                } else {
                    System.debug('Skipping transaction without valid Id: ' + trxData);
                }
            }
    
            // Perform batch update
            if (!activitiesToUpdate.isEmpty()) {
                update activitiesToUpdate;
                System.debug('Updated Activities: ' + activitiesToUpdate);
            }
        } catch (Exception e) {
            System.debug('Error updating activities: ' + e.getMessage());
            throw new AuraHandledException('Error updating activities: ' + e.getMessage());
        }
    }
    
    


    
    // Helper class for File Info
    public class FileInfo {
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String documentId { get; set; }
        @AuraEnabled
        public String versionId { get; set; }
        @AuraEnabled
        public String Id { get; set; }
    
        public FileInfo(String title, String documentId, String versionId, String Id) {
            this.title = title;
            this.documentId = documentId;
            this.versionId = versionId;
            this.Id = Id;
        }
    }
    

    @AuraEnabled
    public static string createRefundTransaction(String refundTransactionJSON){
        try {
            // Deserialize JSON string to a Map for easy access
            Map<String, Object> refundTransactionData = (Map<String, Object>) JSON.deserializeUntyped(refundTransactionJSON);

            String recordId = (String) refundTransactionData.get('recordId');
            String activityId = (String) refundTransactionData.get('activityId');
            String selectedRefundCard = (String) refundTransactionData.get('selectedRefundCard');
            String refundMethod  = (String) refundTransactionData.get('refundMethod');
            Date refundDate = refundTransactionData.containsKey('refundDate') 
            ? Date.valueOf((String) refundTransactionData.get('refundDate')) 
            : null;
            String voucherId   = (String) refundTransactionData.get('voucherId');
            Decimal refundAmount = refundTransactionData.containsKey('refundAmount') 
            ? Decimal.valueOf((String) refundTransactionData.get('refundAmount')) 
            : 0;
            String transactionType = (String) refundTransactionData.get('transactionType');

            

            List<Object> rawPayments = (List<Object>) refundTransactionData.get('payments');
        if (rawPayments == null || rawPayments.isEmpty()) {
            throw new AuraHandledException('No payment data provided for refund transaction.');
        }

       // Step 2: Create a single Regulatory Transaction Fee Record
       RegulatoryTrxnFee regulatoryFee = new RegulatoryTrxnFee();
       regulatoryFee.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'RegulatoryTrxnFee' AND DeveloperName = 'Refund_Transaction' LIMIT 1].Id;
       regulatoryFee.Date_of_Refund__c = refundDate;
       regulatoryFee.Refund_Amount__c = refundAmount;
       regulatoryFee.Refund_Method__c = refundMethod;
       regulatoryFee.Refund_Voucher_ID__c = voucherId;

       // Map the original transaction only if the refund method is 'Card'
       if (refundMethod == 'Card') {
           regulatoryFee.Related_to_Transaction__c = selectedRefundCard;
       }

       regulatoryFee.Status = 'Draft';

       insert regulatoryFee;

       // Step 3: Create a single Regulatory Transaction Fee Item Record
       RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
       feeItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'RegulatoryTrxnFeeItem' AND DeveloperName = 'Refund_Transaction' LIMIT 1].Id;
       feeItem.FeeAmount = refundAmount;
       feeItem.Name = regulatoryFee.Id;
       feeItem.RegulatoryTrxnFeeId = regulatoryFee.Id;

       insert feeItem;

       // Step 4: Create an ActivityTransactionItemMapping Record
       ActivityTransactionItemMapping__c mapping = new ActivityTransactionItemMapping__c();
       mapping.Activity__c = activityId;
       mapping.Regulatory_Transaction_Fee__c = regulatoryFee.Id; // Regulatory Fee ID
       mapping.Transaction_Type__c = transactionType;

       insert mapping;

       return recordId;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}