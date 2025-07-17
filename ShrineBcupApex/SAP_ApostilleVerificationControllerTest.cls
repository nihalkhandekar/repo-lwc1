@isTest
public class SAP_ApostilleVerificationControllerTest {
    
  @testSetup
  static void setupTestData() {
    
     Id staffRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Staff' LIMIT 1].Id;
    
    Contact Contact1 = new Contact(
        SAP_position__c = 'Notary Public',
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'johndoe@test.com'
        
    );
    Contact Contact2 = new Contact(
        SAP_position__c = 'Notary Public',
        FirstName = 'Narendra',
        LastName = 'Modi',
        Email = 'Modi@test.com',
        recordTypeId=staffRT
        
    );
    insert new List<Contact>{Contact1,Contact2};
   
    RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
    insert licenseType;

    IndividualApplication testApplication = new IndividualApplication(
        SAP_First_Name__c = 'John',
        SAP_Last_Name__c = 'Doe',
        LicenseTypeId = licenseType.Id,
        Category = 'License'
    );
    insert testApplication;

  
    DocumentChecklistItem docItem1 = new DocumentChecklistItem(
        Name = 'Test Document',
        ParentRecordId = testApplication.Id,
        SAP_Certificate_Number__c = '2025-00001',
        SAP_Country__c = 'USA',
        Status = 'Accepted',
        Signed_By__c = Contact1.Id,
        Signing_Authority__c = Contact2.Id,
        SAP_ApprovedDate__c = Date.Today()
    );
    
      insert  docItem1;
}

    @isTest
    static void testgetApplications() {
       
       
        Test.startTest();
        List<Map<String, Object>> results = SAP_ApostilleVerificationController.getApplications('2025-00001');
        Test.stopTest();
        
        

       System.assertNotEquals(0, results.size(), 'Expected at least one application record.');
       System.assertEquals('2025-00001', results[0].get('certificateNumber'), 'Certificate number should match.');

    }
    
}