public with sharing class AddOfficialContactController {

    @AuraEnabled
    public static List<Office__c> fetchOffices() {
        return [SELECT Id, Name__c FROM Office__c WITH SECURITY_ENFORCED ORDER BY Id_Number__c ASC];
    }

    @AuraEnabled
    public static String upsertContact(Map<String, Object> formData) {
        try {
            Contact contactRecord;

            // Check if we're inserting a new record or updating an existing one
            String recordIdString = (String) formData.get('recordId');
            if (String.isNotBlank(recordIdString)) {
                // Perform an update since recordId is provided
                contactRecord = updateContact(recordIdString, formData);
            } else {
                // Perform an insert since recordId is null or blank
                contactRecord = createContact(formData);
            }

            // Return the ID of the upserted record
            return contactRecord.Id;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error upserting record: ' + dmlEx.getDmlMessage(0) + ' - ' + dmlEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }
    
    private static Id sharedAccountId;

    // Helper method to handle the insert scenario
     private static Contact createContact(Map<String, Object> formData) {
        try {
            Contact newContact = new Contact();

            String staffRecordTypeName = 'Official';
            RecordType staffRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = :staffRecordTypeName WITH SECURITY_ENFORCED LIMIT 1];

            // Populate the fields for insert
            populateFields(newContact, formData);

            // Hardcode the RecordTypeId here
            newContact.RecordTypeId = staffRecordType.Id; 
            // newContact.AccountId = '0013S00000dacrKQAQ';

            // Insert the new record
            Database.insert(newContact, false, AccessLevel.USER_MODE);
            return newContact;
        } catch (Exception e) {
            throw new AuraHandledException('Error inserting new record: ' + e.getMessage());
        }
    }

    // Helper method to handle the update scenario
    private static Contact updateContact(String recordIdString, Map<String, Object> formData) {
        try {
            Id recordId = Id.valueOf(recordIdString);
            Contact existingContact = [SELECT Id FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

            // Populate the fields for update
            populateFields(existingContact, formData);

            // Update the existing record
            Database.update(existingContact, false, AccessLevel.USER_MODE);
            return existingContact;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }

    private static void populateFields(Contact contactRecord, Map<String, Object> formData) {
        try {
            System.debug('Populating fields for contact: ' + formData);
    
            // Basic information
            contactRecord.Salutation = formData.containsKey('prefix') && formData.get('prefix') != null ? String.valueOf(formData.get('prefix')) : null;
            contactRecord.LastName = formData.containsKey('lastName') && formData.get('lastName') != null ? String.valueOf(formData.get('lastName')) : null;
            contactRecord.MiddleName = formData.containsKey('middleInitial') && formData.get('middleInitial') != null ? String.valueOf(formData.get('middleInitial')) : null;
            contactRecord.FirstName = formData.containsKey('firstName') && formData.get('firstName') != null ? String.valueOf(formData.get('firstName')) : null;
            contactRecord.Suffix = formData.containsKey('suffix') && formData.get('suffix') != null ? String.valueOf(formData.get('suffix')) : null;
            contactRecord.Personal_Name__c = formData.containsKey('personalName') && formData.get('personalName') != null ? String.valueOf(formData.get('personalName')) : null;
            contactRecord.Title__c = formData.containsKey('title') && formData.get('title') != null ? String.valueOf(formData.get('title')) : null;
            contactRecord.Phone = formData.containsKey('businessPhone') && formData.get('businessPhone') != null ? String.valueOf(formData.get('businessPhone')) : null;
            contactRecord.HomePhone = formData.containsKey('homePhone') && formData.get('homePhone') != null ? String.valueOf(formData.get('homePhone')) : null;
            contactRecord.Email = formData.containsKey('email') && formData.get('email') != null ? String.valueOf(formData.get('email')) : null;
            contactRecord.MailingStreet = formData.containsKey('address1') && formData.get('address1') != null ? String.valueOf(formData.get('address1')) : null;
            contactRecord.MailingAddress2__c = formData.containsKey('address2') && formData.get('address2') != null ? String.valueOf(formData.get('address2')) : null;
            contactRecord.MailingCity = formData.containsKey('city') && formData.get('city') != null ? String.valueOf(formData.get('city')) : null;
            contactRecord.MailingState = formData.containsKey('state') && formData.get('state') != null ? String.valueOf(formData.get('state')) : null;
            contactRecord.MailingPostalCode = formData.containsKey('zipCode') && formData.get('zipCode') != null ? String.valueOf(formData.get('zipCode')) : null;
            contactRecord.MailingCountry = formData.containsKey('country') && formData.get('country') != null ? String.valueOf(formData.get('country')) : null;
            contactRecord.Party__c = formData.containsKey('party') && formData.get('party') != null ? String.valueOf(formData.get('party')) : null;
            contactRecord.Extension__c = formData.containsKey('extension') && formData.get('extension') != null ? String.valueOf(formData.get('extension')) : null;
            contactRecord.Fax = formData.containsKey('fax') && formData.get('fax') != null ? String.valueOf(formData.get('fax')) : null;
            contactRecord.Elected__c = formData.containsKey('elected') && formData.get('elected') != null ? String.valueOf(formData.get('elected')) : null;
    
            // Handle Boolean fields safely
            if (formData.containsKey('apo') && formData.get('apo') != null) {
                contactRecord.Authorized_Public_Official__c = Boolean.valueOf(formData.get('apo'));
            }
    
            if (formData.containsKey('indefiniteTerm') && formData.get('indefiniteTerm') != null) {
                contactRecord.Indefinite_Term__c = Boolean.valueOf(formData.get('indefiniteTerm'));
            }
    
            // Handle Office__c field (sbt field from formData)
            System.debug('sbt (Office__c) value: ' + formData.get('sbt'));
            if (formData.containsKey('sbt') && formData.get('sbt') != null && String.isNotBlank((String) formData.get('sbt'))) {
                contactRecord.Office__c = (String) formData.get('sbt');
            } else {
                contactRecord.Office__c = null; // Clear the field if it's not provided
            }
    
            // Handle date conversion with null and empty string checks
            String startTermStr = (String) formData.get('startTerm');
            if (String.isNotBlank(startTermStr)) {
                contactRecord.Start_Term__c = Date.valueOf(startTermStr);
            } else {
                contactRecord.Start_Term__c = null; // Clear the field if it's not provided
            }
    
            String endTermStr = (String) formData.get('endTerm');
            if (String.isNotBlank(endTermStr)) {
                contactRecord.End_Term__c = Date.valueOf(endTermStr);
            } else {
                contactRecord.End_Term__c = null; // Clear the field if it's not provided
            }
    
        } catch (Exception e) {
            System.debug('Error in populateFields: ' + e.getMessage());
            throw new AuraHandledException('Error processing input data: ' + e.getMessage());
        }
    }
    

    @AuraEnabled
    public static Contact fetchContactData(Id recordId) {
        try {
            return [SELECT Salutation, LastName, MiddleName, FirstName, Suffix, Title__c, 
                           Phone, HomePhone, Email, MailingStreet, MailingAddress2__c, MailingCity, MailingState, 
                           MailingPostalCode, MailingCountry, Party__c, Authorized_Public_Official__c, Personal_Name__c,
                           Fax, Extension__c, Elected__c, Start_Term__c, End_Term__c, Indefinite_Term__c,
                           Office__r.Name 
                    FROM Contact 
                    WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching contact data: ' + e.getMessage());
        }
    }
}