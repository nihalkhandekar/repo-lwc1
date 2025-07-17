@isTest
private class CTBOT_SOTS_ResendAgentEmailTest {
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
    static void testResendAgentEmail() {
        Account acc = [SELECT Id, Citizenship__c, Date_of_Formation__c,Date_Registration__c, Business_Type__c FROM Account LIMIT 1];
        Business_Filing__c businessfiling = [SELECT Id FROM Business_Filing__c LIMIT 1]; 

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
        
        Test.startTest();
            CTBOT_SOTS_ResendAgentEmail.resendAgentEmail(new List<String>{businessfiling.Id});
        Test.stopTest();
    }
}