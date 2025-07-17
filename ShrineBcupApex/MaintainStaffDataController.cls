public class MaintainStaffDataController {

    public class PaginatedResult {
        @AuraEnabled public List<Contact> records;
        @AuraEnabled public Integer totalRecordCount;
    }

    /*@AuraEnabled
    public static PaginatedResult getStateSealStaffData(String searchCriteriaJson) {
        Map<String, Object> searchParams = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJson);
        PaginatedResult result = new PaginatedResult();
        
        try {
            // Extract search parameters
            Integer pageSize = searchParams.get('pageSize') != null ? Integer.valueOf(searchParams.get('pageSize')) : null;
            Integer pageNumber = searchParams.get('pageNumber') != null ? Integer.valueOf(searchParams.get('pageNumber')) : null;
            // Date startDate = searchParams.containsKey('startDate') ? (Date) searchParams.get('startDate') : null;
            // Date endDate = searchParams.containsKey('endDate') ? (Date) searchParams.get('endDate') : null;
             // Parse date values from String to Date
            String startDateStr = (String) searchParams.get('startDate');
            Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
            
            String endDateStr = (String) searchParams.get('endDate');
            Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;
            String sortField = searchParams.containsKey('sortField') ? (String) searchParams.get('sortField') : 'LastModifiedDate';
            String sortDirection = searchParams.containsKey('sortDirection') ? (String) searchParams.get('sortDirection') : 'DESC';
    
            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * pageSize;
    
            // Base query with LastModifiedDate and CreatedDate
            String query = 'SELECT Id, FirstName, LastName, Phone, Division__c, ' +
                          'Staff_Title__c, CreatedDate, LastModifiedDate ' +
                          'FROM Contact ' +
                          'WHERE RecordType.Name = \'Staff\' ';
    
            if (startDate != null && endDate != null) {
                query += 'AND CreatedDate >= :startDate AND CreatedDate <= :endDate ';
            }
    
            // Add dynamic sorting
            if (String.isBlank(sortField)) {
                sortField = 'LastModifiedDate';
            }
            if (String.isBlank(sortDirection)) {
                sortDirection = 'DESC';
            }
    
            // Validate sort field to prevent SOQL injection
            Set<String> validSortFields = new Set<String> {
                'LastModifiedDate', 'CreatedDate', 'LastName', 'FirstName', 
                'Phone', 'Division__c', 'Staff_Title__c'
            };
    
            if (!validSortFields.contains(sortField)) {
                sortField = 'LastModifiedDate';
            }
    
            // Validate sort direction
            if (sortDirection != 'ASC' && sortDirection != 'DESC') {
                sortDirection = 'DESC';
            }
    
            // Construct the final query
            query += 'ORDER BY ' + sortField + ' ' + sortDirection + ' ' +
                     'LIMIT :pageSize OFFSET :offset';
    
            // Execute the query and set the records
            result.records = Database.query(query);
    
            // Count query for total record count
            String countQuery = 'SELECT COUNT() FROM Contact WHERE RecordType.Name = \'Staff\' ';
            if (startDate != null && endDate != null) {
                countQuery += 'AND CreatedDate >= :startDate AND CreatedDate <= :endDate ';
            }
            result.totalRecordCount = Database.countQuery(countQuery);
    
        } catch (QueryException qe) {
            // Handle query-specific exceptions
            System.debug('QueryException occurred: ' + qe.getMessage());
            throw new AuraHandledException('Error executing the query. Please try again later.');
        } catch (NullPointerException npe) {
            // Handle null pointer exceptions
            System.debug('NullPointerException occurred: ' + npe.getMessage());
            throw new AuraHandledException('Required parameter is missing or null. Please check your input.');
        } catch (Exception e) {
            // Catch any other exceptions
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred. Please try again later.');
        }
    
        return result;
    }*/
    
    
    @AuraEnabled
    public static PaginatedResult searchStaffData(Map<String, Object> searchParams) {
        PaginatedResult result = new PaginatedResult();
    
        try {
            // Extract parameters from the searchParams map with null checks
            Integer pageSize = searchParams.containsKey('pageSize') && searchParams.get('pageSize') != null ? Integer.valueOf(searchParams.get('pageSize')) : 10;
            Integer pageNumber = searchParams.containsKey('pageNumber') && searchParams.get('pageNumber') != null ? Integer.valueOf(searchParams.get('pageNumber')) : 1;
            String lastName = searchParams.containsKey('lastName') ? (String) searchParams.get('lastName') : null;
            String firstName = searchParams.containsKey('firstName') ? (String) searchParams.get('firstName') : null;
            String phone = searchParams.containsKey('phone') ? (String) searchParams.get('phone') : null;
            String title = searchParams.containsKey('title') ? (String) searchParams.get('title') : null;
            String division = searchParams.containsKey('division') ? (String) searchParams.get('division') : null;
            String sortField = searchParams.containsKey('sortField') ? (String) searchParams.get('sortField') : 'LastModifiedDate';
            String sortDirection = searchParams.containsKey('sortDirection') ? (String) searchParams.get('sortDirection') : 'DESC';
            String fromDateString = searchParams.containsKey('fromDate') ? (String) searchParams.get('fromDate') : null;
            String toDateString = searchParams.containsKey('toDate') ? (String) searchParams.get('toDate') : null;
    
            Date fromDate = null;
            Date toDate = null;
            Integer offset = (pageNumber > 0) ? (pageNumber - 1) * pageSize : 0;
    
            if (String.isNotBlank(fromDateString)) {
                fromDate = Date.valueOf(fromDateString);
            }
            if (String.isNotBlank(toDateString)) {
                toDate = Date.valueOf(toDateString);
            }
    
            // Collect conditions for WHERE clause
            List<String> conditions = new List<String>();
            conditions.add('RecordType.DeveloperName = \'Staff\'');  // Using DeveloperName for stability
    
            if (String.isNotBlank(lastName)) {
                conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
            }
            if (String.isNotBlank(firstName)) {
                conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
            }
            if (String.isNotBlank(phone)) {
                conditions.add('Phone LIKE \'%' + String.escapeSingleQuotes(phone) + '%\'');
            }
            if (String.isNotBlank(title)) {
                conditions.add('Staff_Title__c LIKE \'%' + String.escapeSingleQuotes(title) + '%\'');
            }
            if (String.isNotBlank(division)) {
                conditions.add('Division__c LIKE \'%' + String.escapeSingleQuotes(division) + '%\'');
            }
            if (fromDate != null && toDate != null) {
                if (fromDate == toDate) {
                    conditions.add('CreatedDate = TODAY');
                } else {
                    conditions.add('CreatedDate >= :fromDate AND CreatedDate <= :toDate');
                }
            }
    
            String whereClause = String.join(conditions, ' AND ');
    
            // Validate and set default sort field
            Set<String> validSortFields = new Set<String>{
                'LastModifiedDate', 'CreatedDate', 'LastName', 'FirstName', 
                'Phone', 'Division__c', 'Staff_Title__c'
            };
    
            if (String.isBlank(sortField) || !validSortFields.contains(sortField)) {
                sortField = 'LastModifiedDate';
            }
            if (String.isBlank(sortDirection) || (sortDirection != 'ASC' && sortDirection != 'DESC')) {
                sortDirection = 'DESC';
            }
    
            // Construct the query string
            String query = 'SELECT Id, FirstName, LastName, Phone, Division__c, ' +
                           'Staff_Title__c, CreatedDate, LastModifiedDate ' +
                           'FROM Contact ' +
                           'WHERE ' + whereClause + 
                           ' ORDER BY ' + sortField + ' ' + sortDirection +
                           ' LIMIT :pageSize OFFSET :offset';
    
            // Execute the query securely
            result.records = Database.query(query, AccessLevel.USER_MODE);
    
            // Count query for total record count
            String countQuery = 'SELECT COUNT() FROM Contact WHERE ' + whereClause;
            result.totalRecordCount = Database.countQuery(countQuery, AccessLevel.USER_MODE);
    
        } catch (QueryException qe) {
            throw new AuraHandledException('Error executing the query. Please try again later. Details: ' + qe.getMessage());
        } catch (NullPointerException npe) {
            throw new AuraHandledException('Required parameter is missing or null. Please check your input. Details: ' + npe.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred. Please try again later. Details: ' + e.getMessage());
        }
    
        return result;
    }
    
    
    
    @AuraEnabled
    public static void deleteContact(Id contactId) {
        if (contactId == null) {
            throw new AuraHandledException('Invalid contact ID: The provided ID is null.');
        }
    
        try {
            // Fetch the contact with field-level security enforcement
            Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED LIMIT 1];
    
            // Perform a secure delete operation in USER_MODE
            Database.delete(contact, AccessLevel.USER_MODE);
        } catch (QueryException qe) {
            throw new AuraHandledException('No contact found with the provided ID.');
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error deleting contact: ' + dmlEx.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error occurred while deleting contact: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAttorneyInspectorOptions() {
        try {
            List<Contact> contacts = [
                SELECT Id, Name 
                FROM Contact 
                WHERE RecordType.DeveloperName = 'Attorney_Inspector'
                WITH SECURITY_ENFORCED
            ];
    
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Contact contact : contacts) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', contact.Name);
                option.put('value', contact.Id); // Use ID for value to avoid duplicates
                options.add(option);
            }
    
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching attorney inspector options: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void updateContactWithFile(Map<String, Object> contactData) {
        try {
            // Extract parameters with null checks and safe type casting
            Id contactId = contactData.containsKey('contactId') ? (Id) contactData.get('contactId') : null;
            if (contactId == null) {
                throw new AuraHandledException('Contact ID cannot be null.');
            }
    
            String lastName = (String) contactData.get('lastName');
            String firstName = (String) contactData.get('firstName');
            String middleInitial = (String) contactData.get('middleInitial');
            String suffix = (String) contactData.get('suffix');
            String title = (String) contactData.get('title');
            String division = (String) contactData.get('division');
            Boolean esq = (Boolean) contactData.get('esq');
            String phone = (String) contactData.get('phone');
            String status = (String) contactData.get('status');
    
            // Extract uploaded and deleted file IDs
            List<Object> rawUploadedFileIds = contactData.containsKey('uploadedFileIds') ? (List<Object>) contactData.get('uploadedFileIds') : new List<Object>();
            List<Object> rawDeletedFileIds = contactData.containsKey('deletedFileIds') ? (List<Object>) contactData.get('deletedFileIds') : new List<Object>();
    
            List<String> uploadedFileIds = new List<String>();
            for (Object fileId : rawUploadedFileIds) {
                if (fileId instanceof String) {
                    uploadedFileIds.add((String) fileId);
                }
            }
    
            List<String> deletedFileIds = new List<String>();
            for (Object fileId : rawDeletedFileIds) {
                if (fileId instanceof String) {
                    deletedFileIds.add((String) fileId);
                }
            }
    
            // Retrieve the existing contact
            Contact contact = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Phone, Staff_Title__c, Division__c   
                               FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED LIMIT 1];
    
            // Update the contact fields
            contact.FirstName = firstName;
            contact.LastName = lastName;
            contact.MiddleName = middleInitial;
            contact.Suffix = suffix;
            contact.Staff_Title__c = title;
            contact.Division__c = division;
            contact.Phone = phone;
            contact.Esquire__c = esq;
            contact.Status__c = status;
    
            Database.update(contact, false, AccessLevel.USER_MODE);
    
            // Handle deleted files
            if (!deletedFileIds.isEmpty()) {
                List<ContentDocument> documentsToDelete = new List<ContentDocument>();
                for (String fileId : deletedFileIds) {
                    documentsToDelete.add(new ContentDocument(Id = fileId));
                }
                Database.delete(documentsToDelete, false, AccessLevel.USER_MODE);
            }
    
            // Handle uploaded files
            if (!uploadedFileIds.isEmpty()) {
                List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
                for (String fileId : uploadedFileIds) {
                    ContentDocumentLink link = new ContentDocumentLink(
                        LinkedEntityId = contactId,
                        ContentDocumentId = fileId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    );
                    newLinks.add(link);
                }
    
                Database.insert(newLinks, false, AccessLevel.USER_MODE);
            }
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error processing contact update: ' + dmlEx.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }
    
//     @AuraEnabled
//     public static void updateContactWithFile(Map<String, Object> contactData) {
//     try {

//         // Extract parameters with null checks and safe type casting
//         Id contactId = contactData.containsKey('contactId') ? (Id) contactData.get('contactId') : null;
//         String lastName = contactData.containsKey('lastName') ? (String) contactData.get('lastName') : null;
//         String firstName = contactData.containsKey('firstName') ? (String) contactData.get('firstName') : null;
//         String middleInitial = contactData.containsKey('middleInitial') ? (String) contactData.get('middleInitial') : null;
//         String suffix = contactData.containsKey('suffix') ? (String) contactData.get('suffix') : null;
//         String title = contactData.containsKey('title') ? (String) contactData.get('title') : null;
//         String division = contactData.containsKey('division') ? (String) contactData.get('division') : null;
//         Boolean esq = contactData.containsKey('esq') ? (Boolean) contactData.get('esq') : null;
//         String phone = contactData.containsKey('phone') ? (String) contactData.get('phone') : null;
//         String status = contactData.containsKey('status') ? (String) contactData.get('status') : null;

//         // Safe casting for List<String>
//         List<Object> rawUploadedFileIds = contactData.containsKey('uploadedFileIds') 
//             ? (List<Object>) contactData.get('uploadedFileIds') 
//             : new List<Object>();
//         List<String> uploadedFileIds = new List<String>();
//         for (Object fileId : rawUploadedFileIds) {
//             if (fileId instanceof String) {
//                 uploadedFileIds.add((String) fileId);
//             }
//         }

        
//         // Retrieve the existing contact record
//         Contact contact = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Phone, Staff_Title__c, Division__c   
//                            FROM Contact WHERE Id = :contactId LIMIT 1];

//         // Update the contact fields
//         contact.FirstName = firstName;
//         contact.LastName = lastName;
//         contact.MiddleName = middleInitial;
//         contact.Suffix = suffix;
//         contact.Staff_Title__c = title;
//         contact.Division__c = division;
//         contact.Phone = phone;
//         contact.Esquire__c = esq;
//         contact.Status__c = status;
        
//         update contact;

//         if (uploadedFileIds != null && uploadedFileIds.size() > 0) {
//             List<ContentDocumentLink> existingFiles = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :contactId];
//             if (existingFiles.size() > 0) {
//                 delete existingFiles; 
//             }

//             for (String fileId : uploadedFileIds) {
//                 // Retrieve the ContentDocument and its latest version
//                 ContentDocument contentDocument = [
//                     SELECT Id, LatestPublishedVersionId 
//                     FROM ContentDocument 
//                     WHERE Id = :fileId 
//                     LIMIT 1
//                 ];
//                 ContentVersion contentVersion = [
//                     SELECT Id, Title 
//                     FROM ContentVersion 
//                     WHERE Id = :contentDocument.LatestPublishedVersionId 
//                     LIMIT 1
//                 ];

//                 // Update the file name to "Signature"
//                 contentVersion.Title = 'Signature';
//                 update contentVersion;

//                 ContentDocumentLink cdl = new ContentDocumentLink();
//                 cdl.LinkedEntityId = contact.Id;
//                 cdl.ContentDocumentId = fileId;
//                 cdl.ShareType = 'V'; 
//                 cdl.Visibility = 'AllUsers'; 
//                 insert cdl;
//             }
//         }

//     } catch (Exception e) {
//         throw new AuraHandledException('Error updating contact: ' + e.getMessage());
//     }
// }

    

    @AuraEnabled
    public static void updateContact(String contactId, String selectedOption) {
        if (String.isBlank(contactId)) {
            throw new AuraHandledException('Contact ID cannot be null or empty.');
        }
        if (String.isBlank(selectedOption)) {
            throw new AuraHandledException('Selected option cannot be null or empty.');
        }

        try {
            // Retrieve the contact with field-level security enforced
            Contact contactToUpdate = [SELECT Id, State_Seal_Default_Staff__c, State_Extradition_Default_Staff__c, 
                                            Apostille_Default_Staff__c, Public_Official_Default_Staff__c
                                        FROM Contact 
                                        WHERE Id = :contactId 
                                        WITH SECURITY_ENFORCED
                                        LIMIT 1];

            // Reset all default staff flags
            contactToUpdate.State_Seal_Default_Staff__c = false;
            contactToUpdate.State_Extradition_Default_Staff__c = false;
            contactToUpdate.Apostille_Default_Staff__c = false;
            contactToUpdate.Public_Official_Default_Staff__c = false;

            // Set the appropriate flag based on the selected option
            switch on selectedOption {
                when 'Apostille' {
                    contactToUpdate.Apostille_Default_Staff__c = true;
                }
                when 'Public Official' {
                    contactToUpdate.Public_Official_Default_Staff__c = true;
                }
                when 'State Seal' {
                    contactToUpdate.State_Seal_Default_Staff__c = true;
                }
                when 'State Extradition' {
                    contactToUpdate.State_Extradition_Default_Staff__c = true;
                }
                when else {
                    throw new AuraHandledException('Invalid selected option: ' + selectedOption);
                }
            }

            // Securely update the contact record
            Database.update(contactToUpdate, false, AccessLevel.USER_MODE);

        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error updating Contact: ' + dmlEx.getDmlMessage(0));
        } catch (QueryException qEx) {
            throw new AuraHandledException('Error retrieving Contact: ' + qEx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Unexpected error: ' + ex.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        // Check if the search term is blank or null
        if (String.isBlank(searchTerm)) {
            return new List<Contact>();
        }
    
        try {
            // Perform a secure query with field-level security enforced
            return [
                SELECT Id, Name 
                FROM Contact 
                WHERE RecordType.DeveloperName = 'Staff' 
                AND Name LIKE :('%' + String.escapeSingleQuotes(searchTerm) + '%') 
                WITH SECURITY_ENFORCED 
                LIMIT 5
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error searching for contacts: ' + e.getMessage());
        }
    }
    

    
    @AuraEnabled(cacheable=true)
    public static ContactWithFiles getContactById(String recordId, Long timestamp) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('Record ID cannot be null or empty.');
        }
    
        try {
            // Retrieve the contact with field-level security enforced
            Contact contact = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Phone, Staff_Title__c, Division__c, 
                                      Esquire__c, Status__c
                               FROM Contact 
                               WHERE Id = :recordId 
                               WITH SECURITY_ENFORCED
                               LIMIT 1];
    
            // Retrieve linked files
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
                                                              FROM ContentDocumentLink
                                                              WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
    
            // Build the list of FileInfo objects
            List<FileInfo> files = new List<FileInfo>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                files.add(new FileInfo(cdl.ContentDocumentId, cdl.ContentDocument.Title, cdl.ContentDocument.FileExtension));
            }
    
            // Return the contact and associated files
            return new ContactWithFiles(contact, files);
    
        } catch (QueryException qe) {
            throw new AuraHandledException('Error retrieving data for the specified record ID: ' + qe.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
    
    
    public class ContactWithFiles {
        @AuraEnabled public Contact contact;
        @AuraEnabled public List<FileInfo> files;
        
        public ContactWithFiles(Contact contact, List<FileInfo> files) {
            this.contact = contact;
            this.files = files;
        }
    }
    
    public class FileInfo {
        @AuraEnabled public String documentId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileExtension;
        
        public FileInfo(String documentId, String fileName, String fileExtension) {
            this.documentId = documentId;
            this.fileName = fileName;
            this.fileExtension = fileExtension;
        }
    }
    


    @AuraEnabled
    public static Id createContactWithFile(Map<String, Object> contactData) {
        try {
            // Validate mandatory fields
            if (contactData == null || !contactData.containsKey('lastName') || String.isBlank((String) contactData.get('lastName'))) {
                throw new AuraHandledException('Last Name is required to create a Contact.');
            }
    
            String lastName = (String) contactData.get('lastName');
            String firstName = contactData.containsKey('firstName') ? (String) contactData.get('firstName') : null;
            String middleInitial = contactData.containsKey('middleInitial') ? (String) contactData.get('middleInitial') : null;
            String suffix = contactData.containsKey('suffix') ? (String) contactData.get('suffix') : null;
            String title = contactData.containsKey('title') ? (String) contactData.get('title') : null;
            String division = contactData.containsKey('division') ? (String) contactData.get('division') : null;
            Boolean esq = contactData.containsKey('esq') ? (Boolean) contactData.get('esq') : null;
            String phone = contactData.containsKey('phone') ? (String) contactData.get('phone') : null;
            String status = contactData.containsKey('status') ? (String) contactData.get('status') : null;
    
            // Extract uploaded file IDs
            List<Object> rawUploadedFileIds = contactData.containsKey('uploadedFileIds') 
                ? (List<Object>) contactData.get('uploadedFileIds') 
                : new List<Object>();
            List<String> uploadedFileIds = new List<String>();
            for (Object fileId : rawUploadedFileIds) {
                if (fileId instanceof String) {
                    uploadedFileIds.add((String) fileId);
                }
            }
    
            // Retrieve the RecordTypeId for "Staff"
            RecordType staffRecordType = [SELECT Id 
                                          FROM RecordType 
                                          WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff' 
                                          WITH SECURITY_ENFORCED 
                                          LIMIT 1];
    
            // Create a new Contact
            Contact newContact = new Contact(
                LastName = lastName,
                FirstName = firstName,
                MiddleName = middleInitial,
                Suffix = suffix,
                Staff_Title__c = title,
                Division__c = division,
                Phone = phone,
                Esquire__c = esq,
                Status__c = status,
                RecordTypeId = staffRecordType.Id
            );
    
            // Securely insert the Contact
            Database.insert(newContact, false, AccessLevel.USER_MODE);
    
            // Link uploaded files to the Contact
            if (!uploadedFileIds.isEmpty()) {
                List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
    
                for (String fileId : uploadedFileIds) {
                    ContentDocument contentDocument = [
                        SELECT Id, LatestPublishedVersionId 
                        FROM ContentDocument 
                        WHERE Id = :fileId 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1
                    ];
    
                    ContentVersion contentVersion = [
                        SELECT Id, Title 
                        FROM ContentVersion 
                        WHERE Id = :contentDocument.LatestPublishedVersionId 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1
                    ];
    
                    // Update file title to "Signature"
                    contentVersion.Title = 'Signature';
                    Database.update(contentVersion, false, AccessLevel.USER_MODE);
    
                    // Create a ContentDocumentLink
                    ContentDocumentLink cdl = new ContentDocumentLink(
                        LinkedEntityId = newContact.Id,
                        ContentDocumentId = fileId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    );
                    newLinks.add(cdl);
                }
    
                // Securely insert the ContentDocumentLinks
                if (!newLinks.isEmpty()) {
                    Database.insert(newLinks, false, AccessLevel.USER_MODE);
                }
            }
    
            // Return the new Contact's ID
            return newContact.Id;
    
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error creating Contact or linking files: ' + dmlEx.getDmlMessage(0));
        } catch (QueryException qEx) {
            throw new AuraHandledException('Error retrieving required data: ' + qEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static Map<String, String> downloadFile(Id documentId) {
        if (documentId == null) {
            throw new AuraHandledException('Document ID cannot be null.');
        }
    
        try {
            // Retrieve the ContentVersion with field-level security enforced
            ContentVersion cv = [SELECT VersionData, FileType, PathOnClient 
                                 FROM ContentVersion 
                                 WHERE ContentDocumentId = :documentId 
                                 AND IsLatest = true 
                                 WITH SECURITY_ENFORCED 
                                 LIMIT 1];
    
            // Encode the file data as Base64
            String base64Data = EncodingUtil.base64Encode(cv.VersionData);
    
            // Get the content type based on the file type
            String contentType = getContentType(cv.FileType);
    
            // Return the file data and content type
            return new Map<String, String>{
                'base64Data' => base64Data,
                'contentType' => contentType
            };
    
        } catch (QueryException qe) {
            throw new AuraHandledException('Error retrieving file data: ' + qe.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
    
    private static String getContentType(String fileType) {
        Map<String, String> contentTypeMap = new Map<String, String>{
            'JPG' => 'image/jpeg',
            'JPEG' => 'image/jpeg',
            'PNG' => 'image/png',
            'GIF' => 'image/gif'
        };
        
        return contentTypeMap.containsKey(fileType.toUpperCase()) 
            ? contentTypeMap.get(fileType.toUpperCase()) 
            : 'application/octet-stream';
    }
}