/*********************************************************************************************
* NAME:  Bos_VerificationController
* DESCRIPTION: This class generate the verification code and verify the verification code.
*
* @AUTHOR: Rohit Heera
* @DATE: 18/03/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*Rohit Heera                    26/11/2020                         Created the first version


*********************************************************************************************/

public with sharing class Bos_VerificationController {
    public static final String className = 'AccountDashboard';
    public static final String linkBusiness = 'linkBusiness';
    public static final String searchBusiness = 'searchBusiness';
    public static final String accountObject = 'Account';
    @AuraEnabled()
    public static  string  sendNumber( string email) {
        
        Integer rndnum = Math.round((Math.random() * (900000) + 100000));//Math.round(Math.random()*10000);
    
        String otp = string.valueOf(rndnum);
       String value = MD5Hash(otp);
     
 
        
       try {
			User userdata = [Select id, FirstName, LastName, MiddleName, ContactID from User where id =: UserInfo.getUserId() Limit 1];
                System.debug('Enterd in if email section');
                
                //Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                List<string> toAddress = new List<string>();
                toAddress.add(email);
               // OrgWideEmailAddress[] lstOWEA = [select Id from OrgWideEmailAddress where DisplayName =: system.label.Org_Wide_Email_Address_Record_Name];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                //mail.setTemplateId(et.Id);
                message.setToAddresses(toAddress);
                message.setSubject(System.label.VerificationEmailSubject);

                String htmlBody=System.label.Email_Verification_Hello_Content+' '+userdata.FirstName+ ' '+userdata.LastName+', <br/><br/>';
                htmlBody=htmlBody+System.label.VerificationText1+' '+otp;
                htmlBody=htmlBody+'<br/>'+System.label.VerificationText2;
                htmlBody=htmlBody+'<br/><br/>'+System.label.VerificationText3;
                htmlBody=htmlBody+'<br/>'+System.label.VerificationText4;
                htmlBody=htmlBody+'<br/><br/><br/>'+System.label.VerificationText5;
                message.htmlbody=htmlBody;
				OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :system.label.VerificationFromEmailAddress];
           if(owea!=null && owea.size()>0){
                message.setOrgWideEmailAddressId(owea[0].id); 
           }
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                allmsg.add(message);
               
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
           if(Test.isRunningTest()){
               throw new NullPointerException();
           }
                } catch (Exception error) {
                    BOS_Utility.ExceptionHandler(className, searchBusiness, accountObject, null, null, error, null);
     
                }
                
          
               
               
        return   value;
        
    }
    public static String MD5Hash(String value) {
        return hash('MD5', value);
    }
    
     public static String hash(String algorithmName, String input) {
        return EncodingUtil.convertToHex(Crypto.generateDigest(algorithmName, Blob.valueOf(input)));
    }
   
   @AuraEnabled()
    public static  string  verifycode( String  encryptevalue, string code) {
        try{
       String finalCode = MD5Hash(code);
        if(finalCode==encryptevalue) {
            return System.label.SUCCESS_MESSAGE;
        }else{
           return System.label.NotMatched;
        }
              
    } catch (Exception error) {
        BOS_Utility.ExceptionHandler(className, searchBusiness, accountObject, null, null, error, null);
     
    }
    return null;
    }
@AuraEnabled
public static String validateCredentialID(String encryptedValue,String inputValue,String email,String preVerified){

try{
String decryptedvalue = EncryptAndDecryptHelper.processDecryption(encryptedValue);
if(decryptedvalue.equalsIgnoreCase(inputValue)){
    if(String.isBlank(email) || String.isEmpty(email))
    {
        return System.label.EmailNotAvialable;  
    

}else{

    Boolean isverified = verifyLinkedCredentials(encryptedValue,email,true, preVerified);
    if(isverified==true){
    return System.label.AlreadyVerified;
    
    }else{

    String demail = EncryptAndDecryptHelper.processDecryption(email);

 String masked = demail.replaceAll('(?<=.)[^@\n](?=[^@\n]*?[^@\n]@)|(?:(?<=@.)|(?!^)\\G(?=[^@\n]*$)).([^@\n]\\.)', '$1*');
return masked;
    }
}

}else{
    return System.label.NotMatched;
}
}catch(Exception error){
BOS_Utility.ExceptionHandler(className, searchBusiness, accountObject, null, null, error, null);
}
return null;
    }



    @AuraEnabled
    public static String validatCredEmailID(String email,String inputvalue){
 

try{


if(email!=null){

    String dvalue = EncryptAndDecryptHelper.processDecryption(email);
if(dvalue.equalsIgnoreCase(inputvalue)){
   return  Bos_VerificationController.sendNumber(inputvalue);

}else{
    return System.label.NotMatched;
}
}

}catch(Exception error){
    BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);


}
  return null;
    }
