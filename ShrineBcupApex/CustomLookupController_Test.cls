@isTest
public class CustomLookupController_Test {
		@TestSetup
    	static void setup() {
        
            Account acc = BRS_TestDataFactory.createAccountObject();
            
        }
    testMethod static void findRecords() {
        Account acc = [select Id, Name from Account where Name='Test Account' limit 1];
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        String searchKey = 'Test Account';
        String objectName = 'Account';
        String searchField = 'Name';
        Boolean isNameReservation = true;
        Boolean isName = false;
 		test.startTest();
        CustomLookupController.findRecords(searchKey, objectName, searchField, isNameReservation);
        CustomLookupController.findRecords(searchKey, objectName, searchField, isName);
        test.stopTest();
    }
    
    testMethod static void getRecords() {
        Account acc = [select Id, Name from Account where Name='Test Account' limit 1];
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        string objectName = 'Account';
        string searchField = 'Name';
        string sid = acc.Id;
        test.startTest();
        CustomLookupController.getRecords(objectName, searchField, sid);
        test.stopTest();
    }
}