@isTest
public class brs_UCCCloneForResubmissionClassTest {
    
    @isTest
    static void CloneRecordsTest(){
        Account acc=BRS_TestDataFactory.createAccountObject();
        Contact con=BRS_TestDataFactory.createContactObject('');
        Work_Order__c workOrd=BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c busFiling=BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId,acc.id,workOrd.Id,'Business Formation','Approved');
        brs_UCCCloneForResubmissionClass.RequestCls req=new  brs_UCCCloneForResubmissionClass.RequestCls();
        req.filingId=busFiling.Id;
        List<brs_UCCCloneForResubmissionClass.RequestCls> reqList=new List<brs_UCCCloneForResubmissionClass.RequestCls>{req};
            brs_UCCCloneForResubmissionClass.CloneRecords(reqList);
        //brs_UCCCloneForResubmissionClass.cloneUCCFilingWithRelatedrecords(reqList);
    }
    @isTest static void CloneUCCRecordsTest(){
        Account acc=BRS_TestDataFactory.createAccountObject();
        Contact con=BRS_TestDataFactory.createContactObject('');
        Work_Order__c workOrd=BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c();      
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress', uccLien.Id,'');
        BRS_TestDataFactory.createUCCRelatedObject('', uccFiling.Id);
        brs_UCCCloneForResubmissionClass.RequestCls req=new  brs_UCCCloneForResubmissionClass.RequestCls();
        req.filingId=uccFiling.Id;
        List<brs_UCCCloneForResubmissionClass.RequestCls> reqList=new List<brs_UCCCloneForResubmissionClass.RequestCls>{req};
            brs_UCCCloneForResubmissionClass.CloneRecords(reqList);
      //  brs_UCCCloneForResubmissionClass.cloneUCCFilingWithRelatedrecords(reqList);
        
    }
}