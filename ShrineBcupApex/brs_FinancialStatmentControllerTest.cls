@isTest
public class brs_FinancialStatmentControllerTest {

    @testSetup 
    static void setup() {
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Status__c='Active',Lapse_Date__c=System.today().addYears(-1)));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2'));
        uccLien.add(new UCC_Lien__c(Type__c='OFS',Status__c='Active'));
        insert uccLien;
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = BRS_TestDataFactory.onOffCustomSetting();
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[0].id));
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[1].id));
        testFiling.add(new UCC_Filing__c(Type__c = 'OFS',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[2].id));
        insert testFiling; 
        List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        
         UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
         objRelatedInfo.City__c = 'City';   
         objRelatedInfo.Country__c = 'country';
         objRelatedInfo.isAuthorizer__c = true;
         //Added as Part of BRS-2491
         objRelatedInfo.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
         objRelatedInfo.Org_Name__c = 'Orgname';
         objRelatedInfo.Type__c = 'Secured Party';
         objRelatedInfo.Street__c = 'Street';
		 objRelatedInfo.State__c = 'State';
         objRelatedInfo.Zip_Code__c = '11111';
         objRelatedInfo.Suffix__c = 'Suffix';   
         objRelatedInfo.Filing_Id__c = testFiling[0].id;
         lstRelatedInfo.add(objRelatedInfo);
            
         UCC_Related_Info__c objRelatedInfo2 = new UCC_Related_Info__c();  
         objRelatedInfo2.City__c = 'City';   
         objRelatedInfo2.Country__c = 'country';
         objRelatedInfo2.isAuthorizer__c = true;
         //Added as Part of BRS-2491
         objRelatedInfo2.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
         objRelatedInfo2.Org_Name__c = 'Orgname';
         objRelatedInfo2.Type__c = 'Secured Party';
         objRelatedInfo2.Street__c = 'Street';
		 objRelatedInfo2.State__c = 'State';
         objRelatedInfo2.Zip_Code__c = '11111';
         objRelatedInfo2.Suffix__c = 'Suffix';   
         objRelatedInfo2.Filing_Id__c = testFiling[0].id;
         lstRelatedInfo.add(objRelatedInfo2);
        
        UCC_Related_Info__c objRelatedInfo3 = new UCC_Related_Info__c();  
         objRelatedInfo3.City__c = 'City';   
         objRelatedInfo3.Country__c = 'country';
         objRelatedInfo3.isAuthorizer__c = true;
         objRelatedInfo3.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
         objRelatedInfo3.Org_Name__c = 'Orgname';
         objRelatedInfo3.Type__c = 'Secured Party';
         objRelatedInfo3.Street__c = 'Street';
		 objRelatedInfo3.State__c = 'State';
         objRelatedInfo3.Zip_Code__c = '11111';
         objRelatedInfo3.Suffix__c = 'Suffix';   
         objRelatedInfo3.Filing_Id__c = testFiling[2].id;
         lstRelatedInfo.add(objRelatedInfo3);
         insert lstRelatedInfo;
        
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account acc = new Account();
        acc = BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con = BRS_TestDataFactory.createContactObject(acc.id);
        User user = new User();
        user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
       
    }
    @isTest
    static void getFilingRecordsTest() {
        Test.startTest();
        List<UCC_Lien__c> ucclienobj = [Select id,UCC_Lien_Number__c from UCC_Lien__c];
        brs_FinancialStatmentController.getFilingRecords(ucclienobj[0].UCC_Lien_Number__c);
        Test.stopTest();
    }
   @isTest
    static void updateFilingRecordsTest() {
        Id ucc  = [Select id from UCC_Filing__c Limit 1].id;
        Test.startTest();
        brs_FinancialStatmentController.updateFilingRecords(ucc,true);
        try {
            brs_FinancialStatmentController.updateFilingRecords(ucc,null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
   @isTest
    static void createCloneRecordsTest() {
         List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
       Contact con=[Select Id,Name from Contact LIMIT 1];
        User commUser=[Select Id from User where ProfileId=:lstProfileId[0].Id AND LastName='Testing' LIMIT 1];
        List<UCC_Lien__c> ucclienobj = [Select id,UCC_Lien_Number__c from UCC_Lien__c where Type__c='OFS'];
        List<UCC_Lien__c> ucclienobj2 = [Select id,UCC_Lien_Number__c from UCC_Lien__c where Name__c='LienData1'];
        List<UCC_Filing__c> uccInst = [SELECT Id, Name,Status__c,Type__c,Name__c,Lien_Type__c,Location__Latitude__s,Lapse_Date__c,Collateral_Information__c,
                           Claim_Amount__c,Filer_Reference_Data__c,Date_of_Judgement__c,Original_Judgement_Amount__c,Amount_Due__c,Description__c,
                           Collateral_Type__c,Lien_Filing_Type__c,Collateral_Document_Description__c,Reason_for_Dispute__c,
                           Amendment_Type__c,Acknowledge__c,Amendment_Entity__c,Type_of_Update__c,Dispute_Justification__c,Request_Amendment__c,
                           Amend_Collateral__c,Type_of_Collateral_Update__c,Assignment_Type__c,UCC_Filing_Type__c,Filing_Source__c,Filing_Date__c,
                           OFC_Comments__c,OFC_Comments_Code__c,
                           (Select Id, Name,Type__c, Street__c, City__c, State__c, Country__c, Zip_Code__c, Individual_First_Name__c,
                            Individual_Middle_Name__c,Deleted_Flag__c,Filing_Id__c,RecordTypeId,RecordType.DeveloperName, Individual_SurName__c, Org_Name__c,
                            Suffix__c,Individual_Salutation__c,isAuthorizer__c,Address__c,Debtor_Is__c,International_Address__c,Unit__c
                            FROM  UCC_Related_Info__r) from UCC_Filing__c where UCC_Lien_Id__c=:ucclienobj[0].Id];
        
        System.assertNotEquals(null, brs_FinancialStatmentController.createCloneRecords(ucclienobj[0].UCC_Lien_Number__c));
        
        uccInst[0].Status__c = system.label.UCC_FILING_STATUS;
        update uccInst[0];
        
        System.runAs(commUser){
            Test.startTest();
            
            try {
                
                brs_FinancialStatmentController.createCloneRecords(ucclienobj2[0].UCC_Lien_Number__c);
                System.assertEquals(null, brs_FinancialStatmentController.createCloneRecords('NoData'));
                System.assertNotEquals(null, brs_FinancialStatmentController.createCloneRecords(ucclienobj[0].UCC_Lien_Number__c));
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        	Test.stopTest();
        }
        
    }
    
    @isTest
    static void getUCCRelatedRecordsTest() {
        Test.startTest();      
        UCC_Filing__c uccFilingObj = [Select id,Name,Type__c,Filing_Number__c,Status__c from UCC_Filing__c where Status__c='Completed'];
        brs_FinancialStatmentController.getUCCRelatedRecords(uccFilingObj.Filing_Number__c);
       
        Test.stopTest();
    }

}