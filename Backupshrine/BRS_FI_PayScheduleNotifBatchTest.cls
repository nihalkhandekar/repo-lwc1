@isTest
public class BRS_FI_PayScheduleNotifBatchTest {
    @testsetup
    public static void dataSetup() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con = BRS_TestDataFactory.createContactObject(acc.id);
        
        List<Foreign_Investigation__c> lstFI = new List<Foreign_Investigation__c>();
        Foreign_Investigation__c foreignInv = BRS_TestDataFactory.setForeignInvestigationRecords('', 'Open - Settlement Letter Issued', System.today()-200);
        foreignInv.Negotiated_Amount__c = 1000;
        foreignInv.Auto_payment_plan__c = true;
        foreignInv.Payment_Plan_Established__c = true;
        foreignInv.Due_Date__c = System.today();
        foreignInv.Monthly_Payable__c = 100;
        foreignInv.Payment_Duration__c = 2;
        foreignInv.First_Payment__c = 800;
        foreignInv.First_Payment_Done__c = true;
        foreignInv.Payments_Made_to_Date__c = 800;
        foreignInv.Registration_Date__c = Date.newInstance(2021, 08, 01);
        foreignInv.Date_Began_Transacting_Business_in_CT__c = Date.newInstance(2021, 01, 01);
        lstFI.add(foreignInv);
        List<Foreign_Investigation__c> lstFrnRes = (List<Foreign_Investigation__c>)BRS_TestDataFactory.insertSObject(lstFI);
        
        Work_Order__c workOrdRec = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        workOrdRec.Foreign_Investigation__c = lstFrnRes[0].Id;
        update workOrdRec;
        
        List<bt_stripe__Payment_Schedule__c> lstNewPaySchedule = new List<bt_stripe__Payment_Schedule__c>();
        bt_stripe__Payment_Schedule__c newPaySchedule = new bt_stripe__Payment_Schedule__c();
        newPaySchedule.bt_stripe__Preset__c = System.Label.Monthly_comparable;
        newPaySchedule.bt_stripe__Status__c = System.Label.Generate_Comparable;
        newPaySchedule.bt_stripe__Currency__c = 'USD';
        newPaySchedule.bt_stripe__Each_Amount__c = lstFI[0].Monthly_Payable__c;                    
        newPaySchedule.bt_stripe__Count__c = lstFI[0].Payment_Duration__c;
        newPaySchedule.bt_stripe__Start_Date__c = lstFI[0].Due_Date__c;
        newPaySchedule.Foreign_Investigation__c = lstFI[0].Id;
        newPaySchedule.bt_stripe__Auto_Capture__c = true; 
        lstNewPaySchedule.add(newPaySchedule);
        insert lstNewPaySchedule;
        
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn.Work_Order__c = workOrdRec.Id;
        txn.bt_stripe__Amount__c = 90;
        txn.bt_stripe__Transaction_Status__c = 'Completed';
        txn.bt_stripe__Payment_Status__c = 'Captured';
        txn.bt_stripe__Related_Contact__c = con.Id;
        txn.bt_stripe__Processed_Date__c = System.today();
        txn.bt_stripe__Payment_Schedule__c = lstNewPaySchedule[0].Id;
        insert txn;
    }
    
    @isTest
    public static void testBatch1() {
        List<Foreign_Investigation__c> lstFr = [SELECT Id, Payments_Made_to_Date__c, Months_Paid__c, Due_Date__c FROM Foreign_Investigation__c LIMIT 1];
        List<bt_stripe__Payment_Schedule__c> lstPS = [SELECT Id, Foreign_Investigation__c FROM bt_stripe__Payment_Schedule__c LIMIT 1];
        List<bt_stripe__Transaction__c> lstTxn = [SELECT Id, bt_stripe__Payment_Schedule__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c,
                                                  bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Payments_Made_to_Date__c
                                                  FROM bt_stripe__Transaction__c LIMIT 1];
        
        Test.startTest();
        Database.executeBatch(new BRS_FI_PayScheduleNotificationBatch(), 200);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatch2() {
        List<Foreign_Investigation__c> lstFr = [SELECT Id, Payments_Made_to_Date__c, Months_Paid__c, Due_Date__c FROM Foreign_Investigation__c LIMIT 1];
        List<bt_stripe__Payment_Schedule__c> lstPS = [SELECT Id, Foreign_Investigation__c FROM bt_stripe__Payment_Schedule__c LIMIT 1];
        List<bt_stripe__Transaction__c> lstTxn = [SELECT Id, bt_stripe__Payment_Schedule__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c,
                                                  bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Payments_Made_to_Date__c
                                                  FROM bt_stripe__Transaction__c LIMIT 1];
        
            
        String query = 'SELECT Id, CreatedDate, bt_stripe__Related_Contact__c, bt_stripe__Related_Contact__r.Email, bt_stripe__Payment_Status__c, bt_stripe__Transaction_Status__c, bt_stripe__Amount__c, bt_stripe__Processed_Date__c, bt_stripe__Transaction_Type__c, '
                                    + 'bt_stripe__Payment_Schedule__c, bt_stripe__Payment_Schedule__r.bt_stripe__Next_Payment_Date__c, bt_stripe__Payment_Schedule__r.bt_stripe__Balance_Paid__c, '
                                    + 'bt_stripe__Payment_Schedule__r.bt_stripe__Balance_Due__c, bt_stripe__Payment_Schedule__r.bt_stripe__Status__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__c, '
                                    + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Months_Paid__c, bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Payments_Made_to_Date__c '
                                + 'FROM bt_stripe__Transaction__c '
                                + 'WHERE bt_stripe__Payment_Schedule__c != null AND '
                                    + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__c != null AND '
                                    + 'bt_stripe__Payment_Schedule__r.bt_stripe__Status__c != \'Canceled\' AND '
                                    + 'DAY_ONLY(bt_stripe__Processed_Date__c) = TODAY AND '
                                    + 'bt_stripe__Transaction_Status__c != \'Open\' AND '
                                    + 'bt_stripe__Transaction_Type__c = \'Normal\' AND '
                                    + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.Auto_payment_plan__c = true AND '
                                    + 'bt_stripe__Payment_Schedule__r.Foreign_Investigation__r.First_Payment_Done__c = true '
                                + 'ORDER BY CreatedDate ASC';
        
        Test.startTest();
        Database.executeBatch(new BRS_FI_PayScheduleNotificationBatch(query), 200);
        Test.stopTest();
    }
}