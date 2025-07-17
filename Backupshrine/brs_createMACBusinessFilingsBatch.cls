/********************************************************************************************
* DESCRIPTION: Batch class to insert Business Filing records for updated Agents
*
* MODIFICATION LOG:
* DEVELOPER                      DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Aparna S                     09/16/2021               Created first version
*********************************************************************************************/
public class brs_createMACBusinessFilingsBatch implements Database.Batchable<sObject> {
	private Set<Id> agentChangesIdSet;
    private String changeType;
    private Id rcId = SchemaUtility.getRecordTypeId('Business_Filing__c', 'Maintenance');
    
    public brs_createMACBusinessFilingsBatch(Set<Id> agentChangesIdSet, String changeType) { //Iterable<sObject> | 50k limits 
        this.agentChangesIdSet = agentChangesIdSet;
        this.changeType = changeType;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        List<Business_Filing__c> filings2Create = new List<Business_Filing__c>();
        if(agentChangesIdSet.size() > 0 && changeType != null){
            for(Agent_Change__c ac: [SELECT Id, Account__c, Mass_Agent_Change__c, Mass_Agent_Change__r.Work_Order__c, Mass_Agent_Change__r.Filing_Date__c, Mass_Agent_Change__r.Effective_Date_Time__c FROM Agent_Change__c WHERE Id IN :agentChangesIdSet]){
                Business_Filing__c bf = new Business_Filing__c();
                bf.isFromMassAgentChange__c = true;
                bf.RecordTypeId = rcId;
                bf.Account__c = ac.Account__c;
                bf.Work_Order__c = ac.Mass_Agent_Change__r.Work_Order__c;
                bf.Filing_Date__c = ac.Mass_Agent_Change__r.Filing_Date__c != null ? ac.Mass_Agent_Change__r.Filing_Date__c : null;
                bf.Effective_Date_Time__c = ac.Mass_Agent_Change__r.Effective_Date_Time__c != null ? ac.Mass_Agent_Change__r.Effective_Date_Time__c : null;
                bf.Effective_Date__c = ac.Mass_Agent_Change__r.Effective_Date_Time__c != null ? (Date.valueOf(ac.Mass_Agent_Change__r.Effective_Date_Time__c)) : null;
                bf.Effective_Time__c = ac.Mass_Agent_Change__r.Effective_Date_Time__c != null ? (ac.Mass_Agent_Change__r.Effective_Date_Time__c).time() : null;
                bf.Status__c = 'Approved';
                if(changeType == 'NameChange') {
                    bf.Type__c = 'Mass Agent Change – Name';
                    bf.Filing_Type__c = 'Change of Agent Name';
                }
                else if(changeType == 'AddressChange'){
                    bf.Type__c = 'Mass Agent Change – Address';
                    bf.Filing_Type__c = 'Agent Address Change';
                }
                filings2Create.add(bf);
            }
            return filings2Create;
        }
        return null;
    }
    
    public void execute(Database.BatchableContext BC, List<Business_Filing__c> listOfRecords){
        if(listOfRecords.size() > 0){
            brs_ExecutionFlowUtility.doNotUpdate = true;
            
            Database.SaveResult[] srList = Database.insert(listOfRecords, false);
            BOS_Utility.ExceptionHandlerForBatches('brs_createMACBusinessFilingsBatch','Business_Filing__c','insert',srList,listOfRecords);
            
            brs_ExecutionFlowUtility.doNotUpdate = false;
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
}