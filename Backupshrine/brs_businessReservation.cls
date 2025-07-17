/* DESCRIPTION: This class is used to fetch the reserved names associated with a user.
*
* @AUTHOR:  Priyanka Sharma
* @DATE:    10/27/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka Sharma                   10/27/2020                   Created the first version
*********************************************************************************************/
global without sharing class brs_businessReservation {
    public static Final String className='brs_businessReservation';
    @AuraEnabled
    public String label {get;set;}
    @AuraEnabled
    public String name{get;set;}
    @AuraEnabled
    public String id{get;set;}
    @AuraEnabled
    public String shortValue{get;set;}
    @AuraEnabled
    public String question{get;set;}
    @AuraEnabled
    public String businessId{get;set;}
   
    @AuraEnabled(cacheable=true)
    public static List<brs_businessReservation> getReservedNames() {
        try{           
            List<brs_businessReservation> brsReservList = new List<brs_businessReservation>();          
                for(Account acc : [Select id, Name from Account where Has_Business_Name_Reservation_No__c=true and Reserved_Name_Used__c=false and Status__c =: system.label.brs_BusinessReservationStatus and Reservation_Expiration_Date__c >=: system.now()  and Reserved_User__c=: UserInfo.getUserId() WITH SECURITY_ENFORCED] ){
                    brs_businessReservation brsReserv = new brs_businessReservation();
                    brsReserv.label = acc.Name;
                    brsReserv.name = acc.Id;
                    brsReserv.shortValue = acc.Name;
                    brsReservList.add(brsReserv);
                }
            
            return brsReservList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getReservedNamesInv', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean setReservedAccountDetails(String reservedAccName) {
        try{
            Account selectedAccount;
            if(!String.isBlank(reservedAccName)){
            selectedAccount = [Select Id, Name, Account_Name_Without_Designators__c, Reserved_Name_Used__c from Account where Has_Business_Name_Reservation_No__c=true and Reserved_Name_Used__c=false and Status__c =: System.label.brs_BusinessReservationStatus and Reservation_Expiration_Date__c >=: system.now() and name =: reservedAccName WITH SECURITY_ENFORCED LIMIT 1];
             }
            Boolean isUpdated = false;
            if(selectedAccount != null){
                selectedAccount.Reserved_Name_Used__c = true;
                selectedAccount.Account_Name_Without_Designators__c = QnA_Constants.EMPTY_STRING;                
                isUpdated = true;
            }
            else{
                isUpdated = false;
            }
            //added empty check 
            if(isUpdated && selectedAccount!=null){
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{selectedAccount}, 'update');
				if(bAccessCheck){
                    update selectedAccount;
                }
                return true;
            }
            else{
                return false;
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'setReservedAccountDetails', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @InvocableMethod(label='getReservedNamesInv' description='test getReservedNames')
    public static List<Results> getReservedNamesInv() {
        try{
            List<Results> lstResults = new List<Results>();
            List<brs_businessReservation> brsReservList = new List<brs_businessReservation>();

                for(Account acc : [Select id, Name from Account where Has_Business_Name_Reservation_No__c=true and Reserved_Name_Used__c=false and Status__c =: System.label.brs_BusinessReservationStatus and Reservation_Expiration_Date__c >=: system.now() and Reserved_User__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED] ){
                    brs_businessReservation brsReserv = new brs_businessReservation();
                    brsReserv.label = acc.Name;
                    brsReserv.name = acc.Id;
                    brsReserv.shortValue = acc.Name;
                    brsReservList.add(brsReserv);
                }
                if(!brsReservList.isEmpty()){
                Results r = new Results();
                r.records = Json.serialize(brsReservList);
                lstResults.add(r);
                }
                return lstResults;
                 
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getReservedNamesInv', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    global without sharing class Requests {
        @InvocableVariable
        global string accId;
    }    
    global without sharing class Results {
        @InvocableVariable
        global string records;
    }
    
    @AuraEnabled
    public static List<brs_businessReservation> getBusinessNameUsingPIN(String pinNum) {
        try{
            List<Account> reservedNamesList=new List<Account>();           
            List<brs_businessReservation> brsReservList = new List<brs_businessReservation>();
             if(!String.isBlank(pinNum)){
                for(Account acc : [Select id, Name,Pin__c,Reservation_Expiration_Date__c from Account where Has_Business_Name_Reservation_No__c=true and Reserved_Name_Used__c=false and Status__c =: System.label.brs_BusinessReservationStatus and Reservation_Expiration_Date__c >=: system.now() and Pin__c =: String.escapeSingleQuotes(pinNum) WITH SECURITY_ENFORCED Limit 1] ){
                    brs_businessReservation brsReserv = new brs_businessReservation();
                    brsReserv.label = acc.Name;
                    brsReserv.name = acc.Id;
                    brsReserv.id = acc.Id;
                    brsReserv.shortValue = acc.Name;
                    brsReserv.businessId = System.label.brs_BusinessNamePin + ' ' +acc.Pin__c;
                    brsReservList.add(brsReserv);
                }
             }
            return brsReservList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getReservedNamesInv', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}