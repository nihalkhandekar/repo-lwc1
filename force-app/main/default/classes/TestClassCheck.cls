@isTest
public class TestClassCheck {
    public static testmethod void TestClassCheck(){
        Contact c = new Contact();
        c.FirstName = 'test22';
        c.LastName = 'second22';
        system.test.startTest();
        insert c; 
        system.test.stopTest();
        list<Contact> cList = new list<Contact>();
        cList.add(c);
        RecTriggerCon.onInsertCon(cList);
    }
}