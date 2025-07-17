@IsTest
public class CamelCaseHelperTest {

    @TestSetup
    static void setupTestData() {
        // Create sample Account records with various text fields
        Account acc1 = new Account(Name = 'test account one', Industry = 'banking', Description = 'sample description');
        Account acc2 = new Account(Name = 'second test account', Industry = 'communications', Description = 'another example');
        insert new List<Account> { acc1, acc2 };
    }

    @IsTest
    static void testConvertTextFieldsToCamelCase() {
        // Retrieve the test data
        List<Account> accounts = [SELECT Id, Name,lastname,firstname,MiddleName,BillingState,Suffix,BillingCity, Industry, Description FROM Account];

        // Verify initial state before processing
        System.assertEquals('test account one', accounts[0].Name, 'Expected unmodified name before camel case conversion.');
        System.assertEquals('second test account', accounts[1].Name, 'Expected unmodified name before camel case conversion.');

        // Call the CamelCaseHelper method, casting accounts to List<SObject>
        CamelCaseHelper.convertTextFieldsToCamelCase((List<SObject>) accounts);

        // Verify if each text field was converted to capital case
        System.assertEquals('Test Account One', accounts[0].Name, 'Name field should be in capital case.');
        System.assertEquals('Banking', accounts[0].Industry, 'Industry field should be in capital case.');
        System.assertEquals('Sample Description', accounts[0].Description, 'Description field should be in capital case.');
        
        System.assertEquals('Second Test Account', accounts[1].Name, 'Name field should be in capital case.');
        System.assertEquals('Communications', accounts[1].Industry, 'Industry field should be in capital case.');
        System.assertEquals('Another Example', accounts[1].Description, 'Description field should be in capital case.');
    }

    @IsTest
    static void testConvertTextFieldsToCamelCaseEmptyList() {
        // Call the CamelCaseHelper method with an empty list
        CamelCaseHelper.convertTextFieldsToCamelCase(new List<SObject>());

        // Assert no exception is thrown and the method handles an empty list gracefully
        System.assert(true, 'Method should complete without exceptions on an empty list.');
    }
}