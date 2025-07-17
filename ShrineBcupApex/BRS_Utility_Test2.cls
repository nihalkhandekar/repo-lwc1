@isTest
public class BRS_Utility_Test2 {
    public class wrapperChecklist
    {
        public String name;
        public String isChecked;
        
    }
    @testSetup static void setup() {
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account accInst = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(accInst.id);
        User user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;

        List<UCC_Lien__c> insertUCCLList=new List<UCC_Lien__c>();
        UCC_Lien__c uccOnlineLien=new UCC_Lien__c(Name__c='OnlineUCC');
        insertUCCLList.add(uccOnlineLien);

        insert insertUCCLList;

        Agent__c agent = new Agent__c(Business_ID__c=accInst.Id,Name__c='Test Agent',FirstName__c='Agent', Business_Zip_Code__c = '12345');
        insert agent;
        
        List<UCC_Filing__c> insertUFList = new List<UCC_Filing__c>();
        UCC_Filing__c uccFileOnline = new UCC_Filing__c();
        uccFileOnline.Type__c = 'Transmitting Utility';
        uccFileOnline.UCC_Lien_Type__c = 'OFS';
        //uccFileOnline.Work_Order__c = onlineUCCWorkorder.Id;
        uccFileOnline.UCC_Lien_Id__c = uccOnlineLien.Id;
        uccFileOnline.Filing_Source__c = 'Online';
        uccFileOnline.Amount__c = 200;
        uccFileOnline.Owner_name_present__c='Yes';
        uccFileOnline.Owner_address_present__c='Yes';
        uccFileOnline.Claimant_name_present__c='Yes';
        uccFileOnline.Claimant_address_present__c='Yes';
        uccFileOnline.Aircraft_Vessel_name_present__c='Yes';
        uccFileOnline.Form_legible__c='Yes';
        uccFileOnline.Referenced_documents_attached__c='Yes';
        uccFileOnline.Meets_other_requirements__c='Yes';
        uccFileOnline.Debtor_name_present__c='Yes';
        uccFileOnline.Debtor_address_present__c='Yes';
        uccFileOnline.Indicates_debtor_is_indiviudal_organizat__c='Yes';
        uccFileOnline.Secured_party_name_present__c='Yes';
        uccFileOnline.Secured_party_address_present__c='Yes';
        uccFileOnline.Description_of_vessel__c='Yes';
        uccFileOnline.Statement_of_assumed_ownership__c='Yes';
        uccFileOnline.Judgment_debtor_present__c='Yes';
        uccFileOnline.Judgment_creditor_present__c='Yes';
        uccFileOnline.Defendant_name_present__c='Yes';
        uccFileOnline.Plaintiff_name_present__c='Yes';
        uccFileOnline.Is_court_order_present__c='Yes';
        uccFileOnline.Is_court_order_signed__c='Yes';
        insertUFList.add(uccFileOnline);
        Insert insertUFList;
		
        Work_Order__c onlineBusWorkorder = new Work_Order__c();
        onlineBusWorkorder.Status__c = 'In-Progress';
        onlineBusWorkorder.Type__c = 'Business';
        onlineBusWorkorder.Source__c = 'Online';
        onlineBusWorkorder.Customer__c = con.Id;
        onlineBusWorkorder.Received_Date__c = System.today();
        insert onlineBusWorkorder;
        
        Id newbusinessRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        List<Business_Filing__c> insertBFList = new List<Business_Filing__c>();
        Business_Filing__c onlineBusFiling = new Business_Filing__c();
        //onlineBusFiling.Work_Order__c = onlineBusWorkorder.Id;
        onlineBusFiling.RecordTypeId = newbusinessRecTypeId;
        onlineBusFiling.Source__c = 'Online';
        onlineBusFiling.Type__c = 'Business Registration';
        insertBFList.add(onlineBusFiling);
        
        Business_Filing__c onlineApprovedBusFiling = new Business_Filing__c();
        onlineApprovedBusFiling.Work_Order__c = onlineBusWorkorder.Id;
        onlineApprovedBusFiling.RecordTypeId = newbusinessRecTypeId;
        onlineApprovedBusFiling.Source__c = 'Online';
        onlineApprovedBusFiling.Type__c = 'Business Registration';
        onlineApprovedBusFiling.Status__c = 'Approved';
        insertBFList.add(onlineApprovedBusFiling);
        
         Business_Filing__c onlineApprovedBusFilingStock = new Business_Filing__c();
        onlineApprovedBusFilingStock.Work_Order__c = onlineBusWorkorder.Id;
        onlineApprovedBusFilingStock.RecordTypeId = newbusinessRecTypeId;
        onlineApprovedBusFilingStock.Source__c = 'Online';
        onlineApprovedBusFilingStock.Type__c = 'Business Formation';
        onlineApprovedBusFilingStock.Status__c = 'Approved';
        insertBFList.add(onlineApprovedBusFilingStock);
        
        Insert insertBFList;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'TestDocument',
            PathOnClient = 'TestDocument.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = onlineApprovedBusFiling.id;
        contentlink.ContentDocumentId = documents[0].Id;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        List<Attachment> attList = new List<Attachment>();
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.parentId=onlineApprovedBusFiling.id;
        attList.add(attach);
        //insert attach;
        
        Attachment attach_1=new Attachment(); 
        attach_1.Name='Unit Test Attachment Stock'; 
        Blob bodyBlob_1=Blob.valueOf('Unit Test Attachment Body Stock'); 
        attach_1.body=bodyBlob; 
        attach_1.parentId=onlineApprovedBusFilingStock.id;
        attList.add(attach_1);
        insert attList;
        
        
        /****************************************/
        
        /*OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;*/
        
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing1 = new Business_Filing__c();
            filing1.Account__c=accInst.Id;
            filing1.Filing_Fee__c=30;
            filing1.Type__c = system.label.Annual_Report;
            filing1.Citizenship__c = 'Domestic';
            filing1.Filing_Date__c = System.Today().addDays(-30);
            filing1.Due_Date__c = (System.today() + 5);
            filing1.Status__c='Approved';
            filingList.add(filing1);
        }
        insert filingList;
        
        Map<Id, Boolean> busFilingIDList = new Map<Id, Boolean>();
        busFilingIDList.put(filingList[0].Id, false);
        System.debug('filing id @@@@@@'+filingList[0].Id);
        
