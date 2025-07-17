/* DESCRIPTION: This class contains methods to send email/search liens for online enquiry. 
*
* @AUTHOR:  Sarita/Rahul
* @DATE:    2/1/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita/Rahul                      2/1/2021                           Created the first version
*********************************************************************************************/
global with sharing class brs_genericSearchClass {
    public static Final String className = 'brs_genericSearchClass';
    public static Final List<String> businessStatuses = new List<String>();
    @AuraEnabled
    public static void sendEmailApex(List<String> toAddress,String link,String searchType) {         
        brs_genericSearchBusinessClass.sendSearchURLEmail(toAddress,link,searchType);
    }
    @AuraEnabled
    public static List<BRS_Lien_Search_Dates__c> getUCCDates() {
        return brs_genericSearchBusinessClass.retrieveUCCDates();        
    }
    
    /**
     * @desc: get all dashboard filters for myfilings page
     * @uage: brs_myFilingHistory.js
     */
    @AuraEnabled
    public static List<brs_genericSearchBusinessClass.filterTypeWrapper> getAllFilters(String searchType) {
        return brs_genericSearchBusinessClass.retrieveFilters(searchType);
        
    }

    

    /**
     * @update: BRS-6673 | Update debtor logic
     */
    @AuraEnabled
    public static brs_genericSearchBusinessClass.GenericSearchWrapper getAllRecords(String searchObj) {
        return brs_genericSearchBusinessClass.retrieveAllRecords(searchObj);

    }

  
    @AuraEnabled
    public static brs_genericSearchBusinessClass.genericSearchWrapper getAllLiens(List<String> LienIds) {
        return brs_genericSearchBusinessClass.retrieveAllLiens(LienIds);          
    }
    
    /**
	 * @update: BRS-6673 | BRS-6319
	 * Update the CSV logic to sort based on onlineenquiry
	 * Additional logic to pull in Secured Party
	 */
    @AuraEnabled
    public static List<brs_genericSearchBusinessClass.objWrapper> getInfoForCSV(String searchObj) {
        return brs_genericSearchBusinessClass.retrieveInfoForCSV(searchObj);        
    }

    @AuraEnabled
    public static List<brs_genericSearchBusinessClass.filingRelatedInfoWrap> getUCCRelatedRecords(string FilingNumber) {
        return brs_genericSearchBusinessClass.retrieveUCCRelatedRecord(FilingNumber);        
    }

    @AuraEnabled
    public static String encrypt(string toEncrypt) {
        return brs_genericSearchBusinessClass.encrypt(toEncrypt);        
    }
    @AuraEnabled
    public static String decrypt(string toDecrypt) {
        return brs_genericSearchBusinessClass.decrypt(toDecrypt);        
    }
    @AuraEnabled
    public static brs_genericSearchBusinessClass.InterfaceConfigWrapper fetchInterfaceConfig(String labelName) {
        return brs_genericSearchBusinessClass.fetchInterfaceConfig(labelName);        
    }
    
}