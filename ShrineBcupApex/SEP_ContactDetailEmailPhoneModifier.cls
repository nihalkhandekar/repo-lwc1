/* DESCRIPTION: This is the trigger helper class is used to check duplicate Emails and Phone numbers
*
* @AUTHOR:  Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                             5-September-2021                      Created First Version
***************************************************************************************************/
public without sharing class SEP_ContactDetailEmailPhoneModifier {
    public static final String sSeverity = 'Medium';
    /*
    * Description:      
    * Param 1:          List of ContactDetail records from trigger.new
    * Return Type:      none
    *
    */

    public static void CheckEmailPhoneNumber(List<SEP_Contact_Detail__c> newTriggerList){

        Set<id> setConsnetRecordIds = new Set<id>();
        List<SEP_Contact_Detail__c> lstExistingContactDetailRecords = new List<SEP_Contact_Detail__c>();
        List<SEP_Exclusion_Consent__c> lstConsentRecordsToUpdate = new List<SEP_Exclusion_Consent__c>();
        Map<String,SEP_Contact_Detail__c> mapOfEmailandContactDetails = new Map<String,SEP_Contact_Detail__c>();
        Map<id,Map<string,SEP_Contact_Detail__c>> mapofConsentIdandMapofEmailandContactdetailrecord = new Map<id,Map<string,SEP_Contact_Detail__c>>();
        Map<id,Map<string,SEP_Contact_Detail__c>> mapofConsentIdandMapofPhoneandContactdetailrecord = new Map<id,Map<string,SEP_Contact_Detail__c>>();
        Map<id,SEP_Contact_Detail__c> mapofConsentIdandPrimaryEmailConDetailRecord = new Map<id,SEP_Contact_Detail__c>();
        Map<id,SEP_Contact_Detail__c> mapofConsentIdandPrimaryPhoneConDetailRecord = new Map<id,SEP_Contact_Detail__c>();
        List<SEP_Contact_Detail__c> lstConDetailRecordsTobeDeleted = new List<SEP_Contact_Detail__c>();
        List<SEP_Contact_Detail__c> lstConDetailRecordsTobeUpdated = new List<SEP_Contact_Detail__c>();
        Set<id> setOfConsentIdtobeUpdated = new Set<id>();   
        try{ 
            for(SEP_Contact_Detail__c objContactDetails : newTriggerList){
                setConsnetRecordIds.add(objContactDetails.SEP_Exclusion_Consent__c);
                }

            lstExistingContactDetailRecords = [SELECT id,Email_Address__c,IsPrimary__c,IsVerified__c,Phone_number__c,SEP_Exclusion_Consent__c FROM SEP_Contact_Detail__c WHERE SEP_Exclusion_Consent__c in : setConsnetRecordIds];
        
            for(SEP_Contact_Detail__c objConDetail : lstExistingContactDetailRecords){
                if(String.isNotBlank(objConDetail.Email_Address__c)){
                    if(objConDetail.IsPrimary__c == true){
                        mapofConsentIdandPrimaryEmailConDetailRecord.put(objConDetail.SEP_Exclusion_Consent__c,objConDetail);
                    }
                    if(!mapofConsentIdandMapofEmailandContactdetailrecord.containsKey(objConDetail.SEP_Exclusion_Consent__c)){
                    mapofConsentIdandMapofEmailandContactdetailrecord.put(objConDetail.SEP_Exclusion_Consent__c, new Map<string, SEP_Contact_Detail__c>{ objConDetail.Email_Address__c => objConDetail });
                    }else{
                        mapofConsentIdandMapofEmailandContactdetailrecord.get(objConDetail.SEP_Exclusion_Consent__c).put(objConDetail.Email_Address__c,objConDetail);
                    }
                }else if(String.isNotBlank(objConDetail.Phone_number__c)){
                    if(objConDetail.IsPrimary__c == true){
                        mapofConsentIdandPrimaryPhoneConDetailRecord.put(objConDetail.SEP_Exclusion_Consent__c,objConDetail);
                    }
                            if(!mapofConsentIdandMapofPhoneandContactdetailrecord.containsKey(objConDetail.SEP_Exclusion_Consent__c)){
                                mapofConsentIdandMapofPhoneandContactdetailrecord.put(objConDetail.SEP_Exclusion_Consent__c, new Map<string, SEP_Contact_Detail__c>{ objConDetail.Phone_number__c => objConDetail });
                                }else{
                                    mapofConsentIdandMapofPhoneandContactdetailrecord.get(objConDetail.SEP_Exclusion_Consent__c).put(objConDetail.Phone_number__c,objConDetail);
                                }
                }
            }
            for(SEP_Contact_Detail__c objConDetailNew : newTriggerList){
                if(String.isNotBlank(objConDetailNew.Email_Address__c) && mapofConsentIdandMapofEmailandContactdetailrecord.containsKey(objConDetailNew.SEP_Exclusion_Consent__c)){
                map<String,SEP_Contact_Detail__c> mapTemporayMap = mapofConsentIdandMapofEmailandContactdetailrecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                    if(mapTemporayMap.containsKey(objConDetailNew.Email_Address__c)){
                        SEP_Contact_Detail__c objExistingConDetail  = mapTemporayMap.get(objConDetailNew.Email_Address__c);
                            if(objConDetailNew.IsPrimary__c == true){
                                lstConDetailRecordsTobeDeleted.add(objExistingConDetail);
                                SEP_Contact_Detail__c objoldconDetail = new SEP_Contact_Detail__c();
                                if(mapofConsentIdandPrimaryEmailConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c) != null){
                                    objoldconDetail = mapofConsentIdandPrimaryEmailConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                                    objoldconDetail.IsPrimary__c = false;
                                    setOfConsentIdtobeUpdated.add(objConDetailNew.SEP_Exclusion_Consent__c);
                                    lstConDetailRecordsTobeUpdated.add(objoldconDetail);
                                    }
                            }else{
                                objConDetailNew.is_Duplicate_Record__c = true;
                            } 
                    }
                    else if(objConDetailNew.IsPrimary__c == true){
                        setOfConsentIdtobeUpdated.add(objConDetailNew.SEP_Exclusion_Consent__c);
                        SEP_Contact_Detail__c objoldconDetail = new SEP_Contact_Detail__c();
                        objoldconDetail = mapofConsentIdandPrimaryEmailConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                        objoldconDetail.IsPrimary__c = false;
                        lstConDetailRecordsTobeUpdated.add(objoldconDetail);
                    }
                }else if(String.isNotBlank(objConDetailNew.Phone_number__c) && mapofConsentIdandMapofPhoneandContactdetailrecord.containsKey(objConDetailNew.SEP_Exclusion_Consent__c)){
                    map<String,SEP_Contact_Detail__c> mapTemporayMap = mapofConsentIdandMapofPhoneandContactdetailrecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                    if(mapTemporayMap.containsKey(objConDetailNew.Phone_number__c)){
                        SEP_Contact_Detail__c objExistingConDetail  = mapTemporayMap.get(objConDetailNew.Phone_number__c);
                            if(objConDetailNew.IsPrimary__c == true){
                                lstConDetailRecordsTobeDeleted.add(objExistingConDetail);
                                SEP_Contact_Detail__c objoldconDetail = new SEP_Contact_Detail__c();
                                if(mapofConsentIdandPrimaryPhoneConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c) != null){
                                    objoldconDetail = mapofConsentIdandPrimaryPhoneConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                                    objoldconDetail.IsPrimary__c = false;
                                    objConDetailNew.IsVerified__c = objExistingConDetail.IsVerified__c;
                                    lstConDetailRecordsTobeUpdated.add(objoldconDetail);
                                }
                            }else{
                                objConDetailNew.is_Duplicate_Record__c = true;
                            } 
                    }
                    else if(objConDetailNew.IsPrimary__c == true){
                        SEP_Contact_Detail__c objoldconDetail = new SEP_Contact_Detail__c();
                        objoldconDetail = mapofConsentIdandPrimaryPhoneConDetailRecord.get(objConDetailNew.SEP_Exclusion_Consent__c);
                        objoldconDetail.IsPrimary__c = false;
                        lstConDetailRecordsTobeUpdated.add(objoldconDetail);
                    }
                }
            }

            if(lstConDetailRecordsTobeUpdated.size() > 0){
            update lstConDetailRecordsTobeUpdated;
            }

            if(lstConDetailRecordsTobeDeleted.size() > 0){
                delete lstConDetailRecordsTobeDeleted;
            }

            for(SEP_Exclusion_Consent__c objConsent : [SELECT id,Send_Mail__c FROM SEP_Exclusion_Consent__c WHERE id in : setOfConsentIdtobeUpdated]){
                objConsent.Send_Mail__c = true;
                lstConsentRecordsToUpdate.add(objConsent);
            }
            
            if(lstConsentRecordsToUpdate.size() > 0){
               // Update lstConsentRecordsToUpdate;
            }

        }catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_ContactDetailEmailPhoneModifier','CheckEmailPhoneNumber','SEP_Contact_Detail__c',' ',sSeverity,objExp,'');
            
        }
    }

}