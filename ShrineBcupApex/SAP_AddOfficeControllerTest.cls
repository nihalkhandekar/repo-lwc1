@isTest
public class SAP_AddOfficeControllerTest {

    
     @testSetup
    static void setupTestData() {
        // Create Districts
        List<District__c> districts = TestDataFactory.createDistricts();
        
        // Create Office
        Office__c office = TestDataFactory.createOffice();

        // Map Office to Districts
        TestDataFactory.createOfficeDistrictMappings(office, districts);
    }


    @isTest
    static void testGetNextMaxId() {
        Test.startTest();
        Integer nextMaxId = SAP_AddOfficeController.getNextMaxId();
        Test.stopTest();
        
         System.assertEquals(true, nextMaxId != null, 'Max ID should not be null');
        
    }
   
    @isTest
    static void testGetDistrictOptions() {
        Test.startTest();
   		Map<String, List<SAP_AddOfficeController.DistrictOption>> districtOptions = SAP_AddOfficeController.getDistrictOptions();
 		Test.stopTest();
        
        
    // Assert that the map is not null
    System.assertEquals(true, districtOptions != null, 'District options map should not be null');

    // Assert that the map contains keys and values
    System.assertEquals(true, districtOptions.size() > 0, 'District options map should contain values');
    }

    
   @isTest
    static void testupsertOffice() {
      
        //JSON for INSERT
        Map<String, Object> formData = new Map<String, Object>();
        formData.put('name', 'New Office');
        formData.put('electionHeldIn', 'May');
        formData.put('email', 'newoffice@example.com');
        formData.put('address1', '456 Oak St');
        formData.put('city', 'Townsville');
        formData.put('state', 'Stateville');
        formData.put('zipCode', '67890');
        formData.put('country', 'Countryland');
        formData.put('title', 'Senator');
        formData.put('officeType', 'City'); 
    
        Id recordId = [SELECT Id FROM Office__c WHERE SAP_Name__c = 'Office 1' LIMIT 1].Id;
        //Json for Update
        Map<String, Object> Data = new Map<String, Object>();
        Data.put('recordId',recordId);
        Data.put('electionHeldIn', 'Nov');
        Data.put('email', 'newoffice@example.com');
        Data.put('address1', '456 Oak St');
        Data.put('city', 'Townsville');
        Data.put('state', 'Stateville');
        Data.put('zipCode', '67890');
        Data.put('country', 'Countryland');
        Data.put('title', 'Senator');
        Data.put('officeType', 'Town'); 
        
         Test.startTest();  
         String insertedOfficeId = SAP_AddOfficeController.upsertOffice(formData);
         String updatedOfficeId = SAP_AddOfficeController.upsertOffice(Data);
         Test.stopTest();
        
         Office__c insertedOffice = [SELECT Id, SAP_Election_Held_In__c FROM Office__c WHERE Id = :insertedOfficeId];
         System.assertEquals('May', insertedOffice.SAP_Election_Held_In__c, 'Inserted office electionHeldIn should be 2025');

         Office__c updatedOffice = [SELECT SAP_Election_Held_In__c FROM Office__c WHERE Id = :updatedOfficeId];
         System.assertEquals('Nov', updatedOffice.SAP_Election_Held_In__c, 'Updated office electionHeldIn should be Jun');
 
    
    }
     @isTest
    static void testFetchOfficeAndDistrictData() {
        
         Office__c office = [SELECT Id FROM Office__c WHERE SAP_Name__c = 'Office 1' LIMIT 1];
        
         Test.startTest();  
         SAP_AddOfficeController.OfficeWrapper fetchData = SAP_AddOfficeController.fetchOfficeAndDistrictData(office.Id);
         Test.stopTest();
        
         System.assertEquals(true, fetchData != null, 'Fetch data should not be null');
    }
   
}