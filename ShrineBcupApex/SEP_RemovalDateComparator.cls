/* DESCRIPTION:  checks if a removal request is Valid or not?
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                    25-September-2021                    Created First Version
***************************************************************************************************/
global with sharing class SEP_RemovalDateComparator {
    public static final String sSeverity = 'Medium';
    global without sharing class Requests {
        @InvocableVariable
        global DateTime dtRemovalDateTime;
        @InvocableVariable
        global String sUserTime;
      }
      global without sharing class Results {
       @InvocableVariable
       global Boolean isValidRequest;
      }
      @InvocableMethod
      global static List<Results> checkIsValidRemoval(List<Requests> lstRemovalRequests){
          List<Results> lstRes = new List<Results>();
          Results objRes = new Results();
          Date dtUser;
          try{
            if(lstRemovalRequests.size() > 0){
                system.debug(lstRemovalRequests[0].dtRemovalDateTime);
                system.debug(lstRemovalRequests[0].sUserTime);
                List<String> lstUserDate = lstRemovalRequests[0].sUserTime.split(' ');
                system.debug('list ' + lstUserDate);
                if(lstUserDate.size() > 0){
                    dtUser = Date.valueof(lstUserDate[0]);
                    system.debug('string converted into date ' + dtUser);
                }
                system.debug('date from removal date ' + lstRemovalRequests[0].dtRemovalDateTime.Date());
                if(dtUser < lstRemovalRequests[0].dtRemovalDateTime.Date()){
                    objRes.isValidRequest = false;
                    lstRes.add(objRes);
                    return lstRes;
                }
                else{
                    objRes.isValidRequest = true;
                    lstRes.add(objRes);
                    return lstRes;
                }
            }
        }
        catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_RemovalDateComparator','checkIsValidRemoval','SEP_Exclusion_Consent__c',' ',sSeverity,objExp,'');
            throw new AuraHandledException(objExp.getMessage());
        }
        return null;
      }
}