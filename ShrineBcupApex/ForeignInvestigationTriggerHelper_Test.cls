@isTest 
public class ForeignInvestigationTriggerHelper_Test {
    
    @testSetup
    static void dataSetup(){

        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Date_Registration__c=System.today()-1000;
        update acc;
        Foreign_Investigation__c fi=new Foreign_Investigation__c();
        fi.Business__c=acc.Id;  
        fi.Case_Status__c=System.label.OpenPartiallyPaid;
        fi.Payments_Made_to_Date__c=10;
        fi.Negotiated_Amount__c=1;

        insert fi;

        
    
    }
    
    @isTest static void updateCaseStatusTest(){
        Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c from Foreign_Investigation__c LIMIT 1];
        ForeignInvestigationTriggerHelper.updateCaseStatus(new List<Foreign_Investigation__c> {fi}, null);
    }
    @isTest static void updateBusinessFieldsTest(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            Account acc=new Account();
            acc.Id=fi.Business__c;
            acc.Began_Transacting_in_CT__c=System.today();
            acc.ShippingStreet='Test';
            acc.ShippingCity='Test';
            acc.ShippingState='Test';
            acc.ShippingCountry='Test';
            acc.ShippingPostalCode='12345';
            acc.Principle_Office_International_Address__c='Test';
            update acc;            
            
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);            
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest1(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=null;            
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest2(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest3(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c='Test';
            fi.Business_Type__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest4(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c='Test';
            fi.Business_Type__c='LLP';
            fi.Business_Street_Address_1__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest5(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c='Test';
            fi.Business_Type__c='LLP';
            fi.Business_Street_Address_1__c='Test';
            fi.Business_City__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest6(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c='Test';
            fi.Business_Type__c='LLP';
            fi.Business_Street_Address_1__c='Test';
            fi.Business_City__c='Test';
            fi.Business_State__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void updateBusinessFieldsTest7(){
        try{
            Foreign_Investigation__c fi=[Select Id,Name,Case_Status__c,Payments_Made_to_Date__c,Negotiated_Amount__c,Registration_Date__c,Business__c from Foreign_Investigation__c LIMIT 1];
            fi.Business__c=null;
            fi.Date_Began_Transacting_Business_in_CT__c=System.today();
            fi.Registration_Date__c=System.Today();   
            fi.Business_Name__c='Test';
            fi.Business_Type__c='LLP';
            fi.Business_Street_Address_1__c='Test';
            fi.Business_City__c='Test';
            fi.Business_State__c='Test';
            fi.Business_Country__c=null;
            update fi;           
            ForeignInvestigationTriggerHelper.updateBusinessFields(new List<Foreign_Investigation__c> {fi}, null);      
        }catch(Exception e){
            
        }
    }
    @isTest static void createPaymentLineItemsTest(){
        try{
        List<Foreign_Investigation__c> lstfiv= new List<Foreign_Investigation__c>();     
        Foreign_Investigation__c foreignInv = new Foreign_Investigation__c();
        foreignInv.Case_Status__c='Closed - Paid in Full';
        foreignInv.Due_Date__c = System.today()+30;
        foreignInv.Negotiated_Amount__c=1500;
        foreignInv.Monthly_Payable__c=250;
        foreignInv.Payment_Duration__c=4;
        foreignInv.First_Payment__c=500;
        //foreignInv.Registration_Date__c = System.today();
        foreignInv.Business_Type__c = 'LLP';
        foreignInv.Case_Initiated_By__c='Complaint';
        foreignInv.Business_Name__c='Test';
        foreignInv.Outstanding_Amount_Due__c=0;
        foreignInv.Auto_payment_plan__c=true;
        foreignInv.First_Payment_Done__c=true;
        foreignInv.Date_Began_Transacting_Business_in_CT__c=system.today()-100;
        foreignInv.Registration_Date__c= system.today();
            lstfiv.add(foreignInv);
        insert lstfiv;
        ForeignInvestigationTriggerHelper.createPaymentLineItems(lstfiv, null);
        } catch(Exception e){
            
            
        }

    }
    
    @isTest static void cancelPaymentScheduleTest(){
        List<Foreign_Investigation__c> lstfiv= new List<Foreign_Investigation__c>(); 
        Foreign_Investigation__c foreignInv = new Foreign_Investigation__c();
        foreignInv.Case_Status__c='Closed - Paid in Full';
        foreignInv.Due_Date__c = System.today()+30;
        foreignInv.Negotiated_Amount__c=1500;
        foreignInv.Monthly_Payable__c=250;
        foreignInv.Payment_Duration__c=4;
        foreignInv.First_Payment__c=500;
        foreignInv.Registration_Date__c = System.today();
        foreignInv.Business_Type__c = 'LLP';
        foreignInv.Case_Initiated_By__c='Complaint';
        foreignInv.Business_Name__c='Test';
        foreignInv.Outstanding_Amount_Due__c=0;
        lstfiv.add(foreignInv);
        insert lstfiv;
        bt_stripe__Payment_Schedule__c newPaySchedule = new bt_stripe__Payment_Schedule__c();
        newPaySchedule.bt_stripe__Preset__c = System.Label.Monthly_comparable;
        newPaySchedule.bt_stripe__Status__c = 'Scheduled';
        newPaySchedule.bt_stripe__Currency__c = 'USD';
        newPaySchedule.bt_stripe__Each_Amount__c = lstfiv[0].Monthly_Payable__c;                    
        newPaySchedule.bt_stripe__Count__c = lstfiv[0].Payment_Duration__c;
        newPaySchedule.bt_stripe__Start_Date__c = lstfiv[0].Due_Date__c;
        newPaySchedule.Foreign_Investigation__c = lstfiv[0].Id;
        newPaySchedule.bt_stripe__Auto_Capture__c = true; 
        
        Test.startTest();
        ForeignInvestigationTriggerHelper.cancelPaymentSchedule(lstfiv);
        Test.stopTest();
        
    }
    
    @isTest static void createBTPaymentScheduleTest(){
        
        Foreign_Investigation__c foreignInv = new Foreign_Investigation__c();
        foreignInv.Case_Status__c='Closed - Paid in Full';
        foreignInv.Due_Date__c = System.today()+30;
        foreignInv.Negotiated_Amount__c=1500;
        foreignInv.Monthly_Payable__c=250;
        foreignInv.Payment_Duration__c=4;
        foreignInv.First_Payment__c=500;
        foreignInv.Registration_Date__c = System.today();
        foreignInv.Business_Type__c = 'LLP';
        foreignInv.Case_Initiated_By__c='Complaint';
        foreignInv.Business_Name__c='Test';
        foreignInv.Outstanding_Amount_Due__c=0;
        foreignInv.Auto_payment_plan__c=false;
        foreignInv.First_Payment_Done__c=false;
        insert foreignInv;
        
        Account acc = new Account();
        acc = BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con = BRS_TestDataFactory.createContactObject(acc.id);
        Contact Customer1 = new Contact(Allow_negative_balances__c = false, LastName = 'xyz');
        insert Customer1;
        
        Work_Order__c task = new Work_Order__c();
        task = BRS_TestDataFactory.createWorkOrderObject(Customer1.id, 'Online', 'Completed');
        task.Foreign_Investigation__c=foreignInv.id;
        update task;

        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn.Work_Order__c = task.id;
        txn.bt_stripe__Payment_Status__c = 'Authorized';
        txn.bt_stripe__Authorize_Only__c = true;
        insert txn;

        foreignInv.Auto_payment_plan__c=true;
        foreignInv.First_Payment_Done__c=true;
        update foreignInv;
        

                     
    }
}