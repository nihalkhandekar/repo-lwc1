/*********************************************************************************************
* NAME:  BOS_Topics
* DESCRIPTION: Resource Center | Recommended Topics
*
* MODIFICATION LOG:
* DEVELOPER                 DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                    1/6/21                             Recommended Topics
*********************************************************************************************/
@isTest
private class BOS_Topics_Test {

    @IsTest(SeeAllData=true)
    private static void getRecommendedTopics_Test(){
        Test.startTest();
           knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',urlname='xyz');
        insert newArticle;

        Id businessId = [
            SELECT Id 
            FROM Network 
            WHERE Name = :System.Label.ActionItem_AccountRecordType
        ].Id;

        topic newTopic = new topic(NetworkId = businessId, name = 'test');
      	insert newTopic;
             
        TopicAssignment newTopicAssignment = new TopicAssignment(EntityId = newArticle.Id, TopicId = newTopic.Id);
        insert newTopicAssignment;
        
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
         Knowledge__kav kw = new Knowledge__kav();
        kw.title = 'Business';
        kw.UrlName = 'test';
        kw.Language='en_US';
        kw.Selected_Featured_Resource__c=true;
        kw.Resource_Type__c='Resource';
        kw.RecordTypeID=BOSKnowledgeRecordTypeId;
        kw.IsVisibleInPkb=True; 
        kw.IsVisibleInCsp=True; 
        kw.IsVisibleInPrm=True;
        insert kw;
        Map<Account,List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        List<Contact> cons = AccountsVsContacts.values().get(0);
        Id p = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(user){
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        }
        
        String cid=    [Select Id from Network where Name = 'business'].Id;
        ConnectApi.KnowledgeArticleVersionCollection testPage = new ConnectApi.KnowledgeArticleVersionCollection();
        List<ConnectApi.KnowledgeArticleVersion> testItemList = new List<ConnectApi.KnowledgeArticleVersion>();
        testItemList.add(new ConnectApi.KnowledgeArticleVersion());
        testItemList.add(new ConnectApi.KnowledgeArticleVersion());      
        testPage.items = testItemList;
        ConnectApi.Knowledge.setTestGetTrendingArticles(cid, 25, testPage);
        
        Category__c category1 = QnA_TestDataFactory.createCategory('Category 1', 'Level1');
        Questionnaire__c newQuestionnaire = (QnA_TestDataFactory.createQuestionnair(category1.Id, System.Label.Questionnaire_Status_Update));
        newQuestionnaire.contact__c = cons[0].Id;
        update newQuestionnaire;
         List<QnA_FrameworkQuestion__c> listFrameworkQuestions = new List<QnA_FrameworkQuestion__c>();
 
        QnA_FrameworkQuestion__c equestionCreate = QnA_TestDataFactory.createQuestion(
            'this i english version question ', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Identified Groups');
       
        
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Are you registering new business in Connecticut?', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Identified Groups');
        questionCreate.Question_Heading_Help_Text__c = 'Default';
        questionCreate.Question_Help_Text_Notes__c = 'Default';
        questionCreate.Subsection_Help_Text_Static__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_Label__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_URL__c = 'Default';
       questionCreate.English_Version__c = equestionCreate.id;
        listFrameworkQuestions.add(questionCreate);
       
        
        if(listFrameworkQuestions.size() >= 4){
            QnA_FrameworkQuestion__c questionCreate1 =QnA_TestDataFactory.createQuestion(
                'What is the Legal structure of your business?','Yes|No', listFrameworkQuestions.get(0).Id,
                'Yes',2,'Active',true,'File','Yes','Text','lightning:radioGroup','Identified Groups');
       questionCreate1.English_Version__c = questionCreate.id;
            
            listFrameworkQuestions.add(questionCreate1);
            listFrameworkQuestions.add(QnA_TestDataFactory.createQuestion(
                'Do you have "General Liability Insurance?','Yes|No', listFrameworkQuestions.get(1).Id,
                'Yes',3,'Active',true,'File','Yes','Text','lightning:radioGroup','Identified Groups'));
            listFrameworkQuestions.add(QnA_TestDataFactory.createQuestion(
                'Do you have Employees','Yes|No', listFrameworkQuestions.get(2).Id,'Yes',4,'Active',
                true,'File','Yes','Text','lightning:radioGroup','Identified Groups'));
            listFrameworkQuestions.get(3).QuestionBody__c = 'Do you have Employees??';
        }
        upsert listFrameworkQuestions;
		
        QnA_TestDataFactory.createOption(questionCreate.id, 'test1', 'test1',1);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test2', 'test2',2);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test3', 'test3',3);
		
