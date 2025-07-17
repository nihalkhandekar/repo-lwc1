@isTest
public class SAP_FinsysAgingReportTest {
    
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
    static void testagingReport() {
         
        String jsonInput = '{"customerName":"CustomerOne", "reportDate":null,"currentPage":1, "recordsPerPage":5, "sortedBy":"Name", "sortedDirection":"ASC"}';
       
        Test.startTest();
        List<Map<String, Object>> result = SAP_FinsysAgingReport.agingReport(jsonInput);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');

      }

   @isTest
    static void testagingReportCount() {
        
        String jsonInput = '{"Name":"CustomerTwo"}';

        Test.startTest();
        Integer count = SAP_FinsysAgingReport.agingReportCount(jsonInput);
        Test.stopTest();
        System.assert(count > 0, 'Expected aging Report Count to be greater than zero.');
    }
}