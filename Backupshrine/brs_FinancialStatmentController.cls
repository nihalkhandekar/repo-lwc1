public without sharing class brs_FinancialStatmentController {
    public static final String Status='Completed';
    public static final String StatusProgress='In-Progress';
    
    @AuraEnabled
    public static  list<UCC_Lien__c> getFilingRecords(string FilingName) {
        list<UCC_Lien__c > lstucc = new list<UCC_Lien__c>();
        list<UCC_Lien__c > lstUccToReturn = new list<UCC_Lien__c>();
        Map<String,String>  labelMaps = new Map<String,String>();
        labelMaps = brs_filingDueController.getTranslatedMap();
        try {
            lstucc = [SELECT Id,
            UCC_Lien_Number__c, Type__c, Lapse_Date__c, Status__c,(Select Id,Name,Type__c,UCC_Lien_Id__c,
            Filing_Number__c,Filing_Date__c,UCC_Filing_Type__c from UCC_Filings__r where Status__c =:system.label.UCC_FILING_STATUS)  from UCC_Lien__c
                      where UCC_Lien_Number__c = : FilingName and Status__c!=:System.Label.BRS_Archived WITH SECURITY_ENFORCED];
            
            if (!lstucc.isEmpty()) {
                for (UCC_Lien__c uccRec : lstucc) {
                    Date lapseDate = uccRec.Lapse_Date__c;
                    uccRec.Status__c=uccRec.Status__c != null? (labelMaps.containsKey(uccRec.Status__c)? labelMaps.get(uccRec.Status__c) : uccRec.Status__c) : null;
                    if(lapseDate!=null){
                        lapseDate = lapseDate.addYears(1);
                        if (lapseDate >= System.today()) {
                            lstUccToReturn.add(uccRec);
                        }
                    }
                    else{
                        lstUccToReturn.add(uccRec);
                    }
                }
            }
            return lstUccToReturn;
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler('brs_FinancialStatmentController', 'getFilingRecords', 'UCC_Lien__c', null, 'medium', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static  list<filingRelatedInfoWrap> getUCCRelatedRecords(string FilingNumber) {
        list<UCC_Filing__c > lstuccrel = new list<UCC_Filing__c>();
        list<filingRelatedInfoWrap> wrapList = new list<filingRelatedInfoWrap>();
        Set<Id> FilingIds = new Set<Id>();
        
        try {
            lstuccrel = [SELECT Id, Name,toLabel(Type__c),Start_Page__c,Filing_Number__c,Filing_Date__c,Lapse_Date__c,Microfilm_volume_number__c,Pages__c,IRS_SLID_Number__c,
                         (Select Secured_Party_ID__r.Assignor_Name__c,Assignor_ID__c,Secured_Party_ID__c,Filing_ID__c from UCC_Assignee_Info__r),
                         (Select Id,Type__c,Address__c,City__c,Country__c,Unit__c,Debtor_Is__c,Deleted_Flag__c,External_ID__c,Filing_Id__c,Individual_First_Name__c,Individual_Middle_Name__c,RecordTypeId,RecordType.DeveloperName,Individual_Salutation__c,Individual_SurName__c,International_Address__c,isAuthorizer__c,Name,Name__c,Org_Name__c,OwnerId,State__c,Status__c,Street__c,Suffix__c,UCC_Related_Info__c,Zip_Code__c,Assignor_Name__c from UCC_Related_Info__r),UCC_Lien_Id__r.UCC_Lien_Number__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Lapse_Date__c
                         FROM  UCC_Filing__c where Filing_Number__c =: FilingNumber WITH SECURITY_ENFORCED];//Filing_Number__c
            for(UCC_Filing__c uccFile : lstuccrel){
                filingRelatedInfoWrap wrapInst = new filingRelatedInfoWrap();
                wrapInst.FilingRec = uccFile;
                FilingIds.add(uccFile.Id);
                Map<Id,String> filingDocMap = brs_onlineEnquiryBusinessSearchBusCls.getFilingRelatedDocs(FilingIds,'UCC');
                wrapInst.publicLink = filingDocMap.containsKey(uccFile.Id)?filingDocMap.get(uccFile.Id):null;
                wrapList.add(wrapInst);
            }
            return wrapList;
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler('brs_FinancialStatmentController', 'getUCCRelatedRecords', 'UCC_Filing__c', null, 'medium', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static string createCloneRecords(string FilingName) {
        List<UCC_Filing__c> uccInst = new List<UCC_Filing__c>();
        try {
            if (FilingName != '') {
                uccInst = [SELECT Id,
                           Name,Status__c,Type__c,Name__c,Lien_Type__c,Location__Latitude__s,Lapse_Date__c,Collateral_Information__c,
                           Claim_Amount__c,Filer_Reference_Data__c,Date_of_Judgement__c,Original_Judgement_Amount__c,Amount_Due__c,Description__c,
                           Collateral_Type__c,Lien_Filing_Type__c,Collateral_Document_Description__c,Reason_for_Dispute__c,
                           Amendment_Type__c,Acknowledge__c,Amendment_Entity__c,Type_of_Update__c,Dispute_Justification__c,Request_Amendment__c,
                           Amend_Collateral__c,Type_of_Collateral_Update__c,Assignment_Type__c,UCC_Filing_Type__c,Filing_Source__c,Filing_Date__c,
                           OFC_Comments__c,OFC_Comments_Code__c,
                           (Select Id, Name,Type__c, Street__c, City__c, State__c, Country__c, Zip_Code__c, Individual_First_Name__c,International_Address__c,Unit__c,
                            Individual_Middle_Name__c,Deleted_Flag__c,isCloned__c,Filing_Id__c,RecordTypeId,RecordType.DeveloperName, Individual_SurName__c, Org_Name__c,
                            Suffix__c,Individual_Salutation__c,isAuthorizer__c,Address__c,Debtor_Is__c
                            FROM  UCC_Related_Info__r where Deleted_Flag__c !=true and Status__c =: System.label.UCC_CONTACTS_STATUS And UCC_Related_Info__c = null),
                           UCC_Lien_Id__r.Name, UCC_Lien_Id__r.Status__c FROM  UCC_Filing__c
                           where UCC_Lien_Id__r.UCC_Lien_Number__c = : FilingName 
						   and Status__c =:System.label.UCC_FILING_STATUS 
						   And Type__c !=: system.label.Office_Correct WITH SECURITY_ENFORCED
						   order by Filing_Date__c DESC limit 1];
            }
            if (!uccInst.isEmpty()) {
                UCC_Filing__c filingNewUInst = new UCC_Filing__c();
                filingNewUInst.Status__c = StatusProgress;
				filingNewUInst.Filing_Source__c = System.label.brs_FilingOnline;
                filingNewUInst.UCC_Lien_Id__c = uccInst[0].UCC_Lien_Id__c;
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject>{filingNewUInst}, 'insert'); 
                if(accessCheck){ 
                  insert filingNewUInst;   
                } 

                List<UCC_Related_Info__c> uccrelatedInfoList = new List<UCC_Related_Info__c>();
                uccrelatedInfoList = uccInst.get(0).UCC_Related_Info__r.deepClone(false, false, false);
                insert uccrelatedInfoList;

                List<UCC_Related_Info__c> lstRel = new List<UCC_Related_Info__c>();
                if(!uccrelatedInfoList.isEmpty()){
                    for(UCC_Related_Info__c uccRel :uccrelatedInfoList){
                        uccRel.Filing_Id__c =filingNewUInst.Id;
                        uccRel.isAuthorizer__c = false;
                        uccRel.Status__c=Status;
                        uccRel.isCloned__c=true;
                        lstRel.add(uccRel);
                    }
            Boolean accessCheck2 = BRS_SecurityUtility.checkDMLAccess(lstRel, 'update'); 
                    if(accessCheck2){ 
                       update lstRel;  
                    } 
                }
                return filingNewUInst.id;
            } else {
              uccInst = [SELECT Id,
                        Name,Status__c,Type__c,Name__c,Lien_Type__c,Location__Latitude__s,Lapse_Date__c,Collateral_Information__c,
                        Claim_Amount__c,Filer_Reference_Data__c,Date_of_Judgement__c,Original_Judgement_Amount__c,Amount_Due__c,Description__c,
                        Collateral_Type__c,Lien_Filing_Type__c,Collateral_Document_Description__c,Reason_for_Dispute__c,
                        Amendment_Type__c,Acknowledge__c,Amendment_Entity__c,Type_of_Update__c,Dispute_Justification__c,Request_Amendment__c,
                        Amend_Collateral__c,Type_of_Collateral_Update__c,Assignment_Type__c,UCC_Filing_Type__c,Filing_Source__c,Filing_Date__c,
                        (Select Id, Name,Type__c, Street__c, City__c, State__c, Country__c, Zip_Code__c, Individual_First_Name__c,
                         Individual_Middle_Name__c,Deleted_Flag__c,Filing_Id__c,RecordTypeId,RecordType.DeveloperName, Individual_SurName__c, Org_Name__c,International_Address__c,Unit__c,
                         Suffix__c,Individual_Salutation__c,isAuthorizer__c,Address__c,Debtor_Is__c
                         FROM  UCC_Related_Info__r where Deleted_Flag__c !=true),
                         UCC_Lien_Id__r.Name, UCC_Lien_Id__r.Status__c FROM  UCC_Filing__c
                         where UCC_Lien_Id__r.UCC_Lien_Number__c = : FilingName 
						 And Type__c !=: system.label.Office_Correct 
						 and Status__c !=:System.label.UCC_FILING_STATUS WITH SECURITY_ENFORCED order by Filing_Date__c DESC limit 1];
                if(!uccInst.isEmpty()){
                    return uccInst[0].id;
                }
                else{
                    return null;
                }  
            }
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler('brs_FinancialStatmentController', 'createCloneRecords', 'UCC_Filing__c', null, 'medium', exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
    public class filingRelatedInfoWrap{
        @AuraEnabled public UCC_Filing__c FilingRec{get;set;}
        @AuraEnabled public String publicLink{get;set;}
    }

    @AuraEnabled
    public static void updateFilingRecords (string FilingId, Boolean Acknowledge) {
        list<UCC_Filing__c> lstFiling = new list<UCC_Filing__c>();
        try {
            lstFiling = [SELECT Id, Name, Acknowledge__c FROM UCC_Filing__c where id = :FilingId WITH SECURITY_ENFORCED];
            lstFiling[0].Acknowledge__c = Acknowledge;
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(lstFiling, 'update'); 
            if(accessCheck){ 
                update lstFiling;
            } 
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler('brs_FinancialStatmentController', 'updateFilingRecords', 'UCC_Filing__c', null, 'medium', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}