@isTest
public class BRSUpAccUsingMaintenanceFiling_Test {
    
    @isTest 
    static void testbatch() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Temp_History__c > lstTemp = new List<Temp_History__c >();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,'Interim Notice',system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Principal__c Principl = BRS_TestDataFactory.createPrincipal();
        Temp_History__c temp = new Temp_History__c(Account__c=acc.Id,Type__c = system.label.Principal , Business_Filing__c = lstBusFil[0].Id , Change_Type__c = system.label.brs_maintenance_tempCreated);
        Temp_History__c temp1 = new Temp_History__c(Account__c=acc.Id,Type__c = system.label.Principal,Principal_Title__c = 'Manager', Email__c = 'a@a.com' , Business_Filing__c = lstBusFil[0].Id , Change_Type__c = system.label.brs_maintenance_tempCreated);
        Temp_History__c temp2 = new Temp_History__c(Account__c=acc.Id,Principal__c = Principl.Id,Type__c = system.label.Principal, Business_Filing__c = lstBusFil[0].Id , Change_Type__c = system.label.Deleted);
        lstTemp.add(temp);
        lstTemp.add(temp1);
        lstTemp.add(temp2);
        insert lstTemp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testbatch2() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,'Change of Agent Address',system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Agent__c agent = BRS_TestDataFactory.createAgent(acc.Id);
        Temp_History__c temp = new Temp_History__c(Agent__c =agent.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Agent , Change_Type__c = system.label.Label_Edited,Business_City__c='Mumbai', Business_State__c='Maharashtra', Business_Street_Address_1__c='221B', Business_Street_Address_2__c='Baker Street', Business_Country__c='India', Business_Street__c='Baker Street', Business_ZipCode__c='12345',Business_InternationalAddress__c='221b Baker Street, London',
                                                  Residence_City__c='Mumbai',Residence_Street_Address_1__c='221b',Residence_Street_Address_2__c='Baker Street',Residence_Zip_Code__c='12345',Residence_State__c='Washington',
                                                  Residence_Country__c='India',Mailing_City__c='Mumbai', Mailing_State__c='Maharashtra', Mailing_Street_Address_1__c='221b baker street',
                                                   Mailing_Street_Address_2__c='baker street', Mailing_Zip_Code__c='12345', Mailing_Country__c='India', Mailing_Street__c='Baker Street',Business_Zip_Code__c='12345');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testbatch3() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Temp_History__c > lstTemp = new List<Temp_History__c >();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,'Change of Agent',system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Agent__c agent = BRS_TestDataFactory.createAgent(acc.Id);
        Temp_History__c temp = new Temp_History__c (Account__c=acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = 'Agent' , Change_Type__c = system.label.brs_maintenance_tempCreated, Mailing_City__c='Mumbai', Mailing_International_Address__c='xyz', Mailing_Street_Address_1__c='baker street', Mailing_Street_Address_2__c='baker street', Mailing_Zip_Code__c='12345', Mailing_Country__c='India',
                                                   Mailing_Street__c='abc', Mailing_ZipCode__c='12345', Business_InternationalAddress__c='xyzabc, abc', Business_City__c='Mumbai', Business_State__c='ABC', Mailing_State__c='ABCDE', FirstName__c='Test', LastName__c='Test', Phone__c='1234567890', Business_Street_Address_1__c='xyz, abcdef', Business_Street_Address_2__c='baker street', Business_Zip_Code__c='12345', Business_Country__c='India', Residence_Country__c='India', Residence_State__c='ABCD', Residence_Street_Address_1__c='XYZ, ABC', 
                                                   Residence_Street_Address_2__c='Baker street', Residence_Zip_Code__c='12345', Residence_City__c='Mumbai', Residence_InternationalAddress__c='xyz, abcd', Business_Street__c='baker street', Business_ZipCode__c='12345');
        lstTemp.add(temp);
        Temp_History__c temp1 = new Temp_History__c (Account__c=acc.Id, Agent__c =agent.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = 'Agent' , Change_Type__c = system.label.Deleted);
        lstTemp.add(temp1);
        insert lstTemp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testbatch4() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,acc.Id,'Agent Resignation',system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Agent__c agent = BRS_TestDataFactory.createAgent(acc.Id);
        Temp_History__c temp = new Temp_History__c(Account__c = acc.Id , Agent__c =agent.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = 'Agent' , Change_Type__c = system.label.brs_maintenance_tempCreated, Mailing_City__c='Mumbai', Mailing_International_Address__c='xyz', Mailing_Street_Address_1__c='baker street', Mailing_Street_Address_2__c='baker street', Mailing_Zip_Code__c='12345', Mailing_Country__c='India',
                                                   Mailing_Street__c='abc', Mailing_ZipCode__c='12345', Business_InternationalAddress__c='xyzabc, abc', Business_City__c='Mumbai', Business_State__c='ABC', Mailing_State__c='ABCDE', FirstName__c='Test', LastName__c='Test', Phone__c='1234567890', Business_Street_Address_1__c='xyz, abcdef', Business_Street_Address_2__c='baker street', Business_Zip_Code__c='12345', Business_Country__c='India', Residence_Country__c='India', Residence_State__c='ABCD', Residence_Street_Address_1__c='XYZ, ABC', 
                                                   Residence_Street_Address_2__c='Baker street', Residence_Zip_Code__c='12345', Residence_City__c='Mumbai', Residence_InternationalAddress__c='xyz, abcd', Business_Street__c='baker street', Business_ZipCode__c='12345');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }
    
     @isTest 
    static void testbatch9() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,acc.Id,'Agent Resignation',system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Agent__c agent = BRS_TestDataFactory.createAgent(acc.Id);
        Temp_History__c temp = new Temp_History__c( Account__c = acc.Id, Agent__c =agent.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = 'Agent' , Change_Type__c = system.label.brs_maintenance_tempCreated,Jurisdiction_International_address_New__c='abc', Office_Jurisdiction_BusinessCity_New__c='abc',
                                                   Office_Jurisdiction_BusinessState_New__c='abc', Office_Jurisdiction_BusinessStreet_New__c='abc', Office_Jurisdiction_BusinessUnit_New__c='abc', Office_Jurisdiction_BusinessZipCode_New__c='12345', Billing_City_New__c='abc', BillingPostalCode_New__c='12345', BillingState_New__c='abc', BillingStreet_New__c='abc', ShippingCity_New__c='abc',
                                                   ShippingPostalCode_New__c='12345', ShippingState_New__c='abc', ShippingStreet_New__c='abc', Principle_Office_International_Address_N__c='abc', Mailing_Jurisdiction_BusinessCity_New__c='abc', Mailing_Jurisdiction_BusinessState_New__c='abc', Mailing_Jurisdiction_BusinessStreet_New__c='abc', Mailing_Jurisdiction_BusinessUnit_New__c='abc',
                                                   Mailing_Jurisdiction_BusinessZipCode_New__c='12345',Mail_JurisdictionInternationaladdress_N__c='abc',Billing_Country_New__c='abc',Shipping_Country_New__c='abc',Mailing_International_Address_New__c='abc');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }

    @isTest 
    static void testbatch5() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Temp_History__c > lstTemp = new List<Temp_History__c >();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_NAICSChange_FilingType ,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        Business_Filing__c bfc1 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_EmailChange_FilingType,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc1);
        Business_Filing__c bfc2 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_name_change_amendment_flow,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc2);
        Business_Filing__c bfc4 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_maintenance_Address2 ,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc4);
        insert lstBusFil;
        Temp_History__c temp1 = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Account , Change_Type__c = system.label.Label_Edited,
                                                   NAICS_Code_New__c = 'abc',NAICS_Code__c='abc1');
        lstTemp.add(temp1);
        Temp_History__c temp2 = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[1].Id , Type__c = system.label.Account , Change_Type__c = system.label.Label_Edited,
                                                   Email_New__c = 'a@a.com',Business_Email_Address__c='abc@abc.com');
        lstTemp.add(temp2);
        Temp_History__c temp3 = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[2].Id , Type__c = system.label.Account , Change_Type__c = system.label.Label_Edited,
                                                   Business_Name_New__c= 'test new',Business_Name__c='test old',Business_Name_in_state_country_New__c= 'test state name new',Business_Name_in_state_country__c='test state name');
        lstTemp.add(temp3);
        Temp_History__c temp = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[3].Id , Type__c = system.label.Account , Change_Type__c = system.label.Label_Edited,Jurisdiction_International_address_New__c='abc', Office_Jurisdiction_BusinessCity_New__c='abc',
                                                   Office_Jurisdiction_BusinessState_New__c='abc', Office_Jurisdiction_BusinessStreet_New__c='abc', Office_Jurisdiction_BusinessUnit_New__c='abc', Office_Jurisdiction_BusinessZipCode_New__c='12345', Billing_City_New__c='abc', BillingPostalCode_New__c='12345', BillingState_New__c='abc', BillingStreet_New__c='abc', ShippingCity_New__c='abc',
                                                   ShippingPostalCode_New__c='12345', ShippingState_New__c='abc', ShippingStreet_New__c='abc', Principle_Office_International_Address_N__c='abc', Mailing_Jurisdiction_BusinessCity_New__c='abc', Mailing_Jurisdiction_BusinessState_New__c='abc', Mailing_Jurisdiction_BusinessStreet_New__c='abc', Mailing_Jurisdiction_BusinessUnit_New__c='abc',
                                                   Mailing_Jurisdiction_BusinessZipCode_New__c='12345',Mail_JurisdictionInternationaladdress_N__c='abc',Billing_Country_New__c='abc',Shipping_Country_New__c='abc',Mailing_International_Address_New__c='abc');
        lstTemp.add(temp);
        insert lstTemp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    } 
    @isTest 
    static void testbatch10() {
        Database.BatchableContext BC;
        
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Temp_History__c > lstTemp = new List<Temp_History__c >();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc1 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_EmailChange_FilingType,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc1);
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_NAICSChange_FilingType ,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Temp_History__c temp2 = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Account , Change_Type__c = system.label.brs_maintenance_tempCreated,
                                                   Email_New__c = 'a@a.com',Business_Email_Address__c='abc@abc.com');
        lstTemp.add(temp2);
        Temp_History__c temp1 = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[1].Id , Type__c = system.label.Account , Change_Type__c = system.label.brs_maintenance_tempCreated,
                                                   NAICS_Code_New__c = 'abc',NAICS_Code__c='abc1');
        lstTemp.add(temp1);
        insert lstTemp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }  
    
    @isTest 
    static void testbatch6() {
        Database.BatchableContext BC;
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_EmailChange_FilingType,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Temp_History__c temp = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Account , Change_Type__c = system.label.brs_maintenance_tempCreated,
                                                   Email_New__c = 'a@a.com',Business_Email_Address__c='abc@abc.com');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }  
    
    @isTest 
    static void testbatch8() {
        Database.BatchableContext BC;
        
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_name_change_amendment_flow,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Temp_History__c temp = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Account , Change_Type__c = system.label.brs_maintenance_tempCreated,
                                                   Business_Name_New__c= 'test new',Business_Name__c='test old',Business_Name_in_state_country_New__c= 'test state name new',Business_Name_in_state_country__c='test state name');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }  
    
    @isTest 
    static void testbatch7() {
        Database.BatchableContext BC;
        
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        insert acc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,acc.Id,system.label.brs_maintenance_Address2 ,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        insert lstBusFil;
        Temp_History__c temp = new Temp_History__c( Account__c =acc.Id,  Business_Filing__c = lstBusFil[0].Id , Type__c = system.label.Account , Change_Type__c = system.label.brs_maintenance_tempCreated,Jurisdiction_International_address_New__c='abc', Office_Jurisdiction_BusinessCity_New__c='abc',
                                                   Office_Jurisdiction_BusinessState_New__c='abc', Office_Jurisdiction_BusinessStreet_New__c='abc', Office_Jurisdiction_BusinessUnit_New__c='abc', Office_Jurisdiction_BusinessZipCode_New__c='12345', Billing_City_New__c='abc', BillingPostalCode_New__c='12345', BillingState_New__c='abc', BillingStreet_New__c='abc', ShippingCity_New__c='abc',
                                                   ShippingPostalCode_New__c='12345', ShippingState_New__c='abc', ShippingStreet_New__c='abc', Principle_Office_International_Address_N__c='abc', Mailing_Jurisdiction_BusinessCity_New__c='abc', Mailing_Jurisdiction_BusinessState_New__c='abc', Mailing_Jurisdiction_BusinessStreet_New__c='abc', Mailing_Jurisdiction_BusinessUnit_New__c='abc',
                                                   Mailing_Jurisdiction_BusinessZipCode_New__c='12345',Mail_JurisdictionInternationaladdress_N__c='abc',Billing_Country_New__c='abc',Shipping_Country_New__c='abc',Mailing_International_Address_New__c='abc');
        insert temp;
        Test.StartTest();
        BRSUpdateAccountUsingMaintenanceFiling Batchclass = new BRSUpdateAccountUsingMaintenanceFiling('select id from Business_Filing__c');
        Batchclass.execute(BC,lstBusFil);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testClosureBusiness1() {
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Account> lstAcc = new List<Account>();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        lstAcc.add(acc);
        Account acc1 = BRS_TestDataFactory.createAcc(system.label.brs_maintenance_domestic,system.label.LLP);
            acc1.BillingCity='Mumbai';
            acc1.BillingState='WA';
            acc1.BillingPostalCode='12345';
            acc1.BillingCountry='India';
            acc1.BillingStreet='Baker street';
        lstAcc.add(acc1);
        Account acc2 = BRS_TestDataFactory.createAcc(system.label.brs_maintenance_domestic,system.label.LLC);
            acc2.BillingCity='Mumbai';
            acc2.BillingState='WA';
            acc2.BillingPostalCode='12345';
            acc2.BillingCountry='India';
            acc2.BillingStreet='Baker street';
        lstAcc.add(acc2);
        //insert lstAcc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,lstAcc[0].Id,system.label.Withdrawal_Label,system.label.LLC,RecordTypeIdMaintenance );
        Business_Filing__c bfc1 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,lstAcc[1].Id,system.label.Renunciation_Status_Report,system.label.LLC,RecordTypeIdMaintenance );
        Business_Filing__c bfc2 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,lstAcc[2].Id,system.label.Dissolution_Label,system.label.LLC,RecordTypeIdMaintenance );
        Business_Filing__c bfc3 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.BRS_FilingStatus_Approved,lstAcc[2].Id,system.label.Dissolution_Label,system.label.LLC,RecordTypeIdMaintenance );
        lstBusFil.add(bfc);
        lstBusFil.add(bfc1);
        lstBusFil.add(bfc2);
        lstBusFil.add(bfc3);
        /*insert lstBusFil;
        Test.StartTest();
        BRSMaintenanceFilingScheduler m = new BRSMaintenanceFilingScheduler();
        String sch = '0 21 3 7 6 ?';
        String jobID = system.schedule('test Maintenance', sch, m);
        Test.stopTest(); */
    }

     @isTest 
    static void testDomestication() {
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Account> lstAcc = new List<Account>();
		Loop__DDP__c template = new Loop__DDP__c(Loop__Object_Name__c = 'Business_Filing__c',
                                                Filing__c='Domestication',
                                                Status__c='Approved',
                                                Is_Active__c=true);
        insert template;
        Loop__DDP_Integration_Option__c deloption = new Loop__DDP_Integration_Option__c(Loop__DDP__c=template.id,
                                                                                       Name='attach');
        insert deloption;
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        lstAcc.add(acc);
        Account acc2 = BRS_TestDataFactory.createAcc(system.label.brs_maintenance_domestic,system.label.LLC);
        acc2.Status__c = System.Label.brs_Domistication_Accepted_Domestication_Pending;
            acc2.BillingCity='Mumbai';
            acc2.BillingState='WA';
            acc2.BillingPostalCode='12345';
            acc2.BillingCountry='India';
            acc2.BillingStreet='Baker street';
        lstAcc.add(acc2);
        insert lstAcc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,lstAcc[0].Id,system.label.Domestication_Label,system.label.LLC,RecordTypeIdMaintenance );
        bfc.Effective_Date__c = system.today();
        lstBusFil.add(bfc);
        insert lstBusFil;
        Business_History__c busHis = BRS_TestDataFactory.createBusHistory(lstBusFil[0].Id,lstAcc[0].Id,lstAcc[1].Id);
        insert busHis;
        Test.StartTest();
        BRSMaintenanceFilingScheduler m = new BRSMaintenanceFilingScheduler();
        String sch = '0 21 3 7 6 ?';
        String jobID = system.schedule('test Maintenance', sch, m);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testConversion() {
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Account> lstAcc = new List<Account>();
		Loop__DDP__c template = new Loop__DDP__c(Loop__Object_Name__c = 'Business_Filing__c',
                                                Filing__c='Conversion',
                                                Status__c='Approved',
                                                Is_Active__c=true);
        insert template;
        Loop__DDP_Integration_Option__c deloption = new Loop__DDP_Integration_Option__c(Loop__DDP__c=template.id,
                                                                                       Name='attach');
        insert deloption;
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLP);
        acc.Description = 'test';
        lstAcc.add(acc);
        Account acc2 = BRS_TestDataFactory.createAcc(system.label.brs_maintenance_domestic,system.label.LLP);
        acc2.Status__c = System.Label.brs_Domistication_Accepted_Domestication_Pending;
        lstAcc.add(acc2);
        insert lstAcc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,lstAcc[1].Id,system.label.Conversion_Label,system.label.LLC,RecordTypeIdMaintenance );
        bfc.Effective_Date__c = system.today();
        lstBusFil.add(bfc);
        insert lstBusFil;
        Business_History__c busHis = BRS_TestDataFactory.createBusHistory(lstBusFil[0].Id,lstAcc[0].Id,lstAcc[1].Id);
        insert busHis;
        Test.StartTest();
        BRSMaintenanceFilingScheduler m = new BRSMaintenanceFilingScheduler();
        String sch = '0 21 3 7 6 ?';
        String jobID = system.schedule('test Maintenance', sch, m);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testMerger() {
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        List<Account> lstAcc = new List<Account>();
		Loop__DDP__c template = new Loop__DDP__c(Loop__Object_Name__c = 'Business_Filing__c',
                                                Filing__c='Merger',
                                                Status__c='Approved',
                                                Is_Active__c=true);
        insert template;
        Loop__DDP_Integration_Option__c deloption = new Loop__DDP_Integration_Option__c(Loop__DDP__c=template.id,
                                                                                       Name='attach');
        insert deloption;
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLc);
        acc.Description = 'test';
            acc.BillingCity='Mumbai';
            acc.BillingState='WA';
            acc.BillingPostalCode='12345';
            acc.BillingCountry='India';
            acc.BillingStreet='Baker street';
        lstAcc.add(acc);
        Account acc2 = BRS_TestDataFactory.createAcc(system.label.brs_maintenance_domestic,system.label.LLP);
        acc2.Status__c = System.Label.brs_Domistication_Accepted_Domestication_Pending;
        acc2.BillingCity='Mumbai';
            acc2.BillingState='WA';
            acc2.BillingPostalCode='12345';
            acc2.BillingCountry='India';
            acc2.BillingStreet='Baker street';
        lstAcc.add(acc2);
        insert lstAcc;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Label_Pending_Filing_1,lstAcc[0].Id,system.label.Merger_Label,system.label.LLC,RecordTypeIdMaintenance );
        bfc.Effective_Date__c = system.today();
        lstBusFil.add(bfc);
        insert lstBusFil;
        Business_History__c busHis = BRS_TestDataFactory.createBusHistory(lstBusFil[0].Id,lstAcc[0].Id,lstAcc[1].Id);
        insert busHis;
        Test.StartTest();
        BRSMaintenanceFilingScheduler m = new BRSMaintenanceFilingScheduler();
        String sch = '0 21 3 7 6 ?';
        String jobID = system.schedule('test Maintenance', sch, m);
        Test.stopTest(); 
    }
}