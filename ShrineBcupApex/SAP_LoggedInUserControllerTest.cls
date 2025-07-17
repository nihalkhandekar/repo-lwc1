@isTest
public class SAP_LoggedInUserControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test account with billing details
        Account testAccount = new Account(
            Name = 'Test Account',
            SAP_Business_Email_Address__c = 'test.user@example.com',
            Phone = '1234567890',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country'
        );
        insert testAccount;

        // Create a test user WITHOUT linking a Contact
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(
            Alias = 'tuser',
            Email = 'test.user@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            Username = 'test.user@example.com.' + System.currentTimeMillis() // Ensure unique username
        );
        insert testUser;
    }

    @isTest
    static void testGetUserDetailsCityStateCountryOptions() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'test.user@example.com' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            SAP_LoggedInUserController.UserCityStateCountryWrapper userWrapper = SAP_LoggedInUserController.getUserDetailsCityStateCountryOptions();
            Test.stopTest();
            
            
            System.assertNotEquals(userWrapper, null, 'The returned wrapper object should not be null');
            System.assertNotEquals(userWrapper.userDetails, null, 'User details should not be null');
            System.assertEquals(testUser.Id, userWrapper.userDetails.Id, 'User Id should match the logged-in user');

        }
    }
}