/********************************************************************************
*NAME: brs_stockClassificationControllerTest
*DESCRIPTION: Test Class for brs_stockClassificationController
*
**********************************************************************************/
@isTest
public class brs_stockClassificationControllerTest {

    @testSetup
    static void setup() {
            List<Stock_Classification__c> lstsk = new List<Stock_Classification__c>();
        Stock_Classification__c sk = new Stock_Classification__c();
        sk.Number_of_Stocks__c=100;
        sk.Par_Value__c =10;
        lstsk.add(sk);
        insert lstsk;
        Account acc=new Account(Name='Test_Account');
        insert acc;
    }
    @isTest
    static void upsertStockRecordsTest() {
        List<Stock_Classification__c> stockdata=[Select Number_of_Stocks__c,Par_Value__c from Stock_Classification__c];
        Id accId  = [Select id from Account Limit 1].id;
        Test.startTest();
        brs_stockClassificationController.upsertStockRecords(stockdata);
            try {
                brs_stockClassificationController.upsertStockRecords(null);
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
      static void getStockRecordsTest() {
        Account accId = [Select id from Account Limit 1];
        Test.startTest();
        brs_stockClassificationController.getStockRecords(accId.id);
        brs_stockClassificationController.getStockRecords(null);
        Test.stopTest();
    }
      @isTest
      static void deleteStockRecordsTest() {
        Id stockid  = [Select Number_of_Stocks__c,Par_Value__c from Stock_Classification__c Limit 1].id;
        Test.startTest();
              
        try 
        {
            brs_stockClassificationController.deleteStockRecords(stockid);
            brs_stockClassificationController.deleteStockRecords(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
     
}