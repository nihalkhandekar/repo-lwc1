@IsTest private class SdocTemplateServices_Test {
    @testSetup private static void setup() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        
        Id RecordTypeIdMaintenance = SchemaUtility.getRecordTypeId('Business_Filing__c', 'Maintenance');
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.Approved);
        
        Certficate__c cert = new Certficate__c(
            RecordTypeId = SchemaUtility.getRecordTypeId('Certficate__c', 'Business Copy Request')
        );
        insert cert;
        Copy_Request_Details__c copyDetails = new Copy_Request_Details__c(
            Other_Request__c = cert.Id,
            RecordTypeId = SchemaUtility.getRecordTypeId('Copy_Request_Details__c', 'Business Filling Request'),
            Account__c = acc.Id,
            Business_Filing__c = filing.Id,
            Number_Of_Copies__c = 1,
            Copy_Type__c = 'Plain'
        );
        insert copyDetails;
    }

    private static Business_Filing__c getFiling() {
        return [
            SELECT Id, Account__c, Type__c
            FROM Business_Filing__c
        ];
    }

    private static Account getAccount() {
        return [
            SELECT Id
            FROM Account
        ];
    }
    
    private static Certficate__c getOtherRequest() {
        return [
            SELECT Id
            FROM Certficate__c
        ];
    }

    @isTest private static void testGetPrincipalTitle() {
        Business_Filing__c filing = getFiling();
        Map<String, String> args = new Map<String, String> {
            'recordId' => filing.Id,
            'authorizerName' => 'authorizerName',
            'incorporatorName' => 'incorporatorName',
            'account' => filing.Account__c
        };
        
        Test.startTest();
            new SdocTemplateServices().call('getPrincipalTitle', args);
        Test.stopTest();
    }
    
    @isTest private static void testGenerateRequestInformation() {
        Business_Filing__c filing = getFiling();
        List<Attachment> attachedFiles = new List<Attachment> {
            new Attachment(
                ParentId = filing.Id, 
                Name = System.Label.Acceptance_N_Comparable, 
                Body = Blob.valueof('string')
            )
        };
        insert attachedFiles;
            
            
        try {        
            Test.startTest();
                SdocTemplateServices.generateRequestInformation(
                    new List<SdocTemplateServices.RequestWrapper> { new SdocTemplateServices.RequestWrapper(filing.id, filing.Type__c) }
                );
            Test.stopTest();
        } catch(Exception e){
            //Methods defined as testMethod do not support getContent calls
        }
        
    }

    @isTest private static void testMarkSearched() {
        Mark__c mark = BRS_TestDataFactory.createMark();
        Map<String, Object> marksearch = new Map<String, Object> {
            'searchBy'  => 'Registration #',
            'searchFor' => '9999999999- TEST',
            'recordId'  => mark.Id
        };

        Test.startTest();
            SdocTemplateServices sts = new SdocTemplateServices();
            sts.call('getMarkSearches', marksearch);
            sts.call('getNoticeDatePlusThirtyDays', markSearch);
        Test.stopTest();
    }

    @isTest private static void testGetCopyRequestDetails() {
        Map<String, String> args = new Map<String, String> {
            'filingId' => getOtherRequest().Id
        };

        Test.startTest();
            new SdocTemplateServices().call('getCopyRequestDetails', args);
        Test.stopTest();
    }

    @isTest private static void testGetlongFormRejectReasonWRIT() {
        Map<String, String> mapReasons = new Map<String, String> {
            'Reason' => 'Subpoena on behalf of a corp',
            'CustomReason' => 'Custom reason'
        };

        Test.startTest();
            new SdocTemplateServices().call('getlongFormRejectReasonWRIT', mapReasons);
        Test.stopTest();
    }
}