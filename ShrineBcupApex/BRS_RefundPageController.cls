/******************************************************************************************************
* NAME:  		BRS_RefundPageController
* DESCRIPTION:  This class is used in payment module for refund processing
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		2nd Feb, 2021
*******************************************************************************************************/
public without sharing class BRS_RefundPageController {
	ApexPages.StandardSetController setCon;
 
    public BRS_RefundPageController(ApexPages.StandardSetController controller) {
        setCon = controller;
    }
 
    public integer getSelectedSize() {
        return setCon.getSelected().size();
    }
    
    public Decimal getTotalAmount() {
        List<SObject> sobjList = setCon.getRecords();
        Decimal totalAmount =0;
        for(sObject sobj : setCon.getSelected())
        {	
            Customer_Balance_Transaction__c cbt =(Customer_Balance_Transaction__c)sobj;
            totalAmount+=cbt.Amount__c;
            
        }
        return totalAmount;
    }
    public PageReference save() {
        list<Customer_Balance_Transaction__c> lstToUpdate= new list<Customer_Balance_Transaction__c>();
        for(sObject sobj : setCon.getSelected())
        {	
            Customer_Balance_Transaction__c cbt =(Customer_Balance_Transaction__c)sobj;
            cbt.Status__c='Refunded';
			cbt.Refund_Date__c=System.today();
            lstToUpdate.add(cbt);
        }
        if(lstToUpdate.size() > 0)
            update lstToUpdate;
        return null;
    }
}