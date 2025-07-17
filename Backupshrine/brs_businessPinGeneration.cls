/* DESCRIPTION: This class is used to generate Pin for name reservation and update them.
*
* @AUTHOR:  Dheeraj 
* @DATE:    03/05/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Dheeraj                    03/05/2021                  Created the first version
*********************************************************************************************/
public without sharing class brs_businessPinGeneration {    
    public static Final String className='brs_businessPinGeneration';

    @InvocableMethod(label='Update Account Pin' description='Generates pins and updates accounts')
    public static void updateAccountPin(List<String> AccountIds) {
        try{           
            List<Account> AccList=new List<Account>();            
            for(Account newAcc:[Select Id,Name,Pin__c from Account where Pin__c=NULL and ID IN:AccountIds WITH SECURITY_ENFORCED]){
                String generatedPin = generateReservationPin(newAcc.Id,6);                
                newAcc.Pin__c=generatedPin;
                AccList.add(newAcc);              
            }
            if (!AccList.IsEmpty() && BRS_SecurityUtility.checkDMLAccess(AccList, 'update')){
                update AccList; 
            } 
        } catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateAccountPin', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }      
    }
    public static String generateReservationPin(String RecordId,Integer length) {
        try{       
            String hexDigest;     
            do{
            String hashString = RecordId+ String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            hexDigest = EncodingUtil.convertToHex(hash).subString(0,length).toUpperCase();
            }while(hexDigest.isAlpha() || hexDigest.isNumeric());
            return hexDigest;       
        }        
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'generateReservationPin', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}