@istest(seeAllData = false)
public class brs_FilingStatusAuraHelper_Test {
    @TestSetup
    static void setup() {
        List<Account> accList=new List<Account>();
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        
        Account acCancelled=new Account();
        acCancelled.Name = 'Test Account';
        acCancelled.Citizenship__c='Foreign';
        acCancelled.Business_Type__c='Limited Partnership';
        acCancelled.ClientAccountNum__c='12345';
        acCancelled.Purpose_of_Business__c = 'Test business run';
        acCancelled.status__c = 'Active';
        acCancelled.Mailing_International_Address__c = '2';
        acCancelled.ShippingCountry = 'ALBANIA';
        acCancelled.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acCancelled.Date_of_Formation__c = Date.today().addDays(-2);
        acCancelled.Business_Name_in_state_country__c = 'Test Account';
        acCancelled.Description = 'TEST';
        acCancelled.Country_Formation__c  = 'TEST';
        acCancelled.State_or_Territory_Formation__c  = 'CT';
        acCancelled.Total_Authorized_Shares__c = 50;
        accList.add(acCancelled);
        
        Account acReinstate=new Account();
        acReinstate.Name = 'Test Account';
        acReinstate.Citizenship__c='Foreign';
        acReinstate.Business_Type__c='Limited Partnership';
        acReinstate.ClientAccountNum__c='12345';
        acReinstate.Purpose_of_Business__c = 'Test business run';
        acReinstate.status__c = 'Reserved';
        acReinstate.Mailing_International_Address__c = '2';
        acReinstate.ShippingCountry = 'ALBANIA';
        acReinstate.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acReinstate.Date_of_Formation__c = Date.today().addDays(-2);
        acReinstate.Business_Name_in_state_country__c = 'Test Account';
        acReinstate.Description = 'TEST';
        acReinstate.Country_Formation__c  = 'TEST';
        acReinstate.State_or_Territory_Formation__c  = 'CT';
        acReinstate.Total_Authorized_Shares__c = 50;
        accList.add(acReinstate);
        
        Account acRenuntiate=new Account();
        acRenuntiate.Name = 'Test Account';
        acRenuntiate.Citizenship__c='Domestic';
        acRenuntiate.Business_Type__c='LLP';
        acRenuntiate.ClientAccountNum__c='12345';
        acRenuntiate.Purpose_of_Business__c = 'Test business run';
        acRenuntiate.status__c = 'Active';
        acRenuntiate.Mailing_International_Address__c = '2';
        acRenuntiate.ShippingCountry = 'ALBANIA';
        acRenuntiate.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acRenuntiate.Date_of_Formation__c = Date.today().addDays(-2);
        acRenuntiate.Business_Name_in_state_country__c = 'Test Account';
        acRenuntiate.Description = 'TEST';
        acRenuntiate.Country_Formation__c  = 'TEST';
        acRenuntiate.State_or_Territory_Formation__c  = 'CT';
        acRenuntiate.Total_Authorized_Shares__c = 50;
        accList.add(acRenuntiate);
        
        Account acRenuntiate1=new Account();
        acRenuntiate1.Name = 'Test Account';
        acRenuntiate1.Citizenship__c='Domestic';
        acRenuntiate1.Business_Type__c='B Corp';
        acRenuntiate1.ClientAccountNum__c='12345';
        acRenuntiate1.Purpose_of_Business__c = 'Test business run';
        acRenuntiate1.status__c = 'Active';
        acRenuntiate1.Mailing_International_Address__c = '2';
        acRenuntiate1.ShippingCountry = 'ALBANIA';
        acRenuntiate1.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acRenuntiate1.Date_of_Formation__c = Date.today().addDays(-2);
        acRenuntiate1.Business_Name_in_state_country__c = 'Test Account';
        acRenuntiate1.Description = 'TEST';
        acRenuntiate1.Country_Formation__c  = 'TEST';
        acRenuntiate1.State_or_Territory_Formation__c  = 'CT';
        acRenuntiate1.Election_of_Bcorp_Status__c=true;
        acRenuntiate1.Total_Authorized_Shares__c=10;
        accList.add(acRenuntiate1);
        
        Account acWithDrawl=new Account();
        acWithDrawl.Name = 'Test Account';
        acWithDrawl.Citizenship__c='Foreign';
        acWithDrawl.Business_Type__c='LLC';
        acWithDrawl.ClientAccountNum__c='12345';
        acWithDrawl.Purpose_of_Business__c = 'Test business run';
        acWithDrawl.status__c = 'Forfeited';
        acWithDrawl.Mailing_International_Address__c = '2';
        acWithDrawl.ShippingCountry = 'ALBANIA';
        acWithDrawl.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acWithDrawl.Date_of_Formation__c = Date.today().addDays(-2);
        acWithDrawl.Business_Name_in_state_country__c = 'Test Account';
        acWithDrawl.Description = 'TEST';
        acWithDrawl.Country_Formation__c  = 'TEST';
        acWithDrawl.State_or_Territory_Formation__c  = 'CT';
        acWithDrawl.Total_Authorized_Shares__c = 50;
        accList.add(acWithDrawl);
        insert accList;
        
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        
        Customer_Balance_Transaction__c customerBal = new Customer_Balance_Transaction__c();
        customerBal=BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Credit',4000);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'Mail','In-Progress');
        RecordType cert =[select id,Name,developername from RecordType where developername='Certificate_Request'];
        Certficate__c certficate = new Certficate__c();
        certficate=BRS_TestDataFactory.createCertificate(cert.id,acc.id,workOrder.id);
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod=BRS_TestDataFactory.genericPaymentMethod(workOrder.id);
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        RecordType cr =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        RecordType arfr =[select id,Name,developername from RecordType where developername='Annual_Report_First_Report'];
        RecordType nb =[select id,Name,developername from RecordType where developername='New_Business'];
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        List<Business_Filing__c> businessList=new List<Business_Filing__c>();
        Business_Filing__c filing=new Business_Filing__c();
        filing=BRS_TestDataFactory.createBusinessFilingObject1(rt.id,acc.id,workOrder.id,'Amendment','Approved');
        businessList.add(filing);
        Business_Filing__c filing1=new Business_Filing__c();
        filing1=BRS_TestDataFactory.createBusinessFilingObject1(cr.id,acCancelled.id,workOrder.id,System.label.brs_Cancellation,null);
        businessList.add(filing1);
        Business_Filing__c filing2=new Business_Filing__c();
        filing2=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acRenuntiate.id,workOrder.id,System.label.BRS_Name_Reservation_Flow,null);
        businessList.add(filing2);
        Business_Filing__c filing3=new Business_Filing__c();
        filing3=BRS_TestDataFactory.createBusinessFilingObject1(cr.id,acWithDrawl.id,workOrder.id,System.label.brs_Reinstatement,null);
        filing3.Sub_Type__c= System.label.With_Annual_Report;
        filing3.Effective_Date__c = System.today();
        businessList.add(filing3);
        Business_Filing__c filing4=new Business_Filing__c();
        filing4=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acc.id,workOrder.id,'Registration of Name',null);
        businessList.add(filing4);
        Business_Filing__c filing5=new Business_Filing__c();
        filing5=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acc.id,workOrder.id,'Registration of Corporate Name',null);
        businessList.add(filing5);
        Business_Filing__c filing6=new Business_Filing__c();
        filing6=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acc.id,workOrder.id,'Renew Registration of Corporate Name',null);
        businessList.add(filing6);
        Business_Filing__c filing7=new Business_Filing__c();
        filing7=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acc.id,workOrder.id,System.label.brs_NameReserCancellationLabel,null);
        businessList.add(filing7);
        Business_Filing__c filing8=new Business_Filing__c();
        filing8=BRS_TestDataFactory.createBusinessFilingObject1(nr.id,acc.id,workOrder.id,System.label.Transfer_of_Name_Reservation,null);
        businessList.add(filing8);
        Business_Filing__c filing12=new Business_Filing__c();
        filing12=BRS_TestDataFactory.createBusinessFilingObject1(cr.id,acRenuntiate.id,'',System.label.Renunciation_Status_Report,null);
        businessList.add(filing12);
        Business_Filing__c filing13=new Business_Filing__c();
        filing13=BRS_TestDataFactory.createBusinessFilingObject1(cr.id,acRenuntiate.id,workOrder.id,System.label.Renunciation_Status_Report,null);
        businessList.add(filing13);
        insert businessList;
        /*List<SDOC__SDoc__c> sdocList =new List<SDOC__SDoc__c>();
        SDOC__SDoc__c sdoc = new SDOC__SDoc__c();
        sdocList=BRS_TestDataFactory.ListcreateSDoc(sdoc.Id);*/
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        List<UCC_Filing__c> uccFileLst = new List<UCC_Filing__c>();
        UCC_Filing__c uccFiling = new UCC_Filing__c(recordtypeid=recordTypeId.id,Lien_Filing_Type__c = 'Not Applicable',Amount__c = 50,Status__c = 'Approved',UCC_Lien_Type__c='OFS',Work_Order__c=workOrder.id,UCC_Lien_Id__c = uccLien.Id,Filing_Source__c='Online');
        uccFileLst.add(uccFiling);
        UCC_Filing__c uccFiling2 = new UCC_Filing__c(recordtypeid=recordTypeId.id,Lien_Filing_Type__c = 'Not Applicable',Amount__c = 50,Status__c = 'In-Progress',UCC_Lien_Type__c='OFS',Work_Order__c=workOrder.id,UCC_Lien_Id__c = null,Filing_Source__c='Online');
        uccFileLst.add(uccFiling2);
        test.startTest();
        insert uccFileLst;
        test.stopTest();
        boolean confirmFile;
        String docId;
           Account accdata = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Stock', Business_Email_Address__c = 'testbussinessemail@gmail.com',Franchise_Tax__c = 200,Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2 );
        insert accdata;
       Business_Filing__c bfc = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = accdata.Id, Source__c = System.Label.brs_FilingOnline);
        insert bfc;
                        RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
			Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            //Filing__c = 'Business Registration',
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
        
        Loop__DDP__c docgen1=new Loop__DDP__c(
            Name = 'UCC Filing Template',
            RecordTypeId = rc.Id,
            //Filing__c = 'Business Registration',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Business_Filing__c',
            Loop__Type__c = 'Letter'
        );
        insert docgen1;
        Loop__DDP_Integration_Option__c delivery1 = new Loop__DDP_Integration_Option__c(
            Name = 'UCC Filing Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen1.id
            
        );
        insert delivery1;
        Loop__DDP__c docgen2=new Loop__DDP__c(
            Name = 'UCC Filing Template',
            RecordTypeId = rc.Id,
            //Filing__c = 'Business Registration',
            Status__c = 'Approved;Rejected',
            Is_Active__c = true,
            Loop__Object_Name__c = 'UCC_Filing__c',
            Loop__Type__c = 'Letter'
        );
        insert docgen2;
        Loop__DDP_Integration_Option__c delivery2 = new Loop__DDP_Integration_Option__c(
            Name = 'UCC Filing Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen2.id
            
        );
        insert delivery2;
        Loop__DDP__c docgen3=new Loop__DDP__c(
            Name = 'certificate Template',
            RecordTypeId = rc.Id,
            //Filing__c = 'Business Registration',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Certficate__c',
            Loop__Type__c = 'Letter'
        );
        insert docgen3;
        Loop__DDP_Integration_Option__c delivery3 = new Loop__DDP_Integration_Option__c(
            Name = 'certificate Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen3.id
            
        );
        insert delivery3;
           Loop__DDP__c docgen4=new Loop__DDP__c(
            Name = 'certificate Template',
            RecordTypeId = rc.Id,
            //Filing__c = 'Business Registration',
            Status__c = 'Approved',
            Is_Active__c = true,
            Loop__Object_Name__c = 'Mark_Filing__c',
            Loop__Type__c = 'Letter'
        );
        insert docgen4;
        Loop__DDP_Integration_Option__c delivery4 = new Loop__DDP_Integration_Option__c(
            Name = 'certificate Delivery',
            RecordTypeId = rn.id,
            Loop__Output__c = 'PDF',
            Loop__Wait__c=true,
            Loop__Attach_As__c = 'Attachment',
            Loop__DDP__c = docgen4.id
            
        );
        insert delivery4;
    }
    
    testmethod static void getFilingRecord() {
        Account acc = [select id from Account limit 1];
        
        test.startTest();
        brs_FilingStatusAuraHelper.getFilingRecord(acc.Id);
        test.stopTest();
    }
    
    testmethod static void getFilingRecordWrit() {
        WRIT_Case__c writcase=new WRIT_Case__c();
        writcase=BRS_TestDataFactory.createWritCase();
        test.startTest();
        brs_FilingStatusAuraHelper.getFilingRecord(writcase.Id);
        test.stopTest();
    }
    
    testmethod static void generateFilingOutput() {
        Business_filing__c filing = [select id,Status__c,Type__c from Business_filing__c limit 1];
        test.startTest();
        try{
            brs_FilingStatusAuraHelper.generateFilingOutput(filing,'Approved');
        }catch(Exception e){System.debug(e);}
        try{
            brs_FilingStatusAuraHelper.generateFilingOutput(filing,'Rejected');
        }catch(Exception e){System.debug(e);}
        test.stopTest();
    }
    
    testmethod static void generateFilingAttachment() {
        Business_filing__c filing = [select id from Business_filing__c limit 1];
        List<String> listsdocId=new List<String>();
        listsdocId.add(filing.id);
        test.startTest();
        brs_FilingStatusAuraHelper.generateFilingAttachment(filing.Id, listsdocId);
        test.stopTest();
    }
    
    testmethod static void getCustomerDisplayMssg() {
        UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Type__c,Work_Order__c,Work_Order__r.Customer__r.Email from UCC_Filing__c limit 1];
        String status = filing.Status__c;
        test.startTest();
        brs_FilingStatusAuraHelper.getCustomerDisplayMssg(filing.id,status);
        brs_FilingStatusAuraHelper.getDisplayMssg(filing);

        filing.Type__c = 'Office Correct';
        update filing;
        brs_FilingStatusAuraHelper.getCustomerDisplayMssg(filing.id,status);
        brs_FilingStatusAuraHelper.getDisplayMssg(filing);

        filing.Work_Order__c = null;
        filing.Type__c = '';
        update filing;
        brs_FilingStatusAuraHelper.getCustomerDisplayMssg(filing.id,status);
        brs_FilingStatusAuraHelper.getDisplayMssg(filing);

        Business_filing__c businessfiling = [select id,Work_Order__c,Work_Order__r.Customer__r.Email,Status__c,Type__c from Business_filing__c limit 1];
        brs_FilingStatusAuraHelper.getCustomerDisplayMssg(businessfiling.id,'Approved');

        businessfiling.Work_Order__c =null;
        update businessfiling;
        brs_FilingStatusAuraHelper.getCustomerDisplayMssg(businessfiling.id,'Approved');
        brs_FilingStatusAuraHelper.getDisplayMssg(businessfiling);
        test.stopTest();
    }
    testmethod static void approveFiling() {
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where recordtypeid=:rt.id];
        String status = filing.Status__c;
        System.debug('filing.Status__c@@@'+filing.Status__c);
        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(uccfiling.id,confirmFile);
        test.stopTest();
    }
    
    testmethod static void approveFilingUCC1() {
        test.startTest();
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where recordtypeid=:rt.id];
        String status = filing.Status__c;
        Boolean confirmFile=false;
        uccfiling.Type__c = 'Aircraft';
        update uccfiling;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(uccfiling.id,confirmFile);
        test.stopTest();
    }
    
    testmethod static void approveFilingUCC2() {
        test.startTest();
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where recordtypeid=:rt.id];
        String status = filing.Status__c;
        Boolean confirmFile=false;
        uccfiling.Type__c = 'Judgment';
        update uccfiling;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(uccfiling.id,confirmFile);
        test.stopTest();
    }
    
    testmethod static void approveFilingUCC3() {
        test.startTest();
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where recordtypeid=:rt.id];
        String status = filing.Status__c;
        Boolean confirmFile=false;
        uccfiling.Type__c = 'OFS';
        uccfiling.UCC_Lien_Type__c = 'IRS' ;
        update uccfiling;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(uccfiling.id,confirmFile);
        test.stopTest();
    }
    testmethod static void approveFilingCert() {
        RecordType cert =[select id,Name,developername from RecordType where developername='Certificate_Request'];
        Boolean confirmFile=false;
        Certficate__c certinfo=[Select id from Certficate__c];
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(certinfo.id,confirmFile);
        test.stopTest();
    }
    testmethod static void approveFiling1() {
        test.startTest();
        Account acc = [select id from Account limit 1];
        acc.Citizenship__c = 'Domestic';
        acc.Business_Type__c = 'General Partnerships';
        acc.Status__c = 'Expired';
        acc.Total_Authorized_Shares__c = 120;
        update acc;
        RecordType cr =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Business_filing__c filing1=[select id,Status__c from Business_filing__c where recordtypeid=:cr.id and Type__c=:'Cancellation'];
        Business_filing__c filing2=[select id,Status__c,Account__c,Effective_Date__c,Sub_Type__c from Business_filing__c where recordtypeid=:cr.id and Type__c =: 'Reinstatement'];
        filing2.Sub_Type__c = 'With Org & 1st report';
        filing2.Account__c = acc.id;
        //update filing2;
        Boolean confirmFile=false;
        brs_FilingStatusAuraHelper.approveFiling(filing1.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(filing2.id,confirmFile);
        test.stopTest();
    }
    testmethod static void approveFiling2() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        Business_filing__c filing2=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =: 'Business Name Reservation'];
        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing2.id,confirmFile);
        test.stopTest();
    }

    /*testmethod static void approveFiling900() {
        RecordType rt =[select id,Name,developername from RecordType where developername='Close_Reinstate' LIMIT 1];
        Account acc = [SELECT id,Citizenship__c,Business_Type__c from Account where Status__c='Reserved' AND Name='Test Account' LIMIT 1];
        acc.Citizenship__c = 'Domestic';
        acc.Business_Type__c = 'Cemetery';
        update acc;
        Work_Order__c workOrder = [SELECT ID from Work_Order__c LIMIT 1];
        Business_Filing__c filing=new Business_Filing__c();
        filing=BRS_TestDataFactory.createBusinessFilingObject1(rt.id,acc.id,workOrder.id,'Amendment','Approved');
        filing.Type__c = 'Reinstatement';
        filing.Effective_Date__c = System.Today();
        filing.Sub_Type__c = 'With Org & 1st report';
        insert filing;
        

        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        
        filing.Sub_Type__c = 'With Annual report';
        filing.Filing_Date__c = system.today();
        update filing;
          brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        filing.Filing_Date__c=null;
        update filing;
        acc.Business_Type__c='LLC';
        update acc;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        
        filing.Type__c ='Renew Registration of Corporate Name';
        update filing;
        
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        filing.Type__c = 'Transfer of Registration of Name';
        update filing;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        
        filing.Type__c = 'Business Formation';
        update filing;
        brs_FilingStatusAuraHelper.approveFiling(filing.id,confirmFile);
        test.stopTest();
    }*/
    
    testmethod static void approveFiling901(){
        Test.startTest();
        Account acc1 = [SELECT id from Account LIMIT 1];
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Request for Search of Mark').getRecordTypeId();
        Contact con1 = [SELECT id from Contact where AccountId =:acc1.Id LIMIT 1];
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.id, 'Mail', 'Completed');
       // workOrder.Name = 'Testjhj';
       // update workOrder;
       Certficate__c cert = new Certficate__c();
       cert.RecordTypeId=mainRecTypeId1;
       cert.Type__c='Certificate of Legal Existence';
       cert.Certificate_Type__c='Standard';
       cert.Business__c = acc1.id;
       cert.Work_Order__c = workOrder.id;
        cert.Status__c = 'Approved';
       insert cert;
         Blob bodyBlob=Blob.valueOf('Test blob');
         ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;
            
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
            ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = cert.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        
        Test.stopTest();
    }
    
    
    
    testmethod static void approveFiling3() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        Business_filing__c filing7=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =:'Registration of Name'];
        Business_filing__c filing8=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =:'Registration of Corporate Name'];
        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing7.id,confirmFile);
        brs_FilingStatusAuraHelper.approveFiling(filing8.id,confirmFile);
        test.stopTest();
    }
    testmethod static void approveFiling4() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        Business_filing__c filing6=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =:'Cancellation of Name Reservation'];
        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing6.id,confirmFile);
        test.stopTest();
    }
    
    testmethod static void approveFiling5() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        Business_filing__c filing7=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =:'Transfer of Name Reservation'];
        Boolean confirmFile=false;
        test.startTest();
        brs_FilingStatusAuraHelper.approveFiling(filing7.id,confirmFile);
        test.stopTest();
    }
    testmethod static void approveFiling6() {
        test.startTest();
        Boolean confirmFile=false;
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        Blob bodyBlob=Blob.valueOf('Test blob');
        String imagename=markfiling.Sdoc_Filing_Number__c + ' - Mark Image';
        system.debug('iamge name testclass:' + imagename);
        ContentVersion cv = new ContentVersion(Title=imagename, PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = markfiling.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        
        brs_FilingStatusAuraHelper.approveFiling(markfiling.id,confirmFile);
        test.stopTest();
    }
    testmethod static void rejectFiling() {
        test.startTest();                     
        UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c,Type__c,Work_Order__r.Customer__r.Email from UCC_Filing__c limit 1];
        if(filing.Status__c !=null && filing.Status__c != 'Rejected')
        {
            filing.Status__c='Rejected';
            update filing;
        }
        Boolean confirmFile;
        
        brs_FilingStatusAuraHelper.rejectFiling(filing,true);
        brs_FilingStatusAuraHelper.rejectFiling(filing,confirmFile);
        brs_FilingStatusAuraHelper.generateNintexOutputDigitalCopyReq(filing.Id,'Approved');
        test.stopTest();
    }
    
    testmethod static void getFiles(){
        Business_filing__c filing = [select id,Status__c from Business_filing__c limit 1];
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        test.startTest();
        brs_FilingStatusAuraHelper.getFiles(filing.Id,contentLink.ContentDocumentId,false);
        test.stopTest();
    }
    
    testmethod static void deleteFiles(){
        Business_filing__c filing = [select id,Status__c,Sdoc_Filing_Number__c,Filing_Type__c from Business_filing__c limit 1];
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        string sdocumentId = contentLink.ContentDocumentId;
        test.startTest();
        brs_FilingStatusAuraHelper.deleteFiles(filing,sdocumentId);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow() {
        List<brs_FilingStatusAuraHelper.Requests> Requests1 = new List<brs_FilingStatusAuraHelper.Requests>();
        List<Business_filing__c> bfiling =[Select Id, RecordTypeId, Type__c, Status__c from Business_Filing__c  LIMIT 2];
        for(Business_filing__c bus : bfiling )
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = bus.Id;
            Requests1.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests1);
        test.stopTest();
    }
    
    testmethod static void approveFilingfromFlow1() {
        List<brs_FilingStatusAuraHelper.Requests> Requests2 = new List<brs_FilingStatusAuraHelper.Requests>();
        List<UCC_Filing__c> filing1=[select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c='In-Progress' limit 1];
        for(UCC_Filing__c ucc:filing1)
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid=ucc.id;
            Requests2.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests2);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow2() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        List<brs_FilingStatusAuraHelper.Requests> Requests3 = new List<brs_FilingStatusAuraHelper.Requests>();
        List<Business_filing__c> bfiling2=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =: 'Business Name Reservation'];
        for(Business_filing__c business : bfiling2 )
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = business.Id;
            Requests3.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests3);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow3() {
        RecordType cr =[select id,Name,developername from RecordType where developername='Close_Reinstate'];
        Business_filing__c filing8=[select id,Status__c,Effective_Date__c,Sub_Type__c from Business_filing__c where recordtypeid=:cr.id and Type__c =: 'Reinstatement'];
        filing8.Effective_Date__c=System.today();
        filing8.Sub_Type__c = System.label.With_First_Report;
        List<Business_Filing__c> listbusiness=new List<Business_Filing__c>();
        listbusiness.add(filing8);
        List<brs_FilingStatusAuraHelper.Requests> Requests4 = new List<brs_FilingStatusAuraHelper.Requests>();
        for(Business_filing__c busidata : listbusiness )
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = busidata.Id;
            Requests4.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests4);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow4() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        List<Business_filing__c> filing3=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =: 'Registration of Name'];
        List<brs_FilingStatusAuraHelper.Requests> Requests5 = new List<brs_FilingStatusAuraHelper.Requests>();
        for(Business_filing__c filingdata : filing3 )
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = filingdata.Id;
            Requests5.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests5);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow5() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        List<Business_filing__c> filing4=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =: 'Registration of Corporate Name'];
        List<brs_FilingStatusAuraHelper.Requests> Requests6 = new List<brs_FilingStatusAuraHelper.Requests>();
        for(Business_filing__c filinginfo : filing4 )
        {
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = filinginfo.Id;
            Requests6.add(req);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests6);
        test.stopTest();
    }
    testmethod static void approveFilingfromFlow7() {
        RecordType nr =[select id,Name,developername from RecordType where developername='Name_Reservation'];
        List<Business_filing__c> filing6=[select id,Status__c from Business_filing__c where recordtypeid=:nr.id and Type__c =:'Cancellation of Name Reservation'];
        List<brs_FilingStatusAuraHelper.Requests> Requests8 = new List<brs_FilingStatusAuraHelper.Requests>();
        for(business_filing__c file6:filing6)
        {
            brs_FilingStatusAuraHelper.Requests req6= new brs_FilingStatusAuraHelper.Requests();
            req6.recordid=file6.id;
            Requests8.add(req6);
        }
        test.startTest();
        brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests8);
        test.stopTest();
    }
    testmethod static void approveUUCFilingfromFlowTest() {
        
        try{
            
            UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c from UCC_Filing__c where UCC_Lien_Id__c != null limit 1];
            UCC_Filing__c filing1 = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c from UCC_Filing__c where UCC_Lien_Id__c = null limit 1];
            brs_FilingStatusAuraHelper.Requests req = new brs_FilingStatusAuraHelper.Requests();
            req.recordid = filing.Id;
            brs_FilingStatusAuraHelper.Requests req1 = new brs_FilingStatusAuraHelper.Requests();
            req1.recordid = filing1.Id;
            List<brs_FilingStatusAuraHelper.Requests> Requests1 = new List<brs_FilingStatusAuraHelper.Requests>();
            Requests1.add(req);
            List<brs_FilingStatusAuraHelper.Requests> Requests2 = new List<brs_FilingStatusAuraHelper.Requests>();
            Requests2.add(req1);
            test.startTest();
            brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests1);
            brs_FilingStatusAuraHelper.approveFilingfromFlow(Requests2);
            test.stopTest();
        }catch(DmlException ex){
            
        }
    }
    
    testmethod static void rejectFilingfromFlow() {
        try{
            UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c from UCC_Filing__c limit 1];
            Boolean confirmFile;
            test.startTest();
            brs_FilingStatusAuraHelper.rejectFilingfromFlow(filing,confirmFile);
            test.stopTest();
        }catch(exception e){
            
        }
    }
    
    testmethod static void generateEmailAttachment() {
        UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c,Type__c,Work_Order__c,Amendment_Type__c,Sdoc_Filing_Number__c from UCC_Filing__c limit 1];
        test.startTest();
        brs_FilingStatusAuraHelper.generateEmailAttachment(filing);
        test.stopTest();
    }
    
    testmethod static void renameBOUpload() {
        UCC_Filing__c filing = [select id,RecordTypeId,Status__c,Reason_for_Rejection__c,Filing_Source__c,Type__c from UCC_Filing__c limit 1];
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        test.startTest();
        brs_FilingStatusAuraHelper.renameBOUpload(filing);
        test.stopTest();
    }
    
    testmethod static void generateRequestForInfo() {
        Business_filing__c filing = [select id,Status__c,Type__c from Business_filing__c limit 1];
        string filingType='';
        test.startTest();
        brs_FilingStatusAuraHelper.generateRequestForInfo(filing.Id,filingType);
        test.stopTest();
    }
    testmethod static void createMarkFilingObject()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        brs_FilingStatusAuraHelper.createMarkObject(markfiling);
        test.stopTest();
        
    }
    testmethod static void createMarkObject()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        brs_FilingStatusAuraHelper.updateMarkObjectonRenewal(markfiling);
        test.stopTest();
        
    }
    testmethod static void checkMarkFilings()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
    testmethod static void checkMarkFilings111()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        markfiling.Owner_Zip_Code__c = '';
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        update markfiling;
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
    testmethod static void checkMarkFilings112()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        markfiling.Owner_Zip_Code__c = '';
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        markfiling.Owner_Type__c = 'Individual';
        markfiling.Owner_Street_Address__c = 'ghghg';
        markfiling.State_Country_of_Formation__c = '';
        markfiling.Owner_Country__c = 'United States';
        markfiling.Owner_State__c = 'AK';
        markfiling.Owner_City__c = 'Washington';
        update markfiling;
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
    testmethod static void checkMarkFilings113()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        markfiling.Owner_Zip_Code__c = '12345';
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        markfiling.Owner_Type__c = 'Individual';
        markfiling.Owner_Street_Address__c = 'ghghg';
        markfiling.State_Country_of_Formation__c = '';
        markfiling.Owner_Country__c = 'United States';
        markfiling.Owner_State__c = 'AK';
        markfiling.Owner_City__c = 'Washington';
        markfiling.Owner_Name__c = 'hggh';
        update markfiling;
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
    testmethod static void checkMarkFilings114()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        markfiling.Owner_Zip_Code__c = '12345';
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        markfiling.Owner_Type__c = 'Corporation';
        markfiling.Owner_Street_Address__c = 'ghghg';
        markfiling.State_Country_of_Formation__c = '';
        markfiling.Owner_Country__c = 'United States';
        markfiling.Owner_State__c = 'AK';
        markfiling.Owner_City__c = 'Washington';
        markfiling.Owner_Name__c = 'hggh';
        update markfiling;
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
    testmethod static void checkMarkFilings115()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Registration');
        markfiling.Owner_Zip_Code__c = '12345';
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        markfiling.Owner_Type__c = 'Individual';
        markfiling.Owner_Street_Address__c = 'ghghg';
        markfiling.State_Country_of_Formation__c = '';
        markfiling.Owner_Country__c = 'United States';
        markfiling.Owner_State__c = 'AK';
        markfiling.Owner_City__c = 'Washington';
        markfiling.Owner_Name__c = 'hggh';
        markfiling.Date_of_1st_Use_in_CT__c = System.today();
        markfiling.Date_of_1st_Use_Anywhere__c = System.today();
        markfiling.Registration_Date__c = System.today();
        markfiling.Federal_Registration_of_Mark__c = '';
        markfiling.Number_of_Pages__c = 0;
        update markfiling;
        Mark_Filing__c markfiling1=new Mark_Filing__c();
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    testmethod static void checkMarkFilings1()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Renewal_Cancellation'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Renewal');
        Mark_Filing__c markfiling28=new Mark_Filing__c();
        markfiling28=BRS_TestDataFactory.createMarkFiling1(null,rt.id,'Renewal');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling28.id);
        test.stopTest();
        
    }
    testmethod static void checkMarkFilings2()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Assignment'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Assignment');
        Mark_Filing__c markfiling29=new Mark_Filing__c();
        //markfiling29=BRS_TestDataFactory.createMarkFiling1(null,rt.id,'Assignment');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        //brs_FilingStatusAuraHelper.checkMarkFilings(markfiling29.id);
        test.stopTest();
    }

    testmethod static void checkMarkFilings200()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        mark.Status__c='Active';
        update mark;
        RecordType rt =[select id,Name,developername from RecordType where developername='Assignment'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Assignment');
        markfiling.Assignee_Name__c='';
        markfiling.Assignee_Type__c='';
        markfiling.Assignee_Street_Address__c='';
        markfiling.Assignee_Country__c='';
        markfiling.Assignee_State__c='';
        markfiling.Assignee_City__c='';
        markfiling.Assinee_Zip_Code__c='';
        update markfiling;
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);

        markfiling.Assignee_Type__c='Corporation';
        markfiling.Assignee__c = '';
        update markfiling; 
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);

        test.stopTest();
    }
    testmethod static void checkMarkFilings3()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Owner Name Change');
        Mark_Filing__c markfiling32=new Mark_Filing__c();
        markfiling32=BRS_TestDataFactory.createMarkFiling1(null,rt.id,'Owner Name Change');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling32.id);
        test.stopTest();
        
    }
    testmethod static void checkMarkFilings4()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Owner Address Change');
        Mark_Filing__c markfiling30=new Mark_Filing__c();
        markfiling30=BRS_TestDataFactory.createMarkFiling1(null,rt.id,'Owner Address Change');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling30.id);
        test.stopTest();
        
    }
    testmethod static void checkMarkFilings5()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'State of Formation Change');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }

    testmethod static void checkMarkFilings500()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        mark.status__c='Active';
        update mark;
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'State of Formation Change');
        markfiling.Previous_Name_State__c='';
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        markfiling.State_Country_of_Formation__c='';
        update markfiling;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
        testmethod static void checkMarkFilingsCancellation()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Renewal_Cancellation'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(null,rt.id,'Cancellation');
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    testmethod static void updateMarkObjectwithOwnerAddressData()
    {test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        
        brs_FilingStatusAuraHelper.updateMarkObjectwithOwnerAddress(markfiling);
        brs_FilingStatusAuraHelper.updateMarkObjectwithOwnerName(markfiling);
        brs_FilingStatusAuraHelper.updateMarkObjectwithStateCountryofFormation(markfiling);
        test.stopTest();
        
    }
    testmethod static void ValidateAndCompleteWRITCase()
    {test.startTest();
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c writcase=new WRIT_Case__c();
        writcase=BRS_TestDataFactory.createWritCase();
        Defendants__c defendant=new Defendants__c();
        defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(writcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase0()
    {test.startTest();
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c writcase=new WRIT_Case__c();
        writcase=BRS_TestDataFactory.createWritCase();
        writcase.Status__c = 'In-Progress';
        //writcase.Number_of_Defendants__c = 0;
        update writcase;
        /* Defendants__c defendant=new Defendants__c();
Defendants__c defendant1=new Defendants__c();
defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
defendant1 =BRS_TestDataFactory.createDefendant(rt.id,writcase.id);*/
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(writcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase1()
    {test.startTest();
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c writcase=new WRIT_Case__c();
        writcase=BRS_TestDataFactory.createWritCase();
        Defendants__c defendant=new Defendants__c();
        defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(writcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase2()
    {test.startTest();
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c writcase=new WRIT_Case__c();
        writcase=BRS_TestDataFactory.createWritCase();
        Defendants__c defendant=new Defendants__c();
        defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(writcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase3()
    {
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c wcase=new WRIT_Case__c();
        wcase.Type__c='WRIT Case';
        wcase.Status__c='In-Progress';
        wcase.Number_of_Defendants__c=1;
        wcase.Title_Plaintiff__c='case';
        wcase.Title_Defendant__c='des';
        insert wcase;
        
        Defendants__c defendant=new Defendants__c();
        Defendants__c defendant1=new Defendants__c();
        //Defendants__c defendant2=new Defendants__c();
        //defendant=BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        //defendant1 =BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        // defendant2 =BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        test.startTest();
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(wcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase4()
    {	test.startTest();
        Account acc=[select id from account limit 1];
        Work_Order__c workorder=[select id from Work_Order__c limit 1];
        workorder.Payments_Verified__c=false;
        update workorder;
        
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c wcase=new WRIT_Case__c();
        wcase.Type__c='WRIT Case';
        wcase.Status__c='In-Progress';
        wcase.Number_of_Defendants__c=1;
        wcase.Title_Plaintiff__c='case';
        wcase.Title_Defendant__c='des';
        wcase.Work_Order__c = workorder.id;
        //wcase.Approved_Defendants__c = 1;
        insert wcase;
        
        Defendants__c defendant=new Defendants__c();
        Defendants__c defendant1=new Defendants__c();
        //Defendants__c defendant2=new Defendants__c();
        defendant=BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        //defendant1 =BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        // defendant2 =BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(wcase.id);
        test.stopTest();
    }
    
    testmethod static void ValidateAndCompleteWRITCase5()
    {	test.startTest();
        Account acc=[select id from account limit 1];
        Work_Order__c workorder=[select id from Work_Order__c limit 1];
        workorder.Payments_Verified__c=true;
        update workorder;
        
        RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
        WRIT_Case__c wcase=new WRIT_Case__c();
        wcase.Type__c='WRIT Case';
        wcase.Status__c='In-Progress';
        wcase.Number_of_Defendants__c=1;
        wcase.Title_Plaintiff__c='case';
        wcase.Title_Defendant__c='des';
        wcase.Work_Order__c = workorder.id;
        //wcase.Approved_Defendants__c = 1;
        insert wcase;
        
        Defendants__c defendant=new Defendants__c();
        Defendants__c defendant1=new Defendants__c();
        //Defendants__c defendant2=new Defendants__c();
        defendant=BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        //defendant1 =BRS_TestDataFactory.createDefendant(rt.id,wcase.id);
        // defendant2 =BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
        
        brs_FilingStatusAuraHelper.ValidateAndCompleteWRITCase(wcase.id);
        test.stopTest();
    }
    
    testmethod static void completeWRIT()
    {
        //Account acc=[select id from account limit 1];
        //Work_Order__c workorder=[select id from Work_Order__c limit 1];
        //workorder.Payments_Verified__c=false;
        //update workorder;
        try
        {
            RecordType rt =[select id,Name,developername from RecordType where developername='Approved'];
            WRIT_Case__c writcase=new WRIT_Case__c();
            writcase=BRS_TestDataFactory.createWritCase();
            Defendants__c defendant=new Defendants__c();
            defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
            defendant.Type_of_Defendant__c = 'Corporation';
            defendant.Section_Number__c = '33-1219';
            defendant.Mailing_Status__c = 'SOS Agent';
            defendant.Address_Street_1__c = 'test';
            defendant.City__c = 'Stest';
            defendant.State__c = 'Stest';
            defendant.Zip_Code__c = 'Stest';
            defendant.Country__c = 'Stest';
            defendant.Mail_Type__c = 'Certified';
            defendant.Mail_Number__c = 'hhhhhhhhhhttttttttll';
            update defendant;
            test.startTest();
            brs_FilingStatusAuraHelper.completeWRIT(writcase);
            test.stopTest();
        }
        catch(exception e)
        {
            system.debug(e);
        }
    }
    
    testmethod static void completeWRITRej()
    {
        try{
            //Account acc=[select id from account limit 1];
            //Work_Order__c workorder=[select id from Work_Order__c limit 1];
            //workorder.Payments_Verified__c=false;
            //update workorder;
            RecordType rt =[select id,Name,developername from RecordType where developername='Rejected'];
            WRIT_Case__c writcase=new WRIT_Case__c();
            writcase=BRS_TestDataFactory.createWritCase();
            //Defendants__c defendant=new Defendants__c();
            //defendant=BRS_TestDataFactory.createDefendant(rt.id,writcase.id);
            Defendants__c defendant=new Defendants__c();
            defendant.WRIT_Case__c=writcase.id;
            defendant.RecordTypeId=rt.id;
            defendant.Defendant_Name__c='def';
            defendant.Type_of_Defendant__c='Individuals';
            defendant.Section_Number__c='52-57';
            defendant.Mailing_Status__c='No Mailing';
            
            defendant.Type_of_Defendant__c = 'Corporation';
            defendant.Section_Number__c = '33-1219';
            defendant.Mailing_Status__c = 'SOS Agent';
            defendant.Address_Street_1__c = 'test';
            defendant.City__c = 'Stest';
            defendant.State__c = 'Stest';
            defendant.Zip_Code__c = 'Stest';
            defendant.Country__c = 'Stest';
            defendant.Mail_Type__c = 'Certified';
            defendant.Mail_Number__c = 'Stest7jhgtdrbnjh';
            // defendant.Rejection_Reason__c = 'No affidavit';
            defendant.Rejection_custom_reason__c = 'ghfhfgf';
            insert defendant;
            test.startTest();
            brs_FilingStatusAuraHelper.completeWRIT(writcase);
            test.stopTest();
        }catch(Exception e){System.debug(e);}
    }
    testmethod static void updateOwnerDetailsOnAssignmentTest(){
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        brs_FilingStatusAuraHelper.updateOwnerDetailsOnAssignment(markfiling);
        test.stopTest();
    }
    testmethod static void otherRequestValidationsTest(){
        test.startTest();
        Id businessCopyRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();
        Id uccCopyRecordType = Schema.SObjectType.Copy_Request_Details__c.getRecordTypeInfosByName().get('UCC Filling Request').getRecordTypeId();
        
        Id tradeCopyRecordType = Schema.SObjectType.Copy_Request_Details__c.getRecordTypeInfosByName().get('Trade and Service Mark Filling Request').getRecordTypeId();
        Account acc = [Select id from Account where Business_Email_Address__c = 'testbussinessemail@gmail.com'];
        //Account acc = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Stock', Business_Email_Address__c = 'testbussinessemail@gmail.com',Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2 );
        //insert acc;
        Contact con = [Select id from contact LIMIT 1];
        //Contact con=new Contact();
        //con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1 = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Email', 'Open');
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        update workOrder1;
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Certficate__c cert1 = BRS_TestDataFactory.createCertificate(businessCopyRecordType,acc.Id,workOrder1.Id);
        //Business_Filing__c bfc = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id, Source__c = System.Label.brs_FilingOnline);
        //insert bfc;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where Source__c='Online'];
        Copy_Request_Details__c copyDetails1 = new Copy_Request_Details__c();
        copyDetails1.Account__c=acc.Id;
        copyDetails1.Other_Request__c=cert1.Id;
        copyDetails1.Business_Filing__c=filing.Id;
        copyDetails1.Number_of_Copies__c=1;
        copyDetails1.Copy_Type__c='Plain';
        insert copyDetails1;
        brs_FilingStatusAuraHelper.otherRequestValidations(cert1);
        copyDetails1.Copy_Type__c='Certified';
        update copyDetails1;
         brs_FilingStatusAuraHelper.otherRequestValidations(cert1);
        copyDetails1.RecordTypeId=uccCopyRecordType;
        update copyDetails1;
        test.stopTest();
    
    }
        testmethod static void otherRequestValidationsTest1(){
            test.startTest();
            try
            {
                Id businessCopyRecordType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Business Copy Request').getRecordTypeId();
        Id uccCopyRecordType = Schema.SObjectType.Copy_Request_Details__c.getRecordTypeInfosByName().get('UCC Filling Request').getRecordTypeId();
        
        Id tradeCopyRecordType = Schema.SObjectType.Copy_Request_Details__c.getRecordTypeInfosByName().get('Trade and Service Mark Filling Request').getRecordTypeId();
        Account acc = [Select id from Account where Business_Email_Address__c = 'testbussinessemail@gmail.com'];
        //Account acc = new Account(Name = 'Test Account',Citizenship__c = 'Domestic', Business_Type__c = 'Stock', Business_Email_Address__c = 'testbussinessemail@gmail.com',Legal_Structure_Acknowledgement__c= false, Total_Authorized_Shares__c = 2 );
        //insert acc;
        Contact con = [Select id from contact LIMIT 1];
        //Contact con=new Contact();
        //con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1 = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Email', 'Open');
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        update workOrder1;
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Certficate__c cert1 = BRS_TestDataFactory.createCertificate(businessCopyRecordType,acc.Id,workOrder1.Id);
        //Business_Filing__c bfc = new Business_Filing__c(Status__c = System.Label.BRS_FilingStatus_Approved, Account__c = acc.Id, Source__c = System.Label.brs_FilingOnline);
        //insert bfc;
        RecordType rt =[select id,Name,developername from RecordType where developername='Maintenance'];
        UCC_Filing__c uccfiling = [select id,RecordTypeId,Status__c from UCC_Filing__c where Status__c=:'In-Progress' limit 1];
        Business_filing__c filing = [select id,Status__c from Business_filing__c where Source__c='Online'];
        Copy_Request_Details__c copyDetails1 = new Copy_Request_Details__c();
        copyDetails1.Account__c=acc.Id;
        copyDetails1.Other_Request__c=cert1.Id;
        copyDetails1.Business_Filing__c=filing.Id;
        copyDetails1.Number_of_Copies__c=1;
        copyDetails1.Copy_Type__c='Plain';
        insert copyDetails1;
        brs_FilingStatusAuraHelper.otherRequestValidations(cert1);
        copyDetails1.RecordTypeId=tradeCopyRecordType;
        update copyDetails1;
        brs_FilingStatusAuraHelper.otherRequestValidations(cert1);    
            }
            catch(Exception e)
            {
                System.debug('**Exception');
            }
            test.stopTest();
            
        }
    testmethod static void completeMassAgentChangeTest(){
         Contact con = [Select id from contact LIMIT 1];        
         Id workorderid=[select id from work_order__c limit 1].id;
         Mass_Agent_Change__c massAgent=new Mass_Agent_Change__c();
        massAgent.Customer__c=con.Id;
        massAgent.Work_Order__c=workorderid;
        massAgent.Filing_Date__c = system.today();
        massAgent.Effective_Date_Time__c = (System.now()).addDays(2);
        insert massAgent;
        brs_FilingStatusAuraHelper.completeMassAgentChange(massAgent);
        brs_FilingStatusAuraHelper.getFilingRecord(massAgent.Id);
    }
    testmethod static void updateMarkFilingTest()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        markfiling.recordtypeId=Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Renewal/Cancellation').getRecordTypeId();
        markfiling.Filing_Type__c='Renewal';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
         markfiling.Filing_Type__c='Cancellation';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        markfiling.recordtypeId=Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Assignment').getRecordTypeId();
        markfiling.Filing_Type__c='Assignment';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        markfiling.recordtypeId=Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Owner Updates').getRecordTypeId();
        markfiling.Filing_Type__c='Owner Address Change';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        markfiling.Filing_Type__c='Owner Name Change';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        
        test.stopTest();
        
    }
      testmethod static void updateMarkFilingTest1()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
         markfiling.recordtypeId=Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Owner Updates').getRecordTypeId();
        markfiling.Filing_Type__c='State of Formation Change';
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
         markfiling.recordtypeId=Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Renewal/Cancellation').getRecordTypeId();
        markfiling.Filing_Type__c='Renewal';
         markfiling.Mark__c=null;
        update markfiling;
        brs_FilingStatusAuraHelper.approveFiling(markfiling.Id, true);
        test.stopTest();
    }
    testmethod static void checkMarkFilingstest()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        Id rt =Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Owner Updates').getRecordTypeId();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt,'Owner Address Change');
        mark.Status__c=System.label.ACTIVE;
        update mark;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
    }
    testmethod static void checkMarkFilingstest1()
    {
        test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        Id rt =Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Owner Updates').getRecordTypeId();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt,'Owner Name Change');
        mark.Status__c=System.label.ACTIVE;
        update mark;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        markfiling.Previous_Name_State__c='test';
        update markfiling;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        
        markfiling.Owner_Name__c='test';
        update markfiling;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        
         markfiling.Image_Path__c='test';
        update markfiling;
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
    }
      testmethod static void renameUploadedMicrofilmInformation()
    {
         test.startTest();
        Business_filing__c filing = [select id,Status__c,Sdoc_Filing_Number__c,Filing_Type__c from Business_filing__c limit 1];
        Blob bodyBlob=Blob.valueOf('Test blob');
        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.pdf',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;     
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = filing.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        string sdocumentId = contentLink.ContentDocumentId;
        brs_FilingStatusAuraHelper.renameUploadedMicrofilm(filing,sdocumentId);
        brs_FilingStatusAuraHelper.getFileDetails(filing.id);
        test.stopTest();
    }
    
    testmethod static void checkMarkFilings116()
    {	test.startTest();
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Registration'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.RecordTypeId=rt.id;
        markfiling.Filing_Type__c='Registration';
        markfiling.Mark_Type__c='Certification Mark';
        markfiling.Owner_City__c='Washington';
		markfiling.Owner_Country__c='United States';
		markfiling.Owner_Name__c='Jhon';
		markfiling.Owner_State__c='AK';
		markfiling.Owner_Street_Address__c='123 street';
		markfiling.Owner_Type__c='Individual';
		markfiling.Owner_Unit__c='pq123';
		markfiling.Owner_Zip_Code__c='45678';
        markfiling.Mark__c=mark.id;
        markfiling.Registration_Date__c= system.today();
        markfiling.Class_of_Goods_Service__c = 'Paints';
        markfiling.Description_of_Mark__c = 'test';
        markfiling.Mark_used_for__c = 'AlMark';
        markfiling.Method_of_use__c = 'Method used';
        markfiling.Date_of_1st_Use_in_CT__c = System.today();
        markfiling.Date_of_1st_Use_Anywhere__c = System.today();
		insert markfiling;
        markfiling.Federal_Registration_of_Mark__c = 'Yes';
        markfiling.Number_of_Pages__c = 6;
        markfiling.Federal_Registration_Number_s__c='';
        update markfiling;
        
        brs_FilingStatusAuraHelper.checkMarkFilings(markfiling.id);
        test.stopTest();
        
    }
    
        testmethod static void writDefWrapperClass(){
        brs_FilingStatusAuraHelper.writDefWrapperClass wr =new brs_FilingStatusAuraHelper.writDefWrapperClass();
        wr.rejDefMap=Null;
        
        test.startTest();
        brs_FilingStatusAuraHelper.createWRITNotices('Test');
        test.stopTest();
    }
    testmethod static void coverCatchBlock(){        
        test.startTest();
        brs_FilingStatusAuraHelper.updateMarkObjectwithOwnerName(NULL);
        brs_FilingStatusAuraHelper.updateMarkObjectwithStateCountryofFormation(NULL);
        test.stopTest();
    }   
}