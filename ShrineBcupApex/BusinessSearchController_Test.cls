@isTest
private without sharing class BusinessSearchController_Test {
    @testSetup
    private static void setup() {
        Map<Account, List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        Contact con = AccountsVsContacts.values().get(0).get(0);
        
        Credential__c cred = QnA_TestDataFactory.createCredential();
        Account_Credential_Relationship__c accRel = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
           Contact__c= con.id,
          
            Account__c = con.AccountId
        );
        insert accRel;
         Account_Credential_Relationship__c accRel1 = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
           Contact__c= con.id,
          
            Account__c = con.AccountId
        );
        insert accRel1;
        
           Account acc1 = [Select Id From Account Where name ='test' limit 1];
        
         Account_Credential_Relationship__c accRel4 = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
           Contact__c= con.id,
          
            Account__c = acc1.id
        );
        insert accRel4;
        
        
        Contact_Credential_Relationship__c conRel = new Contact_Credential_Relationship__c(
        	Credential__c = cred.Id,
            
            Contact__c = con.Id
        );
		insert conRel;
 Contact_Credential_Relationship__c conRel1 = new Contact_Credential_Relationship__c(
        	Credential__c = cred.Id,
            
            Contact__c = con.Id
        );
		insert conRel1;
         Credential__c cred1 = new Credential__c();
        cred1.Credential_Id__c = '123456';
        cred1.External_Id__c = 'test2';
        insert cred1;
        
         Account_Credential_Relationship__c accRel2 = new Account_Credential_Relationship__c(
        	Credential__c = cred.Id,
           Contact__c= con.id,
          
            Account__c = con.AccountId
        );
        insert accRel2;
        
        Id p = [select id from profile where name='CT Community User'].id;
        User user = QnA_TestDataFactory.createCommunityUser(con,p);
        
        
        
        
        
    }
    
    private static BusinessSearchController.BusinessDetail getDetail() {
        AccountDashboard.ContactWrapper principalDetail = new AccountDashboard.ContactWrapper(new Principal__c(
        	Name__c = 'Test',
            Principal_Title__c = 'Test',
            Principal_Type__c = 'Individual'
        ));
        principalDetail.value = 'Some';
        
        BusinessSearchController.BusinessDetail detail = new BusinessSearchController.BusinessDetail();
        detail.businessName = '';
        detail.businessId = '';
        detail.status = '';
        detail.billingCity = '';
        detail.billingCountry = '';
        detail.billingPostalCode = '';
        detail.billingState = '';
        detail.mailingCity = '';
        detail.billingStreet = '';
        detail.id = '';
        detail.mailingCountry = '';
        detail.mailingPostalCode = '';
        detail.mailingState = '';
        detail.mailingStreet = '';
        detail.value = '';
        detail.label = '';
        detail.address = '';
        detail.principalDetails = new List<AccountDashboard.ContactWrapper> { principalDetail };  
        
        detail.listedAgent = new BusinessSearchController.AgentDetail();
        detail.listedAgent.businessId = '123';
        detail.listedAgent.address = 'Some';
        detail.listedAgent.value = 'Some';
        detail.listedAgent.label = '';
        
        return detail;
    }
    
    private static CredentialResponse.CredentialDetail getCredDetail() {
        CredentialResponse.CredentialDetail detail = new CredentialResponse.CredentialDetail();
    	return detail;
    }
    
    private static BusinessSearchController.PreVerifiedData getPreVerifiedData() {
        BusinessSearchController.PreVerifiedData data = new BusinessSearchController.PreVerifiedData();
        data.customerID = '123';
        data.email = 'random@random.com';
        
        return data;
    }
    
    
     

    @isTest
    private static void testBusinessFlow() {
        try{
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
      
          Principal__c pal = [Select Id From Principal__c limit 1];
        Agent__c agt = [Select Id From Agent__c  limit 1];
//System.debug('agt ## '+agt);
        System.debug('pal ## '+pal);
      
        System.runAs(u) {
            Test.startTest();
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = acc.id;
        fixedSearchResults[1] = agt.id;
        fixedSearchResults[2] = pal.id;
       Test.setFixedSearchResults(fixedSearchResults);
                List<BusinessSearchController.BusinessDetail> data = BusinessSearchController.searchBusiness('Grazitti',   null);
               BusinessSearchController.searchBusiness('Grazitti', new  List<String> { acc.Id });
            BusinessSearchController.searchBusiness('Agent', null);
            BusinessSearchController.searchBusiness('Principals',null);
            
            Test.stopTest();
        }
        }catch(Exception e){ system.assertNotEquals(null, e);}
       
    }
    
    @isTest
    private static void testBusinessDetail() {
        Test.startTest();
        	getDetail();
        Test.stopTest();        
    }
    
    @isTest
    private static void testlinkBusiness() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u) {
            Test.startTest();
            	BusinessSearchController.linkBusiness(acc.Id);
            
                try  {
                    BusinessSearchController.linkBusiness(null);
                } catch(AuraHandledException e) {
                    system.assertNotEquals(null, e);
                }
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testupdateBusinessDetail() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        List<BusinessSearchController.BusinessDetail> listDetails = new List<BusinessSearchController.BusinessDetail> { getDetail() };
            // businessData = '[{"custid":"000370264","id":"001r000000Nd6YVAAZ"},{"custid":"000000000","id":"001r000000Nd9mMAAR"}]';
    String credentialData = '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
    List<CredentialResponse.CredentialDetail> credetnials = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentialData, CredentialResponse.CredentialDetail[].class);

        System.runAs(u) {
            Test.startTest();
            	
            	BusinessSearchController.updateBusinessDetail(JSON.serialize(listDetails), JSON.serialize(credetnials));
            
               
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testdoCredentialAutoSearchOne() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        List<BusinessSearchController.BusinessDetail> listDetails = new List<BusinessSearchController.BusinessDetail> { getDetail() };
            
            System.runAs(u) {
                BusinessSearchController controller = new BusinessSearchController();
                Continuation conti = (Continuation)BusinessSearchController.doCredentialAutoSearch(JSON.serialize(listDetails));
                HttpResponse response = new HttpResponse();
                String mockResp = '{"credentials":[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"}]}';
                response.setBody(mockResp);
                response.setStatusCode(200);
                Test.setContinuationResponse('continuation-1', response);
                Object state = listDetails;
                
                Test.startTest();
                try {
                    BusinessSearchController.processResponse(new List<String>{'continuation-1'}, state);                
                } catch(Exception e) {
                    System.assertNotEquals(null, e);
                }
                Test.stopTest();
            }
    }
    
    @isTest
    private static void testdoCredentialAutoSearchTwo() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        List<BusinessSearchController.BusinessDetail> listDetails = new List<BusinessSearchController.BusinessDetail> { getDetail() };
            
            System.runAs(u) {
                BusinessSearchController controller = new BusinessSearchController();
                Continuation conti = (Continuation)BusinessSearchController.doCredentialAutoSearch(JSON.serialize(listDetails));
                HttpResponse response = new HttpResponse();
                String mockResp = '{"credentials":[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"}]}';
                response.setBody(mockResp);
                response.setStatusCode(2004);
                Test.setContinuationResponse('continuation-1', response);
                Object state = listDetails;
                
                Test.startTest();
                try {
                    BusinessSearchController.processResponse(new List<String>{'continuation-1'}, state);                
                } catch(Exception e) {
                    System.assertNotEquals(null, e);
                }
                Test.stopTest();
            }
    }    
    
    @isTest
    private static void testdoCredentialAutoSearchThree() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        List<BusinessSearchController.BusinessDetail> listDetails = new List<BusinessSearchController.BusinessDetail> { getDetail() };
            
            System.runAs(u) {
                BusinessSearchController controller = new BusinessSearchController();
                Continuation conti = (Continuation)BusinessSearchController.doCredentialAutoSearch(JSON.serialize(listDetails));
                HttpResponse response = new HttpResponse();
                String mockResp = '{"credentials":[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC"}]}';
                response.setBody(mockResp);
                response.setStatusCode(100);
                Test.setContinuationResponse('continuation-1', response);
                Object state = listDetails;
                
                Test.startTest();
                try {
                    BusinessSearchController.processResponse(new List<String>{'continuation-1'}, state);                
                } catch(Exception e) {
                    System.assertNotEquals(null, e);
                }
                Test.stopTest();
            }
    }

    @isTest
    private static void testgetRequest() {
        Test.startTest();
        	BusinessSearchController.getRequest('URL', 'requestString');
        Test.stopTest();
    }

	@isTest
    private static void testprocessResponse() {
        Test.startTest();
            try {
		        BusinessSearchController.processResponse(new List<String> { 'Val0'}, '');                
            } catch(Exception e) {
                System.assertNotEquals(null, e);
            }

        Test.stopTest();
    }
    
    @isTest
    private static void testDoDML() {
        Action_Item__c toDelete = new Action_Item__c();
        insert toDelete;
        Action_Item__c toInsert = new Action_Item__c();
        
        Test.startTest();
        	BusinessSearchController.doDML(JSON.serialize(new List<Action_Item__c> { toInsert }), JSON.serialize(new List<Action_Item__c> { toDelete }));
        Test.stopTest();
    }
    
    @isTest
    private static void testprocessIdSearchResponse() {
        Map<String,String> credentilIds = new Map<String,String>();
        Set<String> elicenseIds = new Set<String>();        
        BusinessSearchController.StateWrapper state = new BusinessSearchController.StateWrapper(credentilIds, elicenseIds, 'business');
        
        Test.startTest();
            try {
	        	BusinessSearchController.processIdSearchResponse(new List<String>(), state);                
            } catch(Exception e) {
                system.assertNotEquals(null, e);
            }

        Test.stopTest();
    }
    
    @isTest
    private static void testdoCredentialContactSearch() {
        List<CredentialResponse.CredentialDetail> listCredDetails = new List<CredentialResponse.CredentialDetail> { getCredDetail() };
        
        Test.startTest();
        	BusinessSearchController.doCredentialContactSearch(JSON.serialize(listCredDetails));
        Test.stopTest();
    }
    
    @isTest
    private static void testdoCredentialManualSearch() {
        //List<CredentialResponse.CredentialDetail> listCredDetails = new List<CredentialResponse.CredentialDetail> { getCredDetail() };
        
        Test.startTest();
        	BusinessSearchController.doCredentialManualSearch('Grazitti');
        Test.stopTest();
    }

    @isTest
    private static void testdoCredentialIDSearchOne() {
        Account acc = [SELECT Id FROM Account WHERE name ='Grazitti' LIMIT 1];
        User u = [SELECT Id FROM user WHERE username='tester@noemail.com' LIMIT 1];
        Credential__c cred = new Credential__c(Credential_Type__c = 'Professional');
        insert cred;
        Action_Item__c ai = new Action_Item__c(Credential__c = cred.Id);
        insert ai;
        
        System.runAs(u) {            
            BusinessSearchController controller = new BusinessSearchController();
            Continuation conti = (Continuation) BusinessSearchController.doCredentialIDSearch(acc.Id, 'business');
            HttpResponse response = new HttpResponse();
            String mockResp = '{"credentials":[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[{"eLicense_SOTS_ID":null,"Credential":null,"Name":"","eLicense_Credential_Action_Due_Date":"11/30/2021","Description":"test","Link_Text":"","Link_URL":"","Activity_ID":null}]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[{"eLicense_SOTS_ID":null,"Credential":null,"Name":"","eLicense_Credential_Action_Due_Date":"11/30/2021","Description":"test","Link_Text":"","Link_URL":"","Activity_ID":null}]}]}';
            response.setBody(mockResp);
            response.setStatusCode(200);
            Test.setContinuationResponse('continuation-1', response);
            Map<String,String> mp = new Map<String,String>{'cred.Id' => 'cred.Id'};
            BusinessSearchController.StateWrapper sw = new BusinessSearchController.StateWrapper(mp, new Set<String>{'4656'}, 'Professional');
            Object state = sw;
            
            Test.startTest();
            try {
                BusinessSearchController.processIdSearchResponse(new List<String>{'continuation-1'}, state);                
            } catch(Exception e) {
                System.assertNotEquals(null, e);
            }
            Test.stopTest();
        }
    }   
    
    @isTest
    private static void testgetLinkedBusiness() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
         Account acc1 = [Select Id From Account Where name ='test' limit 1];
         User u = [Select Id From user where username='tester@noemail.com' limit 1];

        System.runAs(u) {
        Test.startTest();
        	BusinessSearchController.getLinkedBusiness(acc.Id);
        BusinessSearchController.getLinkedBusiness(acc1.Id);
        
	        BusinessSearchController.getLinkedBusiness(null);
        Test.stopTest();
        }
    }    
    
    @isTest
    private static void testgetLinkedCredentials() {
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u) {
        Test.startTest();
        	BusinessSearchController.getLinkedCredentials();
        Test.stopTest();
        }
    }    
    
    @isTest
    private static void testgetCurrentUserData() {
        Test.startTest();
        	BusinessSearchController.getCurrentUserData();
        Test.stopTest();
    }   
    
    @isTest
    private static void testvalidateEmailID() {
        Account acc = [Select Id, Business_Email_Address__c From Account Where name ='Grazitti' limit 1];
        acc.Business_Email_Address__c = 'random@random.com';
        update acc;
        
        Test.startTest();
        	String matched = BusinessSearchController.validateEmailID('random@random.com', acc.Id);
        	String notmatched = BusinessSearchController.validateEmailID('random@random.com', acc.Id);
        
            try {
                BusinessSearchController.validateEmailID('random@random.com', '');
            } catch(AuraHandledException e) {
                System.assert(true);
            }
        Test.stopTest();
    }   
    
    @isTest
    private static void testvalidateCustomerID() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        acc.Business_Email_Address__c = 'random@random.com';
        acc.Business_Customer_ID__c = '123';
        update acc;
        
        Credential__c cred = [
            SELECT Id 
            FROM Credential__c 
            LIMIT 1
        ];
        
        List<BusinessSearchController.PreVerifiedData> listData = new List<BusinessSearchController.PreVerifiedData> { getPreVerifiedData() };
        
        Test.startTest();
        	BusinessSearchController.validateCustomerID(cred.Id, acc.Id, JSON.serialize(listData));
        
        	//catch
        	BusinessSearchController.validateCustomerID(acc.Id, cred.Id, JSON.serialize(listData));
        Test.stopTest();
    }  
    
    @isTest
    private static void testcheckforBusinessVerification() {
        Account acc = [Select Id, Business_Email_Address__c, Business_Customer_ID__c From Account Where name ='Grazitti' limit 1];
        acc.Business_Email_Address__c = 'random@random.com';
        acc.Business_Customer_ID__c = '123';
        update acc;
        List<BusinessSearchController.PreVerifiedData> listData = new List<BusinessSearchController.PreVerifiedData> { getPreVerifiedData() };
        
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u) {
            Test.startTest();
                BusinessSearchController.checkforBusinessVerification(acc.Id, false, JSON.serialize(listData));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testcheckforBusinessVerificationEmailOnly() {
        Account acc = [Select Id, Business_Email_Address__c, Business_Customer_ID__c From Account Where name ='Grazitti' limit 1];
        acc.Business_Email_Address__c = 'random@random.com';
        acc.Business_Customer_ID__c = '123';
        update acc;
        List<BusinessSearchController.PreVerifiedData> listData = new List<BusinessSearchController.PreVerifiedData> { getPreVerifiedData() };
        
        User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u) {
            Test.startTest();
                BusinessSearchController.checkforBusinessVerification(acc.Id, true, JSON.serialize(listData));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testcheckCredentialVerificationSwitch() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        Credential__c cred = [
            SELECT Id 
            FROM Credential__c 
            LIMIT 1
        ];
            User u = [Select Id From user where username='tester@noemail.com' limit 1];
          String credentialData = '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
BusinessSearchController.checkCredentialVerificationSwitch(credentialData);
        System.runAs(u) {
        Test.startTest();
        	BusinessSearchController.checkCredentialVerificationSwitch(null);
        
        	try  {
                BusinessSearchController.checkCredentialVerificationSwitch(credentialData);
            } catch(AuraHandledException e) {
                System.assert(true);
            }
        Test.stopTest();
        }
        
       
    }  
    
    @isTest
    private static void testprocessResponseforVerification() {
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        Credential__c cred = [
            SELECT Id 
            FROM Credential__c 
            LIMIT 1
        ];
        
        Test.startTest();
            try {
                BusinessSearchController.processResponseforVerification(new List<String> {'Val0'}, '');                
            } catch(Exception e) {
                System.assertNotEquals(null, e);
            }
        Test.stopTest();
    }  
    
    @isTest
    private static void testClasses() {
        Test.startTest();
            BusinessSearchController.PreVerifiedData data = getPreVerifiedData();
        
            BusinessSearchController.BusinessData bizData = new BusinessSearchController.BusinessData();
            bizData.Name =  '';
            bizData.SotsID =  '';
            bizData.BusinessAddress =  '';
            bizData.MailingAddress =  '';
            bizData.Principals =  null;
        
        	BusinessSearchController.NameJsonClass jsonData = new BusinessSearchController.NameJsonClass();
        	jsonData.Name = '';
        Test.stopTest();
    }  
    @isTest
    private static void testdoupdateIdsInForgerock(){
                Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        
          String businessData = '[{"custid":"000370264","id":"001r000000Nd6YVAAZ"},{"custid":"000000000","id":"'+acc.id+'"}]';
    String credentialData = '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
    User u = [Select Id From user where username='tester@noemail.com' limit 1];
        
        System.runAs(u) {
         Test.startTest();
        BusinessSearchController.doupdateIdsInForgerock(businessData, credentialData);
        Test.stopTest();
    }
    }
    
    @isTest
    private static void testVerifiedEmail(){
        try{      
        Account acc = [Select Id From Account Where name ='Grazitti' limit 1];
        
    User u = [Select Id From user where username='tester@noemail.com' limit 1];
         BusinessSearchController.PreVerifiedData listData =  getPreVerifiedData() ;
      listData.id = acc.id;
        System.runAs(u) {
         Test.startTest();
            
        BusinessSearchController.getVerifiedEmail(JSON.serialize(listData));
            BusinessSearchController.getVerifiedEmail(null);
        Test.stopTest();
    }
            
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
    }
    
    @istest
    public static void formatDateTest(){
        Test.startTest();
        Date date1 = Date.newInstance(2021, 03, 22);
        string newdate = string.valueOf(date1);
        System.debug(newdate);
        List<string> arr = newdate.split('-');
        String formatteddate = arr[1]+'/'+arr[2]+'/'+arr[0];
        date dateformat = BusinessSearchController.formatDate(formatteddate);
        Test.stopTest();  
    }
}