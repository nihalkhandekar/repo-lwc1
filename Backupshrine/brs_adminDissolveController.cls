/*********************************************************************************************
 * NAME:  brs_adminDissolveController
 * DESCRIPTION: Custom Controller for VF pages to process Administrative Dissolution
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 06/22/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     06/22/2021                        Created the first version
 * Shreya Bordia                    09/06/2021                        BRS-7025 | Apex CPU time out, too many soql issues
*************************************************************************************************/
public with sharing class brs_adminDissolveController{
    private String pageName {get;set;}
    public String strMsg {get;set;}
    private ApexPages.StandardSetController standardController;

    public brs_adminDissolveController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        this.pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        String filterId = (String) standardController.getFilterId();
        
        List<ListView> listViews = [
            SELECT Id, DeveloperName 
            FROM ListView 
            WHERE Id = :filterId
            LIMIT 1
        ];
        
        if(!standardController.getSelected().IsEmpty()) {
            if(!System.Label.Ready_for_Administrative_Dissolution_Label.equalsIgnoreCase(listViews[0].DeveloperName)
                && System.Label.vfPageLabel_brs_administrivateDissolutionIntentPage.equalsIgnoreCase(pageName)
            ) {
                this.strMsg = System.Label.vfPageMessage_Label1;
            } else if(!System.Label.Ready_for_Forfeiture_Revocation_Label.equalsIgnoreCase(listViews[0].DeveloperName)
                && System.Label.vfPageLabel_brs_administrivateDissolutionPage.equalsIgnoreCase(pageName)
            ) {
                this.strMsg = System.Label.vfPageMessage_Label2;
            }
        } else {
            this.strMsg = System.Label.vfPageMessage_Label3;
        }
    }
    
    //Savepoint will undo everything
    //To-Do | Error logging
    public void processAdminDissolution() {
        if(String.isNotBlank(strMsg)) {
            return;
        }

        Integer succeededBusinessCount = 0;
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        
        //update
        List<Account> accUpdLst = new List<Account>();
        Map<Id, Business_Filing__c> mapAccountFilings = new Map<Id, Business_Filing__c>();
        //rollback
        Map<Id, Account> mapAccIdToOldAcc = new Map<Id, Account>();
        List<Account> listAccountsToRollback = new List<Account>();

        //1. Admin Dissolution
        if(System.Label.vfPageLabel_brs_administrivateDissolutionIntentPage.equalsIgnoreCase(pageName)) {
            for(Account account :getAccLst(standardController.getSelected(), System.Label.Ready_for_dissolution, true)) {
                mapAccIdToOldAcc.put(account.Id, account);
                
                accUpdLst.add(new Account(  //update account
                    Id = account.Id,
                    Sub_status__c = System.Label.Admin_Dissolution_Initiated_Label
                ));
                
                mapAccountFilings.put(account.Id, new Business_Filing__c(
                    RecordTypeId = RecordTypeIdMaintenance,
                    Account__c = account.Id,
                    Status__c = System.Label.Latest_Filed_Status,
                    Type__c = System.Label.Administrative_Dissolution_Label,
                    Filing_Type__c = System.Label.Notice_of_Intent_to_Dissolve_Revoke_Label,
                    Filing_Date__c = System.today(),
                    Date_Intend_Notice__c = System.today(),
                    Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
                ));
            }
        }
        //2. Forfeiture/Revocation
        else if(System.Label.vfPageLabel_brs_administrivateDissolutionPage.equalsIgnoreCase(pageName)) {
            for(Account account : getAccLst(standardController.getSelected(), System.Label.Ready_for_Forfeiture_Revocation_Label_1, false)) {   
                mapAccIdToOldAcc.put(account.Id, account); //old account

                accUpdLst.add(new Account( //updated account
                    Id = account.Id,
                    Sub_status__c = null,
                    Status__c = System.Label.brs_maintenance_domestic.equalsIgnoreCase(account.Citizenship__c)
                        ? System.Label.Forfeited
                        : System.Label.Revoked_Label
                ));
    
                mapAccountFilings.put(account.Id, new Business_Filing__c(
                    RecordTypeId = RecordTypeIdMaintenance,
                    Account__c = account.Id,
                    Status__c = System.Label.Latest_Filed_Status,
                    Type__c = System.Label.Administrative_Dissolution_Label,
                    Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
                    Filing_Date__c = System.today(),
                    Date_Intend_Notice__c = System.today(),
                    Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
                ));
            }
        }
    
        //Process Administrative Dissoltion | Update account
        if(!accUpdLst.IsEmpty() && Schema.SObjectType.Account.isAccessible()) {
            for(Database.SaveResult result : Database.update(accUpdLst, false)) {
                if (result.isSuccess()) {
                    succeededBusinessCount++;
                } else {
                    mapAccountFilings.remove(result.getId());
                }
            }
        }
        
        //Insert Business Filings
        if(!mapAccountFilings.IsEmpty() && Schema.SObjectType.Business_Filing__c.isAccessible()) {
            List<Business_Filing__c> listFilings = mapAccountFilings.values();
            Database.SaveResult[] busFileInsertSuccessList = Database.insert(listFilings, false);
            List<Id> listFilingIds = new List<Id>();
            
            for(Integer index = 0; index < busFileInsertSuccessList.size(); index++) {
                if (busFileInsertSuccessList.get(index).isSuccess()) {
                    listFilingIds.add(busFileInsertSuccessList.get(index).getId());
                } else {
                    succeededBusinessCount--;
                    listAccountsToRollback.add(mapAccIdToOldAcc.get(listFilings.get(index).Account__c));                    
                }
            }

            //BRS-2708 | BRS-5417 | BRS-7025 | Nintex implementation for bulk admin dissolution doc generation
            //max 10 callouts allowed for SF
            if(!test.isRunningTest()){
            Database.executeBatch(new NintexBatchGeneration(listFilingIds, UCCFilingAcknowledgement.Operation.ADMIN_DISSOLUTION), 10);
             }
        }
        
        if(System.Label.vfPageLabel_brs_administrivateDissolutionIntentPage.equalsIgnoreCase(pageName)) {
            strMsg = System.Label.vfPageMessage_Label4 + ' ' + succeededBusinessCount
                + ' ' + System.Label.vfPageMessage_Label6 + ' ' + accUpdLst.size() + ' ' + System.Label.vfPageMessage_Label7;
        } else if(System.Label.vfPageLabel_brs_administrivateDissolutionPage.equalsIgnoreCase(pageName)) {
            strMsg = System.Label.vfPageMessage_Label5 + ' ' + succeededBusinessCount 
                + ' ' + System.Label.vfPageMessage_Label6 + ' ' + accUpdLst.size() + ' ' + System.Label.vfPageMessage_Label8;
        }

        //Undo The Error Records And INsert And Error Log Record
        if(!listAccountsToRollback.IsEmpty()) {
            Database.Update(listAccountsToRollback, false);
        }
    }

    public PageReference goToListView() {
        return new ApexPages.Action('{!List}').invoke();
    }
    
    public List<Account> getAccLst(List<sObject> listRecords, String strStatus, Boolean noAddressFoundCheck) {
        if(noAddressFoundCheck) {
            return [
                SELECT Id, Name,Citizenship__c,Sub_status__c,Status__c 
                FROM Account 
                WHERE Id IN :listRecords 
                    AND Sub_status__c = :strStatus 
                    AND No_address_found__c = false 
                    AND RecordType.Name = :System.Label.SignatoryType_Business 
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
        } else {
            return [
                SELECT Id, Name,Citizenship__c,Sub_status__c,Status__c 
                FROM Account 
                WHERE ID IN :listRecords 
                    AND 
                        (
                            (
                                Sub_status__c =: System.Label.brs_AdminDissolveReady_for_Revocation 
                                AND 
                                Citizenship__c =: System.Label.Foreign
                            ) 
                            OR 
                            (
                                Sub_status__c =: System.Label.brs_AdminDissolveReady_for_Forfeiture 
                                AND 
                                Citizenship__c =: System.Label.brs_maintenance_domestic
                            )
                        ) 
                    AND RecordType.Name =: System.Label.SignatoryType_Business 
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
        }
    }
}