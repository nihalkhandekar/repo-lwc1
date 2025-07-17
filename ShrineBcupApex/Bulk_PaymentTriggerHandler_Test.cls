@isTest
public class Bulk_PaymentTriggerHandler_Test {
    
    @isTest
    private static void method1Test(){
        
        Bulk_PaymentTriggerHandler bulk_triggerhandler=new Bulk_PaymentTriggerHandler();
        
        Test.startTest();
        
        bulk_triggerhandler.beforeInsert(null);
        bulk_triggerhandler.beforeDelete(null,null);
        bulk_triggerhandler.afterInsert(null,null);
        bulk_triggerhandler.afterUpdate(null,null);
        bulk_triggerhandler.afterDelete(null);
        bulk_triggerhandler.afterUndelete(null,null);
            
        Test.stopTest();    
    } 

}