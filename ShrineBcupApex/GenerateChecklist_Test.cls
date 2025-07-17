/*********************************************************************************************
* NAME:  GenerateChecklist_Test
* DESCRIPTION: This is test class for GenerateChecklist class. 
*
* @AUTHOR: Sabhyata Rao
* @DATE: 07/04/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sabhyata Rao                     31/03/2020                         Created the first version
*********************************************************************************************/

@isTest 
private class GenerateChecklist_Test {
    private static final String NAICS_CODE = '728467';
    private static final String SERVICE_TITLE = 'Food';
    
    @testSetup
    private static void setup() {
		Account ac = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='Grazitti',
            Status__c = System.Label.ACTIVE
        );
        insert ac;
        Contact con = new Contact(LastName ='testCon',Email='abc@gmail.com',AccountId = ac.Id);
		insert con;
        Contact con123 = new Contact(LastName ='testCon123',Email='testertest@gmail.com',AccountId = ac.Id);
		insert con123;
        Id profileID = [SELECT ID FROM Profile WHERE NAME ='CT Community User'].id;
        User objUser = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileID, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.comtesting'
        );
        insert objUser;
        Category__c categoryCreated = QnA_TestDataFactory.createCategoryWithCode('Services','Level1', NAICS_CODE);
        Questionnaire__c questionnaire = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        QnA_FrameworkQuestionVersion__c questionVersion = QnA_TestDataFactory.createQuestionVersion(System.today()-1);
        
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Will your business be any of these less common legal structures?',
            'General Partnership|Benefit Corporation|Limited Partnership|Limited Liability Partnership|Religious Corporation or Society|Statutory Trust|I\'m not sure',
            null,null,null,null,false,null,null,null,
            'lightning:radioGroup','Employees');
        
        QA_Question_Option__c option1 =  QnA_TestDataFactory.createOption(questionCreate.id,'General Partnership','General Partnership',1);
        QA_Question_Option__c option2 =  QnA_TestDataFactory.createOption(questionCreate.id,'Benefit Corporation','General Partnership',2);
        QA_Question_Option__c option3 =  QnA_TestDataFactory.createOption(questionCreate.id,'Limited Partnership','General Partnership',3);
        QA_Question_Option__c option4 =  QnA_TestDataFactory.createOption(questionCreate.id,'Limited Liability Partnership','General Partnership',4);
        QA_Question_Option__c option5 =  QnA_TestDataFactory.createOption(questionCreate.id,'Religious Corporation or Society','General Partnership',5);
        QA_Question_Option__c option6 =  QnA_TestDataFactory.createOption(questionCreate.id,'Statutory Trust','General Partnership',6);
        
        QnA_FrameworkQuestion__c questionCreate2 = QnA_TestDataFactory.createQuestion(
            'Pick each description that matches your business.',
            'Woman Owned|Minority Owned|LGBTQI Owned|Veteran Owned|Disability Owned',
            null,null,null,null,false,null,null,null,
            'lightning-dual-listbox','Employees');
        
        QnA_FrameworkQuestion__c questionCreate3 = QnA_TestDataFactory.createQuestion(
            'What do you plan to name your business?',
            'E.g. Barb\'s Bakery',
            null,null,null,null,false,null,null,null,
            'Search Input','Employees');
        
        TemplateChecklistItems__c templateCheckList = QnA_TestDataFactory.createTemplateCheckListItem(
            'Check if your business name is available.',
            'Check with the State of Connecticut to make sure your business name is available for you to use. Please note your business name is subject to approval by the CT Secretary of State and may need to change.',
            'Business registration');
        TemplateChecklistItems__c templateCheckList_1 = QnA_TestDataFactory.createTemplateCheckListItem(
            'Check if your business name is available.',
            'Check with the State of Connecticut to make sure your business name is available for you to use. Please note your business name is subject to approval by the CT Secretary of State and may need to change.',
            'Licenses');
        TemplateChecklistItems__c templateCheckList2 = QnA_TestDataFactory.createTemplateCheckListItem(
            'Choose your business\'s address.',
            'You\'ll need a real US mailing address. At this address, you\'ll get business-related mail, so make sure it\'s an address you\'ll check often.',
            'Before you register');
        TemplateChecklistItems__c templateCheckList3 = QnA_TestDataFactory.createTemplateCheckListItem(
            'Explore resources for getting your business started.',
            'Here are some resources and organizations that can help your business succeed.',
            'Resources');
        TemplateChecklistItems__c templateCheckList4 = QnA_TestDataFactory.createTemplateCheckListItem(
            'Check if your business name is available.',
            'Check with the State of Connecticut to make sure your business name is available for you to use. Please note your business name is subject to approval by the CT Secretary of State and may need to change.',
            'Business registration');
        
        Checklist_Master__c checklistMaster = QnA_TestDataFactory.createChecklistMaster(
            'Check Business Name Availability (General Partnership)',templateCheckList.id, questionCreate.id, 'General Partnership');
        Checklist_Master__c checklistMaster2 = QnA_TestDataFactory.createChecklistMaster(
            'Choose your business\'s address',templateCheckList2.id, null,null);
        checklistMaster2.Include_as_Static_Checklist_Item__c = true;
        if(checklistMaster2 != NULL){
            update checklistMaster2;
        }
        
        Checklist_Master__c  checklistMaster3 = QnA_TestDataFactory.createChecklistMaster(
            'Resources',templateCheckList3.id,
            questionCreate2.id,
            'Woman Owned|Minority Owned|LGBTQI Owned|Veteran Owned|Disability Owned');
        Checklist_Master__c  checklistMaster4  = QnA_TestDataFactory.createChecklistMaster(
            'Business availability',templateCheckList4.id,
            questionCreate3.id,
            '');
        
        QnA_QuestionResponse__c questionResponse = QnA_TestDataFactory.createResponse(questionnaire.id,questionCreate.id,'General Partnership');
        questionResponse.Given_Response_Value__c = 'General Partnership';
        if(questionResponse != NULL){
            update questionResponse;  
        }
        
        QnA_QuestionResponse__c questionResponse2 = QnA_TestDataFactory.createResponse(questionnaire.id,questionCreate2.id,'Woman Owned');
        questionResponse2.Given_Response_Value__c = 'Woman Owned';
        if(questionResponse2 != NULL){
            update questionResponse2;  
        }
        
        QnA_QuestionResponse__c questionResponse3 = QnA_TestDataFactory.createResponse(questionnaire.id,questionCreate3.id,'Test Business');
        questionResponse3.Given_Response_Value__c = 'Test business';
        if(questionResponse3 != NULL){
            update questionResponse3; 
        }
        
        Service__c service = new Service__c(
            Service_Title__c = SERVICE_TITLE,
            Level__c='Level 1',
            Language__c = 'en_US'
        );
        if(service != NULL){
            insert service;
        }
    }
    
    private static Map<String, GenerateChecklist.ResourceWrapper> getMapResourceWrapper() {
        Map<String, Checklist_Mapping__mdt> mappings = GenerateChecklist.getChecklistMapping();
        
        Map<String, GenerateChecklist.ResourceWrapper> mapTypeResWrapper = new Map<String, GenerateChecklist.ResourceWrapper>();
        mapTypeResWrapper.put(System.Label.Subsection_Id_Licenses, new GenerateChecklist.ResourceWrapper(mappings.get(System.Label.Subsection_Id_Licenses), SERVICE_TITLE,  System.Label.Answer_Element_Lightning_Input));
        mapTypeResWrapper.put(System.Label.Subsection_Id_Towns, new GenerateChecklist.ResourceWrapper(mappings.get(System.Label.Subsection_Id_Towns), 'Avon', System.Label.Answer_Element_Lightning_Input));
        mapTypeResWrapper.put(System.Label.Subsection_Id_Resources, new GenerateChecklist.ResourceWrapper(mappings.get(System.Label.Subsection_Id_Resources), 'No Group',  System.Label.Answer_Element_Lightning_Input));
        mapTypeResWrapper.put(System.Label.Subsection_Id_NAICS_Code, new GenerateChecklist.ResourceWrapper(mappings.get(System.Label.Subsection_Id_NAICS_Code), '('+NAICS_CODE+')',  System.Label.Answer_Element_Lightning_Input));
        
        for(GenerateChecklist.ResourceWrapper res :mapTypeResWrapper.values()) {
            res.listRecords = GenerateChecklist.getRecords(res, 'en_US');
            System.debug(res + ':' + res.listRecords);
        }                              
                              
        return mapTypeResWrapper;
    }
    
    @isTest
    private static void independentMappedChecklistMaster() {
        Questionnaire__c questionnaire = QnA_TestDataFactory.getQuestionnaire();
        
        Test.startTest();
        try{
            GenerateChecklist.Checklist checklist = GenerateChecklist.generateChecklistItem(questionnaire.id, 'en_US');    
            GenerateChecklist.Checklist checklistRegenerated = GenerateChecklist.generateChecklistItem(questionnaire.id, 'en_US'); 
            String json = 'JSON';
            GenerateChecklist.updateJson(questionnaire.id,json);
        }Catch(Exception e){
            System.assertNotEquals(Null, e);
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void parentChildChecklist() {
        Category__C categoryCreated=QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
        Questionnaire__c questionnaire = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        QnA_FrameworkQuestionVersion__c questionVersion=QnA_TestDataFactory.createQuestionVersion(System.today()-1);
        
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Are you registering a new business in Connecticut?',
            'Domestic|Foreign|I\'m not sure',
            null,null,null,null,false,null,null,null,
            'lightning:radioGroup','Employees'
        );
        
        QnA_FrameworkQuestion__c questionCreate2 = QnA_TestDataFactory.createQuestion(
            'Will your business be any of these less common legal structures?',
            'Sole Proprietorship|Limited Liability Company|Stock Corporation|Non-stock Corporation|Less common|I\'m not sure',
            null,null,null,null,false,null,null,null,
            'lightning:radioGroup','Employees'
        );
        
        QnA_FrameworkQuestion__c questionCreate3 = QnA_TestDataFactory.createQuestion(
            'What do you plan to name your business?',
            'E.g. Barb\'s Bakery',
            null,null,null,null,false,null,null,null,
            'Search Input','Employees'
        );
        
        TemplateChecklistItems__c templateCheckList = QnA_TestDataFactory.createTemplateCheckListItem(
            'Register your Limited Liability Company (LLC) with the Secretary of State.',
            'A business agent is a person or company that represents your business. This might be you! They\'re the person we contact with any news or updates.',
            'Business registration'
        );
        TemplateChecklistItems__c templateCheckList2 = QnA_TestDataFactory.createTemplateCheckListItem(
            'Check if your business name is available.',
            'Check with the State of Connecticut to make sure your business name is available for you to use. Please note your business name is subject to approval by the CT Secretary of State and may need to change.',
            'Business registration'
        );
        Checklist_Master__c  checklistMaster  = QnA_TestDataFactory.createChecklistMaster(
            'Register Domestic LLC with SOTS',templateCheckList.id,
            null,
            null
        );
        checklistMaster.Check_child_records__c = true;
        checklistMaster.Include_as_Static_Checklist_Item__c = true;
        if(checklistMaster != NULL){
            update checklistMaster;
        }
        Checklist_Master__c  childChecklistMaster1  = QnA_TestDataFactory.createChecklistMaster(
            'Domestic Response',null,
            questionCreate.id,
            'Domestic'
        );
        
        childChecklistMaster1.Checklist_Master_Parent__c = checklistMaster.id;
        if(childChecklistMaster1 != NULL){
            update childChecklistMaster1;  
        }
        
        Checklist_Master__c  childChecklistMaster2 = QnA_TestDataFactory.createChecklistMaster(
            'LLC Response',null,
            questionCreate2.id,
            'Limited Liability Company'
        );
        childChecklistMaster2.Checklist_Master_Parent__c = checklistMaster.id;
        if(childChecklistMaster2 != NULL){
            update childChecklistMaster2;
        }
        
        
        Checklist_Master__c  checklistMaster2  = QnA_TestDataFactory.createChecklistMaster(
            'Check availability',templateCheckList2.id,
            null,
            null);
        checklistMaster2.Check_child_records__c = true;
        if(checklistMaster2 != NULL){
            update checklistMaster2;
        }
        
        Checklist_Master__c  childChecklistMaster3  = QnA_TestDataFactory.createChecklistMaster(
            'Domestic Response',null,
            questionCreate.id,
            'Domestic'); 
        childChecklistMaster3.Checklist_Master_Parent__c = checklistMaster2.id;
        if(childChecklistMaster3 != NULL){
            update childChecklistMaster3;
        }
        
        
        Checklist_Master__c  childChecklistMaster4  = QnA_TestDataFactory.createChecklistMaster(
            'Business Name',null,
            questionCreate3.id,
            null);
        childChecklistMaster4.Checklist_Master_Parent__c = checklistMaster2.id;
        if(childChecklistMaster4 != NULL){
            update childChecklistMaster4;  
        }
        
        QnA_QuestionResponse__c questionResponse = QnA_TestDataFactory.createResponse(
            questionnaire.id,questionCreate.id,'General Partnership'
        );
        questionResponse.Given_Response_Value__c = 'Domestic';
        if(questionResponse != NULL){
            update questionResponse;
        }
        
        QnA_QuestionResponse__c questionResponse2 = QnA_TestDataFactory.createResponse(
            questionnaire.id,questionCreate2.id,'Woman Owned'
        );
        questionResponse2.Given_Response_Value__c = 'Limited Liability Company';
        if(questionResponse2 != NULL){
            update questionResponse2;
        }
        
        QnA_QuestionResponse__c questionResponse3 = QnA_TestDataFactory.createResponse(
            questionnaire.id,questionCreate3.id,'Test Business');
        questionResponse3.Given_Response_Value__c = 'Test business';
        if(questionResponse3 != NULL){
            update questionResponse3;   
        }
        
        Test.startTest();
        try{
             GenerateChecklist.generateChecklistItem(questionnaire.Id, 'en_US');
        }Catch(Exception e){
            System.assertNotEquals(Null, e);
        }
        Test.stopTest();
        
        System.assertEquals(QnA_TestDataFactory.getQuestionnaire().Status__c, 'Completed', 'Error');
    }
    
    @isTest
    private static void deleteCheckListTest(){
        Test.startTest();
        	Boolean checklistdeleted = GenerateChecklist.deleteCheckList(QnA_TestDataFactory.getQuestionnaire().Id);
        Test.stopTest();
        
        system.assert(checklistdeleted, 'Error');
    }
    
    @isTest
    private static void testDynamicData() {
        TemplateChecklistItems__c templateItem = [
            SELECT Id, Additional_Detail_Information__c, Checklist_Item_Name__c
			FROM TemplateChecklistItems__c
            LIMIT 1
        ];
        List<GenerateChecklist.DynamicData> listData = new List<GenerateChecklist.DynamicData>();
        
        Municipality_Information__mdt town = [
            SELECT Id, City_Town__c, City_Town_2__c, StreetAddress__c, State__c, Zip_Code__c, Phone_Number__c, Municipality_URL__c, External_or_Internal_URL__c
            FROM Municipality_Information__mdt
            WHERE City_Town__c = 'Avon'
            LIMIT 1
        ];
        Category__c naics = [
            SELECT Id, Title__c, Parent_Category__c, Code__c,
            	Parent_Category__r.Parent_Category__r.Parent_Category__r.Title__c, Parent_Category__r.Parent_Category__r.Parent_Category__r.Code__c
            FROM Category__c
           	LIMIT 1
        ];
        Service__c service = [
            SELECT Id, Licenses_Details__c
            FROM Service__c
            LIMIT 1
        ];
        
        Test.startTest();
        	listData.add(GenerateChecklist.DynamicData.getInstance(town));
        	listData.add(GenerateChecklist.DynamicData.getInstance(naics));
        	listData.add(GenerateChecklist.DynamicData.getInstance(service));
        	
        	GenerateChecklist.TemplateChecklist template = new GenerateChecklist.TemplateChecklist(listData, templateItem);
        Test.stopTest();
    }
    
    @isTest
    private static void exceptionalTestCaseforOption(){
        try{
            QnA_QuestionResponse__c responseRec = QnA_TestDataFactory.getQuestionResponse();
            responseRec.Given_Response_Value__c = 'Invalid Question Option';
            if(responseRec != NULL){
                update responseRec;
            }
            Test.startTest();
            GenerateChecklist.generateChecklistItem(responseRec.Questionnaire__c, 'en_US');
            Test.stopTest();
        }
        catch(exception e){
            System.assertNotEquals(Null, e);
        }
    }
    
    @isTest
    private static void exceptionalTestCaseforRequired(){
        try{
            
            QnA_QuestionResponse__c responseRec = QnA_TestDataFactory.getQuestionResponse();
            QnA_FrameworkQuestion__c question = [SELECT Id,Required__c FROM QnA_FrameworkQuestion__c WHERE Id =: responseRec.Question__c];
            question.Required__c = true;
            if(question != NULL){
                update question;  
            }
            
            responseRec.Given_Response_Value__c = NULL;
            if(responseRec != NULL){
                update responseRec;  
            }
            
            Test.startTest();
            GenerateChecklist.generateChecklistItem(responseRec.Questionnaire__c, 'en_US');
            GenerateChecklist.createnewClonedApplication(responseRec.Questionnaire__c);

            Test.stopTest();
        }
        catch(exception e){
            System.assertEquals(e.getMessage().contains('Script-thrown exception'), true, 'Error');
        }
    }
	
    @isTest
    private static void test_services(){
        List<String> serviceSelected = new List<String>();
		Set<String> licenseDetailSet = new Set<String>();
        serviceSelected.add('Beverage');
        Test.startTest();
        Service__c service = new Service__c(Service_Title__c='Beverage',Level__c='Level 1',Licenses_Details__c='ABC');
        insert service;
        System.assertNotEquals(null, service, 'Service not null');
        //Map<Id,Service__c> newmap = GenerateChecklist.getService(serviceSelected,licenseDetailSet,licenseDetailSet);
        Test.stopTest();
        //System.assertNotEquals(Null, newmap);
    }
    
    @isTest
    private static void testNoLanguage() {
        Test.startTest();
        	GenerateChecklist.generateChecklistItem(null, null);
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateTask() {
        Questionnaire__c questionnaire = QnA_TestDataFactory.getQuestionnaire();
        Map<Id, TemplateChecklistItems__c> mapTemplateChecklistItem = new Map<Id, TemplateChecklistItems__c>([
            SELECT Id, Checklist_Item_Name__c, Additional_Detail_Information__c
            FROM TemplateChecklistItems__c
        ]);
        Map<String, GenerateChecklist.ResourceWrapper> mapTypeResWrapper = getMapResourceWrapper();
        
        Test.startTest();
        	GenerateChecklist.createTask(questionnaire.Id, mapTemplateChecklistItem, mapTypeResWrapper);
            GenerateChecklist.createnewClonedApplication(questionnaire.Id);
        Test.stopTest();
    }
    @isTest
    private static void testCreateTask1() {
        Questionnaire__c questionnaire = QnA_TestDataFactory.getQuestionnaire();
        Map<Id, TemplateChecklistItems__c> mapTemplateChecklistItem = new Map<Id, TemplateChecklistItems__c>([
            SELECT Id, Checklist_Item_Name__c, Additional_Detail_Information__c
            FROM TemplateChecklistItems__c where Checklist_Category__c = 'Licenses'
        ]);
        Map<String, GenerateChecklist.ResourceWrapper> mapTypeResWrapper = getMapResourceWrapper();
        
        Test.startTest();
        	GenerateChecklist.createTask(questionnaire.Id, mapTemplateChecklistItem, mapTypeResWrapper);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetMapResources() {
        
        
        Test.startTest();
        	GenerateChecklist.getMapResources('', new List<sObject>());
        Test.stopTest();
    }
    
    @isTest
    private static void testgetTemplateChecklist() {
        GenerateChecklist.ResourceWrapper res = getMapResourceWrapper().get('Towns');
        TemplateChecklistItems__c templateItem = [
            SELECT Id, Checklist_Item_Name__c, Additional_Detail_Information__c
			FROM TemplateChecklistItems__c
            LIMIT 1
        ];
        
        Test.startTest();
        	GenerateChecklist.getTemplateChecklist(res, templateItem);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetChecklistResources() {
        GenerateChecklist.ResourceWrapper res = getMapResourceWrapper().get('Resources');
        TemplateChecklistItems__c templateItem = [
            SELECT Id, Additional_Detail_Information__c, Checklist_Item_Name__c
			FROM TemplateChecklistItems__c
            LIMIT 1
        ];
        
        Test.startTest();
        	GenerateChecklist.getChecklistResources(res, templateItem);
        Test.stopTest();
    }
	@isTest
    private static void validateChecklistItemAccess_TrueTest(){
        Account ac = [SELECT id FROM Account WHERE Name ='Grazitti' LIMIT 1];
        Contact con = [SELECT id, Name FROM Contact WHERE LastName ='testCon' LIMIT 1];
        Test.startTest();
        User objUser = [SELECT id, username, email FROM User WHERE username = 'tester@noemail.comtesting' LIMIT 1];
        Questionnaire__c objQuestionnaire = [SELECT id, Status__c FROM Questionnaire__c LIMIT 1];
        objQuestionnaire.Contact__c = con.id;
        update objQuestionnaire;
        
        System.runAs(objUser)
        {
            Boolean returnVal = GenerateChecklist.validateChecklistItemAccess(objQuestionnaire.Id);
        	System.assertEquals(true, returnVal);
        }
        Test.stopTest();
    }
    @isTest
    private static void validateChecklistItemAccess_FalseTest(){
        Account ac = [SELECT id FROM Account WHERE Name ='Grazitti' LIMIT 1];
        Contact con = [SELECT id, Name FROM Contact WHERE LastName ='testCon123' LIMIT 1];
        Test.startTest();
        User objUser = [SELECT id, username, email FROM User WHERE username = 'tester@noemail.comtesting' LIMIT 1];
        Questionnaire__c objQuestionnaire = [SELECT id, Status__c FROM Questionnaire__c LIMIT 1];
        objQuestionnaire.Contact__c = con.id;
        update objQuestionnaire;
        
        System.runAs(objUser)
        {
            Boolean returnVal = GenerateChecklist.validateChecklistItemAccess(objQuestionnaire.Id);
        	System.assertEquals(false, returnVal);
        }
        Test.stopTest();
    }
    @isTest
    private static void getNaicsRelatedTemplate_Test(){
        TemplateChecklistItems__c objTCIRetrieved = [SELECT id, Checklist_Item_Name__c, Additional_Detail_Information__c, NAICS_Code_Category__c, Language__c FROM TemplateChecklistItems__c WHERE Checklist_Item_Name__c='Check if your business name is available.' LIMIT 1];
        objTCIRetrieved.NAICS_Code_Category__c = 'DEEP';
        update objTCIRetrieved;
        Test.startTest();
        TemplateChecklistItems__c objTCI = GenerateChecklist.getNaicsRelatedTemplate('DEEP', 'en_US');
        System.assertEquals(objTCIRetrieved.Checklist_Item_Name__c, objTCI.Checklist_Item_Name__c);
        
        Test.stopTest();
    }
    @isTest
    private static void getNaicsRelatedTemplateNull_Test(){
        TemplateChecklistItems__c objTCIRetrieved = [SELECT id, Checklist_Item_Name__c, Additional_Detail_Information__c, NAICS_Code_Category__c, Language__c FROM TemplateChecklistItems__c WHERE Checklist_Item_Name__c='Check if your business name is available.' LIMIT 1];
        Test.startTest();
        TemplateChecklistItems__c objTCI = GenerateChecklist.getNaicsRelatedTemplate('DEEP', 'en_US');
        System.assertEquals(null, objTCI);
        Test.stopTest();
    }
}