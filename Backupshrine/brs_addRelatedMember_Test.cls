@isTest
private class brs_addRelatedMember_Test {
    
    @testSetup 
    static void setup() {
        
        List<UCC_Related_Info__c> relatedInfo=new List<UCC_Related_Info__c>();
        relatedInfo = BRS_TestDataFactory.createListUCCRelatedInfoObject();      
        UCC_Lien__c uccLien=new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien('OFS');
        
    }
    
    @isTest
    static void insertUccRelatedInforTest1(){ 
        
        List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        lstRelatedInfo = [SELECT Type__c,State__c FROM UCC_Related_Info__c];
        ID uccLienId = [SELECT Id,Name__c from UCC_Lien__c].id;
        
        System.assertEquals(3,lstRelatedInfo.size()); 
        
        Test.startTest(); 
        try{
            
            brs_addRelatedMember.insertUccRelatedInfor(lstRelatedInfo,''+uccLienId,'Upsert',''+null,'Debtor',true);
            brs_addRelatedMember.insertUccRelatedInfor(lstRelatedInfo,''+uccLienId,'Delete',''+null,'Assignor',true);
            brs_addRelatedMember.insertUccRelatedInfor(lstRelatedInfo,''+uccLienId,'Insert',''+null,'Debtor',true);            
            
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void insertUccRelatedInforTest2(){
        
        List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        lstRelatedInfo = [SELECT Type__c,State__c FROM UCC_Related_Info__c];
        ID uccLienId = [SELECT Id,Name__c from UCC_Lien__c].id;
        
        System.assertEquals(3,lstRelatedInfo.size()); 
        
        Test.startTest(); 
        try{ 
            brs_addRelatedMember.insertUccRelatedInfor(lstRelatedInfo,''+uccLienId,'Upsert',''+null,'Debtor',false);
            brs_addRelatedMember.insertUccRelatedInfor(lstRelatedInfo,''+uccLienId,'Upsert',''+null,'Debtor',null);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    
    @isTest
    static void getdebtorSecuredRecordsTest(){
        ID uccLienId = [SELECT Id,Name__c from UCC_Lien__c].id;
        List<UCC_Lien__c> lstUccLien = [SELECT Id,Name__c from UCC_Lien__c];        
        System.assertEquals(1,lstUccLien.size());        
        Test.startTest();
        try{
            brs_addRelatedMember.getdebtorSecuredRecords(''+uccLienId,'');
             brs_addRelatedMember.getdebtorSecuredRecords(''+uccLienId,System.label.JudgmentPersonalPropertyLabel);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void deleteContacts(){
        ID uccLienId = [SELECT Id,Name__c from UCC_Lien__c].id;
        String uccLienID1=uccLienId;
        String action='hi';
        String idToDelete=uccLienId;
        String lienType='hi';
        Boolean isAmendment=True;
        Test.startTest();
        try{
        brs_addRelatedMember.deleteContacts(uccLienID1, action, idToDelete, lienType, isAmendment);
        } catch(Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
        
    }
}