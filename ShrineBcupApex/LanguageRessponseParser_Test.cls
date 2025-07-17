@isTest
private class LanguageRessponseParser_Test {
    @testSetup
    private static void setup() {
        List<Service__c> listServices = new List<Service__c>();
        
        for(Integer index = 0; index < 2; index++) {
            listServices.add(new Service__c(
            	Level__c = 'Level 1',
                Language__c = 'en_US',
                Licenses_Details__c = 'Some Data',
                Service_Title__c = 'Some title'
            ));
        }
        
        insert listServices;
    }
    
    private static String getTranslationString() {
        LanguageRessponseParser.Translation translation = new LanguageRessponseParser.Translation();
        translation.translatedText = 'Some text';
        
        LanguageRessponseParser parser = new LanguageRessponseParser();
        parser.data = new LanguageRessponseParser.Translations();
        parser.data.translations = new List<LanguageRessponseParser.Translation> { translation };
            
        return JSON.serialize(parser);
    }

    @isTest
    private static void testParse() {
        String translationString = getTranslationString();

        Test.startTest();
            LanguageRessponseParser actual = LanguageRessponseParser.parse(translationString);
        	List<LanguageRessponseParser.Translation> listTranslation = actual.data.getTranslation();
        Test.stopTest();

        System.assertNotEquals(null, actual, 'error');
    }

    @isTest
    private static void testGetTranslations() {
        String translationString = getTranslationString();

        Test.startTest();
            List<String> actual = LanguageRessponseParser.getTranslations(translationString);
        Test.stopTest();

        System.assertNotEquals(null, actual, 'error');
    }
    
    //-------------- For LanguageRequestWrapper ------------
    @isTest
    private static void testLanguageRequestWrapper() {
        Test.startTest();
        	LanguageRequestWrapper actual1 = new LanguageRequestWrapper(new List<String>(), 'es', 'text');
        	LanguageRequestWrapper actual2 = new LanguageRequestWrapper(new List<String>(), 'es');
        Test.stopTest();
        
        System.assertNotEquals(null, actual1, 'error');
        System.assertNotEquals(null, actual2, 'error');
    }
}