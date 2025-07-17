@isTest
public class brs_BackOfficeRecsForm_Test {
    
    @testSetup 
    static void setup() {
        UCC_Lien__c lien= BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c objFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress',lien.Id,'Amendments');
        BRS_TestDataFactory.createUCCRelatedObject('Secured Party',objFiling.id);
        Account acc=BRS_TestDataFactory.createAccountObject();
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        Business_Filing__c bf=BRS_TestDataFactory.createBusinessFilingObject(annualFirstrecTypeId,acc.Id,'',System.Label.First_Report_Label,'Completed');
    }
    @isTest
    static void getUCCContactRecordsTest(){
        List<UCC_Filing__c> lstUccFiling = [Select id,UCC_Lien_Id__c from UCC_Filing__c  where Type__c = 'Amendments'];
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        lstUccFiling[0].UCC_Lien_Type__c=System.label.debtor_state;
        update lstUccFiling;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        lstUccFiling[0].UCC_Lien_Type__c=System.label.Vessel_Label;
        update lstUccFiling;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);        
        lstUccFiling[0].UCC_Lien_Type__c=System.label.JudgmentPersonalPropertyLabel;
        update lstUccFiling;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);        
        lstUccFiling[0].UCC_Lien_Type__c=System.label.JudgmentTypeLabel;
        update lstUccFiling;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);       
		        
    }
      @isTest
    static void getUCCContactRecordsLienTest(){
         List<UCC_Filing__c> lstUccFiling = [Select id,UCC_Lien_Id__c from UCC_Filing__c  where Type__c = 'Amendments'];
         UCC_Lien__c lien=[Select Id,name,Type__c from UCC_Lien__c where Id=:lstUccFiling[0].UCC_Lien_Id__c];
        lien.Type__c=System.label.debtor_state;
        update lien;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        lien.Type__c=System.label.Aircraft_Label;
        update lien;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        lien.Type__c=System.label.JudgmentPersonalPropertyLabel;
        update lien;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        lien.Type__c=System.label.JudgmentTypeLabel;
        update lien;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);
        
         lstUccFiling[0].UCC_Lien_Id__c=null;
         update lstUccFiling;
        brs_BackOfficeRecsForm.getUCCContactRecords(lstUccFiling[0].Id);   
    }
     @isTest
    static void getUCCContactRecordsAccountTest(){
        Account acc=[Select Id,Name from Account LIMIT 1];
         brs_BackOfficeRecsForm.getUCCContactRecords(acc.Id); 
        brs_BackOfficeRecsForm.getAccountRecord(acc.Id);
    }
}