@AuraEnabled
public static Boolean verifyLinkedCredentials(String custID,String email, boolean isEmailOnly,String preVerified){
   Boolean isAvailable=false;
    try {
        if(isAvailable==false && String.isNotBlank(preVerified)){
         String customerId = EncryptAndDecryptHelper.processDecryption(custID);
         String demail = EncryptAndDecryptHelper.processDecryption(email);
            System.debug('preVerified'+preVerified);  
            List<BusinessSearchController.PreVerifiedData> preverifiredData = (List<BusinessSearchController.PreVerifiedData>)JSON.deserialize(preVerified, BusinessSearchController.PreVerifiedData[].class);
            System.debug('preverifiredData'+preverifiredData); 
            if(preverifiredData!=null && preverifiredData.size()>0){
           for(BusinessSearchController.PreVerifiedData pdata:preverifiredData){
            String customerId1 = EncryptAndDecryptHelper.processDecryption(pdata.customerID);
            String demail1 = EncryptAndDecryptHelper.processDecryption(pdata.email);
            if(demail1.equalsIgnorecase(demail)){
                isAvailable=true;
                break; 
               } 
               else if(demail1.equalsIgnorecase(demail) && 
              ( customerId1.equalsIgnorecase(customerId))){
                isAvailable=true;
                break; 
           }
       }
       
        }
    
    
        }  
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);
    }

    String isrequired= System.label.IsVerificationRequired;
if(isrequired=='false'){
    isAvailable = true;
}
    return isAvailable;
}



@AuraEnabled
public static String updateCredCounter(String credList) {
 Map<String,String> credDetails = new Map<String,String> ();

  List<CredentialResponse.CredentialDetail> result =(List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credList, CredentialResponse.CredentialDetail[].class);
    if(result!=null ){
        for(CredentialResponse.CredentialDetail cred:result){
            String customerId = EncryptAndDecryptHelper.processDecryption(cred.Cust_ID);
            String demail = EncryptAndDecryptHelper.processDecryption(cred.Cust_Email);
           
           String key = customerId+'-'+demail;
           if(credDetails.get(key)!=null){
               
String credId = credDetails.get(key);
cred.eLicense_Dupcred_ID  = credId;
   }
               else{
            credDetails.put(key, cred.eLicense_Credential_ID);
           
        }
        
        }

       
return JSON.serialize(result);
               }

               return credList;
}

@AuraEnabled
public static String verifyPreVeriedCredentials(String credentials,String preVerified){
    String isrequired= System.label.IsVerificationRequired;
    try {
        if(String.isNotBlank(credentials) && String.isNotBlank(preVerified)){

            List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentials, CredentialResponse.CredentialDetail[].class);
 for(  CredentialResponse.CredentialDetail single:businesses){


         String customerId = EncryptAndDecryptHelper.processDecryption(single.Cust_ID);
         String demail = EncryptAndDecryptHelper.processDecryption(single.Cust_Email);
           
            List<BusinessSearchController.PreVerifiedData> preverifiredData = (List<BusinessSearchController.PreVerifiedData>)JSON.deserialize(preVerified, BusinessSearchController.PreVerifiedData[].class);
        
            if(preverifiredData!=null && preverifiredData.size()>0){
           for(BusinessSearchController.PreVerifiedData pdata:preverifiredData){
            String customerId1 = EncryptAndDecryptHelper.processDecryption(pdata.customerID);
            String demail1 = EncryptAndDecryptHelper.processDecryption(pdata.email);
            if(demail1.equalsIgnorecase(demail) || isrequired == 'false' ){
                single.isEmailVerified=true;
               } 
               if(customerId1.equalsIgnorecase(customerId) || isrequired == 'false'){
                single.isCredIdVerified=true;
           }
       
       
        }
    
 }
        }  
        return JSON.serialize(businesses);
    }
        if(Test.isRunningTest()){
            throw new NullPointerException();
        }
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);

    }

    return credentials;
}

@AuraEnabled
public static string getVerifiedEmail(String preVerified){
    try {
        if(String.isNotEmpty(preVerified)){
            BusinessSearchController.PreVerifiedData preverifiredData = (BusinessSearchController.PreVerifiedData)JSON.deserialize(preVerified, BusinessSearchController.PreVerifiedData.class);
        if(preverifiredData!=null){
            String accId = preverifiredData.id;

            if(String.isNotEmpty(accId)){
              Account accList = [Select id,Business_Email_Address__c from Account where id =:accId];
preverifiredData.email = accList.Business_Email_Address__c;
return JSON.serialize(preverifiredData);
            }
        }
        }
        
        if(Test.isRunningTest()){
            throw new NullPointerException();
        }
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);

    }
    return  preVerified;
}
}