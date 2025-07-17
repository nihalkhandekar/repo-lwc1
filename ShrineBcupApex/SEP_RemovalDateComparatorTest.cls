/* NAME         :  SEP_RemovalDateComparatorTest
* DESCRIPTION   :  Test Class for SEP_RemovalDateComparator
* @AUTHOR       :  Sakshi Nawab
********************************************************************************************/
@isTest
public with sharing class SEP_RemovalDateComparatorTest {
    /********************************************************************************************
        METHOD NAME    : checkValidRequestTest
        DESCRIPTION    : check for valid removal request test method
    ********************************************************************************************/
    @isTest
    static void checkValidRequestTest(){
        Test.startTest();
        List<SEP_RemovalDateComparator.Requests> lstRequests =  new List<SEP_RemovalDateComparator.Requests>();
        SEP_RemovalDateComparator.Requests orequest = new SEP_RemovalDateComparator.Requests();
        orequest.dtRemovalDateTime = System.now();
        orequest.sUserTime = '2021-09-03 14:49:17';
        lstRequests.add(orequest);
        System.assert(SEP_RemovalDateComparator.checkIsValidRemoval(lstRequests) != null);
        try {
            SEP_RemovalDateComparator.checkIsValidRemoval(null);
        } catch (AuraHandledException oException) {
            System.assertNotEquals(null,oException.getMessage());
        }
        Test.stopTest();
    }
}