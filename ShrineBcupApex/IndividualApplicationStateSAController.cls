public with sharing class IndividualApplicationStateSAController {

    @AuraEnabled
    public static List<Contact> getStateSealStaffData() {
        // Query to fetch all staff data without pagination or filtering by date
        String query = 'SELECT Id, FirstName, LastName, Phone, Division__c, Staff_Title__c, CreatedDate ' +
                    'FROM Contact ' +
                    'WHERE Status__c = \'Active\' AND RecordType.Name = \'Staff\' ' +
                    'ORDER BY CreatedDate DESC';

        // Execute and return the query results
        return Database.query(query);
}




    @AuraEnabled
    public static String upsertApplicationStateSealArm(Map<String, Object> formData) {
        try {
            IndividualApplication application;

            // Check if we're inserting a new record or updating an existing one
            String recordIdString = (String) formData.get('recordId');
            if (String.isNotBlank(recordIdString)) {
                // Perform an update since recordId is provided
                application = updateApplication(recordIdString, formData);
            } else {
                // Perform an insert since recordId is null or blank
                application = insertApplication(formData);
            }

            // Return the ID of the upserted record
            return application.Id;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error upserting record: ' + dmlEx.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }

    // Helper method to handle the insert scenario
    private static IndividualApplication insertApplication(Map<String, Object> formData) {
        try {
            IndividualApplication application = new IndividualApplication();

            // Populate the fields for insert
           

            // Hard-code additional fields
            application.AccountId = '0013S00000dA00UQAS';
            //application.AccountId = Date.today();
            application.Category = 'License';
            application.Destination__c = 'Destination';
            application.LicenseTypeId = '0eh3S0000003Ix2QAE';
            //application.RecordType.Name = 'State Seal';
            Id recordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('State_Seal').getRecordTypeId();

            application.RecordTypeId = recordTypeId;

            populateFields(application, formData);

            // Insert the new record
            insert application;
            return application;
        } catch (Exception e) {
            throw new AuraHandledException('Error inserting new record: ' + e.getMessage());
        }
    }

    // Helper method to handle the update scenario
    private static IndividualApplication updateApplication(String recordIdString, Map<String, Object> formData) {
        try {
            Id recordId = Id.valueOf(recordIdString);
            IndividualApplication application = [SELECT Id FROM IndividualApplication WHERE Id = :recordId LIMIT 1];

            // Populate the fields for update
            populateFields(application, formData);
            if (formData.containsKey('signedBy') && formData.get('signedBy') != null) {
                application.Signedby__c = (String) formData.get('signedBy');
            }

            // Update the existing record
            update application;
            return application;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }

    // Helper method to populate fields common to both insert and update scenarios
    private static void populateFields(IndividualApplication application, Map<String, Object> formData) {
        try {
            application.Prefix__c = (String) formData.get('prefix');
            application.Last_Name__c = (String) formData.get('lastName');
            application.Middle_Name__c = (String) formData.get('middleInitial');
            application.First_Name__c = (String) formData.get('firstName');
            application.Suffix__c = (String) formData.get('suffix');

            // Handle Date of Birth conversion with null checks
            if (formData.containsKey('dob') && formData.get('dob') != null) {
                application.Date_Of_Birth__c = parseDate((String) formData.get('dob'));
            }

            application.Title__c = (String) formData.get('title');
            application.Organization_Name__c = (String) formData.get('entity');
            application.Email_Address__c = (String) formData.get('email');
            application.Cell_Phone_Number__c = (String) formData.get('phoneNumber');
            application.ESQ__c = (Boolean) formData.get('esq');
            application.Address_Line_1__c = (String) formData.get('address1');
            application.Suite_Apartment_Floor__c = (String) formData.get('address2');
            application.City__c = (String) formData.get('city');
            application.State__c = (String) formData.get('state');
            application.Country__c = (String) formData.get('country');
            application.Zip_Code__c = (String) formData.get('zipCode');
            application.Letter_Type__c = (String) formData.get('letterType');
            application.Enclosure__c = (String) formData.get('enclosure');
            application.Proposed_Use__c = (String) formData.get('proposedUse');
            application.Requested_For__c = (String) formData.get('requestedFor');
            application.Disposition__c = (String) formData.get('disposition');
            application.Approved_For__c = (String) formData.get('approvedFor');
            application.Letter_Text__c = (String) formData.get('letterText');

            
            application.Wet_Signature__c = (String) formData.get('wetSign');

            // Handle Date of Birth conversion with null checks
            if (formData.containsKey('dateOfResponse') && formData.get('dateOfResponse') != null) {
                application.Date_of_SOTS_Response__c = parseDate((String) formData.get('dateOfResponse'));
            }

            // Handle date conversion with null checks
            // if (formData.containsKey('dateOfResponse') && formData.get('dateOfResponse') != null) {
            //     application.Date_of_SOTS_Response__c = Date.valueOf((String) formData.get('dateOfResponse'));
            // }

            application.Reason__c = (String) formData.get('reason');
        } catch (Exception e) {
            throw new AuraHandledException('Error processing input data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static IndividualApplication fetchApplicationData(Id recordId) {
        try {
            return [SELECT Prefix__c, Last_Name__c, Middle_Name__c, First_Name__c, Suffix__c, Date_Of_Birth__c, Title__c, 
                           Organization_Name__c, Email_Address__c, Cell_Phone_Number__c, ESQ__c, Address_Line_1__c, Suite_Apartment_Floor__c, 
                           City__c, State__c, Country__c, Zip_Code__c, Letter_Text__c, Enclosure__c, Proposed_Use__c, Requested_For__c, 
                           Disposition__c, Approved_For__c, Date_of_SOTS_Response__c, Reason__c, Signedby__c, Letter_Type__c, Wet_Signature__c 
                    FROM IndividualApplication 
                    WHERE Id = :recordId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching application data: ' + e.getMessage());
        }
    }

    // Helper method to parse date from different formats and ensure yyyy-MM-dd format
private static Date parseDate(String dateStr) {
    try {
        System.debug('Attempting to parse date in yyyy-MM-dd format: ' + dateStr);
        // Check if the format is already "yyyy-MM-dd" and parse
        if (dateStr.contains('-') && dateStr.length() == 10) {
            return Date.valueOf(dateStr);
        } 
        
        // Check if the format is "MM/dd/yyyy" and reformat
        else if (dateStr.contains('/') && dateStr.length() == 10) {
            System.debug('Attempting to parse date in MM/dd/yyyy format: ' + dateStr);
            List<String> dateParts = dateStr.split('/');
            if (dateParts.size() == 3) {
                String reformattedDate = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
                System.debug('Reformatted date to yyyy-MM-dd: ' + reformattedDate);
                return Date.valueOf(reformattedDate);
            } else {
                throw new AuraHandledException('Invalid date format: ' + dateStr);
            }
        } else {
            throw new AuraHandledException('Unknown date format: ' + dateStr);
        }
    } catch (Exception e) {
        System.debug('Error parsing date after all attempts: ' + dateStr);
        throw new AuraHandledException('Error parsing date: ' + dateStr);
    }
}






}