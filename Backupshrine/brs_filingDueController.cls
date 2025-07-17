/********************************************************************************************
* DESCRIPTION: Class to get filing information
*
* @AUTHOR:  Pooja Dubey
* @DATE:    01/20/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita Nayak                   01/20/2020                  Created the first version
*********************************************************************************************/
public with sharing class brs_filingDueController {
    public static final string CLASSNAME = 'brs_filingDueController';
    
    @AuraEnabled
    public static string getFilingStatus(string filingId)
    {
        List<Business_Filing__c> buslist;
        String BusinessFilingStatus;
        if(filingId !=null)
        {
            buslist=[select id,Status__c from Business_Filing__c where id=:filingId];
        }
        if(!buslist.isEmpty())
        {
            BusinessFilingStatus=buslist[0].Status__c;
        }
        return BusinessFilingStatus;
    }

    @AuraEnabled
    public static Business getBusinessWithFiling(String accountId, string filingId, String reportType) {
        try{
            Map<String,String>  labelMaps = new Map<String,String>();
            labelMaps = getTranslatedMap();
            set<String> maintenanceTypes = new set<String>{system.label.brs_maintenance_interim, 
                                                            system.label.brs_maintenance_agent,
                                                            system.label.BRS_NAICS_Maintenance,
                                                            system.label.brs_maintenance_Address,
                                                            system.label.brs_maintenance_Email,
                                                            system.label.brs_maintenance_address_agent,
                                                            system.label.brs_ObtainCertFlow,
                                                            system.label.Payment_Withdrawal_LLC,
                                                            system.label.brs_AgentResignation
                                                            };
            Account account = BRS_Utility.getAccount(accountId);
            Business business = new Business();
            business.name = account.Name;
            business.businessId = account.AccountNumber;
            business.status = account.Status__c != null? (labelMaps.containsKey(account.Status__c)? labelMaps.get(account.Status__c) : account.Status__c) : null;    //account.Status__c;
            Business_Filing__c businessFiling = new Business_Filing__c();
            if(filingId!=null){
                businessFiling = [select Id, Filing_Fee__c,Total_Fee__c,Due_Date__c from Business_Filing__c where Id=:filingId WITH SECURITY_ENFORCED];
            }        
            if(businessFiling.Filing_Fee__c!=null){
                business.filingFee = businessFiling.Filing_Fee__c;
            }
            if((account.Citizenship__c != null || account.Business_Type__c != null) && (filingId!=null || maintenanceTypes.contains(reportType))){

                if(reportType!=null){
                    if(!maintenanceTypes.contains(reportType))
                    {
                        List<Business_Filing__c> businessFilingList = BRS_Utility.getBusinessFiling(accountId,reportType,filingId);
                        business.filingYear = businessFilingList.isEmpty() ? null : businessFilingList[0].Due_Date__c != null ? businessFilingList[0].Due_Date__c.year(): null;
                        business.dueDate = businessFilingList.isEmpty() ? null : businessFilingList[0].Due_Date__c != null ? businessFilingList[0].Due_Date__c.format(): null;
                    }
                }
            }
            return business;
        }catch (exception exe) {
            BOS_Utility.ExceptionHandler(CLASSNAME,'getBusinessWithFiling','',null,BOS_Utility.sSeverity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
        
        
    }
    
    public static Map<String,String> getTranslatedMap(){
        Map<String,String>  labelMaps = new Map<String,String>();
        labelMaps.put('Withdrawn', System.label.Withdrawn_Label);
        labelMaps.put('Forfieted', System.label.Forfeited_Label);
        labelMaps.put('Dissolved',System.label.Dissolved_Label);
        labelMaps.put('Revoked',System.label.Revoked_Label1);
        labelMaps.put('Active',System.label.Active_Label);
        labelMaps.put('Cancelled',System.label.Cancelled_Label);
        labelMaps.put('Merged',System.label.Merged_Label);
        labelMaps.put('Recorded', System.label.RECORDED_Label);
        
        return labelMaps;   
    }

    @AuraEnabled
    public static List<filingDueWrapper> getFilingDueDetails(String accountId,String reportType) {
        try {
            List<Business_Filing__c> businessFilingList = new List<Business_Filing__c>();
            Map<string, Decimal> filingFeeMap = new Map<string, Decimal>();
            List<filingDueWrapper> wrapListforFilingDue = new List<filingDueWrapper>();
            Account account = BRS_Utility.getAccount(accountId);
            if(account.Citizenship__c != null || account.Business_Type__c != null){
                filingFeeMap = BRS_Utility.getFilingFee(account.Citizenship__c,account.Business_Type__c,reportType);
            }
            if(AccountId != null && reportType != null){
               businessFilingList = BRS_Utility.getBusinessFiling(accountId,reportType,null);
            }
            
            /** **/
            for(Business_Filing__c busFileInst : businessFilingList){
                FilingDueWrapper wrapInst = new FilingDueWrapper();
                wrapInst.Id = busFileInst.Id;
                wrapInst.Name = busFileInst.Due_Date__c.year();
                wrapInst.ActionItemName = '';
                wrapInst.dueDate = busFileInst.Due_Date__c;
                wrapInst.Status = busFileInst.Status__c;
                wrapInst.AccountId = AccountId;
                if(busFileInst.Due_Date__c < system.today()){
                    wrapInst.isPastDue = true;
                    wrapInst.isUpcoming = false;
                    wrapInst.description = system.label.Past_Due;
                }else{
                    wrapInst.isUpcoming = true;
                    wrapInst.isPastDue = false;
                }
                if(busFileInst.Id == businessFilingList[0].Id){
                    wrapInst.isToDo = true;
                    wrapInst.description = wrapInst.isPastDue ? system.label.Past_Due_and_Selected_for_Filing : 'Selected for filing';
                }
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-6730
                * Change(s)/Modification(s) Description : Since the filing fee mdt does not have LP so adding condition to filing fee data from business filing field for LP type businesses
                * Change(s)/Modification(s) Made on : 10-08-2021
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if(filingFeeMap.containsKey(account.Business_Type__c) || account.Business_Type__c == System.Label.Limited_Partnership){
                    if(filingFeeMap.containsKey(account.Business_Type__c)){
                        wrapInst.amountNumber = filingFeeMap.get(account.Business_Type__c);
                    }
                    // Added filing fee from business filing.
                    wrapInst.amount = '$'+busFileInst.Filing_Fee__c;
                }
                
                wrapListforFilingDue.add(wrapInst);
            }

            return wrapListforFilingDue;
        } catch (exception exe) {
            BOS_Utility.ExceptionHandler(CLASSNAME,'getFilingDueDetails','',null,BOS_Utility.sSeverity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    public class FilingDueWrapper{
        @AuraEnabled public string Id;
        @AuraEnabled public Integer Name;
        @AuraEnabled public string ActionItemName;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public string Status;
        @AuraEnabled public string AccountId;
        @AuraEnabled public boolean isUpcoming = false;
        @AuraEnabled public boolean isToDo = false;
        @AuraEnabled public boolean isPastDue = false;
        @AuraEnabled public Decimal amountNumber = 0;
        @AuraEnabled public String amount;
        @AuraEnabled public String description;
    }  
    
    public class Business{
        @AuraEnabled public string businessId;
        @AuraEnabled public string name;
        @AuraEnabled public Decimal filingYear;
        @AuraEnabled public Decimal filingFee;
        @AuraEnabled public string status;
        @AuraEnabled public string dueDate;
    }
}