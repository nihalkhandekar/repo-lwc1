@isTest
public class AddOfficeControllerTest {

  @isTest
static void testGetNextMaxId() {
    try {
        // Test Case 1: No records initially
        Integer nextMaxIdNoRecords = AddOfficeController.getNextMaxId();
        System.assert(false, 'Should have thrown an exception when no records exist');
    } catch (System.QueryException e) {
        System.assert(e.getMessage().contains('List has no rows for assignment to SObject'), 
            'Expected QueryException when no records exist');
    }

    // Test Case 2: Valid numeric Id__c
    Office__c validOffice = new Office__c(Id__c = '1');
    insert validOffice;
    Integer nextMaxId = AddOfficeController.getNextMaxId();
    System.assertEquals(2, nextMaxId, 'The next max ID should be 2 for valid numeric Id__c.');

    // Test Case 3: Non-numeric Id__c
    Office__c nonNumericOffice = new Office__c(Id__c = 'abc');
    insert nonNumericOffice;
    nextMaxId = AddOfficeController.getNextMaxId();
    System.assertEquals(1, nextMaxId, 'The next max ID should default to 1 for non-numeric Id__c.');
    
    // Test Case 4: Blank Id__c
    Office__c blankIdOffice = new Office__c(Id__c = '');
    insert blankIdOffice;
    nextMaxId = AddOfficeController.getNextMaxId();
    System.assertEquals(1, nextMaxId, 'The next max ID should default to 1 for blank Id__c.');
    
    // Test Case 5: Null Id__c
    Office__c nullIdOffice = new Office__c(Id__c = null);
    insert nullIdOffice;
    nextMaxId = AddOfficeController.getNextMaxId();
    System.assertEquals(1, nextMaxId, 'The next max ID should default to 1 for null Id__c.');
}

    @isTest
    static void testGetDistrictOptions() {
        RecordType congressionalRT = [SELECT Id FROM RecordType WHERE Name = 'Congressional' AND SObjectType = 'District__c' LIMIT 1];
        RecordType houseAssemblyRT = [SELECT Id FROM RecordType WHERE Name = 'House Assembly' AND SObjectType = 'District__c' LIMIT 1];
        RecordType senatorialRT = [SELECT Id FROM RecordType WHERE Name = 'Senatorial' AND SObjectType = 'District__c' LIMIT 1];

        District__c congressionalDistrict = new District__c(District_Id__c = 'CD1', RecordTypeId = congressionalRT.Id);
        District__c houseDistrict = new District__c(District_Id__c = 'HD1', RecordTypeId = houseAssemblyRT.Id);
        District__c senatorialDistrict = new District__c(District_Id__c = 'SD1', RecordTypeId = senatorialRT.Id);
        
        insert new List<District__c>{ congressionalDistrict, houseDistrict, senatorialDistrict };
        Map<String, List<AddOfficeController.DistrictOption>> districtOptions = AddOfficeController.getDistrictOptions();
        System.assertEquals(1, districtOptions.get('Congressional').size(), 'There should be 1 Congressional district option.');
        System.assertEquals(1, districtOptions.get('House Assembly').size(), 'There should be 1 House Assembly district option.');
        System.assertEquals(1, districtOptions.get('Senatorial').size(), 'There should be 1 Senatorial district option.');
    }

@isTest
static void testUpsertOffice() {
    // Test 1: Successful update
    Office__c office = new Office__c(Name__c = 'Test Office');
    insert office;
    Map<String, Object> formData = new Map<String, Object>();
    formData.put('recordId', office.Id);
    formData.put('name', 'Updated Office');
    formData.put('officeType', 'Town');
    
    String updatedOfficeId = AddOfficeController.upsertOffice(formData);
    Office__c updatedOffice = [SELECT Id, Name__c FROM Office__c WHERE Id = :updatedOfficeId LIMIT 1];
    System.assertEquals('Updated Office', updatedOffice.Name__c, 'The office name should be updated.');
    
    // Test 2: DML Exception
    Id deletedRecordId = office.Id;
    delete office;
    
    formData.clear();
    formData.put('recordId', deletedRecordId);  // Using ID of deleted record
    formData.put('name', 'Test Office');
    
    Boolean dmlExceptionCaught = false;
    try {
        AddOfficeController.upsertOffice(formData);
    } catch (AuraHandledException e) {
        dmlExceptionCaught = true;
        // Print the actual error message for debugging
        System.debug('DML Exception Message: ' + e.getMessage());
    }
    System.assert(dmlExceptionCaught, 'DML Exception should have been caught');
    
    // Test 3: General Exception
    formData.clear();
    formData.put('recordId', 'InvalidId');  // Invalid ID format
    formData.put('name', 'Test Office');
    
    Boolean generalExceptionCaught = false;
    try {
        AddOfficeController.upsertOffice(formData);
    } catch (AuraHandledException e) {
        generalExceptionCaught = true;
        // Print the actual error message for debugging
        System.debug('General Exception Message: ' + e.getMessage());
    }
    System.assert(generalExceptionCaught, 'General Exception should have been caught');
}
    
