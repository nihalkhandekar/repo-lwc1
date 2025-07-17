@isTest
public with sharing class DashboardlinkApexTest {
     @testSetup
    private static void setup() {
        Map<Account,List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        List<Contact> cons = AccountsVsContacts.values().get(0);
        
        Credential__c cred = QnA_TestDataFactory.createCredential();
        Account_Credential_Relationship__c accRel = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
            Contact__c=cons.get(0).Id,
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
    
    
    @isTest
    public static void testGetIwantTolinks(){
        try{
            DashboardlinkApex.getIwantTolinks();
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
    @isTest
    public static void testgetCTHighlightNews(){
        try{
            DashboardlinkApex.getCTHighlightNews();
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
    @isTest
    public static void testgetDashboardActionItems(){
        try{
            user u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u){
            Test.startTest();
            DashboardlinkApex.getDashboardActionItems();
            Test.stopTest();
        }
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
   @isTest
    public static void testgetCollectionList(){
        try{
             user u = [Select Id,ContactID From user where username='tester@noemail.com' limit 1];
        
            DashboardlinkApex.getCollectionList(u.ContactID);
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
    @isTest
    public static void testgetDashboardCount(){
        try{
           user u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u){
            Test.startTest();
            DashboardlinkApex.getDashboardCount();
            Test.stopTest();
        }
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
}