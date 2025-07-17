/********************************************************************************************************
* DESCRIPTION: Controller class for Mass Agent change button to process Agent records to be updated
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                        DESCRIPTION
* ------------------------------------------------------------------------------------------------------
* Andrew Friedman             07/11/2021                 Created first version
* Aparna S                    09/15/2021                 Move Database operations to Queable/Batch jobs
*********************************************************************************************************/
public class Mass_Agent_Change_Button_Controller
{    
    @AuraEnabled
	public static String checkCustomerExists(String macId)
    {
        Mass_Agent_Change__c mac = [Select id, Customer__c, Effective_Date_Time__c from Mass_Agent_Change__c where id = :macId];
        if(mac.Customer__c != null)
        {
            if(mac.Effective_Date_Time__c < System.now())
            {
                return 'DateError';
            }
            else{
            	return 'NoError';
            }
        }
        else{
        	return 'CustomerError';
        }
    }
    
 	@AuraEnabled
	public static List<agentWrapper> getRelatedAgents(String macId)
    {         
        List<agentWrapper> agents = new List<agentWrapper>();
        for(Agent_Change__c a: [select 
                         	id, Agent__r.id, Agent__r.Name__c, Agent__r.Business_ID__c, Agent__r.Business_ID__r.AccountNumber, Agent__r.Business_ID__r.Name, Agent__r.Business_ID__r.Citizenship__c, Agent__r.Business_ID__r.Type,  Agent__r.Business_ID__r.Status__c 
                         from 
                         	Agent_Change__c 
                         where  
                         	Mass_Agent_Change__c = :macId])
        {
            agents.add(new agentWrapper(a.id, a.Agent__r.id, a.Agent__r.Name__c, a.Agent__r.Business_ID__c, a.Agent__r.Business_ID__r.AccountNumber, a.Agent__r.Business_ID__r.Name, a.Agent__r.Business_ID__r.Citizenship__c, a.Agent__r.Business_ID__r.Type, a.Agent__r.Business_ID__r.Status__c));
        }  
        return agents;
    }
    
    @AuraEnabled
	public static List<picklistWrapper> getPicklistValues(String fieldAPIVal)
    {   
        List<picklistWrapper> listOptions = new List<picklistWrapper>();
        Map<String, String> mapPicklistValues = SchemaUtility.getPicklistValues('Agent__c', fieldAPIVal);

        for(String picklistValues :mapPicklistValues.keySet()) {
            listOptions.add(new picklistWrapper(picklistValues,mapPicklistValues.get(picklistValues)));
        }
        return listOptions;
    }
    
    public class picklistWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
		
        public picklistWrapper(String value, String label) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
	public static String commitChanges(String macId, List<agentWrapper> finalAgents, List<List<String>> fieldChanges, String changeType)
    {
        try{
            List<String> agentChangeIds2Keep = new List<String>();
            List<Agent_Change__c> agentChanges2Keep = new List<Agent_Change__c>();
            Set<Id> agentChangesIdSet = new Set<Id>();
            Set<Id> agentIds2UpdateSet = new Set<Id>();
            List<Agent_Change__c> agentChanges2Delete = new List<Agent_Change__c>();
            List<String> agentIds2Update = new List<String>();
            integer activeAccounts = 0;

            Mass_Agent_Change__c mac = [SELECT id, Customer__c, Work_Order__c, Filing_Date__c, Effective_Date_Time__c,
                    New_Business_Name__c,
                    New_Business_Street_Address_1__c, New_Business_Street_Address_2__c, New_Business_Street_Address_3__c,
                    New_Business_City__c, New_Business_State__c, New_Business_Zip_Code__c, New_Business_Country__c,
                    New_Business_InternationalAddress__c,                    
                    New_Mailing_Street_Address_1__c, New_Mailing_Street_Address_2__c, New_Mailing_Street_Address_3__c,
                    New_Mailing_City__c, New_Mailing_State__c, New_Mailing_Zip_Code__c, New_Mailing_Country__c,                    
                    New_Residence_Street_Address_1__c, New_Residence_Street_Address_2__c, New_Residence_Street_Address_3__c,
                    New_Residence_City__c, New_Residence_State__c, New_Residence_Zip_Code__c, New_Residence_Country__c                    
                    FROM Mass_Agent_Change__c 
                    WHERE Id = :macId LIMIT 1];            
            
            for(agentWrapper aw: finalAgents){
                agentChangeIds2Keep.add(aw.agentChangeId);
            }            
            
            for(Agent_Change__c ac: [SELECT Id, Account__c, Agent__c, Account__r.Status__c FROM Agent_Change__c WHERE Mass_Agent_Change__c = :macId]){
                if(agentChangeIds2Keep.contains(ac.id)){
                    agentChanges2Keep.add(ac);
                    agentChangesIdSet.add(ac.Id);
                    agentIds2Update.add(ac.Agent__c);
                    agentIds2UpdateSet.add(ac.Agent__c);
                    if(ac.Account__c != null && ac.Account__r.Status__c == 'Active')
                    {
                        activeAccounts = activeAccounts + 1;
                    }
                }
                else{
                    agentChanges2Delete.add(ac);
                }
            }
            if(agentChanges2Delete.size() > 0){
                delete agentChanges2Delete;
            }
            
            integer totalCost = (activeAccounts * 2);
            
            mac.Total_Cost__c = totalCost;

            String tempAgentBusName = '';
            Map<String,String> fieldChangeMap = new Map<String,String>();

            for(List<String> fieldChange: fieldChanges){
                mac.put(fieldChange[1],fieldChange[2]);
                if(fieldChange[1] == 'New_Business_Name__c'){
                    tempAgentBusName = fieldChange[2];
                }

                if(fieldChange[2] != ''){
                    fieldChangeMap.put((fieldChange[1].Right(fieldChange[1].length() - 4)),fieldChange[2]); 
                }
            }
            
            // enqueue the job for processing 
            brs_MassAgentQueuedUpdates batchJob = new brs_MassAgentQueuedUpdates(agentIds2UpdateSet, fieldChangeMap, agentChangesIdSet, changeType, tempAgentBusName);
            ID batchprocessid = Database.executeBatch(batchJob);
            
            Work_Order__c wo2Update = [SELECT Id, Total_Hold_Amount__c, Final_Amount_Payable__c FROM Work_Order__c WHERE Id =:mac.Work_Order__c LIMIT 1];
            wo2Update.Total_Hold_Amount__c = (wo2Update.Total_Hold_Amount__c !=null) ? (wo2Update.Total_Hold_Amount__c + totalCost) : totalCost;
            wo2Update.Final_Amount_Payable__c = wo2Update.Total_Hold_Amount__c;
            update wo2Update;
                       
            update mac;            
            return wo2Update.id;  

        }Catch(DmlException ex){
            BOS_Utility.ExceptionHandler('Mass_Agent_Change_Button_Controller', 'commitChanges', 'Mass_Agent_Changes__c', null, null, ex, ex.getMessage());
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
    
    //This is needed because related fields come out as sub objects instead 
    //of the plain text needed for the datatable
    public class agentWrapper 
    {
        @AuraEnabled public String agentChangeId {get; set;}
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
        public agentWrapper(String acId, String aId, String aName, String bId, String bRegId, String bName, String bCitizenship, String bType, String bStatus) 
        {
            agentChangeId = acId;
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