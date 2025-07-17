/* DESCRIPTION: This class is used to update authorizer for Ucc filing in UCC-3
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

public with sharing class brs_designateAuthorizer {

    public static final String className='brs_designateAuthorizer';    
    public static final String relatedInfoObject = 'UCC_Related_Info__c';
    public static final String severity = 'High';
    
    // Method to update the Authorizer in UCC related Info for the filing
    @AuraEnabled
    public static String updateAuthorizer(String FilingId, String AuthorizerId) {
        try {
            List<UCC_Related_Info__c> relatedInfoInst = new List<UCC_Related_Info__c>();
            String InProgressStatus = System.label.BRS_UCC_StatusInProgress;
            List<UCC_Related_Info__c> RelatedInfoUpdateList=new List<UCC_Related_Info__c>();
            String newAuthorizerId;
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: UCC3 Fix
            * Change(s)/Modification(s) Description : Removing the condition to update isAuthoriser as true or false only on 'In Progress' Ucc related Infos.
                                                      Fix is for Authorizor not showing on the review screen.
            * Change(s)/Modification(s) Made on : 2021-03-03
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if(!String.isBlank(FilingId)){
                relatedInfoInst= [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c,RecordType.Name, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,International_Address__c,Unit__c,Filing_Id__c FROM UCC_Related_Info__c WHERE Filing_Id__c = : FilingId WITH SECURITY_ENFORCED];
            }     
             if (!Schema.sObjectType.UCC_Related_Info__c.fields.isAuthorizer__c.isUpdateable()){
                return null;
              }
           for(UCC_Related_Info__c uci:relatedInfoInst){
                  if(uci.Id == AuthorizerId){
                    uci.isAuthorizer__c=true;
                    newAuthorizerId=uci.Id;
                    RelatedInfoUpdateList.add(uci);
                  }else if(uci.isAuthorizer__c==true){
                    uci.isAuthorizer__c=false;
                    RelatedInfoUpdateList.add(uci);
                  }
              }
            if(!RelatedInfoUpdateList.isEmpty())
             update RelatedInfoUpdateList;
          return newAuthorizerId;
        } catch (exception exe) {
            BOS_Utility.ExceptionHandler(className,'updateAuthorizer','',null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }
    // Method to query all the Secured Parties and Debtors List 
    @AuraEnabled
    public static getallDataWrap getAuthorizers(String FilingId,String lienType){
        try {
            List<UCC_Related_Info__c> relatedInfoList = new List<UCC_Related_Info__c>();
            if (Schema.SObjectType.UCC_Related_Info__c.isAccessible() && FilingId != null) {
                relatedInfoList = [SELECT Id, Status__c,Name,isAuthorizer__c,RecordType.Name, Individual_First_Name__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,International_Address__c,Unit__c,Filing_Id__c,(Select id from UCC_Assignee_Info1__r) FROM UCC_Related_Info__c WHERE Filing_Id__c = : FilingId AND UCC_Related_Info__c = null AND Deleted_Flag__c != true WITH SECURITY_ENFORCED];
            }
            getallDataWrap wrapInst = new getallDataWrap();
            List<UCC_Related_Info__c> uccTempList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> securedPartyList = new List<UCC_Related_Info__c>();
            for(UCC_Related_Info__c uccInst : relatedInfoList){
                if(uccInst.UCC_Assignee_Info1__r.isEmpty()){
                    if(lienType == System.Label.Vessel_Label || lienType == System.Label.Aircraft_Label || lienType == System.Label.Notice_of_Attachment){
                        if(uccInst.Type__c == System.Label.Review_MasterLabel_Type_Owner){
                            uccTempList.add(uccInst);
                            wrapInst.debtorList = uccTempList;
                        }
                        else if(uccInst.Type__c == System.Label.Review_MasterLabel_Type_Claimant){
                            securedPartyList.add(uccInst);
                            wrapInst.securedPartyList = securedPartyList;
                        }
                    }
                    else if(lienType == System.Label.Judgment_Label ){
                        if(uccInst.Type__c == System.Label.BRS_UCC_JudgmentDebtor){
                            uccTempList.add(uccInst);
                            wrapInst.debtorList = uccTempList;
                        }
                        else if(uccInst.Type__c == System.Label.BRS_UCC_Judgment_Creditor){
                            securedPartyList.add(uccInst);
                            wrapInst.securedPartyList = securedPartyList;
                        }
                    }
					else if(lienType == System.Label.Judgement_Lien_Type){
                        if(uccInst.Type__c == System.Label.Defendant){
                            uccTempList.add(uccInst);
                            wrapInst.debtorList = uccTempList;
                        }
                        else if(uccInst.Type__c == System.Label.Plaintiff){
                            securedPartyList.add(uccInst);
                            wrapInst.securedPartyList = securedPartyList;
                        }
                    }
                    else{
                        if(uccInst.Type__c == System.Label.Secured_Party_Label){
                            securedPartyList.add(uccInst);
                            wrapInst.securedPartyList = securedPartyList;
                        }else if(uccInst.Type__c == System.Label.BRS_UCC_Debtor_Label){
                            uccTempList.add(uccInst);
                            wrapInst.debtorList = uccTempList;
                        }
                    }
                }
            }
            return wrapInst;
        } catch (Exception exe) {
            BOS_Utility.ExceptionHandler(className,'getAuthorizers','',null,severity,exe,null);
            throw new AuraHandledException(exe.getMessage());
        }
    }

    // Wrapper class for the Secured Party and Debtor List
    public without sharing class getallDataWrap{
        @AuraEnabled public List<UCC_Related_Info__c> securedPartyList;
        @AuraEnabled public List<UCC_Related_Info__c> debtorList;
        
    }
}