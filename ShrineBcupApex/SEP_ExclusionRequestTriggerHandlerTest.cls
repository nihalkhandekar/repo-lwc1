/* NAME         :  SEP_ExclusionRequestTriggerHandlerTest
* DESCRIPTION   :  Test Class for SEP_ExclusionRequestTriggerHandler & SEP_ExclusionRequestTriggerHelper
* @AUTHOR       :  Sakshi Nawab
********************************************************************************************/
@isTest
public class SEP_ExclusionRequestTriggerHandlerTest {
    /********************************************************************************************
        METHOD NAME    : insertRecordTestOneYear
        DESCRIPTION    : Test data for 1 year period use case
    ********************************************************************************************/
    @isTest
    static void insertRecordTestOneYear(){
        SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'Test_Staff',
        Last_Name__c = 'Staff01',
        Date_Of_Birth__c = Date.newInstance(2000, 12, 9),
        Unique_Identifier_Number__c = '123456789',
        Minimum_Self_Exclusion_Period__c = '1',
        Exclusion_Source__c = 'DCP Staff');
        insert objSep;
    }
    @isTest
    static void insertRecordTestFiveYear(){
        SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'Test_Staff',
        Last_Name__c = 'Staff02',
        Date_Of_Birth__c = Date.newInstance(2000,11, 9),
        Unique_Identifier_Number__c = '123456788',
        Minimum_Self_Exclusion_Period__c = '5',
        Exclusion_Source__c = 'DCP Staff');
        insert objSep;
    }
    @isTest
    static void insertRecordTestLifeTime(){
        SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'Test_Staff',
        Last_Name__c = 'Staff03',
        Date_Of_Birth__c = Date.newInstance(2000,11, 9),
        Unique_Identifier_Number__c = '123456777',
        Minimum_Self_Exclusion_Period__c = 'L',
        Exclusion_Source__c = 'DCP Staff');
        insert objSep;
    }
    @isTest
    static void updateRecord(){
        SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'Test_Staff',
        Last_Name__c = 'Staff04',
        Date_Of_Birth__c = Date.newInstance(2000,11, 9),
        Unique_Identifier_Number__c = '123457777',
        Minimum_Self_Exclusion_Period__c = '1',
        Exclusion_Source__c = 'DCP Staff');
        insert objSep;
        SEP_Exclusion_Consent__c objExclusion = [SELECT Id,Minimum_Self_Exclusion_Period__c,Unique_Identifier_Number__c FROM SEP_Exclusion_Consent__c WHERE Exclusion_Source__c = 'DCP Staff' LIMIT 1];
        objExclusion.Minimum_Self_Exclusion_Period__c = 'L';
        update objExclusion;
    }
    /********************************************************************************************
        METHOD NAME    : coverNullMethods
        DESCRIPTION    : to cover trigger contexts
    ********************************************************************************************/
    @isTest
    static void coverNullMethods(){
        SEP_ExclusionRequestTriggerHandler objHandler = new SEP_ExclusionRequestTriggerHandler();
        objHandler.beforeDelete(null,null);
        objHandler.afterInsert(null,null);
        objHandler.afterUpdate(null,null);
        objHandler.afterDelete(null);
        objHandler.afterUndelete(null,null);
    }
     /********************************************************************************************
        METHOD NAME    : UpdateStatusByProfile
        DESCRIPTION    : Test method for testing update scenario 
    ********************************************************************************************/
    @isTest
    static void UpdateStatusByProfile(){
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Agency User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/New_York',
        UserName=uniqueUserName);

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DCP_Self_Exclusion'];

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) { 
           Test.startTest();
           SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'Test_Staff',
                                                                          Last_Name__c = 'Staff04',
                                                                          Date_Of_Birth__c = Date.newInstance(2000,11, 9),
                                                                          Unique_Identifier_Number__c = '123457777',
                                                                          Minimum_Self_Exclusion_Period__c = '1',
                                                                          Exclusion_Source__c = 'DCP Staff',
                                                                          Exclusion_Consent_Status__c = 'Removed');
            insert objSep;
            SEP_Exclusion_Consent__c objExclusion = [SELECT Id,Minimum_Self_Exclusion_Period__c,Unique_Identifier_Number__c FROM SEP_Exclusion_Consent__c WHERE Exclusion_Source__c = 'DCP Staff' LIMIT 1];
            objExclusion.Minimum_Self_Exclusion_Period__c = '1';
            objExclusion.Exclusion_Consent_Status__c = 'Active';
            update objExclusion;
            
            objExclusion.Exclusion_Consent_Status__c = 'Removed';
            update objExclusion;
            Test.stopTest();
            
        }
    }
}