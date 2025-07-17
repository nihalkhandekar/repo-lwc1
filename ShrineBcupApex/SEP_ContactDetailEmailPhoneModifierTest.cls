/* DESCRIPTION: This is Test class for SEP_ContactDetailEmailPhoneModifier      
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                          16-September-2021               Created First Version
***************************************************************************************************/
@isTest
private class SEP_ContactDetailEmailPhoneModifierTest {
     /********************************************************************************************
        METHOD NAME    : makeData
        DESCRIPTION    : Test method for creating test data 
    ********************************************************************************************/
    @TestSetup
    static void makeData(){
    SEP_Exclusion_Consent__c objConsent = new SEP_Exclusion_Consent__c();
    objConsent.Last_Name__c = 'User';
    objConsent.First_Name__c = 'Test';
    objConsent.Unique_Identifier_Number__c = '123456789';
    objConsent.Date_Of_Birth__c = date.newInstance(2000, 1, 1);
    objConsent.Minimum_Self_Exclusion_Period__c = 'L';
    objConsent.Exclusion_Start_DateTime__c = datetime.now();
    objConsent.Removal_Allowed_DateTime__c = datetime.now();
    objConsent.Exclusion_Status_Change_Date__c = datetime.now();
    insert objConsent;
   
    SEP_Contact_Detail__c objConDetail = new SEP_Contact_Detail__c();
    objConDetail.Email_Address__c = 'abc@xyz.com';
    objConDetail.IsPrimary__c = true;
    objConDetail.IsVerified__c = true;
    objConDetail.SEP_Exclusion_Consent__c = objConsent.id;
    insert objConDetail;
        
 	SEP_Contact_Detail__c objConDetail2 = new SEP_Contact_Detail__c();
    objConDetail2.Phone_number__c = '1234567890';
    objConDetail2.IsPrimary__c = true;
    objConDetail2.IsVerified__c = false;
    objConDetail2.SEP_Exclusion_Consent__c = objConsent.id;        
    insert objConDetail2; 
        
    }
    
    /********************************************************************************************
        METHOD NAME    : UnitTest1
        DESCRIPTION    : Test method for before Insert
    ********************************************************************************************/
    @isTest static void UnitTest1() {
        
    List<SEP_Exclusion_Consent__c> lstExclusionRecord = new List<SEP_Exclusion_Consent__c>();
    lstExclusionRecord = [SELECT id,Name,CreatedDate,Exclusion_Start_DateTime__c,Removal_Allowed_DateTime__c,Minimum_Self_Exclusion_Period__c,Exclusion_Status_Change_Date__c FROM SEP_Exclusion_Consent__c];
        
    List<SEP_Contact_Detail__c> lstConDetail = new List<SEP_Contact_Detail__c>();   
    SEP_Contact_Detail__c objConDetail = new SEP_Contact_Detail__c();
    objConDetail.Email_Address__c = 'abc@xyz.com';
    objConDetail.IsPrimary__c = true;
    objConDetail.IsVerified__c = true;
    objConDetail.SEP_Exclusion_Consent__c = lstExclusionRecord[0].id;     
    lstConDetail.add(objConDetail);
        
 	SEP_Contact_Detail__c objConDetail2 = new SEP_Contact_Detail__c();
    objConDetail2.Phone_number__c = '1234567890';
    objConDetail2.IsPrimary__c = true;
    objConDetail2.IsVerified__c = false;
    objConDetail2.SEP_Exclusion_Consent__c = lstExclusionRecord[0].id;        
    lstConDetail.add(objConDetail2); 
        
    SEP_Contact_Detail__c objConDetail3 = new SEP_Contact_Detail__c();
    objConDetail3.Email_Address__c = 'abcee@xyz.com';
    objConDetail3.IsPrimary__c = true;
    objConDetail3.IsVerified__c = true;
    objConDetail3.SEP_Exclusion_Consent__c = lstExclusionRecord[0].id;
    lstConDetail.add(objConDetail3);     
        
    SEP_Contact_Detail__c objConDetail4 = new SEP_Contact_Detail__c();
    objConDetail4.Phone_number__c = '1111167890';
    objConDetail4.IsPrimary__c = true;
    objConDetail4.IsVerified__c = true;
    objConDetail4.SEP_Exclusion_Consent__c = lstExclusionRecord[0].id;
    lstConDetail.add(objConDetail4);
        
    Test.startTest();
    insert lstConDetail;
    delete lstConDetail;  
    Test.stopTest();  
    }
}