@isTest public class brs_agentBusinessNameDataUpdate_Test {
    
    @isTest static void brs_agentBusinessNameDataUpdateExecute(){
        
        Account acc = BRS_TestDataFactory.createAccountObject();
        Id profileId = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(profileId);
        user.Bypass_Trigger__c=true;
        update user;        
        system.runAs(user){ 
            
            String accId = acc.Id;
            Agent__c agent = new Agent__c();
            agent.Business_ID__c = accId;
            agent.Agent_Phone__c ='8699671466';
            agent.Name__c = 'Agent business Name';
            agent.Email__c='sbabarabbani@deloitte.com';
            agent.Business_Name__c = 'Agent business Name';
            agent.Residence_City__c = 'CT';
            agent.Residence_State__c = 'CT';
            agent.Residence_Country__c = 'United States';
            agent.Residence_Street_Address_1__c = 'street address1';
            agent.Residence_Zip_Code__c= '45367';
            agent.Residence_Street_Address_2__c = 'mailing address';
            agent.Type__c=System.Label.Individual_Label;
            agent.FirstName__c = 'Test';
            agent.LastName__c = 'Agent';
            agent.Business_City__c = 'CT';
            agent.Business_State__c = 'CT';
            agent.Business_Country__c = 'United States';
            agent.Business_Street_Address_1__c = 'street address1';
            agent.Business_Zip_Code__c= '45367';
            agent.Agent_Account_ID__c=acc.Id;
            insert agent;
            
            test.startTest();
            Database.executeBatch(new brs_agentBusinessNameDataUpdate());
            test.stopTest();
        }
    }
    @isTest static void brs_agentBusinessNameDataUpdateExecute1(){
        
        Account acc = BRS_TestDataFactory.createAccountObject();
        Id profileId = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(profileId);
        user.Bypass_Trigger__c=true;
        update user;        
        system.runAs(user){  
            
            List<Agent__c> lstagent = new List<Agent__c>();
            String accId = acc.Id;
            Agent__c agent = new Agent__c();
            agent.Business_ID__c = accId;
            agent.Agent_Phone__c ='8699671466';
            agent.Name__c = 'Agent business Name';
            agent.Email__c='sbabarabbani@deloitte.com';
            agent.Business_Name__c = 'Agent business Name';
            agent.Residence_City__c = 'CT';
            agent.Residence_State__c = 'CT';
            agent.Residence_Country__c = 'United States';
            agent.Residence_Street_Address_1__c = 'street address1';
            agent.Residence_Zip_Code__c= '45367';
            agent.Residence_Street_Address_2__c = 'mailing address';
            agent.Type__c=System.Label.Individual_Label;
            agent.FirstName__c = 'Test';
            agent.Business_City__c = 'CT';
            agent.Business_State__c = 'CT';
            agent.Business_Country__c = 'United States';
            agent.Business_Street_Address_1__c = 'street address1';
            agent.Business_Zip_Code__c= '45367';
            agent.Agent_Account_ID__c=acc.Id;
            insert agent;
            
        }
        test.startTest();
        Database.executeBatch(new brs_agentBusinessNameDataUpdate());
        test.stopTest();
    }
}