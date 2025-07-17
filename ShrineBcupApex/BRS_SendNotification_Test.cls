@isTest
public class BRS_SendNotification_Test {
    
    @testSetup static void setup(){        
        Account acc1 = new Account(Name = 'Test Account',Citizenship__c = 'Foreign', Business_Type__c = 'LLC',Franchise_Tax__c=200, Mailing_International_Address__c = 'Mailing address', Began_Transacting_in_CT__c = system.today() , Date_of_Formation__c = system.today(), Business_Name_in_state_country__c = 'test business name', Country_Formation__c = 'USA');
        insert acc1;
        Contact con1 = new Contact(FirstName = 'Test',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=acc1.Id);
        insert con1;
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
    }
    
    @isTest
    static void getBusinessWithFilingTest(){
        Work_Order__c workOrder = [Select id from Work_Order__c where Status__c='Completed'];
        Account acc1 = [Select id from Account where Name = 'Test Account'];
        Certficate__c cert = new Certficate__c();
        cert.Business__c = acc1.Id;
        cert.Work_Order__c = WorkOrder.Id;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        insert cert;
        String encodedContentsString='Test Data';
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('test.pdf');
        attachment.ParentId = cert.id; 
        insert attachment;
        
        BRS_SendNotification.Requests req = new BRS_SendNotification.Requests();
        list<BRS_SendNotification.Requests> lstReq = new list<BRS_SendNotification.Requests>();
        req.accId = acc1.id;
        req.workOrderId = workOrder.id;
        lstReq.add(req);
        
        string[] to = new string[] {};
        string businessName;
        String body = system.label.BRS_Obtian_cert_internal_table_header;
        
        Map<Id,Certficate__c> certificateMap = new Map<Id,Certficate__c>();
        
        List<Attachment> docs = [SELECT Id, Name, Body, ContentType 
                            FROM Attachment 
                            WHERE parentId =: certificateMap.keyset()];
        
        List<Messaging.EmailFileAttachment> listAttach = new List<Messaging.EmailFileAttachment>();
            for(Attachment doc: docs){
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType(doc.ContentType);
                    attach.setFileName(doc.Name);
                    attach.setInline(false);
                    attach.Body = doc.Body;
                listAttach.add(attach);
            }
        string firstRow = system.label.BRS_Obtian_cert_internal_table_row.replace(system.label.BRS_Obtian_cert_internal_table_row_type,cert.Certificate_Type__c);
        
        test.startTest();
        BRS_SendNotification.sendemail(lstReq);
        test.stopTest();
    }
    
}