global class BRS_AgentResignationDataCleanUp implements Database.Batchable<sObject> {
    public Set<Id> accIds;  
    public BRS_AgentResignationDataCleanUp(Set<Id> Ids){
        accIds= Ids; //Add Account ids here from the report
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Name,Sub_status__c,Reason_for_Administrative_Dissolution__c,(Select Id,Account__c,Type__c,status__c,Filing_Date__c From Business_Filings__r where status__c = \'Approved\' AND (Type__c =\'Change Agent\' OR Type__c = \'Agent Resignation\' OR Type__c = \'Change of Agent\') ORDER BY Filing_Date__c DESC),(Select Id,Name,Business_ID__c from Agents__r) From Account where Id IN:accIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        
        List<Agent__c> deleteAgentList= new List<Agent__c>();
        List<Account> updateAccounts= new List<Account>();
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        Set<Id> failedAccountIds=new Set<Id>();
        Set<Id> validAccounts = new Set<Id>();
        
        Map<Id,Account> accMap=new Map<Id,Account>(scope);
        for (Account acc:accMap.values()){
            Business_Filing__c oResignation ;
            Business_Filing__c oChange ;
            for (Business_Filing__c oFiling: acc.Business_Filings__r) {
                if (oResignation == null && oFiling.Type__c == 'Agent Resignation') {
                    oResignation = oFiling;
                } else if (oChange == null && (oFiling.Type__c == 'Agent Change' || oFiling.Type__c == 'Change of Agent')) {
                    oChange = oFiling;
                }
            }
            //Date resignationBufferDate = oResignation == null ? Date.today() : oResignation.Filing_Date__c.addDays(30);
            if ((oResignation != null && oChange == null) || oResignation.Filing_Date__c > oChange.Filing_Date__c) {// || oChange.Filing_Date__c > resignationBufferDate
                acc.Sub_status__c='No Agent';
                acc.Reason_for_Administrative_Dissolution__c = 'Failure to appoint or maintain an agent for service';
                updateAccounts.add(acc);	
            }
        }
        
        Database.SaveResult[] accresult=Database.update(updateAccounts, false);
        for(Database.SaveResult res : accresult){
            if (res.isSuccess()) {
                deleteAgentList.addAll(accMap.get(res.getId()).Agents__r);
            }else {
                String error='ERROR: Id:'+res.getId();
                for(Database.Error err : res.getErrors()){
                    error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                }
                Error_Log__c err = BOS_Utility.errorRecordLogger('BRS_AgentResignationDataCleanUp', 'Updating Account', 'Account', res.getId(), BOS_Utility.sSeverity, null, error);
                errorFilingLst.add(err);
                failedAccountIds.add(res.getId());
            }
        }
        System.debug('@@@FAILED: AccountIds'+failedAccountIds);
        System.debug('@@@Delete Agent List:'+deleteAgentList);
        delete deleteAgentList;
        if(!errorFilingLst.IsEmpty()){
            BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }
    }
    global void finish(Database.BatchableContext BC) { }
}