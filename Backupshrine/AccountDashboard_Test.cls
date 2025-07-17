/*********************************************************************************************
* NAME:  AccountDashboard_Test
* DESCRIPTION: Test class for AccountDashboard
* 				 
*
* @AUTHOR: Piyush Jogdand
* @DATE: 9/1/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Piyush Jogdand				  9/1/2020                              Created
*********************************************************************************************/
@isTest
private class AccountDashboard_Test {
    @testSetup
    private static void setup() {
        Map<Account,List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        List<Contact> cons = AccountsVsContacts.values().get(0);
        
        Credential__c cred = QnA_TestDataFactory.createCredential();
        Account_Credential_Relationship__c accRel = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
            Account__c = cons.get(0).AccountId
        );
        insert accRel;
        
        Contact_Credential_Relationship__c conRel = new Contact_Credential_Relationship__c(
        	Credential__c = cred.Id,
            Contact__c = cons.get(0).Id
        );
		insert conRel;

        Id p = [select id from profile where name='CT Community User'].id;
        User user = QnA_TestDataFactory.createCommunityUser(cons[0],p);
    }
    
    private static String getTranslationString() {
        LanguageRessponseParser.Translation translation = new LanguageRessponseParser.Translation();
        translation.translatedText = 'Translated Details##Translated Title';
        
        LanguageRessponseParser parser = new LanguageRessponseParser();
        parser.data = new LanguageRessponseParser.Translations();
        parser.data.translations = new List<LanguageRessponseParser.Translation> { translation };
            
        return JSON.serialize(parser);
    }
    
	@isTest
    private static void Test_getBusinesses() {
        user u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u){
            Test.startTest();
            AccountDashboard.getBusinesses();
            Test.stopTest();
        }
    }
    @isTest
    private static void Test_getBusinessDetails() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        user u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        HttpResponseMock mock = new HttpResponseMock(getTranslationString(), 200, 'OK');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        System.runAs(u){
            Test.startTest();
                AccountDashboard.getBusinessDetails(acc.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void Test_unlinkBusiness() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        try{
            Test.startTest();
            	AccountDashboard.unlinkBusiness(acc.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(Null, e);
        }
    }
    
    @isTest
    private static void Test_unlinkCredential() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        try{
            Test.startTest();
            AccountDashboard.unlinkCredential(acc.Id,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(Null, e);
        }
    }
    
    @isTest
    private static void testUnlinkCredentialError() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        
        try{
            Test.startTest();
            	AccountDashboard.unlinkCredential(acc.Id, acc.Id);
            Test.stopTest();
        } catch(AuraHandledException e){
            System.assert(true);
        }
    }
    
    @isTest
    private static void Test_getRightPaneResources(){
        Test.startTest();
        AccountDashboard.getRightPaneResources('',true);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAgentsAndPrincipals(){
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        HttpResponseMock mock = new HttpResponseMock(getTranslationString(), 200, 'OK');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	AccountDashboard.getAgentsAndPrincipals(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testunlinkProfessionalCredential() {
        Credential__c cred = [
            SELECT Id 
            FROM Credential__c 
            LIMIT 1
        ];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u){
            try {
                Test.startTest();
                    AccountDashboard.unlinkProfessionalCredential(cred.Id);
                Test.stopTest();
            } catch(AuraHandledException e) {
                System.assert(true);
            }
        }
    }
    
    @isTest
    private static void testunlinkProfessionalCredentialError() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u){
            try {
                Test.startTest();
                    AccountDashboard.unlinkProfessionalCredential(acc.Id);
                Test.stopTest();
            } catch(AuraHandledException e) {
                System.assert(true);
            }
        }
    }
    
    @isTest
    private static void testsearchCredential(){
        Credential__c cred = [
            SELECT Id, Name
            FROM Credential__c 
            LIMIT 1
        ];
        
        Test.startTest();
        	AccountDashboard.searchCredential(cred.Name);
        Test.stopTest();
    }
    
    @isTest
    private static void testBusinessWrapper(){
        Test.startTest();
        	AccountDashboard.BusinessWrapper  wrapper = new AccountDashboard.BusinessWrapper(
                new Account(), new List<Action_Item__c>(), new List<Credential__c>(), new List<Business_Status_Mapping__mdt>()
            );
        Test.stopTest();
    }
    
    @isTest
    private static void testContactWrapper(){
        Test.startTest();
        	AccountDashboard.ContactWrapper wrapperAgent = new AccountDashboard.ContactWrapper(new Agent__c());
        	AccountDashboard.ContactWrapper wrapperPrincipal = new AccountDashboard.ContactWrapper(new Principal__c());
        Test.stopTest();
    }
    
    @isTest
    private static void testGetScholarsColumn(){
        Test.startTest();
        	AccountDashboard.getScholarsColumn('');
        Test.stopTest();
    }
}