@isTest public class BRS_AnnualReport_DataCleanupTest {
    @testSetup static void testDataSetup(){
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Business_Filing__c bf=BRS_TestDataFactory.createBusinessFilingObject1(RecordTypeIdAnnual,testAcc1.Id,null,'Annual Report','Approved');
        bf.Source__c='Online';
        bf.Filing_Date__c= Date.newInstance(2021, 12, 01);
        bf.Due_Date__c=Date.newInstance(2021, 11, 29);
        bf.Filing_Type__c = 'Annual Report';
        insert bf;
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = 'Annual Report';
        attachment.Body = b;
        insert(attachment);

        RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Annual Report',
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
    }
    @isTest static void testData(){
        Id RecordTypeIdAnnual = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Business_Filing__c filing=new Business_Filing__c();
           filing.recordtypeid=RecordTypeIdAnnual;
        filing.Account__c=testAcc1.id;
        filing.Type__c = 'Annual Report';
        filing.Filing_Type__c='Annual Report';
        filing.Status__c='In-Progress';
        insert filing;
        String myString2 = 'UHl0aG9d';
          String nameValue=filing.Name;
        Blob myBlob = Blob.valueof(myString2);
        String fName = 'Annual Report';
        Attachment att1 = new Attachment(ParentId=filing.Id, Name=fName, Body=myBlob);
        insert att1;     
        test.startTest();
        
        Database.executeBatch(new BRS_AnnualReport_DataCleanUp_Batch());
        //Database.executeBatch(new BRS_AnnualReport_DataCleanUp_Batch(Date.newInstance(2021, 12, 10),Date.newInstance(2021, 11, 10),q));
        Database.executeBatch(new BRS_AnnualReport_RecreateDoc_Batch());
         List<Attachment> att=[SELECT Id, Name, Body, ParentId FROM Attachment];
        new BRS_AnnualReport_RecreateDoc_Batch().execute(null, att);
        //Database.executeBatch(new BRS_AnnualReport_RecreateDoc_Batch(Date.newInstance(2021, 12, 10),Date.newInstance(2021, 11, 10),q));
        test.stopTest();
    }
}