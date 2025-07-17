@isTest
public with sharing class SEP_ContactDetailTriggerHelperTest {

      /********************************************************************************************
        METHOD NAME    : dataSetup
        DESCRIPTION    : Test method for creating test data 
    ********************************************************************************************/
    @TestSetup
    static void dataSetup(){  
        
    SEP_Exclusion_Consent__c objConsent = new SEP_Exclusion_Consent__c();
    objConsent.Last_Name__c = 'User';
    objConsent.First_Name__c = 'Test';
    objConsent.Unique_Identifier_Number__c = '123456789';
    objConsent.Date_Of_Birth__c = Date.newInstance(2000,1,1);
    objConsent.Minimum_Self_Exclusion_Period__c = 'L';
    objConsent.Exclusion_Start_DateTime__c = datetime.now();
    objConsent.Removal_Allowed_DateTime__c = datetime.now();
    objConsent.Exclusion_Status_Change_Date__c = datetime.now();
    insert objConsent;
   
    List<SEP_Contact_Detail__c> lstContact = new List<SEP_Contact_Detail__c>(); 
    SEP_Contact_Detail__c objConDetail = new SEP_Contact_Detail__c();
    objConDetail.Email_Address__c = 'abc@xyz.com';
    objConDetail.IsPrimary__c = false;
    objConDetail.IsVerified__c = false;
    objConDetail.SEP_Exclusion_Consent__c = objConsent.id;
    lstContact.add(objConDetail);  

    SEP_Contact_Detail__c objConDetail2 = new SEP_Contact_Detail__c();
    objConDetail2.Phone_number__c = '1234567890';
    objConDetail2.IsPrimary__c = true;
    objConDetail2.IsVerified__c = false;
    objConDetail2.SEP_Exclusion_Consent__c = objConsent.id;
    lstContact.add(objConDetail2);  
    insert lstContact;
    
    }

 /********************************************************************************************
        METHOD NAME    : sendVerificationMessagesTest
        DESCRIPTION    : Test method for sendVerificationMessages()
    ********************************************************************************************/
    @isTest static void sendVerificationMessagesTest() {

        List<SEP_Contact_Detail__c> lstObj= [SELECT id,Email_Address__c,Phone_number__c,IsPrimary__c from SEP_Contact_Detail__c];
        Test.startTest();
        Delete lstObj[0];
        lstObj[1].IsVerified__c =true ;
        update lstObj[1];
        Test.stopTest();
        
    }
    
}