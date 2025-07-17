@isTest
public class BRSFIEmailNotification_Test {
    @isTest
    static void sendPaymentConfirmationEmail() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Date_Registration__c = System.today()-1000;
        update acc;
        
        Foreign_Investigation__c fi = new Foreign_Investigation__c();
        fi.Business__c = acc.Id;  
        fi.Case_Status__c = System.label.OpenPartiallyPaid;
        fi.Payments_Made_to_Date__c = 10;
        fi.Negotiated_Amount__c = 1;
        fi.Registration_Date__c = System.today()-1000;
        insert fi;
        
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        
        Work_Order__c workOrder = new Work_Order__c();
        workOrder = BRS_TestDataFactory.createWorkOrderObject(con.Id, System.label.Online_Label, System.label.In_Progress_Label);
                
       /* BRSBusinessFilingEmailNotification.RequestsInfo req= new BRSBusinessFilingEmailNotification.RequestsInfo();
        req.businessFilingRec =bfc;   
        list<BRSBusinessFilingEmailNotification.RequestsInfo> reqList=new list<BRSBusinessFilingEmailNotification.RequestsInfo>();
        reqList.add(req);
        test.startTest();
        BRSBusinessFilingEmailNotification.sendBusinessFilingEmail(reqList);
        test.stopTest(); */
        
        test.startTest();
        workOrder.Foreign_Investigation__c = fi.Id;
        workOrder.Type__c = System.label.Foreign_Investigation;
        workOrder.Status__c = System.label.BRS_Status_Value_Completed;
        update workOrder;
        test.stopTest();
    }
}