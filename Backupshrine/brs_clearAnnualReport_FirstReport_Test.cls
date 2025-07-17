@isTest
private class brs_clearAnnualReport_FirstReport_Test {
    Static List<Id> acctIdList = new List<Id>(); 
    @isTest
    static void insertUccRelatedInforTest1() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c=System.Label.Stock,
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                Sub_Status__c='Annual Report Due',
                                State_or_Territory_Formation__c='WA',
                                State__c='WA',
                                Country__c='India',
                                Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        insert acc;
        acc.sub_status__c='Annual Report Past Due';
        update acc;
        Contact con=BRS_TestDataFactory.createContactObject(acc.Id);       
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c=con.Id;
        insert workOrder1;
        
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = System.Label.First_Report_Label;
        filing.Filing_Type__c='Organization and First Report';
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.recordtypeId=annualFirstrecTypeId;
        filing.status__c='Past due';
        insert filing;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = system.label.Annual_Report;
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        filing1.status__c='Past due';
        insert filing1;
        Test.startTest();
        List<Account> acclist=new List<Account>();
        acclist.add(acc);
        brs_clearAnnualReport_FirstReport obj=new brs_clearAnnualReport_FirstReport();
        DataBase.executeBatch(obj); 
        obj.execute(null,acclist);
        Test.stopTest();
    }
    @isTest
    static void insertUccRelatedInforTest2() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c=System.Label.Stock,
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                Sub_Status__c='Annual Report Due',
                                State_or_Territory_Formation__c='WA',
                                State__c='WA',
                                Country__c='India',
                                Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        insert acc;
        acc.sub_status__c='Annual Report Past Due';
        update acc;
        Contact con=BRS_TestDataFactory.createContactObject(acc.Id);       
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c=con.Id;
        insert workOrder1;
        
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = System.Label.First_Report_Label;
        filing.Filing_Type__c='Organization and First Report';
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() -5);
        filing.recordtypeId=annualFirstrecTypeId;
        filing.status__c='Past due';
        insert filing;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = system.label.Annual_Report;
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        filing1.status__c='Past due';
        insert filing1;
        Test.startTest();
        List<Account> acclist=new List<Account>();
        acclist.add(acc);
        brs_clearAnnualReport_FirstReport obj=new brs_clearAnnualReport_FirstReport();
        DataBase.executeBatch(obj); 
        obj.execute(null,acclist);
        Test.stopTest();
    }
    @isTest
    static void insertUccRelatedInforTest3() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c=System.Label.Stock,
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                Sub_Status__c='Annual Report Due',
                                State_or_Territory_Formation__c='WA',
                                State__c='WA',
                                Country__c='India',
                                Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        insert acc;
        acc.sub_status__c='Ready for dissolution';
        update acc;
        Contact con=BRS_TestDataFactory.createContactObject(acc.Id);       
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c=con.Id;
        insert workOrder1;
        
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = System.Label.First_Report_Label;
        filing.Filing_Type__c='Organization and First Report';
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() -5);
        filing.recordtypeId=annualFirstrecTypeId;
        filing.status__c='Past due';
        insert filing;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = system.label.Annual_Report;
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        filing1.status__c='Past due';
        insert filing1;
        Test.startTest();
        List<Account> acclist=new List<Account>();
        acclist.add(acc);
        brs_clearAnnualReport_FirstReport obj=new brs_clearAnnualReport_FirstReport();
        DataBase.executeBatch(obj); 
        obj.execute(null,acclist);
        Test.stopTest();
    }
    @isTest
    static void insertUccRelatedInforTest4() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c='Limited Partnership',
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                Sub_Status__c='Annual Report Due',
                                State_or_Territory_Formation__c='WA',
                                State__c='WA',
                                Country__c='India',
                                Name='Test Partnership',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        insert acc;
        acc.sub_status__c='Ready for dissolution';
        update acc;
        Contact con=BRS_TestDataFactory.createContactObject(acc.Id);       
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c=con.Id;
        insert workOrder1;
        List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
         objRelatedInfo.City__c = 'City';   
         objRelatedInfo.Country__c = 'country';
         objRelatedInfo.isAuthorizer__c = true;
         objRelatedInfo.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
         objRelatedInfo.Org_Name__c = 'Orgname Partnership';
        objRelatedInfo.Org_Name_Indexed__c='OrgnamePartnership';
         objRelatedInfo.Type__c = 'Secured Party';
         //objRelatedInfo.Individual_SurName__c = 'surname'; 
         objRelatedInfo.Street__c = 'Street';
         objRelatedInfo.Zip_Code__c = '11111';
         //objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
         objRelatedInfo.Suffix__c = 'Suffix';   
		 objRelatedInfo.state__c = 'Test';
         lstRelatedInfo.add(objRelatedInfo);
            
         UCC_Related_Info__c objRelatedInfo2 = new UCC_Related_Info__c();  
         objRelatedInfo2.City__c = 'City';   
         objRelatedInfo2.Country__c = 'country';
         //objRelatedInfo2.Individual_First_Name__c = 'FirstName';
         objRelatedInfo2.isAuthorizer__c = true;
          //Added as Part of BRS-2366
          objRelatedInfo2.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
          objRelatedInfo2.Org_Name__c = 'Orgname Partnership';
        objRelatedInfo2.Org_Name_Indexed__c='OrgnamePartnership';
         objRelatedInfo2.Type__c = 'Secured Party';
         //objRelatedInfo2.Individual_SurName__c = 'surname'; 
         objRelatedInfo2.Street__c = 'Street';
         objRelatedInfo2.Zip_Code__c = '11111';
         //objRelatedInfo2.Individual_Middle_Name__c = 'Middlename';
         objRelatedInfo2.Suffix__c = 'Suffix';   
		 objRelatedInfo2.state__c = 'Test';
         lstRelatedInfo.add(objRelatedInfo2);
         insert lstRelatedInfo;
         
    
        List<Account> acclist=new List<Account>();
        acclist.add(acc);
        Test.startTest();
        brs_label_designation_removal_Batch obj=new brs_label_designation_removal_Batch();
        DataBase.executeBatch(obj); 
        obj.execute(null,lstRelatedInfo);
        Test.stopTest();
    }
}