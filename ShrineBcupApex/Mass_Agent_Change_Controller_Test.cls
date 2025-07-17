@istest(seeAllData = false)
public class Mass_Agent_Change_Controller_Test {
    @TestSetup
    static void setup() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        Agent__c agent=new Agent__c();
        agent=BRS_TestDataFactory.createAgent(acc.id);
        Contact con=BRS_TestDataFactory.createContactObject(agent.Business_ID__c);        
        Work_Order__c workOrdernew  = new Work_Order__c();
        workOrdernew.Source__c = 'Email';
        workOrdernew.Received_Date__c = System.Now();
        workOrdernew.Completed_Date__c = System.Today();
        workOrdernew.Status__c = System.Label.BRS_Status_Value_Completed;
        workOrdernew.Customer__c=con.Id;
        workOrdernew.Payment_Method__c = 'Credit Card';
        workOrdernew.Type__c = System.Label.MassAgentChangeLabel;
        insert workOrdernew;
    }
    testMethod static void searchAgentName()
    {
        Agent__c agent=[select id,Name,Name__c from Agent__c];
        Test.startTest();
        Mass_Agent_Change_Controller.searchAgentName(agent.Name__c,true);
        Integer count = Mass_Agent_Change_Controller.totalAgentRecords(agent.Name__c, true);
        Test.stopTest();
    }

        testMethod static void insertAgentChanges()
    {        
        Agent__c agent=[select id,Name,Name__c,Business_ID__c,Business_ID__r.Citizenship__c,Business_ID__r.Name,Business_ID__r.Business_Type__c,Business_ID__r.Status__c from Agent__c];
        Work_Order__c workOrdernew=[select id, Name,Source__c,Received_Date__c,Completed_Date__c,Status__c,Customer__c,Type__c from Work_Order__c];
        List<Mass_Agent_Change_Controller.agentWrapper> listagentwrapper= new List<Mass_Agent_Change_Controller.agentWrapper>();
        Mass_Agent_Change_Controller.agentWrapper agentwrapper=new Mass_Agent_Change_Controller.agentWrapper();
        agentwrapper.agentId=agent.id;
        agentwrapper.agentName=agent.Name__c;
        agentwrapper.businessId=agent.Business_ID__c;
        agentwrapper.businessName=agent.Business_ID__r.Name;
        agentwrapper.businessType=agent.Business_ID__r.Business_Type__c;
        agentwrapper.businessStatus=agent.Business_ID__r.Status__c;
        listagentwrapper.add(agentwrapper);
        Test.startTest();
        Mass_Agent_Change_Controller.insertAgentChanges(listagentwrapper,workOrdernew.id);
        Test.stopTest();
    }
}