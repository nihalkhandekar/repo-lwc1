/********************************************************************************************
* DESCRIPTION: Batch job to mass update Agents list coming from UI
*
* MODIFICATION LOG:
* DEVELOPER                      DATE                       DESCRIPTION
* -------------------------------------------------------------------------------------------
* Aparna S                     09/15/2021               Created first version
* Aparna S                     10/04/2021               Modified from Queable to Batch
*********************************************************************************************/
public class brs_MassAgentQueuedUpdates implements Database.Batchable<sObject> {
    private Set<Id> agentIds2UpdateSet;
    private Set<Id> agentChangesIdSet;
    private Map<String,String> fieldChangeMap;
    private String changeType;    
    private String tempAgentBusName;
    
    public brs_MassAgentQueuedUpdates(Set<Id> agentIds2UpdateSet, Map<String,String> fieldChangeMap, Set<Id> agentChangesIdSet, String changeType, String tempAgentBusName) {
        this.agentIds2UpdateSet = agentIds2UpdateSet;
        this.fieldChangeMap = fieldChangeMap;
        this.agentChangesIdSet = agentChangesIdSet;
        this.changeType = changeType;
        this.tempAgentBusName = tempAgentBusName;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        List<Agent__c> recordsToUpdate = new List<Agent__c>();
        String indexedAgentBusName = '';
        if(agentIds2UpdateSet.size() > 0 && changeType != null){
            
            //Added Agent bypassed code for agent name from Agent trigger
            if(changeType == 'NameChange'){
                List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
                List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
                
                String searchString = tempAgentBusName != null && String.isNotBlank(tempAgentBusName) ?  ' ' + (tempAgentBusName).normalizeSpace() + ' ' : '';
                
                for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                    if((searchString != '' || searchString != null) && noiseWrd.Label!='.' && (searchString.containsIgnoreCase(noiseWrd.Label))){
                        if(!(noiseWrd.Label).isAlpha()){
                            searchString = ' ' + (((searchString).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                        else{
                            searchString = ' ' + (((searchString).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                    }
                }
                for(brs_SortLegalDesignators desgn : listOfDesignators) {                    
                    if((' '+searchString+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        Integer matchCount = (searchString.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                        if(matchCount >= 1){
                            for(Integer i=0; i<matchCount; i++){
                                searchString= ' ' + (((searchString).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                        }
                    }
                } 
                searchString = Accents.removeDiacritics(searchString);
                searchString = ((searchString).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
                indexedAgentBusName = searchString;
            }
            
            for(Agent__c agent: [SELECT id, Name__c, Type__c, Agent_Name_Indexed__c, isFromMassAgentChange__c,
                                 Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c,
                                 Business_City__c, Business_State__c, Business_Zip_Code__c, Business_Country__c,
                                 Business_InternationalAddress__c,                                    
                                 Mailing_Street_Address_1__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,
                                 Mailing_City__c, Mailing_State__c, Mailing_Zip_Code__c, Mailing_Country__c,
                                 Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c,
                                 Residence_City__c, Residence_State__c, Residence_Zip_Code__c, Residence_Country__c                                    
                                 FROM Agent__c WHERE Id IN :agentIds2UpdateSet]){
           		if(!fieldChangeMap.isEmpty()){
                	if(fieldChangeMap.containsKey('Business_Name__c')){
                    	agent.Business_Name__c = fieldChangeMap.get('Business_Name__c');
                        if(changeType == 'NameChange' && String.isNotBlank(agent.Type__c) && agent.Type__c.equalsIgnoreCase(System.Label.SignatoryType_Business)){
                        	if(String.isNotBlank(agent.Business_Name__c) ){
                                agent.Name__c = agent.Business_Name__c;
                                agent.Agent_Name_Indexed__c = indexedAgentBusName;
                            }
                        }
                    }
                    if(fieldChangeMap.containsKey('Business_Street_Address_1__c')){
                        agent.Business_Street_Address_1__c = fieldChangeMap.get('Business_Street_Address_1__c');
                    }
                    if(fieldChangeMap.containsKey('Business_Street_Address_2__c')){
                        agent.Business_Street_Address_2__c = fieldChangeMap.get('Business_Street_Address_2__c');
                    }
                    if(fieldChangeMap.containsKey('Business_Street_Address_3__c')){
                        agent.Business_Street_Address_3__c = fieldChangeMap.get('Business_Street_Address_3__c');
                    }
                    if(fieldChangeMap.containsKey('Business_City__c')){
                        agent.Business_City__c = fieldChangeMap.get('Business_City__c');
                    }
                    if(fieldChangeMap.containsKey('Business_State__c')){
                        agent.Business_State__c = fieldChangeMap.get('Business_State__c');
                    }
                    if(fieldChangeMap.containsKey('Business_Zip_Code__c')){
                        agent.Business_Zip_Code__c = fieldChangeMap.get('Business_Zip_Code__c');
                    }
                    if(fieldChangeMap.containsKey('Business_Country__c')){
                        agent.Business_Country__c = fieldChangeMap.get('Business_Country__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_Street_Address_1__c')){
                        agent.Mailing_Street_Address_1__c = fieldChangeMap.get('Mailing_Street_Address_1__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_Street_Address_2__c')){
                        agent.Mailing_Street_Address_2__c = fieldChangeMap.get('Mailing_Street_Address_2__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_Street_Address_3__c')){
                        agent.Mailing_Street_Address_3__c = fieldChangeMap.get('Mailing_Street_Address_3__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_City__c')){
                        agent.Mailing_City__c = fieldChangeMap.get('Mailing_City__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_State__c')){
                        agent.Mailing_State__c = fieldChangeMap.get('Mailing_State__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_Zip_Code__c')){
                        agent.Mailing_Zip_Code__c = fieldChangeMap.get('Mailing_Zip_Code__c');
                    }
                    if(fieldChangeMap.containsKey('Mailing_Country__c')){
                        agent.Mailing_Country__c = fieldChangeMap.get('Mailing_Country__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_Street_Address_1__c')){
                        agent.Residence_Street_Address_1__c = fieldChangeMap.get('Residence_Street_Address_1__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_Street_Address_2__c')){
                        agent.Residence_Street_Address_2__c = fieldChangeMap.get('Residence_Street_Address_2__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_Street_Address_3__c')){
                        agent.Residence_Street_Address_3__c = fieldChangeMap.get('Residence_Street_Address_3__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_City__c')){
                        agent.Residence_City__c = fieldChangeMap.get('Residence_City__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_State__c')){
                        agent.Residence_State__c = fieldChangeMap.get('Residence_State__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_Zip_Code__c')){
                        agent.Residence_Zip_Code__c = fieldChangeMap.get('Residence_Zip_Code__c');
                    }
                    if(fieldChangeMap.containsKey('Residence_Country__c')){
                        agent.Residence_Country__c = fieldChangeMap.get('Residence_Country__c');
                    }
                    agent.isFromMassAgentChange__c = true;
                }
                recordsToUpdate.add(agent);
            }
            return recordsToUpdate;
        }        
        return null;
    }
    
    public void execute(Database.BatchableContext BC, List<Agent__c> listOfRecords) {
        if(listOfRecords.size() > 0){
            brs_ExecutionFlowUtility.doNotUpdate = true;
            
            Database.SaveResult[] srList = Database.update(listOfRecords, false);
            BOS_Utility.ExceptionHandlerForBatches('brs_MassAgentQueuedUpdates','Agent__c','update',srList,listOfRecords);
            
            brs_ExecutionFlowUtility.doNotUpdate = false;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        brs_createMACBusinessFilingsBatch secondBatch = new brs_createMACBusinessFilingsBatch(agentChangesIdSet, changeType);
        Database.executeBatch(secondBatch);
    }
}