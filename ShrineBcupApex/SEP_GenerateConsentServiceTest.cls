/* DESCRIPTION: This is Test class for SEP_GenerateConsentService     
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                          16-September-2021               Created First Version
***************************************************************************************************/
@isTest
public class SEP_GenerateConsentServiceTest {   
     /********************************************************************************************
        METHOD NAME    : createConsentRecords
        DESCRIPTION    : Test method for test POST request
     ********************************************************************************************/ 
        @isTest
        static void createConsentRecords(){

            SEP_Exclusion_Consent__c objConsent = new SEP_Exclusion_Consent__c();
            objConsent.Last_Name__c = 'User';
            objConsent.First_Name__c = 'Test';
            objConsent.Unique_Identifier_Number__c = '133546789';
            objConsent.Date_Of_Birth__c = date.newInstance(1998, 01, 01); 
            objConsent.Minimum_Self_Exclusion_Period__c = 'L';
            objConsent.Exclusion_Start_DateTime__c = datetime.now();
            objConsent.Removal_Allowed_DateTime__c = datetime.now();
            objConsent.Exclusion_Status_Change_Date__c = datetime.now();
            insert objConsent;
            
            SEP_Exclusion_Consent__c objConsent2 = new SEP_Exclusion_Consent__c();
            objConsent2.Last_Name__c = 'User';
            objConsent2.First_Name__c = 'Test';
            objConsent2.Unique_Identifier_Number__c = '033546789';
            objConsent2.Date_Of_Birth__c = date.newInstance(1998, 01, 01); 
            objConsent2.Minimum_Self_Exclusion_Period__c = '1';
            objConsent2.Exclusion_Start_DateTime__c = datetime.now();
            objConsent2.Removal_Allowed_DateTime__c = datetime.now();
            objConsent2.Exclusion_Status_Change_Date__c = datetime.now();
            insert objConsent2;
   
            SEP_ConsentRequestWrapper.Consentwrapper objConsentWrapper = new SEP_ConsentRequestWrapper.Consentwrapper('','','','','','','','','','','','','','','','','','','','','','','','');
            RestRequest request = new RestRequest();
            String sBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String sEndpoint = sBaseUrl+'/services/apexrest/GenerateConsentRecords';
            request.requestUri = sEndpoint;
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof('{"lstConsentWrapper":[{"sFirstName":"johsssn","sMiddleName":"M","sLastName":"Smith","sDateOfBirth":"1998-01-01","sUniqueIdentifierNumber":"133546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"L","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"abc@ssxyz.com","sAlternateEmailAddress2":"awwwbc@xyz.com","sAlternateEmailAddress3":"abxxxxc@xyz.com","sAlternateEmailAddress4":"abcrrr@xyz.com","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"smith","sMiddleName":"M","sLastName":"william","sDateOfBirth":"2000-01-01","sUniqueIdentifierNumber":"122546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"3","sPrimaryEmailAddress":"abcss@cc.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"false","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"johsssn","sMiddleName":"M","sLastName":"Smith","sDateOfBirth":"1998-01-01","sUniqueIdentifierNumber":"033546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"L","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"john","sMiddleName":"M","sLastName":"william","sDateOfBirth":"2001-01-01","sUniqueIdentifierNumber":"123546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"1","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"vv","sVendorName":"abc","sLanguagePreference":"aa"}]}');
            RestContext.request = request;
            SEP_GenerateConsentService.createConsentRecords();
        }

     /********************************************************************************************
        METHOD NAME    : createConsentRecordsUnitTest2
        DESCRIPTION    : Test method for test POST request
     ********************************************************************************************/ 
		@isTest
		static void createConsentRecordsUnitTest2(){

            SEP_Exclusion_Consent__c objConsent = new SEP_Exclusion_Consent__c();
            objConsent.Last_Name__c = 'User';
            objConsent.First_Name__c = 'Test';
            objConsent.Unique_Identifier_Number__c = '133546789';
            objConsent.Date_Of_Birth__c = date.newInstance(1998, 01, 01); 
            objConsent.Minimum_Self_Exclusion_Period__c = 'L';
            objConsent.Exclusion_Start_DateTime__c = datetime.now();
            objConsent.Removal_Allowed_DateTime__c = datetime.now();
            objConsent.Exclusion_Status_Change_Date__c = datetime.now();
            insert objConsent;
            
            SEP_Exclusion_Consent__c objConsent2 = new SEP_Exclusion_Consent__c();
            objConsent2.Last_Name__c = 'User';
            objConsent2.First_Name__c = 'Test';
            objConsent2.Unique_Identifier_Number__c = '033546789';
            objConsent2.Date_Of_Birth__c = date.newInstance(1998, 01, 01); 
            objConsent2.Minimum_Self_Exclusion_Period__c = '1';
            objConsent2.Exclusion_Start_DateTime__c = datetime.now();
            objConsent2.Removal_Allowed_DateTime__c = datetime.now();
            objConsent2.Exclusion_Status_Change_Date__c = datetime.now();
            insert objConsent2;
   
            SEP_ConsentRequestWrapper.Consentwrapper objConsentWrapper = new SEP_ConsentRequestWrapper.Consentwrapper('','','','','','','','','','','','','','','','','','','','','','','','');
            RestRequest request = new RestRequest();
            String sBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String sEndpoint = sBaseUrl+'/services/apexrest/GenerateConsentRecords';
            request.requestUri = sEndpoint;
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof('{"lstConsentWrapper":[{"sFirstName":"johsssn","sMiddleName":"M","sLastName":"Smith","sDateOfBirth":"1998-01-01","sUniqueIdentifierNumber":"133546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"L","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"abc@ssxyz.com","sAlternateEmailAddress2":"awwwbc@xyz.com","sAlternateEmailAddress3":"abxxxxc@xyz.com","sAlternateEmailAddress4":"abcrrr@xyz.com","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"johsssn","sMiddleName":"M","sLastName":"Smith","sDateOfBirth":"1998-01-01","sUniqueIdentifierNumber":"133546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"L","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"abc@ssxyz.com","sAlternateEmailAddress2":"awwwbc@xyz.com","sAlternateEmailAddress3":"abxxxxc@xyz.com","sAlternateEmailAddress4":"abcrrr@xyz.com","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"smith","sMiddleName":"M","sLastName":"william","sDateOfBirth":"2000-01-01","sUniqueIdentifierNumber":"122546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"3","sPrimaryEmailAddress":"abcss@cc.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"false","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"johsssn","sMiddleName":"M","sLastName":"Smith","sDateOfBirth":"1998-01-01","sUniqueIdentifierNumber":"033546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"L","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"Vendor","sVendorName":"abc","sLanguagePreference":"S"},{"sFirstName":"john","sMiddleName":"M","sLastName":"william","sDateOfBirth":"2001-01-01","sUniqueIdentifierNumber":"123546789","sAddress":"xyz road","sUnitApt":"Unit 3","sCity":"HartFort","sState":"CT","sZipCode":"123456789","sAddressNotProvided":"false","sMinimumSelfExclusionPeriod":"1","sPrimaryEmailAddress":"abc@xyz.com","sAlternateEmailAddress1":"","sAlternateEmailAddress2":"","sAlternateEmailAddress3":"","sAlternateEmailAddress4":"","sAlternateEmailAddress5":"abcdddd@xyz.com","sPrimaryPhoneNumber":"1323567891","sAlternatePhoneNumber":"1453567891","sConsentProvided":"true","sExclusionSource":"vv","sVendorName":"abc","sLanguagePreference":"aa"}]}');
            RestContext.request = request;
            SEP_GenerateConsentService.createConsentRecords();
        }
}