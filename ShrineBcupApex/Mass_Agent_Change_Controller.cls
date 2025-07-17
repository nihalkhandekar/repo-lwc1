public class Mass_Agent_Change_Controller 
{
    @AuraEnabled
    public static List<agentWrapper> searchAgentName(String aName, boolean exactMatch)
    { 
        if(!exactMatch){aName = '%'+aName+'%';}
        
        List<agentWrapper> agents = new List<agentWrapper>();
        for(Agent__c a: [select 
                            id, Name__c, Business_ID__c, Business_ID__r.AccountNumber, Business_ID__r.Name, Business_ID__r.Citizenship__c, Business_ID__r.Business_Type__c, Business_ID__r.Status__c 
                         from 
                            Agent__c 
                         where  
                            Name__c Like :aName
                        and Business_ID__r.Status__c != 'Pending'
                        and Business_ID__r.Status__c != ''])
        {
            agents.add(new agentWrapper(a.id, a.Name__c, a.Business_ID__c, a.Business_ID__r.AccountNumber, a.Business_ID__r.Name, a.Business_ID__r.Citizenship__c, a.Business_ID__r.Business_Type__c, a.Business_ID__r.Status__c));
        }  
        return agents;
    }

    @AuraEnabled
    public static Integer totalAgentRecords(String aName, boolean exactMatch)
    { 
        if(!exactMatch){aName = '%'+aName+'%';}
        
        Integer totalRecords = [select COUNT() FROM Agent__c WHERE Name__c Like :aName AND Business_ID__r.Status__c != 'Pending' AND Business_ID__r.Status__c != ''];
        
        return totalRecords;
    }
    
    @AuraEnabled
    public static String insertAgentChanges(List<agentWrapper> agentDisplays, String workOrderId)
    {
        try{
            Mass_Agent_Change__c mac = new Mass_Agent_Change__c();
            mac.Status__c = 'Pending';
            if(workOrderId != null){
                Work_Order__c WO = [SELECT Id, Received_Date__c, Customer__c FROM Work_Order__c WHERE Id =:workOrderId LIMIT 1 ];
                mac.Work_Order__c = WO.Id;
                mac.Filing_Date__c = Date.valueOf(WO.Received_Date__c);
                mac.Effective_Date_Time__c = WO.Received_Date__c;
                mac.Customer__c = WO.Customer__c;
            }
            insert mac;
            List<Agent_Change__c> agentChanges2Insert = new List<Agent_Change__c>();
            for(agentWrapper adw: agentDisplays)
            {
                Agent_Change__c ac = new Agent_Change__c();
                ac.Agent__c = adw.agentId;
                ac.Account__c = adw.businessId;
                ac.Mass_Agent_Change__c = mac.id;
                agentChanges2Insert.add(ac);
            }
            if(agentChanges2Insert.size() > 0){
                insert agentChanges2Insert;
            }
            return mac.id;
        } Catch(DmlException ex){
            BOS_Utility.ExceptionHandler('Mass_Agent_Change_Controller', 'insertAgentChanges', 'Mass_Agent_Changes__c', null, null, ex, ex.getMessage());
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
    
    //This is needed because related fields come out as sub objects instead 
    //of the plain text needed for the datatable
    public class agentWrapper 
    {
        @AuraEnabled public String agentId {get; set;}
        @AuraEnabled public String agentName {get; set;}
        @AuraEnabled public String businessId {get; set;}
        @AuraEnabled public String businessRegId {get; set;}
        @AuraEnabled public String businessName {get; set;}
        @AuraEnabled public String businessCitizenship {get; set;}
        @AuraEnabled public String businessType {get; set;}
        @AuraEnabled public String businessStatus {get; set;}
        
        public agentWrapper() 
        {
        }
        public agentWrapper(String aId, String aName, String bId, String bRegId, String bName, String bCitizenship, String bType, String bStatus) 
        {
            agentId = aId;
            agentName = aName;
            businessId = bId;
            businessRegId = bRegId;
            businessName = bName;
            businessCitizenship = bCitizenship;
            businessType = bType;
            businessStatus = bStatus;
        }
    }
}