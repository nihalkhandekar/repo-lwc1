@isTest
public class CertificateTriggerHelper_Test {
    @testSetup 
    static void setup() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con1 = BRS_TestDataFactory.createContactObject(acc.Id);
        
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Online', 'Completed');
        
        Payment_Method__c pm1 = new Payment_Method__c();
        pm1 = BRS_TestDataFactory.cardPaymentMethod(workOrder.id);        
        
        workOrder.Payments_Verified__c=true;
        update workOrder;
        
        OnOff_Filing_Auto_Refund__c onoff1 = BRS_TestDataFactory.onOffCustomSetting();
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();    
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId, acc.Id, workorder.Id, 'Amendment', 'Approved');
        
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();
        Master_Fee__c masterfee1 = new Master_Fee__c(Status__c=System.Label.ACTIVE,Start_Date__c=System.today().addDays(-2),End_Date__c=System.today().addDays(2),Filing_Type__c='Standard', Service_Type__c=System.Label.CertificateExpediteFee.trim(),Amount__c=100, External_ID__c='MF-0000000299');
        insert masterfee1;
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=mainRecTypeId1;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = acc.Id;
        cert.Business_Name__c=acc.Name;
        cert.Work_Order__c = WorkOrder.Id;
        cert.Include_Expedited_Service__c=false;
        insert cert;        
        cert.Type__c='Certificate of No Record';
        update cert;
        Master_Fee__c mf = new Master_Fee__c();
        mf.Amount__c=80.00;
        mf.External_ID__c ='MF-0000000061';
        mf.Status__c='Active';
        mf.Type__c='Certificate of Dissolution';
        mf.Start_Date__c=System.today();
        mf.Service_Type__c=System.Label.CertificateExpediteFee;
        insert mf;
        
        Copy_Request_Details__c copy = new Copy_Request_Details__c();
        copy.Account__c = acc.id;
        copy.Business_Filing__c = filing.id;
        copy.Other_Request__c = cert.id;
        insert copy;
    }
    
    testMethod static void updateFilingFeeCopyRequest() {
        try{
        Certficate__c cert = [Select Id, Name,RecordTypeId,Work_Order__c,Certificate_Type__c,Business_Name__c,Business__c,Total_Number_of_Plain_Copies__c,Total_Number_of_Certified_Copies__c,Include_Expedited_Service__c,	Include_Certified_Copy__c from Certficate__c where Type__c= 'Certificate of No Record' limit 1];
        Contact cont = [Select id from Contact];
        cert.Type__c=System.Label.Certificate_of_No_Record;
        cert.Business_Name__c='ABC corp';
        cert.recordTypeId=Schema.SObjectType.Certficate__c.getRecordTypeInfosByDeveloperName().get(System.label.Business_Copy_Request_RecordTypeAPI).getRecordTypeId();        
        update cert;
        Set<Id> setCert = new Set<Id>();
        List<Certficate__c> newCertList = new List<Certficate__c>();
        newCertList.add(cert);
        Map<Id, Certficate__c> oldMap = new Map<Id, Certficate__c>();
        oldMap.put(cert.Id,cert);   
        setCert.add(cert.Id);
        Map<Id, Decimal> oldMaptest = new Map<Id, Decimal>();
        oldMaptest.put(cert.Id,660.0); 
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn.Work_Order__c = cert.Work_Order__c;
        txn.bt_stripe__Amount__c = 90;
        txn.bt_stripe__Transaction_Status__c = 'Completed';
        txn.bt_stripe__Payment_Status__c = 'Captured';
        txn.bt_stripe__Related_Contact__c = cont.Id;
        txn.bt_stripe__Processed_Date__c = System.today();
        //txn.bt_stripe__Payment_Schedule__c = lstNewPaySchedule[0].Id;
        insert txn;
        test.startTest();
        
        CertificateTriggerHelper.updateFilingFee(newCertList,oldMap);
        CertificateTriggerHelper.processBTRefundforOtherRequest(setCert,oldMaptest);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    testMethod static void checkPaymentVerification() {
        Certficate__c cert = [Select Id, Name from Certficate__c where Type__c='Certificate of No Record' limit 1];
        cert.Status__c=system.label.BRS_FilingStatus_Approved;
        update cert;
        List<Certficate__c> newCertificates = new List<Certficate__c>();
        Map<Id, Certficate__c> oldCertificateMap = new Map<Id, Certficate__c>();
        oldCertificateMap.put(cert.Id,cert);
        
        test.startTest();
        CertificateTriggerHelper.checkPaymentVerification(newCertificates, oldCertificateMap);
        test.stopTest();
    }
    
    testMethod static void checkAccountForNoRecord(){
        Certficate__c cert = [Select Id, Name,Business_Name__c,Type__c from Certficate__c where Type__c='Certificate of No Record' limit 1];
        List<Certficate__c> newCertList = new List<Certficate__c>();
        newCertList.add(cert);        
        
        test.startTest();
        CertificateTriggerHelper.checkAccountForNoRecord(newCertList);
        test.stopTest();
    }
    
    testMethod static void testUpdateFiling(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con1 = [Select id from contact limit 1];
        
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Mail', 'Completed');
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Master_Fee__c masterfee4 = new Master_Fee__c(Status__c=System.Label.ACTIVE,Start_Date__c=System.today().addDays(-2),End_Date__c=System.today().addDays(2),Filing_Type__c='Standard', Service_Type__c=System.Label.CertificateExpediteFee.trim(),Amount__c=100, External_ID__c='MF-0000000409');
        insert masterfee4;
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=mainRecTypeId1;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = acc.Id;
        cert.Business_Name__c=acc.Name;
        cert.Work_Order__c = WorkOrder.Id;
        cert.Include_Expedited_Service__c=true;
        cert.Total_Number_of_Plain_Copies__c=1;
        cert.Total_Number_of_Certified_Copies__c=1;
        cert.Status__c='Approved';
        insert cert;        
        cert.Type__c='Certificate of No Record';
        cert.Business_Name__c='ABC corp';
        update cert;
        
    }
    
    testmethod static void refundRejectedOnlineFilingsTest(){
        
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con1 = [Select id from contact limit 1];
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Mail', 'Completed');
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Master_Fee__c masterfee4 = new Master_Fee__c(Status__c=System.Label.ACTIVE,Start_Date__c=System.today().addDays(-2),End_Date__c=System.today().addDays(2),Filing_Type__c='Standard', Service_Type__c=System.Label.CertificateExpediteFee.trim(),Amount__c=100, External_ID__c='MF-0000000409');
        insert masterfee4;
        
        List<Certficate__c> lstnewcert=new List<Certficate__c>();
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=mainRecTypeId1;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = acc.Id;
        cert.Business_Name__c=acc.Name;
        cert.Work_Order__c = WorkOrder.Id;
        cert.Include_Expedited_Service__c=true;
        cert.Total_Number_of_Plain_Copies__c=1;
        cert.Total_Number_of_Certified_Copies__c=1;
        cert.Status__c='Rejected';
        lstnewcert.add(cert);
        insert lstnewcert;
        
        
        Map<id,Certficate__c> mapoldcert= new Map<id,Certficate__c>();
        Certficate__c oldcert = new Certficate__c();
        oldcert.RecordTypeId=mainRecTypeId1;
        oldcert.Type__c='Certificate of Legal Existence';
        oldcert.Certificate_Type__c='Standard';
        oldcert.Business__c = acc.Id;
        oldcert.Business_Name__c=acc.Name;
        oldcert.Work_Order__c = WorkOrder.Id;
        oldcert.Include_Expedited_Service__c=true;
        oldcert.Total_Number_of_Plain_Copies__c=1;
        oldcert.Total_Number_of_Certified_Copies__c=1;
        oldcert.Status__c='Approved';
        mapoldcert.put(oldcert.id,oldcert);
        
        
        Customer_Balance_Transaction__c customerBal = new Customer_Balance_Transaction__c();
        customerBal=BRS_TestDataFactory.createCustomerBalanceTransactionObject(con1.id,'Debit',4000);
        
        test.startTest();
        //CertificateTriggerHelper.refundRejectedOnlineFilings(lstnewcert,null);
        test.stopTest();
    }
    
}