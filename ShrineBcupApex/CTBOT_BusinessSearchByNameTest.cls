@isTest
public with sharing class CTBOT_BusinessSearchByNameTest {
    
    @testSetup
    static void makeData() {
        List<Integer> dueDatesFromNow = new List<Integer>{ 30 };
        BRS_TestDataFactory.createAccountObject();
    }

    @isTest
    static void testGetBusinessInfoByName() {
        List<CTBOT_BusinessSearchByName.Output> results = new List<CTBOT_BusinessSearchByName.Output>();
        List<CTBOT_BusinessSearchByName.Input> inputs = new List<CTBOT_BusinessSearchByName.Input>();
        CTBOT_BusinessSearchByName.Input input = new CTBOT_BusinessSearchByName.Input();
        input.name = 'Test';
        inputs.add(input);
        Account testAccount = [
            SELECT Id
            FROM Account
        ];

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{ testAccount.Id });
        results = CTBOT_BusinessSearchByName.getBusinessInfoByName(inputs);
        Test.stopTest();

        System.assertEquals(1, results[0].resultCount);
        System.assertNotEquals(null, results[0].accounts);
    }
}