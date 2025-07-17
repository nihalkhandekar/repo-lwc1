@isTest
private class brs_searchBusinessControllerTest {

    @testSetup static void setup() {
        Id businessRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = businessRecTypeId;
        acc.Name = 'Test, LTD.';
        acc.Business_Type__c = 'Bank Non-Stock';
        acc.Business_Sub_Type__c = 'Corporation';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.Citizenship__c = 'Domestic';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.Status__c = 'Active';
        acc.Total_Authorized_Shares__c = 10;
        acc.Country_Formation__c = 'India';
        acc.Began_Transacting_in_CT__c = System.today();
        acc.Date_of_Formation__c = System.today();
        acc.Business_Name_in_state_country__c = 'test country';
        //acc.ShippingAddress = 'test mailing address';
        acc.Mailing_Address__c = 'hhh';
        acc.Mailing_International_Address__c = 'hhhh';
        acc.Sub_status__c=System.label.Ready_for_dissolution;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc.Id;
        insert con;
        
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User'];
        
        User user = new User( email='testUsr@test.com',
        profileid = lstProfileId[0].Id, 
        UserName='testUsr@test.com', 
        Alias = 'tusr',
        TimeZoneSidKey='America/New_York',
        EmailEncodingKey='UTF-8',
        LocaleSidKey='en_US', 
        LanguageLocaleKey='en_US',
        ContactId = con.Id,
        FirstName = 'Test',
        LastName = 'User');
        
        insert user;
        
        List<Profile> lstProfileadmin = [Select Id From Profile Where Name = 'System Administrator'];
        
        User userAdmin = new User( email='testAdmin12@test.com',
        profileid = lstProfileadmin[0].Id, 
        UserName='cherry@grapes.com', 
        Alias = 'tusrA',
        TimeZoneSidKey='America/New_York',
        EmailEncodingKey='UTF-8',
        LocaleSidKey='en_US', 
        LanguageLocaleKey='en_US',
        FirstName = 'Admin',
        LastName = 'User');
        
        insert userAdmin;
        
        Agent__c agent = new Agent__c();
        agent.FirstName__c = 'Test';
        agent.LastName__c = 'Agent';
        agent.Email__c = 'testagent@test.com';
        agent.Business_ID__c = acc.Id;
        agent.Business_Name__c = 'Pizza';
        agent.Business_Street_Address_1__c = 'Test';
        agent.Business_City__c = 'New York';
        agent.Business_Country__c = 'United States';
        //agents.Business_State__c = 'California';
        agent.Business_Zip_Code__c = '12334';
        agent.Business_State__c = 'CT';
        agent.Type__c = 'Individual';
        agent.Residence_Street_Address_1__c = '100';
        agent.Residence_City__c = 'Hartford';
        agent.Residence_Country__c = 'United States';
        agent.Residence_State__c = 'CT';
        agent.Residence_Zip_Code__c  = '06100';
        
        insert agent;
        
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();        
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Annual Report';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        businessFiling.Due_Date__c = System.Today().addDays(15);
        businessFiling.Status__c = 'Submitted - Agency review pending';
       
        insert businessFiling;
        
        Id mainRecTypeId1 = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();        
        Business_Filing__c businessFiling1 = new Business_Filing__c();
        businessFiling1.Account__c = acc.Id;
        businessFiling1.RecordTypeId = mainRecTypeId1;
        businessFiling1.Type__c = System.Label.First_Report_Label;
        businessFiling1.Filing_Date__c = System.Today().addDays(-30);
        businessFiling1.Due_Date__c = System.Today().addDays(15);
        businessFiling1.Status__c = 'Submitted - Agency review pending';
        insert businessFiling1;
        
        Principal__c principal = new Principal__c();
        principal.FirstName__c = 'Test';
        principal.LastName__c = 'Principal';
        principal.Business_ID__c = acc.Id;
        principal.Email__c = 'saritanayak71@gmail.com';
        
        insert principal;
        
        Certficate__c cert = new Certficate__c();
        cert.Requested_On__c = System.Today().addDays(-15);
        cert.Business__c = acc.Id;
        
        insert cert;
    }
    
