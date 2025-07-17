@isTest
public class SelfCeriftyBadgeLWCControllerTest {
     @isTest
    public static void testemailexists(){
      Business_Reopen_Certification__c obj1 = new Business_Reopen_Certification__c();
      obj1.Email_Address__c = 'mohan1@gmail.com';
      obj1.Date__c=Date.valueOf('2020-06-07');
      obj1.Business_Type__c='Accommodation and Food Services';
      obj1.Representative_last_Name__c='Jaiswal';
      insert obj1;
        
      Test.startTest();
      SelfCeriftyBadgeLWCController.emailIdExists('mohan1@gmail.com');
      Test.stopTest();
    }  
    
     @isTest
     public static void testemailnotexists(){
      Business_Reopen_Certification__c obj1 = new Business_Reopen_Certification__c();
      obj1.Email_Address__c = 'mohan1@gmail.com';
      obj1.Date__c=Date.valueOf('2020-06-07');
      obj1.Business_Type__c='Accommodation and Food Services';
      obj1.Representative_last_Name__c='Jaiswal';
      insert obj1;
        
      Test.startTest();
      SelfCeriftyBadgeLWCController.emailIdExists('mohan66@gmail.com');
      Test.stopTest();
    }
}