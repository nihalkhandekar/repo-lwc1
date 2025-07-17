@IsTest
public class CertificateTriggerHandler_Test {
    testmethod static void test1() {
        	Account acc = BRS_TestDataFactory.createAccountObject();
        	List<Account> acclist = new List<Account>();
        	acclist.add(acc);
        	Map<Id,Account> oldItems = new Map<Id,Account>();
        	oldItems.put(acc.Id,acc);
        
        	decimal fee = 100;
        	Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        	Contact con1 = BRS_TestDataFactory.createContactObject(acc.Id);
       		Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Mail', 'Completed');
        
        	Certficate__c cert = BRS_TestDataFactory.createCertificate(mainRecTypeId1, acc.Id, WorkOrder.Id);
        	
			test.startTest();
        	CertificateTriggerHandler cth  = new CertificateTriggerHandler();
        	cth.beforeDelete(acclist, oldItems);
        	cth.afterDelete(oldItems);
        	cth.afterUndelete(acclist, oldItems);
        	//cth.updateFilingTypeAndFee(cert, fee, cert);
        	test.stopTest();
    }
    

}