public with sharing class AddOfficeController {

    // Custom class to represent SelectOption
    public class DistrictOption {
        @AuraEnabled public String label { get; set; }  // This will hold the District_Id__c
        @AuraEnabled public String value { get; set; }  // This will hold the District's Salesforce ID

        // Constructor
        public DistrictOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    // Wrapper class to return both office and district data
    public class OfficeWrapper {
        @AuraEnabled public Office__c office { get; set; }
        @AuraEnabled public String congDistId { get; set; }
        @AuraEnabled public String congDistLabel { get; set; }
        @AuraEnabled public List<String> houseDistIds { get; set; }
        @AuraEnabled public List<String> houseDistLabels { get; set; }
        @AuraEnabled public List<String> senatorialDistIds { get; set; }
        @AuraEnabled public List<String> senatorialDistLabels { get; set; }

        public OfficeWrapper() {
            houseDistIds = new List<String>();
            houseDistLabels = new List<String>();
            senatorialDistIds = new List<String>();
            senatorialDistLabels = new List<String>();
        }
    }



    @AuraEnabled
    public static Integer getNextMaxId() {
        // Fetch the last created record's Id__c value, ordered by CreatedDate in descending order
        Office__c lastRecord = [SELECT Id, Id__c FROM Office__c WITH SECURITY_ENFORCED
        ORDER BY Id_Number__c DESC LIMIT 1];

        if (lastRecord != null && String.isNotBlank(lastRecord.Id__c)) {
            try {
                // Convert Id__c from String to Integer
                Integer idValue = Integer.valueOf(lastRecord.Id__c);
                return idValue + 1; // Return max + 1
            } catch (Exception e) {
                // Handle conversion failure (e.g., non-numeric Id__c)
                System.debug('Invalid Id__c value: ' + lastRecord.Id__c);
                return 1; // Return default value if conversion fails
            }
        } else {
            // Return 1 if no valid record is found
            return 1;
        }
    }


    @AuraEnabled(cacheable=true)
    public static Map<String, List<DistrictOption>> getDistrictOptions() {
        Map<String, List<DistrictOption>> districtOptions = new Map<String, List<DistrictOption>>();

        // Fetch all Districts with District_Id__c
        List<District__c> districts = [SELECT Id, District_Id__c, RecordType.Name FROM District__c WHERE RecordType.Name IN ('Congressional', 'Senatorial', 'House Assembly') WITH SECURITY_ENFORCED
        ORDER BY District_Id__c];

        // Prepare DistrictOption lists for each record type
        List<DistrictOption> congressionalOptions = new List<DistrictOption>();
        List<DistrictOption> houseAssemblyOptions = new List<DistrictOption>();
        List<DistrictOption> senatorialOptions = new List<DistrictOption>();

        for (District__c district : districts) {
            // Create a DistrictOption with the label as District_Id__c and value as the Salesforce Id
            DistrictOption option = new DistrictOption(district.Id, district.District_Id__c);

            if (district.RecordType.Name == 'Congressional') {
                congressionalOptions.add(option);
            } else if (district.RecordType.Name == 'House Assembly') {
                houseAssemblyOptions.add(option);
            } else if (district.RecordType.Name == 'Senatorial') {
                senatorialOptions.add(option);
            }
        }

        // Add the options to the map
        districtOptions.put('Congressional', congressionalOptions);
        districtOptions.put('House Assembly', houseAssemblyOptions);
        districtOptions.put('Senatorial', senatorialOptions);

        return districtOptions;
    }

    @AuraEnabled
    public static String upsertOffice(Map<String, Object> formData) {
        try {
            Office__c officeRecord;
            Boolean isNewRecord = false;

            // Check if we're inserting a new record or updating an existing one
            String recordIdString = (String) formData.get('recordId');
            String officeType = (String) formData.get('officeType'); // Get office type from formData

            if (String.isNotBlank(recordIdString)) {
                // Perform an update since recordId is provided
                officeRecord = updateOffice(recordIdString, formData);
            } else {
                // Perform an insert since recordId is null or blank
                isNewRecord = true;
                officeRecord = createOffice(formData);
            }

            // Only insert district mappings if the officeType is 'Town'
            if (String.isNotBlank(officeType) && officeType == 'Town' && officeRecord != null) {
                insertOfficeDistrictMappings(officeRecord.Id, formData, isNewRecord);
            }

            // Return the ID of the upserted record
            return officeRecord.Id;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Error upserting record: ' + dmlEx.getDmlMessage(0) + ' - ' + dmlEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }

    // Helper method to handle the insert scenario
    private static Office__c createOffice(Map<String, Object> formData) {
        try {
            System.debug('Creating a new Office record with formData: ' + formData);

            Office__c newOffice = new Office__c();

            // Populate the fields for insert
            populateFields(newOffice, formData);
            System.debug('Office fields populated: ' + newOffice);

            // Set the RecordTypeId based on officeType in formData
            String officeType = (String) formData.get('officeType');
            if (String.isNotBlank(officeType)) {
                if (officeType == 'Town') {
                    newOffice.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Town').getRecordTypeId();
                } else if (officeType == 'City') {
                    newOffice.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('City').getRecordTypeId();
                } else if (officeType == 'State') {
                    newOffice.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('State').getRecordTypeId();
                }
                System.debug('Office RecordType set to: ' + officeType + ', RecordTypeId: ' + newOffice.RecordTypeId);
            }

            // Insert the new record
            Database.insert(newOffice, false, AccessLevel.USER_MODE);

            //insert newOffice;
            System.debug('Successfully inserted new Office record with Id: ' + newOffice.Id);

            return newOffice;
        } catch (Exception e) {
            System.debug('Error in createOffice: ' + e.getMessage());
            throw new AuraHandledException('Error inserting new record: ' + e.getMessage());
        }
    }


    private static Office__c updateOffice(String recordIdString, Map<String, Object> formData) {
        try {
            System.debug('Updating Office record with Id: ' + recordIdString + ' and formData: ' + formData);

            Id recordId = Id.valueOf(recordIdString);
            Office__c existingOffice = [SELECT Id FROM Office__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('Fetched existing Office record: ' + existingOffice);

            // Populate the fields for update
            populateFields(existingOffice, formData);
            System.debug('Office fields populated for update: ' + existingOffice);

            // Update the existing record
            Database.update(existingOffice, false, AccessLevel.USER_MODE);

            //update existingOffice;
            System.debug('Successfully updated Office record with Id: ' + existingOffice.Id);

            return existingOffice;
        } catch (Exception e) {
            System.debug('Error in updateOffice: ' + e.getMessage());
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }


    private static void populateFields(Office__c officeRecord, Map<String, Object> formData) {
        try {
            System.debug('Populating fields for office: ' + formData);

            // Populate fields based on formData
            officeRecord.Name__c = formData.containsKey('name') && formData.get('name') != null ? String.valueOf(formData.get('name')) : null;
            officeRecord.Election_Held_In__c = formData.containsKey('electionHeldIn') && formData.get('electionHeldIn') != null ? String.valueOf(formData.get('electionHeldIn')) : null;
            officeRecord.Business_Email__c = formData.containsKey('email') && formData.get('email') != null ? String.valueOf(formData.get('email')) : null;
            officeRecord.Mailing_Address_Line_1__c = formData.containsKey('address1') && formData.get('address1') != null ? String.valueOf(formData.get('address1')) : null;
            officeRecord.Mailing_Address_Line_2__c = formData.containsKey('address2') && formData.get('address2') != null ? String.valueOf(formData.get('address2')) : null;
            officeRecord.Mailing_Address_City__c = formData.containsKey('city') && formData.get('city') != null ? String.valueOf(formData.get('city')) : null;
            officeRecord.Mailing_Address_State__c = formData.containsKey('state') && formData.get('state') != null ? String.valueOf(formData.get('state')) : null;
            officeRecord.Mailing_Address_Zip__c = formData.containsKey('zipCode') && formData.get('zipCode') != null ? String.valueOf(formData.get('zipCode')) : null;
            officeRecord.Mailing_Address_Country__c = formData.containsKey('country') && formData.get('country') != null ? String.valueOf(formData.get('country')) : null;
            officeRecord.Id__c = formData.containsKey('id') && formData.get('id') != null ? String.valueOf(formData.get('id')) : null;
            officeRecord.ROV_Name__c = formData.containsKey('rovName') && formData.get('rovName') != null ? String.valueOf(formData.get('rovName')) : null;
            officeRecord.Title__c = formData.containsKey('title') && formData.get('title') != null ? String.valueOf(formData.get('title')) : null;

        } catch (Exception e) {
            System.debug('Error in populateFields: ' + e.getMessage());
            throw new AuraHandledException('Error processing input data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static OfficeWrapper fetchOfficeAndDistrictData(Id recordId) {
        OfficeWrapper wrapper = new OfficeWrapper();

        // Fetch office data
        wrapper.office = [SELECT Id, Name__c, Election_Held_In__c, Business_Email__c,ROV_Name__c, Mailing_Address_Line_1__c, Mailing_Address_Line_2__c,
                            Mailing_Address_City__c, Mailing_Address_State__c, Mailing_Address_Zip__c, Mailing_Address_Country__c, Id__c, Title__c
                          FROM Office__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        // Fetch related district mappings from the junction object
        List<Office_District_Mapping__c> districtMappings = [
            SELECT District__r.District_Id__c, District__r.RecordType.Name, District__c
            FROM Office_District_Mapping__c
            WHERE Office__c = :recordId WITH SECURITY_ENFORCED
        ];

        for (Office_District_Mapping__c mapping : districtMappings) {
            String districtType = mapping.District__r.RecordType.Name;
            String districtId = mapping.District__c;
            String districtLabel = mapping.District__r.District_Id__c;

            // Assign district details to the wrapper
            if (districtType == 'Congressional') {
                wrapper.congDistId = districtId;
                wrapper.congDistLabel = districtLabel;
            } else if (districtType == 'House Assembly') {
                wrapper.houseDistIds.add(districtId);
                wrapper.houseDistLabels.add(districtLabel);
            } else if (districtType == 'Senatorial') {
                wrapper.senatorialDistIds.add(districtId);
                wrapper.senatorialDistLabels.add(districtLabel);
            }
        }

        return wrapper;
    }

   // Insert or update District Mappings after Office creation
    private static void insertOfficeDistrictMappings(Id officeId, Map<String, Object> formData, Boolean isNewRecord) {
        List<Office_District_Mapping__c> mappingsToInsert = new List<Office_District_Mapping__c>();
        List<Id> districtIds = new List<Id>();

        // Handle Congressional District
        if (formData.containsKey('congDistId')) {
            Id congDistId = (Id) formData.get('congDistId');
            districtIds.add(congDistId);
        }

        // Handle House Assembly Districts
        if (formData.containsKey('houseDistIds')) {
            List<Object> houseDistIds = (List<Object>) formData.get('houseDistIds');
            for (Object obj : houseDistIds) {
                districtIds.add((Id) obj);
            }
        }

        // Handle Senatorial Districts
        if (formData.containsKey('senatorialDistIds')) {
            List<Object> senatorialDistIds = (List<Object>) formData.get('senatorialDistIds');
            for (Object obj : senatorialDistIds) {
                districtIds.add((Id) obj);
            }
        }

        // If updating an existing office, fetch existing district mappings
        Map<Id, Office_District_Mapping__c> existingMappings = new Map<Id, Office_District_Mapping__c>();
        if (!isNewRecord) {
            List<Office_District_Mapping__c> existingMappingsList = [
                SELECT District__c
                FROM Office_District_Mapping__c
                WHERE Office__c = :officeId WITH SECURITY_ENFORCED
            ];
            for (Office_District_Mapping__c mapping : existingMappingsList) {
                existingMappings.put(mapping.District__c, mapping);
            }
        }

        // Query District__c to get their RecordType.Name dynamically
        List<District__c> districtRecords = [
            SELECT Id, RecordType.Name
            FROM District__c
            WHERE Id IN :districtIds WITH SECURITY_ENFORCED
        ];

        // Insert new mappings only if they don't already exist
        for (District__c district : districtRecords) {
            if (!existingMappings.containsKey(district.Id)) {
                // Create a new mapping if it does not exist
                mappingsToInsert.add(new Office_District_Mapping__c(
                    Office__c = officeId,
                    District__c = district.Id,
                    District_Type__c = district.RecordType.Name
                ));
            }
        }

        // Insert new district mappings
        if (!mappingsToInsert.isEmpty()) {
            Database.insert(mappingsToInsert, false, AccessLevel.USER_MODE);
            //insert mappingsToInsert;
        }
    }
}