public with sharing class Brs_CompleteIntakeButton {
   
    @AuraEnabled
    public static void updateStatus(String workorder, String businessFiling,Boolean isFormation,String businessName){
        try {
            
Work_Order__c order = new  Work_Order__c();
order.id = workorder;
order.Assigned_To__c = null;
order.Status__c = 'Intake pending';

update order;


Work_Order__c orderId = [Select id, Customer__c from Work_Order__c where id = :workorder Limit 1];

Account  acc = new Account();
if(isFormation){
    ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();

acc.Name  = businessName;
acc.Account_Name_Without_Designators__c= businessName;

acc.Has_Business_Name_Reservation_No__c  = true;
acc.Name_of_Applicant__c= orderId.Customer__c;
acc.RecordTypeId= storeRecordTypeId;
acc.Status__c= 'Reserved';
acc.Is_Intake_Filing__c = true;
insert acc;
}
Business_Filing__c filing = new Business_Filing__c();
filing.id = businessFiling;
filing.Status__c = 'Submitted - Intake pending';
//filing.Source__c = 'Digital Mail';
filing.Intake_Reserved_Name__c =acc.id;
update filing;
        } catch (Exception e) {
           BOS_Utility.handleException(e);
        }
    }
}