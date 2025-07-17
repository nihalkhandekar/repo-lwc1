@isTest
public class SAP_FinsysWorkOrderControllerTest {

    @TestSetup
    static void setupTestData() {
        
        // Query existing metadata records (Ensure these records exist in your org)
        List<FinSys_Activity_SubActivity__mdt> activityMetadataList = [
            SELECT Id, Activity__c, Sub_Activity__c, Program_Code__c FROM FinSys_Activity_SubActivity__mdt
            WHERE Activity__c = 'Authentication/Apostille' AND Sub_Activity__c = 'Adoption, Regular, Regular Expedited'
        ];
        system.debug('activityMetadataList=='+activityMetadataList);
        
        
        

        List<FinSys_Activity_SubActivity_Fees__mdt> feeMetadataList = [
            SELECT Id, Activity__c, Sub_Activity__c, Fee__c FROM FinSys_Activity_SubActivity_Fees__mdt
            WHERE Activity__c = 'Authentication/Apostille' AND Sub_Activity__c = 'Regular'
        ];
         system.debug('feeMetadataList=='+feeMetadataList);
        
        
         Id recordTypeid = [ SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Enterprise' LIMIT 1].Id;
         Id recordTypeidofFinSys = [ SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers' LIMIT 1].Id;
         Id recordTypeidfortransaction = [ SELECT Id FROM RecordType WHERE SObjectType = 'RegulatoryTrxnFee' AND DeveloperName = 'Refund_Transaction' LIMIT 1].Id;
        // Id recordTypeidforrefundtransaction = [ SELECT Id FROM RecordType WHERE SObjectType = 'RegulatoryTrxnFee' AND DeveloperName = 'Refund_Transaction' LIMIT 1].Id;
          system.debug('recordTypeidfortransaction==='+recordTypeidfortransaction);
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Enterprise',
            LastName ='test',
            Email = 'test.contact@example.com',
            Phone = '1234567890',
			RecordTypeId = recordTypeid,
            SAP_Organization__c ='SAPDEV',
            SAP_Customer_Account_Balance__c = 10000,
            SAP_Residence_City__c = 'Ahemdabad',
            SAP_Residence_Zip_Code__c ='364002',
            SAP_Residence_State__c ='GU',
            SAP_Residence_Country__c ='	India'
        );
        insert testContact;
        
        Contact testContactforFinSys = new Contact(
            FirstName = 'Test',
            LastName ='data',
            Email = 'test.contact@example.com',
            Phone = '1234567890',
			RecordTypeId = recordTypeidofFinSys
        );
        insert testContactforFinSys;
        
        Contact testContactforRefundTxn = new Contact(
            FirstName = 'RefundTest',
            LastName ='RefundData',
            Email = 'RefundData.contact@example.com',
            Phone = '1234567890'
        );
        insert testContactforRefundTxn;
        
        
		
        // Create test Work Order
        Work_Order__c testWorkOrder = new Work_Order__c(
            Customer__c = testContact.Id,
            Status__c = 'Open',
            Type__c = 'UCC'
                                                     
        );
        insert testWorkOrder;
     
      
        // Create test Transaction
        bt_stripe__Transaction__c testTransaction = new bt_stripe__Transaction__c(
            Work_Order__c = testWorkOrder.Id,
            bt_stripe__Amount__c = 100.00
        );
        insert testTransaction;
        
        Batch__c testBatch=new Batch__c(
            SAP_Batch_Name__c = 'Authentication/Apostille',
            SAP_Batch_Status__c = 'Open',
            SAP_Batch_Date__c = Date.today()
        );
        insert testBatch;
        
        Batch__c testBatchforInvalidvalue=new Batch__c(
            SAP_Batch_Name__c = 'Authentication/Apostille',
            SAP_Batch_Status__c = 'Closed',
            SAP_Batch_Date__c = Date.today()
        );
        insert testBatchforInvalidvalue;
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        IndividualApplication indApp = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'Test',
            SAP_Last_Name__c = 'Contact',
            Category='License',
            Contact__c = testContact.Id,
            AppliedDate = Date.today(),
            SAP_City__c = 'Ahemdabad',
            SAP_State__c = 'Gujarat',
            SAP_Country__c = 'India',
            SAP_Zip_Code__c = '1234',
            SAP_Organization_Name__c ='TestOrg',
            SAP_Email_Address__c = 'test.contact@example.com',
            SAP_Cell_Phone_Number__c = '1234567890',
            SAP_Work_Order_Status__c = 'Open',
            SAP_Work_Order_Comments__c = 'Test Comments'
          
            
        );
        insert indApp;
        
         RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            ParentRecordId = indApp.Id,
            SAP_Auth_Code__c = 'AUTH123',
            SAP_Transaction_Date__c = Date.today(),
            SAP_Payment_Type__c = 'Card',
            SAP_Card_Number__c = 1234,
            SAP_Brand__c = 'Visa',
            Status = 'DRAFT',
            SAP_Payment_Collection__c ='IRS (ACH)',
            SAP_Refund_Reason__c ='Customer Request',
            SAP_Refund_ID__c ='',
            SAP_Refund_Voucher_ID__c ='',
            SAP_Transaction_Status__c = 'Pending',
            SAP_Transaction_Id__c ='TXN123'
                     
        );
        insert fee;
        system.debug('fee.ParentRecordId==='+fee.ParentRecordId);
        
        
          RegulatoryTrxnFeeItem existingFeeItems = new RegulatoryTrxnFeeItem(
            Name = 'TestItem',
            SAP_Select_Activity__c = 'Sales',
            //SAP_Select_Sub_Activity__c = 'Regular', 
            //SAP_Select_Program_Code__c = 'Board of Accountancy',
            SAP_Tax_Exempt__c = true, 
            SAP_Transaction_Date__c = Date.today(),
            RegulatoryTrxnFeeId = fee.Id,
            FeeAmount = 100.00,
            SAP_Card_Type__c ='Visa',
             // SAP_Activity_Code__c = 'Test Sub Activity',
            //SAP_Credit_Card_Number__c ='12345678',
            SAP_Payment_Type__c ='Card',
               SAP_Refund_Reason__c ='Customer Request'
           // RecordTypeId = recordTypeidfortransaction
        );
        insert existingFeeItems;
        
        
         IndividualApplication indAppforrefund = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'Test2',
            SAP_Last_Name__c = 'Contact2',
            Category='License',
            Contact__c = testContactforRefundTxn.Id,
            AppliedDate = Date.today(),
            SAP_City__c = 'Ahemdabad',
            SAP_State__c = 'Gujarat',
            SAP_Country__c = 'India',
            SAP_Zip_Code__c = '1234',
            SAP_Organization_Name__c ='TestOrg',
            SAP_Email_Address__c = 'test.contact@example.com',
            SAP_Cell_Phone_Number__c = '1234567890',
            SAP_Work_Order_Status__c = 'Open',
            SAP_Work_Order_Comments__c = 'Test Comments'
          
            
        );
        insert indAppforrefund;
        
         RegulatoryTrxnFee feeforrefund = new RegulatoryTrxnFee(
            ParentRecordId = indAppforrefund.Id,
            SAP_Auth_Code__c = 'AUTH123',
            SAP_Transaction_Date__c = Date.today(),
            SAP_Payment_Type__c = 'Card',
            SAP_Card_Number__c = 1234,
            SAP_Brand__c = 'Visa',
            Status = 'DRAFT',
            SAP_Payment_Collection__c ='IRS (ACH)',
            SAP_Refund_Reason__c ='Customer Request',
            SAP_Refund_ID__c ='',
            SAP_Refund_Voucher_ID__c ='',
            SAP_Transaction_Status__c = 'Pending',
            SAP_Transaction_Id__c ='TXN123',
            RecordTypeId =recordTypeidfortransaction
                     
        );
        insert feeforrefund;
        system.debug('fee.ParentRecordId==='+fee.ParentRecordId);
        
        
          RegulatoryTrxnFeeItem FeeItemsforrefund = new RegulatoryTrxnFeeItem(
            Name = 'TestItem2',
            SAP_Select_Activity__c = 'Sales',
            //SAP_Select_Sub_Activity__c = 'Regular', 
            //SAP_Select_Program_Code__c = 'Board of Accountancy',
            SAP_Tax_Exempt__c = true, 
            SAP_Transaction_Date__c = Date.today(),
            RegulatoryTrxnFeeId = feeforrefund.Id,
            FeeAmount = 100.00,
            SAP_Card_Type__c ='Visa',
             // SAP_Activity_Code__c = 'Test Sub Activity',
            //SAP_Credit_Card_Number__c ='12345678',
            SAP_Payment_Type__c ='Card',
            SAP_Refund_Reason__c ='Customer Request'
          //  RecordTypeId = recordTypeidfortransaction
        );
        insert FeeItemsforrefund;
        
        
       ContentVersion contentVersion = new ContentVersion(
            Title = 'signature_test',
            PathOnClient = 'signature.png',
            VersionData = Blob.valueOf('Sample Signature Data'),
            IsMajorVersion = true
        );
        insert contentVersion;

         Id contentDocumentId = [
            SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id
        ].ContentDocumentId;

        //   Link ContentDocument to Individual Application
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = indApp.Id,
            ContentDocumentId = contentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert contentDocLink;
        
        
         Activity__c activity = new Activity__c(
            Activity_Name__c = 'Authentication/Apostille',
            Sub_Activity_Name__c = 'Sub Activity A',
            Program_Name__c = 'Program X',
            FeeAmount__c = 100.00,
            TaxExempt__c = false,
            TransactionDate__c = Date.today(),
            Individual_Application__c = indApp.Id
        );
        insert activity;
        
         ActivityTransactionItemMapping__c mapping = new ActivityTransactionItemMapping__c(
            Regulatory_Transaction_Fee__c = fee.Id,
            Activity__c = activity.Id,
            Transaction_Type__c = 'New Transaction'
        );
        insert mapping;
    }

    @isTest
    static void testGetActivityData() {
        Test.startTest();
        List<Map<String, Object>> activityData = SAP_FinsysWorkOrderController.getActivityData();
        Test.stopTest();

    }

    @isTest
    static void testGetActivityFee() {
        Test.startTest();
        Decimal fee = SAP_FinsysWorkOrderController.getActivityFee('Authentication/Apostille', 'REGULAR');
        Test.stopTest();

        
    }
    @isTest
    static void testSearchContacts() {
        //Contact testContact = [SELECT id, Name FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        Test.startTest();
        List<Contact> contacts = SAP_FinsysWorkOrderController.searchContacts('Test');
        Test.stopTest();

    }
     @isTest
    static void testCreateWorkOrder() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        IndividualApplication indApp = [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test' ];

        Map<String, Object> workOrderData = new Map<String, Object>{
            'selectedCustomerId' => testContact.Id,
                'recordId' => indApp.Id,
            'workOrderDate' => String.valueOf(Date.today()),
            'customerDetails' => new Map<String, Object>{
                'firstName' => 'Test',
                'lastName' => 'Contact',
                'emailAddress' => 'test.contact@example.com',
                'phoneNumber' => '1234567890',
                'address' => new Map<String, Object>{
                    'street' => '123 Test St',
                    'city' => 'Test City',
                    'state' => 'Test State',
                    'zipCode' => '12345',
                    'country' => 'Test Country'
                }
            },
            'transactions' => new List<Object>{
                new Map<String, Object>{
                    'activity' => 'Authentication/Apostille',
                    'Sub Activity' => 'Regular',
                    'activityCode' => 'Regular',
                    //'programCode' => 'Board of Accountancy',
                    'paymentAmount' => '100.00',
                    'paymentType' =>'Card',
                    'cardType' =>'Visa',
                    'taxExempt' => true,
                    'reportingOnly' => true,
                    'cardDigit' => '12345678'
                    
                }
            },
            'defaultActivity' => 'Authentication/Apostille',
            'Transaction_Type' =>'Normal'
        };

        Test.startTest();
        Map<String, Object> result = SAP_FinsysWorkOrderController.createWorkOrder(JSON.serialize(workOrderData));
        Test.stopTest();

    }
    
    @isTest
    static void testCreateWorkOrder_existingBatch_null() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        IndividualApplication indApp = [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'];
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion limit 1].Id;
        List<String> deletedFileIds = new List<String>{ String.valueOf(contentDocumentId) };
            
       Blob sampleBlob = Blob.valueOf('This is a test file');
       String validBase64 = EncodingUtil.base64Encode(sampleBlob);
       System.debug('Valid Base64 String: ' + sampleBlob);




        Map<String, Object> workOrderData = new Map<String, Object>{
    'workOrderId' => indApp.Id,
    'workOrderDate' => String.valueOf(Date.today()),
    'customerDetails' => new Map<String, Object>{
        'firstName' => 'Test',
        'lastName' => 'Contact',
        'emailAddress' => 'test.contact@example.com',
        'phoneNumber' => '1234567890',
        'address' => new Map<String, Object>{
            'street' => '123 Test St',
            'city' => 'Test City',
            'state' => 'Test State',
            'zipCode' => '12345',
            'country' => 'Test Country'
        }
    },
    'transactions' => new List<Object>{
        new Map<String, Object>{
            'activity' => 'Authentication/Apostille',
            'Sub Activity' => 'Regular',
            'activityCode' => 'Regular',
            //'programCode' => 'Board of Accountancy',
            'paymentAmount' => '100.00',
            'paymentType' => 'Card',
            'cardType' => 'Visa',
            'taxExempt' => true,
            'reportingOnly' => true,
            'cardDigit' => '12345678'
        }
    },
    'defaultActivity' => 'Sales',
    'Transaction_Type' => 'Normal',
    'deletedFiles' => new List<String>{ contentDocumentId },
    'documents' => new List<Object>{
        new Map<String, Object>{
            'docType' => 'Invoice',
            'documentId' => '069XXXXXXXXXXXXAAA', 
            'docFile' => new Map<String, Object>{
                'fileName' => 'invoice.pdf',
                'base64Data' => validBase64, 
                'contentType' => 'application/pdf'
            }
        },
        new Map<String, Object>{
            'docType' => 'Receipt',
            'docFile' => new Map<String, Object>{
                'fileName' => 'receipt.png',
                'base64Data' => validBase64,
                'contentType' => 'image/png'
            }
        }
    }
};


        Test.startTest();
        Map<String, Object> result = SAP_FinsysWorkOrderController.createWorkOrder(JSON.serialize(workOrderData));
        Test.stopTest();

    }

    @isTest
    static void testUpdateWorkOrder() {
        //Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Batch__c  testBatch = [SELECT Id FROM Batch__c LIMIT 1];
        IndividualApplication indApp = [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'];
        
        Map<String, Object> workOrderData = new Map<String, Object>{
            'recordId' => indApp.Id,
                'batchId' => testBatch.Id,
            'selectedCustomerId' => testContact.Id,
                'defaultActivity' =>'Authentication/Apostille',
                'updatedActivity' =>'Sales',
            'workOrderDate' => String.valueOf(Date.today()),
            'customerDetails' => new Map<String, Object>{
                'firstName' => 'Test',
                'lastName' => 'Contact',
                'emailAddress' => 'test.contact@example.com',
                'phoneNumber' => '1234567890',
                'address' => new Map<String, Object>{
                    'street' => '123 Test St',
                    'city' => 'Test City',
                    'state' => 'Test State',
                    'zipCode' => '12345',
                    'country' => 'Test Country'
                }
            },
            'transactions' => new List<Object>{
                new Map<String, Object>{
                    'activity' => 'Authentication/Apostille',
                    'Sub Activity' => 'Regular',
                    'activityCode' => 'Regular',
                    //'programCode' => 'Board of Accountancy',
                    'paymentAmount' => '100.00',
                    'paymentType' =>'Card',
                    'cardType' =>'Visa',
                    'taxExempt' => true,
                    'reportingOnly' => true,
                    'cardDigit' => '12345678'
                }
            },
                'Transaction_Type' =>'Normal'
        };

        Test.startTest();
        Map<String, Object> result = SAP_FinsysWorkOrderController.updateWorkOrder(JSON.serialize(workOrderData));
        Test.stopTest();

    }
    
      @isTest
    static void testUpdateWorkOrder_existingBatch_null() {
        //Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Batch__c  testBatchforInvalidvalue = [SELECT Id FROM Batch__c LIMIT 1];
        IndividualApplication indApp = [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'];
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion limit 1].Id;
        
         List<String> deletedFileIds = new List<String>{ String.valueOf(contentDocumentId) };
            
       Blob sampleBlob = Blob.valueOf('This is a test file');
       String validBase64 = EncodingUtil.base64Encode(sampleBlob);
       System.debug('Valid Base64 String: ' + sampleBlob);

        
        Map<String, Object> workOrderData = new Map<String, Object>{
            'recordId' => indApp.Id,
                //'batchId' => testBatch.Id,
            'selectedCustomerId' => testContact.Id,
                //'defaultActivity' =>'Authentication/Apostille',
                'updatedActivity' =>'Sales',
            'workOrderDate' => String.valueOf(Date.today()),
            'customerDetails' => new Map<String, Object>{
                'firstName' => 'Test',
                'lastName' => 'Contact',
                'emailAddress' => 'test.contact@example.com',
                'phoneNumber' => '1234567890',
                'address' => new Map<String, Object>{
                    'street' => '123 Test St',
                    'city' => 'Test City',
                    'state' => 'Test State',
                    'zipCode' => '12345',
                    'country' => 'Test Country'
                }
            },
            'transactions' => new List<Object>{
                new Map<String, Object>{
                    'activity' => 'Authentication/Apostille',
                    'Sub Activity' => 'Regular',
                    'activityCode' => 'Regular',
                    //'programCode' => 'Board of Accountancy',
                    'paymentAmount' => '100.00',
                    'paymentType' =>'Card',
                    'cardType' =>'Visa',
                    'taxExempt' => true,
                    'reportingOnly' => true,
                    'cardDigit' => '12345678'
                }
            },
                'tnxId' => 'TXN123',
                'Transaction_Type' =>'Normal',
                    'deletedFiles' => new List<String>{ contentDocumentId },
                    'documents' => new List<Object>{
                        new Map<String, Object>{
                               'docType' => 'Invoice',
                               'documentId' => '069XXXXXXXXXXXXAAA', 
                               'docFile' => new Map<String, Object>{
                               'fileName' => 'invoice.pdf',
                               'base64Data' => null, 
                               'contentType' => 'application/pdf'
            }
        },
        new Map<String, Object>{
            'docType' => 'Receipt',
            'docFile' => new Map<String, Object>{
                'fileName' => 'receipt.png',
                'base64Data' => null,
                'contentType' => 'image/png'
            }
        }
    }
                
        };

        Test.startTest();
        Map<String, Object> result = SAP_FinsysWorkOrderController.updateWorkOrder(JSON.serialize(workOrderData));
        Test.stopTest();

    }
    
      
  @isTest
    static void testGetWorkOrderDetailsUpdated_NewTransaction() {
        IndividualApplication indApp = [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Map<String, Object> requestData = new Map<String, Object>{
            'workOrderId' => indApp.Id,
            'transactionType' => 'New Transaction',
             'transactions' => new List<Object>{
                new Map<String, Object>{
                    'activity' => 'Authentication/Apostille',
                    'Sub Activity' => 'Regular',
                    'activityCode' => 'Regular',
                    //'programCode' => 'Board of Accountancy',
                    'paymentAmount' => '100.00',
                    'paymentType' =>'Card',
                    'cardType' =>'Visa',
                    'taxExempt' => true,
                    'reportingOnly' => true,
                    'cardDigit' => '12345678'
                }
            },
                'selectedCustomerId' => testContact.Id,
                'defaultActivity' =>'Authentication/Apostille',
                'updatedActivity' =>'Sales',
            'workOrderDate' => String.valueOf(Date.today()),
            'customerDetails' => new Map<String, Object>{
                'firstName' => 'Test',
                'lastName' => 'Contact',
                'emailAddress' => 'test.contact@example.com',
                'phoneNumber' => '1234567890',
                'address' => new Map<String, Object>{
                    'street' => '123 Test St',
                    'city' => 'Test City',
                    'state' => 'Test State',
                    'zipCode' => '12345',
                    'country' => 'Test Country'
                }
            }
            
        };

        //Test.setCurrentUser(UserInfo.getUserId());
        Map<String, Object> response =  SAP_FinsysWorkOrderController.getWorkOrderDetailsUpdated(JSON.serialize(requestData));
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetWorkOrderDetailsUpdated_RefundTransaction() {
        Test.startTest();
        Map<String, Object> requestData = new Map<String, Object>{
            'workOrderId' => [SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test2'].Id,
            'transactionType' => 'Refund Transaction'
        };

        Map<String, Object> response = SAP_FinsysWorkOrderController.getWorkOrderDetailsUpdated(JSON.serialize(requestData));
        Test.stopTest();
    }

    @isTest
    static void testGetBRSdata() {
        Work_Order__c testWorkOrder = [SELECT Id, Customer__c FROM Work_Order__c LIMIT 1];

        Test.startTest();
        Map<String, Object> brsData = SAP_FinsysWorkOrderController.getBRSdata(testWorkOrder.Id);
        Test.stopTest();

        
    }
    
    
    
    @isTest
static void testUpdateRefundTransaction() {
    Test.startTest();
    RegulatoryTrxnFee fee = [select id, ParentRecordId from RegulatoryTrxnFee limit 1];
    system.debug('ParentRecordId===='+fee.ParentRecordId);
    
    // Prepare the JSON input for the method
    List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
    Map<String, Object> refundTransaction = new Map<String, Object>{
        'id' => fee.Id,
        'refundReason' => 'Customer Request'
    };
    refundTransactions.add(refundTransaction);
    
    String refundTransactionJSON = JSON.serialize(refundTransactions);
    
    
    String result = SAP_FinsysWorkOrderController.updateRefundTransaction(refundTransactionJSON);
    
    
    Test.stopTest();
}
    
    @isTest
    static void testGetContactFirstName() {
    Test.startTest();
    
    // Get a test contact from setup data
    Contact testContact = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Enterprise' LIMIT 1];
    
    
    String firstName = SAP_FinsysWorkOrderController.getContactFirstName(testContact.Id);
    //System.assertEquals('Enterprise', firstName, 'The first name should be Enterprise');


    Test.stopTest();
    system.assertEquals(firstName, testContact.FirstName, 'The first name should be Enterprise');
}

    @isTest
    static void testGetWorkOrderDetailsFinsys() {
        // Fetch test data
        IndividualApplication testWorkOrder = [
            SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'
        ];

        String requestData = '{"workOrderId": "' + testWorkOrder.Id + '", "transactionType": ""}';

        Test.startTest();
        
        // Call the method
        Map<String, Object> response = SAP_FinsysWorkOrderController.getWorkOrderDetailsFinsys(requestData);
        
        Test.stopTest();

        // Assertions
        System.assert(response != null, 'Response should not be null');
        System.assert(response.containsKey('workOrder'), 'Response should contain workOrder details');
        System.assert(response.containsKey('transactions'), 'Response should contain transactions');
        System.assert(response.containsKey('payments'), 'Response should contain payments');
    }
    
    @isTest
    static void testGetWorkOrderDetailsFinsysWithRefund() {
        // Fetch test data
        IndividualApplication testWorkOrder = [
            SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test'
        ];

        String requestData = '{"workOrderId": "' + testWorkOrder.Id + '", "transactionType": "Refund Transaction"}';

        Test.startTest();
        
        // Call the method
        Map<String, Object> response =SAP_FinsysWorkOrderController.getWorkOrderDetailsFinsys(requestData);
        
        Test.stopTest();

        // Assertions
        System.assert(response != null, 'Response should not be null');
        System.assert(response.containsKey('workOrder'), 'Response should contain workOrder details');
        System.assert(response.containsKey('refundTransactions'), 'Response should contain refund transactions');
    }
    
    @isTest
    static void testGetWorkOrderDetailsFinsysWithInvalidId() {
        IndividualApplication testWorkOrder = [
            SELECT Id FROM IndividualApplication where SAP_First_Name__c = 'Test2'
        ];
        String requestData = '{"workOrderId": "' + testWorkOrder.Id + '", "transactionType": ""}';

        Test.startTest();
        
        try {
           SAP_FinsysWorkOrderController.getWorkOrderDetailsFinsys(requestData);
            //System.assert(false, 'Method should throw an exception for invalid ID');
            
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Work Order ID is required'), 'Exception should indicate missing work order ID');
        }
        Test.stopTest();

    }
    
     @isTest
    static void testGetWorkOrderDetails_SuccesswithNewTransaction() {
        // Retrieve the inserted work order and activity
        IndividualApplication workOrder = [SELECT Id FROM IndividualApplication LIMIT 1];
        Activity__c activity = [SELECT Id FROM Activity__c LIMIT 1];

        // Prepare request data
        String requestData = '{"workOrderId": "' + workOrder.Id + '", "activityId": "' + activity.Id + '", "transactionType": "New Transaction"}';

        // Call the method and assert response
        Test.startTest();
        Map<String, Object> response = SAP_FinsysWorkOrderController.getWorkOrderDetails(requestData);
        Test.stopTest();

        System.assertNotEquals(response, null, 'Response should not be null');
        System.assert(response.containsKey('workOrder'), 'Work order data should be present');
        System.assert(response.containsKey('transactions'), 'Transactions data should be present');
        System.assert(response.containsKey('payments'), 'Payments data should be present');
    }
    
     @isTest
    static void testGetWorkOrderDetails_SuccesswithRefundTransaction() {
        // Retrieve the inserted work order and activity
        IndividualApplication workOrder = [SELECT Id FROM IndividualApplication LIMIT 1];
        Activity__c activity = [SELECT Id FROM Activity__c LIMIT 1];

        // Prepare request data
        String requestData = '{"workOrderId": "' + workOrder.Id + '", "activityId": "' + activity.Id + '", "transactionType": "Refund Transaction"}';

        // Call the method and assert response
        Test.startTest();
        Map<String, Object> response = SAP_FinsysWorkOrderController.getWorkOrderDetails(requestData);
        Test.stopTest();

        System.assertNotEquals(response, null, 'Response should not be null');
        System.assert(response.containsKey('workOrder'), 'Work order data should be present');
        System.assert(response.containsKey('transactions'), 'Transactions data should be present');
        System.assert(response.containsKey('payments'), 'Payments data should be present');
    }

   /* @isTest
    static void testGetWorkOrderDetails_MissingWorkOrderId() {
        String requestData = '{"activityId": "12345", "transactionType": "New Transaction"}';
        try {
            Test.startTest();
            SAP_FinsysWorkOrderController.getWorkOrderDetails(requestData);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException due to missing Work Order ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Work Order ID is required'));
        }
    }*/
}