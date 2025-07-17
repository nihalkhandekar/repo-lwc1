@isTest
public class brs_MassAgentQueuedUpdates_Test {

    @testSetup
    static void setup() {
        List<Agent__c> agentLst = new List<Agent__c>();        
    	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c wo = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Mail', 'Open');
        Mass_Agent_Change__c mac = BRS_TestDataFactory.createMassAgentChange(con.Id, wo.Id);
        
        for (Integer i = 0; i < 100; i++) {
            Agent__c agent = new Agent__c();
            agent.Business_ID__c = acc.Id;
            agent.Agent_Account_ID__c = acc.Id;
            agent.Agent_Phone__c = '1234567890';
            agent.Type__c = 'Business';
            agent.Name__c = 'Agent business Name' + i;
            agent.Email__c = 'test@test.com';
            agent.Business_City__c = 'CT';
            agent.Business_State__c = 'CT';
            agent.Business_Country__c = 'United States';
            agent.Business_Street_Address_1__c = 'street address1';
            agent.Business_Zip_Code__c = '45367';
            agent.Mailing_Street_Address_1__c = 'mailing address';
            agent.Mailing_City__c = 'CT';
            agent.Mailing_Country__c = 'United States';
            agent.Mailing_State__c = 'CT';
            agent.Mailing_Zip_Code__c = '67493';
            agentLst.add(agent);
        }
        insert agentLst;
        
        List<Agent_Change__c> agentChangesList = new List<Agent_Change__c>();
        for(Agent__c agent: agentLst){
            Agent_Change__c ac = new Agent_Change__c();
            ac.Agent__c = agent.Id;
            ac.Account__c = acc.Id;
            ac.Mass_Agent_Change__c = mac.id;
            agentChangesList.add(ac);
        }
        insert agentChangesList;
    }
    
    static testmethod void testQueueable1() {
        Map<String,String> fieldChangeMap = new Map<String,String>();
        List<Agent__c> agentLst = new List<Agent__c>();        
        Set<Id> agentChangesSet = new Set<Id>();
        Set<Id> agentIds2UpdateSet = new Set<Id>();
        
        for(Agent_Change__c ac: [Select Id from Agent_Change__c]){
            agentChangesSet.add(ac.Id);
        }
        for(Agent__c ag: [Select Id, name from Agent__c]){
            agentIds2UpdateSet.add(ag.Id);
            agentLst.add(ag);
        }
        
        fieldChangeMap.put('Business_Name__c','Test the LLC');
        fieldChangeMap.put('Business_Street_Address_1__c','Test123');
        fieldChangeMap.put('Business_Street_Address_2__c','Test123');
        fieldChangeMap.put('Business_Street_Address_3__c','Test123');
        fieldChangeMap.put('Business_City__c','Test123');
        fieldChangeMap.put('Business_State__c','AZ');
        fieldChangeMap.put('Business_Zip_Code__c','85244');
        fieldChangeMap.put('Business_Country__c','USA');
        
        fieldChangeMap.put('Mailing_Street_Address_1__c','Test123');
        fieldChangeMap.put('Mailing_Street_Address_2__c','Test123');
        fieldChangeMap.put('Mailing_Street_Address_3__c','Test123');
        fieldChangeMap.put('Mailing_City__c','Test123');
        fieldChangeMap.put('Mailing_State__c','AZ');
        fieldChangeMap.put('Mailing_Zip_Code__c','85244');
        fieldChangeMap.put('Mailing_Country__c','USA');
        
        fieldChangeMap.put('Residence_Street_Address_1__c','Test123');
        fieldChangeMap.put('Residence_Street_Address_2__c','Test123');
        fieldChangeMap.put('Residence_Street_Address_3__c','Test123');
        fieldChangeMap.put('Residence_City__c','Test123');
        fieldChangeMap.put('Residence_State__c','AZ');
        fieldChangeMap.put('Residence_Zip_Code__c','85244');
        fieldChangeMap.put('Residence_Country__c','USA');
        
        Test.startTest();
        
        brs_MassAgentQueuedUpdates batchJob = new brs_MassAgentQueuedUpdates(agentIds2UpdateSet, fieldChangeMap, agentChangesSet, 'AddressChange', 'Test the LLC');
        ID batchprocessid1 = Database.executeBatch(batchJob);
        
        brs_MassAgentQueuedUpdates batchJob2 = new brs_MassAgentQueuedUpdates(agentIds2UpdateSet, fieldChangeMap, agentChangesSet, 'NameChange', 'Test the LLC');
        ID batchprocessid2 = Database.executeBatch(batchJob2);
         
        Test.stopTest();
    }
}