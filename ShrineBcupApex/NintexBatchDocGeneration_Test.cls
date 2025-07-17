@isTest
public class NintexBatchDocGeneration_Test {

    testMethod Static Void NintexBatchDocGenerationExecution()
    {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        con.Email='sbabarabbani@deloitte.com';
        update con;
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
         Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Change of Email Address';
        filing.Status__c='Approved';
        insert filing;
        String filingid=filing.id;
         RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Change of Email Address',
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
            Name = 'hasNoUpload',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen.id
        );
        insert delivery;
        Test.startTest();
        Database.executeBatch(new NintexBatchDocGeneration('Business_Filing__c',filingid));
        Database.executeBatch(new NintexBatchDocGeneration('Business_Filing__c'));
        Test.stopTest();
    }
     testMethod Static Void NintexBatchDocGenerationExecution1()
    {
        NintexBatchDocGeneration sh1 = new NintexBatchDocGeneration('Business_Filing__c');
        Test.startTest(); 
		String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
         testMethod Static Void NintexBatchDocGenerationExecution2()
    {
        NintexBatchDocGeneration sh1 = new NintexBatchDocGeneration('Business_Filing__c','123456789y');
        Test.startTest(); 
		String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
     testMethod Static Void NintexBatchDocGenerationExecution4()
    {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        con.Email='sbabarabbani@deloitte.com';
        update con;
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
         Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Change of Email Address';
        filing.Status__c='Rejected';
        insert filing;
        String filingid=filing.id;
         RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Change of Email Address',
            Status__c = 'Rejected',
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
            Name = 'hasNoUpload',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen.id
        );
        insert delivery;
        Test.startTest();
        Database.executeBatch(new NintexBatchDocGeneration('Business_Filing__c',filingid));
        Database.executeBatch(new NintexBatchDocGeneration('Business_Filing__c'));
        Test.stopTest();
    }
     
}