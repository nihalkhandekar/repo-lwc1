public without sharing class brs_BackOfficeRecsForm {
    public static final string CLASSNAME = 'brs_BackOfficeRecsForm';
    @AuraEnabled()
    public static RelatedListWrapper getUCCContactRecords(String recordId){
        try{
        RelatedListWrapper objWrap = new RelatedListWrapper();
        List <UCC_Related_Info__c> listOfSPRecords = new List <UCC_Related_Info__c>();
        List <UCC_Related_Info__c> listOfDebtorRecords = new List <UCC_Related_Info__c>();
        List <UCC_Related_Info__c> listOfSubmitterRecords = new List <UCC_Related_Info__c>();
        List <Business_Filing__c> listOfAnnualReportRecords = new List <Business_Filing__c>();
        List <Business_Filing__c> listOfFirstReportRecords = new List <Business_Filing__c>();
        List <Principal__c> listOfPrincipalRecords = new List <Principal__c>();
        List <Stock_Classification__c> listOfStockRecords = new List <Stock_Classification__c>();
        List <Contact> listOfContactRecords = new List <Contact>();

        
        if (recordId != null &&  Id.valueOf(recordId).getSobjectType().getDescribe().getName()=='UCC_Filing__c') {
            List<UCC_Filing__c> uccInst = [SELECT Id, Type__c, UCC_Lien_Type__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,Checklist_Status__c, (SELECT Id, Type__c FROM  UCC_Related_Info__r) FROM UCC_Filing__c WHERE id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
            system.debug('UCCINSTA :::'+uccInst);
            //Removed nested If as part of code clean up activity
           // if(uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !=''){
                if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') &&( uccInst[0].UCC_Lien_Type__c == System.label.OFS_Value || 
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
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') && (uccInst[0].UCC_Lien_Type__c == System.label.Aircraft_Label || 
                        uccInst[0].UCC_Lien_Type__c == System.label.Vessel_Label || 
                        uccInst[0].UCC_Lien_Type__c == System.label.NoticeOfAttachmentLabel))
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Claimants_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Owners_Label;
                    objWrap.sPRecordsType = System.label.Review_MasterLabel_Type_Claimant;
                    objWrap.debtorRecordsType = System.label.Review_MasterLabel_Type_Owner;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') && uccInst[0].UCC_Lien_Type__c == System.label.JudgmentPersonalPropertyLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Judgment_Creditors_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Judgment_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Judgment_Creditor_Label_Title_Case;
                    objWrap.debtorRecordsType = System.label.Judgment_Debtor_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Type__c != null || uccInst[0].UCC_Lien_Type__c !='') && uccInst[0].UCC_Lien_Type__c == System.label.JudgmentTypeLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Plaintiffs_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Defendant_Plural;
                    objWrap.sPRecordsType = System.label.BRS_UCC_Plaintiff_Label;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Defendant_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else
                {
                    objWrap.sPRecordsTitle = System.label.Secured_Party_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Label_Secured_Party;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Debtor_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
           // } 
           //Removed nested If as part of code clean up activity
          //  else if(uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != ''){
                if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&& (uccInst[0].UCC_Lien_Id__r.Type__c == System.label.OFS_Value || 
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
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&& (uccInst[0].UCC_Lien_Id__r.Type__c == System.label.Aircraft_Label || 
                        uccInst[0].UCC_Lien_Id__r.Type__c == System.label.Vessel_Label || 
                        uccInst[0].UCC_Lien_Id__r.Type__c == System.label.NoticeOfAttachmentLabel))
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Claimants_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Owners_Label;
                    objWrap.sPRecordsType = System.label.Review_MasterLabel_Type_Claimant;
                    objWrap.debtorRecordsType = System.label.Review_MasterLabel_Type_Owner;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '') && uccInst[0].UCC_Lien_Id__r.Type__c == System.label.JudgmentPersonalPropertyLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Judgment_Creditors_Label;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Judgment_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Judgment_Creditor_Label_Title_Case;
                    objWrap.debtorRecordsType = System.label.Judgment_Debtor_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else if((uccInst[0].UCC_Lien_Id__c != null || uccInst[0].UCC_Lien_Id__c != '')&& uccInst[0].UCC_Lien_Id__r.Type__c == System.label.JudgmentTypeLabel)
                {
                    objWrap.sPRecordsTitle = System.label.BRS_UCC_Plaintiffs_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Defendant_Plural;
                    objWrap.sPRecordsType = System.label.BRS_UCC_Plaintiff_Label;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Defendant_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
                else
                {
                    objWrap.sPRecordsTitle = System.label.Secured_Party_Plural;
                    objWrap.debtorRecordsTitle = System.label.BRS_UCC_Debtors_Label;
                    objWrap.sPRecordsType = System.label.Label_Secured_Party;
                    objWrap.debtorRecordsType = System.label.BRS_UCC_Debtor_Label;
                    objwrap.checklistStatus= uccInst[0].Checklist_Status__c;
                }
           // }                        
            
            if(uccInst[0].type__c == System.label.brs_InfoStatement){
                objWrap.isInformationStatement = true;
            }
            else{
                objWrap.isInformationStatement = false;
            }
            
            Integer i=1,j=1,k=1;
            Set<String> debtorTypes=new Set<String>{System.label.BRS_UCC_Debtor_Label,System.label.Review_MasterLabel_Type_Owner,System.label.Judgment_Debtor_Label,System.label.BRS_UCC_Defendant_Label};
            Set<String> SecuredTypes=new Set<String>{System.label.Label_Secured_Party,System.label.BRS_UCC_Assignor_Label,System.label.Review_MasterLabel_Type_Claimant,System.label.Judgment_Creditor_Label_Title_Case,System.label.BRS_UCC_Plaintiff_Label};
            system.debug('UCC_Related_Info__c contact : uccInst[0].UCC_Related_Info__r:::'+uccInst[0].UCC_Related_Info__r);
                for(UCC_Related_Info__c contact : uccInst[0].UCC_Related_Info__r){                
                if(debtorTypes.contains(contact.Type__c)){
                    if(i<=2){
                        System.debug('test i1: '+i);
                        listOfDebtorRecords.add(contact);                        
                    }
                    i++;
                    System.debug('test i2: '+i);
                }
                else if(SecuredTypes.contains(contact.Type__c)){
                    if(j<=2){
                        System.debug('test j1: '+j);
                        listOfSPRecords.add(contact);
                    }
                    j++;
                    System.debug('test j2: '+j);
                }
                else if(contact.Type__c==System.label.Review_MasterLabel_Type_Submitter){
                    if(k<=2){
                        System.debug('test k1: '+k);
                        listOfSubmitterRecords.add(contact);
                    }
                    k++;
                    System.debug('test k2: '+k);
                }
            }
            objWrap.listOfSPRecords = listOfSPRecords;
            objWrap.listOfDebtorRecords = listOfDebtorRecords;
            objWrap.listOfSubmitterRecords = listOfSubmitterRecords;
            objWrap.recordCount = [SELECT COUNT() FROM UCC_Related_Info__c WHERE Filing_Id__c =:recordId WITH SECURITY_ENFORCED];
            System.debug('3: '+objWrap.recordCount);
        }else if(recordId != null &&  Id.valueOf(recordId).getSobjectType().getDescribe().getName()=='Account'){
 //           Id annualFirstReportType=Wizard_Utlity.getRecordTypeId('Annual_Report_First_Report',Schema.Business_Filing__c.getSObjectType());
            List<Business_Filing__c> annualFirstReportList=[Select Id,Name,Type__c,Status__c from Business_Filing__c where Account__c=:recordId];
            for(Business_Filing__c bf:annualFirstReportList){
                if(bf.Type__c == 'Annual Report'){
                    listOfAnnualReportRecords.add(bf);
                }else if(bf.Type__c == 'First Report'){
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
    
    public without sharing class RelatedListWrapper{
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
        public List <Principal__c> listOfPrincipalRecords;
        @AuraEnabled
        public List <Stock_Classification__c> listOfStockRecords;
        @AuraEnabled
        public List <Contact> listOfContactRecords;


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
        @AuraEnabled
        public String checklistStatus;
    }
}