@isTest 
public class NintexFirstAnnualReportServices_Test {
    @TestSetup
    static void setup() {
        //Account acc = BRS_TestDataFactory.createAccountObject();
        Account acc = new Account();
        acc.Name = 'Test Account First';
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='LLP';
        acc.Began_Transacting_in_CT__c=System.today();
        acc.Date_of_Formation__c=System.today();
        acc.Business_Name_in_state_country__c='USA';
        acc.ClientAccountNum__c='12345';
        acc.Description='Data';
        acc.State_or_Territory_Formation__c='CT';
        acc.Country_Formation__c='washington';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Mailing_Address__c='sa';
        acc.ShippingCity='sad';
        acc.ShippingStreet='121';
        acc.ShippingCountry='USA';
        acc.BillingStreet='billing street';
        acc.BillingCity='city';
        acc.BillingCountry='US';
        acc.Business_Email_Address__c='s@s.com';
        acc.Office_Jurisdiction_BusinessStreet__c='Street';
        acc.Mailing_Jurisdiction_BusinessStreet__c='mailjuridiction Street';
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con.id,'Mail','In-Progress');
        
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Maintenance'
        ];
                RecordType rt1 = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, acc.id, workOrder.id, 'Amendment', 'Approved');
        insert filing;
        Business_Filing__c filing1 = BRS_TestDataFactory.createBusinessFilingObject1(rt1.id, acc.id, workOrder.id, 'First Report', 'In-progress');
        insert filing1;
        filing1.Filing_Type__c = 'Organization and First Report';
        update filing1;
    }
    @isTest private static void getCurrentPrincipalTest() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        Id filingid = [Select id from Business_Filing__c where Account__c=:accid limit 1].id;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filingid,principal.id,accid,'Principal','Edited');
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingid;
        List<string> fields = new List<string>();
        fields.add('Principal Name');
        fields.add('Principal Designation');
        fields.add('Principal Title');
        fields.add('Principal Business Address');
        fields.add('Principal Residence Address');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.ARCurrentPrincipalInfoWrapper');
        objectNames.add('Contact');
        objectNames.add('Principal__c');
        objectNames.add('Business_Filing__c');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getCurrentPrincipalInfo(filingid);
        
        Test.stopTest(); 
        
    }
    @isTest private static void getCurrentPrincipalTest1() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        Id filingid = [Select id from Business_Filing__c where Account__c=:accid limit 1].id;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filingid,principal.id,accid,'Principal','Created');
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingid;
        List<string> fields = new List<string>();
        fields.add('Principal Name');
        fields.add('Principal Designation');
        fields.add('Principal Title');
        fields.add('Principal Business Address');
        fields.add('Principal Residence Address');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.ARCurrentPrincipalInfoWrapper');
        objectNames.add('Contact');
        objectNames.add('Principal__c');
        objectNames.add('Business_Filing__c');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getCurrentPrincipalInfo(filingid);
        NintexFirstAnnualReportTemplateServices.fetchBusinessAddrStr(principal);
        NintexFirstAnnualReportTemplateServices.fetchResidenceAddrStr(principal);
        NintexFirstAnnualReportTemplateServices.comparePrincipals(principal,principal,'LLP');
        Test.stopTest(); 
        
    }
    @isTest private static void getCurrentPrincipalTest2() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal = new Principal__c();
        principal.Principal_Account_ID__c = accid;
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Individual';
        //principal.Business_Name__c = 'Pizza';
        principal.FirstName__c='First Test';
        principal.LastName__c='Last Test';
        principal.Residence_Street_Address_1__c = '100';
        principal.Residence_City__c = 'Hartford';
        principal.Residence_Country__c = 'United States';
        principal.Residence_State__c = 'CT';
        principal.Residence_Zip_Code__c  = '06100';
        principal.Business_ID__c=accid;
        //principal.Business_InternationalAddress__c='Test International';
        insert principal;
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
        Id filingid = [Select id from Business_Filing__c where Account__c=:accid limit 1].id;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filingid,principal.id,accid,'Principal','Deleted');
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingid;
        List<string> fields = new List<string>();
        fields.add('Principal Name');
        fields.add('Principal Designation');
        fields.add('Principal Title');
        fields.add('Principal Business Address');
        fields.add('Principal Residence Address');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.ARCurrentPrincipalInfoWrapper');
        objectNames.add('Contact');
        objectNames.add('Principal__c');
        objectNames.add('Business_Filing__c');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getCurrentPrincipalInfo(filingid);
        NintexFirstAnnualReportTemplateServices.fetchResidenceAddrStr(principal);
        NintexFirstAnnualReportTemplateServices.fetchBusinessAddrStr(principal);
        Test.stopTest(); 
        
    }  
    
    @isTest private static void getPrimaryAndLocationDetailsTest() {
        Test.startTest();
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,accid,'Account','Created');
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest1() {
        Test.startTest();
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest2() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
		id filingId=[Select id from Business_Filing__c where Filing_Type__c= 'Organization and First Report' limit 1].id;
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingId;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filingId);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest3() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
  		id filingId=[Select id from Business_Filing__c where Filing_Type__c= 'Organization and First Report' limit 1].id;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filingId,principal.id,accid,'Account','Created');
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingId;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filingId);
        Test.stopTest(); 
        
    }  
    @isTest private static void dateFormatMethodTest() {
        Date da=System.today();
        Test.startTest();
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        NintexFirstAnnualReportTemplateServices.dateFormatMethod(da);
        Test.stopTest(); 
        
    }  
    @isTest private static void getCurrentPrincipalTestdata() {
        id accid = [Select Id from Account].id;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c princ= new Principal__c();
        princ.Principal_Type__c = 'Individual';
        princ.Business_ID__c=accid;
        princ.Principal_Title__c = 'PRESIDENT';
        princ.Principal_Type__c = 'Individual';
        princ.FirstName__c = 'test first name';
        princ.LastName__c = 'test last name';
        princ.Residence_State__c='AK';
        princ.Residence_City__c='sa';
        princ.Residence_Zip_Code__c='12345';
        princ.Residence_Country__c='United States';
        princ.Business_Address__c='bus';
        princ.Business_State__c='AK';
        princ.Business_City__c='US';
        
        princ.Residence_Street_Address_1__c='add';
        princ.Business_Street_Address_1__c='addbus';
        princ.Residence_Street_Address_2__c='res2';
        princ.Residence_Street_Address_3__c='res3';
        princ.Business_Street_Address_2__c='bus2';
        princ.Business_Street_Address_3__c='bus3';
        princ.Business_Country__c = 'Afghanistan';
        insert princ;
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
        Id filingid = [Select id from Business_Filing__c where Account__c=:accid limit 1].id;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filingid,princ.id,accid,'Principal','Deleted');
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filingid;
        List<string> fields = new List<string>();
        fields.add('Principal Name');
        fields.add('Principal Designation');
        fields.add('Principal Title');
        fields.add('Principal Business Address');
        fields.add('Principal Residence Address');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.ARCurrentPrincipalInfoWrapper');
        objectNames.add('Contact');
        objectNames.add('Principal__c');
        objectNames.add('Business_Filing__c');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.fetchResidenceAddrStr(princ);
        NintexFirstAnnualReportTemplateServices.fetchBusinessAddrStr(princ);
        NintexFirstAnnualReportTemplateServices.getPrincipalTitle(filingid);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest00() {
        Account acc = new Account();
        acc.Name = 'Test Account First1';
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='LLP';
        acc.Began_Transacting_in_CT__c=System.today();
        acc.Date_of_Formation__c=System.today();
        acc.Business_Name_in_state_country__c='USA';
        acc.ClientAccountNum__c='12345';
        acc.Description='Data';
        acc.State_or_Territory_Formation__c='CT';
        acc.Country_Formation__c='washington';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Mailing_Address__c='sa';
        acc.ShippingCity='sad';
        acc.ShippingStreet='121';
        acc.ShippingCountry='USA';
        
        acc.BillingCity='city';
        acc.BillingCountry='US';
        acc.Business_Email_Address__c='s@s.com';
        acc.Office_Jurisdiction_BusinessStreet__c='Street';
        acc.Mailing_Jurisdiction_BusinessStreet__c='mailjuridiction Street';
        insert acc;
        id accid = acc.id;
        Contact con1 = new Contact();
        con1.FirstName = 'Test12';
        con1.LastName = 'Contact1232';
        con1.Email = 'testConBrs1@test.com';
        con1.AccountId = acc.id;
        insert con1;
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id,'Mail','In-Progress');
        
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(acc.id);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:con1.id limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,accid,'Account','Created');
        temp.BillingStreet__c ='';
        temp.Principle_Office_International_Address__c ='Test';
        temp.BillingStreet_New__c='';
        temp.Principle_Office_International_Address_N__c='Test';
        temp.ShippingStreet__c='';
        temp.Mailing_International_Address__c='Test';
        temp.ShippingStreet_New__c='';
        temp.Mailing_International_Address_New__c='Test';
        temp.Office_Jurisdiction_BusinessStreet__c='';
        temp.Jurisdiction_International_address__c='Test';
        temp.Office_Jurisdiction_BusinessStreet_New__c='';
        temp.Jurisdiction_International_address_New__c='Test';
        temp.Mailing_Jurisdiction_BusinessStreet__c='';
        temp.Mail_Jurisdiction_International_address__c='Test';
        temp.Mailing_Jurisdiction_BusinessStreet_New__c='';
        temp.Mail_JurisdictionInternationaladdress_N__c='Test';
        update temp;
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest01() {
        Account acc = new Account();
        acc.Name = 'Test Account First1';
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='LLP';
        acc.Began_Transacting_in_CT__c=System.today();
        acc.Date_of_Formation__c=System.today();
        acc.Business_Name_in_state_country__c='USA';
        acc.ClientAccountNum__c='12345';
        acc.Description='Data';
        acc.State_or_Territory_Formation__c='CT';
        acc.Country_Formation__c='washington';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Mailing_Address__c='sa';
        acc.ShippingCity='sad';
        acc.ShippingStreet='121';
        acc.ShippingCountry='USA';
        acc.BillingStreet='USA';
        acc.BillingCity='city';
        acc.BillingCountry='US';
        acc.Business_Email_Address__c='s@s.com';
        acc.Office_Jurisdiction_BusinessStreet__c='Street';
        acc.Mailing_Jurisdiction_BusinessStreet__c='mailjuridiction Street';
        insert acc;
        id accid = acc.id;
        Contact con1 = new Contact();
        con1.FirstName = 'Test12';
        con1.LastName = 'Contact1232';
        con1.Email = 'testConBrs1@test.com';
        con1.AccountId = acc.id;
        insert con1;
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id,'Mail','In-Progress');
        
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(acc.id);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:con1.id limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,accid,'Account','Created');
        temp.BillingStreet__c ='';
        temp.Principle_Office_International_Address__c ='Test';
        temp.Type_of_Update__c=null;
        update temp;
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest02() {
        Account acc = new Account();
        acc.Name = 'Test Account First1';
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='LLP';
        acc.Began_Transacting_in_CT__c=System.today();
        acc.Date_of_Formation__c=System.today();
        acc.Business_Name_in_state_country__c='USA';
        acc.ClientAccountNum__c='12345';
        acc.Description='Data';
        acc.State_or_Territory_Formation__c='CT';
        acc.Country_Formation__c='washington';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Mailing_Address__c='sa';
        acc.ShippingCity='sad';
        acc.Mailing_International_Address__c='121';
        acc.ShippingCountry='USA';
        acc.Principle_Office_International_Address__c='USA';
        acc.BillingCity='city';
        acc.BillingCountry='US';
        acc.Business_Email_Address__c='s@s.com';
        acc.Jurisdiction_International_address__c='Street';
        acc.Mail_Jurisdiction_International_address__c='mailjuridiction Street';
        insert acc;
        id accid = acc.id;
        Contact con1 = new Contact();
        con1.FirstName = 'Test12';
        con1.LastName = 'Contact1232';
        con1.Email = 'testConBrs1@test.com';
        con1.AccountId = acc.id;
        insert con1;
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id,'Mail','In-Progress');
        
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(acc.id);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:con1.id limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Temp_History__c temp=BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,accid,'Account','Created');
        temp.BillingStreet__c ='';
        temp.Principle_Office_International_Address__c ='Test';
        temp.Type_of_Update__c=null;
        update temp;
        Test.startTest();
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }  
    @isTest private static void getPrimaryAndLocationDetailsTest03() {
        Test.startTest();
        id accid = [Select Id from Account].id;
        Account acc= new Account();
        acc.Id=accid;
        acc.BillingStreet='';
        acc.Principle_Office_International_Address__c='test';
        acc.ShippingStreet='';
        acc.Mailing_International_Address__c='test';
        acc.Office_Jurisdiction_BusinessStreet__c='';
        acc.Jurisdiction_International_address__c='test';
        acc.Mailing_Jurisdiction_BusinessStreet__c='';
        acc.Mail_Jurisdiction_International_address__c='test';
            update acc;
        id conid=[Select Id from contact where AccountId=:accid].id;
        Principal__c principal= BRS_TestDataFactory.createPrincipalRecords(accid);
        id workOrderid=[Select id from Work_Order__c where Customer__c=:conid limit 1].id;
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, accid, workOrderid, 'Annual Report', 'Approved');
        insert filing;
        filing.Filing_Type__c = 'Annual Report';
        update filing;
        Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        List<string> fields = new List<string>();
        fields.add('Business Citizenship');
        fields.add('Business Type');
        fields.add('Business Name');
        fields.add('Business ALEI');
        fields.add('Date of Organization Meeting');
        fields.add('Business Email Address Old');
        fields.add('Business Email Address New');
        fields.add('NAICS Code Old');
        fields.add('NAICS Code New');
        fields.add('Principal Office Address Old');
        fields.add('Principal Office Address New');
        fields.add('Mailing Address Old');
        fields.add('Mailing Address New');
        fields.add('Office Jurisdiction Address Old');
        fields.add('Office Jurisdiction Address New');
        fields.add('Mailing Address (in State of Formation) Old');
        fields.add('Mailing Address (in State of Formation) New');
        List<string> objectNames = new List<string>();
        objectNames.add('NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper');
        NintexFirstAnnualReportTemplateServices annualReportTemplate=new NintexFirstAnnualReportTemplateServices();
        annualReportTemplate.describeObjects(objectNames);
        annualReportTemplate.getGlobalDescribe();
        annualReportTemplate.getChildRelationships('Business_Filing__c');
        requestInfo1.GetObjectNames();
        annualReportTemplate.query(requestInfo1);
        NintexFirstAnnualReportTemplateServices.getPrimaryAndLocationDetails(filing.Id);
        Test.stopTest(); 
        
    }    
    
}