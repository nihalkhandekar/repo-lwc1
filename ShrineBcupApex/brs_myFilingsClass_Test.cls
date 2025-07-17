@isTest
public class brs_myFilingsClass_Test {
    
    @testSetup static void setup() {
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        for(Integer i=0;i<2;i++) {
            testFiling.add(new UCC_Filing__c(Type__c = 'Amendments'));
        }
        //insert testFiling; 
    }
    
    @testVisible static List<BRS_Resume_Flow_URLs__mdt> flowUrls{ 
        get{ 
            if(flowUrls == NULL){ 
                flowUrls = [Select Id,DeveloperName,MasterLabel,URL_For_Flow__c from BRS_Resume_Flow_URLs__mdt]; 
            } 
            return flowUrls; 
        } 
        set; 
    } 
    
    testmethod static void getAllData(){
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Id profileId = [Select Id From Profile Where Name ='CT Community User'].id;
        User tUser = BRS_TestDataFactory.createCommunityUser(con,profileId);
        test.startTest();
        List<brs_myFilingsClass.filterWrapper> wrapList = new List<brs_myFilingsClass.filterWrapper>();
        List<String> strList = new List<String>();
        strList.add('Business Registration');
        brs_myFilingsClass.filterWrapper wrapInst= new brs_myFilingsClass.filterWrapper();
        wrapInst.type =System.label.BusinessFiling_Label; 
        wrapInst.selectedOptions = strList;
        wrapInst.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst);
        brs_myFilingsClass.filterWrapper wrapInst1= new brs_myFilingsClass.filterWrapper();
        wrapInst1.type =System.label.BusinessFiling_Label; 
        wrapInst1.selectedOptions = strList;
        wrapInst1.searchType = System.label.Business_Dashboard_Label; 
        wrapList.add(wrapInst1);
        brs_myFilingsClass.filterWrapper wrapInst2= new brs_myFilingsClass.filterWrapper();
        wrapInst2.type =System.label.BusinessFiling_Label; 
        wrapInst2.selectedOptions = strList;
        wrapInst2.searchType = System.label.Certificate_Dashboard_Label; 
        wrapList.add(wrapInst2);
        brs_myFilingsClass.filterWrapper wrapInst3= new brs_myFilingsClass.filterWrapper();
        wrapInst3.type =System.label.BusinessStatus_Label; 
        wrapInst3.selectedOptions = strList;
        wrapInst3.searchType = System.label.Certificate_Dashboard_Label; 
        wrapList.add(wrapInst3);
        brs_myFilingsClass.mainWrapper mainWrapInst = new brs_myFilingsClass.mainWrapper();
        mainWrapInst.filters = wrapList;
        mainWrapInst.UserId = string.valueOf(tUser.Id);
        String Obj1 = JSON.serialize(mainWrapInst);
        brs_myFilingsClass.getAllData(Obj1);
        brs_myFilingsClass.mainWrapper mainWrapInst1 = new brs_myFilingsClass.mainWrapper();
        mainWrapInst1.filters = null;
        mainWrapInst1.UserId = string.valueOf(tUser.Id);
        String Obj2 = JSON.serialize(mainWrapInst1);
        brs_myFilingsClass.getAllData(Obj2);
        
        List<brs_myFilingsClass.filingsinfoWrapper> filingWrapList = new List<brs_myFilingsClass.filingsinfoWrapper>();
        brs_myFilingsClass.filingsinfoWrapper fillingWrap= new brs_myFilingsClass.filingsinfoWrapper();
        fillingWrap.recId ='';
        fillingWrap.workOrderNum ='';
        fillingWrap.filingName ='';
        fillingWrap.createdDate ='';
        fillingWrap.filingOrCertType ='';
        fillingWrap.Status ='';
        fillingWrap.certNum='';
        fillingWrap.FilingType='';
        fillingWrap.LienType='';
        fillingWrap.filingDate ='';
        fillingWrap.isContinueFiling =true;
        fillingWrap.isAcceptanceNotice =true;
        fillingWrap.isRejectionNotice =true;
        fillingWrap.isviewFiling =true;
        fillingWrap.isViewCertificate =true;
        fillingWrap.isViewReport =true;
        fillingWrap.isResubmit=true;
        fillingWrap.filingNumber ='';
        fillingWrap.FilingTypeSdocs='';
        
