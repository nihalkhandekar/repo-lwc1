@isTest
public class AccountTriggerHelperTestCls {  
    
    @testSetup static void setup() {
        
        // Id profileId = [select id from profile where name='System Administrator'].id;
        //  User user = QnA_TestDataFactory.createAdminUser(profileId);
        
        
        // system.runAs(user){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(Label.Maintenance).getRecordTypeId();
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Business_Label).getRecordTypeId();
        Id RecordTypeIdNewBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByDeveloperName().get(Label.New_Business_Label).getRecordTypeId();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(Label.CloseReinstateLabel).getRecordTypeId();

        List<Account> Acclist = new List<Account>();
        Account testAcc1 = new Account(Name = 'Check Name LLC', Mailing_International_Address__c = 'Mailing address', Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington', RecordTypeId = RecordTypeIdBusiness);
        Account testAcc2 = new Account(Name = (userInfo.getFirstName()+' '+userInfo.getLastName()), Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_International_Address__c = 'Mailing address', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington');
        
        
        Account testAcc3 = new Account(Name = 'TestClassAcct1 & Co', Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India' ,Mailing_International_Address__c = 'Mailing address'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington');
        Account testAcc4 = new Account(Name = 'TestClassAcct4 & Co',Citizenship__c = 'Domestic', Business_Type__c = 'Religious',sub_status__c = system.label.Active_Ready_for_Admin_Dissolution,  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India',Mailing_International_Address__c = 'Mailing address',
                                       BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington', RecordTypeId = RecordTypeIdBusiness);    
        
        Account testAcc5 = new Account(Name = 'TestClassAcctBypass & Co',Citizenship__c = 'Foreign',Business_Type__c =system.label.Statutory_Trust, Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street',Mailing_International_Address__c = 'Mailing address', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                       sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness,State_or_Territory_Formation__c='Washington');                
        
        Account testAcc6 = new Account(Name = 'TestClassAcct6 & Co',Citizenship__c = 'Domestic', Business_Type__c = 'Religious', BillingStreet = null, BillingCity = null, BillingCountry = null, BillingState = null, BillingPostalCode = null, ShippingStreet = null, ShippingCity = null, ShippingCountry = null,ShippingState = null, ShippingPostalCode = null, Business_Sub_Type__c = 'Religious', Account_Name_Without_Designators__c = 'Acc Name without designator test', Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC',Mailing_International_Address__c = 'Mailing address', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India',State_or_Territory_Formation__c='Washington'
                                      );      
        
        Account testAcc7 = new Account(Name = 'TestClassAcct7 & Co',Citizenship__c = 'Foreign',Business_Type__c ='LLP',
                                       Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),
                                       Country_Formation__c='India',Mailing_International_Address__c = 'Mailing address',
                                       Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345', Account_Name_Without_Designators__c = 'Acc Name without designator test',
                                       sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , Reserved_Name_Used__c = false , Status__c = System.label.ACTIVE , Business_Name_in_state_country__c ='acc5',Description='abc product',State_or_Territory_Formation__c='Washington');                
        
        
        Account testAcc8 = new Account(Name = 'TestClassAcct8 & Co',Citizenship__c = 'Domestic', Business_Type__c = 'LLC', 
                                       BillingStreet = null, BillingCity = null, BillingCountry = null, BillingState = null, BillingPostalCode = null, 
                                       ShippingStreet = null, ShippingCity = null, ShippingCountry = null,ShippingState = null, ShippingPostalCode = null, 
                                       /*Business_Sub_Type__c = 'Religious',*/ RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = 'Acc Name without designator test',
                                       Status__c = System.label.ACTIVE , Reserved_Name_Used__c = false , Business_Name_in_state_country__c ='acc6', Purpose_of_Business__c='ABC Business requirement', Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC',Mailing_International_Address__c = 'Mailing address', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India',State_or_Territory_Formation__c='Washington');      
        
        Account testAcc9 = new Account(Name = 'The TestClassAcct9 & Co',Citizenship__c = 'Domestic', Business_Type__c = 'LLC', 
                                       BillingStreet = null, BillingCity = null, BillingCountry = null, BillingState = null, BillingPostalCode = null, 
                                       ShippingStreet = null, ShippingCity = null, ShippingCountry = null,ShippingState = null, ShippingPostalCode = null, 
                                       /*Business_Sub_Type__c = 'Religious',*/ RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = 'Acc Name without designator test',
                                       Status__c = System.label.ACTIVE , Reserved_Name_Used__c = false , Business_Name_in_state_country__c ='acc6', Purpose_of_Business__c='ABC Business requirement', Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC',Mailing_International_Address__c = 'Mailing address', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India',State_or_Territory_Formation__c='Washington'); 
        
        Account testAcc10 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                        Status__c = System.label.brs_BusinessReservationStatus , Reserved_Name_Used__c = false);
        
        
        Acclist.add(testAcc1);
        Acclist.add(testAcc2);
        Acclist.add(testAcc3);
        Acclist.add(testAcc4);
        Acclist.add(testAcc5);
        Acclist.add(testAcc6);
        Acclist.add(testAcc7);
        Acclist.add(testAcc8);
        Acclist.add(testAcc9);
        Acclist.add(testAcc10);
        insert Acclist;
        
        Agent__c agent = new Agent__c(Business_ID__c=testAcc1.Id,FirstName__c='Agent',Agent_Account_ID__c=testAcc1.Id);
        insert agent;
        Agent__c agent2 = new Agent__c(Business_ID__c=testAcc5.Id,FirstName__c='Agent',Agent_Account_ID__c=testAcc5.Id);
        insert agent2;
        
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
        tmpHistory.Account__c = testAcc5.Id;
        tmpHistory.business_filing__c = filing.Id;
        tmpHistory.BusinessName_New_Without_Designators__c = 'Acc Name without designator test' ;
        insert tmpHistory;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=testAcc5.Id;
        filing1.Filing_Fee__c=30;
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.type__c = System.label.Name_Change_Amendment;
        filing1.Status__c = System.label.BRS_Submitted_Agent_acceptance_pending;
        filing1.RecordTypeId = RecordTypeIdMaintenance;
        insert filing1;
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Account__c = testAcc5.Id;
        tmpHistory1.business_filing__c = filing.Id;
        tmpHistory1.BusinessName_New_Without_Designators__c = 'Acc Name without designator test' ;
        insert tmpHistory1;
        
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.Account__c=testAcc7.Id;
        filing2.Filing_Fee__c=30;
        filing2.Filing_Date__c = System.Today().addDays(-30);
        filing2.Due_Date__c = (System.today() + 5);
        filing2.type__c = 'Withdrawal';
        filing2.Status__c = System.label.BRS_Submitted_Agent_acceptance_pending; 
        filing2.RecordTypeId = RecordTypeIdCloseReinstate;
        //filing2.Sub_Type__c = system.label.With_NameChange_Label;
        insert filing2;
        Temp_History__c tmpHistory2 = new Temp_History__c();
        tmpHistory2.Certificate_Types__c = 'Express';
        tmpHistory2.Account__c = testAcc7.Id;
        tmpHistory2.business_filing__c = filing.Id;
        tmpHistory2.BusinessName_New_Without_Designators__c = 'Acc Name without designator test' ;
        insert tmpHistory2;
        
        /*  Business_Filing__c filing3 = new Business_Filing__c();

filing3.Account__c=testAcc8.Id;
filing3.Filing_Fee__c=30;
filing3.Filing_Date__c = System.Today().addDays(-30);
filing3.Due_Date__c = (System.today() + 5);
filing3.type__c = 'Revocation of dissolution';
filing3.Status__c = System.label.BRS_Submitted_Agent_acceptance_pending;
filing3.RecordTypeId = RecordTypeIdCloseReinstate;
filing3.Sub_Type__c = system.label.With_NameChange_Label;
insert filing3;
Temp_History__c tmpHistory3 = new Temp_History__c();
tmpHistory3.Certificate_Types__c = 'Express';
tmpHistory3.Account__c = testAcc8.Id;
tmpHistory3.business_filing__c = filing.Id;
tmpHistory3.BusinessName_New_Without_Designators__c = 'Acc Name without designator test' ;
insert tmpHistory3; */
        //   }
        
        
    }
    @isTest
    static void updateAccountBackendNameTest1() {
        Test.startTest();
        Account testAcc4 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c from Account where Name = 'TestClassAcct4 & Co'];
        List<Account> newTriggerList1 = new List<Account>();
        newTriggerList1.add(testAcc4);
        Map<Id,SObject> oldTriggerMap1 = new Map<Id,SObject>();
        
        AccountTriggerHelper.updateAccountBackendName(newTriggerList1, oldTriggerMap1);
        Test.stopTest();
    } 
    
