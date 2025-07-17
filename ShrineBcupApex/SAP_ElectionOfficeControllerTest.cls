@isTest
private class SAP_ElectionOfficeControllerTest {

    @testSetup
    static void setupTestData() {
        String officeRTId;
        
        Map<String, Schema.RecordTypeInfo> officeRTMap = Office__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        if(officeRTMap.containsKey('Town')){
            officeRTId = officeRTMap.get('Town').getRecordTypeId();
        } else {
            officeRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Office__c' LIMIT 1].Id;
        }
        
        Office__c office = new Office__c(
            SAP_Name__c = 'Test Office',
            SAP_Id__c = 'TestId1',           
            SAP_ROV_Name__c = 'Test ROV',
            SAP_Election_Held_In__c = 'May',
            SAP_Title__c = 'Test Title',
            SAP_Mailing_Address_Line_1__c = '123 Test St',
            SAP_Mailing_Address_City__c = 'Test City',
            SAP_Mailing_Address_State__c = 'TS',
            SAP_Mailing_Address_Zip__c = '12345',
            RecordTypeId = officeRTId
        );
        insert office;
        
        
        String districtRTId;
        Map<String, Schema.RecordTypeInfo> districtRTMap = District__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        if(districtRTMap.containsKey('Congressional')){
            districtRTId = districtRTMap.get('Congressional').getRecordTypeId();
        }
        
        District__c district = new District__c(
            Name = 'Congressional District',
            SAP_District_Id__c = 'C1'
        );
        if(districtRTId != null) {
            district.RecordTypeId = districtRTId;
        }
        insert district;
        
        
        Office_District_Mapping__c mapping = new Office_District_Mapping__c(
            Office__c = office.Id,
            District__c = district.Id
        );
        insert mapping;
        
            Contact con = new Contact(
            LastName = 'Test',
            FirstName = 'Contact',
            SAP_Title__c = 'Borough Clerk',
            SAP_Party__c = 'Democratic',
            Office__c = office.Id
        );
        insert con;
    }
    
    
    static testMethod void testGetOfficeOptions() {
        Test.startTest();
        List<String> options = SAP_ElectionOfficeController.getOfficeOptions('Town');
        Test.stopTest();
        
    }
    
    
   static testMethod void testGetElectionOfficesAndCount() {
    
    District__c district = [SELECT Id, SAP_District_Id__c FROM District__c WHERE SAP_District_Id__c = 'C1' LIMIT 1];
    
    
    Office__c testOffice = [
        SELECT Id, RecordType.Name, SAP_Election_Held_In__c, SAP_Mailing_Address_City__c, SAP_Mailing_Address_Zip__c, Name__c 
        FROM Office__c 
        LIMIT 1
    ];
    String officeRTName = testOffice.RecordType.Name;
    
    
    Map<String, Object> criteria = new Map<String, Object>{
        'electionOfficeBy'          => officeRTName,
        'electionHeldIn'            => testOffice.SAP_Election_Held_In__c,
        'congressionalDistId'       => String.valueOf(district.Id),
        'houseAssemblyDistId'       => '',
        'senatorialDistId'          => '',
        'townsElectionOffice'       => 'Test',  // Partial match for Name__c
        'stateElectionOffice'       => 'Test',
        'boroughCityElectionOffice' => 'Test',
        'city'                      => testOffice.SAP_Mailing_Address_City__c,
        'zip'                       => testOffice.SAP_Mailing_Address_Zip__c,
        'startDate'                 => String.valueOf(Date.today().addDays(-1)),
        'endDate'                   => String.valueOf(Date.today().addDays(1)),
        'pageSize'                  => 10,
        'pageNumber'                => 1,
        'sortedBy'                  => 'SAP_Name__c',
        'sortedDirection'           => 'ASC'
    };
    String criteriaJson = JSON.serialize(criteria);
    
    Test.startTest();
        List<SAP_ElectionOfficeController.OfficeWrapper> wrappers = 
            SAP_ElectionOfficeController.getElectionOffices(criteriaJson);
        Integer countResult = SAP_ElectionOfficeController.getElectionOfficesCount(criteriaJson);
    Test.stopTest();
    
   
    
    for(SAP_ElectionOfficeController.OfficeWrapper wrap : wrappers) {
        System.assertEquals('C1', wrap.congressionalDist, 'Congressional District should be C1.');
    }
}

    
    static testMethod void testDeleteOffice() {
        
        String officeRTId;
        Map<String, Schema.RecordTypeInfo> officeRTMap = Office__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        if(officeRTMap.containsKey('Town')){
            officeRTId = officeRTMap.get('Town').getRecordTypeId();
        } else {
            officeRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Office__c' LIMIT 1].Id;
        }
        
        Office__c officeToDelete = new Office__c(
            SAP_Name__c = 'Delete Office',
            SAP_Mailing_Address_City__c = 'Delete City',
            SAP_Mailing_Address_Zip__c = '00000',
            RecordTypeId = officeRTId
        );
        insert officeToDelete;
        
       
        Contact con = new Contact(
            LastName = 'Delete',
            FirstName = 'Contact',
            Office__c = officeToDelete.Id,
            SAP_Title__c = 'Mayor',
            SAP_Party__c = 'Democratic'
        );
        insert con;
        
        Map<String, Object> criteria = new Map<String, Object>{
            'recordId'       => String.valueOf(officeToDelete.Id),
            'startDate'      => String.valueOf(Date.today().addDays(-1)),
            'endDate'        => String.valueOf(Date.today().addDays(1)),
            'pageSize'       => 10,
            'pageNumber'     => 1,
            'sortedBy'       => 'CreatedDate',
            'sortedDirection'=> 'DESC'
        };
        String criteriaJson = JSON.serialize(criteria);
        
        Test.startTest();
        List<Contact> publicOfficials = SAP_ElectionOfficeController.getPublicOfficial(criteriaJson);
        Integer publicOfficialsCount = SAP_ElectionOfficeController.getPublicOfficialsCount(criteriaJson);
        Test.stopTest();
        
     }
}