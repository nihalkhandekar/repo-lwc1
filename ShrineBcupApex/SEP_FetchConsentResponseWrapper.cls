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
public with sharing class SEP_FetchConsentResponseWrapper {

    public List<Consentwrapper> lstConsentWrapper;
   /*
    * Description: 		Constructor of the SEP_ConsentRequestWrapper class
    * Param 1: 			none
    * Return Type: 		none
    *
    */
    public SEP_FetchConsentResponseWrapper(){
        this.lstConsentWrapper = lstConsentWrapper;
    }

    public class Consentwrapper{
        public String sName;
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
        public String sExclusionStatus;
        public String sExclusionStatusDate;
        public List<ContactDetailWrapper> lstContactDetails;

        public Consentwrapper(String sName,String sFirstName,String sMiddleName,String sLastName,String sDateOfBirth,String sUniqueIdentifierNumber,
                                    String sAddress,String sUnitApt,String sCity,String sState,String sZipCode,String sAddressNotProvided,
                                    String sExclusionStatus,String sExclusionStatusDate,List<ContactDetailWrapper> lstContactDetails){

            this.sName = sName;
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
            this.sExclusionStatus = sExclusionStatus;
            this.sExclusionStatusDate = sExclusionStatusDate; 
            this.lstContactDetails = lstContactDetails;
                       
        }               
    }
    public class ContactDetailWrapper{
        public String sEmailAddress;
        public String sPhoneNumber;
        public String sIsPrimary; 

        public ContactDetailWrapper(String sEmailAddress,String sPhoneNumber,String sIsPrimary){
            this.sEmailAddress = sEmailAddress;
            this.sPhoneNumber = sPhoneNumber;
            this.sIsPrimary = sIsPrimary;
        }
    }      
}