@isTest private class NintexDocumentGeneration_Test {
    @TestSetup
    static void setup() {
        //Account acc = BRS_TestDataFactory.createAccountObject();
        Account acc = new Account();
        acc.Name = 'Test Account First';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con.id,'Mail','In-Progress');
        
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Maintenance'
        ];
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject1(rt.id, acc.id, workOrder.id, 'Amendment', 'Approved');
        insert filing;
        
        RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = filing.Type__c,
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
        //Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        RecordType rt1 =[select id,Name,developername from RecordType where developername='Request_for_Search_of_Mark'];
        Certficate__c cert = BRS_TestDataFactory.createCertificate(rt1.id, acc.Id, WorkOrder.Id);
        cert.Search_by__c='Description';
        cert.Search_for__c='Test';
        update cert;
        NintexTemplateServices tt = new NintexTemplateServices();
        //tt.getFieldValue(con, 'Name') ;
        
        List<Copy_Request_Details__c> copyDetailsList = new List<Copy_Request_Details__c>();
        Copy_Request_Details__c copyDet1 = new Copy_Request_Details__c();
        copyDet1.Other_Request__c = cert.Id;
        copyDet1.Account__c = acc.Id;
        copyDet1.Business_Filing__c = filing.Id;
        copyDet1.Copy_Type__c = 'Certified';
        copyDetailsList.add(copyDet1);
        
       	Work_Order__c workOrder1 = BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        UCC_Lien__c uccLien = BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        UCC_Filing__c uccFiling = BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder1.id,'Approved',uccLien.id,'OFS');
        
        Copy_Request_Details__c copyDet2 = new Copy_Request_Details__c();
        copyDet2.Other_Request__c = cert.Id;
        copyDet2.UCC_Filing__c = uccFiling.Id;
        copyDet2.Copy_Type__c = 'Certified';
        copyDetailsList.add(copyDet2);
        
        insert copyDetailsList;
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='TestTitle', PathOnClient='SampleTitle.pdf',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
		ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        
       /* Mark__c mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        
        Copy_Request_Details__c copyDet3 = new Copy_Request_Details__c();
        copyDet3.Other_Request__c = cert.Id;
        copyDet3.Mark_Filing__c = markfiling.Id;
        copyDet3.Copy_Type__c = 'Certified';
        copyDetailsList.add(copyDet3);*/
        
        
    }

    private static Certficate__c getCert() {
        return [
            SELECT Id,Name,Search_by__c,Search_for__c,Status__c,Type__c
            FROM Certficate__c
        ];
    }

    private static Business_Filing__c getFiling() {
        return [
            SELECT Id, Type__c, Status__c
            FROM Business_Filing__c
        ];
    }
    
