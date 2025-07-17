/* DESCRIPTION: This class is used to get UCC related info and UCC Entity info and perform DML operations on them.
*
* @AUTHOR: Sushri Sarita Nayak
* @DATE:   2020-12-05
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sushri Sarita Nayak                  2020-12-05                   Created the first version
*
*********************************************************************************************/

public with sharing class brs_addAssignorClass {
    
    // Variables for Exception handling
    public static final String className='brs_addAssignorClass';
    public static final String insertAssinorRelatedEntityMethod = 'insertAssinorRelatedEntity';
    public static final String insertAssinorRelatedEntityBulk = 'insertAssinorRelatedEntityBulk';
    public static final String getSecuredPartiesmethod = 'getSecuredParties'; 
    public static final String relatedInfoObject = 'UCC_Related_Info__c';
    public static final String severity = 'High';
    public static final String deleteMethod = 'DeleteRelatedInfo';
    public static final String getAllAssignorAndAssigneemethod = 'getAllAssignorAndAssignee';
    
    // This method is called to get all the Secured Parties to be added as Assigness
    @AuraEnabled
    public static List<UCC_Related_Info__c> getSecuredParties(String FilingId, String lienType, Boolean isAssignee) {
        try {
            List<UCC_Related_Info__c> allRelatedUCCRecords = new List<UCC_Related_Info__c>();
            if(lienType != '' && FilingId != ''){
				string statusvalue = isAssignee ? System.label.BRS_UCC_StatusInProgress : null;
                //Added as Part of BRS-2491
                allRelatedUCCRecords = [SELECT Id, Name, Individual_First_Name__c, Unit__c,RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c,International_Address__c FROM UCC_Related_Info__c WHERE Filing_Id__c = : FilingId  AND Type__c = :lienType and Status__c !=: statusvalue WITH SECURITY_ENFORCED];
            }
            return allRelatedUCCRecords;
        } catch (exception exe) {BOS_Utility.ExceptionHandler(className,getSecuredPartiesmethod,relatedInfoObject,null,severity,exe,null);
                                 throw new AuraHandledException(exe.getMessage());
                                }
    }
    
    // This method is used to insert all realted entities on click of confirm button
    @AuraEnabled
    public static String insertAssinorRelatedEntity(UCC_Related_Info__c objUCCRelatedMemberInfo,string[] listSecuredIds, String uccFilingId, String lienType , String[] removedIds) {
        List<UCC_Entity_Info__c> entityList = new List<UCC_Entity_Info__c>();
        List<UCC_Entity_Info__c> entityListqueryStr = new List<UCC_Entity_Info__c>([Select Filing_ID__c,Assignor_ID__c,Secured_Party_ID__c 
                                                                                    FROM UCC_Entity_Info__c
                                                                                    WHERE Filing_ID__c =: uccFilingId
                                                                                    WITH SECURITY_ENFORCED]);
        List<UCC_Entity_Info__c> updateEntityList = new List<UCC_Entity_Info__c>();
        map<Id,List<String>> mapIndexAssignor = new map<Id,List<String>>();
        try {
            if (objUCCRelatedMemberInfo != null) {
                /*if (!Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    return null;
                }
                else if(Schema.sObjectType.UCC_Related_Info__c.isCreateable() && Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    Upsert objUCCRelatedMemberInfo;
                }*/
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{objUCCRelatedMemberInfo}, 'Upsert');
                if(bAccessCheck1){
                    Upsert objUCCRelatedMemberInfo;
                }else{
                    return null;
                }
                
            }
            
            for(UCC_Entity_Info__c enInst : entityListqueryStr){
                if(enInst.Assignor_ID__c == objUCCRelatedMemberInfo.Id  && lienType == 'Assignor'){
                    if(mapIndexAssignor.containsKey(enInst.Assignor_ID__c)) {
                        List<String> assigneeList = mapIndexAssignor.get(enInst.Assignor_ID__c);
                        assigneeList.add(enInst.Secured_Party_ID__c);
                        mapIndexAssignor.put(enInst.Assignor_ID__c,assigneeList);
                        
                    }
                    else{
                        mapIndexAssignor.put(enInst.Assignor_ID__c, new List<String> {enInst.Secured_Party_ID__c }); 
                    }
                }
                
                if(enInst.Secured_Party_ID__c == objUCCRelatedMemberInfo.Id && lienType != 'Assignor'){
                    if(mapIndexAssignor.containsKey(enInst.Secured_Party_ID__c)) {
                        List<String> assigneeList = mapIndexAssignor.get(enInst.Secured_Party_ID__c);
                        assigneeList.add(enInst.Assignor_ID__c);
                        mapIndexAssignor.put(enInst.Secured_Party_ID__c,assigneeList);
                        
                    }
                    else{
                        mapIndexAssignor.put(enInst.Secured_Party_ID__c, new List<String> {enInst.Assignor_ID__c }); 
                    }
                }
            }
            if(listSecuredIds.size() > 0){
                for(String idInst : listSecuredIds){
                    if(mapIndexAssignor.values().size() > 0){
                        for(List<String> assigneeList : mapIndexAssignor.values()){
                            if(!assigneeList.contains(idInst)){
                                UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                                entityInfoInst.Filing_ID__c = uccFilingId;
                                entityInfoInst.Assignor_ID__c = lienType == 'Assignor' ? objUCCRelatedMemberInfo.Id : idInst;
                                entityInfoInst.Secured_Party_ID__c = lienType == 'Assignor' ? idInst : objUCCRelatedMemberInfo.Id; 
                                entityList.add(entityInfoInst);
                            }
                        }
                    }
                    else{
                        UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                        entityInfoInst.Filing_ID__c = uccFilingId;
                        entityInfoInst.Assignor_ID__c = lienType == 'Assignor' ? objUCCRelatedMemberInfo.Id : idInst;
                        entityInfoInst.Secured_Party_ID__c = lienType == 'Assignor' ? idInst : objUCCRelatedMemberInfo.Id;
                        entityList.add(entityInfoInst);
                    }
                    
                }
            }
            List<UCC_Entity_Info__c> removeList = new List<UCC_Entity_Info__c>();
            
            if(removedIds.size() >0 ){
                string deleteId = objUCCRelatedMemberInfo.Id;
                String queryStr = 'SELECT id,Assignor_ID__c,Filing_ID__c,Secured_Party_ID__c FROM UCC_Entity_Info__c ';
                queryStr += lienType == 'Assignor' ? 
                                'WHERE Secured_Party_ID__c IN: removedIds AND Assignor_ID__c =: deleteId WITH SECURITY_ENFORCED': 
                                    'WHERE Assignor_ID__c IN: removedIds AND Secured_Party_ID__c =: deleteId WITH SECURITY_ENFORCED';
                removeList = Database.query(queryStr);
                /*if(Schema.sObjectType.UCC_Entity_Info__c.isDeletable()){
                    delete removeList;
                }*/
                Boolean bAccessCheck2 = BRS_SecurityUtility.checkDMLAccess(removeList, 'delete');
                if(bAccessCheck2){
                    delete removeList;
                }
            }
            
            if(entityList.size()>0){
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isAccessible()){
                    return null;
                }
                else if(Schema.sObjectType.UCC_Entity_Info__c.isCreateable()){
                    insert entityList;
                }*/
                
                Boolean bAccessCheck3 = BRS_SecurityUtility.checkDMLAccess(entityList, 'insert');
                if(bAccessCheck3){
                    insert entityList;
                }else{
                    return null;
                }
            }
            return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler(className,insertAssinorRelatedEntityMethod,relatedInfoObject,null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
            
        }
    }
    
    // This method is used to insert all realted entities on click of next button
    @AuraEnabled
    public static String insertOnNextButton(String objUCCRelatedMemberInfo, String uccFilingId, String lienType) {
        try {
            List<assignorWrapper> objUCCRelatedMemberInfoList = (List<assignorWrapper>)System.JSON.deserialize(objUCCRelatedMemberInfo, List<assignorWrapper>.class);
            List<UCC_Related_Info__c> assignorList = new List<UCC_Related_Info__c>();
            Map<Integer,List<UCC_Entity_Info__c>> IndexAssignorRelatedAssigneeMap = new  Map<Integer,List<UCC_Entity_Info__c>>();
            for(Integer i = 0; i<objUCCRelatedMemberInfoList.size(); i++){
                assignorList.add(objUCCRelatedMemberInfoList[i].uccAssignor);
                List<UCC_Related_Info__c> uccAssignees = objUCCRelatedMemberInfoList[i].uccAssignees;
                List<UCC_Entity_Info__c> entityList = new List<UCC_Entity_Info__c>();
                for(UCC_Related_Info__c uccInst : uccAssignees){
                    UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                    entityInfoInst.Filing_ID__c = uccFilingId;
                    entityInfoInst.Assignor_ID__c = objUCCRelatedMemberInfoList[i].uccAssignor?.Id;
                    entityInfoInst.Secured_Party_ID__c = uccInst.Id;
                    entityList.add(entityInfoInst);
                }
                IndexAssignorRelatedAssigneeMap.put(i,entityList);
            }
            if(assignorList.size() > 0 ){
                /*if(!Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    return null;
                }
                else if(Schema.sObjectType.UCC_Related_Info__c.isCreateable() && Schema.sObjectType.UCC_Related_Info__c.isUpdateable()){
                    upsert assignorList; 
                }*/
                
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(assignorList, 'upsert');
				if(bAccessCheck){
                     upsert assignorList; 
                }else{
                    return null;
                }
            }
            List<UCC_Entity_Info__c> entityInfoNewList = new List<UCC_Entity_Info__c>();
            for(Integer keyInst : IndexAssignorRelatedAssigneeMap.keyset()){
                for(UCC_Entity_Info__c entityInfoInst : IndexAssignorRelatedAssigneeMap.get(keyInst)){
                    entityInfoInst.Assignor_ID__c = assignorList[keyInst].Id;
                    entityInfoNewList.add(entityInfoInst);
                }
            }
            if(entityInfoNewList.size()>0){
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isUpdateable()){
                    return null;
                }*/
                
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(entityInfoNewList, 'upsert');
				if(bAccessCheck1){
                	upsert entityInfoNewList;
                }else{
                    return null;
                }
            }
            return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe) {BOS_Utility.ExceptionHandler(className,'insertOnNextButton',relatedInfoObject,null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
    
    // This method is being used to get all Assignors and related Assignees to be shown on the card
    @AuraEnabled
    public static String getAllAssignorAndAssignee(String FilingId, String lienType){
        try {
            List<UCC_Related_Info__c> allRelatedUCCRecords = new List<UCC_Related_Info__c>();
            //Added as Part of BRS-2491
            allRelatedUCCRecords = [SELECT Id, Name,RecordTypeId,RecordType.DeveloperName, Individual_First_Name__c, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c,International_Address__c FROM UCC_Related_Info__c WHERE Filing_Id__c =: FilingId  AND Type__c = :lienType WITH SECURITY_ENFORCED];  
            List<UCC_Entity_Info__c> listAssigneeInfo = new List<UCC_Entity_Info__c>([Select id,Assignor_ID__c,Assignor_ID__r.Individual_First_Name__c,Assignor_ID__r.Individual_SurName__c,Assignor_ID__r.Org_Name__c,Assignor_ID__r.RecordTypeId,Assignor_ID__r.RecordType.DeveloperName,Secured_Party_ID__r.RecordTypeId,Secured_Party_ID__r.RecordType.DeveloperName,Assignor_ID__r.International_Address__c,
                                                                                      Assignor_ID__r.City__c,Assignor_ID__r.Street__c,Assignor_ID__r.Unit__c,Assignor_ID__r.Country__c,Assignor_ID__r.Zip_Code__c,Assignor_ID__r.State__c,Assignor_ID__r.Suffix__c,Assignor_ID__r.Individual_Middle_Name__c,Secured_Party_ID__r.Org_Name__c,Secured_Party_ID__r.Individual_First_Name__c,Secured_Party_ID__r.Suffix__c,Secured_Party_ID__r.Individual_Middle_Name__c,Secured_Party_ID__r.Individual_SurName__c,Filing_ID__c,Secured_Party_ID__r.City__c,Secured_Party_ID__r.Street__c,
                                            Secured_Party_ID__r.Country__c,Secured_Party_ID__r.Zip_Code__c,Secured_Party_ID__r.State__c,Secured_Party_ID__r.Unit__c,
                                            Secured_Party_ID__r.Status__c,
                                                                                      Secured_Party_ID__r.International_Address__c,
                                                                                      Secured_Party_ID__c from UCC_Entity_Info__c where Filing_ID__c =: FilingId
                                                                                      WITH SECURITY_ENFORCED]);
            List<assignorWrapper> assignorWrapList = new  List<assignorWrapper>();
            Map<Id,Id> mapAssignorIdAssignee = new Map<Id,Id>();
            Map<Id,Integer> mapIndexAssignor = new  Map<Id,Integer>();
            if(lienType == 'Assignor'){
                for(UCC_Entity_Info__c uccinfoInst : listAssigneeInfo){
                    assignorWrapper wrapInst;
                    if(mapIndexAssignor.containskey(uccinfoInst.Assignor_ID__c)){
                        wrapInst = assignorWrapList[mapIndexAssignor.get(uccinfoInst.Assignor_ID__c)];
                    }
                    else{
                        wrapInst = new assignorWrapper();
                        mapIndexAssignor.put(uccinfoInst.Assignor_ID__c,assignorWrapList.size());
                        assignorWrapList.add(wrapInst);
                    }
                    UCC_Related_Info__c assignorInst = new UCC_Related_Info__c();
                    //Added as Part of BRS-2491
                    if(uccinfoInst.Assignor_ID__r.RecordTypeId ==  Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType())){
                        assignorInst.Org_Name__c =  uccinfoInst.Assignor_ID__r.Org_Name__c;
                        //Added as Part of BRS-2491
                       assignorInst.RecordTypeId =  uccinfoInst.Assignor_ID__r.RecordTypeId;
                    }
                    else{
                        //Added as Part of BRS-2491
                        assignorInst.RecordTypeId =  uccinfoInst.Assignor_ID__r.RecordTypeId;
                        assignorInst.Individual_First_Name__c = uccinfoInst.Assignor_ID__r.Individual_First_Name__c;
                        assignorInst.Individual_Middle_Name__c = uccinfoInst.Assignor_ID__r.Individual_Middle_Name__c;
                        assignorInst.Individual_SurName__c = uccinfoInst.Assignor_ID__r.Individual_SurName__c;
                        assignorInst.Suffix__c = uccinfoInst.Assignor_ID__r.Suffix__c;

                    }
                    assignorInst.Street__c = uccinfoInst.Assignor_ID__r.Street__c;
                    assignorInst.Zip_Code__c = uccinfoInst.Assignor_ID__r.Zip_Code__c;
                    assignorInst.Country__c = uccinfoInst.Assignor_ID__r.Country__c;
                    assignorInst.City__c = uccinfoInst.Assignor_ID__r.City__c;
                    assignorInst.Unit__c = uccinfoInst.Assignor_ID__r.Unit__c;
                    assignorInst.State__c = uccinfoInst.Assignor_ID__r.State__c;
                    assignorInst.Id = uccinfoInst.Assignor_ID__r.Id;
                    assignorInst.International_Address__c = uccinfoInst.Assignor_ID__r.International_Address__c; // added by POoja
                    
                    mapAssignorIdAssignee.put(assignorInst.id,uccinfoInst.Secured_Party_ID__c);
                    UCC_Related_Info__c uccInst = new UCC_Related_Info__c();
                    List<UCC_Related_Info__c> assigneeList = wrapInst.uccAssignees;
                    if(mapAssignorIdAssignee.get(uccinfoInst.Assignor_ID__c) == uccinfoInst.Secured_Party_ID__c){
                        //Added as Part of BRS-2491
                        if(uccinfoInst.Secured_Party_ID__r.RecordTypeId == Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType())){
                        
                            uccInst.Org_Name__c = uccinfoInst.Secured_Party_ID__r.Org_Name__c;
                            //Added as Part of BRS-2491
                           
                           uccInst.RecordTypeId =  uccinfoInst.Secured_Party_ID__r.RecordTypeId;
                        }
                        else{
                            uccInst.Individual_First_Name__c = uccinfoInst.Secured_Party_ID__r.Individual_First_Name__c;
                            uccInst.Individual_Middle_Name__c = uccinfoInst.Secured_Party_ID__r.Individual_Middle_Name__c;
                            uccInst.Individual_SurName__c = uccinfoInst.Secured_Party_ID__r.Individual_SurName__c;
                            uccInst.Suffix__c = uccinfoInst.Secured_Party_ID__r.Suffix__c;

                            //Added as Part of BRS-2491
                            uccInst.RecordTypeId =  uccinfoInst.Secured_Party_ID__r.RecordTypeId;
                        }
                        uccInst.International_Address__c = uccinfoInst.Secured_Party_ID__r.International_Address__c; // added by POoja
                    
                    }
                    uccInst.Id = uccinfoInst.Secured_Party_ID__r.Id;
                    assigneeList.add(uccInst);
                    wrapInst.uccAssignor = assignorInst;
                    wrapInst.uccAssignees = assigneeList;
                }
            }else{
                assignorWrapList = getAssignee(listAssigneeInfo, assignorWrapList);     
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
            UCC_Related_Info__c relatedInfo = new UCC_Related_Info__c(Id = AssignorID);
            List<UCC_Entity_Info__c> listUccEntity = new List<UCC_Entity_Info__c>();
            string queryStr = 'select id FROM UCC_Entity_Info__c ';
            if(lienType == 'Assignor'){
                queryStr += ' WHERE Assignor_ID__c =: AssignorID WITH SECURITY_ENFORCED';
            }else{
                queryStr += ' WHERE Secured_Party_ID__c =: AssignorID WITH SECURITY_ENFORCED';
            }
            
            listUccEntity = Database.query(queryStr);
            
            if(listUccEntity.size()>0){
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isAccessible()){
                    return null;
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
    
    public without sharing class assignorWrapper{
        /** for Assignee UCC3  -- passing assignee here **/
        @AuraEnabled public  UCC_Related_Info__c uccAssignor{get;set;}
        /** for Assignee UCC3  -- passing assignors here **/
        @AuraEnabled public  List<UCC_Related_Info__c> uccAssignees{get;set;}
        public assignorWrapper(){
            uccAssignees = new List<UCC_Related_Info__c>();
        }
    }

    public static List<assignorWrapper> getAssignee(List<UCC_Entity_Info__c> listAssigneeInfo, List<assignorWrapper> assignorWrapList){
        Map<Id,Set<Id>> assigneeAssignorsMap = new Map<Id,Set<Id>>();
        Map<Id,UCC_Entity_Info__c> assigneesMap = new Map<Id,UCC_Entity_Info__c>();
        Map<Id,UCC_Entity_Info__c> assignorMap = new Map<Id,UCC_Entity_Info__c>();
        for(UCC_Entity_Info__c uccinfoInst : listAssigneeInfo){
            
            if(assigneeAssignorsMap.containskey(uccinfoInst.Secured_Party_ID__c)){
                assigneeAssignorsMap.get(uccinfoInst.Secured_Party_ID__c).add(uccinfoInst.Assignor_ID__c);
            }else{
                assigneeAssignorsMap.put(uccinfoInst.Secured_Party_ID__c, new Set<Id>{uccinfoInst.Assignor_ID__c});
                assigneesMap.put(uccinfoInst.Secured_Party_ID__c,uccinfoInst );
            }
            assignorMap.put(uccinfoInst.Assignor_ID__c,uccinfoInst );
            
        }
        
        for(Id assigneeId : assigneeAssignorsMap.keySet()){
            
            AssignorWrapper wrapInst = new AssignorWrapper();
            
            if(assigneesMap.containskey(assigneeId)){
                UCC_Entity_Info__c uccinfoInst = assigneesMap.get(assigneeId);
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
                assignee.Unit__c = uccinfoInst.Secured_Party_ID__r.Unit__c;
                assignee.State__c = uccinfoInst.Secured_Party_ID__r.State__c;
                assignee.Id = uccinfoInst.Secured_Party_ID__r.Id;
                assignee.International_Address__c = uccinfoInst.Secured_Party_ID__r.International_Address__c;
                wrapInst.uccAssignor = assignee;
            }
            for(Id assignorId : assigneeAssignorsMap.get(assigneeId) ){
                UCC_Entity_Info__c uccinfoInst = assignorMap.get(assignorId);
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
                assignor.Unit__c = uccinfoInst.Secured_Party_ID__r.Unit__c;
                assignor.City__c = uccinfoInst.Assignor_ID__r.City__c;
                assignor.State__c = uccinfoInst.Assignor_ID__r.State__c;
                assignor.Id = uccinfoInst.Assignor_ID__r.Id;
                assignor.International_Address__c = uccinfoInst.Assignor_ID__r.International_Address__c;
                wrapInst.uccAssignees.add(assignor);
            }
            
            assignorWrapList.add(wrapInst);
        }

        return assignorWrapList;

    }
    @AuraEnabled
    public static String insertAssinorRelatedEntityBulk(Object[] assignorList, String uccFilingId, String lienType) {
        try {
            List<UCC_Entity_Info__c> entityListToInsert = new List<UCC_Entity_Info__c>();
            Map<String, List<String>> assignorVsSecuredPartyList = new Map<String, List<String>>();
            for (Object obj : assignorList) {
                Map<Object, Object> mp_StrObj = (Map<Object, Object>)obj;
                UCC_Related_Info__c objRelated = new UCC_Related_Info__c();
                List<String> allsecIds = new List<String>();
                for (Object objKey : mp_StrObj.keySet()) {
                    if (String.valueOf(objKey) != 'listSecuredIds' && String.valueOf(objKey) != 'removedIds') {
                        objRelated.put(String.valueOf(objKey), (String.valueOf(mp_StrObj.get(objKey))));
                    } else if(String.valueOf(objKey) == 'listSecuredIds'){
                        allsecIds = (List<String>)JSON.deserialize(JSON.serialize(mp_StrObj.get(objKey)), List<String>.class);
                    }
                }
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{objRelated}, 'insert');
                if(bAccessCheck){
                    Insert objRelated;
                }
                assignorVsSecuredPartyList.put(objRelated.Id, allsecIds);
            }
            If(!assignorVsSecuredPartyList.isEmpty()) {
                for (String key : assignorVsSecuredPartyList.keySet()) {
                    for (String secIds : assignorVsSecuredPartyList.get(key)) {
                        UCC_Entity_Info__c entityInfoInst = new UCC_Entity_Info__c();
                        entityInfoInst.Filing_ID__c = uccFilingId;
                        entityInfoInst.Assignor_ID__c = lienType == System.Label.Assignor ? key : secIds;
                        entityInfoInst.Secured_Party_ID__c = lienType == System.Label.Assignor ? secIds : key;
                        entityListToInsert.add(entityInfoInst);
                    }
                }
            }
    
            if (!entityListToInsert.isEmpty()) {
                /*if (!Schema.sObjectType.UCC_Entity_Info__c.isAccessible()) {
                    return null;
                } else if (Schema.sObjectType.UCC_Entity_Info__c.isCreateable()) {
                    insert entityListToInsert;
                }*/
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(entityListToInsert, 'insert');
                if(bAccessCheck1){
                    insert entityListToInsert;
                }else{
                    return null;
                }
            }
            return getAllAssignorAndAssignee(uccFilingId, lienType);
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler(className, insertAssinorRelatedEntityBulk, relatedInfoObject, null, severity, exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    Public class wrapAssignor {
        @AuraEnabled Public String securedIds;
    }
}