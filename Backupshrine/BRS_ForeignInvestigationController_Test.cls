@isTest
public class BRS_ForeignInvestigationController_Test {
    @testSetup static void setup() {
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account accInst = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(accInst.id);
        User user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
        
        Account acc = BRS_TestDataFactory.createAcc('Foreign','LLP');
        acc.Business_Email_Address__c='test@test.com';
        acc.Description ='test';
		acc.Date_of_Formation__c = System.today().addDays(-150);
        acc.Began_Transacting_in_CT__c = System.today().addDays(-100);
        insert acc;
        
        Foreign_Investigation__c foreignInv = new Foreign_Investigation__c();
        foreignInv.Case_Status__c='Pending';
        foreignInv.Due_Date__c = System.today()+30;
        foreignInv.Negotiated_Amount__c=1500;
        foreignInv.Monthly_Payable__c=250;
        foreignInv.Payment_Duration__c=4;
        foreignInv.First_Payment__c=500;
        foreignInv.Registration_Date__c = System.today();
        foreignInv.Business__c=acc.Id;
        foreignInv.Business_Type__c = 'LLP';
        insert foreignInv;
        
        Payment_Line_Item__c paymentItem = new Payment_Line_Item__c(Fee_Type__c='License Fee',Fee_Amount__c=2000,Case_Number__c=foreignInv.Id);
    }
	
    testmethod static void getForeignInvestigationTest(){
        User commUser = [Select Id,Contact_Email_Address__c,Contact.Phone,IsActive from User where IsActive=true and username='testerbrs@noemail.com' LIMIT 1];
        Foreign_Investigation__c foreignInv = [select Id,Case_Status__c,Name,Due_Date__c,Total_Amount__c,Negotiated_Amount__c,
                                               Outstanding_Amount_Due__c,Monthly_Payable__c,Business__r.Business_Email_Address__c from Foreign_Investigation__c limit 1];
        System.runAs(commUser){
            
            Test.startTest();
            BRS_ForeignInvestigationController.getForeignInvestigation(foreignInv.Id);
            BRS_ForeignInvestigationController.getFIForConfirmation(foreignInv.Id, 1);
            Test.stopTest();
        }
        
    }
}