@isTest
public class getAddressDetailTest {
    
    // Test setup method to create test data
    @testSetup
    static void setup() {
        // Create a test Account
        Account testAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'johndoe123@gmail.com',
            Phone = '1234567890',
            Customer_ID__pc = '89675612',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            ShippingStreet = '456 Ship St',
            ShippingCity = 'Ship City',
            ShippingState = 'Ship State',
            ShippingPostalCode = '67890',
            ShippingCountry = 'USA'
        );
        insert testAccount;
    }
    
    // Test method to validate getAccountDetails functionality
    @isTest
    static void testGetAccountDetails() {
        // Retrieve the ID of the test Account created in setup
        Account testAccount = [SELECT Id FROM Account where PersonEmail='johndoe123@gmail.com' and Customer_ID__pc ='89675612'  LIMIT 1];
        
        System.debug(testAccount);

        // Call the getAccountDetails method
        Account result = getAddressDetail.getAccountDetails(testAccount.Id);

        // Assertions to verify the returned Account details
        System.assertNotEquals(null, result, 'Expected account record to be returned');
        System.assertEquals('John', result.FirstName, 'First Name does not match');
        System.assertEquals('Doe', result.LastName, 'Last Name does not match');
        System.assertEquals('johndoe123@gmail.com', result.PersonEmail, 'Email does not match');
        System.assertEquals('1234567890', result.Phone, 'Phone does not match');
        System.assertEquals('89675612', result.Customer_ID__pc, 'Customer ID does not match');
        System.assertEquals('123 Test St', result.BillingStreet, 'Billing Street does not match');
        System.assertEquals('Test City', result.BillingCity, 'Billing City does not match');
        System.assertEquals('Test State', result.BillingState, 'Billing State does not match');
        System.assertEquals('12345', result.BillingPostalCode, 'Billing Postal Code does not match');
        System.assertEquals('USA', result.BillingCountry, 'Billing Country does not match');
        System.assertEquals('456 Ship St', result.ShippingStreet, 'Shipping Street does not match');
        System.assertEquals('Ship City', result.ShippingCity, 'Shipping City does not match');
        System.assertEquals('Ship State', result.ShippingState, 'Shipping State does not match');
        System.assertEquals('67890', result.ShippingPostalCode, 'Shipping Postal Code does not match');
        System.assertEquals('USA', result.ShippingCountry, 'Shipping Country does not match');
    }
}