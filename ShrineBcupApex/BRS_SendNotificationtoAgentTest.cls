@isTest
public class BRS_SendNotificationtoAgentTest {
    
    @testSetup 
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Date_of_Formation__c=Date.newInstance(2021,01,01);
        acc.Date_Registration__c=Date.newInstance(2021,01,03);
        acc.Business_Type__c=System.Label.Stock;
        acc.Total_Authorized_Shares__c = 10;
        acc.ShippingStreet='Baker street';
        acc.ShippingCity='Mumbai';
        acc.ShippingState='WA';
        acc.ShippingPostalCode='12345';
        acc.ShippingCountry='India';
        acc.Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        acc.Purpose_of_Business__c='Business required';
        acc.BillingStreet='123';
        acc.BillingState='CT';
        acc.BillingCity='Test';
        acc.BillingCountry='United States';
        acc.BillingPostalCode='12345';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc.Id;
        insert con;
        
        Agent__c agent = new Agent__c();
        agent.Business_ID__c = acc.Id;
        agent.Agent_Account_ID__c=acc.Id;
        agent.Agent_Phone__c ='8699671466';
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
        agent.Business_Name__c = 'Business Name';
        insert agent;
        
          
        BRS_Encryption_Key_Setting__c EncryptSetting = new BRS_Encryption_Key_Setting__c();
        EncryptSetting.Crypto_Key__c = 'eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=';
        insert EncryptSetting;
        
         OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
        
