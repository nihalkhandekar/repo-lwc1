@IsTest
public class attachmentTriggerHandler_Test {
    testmethod static void test1(){
        
        
        try{
            
            Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
    	Mark__c objmark = BRS_TestDataFactory.createMark();
         Mark_Filing__c mrkfiling = BRS_TestDataFactory.createMarkFiling(objmark.id);
        
        String myString = 'UHl0aG9u';
        Blob myBlob = Blob.valueof(myString);
        List<Attachment> attachedFiles = new List<Attachment>();
            
            String fName = filing.Sdoc_Filing_Number__c + ' - ' + filing.Filing_Type__c;
            fName = fName.replace('/', '-');
        
        string filingNameOt = UCCFileMerge.getFilingOutputName(filing);
        Attachment att1 = new Attachment(ParentId=filing.Id, Name=filingNameOt, Body=myBlob);
        attachedFiles.add(att1);
        insert attachedFiles;
        
		List<ContentVersion> listContentVersion = new List<ContentVersion>();
       	listContentVersion.add(new ContentVersion(
                        ContentLocation = 'S',
                        Origin = 'C',
                        PathOnClient = att1.Name,
                        Title = att1.Name,
                        VersionData = att1.Body
                    ));
        insert listContentVersion;
            
            
                
                String inputdata = 'jhghgfg.fggfhf,hfg';
                string propContentType;
                blob propFileBody;
                List<String> datalist = inputdata.split(',');
                System.debug('datalist -> '+datalist);
                if(datalist.size()>0)
                {
                    propContentType=datalist[0].split(';')[0];
                    propContentType=propContentType.removeStart('data:');
                    inputdata=datalist[1].trim();
                }
                System.debug('basebob -> '+inputdata);
                propFileBody=EncodingUtil.base64Decode(inputdata);
        
        ContentVersion fileVersion = new ContentVersion(
                ContentLocation = 'S',
                PathOnClient = mrkfiling.Sdoc_Filing_Number__c + ' - Mark Image' + '.png', 
                Title = mrkfiling.Sdoc_Filing_Number__c + ' - Mark Image',
                VersionData = propFileBody
            );
        insert fileVersion;
        List<ContentVersion> listFileVersions = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :fileVersion.Id
            ];
        ContentDocumentLink contentDocLinkMark = new ContentDocumentLink(
                ContentDocumentId = listFileVersions.get(0).ContentDocumentId,
                LinkedEntityId = filing.Id
            );
        insert contentDocLinkMark;
        
        Map<String, Id> mapTitleParentId= new Map<String, Id> ();
        mapTitleParentId.put('Test',filing.id);
            
        attachmentTriggerHandler tr = new attachmentTriggerHandler();
        List<Attachment> newItems = new List<Attachment>();
        newItems.add(att1);
        Map<Id, Attachment> newItems1 = new Map<Id, Attachment>();
        newItems1.put(att1.Id,att1);
        Test.startTest();
        tr.beforeInsert(newItems);
        tr.beforeDelete(newItems, newItems1);
        tr.beforeUpdate(newItems1, newItems1);
        tr.afterInsert(newItems, newItems1);
        tr.afterDelete(newItems1);
        tr.afterUndelete(newItems, newItems1);
        tr.afterUpdate(newItems1, newItems1);
        
            attchementTriggerHelper.createRecordLinks(listFileVersions,mapTitleParentId);
            attchementTriggerHelper.getRecordFiles(new List<Id>{filing.Id});
            attchementTriggerHelper.convertAttachmentToFiles(attachedFiles);

        
        Test.stopTest();      
            
            
        }catch(Exception e){
            
            System.debug('Error');
        }
    }
        @istest
    static void convertAttachmentToFilesTest(){
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');

        
          Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=acc.id;
        filing.Work_Order__c=workorder.id;
        filing.Type__c = 'Change of Email Address';
        filing.Filing_Type__c='Business Address Change';
        filing.Citizenship__c = 'Domestic';
        filing.Status__c='Approved';
        insert filing;
        Business_Filing__c fil=[Select id,name,Sdoc_Filing_Number__c from Business_Filing__c where id=:filing.id limit 1];
		String myString2 = 'UHl0aG9d';
        Blob myBlob = Blob.valueof(myString2);
        List<Attachment> attachedFiles = new List<Attachment>();
       String nameValue=fil.Name;
        String fName = nameValue.remove('BF-') + ' - ' + filing.Filing_Type__c;
        //String fName = fil.Sdoc_Filing_Number__c + ' - ' + filing.Filing_Type__c;
        fName = fName.replace('/', '-');
        Attachment att1 = new Attachment(ParentId=filing.Id, Name=fName, Body=myBlob);
        attachedFiles.add(att1);
        insert attachedFiles;     
    }
}