    testmethod static void testGetBusiness() {
        test.startTest();
        List<Profile> lstProfileadmin = [Select Id From Profile Where Name = 'System Administrator'];
        
        User userAdmin = new User( email='testAdmin12@test.com',
        profileid = lstProfileadmin[0].Id, 
        UserName='apples@orangestaiyyq.com', 
        Alias = 'tusrAyq',
        TimeZoneSidKey='America/New_York',
        EmailEncodingKey='UTF-8',
        LocaleSidKey='en_US', 
        LanguageLocaleKey='en_US',
        FirstName = 'Admin',
        LastName = 'User');
        
        insert userAdmin;
        
        List<User> lstUsr = [Select Id From User where username = 'testUsr@test.com'];
        List<User> lstUsrAdmin= [Select Id From User where username = 'apples@orangestaiyyq.com'];
        system.runAs(lstUsr[0]) {
            brs_searchBusinessController.getBusiness('1234','Annual Report');
            brs_searchBusinessController.getBusiness('1234',Label.Revocation_Dissolution_Flow);
            brs_searchBusinessController.getBusiness('1234','First Report');
            brs_searchBusinessController.getBusiness('1234',Label.brs_maintenance_Address);
            brs_searchBusinessController.getBusiness('1234',Label.brs_maintenance_address_agent);
            brs_searchBusinessController.getBusiness('1234',Label.brs_AgentResignation);
            brs_searchBusinessController.getBusiness('1234',Label.foreign_investigation_comparable);
            brs_searchBusinessController.getBusiness('1234',Label.Request_for_copy_comparable);
            brs_searchBusinessController.getBusiness('1234','Online Intake Category');
            
        }
        system.runAs(lstUsrAdmin[0]) {
            brs_searchBusinessController.getBusiness('1234','Annual Report');
            brs_searchBusinessController.getBusiness('1234',Label.Revocation_Dissolution_Flow);
            brs_searchBusinessController.getBusiness('1234','First Report');
            brs_searchBusinessController.getBusiness('1234',Label.brs_maintenance_Address);
            brs_searchBusinessController.getBusiness('1234',Label.brs_maintenance_address_agent);
            brs_searchBusinessController.getBusiness('1234',Label.brs_AgentResignation);
            brs_searchBusinessController.getBusiness('1234','');
            brs_searchBusinessController.getBusiness('1234',Label.foreign_investigation_comparable);
            brs_searchBusinessController.getBusiness('1234',Label.Request_for_copy_comparable);
            brs_searchBusinessController.getBusiness('1234','Online Intake Category');
          
        }
        test.stopTest();
    }
    
    testmethod static void testGetBusinesscheck(){
        test.startTest();
        List<Account> accList = new List<Account>([SELECT ID FROM Account where Name = 'Test, LTD.' LIMIT 1]);
        brs_searchBusinessController.checkAccSubStatus(System.label.Annual_Report_Due1_Comparable,'');
        brs_searchBusinessController.checkAccSubStatus(System.label.Annual_report_past_due_Comparable,'');
        brs_searchBusinessController.checkAccSubStatus(System.label.First_Report_Due_Comparable,'');
        brs_searchBusinessController.checkAccSubStatus(System.label.First_report_past_due_Comparable,'');
        brs_searchBusinessController.checkAccSubStatus(System.label.Ready_for_dissolution_Comparable,'');
        brs_searchBusinessController.checkAvailability(accList[0].Id);
        brs_searchBusinessController.getNameWithoutDesignators('Test, LTD.');
        test.stopTest();
    }

    testmethod static void testGetBusinessInv() {
        test.startTest();
        List<brs_searchBusinessController.Requests> lstRequests = new List<brs_searchBusinessController.Requests>();
        brs_searchBusinessController.Requests req = new brs_searchBusinessController.Requests();
        req.busStr = '1234';
        req.flowName = 'First Report';
        lstRequests.add(req);
        brs_searchBusinessController.getBusinessInv(lstRequests);
        test.stopTest();
    }
    testmethod static void checkDissolution() {
        Id accountid=[select id from account limit 1].id;
        test.startTest();
        brs_searchBusinessController.checkAccountHasDuplicateDissolution(accountid);
        test.stopTest();
    }
}