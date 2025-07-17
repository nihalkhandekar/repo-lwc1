/* DESCRIPTION:  calculates end date for a particular exclusion request 
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                    9-September-2021                    Created First Version
***************************************************************************************************/
global without sharing class SEP_RegistrationFlow_SelfExclusion {
  public static final String sSeverity = 'Medium';
    @InvocableMethod
    global static List<Results> calculateEndDate(List<Requests> Requests){
        //calculate new end date
        List<Results> lstResults = new List<Results>();
        Results objRes = new Results();

        DateTime dtNewEndDate ;
        try{
          if(Requests[0].sNewRequestExclusionPeriod == 'L'){
              dtNewEndDate = DateTime.newInstance(4000,Requests[0].dtNewStatusChangeDate.month(),Requests[0].dtNewStatusChangeDate.day());
              //system.debug('when request is lifetime  ' + dtNewEndDate);
              objRes.dtNewEndDate = dtNewEndDate;
              objRes.dtRemovalDate = dtNewEndDate; //No need of removal date in case of lifetime value
              //system.debug('lifetime and removal date' + dtNewEndDate);
              lstResults.add(objRes);
              return lstResults;
            }
            else if(Requests[0].sNewRequestExclusionPeriod == '1'){
              dtNewEndDate = Requests[0].dtNewStatusChangeDate.addMonths(12);
              //system.debug('when request is 1 year  ' + dtNewEndDate);
              objRes.dtNewEndDate = dtNewEndDate;
              objRes.dtRemovalDate = dtNewEndDate.addDays(1);
              //system.debug('1 year and removal date' + dtNewEndDate);
              lstResults.add(objRes);
              return lstResults;
            }
            else if(Requests[0].sNewRequestExclusionPeriod == '5'){
              dtNewEndDate = Requests[0].dtNewStatusChangeDate.addMonths(60);
              //system.debug('when request is 5 years  ' + dtNewEndDate);
              objRes.dtNewEndDate = dtNewEndDate;
              objRes.dtRemovalDate = dtNewEndDate.addDays(1);
              //system.debug('5 year and removal date' + dtNewEndDate);
              lstResults.add(objRes);
              return lstResults;
            }
          }
          catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_RegistrationFlow_SelfExclusion','calculateEndDate','SEP_Exclusion_Consent__c',' ',sSeverity,objExp,'');
            throw new AuraHandledException(objExp.getMessage());
          }
          return null;
    }
    global without sharing class Requests {
        @InvocableVariable
        global DateTime dtNewStatusChangeDate;
        @InvocableVariable
        global String sNewRequestExclusionPeriod;
      }
      global without sharing class Results {
        @InvocableVariable
        global DateTime dtNewEndDate;
        @InvocableVariable
        global DateTime dtRemovalDate;
    }
}