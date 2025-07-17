/******************************************************************************************************
* NAME:  		BRS_RefundPageController
* DESCRIPTION:  This class is used in payment module for refund processing
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		2nd Feb, 2021
*******************************************************************************************************/
public without sharing class BRS_RefundProcessBatch implements Database.Batchable<sObject>, Schedulable{
    public static final String className='BRS_RefundProcessBatch';
    public static final String objectName='Contact';
    public static final String severity='High';
    // method implemented from Schedulable interface
    public void execute(SchedulableContext sc){
        String currentMonth = System.now().format('MMMM');
        Map<String,Boolean> monthlyActiveMap = new Map<String,Boolean>();
        List<BRS_Refund_Process_Batch_Schedule__mdt> refundMonthList = [SELECT Id, DeveloperName, MasterLabel, Refund_Process_Active__c FROM BRS_Refund_Process_Batch_Schedule__mdt];
        for(BRS_Refund_Process_Batch_Schedule__mdt month:refundMonthList){
            monthlyActiveMap.put(month.MasterLabel,month.Refund_Process_Active__c);
        }
        if(monthlyActiveMap.keyset().contains(currentMonth) && monthlyActiveMap.get(currentMonth) == true){
             Database.executebatch(this,100); 
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,Name,Total_Check_Balance__c  from Contact where Total_Check_Balance__c>0 AND RecordType.DeveloperName=\'Enterprise\' AND Trademark_Balance__c =0';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{ 
            List<Contact> contactList = (List<Contact>)scope;
            List<Customer_Balance_Transaction__c> refundRecordsList = new List<Customer_Balance_Transaction__c>();
        Database.SaveResult[] srList = new List<Database.SaveResult>();
            for(Contact con: contactList){
                Customer_Balance_Transaction__c customerbalance = new Customer_Balance_Transaction__c();
                customerbalance.Amount__c=con.Total_Check_Balance__c;
                customerbalance.Payment_Source__c = System.Label.BRS_PaymentSource_Check;
                customerbalance.Contact__c=con.Id;
                customerbalance.Type__c=System.Label.BRS_Transaction_Type_Debit;
                customerbalance.Status__c=System.Label.BRS_Transaction_Status_RefundProgress;
                customerbalance.Start_Date__c = System.today();
				customerbalance.Transaction_Date_Time__c = System.now();
                refundRecordsList.add(customerbalance);
            }
			if(!refundRecordsList.isEmpty()){
				srList = database.insert(refundRecordsList,false);
			}
            BOS_Utility.ExceptionHandlerForBatches(className,objectName,'execute',srList,null);
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'execute',objectName,null,severity,e,null);
        }
    }
    public void finish(Database.BatchableContext BC){
    }
}