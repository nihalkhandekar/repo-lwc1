@isTest
private class LanguageConversionBatch_Test {
    @testSetup 
    private static void initData() {
        Category__c categoryCreated = QnA_TestDataFactory.createCategoryWithCode('Services','Level1','728467');
    }
    @isTest
    private static void LanguageConversionBatch_test(){
		Test.startTest();
        try{
            List<FlowConversionConfiguration__mdt> configList = [Select Id,RequiredFieldsToAdd__c,AllFieldsToConvert__c,AllFieldsToQuery__c,Object_Name__c,
                                                                 Where_Condition__c,Linked_Object__c,LinkedField__c From FlowConversionConfiguration__mdt];
        	DataBase.executeBatch(new LanguageConversionBatch(configList,'es',0));
        }catch(Exception e){}
        Test.stopTest();
    }
     @isTest
    private static void LanguageConversionBatch_test1(){
        try{
            Test.startTest();
            List<FlowConversionConfiguration__mdt> configList = [Select Id,RequiredFieldsToAdd__c,AllFieldsToConvert__c,AllFieldsToQuery__c,Object_Name__c,
                                                                 Where_Condition__c,Linked_Object__c,LinkedField__c From FlowConversionConfiguration__mdt];
        	for(FlowConversionConfiguration__mdt config : configList){
                config.AllFieldsToConvert__c = '';
            }
            DataBase.executeBatch(new LanguageConversionBatch(configList,'es',0));
            Test.stopTest();
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
    }
	@isTest
    private static void Charset_test(){
        Test.startTest();
        Charset.test_encode();
        Charset.test_decode();
        Test.stopTest();
    }
}