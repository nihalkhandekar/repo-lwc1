@isTest
public class SAP_FinsysCreditBalanceReportTest {
    
    @testSetup
    static void setupTestData() {
        // Create RecordType for 'FinSys Customers'
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'FinSys Customers' AND SObjectType = 'Contact' LIMIT 1];
        

        // Create test Contacts
        List<Contact> contacts = new List<Contact>{
            new Contact(
                LastName = 'CustomerOne',
                Email = 'customer1@example.com',
                Phone = '1234567890',
                SAP_Customer_Account_Balance__c = 500.00,
                SAP_Last_Balance_Update__c = Date.today(),
                MailingStreet = '123 Main St',
                MailingCity = 'New York',
                MailingState = 'NY',
                MailingPostalCode = '10001',
                MailingCountry = 'USA', 
                RecordTypeId = recordType.Id
            ),
            new Contact(
                LastName = 'CustomerTwo',
                Email = 'customer2@example.com',
                Phone = '9876543210',
                SAP_Customer_Account_Balance__c = 1000.00,
                SAP_Last_Balance_Update__c = Date.today(),
                MailingStreet = '456 Elm St',
                MailingCity = 'Los Angeles',
                MailingState = 'CA',
                MailingPostalCode = '90001',
                MailingCountry = 'USA',
                RecordTypeId = recordType.Id
            )
        };
        insert contacts;
    }

    @isTest
    static void testCreditBalanceReport() {
        
        Contact testContact = [SELECT Id, Customer__c FROM Contact WHERE LastName = 'CustomerOne'];
        System.debug(testContact.Customer__c);
        String jsonInput = '{"customerId":"'+testContact.Customer__c+'", "name":"CustomerOne", "createddate":null, "transactionFromDate":"2025-01-01", "transactionToDate":"2025-12-31", "currentPage":1, "pageSize":10, "sortedBy":"Name", "sortedDirection":"ASC"}';
  		
        Test.startTest();
        List<Map<String, Object>> results = SAP_FinsysCreditBalanceReport.creditBalanceReport(jsonInput);
        Test.stopTest();
      
    	System.assertNotEquals(0, results.size(), 'Expected at least one record to be returned.');
        System.assertEquals(testContact.Customer__c, results[0].get('Customer__c'), 'Customer ID should match the expected Contact.Customer__c');

     }

    @isTest
    static void testCreditBalanceReportCount() {
        
         Contact testContact = [SELECT Id, Customer__c FROM Contact WHERE LastName = 'CustomerTwo'];
         String jsonInput = '{"customerId":"'+testContact.Customer__c+'", "name":"CustomerTwo", "createddate":null, "transactionFromDate":"2025-01-01", "transactionToDate":"2025-12-31"}';
        
        Test.startTest();
		Integer count = SAP_FinsysCreditBalanceReport.creditBalanceReportCount(jsonInput);
        Test.stopTest(); 
        
        System.assert(count > 0, 'Expected credit Balance Report count to be greater than zero.');
    }
}