@isTest private static void testGenerateFilingOutput() {
        Business_Filing__c filing = getFiling();

        NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = filing.id;
       	//nintextemplate.status = filing.Status__c;
        nintextemplate.type = filing.Type__c;
        List<NintexDocumentGeneration.NintexWrapper> listNintexDetails =new List<NintexDocumentGeneration.NintexWrapper>();
        listNintexDetails.add(nintextemplate);
        String nintexinfo=JSON.serialize(listNintexDetails);
        Test.startTest();
        NintexDocumentGeneration.generateDocument(nintexinfo); 
            NintexDocumentGeneration.generateFilingOutput(new List<NintexDocumentGeneration.NintexWrapper> {
            	nintextemplate
        	}); 
        Test.stopTest(); 
    }

    @isTest private static void testGenerateFilingAcceptance() {
        Business_Filing__c filing = getFiling();

        NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = filing.id;
       	nintextemplate.status = filing.Status__c;
        nintextemplate.type = filing.Type__c;
        
        Test.startTest();
            NintexDocumentGeneration.generateFilingOutput(new List<NintexDocumentGeneration.NintexWrapper> {
                nintextemplate
            }); 
        Test.stopTest(); 
    }
    
    @isTest private static void testGenerateFilingOutputDigitalCertified(){
        Test.startTest();
		RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Digital Certified Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Certified',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Copy_Request_Details__c',
            Loop__Type__c = 'Copy Request Details'
        );
        insert docgen;
        
        RecordType rn =[
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Attach'
        ];
        Loop__DDP_Integration_Option__c delivery = new Loop__DDP_Integration_Option__c(
            Name = 'Digital Certified Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen.id
        );
        insert delivery;
        Certficate__c otherReq = [SELECT Id,Name,Search_by__c,Search_for__c,Status__c,Type__c
            FROM Certficate__c limit 1];
        
        Mark__c mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        
        Copy_Request_Details__c copyDet3 = new Copy_Request_Details__c();
        copyDet3.Other_Request__c = otherReq.Id;
        copyDet3.Mark_Filing__c = markfiling.Id;
        copyDet3.Copy_Type__c = 'Certified';
        insert copyDet3;
        NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = otherReq.id;
       	nintextemplate.status = otherReq.Status__c;
        nintextemplate.type = 'Certified';
        
        NintexDocumentGeneration.NintexWrapper nintextemplate1 = new NintexDocumentGeneration.NintexWrapper(otherReq.id,otherReq.Status__c,otherReq.Type__c);
        NintexDocumentGeneration.NintexWrapper nintextemplate2 = new NintexDocumentGeneration.NintexWrapper(otherReq.id,otherReq.Status__c);
        
            NintexDocumentGeneration.generateFilingOutputDigitalCertified(new List<NintexDocumentGeneration.NintexWrapper> {
                nintextemplate
            }); 
        Test.stopTest(); 
    }

    @isTest private static void testGenerateFilingAcceptancetest() {
        Test.startTest();
        Mark__c mark=New Mark__c();
        mark=BRS_TestDataFactory.createMark();
        mark.Description_of_Mark__c = 'Test';
        update mark;
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        markfiling.Description_of_Mark__c = 'Test';
        update markfiling;
        /*Business_Filing__c filing = getFiling();

        NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = filing.id;
       	nintextemplate.status = filing.Status__c;
        nintextemplate.type = filing.Type__c;*/
        
        Principal__c principal = new Principal__c();
        principal.Name__c = 'principal';
        principal.Principal_Type__c = 'Business';
        principal.Business_Name__c = 'Pizza';
        principal.Business_Street_Address_1__c = 'Test';
        principal.Business_City__c = 'New York';
        principal.Business_Country__c = 'United States';
        principal.Business_Zip_Code__c = '12334';
        principal.Business_State__c = 'CT';
        principal.Email__c = 'saritanayak71@gmail.com';
        insert principal;


        /*Account acc = BRS_TestDataFactory.createAccountObject();
        	List<Account> acclist = new List<Account>();
        	acclist.add(acc);
        	Map<Id,Account> oldItems = new Map<Id,Account>();
        	oldItems.put(acc.Id,acc);*/
        
        	decimal fee = 100;
        	
            Business_Filing__c filing = getFiling();
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.RecordId = filing.id;
        String obj ;
        List<string> fields = new List<string>();
        fields.add('Name');
        fields.add('Business__c');
        fields.add('Search_by__c');
        fields.add('Search_for__c');
        fields.add('Description__c');
        List<string> objectNames = new List<string>();
        objectNames.add('Contact');
        objectNames.add('Principal__c');
        objectNames.add('Certificate__c');
        objectNames.add('brs_InformationRequestForm.DataWrapper');
        objectNames.add('brs_InformationRequestForm.ChangeHistoryWrapper');
        NintexTemplateServices tt = new NintexTemplateServices();
        NintexPackageServices tt1 = new NintexPackageServices();
        
        
        List<NintexDocumentGeneration.NintexWrapper> listNintexDetails = new List<NintexDocumentGeneration.NintexWrapper>();
        NintexDocumentGeneration.NintexWrapper wrapper = new NintexDocumentGeneration.NintexWrapper();
       // getCert().Business__c = [Select id from Account][0].id;
       // getCert().Search_by__c = 'Description';
        //getCert().Search_for__c = 'test';
        //getCert().Description__c = 'test';
        //update getCert();

        System.debug('***getCert()'+getCert());
        wrapper.filingId = getCert().id;
        listNintexDetails.add(wrapper);
        //Test.startTest();
        tt.describeObjects(objectNames) ;
        tt.getGlobalDescribe();
        tt.getChildRelationships('Principal__c');
        tt1.describeObjects(objectNames) ;
        tt1.getGlobalDescribe();
        tt1.getChildRelationships('Certificate__c');
       // Test.stopTest(); 
        tt1.getRequestForInfo('Certificate__c');
        //NintexTemplateServices.generateFilingOutput(listNintexDetails);
        //requestInfo.RecordId = filing.id;
        requestInfo.RecordId =  getCert().id;
        tt.getMarkSearchRecords(requestInfo,'Certificate__c',fields);
        try{
        tt.getLongformFilingHistory(requestInfo,'Certificate__c',fields);
        
        }catch(Exception e){
        
        }
        requestInfo.RecordId = principal.id;
        tt.getMarkSearchInfo('brs_InformationRequestForm.DataWrapper');
        tt.getChangeHistoryInformation('brs_InformationRequestForm.ChangeHistoryWrapper');
        //tt.getFieldValue((Sobject)principal, 'Name');
        //tt.getFieldValue((Sobject)getCert(), 'Name\\.Business__c');
        //tt.getFieldValue((Sobject)getCert(), 'Search_by__c\\.Search_for__c');
       // requestInfo.SetObjectNames(objectNames);
        tt.query(requestInfo);
        requestInfo.RecordId = getCert().id; 
        Test.stopTest();
    }

    @isTest private static void testAdminDissolutionBatch() {
        Business_Filing__c filing = getFiling();

        Test.startTest();
            Database.executeBatch(new NintexBatchGeneration(new List<Id> { filing.Id}, UCCFilingAcknowledgement.Operation.None)); 
            Database.executeBatch(new NintexBatchGeneration(new List<Id> { filing.Id}, UCCFilingAcknowledgement.Operation.MAINTENANCE));
        Test.stopTest(); 
    }
    @isTest private static void testWritecase() {
                   RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Approved'
        ];
           WRIT_Case__c writcase=BRS_TestDataFactory.createWritCase();
           Defendants__c defendant=BRS_TestDataFactory.createDefendant(rc.id,writcase.id);
            defendant.Type_of_Defendant__c='Corporation';
            defendant.Section_Number__c='33-929';
            defendant.Mailing_Status__c='SOS Agent';
            defendant.Mail_Type__c='Certified';
	        defendant.Address_Street_1__c='MPL';
	        defendant.Mail_Number__c='12345678901010101010';
		    defendant.City__c='NPL';
			defendant.Zip_Code__c='12345';
			defendant.State__c='Ap';
		    defendant.Country__c='india';
            update defendant;
                 NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = writcase.id;
       	//nintextemplate.status = filing.Status__c;
        nintextemplate.type = writcase.Type__c;
        
        Test.startTest();
            NintexDocumentGeneration.generateDocumentWritNotice(new List<NintexDocumentGeneration.NintexWrapper> {
            	nintextemplate
        	}); 
        Test.stopTest(); 
    }
     @isTest private static void testWritecase1() {
                   RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Rejected'
        ];
           WRIT_Case__c writcase=BRS_TestDataFactory.createWritCase();
           Defendants__c defendant=new Defendants__c();
         defendant.WRIT_Case__c=writcase.id;
         defendant.RecordTypeId=rc.id;
            defendant.Rejection_Reason__c='Agent of record';
            insert defendant;
                 NintexDocumentGeneration.NintexWrapper nintextemplate = new NintexDocumentGeneration.NintexWrapper();
        nintextemplate.filingId = writcase.id;
       	//nintextemplate.status = filing.Status__c;
        nintextemplate.type = writcase.Type__c;
        
        Test.startTest();
            NintexDocumentGeneration.generateDocumentWritNotice(new List<NintexDocumentGeneration.NintexWrapper> {
            	nintextemplate
        	}); 
        Test.stopTest(); 
    }
        @isTest private static void testGeneratecopyDet3(){
        Test.startTest();
		RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Digital Certified Template',
            RecordTypeId = rc.Id,
            Filing__c = 'Certified',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Copy_Request_Details__c',
            Loop__Type__c = 'Copy Request Details'
        );
        insert docgen;
        
        RecordType rn =[
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Attach'
        ];
        Loop__DDP_Integration_Option__c delivery = new Loop__DDP_Integration_Option__c(
            Name = 'Digital Certified Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen.id
        );
        insert delivery;
        Certficate__c otherReq = [SELECT Id,Name,Search_by__c,Search_for__c,Status__c,Type__c
            FROM Certficate__c limit 1];
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.RecordId = otherReq.id;
         Business_Filing__c filing = getFiling();
         Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        Mark__c mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        
        Copy_Request_Details__c copyDet3 = new Copy_Request_Details__c();
        copyDet3.Other_Request__c = otherReq.Id;
        copyDet3.Mark_Filing__c = markfiling.Id;
        copyDet3.Copy_Type__c = 'Certified';
        insert copyDet3;
          List<string> fields = new List<string>();
        fields.add('Filing_Number__c');
        fields.add('Copy_Type__c');
        fields.add('No_Of_Copies__c');
        fields.add('Volume_Type__c');
        fields.add('Volume__c');
        fields.add('Start_Page__c');
        fields.add('Pages__c');
                              RecordType rc1 = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Rejected'
        ];
           WRIT_Case__c writcase=BRS_TestDataFactory.createWritCase();
           Defendants__c defendant=new Defendants__c();
         defendant.WRIT_Case__c=writcase.id;
         defendant.RecordTypeId=rc1.id;
            defendant.Rejection_Reason__c='Agent of record';
            insert defendant;
        Loop.ExternalData.QueryRequestInfo requestInfo2 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = defendant.id;
   	NintexTemplateServices nin=new NintexTemplateServices();
         nin.getChangeHistoryInformation('Copy_Request_Details__c');
        nin.getCopyRequestDetailsInformation('Copy_Request_Details__c');
        nin.getFilingDateAndTime('Copy_Request_Details__c');
        nin.getCopyDetails(requestInfo,'Copy_Request_Details__c',fields);
        nin.getFilingValue(requestInfo,'Copy_Request_Details__c',fields);
        nin.getBusinessAdressChange('Business_Filing__c');
        nin.getEmailAddressChangeInfo(requestInfo1,'Business_Filing__c',fields);
        nin.getLongformRejectReasonWRIT('Certficate__c');
        nin.getRejectReasonWRIT(requestInfo2,'Defendants__c');
        nin.getBizAcknowledgementFieldInfo('Business_Filing__c');
        nin.getBusinessAcknowledgement(requestInfo1,'Business_Filing__c');
        nin.getProfileName(requestInfo1,'Business_Filing__c',fields);
        nin.getLastModifiedProfileInfo('Business_Filing__c');
        NintexDocumentGeneration.ConvertFileToAttachment(filing.Id);
    } 
  @isTest private static void getFilingDescriptionRecordsTest() {
                RecordType rt1 = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Registration'
        ];
         Mark__c mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt1.id,'Registration');
        NintexTemplateServices nin=new NintexTemplateServices();
        nin.getFilingDescription('Mark_Filing__c');
            List<string> fields = new List<string>();
        fields.add('filingDescription');
        fields.add('filingValue');
          Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = markfiling.id;
        nin.getFilingDescriptionRecords(requestInfo1, 'Mark_Filing__c',fields);
    }
    @isTest private static void getFilingDescriptionRecordsTest1() {
                RecordType rt1 = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Assignment'
        ];
        Mark__c mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt1.id,'Assignment');
        NintexTemplateServices nin=new NintexTemplateServices();
        nin.getFilingDescription('Mark_Filing__c');
            List<string> fields = new List<string>();
        fields.add('filingDescription');
        fields.add('filingValue');
          Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = markfiling.id;
        nin.getFilingDescriptionRecords(requestInfo1, 'Mark_Filing__c',fields);
    }
    @isTest private static void getFilingDescriptionRecordsTest2() {

		Id uccFilingId=[Select id from UCC_Filing__c].id;
        NintexTemplateServices nin=new NintexTemplateServices();
        nin.getFilingDescription('UCC_Filing__c');
        List<string> fields = new List<string>();
        fields.add('filingDescription');
        fields.add('filingValue');
          Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = uccFilingId;
        nin.getFilingDescriptionRecords(requestInfo1, 'UCC_Filing__c',fields);
    }
     @isTest private static void getBusinessAcknowledgementTest() {

           Business_Filing__c filing = getFiling();
         Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = filing.id;
        NintexTemplateServices nin=new NintexTemplateServices();
             List<string> fields = new List<string>();
        fields.add('authorizerName');
        fields.add('authorizerTitle');
        fields.add('filerName');
        fields.add('filerSignature');
        fields.add('executionDate');
        nin.getBusinessAcknowledgement(requestInfo1, 'Business_Filing__c');
        nin.getEmailAddressChangeInfo(requestInfo1, 'Business_Filing__c',fields);
    }
    @isTest private static void getRejectReasonWRITTest() {
            RecordType rc1 = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Rejected'
        ];
           WRIT_Case__c writcase=BRS_TestDataFactory.createWritCase();
           Defendants__c defendant=new Defendants__c();
         defendant.WRIT_Case__c=writcase.id;
         defendant.RecordTypeId=rc1.id;
            defendant.Rejection_Reason__c='Agent of record';
            insert defendant;
         Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
        requestInfo1.RecordId = defendant.id;
        NintexTemplateServices nin=new NintexTemplateServices();
        nin.getRejectReasonWRIT(requestInfo1, 'Defendants__c');

    }
}