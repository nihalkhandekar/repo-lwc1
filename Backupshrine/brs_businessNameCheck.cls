/* DESCRIPTION: This class is used to check if the Business Name is available or not.
*
* @AUTHOR: 	Aparna Shahapurkar
* @DATE: 	01/09/2021 
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* -----------------------------------------------------------------------------------------------------------------------------------
* Aparna Shahapurkar               01/09/2021                   Created the first version
  Aparna Shahapurkar               01/26/2021                   Check business name across Account, Business Filing and Temp History
*************************************************************************************************************************************/

global without sharing class brs_businessNameCheck {
    public static Final String className='brs_businessNameCheck';

    @AuraEnabled
    public static Boolean checkDuplicateAccName(String businessName, Id accId){
        Boolean isNameAvailable = checkDuplicateAccNameReview(businessName, accId, false);
        return isNameAvailable;
    }

	@AuraEnabled
    public static Boolean checkDuplicateAccNameReview(String businessName, Id accId, Boolean isFromReview){
        try{
            if(isFromReview == null){
                isFromReview = false;
            }
            Boolean isNameAvailable = true;
            Account acct;
            List<Account> acctList = new List<Account>();
            Set<String> accountNameSetWithDesgntrs = new Set<String>();
            List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
            List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
            Integer count = 1;
            Boolean duplicatesFound = false;
            if(accId!=null && businessName !=null){
                acct = [Select Id, name, Account_Name_Without_Designators__c, Reserved_Name_Used__c from Account where Id= :accId and Reserved_Name_Used__c = false WITH SECURITY_ENFORCED];    
            }
            else if(businessName != null){
                acct=new Account(Name=businessName, Account_Name_Without_Designators__c=businessName);
            }
			
			if(acct != null){				
                String tempAccount_Name_Without_Designators = ' ' + businessName.normalizeSpace() + ' ';
                for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                    if((tempAccount_Name_Without_Designators != '' || tempAccount_Name_Without_Designators != null) && noiseWrd.Label!='.' && ((tempAccount_Name_Without_Designators).containsIgnoreCase(noiseWrd.Label))){                           
                        // Added if condition for 'The' and 'AND'
                        if(!(noiseWrd.Label).isAlpha()){
                            tempAccount_Name_Without_Designators = ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                        else{
                            tempAccount_Name_Without_Designators = ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                    }                    
                 }
                 for(brs_SortLegalDesignators desgn : listOfDesignators) {               
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                }   
                tempAccount_Name_Without_Designators = Accents.removeDiacritics(tempAccount_Name_Without_Designators);    
                tempAccount_Name_Without_Designators = ((tempAccount_Name_Without_Designators).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
                acct.Account_Name_Without_Designators__c = tempAccount_Name_Without_Designators;
                
                for(Account existingAccount : [Select Id, Name, Account_Name_Without_Designators__c from Account where (Status__c =: System.label.ACTIVE OR Status__c =: System.label.brs_BusinessReservationStatus) AND (Business_Sub_Type__c !=: System.label.brs_GeneralPartnership AND Business_Type__c !=: System.label.brs_GeneralPartnership) AND Reserved_Name_Used__c = false AND Account_Name_Without_Designators__c = :acct.Account_Name_Without_Designators__c WITH SECURITY_ENFORCED])
                {
                    acctList.add(existingAccount);                    
                }

                if(!acctList.isEmpty()){
                    duplicatesFound = true;
                    isNameAvailable = false;
                    if(!Test.isRunningTest())
                    {
                        return isNameAvailable;
                    }
                    
                }
				
                
                    for(Temp_History__c tempRecords : [Select Id, BusinessName_New_Without_Designators__c, Business_Filing__c, Business_Filing__r.Type__c, Business_Filing__r.Status__c, Business_Filing__r.Account__c, Business_Filing__r.Account__r.Name, Business_Filing__r.Account__r.Account_Name_Without_Designators__c, Business_Name_New__c from Temp_History__c where (Business_Filing__r.type__c =: System.label.Name_Change_Amendment OR Business_Filing__r.type__c =: System.label.Business_Formation_Label OR Business_Filing__r.type__c =: System.label.Business_Registration_Label) AND (Business_Filing__r.Status__c =: System.label.BRS_Submitted_Agent_acceptance_pending OR Business_Filing__r.Status__c =: System.label.Submitted_Agency_review_pending OR Business_Filing__r.Status__c =: System.label.Label_Pending_Filing_1) AND BusinessName_New_Without_Designators__c = :acct.Account_Name_Without_Designators__c WITH SECURITY_ENFORCED]){
                        if(tempRecords.Business_Filing__r.type__c == System.label.Name_Change_Amendment){
                            if(tempRecords.BusinessName_New_Without_Designators__c != null){
                                accountNameSetWithDesgntrs.add(tempRecords.BusinessName_New_Without_Designators__c);
                            }
                        }
                    }
                


                    for(Business_Filing__c filinRec : [Select Id, Type__c, Status__c, Account__c, Account__r.Name, Account__r.Account_Name_Without_Designators__c from Business_Filing__c where (type__c =: System.label.Name_Change_Amendment OR type__c =: System.label.Business_Formation_Label OR type__c =: System.label.Business_Registration_Label) AND (Status__c =: System.label.BRS_Submitted_Agent_acceptance_pending OR Status__c =: System.label.Submitted_Agency_review_pending OR Status__c =: System.label.Label_Pending_Filing_1) AND Account__r.Account_Name_Without_Designators__c = :acct.Account_Name_Without_Designators__c WITH SECURITY_ENFORCED]){
                        if(filinRec.type__c == System.label.Business_Formation_Label || filinRec.type__c == System.label.Business_Registration_Label){
                            if(filinRec.Account__r.Account_Name_Without_Designators__c != null){
                                accountNameSetWithDesgntrs.add(filinRec.Account__r.Account_Name_Without_Designators__c);
                            }
                        }
                    }
                

                if (!accountNameSetWithDesgntrs.isEmpty()){
                    duplicatesFound = true;
                    isNameAvailable = false;
                    if(!Test.isRunningTest())
                    {
                        return isNameAvailable;
                    }
                }

                if(!isFromReview){                
                    for(Account reservedAcc: [Select Name, Account_Name_Without_Designators__c from Account where Status__c = 'Reserved' AND Reserved_Name_Used__c = false AND AccNameWithoutDesignatorsIsNull__c = true AND Reserved_User__c != :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 50000]){
                       String tempReservedAccName = ' ' + (reservedAcc.Name).normalizeSpace() + ' ';
                        for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                            if((tempReservedAccName != '' || tempReservedAccName != null) && noiseWrd.Label!='.' && ((tempReservedAccName).containsIgnoreCase(noiseWrd.Label))){                           
                                // Added if condition for 'The' and 'AND'
                                if(!(noiseWrd.Label).isAlpha()){
                                    tempReservedAccName = ' ' + (((tempReservedAccName).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                                }
                                else{
                                    tempReservedAccName = ' ' + (((tempReservedAccName).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                                }
                            }                    
                        }
                        for(brs_SortLegalDesignators desgn : listOfDesignators) {               
                            if((' '+tempReservedAccName+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                                tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                            if((' '+tempReservedAccName+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                                tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                            if((' '+tempReservedAccName+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                                tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                        }
                        tempReservedAccName = ((tempReservedAccName).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();

                        if(tempAccount_Name_Without_Designators.equalsIgnoreCase(tempReservedAccName)){
                            isNameAvailable = false;
                            return isNameAvailable;
                        }
                    }
                }
                isNameAvailable = true;
            }
            
            //Ends
            return isNameAvailable;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'checkDuplicateAccName', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //BRS-3920: Check if business name contains "BANK;CREDIT UNION;INSURANCE;CEMETERY;COOPERATIVE"
    @InvocableMethod
    public static List<Results> checkBusNameContainsKeywords(List<Requests> Requests){
        List<Results> resultLst = new List<Results>();
        try{
            if(Requests[0].businessName != null){
                List<String> keywordsLst = (System.label.brs_BusinessApprovalLogicKeywords).split(';');
                for(String word : keywordsLst) {
                    if((Requests[0].businessName).containsIgnoreCase(word)){                           
                        Results r = new Results();
                        r.containsKeyword = true;
                        resultLst.add(r);
                        break;
                    }        
                }
            }
            return resultLst;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'checkBusNameContainsKeywords', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    global without sharing class Requests {
        @InvocableVariable
        global string businessName;
    }

    global without sharing class Results {
        @InvocableVariable
        global Boolean containsKeyword;
    }
}