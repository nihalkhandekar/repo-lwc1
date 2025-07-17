@isTest
public with sharing class CTBOT_BusinessSearchByID_Test {
    
    @testSetup
    static void makeData() {
        List<Integer> dueDatesFromNow = new List<Integer>{ 30, 100 };
        Account Acc1 =BRS_TestDataFactory.createAccountObject();
        Acc1.Annual_Report_Due_Date__c= system.today();
        update Acc1;
        Account acc2 = BRS_TestDataFactory.createAccountObject();
        acc2.Annual_Report_Due_Date__c= system.today().addDays(100);
        update acc2;
    }

    @isTest
    static void testDateWithinNinetyDays() {
        List<CTBOT_BusinessSearchByID.Output> results = new List<CTBOT_BusinessSearchByID.Output>();
        List<Account> accounts = getAccountsOrderedByDate();

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Account>(accounts).keySet()));
        results = CTBOT_BusinessSearchByID.getBusinessInfoByID(new List<String>{ accounts[0].AccountNumber });
        Test.stopTest();
        //Commenting since getting prod validation failure
        System.assert(results[0].withinNinetyDays == true);
        System.assert(results[0].businessName.contains('Test Account'));
    }

    @isTest
    static void testGreaterThanNinetyDays() {
        List<CTBOT_BusinessSearchByID.Output> results = new List<CTBOT_BusinessSearchByID.Output>();
        List<Account> accounts = getAccountsOrderedByDate();

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Account>(accounts).keySet()));
        results = CTBOT_BusinessSearchByID.getBusinessInfoByID(new List<String>{ accounts[1].AccountNumber });
        Test.stopTest();
        //Commenting since getting prod validation failure
        System.assert(results[0].withinNinetyDays == false);
        System.assert(results[0].businessName.contains('Test Account'));
    }

    private static List<Account> getAccountsOrderedByDate() {
        Account dateWithinNinetyDays;
        Account dateGreaterThanNinetyDays;
        List<Account> accountsOrderedByDueDate;

        List<Account> testAccountList = [
            SELECT AccountNumber, Annual_Report_Due_Date__c, Status__c
            FROM Account
        ];

        if (testAccountList[0].Annual_Report_Due_Date__c < testAccountList[1].Annual_Report_Due_Date__c) {
            accountsOrderedByDueDate = testAccountList;
        } else {
            accountsOrderedByDueDate = new List<Account>{ testAccountList[1], testAccountList[0]};
        }

        return accountsOrderedByDueDate;
    }
}