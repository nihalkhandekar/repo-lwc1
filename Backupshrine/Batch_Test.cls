//Shreya | 1/6/20
@isTest
private class Batch_Test {
    private static final String JOB_NAME = 'Delete_Questionnaires';
    private static final String SCHEDULER = '20 30 8 10 2 ?';
    private static final String QUERY = 'SELECT Id, Status__c '
        +'FROM Questionnaire__c '
        +'where Status__c=\'In Progress\''
        +' and Contact__c=\'\''
        +' and LastModifiedDate =today';
    
    @testSetup 
    private static void initData() {
        Category__C categoryCreated = QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
        Questionnaire__c quest = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id, 'In Progress');
    }
    
    @isTest
    private static void testDeleteBatch() {
        Test.startTest();
            DataBase.executeBatch(new BatchDelete(QUERY, System.Label.Batch_Delete,JOB_NAME, null));
        Test.stopTest();
        
        List<Questionnaire__c> listQuestionnaires = (List<Questionnaire__c>) Database.query(QUERY);
        System.assertEquals(0, listQuestionnaires.size(),'Deleted');
    }
    
    @isTest
    private static void testUpdateBatch() {
        List<Update_Job_Configuration__mdt> updateConfigList = new List<Update_Job_Configuration__mdt>();
        
        Job_Configuration__mdt jobConfigUpdate = new Job_Configuration__mdt();
        jobConfigUpdate.MasterLabel = 'Update Questionnaires';
        jobConfigUpdate.DeveloperName = 'Update_Questionnaires';
        jobConfigUpdate.Active__c=true;
        jobConfigUpdate.Batch_Size__c=100;
        jobConfigUpdate.Query__c=query;
        jobConfigUpdate.Job_Operation__c='Update';
        
        Update_Job_Configuration__mdt updateConfig = new Update_Job_Configuration__mdt();
        updateConfig.Field_API_Name__c = 'Business_Name__c';
        updateConfig.Field_Value__c = 'Test Class Business';
        updateConfig.Job_Configuration__c = jobConfigUpdate.Id;
        updateConfigList.add(updateConfig);
        
        Test.startTest();
            DataBase.executeBatch(new BatchDelete(QUERY, System.Label.Batch_Update,JOB_NAME, updateConfigList));
        Test.stopTest();
        
        Questionnaire__c checkQuestionnaire = [
            SELECT Id,Business_Name__c, Status__c 
            FROM Questionnaire__c 
            WHERE Status__c = 'In Progress' 
            	AND Contact__c = '' 
            	AND LastModifiedDate = today
        ];
        
        System.assertNotEquals('', checkQuestionnaire.Business_Name__c,'Business Name Updated');
        System.assertEquals('Test Class Business', checkQuestionnaire.Business_Name__c, 'Business Name Updated');
    }
    
    @isTest
    private static void testDeleteScheduler() {
        Test.startTest();
    		Id jobId = System.schedule('TestScheduler', SCHEDULER, new Batch_Scheduler(JOB_NAME));
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduler did not run');
    }
    
    @isTest
    private static void testUpdateScheduler() {
        Test.startTest();
        	Id jobId = System.schedule('TestScheduler', SCHEDULER, new Batch_Scheduler(JOB_NAME));
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduler did not run');
    }
}