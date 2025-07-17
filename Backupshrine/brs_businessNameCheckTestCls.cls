@isTest
public class brs_businessNameCheckTestCls {
    @testSetup 
    static void setup() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestClassAcct'+i, Status__c = 'Active', Account_Name_Without_Designators__c = 'TESTCLASSACCT'+i,Citizenship__c = 'Domestic', Business_Type__c = 'Religious'));
        }
        insert testAccts;
    }
    
    @isTest
    static void checkDuplicateAccNameTest() {
        Account accId  = [Select id,name,Account_Name_Without_Designators__c from Account where name='TestClassAcct0' Limit 1];
        Contact con1 = BRS_TestDataFactory.createContactObject(accId.Id);
        Work_Order__c workorder1 = BRS_TestDataFactory.createWorkOrderObject(con1.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();   
        Business_Filing__c filing1 = BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId, accId.id, workorder1.Id, system.label.Name_Change_Amendment, system.label.Submitted_Agency_review_pending);
		Temp_History__c temprec1 = BRS_TestDataFactory.createTempHistoryObject();
        temprec1.Account__c=accId.Id;
        temprec1.Business_Filing__c=filing1.Id;
        temprec1.BusinessName_New_Without_Designators__c=accId.Account_Name_Without_Designators__c;
        update temprec1;
        
        Test.startTest();
        brs_businessNameCheck.checkDuplicateAccName('TestClassAcct0', accId.Id);
        Boolean checkifAvailable1 = brs_businessNameCheck.checkDuplicateAccName('TestClassAcct1 # Co.', accId.id);
        Boolean checkifAvailable2 = brs_businessNameCheck.checkDuplicateAccName('TestClassAcctCheck', accId.id);
        Boolean checkifAvailable3;
        Boolean checkifAvailable4;
        try {
            delete accId;
            checkifAvailable3 = brs_businessNameCheck.checkDuplicateAccName('TestClassAcct1', accId.Id);
            checkifAvailable4 = brs_businessNameCheck.checkDuplicateAccName('TestClass', null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void checkDuplicateAccNameTest1() {
        Account accId1  = [Select id,name,Account_Name_Without_Designators__c from Account where name='TestClassAcct0' Limit 1];
        Contact con1 = BRS_TestDataFactory.createContactObject(accId1.Id);
        Work_Order__c workorder1 = BRS_TestDataFactory.createWorkOrderObject(con1.Id, 'Online', 'Completed');
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();   
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing1 = BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId, accId1.id, workorder1.Id, system.label.Name_Change_Amendment, system.label.Submitted_Agency_review_pending);

        Test.startTest();
        Boolean checkifAvailable;
        try {
            checkifAvailable = brs_businessNameCheck.checkDuplicateAccName('TestClass', null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void checkBusNameContainsKeywords() {
        Account accId1  = [Select id,name,Account_Name_Without_Designators__c from Account where name='TestClassAcct0' Limit 1];
        Contact con1 = BRS_TestDataFactory.createContactObject(accId1.Id);
        Work_Order__c workorder1 = BRS_TestDataFactory.createWorkOrderObject(con1.Id, 'Online', 'Completed');
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();   
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing1 = BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId, accId1.id, workorder1.Id, system.label.Name_Change_Amendment, system.label.Submitted_Agency_review_pending);
        brs_businessNameCheck.Requests req = new brs_businessNameCheck.Requests();
        req.businessName='ABC INSURANCE';
        list<brs_businessNameCheck.Requests> lstReq = new list<brs_businessNameCheck.Requests>();
        
        lstReq.add(req);
        
        test.startTest();
        brs_businessNameCheck.checkBusNameContainsKeywords(lstReq);
        test.stopTest();
    }
    
    @isTest
    static void checkDuplicateAccNameReview(){
        
        Account testAcc1 = new Account(Name = 'Check Name LLC', Mailing_International_Address__c = 'Mailing address', Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington',	Account_Name_Without_Designators__c=' Test ');
        
        insert testAcc1;
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.type__c = System.label.Name_Change_Amendment;
		filing.Status__c = System.label.BRS_Submitted_Agent_acceptance_pending; 
        filing.RecordTypeId = RecordTypeIdMaintenance;
        insert filing;
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Certificate_Types__c = 'Express';
        tmpHistory.Account__c = testAcc1.Id;
        tmpHistory.business_filing__c = filing.Id;
        tmpHistory.BusinessName_New_Without_Designators__c = ' Test ' ;
        insert tmpHistory;
        
        test.startTest();
        brs_businessNameCheck.checkDuplicateAccNameReview('Test',testAcc1.id,True);
        test.stopTest();
        
    }
     @isTest
    static void checkDuplicateAccNameReview1(){
        System.debug('UserInfo.getUserId()@@'+UserInfo.getUserId());
        String reserveUser=UserInfo.getUserId();
        Account testAcc1 = new Account(Name = 'Check Name,LLC.', Mailing_International_Address__c = 'Mailing address', Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington',Reserved_Name_Used__c=false,Status__c = 'Reserved',Reserved_User__c =null,Account_Name_Without_Designators__c='');
        
        insert testAcc1;
        System.debug('testAcc1@@@ '+testAcc1.Account_Name_Without_Designators__c);
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.type__c = System.label.Business_Formation_Label;
		filing.Status__c = System.label.BRS_Submitted_Agent_acceptance_pending; 
        filing.RecordTypeId = RecordTypeIdMaintenance;
        insert filing;
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Certificate_Types__c = 'Express';
        tmpHistory.Account__c = testAcc1.Id;
        tmpHistory.business_filing__c = filing.Id;
        tmpHistory.BusinessName_New_Without_Designators__c = 'Test' ;
        insert tmpHistory;
        
        test.startTest();
        brs_businessNameCheck.checkDuplicateAccNameReview('Check Name,LLC.',testAcc1.id,null);
        test.stopTest();
        
    }
}