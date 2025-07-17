/* DESCRIPTION: This is the test class for BRS_ReqCopyController
*
* @AUTHOR:  Himanshi Mayal
* @DATE:    5/25/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Himanshi Mayal                  5/25/2021                         Created the first version
*********************************************************************************************/
@isTest
public class BRS_ReqCopyControllerTest {
    @testSetup static void setup() {
        List<id> filingIds = new List<id>();
        Id businessRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        List<Account> lstAcc = new List<Account>();
        Account acc = new Account();
        acc.RecordTypeId = businessRecTypeId;
        acc.Name = 'Test,LTD.';
        //acc.Business_Type__c = 'Stock';
        //acc.Business_Sub_Type__c = 'Corporation';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        //acc.Citizenship__c = 'Domestic';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.Total_Authorized_Shares__c = 100;
        //acc.Business_End_Date__c = System.today().addDays(365);
        lstAcc.add(acc);
        
        Account acc2 = new Account();
        acc2.RecordTypeId = businessRecTypeId;
        acc2.Name = 'Test,LTD. UCC';
        //acc.Business_Type__c = 'Stock';
        //acc.Business_Sub_Type__c = 'Corporation';
        acc2.Business_Registration_ID__c = '1234';
        acc2.AccountNumber = '1234';
        //acc.Citizenship__c = 'Domestic';
        acc2.BillingStreet = 'Market St';
        acc2.BillingCity = 'San Francisco';
        acc2.BillingState = 'CA';
        acc2.BillingPostalCode = '9400';
        acc2.BillingCountry = 'US';
        acc2.Total_Authorized_Shares__c = 100;
        //acc.Business_End_Date__c = System.today().addDays(365);
        lstAcc.add(acc2);
        insert lstAcc;
        List<Contact> lstCon = new List<Contact>();
        Contact con1 = new Contact(FirstName = 'TestBusiness',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=acc.Id);
        lstCon.add(con1);
        Contact con2 = new Contact(FirstName = 'TestUCC',Allow_negative_balances__c=false, LastName='xyz',AccountId=acc2.Id);
        lstCon.add(con2);
        insert lstCon;       
        
        UCC_Lien__c lien=new UCC_Lien__c();
        lien=BRS_TestDataFactory.createUCCLien('OFS');
        
        Work_Order__c wo1=new Work_Order__c();
        List<Work_Order__c> lstWO=new List<Work_Order__c>();
        wo1=BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Email', 'Open');
        Work_Order__c wo2=new Work_Order__c();
        wo2=BRS_TestDataFactory.createWorkOrderObject(con2.id, 'Mail', 'completed');
        
        Payment_Method__c pm1 = new Payment_Method__c();
        pm1 = BRS_TestDataFactory.cardPaymentMethod(wo1.id);
        Payment_Method__c pm2 = new Payment_Method__c();
        pm2 = BRS_TestDataFactory.cardPaymentMethod(wo2.id);
        
        wo1.Payments_Verified__c = true;
        //lstWO.add(wo1);
        wo2.Payments_Verified__c = true;
        //lstWO.add(wo2);
        //update lstWO;
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        Id bFilingRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();        
        Business_Filing__c bfiling=new Business_Filing__c();
        bfiling=BRS_TestDataFactory.createBusinessFilingObject(String.ValueOf(bFilingRecTypeId), String.ValueOf(acc.id), String.valueOf(wo1.id), 'Change of Agent','Approved');
        
        Id uccFilingRecTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();
        System.debug('uccFilingRecTypeId -> '+uccFilingRecTypeId);
        UCC_Filing__c ufiling=new UCC_Filing__c();
        ufiling=BRS_TestDataFactory.createUCCFiling2('As a transmitting utility', String.ValueOf(uccFilingRecTypeId), 'Original Financing Statement', String.ValueOf(wo2.id), 'Approved', lien.id,'Amendment');
        
        Id bCertRecTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();        
        Id uCertRecTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('UCC Copy Request').getRecordTypeId(); 
        Id copyRequestUccFilingRecordTypeId = Schema.SObjectType.Copy_Request_Details__c.getRecordTypeInfosByName().get('UCC Filling Request').getRecordTypeId();       
        List<Certficate__c> lstCert = new List<Certficate__c>();
        Certficate__c cert1 = new Certficate__c();
        cert1 = BRS_TestDataFactory.createCertificate(String.valueOf(bCertRecTypeId), String.valueOf(acc.id), String.valueOf(wo1.id));
        cert1.Status__c='Approved';
        Certficate__c cert2 = new Certficate__c();
        cert2 = BRS_TestDataFactory.createCertificate(String.valueOf(uCertRecTypeId), String.valueOf(acc2.id), String.valueOf(wo2.id));
        cert2.Status__c='Approved';
        update cert1;
        update cert2;
        
        
        List<Copy_Request_Details__c> lstCopyReq = new List<Copy_Request_Details__c>();
        Copy_Request_Details__c copy1 = new Copy_Request_Details__c();
        copy1.Account__c = acc.id;
        copy1.Business_Filing__c = bfiling.id;
        copy1.Other_Request__c = cert1.id;
        lstCopyReq.add(copy1);
        Copy_Request_Details__c copy2 = new Copy_Request_Details__c();
        copy2.RecordTypeId=copyRequestUccFilingRecordTypeId;
        copy2.Account__c = acc2.id;
        copy2.UCC_Filing__c = ufiling.id;
        copy2.Other_Request__c = cert2.id;
        copy2.Number_of_Copies__c=1;
        copy2.Copy_Type__c='Plain'; 
        lstCopyReq.add(copy2);
        insert lstCopyReq;

        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;            
            
         List<ContentDocument> documentList = [Select Id, Title from ContentDocument ];
         System.assertEquals(documentList.size(),1);
   
		ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = bfiling.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
    }
    @isTest
    public static void getBusinessFilingsTest() {
        test.startTest();
        Account acc = [SELECT id, Name FROM Account LIMIT 1];
        BRS_ReqCopyController.filingDataAndIsDocAvailableWrap filingData = BRS_ReqCopyController.getBusinessFilings(acc.id);
        test.stopTest();
    }
    @isTest
    public static void getSelectedBusinessFilingsnotUCCTest() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Email' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        List <BRS_ReqCopyController.filingDataWrapper> filingData = BRS_ReqCopyController.getSelectedBusinessFilings(cert.id, false);
        test.stopTest();
    }
    @isTest
    public static void getSelectedBusinessFilingsUCCTest() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE 	Other_Request__c=:cert.id LIMIT 1];
        List <BRS_ReqCopyController.filingDataWrapper> filingData = BRS_ReqCopyController.getSelectedBusinessFilings(cert.id, true);
        test.stopTest();
    }
    @isTest
    public static void checkFilingNoTest() {
        test.startTest();
        UCC_Filing__c uFiling = [SELECT id, Filing_Number__c FROM UCC_Filing__c LIMIT 1];
        BRS_ReqCopyController.filingDataAndIsDocAvailableWrap  filing = BRS_ReqCopyController.checkFilingNo(String.valueOf(uFiling.Filing_Number__c), '', 1000);
        test.stopTest();
    }
    @isTest
    public static void getBusinessFiDocsBFilingTest() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Email' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        List<BRS_ReqCopyController.filingAttachWrapper> lstAtt = BRS_ReqCopyController.getBusinessFiDocs(cert.Id);
        test.stopTest();
    }
    @isTest
    public static void getBusinessFiDocsUCCFilingTest() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        List<BRS_ReqCopyController.filingAttachWrapper> lstAtt = BRS_ReqCopyController.getBusinessFiDocs(cert.Id);
        test.stopTest();
    }
    @isTest
    public static void createUCCCertificateRecords() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        Account acc = [SELECT id, Name FROM Account LIMIT 1];
        UCC_Filing__c bf = [SELECT id,Type__c,Filing_Date__c, Filing_Number__c FROM UCC_Filing__c LIMIT 1];

        Master_Fee__c masterfee=new Master_Fee__c();
       	masterfee.Amount__c=100;
        masterfee.Start_Date__c=system.today();
        masterfee.End_Date__c=system.today();
        masterfee.Filing_Type__c='Standard';
        masterfee.Status__c='Active';
        masterfee.External_ID__c='1234567891911111';
        masterfee.Service_Type__c='CertificateExpedite';
        insert masterfee;
        
        BRS_ReqCopyController.filingDataWrapper filingwrap= new BRS_ReqCopyController.filingDataWrapper();
        filingwrap.filingType=bf.Type__c;
        filingwrap.accId=acc.Id;
        filingwrap.amount=1000;
        filingwrap.certId=copy.Id;
        filingwrap.copyType=System.Label.Certified_Label;
        filingwrap.filingDate=String.valueOf(System.today());
        filingwrap.filingId=bf.Id;
        filingwrap.filingNo='1234';      
        String filingwrapString=JSON.serialize(new List<BRS_ReqCopyController.filingDataWrapper>{filingwrap});
        List<String> filingList=new List<String>();       
        
        //BRS_ReqCopyController.createCertificateRecords(filingwrapString,null, filingList,1000, true);
        try{
            BRS_ReqCopyController.createCertificateRecords(filingwrapString,cert.Id, new List<String>{bf.Id},1000, true,200);
        }catch(Exception e){
            System.debug('****test');
        }
        test.stopTest();
    }
    @isTest
    public static void createBusinessCertificateRecords() {
        test.startTest();
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        Account acc = [SELECT id, Name FROM Account LIMIT 1];
        Business_Filing__c bf = [SELECT id,Type__c,Filing_Date__c, Filing_Number__c FROM Business_Filing__c LIMIT 1];
        
        BRS_ReqCopyController.filingDataWrapper filingwrap= new BRS_ReqCopyController.filingDataWrapper();
        filingwrap.filingType=bf.Type__c;
        filingwrap.accId=acc.Id;
        filingwrap.amount=1000;
        filingwrap.certId=copy.Id;
        filingwrap.copyType=System.Label.Certified_Label;
        filingwrap.filingDate=String.valueOf(System.today());
        filingwrap.filingId=bf.Id;
        filingwrap.filingNo='1234';      
        String filingwrapString=JSON.serialize(new List<BRS_ReqCopyController.filingDataWrapper>{filingwrap});
        List<String> filingList=new List<String>();
        
        BRS_ReqCopyController.createCertificateRecords(filingwrapString,null, filingList,1000, false ,200);
        BRS_ReqCopyController.createCertificateRecords(filingwrapString,cert.Id, filingList,1000, false,200 );
        test.stopTest();
    }
    @isTest
    public static void businessSendEmail() {
        test.startTest();
        try {
        Work_Order__c workOrder = [SELECT id, Name FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1 ];
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Copy_Request_Details__c copy = [SELECT id, Name FROM Copy_Request_Details__c WHERE Other_Request__c=:cert.id LIMIT 1];
        Account acc = [SELECT id, Name FROM Account LIMIT 1];
        Business_Filing__c bf = [SELECT id,Type__c,Filing_Date__c, Filing_Number__c FROM Business_Filing__c LIMIT 1];
        
        BRS_ReqCopyController.copyRequestsInfo crInfo= new BRS_ReqCopyController.copyRequestsInfo();
        crInfo.workOrderID=cert.Id;
        crInfo.flowName=System.Label.Request_for_copy_comparable;
        crInfo.isUCC=false;
        crInfo.toAddress='test@test.com';
         crInfo.attachDocs=true;
        crInfo.loggedInUserName=UserInfo.getUserId();
        BRS_ReqCopyController.sendemail(new List<BRS_ReqCopyController.copyRequestsInfo>{crInfo});
          crInfo.flowName='Test';
         BRS_ReqCopyController.sendemail(new List<BRS_ReqCopyController.copyRequestsInfo>{crInfo});
        test.stopTest();
        } catch (Exception ex) {}
    }
    @isTest
    public static void getAttachmentsInformation() {
        
        Account acc = [select id,Name from Account Limit 1];
        Contact con = [select id,Email from contact where Email != Null and AccountId =:acc.id Limit 1];
        
        set<Id> certIds=new set<Id>();
        Work_Order__c workOrder = [SELECT id, Name,Customer__c FROM Work_Order__c WHERE Source__c='Mail' LIMIT 1 ];
        workOrder.Customer__c = con.id;
        test.startTest();
        update workOrder;
        Certficate__c cert = [SELECT id FROM Certficate__c WHERE Work_Order__c =:workOrder.id LIMIT 1];
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob1;
        attach.parentId=cert.id;
        insert attach;
        certIds.add(cert.id);
        BRS_ReqCopyController.getAttachments(certIds); 
        
        BRS_ReqCopyController.copyRequestsInfo crInfo= new BRS_ReqCopyController.copyRequestsInfo();
        crInfo.workOrderID=cert.Id;
        crInfo.flowName=System.Label.Request_for_copy_comparable;
        crInfo.isUCC=false;
        crInfo.toAddress='test@test.com';
         crInfo.attachDocs=true;
        crInfo.loggedInUserName=UserInfo.getUserId();
        BRS_ReqCopyController.sendemail(new List<BRS_ReqCopyController.copyRequestsInfo>{crInfo});
        test.stopTest();
    }
}