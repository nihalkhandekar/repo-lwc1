@isTest
public class BRS_SendNotificationtoAgentBatch_Test {
 testmethod  static void agentNotificationTest() {
     	Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
   		RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
    	Account acc=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='LLP',Office_Jurisdiction_BusinessState__c='AK', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),State_or_Territory_Formation__c='Alaska',Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='AK', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product'); 
            insert acc;
        Agent__c agent = new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
        
     	
     	
     	List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=rt.Id;
            filing.Account__c=acc.Id;
            filing.status__c='Submitted - Agent acceptance pending';
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c ='Foreign';
            filing.Agent_Id__c='12345';
            filing.Type__c='Withdrawal';
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c='LLP';
            filing.Status__c='Approved';
            filingList.add(filing);
        }
        insert filingList;
     
        Test.startTest();
        BRS_SendNotificationtoAgentBatch obj = new BRS_SendNotificationtoAgentBatch();
           obj.start(null);
        obj.execute(null, filingList);
        obj.finish(null);
         ID batchprocessid =Database.executeBatch(obj);
        String sch = '0 0 2 * * ?'; 
		system.schedule('Notification Check', sch, obj); 
     	new BRS_SendNotificationtoAgentBatch().callSendMessage(filingList);
     	
        Test.stopTest();
    }
    testmethod  static void agentNotificationTest1() {
   Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
    	Account acc=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='LLP', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),State_or_Territory_Formation__c='CT',Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='CT', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product'); 
            insert acc;
		RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        
		List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=rt.Id;
            filing.Account__c=acc.Id;
            filing.status__c='Submitted - Agent acceptance pending';
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c ='Foreign';
            filing.Agent_Id__c='12345';
            filing.Type__c='Withdrawal';
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c='LLP';
            filing.Status__c='Approved';
            filingList.add(filing);
        }
        insert filingList;
        
        Test.startTest();
        BRS_SendNotificationtoAgentBatch obj = new BRS_SendNotificationtoAgentBatch();
        obj.start(null);
        obj.execute(null, filingList);
        obj.finish(null);
         ID batchprocessid =Database.executeBatch(obj);
        Test.stopTest();
    }
    testMethod static void sendemail(){
        RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
    	Account acc=new Account(Name = 'TestClassAcctBypass & Co',Citizenship__c = 'Foreign',Business_Type__c ='LLP', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),State_or_Territory_Formation__c='CT',Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='CT', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product'); 
            insert acc;
        Agent__c agent = new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
         //acc.id,datetime.newInstance(2021, 4, 19, 12, 30, 0),48);
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=rt.Id;
            filing.Account__c=acc.Id;
            filing.status__c='Submitted - Agent acceptance pending';
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c ='Foreign';
            filing.Agent_Id__c='12345';
            filing.Type__c='Withdrawal';
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c='LLP';
            filing.Status__c='Approved';
            filingList.add(filing);
        }
        insert filingList;
        
        BRS_Encryption_Key_Setting__c EncryptSetting = new BRS_Encryption_Key_Setting__c();
        EncryptSetting.Crypto_Key__c = 'eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=';
        insert EncryptSetting;
      
        
        test.startTest();
        System.debug(filingList);
        new BRS_SendNotificationtoAgentBatch().sendEmail(filingList);
        test.stopTest();
    }
    testMethod static void updateStatus() {
       
        RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
    	Account acc=new Account();
    	acc=BRS_TestDataFactory.createAccountObject();
        acc.Legal_Structure_Acknowledgement__c = true;
        acc.Business_Type__c =system.Label.Non_Stock;
        acc.Nature_of_Activities_Conducted__c = 'non-stock';
		acc.BillingStreet='123';
        acc.BillingState='CT';
        acc.BillingCity='Test';
        acc.BillingCountry='United States';
        acc.BillingPostalCode='12345';
        acc.ShippingStreet='123';
        acc.ShippingState='CT';
        acc.ShippingCity='Test';
        acc.ShippingCountry='United States';
        acc.ShippingPostalCode='12345';
        update acc;
        
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
    	
    	Account acc1=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c =system.Label.Non_Stock, Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',State_or_Territory_Formation__c ='Washington' ); 
            insert acc1;
        Agent__c agent = new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
        Id RecordTypeAnnualFirstReport = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();

        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=RecordTypeAnnualFirstReport;
            filing.Account__c=acc.Id;
            filing.status__c=System.Label.Submitted_Agent_acceptance_pending;
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c =system.Label.Domestic;
            filing.Agent_Id__c='12345';
            filing.Type__c=system.Label.Annual_Report;
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c=system.Label.Non_Stock;
            filing.Status__c='Approved';
            filingList.add(filing);
            
            Business_Filing__c filing2 = new Business_Filing__c();
            filing2.recordtypeid=Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            filing2.Account__c=acc1.Id;
            
            filing2.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing2.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing2.Citizenship__c =system.Label.Foreign;
            filing2.Agent_Id__c='12345';
            filing2.Type__c=system.Label.Business_Registration_Label;
            filing2.Agent_Phone_Number__c=1234567890;
            filing2.Agent_Confirmation_Hours_Left__c=48;
            filing2.Business_Type__c=system.Label.Non_Stock;
            filing2.status__c=System.Label.Submitted_Agent_acceptance_pending;
            filingList.add(filing2);
        }
        insert filingList;
        
        test.startTest();
        new BRS_SendNotificationtoAgentBatch().updateStatus(filingList);
        test.stopTest();
        
    }
    
    testMethod static void callSendMessage() {
        RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
    	
    	Account acc=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='LLP', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),
                                State_or_Territory_Formation__c='CT',Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',
                                Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='CT', 
                                Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                Mailing_Jurisdiction_Country__c='India',BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', 
                                BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', 
                                ShippingPostalCode = '12345', sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product');  
            insert acc;
        Agent__c agent = new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
        
                List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=rt.Id;
            filing.Account__c=acc.Id;
            filing.status__c='Submitted - Agent acceptance pending';
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c ='Foreign';
            filing.Agent_Id__c='12345';
            filing.Type__c='Withdrawal';
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c='LLP';
            filing.Status__c='Approved';
            filingList.add(filing);
        }
        insert filingList;
        //acc.id,datetime.newInstance(2021, 4, 19, 12, 30, 0),48);
        
        BRS_Encryption_Key_Setting__c EncryptSetting = new BRS_Encryption_Key_Setting__c();
        EncryptSetting.Crypto_Key__c = 'eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=';
        insert EncryptSetting;
        
        test.startTest();
        new BRS_SendNotificationtoAgentBatch().callSendMessage(filingList);
        test.stopTest();
    }
     testMethod static void updateStatus2() {
       
        RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
    	Account acc=new Account();
    	acc=BRS_TestDataFactory.createAccountObject();
        acc.Legal_Structure_Acknowledgement__c = true;
        acc.Business_Type__c =system.Label.Non_Stock;
        acc.Nature_of_Activities_Conducted__c = 'non-stock';
		acc.BillingStreet='123';
        acc.BillingState='CT';
        acc.BillingCity='Test';
        acc.BillingCountry='United States';
        acc.BillingPostalCode='12345';
        acc.ShippingStreet='123';
        acc.ShippingState='CT';
        acc.ShippingCity='Test';
        acc.ShippingCountry='United States';
        acc.ShippingPostalCode='12345';
        update acc;
        
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
    	
    	Account acc1=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c =system.Label.Non_Stock, Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',State_or_Territory_Formation__c ='Washington' ); 
            insert acc1;
        Agent__c agent = new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
        Id RecordTypeAnnualFirstReport = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();

        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        {
            Business_Filing__c filing = new Business_Filing__c();
            filing.recordtypeid=RecordTypeAnnualFirstReport;
            filing.Account__c=acc.Id;
            filing.status__c=System.Label.Submitted_Agent_acceptance_pending;
            filing.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing.Citizenship__c =system.Label.Domestic;
            filing.Agent_Id__c='12345';
            filing.Type__c=system.Label.Annual_Report;
            filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=48;
            filing.Business_Type__c=system.Label.Non_Stock;
            filing.Status__c='Approved';
            filingList.add(filing);
            
            Business_Filing__c filing2 = new Business_Filing__c();
            filing2.recordtypeid=Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
            filing2.Account__c=acc1.Id;
            
            filing2.Agent_Confirmation_Notification__c=datetime.newInstance(2021, 4, 19, 12, 30, 0);
            filing2.Agent_Email_Address__c='sbabarabbani@deloitte.com';
            filing2.Citizenship__c =system.Label.Foreign;
            filing2.Agent_Id__c='12345';
            filing2.Type__c=system.Label.Annual_Report;
            filing2.Agent_Phone_Number__c=1234567890;
            filing2.Agent_Confirmation_Hours_Left__c=48;
            filing2.Business_Type__c=system.Label.Non_Stock;
            filing2.status__c=System.Label.Submitted_Agent_acceptance_pending;
            filingList.add(filing2);
        }
        insert filingList;
        
        test.startTest();
        new BRS_SendNotificationtoAgentBatch().updateStatus(filingList);
        test.stopTest();
        
    }
}