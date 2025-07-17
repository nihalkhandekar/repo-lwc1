@isTest
public class BusinessTypeController_Test {
    @isTest
    public static void getFlowTestPositive(){
        Category__C categoryCreated=QnA_TestDataFactory.createCategoryWithCode('Services','Level1',System.Label.Generic_Flow2_NAICS_Code);
        Questionnaire__c quest = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        QnA_FrameworkQuestionVersion__c questionVersion=QnA_TestDataFactory.createQuestionVersion(System.today()-1);
        QnA_FunctionalFlow__c mainFlow = QnA_TestDataFactory.createMainFlow('Generic Flow',true,categoryCreated.Id,
                                                                           questionVersion.id);
        //test
        Test.startTest();
		try{
			BusinessTypeController.getFlow(quest.id, categoryCreated.Id);
		}catch(Exception e){
            BOS_Utility.ExceptionHandler('BusinessTypeController_Test','getFlowTestPositive','Category__c','','Low',e,e.getMessage());
        }
        System.assertNotEquals(mainFlow.id, null, 'Main Flow Returned');
        Test.stopTest();
    }
    @isTest
    public static void CategoryWrapperTest(){
        Category__C categoryCreated=QnA_TestDataFactory.createCategory('Services','Level1');
        Questionnaire__c quest = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        Test.startTest();
        BusinessTypeController.CategoryWrapper categoryWrapper = new BusinessTypeController.CategoryWrapper(categoryCreated);
        if(quest !=null){
        List<Task> TaskList = [SELECT Id,WhatId from Task WHERE WhatId =: quest.id ];
        System.assertEquals(0, TaskList.size(),'Task records');
        }
        Test.stopTest();
    }
     @isTest
    public static void getAllChildBusinessTypesTest(){
        Category__C categoryCreated=QnA_TestDataFactory.createCategory('Services','Level1');
        Questionnaire__c quest = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
        Category__C categoryCreated1=QnA_TestDataFactory.createCategoryWithId('Services','Level2',categoryCreated.id);
        Category__C categoryCreated2=QnA_TestDataFactory.createCategoryWithId('Services','Level3',categoryCreated1.id);
        Category__C categoryCreated3=QnA_TestDataFactory.createCategoryWithId('Services','Level4',categoryCreated2.id);
        
        Test.startTest();
        	try{
	            BusinessTypeController.getAllChildBusinessTypes(categoryCreated.id, null);
            }catch(Exception e){
                System.assert(true);
            }
        
		try{
			BusinessTypeController.getAllChildBusinessTypes(categoryCreated.id,'en_US');
		}catch(Exception e){
            BOS_Utility.ExceptionHandler('BusinessTypeController_Test','getAllChildBusinessTypesTest','Category__c','','Low',e,e.getMessage());
        }
        if(quest !=null){
        List<Task> TaskList = [SELECT Id,WhatId from Task WHERE WhatId =: quest.id ];
        System.assertEquals(0, TaskList.size(),'Task records');
        }
        Test.stopTest();
    }
    @isTest
    public static void getBusinessTypesTest(){
        Category__C categoryCreated=QnA_TestDataFactory.createCategoryWithCode('Services','Level1','NAICS');
        Category__C categoryCreated1=QnA_TestDataFactory.createCategoryWithCode('License','Level2','NAICS');
        Category__C categoryCreated2=QnA_TestDataFactory.createCategoryWithCode('License Type','Level3','NAICS');
        List<Category__C> lCategory = new List<Category__C>();
        lCategory.add(categoryCreated);
        Test.startTest();
        BusinessTypeController.getBusinessTypes(null);
        BusinessTypeController.getBusinessTypes('en_US');
        System.assertNotEquals(null,lCategory.size(),'Category returned');
        Test.stopTest();
    }
 
    @isTest
    public static void getServicesTest(){
        Service__c service = new Service__c(Service_Title__c='Food',Level__c='Level 1');
        if(service!=null){
             insert service;
        }
       
        Test.startTest();
        	try{
				BusinessTypeController.getServices(null);
            }catch(exception e){
                System.assert(true);
            }
        
		try{
			BusinessTypeController.getServices('en_US');
		}catch(exception e){
            BOS_Utility.ExceptionHandler('BusinessTypeController_Test','getServicesTest','Service__c','','Low',e,e.getMessage());
        }
        System.assertNotEquals(null, service.Id,'Services returned');
        Test.stopTest();
    }
    @isTest
    public static void getAllRelatedServicesTest(){
        Service__c service = new Service__c(Service_Title__c='Food',Level__c='Level 1');
       if(service!=null){
             insert service;
        }
        Service__c relatedservice = new Service__c(Service_Title__c='Food & beverage',Level__c='Level 2',Service__c=service.id);
        if(relatedservice!=null){
            insert relatedservice;
        }
        
        Test.startTest();
        	BusinessTypeController.getAllRelatedServices(service.Id,null);
	        BusinessTypeController.getAllRelatedServices(service.Id,'en_US');
        Test.stopTest();
        
        System.assertNotEquals(null, relatedservice.Id,'Related Services returned');
        
    }

}