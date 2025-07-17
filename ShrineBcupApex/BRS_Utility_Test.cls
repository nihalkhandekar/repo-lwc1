@isTest
public class BRS_Utility_Test {
    /*@testSetup
static void testSetUp() {
Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
Account acc = BRS_TestDataFactory.createAccountObject();
Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);

}*/
    
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
        try{
            BRS_Utility.updateSObjectFromFlow(sObjectFieldMap,fieldAndValueMap,fieldAndTypeMap,acc.id);
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest 
    static void updateSObjectFromFlowTest_1() {
        Account acc = new Account(name = 'Test'/*,Annual_Report_Filing_Fee__c = 2400*/,Annual_Report_Due_Date__c = Date.newInstance(2016, 12, 9),Filing_DateTime__c = datetime.newInstance(2014, 9, 15, 12, 30, 0) );
        insert acc;
        List<String> Accountlist = new List<String>();
        Accountlist.add('Filing_Time');
        Accountlist.add('Name');
        Accountlist.add('Annual_Report_Filing_Fee__c');
        Accountlist.add('Annual_Report_Due_Date__c');
        Accountlist.add('Filing_DateTime__c');
        
        Map<String,List<String>> sObjectFieldMap  = new Map<String,List<String>>();
        Map<String,String> fieldAndValueMap = new Map<String,String>();
        Map<String,String> fieldAndTypeMap = new Map<String,String>();
        sObjectFieldMap.put('ACCOUNT',Accountlist);
        
        for(Account accountval:[select id,name/*,Annual_Report_Filing_Fee__c*/,Annual_Report_Due_Date__c,Filing_DateTime__c from account where id = :acc.id]) {
            
            fieldAndValueMap.put('Name',accountval.name);
            //fieldAndValueMap.put('Annual_Report_Filing_Fee__c',string.valueOf(accountval.Annual_Report_Filing_Fee__c));
            fieldAndValueMap.put('Annual_Report_Due_Date__c',string.valueOf(accountval.Annual_Report_Due_Date__c));
            fieldAndValueMap.put('Filing_DateTime__c',string.valueOf(accountval.Filing_DateTime__c.format('yyyy-mm-dd')));
            fieldAndValueMap.put('Filing_Time',string.valueOf(accountval.Filing_DateTime__c.format('HH:MM:SS:MS')));
        }
        //fieldAndTypeMap.put('Annual_Report_Filing_Fee__c','Number');
        fieldAndTypeMap.put('Annual_Report_Due_Date__c','Date');
        fieldAndTypeMap.put('Filing_DateTime__c','DateTime');
        fieldAndTypeMap.put('Filing_Time','Time');
        Test.startTest();
        try{
            BRS_Utility.updateSObjectFromFlow(sObjectFieldMap,fieldAndValueMap,fieldAndTypeMap,acc.id);
        }catch(Exception e){}
        Test.stopTest();
    }
    
    //Get Account Test 
    @isTest 
    static void getAccountTest() {
        Account acct = new Account(Name = 'TEST_ACCT');
        Test.startTest();
        try {
            BRS_Utility.getAccount(acct.Id);
            BRS_Utility.getAccount(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception',e.getMessage());
            try {
                BRS_Utility.getAccount('null');
            } catch (Exception ex) {
                System.assertEquals('Invalid id: null',ex.getMessage());
            }
        }
        insert acct;
        BRS_Utility.getAccount(acct.Id);
        Test.stopTest();
    }
    // Update Account Test
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
    testmethod static void getAddressTest() {
        Account acct = new Account(Name='TEST_ACCOUNT',Business_Email_Address__c = 'alex@gmail.com');
        Test.startTest();
        BRS_Utility.getAddress(acct,new List<String>{'Name','Business_Email_Address__c'});
        Test.stopTest();
    }
    
    // Update Agent On Account
    
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
    testmethod static void getOptionsDataTest() {
        Test.startTest();
        /*List<BRS_Special_Business_Group_Option__mdt> BRSSpecial = BRS_Utility.getOptionsData();*/
        Test.stopTest();
    }
    testmethod static void getLapsedDiffMonthsTest() {
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
    }
    testmethod static void getCountriesTest() {
        Test.startTest();
        System.assertNotEquals(null,BRS_Utility.getCountries());
        Test.stopTest();
    }
    testmethod static void fetchAPIInterfaceConfigTest() {
        Test.startTest();
        BRS_Utility.fetchAPIInterfaceConfig(System.Label.Review_MasterLabel_Type_Debtor);
        Test.stopTest();
    }
    testMethod static void getReviewMetadataTest() {
        Account acc0 = new Account(Name = 'Test');
        Insert acc0;
        Contact con2 = BRS_TestDataFactory.createContactObject(acc0.Id);
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        acc.Began_Transacting_in_CT__c=system.today();
        acc.Business_End_Date__c = system.today().addDays(10);
        update acc;
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=System.today().addYears(-1),Type__c='Judgment - Personal Property'));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData3',UCC_Lien_Number__c='TestData3',Type__c='Aircraft'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData4',UCC_Lien_Number__c='TestData4',Type__c='Vessel'));
        insert uccLien;
        List<UCC_Filing__c> uccFilingRec = new List<UCC_Filing__c>();
        uccFilingRec = [select Id, Name__c, Type__c, UCC_Lien_Number__c, Description__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Alternative_Designations__c, Collateral_Type__c, Collateral_Information__c, Lien_Filing_Type__c, Original_Judgement_Amount__c,
                        Date_of_Judgement__c, Amount_Due__c, Reason_for_Dispute__c, Dispute_Justification__c, Claim_Amount__c, Filer_Reference_Data__c, Type_of_Collateral_Update__c 
                        from UCC_Filing__c where UCC_Lien_Id__c = :uccLien[0].Id limit 1];
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[0].id, Amendment_Type__c = 'Amendment'));
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[1].id));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[2].id, Amendment_Type__c = 'Amendment'));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Vessel',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[3].id));
        insert testFiling; 
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
        mainWorkorder.Customer__c = con2.Id;
        mainWorkorder.Received_Date__c = System.today();
        insert mainWorkorder;
        //insertWOList.add(mainWorkorder);
        
        Work_Order__c otherReqWO = new Work_Order__c();
        otherReqWO.Status__c = 'In-Progress';
        otherReqWO.Type__c = 'Other Requests';
        otherReqWO.Source__c = 'Mail';
        otherReqWO.Customer__c = con2.Id;
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
        
        
        
        Test.startTest();
        String flowname = 'Business Formation';
        BRS_Utility.getReviewMetadata(flowname,acc, testFiling[0].id);
        BRS_Utility.getReviewMetadata(flowname,acc, null);
        BRS_Utility.getReviewMetadata('UCC-3 Lien',testFiling[0],null);
        BRS_Utility.getReviewMetadata('UCC 5 Lien',testFiling[0],null);
        BRS_Utility.getReviewMetadata('UCC Lien', uccLien[0] ,null);

        BRS_Utility.getReviewMetadata('Obtain Certificate Flow', insertCertList[0] ,testFiling[0].id); //uncommented
        

        BRS_Utility.getOptionsData();
        BRS_Utility.getLegalDesignators();
        BRS_Utility.getNoiseWords();
        //BRS_Utility.getFieldSetMember('Account','Name');
        BRS_Utility.getCities();
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc1.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc1.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Business Registration';
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        insert businessFiling;
        
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
        Principal__c principal1 = BRS_TestDataFactory.createPrincipal();
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = businessFiling.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc1.id;
        tmpHistory1.Agent__c = agents.id;
        insert tmpHistory1;
        tmpHistory1.Type__c=System.label.Label_Principal;
        tmpHistory1.Principal__c=principal1.Id;
        update tmpHistory1;
        BRS_Utility.upsertTempRecord(tmpHistory1);
        
        
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
        objRelatedInfo.City__c = 'City';   
        objRelatedInfo.Country__c = 'country';
        //objRelatedInfo.Individual_First_Name__c = 'FirstName';
        objRelatedInfo.isAuthorizer__c = true;
        objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
        objRelatedInfo.Org_Name__c = 'Orgname';
        objRelatedInfo.Type__c = 'Secured Party';
        //objRelatedInfo.Individual_SurName__c = 'surname'; 
        objRelatedInfo.Street__c = 'Street';
        objRelatedInfo.State__c = 'state';
        objRelatedInfo.Zip_Code__c = '11111';
        //objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
        objRelatedInfo.Suffix__c = 'Suffix';  
        Insert objRelatedInfo;
        
        List<String> strList = new List<String>();
        
        
        BRS_Utility.getReviewMetadata('UCC',acc1,businessFiling.Id);
        //BRS_Utility.getReviewMetadata('UCC-3 Lien',acc1,businessFiling.Id);
        Test.stopTest();
        
    }
    @isTest 
    static void testAdditionalMethod() {
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        set<id> acclist = new set<id>();
        acclist.add(acc.id);
        string accid = acc.id;
        Business_Filing__c bfc = new Business_Filing__c(Type__c = 'Business Registration', Account__c = acc.Id, recordtypeid = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId());
        insert bfc;
        
        UCC_Lien__c lien=new UCC_Lien__c();
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
        attachlist.add(attach);
        
        list<id> useridlist= new list<id>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CT Community User' LIMIT 1];
        user usr = new user();
        usr = BRS_TestDataFactory.createCommunityUser(con, profileId.Id);
        useridlist.add(usr.id);
        Work_Order__c task=new Work_Order__c();
        task=BRS_TestDataFactory.createWorkOrderObject(con.id, 'Mail', 'completed');
        
        //String[] array1 = new String[]{'abcd@xyz'};
        //String[] array2 = new String[]{'efgh@xyz'};
        try{
            Test.startTest();
            BRS_Utility.updateFilingAckValues(bfc);
            //BRS_Utility.getFilingAckValues(bfc.Id);
            BRS_Utility.getDownloadFileCommunityUser(acc.id);
            BRS_Utility.updateSignatoryDetails('test Name','test title','Business Registration',bfc.Id);
            BRS_Utility.updateSectionNameinFiling(bfc.Id,'string section Name','string section');
            BRS_Utility.getAppLabels();
            BRS_Utility.getUsersDetail(useridlist);
            //BRS_Utility.createAccountRelation(acclist);
            //BRS_Utility.sendMailByBody(array1 , array2, 'test mail', 'test body', 'testorgwideEmail',attachlist);
            BRS_Utility.linkBusinessToContact(acc1.id,usr.id);
            BRS_Utility.createCertificateRecords(acc.id, 'test cert type', task.id );
            BRS_Utility.cloneBusinessFilingWithRelatedRecords(bfc.Id);
            BRS_Utility.updateBusinessFilingChecklist('String Info', bfc.id );
            BRS_Utility.updateUccFiling('info', filing.id );
            BRS_Utility.getChecklistData(filing.id);
            BRS_Utility.updateBusinessClosingEffectiveDate(filing.Id,System.today(),'effectiveTime');
            
            BRS_Utility.getAppLabels();
            Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    @isTest 
    static void testexceptionMethod() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Business_Filing__c bfc = new Business_Filing__c();
        
        
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=acc.id;
        insert attach;
        try{
            Test.startTest();
            
            BRS_Utility.updateFilingAckValues(bfc);
            
            
            BRS_Utility.getDownloadFileCommunityUser(acc.id);
            BRS_Utility.updateSignatoryDetails('test Name','test title','Business Registration',bfc.Id);
            BRS_Utility.updateSectionNameinFiling(bfc.Id,'string section Name','string section'); 
            Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
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
    
    @IsTest
    static void getDataForReportFiling() {

        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,Other_Provisions__c,Citizenship__c,Description from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        String flowName='Business Formation';
        Boolean isOverView=false;
        test.startTest();
        
        try{
            BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
            BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }
        catch(Exception e){}
        test.stopTest();
    }
    
    @IsTest
    static void getDataForReportFiling_1() {

        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,BillingState,BillingCity,BillingPostalCode,BillingStreet,Principle_Office_International_Address__c,Other_Provisions__c,ShippingCountry,Mailing_International_Address__c,ShippingState,ShippingPostalCode,ShippingStreet,Shipping_Unit__c,ShippingCity,Citizenship__c,Description from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        String flowName='First_Annual_Report';
        Boolean isOverView=false;
        test.startTest();
        try{
            BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
            //BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }catch(Exception e){}
        test.stopTest();
    }
    
    @IsTest
    static void retDataComparisionObject() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
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
        test.startTest();
        BRS_Utility.retDataComparisionObject(type,fieldAPIName,objectToCompare,tempHistoryList);
        test.stopTest();
    }
    
    @IsTest
    static void getTableDataForReview() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        String type = filing.Type__c;
        List<Business_Filing__c> allOrginalTableData = new List<Business_Filing__c>();
        allOrginalTableData.add(filing);
        Map<String, Map<Id, Business_Filing__c>> originalDataDMLChanged = new Map<String, Map<Id, Business_Filing__c>>();
        test.startTest();
        //BRS_Utility.getTableDataForReview(type,allOrginalTableData,originalDataDMLChanged);
        test.stopTest();
    }
    
    @IsTest
    static void processBusinessMaintenance() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        BRS_Utility.Requests req = new BRS_Utility.Requests();
        req.rejectedFilingId=filing.Id;
        List<BRS_Utility.Requests> Requests = new List<BRS_Utility.Requests>();
        Requests.add(req);
        test.startTest();
        BRS_Utility.processBusinessMaintenance(Requests);
        test.stopTest();
    }
    
    @IsTest
    static void processBusinessMaintenance1() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        BRS_Utility.Requests req = new BRS_Utility.Requests();
        req.businessName='Test Business';
        List<BRS_Utility.Requests> Requests = new List<BRS_Utility.Requests>();
        Requests.add(req);
        test.startTest();
        BRS_Utility.processBusinessMaintenance(Requests);
        test.stopTest();
    }
    
    @IsTest
    static void processBusinessMaintenance2() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        BRS_Utility.Requests req = new BRS_Utility.Requests();
        List<BRS_Utility.Requests> Requests = new List<BRS_Utility.Requests>();
        Requests.add(req);
        test.startTest();
        BRS_Utility.processBusinessMaintenance(Requests);
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateBusinessClosingEffectiveDate () {
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
    
    
    @isTest
    public static void testCreateAccountRelation1() {
        Account testAcc1 = new Account(Name = 'TestClassAcct1 LLC Co.', Citizenship__c = 'Domestic', Business_Type__c = 'Religious', Status__c='Active');
        insert testAcc1; 
        
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Set<Id> lstAccIds1 = new Set<Id>{acc.Id};
            Set<Id> lstAccIds2 = new Set<Id>{testAcc1.Id};
                
                Contact con1 = new Contact(FirstName = 'Test',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=testAcc1.Id);
        insert con1;
        
        Contact con2 = new Contact(FirstName = 'Test12',LastName = 'Contact124',Email = 'test@test.com',AccountId=acc.Id);
        insert con2; 
        
        AccountContactRelation accConR1 = new AccountContactRelation();
        accConR1.AccountId = acc.Id;
        accConR1.ContactId = con1.Id;
        insert accConR1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = BRS_TestDataFactory.createCommunityUser(con1, p.Id);
        
        Test.startTest();
        System.runAs(u) {
            //BRS_Utility.createAccountRelation(lstAccIds1);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateAccountRelation2() {
        Account testAcc1 = new Account(Name = 'TestClassAcct1 LLC Co.', Citizenship__c = 'Domestic', Business_Type__c = 'Religious', Status__c='Active');
        insert testAcc1; 
        
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Set<Id> lstAccIds1 = new Set<Id>{acc.Id};
            Set<Id> lstAccIds2 = new Set<Id>{testAcc1.Id};
                
                Contact con1 = new Contact(FirstName = 'Test',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=testAcc1.Id);
        insert con1;
        
        Contact con2 = new Contact(FirstName = 'Test12',LastName = 'Contact124',Email = 'test@test.com',AccountId=acc.Id);
        insert con2; 
        
        AccountContactRelation accConR1 = new AccountContactRelation();
        accConR1.AccountId = acc.Id;
        accConR1.ContactId = con1.Id;
        insert accConR1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u2 = BRS_TestDataFactory.createCommunityUser(con2, p.Id);
        Test.startTest();
        System.runAs(u2) {
            //  BRS_Utility.createAccountRelation(lstAccIds2);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testSendMailByBody(){
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, 'Annual Report', 'In-Progress');
        
        List<String> lstTo = new List<String>{'test@mailinator.com'};
            List<String> lstcc = new List<String>{'nottest@mailinator.com'};
                String subject = 'This is a test subject';
        String body = 'This is a test body';
        
        OrgWideEmailAddress[] addresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        String orgWideEmailAddr = String.valueOf(addresses[0].Address);
        
        Attachment attchmnt = new Attachment();
        attchmnt.Name = 'Test';
        attchmnt.IsPrivate = false;
        Blob b = Blob.valueOf('Test');
        attchmnt.Body = b;
        attchmnt.ParentId = filing.Id;
        insert attchmnt;
        
        Messaging.EmailFileAttachment mEmAtt = new Messaging.EmailFileAttachment();
        mEmAtt.body = b;
        //mEmAtt.Id = attchmnt.Id;
        mEmAtt.filename = 'Test';
        List<Messaging.EmailFileAttachment> lstEmAtt = new List<Messaging.EmailFileAttachment>{mEmAtt};
            brs_Utility.getReviewMetadata('Online Intake Category', acc,filing.Id);
        Test.startTest();
        //BRS_Utility.sendMailByBody(lstTo, lstcc, subject, body, orgWideEmailAddr, lstEmAtt);
        Test.stopTest();
    }
    @isTest
    public static void getPicklistLabeltest(){
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Id bizFilingARRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Annual_Report_First_Report').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingARRecordType, acc.Id, wo.Id, 'Annual Report', 'In-Progress');
        //SObjectType objType = SObjectType.newSObject();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Business_Filing__c');
        Test.startTest();
        String ret = BRS_Utility.getPicklistLabel(objType, 'Type__c', 'Annual Report');
        System.assertEquals('Annual Report', ret);
        Test.stopTest();
    }
    @isTest
    public static void updateRecordsFromTempAgenttest(){
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
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
        //BRS_Utility.getFieldSetMember('Principal__c','Business_Filing_Review');
        Test.stopTest();
    }
    @isTest
    public static void updateRecordsFromTempPrincipaltest(){
        Account acc = BRS_TestDataFactory.createAcc('Foreign', 'Stock');
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Id bizFilingMaintRecordType = Schema.getGlobalDescribe().get('Business_Filing__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Maintenance').getRecordTypeId();
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Open');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingRecord(bizFilingMaintRecordType, acc.Id, wo.Id, 'Change of Agent', 'In-Progress');

        Principal__c principal1 = BRS_TestDataFactory.createPrincipal();
        List<Temp_History__c> lstTH = new List<Temp_History__c>();
        Temp_History__c tmpHistory2 = new Temp_History__c();
        tmpHistory2.Certificate_Types__c = 'Express';
        tmpHistory2.Business_Filing__c = filing.id;
        tmpHistory2.Business_ID__c = acc.id;
        tmpHistory2.Change_Type__c = system.label.Deleted;
        tmpHistory2.Type__c='Principal';
        tmpHistory2.Principal__c=principal1.Id;
        lstTH.add(tmpHistory2);
        insert lstTH;
        Test.startTest();
        List<BRS_Utility.maintennaceResponce> lstret = BRS_Utility.updateRecordsFromTemp(acc.id, 'Principal', String.valueOf(filing.Id));
        Test.stopTest();
    }
    testMethod static void getReviewMetadataTest1() {
        Account acc0 = new Account(Name = 'Test');
        Insert acc0;
        Contact con2 = BRS_TestDataFactory.createContactObject(acc0.Id);
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        acc.Began_Transacting_in_CT__c=system.today();
        acc.Business_End_Date__c = system.today().addDays(10);
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='Stock';
        acc.Duration_of_Business_In_CT__c='Period of Duration';
        acc.Date_of_Formation__c=System.today();
        acc.Business_Name_in_state_country__c='Teststs';
        acc.State_or_Territory_Formation__c='CT';
        acc.ShippingStreet ='Test';
        update acc;
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=System.today().addYears(-1),Type__c='Judgment - Personal Property'));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2'));
        
        insert uccLien;
        List<UCC_Filing__c> uccFilingRec = new List<UCC_Filing__c>();
        uccFilingRec = [select Id, Name__c, Type__c, UCC_Lien_Number__c, Description__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Alternative_Designations__c, Collateral_Type__c, Collateral_Information__c, Lien_Filing_Type__c, Original_Judgement_Amount__c,
                        Date_of_Judgement__c, Amount_Due__c, Reason_for_Dispute__c, Dispute_Justification__c, Claim_Amount__c, Filer_Reference_Data__c, Type_of_Collateral_Update__c 
                        from UCC_Filing__c where UCC_Lien_Id__c = :uccLien[0].Id limit 1];
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[0].id, Amendment_Type__c = 'Amendment'));
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[1].id));
        insert testFiling; 
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
        mainWorkorder.Customer__c = con2.Id;
        mainWorkorder.Received_Date__c = System.today();
        insert mainWorkorder;
        //insertWOList.add(mainWorkorder);
        
        Work_Order__c otherReqWO = new Work_Order__c();
        otherReqWO.Status__c = 'In-Progress';
        otherReqWO.Type__c = 'Other Requests';
        otherReqWO.Source__c = 'Mail';
        otherReqWO.Customer__c = con2.Id;
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
        
        
        
        Test.startTest();
        String flowname = 'Business Formation';
        BRS_Utility.getReviewMetadata(flowname,acc, testFiling[0].id);
    
        BRS_Utility.getOptionsData();
        BRS_Utility.getLegalDesignators();
        BRS_Utility.getNoiseWords();
        //BRS_Utility.getFieldSetMember('Account','Name');
        BRS_Utility.getCities();
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc1.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc1.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Business Registration';
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        insert businessFiling;
        
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
        Principal__c principal1 = BRS_TestDataFactory.createPrincipal();
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = businessFiling.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc1.id;
        tmpHistory1.Agent__c = agents.id;
        insert tmpHistory1;
        tmpHistory1.Type__c=System.label.Label_Principal;
        tmpHistory1.Principal__c=principal1.Id;
        update tmpHistory1;
        BRS_Utility.upsertTempRecord(tmpHistory1);
        
        
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
        objRelatedInfo.City__c = 'City';   
        objRelatedInfo.Country__c = 'country';
        //objRelatedInfo.Individual_First_Name__c = 'FirstName';
        objRelatedInfo.isAuthorizer__c = true;
        objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
        objRelatedInfo.Org_Name__c = 'Orgname';
        objRelatedInfo.Type__c = 'Secured Party';
        //objRelatedInfo.Individual_SurName__c = 'surname'; 
        objRelatedInfo.Street__c = 'Street';
        objRelatedInfo.State__c = 'state';
        objRelatedInfo.Zip_Code__c = '11111';
        //objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
        objRelatedInfo.Suffix__c = 'Suffix';  
        Insert objRelatedInfo;
        
        List<String> strList = new List<String>();
   
        Test.stopTest();
        
    }

    @IsTest
    static void getDataForReportFiling_2() {
       
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Business_Type__c='LLC';
        //acc.Mailing_International_Address__c='Test';
        acc.ShippingStreet='Test';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,BillingState,BillingCity,BillingPostalCode,BillingStreet,Principle_Office_International_Address__c,Other_Provisions__c,ShippingCountry,Mailing_International_Address__c,ShippingState,ShippingPostalCode,ShippingStreet,Shipping_Unit__c,ShippingCity,Citizenship__c,Description from Account  where Id=:acc.Id limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
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
        agents.Mailing_Street_Address_1__c = 'Test';
        agents.Mailing_City__c = 'Test';
        agents.Mailing_State__c = 'CT';
        agents.Mailing_Country__c = 'United States';
        agents.Mailing_Zip_Code__c = '12345';
        insert agents;
        
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = currentBf.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc.id;
        tmpHistory1.Agent__c = agents.id;
        insert tmpHistory1;
        
        BRS_Utility.upsertTempRecord(tmpHistory1);
        
        String flowName='First_Annual_Report';
        Boolean isOverView=false;
        test.startTest();
        try{
            BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
            //BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }catch(Exception e){}
        test.stopTest();
    }
    @IsTest
    static void getDataForReportFiling_3() {
       
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Business_Type__c='LLC';
        //acc.Mailing_International_Address__c='Test';
        acc.ShippingStreet='Test';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        
        Account accSObj = [Select id,Business_Type__c,BillingState,BillingCity,BillingPostalCode,BillingStreet,Principle_Office_International_Address__c,Other_Provisions__c,ShippingCountry,Mailing_International_Address__c,ShippingState,ShippingPostalCode,ShippingStreet,Shipping_Unit__c,ShippingCity,Citizenship__c,Description from Account  where Id=:acc.Id limit 1];
        accSObj.Mailing_International_Address__c='Test';
        update accSObj;
        currentBf.Account__c=accSObj.Id;
        update currentBf;
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
        agents.Mailing_Street_Address_1__c = 'Test';
        agents.Mailing_City__c = 'Test';
        agents.Mailing_State__c = 'CT';
        agents.Mailing_Country__c = 'United States';
        agents.Mailing_Zip_Code__c = '12345';
        insert agents;
        
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = currentBf.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc.id;
        tmpHistory1.Agent__c = agents.id;
        tmpHistory1.Change_Type__c = 'Deleted';
        insert tmpHistory1;
        
        BRS_Utility.upsertTempRecord(tmpHistory1);
        
        String flowName='First_Annual_Report';
        Boolean isOverView=false;
        test.startTest();
        try{
            BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
            //BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30');
        }catch(Exception e){}
        test.stopTest();
    }
     testMethod static void getReviewMetadataTest_3() {
        Account acc0 = new Account(Name = 'Test');
        Insert acc0;
        Contact con2 = BRS_TestDataFactory.createContactObject(acc0.Id);
        OnOff_Filing_Auto_Refund__c custSettOnOff =  new OnOff_Filing_Auto_Refund__c();
        custSettOnOff.Name = 'On Off Switch';
        custSettOnOff.Auto_Refund_UCC_Filing__c = True;
        custSettOnOff.Auto_Refund_Business_Filing__c = True;
        custSettOnOff.SetupOwnerId = [Select ID from Organization Limit 1].id;
        insert custSettOnOff;
        
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        acc.Began_Transacting_in_CT__c=system.today();
        acc.Business_End_Date__c = system.today().addDays(10);
        update acc;
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=System.today().addYears(-1),Type__c='Judgment - Personal Property'));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData3',UCC_Lien_Number__c='TestData3',Type__c='Aircraft'));
        //uccLien.add(new UCC_Lien__c(Name__c='LienData4',UCC_Lien_Number__c='TestData4',Type__c='Vessel'));
        insert uccLien;
        List<UCC_Filing__c> uccFilingRec = new List<UCC_Filing__c>();
        uccFilingRec = [select Id, Name__c, Type__c, UCC_Lien_Number__c, Description__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Alternative_Designations__c, Collateral_Type__c, Collateral_Information__c, Lien_Filing_Type__c, Original_Judgement_Amount__c,
                        Date_of_Judgement__c, Amount_Due__c, Reason_for_Dispute__c, Dispute_Justification__c, Claim_Amount__c, Filer_Reference_Data__c, Type_of_Collateral_Update__c 
                        from UCC_Filing__c where UCC_Lien_Id__c = :uccLien[0].Id limit 1];
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[0].id, Amendment_Type__c = 'Amendment'));
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'In-Progress',UCC_Lien_Id__c=uccLien[1].id));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[2].id, Amendment_Type__c = 'Amendment'));
        //testFiling.add(new UCC_Filing__c(Type__c = 'Vessel',Status__c = 'Completed',UCC_Lien_Id__c=uccLien[3].id));
        insert testFiling; 
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
        mainWorkorder.Customer__c = con2.Id;
        mainWorkorder.Received_Date__c = System.today();
        insert mainWorkorder;
        //insertWOList.add(mainWorkorder);
        
        Work_Order__c otherReqWO = new Work_Order__c();
        otherReqWO.Status__c = 'In-Progress';
        otherReqWO.Type__c = 'Other Requests';
        otherReqWO.Source__c = 'Mail';
        otherReqWO.Customer__c = con2.Id;
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
        
        
        
        Test.startTest();
        String flowname = 'Business Formation';
        BRS_Utility.getReviewMetadata(flowname,acc, testFiling[0].id);
        BRS_Utility.getReviewMetadata(flowname,acc, null);
        BRS_Utility.getReviewMetadata('UCC-3 Lien',testFiling[0],null);
        BRS_Utility.getReviewMetadata('UCC 5 Lien',testFiling[0],null);
        BRS_Utility.getReviewMetadata('UCC Lien', uccLien[0] ,null);

        BRS_Utility.getReviewMetadata('Obtain Certificate Flow', insertCertList[0] ,testFiling[0].id); //uncommented
        

        BRS_Utility.getOptionsData();
        BRS_Utility.getLegalDesignators();
        BRS_Utility.getNoiseWords();
        //BRS_Utility.getFieldSetMember('Account','Name');
        BRS_Utility.getCities();
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc1.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc1.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Business Registration';
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        insert businessFiling;
        
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
        Principal__c principal1 = BRS_TestDataFactory.createPrincipal();
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = businessFiling.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc1.id;
        tmpHistory1.Agent__c = agents.id;
        insert tmpHistory1;
        tmpHistory1.Type__c=System.label.Label_Principal;
        tmpHistory1.Principal__c=principal1.Id;
        update tmpHistory1;
        BRS_Utility.upsertTempRecord(tmpHistory1);
        
        
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
        objRelatedInfo.City__c = 'City';   
        objRelatedInfo.Country__c = 'country';
        //objRelatedInfo.Individual_First_Name__c = 'FirstName';
        objRelatedInfo.isAuthorizer__c = true;
        objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
        objRelatedInfo.Org_Name__c = 'Orgname';
        objRelatedInfo.Type__c = 'Secured Party';
        //objRelatedInfo.Individual_SurName__c = 'surname'; 
        objRelatedInfo.Street__c = 'Street';
        objRelatedInfo.State__c = 'state';
        objRelatedInfo.Zip_Code__c = '11111';
        //objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
        objRelatedInfo.Suffix__c = 'Suffix';  
        Insert objRelatedInfo;
        
        List<String> strList = new List<String>();
        
        
        BRS_Utility.getReviewMetadata('UCC',uccLien[0],businessFiling.Id);
        //BRS_Utility.getReviewMetadata('UCC-3 Lien',acc1,businessFiling.Id);
        Test.stopTest();
        
    }

}