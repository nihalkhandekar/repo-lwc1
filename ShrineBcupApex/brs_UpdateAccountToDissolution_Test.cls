@isTest
public class brs_UpdateAccountToDissolution_Test {
    @TestSetup
    public static void testdata() {
        Account acc = BRS_TestDataFactory.createAccountObject();
    }
    
    testMethod static void testmethod1() {
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Sub_Status__c=System.label.Annual_report_past_due_Comparable;
        update acc;
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        Database.BatchableContext BC;
        SchedulableContext SC;
        
        test.startTest();
        brs_UpdateAccountToDissolution batch = new  brs_UpdateAccountToDissolution();
        batch.start(BC);
        batch.execute(BC, lstacc);
        batch.finish(BC);
        batch.execute(SC);
        test.stopTest();
    }
    testMethod static void testmethodUpdateAccountToDissolutionTest() {
       // Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.Citizenship__c='Domestic';
        acc1.Business_Type__c='LLP';
        acc1.ClientAccountNum__c='12345';
        acc1.Purpose_of_Business__c = 'Test business run';
        acc1.Status__c='Active';
        acc1.Sub_Status__c=System.label.Annual_report_past_due_Comparable;
        acc1.Status_changed_on__c = system.now().addDays(-390);
        acc1.Annual_Report_Due_Date__c=system.today().addDays(-390);
        insert acc1;  
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc1);
        Database.BatchableContext BC;
        SchedulableContext SC;
        
        test.startTest();
        brs_UpdateAccountToDissolution batch = new  brs_UpdateAccountToDissolution();
        batch.start(BC);
        batch.execute(BC, lstacc);
        batch.finish(BC);
        batch.execute(SC);
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        acc.BillingCity='India';
        acc.BillingState='AP';
        acc.BillingPostalCode='12345';
        update acc;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert(attachment);
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = bf.ID;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch1(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        acc.ShippingStreet='No Information Provided';
        acc.ShippingCity='USA';
        acc.ShippingState='Dp';
        acc.ShippingPostalCode='12345';
        update acc;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch2(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_1__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        agent.Residence_Street_Address_2__c='sa';
        agent.Residence_Street_Address_3__c='in';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_3__c='';
        update agent;
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_2__c='';
        update agent;
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_1__c='';
        update agent;
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch3(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_City__c = 'CT';
        agent.Business_State__c = 'CT';
        agent.Business_Country__c = 'United States';
        agent.Business_Street_Address_1__c = 'street address1';
        agent.Business_Zip_Code__c= '45367';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch4(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Mailing_Street_Address_3__c='Test';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());     
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch5(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_1__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_3__c='Test';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());       
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch6(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_2__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch7(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_3__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch5_2(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_1__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_3__c='Test';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_2__c='Test';
        agent.Residence_Street_Address_3__c='';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());         
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch5_3(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_1__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Residence_Street_Address_2__c='Test';
        agent.Residence_Street_Address_3__c='Test';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch5_4(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Residence_Street_Address_1__c='inside';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Residence_State__c='CT';
        agent.Residence_City__c='USA';
        agent.Residence_Zip_Code__c='12345';
        
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());       
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch4_2(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch4_3(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        agent.Mailing_Street_Address_2__c='Test';
        agent.Mailing_Street_Address_3__c='Test';
        update agent;
         Database.executeBatch(new brs_UpdateDissolutionAddressBatch()); 
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch4_4(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
     @isTest static void testAdminDissolutionAddressBatch4_5(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_InternationalAddress__c='business international address';
        agent.Business_Country__c='United States';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
         agent.Mailing_Street_Address_2__c='Test';
        update agent;
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch3_2(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_City__c = 'CT';
        agent.Business_State__c = 'CT';
        agent.Business_Country__c = 'United States';
        agent.Business_Street_Address_1__c = 'street address1';
        agent.Business_Street_Address_2__c = 'street address1';
        agent.Business_Street_Address_3__c = 'street address1';
        agent.Business_Zip_Code__c= '45367';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch3_3(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_City__c = 'CT';
        agent.Business_State__c = 'CT';
        agent.Business_Country__c = 'United States';
        agent.Business_Street_Address_1__c = 'street address1';
        agent.Business_Street_Address_2__c = 'street address1';
        agent.Business_Zip_Code__c= '45367';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
    @isTest static void testAdminDissolutionAddressBatch3_4(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(System.Label.CloseReinstateLabel).getRecordTypeId();
        Account acc = [select id, Name, Days_passed_since_sub_status_changed__c,Sub_Status__c from account limit 1];
        acc.Status__c='Forfeited';
        acc.BillingStreet='No Information Provided';
        update acc;
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.id;
        agent.Agent_Account_ID__c=acc.id;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_City__c = 'CT';
        agent.Business_State__c = 'CT';
        agent.Business_Country__c = 'United States';
        agent.Business_Street_Address_1__c = 'street address1';
        agent.Business_Street_Address_3__c = 'street address1';
        agent.Business_Zip_Code__c= '45367';
        insert agent;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = RecordTypeIdMaintenance,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = System.Label.Administrative_Dissolution_Label,
            Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label,
            Filing_Date__c = System.today(),
            Date_Intend_Notice__c = System.today(),
            Date_Intend_Forfeited__c = System.today().addDays(Integer.valueOf(System.Label.Administrative_Dissolution_Label_1))
        );
        insert bf;
        test.startTest();
        Database.executeBatch(new brs_UpdateDissolutionAddressBatch());
        test.stopTest();
    }
}