    @isTest
    static void testCreateOffices() {
        List<Map<String, Object>> testCases = new List<Map<String, Object>>{
            new Map<String, Object>{'name' => 'Test Town Office', 'officeType' => 'Town'},
            new Map<String, Object>{'name' => 'Test City Office', 'officeType' => 'City'},
            new Map<String, Object>{'name' => 'Test State Office', 'officeType' => 'State'}
        };
        
        Test.startTest();
        
        for(Map<String, Object> formData : testCases) {
            String officeType = (String)formData.get('officeType');
            String officeName = (String)formData.get('name');
            String newOfficeId = AddOfficeController.upsertOffice(formData);
            
            Office__c newOffice = [SELECT Id, Name__c, RecordTypeId FROM Office__c WHERE Id = :newOfficeId LIMIT 1];
        
            System.assertEquals(officeName, newOffice.Name__c, 'The office name should match the input for ' + officeType);

            String expectedRecordTypeId = Schema.SObjectType.Office__c
                .getRecordTypeInfosByName()
                .get(officeType)
                .getRecordTypeId();
                
            System.assertEquals(expectedRecordTypeId, newOffice.RecordTypeId, 
                'The RecordTypeId should match the ' + officeType + ' record type.');
        }
        Test.stopTest();
        
        List<Office__c> allOffices = [SELECT Id FROM Office__c];
        System.assertEquals(3, allOffices.size(), 'Should have created 3 offices in total'); 
    }

    @isTest
    static void testFetchOfficeAndDistrictData() {
        Office__c office = new Office__c(Name__c = 'Test Office');
        insert office;
    
        RecordType congressionalRT = [SELECT Id FROM RecordType WHERE Name = 'Congressional' AND SObjectType = 'District__c' LIMIT 1];
        RecordType houseAssemblyRT = [SELECT Id FROM RecordType WHERE Name = 'House Assembly' AND SObjectType = 'District__c' LIMIT 1];
        RecordType senatorialRT = [SELECT Id FROM RecordType WHERE Name = 'Senatorial' AND SObjectType = 'District__c' LIMIT 1];
    
        District__c congressionalDistrict = new District__c(District_Id__c = 'CD1', RecordTypeId = congressionalRT.Id);
        insert congressionalDistrict;
    
        District__c houseDistrict = new District__c(District_Id__c = 'HD1', RecordTypeId = houseAssemblyRT.Id);
        insert houseDistrict;
    
        District__c senatorialDistrict = new District__c(District_Id__c = 'SD1', RecordTypeId = senatorialRT.Id);
        insert senatorialDistrict;
    
        Office_District_Mapping__c congressionalMapping = new Office_District_Mapping__c(Office__c = office.Id, District__c = congressionalDistrict.Id);
        Office_District_Mapping__c houseMapping = new Office_District_Mapping__c(Office__c = office.Id, District__c = houseDistrict.Id);
        Office_District_Mapping__c senatorialMapping = new Office_District_Mapping__c(Office__c = office.Id, District__c = senatorialDistrict.Id);
        
        insert new List<Office_District_Mapping__c>{ congressionalMapping, houseMapping, senatorialMapping };
        AddOfficeController.OfficeWrapper wrapper = AddOfficeController.fetchOfficeAndDistrictData(office.Id);

        System.assertEquals(office.Id, wrapper.office.Id, 'The office ID should match.');
        System.assertEquals(congressionalDistrict.District_Id__c, wrapper.congDistLabel, 'The Congressional District label should match.');
        System.assertEquals(1, wrapper.houseDistIds.size(), 'There should be 1 House Assembly district mapping.');
        System.assertEquals(houseDistrict.District_Id__c, wrapper.houseDistLabels[0], 'The House Assembly District label should match.');
        System.assertEquals(1, wrapper.senatorialDistIds.size(), 'There should be 1 Senatorial district mapping.');
        System.assertEquals(senatorialDistrict.District_Id__c, wrapper.senatorialDistLabels[0], 'The Senatorial District label should match.');
    }

    @isTest
    static void testInsertOfficeDistrictMappings() {
        Office__c office = new Office__c(Name__c = 'Test Office');
        insert office;
    
        RecordType congressionalRT = [SELECT Id FROM RecordType WHERE Name = 'Congressional' AND SObjectType = 'District__c' LIMIT 1];
        RecordType houseAssemblyRT = [SELECT Id FROM RecordType WHERE Name = 'House Assembly' AND SObjectType = 'District__c' LIMIT 1];
        RecordType senatorialRT = [SELECT Id FROM RecordType WHERE Name = 'Senatorial' AND SObjectType = 'District__c' LIMIT 1];
    
        District__c congressionalDistrict = new District__c(District_Id__c = 'CD1', RecordTypeId = congressionalRT.Id);
        insert congressionalDistrict;
    
        District__c houseDistrict = new District__c(District_Id__c = 'HD1', RecordTypeId = houseAssemblyRT.Id);
        insert houseDistrict;
    
        District__c senatorialDistrict = new District__c(District_Id__c = 'SD1', RecordTypeId = senatorialRT.Id);
        insert senatorialDistrict;
    
        Map<String, Object> formData = new Map<String, Object>();
        formData.put('congDistId', congressionalDistrict.Id);
        formData.put('houseDistIds', new List<Id>{houseDistrict.Id});
        formData.put('senatorialDistIds', new List<Id>{senatorialDistrict.Id});
        formData.put('officeType', 'Town');
        formData.put('recordId', office.Id);
    
        Test.startTest();
        AddOfficeController.upsertOffice(formData);
        Test.stopTest();
    
        List<Office_District_Mapping__c> mappings = [SELECT Id, District__c FROM Office_District_Mapping__c WHERE Office__c = :office.Id];
        System.assertEquals(3, mappings.size(), 'There should be 3 district mappings for the office.');
    
        Set<Id> districtIds = new Set<Id>();
        for (Office_District_Mapping__c mapping : mappings) {
            districtIds.add(mapping.District__c);
        }

        System.assert(districtIds.contains(congressionalDistrict.Id), 'The Congressional District should be mapped.');
        System.assert(districtIds.contains(houseDistrict.Id), 'The House Assembly District should be mapped.');
        System.assert(districtIds.contains(senatorialDistrict.Id), 'The Senatorial District should be mapped.');
    }
}