    @isTest
    static void updateAccountBackendNameTest3() {
        Test.startTest();
        Account testAcc4 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c from Account where Name = 'TestClassAcct4 & Co'];
        testAcc4.Status__c = system.label.Withdrawn;
        testAcc4.Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label;
        update testAcc4;
        List<Account> newTriggerList1 = new List<Account>();
        newTriggerList1.add(testAcc4);
        Map<Id,SObject> oldTriggerMap1 = new Map<Id,SObject>();
        
        AccountTriggerHelper.updateAccountBackendName(newTriggerList1, oldTriggerMap1);
        Test.stopTest();
    } 
    
    @isTest
    static void updateAccountBackendNameTest2() {
        Test.startTest();
        
        Account testAcc5 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Business_Sub_Type__c, Account_Name_Without_Designators__c,Business_Address_1__c,Mailing_Address_1__c,Status__c from Account where Name = 'TestClassAcctBypass & Co'];
        Account testAcc6 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c ,Business_Sub_Type__c , Account_Name_Without_Designators__c,Business_Address_1__c,Mailing_Address_1__c,Status__c from Account where Name = 'TestClassAcct6 & Co'];
        Account testAcc9 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c ,Business_Sub_Type__c , Account_Name_Without_Designators__c,Business_Address_1__c,Mailing_Address_1__c,Status__c from Account where Name = 'The TestClassAcct9 & Co' and Status__c !=: System.label.brs_BusinessReservationStatus];
        
        List<Account> newTriggerList2 = new List<Account>();
        newTriggerList2.add(testAcc5);
        newTriggerList2.add(testAcc6);
        newTriggerList2.add(testAcc9);
        Map<Id,SObject> oldTriggerMap2 = new Map<Id,SObject>();
        oldTriggerMap2.put(testAcc5.Id, testAcc6);
        oldTriggerMap2.put(testAcc6.Id, testAcc6);
        oldTriggerMap2.put(testAcc9.Id, testAcc9);
        
        User currUser = [SELECT Bypass_trigger__c FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        currUser.Bypass_trigger__c = true;
        update currUser;
        AccountTriggerHelper.updateAccountBackendName(newTriggerList2, oldTriggerMap2);
        AccountTriggerHelper.checkForDuplicates(newTriggerList2,oldTriggerMap2);
        Test.stopTest();
    }
    
    @isTest
    static void testCheckduplicates() {
        
        Account testAcc5 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Business_Sub_Type__c, Account_Name_Without_Designators__c from Account where Name = 'TestClassAcctBypass & Co'];
        Account testAcc6 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c ,Business_Sub_Type__c , Account_Name_Without_Designators__c from Account where Name = 'TestClassAcct6 & Co'];
        Account testAcc9 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c ,Business_Sub_Type__c , Account_Name_Without_Designators__c from Account where Name = 'The TestClassAcct9 & Co' and Status__c !=: System.label.brs_BusinessReservationStatus];
        
        List<Account> newTriggerList2 = new List<Account>();
        newTriggerList2.add(testAcc5);
        newTriggerList2.add(testAcc6);
        newTriggerList2.add(testAcc9);
        
        Test.startTest();
        AccountTriggerHelper.checkForDuplicates(newTriggerList2,null);
        Test.stopTest();
    } 
    
    @isTest
    private static void testRecord() {
        Account testAcc7 = [select id, Name, sub_status__c ,Business_Name_in_state_country__c, RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Business_Sub_Type__c, Account_Name_Without_Designators__c from Account where Name = 'TestClassAcct7 & Co'];
        Account testAcc8 = [select id, Name, sub_status__c ,Business_Name_in_state_country__c, RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c ,Business_Sub_Type__c , Account_Name_Without_Designators__c from Account where Name = 'TestClassAcct8 & Co'];
        
        AccountTriggerHandler triggerHandler = new AccountTriggerHandler();  
        
        
        Map<Id, SObject> oldMap1 = new Map<Id, SObject>();
        oldMap1.put(testAcc8.Id, testAcc7); 
        Map<Id, SObject> newItems1 = new Map<Id, SObject>();
        newItems1.put(testAcc8.Id, testAcc8);
        
        
        Id businessRecordTypeId = Wizard_Utlity.getRecordTypeId(system.label.AccountRecordType_Business,Schema.Account.getSObjectType());
        
        Test.startTest();
        triggerHandler.beforeDelete(null, null);
        triggerHandler.afterDelete(null);
        triggerHandler.afterInsert(null, null);
        //triggerHandler.afterUpdate(null, null);
        triggerHandler.afterUndelete(null, null);
        AccountTriggerHelper.createNameHistoryTableRecs(newItems1, oldMap1);
        Test.stopTest();        
    } 
    @isTest
    static void setBillingCityIndexedTest() {
        Account testAcc1 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c from Account LIMIT 1];
        testAcc1.BillingCity='Test,1 LLC ';
        update testAcc1;
        AccountTriggerHelper.setBillingCityIndexed(new List<Account>{testAcc1});
        testAcc1.BillingCity='The';
        update testAcc1;
        AccountTriggerHelper.setBillingCityIndexed(new List<Account>{testAcc1});
    }
     @isTest
    static void createFirstReportTest() {
        Map<Id,Account> newMap=new Map<Id,Account>();
         Map<Id,Account> oldMap=new Map<Id,Account>();
        Account testAcc1 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c from Account LIMIT 1];
        testAcc1.Status__c='Pending Filing';
        testAcc1.Citizenship__c='Domestic';
        testAcc1.Total_Authorized_Shares__c=1;
         testAcc1.Business_Type__c=System.label.Stock;
        update testAcc1;
        oldMap.put(testAcc1.Id,testAcc1);
        Account testAcc2 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c from Account where Id=:testAcc1.Id];
          testAcc2.Status__c='Active';
        testAcc2.Date_Registration__c=System.today();
        update testAcc2;
        newMap.put(testAcc2.Id,testAcc2);
        System.debug('@@@@@@@@@@@@@'+newMap);
        System.debug('@@@@@@@@@@@@@'+oldMap);
        AccountTriggerHelper.createFirstReport(newMap,oldMap);
    }    
     @isTest
    static void createNameHistoryTableRecsTest() {
        Map<Id,Account> newMap=new Map<Id,Account>();
        Map<Id,Account> oldMap=new Map<Id,Account>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get(Label.CloseReinstateLabel).getRecordTypeId();
        Account testAcc1 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c,Business_Name_in_state_country__c from Account LIMIT 1];        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
         testAcc1.Citizenship__c='Domestic';
        testAcc1.Total_Authorized_Shares__c=1;
         testAcc1.Business_Type__c=System.label.Stock;
        testAcc1.Status__c='Forfeited';
        update testAcc1;
        oldMap.put(testAcc1.Id,testAcc1);
         Account testAcc2 = [select id, Name, sub_status__c , RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,
                            ShippingCity, ShippingCountry , ShippingState , ShippingPostalCode , citizenship__c, Business_Type__c ,Reserved_Name_Used__c , Account_Name_Without_Designators__c,Business_Name_in_state_country__c from Account where Id=:testAcc1.Id];
       testAcc2.Name='421412Test';
        update testAcc2;
        newMap.put(testAcc2.Id,testAcc2);
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = System.label.brs_Reinstatement;
        filing.Sub_Type__c = system.label.withAnnual_NameChange;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='In-Progress';
        insert filing;
        AccountTriggerHelper.createNameHistoryTableRecs(newMap,oldMap);
        AccountTriggerHelper.createNameHistoryTableRecs(newMap,oldMap);
    }
    
    @isTest
    static void updateAdmindissolutionAddressTest(){
 
        List<Account> lstacc= new List<Account> ();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        
        lstacc.add(acc1);
        insert lstacc;
        acc1.Sub_status__c='Ready for dissolution';
        acc1.BillingStreet='Test BillingStreet';
        acc1.BillingCity='Test';
        acc1.BillingState='State';
        acc1.BillingPostalCode='12345';
        
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        insert agent11;
        
        update   acc1;  
        

        

        //Test.startTest();
        //AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc); 
        //Test.stopTest();
        
        
    }
    
        @isTest
        static void testupdateForeignInvestigationAddress(){
        Test.startTest();
		AccountTriggerHelper.fetchStatePickListValue();
        
        Map<Id, Account> mapAccounts = new Map<Id, Account>([select id, Surviving_Account__c,Citizenship__c,Name, sub_status__c, RecordTypeId, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,ShippingStreet,Business_Address_1__c,Mailing_Address_1__c,Status__c,ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, Business_Type__c,Reserved_Name_Used__c, Account_Name_Without_Designators__c,Principle_Office_International_Address__c from Account where Name = 'Test Foreign Invstg']);
        AccountTriggerHelper.updateForeignInvestigationAddress(mapAccounts);
        Test.stopTest();
    }
    
        @isTest
        static void testcheckForReservedAccounts(){
        Test.startTest();
        List<Legal_Designation__mdt> legalDesignation=[Select Label,Legal_Designator__c,Order__c from Legal_Designation__mdt];
        List<brs_SortLegalDesignators> legalDesignationList=new List<brs_SortLegalDesignators>();
        legalDesignationList.add(new brs_SortLegalDesignators(legalDesignation[0]));
         legalDesignationList.sort();
        for(Legal_Designation__mdt ds:legalDesignation)
            {
                System.assertEquals(ds.Label, ds.Label);
            }
        
        List<Business_Name_Noisewords__mdt> listOfNoiseWords = [Select Label from Business_Name_Noisewords__mdt];
        
        
        
         AccountTriggerHelper.checkForReservedAccounts(legalDesignationList, listOfNoiseWords);
         Test.stopTest();
        
    }
        @isTest
        static void updateMailingAddressSameasBusiness(){
        
        List<Account> lstacc= new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account56';
        acc1.Same_as_Principal_Office_Address__c=true;
        lstacc.add(acc1);    
        insert lstacc;
        acc1.Same_as_Principal_Office_Address__c=false;
        update acc1;
        Map<id,account> mpacc= new Map<id,account>();
        mpacc.put(acc1.id,acc1);
        AccountTriggerHelper.updateMailingAddressSameasBusiness(lstacc,mpacc);     
            
    }
    
    @isTest
    static void updateAdmindissolutionAddressTest1(){
 
        List<Account> lstacc= new List<Account> ();
        Map<id,Account> mpacc= new Map<id,Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        
        //lstacc.add(acc1);
        insert acc1;
        mpacc.put(acc1.id,acc1);
        
        Account cloneAcc = acc1.clone(true, false, false, false);
        
        cloneAcc.Sub_status__c='Ready for dissolution';
        cloneAcc.BillingStreet='Test BillingStreet';
        cloneAcc.BillingCity='Test';
        cloneAcc.BillingState='State';
        cloneAcc.BillingPostalCode ='12345';
        lstacc.add(cloneAcc);
        //update   lstacc; 
        
        //system.debug();
        //mpacc.put(acc1.id,acc1);
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        insert agent11;
        Test.startTest();
        AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc);
        Test.stopTest();
    }
    
     @isTest
    static void updateAdmindissolutionAddressTest3431(){
 
        List<Account> lstacc= new List<Account> ();
        Map<id,Account> mpacc= new Map<id,Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        
        //lstacc.add(acc1);
        insert acc1;
        mpacc.put(acc1.id,acc1);
        
        Account cloneAcc = acc1.clone(true, false, false, false);
        
        cloneAcc.Sub_status__c='Ready for dissolution';
        cloneAcc.ShippingStreet='Test BillingStreet';
        cloneAcc.ShippingCity='Test';
        cloneAcc.ShippingState='State';
        cloneAcc.ShippingPostalCode='12345';
        lstacc.add(cloneAcc);
        //update   lstacc; 
        
        //system.debug();
        //mpacc.put(acc1.id,acc1);
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        insert agent11;
        Test.startTest();
        AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc);
        Test.stopTest();
    }
    
      @isTest
    static void updateAdmindissolutionAddressTest2(){
 
        List<Account> lstacc= new List<Account> ();
        Map<id,Account> mpacc= new Map<id,Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        insert acc1;
        mpacc.put(acc1.id,acc1);
        Account cloneAcc = acc1.clone(true, false, false, false);
        
        cloneAcc.Sub_status__c='Ready for dissolution';
        
        lstacc.add(cloneAcc);

        
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        insert agent11;
        
        update   acc1; 
        
        Test.startTest();
        AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc);
        Test.stopTest();
        
        
    }
          @isTest
    static void updateAdmindissolutionAddressTest3(){
 

        List<Account> lstacc= new List<Account> ();
        Map<id,Account> mpacc= new Map<id,Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        insert acc1;
        mpacc.put(acc1.id,acc1);
        Account cloneAcc = acc1.clone(true, false, false, false);
        
        cloneAcc.Sub_status__c='Ready for dissolution';
        
        lstacc.add(cloneAcc);

        
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Unknown';
        agent11.Mailing_Street_Address_1__c = '100';
        agent11.Mailing_Street_Address_2__c = '100';
        agent11.Mailing_City__c = 'Hartford';
        agent11.Mailing_Country__c = 'United States';
        agent11.Mailing_State__c = 'CT';
        agent11.Mailing_Zip_Code__c  = '06100';
        insert agent11;
        
        update   acc1;  
        
         Test.startTest();
        AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc);
        Test.stopTest();
        
        
    }
    
     @isTest
    static void updateAdmindissolutionAddressTest34636(){
 

        List<Account> lstacc= new List<Account> ();
        Map<id,Account> mpacc= new Map<id,Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.sub_status__c ='Forfeited';
        insert acc1;
        mpacc.put(acc1.id,acc1);
        Account cloneAcc = acc1.clone(true, false, false, false);
        
        cloneAcc.Sub_status__c='Ready for dissolution';
        
        lstacc.add(cloneAcc);

        
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc1.Id;
        agent11.Type__c = 'Unknown';
        agent11.Business_Street_Address_1__c = '100';
        agent11.Business_Street_Address_2__c = '100';
        agent11.Business_City__c = 'Hartford';
        agent11.Business_Country__c = 'United States';
        agent11.Business_State__c = 'CT';
        agent11.Business_Zip_Code__c  = '06100';
        insert agent11;
        
        update   acc1;  
        
         Test.startTest();
        AccountTriggerHelper.updateAdmindissolutionAddress(lstacc,mpacc);
        Test.stopTest();      
        
    } 
}