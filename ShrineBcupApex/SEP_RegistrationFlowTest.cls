/* NAME         :  SEP_RegistrationFlowTest
* DESCRIPTION   :  Test Class for SEP_RegistrationFlow_SelfExclusion
* @AUTHOR       :  Sakshi Nawab
********************************************************************************************/
@isTest
public class SEP_RegistrationFlowTest {
    /********************************************************************************************
        METHOD NAME    : calculateEndDateTest
        DESCRIPTION    : Test data for 1 year period use case
    ********************************************************************************************/
    @isTest
    static void calculateEndDateTest(){
        Test.startTest();
        List<SEP_RegistrationFlow_SelfExclusion.Requests> lstRequests =  new List<SEP_RegistrationFlow_SelfExclusion.Requests>();
        SEP_RegistrationFlow_SelfExclusion.Requests orequest = new SEP_RegistrationFlow_SelfExclusion.Requests();
        orequest.dtNewStatusChangeDate = System.now();
        orequest.sNewRequestExclusionPeriod = '1';
        lstRequests.add(orequest);
        System.assert(SEP_RegistrationFlow_SelfExclusion.calculateEndDate(lstRequests) != null);
        try {
            SEP_RegistrationFlow_SelfExclusion.calculateEndDate(null);
        } catch (AuraHandledException oException) {
            System.assertNotEquals(null,oException.getMessage());
        }
        Test.stopTest();
    }
    /********************************************************************************************
        METHOD NAME    : calculateEndDateTest5Year
        DESCRIPTION    : Test data for 5 year period use case
    ********************************************************************************************/
    @isTest
    static void calculateEndDateTest5Year(){
        Test.startTest();
        List<SEP_RegistrationFlow_SelfExclusion.Requests> lstRequests =  new List<SEP_RegistrationFlow_SelfExclusion.Requests>();
        SEP_RegistrationFlow_SelfExclusion.Requests orequest = new SEP_RegistrationFlow_SelfExclusion.Requests();
        orequest.dtNewStatusChangeDate = System.now();
        orequest.sNewRequestExclusionPeriod = '5';
        lstRequests.add(orequest);
        System.assert(SEP_RegistrationFlow_SelfExclusion.calculateEndDate(lstRequests) != null);
        try {
            SEP_RegistrationFlow_SelfExclusion.calculateEndDate(null);
        } catch (AuraHandledException oException) {
            System.assertNotEquals(null,oException.getMessage());
        }
        Test.stopTest();
    }
    /********************************************************************************************
        METHOD NAME    : calculateEndDateTest5Year
        DESCRIPTION    : Test data for life time period use case
    ********************************************************************************************/
    @isTest
    static void calculateEndDateTestLifetime(){
        Test.startTest();
        List<SEP_RegistrationFlow_SelfExclusion.Requests> lstRequests =  new List<SEP_RegistrationFlow_SelfExclusion.Requests>();
        SEP_RegistrationFlow_SelfExclusion.Requests orequest = new SEP_RegistrationFlow_SelfExclusion.Requests();
        orequest.dtNewStatusChangeDate = System.now();
        orequest.sNewRequestExclusionPeriod = 'L';
        lstRequests.add(orequest);
        System.assert(SEP_RegistrationFlow_SelfExclusion.calculateEndDate(lstRequests) != null);
        try {
            SEP_RegistrationFlow_SelfExclusion.calculateEndDate(null);
        } catch (AuraHandledException oException) {
            System.assertNotEquals(null,oException.getMessage());
        }
        Test.stopTest();
    }
}