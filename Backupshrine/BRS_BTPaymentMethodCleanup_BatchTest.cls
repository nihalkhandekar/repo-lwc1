@isTest
public class BRS_BTPaymentMethodCleanup_BatchTest {
    @testsetup
    static void dataSetup() {
        Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        
        Account acc = BRS_TestDataFactory.createAcc('Domestic', 'Stock');
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact123';
        con.Email = 'testConBrs@test.com';
        con.RecordTypeId = conRecTypeId;
        con.AccountId = acc.Id;
        insert con;
        
        bt_stripe__Payment_Gateway__c payGateway = new bt_stripe__Payment_Gateway__c();
        payGateway.bt_stripe__Provider__c = 'Authorize.net';
        payGateway.Name = 'Test';
        insert payGateway;
        
        List<bt_stripe__Payment_Method__c> lstPayMethod = new List<bt_stripe__Payment_Method__c>();
        bt_stripe__Payment_Method__c payMethod1 = new bt_stripe__Payment_Method__c();
        payMethod1.bt_stripe__Card_Holder_Name__c = 'Test Card data information';
        payMethod1.bt_stripe__Payment_Method_Status__c = 'Valid';
        payMethod1.bt_stripe__Default_Payment_Method__c = false;
        payMethod1.bt_stripe__Billing_Postal_Code__c = '13321';
        payMethod1.bt_stripe__Card_Expiration_Month__c = '10';
        payMethod1.bt_stripe__Card_Expiration_Year__c = '2027';
        payMethod1.bt_stripe__Contact__c = con.Id;
        payMethod1.bt_stripe__CVV__c = '534';
        payMethod1.bt_stripe__Payment_Gateway__c = payGateway.Id;
        lstPayMethod.add(payMethod1);
        
      
        
        for(integer i=0;i<=10;i++)
        {
        bt_stripe__Payment_Method__c payMethod2 = new bt_stripe__Payment_Method__c();
        payMethod2.bt_stripe__Card_Holder_Name__c = 'Test Card';
        payMethod2.bt_stripe__Payment_Method_Status__c = 'Invalid';
        payMethod2.bt_stripe__Default_Payment_Method__c = false;
        payMethod2.bt_stripe__Billing_Postal_Code__c = '13321';
        payMethod2.bt_stripe__Card_Expiration_Month__c = '10';
        payMethod2.bt_stripe__Card_Expiration_Year__c = '2027';
        payMethod2.bt_stripe__Contact__c = con.Id;
        payMethod2.bt_stripe__CVV__c = '534';
        payMethod2.bt_stripe__Payment_Gateway__c = payGateway.Id;
        lstPayMethod.add(payMethod2);
        }
        if(!lstPayMethod.isEmpty()) {
            insert lstPayMethod;
            System.debug('result1 :: ' + lstPayMethod);
        }
    }
    
    static testMethod void testMethod1() {
        String query = 'SELECT Id, (SELECT Id, bt_stripe__Remove_from_Stripe__c, bt_stripe__Payment_Method_Status__c,bt_stripe__Default_Payment_Method__c FROM bt_stripe__Payment_Methods__r) FROM Contact';
        Contact con = Database.query(query);
        System.debug('result :: ' + con.bt_stripe__Payment_Methods__r.size());
        System.debug('contactinformation@@ '+con.bt_stripe__Payment_Methods__r);

        Test.startTest();
        
        BRS_BTPaymentMethodCleanBatch obj = new BRS_BTPaymentMethodCleanBatch(query);
        DataBase.executeBatch(obj); 
        String sch = '0 0 2 * * ?'; 
        system.schedule('sheduled valid payment method', sch, obj); 
        
        Test.stopTest();
    }
    
    static testMethod void testMethod2() {
        String query = 'SELECT Id, (SELECT Id, bt_stripe__Remove_from_Stripe__c, bt_stripe__Payment_Method_Status__c FROM bt_stripe__Payment_Methods__r WHERE bt_stripe__Default_Payment_Method__c = false) FROM Contact';
        Contact con = Database.query(query);
        System.debug('result :: ' + con);
        String q2 = 'SELECT Id, bt_stripe__Remove_from_Stripe__c, bt_stripe__Payment_Method_Status__c FROM bt_stripe__Payment_Method__c';
        List<bt_stripe__Payment_Method__c> lstpm = Database.query(q2);
        System.debug('result3 :: ' + lstpm);
        
        Test.startTest();
        
        BRS_BTPaymentMethodCleanBatch obj = new BRS_BTPaymentMethodCleanBatch();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
}