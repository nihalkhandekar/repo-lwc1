@isTest
public class brs_legalDesignation_Test {
     @testSetup 
    static void setup() {
        /*List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i,Citizenship__c = 'Domestic', Business_Type__c = 'Religious'));
        }
        insert testAccts;
        List<Account> testAccts = new List<Account>();*/
        BRS_TestDataFactory.listOfAccount();
       
    }
     @isTest
    static void testLegalDesignations() {
        Id accId  = [Select id from Account Limit 1].id;
        Test.startTest();
        List<SObject> legalDesgList = brs_legalDesignation.getLegalDesignations(accId);
        try {
        List<SObject> legalDesgList1 = brs_legalDesignation.getLegalDesignations(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void getAccountNameTest() {
        Account accId  = [Select id from Account Limit 1];
        Test.startTest();
        String legalDesgList1 = brs_legalDesignation.getAccountName(accId.id);
        String legalDesgList = brs_legalDesignation.getAccountName(null);
        try {
            delete accId;
            legalDesgList = brs_legalDesignation.getAccountName(accId.Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void requestsTest() {
        Account accId  = [Select id from Account Limit 1];
        brs_legalDesignation.Requests da = new brs_legalDesignation.Requests();
        da.accId = accId.ID;
        List<brs_legalDesignation.Requests> da1 = new List<brs_legalDesignation.Requests>();
        da1.add(da);
        Test.startTest();
        brs_legalDesignation.getLegalDesignationsInv(da1);
        delete accId;
        try {
            brs_legalDesignation.getLegalDesignationsInv(da1);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}