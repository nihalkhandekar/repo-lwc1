@IsTest
public class BusinessFilingTriggerHelper_Test {
    @TestSetup
    static void testSetup() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();//Annual Report / First Report
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();
        List<Business_Filing__c> busFileLst2 = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Amendment';
        filing.Amendment_Type__c ='Amend Name';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Effective_Date__c = system.today().addDays(30);
        filing.Effective_Date_Time__c = system.now();
        filing.Status__c='Approved';
        filing.Citizenship__c='Domestic';
        busFileLst.add(filing);
        
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdMaintenance;
        filing2.Account__c=testAcc1.Id;
        filing2.Filing_Fee__c=30;
        filing2.Work_Order__c=workorder.Id;
        filing2.Type__c = 'Amendment';
        filing2.Amendment_Type__c ='Amend Name';
        filing2.Filing_Date__c = System.Today();
        filing2.Due_Date__c = (System.today() + 5);
        filing2.Effective_Date__c = system.today().addDays(30);
        filing2.Effective_Date_Time__c = system.now();
        filing2.Status__c=system.label.Label_Pending_Filing_1;
        filing2.Citizenship__c='Domestic';
        busFileLst.add(filing2);
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='Non-Stock', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',State_or_Territory_Formation__c='Washington');
        insert ac; 
        Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=RecordTypeIdCloseReinstate ;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = '  ';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Filing_Date__c = System.Today().addDays(-30);
        filing3.Due_Date__c = (System.today() + 5);
        filing3.Effective_Date__c = system.today().addDays(30);
        filing3.Effective_Date_Time__c = system.now();
        filing3.Status__c=System.label.Approved;
        filing3.Filing_Date__c=System.today();
        filing3.Mailing_Unit__c = 'test';
        filing3.Mailing_Street__c = 'test';
        filing3.Mailing_City__c = 'test';
        filing3.Mailing_State__c = 'test';
        filing3.Mailing_Zip_Code__c='test';
        filing3.Mailing_Country__c='test';
        busFileLst.add(filing3);
        insert busFileLst;
        busFileLst[1].Status__c=system.label.Approved;
        busFileLst2.add(busFileLst[1]);
        busFileLst2.add(busFileLst[2]);
        update busFileLst2;
        
