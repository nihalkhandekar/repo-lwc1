@isTest
public class BRS_Utility_Test1 {
    
    @isTest
    static void getTableDataForReviewTest() {
        Temp_History__c th=BRS_TestDataFactory.createTempHistoryObject();
        List<Temp_History__c> templist=new List<Temp_History__c>{th};
            Map<Id, Temp_History__c> tempMap=new Map<Id, Temp_History__c>(templist);
        Map<String, Map<Id, Temp_History__c>> datalist=new Map<String, Map<Id, Temp_History__c>>();
        datalist.put('Edited',tempMap);
        datalist.put('Deleted',tempMap);
        BRS_Utility.getTableDataForOverview(templist,datalist);
        BRS_Utility.getTableDataForOverview(templist,new Map<String, Map<Id, Temp_History__c>>());
    }
    
    @isTest
    static void typeCastToWrapperTest(){
        Account acc=BRS_TestDataFactory.createAccountObject();
        Principal__c p=BRS_TestDataFactory.createPrincipal();
        Agent__c a=BRS_TestDataFactory.createAgent(acc.Id);
        Temp_History__c th=BRS_TestDataFactory.createTempHistoryObject();
        BRS_Utility.typeCastToWrapper(new List<Principal__c>{p}, new List<Agent__c>{a},new List<Temp_History__c>{th});
    }
    @isTest
    static void getCertificateTest(){
        Id bCertRecTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();        
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.State_or_Territory_Formation__c='Test';
        acc.ShippingStreet='test';
        update acc;
        Certficate__c cert= BRS_TestDataFactory.createCertificate(bCertRecTypeId,acc.Id, null);
        Certficate__c certdata=[Select Id,Name,Business__r.AccountNumber from Certficate__c where Id=:cert.Id LIMIT 1];
        Copy_Request_Details__c copyInfo = new Copy_Request_Details__c();
        copyInfo.Other_Request__c = certdata.Id;
        insert copyInfo;
        Copy_Request_Details__c copyData = [Select Id,Name from Copy_Request_Details__c where Id=:copyInfo.Id LIMIT 1];
        BRS_Utility.getCertificate(certdata.Name,certdata.Business__r.AccountNumber);
        BRS_Utility.getCertificate(copyData.Name,certdata.Business__r.AccountNumber);
        BRS_Utility.getLatestStateForALEI(acc.Id);
        BRS_Utility.getAddress(acc, new List<String>{'State_or_Territory_Formation__c','ShippingStreet'});
        // BRS_Utility.getAddressAndValidate(acc, null);
    }
    @isTest
    static void getAccContactListTest(){
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.ClientAccountNum__c = '12345';
        update con;
        Id p = [select id from profile where name='CT Community User'].id;
        User user = QnA_TestDataFactory.createCommunityUser(con,p);
        System.runAs(user){
            BRS_Utility.getAccContactList();
            BRS_Utility.getLoggedInUserProfile();
        }
    }   
    
    @isTest
    public static void testGetPrincipalId() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        
        Principal__c pr1 = BRS_TestDataFactory.createPrincipal();
		pr1.Business_ID__c=acc.id;
        update pr1;
        
