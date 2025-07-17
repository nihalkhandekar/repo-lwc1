/*********************************************************************************************
* NAME:  brsAdminDissolutionTest
* DESCRIPTION: Test class for brs_adminDissolveController and BRSMostRecentFilingDateBatch
*          
*
* @AUTHOR: Rahul Sharma
* @DATE: 29/06/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Rahul Sharma          29/06/2021                             Created
*********************************************************************************************/
@isTest(seeAllData = false)
private class brsAdminDissolutionTest {
    @testSetup
    private static void setup() {
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        List<Account> accLst = new List<Account>();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc.BillingStreet = 'test';
        acc.BillingCity  = 'abc';
        acc.BillingState = 'CT';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '67656';
        accLst.add(acc);
        Account acc2 = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc2.BillingStreet = 'test';
        acc2.BillingCity  = 'abc';
        acc2.BillingState = 'CT';
        acc2.BillingCountry = 'US';
        acc2.BillingPostalCode = '67659';
        accLst.add(acc2);
        insert accLst;
        acc.Sub_Status__c = system.label.Ready_for_dissolution;
        update acc;
        acc2.Sub_Status__c = system.label.Ready_for_dissolution;
        update acc2;
        acc2.Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label;
        update acc2;
        acc2.Status_changed_on__c = system.now().addDays(-91);
        update acc2;
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        List<Business_Filing__c> lstBusFil = new List<Business_Filing__c>();
        Business_Filing__c bfc = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Approved,acc.Id,'Interim Notice',system.label.LLC,RecordTypeIdMaintenance );
        bfc.Filing_Date__c = system.today().addDays(-1);
        lstBusFil.add(bfc);
        Business_Filing__c bfc2 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,system.label.Approved,acc.Id,'Interim Notice',system.label.LLC,RecordTypeIdMaintenance );
        bfc2.Filing_Date__c = system.today();
        lstBusFil.add(bfc2);
        insert lstBusFil;
    }
    @isTest
    private static void testVFbrs_administrivateDissolutionIntentPage() {
        try{
        List<Account> acc = [Select Id,Sub_status__c,No_address_found__c,RecordType.Name from account where BillingPostalCode = '67656' limit 1];
        Test.startTest();
        String strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        strUrl.replace('my.salesforce','visualforce');
        PageReference myVfPage = new PageReference(strUrl +'/apex/'+system.label.vfPageLabel_brs_administrivateDissolutionIntentPage);
        myVfPage.getParameters().put('id',acc[0].id);
        Test.setCurrentPage(myVfPage); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
        sc.setSelected(acc);
        List<ListView> lstView= [SELECT Id, Name, DeveloperName  FROM ListView where SobjectType =: system.label.Account and DeveloperName =: system.label.Ready_for_Administrative_Dissolution_Label limit 1];
        sc.setFilterId(lstView[0].Id);
        brs_adminDissolveController controller = new brs_adminDissolveController(sc);
        controller.processAdminDissolution();
        Test.stoptest();  
        }catch(Exception e){ System.debug(e);}
        
        }
    @isTest
    private static void testVFbrs_administrivateDissolutionIntentPage2() {
        List<Account> acc = [Select Id,Sub_status__c,No_address_found__c,RecordType.Name from account where BillingPostalCode = '67656' limit 1];
        Test.startTest();
        String strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        strUrl.replace('my.salesforce','visualforce');
        PageReference myVfPage = new PageReference(strUrl +'/apex/'+system.label.vfPageLabel_brs_administrivateDissolutionIntentPage);
        myVfPage.getParameters().put('id',acc[0].id);
        Test.setCurrentPage(myVfPage); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
        sc.setSelected(acc);
        brs_adminDissolveController controller = new brs_adminDissolveController(sc);
        controller.processAdminDissolution();
        Test.stoptest();  
    }
    @isTest
    private static void testVFbrs_administrivateDissolutionPage() {
        List<Account> acc = [Select Id,Sub_status__c,No_address_found__c,RecordType.Name from account  where BillingPostalCode = '67659' limit 1];
        Test.startTest();
        String strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        strUrl.replace('my.salesforce','visualforce');
        PageReference myVfPage = new PageReference(strUrl +'/apex/'+system.label.vfPageLabel_brs_administrivateDissolutionPage);
        myVfPage.getParameters().put('id',acc[0].id);
        Test.setCurrentPage(myVfPage); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
        sc.setSelected(acc);
        List<ListView> lstView= [SELECT Id, Name, DeveloperName  FROM ListView where SobjectType =: system.label.Account and DeveloperName =: system.label.Ready_for_Forfeiture_Revocation_Label limit 1];
        sc.setFilterId(lstView[0].Id);
        brs_adminDissolveController controller = new brs_adminDissolveController(sc);
        controller.processAdminDissolution();
        controller.goToListView();
        Test.stoptest();  
    }
    @isTest
    private static void testVFbrs_administrivateDissolutionPage2() {
        List<Account> acc = [Select Id,Sub_status__c,No_address_found__c,RecordType.Name from account  where BillingPostalCode = '67659' limit 1];
        Test.startTest();
        String strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        strUrl.replace('my.salesforce','visualforce');
        PageReference myVfPage = new PageReference(strUrl +'/apex/'+system.label.vfPageLabel_brs_administrivateDissolutionPage);
        myVfPage.getParameters().put('id',acc[0].id);
        Test.setCurrentPage(myVfPage); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
        sc.setSelected(acc);
        brs_adminDissolveController controller = new brs_adminDissolveController(sc);
        controller.processAdminDissolution();
        Test.stoptest();  
    }
    @isTest
    private static void testBRSMostRecentFilingDateBatch() {
        Test.startTest();
        String strQuery = 'SELECT ID FROM Account WHERE status__c not in: statuses '; 
        BRSMostRecentFilingDateBatch be = new BRSMostRecentFilingDateBatch(strQuery);
        Database.executeBatch(be);
        Test.stoptest();  
    }

    @isTest
    private static void test_brs_AdminDissolutionBatch2() {
        Test.startTest();
        String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,BillingState FROM Account WHERE status__c in: statuses and sub_status__c in: substatuses'; 
        brs_AdminDissolutionBatch2 bmr=new brs_AdminDissolutionBatch2(query);
        Database.executeBatch(bmr);
        Test.stoptest();  
    }
    @isTest
    private static void test_brs_AdminDissolutionBatch2_1() {
        Test.startTest();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc.BillingStreet = 'test';
        acc.BillingCity  = 'abc';
        acc.BillingState = 'CT';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '67656';
        insert acc;
        acc.Sub_Status__c = system.label.Ready_for_dissolution;
        update acc;
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();        
        Business_Filing__c bfc2 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,'Past Due',acc.Id,'Annual Report',system.label.LLC,mainRecTypeId);
        bfc2.Filing_Date__c = system.today();
        bfc2.Due_Date__c = system.today().addDays(-366);
        insert bfc2;        
        String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,BillingState FROM Account WHERE status__c in: statuses and sub_status__c in: substatuses'; 
        brs_AdminDissolutionBatch2 bmr=new brs_AdminDissolutionBatch2(query);
        Database.executeBatch(bmr);
        Test.stoptest();  
    }
    @isTest
    private static void test_brs_AdminDissolutionBatch2_2() {
        Test.startTest();
        Account acc = BRS_TestDataFactory.createAcc(system.label.Foreign_Label_Comparable,system.label.LLC);
        acc.BillingStreet = 'test';
        acc.BillingCity  = 'abc';
        acc.BillingState = 'CT';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '67656';
        insert acc;
        acc.Sub_Status__c = system.label.Ready_for_dissolution;
        update acc;
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();        
        Business_Filing__c bfc2 = BRS_TestDataFactory.createBusFile(system.label.Foreign_Label_Comparable,'Past Due',acc.Id,'First Report',system.label.LLC,mainRecTypeId);
        bfc2.Filing_Date__c = system.today();
        bfc2.Due_Date__c = system.today().addDays(-366);
        insert bfc2;
        String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,BillingState FROM Account WHERE status__c in: statuses and sub_status__c in: substatuses'; 
        brs_AdminDissolutionBatch2 bmr=new brs_AdminDissolutionBatch2(query);
        Database.executeBatch(bmr);
        Test.stoptest();  
    }
   @isTest
    private static void testVFbrs_administrivateDissolutionIntentPage1() {
        try{
        List<Account> acc = [Select Id,Sub_status__c,No_address_found__c,RecordType.Name from account where BillingPostalCode = '67656' limit 1];
        Test.startTest();
        String strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        strUrl.replace('my.salesforce','visualforce');
        PageReference myVfPage = new PageReference(strUrl +'/apex/'+system.label.vfPageLabel_brs_administrivateDissolutionIntentPage);
        myVfPage.getParameters().put('id',acc[0].id);
        Test.setCurrentPage(myVfPage); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
        sc.setSelected(acc);
        List<ListView> lstView= [SELECT Id, Name, DeveloperName  FROM ListView where SobjectType =: system.label.Account and DeveloperName =: system.label.Ready_for_Administrative_Dissolution_Label limit 1];
        sc.setFilterId(lstView[0].Id);
        brs_adminDissolveController controller = new brs_adminDissolveController(sc);
        controller.processAdminDissolution();
        Test.stoptest();  
        }catch(Exception e){ System.debug(e);}
        
        }
    
}