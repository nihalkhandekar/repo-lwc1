@isTest(seeAllData = false)
public class Mass_Agent_Change_Button_Controller_Test {

    @TestSetup
    static void setup() {
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        
        contact con=new contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        
        Work_Order__c workOrdernew  = new Work_Order__c();
        workOrdernew.Source__c = 'Email';
        workOrdernew.Received_Date__c = System.Now();
        workOrdernew.Completed_Date__c = System.Today();
        workOrdernew.Status__c = System.Label.BRS_Status_Value_Completed;
        workOrdernew.Customer__c=con.Id;
        workOrdernew.Payment_Method__c = 'Credit Card';
        workOrdernew.Type__c = System.Label.MassAgentChangeLabel;
        workOrdernew.Total_Hold_Amount__c = 50;
        insert workOrdernew;
        
        Agent__c agent = new Agent__c();
        agent = BRS_TestDataFactory.createAgent(acc.id);
        
        Mass_Agent_Change__c massagent = new Mass_Agent_Change__c();
        massagent = BRS_TestDataFactory.createMassAgentChange(con.id,workOrdernew.id);        
                
        Agent_Change__c agentChange = new Agent_Change__c();
        agentChange = BRS_TestDataFactory.createAgentChange(agent.id,massagent.id,acc.id);
    }
    
    testMethod static void checkCustomerExists()
    {
        Mass_Agent_Change__c massagent=[select id,Customer__c from Mass_Agent_Change__c];
        Mass_Agent_Change__c massagent1 = new Mass_Agent_Change__c();
        massagent1.Effective_Date_Time__c = (System.now()).addDays(-2);
        insert massagent1;
        Test.startTest();
        Mass_Agent_Change_Button_Controller.checkCustomerExists(massagent.id);
        Mass_Agent_Change_Button_Controller.checkCustomerExists(massagent1.Id);
        Mass_Agent_Change_Button_Controller.getRelatedAgents(massagent.id);
        Mass_Agent_Change_Button_Controller.getPicklistValues('Business_State__c');
        Test.stopTest();
        
    }
    
     testMethod static void commitChanges()
    {
        Agent__c agent=[select id,Name,Name__c,Business_ID__c,Business_ID__r.Citizenship__c,Business_ID__r.Name,Business_ID__r.Business_Type__c,Business_ID__r.Status__c from Agent__c];
        Agent_Change__c agentchange=[select id from Agent_Change__c];
        Mass_Agent_Change__c massagent=[select id,Customer__c from Mass_Agent_Change__c];
        List<String> field1=new List<String>{'Test the LLC','New_Business_Name__c','Test the LLC'};
        List<String> field2=new List<String>{'Test&','New_Business_Name__c','Test&'};
        List<String> field3=new List<String>{'Test123','New_Business_Street_Address_1__c','Test123'};
        List<String> field4=new List<String>{'Test123','New_Business_Street_Address_2__c','Test123'};
        List<String> field5=new List<String>{'Test123','New_Business_Street_Address_3__c','Test123'};
        List<String> field6=new List<String>{'Test123','New_Business_City__c','Test123'};
        List<String> field7=new List<String>{'AZ','New_Business_State__c','AZ'};
        List<String> field8=new List<String>{'85244','New_Business_Zip_Code__c','85244'};
        List<String> field9=new List<String>{'USA','New_Business_Country__c','USA'};
        List<String> field10=new List<String>{'Test123','New_Mailing_Street_Address_1__c','Test123'};
        List<String> field11=new List<String>{'Test123','New_Mailing_Street_Address_2__c','Test123'};
        List<String> field12=new List<String>{'Test123','New_Mailing_Street_Address_3__c','Test123'};
        List<String> field13=new List<String>{'Test123','New_Mailing_City__c','Test123'};
        List<String> field14=new List<String>{'AZ','New_Mailing_State__c','AZ'};
        List<String> field15=new List<String>{'85244','New_Mailing_Zip_Code__c','85244'};
        List<String> field16=new List<String>{'USA','New_Mailing_Country__c','USA'};
        List<String> field17=new List<String>{'Test123','New_Residence_Street_Address_1__c','Test123'};
        List<String> field18=new List<String>{'Test123','New_Residence_Street_Address_2__c','Test123'};
        List<String> field19=new List<String>{'Test123','New_Residence_Street_Address_3__c','Test123'};
        List<String> field20=new List<String>{'Test123','New_Residence_City__c','Test123'};
        List<String> field21=new List<String>{'AZ','New_Residence_State__c','AZ'};
        List<String> field22=new List<String>{'85244','New_Residence_Zip_Code__c','85244'};
        List<String> field23=new List<String>{'USA','New_Residence_Country__c','USA'};
            
        List<List<String>> finalList= new List<List<String>>{field1,field2};
        List<List<String>> finalList2= new List<List<String>>{field3,field4,field5,field6,field7,field8,field9,field10,field11,field12,field13,field14,field15,field16,field17,field18,field19,field20,field21,field22,field23};
        List<Mass_Agent_Change_Button_Controller.agentWrapper> listAgentWrapper=new List<Mass_Agent_Change_Button_Controller.agentWrapper>();
        Mass_Agent_Change_Button_Controller.agentWrapper agentwrapper=new Mass_Agent_Change_Button_Controller.agentWrapper();
        agentwrapper.agentChangeId=agentchange.id;
        agentwrapper.agentId=agent.id;
        agentwrapper.agentName=agent.Name__c;
        agentwrapper.businessId=agent.Business_ID__c;
        agentwrapper.businessName=agent.Business_ID__r.Name;
        agentwrapper.businessType=agent.Business_ID__r.Business_Type__c;
        agentwrapper.businessStatus=agent.Business_ID__r.Status__c;
        listAgentWrapper.add(agentwrapper);
        Test.startTest();
        Mass_Agent_Change_Button_Controller.commitChanges(massagent.id,listAgentWrapper,finalList,'NameChange');
        Mass_Agent_Change_Button_Controller.commitChanges(massagent.id,listAgentWrapper,finalList2,'AddressChange');
        Test.stopTest();
    }

}