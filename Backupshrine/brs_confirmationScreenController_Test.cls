@isTest
public class brs_confirmationScreenController_Test {
    static testmethod void createDebitRecordsTest()
    {
     Account acc=new Account();
    acc=BRS_TestDataFactory.createAccountObject();
    Contact con=new Contact();
    con=BRS_TestDataFactory.createContactObject(acc.id);
    Work_Order__c workorder=new Work_Order__c();
    workorder=BRS_TestDataFactory.createWorkOrderObject(con.id,'Online','Open');
    RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
    OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
    Business_Filing__c filing=new Business_Filing__c();
    filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,acc.id,workorder.id,'Change of Email Address','Completed');
    Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
   	User u=new User();
    u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        System.runAs(u){
         Test.startTest();
        brs_confirmationScreenController.checkBusinessFiling(acc.id,filing);
        try {
            brs_confirmationScreenController.checkBusinessFiling(acc.id,null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
        }

    }
}