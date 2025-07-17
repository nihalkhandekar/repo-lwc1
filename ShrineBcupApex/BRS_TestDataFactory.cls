@isTest
public class BRS_TestDataFactory {
 public static User createCommunityUser(Contact con, Id profileId){
        User user = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8',firstname='firstname' , middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='testerbrs@noemail.com'
        );

        insert user;
        return user;
    }
    
    public static User createSpanishUser(Id profileId){
        User user = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='es', profileid = profileId, 
            country='United States',IsActive =true,
             timezonesidkey='America/Los_Angeles', 
            username='testerbrspanish@noemail.com'
        );

        insert user;
        return user;
    }
    
    public static User createUser(Id profileId){
        User user = new User(
            alias = 'test123', email='testAdmin@noemail.com',firstname='Test',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, 
            country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='testerAdmin12345@noemail.com' , Bypass_trigger__c = true,  UserPermissionsKnowledgeUser=true
        );
        
        insert user;
        return user;
    }
    
    public static UCC_Lien__c createUCCLien(string type){
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien.Type__c = type;
        uccLien.UCC_Lien_Number__c='12345';
        insert uccLien;
        return uccLien;
    }
    
    
     public static UCC_Filing__c createUCCFiling(string lienfilingtype, string status, string lienId, string type){
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling.Lien_Filing_Type__c = lienfilingtype;
        uccFiling.Amount__c = 50;
        uccFiling.Status__c = status;
        if(lienId!='')
        uccFiling.UCC_Lien_Id__c = lienId;
        if(type!='')
        uccFiling.Type__c = type;
        insert uccFiling;       
        return uccFiling;
    }
    
    public static OnOff_Filing_Auto_Refund__c onOffCustomSetting()
        {
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = true;
        insert onoffCustomSetting;
        return onoffCustomSetting;
        }
    public static ContentVersion contentVersionData()
    {
         ContentVersion objContVer = new ContentVersion();
        objContVer.VersionData = Blob.valueOf('string');
        objContVer.Title = 'title'; 
        objContVer.PathOnClient='title.txt';
        objContVer.File_Type_fileupload__c = 'Text';   
        insert objContVer;
        return objContVer;
    }
    public static ContentDocumentLink contentDocumentLinkData(String conDoc,string Filingid)
    {
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = Filingid;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        return cDe;

    }
    
    public static UCC_Filing__c createUCCFiling2(string lienfilingtype,String recordTypeId, String ucclientype,string workorderId, string status, string lienId, string type){
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling.recordtypeid=recordTypeId;
        uccFiling.Lien_Filing_Type__c = lienfilingtype;
        uccFiling.Amount__c = 50;
        uccFiling.Status__c = status;
        uccFiling.UCC_Lien_Type__c=ucclientype;
        uccFiling.Work_Order__c=workorderId;
        if(lienId!='')
            uccFiling.UCC_Lien_Id__c = lienId;
        if(type!='')
            uccFiling.Type__c = type;
        uccFiling.Filing_Source__c='Online';
        insert uccFiling;       
        return uccFiling;
    }
    
    
    public static UCC_Related_Info__c createUCCRelatedObject(string type, string filingid) {
        
     UCC_Related_Info__c objRelatedInfo4 = new UCC_Related_Info__c();  
     objRelatedInfo4.Deleted_Flag__c = False;
     objRelatedInfo4.City__c = 'City';   
     objRelatedInfo4.Country__c = 'country';
     objRelatedInfo4.isAuthorizer__c = true;      
     objRelatedInfo4.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
     //objRelatedInfo3.Individual_Organization_flg__c = 'OrgFlag';
     objRelatedInfo4.Org_Name__c = 'Orgname';
     objRelatedInfo4.Type__c = type;                           //System.Label.Review_MasterLabel_Type_Claimant;
	 objRelatedInfo4.State__c = 'State';
     objRelatedInfo4.Street__c = 'Street';
     objRelatedInfo4.Zip_Code__c = '11111';
     objRelatedInfo4.Suffix__c = 'Suffix';
     if(filingid!='')  
     objRelatedInfo4.Filing_Id__c = filingid;
         insert objRelatedInfo4;       
        return objRelatedInfo4;
    }
    public static Account createAccountCancelledObject(String BusinessType, String Status, String citizenship )
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c=citizenship !=''?citizenship:'Domestic';
        acc.Business_Type__c=BusinessType;
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.status__c = Status;
        acc.Mailing_International_Address__c = '2';
        acc.ShippingCountry = 'ALBANIA';
        acc.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acc.Date_of_Formation__c = Date.today().addDays(-2);
        acc.Business_Name_in_state_country__c = 'Test Account';
        acc.Description = 'TEST';
        acc.Country_Formation__c  = 'TEST';
        acc.State_or_Territory_Formation__c  = 'TEST';
        return acc;
    }
     public static Business_Filing__c createBusinessFilingObject1(String recordTypeId,String accountId,String workorderId,string type,string status)
    {
        Account ac = [Select id, citizenship__c, business_type__c  from account where id=:accountid];
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=recordTypeId;
        filing.Account__c=accountId;
        filing.Filing_Fee__c=30;
         filing.Amendment_Type__c ='Amend Name';
        if(workorderId!='')
            filing.Work_Order__c=workorderId;
        if (type=='')
            filing.Type__c = 'Business Registration';
        else
        filing.Type__c = type;
        filing.Citizenship__c = ac.citizenship__c;
        filing.business_type__c = ac.business_type__c;
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=status;
        filing.Filing_Date__c=System.today();
        return filing;
    }
    public static Work_Order__c createWorkOrderObject(String contactId, string source, string status)
    {
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = source;
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = status;
        workOrder.Total_Hold_Amount__c=3010;
        workOrder.Payments_Verified__c=true;
        if(contactId!='')
        workOrder.Customer__c = contactId;
        insert workOrder;
        return workOrder;
    }
    
    
    public static Account createAccountObject()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        insert acc;
        return acc;
    }
    
    
    public static Contact createContactObject(string accid)
    {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact123';
        con.Email = 'testConBrs@test.com';
        con.Allow_negative_balances__c = true;
        if(accid!='')
        con.AccountId = accid;
        insert con;
        return con;
    }
