@isTest
public with sharing class AdminDissolutionUpdatesTest {
    public AdminDissolutionUpdatesTest() {
        
    }

    public static testmethod void testAdminUpdates(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Id RecordTypeIdNewBusiness = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
        
        List<Account> Acclist = new List<Account>();
        
        Account testAcc1 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                       Status__c = 'Reserved',Sub_status__c = 'Ready for Dissolution', Reserved_Name_Used__c = false); 
        
        
        Account testAcc2 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                      Status__c = 'Reserved', Sub_status__c = 'Ready for Dissolution' , Reserved_Name_Used__c = false); 
        Account testAcc4 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
      Status__c = 'Reserved',  Sub_status__c = 'Ready for Dissolution' , Reserved_Name_Used__c = false);  
        
       Account testAcc5 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                   Status__c = 'Reserved',    Sub_status__c = 'Ready for Dissolution' , Reserved_Name_Used__c = false);                  
        
        Account testAcc6 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                     Status__c = 'Reserved',   Sub_status__c = 'Ready for Dissolution' , Reserved_Name_Used__c = false);
        
       Account testAcc7 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                    Status__c = 'Reserved',    Sub_status__c ='Ready for Dissolution' , Reserved_Name_Used__c = false);     
            Account testAcc9 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                     Status__c = 'Reserved',   Sub_status__c ='Ready for Dissolution' ,ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                        ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345', Reserved_Name_Used__c = false);
        
        Account testAcc10 = new Account(Name = 'The TestClassAcct9 & Co', RecordTypeId = RecordTypeIdBusiness , Account_Name_Without_Designators__c = '',
                                     Status__c = 'Reserved',   Sub_status__c = 'Ready for Dissolution' ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                        BillingPostalCode = '12345', Reserved_Name_Used__c = false);
        
                                       
        Acclist.add(testAcc1);
        Acclist.add(testAcc2);
        //Acclist.add(testAcc3);
        Acclist.add(testAcc4);
        Acclist.add(testAcc5);
        Acclist.add(testAcc6);
        Acclist.add(testAcc7);
        //Acclist.add(testAcc8);
        Acclist.add(testAcc9);
        Acclist.add(testAcc10);
        insert Acclist;

   

        Agent__c agent11 = new Agent__c();
        agent11.FirstName__c = 'Test';
        agent11.LastName__c = 'Agent';
        agent11.Email__c = 'testagent@test.com';
        agent11.Business_ID__c = testAcc1.Id;
        agent11.Type__c = 'Individual';
        agent11.Residence_Street_Address_1__c = '100';
        agent11.Residence_Street_Address_2__c = '100';
        agent11.Residence_City__c = 'Hartford';
        agent11.Residence_Country__c = 'United States';
        agent11.Residence_State__c = 'CT';
        agent11.Residence_Zip_Code__c  = '06100';
        insert agent11;

        Agent__c agent12 = new Agent__c();
        agent12.FirstName__c = 'Test';
        agent12.LastName__c = 'Agent';
        agent12.Email__c = 'testagent@test.com';
        agent12.Business_ID__c = testAcc2.Id;
        agent12.Type__c = 'Individual';
        agent12.Residence_Street_Address_1__c = '100';
        agent12.Residence_Street_Address_3__c = '100';
        agent12.Residence_City__c = 'Hartford';
        agent12.Residence_Country__c = 'United States';
        agent12.Residence_State__c = 'CT';
        agent12.Residence_Zip_Code__c  = '06100';
        insert agent12;

        Agent__c agent1 = new Agent__c();
        agent1.FirstName__c = 'Test';
        agent1.LastName__c = 'Agent';
        agent1.Email__c = 'testagent@test.com';
        agent1.Business_ID__c = testAcc7.Id;
        agent1.Type__c = 'Business';
        agent1.Mailing_Street_Address_1__c= '100';
        agent1.Mailing_City__c= 'Hartford';
        agent1.Mailing_Country__c= 'United States';
        agent1.Mailing_State__c= 'CT';
        agent1.Mailing_Zip_Code__c= '06100';
      agent1.Business_Street_Address_1__c = '100';
        agent1.Business_City__c = 'Hartford';
        agent1.Business_State__c = 'CT';
        agent1.Business_Zip_Code__c = '06100';
        agent1.Business_Country__c  = 'United States';
        agent1.Business_Name__c ='The TestClassAcct9 & Co';
          agent1.Agent_Account_ID__c  = testAcc6.Id;
        insert agent1;

        Agent__c agent2 = new Agent__c();
        agent2.FirstName__c = 'Test';
        agent2.LastName__c = 'Agent';
        agent2.Email__c = 'testagent@test.com';
        agent2.Business_ID__c = testAcc6.Id;
        agent2.Type__c = 'Business';
        agent2.Business_Street_Address_1__c = '100';
        agent2.Business_City__c = 'Hartford';
        agent2.Business_State__c = 'CT';
        agent2.Business_Zip_Code__c = '06100';
        agent2.Business_Country__c  = 'United States';
      agent2.Business_Name__c ='The TestClassAcct9 & Co';
        agent2.Agent_Account_ID__c  = testAcc6.Id;
        insert agent2;

        Agent__c agent3 = new Agent__c();
        agent3.FirstName__c = 'Test';
        agent3.LastName__c = 'Agent';
        agent3.Email__c = 'testagent@test.com';
        agent3.Business_ID__c = testAcc4.Id;
        agent3.Type__c = 'Individual';
        agent3.Business_Street_Address_1__c = '100';
        agent3.Business_Street_Address_2__c = '100';
        agent3.Business_City__c = 'Hartford';
        agent3.Business_State__c = 'CT';
        agent3.Business_Zip_Code__c = '06100';
        agent3.Business_Country__c  = 'United States';
        agent3.Residence_Street_Address_1__c= '100';
        agent3.Residence_City__c= 'Hartford';
        agent3.Residence_Country__c= 'United States';
        agent3.Residence_State__c= 'CT';
        agent3.Residence_Zip_Code__c= '06100';
        insert agent3;

        Agent__c agent4 = new Agent__c();
        agent4.FirstName__c = 'Test';
        agent4.LastName__c = 'Agent';
        agent4.Email__c = 'testagent@test.com';
        agent4.Business_ID__c = testAcc5.Id;
        agent4.Type__c = 'Individual';
        agent4.Business_Street_Address_1__c = '100';
        agent4.Business_Street_Address_3__c = '100';
        agent4.Business_City__c = 'Hartford';
        agent4.Business_State__c = 'CT';
        agent4.Business_Zip_Code__c = '06100';
        agent4.Business_Country__c  = 'United States';
        agent4.Residence_Street_Address_1__c= '100';
        agent4.Residence_City__c= 'Hartford';
        agent4.Residence_Country__c= 'United States';
        agent4.Residence_State__c= 'CT';
        agent4.Residence_Zip_Code__c= '06100';
        insert agent4;
          String query =   'SELECT BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,'
                + 'ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,'
                + 'Admin_Dissolution_Address__c,Admin_Dissolution_City__c,Admin_Dissolution_State__c,Admin_Dissolution_Zip_Code__c,Admin_Dissolution_Country__c,'
                + '('
                    + 'SELECT Business_ID__c,'
                        + 'Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,'
                        + 'Residence_City__c,Residence_State__c,Residence_Country__c,Residence_Zip_Code__c,'
                        + 'Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,'
                        + 'Mailing_City__c, Mailing_State__c,Mailing_Country__c,Mailing_Zip_Code__c,'
                        + 'Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,'
                        + 'Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c'
                    + ' FROM Agents__r'
                +')'
            + ' FROM Account'
            + ' WHERE Sub_status__c IN (\'Ready for Dissolution\', \'Admin Dissolution Initiated\', \'Ready for Forfeiture\', \'Ready for Revocation\')';
        
       List<Account>  newAcclist = ( List<Account>) database.query(query);
        test.StartTest();
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        AdminDissolutionUpdates batchInstance = new AdminDissolutionUpdates();
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, newAcclist);
        batchInstance.finish(BC); 
        test.StopTest();
    
    }
     
  
}