        //Account testAcc2 = BRS_TestDataFactory.createAccountObject();//Annual Report / First Report
        //Contact con2 = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        /*Work_Order__c workorder2 =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff2 = BRS_TestDataFactory.onOffCustomSetting();
        List<Business_Filing__c> busFileLst3 = new List<Business_Filing__c>();
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
		Business_Filing__c filing4 = new Business_Filing__c();
        filing4.recordtypeid=RecordTypeIdAnnual;
        filing4.Account__c=testAcc1.Id;
        filing4.Filing_Fee__c=30;
        filing4.Work_Order__c=workorder2.Id;
        filing4.Type__c = System.Label.Annual_Report_Label;
        filing4.Amendment_Type__c ='Amend Name';
        filing4.Filing_Date__c = System.Today().addDays(-30);
        filing4.Due_Date__c = (System.today() + 5);
        filing4.Status__c=System.Label.BRS_FilingStatus_Rejected;
        busFileLst3.add(filing4);
		insert busFileLst3;*/
        
        
        BRS_TestDataFactory.createTempHistoryObject2(filing.Id,null,testAcc1.Id,'Agent','Created');
        BRS_TestDataFactory.createTempHistoryObject2(filing.Id,null,testAcc1.Id,'Account','Deleted');
    }
    
    testmethod public static void processMaintenanceFilings() {
        test.startTest();
        Business_filing__c filing = [select id, Type__c, Status__c from Business_filing__c limit 1];
        filing.Status__c='Approved';
        filing.Type__c=system.label.brs_AgentChange_FilingType;
        update filing;
        Business_filing__c filing1 = [select id, Type__c, Status__c from Business_filing__c limit 1];
        filing1.Status__c='Submitted - Agency review pending';
        filing1.Type__c='Change of Agent';
        update filing1;
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing.Id, filing);
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing1.Id, filing1);
        
            Temp_History__c temp = new Temp_History__c();
            temp.Business_Filing__c=filing1.id;
            temp.Change_Type__c=system.label.brs_maintenance_tempCreated;
            temp.Phone__c = '12121212';
            temp.FirstName__c = 'testf';
            temp.LastName__c = 'testfL';
            temp.Name__c = 'testfName';
            temp.Email__c = 'testf@test.com';
            temp.Business_City__c = 'Mumbai';
            temp.Business_Street_Address_1__c = '100 st';
            temp.Business_Street_Address_2__c = 'road no.4';
            temp.Business_Zip_Code__c = '12345';
            temp.Business_State__c = 'ST';
            temp.Business_Country__c = 'United States';
            temp.Business_InternationalAddress__c = '200 ST';
            temp.Residence_City__c = 'NY';
            temp.Residence_Street_Address_1__c = '300 ST';
            temp.Residence_Street_Address_2__c = '300 ST';
            temp.Residence_Zip_Code__c = '12345';
            temp.Residence_State__c = 'CT';
            temp.Residence_Country__c = 'US';
            temp.Mailing_City__c = 'NY';
            temp.Mailing_Street_Address_1__c = '300 ST';
            temp.Mailing_Street_Address_2__c = '300 ST';
            temp.Mailing_Zip_Code__c = '12345';
            temp.Mailing_State__c = 'CT';
            temp.Mailing_Country__c = 'US';
            temp.temp_type__c = 'Individual';
            //temp.Business_Id__c = 
            insert temp;
        	Temp_History__c th = [SELECT Id, Business_Filing__c,Change_Type__c,Phone__c,FirstName__c,
                                 LastName__c,Name__c,Email__c,Business_City__c,Business_InternationalAddress__c,
                                 Residence_City__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,
                                 Residence_Zip_Code__c,Residence_State__c,Residence_Country__c,Mailing_City__c,
                                 Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Zip_Code__c,
                                 Mailing_State__c,Mailing_Country__c FROM Temp_History__c WHERE Id=:temp.Id];

        BusinessFilingTriggerHelper.processMaintenanceFilings(newItems, oldItems);
        test.stopTest();
    }
    
    testmethod public static void processMaintenanceFilings1() {
        Id profileId = [select id from profile where name='System Administrator'].id;
        User user=BRS_TestDataFactory.createUser(profileId);
        
        System.runAs(user){
            Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Business_filing__c filing = [select id, Type__c, Status__c,Account__c from Business_filing__c limit 1];
            Account acc=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='LLP', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                    ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                    sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',State_or_Territory_Formation__c='Washington');
            insert acc;
            filing.Account__c=acc.Id;
            filing.Citizenship__c='Foreign';
            filing.Business_Type__c='LLP';
            filing.Status__c='Submitted - Agency review pending';
            filing.Type__c='Name Change Amendment';
            update filing;
            Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
            oldItems.put(filing.Id, filing);
            
            Business_filing__c filing1 = [select id,  Status__c,Citizenship__c,Business_Type__c,Type__c from Business_filing__c where Id=:filing.Id limit 1];
            filing1.Status__c='Approved';
            filing1.Type__c='Name Change Amendment';
            update filing1;
            Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
            newItems.put(filing1.Id, filing1);           
            
            Temp_History__c temp = new Temp_History__c();
            temp.Business_Filing__c=filing.id;
            temp.Type__c=system.label.Account;
            temp.Account__c=acc.Id;
            temp.Business_Name_New__c='Test John';
            temp.Business_Name_in_state_country_New__c='Test';
            insert temp;            
            
            test.startTest();
            BusinessFilingTriggerHelper.processMaintenanceFilings(newItems, oldItems);
            test.stopTest();
        }
    }
    
    
    testmethod public static void processBusinessFilingUpdateOnAccountAnnual() {
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Business_filing__c filing = [select id, Type__c, Status__c,Account__c from Business_filing__c limit 1];
        filing.Type__c=Label.Annual_Report_Label;
        filing.RecordTypeId=RecordTypeIdAnnual;
        filing.Status__c='In-Progress';
        update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        Business_filing__c filing1=new Business_filing__c();
        filing1.Id=filing.Id;
        filing1.Type__c=Label.Annual_Report_Label;
        filing1.RecordTypeId=RecordTypeIdAnnual;
        filing1.Status__c='Approved';
        update filing1;
        
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing1.Id, filing1);        
        
        boolean IsInsert = false;
        test.startTest();
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, IsInsert);
        test.stopTest();
    }
    testmethod public static void processBusinessFilingUpdateOnAccountAnnual1() {
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Business_filing__c filing = [select id, Type__c, Status__c,Account__c from Business_filing__c limit 1];
        filing.Type__c=Label.Annual_Report_Label;
        filing.RecordTypeId=RecordTypeIdAnnual;
        filing.Business_Type__c='LLC';
        update new Account(Id=filing.Account__c,Business_Type__c='LLC',ShippingStreet='test');                
        update filing;
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing.Id, filing);
        filing.status__c='Past Due';         
        update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        boolean IsInsert = false;
        test.startTest();
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, IsInsert);
        test.stopTest();
    }
    testmethod public static void processBusinessFilingUpdateOnAccountAnnual2() {
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Business_filing__c filing = [select id, Type__c, Status__c,Account__c,Business_Type__c from Business_filing__c limit 1];
        filing.Type__c=Label.Annual_Report_Label;
        filing.RecordTypeId=RecordTypeIdAnnual;
        
        update filing;
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing.Id, filing);
        filing.status__c='Past Due';    
        update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        boolean IsInsert = false;
        test.startTest();
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, IsInsert);
        test.stopTest();
    }
    
    testmethod public static void updateFilingTypeAndFee() {        
        
        Business_filing__c filing = [select id, Citizenship__c,Due_Year__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c from Business_filing__c limit 1];
        filing.Include_Expedited_Service__c=true;
        filing.Total_Authorized_Shares__c=0;
        update filing;
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);        
        
        Master_Fee__c mf = new Master_Fee__c();
        mf.Amount__c=80.00;
        mf.External_ID__c ='MF-0000000061';
        mf.Status__c='Active';
        mf.Type__c=filing.Type__c;
        mf.Start_Date__c=System.today();
        mf.Service_Type__c=System.Label.CertificateExpediteFee;
        mf.Citizenship__c=filing.Citizenship__c;
        mf.Business_Type__c=filing.Business_Type__c;
        insert mf;
        
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, oldItems);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, NULL);
        test.stopTest();
    }
    testmethod public static void updateFilingTypeAndFee1() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        
        Business_filing__c filing = [select id,Source__c,Due_Year__c, Citizenship__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c,Account__c from Business_filing__c limit 1];
        filing.Include_Expedited_Service__c=FALSE;
        filing.Total_Authorized_Shares__c=0;
        filing.recordTypeId=RecordTypeIdBusiness;
        filing.Type__c='Business Formation';
        filing.Business_Type__c='Insurance Stock';
        update new Account(Id=filing.Account__c,Business_Type__c='Insurance Stock',Total_Authorized_Shares__c=0);
        update filing;
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);        
        
        Master_Fee__c mf = new Master_Fee__c();
        mf.Amount__c=80.00;
        mf.External_ID__c ='MF-0000000061';
        mf.Status__c='Active';
        mf.Type__c=filing.Type__c;
        mf.Start_Date__c=System.today();
        mf.Service_Type__c=System.Label.CertificateExpediteFee;
        mf.Citizenship__c=filing.Citizenship__c;
        mf.Business_Type__c=filing.Business_Type__c;
        insert mf;
        filing.Include_Expedited_Service__c=false;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, oldItems);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, null);
        test.stopTest();
    }
    
    
    testmethod public static void updateCitizenship() {
        Account testAcc = BRS_TestDataFactory.createAccountObject();
        Business_filing__c filing = [select id, Type__c, Status__c, Source__c, RecordTypeId, Account__c,Work_Order__c from Business_filing__c limit 1];
        List<Business_filing__c> newItems = new List<Business_filing__c>();        
        newItems.add(filing);
        filing.Account__c=testAcc.Id;
        update filing;
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateCitizenship(newItems, oldMap);
        test.stopTest();
    }    
    testmethod public static void updateTotalShare() {
        Business_filing__c filing = [select id,Total_Authorized_Shares_on_Account__c, Total_Authorized_Shares__c,Type__c, Status__c, Account__c,Business_Type__c from Business_filing__c limit 1];
        Account acc= new Account();
        acc.Total_Authorized_Shares__c=10;
        acc.Business_Type__c='B Corp';
        acc.Election_of_Bcorp_Status__c=true;
        acc.Id=filing.Account__c;
        acc.Citizenship__c='Domestic';
        update acc;
        
        filing.Total_Authorized_Shares__c=1000000000;
        filing.Business_Type__c='B Corp';
        update filing;
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        System.debug('@@Total_Authorized_Shares__c'+filing.Total_Authorized_Shares__c);
        System.debug('@@Total_Authorized_Shares__c on account'+filing.Total_Authorized_Shares_on_Account__c);
        BusinessFilingTriggerHelper.updateTotalShare(newFilingList, oldMap);
        test.stopTest();
    }
    testmethod public static void updateTotalShare1() {
        Business_filing__c filing = [select id, Type__c, Status__c, Account__c,Business_Type__c from Business_filing__c limit 1];
        Account acc= new Account();
        acc.Total_Authorized_Shares__c=0;
        acc.Business_Type__c='B Corp';
        acc.Election_of_Bcorp_Status__c=true;
        acc.Id=filing.Account__c;
        update acc;
        
        filing.Total_Authorized_Shares__c=100;
        filing.Business_Type__c='B Corp';
        update filing;
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateTotalShare(newFilingList, oldMap);
        test.stopTest();
    }
    
    testmethod public static void checkPaymentVerification() {
        Business_filing__c filing = [select id, Type__c, Status__c,Work_Order__c,Account__c from Business_filing__c limit 1];
        update new Account(Id=filing.Account__c,Began_Transacting_in_CT__c=System.today()-1000);
        filing.Status__c='In-Progress';
        update filing;
        Map<Id, Business_filing__c> oldFilingMap = new Map<Id, Business_filing__c>();
        oldFilingMap.put(filing.Id, filing);
        Business_filing__c orgfiling = [select id, Type__c, Status__c,Work_Order__c,Account__c,Days_between_Filing_and_Transacting__c from Business_filing__c where Id=:filing.Id limit 1];
        
        List<Business_filing__c> newBusinessFilings = new List<Business_filing__c>();
        
        orgfiling.Status__c='Approved';
        update orgfiling;
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();
        
        Business_Filing__c filing100 = new Business_Filing__c();
        filing100.recordtypeid=RecordTypeIdMaintenance;
        filing100.Account__c=filing.Account__c;
        filing100.Filing_Fee__c=30;
        filing100.Work_Order__c=filing.Work_Order__c;
        filing100.Type__c = 'Business Registration';
        //filing100.Amendment_Type__c ='Amend Name';
        filing100.Filing_Date__c = System.Today().addDays(-100);
        filing100.Due_Date__c = (System.today() + 5);
        filing100.Effective_Date__c = system.today().addDays(30);
        filing100.Effective_Date_Time__c = system.now();
        filing100.Status__c='Approved';
        filing100.Citizenship__c='Domestic';
        busFileLst.add(filing100);
        insert busFileLst;
        
        newBusinessFilings.add(orgfiling);
        test.startTest();
        BusinessFilingTriggerHelper.checkPaymentVerification(newBusinessFilings, oldFilingMap);
        BusinessFilingTriggerHelper.createForeignInvestigationCase(newBusinessFilings, oldFilingMap);
         BusinessFilingTriggerHelper.createForeignInvestigationCase(busFileLst, null);
        test.stopTest();
    }
    
    testmethod public static void updateAccountPin() {
        Business_Filing__c filing = [select id, Type__c, Status__c from Business_Filing__c limit 1];
        List<Business_Filing__c> newFilingList = new List<Business_Filing__c>();
        newFilingList.add(filing);
        Map<Id, Business_Filing__c> oldMap = new Map<Id, Business_Filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateAccountPin(newFilingList, oldMap);
        test.stopTest();
    }
    
    
    testmethod public static void createBusinessFilingRecordType() {
        Business_filing__c filing = [select id, Type__c, Status__c, Account__r.Business_Type__c,Account__r.Citizenship__c,Account__r.Total_Authorized_Shares__c, Account__c,Account__r.Name from Business_filing__c limit 1];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);
        test.startTest();
        BusinessFilingTriggerHelper.createBusinessFilingRecordType(newItems);
        test.stopTest();
    }
    
    
    testmethod public static void checkOldFilingForFormations() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        Business_filing__c filing = [select id, Type__c, Status__c, Account__c from Business_filing__c limit 1];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        filing.Type__c='Business Formation';
        filing.RecordTypeId=RecordTypeIdBusiness;
        filing.Status__c='Pending Filing';
        update new Account(Id=filing.Account__c,Date_Registration__c=System.today());
        update filing;
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        
        filing.Status__c='Approved';
        update filing;
        newItems.add(filing);
        test.startTest();
        BusinessFilingTriggerHelper.checkOldFilingForFormations(newItems, oldMap);
        test.stopTest();
    }
    
    testmethod public static void updateReservedAccountsForRejectedFilings() {
        Business_filing__c filing = [select id, Type__c, Status__c from Business_filing__c limit 1];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.updateReservedAccountsForRejectedFilings(newItems, oldMap);
        test.stopTest();
    }   
    
    testmethod public static void createNameHistoryTableRecs() {
        Business_filing__c filing = [select id, Type__c, Status__c,Account__c from Business_filing__c limit 1];
        Update new Account(Id=filing.Account__c,Business_Type__c='LLC', Status__c='Forfeited',Mailing_Address__c='221B Baker Street, London',ShippingStreet = 'Baker Street',BillingStreet = 'Baker Street');
        Temp_History__c temp1 = new Temp_History__c();
        temp1.Business_Filing__c=filing.id;
        temp1.Change_Type__c=system.label.Deleted;
        temp1.Business_Name_New__c='oiooyio';
        temp1.Type_of_Update__c=System.label.Name;
        insert temp1; 
        filing.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.label.CloseReinstateLabel,Schema.Business_Filing__c.getSObjectType());
        filing.Type__c=System.label.brs_Reinstatement;
        filing.Sub_Type__c = system.label.withAnnual_NameChange;
        filing.Status__c = 'In-Progress';
        filing.Business_Type__c='LLC';
        update filing;
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        Business_filing__c filing1 =new Business_filing__c();
        filing1=filing;
        filing1.Status__c='Approved';
        update filing1;
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing1.Id, filing1);
        test.startTest();
        BusinessFilingTriggerHelper.createNameHistoryTableRecs(newItems, oldMap);
        test.stopTest();
    }
    
    testmethod public static void LinkBusinessOnApproval() {
        Business_filing__c filing = [select id, Type__c, Status__c from Business_filing__c limit 1];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.LinkBusinessOnApproval(newItems, oldMap);
        test.stopTest();
    }
    
    testmethod public static void refundRejectedOnlineFilings() {
        try{
        OnOff_Filing_Auto_Refund__c onOffSwich = OnOff_Filing_Auto_Refund__c.getall().values()[0];
        onOffSwich.Auto_Refund_Business_Filing__c=true;
        update onOffSwich;
        Business_filing__c filing = [select id, Type__c, Status__c,Work_Order__c from Business_filing__c limit 1];
        update new Work_Order__c(Id=filing.Work_Order__c,Status__c='Completed',Source__c='Online');
        BRS_TestDataFactory.createStripeTransactionObject(filing.Work_Order__c);
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        Id recordTypeIdCharge = Schema.SObjectType.bt_stripe__Transaction__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId();
        txn.RecordTypeId = recordTypeIdCharge;
        txn.Work_Order__c = filing.Work_Order__c;
        txn.bt_stripe__Payment_Status__c = 'Captured';
        txn.bt_stripe__Transaction_Type__c = 'Normal';
        txn.bt_stripe__Transaction_Status__c = 'Completed';
        txn.bt_stripe__Authorize_Only__c = true;
        txn.bt_stripe__Currency_ISO__c='USD';
        txn.bt_stripe__Amount__c = 100;
        insert txn;
            
        filing.Status__c='Rejected';
             update filing;
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        oldMap.put(filing.Id, filing);
        test.startTest();
        BusinessFilingTriggerHelper.refundRejectedOnlineFilings(newFilingList,oldMap);
        BusinessFilingTriggerHelper.processBlackthornRefund(oldMap.KeySet());
        test.stopTest();
        } catch(Exception e){
            
        }
    }
    
    testmethod public static void updateTotalShareBRSFee() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        
        Business_filing__c filing = [select id, Type__c, Status__c from Business_filing__c limit 1];
        Map<Id, Business_filing__c> oldMap = new Map<Id, Business_filing__c>();
        filing.Type__c='Business Formation';
        filing.RecordTypeId=RecordTypeIdBusiness;
        filing.Total_Authorized_Shares__c=10;
        update filing;
        oldMap.put(filing.Id, filing);
        Franchise_Tax__mdt franchisetax = new Franchise_Tax__mdt();
        franchisetax.Type__c='BFR';
        franchisetax.Max_Value__c=100;
        List<Franchise_Tax__mdt> mdtlst = new List<Franchise_Tax__mdt>();
        mdtlst.add(franchisetax);
        test.startTest();
        BusinessFilingTriggerHelper.updateTotalShareBRSFee(filing, oldMap, mdtlst);
        franchisetax.Max_Value__c=1;
        mdtlst.add(franchisetax);
        BusinessFilingTriggerHelper.updateTotalShareBRSFee(filing, oldMap, mdtlst);
        test.stopTest();
    }
    
    
    testmethod public static void rejectAccountOnFilingReject() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Business_filing__c filing = [select id, Type__c, Status__c from Business_filing__c limit 1];
        filing.Type__c =System.label.Business_Registration_Label;
        filing.RecordTypeId=RecordTypeIdBusiness;
        filing.Status__c=System.Label.Rejected;
        update filing;
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        test.startTest();
        BusinessFilingTriggerHelper.rejectAccountOnFilingReject(newFilingList);
        test.stopTest();
    }
    testmethod public static void processMostRecentFilingDateTest() {
        Business_filing__c filing = [select id, Type__c, Status__c,Work_Order__c,Account__c,Filing_Date__c from Business_filing__c limit 1];
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        BusinessFilingTriggerHelper.processMostRecentFilingDate(new Map<Id,Business_filing__c>(newFilingList), new Map<Id,Business_filing__c>(newFilingList));
        filing.Status__c='In-Progress';
        update filing;
        BusinessFilingTriggerHelper.processMostRecentFilingDate(new Map<Id,Business_filing__c>(newFilingList), new Map<Id,Business_filing__c>(newFilingList));
        update new Account(Id=filing.Account__c,Status__c='Expired');
        BusinessFilingTriggerHelper.processMostRecentFilingDate(new Map<Id,Business_filing__c>(newFilingList), new Map<Id,Business_filing__c>(newFilingList));
        
    }
    testmethod public static void processMostRecentFilingDateTest1() {
        
        Business_filing__c filing = [select id, Type__c, Status__c,Work_Order__c,Account__c,Filing_Date__c from Business_filing__c limit 1];        
        update new Account(Id=filing.Account__c,Status__c='Expired');
        List<Business_filing__c> newFilingList = new List<Business_filing__c>();
        newFilingList.add(filing);
        BusinessFilingTriggerHelper.processMostRecentFilingDate(new Map<Id,Business_filing__c>(newFilingList), new Map<Id,Business_filing__c>(newFilingList));
        
        
    }
    testmethod public static void processBusinessFilingUpdateOnAccountFormationLLC() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        
        Business_filing__c filing = [select id,Source__c, Citizenship__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c,Account__c from Business_filing__c limit 1];
        filing.Business_Type__c='LLC';
        update new Account(Id=filing.Account__c,Business_Type__c='LLC',ShippingStreet='test');
        filing.Include_Expedited_Service__c=FALSE;
        filing.Total_Authorized_Shares__c=0;
        filing.recordTypeId=RecordTypeIdBusiness;
        filing.Type__c='Business Formation';
        filing.Status__c='In-Progress';
        update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        Business_filing__c filing1=new Business_filing__c();
        filing1.Id=filing.Id;
        filing1.Status__c='Approved';
        filing1.Type__c=filing.Type__c;
        filing1.Account__c=filing.Account__c;
        update filing1;
        
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing1.Id, filing1);
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, false);
        update new Account(Id=filing.Account__c,Date_Registration__c=System.today());
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, false);
    }
    testmethod public static void processBusinessFilingUpdateOnAccountFormation() {
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
        Business_filing__c filing = [select id,Source__c, Citizenship__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c,Account__c from Business_filing__c limit 1];
        filing.Include_Expedited_Service__c=FALSE;
        filing.Total_Authorized_Shares__c=0;
        filing.recordTypeId=RecordTypeIdBusiness;
        filing.Type__c='Business Formation';
        filing.Status__c='In-Progress';
        update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        Business_filing__c filing1=new Business_filing__c();
        filing1.Id=filing.Id;
        filing1.Status__c='Approved';
        filing1.Type__c=filing.Type__c;
        filing1.Account__c=filing.Account__c;
        update filing1;
        
        Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing1.Id, filing1);
        
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, false);
        update new Account(Id=filing.Account__c,Date_Registration__c=System.today());
        BusinessFilingTriggerHelper.processBusinessFilingUpdateOnAccount(newItems, oldItems, false);
    }   
    
    testmethod public static void updateForfeitureDateOnAccount() {
        Test.startTest();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        system.debug('line no 28 ' +ac.Date_Intend_Forfeited__c );
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Administrative Dissolution';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Notice of Intent to Dissolve/Revoke';
        filing.Date_Intend_Forfeited__c =System.today();
        insert filing;
        Test.stopTest();
    }
    
    testmethod public static void updateForfeitureDateOnAccount2() {
        Test.startTest();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Administrative Dissolution';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Notice of Intent to Dissolve/Revoke';
        filing.Date_Intend_Forfeited__c =System.today();
        lstFile.add(filing);
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdCloseReinstate ;
        filing2.Account__c=ac.Id;
        filing2.Filing_Fee__c=30;
        filing2.Type__c = 'Administrative Dissolution';
        filing2.Citizenship__c = ac.citizenship__c;
        filing2.business_type__c = ac.business_type__c;
        filing2.Filing_Date__c = System.Today().addDays(-30);
        filing2.Due_Date__c = (System.today() + 5);
        filing2.Status__c=System.label.Approved;
        filing2.Filing_Date__c=System.today();
        filing2.Filing_Type__c ='Notice of Intent to Dissolve/Revoke';
        filing2.Date_Intend_Forfeited__c =System.today().addDays(2);
        lstFile.add(filing2);
        insert lstFile;
    }
    
    testmethod public static void processWithdrwalUpdates_test() {
        Test.startTest();
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='LLC', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',status__c = system.label.Withdrawn,State_or_Territory_Formation__c='Washington');
        insert ac; 
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Withdrawal';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Mailing_Unit__c = 'test';
        filing.Mailing_Street__c = 'test';
        filing.Mailing_City__c = 'test';
        filing.Mailing_State__c = 'test';
        filing.Mailing_Zip_Code__c='test';
        filing.Mailing_Country__c='test';
        insert filing;
        Business_Filing__c busFile = [Select id,Mailing_Country__c,Mailing_Zip_Code__c,Mailing_State__c,Mailing_City__c,Mailing_Street__c,Mailing_Unit__c,Type__c,Citizenship__c,RecordTypeId,Business_Type__c,status__c,Account__c,Mailing_Address__c from Business_Filing__c where id =: filing.Id];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(busFile);
        BusinessFilingTriggerHelper.processWithdrwalUpdates(newItems);
        Test.stopTest();
    }
    testmethod public static void processWithdrwalUpdates_test2() {
        Test.startTest();
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='Stock', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness, Description='abc product',State_or_Territory_Formation__c='Washington');
        insert ac; 
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Withdrawal';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Mailing_Unit__c = 'test';
        filing.Mailing_Street__c = 'test';
        filing.Mailing_City__c = 'test';
        filing.Mailing_State__c = 'test';
        filing.Mailing_Zip_Code__c='test';
        filing.Mailing_Country__c='test';
        insert filing;
        Business_Filing__c busFile = [Select id,Mailing_Country__c,Mailing_Zip_Code__c,Mailing_State__c,Mailing_City__c,Mailing_Street__c,Mailing_Unit__c,Type__c,Citizenship__c,RecordTypeId,Business_Type__c,status__c,Account__c,Mailing_Address__c from Business_Filing__c where id =: filing.Id];
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(busFile);
        BusinessFilingTriggerHelper.processWithdrwalUpdates(newItems);
        Test.stopTest();
    }
    testmethod public static void updateFilingTypeAndFee2() {
        /*Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();        
        
        Business_filing__c filing = [select id,Source__c,Due_Year__c, Citizenship__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c,Account__c from Business_filing__c limit 1];
        filing.Include_Expedited_Service__c=FALSE;
        filing.Total_Authorized_Shares__c=0;
        filing.recordTypeId=RecordTypeIdBusiness;
        filing.Type__c='Annual Report';
        filing.Sub_type__c=Null;
        filing.Business_Type__c='LLC';
        filing.Citizenship__c='Domestic';
        filing.Due_Date__c=System.today().addYears(-10);
        update new Account(Id=filing.Account__c,Business_Type__c='LLC',Total_Authorized_Shares__c=0,ShippingStreet='test',Citizenship__c='Domestic');
        update filing;
        Business_filing__c filing1=[Select id,Source__c,Due_Year__c,Filing_Date__c, Citizenship__c,Business_Type__c,Sub_type__c,Type__c, Status__c,Include_Expedited_Service__c,Filing_Fee__c,Filing_Type__c,Franchise_Tax__c,Total_Authorized_Shares__c,Total_Fee__c,Account__c from Business_filing__c where Id=:filing.Id];
        
        filing=filing1;
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);        
        System.debug('@@@@@MF'+filing);
        
        Master_Fee__c mf = new Master_Fee__c();
        mf.Amount__c=80.00;
        mf.External_ID__c ='MF-0000000061';
        mf.Status__c='Active';
        mf.Type__c=filing.Type__c;
        mf.Start_Date__c=System.today();
        mf.Service_Type__c=System.Label.CertificateExpediteFee;
        mf.Citizenship__c=filing.Citizenship__c;
        mf.Business_Type__c=filing.Business_Type__c;
        mf.Sub_type__c=filing.Sub_type__c;
        insert mf;
        filing.Include_Expedited_Service__c=false;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account ac=new Account(Name = 'TestMergerFiling',Citizenship__c = 'Domestic',Business_Type__c ='LLC', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdAcc, Description='abc product',State_or_Territory_Formation__c='Washington');
        insert ac; 
        Id RecordTypeIdDomestication = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        Business_Filing__c mergerfiling = new Business_Filing__c();
        mergerfiling.recordtypeid=RecordTypeIdDomestication ;
        mergerfiling.Account__c=ac.Id;
        mergerfiling.Filing_Fee__c=30;
        mergerfiling.Type__c = 'Merger';
        mergerfiling.Citizenship__c = ac.citizenship__c;
        mergerfiling.business_type__c = ac.business_type__c;
        mergerfiling.Filing_Date__c = System.Today().addDays(-30);
        mergerfiling.Due_Date__c = (System.today() + 5);
        mergerfiling.Status__c=System.label.Approved;
        mergerfiling.Filing_Date__c=System.today();
        insert mergerfiling;
        newItems.add(mergerfiling); 
        oldItems.put(mergerfiling.Id, mergerfiling);
        
        test.startTest();
        System.debug('@@@@@MF'+mf);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, oldItems);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, null);
        filing.Filing_Date__c=date.newinstance(2021, 7,13);
        update filing;
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, oldItems);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, null);
        filing.Filing_Date__c=null;
         filing.Status__c='Due';
        update filing;
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, oldItems);
        BusinessFilingTriggerHelper.updateFilingTypeAndFee(newItems, null);
        */ //test.stopTest(); 
    }
    
    
    testmethod public static void TestupdateAnnualReportDueDateOnRejection() {
        try{
        test.startTest();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
		Business_filing__c filing = [select id, Type__c, Status__c,Account__c from Business_filing__c limit 1];
        filing.Filing_Fee__c=50;
        filing.Account__c=ac.id;
        filing.Status__c='Rejected';
        filing.Type__c=System.Label.Annual_Report_Label;
        update filing;
        List<Business_filing__c> newItems = new List<Business_filing__c>();
        newItems.add(filing);
        //filing.Filing_Fee__c=150;    
        //update filing;
        Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing.Id, filing);
        boolean IsInsert = false;
        
        BusinessFilingTriggerHelper.updateAnnualReportDueDateOnRejection(newItems, oldItems);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
        testmethod public static void updateFeeforMergerConversionandDoemsticationTest(){
            try{
                
        Master_Fee__c masterfee1 = new Master_Fee__c();
        masterfee1.Type__c = 'Business Formation';    
        masterfee1.Status__c=System.Label.ACTIVE;
        masterfee1.Start_Date__c=System.today().addDays(-2);
        //masterfee1.ProcessingDate = System.today();  
        masterfee1.End_Date__c=null;
        masterfee1.Filing_Type__c='Standard';
        masterfee1.Service_Type__c=System.Label.FilingExpediteFee.trim();
        masterfee1.Amount__c=100;
        masterfee1.External_ID__c='MF-0000000299';
        //masterfee1.Business_Type__c=lstFile[0].Business_Type__c;      
        insert masterfee1;
        
        Master_Fee__c masterfee2 = new Master_Fee__c(
        Type__c = 'Domestication',    
        Status__c='Active',
        Start_Date__c=System.today(),
        //ProcessingDate = System.today(),  
        End_Date__c=null,
        Amount__c=200,
        //Business_Type__c=lstFile[0].Business_Type__c,    
        External_ID__c='MF-0000000300');
        insert masterfee2;
                
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Domestication';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Notice of Intent to Dissolve/Revoke';
        filing.Date_Intend_Forfeited__c =System.today();
        lstFile.add(filing);
        insert lstFile;
                

                

                

                Test.startTest();
                //BusinessFilingTriggerHelper.updateFeeforMergerConversionandDoemstication(null,null);
                Test.stopTest();
            } Catch(Exception e){
                
                
            }
            
            
    }
    
    testmethod public static void calculateTaxTest(){
        try{
           BusinessFilingTriggerHelper.calculateTax (null,null,null,null);
        }
        catch(exception e){
            
            
        }
    } 
    
            testmethod public static void updateFeeforMergerConversionandDoemsticationTest2(){
            try{
                
        Master_Fee__c masterfee1 = new Master_Fee__c();
        masterfee1.Type__c = 'Business Formation';    
        masterfee1.Status__c=System.Label.ACTIVE;
        masterfee1.Start_Date__c=System.today().addDays(-2);
        //masterfee1.ProcessingDate = System.today();  
        masterfee1.End_Date__c=null;
        masterfee1.Filing_Type__c='Standard';
        masterfee1.Service_Type__c=System.Label.FilingExpediteFee.trim();
        masterfee1.Amount__c=100;
        masterfee1.External_ID__c='MF-0000000299';
        //masterfee1.Business_Type__c=lstFile[0].Business_Type__c;      
        insert masterfee1;
        
        Master_Fee__c masterfee2 = new Master_Fee__c(
        Type__c = 'Domestication',    
        Status__c='Active',
        Start_Date__c=System.today(),
        //ProcessingDate = System.today(),  
        End_Date__c=null,
        Amount__c=200,
        //Business_Type__c=lstFile[0].Business_Type__c,    
        External_ID__c='MF-0000000300');
        insert masterfee2;
                
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        ac.Citizenship__c='Domestic';
                update ac;
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Merger';
        filing.Citizenship__c = 'Domestic';
        filing.business_type__c = 'Stock';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Notice of Intent to Dissolve/Revoke';
        filing.Date_Intend_Forfeited__c =System.today();
        filing.Include_Expedited_Service__c=true;        
        filing.Source__c='Mail';        
        lstFile.add(filing);
        insert lstFile;
        Map<Id,Business_Filing__c> mpbfl= new Map<Id,Business_Filing__c>();
        mpbfl.put(filing.id,filing);        
                

                

                

                Test.startTest();
                BusinessFilingTriggerHelper.updateFeeforMergerConversionandDoemstication(lstFile,mpbfl);
                Test.stopTest();
            } Catch(Exception e){
                
                
            }
            
            
    }
    testmethod public static void updateEffectiveDateAndTime(){
        
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        Contact con1=[Select id from Contact Limit 1];
                
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
        
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Miscellaneous';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Miscellaneous';
        filing.Date_Intend_Forfeited__c =System.today();
        filing.Source__c='Mail';
        filing.Effective_Date_Time__c=system.now();
        filing.Work_Order__c=workOrder.id;
        lstFile.add(filing);
        insert lstFile;

    }
    testmethod public static void updateEffectiveDate(){
        
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        Contact con1=[Select id from Contact Limit 1];
                
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
        
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdCloseReinstate ;
        filing.Account__c=ac.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Miscellaneous';
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=System.label.Approved;
        filing.Filing_Date__c=System.today();
        filing.Filing_Type__c ='Miscellaneous';
        filing.Date_Intend_Forfeited__c =System.today();
        filing.Source__c='Mail';
        filing.Effective_Date_Time__c=null;
        filing.Work_Order__c=workOrder.id;
        lstFile.add(filing);
        insert lstFile;

    }
    testmethod public static void updateIsRejectedInstiatedForAnnualReportTest(){
        
        Id RecordTypeIdMaintainance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account ac = [Select id, Name,citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        Agent__c agentdata=BRS_TestDataFactory.createAgent(ac.id);
        Contact con1=[Select id from Contact Limit 1];
        Id rcId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = : Label.Business_Filing_API_Name AND Name = : Label.Annual_First_recordtype_label].id;
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
        
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=rcId ;
        filing.Account__c=ac.Id;
        filing.Citizenship__c=ac.Citizenship__c;
        filing.Business_Type__c=ac.Business_Type__c;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Annual Report';
        filing.status__c='Rejected';
        filing.Source__c='Online';
        filing.Due_Date__c = (System.today() + 5);
        lstFile.add(filing);
          Business_Filing__c filing1 = new Business_Filing__c();
        filing1.recordtypeid=rcId ;
        filing1.Account__c=ac.Id;
        filing1.Citizenship__c=ac.Citizenship__c;
        filing1.Business_Type__c=ac.Business_Type__c;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = 'Annual Report';
        filing1.status__c='Due';
        filing1.Source__c='Mail';
        filing1.Due_Date__c = (System.today() + 5);
        lstFile.add(filing1);
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdMaintainance ;
        filing2.Account__c=ac.Id;
        filing2.Filing_Fee__c=30;
        filing2.Type__c = 'Agent Resignation';
        filing2.Filing_Type__c='Agent Resignation';
        filing2.Citizenship__c = ac.citizenship__c;
        filing2.business_type__c = ac.business_type__c;
        filing2.Status__c='In-Progress';
        filing2.Filing_Date__c=System.today();
        filing2.Work_Order__c=workOrder.id;
        lstFile.add(filing2);     
        Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=RecordTypeIdMaintainance ;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = 'Agent Resignation';
        filing3.Filing_Type__c='Agent Resignation';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Status__c='Approved';
        filing3.Filing_Date__c=System.today();
        filing3.Work_Order__c=workOrder.id;
        lstFile.add(filing3);
        
        insert lstFile;
          Map<Id, Business_filing__c> oldItems = new Map<Id, Business_filing__c>();
        oldItems.put(filing2.Id, filing2);
         Map<Id, Business_filing__c> newItems = new Map<Id, Business_filing__c>();
        newItems.put(filing3.Id, filing3);
        Test.startTest();
        BusinessFilingTriggerHelper.updateIsRejectedInstiatedForAnnualReport(lstFile);
        Test.stopTest();

    }
    testmethod public static void updateAccountInfromationTest(){
         Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Id RecordTypeIdMaintainance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account ac = [Select id, Name,citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        Agent__c agentdata=BRS_TestDataFactory.createAgent(ac.id);
        Contact con1=[Select id from Contact Limit 1];
        Id rcId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = : Label.Business_Filing_API_Name AND Name = : Label.Annual_First_recordtype_label].id;
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
        ac.Status__c = 'Forfeited';
        update ac;
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=RecordTypeIdCloseReinstate ;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = 'Reinstatement';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Status__c='Approved';
        filing3.Filing_Date__c=System.today();
        filing3.Work_Order__c=workOrder.id;
         filing3.Filing_Date__c = System.Today();
        filing3.Due_Date__c = (System.today() + 5);
        filing3.Date_Intend_Forfeited__c =System.today().addDays(2);
        lstFile.add(filing3);        
        insert lstFile;
        ac.Status__c = 'Active';
        ac.Date_Intend_Forfeited__c  = null;
        update ac;
    }
    testmethod public static void updateAccountInfromationTest1(){
         Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        Id RecordTypeIdMaintainance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account ac = [Select id, Name,citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
        Agent__c agentdata=BRS_TestDataFactory.createAgent(ac.id);
        Contact con1=[Select id from Contact Limit 1];
        Id rcId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = : Label.Business_Filing_API_Name AND Name = : Label.Annual_First_recordtype_label].id;
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = ' Online';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Completed';
        workOrder.Customer__c=con1.Id;
        workOrder.Total_Hold_Amount__c=500;
        insert workOrder;
        ac.Status__c = 'Forfeited';
        ac.Sub_status__c='Annual Report due';
        ac.Reason_for_Administrative_Dissolution__c='Annual Report payment pending';
        update ac;
        List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
        Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=RecordTypeIdCloseReinstate ;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = 'Reinstatement';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Status__c='Approved';
        filing3.Filing_Date__c=System.today();
        filing3.Work_Order__c=workOrder.id;
        filing3.Filing_Date__c = System.Today();
        filing3.Due_Date__c = (System.today() + 5);
        filing3.Date_Intend_Forfeited__c =System.today().addDays(2);
        lstFile.add(filing3);        
        insert lstFile;
        ac.Status__c = 'Active';
        ac.Date_Intend_Forfeited__c  = null;
        update ac;
    }
}