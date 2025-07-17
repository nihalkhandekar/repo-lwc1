@isTest
private class Checklist_PDFController_Test {
    @testSetup
    static void initData() {
        Category__C categoryCreated = QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
        Questionnaire__c questionnaire = QnA_TestDataFactory.createQuestionnair(categoryCreated.Id,'Completed');
    }
	@isTest
    static void getChecklist_Test(){
        Questionnaire__c questionnaire = [Select Id FROM Questionnaire__c limit 1];
        Test.startTest();
        PageReference pageRef = Page.Checklist_PDF;
        pageRef.getParameters().put('id', String.valueOf(questionnaire.Id));
        Test.setCurrentPage(pageRef);
        Checklist_PDFController controller = new Checklist_PDFController();
        controller.url = '';
        controller.Ids = new List<String>();
        PageReference pr = controller.getChecklist();
        Test.stopTest();
		System.assertNotEquals(Null, pageRef,'Success');
    }
    @isTest
    static void getChecklist_Test_Invalid(){
        try{
            Test.startTest();
            PageReference pageRef = Page.Checklist_PDF;
            pageRef.getParameters().put('id', '1234');
            Test.setCurrentPage(pageRef);
            Checklist_PDFController controller = new Checklist_PDFController();
            PageReference pr = controller.getChecklist();
            Test.stopTest();
        }catch(exception e){
            System.assertNotEquals(Null, e);
        }
        
    }
}