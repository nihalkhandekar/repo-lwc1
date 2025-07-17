@isTest
public class BRSBusinessFilingEmailNotification_Test {   
    
    @isTest
     static void sendBusinessFilingEmailTestStatusApproved() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Stock',Franchise_Tax__c=200, 
        Business_Email_Address__c = 'testbussinessemail@gmail.com',Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2,
        BillingStreet='123',BillingState='CT',BillingCity='Test',BillingCountry='United States',BillingPostalCode='12345',
        ShippingStreet='123',ShippingState='CT',ShippingCity='Test',ShippingCountry='United States',ShippingPostalCode='12345' );
        insert acc;
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1 = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Email', 'Open');
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        update workOrder1; 
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id, Source__c = System.Label.brs_FilingOnline);
        insert bfc;
        Business_Filing__c bfc2 = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id,Type__c = System.Label.Agent_Resignation_Label,Filing_Type__c=System.Label.Agent_Resignation_Label,RecordTypeId=RecordTypeIdMaintenance);
        insert bfc2;
         id businessid=bfc2.id;
        List<Business_Filing__c> buslistdata=[select id,Sdoc_Filing_Number__c,name,Filing_Number__c,Filing_Type__c from Business_Filing__c where id=: businessid limit 1];
        Attachment attach=new Attachment();   	
        attach.Name= buslistdata[0].Sdoc_Filing_Number__c + ' - ' + System.Label.BRS_Acceptance_Notice + System.Label.PDF_Type_Extension;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.ParentId=bfc2.id;
        insert attach;
        BRSBusinessFilingEmailNotification.RequestsInfo req= new BRSBusinessFilingEmailNotification.RequestsInfo();
        req.businessFilingRec =bfc;   
        list<BRSBusinessFilingEmailNotification.RequestsInfo> reqList=new list<BRSBusinessFilingEmailNotification.RequestsInfo>();
        reqList.add(req);
         test.startTest();
        BRSBusinessFilingEmailNotification.sendBusinessFilingEmail(reqList);
         test.stopTest();
    } 
   
        
    @isTest(SeeAllData= false)
    private static void sendBusinessFilingEmailTestStatusApprovedAR() {
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
         Account acc = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Religious',Franchise_Tax__c=200,
         BillingStreet='123',BillingState='CT',BillingCity='Test',BillingCountry='United States',BillingPostalCode='12345',
        ShippingStreet='123',ShippingState='CT',ShippingCity='Test',ShippingCountry='United States',ShippingPostalCode='12345');
        insert acc;
        Business_Filing__c bfc2 = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id,Type__c = System.Label.Agent_Resignation_Label,Filing_Type__c=System.Label.Agent_Resignation_Label,RecordTypeId=RecordTypeIdMaintenance);
        lstBusFil.add(bfc2);
        insert  lstBusFil;     
        BRSBusinessFilingEmailNotification.RequestsInfo req= new BRSBusinessFilingEmailNotification.RequestsInfo();
        req.businessFilingRec =bfc2; 
        id businessid=bfc2.id;
        List<Business_Filing__c> buslistdata=[select id,Sdoc_Filing_Number__c,name,Filing_Number__c,Filing_Type__c,Type__c from Business_Filing__c where id=: businessid limit 1];
        String myString = 'UHl0aG9u';
        Blob myBlob = Blob.valueof(myString);
        List<Attachment> attachedFiles = new List<Attachment>();
        Attachment att1 = new Attachment(ParentId=businessid, Name=System.Label.brs_RejectionNotice + System.Label.PDF_Type_Extension, Body=myBlob);
        attachedFiles.add(att1);
        insert attachedFiles;
        Blob bodyBlob=Blob.valueOf('Test blob');
        String filename=null + ' - ' + buslistdata[0].Type__c;
        ContentVersion cv = new ContentVersion(Title=filename , PathOnClient=filename+'.pdf',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = buslistdata[0].Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        list<BRSBusinessFilingEmailNotification.RequestsInfo> reqList=new list<BRSBusinessFilingEmailNotification.RequestsInfo>();
        reqList.add(req);
        test.startTest();
        BRSBusinessFilingEmailNotification.sendBusinessFilingEmail(reqList); 
        test.stopTest();
        
    }
    
    @isTest(SeeAllData= false)
    private static void getEmailAttachmentsTest()   {
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        String myString = 'UHl0aG9u';
        Blob myBlob = Blob.valueof(myString);
        List<Attachment> attachedFiles = new List<Attachment>();
        Attachment att1 = new Attachment(ParentId=filing.Id, Name=System.Label.Acceptance_N_Comparable, Body=myBlob);
        attachedFiles.add(att1);
        insert attachedFiles;
        Messaging.EmailFileAttachment mEmAtt = new Messaging.EmailFileAttachment();
        mEmAtt.body = myBlob;
        //mEmAtt.Id = attachedFiles[0].Id;
        mEmAtt.filename = 'Test';
        test.startTest();
        BRSBusinessFilingEmailNotification.getEmailAttachments(filing.id,'Test');
        Action_Item__c ActItem1 = new Action_Item__c(Action_Item_Name__c = System.Label.ActionItem_AnnualReportName,Account__c = acc.Id,Status__c = System.Label.ActionItem_StatusOpen,Contact__c = con.Id);
        insert ActItem1;
        brs_ActionItemDuplicatesDeletion da=new brs_ActionItemDuplicatesDeletion();
        Database.executeBatch(da,10);
        test.stopTest();
        
    }
    
  }