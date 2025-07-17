@isTest
public class SdocsAnnualRepTemplateApex_Test {
    private static final String EMPTY_STRING = '';
    private static final String PRINCIPAL = 'Principal';
    private static final String CREATED = 'Created';
    private static final String EDITED = 'Edited';
    private static final String DELETED = 'Deleted';
    private static final String FOREIGN = 'Foreign';
    private static final String ONLINE = 'Online';
    private static final String OPEN = 'Open';
    private static final String STOCK_CORPORATION = 'Stock';
    private static final String ANNUAL_REPORT = 'Annual Report';
    
    @testSetup
    public static void dataSetup() {
        OnOff_Filing_Auto_Refund__c onOffSwitch = new OnOff_Filing_Auto_Refund__c();
        onOffSwitch.Name = 'On Off Switch';
        onOffSwitch.Auto_Refund_Business_Filing__c = true;
        insert onOffSwitch;
        
        Account acc = BRS_TestDataFactory.createAcc(FOREIGN, STOCK_CORPORATION);
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, ONLINE, OPEN);
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, ANNUAL_REPORT, 'In-Progress');
        
        List<Principal__c> lstPrincipals = new List<Principal__c>();
        Principal__c pr1 = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        pr1.Residence_InternationalAddress__c = 'abc street, Kabul';
        pr1.Residence_Country__c = 'Afghanistan';
        pr1.Business_InternationalAddress__c = 'abc street, Kabul';
        pr1.Business_Country__c = 'Afghanistan';
		
		Principal__c pr2 = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        pr2.Residence_InternationalAddress__c = 'abc street, Kabul';
        pr2.Residence_Country__c = 'Afghanistan';
        pr2.Business_InternationalAddress__c = 'abc street, Kabul';
        pr2.Business_Country__c = 'Afghanistan';
		
		Principal__c pr3 = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
		pr3.Residence_InternationalAddress__c = 'abc street, Kabul';
        pr3.Residence_Country__c = 'Afghanistan';
        pr3.Business_InternationalAddress__c = 'abc street, Kabul';
        pr3.Business_Country__c = 'Afghanistan';
        
		Principal__c pr4 = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        pr4.FirstName__c = 'Sam';
        pr4.LastName__c = 'Parker';
        pr4.Name__c = 'Sam Parker';
        pr4.Principal_Title__c = 'Semi-Boss';
        pr4.Designation__c = 'Officer';
        pr4.Business_City__c='US';
        pr4.Business_Street_Address_1__c='123Wash';
        pr4.Business_Street_Address_2__c='Mann';
        pr4.Business_Zip_Code__c='12345';
        pr4.Business_State__c='CA';
        pr4.Business_Country__c='India';
        pr4.Business_InternationalAddress__c = null;
        pr4.Residence_InternationalAddress__c = 'abc street, Kabul';
        pr4.Residence_Country__c = 'Afghanistan';
        
        lstPrincipals.add(pr1);
        lstPrincipals.add(pr2);
        lstPrincipals.add(pr3);
        lstPrincipals.add(pr4);
        
        if(!lstPrincipals.isEmpty()) {
            insert lstPrincipals;
        }
        
        List<Temp_History__c> lstTmpRecords = new List<Temp_History__c>();
        Temp_History__c tmp0 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, CREATED, 'Director', 'Boss');
        tmp0.Business_Street_Address_1__c = EMPTY_STRING;
        tmp0.Residence_Street_Address_1__c = EMPTY_STRING;
        Temp_History__c tmp1 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, CREATED, 'Director', 'Boss');
        tmp1.FirstName__c = 'Sam';
        tmp1.LastName__c = 'Parker';
        tmp1.Name__c = 'Sam Parker';
        Temp_History__c tmp2 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, CREATED, 'Officer;Director', 'Semi-Boss');
        Temp_History__c tmp3 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, CREATED, 'Officer', 'Half-Boss');
        Temp_History__c tmp4 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, CREATED, EMPTY_STRING, 'Full-Boss');
        Temp_History__c tmp5 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, pr1.Id, EDITED, 'Officer', 'Semi-Boss');
        Temp_History__c tmp6 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, pr1.Id, EDITED, 'Director', 'Semi-Boss');
        Temp_History__c tmp7 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, pr1.Id, EDITED, 'Officer;Director', 'Semi-Boss');
        Temp_History__c tmp8 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, pr1.Id, EDITED, EMPTY_STRING, 'Semi-Boss');
        Temp_History__c tmp9 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, DELETED, 'Officer;Director', 'Half-Boss');
        Temp_History__c tmp10 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, DELETED, 'Officer', 'Half-Boss');
        Temp_History__c tmp11 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, DELETED, 'Director', 'Half-Boss');
        Temp_History__c tmp12 = BRS_TestDataFactory.createTempHistoryForPrincipal(filing.Id, acc.Id, null, DELETED, EMPTY_STRING, 'Full-Boss');
        
        lstTmpRecords.add(tmp0);
        lstTmpRecords.add(tmp1);
        lstTmpRecords.add(tmp2);
        lstTmpRecords.add(tmp3);
        lstTmpRecords.add(tmp4);
        lstTmpRecords.add(tmp5);
        lstTmpRecords.add(tmp6);
        lstTmpRecords.add(tmp7);
        lstTmpRecords.add(tmp8);
        lstTmpRecords.add(tmp9);
        lstTmpRecords.add(tmp10);
        lstTmpRecords.add(tmp11);
        lstTmpRecords.add(tmp12);
        
        if(!lstTmpRecords.isEmpty()){
            insert lstTmpRecords;
        }      
    }
    
    @isTest
    public static void annualReportCurrentPrincipalTableTest(){        
        List<Account> lstAcc = (List<Account>) fetchSObjectRecords('Account');
        List<Business_Filing__c> lstFiling = (List<Business_Filing__c>) fetchSObjectRecords('Business_Filing__c');
        List<Temp_History__c> lstTmp = (List<Temp_History__c>) fetchSObjectRecords('Temp_History__c');
        List<Principal__c> lstPr = (List<Principal__c>) fetchSObjectRecords('Principal__c');
        
        Test.startTest();
        Map<String,Object> args = new Map<String,Object>();
        args.put('recordId', lstFiling[0].Id);
        args.put('accId', lstAcc[0].Id);
        SdocsAnnualReportTemplateApexActions targetClass = new SdocsAnnualReportTemplateApexActions();
       // targetClass.call('getLineItemsAsSDocTable', args);
        Test.stopTest();
    }

    @isTest
    public static void annualReportNewPrincipalTableTest(){        
        List<Account> lstAcc = (List<Account>) fetchSObjectRecords('Account');
        List<Business_Filing__c> lstFiling = (List<Business_Filing__c>) fetchSObjectRecords('Business_Filing__c');
        List<Temp_History__c> lstTmp = (List<Temp_History__c>) fetchSObjectRecords('Temp_History__c');
        List<Principal__c> lstPr = (List<Principal__c>) fetchSObjectRecords('Principal__c');
        
        Test.startTest();
        Map<String,Object> args = new Map<String,Object>();
        args.put('recordId', lstFiling[0].Id);
        SdocsAnnualReportTemplateApexActions targetClass = new SdocsAnnualReportTemplateApexActions();
        //targetClass.call('getLineItemsAsSDocTableNewPrincipal', args);
        Test.stopTest();
    }
    
    @isTest
    public static void annualReportRemovedPrincipalTableTest(){        
        List<Account> lstAcc = (List<Account>) fetchSObjectRecords('Account');
        List<Business_Filing__c> lstFiling = (List<Business_Filing__c>) fetchSObjectRecords('Business_Filing__c');
        List<Temp_History__c> lstTmp = (List<Temp_History__c>) fetchSObjectRecords('Temp_History__c');
        List<Principal__c> lstPr = (List<Principal__c>) fetchSObjectRecords('Principal__c');
        lstPr[0].Residence_InternationalAddress__c=null;
        lstPr[0].Residence_Street_Address_1__c ='Test';
        Test.startTest();
        Map<String,Object> args = new Map<String,Object>();
        args.put('recordId', lstFiling[0].Id);
        SdocsAnnualReportTemplateApexActions targetClass = new SdocsAnnualReportTemplateApexActions();
        //targetClass.call('getLineItemsAsSDocTableDeletedPrincipal', args);
        new SdocsAnnualReportTemplateApexActions().comparePrincipals(lstPr[0],lstPr[0],'Stock');
        Test.stopTest();
    }
    @isTest
    public static void annualReportRemovedPrincipalTableTest1(){        
        List<Account> lstAcc = (List<Account>) fetchSObjectRecords('Account');
        List<Business_Filing__c> lstFiling = (List<Business_Filing__c>) fetchSObjectRecords('Business_Filing__c');
        List<Temp_History__c> lstTmp = (List<Temp_History__c>) fetchSObjectRecords('Temp_History__c');
        List<Principal__c> lstPr = (List<Principal__c>) fetchSObjectRecords('Principal__c');
        lstPr[0].Principal_Type__c = 'Business';
        lstPr[0].Business_InternationalAddress__c = null;
        lstPr[0].Business_Street_Address_1__c = 'test';
        Test.startTest();
        Map<String,Object> args = new Map<String,Object>();
        args.put('recordId', lstFiling[0].Id);
        SdocsAnnualReportTemplateApexActions targetClass = new SdocsAnnualReportTemplateApexActions();
        //targetClass.call('getLineItemsAsSDocTableDeletedPrincipal', args);
        new SdocsAnnualReportTemplateApexActions().comparePrincipals(lstPr[0],lstPr[0],'Stock');
        Test.stopTest();
    }
    
    private static List<SObject> fetchSObjectRecords (String obj) {
        List<SObject> lstRec = new List<SObject>();
        if(obj == 'Temp_History__c') {
            lstRec = Database.query(
                'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',') + ',Business_Id__r.Business_Type__c'
                +' FROM ' + obj
            );
        }
        else {
            lstRec = Database.query(
                'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
                +' FROM ' + obj
            );
        }
        
        return lstRec;
    }
}