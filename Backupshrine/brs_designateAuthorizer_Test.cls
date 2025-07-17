@isTest
private class brs_designateAuthorizer_Test {
    @testSetup 
    static void setup() {
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c objFiling  = new UCC_Filing__c();
        objFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress','','Amendments');
        UCC_Filing__c objFiling2  = new UCC_Filing__c();
        objFiling2 = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress','','Information');        
        BRS_TestDataFactory.createUCCRelatedObject('Secured Party',objFiling.id);
        BRS_TestDataFactory.createUCCRelatedObject('Owner',objFiling2.id);
        BRS_TestDataFactory.createUCCRelatedObject('Debtor',objFiling2.id);
        BRS_TestDataFactory.createUCCRelatedObject(System.Label.Review_MasterLabel_Type_Claimant,objFiling2.id);
    }
    
    @isTest
    static void updateAuthorizerTest(){
        String filingId  = (String)[Select id from UCC_Filing__c Limit 1].id;        
        UCC_Related_Info__c objRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c where Filing_Id__c =:filingId];
        List<UCC_Filing__c> lstUccFiling = [Select id from UCC_Filing__c  where Type__c != 'Amendments'];
        String filingId2  = (String)lstUccFiling[0].id;        
        System.assertEquals(1,lstUccFiling.size());              
        try{
            Test.startTest();
            brs_designateAuthorizer.updateAuthorizer(filingId,''+objRelatedInfo.id);
            brs_designateAuthorizer.getAuthorizers(filingId,'Amendments');
            brs_designateAuthorizer.updateAuthorizer(filingId,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }        
    } 
    
    @isTest
    static void getAuthorizersTest(){
        String filingId2  = (String)[Select id,Type__c from UCC_Filing__c  where Type__c = 'Information' Limit 1].id;        
        List<UCC_Related_Info__c> lstobjRelatedInfo = [SELECT Id, Name,Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c where Filing_Id__c =:filingId2];
        System.assertEquals(3,lstobjRelatedInfo.size());   
        UCC_Filing__c objFiling3  = new UCC_Filing__c(Type__c = 'Amendments');
        try{    
            Test.startTest();
            brs_designateAuthorizer.getAuthorizers(filingId2,'Amendments'); 
            brs_designateAuthorizer.getAuthorizers(objFiling3.id,'Amendments');  
            brs_designateAuthorizer.getAuthorizers(filingId2,'Vessel'); 
            lstobjRelatedInfo[0].Type__c = 'Judgment debtor'; 
            update lstobjRelatedInfo[0];
            brs_designateAuthorizer.getAuthorizers(filingId2,'Judgment - Personal Property');
            lstobjRelatedInfo[0].Type__c = 'Claimant'; 
            update lstobjRelatedInfo[0];
            brs_designateAuthorizer.getAuthorizers(filingId2,'Vessel');
            lstobjRelatedInfo[0].Type__c = System.Label.BRS_UCC_Judgment_Creditor; 
            update lstobjRelatedInfo[0];
            brs_designateAuthorizer.getAuthorizers(filingId2,'Judgment - Personal Property');
            lstobjRelatedInfo[0].Type__c = System.Label.Defendant; 
            update lstobjRelatedInfo[0];
            brs_designateAuthorizer.getAuthorizers(filingId2,'Judgment');
            lstobjRelatedInfo[0].Type__c = System.Label.Plaintiff; 
            update lstobjRelatedInfo[0];
            brs_designateAuthorizer.getAuthorizers(filingId2,'Judgment');
            Test.stopTest();             
        }catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }        
    }
}