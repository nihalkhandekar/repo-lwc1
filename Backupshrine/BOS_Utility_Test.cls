//Shreya | 1/6/20
@isTest
private class BOS_Utility_Test {
    private class ApplicationException extends Exception {}
    
    @isTest
    private static void testExceptionHandlerTest(){
        Map<String, Object> mapErrorInfo;
        
        Test.startTest();
        try{
            throw new ApplicationException('This is bad');
        }catch(Exception e){
            mapErrorInfo = BOS_Utility.ExceptionHandler('QnA_Constants','QnA_Constants','service__c','abcd','Critical',e,'Additional info');
      BOS_Utility.handleException(e);
        }
        
        System.assertNotEquals(null, mapErrorInfo,'mapErrorInfo returned');
        
        try{
            throw new System.DmlException('DML Exception');
        }catch(Exception e){
            BOS_Utility.ExceptionHandlerLWC('QnA_Constants','QnA_Constants','service__c','abcd','Critical',e.getMessage());
        }
        
        Interface_Configuration__mdt interfaceConfig = BOS_Utility.fetchInterfaceConfig('Login Page');
        System.assertNotEquals(null, interfaceConfig,'interfaceConfig returned');
        Boolean isLoggedIn=true;
        try{
            isLoggedIn = BOS_Utility.checkUserLoggedIn();

        System.assertEquals(true, isLoggedIn,'User LoggedIn');
        
        Questionnaire__c newApplication = BOS_Utility.getApplicationId('en_US');
        System.assertNotEquals(null, newApplication,'newApplication created');
        
        String objectName = Wizard_Utlity.findObjectNameFromRecordId(newApplication.Id);
        System.assertEquals('Questionnaire__c', objectName,'Questionnaire__c object');
        
        List<SObject> objectList = new List<SObject>();
        objectList.add(newApplication);
        String recordsDeleted = BOS_Utility.deleteRecords(objectList);
        System.assertEquals(System.Label.SUCCESS_MESSAGE, recordsDeleted,'Records deleted');
        
        List<Job_Configuration__mdt> jobConfigs = BOS_Utility.getJobConfigMetadata();
        System.assertNotEquals(null, jobConfigs,'Job Configuration returned');
        
        BOS_Utility.scheduleJob(jobConfigs[0].Id, 'Weekly', 'MON,TUE', '12:30:00.000');
        
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('QnA_FrameworkQuestion__c');
        Id recTypeId = Wizard_Utlity.getRecordTypeId('Enterprise',convertType);
        System.assertNotEquals(null, recTypeId,'RecordTypeId returned');
        }
        catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    private static void testDMLExceptionHandler() {
        Account account = new Account();
        Map<String, Object> mapErrorInfo;
        
        Test.startTest();
        try {
            if(account != NULL){
                insert account;
            }
        } catch(Exception e) {
            mapErrorInfo = BOS_Utility.ExceptionHandler('BOS_Utility_Test','testMethod','Account','No Id','Critical', e, 'Additional info');
        }
        Test.stopTest();
        
        System.assertNotEquals(null, mapErrorInfo, 'Does not contain DML associated errors');
    }
    
    @isTest
    private static void testScheduleJobNonWeekly() {
        List<Job_Configuration__mdt> jobConfigs = BOS_Utility.getJobConfigMetadata();
        try {
            Test.startTest();
        	BOS_Utility.scheduleJob(jobConfigs[0].Id, 'Monthly', 'MON,TUE', '12:30:00.000');
        	Test.stopTest();
        }Catch(Exception e){}
        
        String actual = [
            SELECT Id
            FROM CronTrigger
            LIMIT 1
        ][0].Id;
        
        System.assertNotEquals(null, actual, 'Scheduler not setup monthly');
    }
    
    @isTest
    private static void testGetApplicationId() {
        Test.startTest();
        Questionnaire__c actual = BOS_Utility.getApplicationId('en_US');
        Test.stopTest();
        System.assertNotEquals(Null, actual);
    }
    @isTest
    private static void testMatchUserLocale() {
        Test.startTest();
        Questionnaire__c newApplication = BOS_Utility.getApplicationId('es');
        Boolean bool = BOS_Utility.matchUserLocale(newApplication.Id,'In Progress');
        Test.stopTest();
    }
   
    @isTest
    private static void testgetuserlocale() {
        Test.startTest();
       BOS_Utility.getUserLocale();
        Test.stopTest();
    }
    @isTest
    private static void testgetIDProofingDetail() {
        try{
            Test.startTest();
       		Contact con = BOS_Utility.getIDProofingDetail();
       		Test.stopTest();
        }Catch(Exception e){}
    }
    @isTest
    private static void testupdateIdProofingCounter() {
        try{
            Test.startTest();
        	Contact con = new contact(lastname='abc');
        	insert con;
        	BOS_Utility.updateIdProofingCounter(con.Id,1);
        	Test.stopTest();
        }Catch(Exception e){}
    }
    
     @isTest
    private static void testinsertErrorRecord2() {
        try{
            Test.startTest();
        	
        	BOS_Utility.insertErrorRecord2('Error String');
        	Test.stopTest();
        }Catch(Exception e){}
    }
    
    @isTest
    private static void ExceptionHandlerAsync() {
        Account account = new Account();
        Test.startTest();
        try {
            if(account != NULL){
                insert account;
            }
        } catch(Exception e) {
              BOS_Utility.ExceptionHandlerAsync('BOS_Utility_Test','testMethod','Account','No Id','Critical', e, 'Additional info');
        }
        Test.stopTest();
    }
    
     @isTest
     private static void insertErrorRecordForBatches() {
        try{
            Test.startTest();
            Map<String, Object> mapErrorInfo = new Map<String, Object>{};
            mapErrorInfo.put(System.Label.Class_Name, 'Test');
            mapErrorInfo.put(System.Label.Object_Name, 'Test');
            mapErrorInfo.put(System.Label.Severity, 'Medium');
            mapErrorInfo.put(System.Label.User_Info, UserInfo.getUserId());
            mapErrorInfo.put(System.Label.Language, UserInfo.getLanguage());
            mapErrorInfo.put(System.Label.Error_Message,'error msg');
            mapErrorInfo.put(System.Label.DML_Field_Names, 'error msg');
            mapErrorInfo.put(System.Label.Additional_Information, 'error msg');
        	BOS_Utility.insertErrorRecordForBatches(new List<Map<String,Object>>{mapErrorInfo});
        	Test.stopTest();
        }Catch(Exception e){}
    }

    @isTest
    private static void responseTraceHandler() {
        Account account = new Account();
        Test.startTest();
        try {
            if(account != NULL){
                insert account;
            }
        } catch(Exception e) {
              BOS_Utility.responseTraceHandler('BOS_Utility_Test','testMethod','Account','No Id','Critical','response', 'request string','url');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void test1(){
        test.startTest();
        BOS_Utility.getLoggedinUserType();
        BOS_Utility.createAccount();
        test.stopTest();
    }
    
    @isTest
    private static void errorRecordLogger() {
        Account account = new Account();
        Test.startTest();
        try {
            if(account != NULL){
                insert account;
            }
        } catch(Exception e) {
              BOS_Utility.errorRecordLogger('BOS_Utility_Test','testMethod','Account','No Id','Critical', e, 'Additional info');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void insertErrorRecordLst() {
        try{
            List<Error_Log__c> errLst = new List<Error_Log__c>();
            Test.startTest();
        	BOS_Utility.insertErrorRecordLst(errLst);
        	Test.stopTest();
        }Catch(Exception e){}
    }
}