        filingWrapList.add(fillingWrap);
        
        brs_myFilingsClass.AllDataWrapper allDataWrap= new brs_myFilingsClass.AllDataWrapper();
        allDataWrap.Count=2;
        allDataWrap.objList=filingWrapList;
        allDataWrap.resumeFlowURL = flowUrls;  
        String Obj = JSON.serialize(allDataWrap);
        //brs_myFilingsClass.getAllData(Obj);
        //brs_myFilingsClass.getAllData('');
        //brs_myFilingsClass.getResumeFlowURLS();
        test.stopTest();
    }

    testMethod static void certrificateMethodOne()
    {
        //try{
        Account acc1 = BRS_TestDataFactory.createAccountObject();
        List<Account> acclist = new List<Account>();
        acclist.add(acc1);
        Map<Id,Account> oldItems = new Map<Id,Account>();
        oldItems.put(acc1.Id,acc1);
    
        decimal fee = 100;
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Contact con1 = BRS_TestDataFactory.createContactObject(acc1.Id);
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Mail', 'Completed');
       // workOrder.Name = 'Testjhj';
       // update workOrder;
       Certficate__c cert = new Certficate__c();
       cert.RecordTypeId=mainRecTypeId1;
       cert.Type__c='Certificate of Legal Existence';
       cert.Certificate_Type__c='Standard';
       cert.Business__c = acc1.id;
       cert.Work_Order__c = workOrder.id;
       insert cert;

        Copy_Request_Details__c copyDetails11 = new Copy_Request_Details__c();
        copyDetails11.Account__c=acc1.Id;
        copyDetails11.Other_Request__c=cert.Id;
        //copyDetails11.Business_Filing__c=bfc.Id;
        copyDetails11.Number_of_Copies__c=1;
        copyDetails11.Copy_Type__c='Plain';
        //copyDetailsList.add(copyDetails11);
        Datetime yesterday = Datetime.now().addDays(-1);
       // Test.setCreatedDate(cert.Id, yesterday); 
        brs_myFilingsClass.filingsinfoWrapper fillingWrap1= new brs_myFilingsClass.filingsinfoWrapper(cert);
        brs_myFilingsClass.filingsinfoWrapper fillingWrap2= new brs_myFilingsClass.filingsinfoWrapper(copyDetails11);
        /*}catch(Exception e){
            System.debug(e);
        }*/
       
    }
    testMethod static void certrificateMethod()
    {
        RecordType rt =[select id,Name,developername from RecordType where developername='Certificate_Request'];
        List<String> strList = new List<String>();
        strList.add('Standard');
        List<brs_myFilingsClass.filterWrapper> wrapList = new List<brs_myFilingsClass.filterWrapper>();
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'Online','In-Progress');
        Certficate__c cert = new Certficate__c();
        cert=BRS_TestDataFactory.createCertificate(rt.id,acc.id,workOrder.id);
        brs_myFilingsClass.mainWrapper mainWrapInst = new brs_myFilingsClass.mainWrapper();
        mainWrapInst.UserId = string.valueOf(UserInfo.getUserId());
        brs_myFilingsClass.filterWrapper wrapInst= new brs_myFilingsClass.filterWrapper();
        wrapInst.type =System.label.Certificate_Type_Label; 
        wrapInst.selectedOptions = strList;
        wrapInst.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst);
        brs_myFilingsClass.getCertificateData(mainWrapInst.UserId,wrapList);
        
    }
    testMethod static void uccFilingMethod()
    {
        List<String> strList = new List<String>();
        List<String> strList1 = new List<String>();
        List<String> strList2 = new List<String>();
        strList.add('OFS');
        strList1.add('Approved');
        strList2.add('Rejected');
        List<brs_myFilingsClass.filterWrapper> wrapList = new List<brs_myFilingsClass.filterWrapper>();
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Customer_Balance_Transaction__c customerBal = new Customer_Balance_Transaction__c();
        customerBal=BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Credit',4000);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod=BRS_TestDataFactory.genericPaymentMethod(workOrder.id);
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling=BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder.id,'Approved',uccLien.id,'OFS');
        UCC_Filing__c uccFiling1 = new UCC_Filing__c();
        //uccFiling1=BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder.id,'Rejected',uccLien.id,'OFS');
        UCC_Related_Info__c objRelatedInfo4 = new UCC_Related_Info__c();
        objRelatedInfo4=BRS_TestDataFactory.createUCCRelatedObject('Submitter',uccFiling.id);
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();
        objRelatedInfo=BRS_TestDataFactory.createUCCRelatedObject('Submitter',uccFiling1.id);
        brs_myFilingsClass.mainWrapper mainWrapInst = new brs_myFilingsClass.mainWrapper();
        mainWrapInst.UserId = string.valueOf(UserInfo.getUserId());
        brs_myFilingsClass.filterWrapper wrapInst= new brs_myFilingsClass.filterWrapper();
        wrapInst.type =System.label.lien_type; 
        wrapInst.selectedOptions = strList;
        wrapInst.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst);
        brs_myFilingsClass.filterWrapper wrapInst1= new brs_myFilingsClass.filterWrapper();
        wrapInst1.type =System.label.Lien_Status_Label; 
        wrapInst1.selectedOptions = strList1;
        wrapInst1.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst1);

        brs_myFilingsClass.getUCCFilingData(mainWrapInst.UserId,wrapList);
        brs_myFilingsClass.getUCCFilingData(null,wrapList);
    }
    testMethod static void businessFilingMethod()
    {
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        List<brs_myFilingsClass.filterWrapper> wrapList = new List<brs_myFilingsClass.filterWrapper>();
        List<String> strList1 = new List<String>();
        strList1.add('Approved');
        List<String> strList2 = new List<String>();
        strList1.add('Rejected');
        List<String> strList = new List<String>();
        strList.add('Change of Email Address');
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        Business_Filing__c filing=new Business_Filing__c();
        filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,acc.id,workOrder.id,'Change of Email Address','Approved');
        //filing.Status__c = 'Change of Email Address';
        filing.Type__c = 'Change of Email Address' ;
        filing.Source__c = System.label.Online_Label;
        Update filing;
        
        Business_Filing__c filing1=new Business_Filing__c();
        filing1=BRS_TestDataFactory.createBusinessFilingObject(rt.id,acc.id,workOrder.id,'Change of Email Address','Rejected');
        filing1.Type__c = 'Change of Email Address' ;
        filing1.Source__c = System.label.Online_Label;
        Update filing1;
        
        brs_myFilingsClass.mainWrapper mainWrapInst = new brs_myFilingsClass.mainWrapper();
        mainWrapInst.UserId = string.valueOf(UserInfo.getUserId());
        brs_myFilingsClass.filterWrapper wrapInst= new brs_myFilingsClass.filterWrapper();
        wrapInst.type =System.label.BusinessFiling_Label; 
        wrapInst.selectedOptions = strList;
        wrapInst.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst);
        brs_myFilingsClass.filterWrapper wrapInst1= new brs_myFilingsClass.filterWrapper();
        wrapInst1.type =System.label.BusinessStatus_Label; 
        wrapInst1.selectedOptions = strList1;
        wrapInst1.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst1);
        brs_myFilingsClass.filterWrapper wrapInst2= new brs_myFilingsClass.filterWrapper();
        wrapInst2.type =System.label.BusinessStatus_Label; 
        wrapInst2.selectedOptions = strList2;
        wrapInst2.searchType = 'Lien Dashboard Filing';
        wrapList.add(wrapInst2);
        brs_myFilingsClass.getBusinessFilingData(mainWrapInst.UserId,wrapList);
        
    }
    
    
    
    
    
    /*testMethod static void getDocuments1() {
        String Title='abc';
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling=BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder.id,'Approved',uccLien.id,'OFS');
        UCC_Filing__c uccfileInst = [select id,Sdoc_Filing_Number__c,Type__c,Status__c,Amendment_Type__c,recordtype.name from UCC_Filing__c where id =: uccFiling.Id];
        Attachment attach2=new Attachment();    
        attach2.Name=uccfileInst.Sdoc_Filing_Number__c + ' - ' + uccfileInst.Type__c;
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach2.body=bodyBlob2;
        attach2.parentId=uccFiling.id;
        insert attach2;
        Attachment attach=new Attachment();     
        attach.Name=System.label.Acceptance_N_Comparable;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=uccFiling.id;
        insert attach;
        Attachment attach1=new Attachment();    
        attach1.Name=System.label.Rejection_N_Comparable;
        Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob1;
        attach1.parentId=uccFiling.id;
        insert attach1;
        RecordType rt =[select id,Name,developername from RecordType where developername='Certificate_Request'];
        Certficate__c cert = new Certficate__c();
        cert=BRS_TestDataFactory.createCertificate(rt.id,acc.id,workOrder.id);
        Certficate__c certInst = [Select Type__c,Certificate_Type__c from Certficate__c where Id =: cert.Id];
        Attachment attach3=new Attachment();    
        attach3.Name=certInst.Certificate_Type__c + ' ' + certInst.Type__c;
        Blob bodyBlob3=Blob.valueOf('Unit Test Attachment Body');
        attach3.body=bodyBlob3;
        attach3.parentId=cert.id;
        insert attach3;
        Test.startTest();
        String FilingType=System.label.brs_viewFiling;
        brs_myFilingsClass.getDocuments(uccFiling.Id, FilingType);
        FilingType=System.label.brs_ApprovalEmailMessage;
        brs_myFilingsClass.getDocuments(uccFiling.Id, FilingType);
        FilingType=System.label.brs_RejectionNotice;
        brs_myFilingsClass.getDocuments(uccFiling.Id, FilingType);
        FilingType=System.label.CertificatesStage;
        brs_myFilingsClass.getDocuments(cert.Id, FilingType);
        //brs_myFilingsClass.getDocuments(null, FilingType);
        Copy_Request_Details__c copy = new Copy_Request_Details__c();
        copy.Account__c = acc.id;
        copy.UCC_Filing__c = uccFiling.id;
        copy.Other_Request__c = certInst.id;
        insert copy;
        brs_myFilingsClass.getDocuments(copy.Id, FilingType);
        Test.stopTest();
    }*/
    
    testMethod static void getDocuments2() {
        String Title='abc';
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        Business_Filing__c filing=new Business_Filing__c();
        filing=BRS_TestDataFactory.createBusinessFilingObject(rt.id,acc.id,workOrder.id,'Change of Email Address','Approved');      
        Business_Filing__c busFileInst = [Select id,Sdoc_Filing_Number__c,Business_Type__c,Status__c,Filing_Type__c,Citizenship__c from Business_Filing__c where id =: filing.Id];
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title=busFileInst.Sdoc_Filing_Number__c + ' - ' + busFileInst.Filing_Type__c, PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        Test.startTest();
        String FilingType=System.label.brs_viewFiling;
        brs_myFilingsClass.getDocuments(filing.Id, FilingType);

        brs_myFilingsClass.getDocuments(filing.Id, System.label.brs_ApprovalEmailMessage);
        brs_myFilingsClass.getDocuments(filing.Id, System.label.brs_RejectionNotice);
        
        
        
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=mainRecTypeId1;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = acc.id;
        cert.Work_Order__c = workOrder.id;
        insert cert;
        
        Copy_Request_Details__c copyDetails11 = new Copy_Request_Details__c();
        copyDetails11.Account__c=acc.Id;
        copyDetails11.Number_of_Copies__c=1;
        copyDetails11.Copy_Type__c='Plain';
        copyDetails11.Other_Request__c = cert.Id;
        insert copyDetails11;
        brs_myFilingsClass.getDocuments(copyDetails11.Id, FilingType);
        
        Test.stopTest();
    }
    testMethod public static void testDeleteFiling(){
        
        Id RecordTypeIdBusiness1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account ac=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='Non-Stock', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness1, Description='abc product',Office_Jurisdiction_BusinessState__c ='WA',State_or_Territory_Formation__c ='WA');
        insert ac; 
        
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        Business_Filing__c filing3 = new Business_Filing__c();
        
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.recordTypeId=RecordTypeIdBusiness;
        filing3.Type__c='Business Formation';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Filing_Date__c = System.Today().addDays(-30);
        filing3.Due_Date__c = (System.today() + 5);
        filing3.Status__c=System.label.Approved;
        filing3.Filing_Date__c=System.today();
        filing3.Mailing_Unit__c = 'test';
        filing3.Mailing_Street__c = 'test';
        filing3.Mailing_City__c = 'test';
        filing3.Mailing_State__c = 'test';
        filing3.Mailing_Zip_Code__c='test';
        filing3.Mailing_Country__c='test';
        insert filing3;
        
        Business_Filing__c bf3 = [Select id, Type__c, Account__c, Status__c from Business_Filing__c where id =: filing3.Id];
        
        Agent__c agt1 = new Agent__c();
        agt1.Agent_Account_ID__c = bf3.Account__c;
        insert agt1;
        
        List<Agent__c> agents = [Select id,Agent_Account_ID__c from Agent__c where  id =:agt1.Id];
        
        Principal__c pl1 = new Principal__c();
        pl1.Principal_Account_ID__c = filing3.Account__c;
        insert pl1;
        
        List<Principal__c> principals = [Select id,Principal_Account_ID__c,Business_ID__c from Principal__c where  Id = :pl1.Id];
            
            
        //brs_myFilingsClass.deleteFiling(filing3.id);
        Account acc=BRS_TestDataFactory.createAccountObject();
        Contact con=BRS_TestDataFactory.createContactObject('');
        Work_Order__c workOrd=BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c();      
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress', uccLien.Id,'');
        BRS_TestDataFactory.createUCCRelatedObject('', uccFiling.Id);
        //brs_myFilingsClass.deleteFiling(uccFiling.id);  
        
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con.id, 'Mail', 'Completed');
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=mainRecTypeId1;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = acc.Id;
        cert.Business_Name__c=acc.Name;
        cert.Work_Order__c = WorkOrder.Id;
        cert.Include_Expedited_Service__c=true;
        cert.Total_Number_of_Plain_Copies__c=1;
        cert.Total_Number_of_Certified_Copies__c=1;
        cert.Status__c='In-Progress';
        //insert cert;
        test.startTest();
        brs_myFilingsClass.deleteFiling(filing3.id);
        brs_myFilingsClass.deleteFiling(uccFiling.id);  
        //brs_myFilingsClass.deleteFiling(cert.id); 
        test.stopTest();
    }
    
    
    
    /*testMethod public static void testgetResumeFlowURLS(){
        //test.startTest();
        try{
            brs_myFilingsClass.getResumeFlowURLS();
        }catch (Exception ex) {
            System.assertEquals('expected text', ex.getMessage());
        }
        brs_myFilingsClass.getResumeFlowURLS();
        //test.stopTest();
    }*/
    @isTest
    private static void testDeleteMethod(){
           
        Id RecordTypeIdBusiness1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account ac=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Foreign',Business_Type__c ='Non-Stock', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                               ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                               sub_status__c = system.label.Active_Ready_for_Admin_Dissolution , RecordTypeId = RecordTypeIdBusiness1, Description='abc product',Office_Jurisdiction_BusinessState__c ='WA',State_or_Territory_Formation__c ='WA');
       test.startTest();
        insert ac; 
        
        Id RecordTypeIdBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        Business_Filing__c filing3 = new Business_Filing__c();
        
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.recordTypeId=RecordTypeIdBusiness;
        filing3.Type__c='Business Formation';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Filing_Date__c = System.Today().addDays(-30);
        filing3.Due_Date__c = (System.today() + 5);
        filing3.Status__c='In-Progress';
        filing3.Filing_Date__c=System.today();
        filing3.Mailing_Unit__c = 'test';
        filing3.Mailing_Street__c = 'test';
        filing3.Mailing_City__c = 'test';
        filing3.Mailing_State__c = 'test';
        filing3.Mailing_Zip_Code__c='test';
        filing3.Mailing_Country__c='test';
        insert filing3;
        
        Agent__c agt1 = new Agent__c();
        agt1.Agent_Account_ID__c = filing3.Account__c;
        agt1.Business_ID__c = filing3.Account__c;
        insert agt1;
                
        Principal__c pl1 = new Principal__c();
        pl1.Principal_Account_ID__c = filing3.Account__c;
         pl1.Business_ID__c =  filing3.Account__c;  
        insert pl1;
         brs_myFilingsClass.deleteFiling(filing3.id);
        test.stopTest();
    }
    
}