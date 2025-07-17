public class  EncryptAndDecryptHelper { 

    public static Blob cryptoKey; 

    public static Map<String,String> encryptKey = new Map<String,String>(); 
static final String keyValue=System.label.EncryptionKey;
    public static string expMsg; 

    
    public static string processEncryption(string name){ 

        cryptoKey = Blob.valueOf(keyValue); 
   Blob data = Blob.valueOf(name); 

        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 

        string b64Data = EncodingUtil.base64Encode(encryptedData);  

        return b64Data; 

    } 

    public static String processDecryption(string encryptedData){ 

        String decryptedData; 

        Blob data;
        if(encryptedData != Null){
        	data = EncodingUtil.base64Decode(encryptedData);
        } 
 cryptoKey = Blob.valueOf(keyValue); 
       // Blob privateKey = EncodingUtil.base64Decode(key);  

        try{ 

        Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', cryptoKey, data); 

        decryptedData = dataToDecrypt.toString(); 

        } 

        catch(Exception e){ 

           expMsg = e.getMessage();  

        } 

        return (string.isEmpty(expMsg) ?  decryptedData :  null);  

    } 


}