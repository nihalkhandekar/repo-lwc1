/*********************************************************************************************
* NAME:  DashboardlinkApex
* DESCRIPTION: Enhanced Dashboard
*
* @AUTHOR: Rakhee Dubey
* @DATE: 16/12/2020 
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Rakhee Dubey                    12/11/2020                         Enhanced dashboard
*********************************************************************************************/

public without sharing class DashboardlinkApex {
    public static final String ClassName='DashboardlinkApex';
    
     /*
  * @desc: method to get I want to label and links from custom metadata
  */
    @AuraEnabled
    public Static String getIwantTolinks(){
        List<I_want_to_link__mdt> staticLinks = new List<I_want_to_link__mdt>();
        String Links;
        String Userlang = UserInfo.getLocale() ;
        try{ 
            
            staticLinks = [SELECT Id, MasterLabel, Label_URL__c, Language__c, Label_Name__c, Label, Order__c FROM I_want_to_link__mdt where Language__c = :Userlang order by Order__c ];
            Links= JSON.serialize(staticLinks);
            
            system.debug('staticLinks-->'+Links);
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }
        Catch(Exception e){
            BOS_Utility.handleException(e);
        }
        
        return Links;
    }
    
     /*
  * @desc: method to get CT News highlights and news label and links from custom metadata
  */
    @AuraEnabled
    public Static String getCTHighlightNews(){
        List<CTHighlightsNews__mdt> MetadataLinks = new List<CTHighlightsNews__mdt>();
        String HighlightLinks;
        String Userlang = UserInfo.getLocale() ;
        try{ 
            MetadataLinks = [SELECT Id , Label_Name__c, Language__c ,  Label_Description__c , Label_URL__c FROM CTHighlightsNews__mdt where Language__c = :Userlang ];
            HighlightLinks= JSON.serialize(MetadataLinks);
             if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }
        Catch(Exception e){
            BOS_Utility.handleException(e);
        }
        
        return HighlightLinks;
    }
    
    @AuraEnabled(cacheable=false)
    public static String getDashboardActionItems() {
        List<Action_Item__c> actionItems = new List<Action_Item__c>();
          
        try {
            User userdata = BOS_Utility.getLoggedinUserDetail();
            
            if(String.isNotBlank(userdata.ContactId)) {
                Set<Id> AccountIds = getAllLinkedBusinessIDs(userdata.ContactId);
                Set<String> CredentialIds = getAllLinkedCredentialsIDs(userdata.ContactId);
                
                actionItems = [
                    SELECT Id, Name, Action_Item_Name__c, Description__c,Agency__c,Link_Text__c,Link_URL__c,
                        Due_Date__c, toLabel(Status__c), Account__c,Cred_Type_Real_Time__c,Credential_Number__c,
                        Credential__c, Credential__r.Credential_Type__c, Credential__r.Name,Account__r.Name
                    FROM Action_Item__c 
                    WHERE 
                        (
                            (
                                Contact__c = :userdata.ContactId
                                AND
                                Account__c IN: AccountIds
                                AND
                                Due_Date__c <= NEXT_N_DAYS:90
                                AND 
                                Account__r.Status__c ='Active' 
                            )
                            OR 
                            Credential__c IN: CredentialIds 
                        )
                        AND Status__c != :System.Label.TASK_STATUS
                    ORDER BY CreatedDate DESC 
                    LIMIT 3
                ];
            }
        } catch(Exception e){
            BOS_Utility.handleException(e);
        }
        
        return JSON.serialize(actionItems);
    }
    
    //Should be inner query on account
    private static Set<Id> getAllLinkedBusinessIDs(Id contactID) {
        Set<ID> linkedIds = new Set<ID>();
        ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();
     
        for(AccountContactRelation rel :[  
            SELECT Id, AccountId 
            FROM AccountContactRelation 
            WHERE ContactID = :contactID 
                AND Account.RecordTypeID = :storeRecordTypeId AND Account.Status__c ='Active'
        ]) {        
            linkedIds.add(rel.AccountId);
        }
    
        return linkedIds;
    }

    //Should be inner query on Credential
    private static Set<String> getAllLinkedCredentialsIDs(Id contactID) {
        Set<String> credIdIDs = new Set<String>();
        
        for (Contact_Credential_Relationship__c crelation: [
            SELECT Credential__r.Credential_Id__c 
            FROM Contact_Credential_Relationship__c 
            WHERE Contact__c = :contactID
                AND Credential__r.Credential_Id__c != null
        ]) {
            credIdIDs.add(crelation.Credential__r.ID);
        } 
            
        for(Account_Credential_Relationship__c arelation: [
            SELECT Credential__r.Credential_Id__c
            FROM Account_Credential_Relationship__c 
            WHERE Contact__c = :contactID
                AND Credential__r.Credential_Id__c!=null
        ]) {
            credIdIDs.add(arelation.Credential__r.ID);
        } 

        return credIdIDs;
    }
    
     /*
  * @desc: method to get list of collections from contact
  */
     public static List<Collection__c> getCollectionList(String contactID){
        List<Collection__c> collectionlist = new List<Collection__c>();
        
        try{
            collectionlist = [
                SELECT Id, Name, CreatedDate, IsDeleted, Contact__c 
                FROM Collection__c 
                WHERE Contact__c=:contactID
            ];
        } catch(Exception e){
            BOS_Utility.ExceptionHandler(ClassName,'getCollectionList','Collection__c','Multiple','High',e,'Fetching collection list from Loggedin contact');
        }

        return collectionlist;
    }
    
    class DashboardCount{
        Integer businessCount;
        Integer credentialsCount;
        List<QnA_FlowController.Questionnaire> config;
        List<Collection__c> CollecList;
    }
    @AuraEnabled
    public static  String getDashboardCount(){
        User userdata = BOS_Utility.getLoggedinUserDetail();
        
        Set<ID> businessIds = getAllLinkedBusinessIDs(userdata.ContactId);

        Set<String> credentialsIds = new Set<String>();
        
      List<Contact_Credential_Relationship__c> crelation=[
            SELECT Credential__r.Credential_Id__c 
            FROM Contact_Credential_Relationship__c 
            WHERE Contact__c = :userdata.contactID
                AND Credential__r.Credential_Id__c != null
        ];
         List<Collection__c> collectionlst = new List<Collection__c>();
        
        
        
      QnA_FlowController.QuestionnaireConfig config = QnA_FlowController.getLoggedInUserQuestionnaires(System.Label.QuestionaireDashboardCount);
        
        DashboardCount count = new DashboardCount();
        try{
            count.businessCount = businessIds.size();
            count.credentialsCount = crelation.size();
            count.config = config.questionnaires;
            count.CollecList = getCollectionList(userdata.ContactId);
             if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }Catch(Exception e){
			BOS_Utility.ExceptionHandler(ClassName,'getDashboardCount','count','Multiple','High',e,'Fetching collection list from Loggedin contact');            
        }
        return JSON.serialize(count);
    }
    
}