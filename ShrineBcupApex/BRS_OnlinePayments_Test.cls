@isTest
public class BRS_OnlinePayments_Test {
    @isTest(SeeAllData=false)
    static void createDebitRecordsTest() 
    {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 123';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 123' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
        system.debug('conId '+ conId + accId);
        Customer_Balance_Transaction__c customerBal = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',100);
        customerBal.Payment_Source__c='Voucher';
        update customerBal; 
        Customer_Balance_Transaction__c customerBal1 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal1.Payment_Source__c='Voucher';
        update customerBal1;
        Customer_Balance_Transaction__c customerBal10 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',250);
        customerBal10.Payment_Source__c='Voucher';
        update customerBal10; 
        Customer_Balance_Transaction__c customerBal11 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal11.Payment_Source__c='Voucher';
        update customerBal11;        
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',100);
        customerBal2.Payment_Source__c='Trademark Balance';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Trademark Balance';
        update customerBal3;    
        
        Customer_Balance_Transaction__c customerBal4 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',100);
        customerBal4.Payment_Source__c='Direct';
        update customerBal4; 
        Customer_Balance_Transaction__c customerBal5 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal5.Payment_Source__c='Direct';
        update customerBal5; 
            
        Customer_Balance_Transaction__c customerBal6 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',100);
        Customer_Balance_Transaction__c customerBal7 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);

            
        Customer_Balance_Transaction__c customerBal8 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',100);
        customerBal8.Payment_Source__c='Card';
        update customerBal8; 
        Customer_Balance_Transaction__c customerBal9 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal9.Payment_Source__c='Card';
        update customerBal9;    
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=100;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
    }
    
}
    @isTest(SeeAllData=false)
    static void createDebitRecordsTest1() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Trademark Balance';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Trademark Balance';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=100;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
    
        @isTest(SeeAllData=false)
        static void createDebitRecordsTest2() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Direct';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Direct';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=100;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
    
        @isTest(SeeAllData=false)
        static void createDebitRecordsTest3() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Check';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Check';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=100;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
        
        @isTest(SeeAllData=false)
        static void createDebitRecordsTest4() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Card';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Card';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=100;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
    
        @isTest(SeeAllData=false)
        static void createDebitRecordsTest5() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Card';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Card';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=40;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
    
        @isTest(SeeAllData=false)
        static void createDebitRecordsTest6() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Check';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Check';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=40;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }
          @isTest(SeeAllData=false)
        static void createDebitRecordsTest7() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Direct';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Direct';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=40;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }  
            @isTest(SeeAllData=false)
        static void createDebitRecordsTest8() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        con.FirstName='Test 1234';
        update con;
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User u=new User();
        u=BRS_TestDataFactory.createCommunityUser(con,profileId);
        
        system.runAs(u){
        Id conId = [select id from Contact where FirstName = 'Test 1234' limit 1].id;
        Id accId = [select id from Account where Name = 'Test Account' limit 1].id;
            
        Customer_Balance_Transaction__c customerBal2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Debit',150);
        customerBal2.Payment_Source__c='Voucher';
        update customerBal2; 
        Customer_Balance_Transaction__c customerBal3 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(conId,'Credit',200);
        customerBal3.Payment_Source__c='Voucher';
        update customerBal3; 
            
            
        Work_Order__c workorder=BRS_TestDataFactory.createWorkOrderObject(conId,'Online','Open');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,accId,workorder.id,'Change of Email Address','Completed');
        Decimal deductedAmountValue=40;
        List<BRS_OnlinePayments.Requests> reqList =  new List<BRS_OnlinePayments.Requests>();
        BRS_OnlinePayments.Requests req = new BRS_OnlinePayments.Requests();
        req.workorderId = workorder.id;
        req.filingId=filing.id;
        req.contactId=conId;
        req.deductedAmount=deductedAmountValue;
        reqList.add(req);
        Test.startTest();
        BRS_OnlinePayments.createDebitRecords(reqList); 
            
            
            
        Test.stopTest();  
            
            
            
        }
        
        
    }   
}