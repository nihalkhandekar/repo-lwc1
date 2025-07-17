@isTest
public class SAP_ExtraditionRequestControllerTest {
    
    @testSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
        insert licenseType;
       
        IndividualApplication testRequest = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_Attorney_Inspector__c = 'Test Inspector',
            Office__c = 'Test Office',
            SAP_Address_Line_1__c = '123 Test St',
            SAP_City__c = 'Test City',
            SAP_State__c = 'TS',
            SAP_Zip_Code__c = '12345',
            SAP_Country__c = 'Test Country',
            SAP_Last_Name__c = 'Doe',
            SAP_Middle_Name__c = 'M',
            SAP_First_Name__c = 'John',
            SAP_Suffix__c = 'Jr',
            SAP_Extradiction_PC__c = 123,
            SAP_Extradiction_Auth__c = 456,
            SAP_Notes_on_Receipt__c = 'Test Notes',
            Category='License'
        );
        insert testRequest;

      
        Person_AKA__c aka1 = new Person_AKA__c(
            Individual_Application__c = testRequest.Id,
            Name = 'Alias Doe',
            First_Name__c = 'Alias',
            Middle_Name__c = 'M',
            Suffix__c = 'Sr',
            ESQ__c = true
        );
        insert aka1;
    }
    
    @isTest
    static void testGetDetailsforExtradictionReceiptPdf() {
        
     
        IndividualApplication testRequest = [SELECT Id FROM IndividualApplication WHERE SAP_Attorney_Inspector__c='Test Inspector' LIMIT 1];
        
        Test.startTest();
        Map<String, String> details = SAP_ExtraditionRequestController.getDetailsforExtradictionReceiptPdf(testRequest.Id);
        Test.stopTest();
        
        System.assert(details != null, 'Returned map should not be null.');
        System.assertEquals('Jr John M Doe', details.get('personSoughtName'), 'Incorrect personSoughtName');

        
    }
    
    @isTest
    static void testFetchExtradictionRequestData() {
        Id testRequestId = [SELECT Id, SAP_Suffix__c FROM IndividualApplication LIMIT 1].Id;
        
        Test.startTest();
        IndividualApplication requestData = SAP_ExtraditionRequestController.fetchExtradictionrequestData(testRequestId);
        Test.stopTest();
        
        System.assertNotEquals(null, requestData, 'Result should not be null');
      
    }
    
    @isTest
    static void testUpsertNewRequestData() {
      
        IndividualApplication existingApplication = [SELECT Id FROM IndividualApplication LIMIT 1];
        List<Person_AKA__c> existingAkas = [SELECT Id, First_Name__c FROM Person_AKA__c WHERE Individual_Application__c = :existingApplication.Id];

        // JSON Test Data for Request Update
        String requestDataString = JSON.serialize(new Map<String, Object>{
            'idofrecord' => existingApplication.Id,
            'receivedForFillingDate' => String.valueOf(Date.today()),
            'extractedFileNumber' => 'EXT-12345',
            'attorneyInspector' => 'Inspector Name',
            'office' => 'Main Office',
            'location' => '123 Test St',
            'address2' => 'Suite 200',
            'city' => 'Test City',
            'state' => 'CA',
            'zipCode' => '90210',
            'country' => 'USA',
            'comments' => 'This is a test comment',
            'extradictedFrom' => 'Canada',
            'esq' => true,
            'lastName' => 'Doe',
            'middleInitial' => 'M',
            'firstName' => 'John',
            'suffix' => 'Jr',
            'requestDate' => String.valueOf(Date.today()),
            'responseDate' => String.valueOf(Date.today().addDays(5)),
            'extradictionpc' => 5,
            'extradictionAuth' => 10,
            'notes' => 'Some additional notes',
            'destination' => 'New York',
            'akaList' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'id' => existingAkas[0].Id,
                    'akafirstName' => 'Johnny',
                    'akalastName' => 'D',
                    'akamiddleInitial' => 'M',
                    'akasuffix' => 'Jr',
                    'akaesq' => true
                },
                new Map<String, Object>{
                    'akafirstName' => 'NewFirstName',
                    'akalastName' => 'NewLastName',
                    'akamiddleInitial' => 'X',
                    'akasuffix' => 'III',
                    'akaesq' => false
                }
            }
        });

       
        Test.startTest();
        Id updatedRecordId = SAP_ExtraditionRequestController.upsertNewRequestData(requestDataString);
        Test.stopTest();
        
        System.assertNotEquals(null, updatedRecordId, 'Response should not be null');
     

      
    }
}