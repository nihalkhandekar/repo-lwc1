@isTest
public with sharing class EncryptAndDecryptHelper_Test {
   @isTest
    public static void testEncryptionDecryption(){
        String value = 'Hello World';
        String encrupteValue = EncryptAndDecryptHelper.processEncryption(value);
        String DecryptedValue = EncryptAndDecryptHelper.processDecryption(encrupteValue);
        System.assertEquals(value, DecryptedValue);
        try{
           EncryptAndDecryptHelper.processDecryption(null);
        }catch(Exception e ){
            system.assertNotEquals(null, e);
        }
    }
}