@isTest
private class InterOrgBusinessHoursCheckTest {
    @isTest
    static void testBlankBusinessHoursSun() {
        InterOrgBusinessHoursCheck.testDay = 'Sunday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 10, 12, 0, 0);
        InterOrgChatCalloutMock.testBlankBusinessHours_ForSunday = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(false, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursMon() {
        InterOrgBusinessHoursCheck.testDay = 'Monday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 10, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursTue() {
        InterOrgBusinessHoursCheck.testDay = 'Tuesday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 11, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursWed() {
        InterOrgBusinessHoursCheck.testDay = 'Wednesday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 12, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursThur() {
        InterOrgBusinessHoursCheck.testDay = 'Thursday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 13, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursFri() {
        InterOrgBusinessHoursCheck.testDay = 'Friday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 14, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursSat() {
        InterOrgBusinessHoursCheck.testDay = 'Saturday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 15, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testBusinessHoursSun() {
        InterOrgBusinessHoursCheck.testDay = 'Sunday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 16, 12, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(true, results[0].isWithinBusinessHours);
    }

    @isTest
    static void testOutsideBusinessHours() {
        InterOrgBusinessHoursCheck.testDay = 'Monday';
        InterOrgBusinessHoursCheck.testCurrentDt = Datetime.newInstance(2022, 10, 19, 0, 0, 0);
        InterOrgChatCalloutMock.testBusinessHours = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());
        List<InterOrgBusinessHoursCheck.BusinessHoursWrapper> results = InterOrgBusinessHoursCheck.checkBusinessHours(
            new List<String>{ 'Test' }
        );
        System.assertEquals(false, results[0].isWithinBusinessHours);
    }
}