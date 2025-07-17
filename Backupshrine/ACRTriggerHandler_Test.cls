@isTest
public class ACRTriggerHandler_Test {

    @testSetup
    private static void setup() {

        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id adminRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrator').getRecordTypeId();
        Account businessAcc = new Account(Name='Business Account', recordTypeId =businessRecordTypeId, Annual_Report_Due_Date__c = System.today(), Status__c='Active');
        accountList.add(businessAcc);
        Account userAcc = new Account(Name='User Account', recordTypeId =adminRecordTypeId);
        accountList.add(userAcc);
        insert accountList; 
        
        Contact conRec1 = new Contact(LastName = 'User Contact1', AccountId = userAcc.Id);
        contactList.add(conRec1);
        Contact conRec2 = new Contact(LastName = 'User Contact2', AccountId = userAcc.Id);
        contactList.add(conRec2);
        insert contactList;
    }
    @isTest
    public static void afterInsertTest(){
       
        Account businessAcc = [Select id from Account where name = 'Business Account'];
     
        Contact conRec1 = [Select id from Contact where LastName = 'User Contact1'];
        Contact conRec2 = [Select id from Contact where LastName = 'User Contact2'];
        
        Test.startTest();
        AccountContactRelation acrRec1 = new AccountContactRelation(AccountId = businessAcc.Id, ContactId = conRec1.Id);
        insert acrRec1;
        AccountContactRelation acrRec2 = new AccountContactRelation(AccountId = businessAcc.Id, ContactId = conRec2.Id);
        insert acrRec2;
        
        Account accRec = [select Id,(select Id, Name from Action_Items__r) from Account where Id=:businessAcc.Id];
        //System.assertEquals(false, accRec.Action_Items__r.isEmpty(), '1 Action Item created');
        Test.stopTest();
    }
	public static Map<Id, sObject> getRecords(String accName) {
    	return new Map<Id, Account>([
            SELECT Id, OwnerId, Status__c, Annual_Report_Due_Date__c 
            FROM Account where name = :accName
        ]);
    }
    @isTest
    public static void createNewActionItemsTest()
    {
        Account businessAcc = [Select id, Name, Status__c, Annual_Report_Due_Date__c from Account where name = 'Business Account'];
        Map<Id, sObject> mapOldRecords = getRecords(businessAcc.Name);
     	System.debug('businessAcc.Status__c : '+businessAcc.Status__c);
        System.debug('Annual_Report_Due_Date__c before -> '+businessAcc.Annual_Report_Due_Date__c);
        businessAcc.Annual_Report_Due_Date__c = System.today() + 1;
        Test.startTest();
        update businessAcc;
        System.debug('Annual_Report_Due_Date__c -> '+businessAcc.Annual_Report_Due_Date__c);
        Map<Id, sObject> mapNewRecords = getRecords(businessAcc.Name);
        Contact conRec1 = [Select id from Contact where LastName = 'User Contact1'];
        Contact conRec2 = [Select id from Contact where LastName = 'User Contact2'];
        Action_Item__c objectActionItem = new Action_Item__c(Account__c = businessAcc.Id, Status__c = 'Open', Action_Item_Name__c = 'Annual report');
        insert objectActionItem;
        
        
        AccountContactRelation acrRec1 = new AccountContactRelation(AccountId = businessAcc.Id, ContactId = conRec1.Id);
        insert acrRec1;
        AccountContactRelation acrRec2 = new AccountContactRelation(AccountId = businessAcc.Id, ContactId = conRec2.Id);
        insert acrRec2;
        AccountContactRelationTriggerHandler.createNewActionItems(mapNewRecords, mapOldRecords);
        Test.stopTest();
    }

}