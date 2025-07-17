@IsTest
public class SAP_ApoSubmittedRequestControllerTest {
    @testSetup
    static void setupTestData() {
        

        RecordType newRegulatoryTrxnFee = [SELECT Id FROM RecordType WHERE DeveloperName = 'New_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        RecordType CreateTransactionRegulatoryTrxnFeeItem = [SELECT Id FROM RecordType WHERE DeveloperName = 'Create_Transaction' AND SObjectType = 'RegulatoryTrxnFeeItem' LIMIT 1];
        RecordType rtApostille = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];


        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
             
        List<IndividualApplication> applications = new List<IndividualApplication>();
        String state='';
        String recordTypeName = ''; 
        
        for (Integer i = 0; i < 10; i++) {
            if (i == 0) {
                state='Submitted';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            } else if (i == 1) {
                state='Completed';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            } else if (i == 2) {
                state='Draft';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            }
                 else if (i == 3) {
                state='Cancelled';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            }
            else if (i == 4) {
                state='In Review';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            } else if (i == 5) {
                state='Application Accepted';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            } else if (i == 6) {
                state='Approved';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            } else if (i == 7) {
                state='Denied';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            }
            //  else if (i == 8) {
            //     state='Order Completed - Mail';
            //     recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            // } 
            else if (i == 9) {
                state='Order Completed – Pick Up';
                recordTypeName =Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('Apostille').getRecordTypeId();
            }

            IndividualApplication app = new IndividualApplication(
                LicenseTypeId = licenseType.Id,
                SAP_Organization_Name__c = 'Test Organization ' + i,
                SAP_First_Name__c = 'John'+i,
                SAP_Last_Name__c = 'Doe'+i,
                AppliedDate = System.today().addDays(-i),
                SAP_Country__c = 'USA',
                Status = state,
                Category = 'DRAFT',
                RecordTypeId = recordTypeName
            );
            applications.add(app);
        }
        insert applications;
        
        DocumentType doctype=new DocumentType();

       
        List<DocumentChecklistItem> docs = new List<DocumentChecklistItem>();
        for (IndividualApplication app : applications) {
            DocumentChecklistItem doc = new DocumentChecklistItem(
                Name = 'TestType',
                ParentRecordId = app.Id,
                SAP_Certificate_Number__c = 'CERT-001',
                SAP_Country__c = 'USA',
                Status = 'Verified',
                DocumentTypeId = doctype.id
            );
            docs.add(doc);
        }
        insert docs;

        String paymentData ='{\"orderId\":\"9210355414445943A\",\"authorizationId\":\"7K956590WH980421H\",\"status\":\"COMPLETED\",\"amount\":\"15.00\",\"currency\":\"USD\",\"lastFourDigits\":\"4632\",\"cardName\":\"Telstra\",\"cardBrand\":\"VISA\",\"cardType\":\"CREDIT\",\"documents\":[{\"id\":1,\"rowId\":1,\"type\":\"\",\"country\":\"\",\"hague\":\"True\",\"person\":\"\",\"fee\":\"15.00\",\"baseFee\":\"15.00\",\"feeDisplay\":\"$15.00\",\"uploadedFiles\":[],\"expediteFee\":\"0.00\",\"isExpedited\":false,\"hagueStr\":\"Yes\",\"typeOfDocument\":\"Adoption Documents\",\"showUploadField\":false,\"documentChange\":false,\"destinationCountry\":\"ANGUILLA\",\"personName\":\"James\"}]}';
        Id RegulatoryTrxnFeeRecord = SAP_PaypalPaymentCtrl.savePayment(paymentData);

        RegulatoryTrxnFee trxn2=[select Id from RegulatoryTrxnFee where Id = : RegulatoryTrxnFeeRecord limit 1];

        trxn2.SAP_Auth_Code__c = '567';
        trxn2.ParentRecordId=applications[0].Id;

        update trxn2;


        


        RegulatoryTrxnFee txn1 = new RegulatoryTrxnFee(ParentRecordId = applications[0].Id, SAP_Payment_Type__c = 'Card',SAP_Auth_Code__c= '567',SAP_Transaction_Id__c='',SAP_Card_Type__c='VISA', SAP_Brand__c = 'Visa', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today(),RecordTypeId=newRegulatoryTrxnFee.Id);
        insert new List<RegulatoryTrxnFee>{txn1};

        RegulatoryTrxnFeeItem feeItem1 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 1', 
            RegulatoryTrxnFeeId = trxn2.Id, 
            FeeAmount = 150.00,
            RecordTypeId=CreateTransactionRegulatoryTrxnFeeItem.Id
          );
         RegulatoryTrxnFeeItem feeItem2 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 2', 
            RegulatoryTrxnFeeId = trxn2.Id, 
            FeeAmount = 250.00,
            RecordTypeId=CreateTransactionRegulatoryTrxnFeeItem.Id
         );

         insert new List<RegulatoryTrxnFeeItem>{feeItem1,feeItem2};

    }
    
    @isTest
    static void testGetApplications() {
        DocumentType doctype=new DocumentType();
        
    Map<String, Object> params = new Map<String, Object>{
        'workOrder' => 'WO-00',
        'requestDate' => null,
        'requesterName' => 'Test Organization',
        'documentType' => doctype.Id,
        'workOrderStatus' => 'Submitted',
        'offsetVal' => 0,
        'pageSize' => 10,
        'sortBy' => 'ApplicationID',
        'sortDirection' => 'ASC'
        //'requestDate' => '2025-02-09'
           
    };
    
    String paramsJson = JSON.serialize(params);

    
    Test.startTest();
    List<Map<String, Object>> results = SAP_ApostilleSubmittedRequestController.getApplications(paramsJson);
    Test.stopTest();
}
    
   @isTest
    static void testGetApplicationsCount() {
        Test.startTest();
        String paramsJson = '{"workOrder":"WO-001","requesterName" :"Test Organization","workOrderStatus":"Submitted","offsetVal":0}';
        Integer count = SAP_ApostilleSubmittedRequestController.getApplicationsCount(paramsJson);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateApplicationStatusToCancelled() {
        list<IndividualApplication> application = [SELECT Id FROM IndividualApplication WHERE Status = 'Submitted' OR  Status = 'Completed' OR  Status = 'Draft' OR  Status = 'Cancelled' OR  Status = 'In Review' OR  Status = 'Application Accepted' OR  Status = 'Approved' OR  Status = 'Denied' OR  Status = 'Order Completed - Mail' OR  Status = 'Order Completed – Pick Up'];
        Test.startTest();
        for(IndividualApplication app: application){
            Boolean result = SAP_ApostilleSubmittedRequestController.updateApplicationStatusToCancelled(app.Id);
        }
        Test.stopTest();
    }
    
     @isTest
    static void testGetApplicationCountsByStatus() {
        Test.startTest();
        Date startDate = Date.today().addDays(-10);
        Date endDate = Date.today();
        Map<String, Integer> counts = SAP_ApostilleSubmittedRequestController.getApplicationCountsByStatus(startDate, endDate);
        Test.stopTest();
    }
    
    @isTest
    static void testGetApplications_invalidQuery() {
        Test.startTest();
        String paramsJson = '{"workOrder":"INVALID", "pageSize":10, "offsetVal":0}';
        List<Map<String, Object>> results = SAP_ApostilleSubmittedRequestController.getApplications(paramsJson);
        Test.stopTest();
    }

    // @isTest
    // static void getDocumentsByApplicationTest() {
    //     SAP_ApostilleSubmittedRequestController submitRequest = new SAP_ApostilleSubmittedRequestController();
    //     list<IndividualApplication> applicationId = [SELECT Id FROM IndividualApplication WHERE Status = 'Submitted' OR  Status = 'Completed' OR  Status = 'Draft' OR  Status = 'In Review' OR  Status = 'Application Accepted' OR  Status = 'Approved' OR  Status = 'Denied' OR  Status = 'Order Completed - Mail' OR  Status = 'Order Completed – Pick Up' OR  Status = 'Cancelled' ];
    //     set<IndividualApplication> applicationSet= new set<IndividualApplication>(applicationId);
        

    //     Test.startTest();
    //         Boolean result = submitRequest.getDocumentsByApplication(applicationSet);
    //     Test.stopTest();
    // }


}