        Principal__c princ= new Principal__c();
        princ.Name__c = 'test principal 1';
        princ.Designation__c = 'Director';
        princ.Email__c = 'test@test.com';
		princ.Residence_Street_Address_1__c = '100 st';
		princ.Residence_Street_Address_2__c = '200 st';
		princ.Residence_City__c = 'NY';
		princ.Residence_Country__c = 'United States';
		princ.Residence_State__c = 'CT';
		princ.Residence_Zip_Code__c = '11111';
		//princ.Business_InternationalAddress__c = '500 st';
		//princ.Residence_InternationalAddress__c = 'test residence address';
		princ.Business_City__c = 'NY';
		princ.Business_Country__c = 'United States';
		princ.Business_State__c = 'CT';
		princ.Business_Street_Address_1__c = '400 st';
		princ.Business_Street_Address_2__c = '300 st';
		princ.Business_Zip_Code__c = '12345';
        princ.Principal_Title__c = 'PRESIDENT';
        princ.Principal_Type__c = 'Individual';
        princ.FirstName__c = 'test first name';
        princ.LastName__c = 'test last name';
        
        insert princ;
        
        Principal__c pp = [SELECT Id, Name, Email__c, Business_ID__c, Principal_Title__c, Principal_Type__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_City__c, Residence_State__c, Residence_Country__c, Business_Street_Address_1__c, Business_Street_Address_3__c, Business_Street_Address_2__c, Business_City__c, Business_Zip_Code__c, Business_State__c, Business_Country__c, FirstName__c, LastName__c, Name__c, Business_Address__c, Mailing_Address__c, Type__c, Business_Address_1__c, Residence_Address__c, Business_InternationalAddress__c, Residence_InternationalAddress__c, Designation__c FROM Principal__c WHERE Id=:princ.Id LIMIT 1];
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,accInst.id,System.label.Label_Principal,'Created');
        //tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Principal','Deleted');
        //tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Agent','Created');
        //tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Agent','Deleted');
        //tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Account','Created');
        
        /****************************************/
    }

    

    
    
    testmethod static void testSendBulkEmail(){
        List<Business_Filing__c> businessFilingList = [Select id,Status__c,Type__c,Business_Type__c,Source__c,Work_Order__r.Customer__c,Work_Order__r.Customer__r.Email,
                                             Account__r.Business_Email_Address__c from Business_Filing__c where Status__c = 'Approved'];
        System.debug('businessFilingList:'+businessFilingList.size());
        Test.startTest();
        BRS_Utility.sendBulkEmails(businessFilingList);
        Test.stopTest();
    }
    
    testmethod static void testupsertTempRecord(){
        Principal__c pp = [SELECT Id, Name, Email__c, Business_ID__c, Principal_Title__c, Principal_Type__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_City__c, Residence_State__c, Residence_Country__c, Business_Street_Address_1__c, Business_Street_Address_3__c, Business_Street_Address_2__c, Business_City__c, Business_Zip_Code__c, Business_State__c, Business_Country__c, FirstName__c, LastName__c, Name__c, Business_Address__c, Mailing_Address__c, Type__c, Business_Address_1__c, Residence_Address__c, Business_InternationalAddress__c, Residence_InternationalAddress__c, Designation__c FROM Principal__c LIMIT 1];
        Temp_History__c tmpHistory = [Select Id,Type__c,Principal__c, BusinessName_New_Without_Designators__c, Business_Filing__c, Business_Filing__r.Type__c, Business_Filing__r.Status__c, Business_Filing__r.Account__c, Business_Filing__r.Account__r.Name, Business_Filing__r.Account__r.Account_Name_Without_Designators__c, Business_Name_New__c from Temp_History__c where Principal__c=:pp.id limit 1];
        Test.startTest();
        BRS_Utility.upsertTempRecord(tmpHistory);
        Test.stopTest();
    }
    
    @isTest 
    static void updateSObjectFromFlowTest() {
        Account acc = new Account(name = 'Test'/*,Annual_Report_Filing_Fee__c = 2400*/,Annual_Report_Due_Date__c = Date.newInstance(2016, 12, 9),Filing_DateTime__c = datetime.newInstance(2014, 9, 15, 12, 30, 0) );
        insert acc;
        List<String> Accountlist = new List<String>();
        Accountlist.add('Name');
        Accountlist.add('Annual_Report_Filing_Fee__c');
        Accountlist.add('Annual_Report_Due_Date__c');
        Accountlist.add('Filing_DateTime__c');
        Accountlist.add('Filing_Time');
        Map<String,List<String>> sObjectFieldMap  = new Map<String,List<String>>();
        Map<String,String> fieldAndValueMap = new Map<String,String>();
        Map<String,String> fieldAndTypeMap = new Map<String,String>();
        sObjectFieldMap.put('ACCOUNT',Accountlist);
        
        for(Account accountval:[select id,name/*,Annual_Report_Filing_Fee__c*/,Annual_Report_Due_Date__c,Filing_DateTime__c from account where id = :acc.id]) {
            
            fieldAndValueMap.put('Name',accountval.name);
            //fieldAndValueMap.put('Annual_Report_Filing_Fee__c',string.valueOf(accountval.Annual_Report_Filing_Fee__c));
            fieldAndValueMap.put('Annual_Report_Due_Date__c',string.valueOf(accountval.Annual_Report_Due_Date__c));
            fieldAndValueMap.put('Filing_DateTime__c',string.valueOf(accountval.Filing_DateTime__c.format('yyyy-mm-dd')));
        }
        fieldAndTypeMap.put('Annual_Report_Filing_Fee__c','Number');
        fieldAndTypeMap.put('Annual_Report_Due_Date__c','Date');
        fieldAndTypeMap.put('Filing_DateTime__c','DateTime');
        fieldAndTypeMap.put('Filing_Time','Time');
        Test.startTest();
        BRS_Utility.updateSObjectFromFlow(sObjectFieldMap,fieldAndValueMap,fieldAndTypeMap,acc.id);
        Test.stopTest();
	}
    
    
    @isTest 
    static void getAccountTest() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        
        Test.startTest();
        try {
            BRS_Utility.getAccount(acc.Id);
            BRS_Utility.getAccount(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
            try {
                BRS_Utility.getAccount('null');
            } catch (Exception ex) {
                System.assertEquals('Invalid id: null',ex.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
     testmethod static void updateAccountTest() {
        Account acct = new Account(Name='TEST_ACCOUNT');
        Test.startTest();
        try {
            BRS_Utility.updateAccount(acct);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        insert acct;
        acct = [select Id,name from account where id=:acct.Id];
        BRS_Utility.updateAccount(acct);
        Test.stopTest();
    }
    
    testmethod static void updateAgentOnAccountTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Agent__c agent = new Agent__c(FirstName__c = 'Alex',LastName__c = 'Scroggins');
        insert agent;
        agent = [select Id,Business_ID__c from Agent__c where Id=:agent.Id limit 1];
        Test.startTest();
        BRS_Utility.updateAgentOnAccount(acc.id,agent.id);
        try {
            BRS_Utility.updateAgentOnAccount(acc.id,'');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    testmethod static void updateBusinessEmailonAccountTest() {
        Account acc = new Account(Name = 'Test Account',Business_Email_Address__c = 'alex@gmail.com');
        Test.startTest();
        BRS_Utility.updateBusinessEmailonAccount(acc.id,acc.Business_Email_Address__c);
        insert acc;
        BRS_Utility.updateBusinessEmailonAccount(acc.id,acc.Business_Email_Address__c);
        try {
            BRS_Utility.updateBusinessEmailonAccount('','');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    
    testmethod static void getLegalDesignatorsTest() {
        Test.startTest();
        try {
            List<Legal_Designation__mdt> listOfDesignators = [Select Id, Label from Legal_Designation__mdt  where Label not in ('P.C.','PC','Professional Corporation')];
            List<Business_Name_Noisewords__mdt> listOfNoiseWords = [Select Label from Business_Name_Noisewords__mdt];
            List<Tax_Town_Info__mdt> lstRecords =  [SELECT City__c,Tax_Town__c,Multi_Town__c FROM Tax_Town_Info__mdt ORDER BY City__c ASC ];
        	List<BRS_Special_Business_Group_Option__mdt> optionsList = [select Id, Option_Label__c, Option_Value__c, Order__c, Type__c from BRS_Special_Business_Group_Option__mdt Order By Order__c];
        	BRS_Utility.getOptionsData();
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    testmethod static void getAddressTest() {
        Account acct = new Account(Name='TEST_ACCOUNT',Business_Email_Address__c = 'alex@gmail.com');
        Test.startTest();
        BRS_Utility.getAddress(acct,new List<String>{'Name','Business_Email_Address__c'});
        Test.stopTest();
    }
    
    /*testmethod static void getLapsedDiffMonthsTest() {
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData0',UCC_Lien_Number__c='TestData0'));
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=System.today().addYears(1)));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2',Lapse_Date__c=System.today().addYears(-1)));
        insert uccLien;
        Test.startTest();
        System.assertEquals(false,BRS_Utility.getLapsedDiffMonths(uccLien[1].Id));
        //System.assertEquals(false,BRS_Utility.getLapsedDiffMonths(uccLien[2].Id));
        try {
            delete uccLien[1];
            BRS_Utility.getLapsedDiffMonths(uccLien[2].Id);
            BRS_Utility.getLapsedDiffMonths(uccLien[0].Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }*/
    
    testmethod static void fetchAPIInterfaceConfigTest() {
        Test.startTest();
        BRS_Utility.fetchAPIInterfaceConfig(System.Label.Review_MasterLabel_Type_Debtor);
        Test.stopTest();
    }
    
    testmethod static void getBusinessFilingTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Business_Filing__c bfc = new Business_Filing__c(Type__c = 'Business Registration', Account__c = acc.Id, RecordtypeID = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId());
        insert bfc;
        Test.startTest();
        try {
            BRS_Utility.getBusinessFiling(acc.id,'',bfc.Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    } 
    
    @IsTest
    static void getFilingFee() {
        string value='';
        string label='ABC';
        String reportType;
        Filing_Fee__mdt filingfee = new Filing_Fee__mdt();
        filingfee.Field_Value__c=value;
        filingfee.Label=label;
        test.startTest();
        BRS_Utility.getFilingFee(value,label,reportType);
        test.stopTest();
    }
    
    testmethod static void getCountriesTest() {
        Test.startTest();
        System.assertNotEquals(null,BRS_Utility.getCountries());
        Test.stopTest();
    }
    
    @IsTest
    static void getMonth() {
        test.startTest();
        BRS_Utility.getMonth(1);
        BRS_Utility.getMonth(2);
        BRS_Utility.getMonth(3);
        BRS_Utility.getMonth(4);
        BRS_Utility.getMonth(5);
        BRS_Utility.getMonth(6);
        BRS_Utility.getMonth(7);
        BRS_Utility.getMonth(8);
        BRS_Utility.getMonth(9);
        BRS_Utility.getMonth(10);
        BRS_Utility.getMonth(11);
        BRS_Utility.getMonth(12);
        BRS_Utility.getMonth(13);
        test.stopTest();
    }
    
    @isTest
    public static void getPicklistLabeltest(){
  
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Business_Filing__c');
        Test.startTest();
        String ret = BRS_Utility.getPicklistLabel(objType, 'Type__c', 'Annual Report');
        System.assertEquals('Annual Report', ret);
        Test.stopTest();
    }
    
    
    @IsTest
    static void processBusinessMaintenance() {
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        //Account acc = BRS_TestDataFactory.createAccountObject();
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,'Rejected');
        
        BRS_Utility.Requests req = new BRS_Utility.Requests();
        req.rejectedFilingId=filing.Id;
        List<BRS_Utility.Requests> Requests = new List<BRS_Utility.Requests>();
        Requests.add(req);
        //BRS_Utility.processBusinessMaintenance(Requests);
        test.stopTest();
    }
    
    /*@isTest
    public static void updateRecordsFromTempAgenttest(){
        //Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        //insert acc;
        //Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Id bizFilingMaintRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Maintenance').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingMaintRecordType, acc.Id, wo.Id, 'Change of Agent', 'In-Progress');
		Agent__c agents = new Agent__c();
        agents.Name__c = 'agents';
        agents.Type__c = 'Business';
        agents.Business_Name__c = 'Pizza';
        agents.Business_Street_Address_1__c = 'Test';
        agents.Business_City__c = 'New York';
        agents.Business_Country__c = 'United States';
        //agents.Business_State__c = 'California';
        agents.Business_Zip_Code__c = '76800';
        agents.Business_State__c = 'CT';
        agents.Business_ID__c = acc.id;
        insert agents;
        //Principal__c principal1 = BRS_TestDataFactory.createPrincipal();
        List<Temp_History__c> lstTH = new List<Temp_History__c>();
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = filing.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc.id;
        tmpHistory1.Agent__c = agents.id;
        tmpHistory1.Change_Type__c = 'Edited';
        lstTH.add(tmpHistory1);
        insert lstTH;
        Test.startTest();
        List<BRS_Utility.maintennaceResponce> lstret = BRS_Utility.updateRecordsFromTemp(acc.id, 'Agent', String.valueOf(filing.Id));
        Test.stopTest();
    }*/
    
    @IsTest
    static void getDataForReportFiling() {
        //List<BRS_Review_Page_Configuration__mdt> ls = Test.loadData(BRS_Review_Page_Configuration__mdt.sObjectType, 'BRS_Review_Page_Configurations_TestData');
        //BRS_Review_Page_Configuration__mdt mtData1 = new BRS_Review_Page_Configuration__mdt(MasterLabel = 'Loc State of formation',Parent_Field_API_Name__c = 'Citizenship__c');
        //insert mtData1;
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        //Account acc = BRS_TestDataFactory.createAccountObject();
        //Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        String flowName='Business Formation';
        Boolean isOverView=false;
        
        
        try{
            BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
            //BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }
        catch(Exception e){}
        test.stopTest();
    }
    
    
    @IsTest
    static void retDataComparisionObject() {
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        Temp_History__c temphist = BRS_TestDataFactory.createTempHistoryObject();
        temphist.Business_Filing__c=currentBf.id;
        temphist.Account__c=acc.Id;
        temphist.Type__c='Account';
        temphist.Change_Type__c='Created';
        update temphist;
        String type = temphist.Type__c;
        String fieldAPIName = 'Account__c';
        Map<Id, sObject> objectToCompare = new Map<Id, sObject>();
        objectToCompare.put(temphist.id,temphist);
        List<Temp_History__c> tempHistoryList = new List<Temp_History__c>();
        tempHistoryList.add(temphist);
        
        Account accSObj = [Select id from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        String flowName='';
        Boolean isOverView=false;
        BRS_Utility.retDataComparisionObject(type,fieldAPIName,objectToCompare,tempHistoryList);
        test.stopTest();
    }
    
    /*@IsTest
    static void getTableDataForReview() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        String type = filing.Type__c;
        List<Business_Filing__c> allOrginalTableData = new List<Business_Filing__c>();
        allOrginalTableData.add(filing);
        Map<String, Map<Id, Business_Filing__c>> originalDataDMLChanged = new Map<String, Map<Id, Business_Filing__c>>();
        test.startTest();
        BRS_Utility.getTableDataForReview(allOrginalTableData,originalDataDMLChanged);
        test.stopTest();
    }*/
    
    @isTest
    static void getAccContactListTest(){
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        con.ClientAccountNum__c = '12345';
        update con;
        Id p = [select id from profile where name='CT Community User'].id;
        //User user = QnA_TestDataFactory.createCommunityUser(con,p);
        User user = [SELECT Id,username,email, ContactId FROM User WHERE ContactId =: con.Id];
        System.runAs(user){
            BRS_Utility.getAccContactList();
            BRS_Utility.getLoggedInUserProfile();
        }
    }   
    
    
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
    static void getCertificateTest(){
        Id bCertRecTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();        
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
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
    
    /*@isTest
    static void typeCastToWrapperTest(){
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        //Principal__c p=BRS_TestDataFactory.createPrincipal();
        Principal__c p= [SELECT Id,Residence_Address__c,Mailing_Address__c,Business_Address_1__c,Email__c,Name__c,Principal_Title__c,Principal_Type__c,FirstName__c,LastName__c,Residence_InternationalAddress__c,Residence_Country__c FROM Principal__c LIMIT 1];
        //Agent__c a=BRS_TestDataFactory.createAgent(acc.Id);
        Agent__c a = [SELECT Id, Agent_Phone__c, Type__c, FirstName__c, LastName__c, Name__c, Email__c, Business_City__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Zip_Code__c, Business_State__c, Business_Country__c, Residence_City__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Zip_Code__c, Residence_State__c, Residence_Country__c, Mailing_City__c, Mailing_Street_Address_1__c, Mailing_Street_Address_2__c, Mailing_Zip_Code__c, Mailing_State__c, Mailing_Country__c, Agent_Account_ID__c FROM Agent__c  LIMIT 1];
        Temp_History__c th=BRS_TestDataFactory.createTempHistoryObject();
        BRS_Utility.typeCastToWrapper(new List<Principal__c>{p}, new List<Agent__c>{a},new List<Temp_History__c>{th});
    }*/
    
    @IsTest
    static void getAllcerts() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        acc.Business_Type__c='Limited Partnership';
        update acc;
        Master_Fee__c masterfee = new Master_Fee__c();
        masterfee.Business_Type__c=acc.Business_Type__c;
        masterfee.Filing_Type__c=system.label.brs_CertficateTypeStandard;
        masterfee.Amount__c=10; 
        masterfee.Status__c='Active';
        masterfee.External_ID__c='MF-0000999999';
        insert masterfee;
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(acc);
        test.startTest();
        BRS_Utility.getAllcerts(acc.Id);
        test.stopTest();
    }
    
    @IsTest
    static void getQueryConfig() {
        BRS_online_enquiry__mdt brsmdt = new BRS_online_enquiry__mdt(DeveloperName='Test');
        test.startTest();
        BRS_Utility.getQueryConfig(brsmdt.DeveloperName);
        test.stopTest();
    }
    
    @IsTest
    static void udtEffectiveDateTimeTest() {
        //List<BRS_Review_Page_Configuration__mdt> ls = Test.loadData(BRS_Review_Page_Configuration__mdt.sObjectType, 'BRS_Review_Page_Configurations_TestData');
        //BRS_Review_Page_Configuration__mdt mtData1 = new BRS_Review_Page_Configuration__mdt(MasterLabel = 'Loc State of formation',Parent_Field_API_Name__c = 'Citizenship__c');
        //insert mtData1;
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
         Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        String flowName='Business Formation';
        Boolean isOverView=false;  
        try{
            BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }
        catch(Exception e){}
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateBusinessClosingEffectiveDate () {
        OnOff_Filing_Auto_Refund__c onOffSwitch = new OnOff_Filing_Auto_Refund__c();
        onOffSwitch.Name = 'On Off Switch';
        onOffSwitch.Auto_Refund_Business_Filing__c = true;
        insert onOffSwitch;
        
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, 'Annual Report', 'In-Progress');
        
        Test.startTest();
        Date effectiveDate = System.today();
        String effectiveTime = '';
        try{
            Boolean hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id, effectiveDate, effectiveTime);
            
            hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id, null, effectiveTime);
            
            hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id, effectiveDate, null);
            
            effectiveTime = '05:30 PM';
            hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id, effectiveDate, effectiveTime);
            
            hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id, null, effectiveTime);
            
            hasUpdate = BRS_Utility.updateBusinessClosingEffectiveDate(null, null, null);
        }
        catch(Exception e){}
        Test.stopTest();
    }
    
    
    @IsTest
    static void updateBusinessFilingChecklist() {
        try{
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        filing.Checklist_Status__c='Completed';
        test.startTest();
        BRS_Utility.updateBusinessFilingChecklist(filing.Checklist_Status__c, filing.RecordTypeId);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    
    /*@isTest
    public static void testCloneBusinessFilingWithRelatedRecords() {
        OnOff_Filing_Auto_Refund__c onOffSwitch = new OnOff_Filing_Auto_Refund__c();
        onOffSwitch.Name = 'On Off Switch';
        onOffSwitch.Auto_Refund_Business_Filing__c = true;
        insert onOffSwitch;
        
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        
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
            //BRS_Utility.cloneBusinessFilingWithRelatedRecords('287r98w7');
        }
        catch(Exception e) {}
        Test.stopTest();
    }*/
    
    @isTest
    public static void testLinkBusinessToContact1() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        //User u = BRS_TestDataFactory.createCommunityUser(con, p.Id);
        User u = [SELECT Id,username,email, ContactId FROM User WHERE ContactId =: con.Id];

        Test.startTest();
        try{
            BRS_Utility.linkBusinessToContact(acc.Id, u.Id);
            BRS_Utility.getAppLabels();
        }
        catch(Exception e) {}
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGetUserDetails() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = [SELECT Id,username,email, ContactId FROM User WHERE ContactId =: con.Id];

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
    
    @IsTest
    static void updateSectionNameinFiling(){
        try{
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        filing.Current_Screen__c = 'GoToReview';
        filing.Current_Section__c = 'Test';
        update filing;
        Business_Filing__c filingRec = [SELECT Id, Current_Screen__c, Current_Section__c FROM Business_Filing__c WHERE Id=:filing.Id LIMIT 1];
        BRS_Utility.updateSectionNameinFiling(filingRec.Id, filingRec.Current_Screen__c, filingRec.Current_Section__c);
        BRS_Utility.updateSectionNameinFiling(null, filingRec.Current_Screen__c, filingRec.Current_Section__c);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    
    testmethod static void getChecklistDataTest(){
        UCC_Filing__c uccfiling = [select Id, Type__c,UCC_Lien_Type__c,Filing_Source__c from UCC_Filing__c limit 1];
        Business_Filing__c busFiling = [select Id,Type__c,Source__c from Business_Filing__c limit 1];
        
        Test.startTest();
        BRS_Utility.getChecklistData(uccfiling.Id);
        BRS_Utility.getChecklistData(busFiling.Id);
        Test.stopTest();
    }

	testmethod static void updateUccFilingTest(){

        UCC_Filing__c uccfiling = [select Id, Type__c,UCC_Lien_Type__c,Filing_Source__c,Owner_name_present__c,Owner_address_present__c,Claimant_name_present__c,Claimant_address_present__c,
        Aircraft_Vessel_name_present__c,Form_legible__c,Referenced_documents_attached__c,Meets_other_requirements__c,Debtor_name_present__c,
        Debtor_address_present__c,Indicates_debtor_is_indiviudal_organizat__c,Secured_party_name_present__c,Secured_party_address_present__c,Description_of_vessel__c,
        Statement_of_assumed_ownership__c,Judgment_debtor_present__c,Judgment_creditor_present__c,Defendant_name_present__c,Plaintiff_name_present__c,
        Is_court_order_present__c,Is_court_order_signed__c from UCC_Filing__c limit 1];

        List<wrapperChecklist> wrapperList = new List<wrapperChecklist>();
        wrapperChecklist wrapChecklist1 = new wrapperChecklist();
        wrapChecklist1.name='Owner name present?';
        wrapChecklist1.isChecked='Yes';
        wrapperList.add(wrapChecklist1);

        wrapperChecklist wrapChecklist2 = new wrapperChecklist();
        wrapChecklist2.name='Owner address present?';
        wrapChecklist2.isChecked='Yes';
        wrapperList.add(wrapChecklist2);
        wrapperChecklist wrapChecklist3 = new wrapperChecklist();
        wrapChecklist3.name='Claimant name present?';
        wrapChecklist3.isChecked='Yes';
        wrapperList.add(wrapChecklist3);
        wrapperChecklist wrapChecklist4 = new wrapperChecklist();
        wrapChecklist4.name='Claimant address present?';
        wrapChecklist4.isChecked='Yes';
        wrapperList.add(wrapChecklist4);
        wrapperChecklist wrapChecklist5 = new wrapperChecklist();
        wrapChecklist5.name='Aircraft/Vessel name present?';
        wrapChecklist5.isChecked='Yes';
        wrapperList.add(wrapChecklist5);
        wrapperChecklist wrapChecklist6 = new wrapperChecklist();
        wrapChecklist6.name='Form legible?';
        wrapChecklist6.isChecked='Yes';
        wrapperList.add(wrapChecklist6);
        wrapperChecklist wrapChecklist7 = new wrapperChecklist();
        wrapChecklist7.name='Referenced documents attached?';
        wrapChecklist7.isChecked='Yes';
        wrapperList.add(wrapChecklist7);
        wrapperChecklist wrapChecklist8 = new wrapperChecklist();
        wrapChecklist8.name='Meets other requirements?';
        wrapChecklist8.isChecked='Yes';
        wrapperList.add(wrapChecklist8);
        wrapperChecklist wrapChecklist9 = new wrapperChecklist();
        wrapChecklist9.name='Debtor name present?';
        wrapChecklist9.isChecked='Yes';
        wrapperList.add(wrapChecklist9);
        wrapperChecklist wrapChecklist10 = new wrapperChecklist();
        wrapChecklist10.name='Debtor address present?';
        wrapChecklist10.isChecked='Yes';
        wrapperList.add(wrapChecklist10);
        wrapperChecklist wrapChecklist11 = new wrapperChecklist();
        wrapChecklist11.name='Indicates debtor is indiviudal/organization?';
        wrapChecklist11.isChecked='Yes';
        wrapperList.add(wrapChecklist11);
        wrapperChecklist wrapChecklist12 = new wrapperChecklist();
        wrapChecklist12.name='Secured party name present?';
        wrapChecklist12.isChecked='Yes';
        wrapperList.add(wrapChecklist12);
        wrapperChecklist wrapChecklist13 = new wrapperChecklist();
        wrapChecklist13.name='Secured party address present?';
        wrapChecklist13.isChecked='Yes';
        wrapperList.add(wrapChecklist13);
        wrapperChecklist wrapChecklist14 = new wrapperChecklist();
        wrapChecklist14.name='Description of vessel?';
        wrapChecklist14.isChecked='Yes';
        wrapperList.add(wrapChecklist14);
        wrapperChecklist wrapChecklist15 = new wrapperChecklist();
        wrapChecklist15.name='Statement of assumed ownership?';
        wrapChecklist15.isChecked='Yes';
        wrapperList.add(wrapChecklist15);
        wrapperChecklist wrapChecklist16 = new wrapperChecklist();
        wrapChecklist16.name='Judgment debtor present?';
        wrapChecklist16.isChecked='Yes';
        wrapperList.add(wrapChecklist16);
        wrapperChecklist wrapChecklist17 = new wrapperChecklist();
        wrapChecklist17.name='Judgment creditor present?';
        wrapChecklist17.isChecked='Yes';
        wrapperList.add(wrapChecklist17);
        wrapperChecklist wrapChecklist18 = new wrapperChecklist();
        wrapChecklist18.name='Defendant name present?';
        wrapChecklist18.isChecked='Yes';
        wrapperList.add(wrapChecklist18);
        wrapperChecklist wrapChecklist19 = new wrapperChecklist();
        wrapChecklist19.name='Plaintiff name present?';
        wrapChecklist19.isChecked='Yes';
        wrapperList.add(wrapChecklist19);

        wrapperChecklist wrapChecklist20 = new wrapperChecklist();
        wrapChecklist20.name='Is court order present?';
        wrapChecklist20.isChecked='Yes';
        wrapperList.add(wrapChecklist20);
        wrapperChecklist wrapChecklist21 = new wrapperChecklist();
        wrapChecklist21.name='Is court order signed?';
        wrapChecklist21.isChecked='Yes';
        wrapperList.add(wrapChecklist21);

        String info = JSON.serialize(wrapperList);
        Test.startTest();
        BRS_Utility.updateUccFiling(info,uccfiling.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void wrapperTableDataPrincipal() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Principal__c pri = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        pri.Principal_Account_ID__c=acc.id;
        pri.Email__c='abc@xyz.com';
        pri.Principal_Type__c='Business';
        pri.Business_Name__c='Test Business';
        insert pri;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(pri);
    }
    
    @IsTest
    static void wrapperTableDataAgent() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Agent__c agent1 = BRS_TestDataFactory.createAgent(acc.Id);
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(agent1);
    }
    
    @IsTest
    static void wrapperTableDataTempHistory() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        temp.Type__c='Principal';
        temp.Temp_Type__c='Business';
        temp.Account__c=acc.Id;
        update temp;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(temp);
    }
    
    @IsTest
    static void wrapperTableDataTempHistory1() {
        Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        temp.Type__c='Agent';
        temp.Temp_Type__c='Business';
        update temp;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(temp);
    }
    
    @IsTest
    static void getOrgWideEmailAddr() {
        try{
        String emailAddr = 'abc@xyz.com';
        test.startTest();
        BRS_Utility.getOrgWideEmailAddr(emailAddr);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    
    @isTest 
    static void testAdditionalMethod() {
        Test.startTest();
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        
        set<id> acclist = new set<id>();
        acclist.add(acc.id);
        string accid = acc.id;
        Business_Filing__c bfc = new Business_Filing__c(Type__c = 'Business Registration', Account__c = acc.Id, recordtypeid = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId());
        insert bfc;
        
        /*UCC_Lien__c lien=new UCC_Lien__c();
        lien=BRS_TestDataFactory.createUCCLien('OFS');
        UCC_Filing__c filing=new UCC_Filing__c();
        filing=BRS_TestDataFactory.createUCCFiling('As a transmitting utility', 'In-Progress', lien.id,'Amendment');
        
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=acc.id;
        insert attach;
        list<Attachment> attachlist = new list<Attachment>();
        attachlist.add(attach);*/
        
        list<id> useridlist= new list<id>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CT Community User' LIMIT 1];
        /*user usr = new user();
        usr = BRS_TestDataFactory.createCommunityUser(con, profileId.Id);
        useridlist.add(usr.id);*/
        Work_Order__c task=new Work_Order__c();
        task=BRS_TestDataFactory.createWorkOrderObject(con.id, 'Mail', 'completed');

        try{
            BRS_Utility.createCertificateRecords(acc.id, 'test cert type', task.id );
            Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest 
    static void testexceptionMethod() {
        Test.startTest();
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Business_Filing__c bfc = new Business_Filing__c();
        
        Attachment attach = [SELECT Id, Name, body, parentId from Attachment WHERE Name = 'Unit Test Attachment' LIMIT 1];
        
        try{
            BRS_Utility.updateFilingAckValues(bfc);
            //BRS_Utility.updateSectionNameinFiling(bfc.Id,'string section Name','string section'); 
            Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest
    public static void testGetPrincipalId() {
        Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        
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
    public static void testgetFieldSetMember() {

        Test.startTest();
        try {
            BRS_Utility.getFieldSetMember('Account','Virtual Terminal');
            BRS_Utility.getCities();
        }
        catch(Exception e){}
        Test.stopTest();
    }
    
    @IsTest
	static void getChangesFromTempHistoryTest() {
			Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
			Contact con = [Select id,FirstName,LastName from Contact limit 1];
			Principal__c pri = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
			Map<Id, Principal__c> principalMap = new Map<Id, Principal__c>();
			principalMap.put(pri.Id,pri);
        
			Agent__c agent1 = BRS_TestDataFactory.createAgent(acc.Id);
        	Map<Id, Agent__c> agent1Map = new Map<Id, Agent__c>();
        	agent1Map.put(agent1.Id, agent1);
        
			Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        	List<Temp_History__c> tempList = new List<Temp_History__c>();
        	tempList.add(temp);
        
        	Test.startTest();
        	BRS_Utility.getChangesFromTempHistory(acc, principalMap, agent1Map, tempList);
		 	Test.stopTest();
     }
    
    
     @isTest
     static void updateSignatoryDetailsTest() {
         	Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
			Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
			Contact con = [Select id,FirstName,LastName from Contact limit 1];
			Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
			Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
			filing.Checklist_Status__c='Completed';
			
			test.startTest();
			BRS_Utility.updateSignatoryDetails('Test111','Manager','Business',filing.id);
			test.stopTest();
     }
    
    testMethod static void getReviewMetadataTest() {

		Account acc0 = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
		Contact con0 = [Select id,FirstName,LastName from Contact limit 1];
		
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        test.startTest();
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=System.today().addYears(-1),Type__c='Judgment - Personal Property'));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData3',UCC_Lien_Number__c='TestData3',Type__c='Aircraft'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData4',UCC_Lien_Number__c='TestData4',Type__c='Vessel'));
       insert uccLien; 
       
        
        List<UCC_Filing__c> uccFilingRec = new List<UCC_Filing__c>();
        uccFilingRec = [select Id, Name__c, Type__c, UCC_Lien_Number__c, Description__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Alternative_Designations__c, Collateral_Type__c, Collateral_Information__c, Lien_Filing_Type__c, Original_Judgement_Amount__c,
                        Date_of_Judgement__c, Amount_Due__c, Reason_for_Dispute__c, Dispute_Justification__c, Claim_Amount__c, Filer_Reference_Data__c, Type_of_Collateral_Update__c 
                        from UCC_Filing__c limit 1];//where UCC_Lien_Id__c = :uccLien[0].Id limit 1];
        
        
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        List<UCC_Filing__c> insertUFList = new List<UCC_Filing__c>();
        
        UCC_Filing__c uccFileOnline = new UCC_Filing__c();
        uccFileOnline.Type__c = 'Amendments';
        uccFileOnline.UCC_Lien_Type__c = 'OFS';
        uccFileOnline.UCC_Lien_Id__c = uccLien[1].id;
        uccFileOnline.Filing_Source__c = 'Online';
        uccFileOnline.Filing_Number__c='TestClsD16';
        uccFileOnline.PacketNum__c='1234Test';
        uccFileOnline.Status__c = 'Completed';
        uccFileOnline.Amendment_Type__c = 'Amendment';
        
        testFiling.add(uccFileOnline);
       // testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Filing_Number__c='TestClsD1',PacketNum__c='1234Test',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[0].id, Amendment_Type__c = 'Amendment'));
//        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Filing_Number__c='TestD2',PacketNum__c='5678',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[1].id));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[2].id, Amendment_Type__c = 'Amendment'));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Vessel',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[3].id));
          // insert testFiling; 
        testFiling.addAll(uccFilingRec);
        List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        for (Integer index = 0 ; index < 10 ; index++) {
            UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
            objRelatedInfo.City__c = 'City';   
            objRelatedInfo.Country__c = 'country';
            objRelatedInfo.Individual_First_Name__c = 'FirstName';
            objRelatedInfo.isAuthorizer__c = true;
            //Added as Part of BRS-2491
            objRelatedInfo.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Individual_Label, Schema.UCC_Related_Info__c.getSObjectType());
            //objRelatedInfo.Individual_Organization_flg__c = 'orgFlag';
            //objRelatedInfo.Org_Name__c = 'Orgname';
            objRelatedInfo.Type__c = 'Secured Party';
			objRelatedInfo.State__c = 'state';
            objRelatedInfo.Individual_SurName__c = 'surname'; 
            objRelatedInfo.Street__c = 'Street';
            objRelatedInfo.Zip_Code__c = '11111';
            objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
            objRelatedInfo.Suffix__c = 'Suffix';   
            objRelatedInfo.Filing_Id__c = testFiling[0].id;
            lstRelatedInfo.add(objRelatedInfo);
        }
        lstRelatedInfo[1].Type__c = System.Label.Review_MasterLabel_Type_Debtor;
        lstRelatedInfo[2].Type__c = System.Label.Review_MasterLabel_Type_Assignor;
        lstRelatedInfo[3].Type__c = System.Label.Review_MasterLabel_Type_Owner;
        lstRelatedInfo[4].Type__c = System.Label.Review_MasterLabel_Type_Claimant;
        lstRelatedInfo[5].Type__c = System.Label.Review_MasterLabel_Type_JudgementDebtor;
        lstRelatedInfo[6].Type__c = System.Label.Review_MasterLabel_Type_Submitter;
        lstRelatedInfo[7].Type__c = System.Label.Review_MasterLabel_Type_JudgementCreditor;
        insert lstRelatedInfo;
        List<UCC_Entity_Info__c> lstUccEntityInfo = new List<UCC_Entity_Info__c>();
        
        UCC_Entity_Info__c objEntityInfo = new UCC_Entity_Info__c();
        objEntityInfo.Assignor_ID__c = lstRelatedInfo[0].id;
        objEntityInfo.Filing_ID__c = testFiling[0].id;
        objEntityInfo.Secured_Party_ID__c = lstRelatedInfo[0].id;
        lstUccEntityInfo.add(objEntityInfo);   
        
        UCC_Entity_Info__c objEntityInfo1 = new UCC_Entity_Info__c();
        objEntityInfo1.Assignor_ID__c = lstRelatedInfo[1].id;
        objEntityInfo1.Filing_ID__c = testFiling[0].id;
        objEntityInfo1.Secured_Party_ID__c = lstRelatedInfo[0].id;
        lstUccEntityInfo.add(objEntityInfo1);   
        
        
        UCC_Entity_Info__c objEntityInfo2 = new UCC_Entity_Info__c();
        objEntityInfo2.Assignor_ID__c = lstRelatedInfo[1].id;
        objEntityInfo2.Filing_ID__c = testFiling[0].id ;
        objEntityInfo2.Secured_Party_ID__c = lstRelatedInfo[1].id ;
        lstUccEntityInfo.add(objEntityInfo2); 
        insert lstUccEntityInfo; 
        
        Work_Order__c mainWorkorder = new Work_Order__c();
        mainWorkorder.Status__c = 'In-Progress';
        mainWorkorder.Type__c = 'UCC';
        mainWorkorder.Source__c = 'Mail';
        mainWorkorder.Customer__c = con0.Id;
        mainWorkorder.Received_Date__c = System.today();
        insert mainWorkorder;
        //insertWOList.add(mainWorkorder);
        
        Work_Order__c otherReqWO = new Work_Order__c();
        otherReqWO.Status__c = 'In-Progress';
        otherReqWO.Type__c = 'Other Requests';
        otherReqWO.Source__c = 'Mail';
        otherReqWO.Customer__c = con0.Id;
        otherReqWO.Received_Date__c = System.today();
        insert otherReqWO;
        //insertWOList.add(otherReqWO);
        //insert otherReqWO;
        
        List<Certficate__c> insertCertList = new List<Certficate__c>();
        Certficate__c mainCert = new Certficate__c();
        mainCert.Business__c = acc0.Id;
        mainCert.Certificate_Type__c = 'Express';
        mainCert.Type__c='Certificate of Legal Existence';
        mainCert.Work_Order__c = mainWorkorder.Id;
        insertCertList.add(mainCert);
        //Insert mainCert;
        
        Certficate__c certInst = new Certficate__c();
        certInst.Business__c = acc0.Id;
        certInst.Certificate_Type__c = 'Express';
        certInst.Type__c='Certificate of Legal Existence';
        certInst.Filing_Fee__c = 80;
        certInst.Work_Order__c = otherReqWO.Id;
        //insertCertList.add(certInst);
        Insert insertCertList;
        
        
        

        BRS_Utility.getReviewMetadata('Obtain Certificate Flow', insertCertList[0] ,testFiling[0].id); //uncommented
        
        Test.stopTest();
        
    }
    
    
    testMethod static void getFieldValidationTest() {
	
		Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
        Contact con = [Select id,FirstName,LastName from Contact limit 1];
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');

        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        List<String> addrFields = new List<String>();
		addrFields.add('Mailing_Address__c');
        addrFields.add('Mailing_International_Address__c');
		
		test.startTest();
        BRS_Utility.getFieldValidation(filing, addrFields, true, true);
		BRS_Utility.getFieldValidation(filing, addrFields, true, false);
		BRS_Utility.getFieldValidation(filing, addrFields, false, true);
		BRS_Utility.getFieldValidation(filing, addrFields, false, false);
        test.stopTest();
	}
    
    
    testMethod static void arePrincipalsInfoValidTest1() {
			test.startTest();
			Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
			Contact con = [Select id,FirstName,LastName from Contact limit 1];
			Principal__c pri = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        	Principal__c pri2 = BRS_TestDataFactory.createPrincipal();//(acc.Id);
         	pri2.FirstName__c = 'testName';
        	pri2.Business_ID__c = acc.id;
        	pri2.Designation__c='Director';
        	update pri2;
        
        	Principal__c pri3 = BRS_TestDataFactory.createPrincipalRecords(acc.id);//(acc.Id);
         	pri3.FirstName__c = 'testName22';
        	//pri3.Business_ID__c = acc.id;
        	pri3.Principal_Type__c='Business';
        	pri3.Business_Name__c = 'BusName';
        	pri3.Designation__c='Director';
        	pri3.Principal_Title__c='titleValue221';
        	insert pri3;
        
        	//insert pri2;
			Map<Id, Principal__c> principalMap = new Map<Id, Principal__c>();
			principalMap.put(pri.Id,pri);
			
			List<Principal__c> allData = new List<Principal__c>();
			allData.add(pri);
			
        	List<Principal__c> allDataBusiness = new List<Principal__c>();
        	allDataBusiness.add(pri3);
			Set<Id> allDataIds = new Set<Id>();
			allDataIds.add(pri2.Id);
			
        List<Temp_History__c> tempList = new List<Temp_History__c>();
			Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        	temp.Temp_Type__c ='Individual';
        	temp.Residence_InternationalAddress__c ='test residence';        	        	
        	tempList.add(temp);
        	update tempList;
         List<Temp_History__c> tempList1 = new List<Temp_History__c>();
        	Temp_History__c temp1 = BRS_TestDataFactory.createTempHistoryObject();
        	temp1.Temp_Type__c ='Business';
        	temp1.Residence_InternationalAddress__c ='test residence232';
        	tempList1.add(temp1);
        update tempList1;
        
		
		
        BRS_Utility.arePrincipalsInfoValid(allData, allDataIds, tempList, true);
        BRS_Utility.arePrincipalsInfoValid(allDataBusiness, allDataIds, tempList1, true);
        BRS_Utility.getFieldValidation(pri3,new List<String>{'Designation__c','Principal_Title__c'},true,true);
        test.stopTest();
	}
    
    
    testMethod static void updateSignatoryOnUCCFlingTest() {
	
			Account acc = [Select id,Business_Type__c,Citizenship__c,Description from Account limit 1];
			Contact con = [Select id,FirstName,LastName from Contact limit 1];
			UCC_Filing__c uccfiling = [select Id, UCC_Lien_Id__c, Type__c,UCC_Lien_Type__c,Filing_Source__c,Owner_name_present__c,Owner_address_present__c,Claimant_name_present__c,Claimant_address_present__c,
        Aircraft_Vessel_name_present__c,Form_legible__c,Referenced_documents_attached__c,Meets_other_requirements__c,Debtor_name_present__c,
        Debtor_address_present__c,Indicates_debtor_is_indiviudal_organizat__c,Secured_party_name_present__c,Secured_party_address_present__c,Description_of_vessel__c,
        Statement_of_assumed_ownership__c,Judgment_debtor_present__c,Judgment_creditor_present__c,Defendant_name_present__c,Plaintiff_name_present__c,
        Is_court_order_present__c,Is_court_order_signed__c from UCC_Filing__c limit 1];
		
		test.startTest();
        BRS_Utility.updateSignatoryOnUCCFling(uccfiling.UCC_Lien_Id__c,true,'TestSignatory');
        //BRS_Utility.getDownloadFileCommunityUser(acc.Id);
        test.stopTest();
	}
    
}