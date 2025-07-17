/* DESCRIPTION: This class contains the cloning logic for Rejected filings Resubmission
*
* @AUTHOR:  Sarita Nayak
* @DATE:    04/06/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita Nayak                    04/06/2021                           Created the first version
*********************************************************************************************/
public without sharing class brs_UCCCloneForResubmissionClass {
    @invocableMethod
    public static List<cloneResponceUCC> CloneRecords(List<RequestCls> request){
        try{
            List<cloneResponceUCC> returnRes = new List<cloneResponceUCC>();
            if(request[0].filingId != null){
                Schema.DescribeSObjectResult getObj = SchemaUtility.getObjectFromId(request[0].filingId);
                if(getObj.getLabel() == System.label.BusinessFiling_Label){
                    returnRes = cloneBusinessFilingWithRelatedrecords(request);
                }
                else{
                    returnRes = cloneUCCFilingWithRelatedrecords(request);
                }
            }
            return returnRes;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler('brs_UCCCloneForResubmissionClass', 'CloneRecords', '', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        } 
    }

    public static List<cloneResponceUCC> cloneBusinessFilingWithRelatedrecords(List<RequestCls> request){
        try{
            
            List<Business_Filing__c> busFilingInst = new List<Business_Filing__c>();
            Business_Filing__c busFileNew = new Business_Filing__c();
            if(request[0].filingId != null){
                Business_Filing__c busFile = [SELECT ID, Name,Type__c,Total_Authorized_Shares__c,Source__c,RecordTypeId,Citizenship__c,Business_Type__c,Account__c FROM Business_Filing__c WHERE Id = : request[0].filingId WITH SECURITY_ENFORCED];


                busFileNew = busFile.Clone(false,false,false,false);
                busFileNew.Status__c = System.label.BRS_UCC_StatusInProgress;
                busFileNew.Account__c = busFile.Account__c;
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{busFileNew}, 'insert');
				if(bAccessCheck){
                	Insert busFileNew;
                }

                busFile.Is_Rejected_Instantiated__c = true;
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{busFile}, 'update');
				if(bAccessCheck1){
                	update busFile;
                }
            }
            List<cloneResponceUCC> cloneResponseList = new List<cloneResponceUCC>();
            cloneResponceUCC cloneRes = new cloneResponceUCC();
            cloneRes.resFilingId = busFileNew.Id;
            cloneResponseList.add(cloneRes);
            return cloneResponseList; 
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler('brs_UCCCloneForResubmissionClass', 'cloneUCCFilingWithRelatedrecords', '', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        } 
    }

    public static List<cloneResponceUCC> cloneUCCFilingWithRelatedrecords(List<RequestCls> request){
       try{
            List<UCC_Filing__c> uccInst = new List<UCC_Filing__c>();
            if(request[0].filingId != null){
                uccInst = [SELECT Id, Name,Status__c,Type__c,Name__c,Lien_Type__c,Location__Latitude__s,Lapse_Date__c,
					Collateral_Information__c,Filer_Reference_Data__c,Description__c,Collateral_Type__c,
					Lien_Filing_Type__c,Collateral_Document_Description__c,Reason_for_Dispute__c,
                    Amendment_Type__c,Acknowledge__c,Amendment_Entity__c,Type_of_Update__c,Dispute_Justification__c,
					Request_Amendment__c,Amend_Collateral__c,UCC_Lien_Type__c,UCC_Lien_Id__c,Type_of_Collateral_Update__c,
					Assignment_Type__c,UCC_Filing_Type__c,Filing_Source__c,Filing_Date__c,
                OFC_Comments__c,OFC_Comments_Code__c,
                (Select Id, Name,Type__c, Street__c, City__c, State__c, Country__c, Zip_Code__c, Individual_First_Name__c,
                Individual_Middle_Name__c,Deleted_Flag__c,Filing_Id__c,RecordTypeId,RecordType.DeveloperName, Individual_SurName__c, Org_Name__c,
                Suffix__c,Individual_Salutation__c,isAuthorizer__c,Address__c,Debtor_Is__c
                FROM  UCC_Related_Info__r where Deleted_Flag__c !=true Limit 200),
                UCC_Lien_Id__r.Name, UCC_Lien_Id__r.Status__c FROM  UCC_Filing__c
                where Id =:request[0].filingId WITH SECURITY_ENFORCED  Limit 1 ];
            }
                List<UCC_Lien__c> parentLienRec = new List<UCC_Lien__c>([Select id,Type__c,Original_Judgement_Amount__c,Personal_Property_Description__c,
                Date_of_Judgement__c,Name__c,Amount_Due__c from UCC_Lien__c where Id =:uccInst[0].UCC_Lien_Id__c WITH SECURITY_ENFORCED Limit 1 ]);
                UCC_Filing__c filingNewUInst = new UCC_Filing__c();
                if (!uccInst.isEmpty()) {

                    uccInst[0].Is_Rejected_Instantiated__c = true;
                    Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(uccInst, 'update');
					if(bAccessCheck1){
                    	update uccInst;
                    }

                    UCC_Lien__c lienRecInst = new UCC_Lien__c();
                    lienRecInst = parentLienRec[0].Clone(false, false, false,false);
                    Boolean bAccessCheck2 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{lienRecInst}, 'insert');
					if(bAccessCheck2){
                    	Insert lienRecInst;
                    }

                    filingNewUInst = uccInst[0].Clone(false, false, false,false);
                    filingNewUInst.Status__c = System.label.BRS_UCC_StatusInProgress;
                    filingNewUInst.Current_Screen__c = '';
                    filingNewUInst.UCC_Lien_Id__c = lienRecInst.Id;
                    filingNewUInst.Is_Rejected_Instantiated__c = false;
                    Boolean bAccessCheck3 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{filingNewUInst}, 'insert');
					if(bAccessCheck3){
                    	insert filingNewUInst;
                    }

                    List<UCC_Related_Info__c> uccrelatedInfoList = new List<UCC_Related_Info__c>();
                    for(UCC_Related_Info__c oldInfoRecord : uccInst.get(0).UCC_Related_Info__r) {
                        UCC_Related_Info__c uccContact = oldInfoRecord.clone(false, false, false, false);
                        uccContact.Filing_Id__c = filingNewUInst.Id;
                        uccrelatedInfoList.add(uccContact);
                    }
                    Boolean bAccessCheck4 = BRS_SecurityUtility.checkDMLAccess(uccrelatedInfoList, 'insert');
					if(bAccessCheck4){
                    	insert uccrelatedInfoList;
                    } 
                }
                List<cloneResponceUCC> cloneResponseList = new List<cloneResponceUCC>();
                cloneResponceUCC cloneRes = new cloneResponceUCC();
                cloneRes.resFilingId = filingNewUInst.Id;
                cloneResponseList.add(cloneRes);
                return cloneResponseList;
            }catch (Exception e) {
                BOS_Utility.ExceptionHandler('brs_UCCCloneForResubmissionClass', 'cloneUCCFilingWithRelatedrecords', '', null, BOS_Utility.sSeverity, e, null);
                throw new AuraHandledException(e.getMessage());
            } 
    }
    
    public with sharing class cloneResponceUCC {
        @InvocableVariable public string resFilingId;
    }
    public class RequestCls {
        @InvocableVariable public String filingId;
    }
   
}