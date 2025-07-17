@isTest
public with sharing class brs_AccountNoAddressBatchTest {
    @testSetup static void dataSetup(){
        
        
    }
    
    @isTest static void executeBatchTest2(){
        Id profileId = [select id from profile where name='System Administrator'].id;
        User user=BRS_TestDataFactory.createUser(profileId);
            System.runAs(user){
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Citizenship__c='Domestic';
            acc.Business_Type__c='LLP';
            acc.ClientAccountNum__c='12345';
            acc.Purpose_of_Business__c = 'Test business run';
            acc.Status__c='Active';
            acc.Sub_Status__c = system.label.Active_Ready_for_Admin_Dissolution;
            Account acc2 = new Account();
            acc2.Name = 'Test Account2';
            acc2.Citizenship__c='Domestic';
            acc2.Business_Type__c='LLP';
            acc2.ClientAccountNum__c='12345';
            acc2.Purpose_of_Business__c = 'Test business run2';
            acc2.Status__c='Active';
            acc2.Sub_Status__c = system.label.Active_Ready_for_Admin_Dissolution;
            insert acc;
            insert acc2;
            Agent__c agent = BRS_TestDataFactory.createAgent(acc.Id);
            acc.No_address_found__c = false;
            acc2.No_address_found__c = false;
            update acc;
            update acc2;
            Test.startTest();
            brs_AccountNoAddressBatch bmr=new brs_AccountNoAddressBatch();
            Database.executeBatch(bmr);
            Test.stopTest();
        }
    }
}