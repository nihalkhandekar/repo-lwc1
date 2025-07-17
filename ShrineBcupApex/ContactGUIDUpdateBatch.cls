public with sharing class ContactGUIDUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
  public Set<ID> existingUser = new Set<ID>();
    
    public  ContactGUIDUpdateBatch(){
     
       
       
    }
    
   
    public Database.QueryLocator start(Database.BatchableContext BC){
        Profile p;
        JIT_SSO_ConfigInfo__mdt SSOConfig;
        if(Schema.SObjectType.JIT_SSO_ConfigInfo__mdt.isAccessible()){
             SSOConfig = [select Id, MasterLabel, Profile__c, Permission_Sets__c from JIT_SSO_ConfigInfo__mdt limit 1]; 
        }
        if(Schema.SObjectType.Profile.isAccessible() && SSOConfig.Profile__c!=null){
            p = [SELECT Id FROM Profile WHERE name =:SSOConfig.Profile__c Limit 1];
        }

        String query = 'Select id, Name, FederationIdentifier, ContactID from User where ProfileID=\''+p.id+'\'';
		if(Test.isRunningTest()){
            query = query + ' Limit 100';
        }
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<User> userList){
Set<ID> ids = new Set<ID>();
Map<String,String> contactmap = new Map<String,String>();

        for(User userdata:userList) {
            ids.add(userdata.contactID);
            contactmap.put(userdata.contactID, userdata.FederationIdentifier);
        }
		
        List<Contact> contactsList  =[Select id,GUID__C from Contact where id in :ids];
        for(Contact contactdata:contactsList) {
            contactdata.GUID__C = contactmap.get(contactdata.id);
            contactdata.No_of_times_called_Id_proofing__c=0;
        }
		if(!contactsList.isEmpty())
        {
			update contactsList;
        }
       
        
        
    }
    public void finish(Database.BatchableContext BC){
       
    }
    
  
   

}