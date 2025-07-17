/* DESCRIPTION: This is Test class for SEP_FetchConsentService      
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                          16-September-2021               Created First Version
***************************************************************************************************/
@isTest
public class SEP_FetchConsentServiceTest { 
    /********************************************************************************************
        METHOD NAME    : fetchConsentRecordsTestFailure
        DESCRIPTION    : Test method for creating test data
    ********************************************************************************************/
    @isTest
    static void fetchConsentRecordsTestFailure(){  
    RestRequest request = new RestRequest();
    String sBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    String sEndpoint = sBaseUrl+'/services/apexrest/FetchConsentRecords';
    request.requestUri = sEndpoint;
    request.httpMethod = 'GET';
            
    RestContext.request = request;
    SEP_FetchConsentService.fetchConsentRecords();
        }
     /********************************************************************************************
        METHOD NAME    : fetchConsentRecordsTest
        DESCRIPTION    : Test method for test GET request
    ********************************************************************************************/ 
      @isTest
        static void fetchConsentRecordsTest(){
            
    SEP_Exclusion_Consent__c objConsent = new SEP_Exclusion_Consent__c();
    objConsent.Last_Name__c = 'User';
    objConsent.First_Name__c = 'Test';
    objConsent.Unique_Identifier_Number__c = '123456789';
    objConsent.Date_Of_Birth__c = date.newInstance(2000,1,1);
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
    objConDetail2.IsPrimary__c = true;
    objConDetail2.IsVerified__c = true;
    objConDetail2.SEP_Exclusion_Consent__c = objConsent.id;
    insert objConDetail2;
            
            RestRequest request = new RestRequest();
            String sBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String sEndpoint = sBaseUrl+'/services/apexrest/FetchConsentRecords';
            request.requestUri = sEndpoint;
            request.httpMethod = 'GET';
            
            RestContext.request = request;
            SEP_FetchConsentService.fetchConsentRecords();
            
            
        }
}