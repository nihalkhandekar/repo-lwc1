/*********************************************************************************************
* NAME:  CredentialResponse
* DESCRIPTION: This class is used to parse the respose from mulesoft api
*
* @AUTHOR: Rohit Heera
* @DATE: 18/03/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*Rohit Heera                     18/03/2020                         Created the first version


*********************************************************************************************/

public with sharing class CredentialResponse {
 
 public List<CredentialDetail> credentials;
public  class CredentialDetail {
      public  String eLicense_Credential_ID='';
       public String eLicense_Contact_ID='';
      public String eLicense_SOTS_ID='';
      public String Full_Credential_Code='';
      public  String Business_Individual_Name='';
      public  String Expiration_Date='';
      public  String Credential_Type='';
      public  String Credential_Public_Status='';
      public String Credential_Public_Status_Reason='';
      public  String Display_Category_Status='';
      public  String Display_Category_Value='';
      public String MainAddress='';
      public String MailingAddress='';
      public String Doing_Business_As='';
      public Boolean isContactCred=false;
     public List<ActionItems> ActionItems=new List<ActionItems>();
      public String businessRecordID='';
      public Boolean checked = false;
        public String value ='';
        public Boolean credAlreadyLinked = false;
        public Boolean linkValueNotSelected = false;
        public String Cust_ID=null;
        public String Cust_Email=null;
        public Boolean isEmailVerified = false;
        public Boolean isCredIdVerified = false;
        public String eLicense_Dupcred_ID ;
        public String errorMsg ;
    }
    
    public class ActionItems
    {
        public String eLicense_SOTS_ID='';
        public String Credential='';
        public String Name='';
        public String eLicense_Credential_Action_Due_Date='';
        public String Description='';
        public String Link_Text='';
        public String Link_URL='';
        public String Activity_ID='';
    }

    public static CredentialResponse parseData(String response) {
  
        CredentialResponse credResponse = (CredentialResponse) JSON.deserialize(response, CredentialResponse.class);
        for(CredentialDetail detail : credResponse.credentials){
            if(String.isNotBlank(detail.Cust_Email)){
            detail.Cust_Email = EncryptAndDecryptHelper.processEncryption(detail.Cust_Email);
            }
           if(String.isNotBlank(detail.Cust_ID)){
            detail.Cust_ID = EncryptAndDecryptHelper.processEncryption(detail.Cust_ID);
            }
        }
        return credResponse;
    
}
}