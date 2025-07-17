@isTest
public class ACHPayment_Test {
    
    @TestSetup
    static void testSetup(){
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Name Reservation').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workOrdernew  = new Work_Order__c(
            Source__c = 'Online',
            Received_Date__c = System.Now(),
            Completed_Date__c = System.Today(),
            Status__c = System.Label.BRS_Status_Value_Completed,
            Customer__c = con.Id,
            Payment_Method__c = 'Credit Card'
        );
        insert workOrdernew;
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdMaintenance;
        filing2.Account__c=testAcc1.Id;
        filing2.Filing_Fee__c=30;
        filing2.Work_Order__c=workOrdernew.Id;
        filing2.Type__c = 'Business Name Reservation';
        filing2.Filing_Date__c = System.Today();
        filing2.Status__c='Approved';
        insert filing2;
        
        Customer_Balance_Transaction__c customerBal41 = new Customer_Balance_Transaction__c(
            Type__c = 'Debit',
            Amount__c = 2000,
            Payment_Source__c = 'Direct',
            Contact__c = workOrdernew.Customer__c
        );
        insert customerBal41;
    }
    testmethod static void getACHPaymentTest1() {
        HttpResponseMock mock = new HttpResponseMock(createResponseBody(true), 200, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        //BRS_TestDataFactory.createCommunityUser();
        
        String workOrderId = [Select Id FROM Work_Order__c].Id;
        String contactID = [Select Id FROM Contact].Id;
        String businessFilingId = [Select Id FROM Business_Filing__c].Id;
        ACHPaymentRequest.paymentParams reqString = new ACHPaymentRequest.paymentParams();
        reqString.selectedAccOwnerType = 'Personal';
        reqString.selectedAccType = '2';
        reqString.accNo = '12345';
        reqString.accNoConfirm = '12345';
        reqString.routingNo ='12345';
        reqString.firstName = 'Test first name';
        reqString.lastName = 'Test Last Name';
        reqString.companyName = 'Test Company name';
        reqString.attention = 'atte ';
        reqString.city = 'CIty';
        reqString.state  ='state';
        reqString.zip= '12345';
        reqString.street = 'Street';
        reqString.unit = '1';
        reqString.country = 'Country';
        reqString.internationalAddress = '';        
        reqString.phone = '1234452';
        reqString.email = 'a@a.com';
        reqString.amount = '60';
        reqString.workOrderId = workOrderId;
        reqString.filingId = businessFilingId;
        reqString.customerId = contactID;
        Test.startTest();
        String requestString = ACHPaymentController.getPaymentDetails(JSON.serialize(reqString));
        Test.stopTest();
        String requestStringAfterCallout  = ACHPaymentController.achPaymentCallout(requestString);
        
    }
    testmethod static void getACHPaymentTest2() {
        HttpResponseMock mock = new HttpResponseMock(createResponseBody(true), 200, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        //BRS_TestDataFactory.createCommunityUser();
        
        String workOrderId = [Select Id FROM Work_Order__c].Id;
        String contactID = [Select Id FROM Contact].Id;
        String businessFilingId = [Select Id FROM Business_Filing__c].Id;
        ACHPaymentRequest.paymentParams reqString = new ACHPaymentRequest.paymentParams();
        reqString.selectedAccOwnerType = 'Business';
        reqString.selectedAccType = '2';
        reqString.accNo = '12345';
        reqString.accNoConfirm = '12345';
        reqString.routingNo ='12345';
        reqString.firstName = 'Test first name';
        reqString.lastName = 'Test Last Name';
        reqString.companyName = 'Test Company name';
        reqString.attention = 'atte ';
        reqString.city = 'CIty';
        reqString.state  ='state';
        reqString.zip= '12345';
        reqString.street = 'Street';
        reqString.unit = '1';
        reqString.country = 'Country';
        reqString.internationalAddress = '';        
        reqString.phone = '1234452';
        reqString.email = 'a@a.com';
        reqString.amount = '60';
        reqString.workOrderId = workOrderId;
        reqString.filingId = businessFilingId;
        reqString.customerId = contactID;
        Test.startTest();
        String requestString = ACHPaymentController.getPaymentDetails(JSON.serialize(reqString));
        Test.stopTest();
        String requestStringAfterCallout  = ACHPaymentController.achPaymentCallout(requestString);
    }
    static String createResponseBody(Boolean achPayment) {
        ACHPaymentRequest.ACHPaymentResponse achResponse = new ACHPaymentRequest.ACHPaymentResponse();
        String cbId = [Select Id FROM Customer_Balance_Transaction__c].Id;
        if(achPayment == true) {
            achResponse.remittanceId = '1223435';
            achResponse.transactionId = cbId;
            achResponse.BOAtransactionNumber = '1223435';
            achResponse.responseCode = '0';
            achResponse.responseMessage = 'Transaction approved, no errors';
            achResponse.errorCode = '0';
            achResponse.errorMessage = '';
            achResponse.filler = '';
        }
        
        
        Map<String, ACHPaymentRequest.ACHPaymentResponse> testResponse = new Map<String, ACHPaymentRequest.ACHPaymentResponse>();
        testResponse.put('results', achResponse);        
        return JSON.serialize(achResponse);      
    }
}