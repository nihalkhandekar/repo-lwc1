/*********************************************************************************************
* NAME:  brs_addAssigneeClass
* DESCRIPTION: This class is use to add assignee
*
* @AUTHOR: 
* @DATE: 
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*
*********************************************************************************************/
public with sharing class brs_addAssigneeClass {

    // Variables for Exception handling
    public static final String className='brs_addAssigneeClass';
    public static final String insertAssinorRelatedEntityMethod = 'insertAssinorRelatedEntity';
    public static final String getSecuredPartiesmethod = 'getSecuredParties'; 
    public static final String relatedInfoObject = 'UCC_Related_Info__c';
    public static final String severity = 'High';
    public static final String deleteMethod = 'DeleteRelatedInfo';
    public static final String getAllAssignorAndAssigneemethod = 'getAllAssignorAndAssignee';
    
	// This method is called to get all the Secured Parties to be added as Assigness
    @AuraEnabled
    public static List<UCC_Related_Info__c> getSecuredParties(String FilingId, String lienType) {
        try {
            List<UCC_Related_Info__c> allRelatedUCCRecords = new List<UCC_Related_Info__c>();
            if(lienType != '' && FilingId != ''){
                allRelatedUCCRecords = [SELECT Id, Name, Individual_First_Name__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c,Status__c,Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c,International_Address__c FROM UCC_Related_Info__c WHERE Filing_Id__c = : FilingId  AND Type__c = :lienType AND Status__c = 'Completed' WITH SECURITY_ENFORCED];
            }
            return allRelatedUCCRecords;
        } catch (exception exe) {
			BOS_Utility.ExceptionHandler(className,getSecuredPartiesmethod,relatedInfoObject,null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
    
   // This method is used to insert all realted entities on click of confirm button
    @AuraEnabled
    public static String insertAssinorRelatedEntity(UCC_Related_Info__c objUCCRelatedMemberInfo,string[] listSecuredIds, String uccFilingId, String lienType) {
        List<UCC_Entity_Info__c> entityList = new List<UCC_Entity_Info__c>();
       
        try {
            if (objUCCRelatedMemberInfo != null) {
                /*if (!Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    return null;
                }
                else if(Schema.sObjectType.UCC_Related_Info__c.isUpdateable() && Schema.sObjectType.UCC_Related_Info__c.isCreateable()){
                    upsert objUCCRelatedMemberInfo;
                }*/
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{objUCCRelatedMemberInfo}, 'upsert');
                if(bAccessCheck){
                    upsert objUCCRelatedMemberInfo;
                }else{
                    return null;
                }
                
            }
            if(listSecuredIds.size() > 0){
                for(String idInst : listSecuredIds){
                    UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                    entityInfoInst.Filing_ID__c = uccFilingId;
                    entityInfoInst.Assignor_ID__c = idInst;
                    entityInfoInst.Secured_Party_ID__c = objUCCRelatedMemberInfo.Id;
                    entityList.add(entityInfoInst);
                }
            }
            if(entityList.size()>0){
                /*if (!Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    return null;
                  }
                else if(Schema.sObjectType.UCC_Entity_Info__c.isUpdateable() && Schema.sObjectType.UCC_Entity_Info__c.isCreateable()){
                    upsert entityList;
                }*/
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(entityList, 'upsert');
                if(bAccessCheck1){
                    upsert entityList;
                }else{
                    return null;
                }
            }
            return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe){
			BOS_Utility.ExceptionHandler(className,insertAssinorRelatedEntityMethod,relatedInfoObject,null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    // This method is used to insert all realted entities on click of next button
    @AuraEnabled
    public static String insertOnNextButton(AssignorWrapper[] objUCCRelatedMemberInfo, String uccFilingId, String lienType) {
        try {
            List<UCC_Entity_Info__c> entityList = new List<UCC_Entity_Info__c>();
            for(AssignorWrapper wrapInst : objUCCRelatedMemberInfo){
                UCC_Related_Info__c uccAssignor = wrapinst.uccAssignor;
                List<UCC_Related_Info__c> uccAssignees = wrapinst.uccAssignees;
                for(UCC_Related_Info__c uccInst : uccAssignees){
                    UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                    entityInfoInst.Filing_ID__c = uccFilingId;
                    entityInfoInst.Assignor_ID__c =uccInst.Id;
                    entityInfoInst.Secured_Party_ID__c = wrapInst.uccAssignor.Id;
                    entityList.add(entityInfoInst);
                }
            }
            if(entityList.size()>0){
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isUpdateable()){
                    return null;
                  }
                else if(Schema.sObjectType.UCC_Entity_Info__c.isUpdateable() && Schema.sObjectType.UCC_Entity_Info__c.isCreateable()){
                    upsert entityList;
                }*/
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(entityList, 'upsert');
                if(bAccessCheck){
                    upsert entityList;
                }else{
                    return null;
                }
            }
            return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe) {
			BOS_Utility.ExceptionHandler(className,'insertOnNextButton',relatedInfoObject,null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
    
    // This method is being used to get all Assignors and related Assignees to be shown on the card
    @AuraEnabled
    public static String getAllAssignorAndAssignee(String FilingId, String lienType){
        try {
            List<UCC_Related_Info__c> allRelatedUCCRecords = new List<UCC_Related_Info__c>();
            allRelatedUCCRecords = [SELECT Id, Name,RecordTypeId,RecordType.DeveloperName,Status__c, Individual_First_Name__c, 
										Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, 
										Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c,
										International_Address__c 
									FROM UCC_Related_Info__c 
									WHERE Filing_Id__c =: FilingId  
									AND Type__c = :lienType
                                    WITH SECURITY_ENFORCED];
            List<UCC_Entity_Info__c> listAssigneeInfo = new List<UCC_Entity_Info__c>([Select id,Assignor_ID__c,
											Assignor_ID__r.International_Address__c,Assignor_ID__r.Status__c,
											Assignor_ID__r.Individual_First_Name__c,Assignor_ID__r.Individual_SurName__c,
											Assignor_ID__r.Org_Name__c,Assignor_ID__r.RecordTypeId,
											Assignor_ID__r.RecordType.DeveloperName,
											Secured_Party_ID__r.RecordTypeId,Secured_Party_ID__r.RecordType.DeveloperName,
											Assignor_ID__r.City__c,Assignor_ID__r.Street__c,Assignor_ID__r.Country__c,
											Assignor_ID__r.Zip_Code__c,Assignor_ID__r.State__c,Assignor_ID__r.Suffix__c,
											Assignor_ID__r.Individual_Middle_Name__c,Secured_Party_ID__r.Org_Name__c,
											Secured_Party_ID__r.Individual_First_Name__c,Secured_Party_ID__r.Suffix__c,
											Secured_Party_ID__r.Individual_Middle_Name__c,Secured_Party_ID__r.Individual_SurName__c,
											Filing_ID__c,Secured_Party_ID__c,Secured_Party_ID__r.City__c,Secured_Party_ID__r.Street__c,
											Secured_Party_ID__r.Country__c,Secured_Party_ID__r.Zip_Code__c,Secured_Party_ID__r.State__c,
											Secured_Party_ID__r.Status__c,Secured_Party_ID__r.International_Address__c,
											Filing_ID__r.Status__c
										FROM UCC_Entity_Info__c 
										WHERE Filing_ID__c =: FilingId 
										AND Filing_ID__r.Status__c='In-Progress' 
										AND CreatedBy.Id =: UserInfo.getUserId()
                                        WITH SECURITY_ENFORCED]);
            List<AssignorWrapper> assignorWrapList = new  List<AssignorWrapper>();
            Map<Id,Id> mapAssignorIdAssignee = new Map<Id,Id>();
            Map<Id,Integer> mapIndexAssignor = new  Map<Id,Integer>();
			
			for(UCC_Entity_Info__c uccinfoInst : listAssigneeInfo){
				UCC_Related_Info__c assignee = new UCC_Related_Info__c();
					assignee.Org_Name__c = uccinfoInst.Secured_Party_ID__r.Org_Name__c;
					assignee.RecordTypeId =  uccinfoInst.Secured_Party_ID__r.RecordTypeId;
					assignee.Individual_First_Name__c = uccinfoInst.Secured_Party_ID__r.Individual_First_Name__c;
					assignee.Individual_Middle_Name__c = uccinfoInst.Secured_Party_ID__r.Individual_Middle_Name__c;
					assignee.Individual_SurName__c = uccinfoInst.Secured_Party_ID__r.Individual_SurName__c;
					assignee.Suffix__c = uccinfoInst.Secured_Party_ID__r.Suffix__c;
					assignee.RecordTypeId =  uccinfoInst.Secured_Party_ID__r.RecordTypeId;
					assignee.Street__c = uccinfoInst.Secured_Party_ID__r.Street__c;
					assignee.Zip_Code__c = uccinfoInst.Secured_Party_ID__r.Zip_Code__c;
					assignee.Country__c = uccinfoInst.Secured_Party_ID__r.Country__c;
					assignee.City__c = uccinfoInst.Secured_Party_ID__r.City__c;
					assignee.State__c = uccinfoInst.Secured_Party_ID__r.State__c;
					assignee.Id = uccinfoInst.Secured_Party_ID__r.Id;
					assignee.International_Address__c = uccinfoInst.Secured_Party_ID__r.International_Address__c;
					
				UCC_Related_Info__c assignor = new UCC_Related_Info__c();
					assignor.Org_Name__c =  uccinfoInst.Assignor_ID__r.Org_Name__c;
					assignor.RecordTypeId =  uccinfoInst.Assignor_ID__r.RecordTypeId;
					assignor.RecordTypeId =  uccinfoInst.Assignor_ID__r.RecordTypeId;
					assignor.Individual_First_Name__c = uccinfoInst.Assignor_ID__r.Individual_First_Name__c;
					assignor.Individual_Middle_Name__c = uccinfoInst.Assignor_ID__r.Individual_Middle_Name__c;
					assignor.Suffix__c = uccinfoInst.Assignor_ID__r.Suffix__c;
					assignor.Individual_SurName__c = uccinfoInst.Assignor_ID__r.Individual_SurName__c;
					assignor.Street__c = uccinfoInst.Assignor_ID__r.Street__c;
					assignor.Zip_Code__c = uccinfoInst.Assignor_ID__r.Zip_Code__c;
					assignor.Country__c = uccinfoInst.Assignor_ID__r.Country__c;
					assignor.City__c = uccinfoInst.Assignor_ID__r.City__c;
					assignor.State__c = uccinfoInst.Assignor_ID__r.State__c;
					assignor.Id = uccinfoInst.Assignor_ID__r.Id;
					assignor.International_Address__c = uccinfoInst.Assignor_ID__r.International_Address__c;
					
				AssignorWrapper wrapInst = new AssignorWrapper();
				wrapInst.uccAssignees = new List<UCC_Related_Info__c>{assignee};
				wrapInst.uccAssignor = assignor;
				
				assignorWrapList.add(wrapInst);
			}
			return JSON.serialize(assignorWrapList);
        } catch (Exception exe) {BOS_Utility.ExceptionHandler(className,getAllAssignorAndAssigneemethod,'',null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    } 

    // This method is used to delete Assignor and related entities created for the Assignor
    @AuraEnabled
    public static string DeleteRelatedInfo(String AssignorID,string uccFilingId,string lienType){
        try {
            UCC_Related_Info__c relatedInfo = [select id from UCC_Related_Info__c where id =:AssignorID WITH SECURITY_ENFORCED];
            List<UCC_Entity_Info__c> listUccEntity = new List<UCC_Entity_Info__c>([select id from UCC_Entity_Info__c where Secured_Party_ID__c =: AssignorID WITH SECURITY_ENFORCED]);
            if(listUccEntity.size()>0){
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isAccessible()){
                    return null;
                  }
                else if(Schema.sObjectType.UCC_Entity_Info__c.isDeletable()){
                    delete listUccEntity;
                }*/
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(listUccEntity, 'delete');
                if(bAccessCheck){
                    delete listUccEntity;
                }else{
                    return null;
                }
            }
            if(relatedInfo!=null){
                /*if (!Schema.sObjectType.UCC_Related_Info__c.isAccessible()){
                    return null;
                  }
                else if(Schema.sObjectType.UCC_Related_Info__c.isDeletable()){
                    delete relatedInfo;
                }*/
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{relatedInfo}, 'delete');
                if(bAccessCheck1){
                    delete relatedInfo;
                }else{
                    return null;
                }
            }
        return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler(className,deleteMethod,'',null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    public without sharing class AssignorWrapper{
        @AuraEnabled public  UCC_Related_Info__c uccAssignor{get;set;}
        @AuraEnabled public  List<UCC_Related_Info__c> uccAssignees{get;set;}
        public AssignorWrapper(){
            uccAssignees = new List<UCC_Related_Info__c>();
        }
    }
    
}