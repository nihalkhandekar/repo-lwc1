@isTest
public class ContentDocumentLinkTriggerHelper_Test {
@TestSetup
    static void testsetup() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        UCC_Lien__c lien= BRS_TestDataFactory.createUCCLien('OFS');
        UCC_Filing__c objFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','Approved',lien.Id,'Amendments');
        Business_Filing__c businessfiling = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance, acc.Id, workorder.Id, 'Amendment', 'Approved');
    	Id RecordTypeIdCert = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Certficate__c cert = BRS_TestDataFactory.createCertificate(RecordTypeIdCert, acc.Id, WorkOrder.Id);
    }
    
    testMethod static void updateDocType(){
        Business_Filing__c businessfiling = [select id from business_filing__c limit 1];
		UCC_Filing__c uccfiling = [select id from ucc_filing__c limit 1];   
        Certficate__c cert = [select id from Certficate__c limit 1];
        
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = businessfiling.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        
        ContentDocumentLink contentLink1 = new ContentDocumentLink();
        contentLink1.LinkedEntityId = uccfiling.Id;
        contentLink1.ContentDocumentId = cv2.ContentDocumentId;
        contentLink1.ShareType = 'V';
        insert contentLink1;
        
        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.LinkedEntityId = cert.Id;
        contentLink2.ContentDocumentId = cv2.ContentDocumentId;
        contentLink2.ShareType = 'V';
        insert contentLink2;
        
        List<ContentDocumentLink> lstcondoclink1 = new List<ContentDocumentLink>();
        lstcondoclink1.add(contentLink);
        lstcondoclink1.add(contentLink1);
        lstcondoclink1.add(contentLink2);
        
        test.startTest();
       ContentDocumentLinkTriggerHelper.updateDocType(lstcondoclink1);
        test.stopTest();
    }
    
    testmethod static void ContentDocumentLinkHandler() {
        Account acc  = [select id from Account limit 1];
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        Map<Id,Account> oldItems = new Map<Id,Account>();
        oldItems.put(acc.Id,acc);
        test.startTest();
        ContentDocumentLinkHandler ch = new ContentDocumentLinkHandler();
        ch.beforeDelete(lstacc,oldItems);
        ch.beforeUpdate(oldItems,oldItems);
        ch.afterUpdate(oldItems,oldItems);
        ch.afterDelete(oldItems);
        ch.afterUndelete(lstacc,oldItems);
        test.stopTest();
    }
}