/* DESCRIPTION: This class is used to genrate request Wrapper with the request JSON that is send by 
*               Mulesoft      
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                             30-August-2021                      Created First Version
***************************************************************************************************/
public with sharing class SEP_ConsentRequestWrapper {

    public List<Consentwrapper> lstConsentWrapper;
   /*
    * Description: 		Constructor of the SEP_ConsentRequestWrapper class
    * Param 1: 			none
    * Return Type: 		none
    *
    */
    public SEP_ConsentRequestWrapper(){
        this.lstConsentWrapper = lstConsentWrapper;
    }

    public class Consentwrapper{
        public String sFirstName;
        public String sMiddleName;
        public String sLastName;
        public String sDateOfBirth;
        public String sUniqueIdentifierNumber;
        public String sAddress;
        public String sUnitApt;
        public String sCity;
        public String sState;
        public String sZipCode;
        public String sAddressNotProvided;
        public String sMinimumSelfExclusionPeriod;
        public String sPrimaryEmailAddress;
        public String sAlternateEmailAddress1;
        public String sAlternateEmailAddress2;
        public String sAlternateEmailAddress3;
        public String sAlternateEmailAddress4;
        public String sAlternateEmailAddress5;
        public String sPrimaryPhoneNumber;
        public String sAlternatePhoneNumber;
        public String sConsentProvided;
        public String sExclusionSource;
        public String sVendorName;
        public String sLanguagePreference;

        public Consentwrapper(String sFirstName,String sMiddleName,String sLastName,String sDateOfBirth,String sUniqueIdentifierNumber,
                                    String sAddress,String sUnitApt,String sCity,String sState,String sZipCode,String sAddressNotProvided,
                                    String sMinimumSelfExclusionPeriod,String sPrimaryEmailAddress,String sAlternateEmailAddress1,
                                    String sAlternateEmailAddress2,String sAlternateEmailAddress3,String sAlternateEmailAddress4,
                                    String sAlternateEmailAddress5,String sPrimaryPhoneNumber,String sAlternatePhoneNumber,
                                    String sConsentProvided,String sExclusionSource,String sVendorName,String sLanguagePreference){


            this.sFirstName = sFirstName;
            this.sMiddleName = sMiddleName;
            this.sLastName = sLastName;
            this.sDateOfBirth = sDateOfBirth;
            this.sUniqueIdentifierNumber = sUniqueIdentifierNumber;
            this.sAddress = sAddress;
            this.sUnitApt = sUnitApt;
            this.sCity = sCity;
            this.sState = sState;
            this.sZipCode = sZipCode;
            this.sAddressNotProvided = sAddressNotProvided;
            this.sMinimumSelfExclusionPeriod = sMinimumSelfExclusionPeriod;
            this.sPrimaryEmailAddress = sPrimaryEmailAddress;
            this.sAlternateEmailAddress1 = sAlternateEmailAddress1;
            this.sAlternateEmailAddress2 = sAlternateEmailAddress2;
            this.sAlternateEmailAddress3 = sAlternateEmailAddress3;
            this.sAlternateEmailAddress4 = sAlternateEmailAddress4;
            this.sAlternateEmailAddress5 = sAlternateEmailAddress5;
            this.sPrimaryPhoneNumber = sPrimaryPhoneNumber;
            this.sAlternatePhoneNumber = sAlternatePhoneNumber;
            this.sConsentProvided = sConsentProvided;
            this.sExclusionSource = sExclusionSource;
            this.sVendorName = sVendorName; 
            this.sLanguagePreference = sLanguagePreference;            
        }                      
    }
}