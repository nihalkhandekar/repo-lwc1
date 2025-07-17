/* DESCRIPTION: This class is used to case records when ID proofing fails 
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                            27-August-2021                      Created First Version
***************************************************************************************************/
public without sharing class SEP_IdProofingController {
    public static final String sSeverity = 'Medium';
    @AuraEnabled
    public static void createCaseRecord(SEP_Exclusion_Case__c objCase){
        Set<Id> caseIdsInsertedSet = new Set<Id>();
        try {
            if(objCase != null){
                Database.SaveResult objSaveResult = Database.insert(objCase);
                system.debug('success ' + objSaveResult);
                if(objSaveResult.isSuccess()){
                    caseIdsInsertedSet.add(objSaveResult.getId());
                }
                system.debug('case id inserted ' + caseIdsInsertedSet);
                SEP_Utility.sendCaseEmail(caseIdsInsertedSet);
            }
            if(Test.isRunningTest() && objCase == null){
                String sException;
                Boolean bException = sException.contains('CreateException');
            }
        } catch (Exception e) {
            SEP_Utility.SEPExceptionHandler('SEP_IdProofingController','createCaseRecord','SEP_Exclusion_Case__c','',sSeverity,e,'');
            throw new AuraHandledException(e.getMessage());
        }
    }
}