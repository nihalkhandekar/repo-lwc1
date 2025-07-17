/*********************************************************************************************
* NAME:  BOS_SendResourceNotification_Test
* DESCRIPTION: Test class for BOS_SendResourceNotification
*
* MODIFICATION LOG:
* DEVELOPER                 DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Himanshi Mayal           4/6/21                    Test class for BOS_SendResourceNotification
*********************************************************************************************/
@isTest
public class BOS_SendResourceNotification_Test {
	public static Knowledge__kav kw;
    public static Knowledge__kav kw2;
    public static void testData(){
        Account ac1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='test123',
            Status__c = System.Label.ACTIVE
        );
        insert ac1;
        Contact con = new Contact(LastName ='testCon1',Email='abcd@gmail.com',AccountId = ac1.Id,Due_date_reminders_email_notification__c=true,Resource_Email_Notification__c=true, Resource_SMS_Notification__c=true);
        insert con;
        Contact con2 = new Contact(LastName ='testCon1123',Email='abcdspanish@gmail.com',AccountId = ac1.Id,Due_date_reminders_email_notification__c=true,Resource_Email_Notification__c=true, Resource_SMS_Notification__c=true);
        insert con2;
        Id profileId = [SELECT ID FROM Profile WHERE NAME ='CT Community User'].id;
        User user = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='tester123@noemail.com'
        );
        insert user;
        User user2 = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='es',
            localesidkey='es', profileid = profileId, 
            country='United States',IsActive =true,
            ContactId = con2.Id, timezonesidkey='America/Los_Angeles', 
            username='tester123Spanish@noemail.com'
        );
        insert user2;
        Integer days = Integer.ValueOf(Label.rcNotificationDay);
        Date dateValue = System.today().addDays(days); 
        
        Id p = [select id from profile where name='System Administrator'].id;
        User TestUser = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(TestUser){
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        kw = new Knowledge__kav();
        kw.title = 'Test';
        kw.UrlName = 'test';
        kw.Language='en_US';
        kw.Selected_Featured_Resource__c=true;
        kw.Resource_Type__c='Resource';
        kw.RecordTypeID=BOSKnowledgeRecordTypeId;
        kw.NAICS_Code__c = '72';
        kw.Identified_Group__c = 'Woman Owned';
        kw.Resource_Title_URL__c='www.yutube.com.ss';
        kw.Summary='Summary';
        insert kw;
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        
        kw2 = new Knowledge__kav();
        kw2.title = 'Test2';
        kw2.UrlName = 'test2';
        kw2.Language='es';
        kw2.Selected_Featured_Resource__c=true;
        kw2.Resource_Type__c='Resource';
        kw2.RecordTypeID=BOSKnowledgeRecordTypeId;
        kw.NAICS_Code__c = '72';
        kw.Identified_Group__c = 'Veteran Owned';
        kw.Resource_Title_URL__c='www.yutube.com.ss';
        kw.Summary='Summary';
        insert kw2;
        }
        
        Category__c category = QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
        Questionnaire__c quest = new Questionnaire__c(Category__c=category.Id,status__c='Completed', Contact__c=con.id);
        insert quest;
        
        Questionnaire__c quest_Spanish = new Questionnaire__c(Category__c=category.Id,status__c='Completed', Contact__c=con2.id, Language__c='es');
        insert quest_Spanish;
        
        List<QnA_FrameworkQuestion__c> listFrameworkQuestions = new List<QnA_FrameworkQuestion__c>();
 
          QnA_FrameworkQuestion__c equestionCreate = QnA_TestDataFactory.createQuestion(
            'this i english version question ', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Employees');
       
        
        QnA_FrameworkQuestion__c questionCreate = QnA_TestDataFactory.createQuestion(
            'Are you registering new business in Connecticut?', 
            'Yes|No', null, null, 1, 'Active',true,'File',null,'Text','lightning:radioGroup','Employees');
        questionCreate.Question_Heading_Help_Text__c = 'Default';
        questionCreate.Question_Help_Text_Notes__c = 'Default';
        questionCreate.Subsection_Help_Text_Static__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_Label__c = 'Default';
        questionCreate.Subsection_Help_Text_Link_URL__c = 'Default';
       questionCreate.English_Version__c = equestionCreate.id;
        listFrameworkQuestions.add(questionCreate);
       
        System.debug('listFrameworkQuestions.size() ->  '+listFrameworkQuestions.size());
        if(listFrameworkQuestions.size() < 4){
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
            listFrameworkQuestions.get(3).Language__c = 'es';
        }
        upsert listFrameworkQuestions;
		
        QnA_TestDataFactory.createOption(questionCreate.id, 'test1', 'test1',1);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test2', 'test2',2);
	    QnA_TestDataFactory.createOption(questionCreate.id, 'test3', 'test3',3);
		
        List<QnA_QuestionResponse__c> response = new List<QnA_QuestionResponse__c>();
        if(listFrameworkQuestions.size() >= 4){
            response.add(QnA_TestDataFactory.createResponse(quest.Id, listFrameworkQuestions.get(0).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(quest.Id, listFrameworkQuestions.get(1).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(quest.Id, listFrameworkQuestions.get(2).Id, 'Yes'));
            response.add(QnA_TestDataFactory.createResponse(quest_Spanish.Id, listFrameworkQuestions.get(3).Id, 'Yes')); 
        }
		if(response!=null && response.size()>0){
            response[0].Given_Response_Value__c ='Minority Owned';
            response[1].Given_Response_Value__c ='Woman Owned';
            response[2].Given_Response_Value__c ='LGBTQI Owned';
            response[3].Given_Response_Value__c ='Veteran Owned';
			update response;
		}
        
        
        Topic t = new Topic();
        String networkID = [Select Id from Network where Name = 'business'].Id;
        t.Name ='service members';
        t.NetworkId = networkID;
        insert t;
        
        TopicAssignment tA = new TopicAssignment();
        tA.EntityId = kw.id;
        tA.NetworkId = networkID;
        tA.TopicId = t.id;
        insert tA;
        Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
        kdc.DataCategoryGroupName = 'Business';
        kdc.DataCategoryName = 'Starting_my_business';
        kdc.ParentId = kw.id;
        insert kdc;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Res2';
        cv.Description = 'Res2';
        cv.VersionData = Blob.valueOf('Unit Test ContentVersion Body');
        cv.PathOnClient = 'Res 2.jpg';
        cv.FirstPublishLocationId  = kw.id;
        insert cv;
        
        ContentDistribution cvd = new ContentDistribution( 
            Name = 'test', 
            ContentVersionId = cv.id, 
            PreferencesAllowOriginalDownload = true, 
            PreferencesAllowViewInBrowser = true, 
            PreferencesNotifyOnVisit = false 
        );
        //insert cvd;
        
    }
    @isTest
    private static void BOS_SendResourceNotification_LangEN_US_Test(){
        Test.startTest();
        testData();
        Id acID = [Select id, Name From Account LIMIT 1].id;
        List<OrgWideEmailAddress> owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address = 'do-not-reply-business@notifications.ct.gov' limit 1];		
		Knowledge__kav kw_1 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        Knowledge__kav kw_2 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];  
        List<Contact> lstCon = [SELECT ID, Name ,(select Id, LanguageLocaleKey from Users), Resource_Email_Notification__c, Email, FirstName, Resource_SMS_Notification__c, Phone FROM Contact];
        List<Questionnaire__c> lstQuest = [SELECT Id, Category__r.Code__c,(SELECT Given_Response_Value__c FROM QA_Question_Responses__r WHERE Question_Summary__c = 'Identified Groups') FROM Questionnaire__c WHERE Status__c = 'Completed'];
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<Knowledge__kav> KavList = new List<Knowledge__kav>();
        KavList.add(kw_1);
        KavList.add(kw_2);
        BOS_SendResourceNotification batchInstance = new BOS_SendResourceNotification(String.valueOf(acID));
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, lstCon);
        batchInstance.finish(BC); 
        Test.stopTest();
    }
    /*@isTest
    private static void BOS_SendResourceNotification_Schedule_Test(){
        Test.startTest();
        testData();
        Id acID = [Select id, Name From Account LIMIT 1].id;
        List<OrgWideEmailAddress> owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address = 'do-not-reply-business@notifications.ct.gov' limit 1];		
		Knowledge__kav kw_1 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        Knowledge__kav kw_2 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];  
        List<Contact> lstCon = [SELECT ID, Name ,(select Id, LanguageLocaleKey from Users), Resource_Email_Notification__c, Email, FirstName, Resource_SMS_Notification__c, Phone FROM Contact];
        List<Questionnaire__c> lstQuest = [SELECT Id, Category__r.Code__c,(SELECT Given_Response_Value__c FROM QA_Question_Responses__r WHERE Question_Summary__c = 'Identified Groups') FROM Questionnaire__c WHERE Status__c = 'Completed'];
        
        try{
        	BOS_SendResourceNotification scheduler = new BOS_SendResourceNotification(String.valueOf(acID));
            String sch = '0 0 23 * * ?';
            system.schedule('Test BOS_SendResourceNotification', sch, scheduler);
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }*/
    @isTest
    private static void BOS_SendResourceNotificationScheduler_Test(){
        Test.startTest();
        testData();
        try{
			List<Contact> con = [Select ID,Resource_Email_Notification__c,Resource_SMS_Notification__c from Contact where LastName ='testCon1123'];
            if(con != Null && con.Size()>0){
				con[0].Resource_Email_Notification__c=false;
				con[0].Resource_SMS_Notification__c=false;
				update con;
			}
        	BOS_SendResourceNotificationScheduler scheduler = new BOS_SendResourceNotificationScheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test BOS_SendResourceNotificationScheduler', sch, scheduler);
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
}