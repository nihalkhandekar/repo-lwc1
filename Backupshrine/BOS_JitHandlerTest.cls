/*********************************************************************************************
* NAME:  BOS_JitHandlerTest
* DESCRIPTION: Test class for BOS_JitHandler
* 				 
*
* @AUTHOR: Salesforce
* @DATE: 9/1/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Salesforce				      9/1/2020                              Created
*********************************************************************************************/
@isTest
public without sharing class BOS_JitHandlerTest {
    @isTest static void testUserExists(){
        
        final Map<String, String> attributes = new Map<String, String> {
            'urn:oid:2.5.4.42' => 'con1.FirstName',
                'urn:oid:2.5.4.4' => 'con1.LastName',
                'urn:oid:0.9.2342.19200300.100.1.3' => 'contactUser@email.ca',
                'urn:mace:dir:attribute-def:ubcEduCwlPuid' => 'aaaJMvPrGO1b',
                'User.IsActive' => '1',
                'urn:oid:0.9.2342.19200300.100.1.1' => 'aaakzeS7' //SAML Attribute CWL
                };
                    
        User thisUser = [SELECT Id,ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
        User newUser = new user();
        UserRole r = new UserRole(DeveloperName = 'CT_Executive_Test', Name = 'CT Executive Test');
        System.runAs(thisUser){
             if(r!=null){
                insert r;
            }
            
            newUser.ProfileId = thisUser.ProfileId;
            newUser.LastName = 'last';
            newUser.Email = 'test@test.org.com';
            newUser.Username = 'test@test.org.com' + System.currentTimeMillis();
            newUser.CompanyName = 'TEST';
            newUser.Title = 'title';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'America/Los_Angeles';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.LocaleSidKey = 'en_US';
            newUser.UserRoleId = r.Id;
            if(newUser.LastName!=null){
                insert newUser; 
            }
        }
        
        System.runAs (newUser) {
            BOS_JitHandler jitHandler = new BOS_JitHandler();
             Account acc;
            try{
             acc = jitHandler.createAccount('testAccount','testAccount123@test.org');
            system.assertNotEquals(acc,null,'Success');
            }catch(Exception e){
                system.assertNotEquals(null, e);
            }
         Contact con1 ;
            try{
             con1 = jitHandler.createContact('SSOfirstName',  'SSOLastName','test123@gmail.com',acc.Id,'',true,'',system.today());
            system.assertNotEquals(con1,null,'Success');
            }catch(Exception e){
                system.assertNotEquals(null, e);
            }
            try{
                Contact con2 = jitHandler.createContact('SSOfirstName',  'SSOLastName','test123@gmail.com',acc.Id,'',true,'',system.today());
          }catch(Exception e){ system.assertNotEquals(null, e);}
            String fedId = 'aaaJMvPrGO1b';
            String username = 'testUser123456789@testclass.testorg.com';
           User us;
            try{
             us = jitHandler.createUser(con1, fedId, username,'en_US');
                
             }catch(Exception e){ system.assertNotEquals(null, e);}
             try{
             us = jitHandler.createUser(con1, fedId, username,'en');
                
             }catch(Exception e){ system.assertNotEquals(null, e);}
            us.FederationIdentifier = 'aaaJMvPrGO1b';
            if(us.Id<>null)
            {
                update us;
            }
            System.assertEquals('test123@gmail.com', us.Email,'Success');
            Map<String, String> attrMap = new Map<String, String>();
            attrMap.put('Email', 'testuser0@test.com');
            attrMap.put('Username', 'testuser0@test.com');
            attrMap.put('FirstName', 'Test0');
            attrMap.put('LastName', 'User0');
            
            Test.startTest();
            jitHandler.updateUser(us.id, null, null, null,fedId, attributes, null);
            jitHandler.createUser(null, null, null,fedId, attrMap, null);
            Test.stopTest();
        }
    }
    @isTest static void testUserDoesnotExist(){
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('Email', 'testuser1@test.com');
        attributes.put('Username', 'testuser1@test.com');
        attributes.put('FirstName', 'Test1');
        attributes.put('LastName', 'User1');
        attributes.put('groups', 'f3_users');
        
        Map<String, String> attributes2 = new Map<String, String>();
        attributes2.put('Email', 'testuser2@test.com');
        attributes2.put('FirstName', 'Test2');
        attributes2.put('LastName', 'User2');
        attributes2.put('groups', 'f3_users');
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.assertNotEquals(thisUser,null,'Success');
        
        System.runAs (thisUser) {
		try{
            BOS_JitHandler handObj = new BOS_JitHandler();
            String fedId ='aaaJMvPrGO1b';
            Test.startTest();
            handObj.createUser(null, null, null,fedId, attributes, null);
            BOS_JitHandler.encrypt('errorMessage');
            handObj.createUser(null, null, null,fedId, attributes2, null);
            }
            catch(Exception ex){
                System.assertEquals(true, ex.getMessage().contains('A SAML error occurred'));
            }
            Test.stopTest();
        }
    }
}