        List<QnA_QuestionResponse__c> response = new List<QnA_QuestionResponse__c>();
        if(listFrameworkQuestions.size() >= 4){
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(0).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(1).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(2).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(3).Id, 'Yes')); 
        }
        system.runAs(user){
                try {
                    String result = BOS_Topics.getRecommendedTopics();
                } catch(Exception e){}
            Test.stopTest();
            
        }
    }
    @isTest
    private static void getRecommendationsFromQuestionnare_Test(){
        Category__c category1 = QnA_TestDataFactory.createCategory('Category 1', 'Level1');
        Account ac1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='test123',
            Status__c = System.Label.ACTIVE
        );
        insert ac1;
        Contact con = new Contact(LastName ='testCon1',Email='abcd@gmail.com',AccountId = ac1.Id,Due_date_reminders_email_notification__c=true);
        insert con;
     
        Questionnaire__c newQuestionnaire = (QnA_TestDataFactory.createQuestionnair(category1.Id, System.Label.Questionnaire_Status_Update));
        newQuestionnaire.contact__c = con.Id;
        update newQuestionnaire;
        Id profileID = [SELECT ID FROM Profile WHERE NAME ='CT Community User'].id;
        User objUser = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileID, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.comtesting', UserPermissionsKnowledgeUser=True
        );
        insert objUser;
        
        List<QnA_FrameworkQuestion__c> listFrameworkQuestions = new List<QnA_FrameworkQuestion__c>();
 
        QnA_FrameworkQuestion__c equestionCreate = QnA_TestDataFactory.createQuestion(
            'this i english version question ', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Identified Groups');
       
        
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Are you registering new business in Connecticut?', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Identified Groups');
        questionCreate.Question_Heading_Help_Text__c = 'Default';
        questionCreate.Question_Help_Text_Notes__c = 'Default';
        questionCreate.Subsection_Help_Text_Static__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_Label__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_URL__c = 'Default';
       questionCreate.English_Version__c = equestionCreate.id;
        listFrameworkQuestions.add(questionCreate);
       
        
        if(listFrameworkQuestions.size() >= 4){
            QnA_FrameworkQuestion__c questionCreate1 =QnA_TestDataFactory.createQuestion(
                'What is the Legal structure of your business?','Yes|No', listFrameworkQuestions.get(0).Id,
                'Yes',2,'Active',true,'File','Yes','Text','lightning:radioGroup','Identified Groups');
       questionCreate1.English_Version__c = questionCreate.id;
            
            listFrameworkQuestions.add(questionCreate1);
            listFrameworkQuestions.add(QnA_TestDataFactory.createQuestion(
                'Do you have "General Liability Insurance?','Yes|No', listFrameworkQuestions.get(1).Id,
                'Yes',3,'Active',true,'File','Yes','Text','lightning:radioGroup','Identified Groups'));
            listFrameworkQuestions.add(QnA_TestDataFactory.createQuestion(
                'Do you have Employees','Yes|No', listFrameworkQuestions.get(2).Id,'Yes',4,'Active',
                true,'File','Yes','Text','lightning:radioGroup','Identified Groups'));
            listFrameworkQuestions.get(3).QuestionBody__c = 'Do you have Employees??';
        }
        upsert listFrameworkQuestions;
		
        QnA_TestDataFactory.createOption(questionCreate.id, 'test1', 'test1',1);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test2', 'test2',2);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test3', 'test3',3);
		
        List<QnA_QuestionResponse__c> response = new List<QnA_QuestionResponse__c>();
        if(listFrameworkQuestions.size() >= 4){
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(0).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(1).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(2).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(newQuestionnaire.Id, listFrameworkQuestions.get(3).Id, 'Yes')); 
        }
        test.startTest();
         	try {
                System.runAs(objUser){
                    String result = BOS_Topics.getRecommendedTopics();
                }
                } catch(Exception e){}
            Test.stopTest();
    }
}