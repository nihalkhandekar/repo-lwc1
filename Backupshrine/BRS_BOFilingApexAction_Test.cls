@isTest
public class BRS_BOFilingApexAction_Test {
    testmethod static void test1() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
    	BRS_BOFilingApexAction.Input input1 = new  BRS_BOFilingApexAction.Input();
        input1.filing=filing;
        List<BRS_BOFilingApexAction.Input> lstInputs = new List<BRS_BOFilingApexAction.Input>();
        lstInputs.add(input1);
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv; 
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink(LinkedEntityId = filing.Id,ContentDocumentId = cv2.ContentDocumentId,ShareType = 'V');
        insert contentLink;
        
        test.startTest();
        BRS_BOFilingApexAction.boFilingApexAction(lstInputs);
        test.stopTest();
    }
}