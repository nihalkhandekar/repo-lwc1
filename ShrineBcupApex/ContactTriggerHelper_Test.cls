@IsTest
public class ContactTriggerHelper_Test {
    
    @testSetup static void setup() {
    Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        insert acc;    
         Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact123';
        con.Email = 'testConBrs@test.com';
        con.Allow_negative_balances__c = true;
        con.AccountId = acc.id;
        insert con;
                 Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
           User u = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8',firstname='firstname' , middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='testerbrs@noemail.com'
        );
        insert u;
}
static testmethod void validateGovernmentUserTest() {
    
 User u = [SELECT Id, Name FROM User WHERE profile.name='CT Community User' limit 1];
      List<Contact> contactlist=[Select id,Name,isGovernmentUser__c from contact limit 1];
    Map<Id,Contact> oldcontact=new Map<Id,Contact>();
    oldcontact.put(contactlist[0].id,contactlist[0]);
     contactlist[0].isGovernmentUser__c=true;
    update contactlist;

    test.startTest();
    ContactTriggerHelper.validateGovernmentUser(contactlist,oldcontact);
    ContactTriggerHandler sa=new ContactTriggerHandler();
    sa.beforeDelete(null,null);
    sa.afterDelete(null);
    test.stopTest();

}
}