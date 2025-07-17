/*********************************************************************************************
 * NAME:  brs_AccountNoAddressBatch
 * DESCRIPTION: Batch class to update No Address found field of legacy accounts
 *
 * @AUTHOR:Dixita Jain
 * @DATE: 08/26/2021 
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Dixita Jain                    08/26/2021                        Created the first version
 *
*************************************************************************************************/
global with sharing class brs_AccountNoAddressBatch implements Database.Batchable<sObject> {
    public static Final String className = 'brs_AccountNoAddressBatch';
    public static Final String methodName = 'updateAccountBackendName';
    public static Final String objectName = 'Account';
    public String query = '';
    
    global brs_AccountNoAddressBatch()
    {
        query = 'SELECT Id, RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, Mailing_Address_1__c,'
                + 'ShippingPostalCode, Business_Address_1__c, No_address_found__c FROM Account WHERE No_address_found__c = false AND Sub_Status__c =\'' 
                + system.label.Active_Ready_for_Admin_Dissolution + '\' AND Status__c =\'' + System.label.ACTIVE + '\'';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Account> accList) {
        try {
            Map<Id, Account>  accountMap = new Map<Id,Account>();
            List<Account> lstAccountsToUpdate =  new List<Account>();
            /** Get business record type id **/
            Id businessRecordTypeId = Wizard_Utlity.getRecordTypeId(system.label.AccountRecordType_Business,Schema.Account.getSObjectType());
            List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
            
            for (Account oAccount : accList){
                /***
                    If an Account status is changed to Active there must be a validation check 
                    on the Account addresses.
                        First check if there is a Principal Office address on record
                        Second check if there is a mailing address on record
                        Third check if the agent associated with the business Account has an address
                **/
                if(oAccount.RecordTypeId == businessRecordTypeId &&
                    ( (oAccount.BillingStreet == null && oAccount.BillingCity == null && oAccount.BillingCountry == null &&
                        oAccount.BillingState == null && oAccount.BillingPostalCode == null &&
                        oAccount.ShippingStreet == null && oAccount.ShippingCity == null && oAccount.ShippingCountry == null &&
                        oAccount.ShippingState == null && oAccount.ShippingPostalCode == null) ||
                        ((oAccount.Business_Address_1__c != null && (String.valueOf(oAccount.Business_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAccount.Business_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ((oAccount.Mailing_Address_1__c != null && (String.valueOf(oAccount.Mailing_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAccount.Mailing_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) || oAccount.Mailing_Address_1__c == null)) ||
                        ((oAccount.Mailing_Address_1__c != null && (String.valueOf(oAccount.Mailing_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAccount.Mailing_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ((oAccount.Business_Address_1__c != null && (String.valueOf(oAccount.Business_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAccount.Business_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) || oAccount.Business_Address_1__c == null)))){
                    accountMap.put(oAccount.Id,oAccount);
                }
            }
            /** Third check if the oAgent associated with the business oAccount has an address **/
            for(Agent__c oAgent : [SELECT Id, Business_Address__c,Agent_Residence_Address__c,Mailing_Address__c, Business_ID__c
                                    FROM Agent__c 
                                    WHERE Business_ID__c IN: accountMap.keyset() AND Business_ID__c!=null]){
                
                if(accountMap.containsKey(oAgent.Business_ID__c) && ((oAgent.Business_Address__c == null && oAgent.Agent_Residence_Address__c == null && oAgent.Mailing_Address__c == null) ||
                    ((oAgent.Business_Address__c != null && (string.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (oAgent.Agent_Residence_Address__c == null || (oAgent.Agent_Residence_Address__c != null && (string.valueOf(oAgent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (oAgent.Mailing_Address__c == null || ( oAgent.Mailing_Address__c != null && (string.valueOf(oAgent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAgent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))))) ||
                    ((oAgent.Business_Address__c == null || (oAgent.Business_Address__c != null && (string.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (oAgent.Agent_Residence_Address__c != null && (string.valueOf(oAgent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(oAgent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (oAgent.Mailing_Address__c == null || ( oAgent.Mailing_Address__c != null && (string.valueOf(oAgent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase())))) ||
                    ((oAgent.Business_Address__c == null || (oAgent.Business_Address__c != null && (string.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (oAgent.Agent_Residence_Address__c == null || (oAgent.Agent_Residence_Address__c != null && (string.valueOf(oAgent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ( oAgent.Mailing_Address__c != null && (string.valueOf(oAgent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(oAgent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))))) {
                    Account oAccount = accountMap.get(oAgent.Business_ID__c);
                    oAccount.No_address_found__c = true;
                    lstAccountsToUpdate.add(oAccount);
                }
                
                accountMap.remove(oAgent.Business_ID__c);
            }
            /** if no oAgent is associated update Checkbox **/
            for(Account oAccount : accountMap.values()){
                oAccount.No_address_found__c = true;
                lstAccountsToUpdate.add(oAccount);
            }
            if(!lstAccountsToUpdate.IsEmpty())
            {
                Database.SaveResult[] accUpdateSuccessList = Database.update(lstAccountsToUpdate, false);
                for(Integer i=0;i<accUpdateSuccessList.size();i++)
                {
                if(!accUpdateSuccessList.get(i).isSuccess()) 
                {
                        Error_Log__c err = BOS_Utility.errorRecordLogger(className, methodName, objectName, lstAccountsToUpdate.get(i).Id, BOS_Utility.sSeverity, null, system.label.BRSAccountNoAddressBatchError + lstAccountsToUpdate.get(i).Id);
                        errorFilingLst.add(err);
                }
                }
            }
            if(!errorFilingLst.IsEmpty())
            BOS_Utility.insertErrorRecordLst(errorFilingLst);
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, methodName, objectName, null, null, ex, ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}