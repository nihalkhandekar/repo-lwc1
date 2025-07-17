/* NAME         :  SEP_FlowContactDetailRecordsTest
* DESCRIPTION   :  Test Class for SEP_FlowContactDetailRecords
* @AUTHOR       :  Sakshi Nawab
********************************************************************************************/
@isTest
public class SEP_FlowContactDetailRecordsTest {
    @TestSetup
    static void makeData(){
        SEP_Exclusion_Consent__c objSep = new SEP_Exclusion_Consent__c(First_Name__c = 'StatePortal',
        Last_Name__c = 'User01',
        Date_Of_Birth__c = Date.newInstance(2000,11, 9),
        Unique_Identifier_Number__c = '123557777',
        Minimum_Self_Exclusion_Period__c = '1',
        Exclusion_Source__c = 'State Portal');
        insert objSep;
        SEP_Contact_Detail__c objEmail = new SEP_Contact_Detail__c(Email_Address__c = 'test@primary.com',
        IsPrimary__c = true,
        SEP_Exclusion_Consent__c = objSep.Id);
        insert objEmail;
    }
    @isTest
    static void testChildRecords(){
        List<SEP_FlowContactDetailRecords.Requests> lstRequest = new List<SEP_FlowContactDetailRecords.Requests>();
        SEP_FlowContactDetailRecords.Requests objReq = new SEP_FlowContactDetailRecords.Requests();
        SEP_Exclusion_Consent__c objConsent = [SELECT Id FROM SEP_Exclusion_Consent__c LIMIT 1];
        objReq.parentRecordId = objConsent.Id;
        lstRequest.add(objReq);
        SEP_FlowContactDetailRecords.fetchChildRecord(lstRequest);
        try {
            SEP_FlowContactDetailRecords.fetchChildRecord(null);
        } catch (Exception oEx) {
            System.assertNotEquals(null,oEx.getMessage());
        }
    }
}