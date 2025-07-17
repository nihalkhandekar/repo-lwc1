@isTest
public class brs_filingDueController_Test {
    
    @testSetup static void setup() {      
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
         Account acc = new Account();
        acc = BRS_TestDataFactory.createAccountObject();        
        Business_Filing__c businessFiling = new Business_Filing__c();
        BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.id,'','Agent Resignation',Label.In_Progress_Label);
    }
    @isTest
    static void getBusinessWithFilingTest(){
        Business_Filing__c busFilingObj = [Select id from Business_Filing__c];
        Account accObj = [Select id from Account];
        test.startTest();
        brs_filingDueController.getBusinessWithFiling(accObj.id,busFilingObj.id, system.label.brs_maintenance_agent);
        brs_filingDueController.getFilingStatus(busFilingObj.id);
        brs_filingDueController.getBusinessWithFiling(accObj.id,busFilingObj.id, 'Test');
        test.stopTest();
    }
    
    @isTest
    static void getFilingDueDetailsTest(){
        Business_Filing__c busFilingObj = [Select id from Business_Filing__c];
        Account accObj = [Select id from Account];
        test.startTest();
        brs_filingDueController.getFilingDueDetails(accObj.id,system.label.brs_maintenance_Email);        
        brs_filingDueController.getFilingDueDetails(accObj.id, 'Agent Resignation');
        test.stopTest();
    }
    
}