@IsTest(SeeAllData = true)
public with sharing class LightningForgotPasswordControllerTest {

    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
    }

    /* Verifies that null checkEmailRef URL throws proper exception */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }

    /* Verifies redirection is handled correctly */
    @IsTest
    static void testForgotPasswordRedirection() {
        // Use a valid URL to simulate redirection
        String result = LightningForgotPasswordController.forgotPassword('validUser@salesforce.com', 'http://a.com');
        System.assertEquals(null, result, 'Expected no error message for a valid username and URL');
    }

    /* Verifies that LightningForgotPasswordController object is instantiated correctly */
    @IsTest
    static void testLightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    
    /* Verifies that setExperienceId method works as expected */
    @IsTest
    static void testSetExperienceId() {
        // Test with a valid Experience ID, expecting the community error message
        String result = LightningForgotPasswordController.setExperienceId('12345');
        System.assertEquals('This method can be invoked only from within a community.', result, 
            'Expected community-specific error message for non-community context');

        // Test with a null Experience ID (should not throw an error)
        String resultNull = LightningForgotPasswordController.setExperienceId(null);
        System.assertEquals(null, resultNull, 'Expected no error message for null Experience ID');
    }
}