        BRS_SendNotificationtoAgent.accObjWrapper accWra = new BRS_SendNotificationtoAgent.accObjWrapper();
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Reserved_Name__c = 'Test Filing';
        businessFiling.Account__c = acc.Id;businessFiling.Type__c = system.label.Annual_Report;
        businessFiling.Status__c = 'Approved';
        insert businessFiling;
        RecordType rc = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'Custom_Object'
        ];
        Loop__DDP__c docgen=new Loop__DDP__c(
            Name = 'Sample Business Filing Template',
            RecordTypeId = rc.Id,
            Filing__c = businessFiling.Type__c,
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
        
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Business_ID__c =acc.Id;
        tmpHistory.Business_Filing__c =businessFiling.Id;
        tmpHistory.Type__c=System.Label.Agent;
        tmpHistory.Change_Type__c=System.Label.Created;
        insert tmpHistory;
        
    }
    
    @isTest
    static void sendMessageTest(){
        
        Account acc = [Select Id, Citizenship__c From Account Where name ='Test Account' limit 1];
        
        Business_Filing__c businessfiling = [select Id,Type__c,Account__c , Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
       
        businessFiling.Agent_Confirmation_Hours_Left__c=24;
        update businessFiling;
        BRS_SendNotificationtoAgent.Requests req = new BRS_SendNotificationtoAgent.Requests();
        list<BRS_SendNotificationtoAgent.Requests> lstReq = new list<BRS_SendNotificationtoAgent.Requests>();
        req.accId = acc.id;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        
        test.startTest();
        BRS_SendNotificationtoAgent.callSendMessage('ssID','23455','8753','86764574','Morgan Stanley');
        BRS_SendNotificationtoAgent.sendMessage(lstReq);
        businessFiling.Self_Nomination_as_Agent__c=true;
        update businessFiling;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        BRS_SendNotificationtoAgent.sendMessage(lstReq);
       
        test.stopTest();
    }
    
     @isTest
    static void sendMessageTest2(){
         Account acc = [Select Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c From Account Where name ='Test Account' limit 1];
        
         Business_Filing__c businessfiling = [select Id,Type__c,Account__c , Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
        businessFiling.Self_Nomination_as_Agent__c=false;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Agent_Confirmation_Hours_Left__c=24;
        businessFiling.Type__c = System.label.Business_Formation_Label;
        update businessFiling;
        test.startTest();
        
      
        BRS_SendNotificationtoAgent.Requests req = new BRS_SendNotificationtoAgent.Requests();
        list<BRS_SendNotificationtoAgent.Requests> lstReq = new list<BRS_SendNotificationtoAgent.Requests>();
        req.accId = acc.id;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        
       BRS_SendNotificationtoAgent.sendMessage(lstReq);
       
        test.stopTest();
    }
    
     @isTest
    static void sendMessageTest3(){
        Account acc = [Select Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c From Account Where name ='Test Account' limit 1];
        acc.Name = 'BANK';
        acc.Date_of_Formation__c=Date.newInstance(2021,01,01);
        acc.Date_Registration__c=Date.newInstance(2021,01,03);
        acc.Business_Type__c=System.Label.LLC;
        update acc;
        
         Business_Filing__c businessfiling = [select Id,Type__c,Account__c , Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
        businessFiling.Self_Nomination_as_Agent__c=false;
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Type__c = System.label.Business_Formation_Label;
        update businessFiling;
        test.startTest();
        
      
        BRS_SendNotificationtoAgent.Requests req = new BRS_SendNotificationtoAgent.Requests();
        list<BRS_SendNotificationtoAgent.Requests> lstReq = new list<BRS_SendNotificationtoAgent.Requests>();
        req.accId = acc.id;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        
       BRS_SendNotificationtoAgent.sendMessage(lstReq);
       
        test.stopTest();
    }
    
     @isTest
    static void sendMessageTest4(){
        Account acc = [Select Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c From Account Where name ='Test Account' limit 1];
        acc.Name = 'BANK';
        acc.Date_of_Formation__c=Date.newInstance(2021,01,01);
        acc.Date_Registration__c=Date.newInstance(2021,01,03);
        acc.Business_Type__c=System.Label.LLC;
        update acc;
        
         Business_Filing__c businessfiling = [select Id,Type__c,Account__c , Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
        businessFiling.Self_Nomination_as_Agent__c=false;
       
        update businessFiling;
        test.startTest();
        
      
        BRS_SendNotificationtoAgent.Requests req = new BRS_SendNotificationtoAgent.Requests();
        list<BRS_SendNotificationtoAgent.Requests> lstReq = new list<BRS_SendNotificationtoAgent.Requests>();
        req.accId = acc.id;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        
       BRS_SendNotificationtoAgent.sendMessage(lstReq);
       
        test.stopTest();
    }
    
    @isTest
    static void sendMessageTest5(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Date_of_Formation__c=Date.newInstance(2021,01,01);
        acc.Date_Registration__c=Date.newInstance(2021,01,03);
        acc.Business_Type__c=System.Label.Stock;
        acc.Total_Authorized_Shares__c = 10;
        acc.ShippingStreet='Baker street';
        acc.ShippingCity='Mumbai';
        acc.ShippingState='WA';
        acc.ShippingPostalCode='12345';
        acc.ShippingCountry='India';
        acc.Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        acc.Purpose_of_Business__c='Business required';
        acc.BillingStreet='123';
        acc.BillingState='CT';
        acc.BillingCity='Test';
        acc.BillingCountry='United States';
        acc.BillingPostalCode='12345';
        insert acc;
        
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.AccountId = acc.Id;
        insert con;
        
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();    
      
        Business_Filing__c businessfiling = [select Id,Type__c,Account__c , Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
        
        BRS_SendNotificationtoAgent.accObjWrapper accWra = new BRS_SendNotificationtoAgent.accObjWrapper();
        businessFiling.RecordTypeId = mainRecTypeId;
        businessFiling.Account__c = acc.Id;
        businessFiling.Self_Nomination_as_Agent__c=true;
        businessFiling.Type__c = System.label.Business_Formation_Label;
        update businessFiling;
        test.startTest();
        
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory.Business_ID__c =acc.Id;
        tmpHistory.Business_Filing__c =businessFiling.Id;
        tmpHistory.Type__c=System.Label.Agent;
        tmpHistory.Change_Type__c=System.Label.Created;
        insert tmpHistory;
        
        BRS_SendNotificationtoAgent.Requests req = new BRS_SendNotificationtoAgent.Requests();
        list<BRS_SendNotificationtoAgent.Requests> lstReq = new list<BRS_SendNotificationtoAgent.Requests>();
        req.accId = acc.id;
        req.busFilObj = businessFiling;
        lstReq.add(req);
        BRS_SendNotificationtoAgent.sendMessage(lstReq);
       
        test.stopTest();
    }
    
    testMethod static void callSendMessage() {
            String accSID;
        	String phNo;
        	String agentId;
        	String filingId;
            String accName;
        	Test.startTest();
            BRS_SendNotificationtoAgent.callSendMessage(accSID, phNo, agentId, filingId, accName);
        	Test.stopTest();
    }
    
    testMethod static void sendEmail(){
        Account acc1=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Domestic',Business_Type__c ='LLP',State_or_Territory_Formation__c='Washington', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution, Description='abc product', Purpose_of_Business__c='Business Required'); 
            insert acc1;
        
        Agent__c agent = [select Business_ID__c, Name__c,Agent_Account_ID__c,Agent_Phone__c,Email__c,Business_City__c,
        Business_State__c,Business_Country__c,Business_Street_Address_1__c,Business_Zip_Code__c,Mailing_Street_Address_1__c,Mailing_City__c,
        Mailing_Country__c,Mailing_State__c,Mailing_Zip_Code__c,Business_Name__c from Agent__c where Name__c = 'Agent business Name' limit 1];
        
        
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.id;
        filing.Filing_Fee__c=30;
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        insert filing;
        Temp_History__c tempHist1 = BRS_TestDataFactory.createTempHistoryObject();
        
        Boolean sendReminder=true; 
        
        Test.startTest();
        BRS_SendNotificationtoAgent.sendEmail(agent,filing,tempHist1,sendReminder);
        Test.stopTest();
    }
    
    testMethod static void encrypt() {
        BRS_Encryption_Key_Setting__c EncryptSetting = [select id, Crypto_Key__c from BRS_Encryption_Key_Setting__c limit 1 ];
        string toEncrypt='AES256';
        Test.startTest();
        BRS_SendNotificationtoAgent.encrypt(toEncrypt);
        Test.stopTest();
    }
    
    testMethod static void getAgentDetails(){
        Account acc1=new Account(Name = 'TestClassAcctBypass & Co123',Citizenship__c = 'Domestic',Business_Type__c ='LLP',State_or_Territory_Formation__c='Washington', Began_Transacting_in_CT__c=System.today(),Date_of_Formation__c=System.today(),
                                 Business_Name_in_state_country__c='Business Name',Country_Formation__c='India',Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', 
                                 Mailing_Jurisdiction_BusinessCity__c='London', Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street', 
                                 Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',Mailing_Jurisdiction_Country__c='India',
                                 BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington', BillingPostalCode = '12345', 
                                 ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai', ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',
                                      sub_status__c = system.label.Active_Ready_for_Admin_Dissolution, Description='abc product', Purpose_of_Business__c='Business Required'); 
            insert acc1;
        
        
        Agent__c agent = [select Business_ID__c, Name__c,Agent_Account_ID__c,Agent_Phone__c,Email__c,Business_City__c,
        Business_State__c,Business_Country__c,Business_Street_Address_1__c,Business_Zip_Code__c,Mailing_Street_Address_1__c,Mailing_City__c,
        Mailing_Country__c,Mailing_State__c,Mailing_Zip_Code__c,Business_Name__c from Agent__c where Name__c = 'Agent business Name' limit 1];
        
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.id;
        filing.Filing_Fee__c=30;
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Agent_Selection__c='Accepted';
        insert filing;
        
        String enAgentId=BRS_SendNotificationtoAgent.encrypt(agent.Id);
        String enAgentSelection=BRS_SendNotificationtoAgent.encrypt('Accepted');
        String enFilingId = BRS_SendNotificationtoAgent.encrypt(filing.Id);
        
         BRS_Encryption_Key_Setting__c EncryptSetting = [select id, Crypto_Key__c from BRS_Encryption_Key_Setting__c limit 1 ];
        
        Test.startTest();
        BRS_SendNotificationtoAgent.getAgentDetails(enAgentId, enAgentSelection, enFilingId);
        Test.stopTest();
    }
    
   testMethod static void updateFiling(){
         Account acc = [Select Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c From Account Where name ='Test Account' limit 1];
         Business_Filing__c businessfiling = [select Id,Type__c,Account__c ,Name_Electronic_signature__c,Agent_Title__c, Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
         businessfiling.Name_Electronic_signature__c='Tony Stark';
         businessfiling.Agent_Title__c='Iron Man';
       businessfiling.Due_Date__c=System.today().addDays(2);
         update businessfiling;
         Agent__c agent = [Select id, Name__c from Agent__c where Name__c= 'Agent business Name' limit 1 ];
      
        String selection= System.label.I_Accept;
        String enFilingId = BRS_SendNotificationtoAgent.encrypt(businessfiling.Id);
        String electronicSignature=BRS_SendNotificationtoAgent.encrypt(businessfiling.Name_Electronic_signature__c);
        String title= BRS_SendNotificationtoAgent.encrypt(businessfiling.Agent_Title__c);
        
        String selectionD= System.label.I_Decline;
        Test.startTest();
        BRS_SendNotificationtoAgent.updateFiling(selection,enFilingId, electronicSignature, title);
        BRS_SendNotificationtoAgent.updateFiling(selectionD,enFilingId, electronicSignature, title);
        Test.stopTest();
    }
    
    testmethod static void autoRejectOnAgentDeclineTrigger() {
        Business_Filing__c businessfiling = [select Id,Type__c,Account__c ,Name_Electronic_signature__c,Agent_Title__c, Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c,Status__c,Filing_Type__c from Business_Filing__c where Reserved_Name__c = 'Test Filing'];
        AutoRejectOnAgentDecline__e agentDecline = new AutoRejectOnAgentDecline__e(FilingId__c = businessfiling.Id);
        test.startTest();
        Database.SaveResult sr = EventBus.publish(agentDecline);
        test.stopTest();
    }
    
    testmethod static void resendNotificationToAgent(){
        Account acc = [Select Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c From Account Where name ='Test Account' limit 1];
        Business_Filing__c businessfiling = [select Id,Type__c,Account__c ,Name_Electronic_signature__c,Agent_Title__c, Self_Nomination_as_Agent__c , Agent_Confirmation_Hours_Left__c from Business_Filing__c where Reserved_Name__c = 'Test Filing']; 
        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = acc.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        agent11.Mailing_Street_Address_1__c = 'mailing address';
        agent11.Mailing_City__c = 'CT';
        agent11.Mailing_Country__c = 'United States';
        agent11.Mailing_State__c = 'CT';
        agent11.Mailing_Zip_Code__c= '67493';
        insert agent11;
        
        
        test.startTest();
        BRS_SendNotificationtoAgent.resendNotificationToAgent(businessfiling.id);
        test.stopTest();
        
    }
}