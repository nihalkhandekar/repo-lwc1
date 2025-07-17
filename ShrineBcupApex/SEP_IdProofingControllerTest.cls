/* NAME         :  SEP_IdProofingControllerTest
* DESCRIPTION   :  Test Class for SEP_IdProofingController
* @AUTHOR       :  Sakshi Nawab
********************************************************************************************/
@isTest
public with sharing class SEP_IdProofingControllerTest {
    /********************************************************************************************
        METHOD NAME    : insertcase
        DESCRIPTION    : insert case record when id proofing fails
    ********************************************************************************************/
    @isTest
    static void insertcase(){
        SEP_Exclusion_Case__c objSep = new SEP_Exclusion_Case__c(First_Name__c = 'Test_Staff',
        Last_Name__c = 'Staff04',
        Date_Of_Birth__c = '2000/11/9',
        SSN_Tax_ID_Number__c = '123457777',
        Minimum_Self_Exclusion_Period__c = '1',
        Self_Exclusion_Registration_Source__c = 'DCP Staff');
        SEP_IdProofingController.createCaseRecord(objSep);
    }
     /********************************************************************************************
        METHOD NAME    : insertcaseCatch
        DESCRIPTION    : to cover catch block
    ********************************************************************************************/
    @isTest
    static void insertcaseCatch(){
        try{
            SEP_IdProofingController.createCaseRecord(null);
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}