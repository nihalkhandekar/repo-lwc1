/* DESCRIPTION: Helper class for DCP staff trigger on Consent object, used to calculate end date, 
start date, removal date & set Send mail field as true  
*
* @AUTHOR: 	Sakshi Nawab
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Sakshi Nawab                            10-Sep-2021                      Created First Version
***************************************************************************************************/
public with sharing class SEP_ExclusionRequestTriggerHelper {
    public static final String sSeverity = 'Medium';
    /********************************************************************************************
        METHOD NAME    : processRecords
        DESCRIPTION    : only processes records if source is DCP staff and updates corresponding start & end date fields
        RETURN TYPE    : None
        PARAMETER      : Trigger.new & old Map & operation type
        ********************************************************************************************/
    public static void processRecords(List<SEP_Exclusion_Consent__c> lstNewRecords, Map<Id,SObject> oldTriggerMap,String sOprType){
        List<SEP_Exclusion_Consent__c> lstRecToProcess = new List<SEP_Exclusion_Consent__c>();
        List<SEP_Exclusion_Consent__c> lstExistingConsentRecords = new List<SEP_Exclusion_Consent__c>();
        Map<String,SEP_Exclusion_Consent__c> mapOfUniqueIdandExistingConsentRecords = new Map<String,SEP_Exclusion_Consent__c>();
        set<String> setOfUniqueId = new Set<String>();
        
       // System.debug(UserInfo.getProfileId());

        Profile objProfile = [SELECT id,Name FROM Profile WHERE Name ='Agency User' limit 1];

        for(SEP_Exclusion_Consent__c objExConsent : lstNewRecords){
            String sUniqueId = objExConsent.Unique_Identifier_Number__c + String.ValueOf(objExConsent.Date_Of_Birth__c).split(' ')[0];
            //System.debug(' >>sUniqueId '+sUniqueId);
            setOfUniqueId.add(sUniqueId); 
        }
    
        lstExistingConsentRecords = [SELECT id,First_Name__c,Consent_Record_Unique_Id__c,Middle_Name__c,Last_Name__c,Date_Of_Birth__c,Unique_Identifier_Number__c
                                                                    FROM SEP_Exclusion_Consent__c 
                                                                    WHERE Consent_Record_Unique_Id__c in: setOfUniqueId];

       // System.debug('lstExistingConsentRecords >>'+lstExistingConsentRecords);
        for(SEP_Exclusion_Consent__c objExclusionConsent : lstExistingConsentRecords){
            mapOfUniqueIdandExistingConsentRecords.put(objExclusionConsent.Consent_Record_Unique_Id__c,objExclusionConsent);
        }

        try{
            for(SEP_Exclusion_Consent__c objConsent : lstNewRecords){
                if(objConsent.Exclusion_Source__c == System.Label.SEP_DCPStaffPicklistValue){
                    if(sOprType == 'CREATE'){
                        if(mapOfUniqueIdandExistingConsentRecords.containsKey(objConsent.Unique_Identifier_Number__c +  String.ValueOf(objConsent.Date_Of_Birth__c).split(' ')[0])){
                            objConsent.addError('Self-Exclusion Request with the same SSN and DOB already exists.');
                        }
                        Date dtnewdate = objConsent.Date_Of_Birth__c.addYears(18);
                       // System.debug('dtnewdate '+dtnewdate +'Date.today() '+Date.today());
                        if(dtnewdate.daysBetween(Date.today()) < 0 ){
                            objConsent.addError('Age should be greater than 18');
                        }
                        //system.debug('inside create context dcp staff');
                        lstRecToProcess.add(objConsent);
                    }
                }
                if(sOprType == 'UPDATE'){
                    if(oldTriggerMap != null){
                        if(UserInfo.getProfileId() == objProfile.id){
                           // system.debug('inside update context dcp staff');
                            SEP_Exclusion_Consent__c objOldExclusionRecord = (SEP_Exclusion_Consent__c)oldTriggerMap.get(objConsent.Id);
                            if(objConsent.Minimum_Self_Exclusion_Period__c != objOldExclusionRecord.Minimum_Self_Exclusion_Period__c){
                                lstRecToProcess.add(objConsent);
                            }else if(objOldExclusionRecord.Exclusion_Consent_Status__c == 'Active' && objConsent.Exclusion_Consent_Status__c == 'Removed' ){
                                objConsent.Exclusion_End_DateTime__c = System.now();
                                objConsent.Exclusion_Status_Change_Date__c = System.now();
                                objConsent.Removal_Allowed_DateTime__c = System.now();
                                objConsent.Self_Exclusion_Removal_Source__c = 'DCP Staff';
                                objConsent.Send_Mail__c = true;

                            }else if(objOldExclusionRecord.Exclusion_Consent_Status__c == 'Removed' && objConsent.Exclusion_Consent_Status__c == 'Active' ){
                                objConsent.Self_Exclusion_Removal_Source__c = 'Not Applicable';
                                lstRecToProcess.add(objConsent);
                                if(objConsent.Exclusion_End_DateTime__c >  objOldExclusionRecord.Exclusion_End_DateTime__c){
                                    objConsent.Retrigger_Notification__c = true;
                            }
                        }
                    }
                    }
                   
            }
            if(!lstRecToProcess.isEmpty()){
                SEP_ExclusionRequestTriggerHelper.updateEndDateOnRecords(lstRecToProcess,sOprType);

                SEP_Exclusion_Consent__c objOldExclusionRecord = (SEP_Exclusion_Consent__c)oldTriggerMap.get(objConsent.Id);
                System.debug('>>> before objConsent.Exclusion_End_DateTime__c '+objConsent.Exclusion_End_DateTime__c +'objOldExclusionRecord.Exclusion_End_DateTime__c'+objOldExclusionRecord.Exclusion_End_DateTime__c);

                if(objConsent.Exclusion_End_DateTime__c >  objOldExclusionRecord.Exclusion_End_DateTime__c){
                    objConsent.Retrigger_Notification__c = true;
                }
            }
        }}
        catch(Exception e){
            SEP_Utility.SEPExceptionHandler('SEP_ExclusionRequestTriggerHelper','processRecords','SEP_Exclusion_Consent__c','',sSeverity,e,'');
        }
    }
    /********************************************************************************************
        METHOD NAME    : updateEndDateOnRecords
        DESCRIPTION    : This method will stamp start , end & removal allowed dates
        RETURN TYPE    : None
        PARAMETER      : Trigger.new &  operation type
        ********************************************************************************************/
    public static void updateEndDateOnRecords(List<SEP_Exclusion_Consent__c> lstNewRecords,String sOperationType){
        try{
            for(SEP_Exclusion_Consent__c objSEP : lstNewRecords){
                if(objSEP.Minimum_Self_Exclusion_Period__c == 'L'){
                    objSEP.Exclusion_End_DateTime__c = DateTime.newInstance(4000,System.now().month(),System.now().day());
                    //system.debug('end date in case of lifetime ' + objSEP.Exclusion_End_DateTime__c);
                }
                else if(objSEP.Minimum_Self_Exclusion_Period__c == '1'){
                    objSEP.Exclusion_End_DateTime__c = System.now().addMonths(12);
                    //system.debug('end date in case of 1 year ' + objSEP.Exclusion_End_DateTime__c);
                }
                else if(objSEP.Minimum_Self_Exclusion_Period__c == '5'){
                    objSEP.Exclusion_End_DateTime__c = System.now().addMonths(60); //2026-09-05 12:10:03
                    //system.debug('end date in case of 5 year ' + objSEP.Exclusion_End_DateTime__c);
                }
                if(sOperationType == 'CREATE'){
                    //system.debug('users context ' + system.now().format()); // user context 9/5/2021 5:40 PM
                    objSEP.Exclusion_Start_DateTime__c = System.now();
                    objSEP.Send_Mail__c = true;
                }
                if(objSEP.Exclusion_End_DateTime__c != null){
                    objSEP.Exclusion_Status_Change_Date__c = System.now();
                    objSEP.Removal_Allowed_DateTime__c = objSEP.Exclusion_End_DateTime__c.addDays(1);
                    objSEP.Send_Mail__c = true;
                    //system.debug('removal date ' + objSEP.Removal_Allowed_DateTime__c);
                }
            }
        }
        catch(Exception e){
            SEP_Utility.SEPExceptionHandler('SEP_ExclusionRequestTriggerHelper','updateEndDateOnRecords','SEP_Exclusion_Consent__c','',sSeverity,e,'');
        } 
    }

    // /********************************************************************************************
    //     METHOD NAME    : sendRemovalMail 
    //     DESCRIPTION    : This method will send removal confirmation mails to the users
    //     RETURN TYPE    : None
    //     PARAMETER      : Trigger.new 
    //     ********************************************************************************************/
    //     public static void sendRemovalMail(List<SEP_Exclusion_Consent__c> lstNewRecords){
    //         try{
    //             Map<id,String> mapConsentIdandPrimaryEmail = new Map<id,String>();
    //             List<SEP_Contact_Detail__c> lstConDatails =  new List<SEP_Contact_Detail__c>();
    //             List<SEP_SendEmailUtility.Requests> Requests = new List<SEP_SendEmailUtility.Requests>();
    //             Set<Id> setofConsentId = new set<Id>();

    //             for(SEP_Exclusion_Consent__c objSEP : lstNewRecords){
    //                 setofConsentId.add(objSEP.id);
    //             } 

    //             lstConDatails = [SELECT Id, Name, Email_Address__c, IsPrimary__c,SEP_Exclusion_Consent__c, SEP_Exclusion_Consent__r.Send_Mail__c FROM SEP_Contact_Detail__c WHERE ( SEP_Exclusion_Consent__c in: setofConsentId AND IsPrimary__c = true AND Email_Address__c != null)];
                
    //             for(SEP_Contact_Detail__c objCD : lstConDatails){
    //                 mapConsentIdandPrimaryEmail.put(objCD.SEP_Exclusion_Consent__c,objCD.Email_Address__c);  
    //             } 

    //             for(SEP_Exclusion_Consent__c objSEP : lstNewRecords){
    //                 SEP_SendEmailUtility.Requests objRequest = new SEP_SendEmailUtility.Requests();
    //                 objRequest.sEmailAddress=mapConsentIdandPrimaryEmail.get(objSEP.id);
    //                 objRequest.consentObj = objSEP;
    //                 Requests.add(objRequest);
    //                 system.debug('Requests@@'+Requests);
                   
    //             }
    //            // SEP_SendEmailUtility.sendConfirmationEmail(Requests);
    //         }
    //         catch(Exception e){
    //             SEP_Utility.SEPExceptionHandler('SEP_ExclusionRequestTriggerHelper','updateEndDateOnRecords','SEP_Exclusion_Consent__c','',sSeverity,e,'');
    //         } 
    //     }
    
}