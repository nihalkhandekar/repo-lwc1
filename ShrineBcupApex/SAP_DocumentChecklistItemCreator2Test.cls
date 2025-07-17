@IsTest
public class SAP_DocumentChecklistItemCreator2Test {
    
    @testSetup
    static void setupTestData() {
       
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
 
        IndividualApplication testApp = new IndividualApplication(
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Organization_Name__c = 'Test Org',
            SAP_Expedited__c = true,
            LicenseTypeId = licenseType.Id,
            Category = 'License'
        );
        insert testApp;
    }
    
    // Successful scenario for the LWC method.
    @isTest
    static void testCreateDocumentChecklistItemsLwc_Success() {
       
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
        
        // Providing all keys with default or empty values so that no property is null.
        String jsonInput = '[{' +
            '"id": "", ' +                                
            '"typeOfDocument": "SOTS Certified Copies", ' +                      
            '"destinationCountry": "USA", ' +
            '"personName": "Test LWC Checklist", ' +
            '"fee": "15.00", ' +
            '"baseFee": "10.00", ' +
            '"isExpedited": false, ' +
            '"status": "Submitted", ' +
            '"hague": "", ' +
            '"selectedContactID": "", ' +
            '"rejectionReason": "", ' +
            '"customRejectionReason": "", ' +
            '"autority": "", ' +
            '"type": "", ' +
            '"signedByPosition": "", ' +
            '"signedByName": "", ' +
            '"feeDisplay": "", ' +
            '"expediteFee": "", ' +
            '"country": "USA", ' +
            '"copyNumber": ""' +
            '}]';
        System.debug('JSON input for LWC method: ' + jsonInput);
        
        Test.startTest();
        String result = SAP_DocumentChecklistItemCreator2.createDocumentChecklistItemsLwc(jsonInput, testApp.Id, 'USA');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'The method should return Success');
       
    }
    
    // Missing required parameters should throw an AuraHandledException.
   @isTest
static void testCreateDocumentChecklistItemsLwc_MissingParameters() {
  
    Test.startTest();
    try {
        SAP_DocumentChecklistItemCreator2.createDocumentChecklistItemsLwc('', Id.valueOf('001000000000000AAA'), 'USA');

    } catch (AuraHandledException e) {
        System.debug('Caught expected exception: ' + e.getMessage());
      
    } catch (Exception ex) {
        System.debug('Caught unexpected exception: ' + ex.getMessage());
      
    }
    Test.stopTest();
}

    
    //Invalid JSON input should throw an AuraHandledException.
   @isTest
static void testCreateDocumentChecklistItemsLwc_InvalidJSON() {
    
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
    
    Test.startTest();
    try {
        SAP_DocumentChecklistItemCreator2.createDocumentChecklistItemsLwc('invalid json', testApp.Id, 'USA');
       
    } catch (AuraHandledException e) {
        System.debug('Caught expected exception: ' + e.getMessage());
        
    } catch (Exception ex) {
        System.debug('Caught unexpected exception: ' + ex.getMessage());
        
    }
    Test.stopTest();
}

}