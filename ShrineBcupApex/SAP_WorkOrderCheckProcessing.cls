/**
 * @description This class manages processing and operations related to check payments in work orders.
 * It provides functionality for searching, fetching, and manipulating payment records,
 * handling delinquent statuses, and managing associated files.
 */
public with sharing class SAP_WorkOrderCheckProcessing {
    /**
     * @description Fetches search results for check payment transactions based on provided criteria
     * @param searchCriteriaJSON JSON string containing search parameters and pagination settings
     * @return List<Map<String, Object>> List of search results with payment and related record details
     * @throws AuraHandledException If an error occurs during the search process
     */    
    @AuraEnabled
    public static List<Map<String, Object>> fetchSearchResultsUpdated(String searchCriteriaJSON) {
        try {
            // Deserialize the input JSON string to extract search parameters
            Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJSON);            
            // Extract search parameters
            String workOrderNumber = (String) searchCriteria.get('workOrderNumber');
            String firstName = (String) searchCriteria.get('firstName');
            String lastName = (String) searchCriteria.get('lastName');
            String activityCode = (String) searchCriteria.get('activity');
            String checkNumber = (String) searchCriteria.get('check');
            String transactionDateStr = (String) searchCriteria.get('date');
            String amount = (String) searchCriteria.get('amount');
            String amountRangeStart = (String) searchCriteria.get('amountRangeStart');
            String amountRangeEnd = (String) searchCriteria.get('amountRangeEnd');
            Date transactionDate = (transactionDateStr != null) ? Date.valueOf(transactionDateStr) : null;
            
            String startDateStr = (String) searchCriteria.get('startDate');
            Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
            
            String endDateStr = (String) searchCriteria.get('endDate');
            Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;
            
            String sortedBy = String.isNotBlank((String) searchCriteria.get('sortedBy')) ? (String) searchCriteria.get('sortedBy') : 'CreatedDate';
            String sortDirection = String.isNotBlank((String) searchCriteria.get('sortDirection')) ? (String) searchCriteria.get('sortDirection') : 'DESC';
            
            Integer pageSize = (Integer) searchCriteria.get('pageSize') != null ? (Integer) searchCriteria.get('pageSize') : 10;
            Integer currentPage = (Integer) searchCriteria.get('currentPage') != null ? (Integer) searchCriteria.get('currentPage') : 1;
            
            // Calculate offset for pagination
            Integer offset = (currentPage - 1) * pageSize;
            
            // Base query for RegulatoryTrxnFee
            String query = 
                'SELECT Id, SAP_CK_Number__c, SAP_Reason_for_Returned_Check__c, Batch_Look_Up__r.SAP_Batch_Name__c, ' +
                '       SAP_Deliquent__c, TotalFeeAmount, SAP_Transaction_Date__c, ParentRecordId, CreatedDate ' +
                'FROM RegulatoryTrxnFee ' +
                'WHERE SAP_Payment_Type__c = \'Check\' ' +
                '  AND RecordType.Name = \'New Transaction\'' +
				'  AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\')';
            
            // Apply filters
            if (String.isNotBlank(workOrderNumber)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_Sequence_Number__c = \'' + String.escapeSingleQuotes(workOrderNumber) + '\')';
            }
            if (String.isNotBlank(firstName)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_First_Name__c = \'' + String.escapeSingleQuotes(firstName) + '\')';
            }
            if (String.isNotBlank(lastName)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_Last_Name__c = \'' + String.escapeSingleQuotes(lastName) + '\')';
            }
            if (String.isNotBlank(activityCode)) {
                query += ' AND Batch_Look_Up__r.SAP_Batch_Name__c = \'' + String.escapeSingleQuotes(activityCode) + '\'';
            }
            if (String.isNotBlank(checkNumber)) {
                query += ' AND SAP_CK_Number__c = \'' + String.escapeSingleQuotes(checkNumber) + '\'';
            }
            if(String.isNotBlank(amount)){
                try {
                    Decimal amountValue = Decimal.valueOf(amount);
                    query += ' AND TotalFeeAmount = ' + amountValue;
                } catch (Exception e) {
                    throw new AuraHandledException('Invalid numeric value for TotalFeeAmount: ' + e.getMessage());
                }
            }
            if (String.isNotBlank(amountRangeStart) && String.isNotBlank(amountRangeEnd)) {
                query += ' AND TotalFeeAmount >= ' + String.escapeSingleQuotes(amountRangeStart) +
                    ' AND TotalFeeAmount <= ' + String.escapeSingleQuotes(amountRangeEnd);
            } 
            if (transactionDate != null) {
                query += ' AND SAP_Transaction_Date__c = :transactionDate';
            }
            if (startDate != null && endDate != null) {
                query += ' AND SAP_Transaction_Date__c >= :startDate AND SAP_Transaction_Date__c <= :endDate';
            }
            
            query += ' ORDER BY ' + sortedBy + ' ' + sortDirection + ' LIMIT :pageSize OFFSET :offset';
            // Execute the query for RegulatoryTrxnFee
            List<RegulatoryTrxnFee> payments = Database.query(query, AccessLevel.USER_MODE);             
            // Fetch related IndividualApplications
            Set<Id> parentRecordIds = new Set<Id>();
            for (RegulatoryTrxnFee payment : payments) {
                if (payment.ParentRecordId != null) {
                    parentRecordIds.add(payment.ParentRecordId);
                }
            }
            Map<Id, IndividualApplication> iaMap = new Map<Id, IndividualApplication>(
                [SELECT Id, SAP_First_Name__c, SAP_Last_Name__c, Contact__c, Contact__r.SAP_Deliquent__c
                 FROM IndividualApplication
                 WHERE Id IN :parentRecordIds]
            );
            
            // Fetch related ContentDocumentLinks using ParentRecordId
            Map<Id, List<ContentDocumentLink>> documentLinksMap = new Map<Id, List<ContentDocumentLink>>();
            if (!parentRecordIds.isEmpty()) {
                List<ContentDocumentLink> documentLinks = [
                    SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :parentRecordIds
                    WITH SECURITY_ENFORCED
                ];
                for (ContentDocumentLink link : documentLinks) {
                    if (!documentLinksMap.containsKey(link.LinkedEntityId)) {
                        documentLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
                    }
                    documentLinksMap.get(link.LinkedEntityId).add(link);
                }
            }
            
            // Prepare response
            List<Map<String, Object>> response = new List<Map<String, Object>>();
            for (RegulatoryTrxnFee payment : payments) {
                IndividualApplication ia = iaMap.get(payment.ParentRecordId);
                
                // Prepare document details
                List<Map<String, String>> documents = new List<Map<String, String>>();
                if (documentLinksMap.containsKey(payment.ParentRecordId)) {
                    for (ContentDocumentLink link : documentLinksMap.get(payment.ParentRecordId)) {
                        documents.add(new Map<String, String>{
                            'id' => link.ContentDocumentId,
                                'title' => link.ContentDocument.Title
                                });
                    }
                }
                
                response.add(new Map<String, Object>{
                    'Id' => payment.ParentRecordId,
                        'workOrderId' => payment.ParentRecordId,
                        'workOrderNumber' => payment.ParentRecordId,
                        'currenrDStatus' => ia != null && ia.Contact__r != null ? ia.Contact__r.SAP_Deliquent__c : null,
                            'customerId' => ia != null ? ia.Contact__c : null,
                                'firstName' => ia != null ? ia.SAP_First_Name__c : null,
                                    'lastName' => ia != null ? ia.SAP_Last_Name__c : null,
                                        'activity' => payment.Batch_Look_Up__r != null ? payment.Batch_Look_Up__r.SAP_Batch_Name__c : null,
                                            'transactionId' => payment.Id,
                                            'reasonReturnedCheck' => payment.SAP_Reason_for_Returned_Check__c,
                                            'delinquent' => payment.SAP_Deliquent__c,
                                            'checkNumber' => payment.SAP_CK_Number__c,
                                            'paymentAmount' => payment.TotalFeeAmount,
                                            'transactionDate' => payment.SAP_Transaction_Date__c,
                                            'documents' => documents
                                            });
            }
            
            return response;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching search results: ' + e.getMessage());
        }
    }
    /**
     * @description Gets the total count of records matching the search criteria
     * @param searchCriteriaJSON JSON string containing search parameters
     * @return Integer Total count of matching records
     * @throws AuraHandledException If an error occurs during the count process
     */    
    @AuraEnabled
    public static Integer  getSearchResultsCountUpdated(String searchCriteriaJSON) {
        try {
            // Deserialize the input JSON string to extract search parameters
            Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJSON);            
            // Extract search parameters
            String workOrderNumber = (String) searchCriteria.get('workOrderNumber');
            String firstName = (String) searchCriteria.get('firstName');
            String lastName = (String) searchCriteria.get('lastName');
            String activityCode = (String) searchCriteria.get('activity');
            String checkNumber = (String) searchCriteria.get('check');
            String amount = (String) searchCriteria.get('amount');
            String amountRangeStart = (String) searchCriteria.get('amountRangeStart');
            String amountRangeEnd = (String) searchCriteria.get('amountRangeEnd');
            String transactionDateStr = (String) searchCriteria.get('date');
            Date transactionDate = (transactionDateStr != null) ? Date.valueOf(transactionDateStr) : null;
            
            String startDateStr = (String) searchCriteria.get('startDate');
            Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
            
            String endDateStr = (String) searchCriteria.get('endDate');
            Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;
            
            String sortedBy = String.isNotBlank((String) searchCriteria.get('sortedBy')) ? (String) searchCriteria.get('sortedBy') : 'CreatedDate';
            String sortDirection = String.isNotBlank((String) searchCriteria.get('sortDirection')) ? (String) searchCriteria.get('sortDirection') : 'DESC';
            
            Integer pageSize = (Integer) searchCriteria.get('pageSize') != null ? (Integer) searchCriteria.get('pageSize') : 10;
            Integer currentPage = (Integer) searchCriteria.get('currentPage') != null ? (Integer) searchCriteria.get('currentPage') : 1;
            
            // Calculate offset for pagination
            Integer offset = (currentPage - 1) * pageSize;
            
            // Base query for RegulatoryTrxnFee
            String query = 
                'SELECT COUNT() FROM RegulatoryTrxnFee ' +
                'WHERE SAP_Payment_Type__c = \'Check\' ' +
                '  AND RecordType.Name = \'New Transaction\'' +
                '  AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\')';
           
            
            // Apply filters
            if (String.isNotBlank(workOrderNumber)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_Sequence_Number__c = \'' + String.escapeSingleQuotes(workOrderNumber) + '\')';
            }
            if (String.isNotBlank(firstName)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_First_Name__c = \'' + String.escapeSingleQuotes(firstName) + '\')';
            }
            if (String.isNotBlank(lastName)) {
                query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE RecordType.Name = \'FinSys\' AND SAP_Last_Name__c = \'' + String.escapeSingleQuotes(lastName) + '\')';
            }
            if (String.isNotBlank(activityCode)) {
                query += ' AND Batch_Look_Up__r.SAP_Batch_Name__c = \'' + String.escapeSingleQuotes(activityCode) + '\'';
            }
            if (String.isNotBlank(checkNumber)) {
                query += ' AND SAP_CK_Number__c = \'' + String.escapeSingleQuotes(checkNumber) + '\'';
            }
            if(String.isNotBlank(amount)){
                try {
                    Decimal amountValue = Decimal.valueOf(amount); 
                    query += ' AND TotalFeeAmount = ' + amountValue;
                } catch (Exception e) {
                    throw new AuraHandledException('Invalid numeric value for TotalFeeAmount: ' + e.getMessage());
                }
            }
            if (String.isNotBlank(amountRangeStart) && String.isNotBlank(amountRangeEnd)) {
                query += ' AND TotalFeeAmount >= ' + String.escapeSingleQuotes(amountRangeStart) +
                    ' AND TotalFeeAmount <= ' + String.escapeSingleQuotes(amountRangeEnd);
            } 
            if (transactionDate != null) {
                query += ' AND SAP_Transaction_Date__c = :transactionDate';
            }
            if (startDate != null && endDate != null) {
                query += ' AND SAP_Transaction_Date__c >= :startDate AND SAP_Transaction_Date__c <= :endDate';
            }
            // Execute count query
            Integer recordCount = Database.countQuery(query, AccessLevel.USER_MODE);            
            return recordCount;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching search results: ' + e.getMessage());
        }
    }
    /**
     * @description Transforms ActivityTransactionItemMapping__c records to a standardized result format
     * @param mappings List of ActivityTransactionItemMapping__c records to transform
     * @return List<Map<String, Object>> Transformed data in the standard result format
     */    
    private static List<Map<String, Object>> transformDefaultResults(List<ActivityTransactionItemMapping__c> mappings) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        for (ActivityTransactionItemMapping__c mapping : mappings) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('Id', mapping.Id);
            row.put('workOrderId', mapping.Activity__r.Individual_Application__c);
            row.put('workOrderNumber', mapping.Activity__r.Individual_Application__r.SAP_Sequence_Number__c);
            row.put('currenrDStatus', mapping.Activity__r.Individual_Application__r.Contact__r.SAP_Deliquent__c);
            row.put('customerId', mapping.Activity__r.Individual_Application__r.Contact__c);
            row.put('firstName', mapping.Activity__r.Individual_Application__r.SAP_First_Name__c);
            row.put('lastName', mapping.Activity__r.Individual_Application__r.SAP_Last_Name__c);
            row.put('activity', mapping.Activity__r.Activity_Name__c);
            row.put('transactionId', mapping.Regulatory_Transaction_Fee__c);
            row.put('reasonReturnedCheck', mapping.Regulatory_Transaction_Fee__r.SAP_Reason_for_Returned_Check__c);
            row.put('delinquent', mapping.Regulatory_Transaction_Fee__r.SAP_Deliquent__c);
            row.put('checkNumber', mapping.Regulatory_Transaction_Fee__r.SAP_CK_Number__c);
            row.put('paymentAmount', mapping.Regulatory_Transaction_Fee__r.TotalFeeAmount);
            row.put('transactionDate', mapping.Activity__r.TransactionDate__c);
            results.add(row);
        }
        
        return results;
    }
    /**
     * @description Updates the reason for a returned check
     * @param loggingDataJSON JSON string containing transactionId and reasonReturnedCheck
     * @throws AuraHandledException If an error occurs during the update process
     */    
    @AuraEnabled
    public static void logDropdownChange(String loggingDataJSON) {
        try {
            // Deserialize the input JSON into a map
            Map<String, Object> loggingData = (Map<String, Object>) JSON.deserializeUntyped(loggingDataJSON);
            String transactionId = (String) loggingData.get('transactionId');
            String reasonReturnedCheck = (String) loggingData.get('reasonReturnedCheck');
            if (String.isNotBlank(transactionId)) {
                // Query the SAP_Regulatory_Transaction_Fee__c record
                RegulatoryTrxnFee feeRecord = [SELECT Id, SAP_Reason_for_Returned_Check__c 
                                               FROM RegulatoryTrxnFee 
                                               WHERE Id = :transactionId 
                                               WITH SECURITY_ENFORCED
                                               LIMIT 1];
                
                // Update the field SAP_Reason_for_Returned_Check__c
                feeRecord.SAP_Reason_for_Returned_Check__c = reasonReturnedCheck;
                // Perform the update
                Database.update(feeRecord, false, AccessLevel.USER_MODE);
            } 
        } catch (Exception e) {
            throw new AuraHandledException('Error logging dropdown change: ' + e.getMessage());
        }
    }
    /**
     * @description Updates the delinquent status for a transaction and updates related customer account balance
     * @param loggingDataJSON JSON string containing transaction details and delinquent status
     * @throws AuraHandledException If an error occurs during the update process
     */    
    @AuraEnabled
    public static void logCheckboxChange(String loggingDataJSON) {
        try {
            // Deserialize the input JSON into a map
            Map<String, Object> loggingData = (Map<String, Object>) JSON.deserializeUntyped(loggingDataJSON);
            
            // Extract details from the logging data
            String contactId = (String) loggingData.get('contactId');
            String transactionId = (String) loggingData.get('transactionId');
            Decimal paymentAmount;
            Object rawAmount = loggingData.get('paymentAmount');
            if (rawAmount instanceof String) {
                String amountStr = ((String)rawAmount)
                    .replaceAll('[^0-9\\.]', '') 
                    .trim();
                paymentAmount = Decimal.valueOf(amountStr);
            } else {
                paymentAmount = (Decimal)rawAmount;
            }
            Boolean delinquent = (Boolean) loggingData.get('delinquent');
            Boolean currentDelinquent = (Boolean) loggingData.get('currenrDStatus');
            
            // Update the SAP_Regulatory_Transaction_Fee__c record
            if (String.isNotBlank(transactionId)) {
                RegulatoryTrxnFee feeRecord = [SELECT Id, SAP_Deliquent__c, Bounce_Date__c, SAP_Reason_for_Returned_Check__c 
                                               FROM RegulatoryTrxnFee 
                                               WHERE Id = :transactionId 
                                               WITH SECURITY_ENFORCED
                                               LIMIT 1];
                
                feeRecord.SAP_Deliquent__c = delinquent; 
                
                // If marking as delinquent, set SAP_Bounce_Date__c to today's date
                if (delinquent) {
                    feeRecord.Bounce_Date__c = Date.today();
                } else {
                    // If unmarking delinquent, clear the SAP_Bounce_Date__c and SAP_Reason_for_Returned_Check__c
                    feeRecord.Bounce_Date__c = null;
                    feeRecord.SAP_Reason_for_Returned_Check__c = '';
                }
                Database.update(feeRecord, false, AccessLevel.USER_MODE);                
            }
            
            // Update the Contact record
            if (String.isNotBlank(contactId)) {
                Contact contactRecord = [SELECT Id, RecordType.Name, SAP_Deliquent__c, SAP_Customer_Account_Balance__c 
                                         FROM Contact 
                                         WHERE Id = :contactId 
                                         AND RecordType.Name = 'FinSys Customers' 
                                         WITH SECURITY_ENFORCED
                                         LIMIT 1];
                
                // Query other delinquent transactions for the contact
                List<RegulatoryTrxnFee> otherDelinquentFees = [
                    SELECT Id 
                    FROM RegulatoryTrxnFee 
                    WHERE ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE Contact__c = :contactId)
                    AND Id != :transactionId
                    AND SAP_Deliquent__c = true
                    WITH SECURITY_ENFORCED
                ];
                                
                // Adjust the SAP_Customer_Account_Balance__c regardless of other delinquent transactions
                if (delinquent) {
                    // Marking delinquent: Subtract the payment amount
                    contactRecord.SAP_Customer_Account_Balance__c = 
                        (contactRecord.SAP_Customer_Account_Balance__c != null ? contactRecord.SAP_Customer_Account_Balance__c : 0) 
                        - paymentAmount;
                } else {
                    // Unmarking delinquent: Add the payment amount back
                    contactRecord.SAP_Customer_Account_Balance__c = 
                        (contactRecord.SAP_Customer_Account_Balance__c != null ? contactRecord.SAP_Customer_Account_Balance__c : 0) 
                        + paymentAmount;
                }
                
                // Update the delinquent status only if no other delinquent transactions exist
                if (!delinquent && otherDelinquentFees.isEmpty()) {
                    contactRecord.SAP_Deliquent__c = false;
                } else if (delinquent) {
                    contactRecord.SAP_Deliquent__c = true;
                }

                Database.update(contactRecord);                
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating delinquent status and customer balance: ' + e.getMessage());
        }
    }
    /**
     * @description Uploads a file and associates it with the specified transaction
     * @param loggingDataJSON JSON string containing workOrderId
     * @param fileBody Base64 encoded file content
     * @param fileName Name of the file to upload
     * @return String Success message
     * @throws AuraHandledException If an error occurs during the file upload process
     */    
    @AuraEnabled
    public static String uploadFile(String loggingDataJSON, String fileBody, String fileName) {
        try {
            Map<String, Object> loggingData = (Map<String, Object>) JSON.deserializeUntyped(loggingDataJSON);
            String transactionId = (String) loggingData.get('workOrderId');
            if (String.isEmpty(transactionId)) throw new AuraHandledException('Transaction ID is required.');
            
            Blob fileBlob = EncodingUtil.base64Decode(fileBody);
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = fileBlob;
            Database.insert(contentVersion, false, AccessLevel.USER_MODE);
            
            ContentDocument contentDocument = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id)
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = transactionId;
            cdl.ContentDocumentId = contentDocument.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            Database.insert(cdl, false, AccessLevel.USER_MODE);
            
            return 'File uploaded successfully.';
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }
    /**
     * @description Deletes a file associated with a transaction
     * @param contentDocumentId ID of the ContentDocument to delete
     * @param transactionId ID of the transaction the file is linked to
     * @return String Success message
     * @throws AuraHandledException If an error occurs during the file deletion process
     */
    @AuraEnabled
    public static String deleteFile(String contentDocumentId, String transactionId) {
        try {
            if (String.isEmpty(contentDocumentId)) throw new AuraHandledException('Content Document ID is required.');
            
            List<ContentDocumentLink> cdlList = [
                SELECT Id 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :transactionId
                WITH SECURITY_ENFORCED
            ];
            Database.delete(cdlList, AccessLevel.USER_MODE);
            
            Integer remainingLinks = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId WITH SECURITY_ENFORCED];
            if (remainingLinks == 0) {
                delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            }
            
            return 'File deleted successfully.';
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting file: ' + e.getMessage());
        }
    }
}