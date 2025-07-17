@isTest private class brs_fileUploaderControllerTest {
    @testSetup private static void setup() {
        Account objAcc = new Account(
            Name = 'test account',
            Date_of_Formation__c = Date.newInstance(2021, 01, 01),
            Citizenship__c = 'Domestic',
            Business_Type__c = 'Stock',
            Total_Authorized_Shares__c = 18
        );
       
        Test.startTest();
            insert objAcc;
        Test.stopTest();

        ContentVersion objContVer = new ContentVersion();
        objContVer.VersionData = Blob.valueOf('string');
        objContVer.Title = 'title';
        objContVer.PathOnClient = 'title.txt';
        objContVer.File_Type_fileupload__c = 'Text';
        insert objContVer;

        Id conDoc = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: objContVer.Id
        ].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink(
            ContentDocumentId = conDoc,
            LinkedEntityId = objAcc.id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cDe;

        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c businessFiling = new Business_Filing__c(
            Account__c = objAcc.Id,
            RecordTypeId = mainRecTypeId,
            Type__c = 'Annual Report',
            Filing_Date__c = System.Today().addDays(-30),
            Due_Date__c = System.Today().addDays(15),
            Status__c = 'Due'
        );
        insert businessFiling;

        brs_filingDueController.getFilingDueDetails(objAcc.id, 'Annual Report');
        brs_filingDueController testA = new brs_filingDueController();
        brs_filingDueController.FilingDueWrapper wrap = new brs_filingDueController.FilingDueWrapper();
        brs_filingDueController.Business testBus = new brs_filingDueController.Business();
        brs_filingDueController.getFilingDueDetails(objAcc.id, 'AgentAddressChange');

        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c = 'LienData1', UCC_Lien_Number__c = 'TestData1', Lapse_Date__c = System.today().addYears(-1)));
        uccLien.add(new UCC_Lien__c(Name__c = 'LienData2', UCC_Lien_Number__c = 'TestData2'));
        insert uccLien;
        
        Id fileRecTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();
        List < UCC_Filing__c > testFiling = new List < UCC_Filing__c > ();
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments', RecordTypeId = fileRecTypeId, Status__c = 'Completed', UCC_Lien_Id__c = uccLien[0].id, Reason_for_Rejection__c = 'Reason of Rejection'));
        testFiling.add(new UCC_Filing__c(Type__c = 'Amendments', Status__c = 'Completed', RecordTypeId = fileRecTypeId, UCC_Lien_Id__c = null, Reason_for_Rejection__c = ''));
        insert testFiling;

        Account acc = new Account(
            Name = 'Test Account First',
            Citizenship__c = 'Domestic',
            Business_Type__c = 'LLP',
            ClientAccountNum__c = '12345',
            Purpose_of_Business__c = 'Test business run',
            Status__c = 'Active'
        );
        insert acc;
        
        Contact con = BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con.id, 'Mail', 'In-Progress');

        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'Maintenance'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, acc.id, workOrder.id, 'Amendment', 'Approved');
        insert filing;

        //Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        RecordType rt1 = [select id, Name, developername from RecordType where developername = 'Request_for_Search_of_Mark'];
        Certficate__c cert = BRS_TestDataFactory.createCertificate(rt1.id, acc.Id, WorkOrder.Id);
        cert.Search_by__c = 'Description';
        cert.Search_for__c = 'Test';
        update cert;
    }

    private static Id getContentDocumentId() {
        Id contVersion = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            LIMIT 1
        ].id;
        
        Id conDoc = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contVersion
        ].ContentDocumentId;

        return conDoc;
    }

    @isTest 
    private static void deleteDocumentsTest() {
        List<Account> lstObjAcc = [
            SELECT id, name 
            FROM Account
            LIMIT 1
        ];
        Id conDoc = getContentDocumentId();
        
        Test.startTest();
            try {
                brs_fileUploaderController.getDocuments(lstObjAcc.get(0).Id + '', 'Text');
                brs_fileUploaderController.deleteDocuments(conDoc);
                brs_fileUploaderController.deleteDocuments(lstObjAcc.get(0).Id);
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    private static void getURLTest() {
        Id contVersion = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            LIMIT 1
        ].id;
        System.assertNotEquals(null, contVersion);
        
        Test.startTest();
            try {
                brs_fileUploaderController.getURL(contVersion);
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    private static void getContentDetailsTest() {
        Id accId = [SELECT id, name from Account Limit 1].id;
        System.assertNotEquals(Null, accId);

        string base64EncodeString = 'Testing base 64 encode';
        Blob base64Blob = Blob.valueOf(base64EncodeString);
        string paramvalue = EncodingUtil.base64Encode(base64Blob);

        Test.startTest();
            try {
                //brs_fileUploaderController.getContentDetails();
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    private static void FileSizeToStringTest() {
        Long paramValue = 1024;
        Long paramValue2 = 1024 * 1024;
        Long paramValue3 = 1024 * 1024 * 1024 + 1;

        Test.startTest();
        try {
            brs_fileUploaderController.FileSizeToString(paramValue);
            brs_fileUploaderController.FileSizeToString(paramValue3);

            String result = brs_fileUploaderController.FileSizeToString(paramValue2);
            System.assertEquals('1.00 MB', Result);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void ContentTypeTest() {
        Test.startTest();
        try {
            brs_fileUploaderController.fileSizeToString(100);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

        @isTest
    private static void getAllDocumentsSizeTest(){
         List<Account> lstObjAcc = [
            SELECT id, name 
            FROM Account
            LIMIT 1
        ];
        Id conDoc = getContentDocumentId();
        
        brs_fileUploaderController.contentDocDetails docDetails = new brs_fileUploaderController.contentDocDetails();
        docDetails.fileUrl='Testfileurl';
        docDetails.downloadUrl='Testdownloadurl';
        Test.startTest();
        try{
        
        brs_fileUploaderController.getAllDocumentsSize(lstObjAcc.get(0).Id + '', 'Text');
        } Catch (Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
            }
        
        

        Test.stopTest();
        
        
    }

}