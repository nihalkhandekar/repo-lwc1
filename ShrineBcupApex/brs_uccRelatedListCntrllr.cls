/******************************************************************************************************
* NAME:  		brs_uccRelatedListCntrllr
* DESCRIPTION:  Generic class for custom related list
*
* @AUTHOR: 		Aparna Shahpurkar
* @DATE: 		2nd Feb, 2021
*******************************************************************************************************/
public without sharing class brs_uccRelatedListCntrllr {
    public static final string CLASSNAME = 'brs_uccRelatedListCntrllr';    
    @AuraEnabled
    public static RelatedListWrapper getUCCContactRecords(String recordId){
        try{
        RelatedListWrapper objWrap = new RelatedListWrapper();
        List <UCC_Related_Info__c> listOfSPRecords = new List <UCC_Related_Info__c>();
        List <UCC_Related_Info__c> listOfDebtorRecords = new List <UCC_Related_Info__c>();
        List <UCC_Related_Info__c> listOfSubmitterRecords = new List <UCC_Related_Info__c>();
         List <Business_Filing__c> listOfAnnualReportRecords = new List <Business_Filing__c>();
        List <Business_Filing__c> listOfFirstReportRecords = new List <Business_Filing__c>();
        
        if (recordId != null &&  Id.valueOf(recordId).getSobjectType().getDescribe().getName()=='UCC_Filing__c') {

            List<UCC_Filing__c> uccInst = [SELECT Id, Type__c, UCC_Lien_Type__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c, (SELECT Id, Type__c,Address__c FROM  UCC_Related_Info__r) FROM UCC_Filing__c WHERE id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
           
            	if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') && 
					(uccInst[0].UCC_Lien_Type__c == System.label.OFS_Value || 
                   uccInst[0].UCC_Lien_Type__c == System.label.TransmittingUtilityLabel || 
                   uccInst[0].UCC_Lien_Type__c == System.label.PublicFinanceTransactionLabel || 
                   uccInst[0].UCC_Lien_Type__c == System.label.MunicipalLabel || 
                   uccInst[0].UCC_Lien_Type__c == System.label.LaborLabel || 
                   uccInst[0].UCC_Lien_Type__c == System.label.debtor_state || 
                   uccInst[0].UCC_Lien_Type__c == System.label.revenueServicesLabel || 
                   uccInst[0].UCC_Lien_Type__c == System.label.lien_Type_Irs))
                {
                    objWrap.sPRecordsTitle = System.label.Secured_Party_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Label_Secured_Party;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Debtor_Label;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') &&
						(uccInst[0].UCC_Lien_Type__c == System.label.Aircraft_Label || 
                        uccInst[0].UCC_Lien_Type__c == System.label.Vessel_Label || 
                        uccInst[0].UCC_Lien_Type__c == System.label.NoticeOfAttachmentLabel))
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Claimants_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Owners_Label;
                    objWrap.sPRecordsType = System.label.Review_MasterLabel_Type_Claimant;
                    objWrap.debtorRecordsType = System.label.Review_MasterLabel_Type_Owner;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') &&
						uccInst[0].UCC_Lien_Type__c == System.label.JudgmentPersonalPropertyLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Judgment_Creditors_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Judgment_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Judgment_Creditor_Label_Title_Case;
                    objWrap.debtorRecordsType = System.label.Judgment_Debtor_Label;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') &&
						uccInst[0].UCC_Lien_Type__c == System.label.JudgmentTypeLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Plaintiffs_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Defendant_Plural;
                    objWrap.sPRecordsType = System.label.BRS_UCC_Plaintiff_Label;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Defendant_Label;
                }                
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&&
					(uccInst[0].UCC_Lien_Id__r.Type__c == System.label.OFS_Value || 
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.TransmittingUtilityLabel || 
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.PublicFinanceTransactionLabel || 
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.MunicipalLabel || 
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.LaborLabel ||
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.debtor_state ||
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.revenueServicesLabel ||
                   uccInst[0].UCC_Lien_Id__r.Type__c == System.label.lien_Type_Irs))
                {
                    objWrap.sPRecordsTitle = System.label.Secured_Party_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Label_Secured_Party;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Debtor_Label;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&&
						(uccInst[0].UCC_Lien_Id__r.Type__c == System.label.Aircraft_Label || 
                        uccInst[0].UCC_Lien_Id__r.Type__c == System.label.Vessel_Label || 
                        uccInst[0].UCC_Lien_Id__r.Type__c == System.label.NoticeOfAttachmentLabel))
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Claimants_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Owners_Label;
                    objWrap.sPRecordsType = System.label.Review_MasterLabel_Type_Claimant;
                    objWrap.debtorRecordsType = System.label.Review_MasterLabel_Type_Owner;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&&
						uccInst[0].UCC_Lien_Id__r.Type__c == System.label.JudgmentPersonalPropertyLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Judgment_Creditors_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Judgment_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Judgment_Creditor_Label_Title_Case;
                    objWrap.debtorRecordsType = System.label.Judgment_Debtor_Label;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&&
						uccInst[0].UCC_Lien_Id__r.Type__c == System.label.JudgmentTypeLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Plaintiffs_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Defendant_Plural;
                    objWrap.sPRecordsType = System.label.BRS_UCC_Plaintiff_Label;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Defendant_Label;
                }
                else
                {
                    objWrap.sPRecordsTitle = System.label.Secured_Party_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Label_Secured_Party;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Debtor_Label;
                }
                                    
            
            if(uccInst[0].type__c == System.label.brs_InfoStatement){
                objWrap.isInformationStatement = true;
            }
            else{
                objWrap.isInformationStatement = false;
            }
            Set<String> debtorTypes=new Set<String>{System.label.BRS_UCC_Debtor_Label,System.label.Review_MasterLabel_Type_Owner,
                                                    System.label.Judgment_Debtor_Label,System.label.BRS_UCC_Defendant_Label};
            Set<String> SecuredTypes=new Set<String>{System.label.Label_Secured_Party,System.label.BRS_UCC_Assignor_Label,
                                                    System.label.Review_MasterLabel_Type_Claimant,System.label.Judgment_Creditor_Label_Title_Case,
                                                    System.label.BRS_UCC_Plaintiff_Label};
            for(UCC_Related_Info__c contact : uccInst[0].UCC_Related_Info__r){
                if(debtorTypes.contains(contact.Type__c)){
                    listOfDebtorRecords.add(contact);
                }
                else if(SecuredTypes.contains(contact.Type__c)){
                    listOfSPRecords.add(contact);
                }
                else if(contact.Type__c==System.label.Review_MasterLabel_Type_Submitter){
                    listOfSubmitterRecords.add(contact);
                }
            }
            objWrap.listOfSPRecords = listOfSPRecords;
            objWrap.listOfDebtorRecords = listOfDebtorRecords;
            objWrap.listOfSubmitterRecords = listOfSubmitterRecords;
            objWrap.recordCount = [SELECT COUNT() FROM UCC_Related_Info__c WHERE Filing_Id__c =:recordId WITH SECURITY_ENFORCED];
        }else if(recordId != null &&  Id.valueOf(recordId).getSobjectType().getDescribe().getName()==System.label.Account){
            List<Business_Filing__c> annualFirstReportList=[Select Id,Name,Due_Date__c,Type__c,Status__c from Business_Filing__c where Account__c=:recordId];
            for(Business_Filing__c bf:annualFirstReportList){
                if(bf.Type__c == System.label.Annual_Report){
                    listOfAnnualReportRecords.add(bf);
                }else if(bf.Type__c == System.label.First_Report){
                    listOfFirstReportRecords.add(bf);
                }
            }
            objWrap.listOfFirstReportRecords=listOfFirstReportRecords;
            objWrap.listOfAnnualReportRecords=listOfAnnualReportRecords;
        }       
        return objWrap;
        }catch (exception exe) {
            BOS_Utility.ExceptionHandler(CLASSNAME,'getUCCContactRecords','',null,BOS_Utility.sSeverity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
     @AuraEnabled
    public static Account getAccountRecord(String recordId){
        return [Select Id,Name,Citizenship__c,Business_Type__c from Account where Id=:recordId];
    }
    
    public class RelatedListWrapper{
        @AuraEnabled
        public List <UCC_Related_Info__c> listOfSPRecords;
        @AuraEnabled
        public List <UCC_Related_Info__c> listOfDebtorRecords;
        @AuraEnabled
        public List <UCC_Related_Info__c> listOfSubmitterRecords;
        @AuraEnabled
        public List <Business_Filing__c> listOfAnnualReportRecords;
        @AuraEnabled
        public List <Business_Filing__c> listOfFirstReportRecords;
        @AuraEnabled
        public Integer recordCount;
        @AuraEnabled
        public String sPRecordsTitle;
        @AuraEnabled
        public String debtorRecordsTitle;
        @AuraEnabled
        public String sPRecordsType;
        @AuraEnabled
        public String debtorRecordsType;
        @AuraEnabled
        public Boolean isInformationStatement;
    }
}