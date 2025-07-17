/********************************************************************************************/
/* NAME         :  AdminDissolutionUpdates
* DESCRIPTION   :  One time account update for admin dissolution addresses
* @AUTHOR       :  Sonika Gautam
********************************************************************************************/
/* MODIFICATION LOG:
   DEVELOPER                         DATE                       DESCRIPTION
 _____________________________________________________________________________________________
 Sonika                             6/1/2022                    BRS-7805 |  Copy relevant address as admin dissolution address
***********************************************************************************************/
public with sharing class AdminDissolutionUpdates implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(
            'SELECT BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,'
                + 'ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,'
                + 'Admin_Dissolution_Address__c,Admin_Dissolution_City__c,Admin_Dissolution_State__c,Admin_Dissolution_Zip_Code__c,Admin_Dissolution_Country__c,'
                + '('
                    + 'SELECT Business_ID__c,'
                        + 'Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,'
                        + 'Residence_City__c,Residence_State__c,Residence_Country__c,Residence_Zip_Code__c,'
                        + 'Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,'
                        + 'Mailing_City__c, Mailing_State__c,Mailing_Country__c,Mailing_Zip_Code__c,'
                        + 'Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,'
                        + 'Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c'
                    + ' FROM Agents__r'
                +')'
            + ' FROM Account'
            + ' WHERE Sub_status__c IN (\'Ready for Dissolution\', \'Admin Dissolution Initiated\', \'Ready for Forfeiture\', \'Ready for Revocation\')'
                + ' AND Admin_Dissolution_Address__c = null'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listRecords) {
        processAccountRecords((List<Account>) listRecords);
    }
    
    public void finish(Database.BatchableContext oBC) {     
    }

    //priority: Billing, Shipping, Agent.Residence, Agent.Mailing, Agent.Business
    @TestVisible
    private void processAccountRecords(List<Account> listAccounts) {
        List<Account> listAddressAccounts = new List<Account>();

        //Set dissolution address
        for(Account account :listAccounts) {
            //1. Billing Address
            if(account.BillingStreet != null 
                && account.BillingCity != null 
                && account.BillingState != null 
                && account.BillingPostalCode != null
            ) {
                account.Admin_Dissolution_Address__c = account.BillingStreet;
                account.Admin_Dissolution_City__c = account.BillingCity;
                account.Admin_Dissolution_State__c = account.BillingState;
                account.Admin_Dissolution_Zip_Code__c = account.BillingPostalCode;
                account.Admin_Dissolution_Country__c = account.BillingCountry;

                listAddressAccounts.add(account);
            }

            //2. Shipping Address
            else if(account.ShippingStreet != null 
                && account.ShippingCity != null 
                && account.ShippingState != null 
                && account.ShippingPostalCode != null
            ) {
                account.Admin_Dissolution_Address__c = account.ShippingStreet;
                account.Admin_Dissolution_City__c = account.ShippingCity;
                account.Admin_Dissolution_State__c = account.ShippingState;
                account.Admin_Dissolution_Zip_Code__c = account.ShippingPostalCode;
                account.Admin_Dissolution_Country__c = account.ShippingCountry;
                
                listAddressAccounts.add(account);
            }

            //3. if no account address, search agent
            else if(account.Agents__r != null && !account.Agents__r.isEmpty()) {
                Agent__c agent = account.Agents__r.get(0);

                //3.1. Residence
                if(agent.Residence_Street_Address_1__c != null 
                    && agent.Residence_City__c != null 
                    && agent.Residence_State__c != null 
                    && agent.Residence_Zip_Code__c != null
                ) {
                    account.Admin_Dissolution_Address__c = agent.Residence_Street_Address_1__c 
                        + (agent.Residence_Street_Address_2__c != null ? ', ' + agent.Residence_Street_Address_2__c : '') 
                        + (agent.Residence_Street_Address_3__c != null ? ', ' + agent.Residence_Street_Address_3__c : '');
                    account.Admin_Dissolution_City__c = agent.Residence_City__c;
                    account.Admin_Dissolution_State__c = agent.Residence_State__c;
                    account.Admin_Dissolution_Zip_Code__c = agent.Residence_Zip_Code__c;
                    account.Admin_Dissolution_Country__c = agent.Residence_Country__c;
                    
                    listAddressAccounts.add(account);
                }

                //3.2. Mailing
                else if(agent.Mailing_Street_Address_1__c != null 
                    && agent.Mailing_City__c != null 
                    && agent.Mailing_State__c != null 
                    && agent.Mailing_Zip_Code__c != null
                ) {
                    account.Admin_Dissolution_Address__c = agent.Mailing_Street_Address_1__c 
                        + (agent.Mailing_Street_Address_2__c != null ? ', ' + agent.Mailing_Street_Address_2__c : '') 
                        + (agent.Mailing_Street_Address_3__c != null ? ', ' + agent.Mailing_Street_Address_3__c : '');
                    account.Admin_Dissolution_City__c = agent.Mailing_City__c;
                    account.Admin_Dissolution_State__c = agent.Mailing_State__c;
                    account.Admin_Dissolution_Zip_Code__c = agent.Mailing_Zip_Code__c;
                    account.Admin_Dissolution_Country__c = agent.Mailing_Country__c;
                
                    listAddressAccounts.add(account);
                }

                //3.3. Business
                else if(agent.Business_Street_Address_1__c != null 
                    && agent.Business_City__c != null 
                    && agent.Business_State__c != null 
                    && agent.Business_Zip_Code__c != null
                ) {
                    account.Admin_Dissolution_Address__c = agent.Business_Street_Address_1__c 
                        + (agent.Business_Street_Address_2__c != null ? ', ' + agent.Business_Street_Address_2__c : '') 
                        + (agent.Business_Street_Address_3__c != null ? ', ' + agent.Business_Street_Address_3__c : '');
                    account.Admin_Dissolution_City__c = agent.Business_City__c;
                    account.Admin_Dissolution_State__c = agent.Business_State__c;
                    account.Admin_Dissolution_Zip_Code__c = agent.Business_Zip_Code__c;
                    account.Admin_Dissolution_Country__c = agent.Business_Country__c;
                
                    listAddressAccounts.add(account);
                }
            }
        }

        if(!listAddressAccounts.isEmpty()) {
            update listAddressAccounts;
        }
    }
}