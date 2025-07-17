@isTest
public with sharing class brs_myFilerInfoControllerTest {
    public static testmethod void testSaveContact(){
        
        
        
       List<User> users; 
         if (System.Label.SSO_DefaultUser != null) {
      users = [Select Id FROM User WHERE Name = :System.Label.SSO_DefaultUser and isActive = true LIMIT 1];
    }
    ID DEFAULT_ACCOUNT_OWNERID = users[0].Id;
    ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.AccountAdminRecordType).getRecordTypeId();
    Account account = new Account(
    Name = 'TestAccount', OwnerId = DEFAULT_ACCOUNT_OWNERID,RecordTypeId=storeRecordTypeId);
   
        insert account;
    
        
        
        
        
        
        Contact cont = new Contact(Lastname = 'TestLastame',AccountId = account.Id );
        insert cont;
Profile p = [SELECT Id FROM Profile WHERE name = 'CT Community User' Limit 1];
    User cuser =    BRS_TestDataFactory.createCommunityUser(cont, p.Id);
        System.runAs(cuser) {
            Test.startTest();
            
            brs_myFilerInfoController.ContactInfo conObj = new brs_myFilerInfoController.ContactInfo(cont);
            
          conObj.organization='Test';
            conObj.street='Test';
            conObj.city='Test';
            conObj.state='Test';
           conObj.country='Test';
            conObj.zip ='12345';
            
            brs_myFilerInfoController.saveContactInfo(JSON.serialize(conObj));
            brs_myFilerInfoController.getContactInfo();
            
            test.stopTest();
        }
    }
}