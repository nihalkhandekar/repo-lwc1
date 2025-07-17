/********************************************************************************************
* CLASS: 		brs_confirmationScreenController
* DESCRIPTION: Controller for confirmation screen
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------

*********************************************************************************************/
public with sharing class brs_confirmationScreenController {

	public class checkBusinessFilingWrapper{
        @AuraEnabled public Boolean isLinkBusinessTomyDashboard {get; set;}
        @AuraEnabled public Boolean agentSelfAccepted {get; set;}
    }
    @AuraEnabled
    public static checkBusinessFilingWrapper checkBusinessFiling(String accId, business_filing__c businessFilingInst){
        try{
		checkBusinessFilingWrapper responseToSend = new checkBusinessFilingWrapper();
        Boolean isLinkBusinessTomyDashboard = false;
        Boolean isAccountConRel = false;
        String profileName = BRS_Utility.getLoggedInUserProfile();
        List<Id> accountConcIds = new List<Id>();
        if(profileName!=null && profileName == System.label.Community_User_Profile){
            List<AccountContactRelation> acrRecList =BRS_Utility.getAccContactList();
            if(!acrRecList.isEmpty()){
                for(AccountContactRelation acrRecObj : acrRecList){
                    accountConcIds.add(acrRecObj.AccountId);
                }
            }
        }
        business_filing__c businessInst =[select id,Account__c,Filing_Fee__c,due_date__c,type__c,status__c,Self_Nomination_as_Agent__c from business_filing__c where  id =: businessFilingInst.ID WITH SECURITY_ENFORCED Limit 1];
        if(!accountConcIds.Isempty()){
            If(accountConcIds.contains(businessInst.Account__c)){
                isAccountConRel = true;
            }
        }
        if(businessInst.Status__c != null && businessInst.Filing_Fee__c !=  null){
            if(isAccountConRel == false && businessInst.Status__c == System.label.BRS_FilingStatus_Approved && businessInst.Filing_Fee__c > 0){
                isLinkBusinessTomyDashboard = true;
            }
			if(businessInst.Self_Nomination_as_Agent__c!=null){
                    responseToSend.agentSelfAccepted = businessInst.Self_Nomination_as_Agent__c;
                }
        }
		responseToSend.isLinkBusinessTomyDashboard = isLinkBusinessTomyDashboard;
        
        return responseToSend;
    }catch (Exception e) {
        BOS_Utility.ExceptionHandler('brs_confirmationScreenController', 'checkBusinessFiling', '', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
    }  
    }
   
}