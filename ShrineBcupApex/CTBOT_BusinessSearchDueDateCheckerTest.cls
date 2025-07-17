@isTest
public with sharing class CTBOT_BusinessSearchDueDateCheckerTest {
    
    @testSetup
    static void makeData() {
        CTBOT_TestDataFactory.createAccounts(2, new List<Integer>{30, 100}, 'Active', true);
    }

    @isTest
    static void testTrue() {
        Date withinNinetyDays = Date.today().addDays(30);
        List<Account> testAccounts = [
            SELECT Id, Annual_Report_Due_Date__c
            FROM Account
            WHERE Annual_Report_Due_Date__c = :withinNinetyDays
        ];
        List<Boolean> results = CTBOT_BusinessSearchDueDateChecker.dueDateWithinNinetyDays(testAccounts);
        System.assertEquals(true, results[0]);
    }

    @isTest
    static void testFalse() {
        Date withinNinetyDays = Date.today().addDays(100);
        List<Account> testAccounts = [
            SELECT Id, Annual_Report_Due_Date__c
            FROM Account
            WHERE Annual_Report_Due_Date__c = :withinNinetyDays
        ];
        List<Boolean> results = CTBOT_BusinessSearchDueDateChecker.dueDateWithinNinetyDays(testAccounts);
        System.assertEquals(false, results[0]);
    }
}