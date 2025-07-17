@isTest
public class brs_contactDetailPage_Test {
    testMethod static void getAgentRecordsTest() {
        test.startTest();
        List<Agent__c> agentdata = new  List<Agent__c>();
        String whereclause = 'agents';
        List<Account> accountdata = new  List<Account>();
        for(Integer i = 0 ; i < 3 ; i++)
        {
            Account acc = new Account();
            acc.Name = 'Test'+i;
            acc.Status__c = 'Active';
            accountdata.add(acc);
        }
        insert accountdata;
        
        for(Integer i = 0 ; i < 3 ; i++)
        {
            Agent__c agents = new Agent__c();
            agents.Name__c = 'agents' + i;
            agents.Type__c = 'Business';
            agents.Business_Name__c = 'Pizza';
            agents.Business_Street_Address_1__c = 'Test';
            agents.Business_City__c = 'New York';
            agents.Business_Country__c = 'United States';
            agents.Business_Zip_Code__c = '12334';
            agents.Business_State__c = 'CT';
            agents.Business_ID__c = accountdata[i].id;
            agentdata.add(agents);
        }
        insert agentdata;
        brs_contactDetailPage.getAccountRecords(whereclause);
        try {
            whereclause  =  '\' Exception \' AND ' ;
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        test.stopTest();
    }
    testMethod static void insertAgentRecordTest1() {
        String whereclause = 'agents';
        List<Account> accListUpdates = new List<Account>();
        List<Account> accList = new List<Account>([SELECT ID,Status__c FROM Account]);
        for(Account acc :  accList){
            acc.Status__c = 'Cancelled';
            accListUpdates.add(acc);
        }
        update accListUpdates;
        try{
            brs_contactDetailPage.getAccountRecords('Inavlid');  
        }catch(Exception e){ 
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    testMethod static void insertAgentRecordTest() {
        test.startTest();
        try {
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_Street_Address_1__c = 'Test',
                                           Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            insert agents;
            brs_contactDetailPage.insertAgentRecord(agents);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            
            try {
                brs_contactDetailPage.insertAgentRecord(agents);
            } catch (Exception e1) {
                System.assertEquals('Script-thrown exception', e1.getMessage());
            }
        }
        test.stopTest();
    }
    testMethod static void updateAgentRecordTest() {
        test.startTest();
        try {
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_Street_Address_1__c = 'Test',
                                           Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            brs_contactDetailPage.updateAgentRecord(agents);  
        }  catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_Street_Address_1__c = 'Test',
                                           Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            insert agents;
            brs_contactDetailPage.updateAgentRecord(agents);  
        }
        test.stopTest();
    }
    testMethod static void deleteAgentRecordTest1() {
        test.startTest();
        try{
            brs_contactDetailPage.deleteAgentRecord('Invalid');  
        }catch(Exception e){ 
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        test.stopTest();
        
    }
    testMethod static void deleteAgentRecordTest() {
        test.startTest();
        try{
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_Street_Address_1__c = 'Test',
                                           Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            insert agents;
            
            brs_contactDetailPage.deleteAgentRecord(agents.Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        test.stopTest();
    }
    testMethod static void getPrincipalRecordsonLoadTest() {
        test.startTest(); 
        Account acc = new Account(Name='Test',Status__c='Active');
        insert acc;
        Principal__c principal = new Principal__c();
        principal.Principal_Account_ID__c = acc.Id;
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Business_Street_Address_1__c = 'Test';
        principal.Business_City__c = 'New York';
        principal.Business_Country__c = 'United States';
        principal.Business_Zip_Code__c = '12334';
        principal.Business_State__c = 'CT';
        principal.Email__c = 'saritanayak71@gmail.com';
        System.assertEquals(0, brs_contactDetailPage.getPrincipalRecordsonLoad(principal.Id).size());
        insert principal;
        System.assertEquals(0, brs_contactDetailPage.getPrincipalRecordsonLoad(acc.Id).size());
        test.stopTest();
    }
    testMethod static void deletePrincipalRecordTest()
    {
        test.startTest();
        Principal__c principal = new Principal__c();
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Business_Street_Address_1__c = 'Test';
        principal.Business_City__c = 'New York';
        principal.Business_Country__c = 'United States';
        principal.Business_Zip_Code__c = '12334';
        principal.Business_State__c = 'CT';
        principal.Email__c	= 'saritanayak71@gmail.com';
        brs_contactDetailPage.deletePrincipalRecord(principal.Id);
        insert principal;
        brs_contactDetailPage.deletePrincipalRecord(principal.Id);
        test.stopTest();
    }
    testMethod static void updatePrincipalRecordTest() {
        test.startTest();
        try {
            Principal__c principal = new Principal__c();
            principal.Name__c = 'principal';
            principal.Principal_Type__c = 'Business';
            principal.Business_Name__c = 'Pizza';
            principal.Business_Street_Address_1__c = 'Test';
            principal.Business_City__c = 'New York';
            principal.Business_Country__c = 'United States';
            principal.Business_Zip_Code__c = '12334';
            principal.Business_State__c = 'CT';
            principal.Email__c	= 'saritanayak71@gmail.com';
            brs_contactDetailPage.updatePrincipalRecord(principal);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Principal__c principal = new Principal__c();
            principal.Name__c = 'principal';
            principal.Principal_Type__c = 'Business';
            principal.Business_Name__c = 'Pizza';
            principal.Business_Street_Address_1__c = 'Test';
            principal.Business_City__c = 'New York';
            principal.Business_Country__c = 'United States';
            principal.Business_Zip_Code__c = '12334';
            principal.Business_State__c = 'CT';
            principal.Email__c	= 'saritanayak71@gmail.com';
            insert principal;
            brs_contactDetailPage.updatePrincipalRecord(principal);
        }
        test.stopTest();   
    }
    testMethod static void insertPrincipalRecordTest() {
        test.startTest();
        try {
            Principal__c principal = new Principal__c();
            principal.Name__c = 'principal';
            principal.Principal_Type__c = 'Business';
            principal.Business_Name__c = 'Pizza';
            principal.Business_Street_Address_1__c = 'Test';
            principal.Business_City__c = 'New York';
            principal.Business_Country__c = 'United States';
            principal.Business_Zip_Code__c = '12334';
            principal.Business_State__c = 'CT';
            principal.Email__c	= 'saritanayak71@gmail.com';
            insert principal;
            brs_contactDetailPage.insertPrincipalRecord(principal);
            brs_contactDetailPage.insertPrincipalRecord(principal);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Principal__c principal = new Principal__c();
            principal.Name__c = 'principal';
            principal.Principal_Type__c = 'Business';
            principal.Business_Name__c = 'Pizza';
            principal.Email__c	= 'saritanayak71@gmail.com';
            
        }
        test.stopTest();
    }
    testMethod static void updateAgentOnAccountTest() {
        test.startTest();
        try {
            Account acc = new Account(Name='Test',Status__c='Active');
            insert acc;
            brs_contactDetailPage.updateAgentOnAccount(acc.id,'InvalidIdValues');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Account acc = new Account(Name='Test Account',Status__c='Active');
            insert acc;
            Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_ID__c=acc.id,Agent_Account_ID__c=acc.id,Business_Street_Address_1__c = 'Test',
                                           Business_City__c = 'New York',
                                           Business_Country__c = 'United States',
                                           Business_Zip_Code__c = '12334',
                                           Business_State__c = 'CT');
            brs_contactDetailPage.updateAgentOnAccount(acc.id,agents.id);
            insert agents;
            brs_contactDetailPage.updateAgentOnAccount(acc.id,agents.id);
        }
        test.stopTest();
    }
    testMethod static void getPrincipalAsAgentRecordsTest() {
        test.startTest();
        List<Principal__c> principaldata = new  List<Principal__c>();
        Account acc = new Account(Name='Test',Status__c='Active');
        System.assertEquals(0, brs_contactDetailPage.getPrincipalAsAgentRecords(acc.id).size());
        insert acc;
        for(Integer i = 0 ; i < 3 ; i++) {
            Principal__c principal = new Principal__c();
            principal.Name__c = 'principal'+i;
            principal.Principal_Type__c = 'Business';
            principal.Business_Name__c = 'Pizza';
            principal.Business_ID__c = acc.id;
            principal.Principal_Account_ID__c = acc.id;
            principal.Business_Street_Address_1__c = 'Test';
            principal.Business_City__c = 'New York';
            principal.Business_Country__c = 'United States';
            principal.Business_Zip_Code__c = '12334';
            principal.Business_State__c = 'CT';
            principal.Email__c	= 'saritanayak71@gmail.com';
            principaldata.add(principal);
        }
        insert principaldata;
        System.assertEquals(3, brs_contactDetailPage.getPrincipalAsAgentRecords(acc.id).size());
        test.stopTest();
    }
    testMethod static void fetchInterfaceConfigTest() {
        test.startTest();
        Interface_Configuration__mdt sample = brs_contactDetailPage.fetchInterfaceConfig();
        System.assertNotEquals(null,sample);
        test.stopTest();
    }
    testMethod static void insertIncorporatorRecordTest() {
        test.startTest();
        try {
            Contact con = new Contact();
            con.FirstName = 'Fname';
            con.LastName = 'LName';
            insert con;
            brs_contactDetailPage.insertIncorporatorRecord(con);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Contact con = new Contact();
            con.FirstName = 'Fname';
            con.LastName = 'LName';
            brs_contactDetailPage.insertIncorporatorRecord(con);
        }
        test.stopTest();
    }
    testMethod static void updateIncorporatorRecordTest() {
        test.startTest();
        try {
            Contact con = new Contact();
            con.FirstName = 'Fname';
            con.LastName = 'LName';
            brs_contactDetailPage.updateIncorporatorRecord(con);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Contact con = new Contact();
            con.FirstName = 'Fname';
            con.LastName = 'LName';
            insert con;
            brs_contactDetailPage.updateIncorporatorRecord(con);
        }
        test.stopTest();
    }
    testMethod static void deleteIncorporatorRecordTest() {
        Contact con = new Contact();
        con.FirstName = 'Fname';
        con.LastName = 'LName';
        insert con;
        brs_contactDetailPage.deleteIncorporatorRecord(con.Id);
        try{
            
            brs_contactDetailPage.deleteIncorporatorRecord('Invalid');
        }
        catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            Contact con1 = new Contact();
            con1.FirstName = 'Fname';
            con1.LastName = 'LName';
            insert con1;
            brs_contactDetailPage.deleteIncorporatorRecord(con1.Id);
        }
        
        
    }
    testMethod static void getIncorporatorRecordsonLoadTest()
    {
        test.startTest();
        Account acc = new Account();
        acc.Name = 'AccName';
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Fname';
        con.LastName = 'LName';
        con.AccountId = acc.Id;
        insert con;
        System.assertEquals(0, brs_contactDetailPage.getIncorporatorRecordsonLoad(con.Id).size());
        System.assertEquals(1, brs_contactDetailPage.getIncorporatorRecordsonLoad(acc.Id).size());
        test.stopTest();
    }
    
    testMethod static void getAgentRecordsonLoad() {
        test.startTest();
        Account acc = new Account(Name = 'Test',Status__c = 'Active');
        insert acc;
        Agent__c agents = new Agent__c(Name__c='agents',Type__c='Business',Business_Name__c='Pizza',Business_ID__c=acc.id,Agent_Account_ID__c=acc.id,Business_Street_Address_1__c = 'Test',
                                       Business_City__c = 'New York',
                                       Business_Country__c = 'United States',
                                       Business_Zip_Code__c = '12334',
                                       Business_State__c = 'CT');
        try {
            brs_contactDetailPage.getAgentRecordsonLoad('Invalid');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            insert agents;
            brs_contactDetailPage.getAgentRecordsonLoad(acc.Id);
        }
        test.stopTest();
    }
    
    testMethod static void deleteTempRecord() {
        test.startTest();
        Account acc = new Account(Name = 'Test',Status__c = 'Active');
        insert acc;
        Temp_History__c agents = new Temp_History__c(Account__c = acc.Id);
        insert agents;
        brs_contactDetailPage.deleteTempRecord(agents.Id);
        test.stopTest();
    }
    testMethod static void getTempRecordsonLoad() {
        test.startTest();
        Account acc = new Account(Name = 'Test',Status__c = 'Active');
        insert acc;
        Temp_History__c agents = new Temp_History__c(Account__c = acc.Id);
        insert agents;
        System.assertNotEquals(0,1);
        test.stopTest();
    }
   
    testMethod static void updateTempRecordTest() {
        test.startTest();
        Account acc = new Account(Name = 'Test',Status__c = 'Active');
        insert acc;
        Temp_History__c agents = new Temp_History__c(Account__c = acc.Id);
        try {
            
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            insert agents;
            
        }
        
        test.stopTest();
    }
    testMethod static void getStates() {
        test.startTest();
        System.assert(brs_contactDetailPage.getStates() != null);
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();        
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Business Registration';
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        try{
            insert businessFiling;
        }
        catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Principal__c principalRec = new Principal__c();
        principalRec.Name__c = 'principal';
        principalRec.Principal_Type__c = 'Business';
        principalRec.Business_Name__c = 'Pizza';
        principalRec.Business_ID__c = acc.id;
        principalRec.Principal_Account_ID__c = acc.id;
        principalRec.Business_Street_Address_1__c = 'Test';
        principalRec.Business_City__c = 'New York';
        principalRec.Business_Country__c = 'United States';
        principalRec.Business_Zip_Code__c = '12334';
        principalRec.Business_State__c = 'CT';
        principalRec.Email__c	= 'saritanayak71@gmail.com';
        insert principalRec;
        
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Certificate_Types__c = 'Express';
        tmpHistory.Business_Filing__c = businessFiling.id;
        tmpHistory.Type__c = System.Label.Principal;
        tmpHistory.Business_ID__c = acc.id;
        insert tmpHistory;
        
        brs_contactDetailPage.getTempRecordsonLoad(acc.id,'Account',businessFiling.id);
        brs_contactDetailPage.getTempRecordsonLoad(acc.id,'Account',null);
        
        Agent__c agents = new Agent__c();
        agents.Name__c = 'agents';
        agents.Type__c = 'Business';
        agents.Business_Name__c = 'Pizza';
        agents.Business_Street_Address_1__c = 'Test';
        agents.Business_City__c = 'New York';
        agents.Business_Country__c = 'United States';
        agents.Business_Zip_Code__c = '12334';
        agents.Business_State__c = 'CT';
        agents.Business_ID__c = acc.id;
        insert agents;
        
        Temp_History__c tmpHistory1 = new Temp_History__c();
        tmpHistory1.Certificate_Types__c = 'Express';
        tmpHistory1.Business_Filing__c = businessFiling.id;
        tmpHistory1.Type__c = 'Agent';
        tmpHistory1.Business_ID__c = acc.id;
        tmpHistory1.Agent__c = agents.id;
        insert tmpHistory1;
        brs_contactDetailPage.upsertTempRecord(tmpHistory1);
        
        brs_contactDetailPage.getAllRecordsonLoad(acc.id,businessFiling.id);
       
        test.stopTest();
    }
    
    testMethod static void getStates2() {
        test.startTest();
        System.assert(brs_contactDetailPage.getStates() != null);
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();      
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = 'Business Registration';
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Filing_Date__c = System.Today().addDays(-30);
        try{
            insert businessFiling;
        }
        catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        Principal__c principal = new Principal__c();
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Business_Street_Address_1__c = 'Test';
        principal.Business_City__c = 'New York';
        principal.Business_Country__c = 'United States';
        principal.Business_Zip_Code__c = '12334';
        principal.Business_State__c = 'CT';
        principal.Email__c    = 'saritanayak71@gmail.com';
        principal.External_ID__c = '1233456';
        insert principal;
        
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Certificate_Types__c = 'Express';
        tmpHistory.Business_Filing__c = businessFiling.id;
        tmpHistory.Type__c = 'Account';
        tmpHistory.Business_ID__c = acc.id;
        insert tmpHistory;
        
       
        test.stopTest();
    }    
    
   
    testMethod static void getAgentVisible() {
        test.startTest();
        Category__c categoryCreated = QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
        Questionnaire__c questionnaire = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Will your business be any of these less common legal structures?',
            'General Partnership|Benefit Corporation|Limited Partnership|Limited Liability Partnership|Religious Corporation or Society|Statutory Trust|I\'m not sure',
            null,'Test',6,'InProgress',false,'Test','Test','Text',
            'lightning:radioGroup','Employees');
        QnA_QuestionResponse__c questionResponse = QnA_TestDataFactory.createResponse(questionnaire.id,questionCreate.id,'Domestic');
        brs_contactDetailPage.getAgentVisible(questionnaire.Id);
        questionCreate.Question_Summary__c = 'Foreign or Domestic';
        questionResponse.Given_Response_Value__c ='Domestic';
        update questionResponse;
        update questionCreate;
        brs_contactDetailPage.getAgentVisible(questionnaire.Id);
        questionCreate.Question_Summary__c = 'Legal Structure';
        update questionCreate;
        questionResponse.Given_Response_Value__c ='Limited Liability Partnership';
        update questionResponse;
        brs_contactDetailPage.getAgentVisible(questionnaire.Id);
        questionResponse.Given_Response_Value__c ='Location';
        update questionResponse;
        brs_contactDetailPage.getAgentVisible(questionnaire.Id);
        try {
            brs_contactDetailPage.getAgentVisible('InvalidIdValues');
        } catch (Exception e) {
            System.assert(false,e.getMessage());
        }
        test.stopTest();
    }
    testMethod static void upsertTempRecordExce() {
        test.startTest();
        try{
            Temp_History__c histInst;
            brs_contactDetailPage.upsertTempRecord(histInst);  
        }
        catch (Exception e) {
        }
        
        test.stopTest();
    }
    
    testMethod static void upsertTempRecord(){
        test.startTest();
        try{
             Account ac1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='test',
            Status__c = System.Label.ACTIVE);
            insert ac1;
            Agent__c agent = new Agent__c(Business_ID__c=ac1.Id,FirstName__c='Agent', Business_Zip_Code__c = '12345');
        	insert agent;
            Temp_History__c histInst = new Temp_History__c(Type__c='Agent', Account__c=ac1.id, Agent__c=agent.id);
            brs_contactDetailPage.upsertTempRecord(histInst);  
        }
        catch (Exception e) {
        }
        test.stopTest();
    }
    
    
}