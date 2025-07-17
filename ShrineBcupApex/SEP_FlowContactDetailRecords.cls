/* DESCRIPTION: This class is used to fetch primary email address for sending mail via flow.
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                            21-Sep-2021                      Created First Version
***************************************************************************************************/
global without sharing class SEP_FlowContactDetailRecords {
    public static final String sSeverity = 'Medium';
    @InvocableMethod
    global static List<Results> fetchChildRecord(List<Requests> lstReq){
        List<SEP_Contact_Detail__c> lstChildRecord = new List<SEP_Contact_Detail__c>();
        List<Results> lstResults = new List<Results>();
        Results objRes = new Results();
        try{
          if(lstReq.size() > 0){
            lstChildRecord = [SELECT Id,Email_Address__c FROM SEP_Contact_Detail__c WHERE IsPrimary__c = true AND Email_Address__c != NULL AND SEP_Exclusion_Consent__c =: lstReq[0].parentRecordId];
            if(lstChildRecord.size() > 0 && lstChildRecord != null){
              objRes.sEmailAddress = lstChildRecord[0].Email_Address__c ;
              lstResults.add(objRes);
            }
          }
          return lstResults;  
        }
        catch(Exception objExp){
          SEP_Utility.SEPExceptionHandler('SEP_FlowContactDetailRecords','fetchChildRecord','SEP_Contact_Detail__c',' ',sSeverity,objExp,'');
          return null;
        } 
    }
    global without sharing class Requests {
        @InvocableVariable
        global Id parentRecordId;
      }
      global without sharing class Results {
        @InvocableVariable
        global String sEmailAddress;
      }
}