public static Customer_Balance_Transaction__c createCustomerBalanceTransactionObject(string contactid,string Type, Decimal Amount )
    {
        Customer_Balance_Transaction__c customerBal = new Customer_Balance_Transaction__c();
        customerBal.Type__c=Type;
        customerBal.Amount__c=Amount;
        customerBal.Payment_Source__c='Check';
        customerBal.Contact__c=contactid;
        insert customerBal;
        return customerBal;
    }
      public static bt_stripe__Transaction__c createStripeTransactionObject(String workorderId)
    {
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn.Work_Order__c = workorderId;
        txn.bt_stripe__Payment_Status__c = 'Authorized';
        txn.bt_stripe__Authorize_Only__c = true;
        insert txn;
        return txn;
    }
     public static Business_Filing__c createBusinessFilingObject(String recordTypeId,String accountId,String workorderId,string type,string status)
    {
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=recordTypeId;
        filing.Account__c=accountId;
        filing.Filing_Fee__c=30;
        filing.Amendment_Type__c ='Amend Name';
        if(workorderId!='')
            filing.Work_Order__c=workorderId;
        //filing.Type__c='Change of Email Address';
        if (type=='' || type == null)
            filing.Type__c = 'Business Registration';
        else
        filing.Type__c = type;
        filing.Citizenship__c = 'Domestic';
        filing.Effective_Date__c = System.Today();
        filing.Filing_Date__c = System.Today();
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c=status;
        insert filing;
        return filing;
    }

    public static Business_Filing__c createBusinessFilingRecord(String recordTypeId, String accountId, String workorderId, String sType, String status) {
        Account acc = new Account();
        Business_Filing__c filing = new Business_Filing__c();
        
        if (String.isNotBlank(accountId)) {
            acc = [SELECT Id, Citizenship__c, Business_Type__c FROM Account WHERE Id=:accountid];
          
            filing.recordtypeid=recordTypeId;
            filing.Account__c=accountId;
            filing.Filing_Fee__c=30;
            if(String.isNotBlank(workorderId)) {
                filing.Work_Order__c=workorderId;
            }
            if (String.isBlank(sType)) {
                filing.Type__c = 'Business Registration';
            }
            else {
                filing.Type__c = sType;
            }
            filing.Citizenship__c = acc.Citizenship__c;
            filing.Business_Type__c = acc.Business_Type__c;
            filing.Filing_Date__c = System.today().addDays(-30);
            filing.Due_Date__c = (System.today() + 5);
            filing.Status__c=status;
        }
        insert filing;
        return filing;
    }

    public static List<Account> listOfAccount()
        
        {
            List<Account> accounts = new List<Account>();
            for(Integer i=0;i<3;i++)
            {
            Account acct = new Account();
           acct.name='Test'+i;
           acct.Franchise_Tax__c=200;
           acct.ClientAccountNum__c='12345';
           accounts.add(acct);
            }
           insert accounts;
            return accounts;
        }
 public static List<Create_Account__e> createPlatformEvent()
 {
     List<Create_Account__e> publishEvents = new List<Create_Account__e>();
        for(Integer i=0;i<3;i++)
       {
         Create_Account__e eve = new Create_Account__e();
           eve.Account_Name__c='Test'+i;
           publishEvents.add(eve);
       }
       if(publishEvents.size()>0){
            EventBus.publish(publishEvents);
        }
        return publishEvents;
    }
    public static Principal__c createPrincipal()
    {
        Principal__c princ= new Principal__c();
        princ.Principal_Title__c = 'PRESIDENT';
        princ.Principal_Type__c = 'Individual';
        princ.FirstName__c = 'test first name';
        princ.LastName__c = 'test last name';
        princ.Residence_InternationalAddress__c = 'test residence address';
        princ.Residence_Country__c = 'United States';
        insert princ;
        return princ;
    }
    
    public static Principal__c createPrincipalRecords(String accId)
    {
        Principal__c princ= new Principal__c();
        princ.Principal_Type__c = 'Individual';
        princ.Business_ID__c=accId;
        princ.Principal_Title__c = 'PRESIDENT';
        princ.Principal_Type__c = 'Individual';
        princ.FirstName__c = 'test first name';
        princ.LastName__c = 'test last name';
        princ.Business_InternationalAddress__c = 'test residence address';
        princ.Residence_InternationalAddress__c='res';
        princ.Residence_Street_Address_1__c='add';
        princ.Business_Street_Address_1__c='addbus';
        princ.Business_Country__c = 'Afghanistan';
        return princ;
    }
    
     public static Temp_History__c createTempHistoryObject()
    {
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Certificate_Types__c = 'Express';
        insert tmpHistory;
        return tmpHistory;
    }
    
    public static Temp_History__c createTempHistoryObject2(string filingid,String principalId,string accid,String type,String changeType)
    {
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Type__c=type;
        tmpHistory.Business_Filing__c=filingid;
        tmpHistory.Principal__c=principalId;
        tmpHistory.Change_Type__c=changeType;
        tmpHistory.Business_City__c='US';
        tmpHistory.Business_Street_Address_1__c='123Wash';
        tmpHistory.Business_Street_Address_2__c='Mann';
        tmpHistory.Business_Zip_Code__c='12345';
        tmpHistory.Business_State__c='CA';
        tmpHistory.Business_Country__c='India';
        tmpHistory.Business_InternationalAddress__c='';
        tmpHistory.Title__c='Test';
        tmpHistory.FirstName__c='sam';
        tmpHistory.LastName__c='man';
        tmpHistory.Name__c='sample';
       	tmpHistory.Business_Email_Address__c='sam@deloitte.com';
		tmpHistory.Type_of_Update__c='Business Address';
        tmpHistory.Office_Jurisdiction_BusinessStreet__c='jurdiction';
        tmpHistory.Office_Jurisdiction_BusinessStreet_New__c='New Juris';
        tmpHistory.Mailing_Jurisdiction_BusinessStreet__c='Mailing';
        tmpHistory.Office_Jurisdiction_BusinessStreet__c='value';
        tmpHistory.Mailing_Jurisdiction_BusinessStreet__c='new';
        tmpHistory.ShippingStreet__c='Street';
        tmpHistory.ShippingStreet_New__c='different street';
        tmpHistory.BillingStreet__c='StreetData';
        tmpHistory.Email__c='sbabarabbani@deloitte.com';
        tmpHistory.Residence_City__c='US';
        tmpHistory.Residence_Street_Address_1__c='man';
        tmpHistory.Residence_Street_Address_2__c='van';
        tmpHistory.Residence_Zip_Code__c='12345';
        tmpHistory.Residence_State__c='CA';
        tmpHistory.Residence_Country__c='India';
        tmpHistory.Residence_InternationalAddress__c='';
        tmpHistory.Account__c=accid;
        tmpHistory.Business_ID__c=accid;
        //tmpHistory.Designation__c='L.L.C';
        //tmpHistory.Temp_Type__c='type';
        tmpHistory.Billing_City_New__c='maailing inter';
		tmpHistory.BillingPostalCode_New__c='12345';
		tmpHistory.BillingStreet_New__c='justreet';
		tmpHistory.BillingState_New__c='jurstate';
		tmpHistory.Office_Jurisdiction_BusinessCity_New__c='jurcity';
		tmpHistory.Billing_Country_New__c='jurcountry';
		tmpHistory.Business_Unit_New__c='3212';
		tmpHistory.Principle_Office_International_Address_N__c='jurinteraddress';
		tmpHistory.ShippingPostalCode_New__c='12345';
		tmpHistory.Mailing_Jurisdiction_BusinessStreet_New__c='mailstreet';
		tmpHistory.ShippingState_New__c='mailstate';
		tmpHistory.ShippingCity_New__c='mailcity';
		tmpHistory.Mailing_International_Address_New__c='mailinter';
		tmpHistory.Mailing_Unit_New__c='3212';
		tmpHistory.Shipping_Country_New__c='dam';
         tmpHistory.Veteran_Owned_Organization_New__c=true;
         tmpHistory.Woman_Owned_Organization_New__c=true;
         tmpHistory.Prefer_not_to_answer_New__c=true;
         tmpHistory.Organization_is_LGBTQI_Owned_New__c=true;
         tmpHistory.Org_Owned_by_Person_with_disabilitiesNew__c=true;
         tmpHistory.Opt_Out_of_Category_Survey_New__c=true;
         tmpHistory.None_of_the_listed_Organizations_New__c=true;
         tmpHistory.Minority_Owned_Organization_New__c=true;
       	 tmpHistory.Category_Survey_Email_Address_New__c='s@email.com';
       insert tmpHistory;
        return tmpHistory;
    }
    
    public static Temp_History__c createTempHistoryForPrincipal(String filingid, String accid, String principalId, String changeType, String designation, String title) {
        Temp_History__c tmpHistory = new Temp_History__c();
        if(changeType != 'Deleted') {
            tmpHistory.Type__c='Principal';
            tmpHistory.Business_Filing__c=filingid;
            tmpHistory.Principal__c=principalId;
            tmpHistory.Change_Type__c=changeType;
            tmpHistory.Business_City__c='US';
            tmpHistory.Business_Street_Address_1__c='123Wash';
            tmpHistory.Business_Street_Address_2__c='Mann';
            tmpHistory.Business_Zip_Code__c='12345';
            tmpHistory.Business_State__c='CA';
            tmpHistory.Business_Country__c='India';
            tmpHistory.Business_InternationalAddress__c='';
            tmpHistory.Title__c=title;
            tmpHistory.FirstName__c='sam';
            tmpHistory.LastName__c='man';
            tmpHistory.Name__c='sam man';
            tmpHistory.Email__c='sbabarabbani@deloitte.com';
            tmpHistory.Residence_City__c='US';
            tmpHistory.Residence_Street_Address_1__c='man';
            tmpHistory.Residence_Street_Address_2__c='van';
            tmpHistory.Residence_Zip_Code__c='12345';
            tmpHistory.Residence_State__c='CA';
            tmpHistory.Residence_Country__c='India';
            tmpHistory.Residence_InternationalAddress__c='';
            tmpHistory.Account__c=accid;
            tmpHistory.Business_ID__c=accid;
            tmpHistory.Designation__c=designation;
            tmpHistory.Temp_Type__c='Individual';
            tmpHistory.Billing_City_New__c='maailing inter';
            tmpHistory.BillingPostalCode_New__c='12345';
            tmpHistory.BillingStreet_New__c='justreet';
            tmpHistory.BillingState_New__c='jurstate';
            tmpHistory.Office_Jurisdiction_BusinessCity_New__c='jurcity';
            tmpHistory.Billing_Country_New__c='jurcountry';
            tmpHistory.Business_Unit_New__c='3212';
            tmpHistory.Principle_Office_International_Address_N__c='jurinteraddress';
            tmpHistory.ShippingPostalCode_New__c='12345';
            tmpHistory.Mailing_Jurisdiction_BusinessStreet_New__c='mailstreet';
            tmpHistory.ShippingState_New__c='mailstate';
            tmpHistory.ShippingCity_New__c='mailcity';
            tmpHistory.Mailing_International_Address_New__c='mailinter';
            tmpHistory.Mailing_Unit_New__c='3212';
            tmpHistory.Shipping_Country_New__c='dam';
            tmpHistory.Veteran_Owned_Organization_New__c=true;
            tmpHistory.Woman_Owned_Organization_New__c=true;
            tmpHistory.Prefer_not_to_answer_New__c=true;
            tmpHistory.Organization_is_LGBTQI_Owned_New__c=true;
            tmpHistory.Org_Owned_by_Person_with_disabilitiesNew__c=true;
            tmpHistory.Opt_Out_of_Category_Survey_New__c=true;
            tmpHistory.None_of_the_listed_Organizations_New__c=true;
            tmpHistory.Minority_Owned_Organization_New__c=true;
            tmpHistory.Category_Survey_Email_Address_New__c='s@email.com';
            tmpHistory.Change_Type__c = changeType;
            tmpHistory.Residence_InternationalAddress__c = 'abc street, Kabul';
            tmpHistory.Residence_Country__c = 'Afghanistan';
            tmpHistory.Business_InternationalAddress__c = 'abc street, Kabul';
            tmpHistory.Business_Country__c = 'Afghanistan';
        }
        if(changeType == 'Deleted' || changeType == 'Edited') {
            tmpHistory.Account__c=accid;
            tmpHistory.Business_ID__c=accid;
            tmpHistory.Business_Filing__c = filingId;
            tmpHistory.Name_Old__c = 'Test Test';
            tmpHistory.FirstName_Old__c = 'Test';
            tmpHistory.LastName_Old__c = 'Test';
            tmpHistory.Temp_Type__c = 'Individual';
            tmpHistory.Principal_Title__c = title;
            tmpHistory.Designation_Old__c = designation;
            tmpHistory.Email_Old__c = 'test@mailinator.com';
            tmpHistory.Residence_Street_Address1_Old__c = '221B Baker Str';
            tmpHistory.Residence_Street_Address_2_Old__c = 'Near McD';
            tmpHistory.Residence_City_Old__c = 'Birmingham';
            tmpHistory.Residence_Country_Old__c = 'United States';
            tmpHistory.Residence_State_Old__c = 'CA';
            tmpHistory.Residence_Zip_Code_Old__c = '93548';
            tmpHistory.Residence_InternationalAddress_Old__c = '221B Baker Str, London';
            tmpHistory.Business_InternationalAddress_Old__c = '221B Baker Str, London';
            tmpHistory.Business_City_Old__c = 'Birmingham';
            tmpHistory.Business_Country_Old__c = 'United States';
            tmpHistory.Business_State_Old__c = 'CA';
            tmpHistory.Business_Street_Address_1_Old__c = '221B Baker Str';
            tmpHistory.Business_Street_Address_2_Old__c = 'Near McD';
            tmpHistory.Business_Zip_Code_Old__c = '93478';
            tmpHistory.Change_Type__c = changeType;
            tmpHistory.Type__c = 'Principal';
        }
        return tmpHistory;
    }
    
    public static List<UCC_Related_Info__c> createListUCCRelatedInfoObject(){
    
        List<UCC_Related_Info__c> relatedInfo=new List<UCC_Related_Info__c>();
        for(Integer i=0;i<3;i++)
        {
            UCC_Related_Info__c uccRelated= new UCC_Related_Info__c();
            //uccRelated.Org_Name__c = 'CTDS-BRS';
            uccRelated.Individual_SurName__c = 'Mr';
			uccRelated.International_Address__c = 'Test';
            uccRelated.Country__c ='relatedInfo'+i;
            if(i==0)
            {
                uccRelated.Type__c='Debtor';
            }
            if(i==1)
            {
                uccRelated.Type__c='Secured Party';
            }
             if(i==2)
            {
                uccRelated.Type__c='Assignor';
            }
            relatedInfo.add(uccRelated);
        }
        insert relatedInfo;
        return relatedInfo;
    }
    public static Contact createContactObject2(string accid)
    {
        Contact con = new Contact();
        con.FirstName = 'Test1';
        con.LastName = 'Contact1234';
        con.Email = 'testConBrs2@test.com';
        con.Allow_negative_balances__c = true;
        //con.Total_Voucher_Balance__c = 2000.00;
        //Voucher_Credit__c - Voucher_Debit__c
        if(accid!='')
        con.AccountId = accid;
        insert con;
        return con;
    }
     public static List<UCC_Related_Info__c> createListUCCRelatedInfoObjectOrg(){
        List<UCC_Related_Info__c> listUCCCons = new List<UCC_Related_Info__c>();
        UCC_Related_Info__c uccRelated= new UCC_Related_Info__c();
        Id orgRecTypeID = [select Id,Name from RecordType where sObjectType='UCC_Related_Info__c' and name = 'Organization'].Id;
        uccRelated.RecordTypeId = orgRecTypeID;
        uccRelated.Org_Name__c = 'Org, LLC';
		uccRelated.International_Address__c = 'Test';
        uccRelated.Country__c ='USA';
        listUCCCons.add(uccRelated);
        insert listUCCCons;
        return listUCCCons;
    }
    public static Payment_Method__c createVoucherPaymentMethod(String workorderId,String VoucherCode){
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod.Amount__c=100;
        payMethod.Check__c='Test';
        payMethod.Payment_Source__c='Voucher';
        payMethod.Voucher_Code__c=VoucherCode;
        payMethod.Work_Order__c=workorderId;
        return payMethod;
    }
        public static Payment_Method__c genericPaymentMethod(String workorderId){
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod.Amount__c=1000;
        payMethod.Check__c='Test';
        payMethod.Payment_Source__c='Check';
        payMethod.Work_Order__c=workorderId;
         insert payMethod;
        return payMethod;
    }
    public static Voucher_Code_Master__c createVoucherCode(String Code){
        Voucher_Code_Master__c voucherCode=new Voucher_Code_Master__c();
        voucherCode.Amount__c=100;
        voucherCode.Voucher_Code__c=Code;
        voucherCode.Status__c='Pending';
		voucherCode.Start_Date__c=System.today();
        voucherCode.End_Date__c=System.today()+3;
        return voucherCode;
    }    
    
    public static Certficate__c createCertificate(String accId, string WorkOrderId){
       Certficate__c cert = new Certficate__c();
        cert.Business__c = accId;
        cert.Work_Order__c = WorkOrderId;
        insert cert;
        return cert;
    } 
    
    
    /*public static SDOC__SDoc__c createSDoc(){
        SDOC__SDoc__c sdoc = new SDOC__SDoc__c();
        sdoc.SDOC__Allow_Edit__c = false;
        sdoc.SDOC__Attachment_Name__c = 'UCC 1 Original Filing Statement v2.0_SD-000.pdf';
        insert sdoc;
        return sdoc;
    } 
      public static List<SDOC__SDoc__c> ListcreateSDoc(String templateid){
        List<SDOC__SDoc__c> sdocList =new List<SDOC__SDoc__c>();
          for(integer i=0;i<3;i++)
          {
             SDOC__SDoc__c sdoc = new SDOC__SDoc__c();
             sdoc.SDOC__SDTemplate__c=templateid;
            sdoc.SDOC__Allow_Edit__c = false;
        	sdoc.SDOC__Attachment_Name__c = 'UCC 1 Original Filing Statement v2.0_SD-000.pdf';
            sdocList.add(sdoc);
          }
       
        insert sdocList;
        return sdocList;
    } 
        public static SDoc__SDTemplate__c createSDocTemplate(){
        SDoc__SDTemplate__c sdocTemplate = new SDoc__SDTemplate__c();
            sdocTemplate.Name='test';
                sdocTemplate.SDOC__Template_Format__c='PDF';
            sdocTemplate.isActive__c=true;
            sdocTemplate.SDOC__Base_Object__c='Business_Filing__c';
            sdocTemplate.Filing__c='Change of Email Address';
            insert sdocTemplate;
            return sdocTemplate;

    }*/
    
    public static Subscription__c createSubscription(){
        Subscription__c subs = new Subscription__c();
        subs.Business_Industry__c = 'Construction';
        subs.Business_Sector__c = 'Amusement Parks';
        subs.Email__c = 'testClass@gmail.com';
        subs.Language__c = 'en_US';
        //subs.Subscription_Type__c 
       insert subs;
        return subs;
    } 
    public static Business_Reopen_Certification__c createBusinessReopenCertification(){
        Business_Reopen_Certification__c busrecert = new Business_Reopen_Certification__c();
        busrecert.Business_Type__c = 'Construction';
        busrecert.Sector__c = 'Amusement Parks';
        busrecert.Email_Address__c = 'testClass@gmail.com';
        busrecert.Date__c = system.today();
        busrecert.Representative_last_Name__c = 'User';
        insert busrecert;
        return busrecert;
    } 
    
    
        public static EmailTemplate createEmailTemplate(){
        EmailTemplate etemp = new EmailTemplate();
        etemp.Subject = 'test subject';  
        etemp.HtmlValue = 'test html';
        etemp.Body = 'test body'; 
        etemp.Name = 'test name';
            etemp.FolderId = UserInfo.getUserId();
            etemp.TemplateType = 'text';
        etemp.developername = 'Notification_Sign_up_Verification_Email';
        insert etemp;
        return etemp;
    } 

    public static EmailTemplate createEmailTemplateSpanish(){
        EmailTemplate etemp = new EmailTemplate();
        etemp.Subject = 'test subject';  
        etemp.HtmlValue = 'test html';
        etemp.Body = 'test body'; 
        etemp.Name = 'test name';
        etemp.FolderId = UserInfo.getUserId();
        etemp.TemplateType = 'text';
        etemp.developername = 'Notification_Sign_up_Verification_Email_Spanish';
        insert etemp;
        return etemp;
    }
    
        public static List<Business_Filing__c> createBusinessFilingList(String recordTypeId,String accountId,Datetime conformationdate,Decimal lefthours)
    {
         List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=recordTypeId;
        filing.Account__c=accountId;
        filing.status__c='Submitted - Agent acceptance pending';
        filing.Agent_Confirmation_Notification__c=conformationdate;
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
            if(i==1)
            {
                filing.Type__c='Dissolution';  
            }
            if(i==2)
            {
                filing.Type__c='Withdrawal'; 
            }
         filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=lefthours;
            filing.Business_Type__c='LLP';
            filingList.add(filing);
        }
        insert filingList;
        return filingList;
    } 
        public static Agent__c createAgent(String accId){
       Agent__c agent = new Agent__c();
        agent.Business_ID__c = accId;
        agent.Agent_Account_ID__c=accId;
        agent.Agent_Phone__c ='8699671466';
        agent.Type__c='Business';
        agent.Name__c = 'Agent business Name';
        agent.Email__c='sbabarabbani@deloitte.com';
        agent.Business_City__c = 'CT';
        agent.Business_State__c = 'CT';
        agent.Business_Country__c = 'United States';
        agent.Business_Street_Address_1__c = 'street address1';
        agent.Business_Zip_Code__c= '45367';
        agent.Mailing_Street_Address_1__c = 'mailing address';
        agent.Mailing_City__c = 'CT';
        agent.Mailing_Country__c = 'United States';
        agent.Mailing_State__c = 'CT';
        agent.Mailing_Zip_Code__c= '67493';
        insert agent;
        return agent;
    } 
    public static Payment_Method__c cardPaymentMethod(String workorderId){
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod.Amount__c=5000;
        payMethod.Payment_Source__c='Card';
        payMethod.Work_Order__c=workorderId;
        insert payMethod;
        return payMethod;
    }
    public static Certficate__c createCertificate(String recordtypeId,String accId, string WorkOrderId){
        Certficate__c cert = new Certficate__c();
        cert.RecordTypeId=recordtypeId;
        cert.Type__c='Certificate of Legal Existence';
        cert.Certificate_Type__c='Standard';
        cert.Business__c = accId;
        cert.Work_Order__c = WorkOrderId;
        insert cert;
        return cert;
    }

    public static Business_Filing__c createBusFile(String strCitizenship,String status, String accId, String busFileType,String busBusinessType, ID recTypeId){
        Business_Filing__c bfc = new Business_Filing__c(Citizenship__c = strCitizenship , Status__c = status, Account__c = accId, Type__c= busFileType, Business_Type__c= busBusinessType, recordTypeId = recTypeId);
        return bfc;
    }
    public static Account createAcc(String strCitizenship,String busBusinessType){
        Account acc = new Account(Name = 'Test Account',Citizenship__c = strCitizenship,Purpose_of_Business__c ='Test' , Business_Type__c = busBusinessType ,Franchise_Tax__c=200, Mailing_International_Address__c = 'Mailing address', Began_Transacting_in_CT__c = system.today() , Date_of_Formation__c = system.today(), Business_Name_in_state_country__c = 'test business name', Country_Formation__c = 'USA',Status__c ='Active');
        return acc;
    }
    
    public static Account createAccothertypes(String name,String strCitizenship,String busBusinessType){
        Account acc = new Account(Name = name,Total_Authorized_Shares__c=100,Citizenship__c = strCitizenship,Purpose_of_Business__c ='Test' , Business_Type__c = busBusinessType ,Franchise_Tax__c=200, Mailing_International_Address__c = 'Mailing address', Began_Transacting_in_CT__c = system.today() , Date_of_Formation__c = system.today(), Business_Name_in_state_country__c = 'test business name', Country_Formation__c = 'USA',Status__c ='Active');
        insert acc;
        return acc;
    }
     Public static Mark_Filing__c createMarkFiling(String Markid)
    {
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.Filing_Type__c='Registration';
        markfiling.Ist_Expiration_Date__c=System.today();
        markfiling.Class_of_Goods_Service__c='Paints';
        markfiling.Date_of_1st_Use_Anywhere__c=System.today();
        markfiling.Date_of_1st_Use_in_CT__c=System.today();
        markfiling.Disclaimer__c='Disclamied Data';
        markfiling.Expiration_Date__c=system.today();
        markfiling.Federal_Registration_Number_s__c='Date number';
        markfiling.Federal_Registration_of_Mark__c='Yes';
        markfiling.Keywords__c='keywords';
  		markfiling.Mark_Type__c='Certification Mark';
		markfiling.Mark_used_for__c='AlMark';
		markfiling.Method_of_use__c='Method used';
		markfiling.Number_of_Pages__c=23;
		markfiling.Other_Owner_Type__c='Owner Type';
		markfiling.Owner_City__c='Washington';
		markfiling.Owner_Country__c='United States';
		markfiling.Owner_Name__c='Jhon';
		markfiling.Owner_State__c='AK';
		markfiling.Owner_Street_Address__c='123 street';
		markfiling.Owner_Type__c='Corporation';
		markfiling.Owner_Unit__c='as123';
		markfiling.Owner_Zip_Code__c='12345';
		markfiling.Partner_Names__c='alex';
		markfiling.Registration_Date__c=System.today();
		markfiling.Renewal_Date__c=System.today();

		markfiling.State_Country_of_Formation__c='AK';
		markfiling.Status__c='Approved';
		markfiling.Mark__c=Markid;
		insert markfiling;
        return markfiling;
    }
    Public static Mark_Filing__c createMarkFiling1(String markid,String recordtypeid,String filingType)
    {
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.RecordTypeId=recordtypeid;
        markfiling.Filing_Type__c=filingType;
        markfiling.Mark_Type__c='Service Mark';
        markfiling.Owner_City__c='Washington';
		markfiling.Owner_Country__c='United States';
		markfiling.Owner_Name__c='Jhon';
		markfiling.Owner_State__c='AK';
		markfiling.Owner_Street_Address__c='123 street';
		markfiling.Owner_Type__c='Individual';
		markfiling.Owner_Unit__c='as123';
		markfiling.Owner_Zip_Code__c='12345';
        markfiling.Mark__c=markid;
		insert markfiling;
        return markfiling;
    }
     Public static Mark__c createMark()
    {
        Mark__c mark=new Mark__c();
        mark.Class_of_Goods_Service__c = 'Chemicals';
        mark.Date_of_1st_Use_Anywhere__c = Date.today();
        mark.Date_of_1st_Use_in_CT__c = Date.today();
        mark.Description_of_Mark__c = 'TEST';
        mark.Disclaimer__c = 'DISCLAIMER TEXT';
        mark.Expiration_Date__c = Date.today();
        mark.Federal_Registration_Number_s__c = '1231231231';
        mark.Federal_Registration_of_Mark__c = 'Yes';
        mark.Keywords__c = 'RETURN - AVINASH';
        mark.Mark_Type__c = 'Collective Mark';
        mark.Mark_used_for__c = 'MARK TEST NEW';
        mark.Method_of_use__c = 'NEW METHOD';
        mark.Number_of_Pages__c = 321;
        mark.Other_Owner_Type__c = '0';
        mark.Owner_City__c = 'Sample City';
        mark.Owner_Country__c = 'Austria';
        mark.Owner_Name__c = '1924 - INDIVIDUAL';
        mark.Owner_State__c = 'AZ';
        mark.Owner_Street_Address__c = 'Sample Street';
        mark.Owner_Type__c = 'Individual';
        mark.Owner_Unit__c = '124V';
        mark.Owner_Zip_Code__c = '12345-7865';
        mark.Partner_Names__c = 'TEST Partner Main';
        mark.Registration_Date__c = Date.today();
        //mark.Registration_number__c = '9999999999- TEST';
        mark.Renewal_Date__c = Date.today();
        mark.State_Country_of_Formation__c = 'HI';
        mark.Status__c = 'Expired';
        mark.X1st_Expiration_Date__c = Date.today();

		insert mark;
        return mark;
    }
     Public static Mark__c createMark1()
    {
        Mark__c mark=new Mark__c();
        mark.Owner_City__c='Washington1';
        mark.Owner_Country__c='United States';
        mark.Owner_State__c='AK';
        mark.Owner_Street_Address__c='1234 street';
        mark.Owner_Unit__c='as124';
        mark.Owner_Zip_Code__c='12344';
		insert mark;
        return mark;
    }
     Public static List<Mark_Filing__c> createListMarkFiling(String Markid,String workorderId)
    {
       List<Mark_Filing__c> listMarkfiling=new List<Mark_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.Work_Order__c=workorderId;
        markfiling.Class_of_Goods_Service__c='Paints';
        markfiling.Date_of_1st_Use_Anywhere__c=System.today();
        markfiling.Date_of_1st_Use_in_CT__c=System.today();
        markfiling.Disclaimer__c='Disclamied Data';
        markfiling.Expiration_Date__c=system.today();
        markfiling.Federal_Registration_Number_s__c='Date number';
        markfiling.Federal_Registration_of_Mark__c='Yes';
        markfiling.Keywords__c='keywords';
  		markfiling.Mark_Type__c='Certification Mark';
		markfiling.Mark_used_for__c='AlMark';
		markfiling.Method_of_use__c='Method used';
		markfiling.Number_of_Pages__c=23;
		markfiling.Other_Owner_Type__c='Owner Type';
		markfiling.Owner_City__c='Washington';
		markfiling.Owner_Country__c='United States';
		markfiling.Owner_Name__c='Jhon';
		markfiling.Owner_State__c='AK';
		markfiling.Owner_Street_Address__c='123 street';
		markfiling.Owner_Type__c='Corporation';
		markfiling.Owner_Unit__c='as123';
		markfiling.Owner_Zip_Code__c='12345';
		markfiling.Partner_Names__c='alex';
		markfiling.Registration_Date__c=System.today();
		markfiling.Renewal_Date__c=System.today();

		markfiling.State_Country_of_Formation__c='AK';
		markfiling.Status__c='Approved';
		markfiling.Mark__c=Markid;
        listMarkfiling.add(markfiling);
        }
    
		insert listMarkfiling;
        return listMarkfiling;
    }
         Public static Master_Fee__c createListMasterFee()
    {
        Master_Fee__c masterfee=new Master_Fee__c();
        
       	masterfee.Amount__c=100;
        masterfee.Start_Date__c=system.today();
        masterfee.End_Date__c=system.today();
        masterfee.Mark_Type__c='Certification Mark';
        masterfee.Mark_Filing_Type__c='Registration';
        masterfee.Status__c='Active';
        masterfee.External_ID__c='1234567891911111';
        insert masterfee;
        return masterfee;
    }
    public static Mass_Agent_Change__c createMassAgentChange(String contactId,String workorderId)
    {
     Mass_Agent_Change__c massAgent=new Mass_Agent_Change__c();
        massAgent.Customer__c=contactId;
        massAgent.Work_Order__c=workorderId;
        massAgent.Filing_Date__c = system.today();
        massAgent.Effective_Date_Time__c = (System.now()).addDays(2);
        insert massAgent;
        return massAgent;
    }
      public static Agent_Change__c createAgentChange(String agentId,String massagentId,Id accId)
    {
     Agent_Change__c massAgent=new Agent_Change__c();
        massAgent.Agent__c=agentId;
        massAgent.Mass_Agent_Change__c=massagentId;
        massAgent.Account__c = accId;
        insert massAgent;
        return massAgent;
    }
    public static Foreign_Investigation__c setForeignInvestigationRecords(String letterType, String status, Date RegistrationDate) {
        Foreign_Investigation__c fi = new Foreign_Investigation__c();
        fi.Case_Status__c = status;
        fi.Case_Initiated_By__c = 'Complaint';
        fi.Latest_Letter_Type__c = letterType;
        fi.Payment_Plan_Established__c = true;
        fi.Business_Type__c = 'Stock';
        fi.Date_Began_Transacting_Business_in_CT__c = System.today().addDays(-120);
        fi.Registration_Date__c = RegistrationDate;
        fi.Business_Name__c = 'Test Business';
        fi.Business_Street_Address_1__c = '221B Baker\'s Street';
        fi.Business_City__c = 'Stamford';
        fi.Business_State__c = 'Connecticut';
        fi.Business_Zip_Code__c = '85487';
        fi.Business_Country__c = 'United States';
        return fi;
    }

     public static Foreign_Investigation_Mail_Tracking__c setForeignInvestigationMailTrackingRecords(String letterType, String FI_Id) {
        Foreign_Investigation_Mail_Tracking__c fiMail = new Foreign_Investigation_Mail_Tracking__c();
        fiMail.Foreign_Investigation__c = FI_Id;
        fiMail.Type__c = letterType;
        fiMail.Attorney_Name_Dropdown__c = 'William Silk';
        fiMail.Date_Mailed__c = System.today();
        fiMail.Certified_Mail_ID__c = 'M1234';
        return fiMail;
    }

    public static List<SObject> insertSObject(List<SObject> lstSObj) {
        if(!lstSObj.isEmpty()) {
            insert lstSObj;
        }
        return lstSObj;
    }
     public static WRIT_Case__c createWritCase()
    {
        WRIT_Case__c wcase=new WRIT_Case__c();
        wcase.Type__c='WRIT Case';
        wcase.Status__c='Complete';
        wcase.Number_of_Defendants__c=2;
        wcase.Title_Plaintiff__c='case';
        wcase.Title_Defendant__c='des';
        insert wcase;
        return wcase;
    }
    public static Defendants__c createDefendant(String recordTypeId,String writcaseId)
    {
        Defendants__c defendant=new Defendants__c();
        defendant.WRIT_Case__c=writcaseId;
        defendant.RecordTypeId=recordTypeId;
        defendant.Defendant_Name__c='def';
        defendant.Type_of_Defendant__c='Individuals';
        defendant.Section_Number__c='52-57';
        defendant.Mailing_Status__c='No Mailing';
        insert defendant;
        return defendant;
        
    }

    public static Business_History__c createBusHistory(String busFileID,String oldAccId, String accId){
        Business_History__c bfc = new Business_History__c(Business_Filing__c = busFileID, Merging_Business__c= oldAccId, Surviving_Business__c = accId);
        return bfc;
    }
    
}