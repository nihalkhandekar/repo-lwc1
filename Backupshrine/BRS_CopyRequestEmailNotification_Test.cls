@isTest
public with sharing class BRS_CopyRequestEmailNotification_Test {

    @TestSetup
    static void dataSetup(){
        Id businessCopyRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();
        Id tradeCopyRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Trade & Service Mark Copy Request').getRecordTypeId();
        Id uccCopyRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('UCC Copy Request').getRecordTypeId();
        Id ureqinfoRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Request for Information').getRecordTypeId();
        Id rearchmarkRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Request for Search of Mark').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Stock',Franchise_Tax__c=200, Business_Email_Address__c = 'testbussinessemail@gmail.com',Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2 );
        insert acc;
        Account acc1 = new Account(Name = 'Test Account 111',Citizenship__c = 'Domestic', Business_Type__c = 'Stock',Franchise_Tax__c=200, Business_Email_Address__c = 'testbussinessemail@gmail.com',Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2 );
        insert acc1;
        Contact con=new Contact();
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact123';
        con1.Email = 'testConBrfdsasaqws@test.com';
        //if(acc1.id!='')
        con1.AccountId = acc1.id;
        insert con1;
        con=BRS_TestDataFactory.createContactObject(acc.id);
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1 = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Email', 'Open');
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        update workOrder1;

        Work_Order__c workOrder2 = new Work_Order__c();
        workOrder2 = BRS_TestDataFactory.createWorkOrderObject(con1.Id, 'Email', 'Open');
        workOrder2.Received_Date__c = System.Now();
        workOrder2.Completed_Date__c = System.Today();
        update workOrder2;

        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();

        Business_Filing__c bfc = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id, Source__c = System.Label.brs_FilingOnline);
        insert bfc;

        UCC_Lien__c lien = BRS_TestDataFactory.createUCCLien('OFS');

        UCC_Filing__c uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable', 'Approved', lien.Id, 'OFS');

        Mark_Filing__c markFiling = new Mark_Filing__c();
        markFiling.Work_Order__c = workOrder1.Id;
        insert markFiling;

        Certficate__c cert1 = BRS_TestDataFactory.createCertificate(businessCopyRecordType,acc.Id,workOrder1.Id);
        Certficate__c cert2 = BRS_TestDataFactory.createCertificate(uccCopyRecordType,null,workOrder1.Id);
        Certficate__c cert3 = BRS_TestDataFactory.createCertificate(tradeCopyRecordType,null,workOrder1.Id);
        Certficate__c cert4 = BRS_TestDataFactory.createCertificate(tradeCopyRecordType,null,workOrder1.Id);
        Certficate__c cert5 = BRS_TestDataFactory.createCertificate(ureqinfoRecordType,null,workOrder2.Id);
        Certficate__c cert6 = BRS_TestDataFactory.createCertificate(rearchmarkRecordType,null,workOrder2.Id);
        Certficate__c cert7 = BRS_TestDataFactory.createCertificate(rearchmarkRecordType,null,workOrder2.Id);
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attach1=new Attachment();   	
        attach1.Name= System.Label.Acceptance_N_Comparable;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob;
        attach1.ParentId=cert1.id;
        attachmentList.add(attach1);

        Attachment attach2=new Attachment();   	
        attach2.Name= System.Label.Acceptance_N_Comparable;
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach2.body=bodyBlob2;
        attach2.ParentId=cert2.id;
        attachmentList.add(attach2);

        Attachment attach3=new Attachment();   	
        attach3.Name= System.Label.Acceptance_N_Comparable;
        Blob bodyBlob3=Blob.valueOf('Unit Test Attachment Body');
        attach3.body=bodyBlob3;
        attach3.ParentId=cert3.id;
        attachmentList.add(attach3);
        insert attachmentList;

        List<Copy_Request_Details__c> copyDetailsList = new List<Copy_Request_Details__c>();
        Copy_Request_Details__c copyDetails11 = new Copy_Request_Details__c();
        copyDetails11.Account__c=acc.Id;
        copyDetails11.Other_Request__c=cert1.Id;
        copyDetails11.Business_Filing__c=bfc.Id;
        copyDetails11.Number_of_Copies__c=1;
        copyDetails11.Copy_Type__c='Plain';
        copyDetailsList.add(copyDetails11);

        Copy_Request_Details__c copyDetails12 = new Copy_Request_Details__c();
        copyDetails12.Account__c=acc.Id;
        copyDetails12.Other_Request__c=cert1.Id;
        copyDetails12.Business_Filing__c=bfc.Id;
        copyDetails12.Number_of_Copies__c=1;
        copyDetails12.Copy_Type__c='Certified';
        copyDetailsList.add(copyDetails12);

        Copy_Request_Details__c copyDetails21 = new Copy_Request_Details__c();
        copyDetails21.Other_Request__c=cert2.Id;
        copyDetails21.UCC_Filing__c=uccFiling.Id;
        copyDetails21.Number_of_Copies__c=1;
        copyDetails21.Copy_Type__c='Plain';
        copyDetailsList.add(copyDetails21);

        Copy_Request_Details__c copyDetails22 = new Copy_Request_Details__c();
        copyDetails22.Other_Request__c=cert2.Id;
        copyDetails22.UCC_Filing__c=uccFiling.Id;
        copyDetails22.Number_of_Copies__c=1;
        copyDetails22.Copy_Type__c='Certified';
        copyDetailsList.add(copyDetails22);

        Copy_Request_Details__c copyDetails31 = new Copy_Request_Details__c();
        copyDetails31.Other_Request__c=cert3.Id;
        copyDetails31.Mark_Filing__c=markFiling.Id;
        copyDetails31.Number_of_Copies__c=1;
        copyDetails31.Copy_Type__c='Plain';
        copyDetailsList.add(copyDetails31);

        Copy_Request_Details__c copyDetails32 = new Copy_Request_Details__c();
        copyDetails32.Other_Request__c=cert3.Id;
        copyDetails32.Mark_Filing__c=markFiling.Id;
        copyDetails32.Number_of_Copies__c=1;
        copyDetails32.Copy_Type__c='Certified';
        copyDetailsList.add(copyDetails32);
        insert copyDetailsList;

        List<Certficate__c> certList = new List<Certficate__c>();
        cert1.Status__c = 'Approved';
        certList.add(cert1);

        cert2.Status__c = 'Approved';
        certList.add(cert2);

        cert3.Status__c = 'Approved';
        certList.add(cert3);
        update certList;

        cert4.Status__c = 'Rejected';
        certList.add(cert4);
        update certList;

        cert5.Status__c = 'Approved';
        certList.add(cert5);
        update certList;

        cert6.Status__c = 'Approved';
        certList.add(cert6);
        update certList;

        cert7.Status__c = 'Rejected';
        certList.add(cert7);
        update certList;
    }

    @isTest
    public static void sendCopyRequestEmail() {

        Test.startTest();
        List<Certficate__c> otherReqList = [select Id,Status__c, Work_Order__r.Customer__r.Name, Work_Order__r.Customer__r.Email,
        (select Id,Number_of_Copies__c, Business_Filing__c,Filing_Number__c, Copy_Type__c, Mark_Filing__c,Mark_Filing_Number__c, UCC_Filing__c,UCC_Filing_Number__c from Copy_Request_Details__r) 
        from Certficate__c];

        BRS_CopyRequestEmailNotification.RequestsInfo req1= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req1.otherReq =otherReqList[0];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList1=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList1.add(req1);

        BRS_CopyRequestEmailNotification.RequestsInfo req2= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req2.otherReq =otherReqList[1];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList2=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList2.add(req2);

        BRS_CopyRequestEmailNotification.RequestsInfo req3= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req3.otherReq =otherReqList[2];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList3=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList3.add(req3);

        BRS_CopyRequestEmailNotification.RequestsInfo req4= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req4.otherReq =otherReqList[3];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList4=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList4.add(req4);

        BRS_CopyRequestEmailNotification.RequestsInfo req5= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req5.otherReq =otherReqList[4];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList5=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList5.add(req5);

        BRS_CopyRequestEmailNotification.RequestsInfo req6= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req6.otherReq =otherReqList[5];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList6=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList6.add(req6);

        BRS_CopyRequestEmailNotification.RequestsInfo req7= new BRS_CopyRequestEmailNotification.RequestsInfo();
        req7.otherReq =otherReqList[6];   
        list<BRS_CopyRequestEmailNotification.RequestsInfo> reqList7=new list<BRS_CopyRequestEmailNotification.RequestsInfo>();
        reqList7.add(req7);
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlobgg=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlobgg; 
        //content.FirstPublishLocationId =kw2.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=otherReqList[5].id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink; 
        
        

        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attach1=new Attachment();   	
        attach1.Name= 'Test jhghgj';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob;
        attach1.ContentType = 'application/pdf';
        attach1.ParentId=otherReqList[0].Copy_Request_Details__r[0].Business_Filing__c;
        attachmentList.add(attach1);
        insert attachmentList;

        
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList1);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList2);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList3);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList4);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList5);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList6);
        BRS_CopyRequestEmailNotification.sendCopyRequestEmail(reqList7);
        Test.stopTest();
    }
}