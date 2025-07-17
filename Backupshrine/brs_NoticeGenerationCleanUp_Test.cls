@isTest public with sharing class brs_NoticeGenerationCleanUp_Test {
    @isTest public static void brs_NoticeGenerationCleanUp_Test1() {
        RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Business Registration',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Business_Filing__c',
            Loop__Type__c = 'Letter'
        );
        insert docgen;
        
        RecordType rn =[
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Attach'
        ];
        Loop__DDP_Integration_Option__c delivery = new Loop__DDP_Integration_Option__c(
            Name = 'Business Filing Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen.id
        );
        insert delivery;
        
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdBusiness;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Business Registration';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        filing.Include_Expedited_Service__c=FALSE;
        filing.Total_Authorized_Shares__c=0;
        filing.Business_Type__c=testAcc1.Business_Type__c;
        filing.Citizenship__c=testAcc1.Citizenship__c;
        filing.Source__c='Online';
        insert filing;
        
        Test.startTest();
        Database.executeBatch(new brs_NoticeGenerationDataCleanUpBatch(System.today()));
        Database.executeBatch(new brs_NoticeGenerationDataCleanUpBatch(new Set<Id>{filing.Id}));
        Test.stopTest();
    }
}