@isTest
public with sharing class Bos_VerificationController_Test {
   
    @testSetup
    private static void setup() {
        Map<Account, List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
     }
    
    @isTest
    public static void testverification(){
        String code= Bos_VerificationController.sendNumber('test@test.com');
        
        System.assert(code!=null);
        Bos_VerificationController.verifycode(code, code);
        Bos_VerificationController.verifycode(null, null);
    }
      private static BusinessSearchController.PreVerifiedData getPreVerifiedData() {
        BusinessSearchController.PreVerifiedData data = new BusinessSearchController.PreVerifiedData();
        data.customerID = '123';
        data.email = 'random@random.com';
        
        return data;
    }
    @isTest
    public static void testvalidateCredentialID(){
        Test.startTest();
        String encrypteddata = EncryptAndDecryptHelper.processEncryption('abcd');
        Bos_VerificationController.validateCredentialID(encrypteddata,'xyz','abc(?@gmail.com','');
        Bos_VerificationController.validateCredentialID(encrypteddata,'abcd','','');
        Bos_VerificationController.validateCredentialID(encrypteddata,'abcd','abc/@gmail.com','');
        String validation = Bos_VerificationController.validatCredEmailID(encrypteddata,'abcd');
        Test.stopTest();
        system.assertNotEquals('abcd', validation);
    }
    @isTest
    public static void testverifyLinkedCredentials(){
        String encrypteddata = EncryptAndDecryptHelper.processEncryption('abcd');
        String demail = EncryptAndDecryptHelper.processDecryption('encrypteddata');

        try{
            String credlist = '[{"value": null,"MainAddress": "99 QUARRY RD BRANFORD, CT 06405-3344","MailingAddress": "11 BUSINESS PARK DR BRANFORD, CT  06405-2958","linkValueNotSelected": null,"isEmailVerified": null,"isCredIdVerified": null,"isContactCred": null,"Full_Credential_Code": "DEV.0010476","Expiration_Date": "07/31/2021","eLicense_SOTS_ID": null,"ActionItems": []}]';
            Test.startTest();
            Bos_VerificationController.verifyLinkedCredentials(encrypteddata,encrypteddata,true,credlist);
            Test.stopTest();
        }Catch(Exception e){
            system.assertNotEquals(null, e);
        }
    }
    @isTest
    private static void testupdateCredCounter(){
        String credlist = '[{"value": null,"MainAddress": "99 QUARRY RD BRANFORD, CT 06405-3344","MailingAddress": "11 BUSINESS PARK DR BRANFORD, CT  06405-2958","linkValueNotSelected": null,"isEmailVerified": null,"isCredIdVerified": null,"isContactCred": null,"Full_Credential_Code": "DEV.0010476","Expiration_Date": "07/31/2021","eLicense_SOTS_ID": null,"ActionItems": []}]';
        Test.startTest();
        Bos_VerificationController.updateCredCounter(credlist);
        Test.stopTest();
    }
      @isTest
    private static void testverifyPreVeriedCredentials(){
        String credlist =  '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"220617","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
        Test.startTest();
        List<BusinessSearchController.PreVerifiedData> pdata=new List<BusinessSearchController.PreVerifiedData>{getPreVerifiedData()};
        Bos_VerificationController.verifyPreVeriedCredentials(credlist,JSON.serialize(pdata));
        
        try{
            Bos_VerificationController.verifyPreVeriedCredentials(null,null);
        
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
     @isTest
    private static void testgetVerifiedEmail(){
       Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        Test.startTest();
        BusinessSearchController.PreVerifiedData pdata=getPreVerifiedData();
        pdata.id= acc.id;
        Bos_VerificationController.getVerifiedEmail(JSON.serialize(pdata));
        try{
        Bos_VerificationController.getVerifiedEmail(null);
        }catch(Exception e){}
        Test.stopTest();
    }
}