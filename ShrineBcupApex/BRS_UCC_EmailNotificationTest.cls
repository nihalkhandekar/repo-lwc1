@isTest
public class BRS_UCC_EmailNotificationTest {
    
    @isTest
    static void upsertStockRecordsTest() {
     Account acc = new Account();
     acc = BRS_TestDataFactory.createAccountObject();     
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'Email','Open');
        ContentVersion objContVer = new ContentVersion();
		objContVer= BRS_TestDataFactory.contentVersionData();       
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContVer.Id].ContentDocumentId;
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting=BRS_TestDataFactory.onOffCustomSetting();
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling=BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder.id,'Rejected',uccLien.id,'OFS');
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe=BRS_TestDataFactory.contentDocumentLinkData(conDoc,uccFiling.id);
        uccFiling.Status__c = 'Rejected';
        update uccFiling;
        String myString = 'UHl0aG9u';
        Blob myBlob = Blob.valueof(myString);
        List<Attachment> attachedFiles = new List<Attachment>();
        Attachment newat1 = new Attachment(ParentId=uccFiling.Id, Name=System.Label.Acceptance_N_Comparable, Body=myBlob);
        attachedFiles.add(newat1);
        insert attachedFiles;
        List<BRS_UCC_EmailNotification.Requests> requestList=new List<BRS_UCC_EmailNotification.Requests>();
        BRS_UCC_EmailNotification.Requests Request= new BRS_UCC_EmailNotification.Requests();
        Request.filingRec=uccFiling;
        requestList.add(Request);
        BRS_UCC_EmailNotification.sendUCCEmail(requestList);
    }

}