        Test.startTest();
        try {
            BRS_Utility.getPrincipalById(pr1.Id);
            BRS_Utility.getPrincipalById('578493098');
        }
        catch(Exception e){}
        Test.stopTest();
    }

    @isTest
    public static void testGetLatestStateForALEI() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        
        Principal__c pr1 = BRS_TestDataFactory.createPrincipal();
		pr1.Business_ID__c=acc.id;
        update pr1;
        
        Test.startTest();
        try {
            BRS_Utility.getLatestStateForALEI(acc.Id);
            BRS_Utility.getLatestStateForALEI(pr1.Id);
        }
        catch(Exception e){}
        Test.stopTest();
    }

    @isTest
    public static void testUpdateSectionNameinFiling() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, 'Annual Report', 'In-Progress');
        
        Test.startTest();
        try{
            BRS_Utility.updateSectionNameinFiling(filing.Id, 'Test Section Name', 'Test Section');
            BRS_Utility.updateSectionNameinFiling('0549098', 'Test Section Name', 'Test Section');
        }
        catch(Exception e){}

        Test.stopTest();
    }

    @isTest
    public static void testGetPicklistLabel() {
        Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
        Schema.SObjectType oneSObjectType = mapSObjects.get('Account');
        Test.startTest();
        try{
            BRS_Utility.getPicklistLabel(oneSObjectType, 'Business_Type__c', 'Stock Corporation');
            BRS_Utility.getPicklistLabel(oneSObjectType, null, null);
        }
        catch(Exception e){}
        Test.stopTest();
    }

    @isTest
    public static void testGetUserDetails() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);

        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = BRS_TestDataFactory.createCommunityUser(con, p.Id);

        List<Id> userIds = new List<Id>();

        Test.startTest();
        try{
            userIds.add(u.Id);
            BRS_Utility.getUsersDetail(userIds);

            userIds.clear();
            BRS_Utility.getUsersDetail(userIds);
        }
        catch(Exception e) {}
        Test.stopTest();
    }

    @isTest
    public static void testLinkBusinessToContact1() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);

        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = BRS_TestDataFactory.createCommunityUser(con, p.Id);

        Test.startTest();
        try{
            BRS_Utility.linkBusinessToContact(acc.Id, u.Id);
        }
        catch(Exception e) {}
        Test.stopTest();
    }

    @isTest
    public static void testLinkBusinessToContact2() {
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Account acc2 = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc2;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);

        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = BRS_TestDataFactory.createCommunityUser(con, p.Id);

        Test.startTest();
        try{
            BRS_Utility.linkBusinessToContact(acc2.Id, u.Id);
            BRS_Utility.linkBusinessToContact('0', '1');
        }
        catch(Exception e) {}
        Test.stopTest();
    }

    @isTest
    public static void testReviewConfigWrapper() {
        BRS_Utility.ReviewConfig rc = new BRS_Utility.ReviewConfig();
        brs_fileUploaderController.contentDocDetails cd = rc.documentData;
        Map<String, Map<Id, sObject>> mp1 = rc.associatedModifiedDataMap;

        //BRS_Utility.wrapperTableData wt = new BRS_Utility.wrapperTableData();
        Map<String, List<List<BRS_Utility.wrapperTableData>>> mp2 = rc.associatedAddedOrDeletedData;
        Map<String, List<Map<String, List<BRS_Utility.wrapperTableData>>>> mp3 = rc.associatedUpdatedDate;

        String s = rc.associatedChangedDataValue;
        Boolean b1 = rc.showViewUpdateForAgent;
        Boolean b2 = rc.hasEditedData;
        Boolean b3 = rc.hasCreatedData;
        List<Object> lstObj1 = rc.principalListForAcknowledgementAnnualFlow;
        List<Object> lstObj2 = rc.principalListForAcknowledgementFirstFlow;
    }

    @isTest
    public static void testCloneBusinessFilingWithRelatedRecords() {
        OnOff_Filing_Auto_Refund__c onOffSwitch = new OnOff_Filing_Auto_Refund__c();
        onOffSwitch.Name = 'On Off Switch';
        onOffSwitch.Auto_Refund_Business_Filing__c = true;
        insert onOffSwitch;
        
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, 'Annual Report', 'In-Progress');

        List<Temp_History__c> lstTmpRecords = new List<Temp_History__c>();
        Temp_History__c tmp0 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, 'Created', 'Director', 'Boss');

        lstTmpRecords.add(tmp0);
        
        if(!lstTmpRecords.isEmpty()){
            insert lstTmpRecords;
        }     
        
        Test.startTest();
        try{
            BRS_Utility.cloneBusinessFilingWithRelatedRecords(filing.Id);
            BRS_Utility.cloneBusinessFilingWithRelatedRecords('287r98w7');
        }
        catch(Exception e) {}
        Test.stopTest();
    }
}