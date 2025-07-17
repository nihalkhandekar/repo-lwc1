/* DESCRIPTION: This class is used to get UCC related info records and perform DML operations on them.
*
* @AUTHOR:   Avinash Shukla
* @DATE:   2020-11-26
* @description ::: This class is used in reference to LWC Components. Used for the purpose of Managing records creation and there DML operations on object : UCC_Related_Info__c
*                  1. brs_addRelatedMembers
*                  2. brs_UCC3_amendEntities
*
* @Test Class : NA
* @Code coverage : NA
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Avinash Shukla                   2020-11-26                   Created the first version
* Sushri Sarita Nayak              2020-11-30                   Added Handle Exception Method
* Avinash Shukla                   2020-12-04                   Replaced UCC lien ID with UCC Filing record ID and Mailing Street with Street__C and removed field Unit_Apt__c.
                                                                All the entities(secured party, debtor etc are now going to be created with reference to UCC filing records instead of
                                                                UCC Lien records)
* Avinash Shukla                   2020-12-12                   Optimisation : Replaced the SOQL query with dynamic query.
                                                                               Removed system debug logs
                                                                               Added Object level permissions clause in DML Operations.

*********************************************************************************************/

public with sharing class brs_addRelatedMember {
    public static final String className = 'brs_addRelatedMember';
    public static final String relatedInfoObject = 'UCC_Related_Info__c';
    public static final String severity = 'High';


    @AuraEnabled
    /**
    * [insertUccRelatedInfor Method to perform DML actions on UCC Related Info Object]
    * @param  objUCCRelatedMemberInfo [List Of UCCRelatedInfo to perform action on]
    * @param  uccLienID               [LieniD : Parent Id for UCCRelatedInfo]
    * @param  action                  [Upsert, Delete, Insert]
    * @return                         [List of UCCRelatedInfo]
    */
    public static List<UCC_Related_Info__c> insertUccRelatedInfor(UCC_Related_Info__c [] objUCCRelatedMemberInfo, String uccLienID, String action, String idToDelete, String lienType, Boolean isAmendment) {
        try {
            List<UCC_Related_Info__c> objUCCRelMemInfoListToReturn = new List<UCC_Related_Info__c>();
            if (objUCCRelatedMemberInfo.size() > 0) {
                if (action == 'Upsert') {
                    Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(objUCCRelatedMemberInfo, 'upsert');
					if(bAccessCheck1){
                    	Upsert objUCCRelatedMemberInfo;
                    }
                    objUCCRelMemInfoListToReturn  = retAllUCCRelatedInfo(uccLienID, lienType, isAmendment);
                } else if (action == 'Delete') {
                    Boolean bAccessCheck2 = BRS_SecurityUtility.checkDMLAccess(objUCCRelatedMemberInfo, 'delete');
					if(bAccessCheck2){
                    	Delete objUCCRelatedMemberInfo;
                    }
                    objUCCRelMemInfoListToReturn = retAllUCCRelatedInfo(uccLienID, lienType, isAmendment);
                } else if (action == 'Insert') {
                    Boolean bAccessCheck3 = BRS_SecurityUtility.checkDMLAccess(objUCCRelatedMemberInfo, 'insert');
					if(bAccessCheck3){
                    	Insert objUCCRelatedMemberInfo;
                    }
                    objUCCRelMemInfoListToReturn = retAllUCCRelatedInfo(uccLienID, lienType, isAmendment);
                }
            }
            return objUCCRelMemInfoListToReturn;
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler(className, 'insertUccRelatedInfor', relatedInfoObject, null, severity, exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    /**
    * [retAllUCCRelatedInfo Return list of UCCRelatedInfo records]
    * @param  uccLienID [uccLienID : UCC filing ID for UCCRelatedInfo]
    * @return           [List of UCCRelatedInfo]
    */
    @AuraEnabled
    public static List<UCC_Related_Info__c> retAllUCCRelatedInfo(String uccLienID, String lienType, Boolean isAmendment) {
        String query = QnA_Constants.EMPTY_STRING;
        List<UCC_Related_Info__c> allRelatedUCCRecords = new List<UCC_Related_Info__c>();
        try {            
             query = 'SELECT Id,(Select Id,Type_Of_Record__c from UCC_Related_Info__r), Name,status__c, Individual_First_Name__c, RecordTypeId ,RecordType.DeveloperName, Org_Name__c, Unit__c,Type__c, Individual_SurName__c, Filing_Id__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,International_Address__c FROM UCC_Related_Info__c ';

            if (!String.isEmpty(uccLienID) && !String.isEmpty(lienType)) {
               if (!isAmendment) {
                    query+=' '+ 'WHERE Filing_Id__c =:uccLienID AND Type__c =:lienType WITH SECURITY_ENFORCED';
                } else {
                    query+=' '+ 'WHERE Filing_Id__c =:uccLienID AND Type__c =:lienType AND Type_Of_Record__c = null AND Deleted_Flag__c = false AND UCC_Related_Info__c = null WITH SECURITY_ENFORCED';
                }
            }
            if (!String.isEmpty(query)) {
                allRelatedUCCRecords = Database.query(query);
            }
            return allRelatedUCCRecords;
        } catch (exception exe) {
            BOS_Utility.ExceptionHandler(className, 'retAllUCCRelatedInfo', relatedInfoObject, null, severity, exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    /********************************************************************************************
        METHOD NAME    : getDebtorSecuredParties
        DESCRIPTION    : to Get Debtor and Secured Parties from Selected Lien
        RETURN TYPE    : List of UCC Related Info
        PARAMETER      : String
    ********************************************************************************************/
    @AuraEnabled(cacheable = true)
    public static List<UCC_Related_Info__c> getdebtorSecuredRecords(String uccLienID, String lienType) {
        List<UCC_Related_Info__c> l_UccRelatedInfo = new List<UCC_Related_Info__c>();
        try {
            String conTypeD;
            String conTypeSec;
            if(lienType == System.label.JudgmentPersonalPropertyLabel || lienType == System.label.Judgement_Lien_Type){
                conTypeD = System.label.Review_MasterLabel_Type_JudgementDebtor;
                conTypeSec = System.label.BRS_UCC_Judgment_Creditor;
            }
            else if(lienType == System.label.Aircraft_Label || lienType == System.label.Vessel_Label ){
                conTypeD = System.label.Review_MasterLabel_Type_Owner;
                conTypeSec = System.label.Review_MasterLabel_Type_Claimant;
            }
            else{
                conTypeD = System.label.Review_MasterLabel_Type_Debtor;
                conTypeSec = System.label.Review_MasterLabel_Type_SecuredParty;
            }
            String query = 'Select id, City__c,Unit__c,International_Address__c, Country__c, Filing_Id__c, Individual_First_Name__c, Individual_Middle_Name__c, Individual_Salutation__c,Individual_SurName__c, RecordTypeId, RecordType.DeveloperName, Name__c, Org_Name__c, State__c, Street__c, Type__c, Name, Zip_Code__c, Suffix__c from UCC_Related_Info__c Where (Type__c =: conTypeD OR Type__c =:conTypeSec) AND Filing_Id__c =:uccLienID  WITH SECURITY_ENFORCED';
            l_UccRelatedInfo = Database.query(query);
            return l_UccRelatedInfo;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getdebtorSecuredRecords', 'UCC_Related_Info__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
}
	/***********************************************************************************
    * [insertUccRelatedInfor Method to perform DML actions on UCC Related Info Object]
    * @param  uccLienID               [LieniD : Parent Id for UCCRelatedInfo]
    * @param  action                   Delete]
    * @return                         [wrapper instance]
    *********************************************************************************/
	@AuraEnabled
    public static UCCEntityCntlr deleteContacts(String uccLienID, String action, String idToDelete, String lienType, Boolean isAmendment){
        UCCEntityCntlr uccObj = new UCCEntityCntlr();
        try{
            List<UCC_Entity_Info__c> uccEntities = [SELECT id, Secured_Party_ID__r.Type__c from UCC_Entity_Info__c 
                                                WHERE Secured_Party_ID__c =: idToDelete WITH SECURITY_ENFORCED];
            if(!uccEntities.isEmpty()){
                uccObj.message = system.label.Secured_party_not_deleted.replace('[]',uccEntities[0].Secured_Party_ID__r.Type__c );
            }else{
                //delete (new UCC_Related_Info__c(Id= idToDelete));
                UCC_Related_Info__c relatedInfo = new UCC_Related_Info__c(Id = idToDelete);
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{relatedInfo}, 'delete');
				if(bAccessCheck){
                    delete relatedInfo;
                }
            }
            
            uccObj.uccContacts = retAllUCCRelatedInfo(uccLienID, lienType, isAmendment);
            
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'deleteContacts', 'UCC_Related_Info__c', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
        
        return uccObj;
    }
    
    
    public class UCCEntityCntlr{
        @AuraEnabled
        public string message;
        @AuraEnabled
        public List<UCC_Related_Info__c> uccContacts = new List<UCC_Related_Info__c>();
        
    }
}