@isTest
private class brs_onlineEnquiryBusinessSearchTest {
    
    @testSetup static void setup() {
        Set<id> filingIds = new Set<id>();
        Id businessRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = businessRecTypeId;
        acc.Name = 'Test,LTD.';
        acc.Business_Type__c = 'Stock';
        //acc.Business_Sub_Type__c = 'Corporation';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.Citizenship__c = 'Domestic';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.Total_Authorized_Shares__c = 100;
        acc.Status__c = 'Active';
        acc.Date_of_Formation__c = system.today();
        acc.Mailing_International_Address__c = 'Mailing address';
        //acc.Business_End_Date__c = System.today().addDays(365);
        insert acc;
        
        Agent__c agent = new Agent__c();
        agent.FirstName__c = 'Test';
        agent.LastName__c = 'Agent';
        agent.Email__c = 'testagent@test.com';
        agent.Business_ID__c = acc.Id;
        agent.Type__c = 'Individual';
        //agent.Business_Name__c = 'Test';
        agent.Residence_Street_Address_1__c = '100';
        agent.Residence_City__c = 'Hartford';
        agent.Residence_Country__c = 'United States';
        agent.Residence_State__c = 'CT';
        agent.Residence_Zip_Code__c  = '06100';
         agent.Mailing_Street_Address_1__c= '100';
        agent.Mailing_City__c= 'Hartford';
        agent.Mailing_Country__c= 'United States';
        agent.Mailing_State__c= 'CT';
        agent.Mailing_Zip_Code__c= '06100';
        insert agent;
        
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();        
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Change of Agent';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        
        insert businessFiling;
        
        filingIds.add(businessFiling.id);
        ContentVersion objContVer = new ContentVersion();
        objContVer.VersionData = Blob.valueOf('string');
        objContVer.Title = 'title'; 
        objContVer.PathOnClient='title.txt';
        objContVer.File_Type_fileupload__c = 'Text';   
        insert objContVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContVer.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = businessFiling.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        Principal__c principal = new Principal__c();
        principal.FirstName__c = 'Test';
        principal.Name__c = 'Test Principal';
        principal.LastName__c = 'Principal';
        principal.Business_ID__c = acc.Id;
        principal.Principal_Account_ID__c = acc.Id;
        principal.Email__c = 'saritanayak71@gmail.com';
        insert principal;
        
        brs_onlineEnquiryBusinessSearchBusCls.searchData onEnq = new brs_onlineEnquiryBusinessSearchBusCls.searchData();
        onEnq.accountId = acc.id;
        onEnq.businessALEI = businessFiling.id;
        onEnq.connecticutAlei = 'Test';
        onEnq.zipCode = '123456';
        onEnq.businessName = 'Test';
        onEnq.businessAddress = 'Test';
        onEnq.businessAgentName = 'Test';
        onEnq.businessStatus = 'Test';
        onEnq.businessPrincipalsNames = 'Test';
        onEnq.businessPrincipalsCount = 4;
        onEnq.principalList = new List<String>{'test1','test2'};
        onEnq.citizenship = 'Test';
        onEnq.entityType = 'Test';
        //onEnq.filingDate = Date.newInstance(2021,01,01);
        //onEnq.filingName = 'Test';
        //onEnq.filingNumber = '7';
        
        Date myDate = Date.newInstance(2021, 2, 17);        
        brs_onlineEnquiryBusinessSearchBusCls.businessDetails onEnq2 = new brs_onlineEnquiryBusinessSearchBusCls.businessDetails();
        onEnq2.accountId = acc.id;
        onEnq2.businessId = businessFiling.id;
        onEnq2.connecticutAlei = 'Test';
        //onEnq2.zipCode = '123456';
        onEnq2.businessName = 'Test';
        onEnq2.businessAddress = 'Test';
        onEnq2.businessAgentName = 'Test';
        onEnq2.businessStatus = 'Test';
        onEnq2.dateFormed = myDate.format();//Date.newInstance(2021,01,01);
        onEnq2.businessType = 'Test';
        onEnq2.annualReportDue = myDate.format();//Date.newInstance(2021,01,01);
        onEnq2.lastReportFiled = 'Test';
        onEnq2.naicsCode = 'Test';
        onEnq2.naicsSubCode = 'Test';
        onEnq2.agentResidenceAddress = 'Test';
        onEnq2.agentBusinessAddress = 'Test';
        onEnq2.agentMailingAddress = 'Test';
        onEnq2.totalShares = 7.8;
        onEnq2.placeOfFormation = 'Test';
        onEnq2.mailingAddress = 'Test';
        
        brs_onlineEnquiryBusinessSearchBusCls.filingDetails onEnq3 = new brs_onlineEnquiryBusinessSearchBusCls.filingDetails();
        onEnq3.filingId = businessFiling.id;
        onEnq3.filingDateTime = myDate.format();//Date.newInstance(2021,01,01);
        onEnq3.filingVolumeType = 'Test';
        onEnq3.filingPages = 'Test';
        onEnq3.filingVolume = 7;
        onEnq3.filingType = 'Test';
        onEnq3.filinTerminatedBusinessId = 'Test';
        onEnq3.filingTerminatedBusinessName = 'Test';
        onEnq3.filingTerminatedDate = String.ValueOf(Date.newInstance(2021,01,01));
        onEnq3.filingDigitalCopy = 'Test';
        
        brs_onlineEnquiryBusinessSearchBusCls.nameHistoryDetails onEnq4 = new brs_onlineEnquiryBusinessSearchBusCls.nameHistoryDetails();
        onEnq4.nameHistoryNumber = 'Test';
        onEnq4.nameHistoryName = 'Test';
        onEnq4.nameHistoryfilingDate =  String.ValueOf(Date.newInstance(2021,01,01));
        
        brs_onlineEnquiryBusinessSearchBusCls.shareDetails onEnq5 = new brs_onlineEnquiryBusinessSearchBusCls.shareDetails();
        onEnq5.shareClass = 'Test';
        onEnq5.shareNumber = 8.9;
        onEnq5.valuePerShare =  8.9;
        
        brs_onlineEnquiryBusinessSearchBusCls.principalDetails onEnq6 = new brs_onlineEnquiryBusinessSearchBusCls.principalDetails();
        onEnq6.businessPrincipalName = 'Test';
        onEnq6.principalResidenceAddress = 'Test';
        onEnq6.principalBusinessAddress =  'Test';
        onEnq6.principalTitle =  'Test';
        brs_onlineEnquiryBusinessSearchBusCls.getFilingRelatedDocs(filingIds,'UCC');
        brs_onlineEnquiryBusinessSearchBusCls.getFilingRelatedDocs(filingIds,'');
        Temp_History__c agents = new Temp_History__c(Account__c = acc.Id , Type_of_Update__c='Name');
        insert agents;
        /*Principal__c principal = new Principal__c();
        principal.Principal_Account_ID__c = acc.Id;
        principal.Name__c = 'principal';
        insert principal;*/
        
        List<Stock_Classification__c> lstsk = new List<Stock_Classification__c>();
        Stock_Classification__c sk = new Stock_Classification__c();
        sk.Number_of_Stocks__c=100;
        sk.Par_Value__c =10;
        sk.AccountId__c = acc.id;
        lstsk.add(sk);
        insert lstsk;
        
        brs_onlineEnquiryBusinessSearch.getBusinessDetails(acc.id);
        
        try{
            //brs_onlineEnquiryBusinessSearch.getBusinessDetails('');
        }
        catch(Exception e){ 
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    testmethod static void testGetBusiness() {
        test.startTest();
        List<brs_genericSearchBusinessClass.filterWrapper> filterList = new List<brs_genericSearchBusinessClass.filterWrapper>();
        brs_genericSearchBusinessClass.filterWrapper filterWrapper1 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper1.type = 'Business Type';
        filterWrapper1.selectedOptions = new List<String> {'Domestic'};
            filterList.add(filterWrapper1);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper2 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper2.type = 'Business Start Date';
        filterWrapper2.selectedOptions = new List<String> {String.valueOf(System.today())};
            filterList.add(filterWrapper2);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper3 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper3.type = 'Business End Date';
        filterWrapper3.selectedOptions = new List<String> {String.valueOf(System.today().addDays(30))};
            filterList.add(filterWrapper3);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper4 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper4.type = 'Business Status';
        filterWrapper4.selectedOptions = new List<String> {'Active'};
            filterList.add(filterWrapper4);
        
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper5 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper5.type = 'Entity Type';
        filterWrapper5.selectedOptions = new List<String> {'Stock'};
            filterList.add(filterWrapper5);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = [Select Id From Account][0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        brs_onlineEnquiryBusinessSearch.getBusiness('1234', 'Business ID',filterList,true,null);
        brs_onlineEnquiryBusinessSearch.getBusiness('1234', 'Business City',filterList,true,null);
        brs_onlineEnquiryBusinessSearch.getBusiness('1234', 'Business ALEI',filterList,true,null);
        brs_onlineEnquiryBusinessSearch.getBusiness('Test', 'Business Name',filterList,true,null);
        brs_onlineEnquiryBusinessSearch.getBusiness('1234', '',filterList,true,'');
        //brs_onlineEnquiryBusinessSearch.getBusinessOld('1234', 'Business ID',filterList, false);
        //brs_onlineEnquiryBusinessSearch.getBusinessOld('1234', '',filterList, false);
        
        List<Business_Filing__c> busFiling = [Select Id, Name From Business_Filing__c];
        
        brs_onlineEnquiryBusinessSearch.getBusiness(busFiling[0].Name, 'Filing Number',filterList,true,null);
        //brs_onlineEnquiryBusinessSearch.getBusinessOld(busFiling[0].Name, 'Filing Number',filterList,true);
        //brs_onlineEnquiryBusinessSearch.getBusinessOld(busFiling[0].Name, 'Principal Name',filterList,false);
        //brs_onlineEnquiryBusinessSearch.getBusinessOld(busFiling[0].Name, 'Agent Name',filterList,false);
        
        List<Account> accList = [Select Id, Name From Account];
        Account acc = new Account(Name='principal',Status__c='Active', BillingCity='Hartford');
        insert acc;
        Principal__c principal = new Principal__c();
        principal.Principal_Account_ID__c = acc.Id;
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Residence_Street_Address_1__c = '100';
        principal.Residence_City__c = 'Hartford';
        principal.Residence_Country__c = 'United States';
        principal.Residence_State__c = 'CT';
        principal.Residence_Zip_Code__c  = '06100';
        test.stoptest();
        try{
            brs_onlineEnquiryBusinessSearch.getBusiness(accList[0].Id, 'Agent Name',filterList,true,null);
        }
        catch(Exception e){ 
            System.assertEquals('Script-thrown exception', e.getMessage());
        }     
    }
    testmethod static void testGetBusiness1() {
        test.startTest();
        List<brs_genericSearchBusinessClass.filterWrapper> filterList = new List<brs_genericSearchBusinessClass.filterWrapper>();
        brs_genericSearchBusinessClass.filterWrapper filterWrapper1 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper1.type = 'Business Type';
        filterWrapper1.selectedOptions = new List<String> {'Domestic'};
            filterList.add(filterWrapper1);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper2 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper2.type = 'Business Start Date';
        filterWrapper2.selectedOptions = new List<String> {String.valueOf(System.today())};
            filterList.add(filterWrapper2);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper3 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper3.type = 'Business End Date';
        filterWrapper3.selectedOptions = new List<String> {String.valueOf(System.today().addDays(30))};
            filterList.add(filterWrapper3);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper4 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper4.type = 'Business Status';
        filterWrapper4.selectedOptions = new List<String> {'Active'};
            filterList.add(filterWrapper4);
        
        brs_genericSearchBusinessClass.filterWrapper filterWrapper5 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper4.type = 'Business City';
        filterWrapper4.selectedOptions = new List<String> {'Hartford'};
            filterList.add(filterWrapper5);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = [Select Id From Account][0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        List<Business_Filing__c> busFiling = [Select Id, Name From Business_Filing__c];
                
        List<Account> accList = [Select Id, Name From Account];
        Account acc = new Account(Name='principal',Status__c='Active');
        insert acc;
        Principal__c principal = new Principal__c();
        principal.Principal_Account_ID__c = acc.Id;
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Residence_Street_Address_1__c = '100';
        principal.Residence_City__c = 'Hartford';
        principal.Residence_Country__c = 'United States';
        principal.Residence_State__c = 'CT';
        principal.Residence_Zip_Code__c  = '06100';

        test.stopTest();
        try{
            brs_onlineEnquiryBusinessSearch.getBusiness('Test,LTD.', 'Principal Name',filterList,false,null);
        }
        catch(Exception e){ 
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    testmethod static void testGetBusinessEmptySearch() {
        test.startTest();
        List<brs_genericSearchBusinessClass.filterWrapper> filterList = new List<brs_genericSearchBusinessClass.filterWrapper>();
        brs_genericSearchBusinessClass.filterWrapper filterWrapper1 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper1.type = 'Business Type';
        filterWrapper1.selectedOptions = new List<String> {'Domestic'};
            filterList.add(filterWrapper1);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = [Select Id From Account][0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        brs_onlineEnquiryBusinessSearch.getBusiness(null,'', null, false,null);
        test.stopTest();
    }
    testmethod static void testGetSearchType() {
        test.startTest();
        try{
            brs_onlineEnquiryBusinessSearch.getBusiness('Test,LTD.','Business Address',null,false,null);  
        } catch(Exception e){ 
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        test.stopTest();
    }
    testmethod static void testGetSearchType1() {
        List<brs_genericSearchBusinessClass.filterWrapper> filterList = new List<brs_genericSearchBusinessClass.filterWrapper>();
        brs_genericSearchBusinessClass.filterWrapper filterWrapper1 = new brs_genericSearchBusinessClass.filterWrapper();
        filterWrapper1.type = 'Business Type';
        filterWrapper1.selectedOptions = new List<String> {'Domestic'};
            filterList.add(filterWrapper1);
       brs_onlineEnquiryBusinessSearch.getBusiness('Test,LTD.','Filing Number',filterList,false,null); 
    }
    testMethod static void testGetBusinessDetails(){
        Account acc = new Account();
        acc.Name = 'Test,LTD.';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.Total_Authorized_Shares__c = 100;
        insert acc;
        
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.Status__c = 'Approved';
        businessFiling.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling.Type__c = 'Annual Report';
        insert businessFiling;
        Business_Filing__c businessFiling1 = new Business_Filing__c();
        businessFiling1.Account__c = acc.Id;
        businessFiling1.Status__c = 'Approved';
        businessFiling1.Type__c = 'Annual Report';
        businessFiling1.Filing_Date__c = System.Today().addDays(-30); 
        insert businessFiling1;
        
        List<Business_Filing__c> filingList = new List<Business_Filing__c>();
        filingList.add(businessFiling);
        filingList.add(businessFiling1);
        
        Name_Change_History__c hisInst = new Name_Change_History__c();
        hisInst.Account__c = acc.Id;
        hisInst.Business_Filing__c = businessFiling.Id;
        hisInst.Business_Name_New__c = 'abc';
        hisInst.Business_Name_Old__c = 'xyz';
        hisInst.Name_Change_Date__c = system.today();
        insert hisInst; 
        Test.startTest();
        brs_onlineEnquiryBusinessSearch.getBusinessDetails(acc.id);
        Test.stopTest();
    }
    
    testMethod static void testGetBusinessDetailsMergers(){
        Account acc = new Account();
        acc.Name = 'Test,LTD.';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.Total_Authorized_Shares__c = 100;
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test,LTD.111';
        acc1.Business_Registration_ID__c = '1234';
        acc1.AccountNumber = '1234';
        acc1.BillingStreet = 'Market St';
        acc1.BillingCity = 'San Francisco';
        acc1.BillingState = 'CA';
        acc1.BillingPostalCode = '9400';
        acc1.BillingCountry = 'US';
        acc1.Total_Authorized_Shares__c = 100;
        insert acc1;
        
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.Status__c = 'Approved';
        businessFiling.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling.Work_Order__c = workorder.Id;
        businessFiling.Total_Authorized_Shares__c = 10;
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Type__c = 'Conversion';
        insert businessFiling;
        
        Business_Filing__c businessFiling1 = new Business_Filing__c();
        businessFiling1.Account__c = acc1.Id;
        businessFiling1.Status__c = 'Approved';
        businessFiling1.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling1.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling1.Work_Order__c = workorder.Id;
        businessFiling1.Total_Authorized_Shares__c = 10;
        businessFiling1.Citizenship__c = 'Domestic';
        businessFiling1.Type__c = 'Merger';
        insert businessFiling1;
                
        List<Business_Filing__c> filingList = new List<Business_Filing__c>();
        filingList.add(businessFiling);
        filingList.add(businessFiling1);
        
        Name_Change_History__c hisInst = new Name_Change_History__c();
        hisInst.Account__c = acc.Id;
        hisInst.Business_Filing__c = businessFiling.Id;
        hisInst.Business_Name_New__c = 'abc';
        hisInst.Business_Name_Old__c = 'xyz';
        hisInst.Name_Change_Date__c = system.today();
        insert hisInst; 
        
        Business_History__c obh = new Business_History__c();
        obh.Surviving_Business__c = acc.id;
        obh.Business_Filing__c = businessFiling.id;
        obh.Merging_Business__c = acc.id;
        insert obh;
        
        Business_History__c obh1 = new Business_History__c();
        obh1.Surviving_Business__c = acc.id;
        obh1.Business_Filing__c = businessFiling1.id;
        obh1.Merging_Business__c = acc1.id;
        insert obh1;
        Test.startTest();
        brs_onlineEnquiryBusinessSearch.getFilingDetails(businessFiling.id);
        brs_onlineEnquiryBusinessSearch.getFilingDetails(businessFiling1.id);
        Test.stopTest();
    }
}