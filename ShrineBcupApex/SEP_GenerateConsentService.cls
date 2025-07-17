/* DESCRIPTION: This class to expose a rest api to Mulesoft for inbound Consent record insertion    
*
* @AUTHOR:  Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                             27-August-2021                      Created First Version
***************************************************************************************************/
@RestResource(urlMapping='/GenerateConsentRecords')
global with sharing class SEP_GenerateConsentService {
    public static String sRequest = '';
    public static String sResponse = '';
    public static String sErrorMessage = '';
    public static String sFieldNames = '';
    public static final String sSeverity = 'Critical';

    /*
    * Description:      Method that defined what happens when Post request is recieved
    *                   Created the consent record for valid Json and inserts Case Record for invalid Json/error request
    * Param 1:          none
    * Return Type:      none
    *
    */
    @HttpPost
    global static void createConsentRecords() {
        try{
            RestRequest oRequest = RestContext.request;
            SEP_ConsentRequestWrapper oWrapper;
            Set<id> SetCaseId = new Set<id>();
            List<SEP_Exclusion_Case__c> lstCase = new List<SEP_Exclusion_Case__c>();
            List<SEP_Exclusion_Consent__c> lstConsentRecordIterator = new List<SEP_Exclusion_Consent__c>(); 
            Map<String,SEP_ConsentRequestWrapper.Consentwrapper> mapOfUniqueIdandRequestWrapper = new Map<String,SEP_ConsentRequestWrapper.Consentwrapper>();
            Map<String,SEP_Exclusion_Consent__c> mapOfUniqueIdandConsentRecord = new Map<String,SEP_Exclusion_Consent__c>();
            Map<String,List<SEP_Contact_Detail__c>> mapOfUniqueIdandlstContactDetails = new Map<String,List<SEP_Contact_Detail__c>>();
            Map<String,SEP_Exclusion_Consent__c> mapOfUniqueIdandExistingConsentRecords = new Map<String,SEP_Exclusion_Consent__c>();
            List<Integer> lstInvalidRecordIndex = new List<Integer>();
            List<SEP_ConsentRequestWrapper.Consentwrapper> lstConsentRecord = new List<SEP_ConsentRequestWrapper.Consentwrapper>();

            String sRequest = oRequest.requestBody.toString();
            /*
            * Edited by: Michael Mazzotta
            * Date: 2022-06-17
            * Description: Remove logging of SEP Details in the Error Log.
            * This include SSN and other PII information in an unprotected format.
            * Routine can be enabled for testing in a sandbox.
            * if(sRequest.length() > 32766){
            *     SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','','Low',null,''+sRequest.substring(0,32766));
            * }else{
            *     SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','','Low',null,sRequest);
            * }
            */
            List<SEP_Exclusion_Consent__c> lstConsentToUpsert =new List<SEP_Exclusion_Consent__c>();
            List<SEP_Contact_Detail__c> lstExclusionContactDetail = new List<SEP_Contact_Detail__c>();
 
            
            if(sRequest != null){
                oWrapper = (SEP_ConsentRequestWrapper)JSON.deserialize(sRequest,SEP_ConsentRequestWrapper.class);
                for(SEP_ConsentRequestWrapper.Consentwrapper oConsentWrapper: oWrapper.lstConsentWrapper){
                    SEP_Utility.RecordsWrapper objResult= SEP_Utility.generateConsentandChildRecord(oConsentWrapper);
                    if(String.isBlank(objResult.sErrorMessage)){

                        String sUniqueId;
                        Date dtDob =  Date.newInstance( objResult.ObjConsent.Date_Of_Birth__c.year(),  objResult.ObjConsent.Date_Of_Birth__c.month(),  objResult.ObjConsent.Date_Of_Birth__c.day());
                        sUniqueId = objResult.ObjConsent.Unique_Identifier_Number__c+dtDob;
                        sUniqueId = sUniqueId.split(' ')[0];
                        if(mapOfUniqueIdandConsentRecord.containsKey(sUniqueId)){
                          
                            SEP_Exclusion_Case__c objSepCase =  new SEP_Exclusion_Case__c();
                            objSepCase.First_Name__c = oConsentWrapper.sFirstName;
                            objSepCase.Last_Name__c = oConsentWrapper.sLastName;
                            objSepCase.Middle_Name__c = oConsentWrapper.sMiddleName;
                            objSepCase.Date_Of_Birth__c = oConsentWrapper.sDateOfBirth;
                            objSepCase.SSN_Tax_ID_Number__c = oConsentWrapper.sUniqueIdentifierNumber;
                            objSepCase.Current_Residential_Address__c = oConsentWrapper.sAddress;
                            objSepCase.Unit_Apt_Number__c = oConsentWrapper.sUnitApt;
                            objSepCase.City__c = oConsentWrapper.sCity;
                            objSepCase.State__c = oConsentWrapper.sState;
                            objSepCase.Zip_Code__c = oConsentWrapper.sZipCode;
                            objSepCase.I_don_t_have_an_address__c = oConsentWrapper.sAddressNotProvided;
                            objSepCase.Primary_Email_Address__c = oConsentWrapper.sPrimaryEmailAddress;
                            objSepCase.Minimum_Self_Exclusion_Period__c = oConsentWrapper.sMinimumSelfExclusionPeriod;
                            objSepCase.Unverified_Alternate_Email_Address_1__c = oConsentWrapper.sAlternateEmailAddress1;
                            objSepCase.Unverified_Alternate_Email_Address_2__c = oConsentWrapper.sAlternateEmailAddress2;
                            objSepCase.Unverified_Alternate_Email_Address_3__c = oConsentWrapper.sAlternateEmailAddress3;
                            objSepCase.Unverified_Alternate_Email_Address_4__c = oConsentWrapper.sAlternateEmailAddress4;
                            objSepCase.Unverified_Alternate_Email_Address_5__c = oConsentWrapper.sAlternateEmailAddress5;
                            objSepCase.Unverified_Primary_Phone_Number__c = oConsentWrapper.sPrimaryPhoneNumber;
                            objSepCase.Unverified_Alternate_Phone_Number__c = oConsentWrapper.sAlternatePhoneNumber;
                            objSepCase.Overall_Consent_Provided__c = oConsentWrapper.sConsentProvided;
                            objSepCase.Self_Exclusion_Registration_Source__c = oConsentWrapper.sExclusionSource;
                            objSepCase.Online_Gaming_Operator_License__c = oConsentWrapper.sVendorName;
                            objSepCase.Language_Preference__c = oConsentWrapper.sLanguagePreference;
                            objSepCase.Error_Message__c = 'Duplicate Records in Inbound File';
                            objSepCase.Case_Status__c = 'Closed';
                            lstCase.add(objSepCase);
                            
                        }else {

                        mapOfUniqueIdandConsentRecord.put(sUniqueId,objResult.ObjConsent);
                        mapOfUniqueIdandlstContactDetails.put(sUniqueId,objResult.lstContactDetail);
                        lstConsentRecordIterator.add(objResult.ObjConsent);
                        mapOfUniqueIdandRequestWrapper.put(sUniqueId,oConsentWrapper);
                        lstConsentRecord.add(oConsentWrapper);
                        }
                   
                    }else if(objResult.sErrorMessage != 'Null Record'){
                        SEP_Exclusion_Case__c objSepCase =  new SEP_Exclusion_Case__c();
                            objSepCase.First_Name__c = oConsentWrapper.sFirstName;
                            objSepCase.Last_Name__c = oConsentWrapper.sLastName;
                            objSepCase.Middle_Name__c = oConsentWrapper.sMiddleName;
                            objSepCase.Date_Of_Birth__c = oConsentWrapper.sDateOfBirth;
                            objSepCase.SSN_Tax_ID_Number__c = oConsentWrapper.sUniqueIdentifierNumber;
                            objSepCase.Current_Residential_Address__c = oConsentWrapper.sAddress;
                            objSepCase.Unit_Apt_Number__c = oConsentWrapper.sUnitApt;
                            objSepCase.City__c = oConsentWrapper.sCity;
                            objSepCase.State__c = oConsentWrapper.sState;
                            objSepCase.Zip_Code__c = oConsentWrapper.sZipCode;
                            objSepCase.I_don_t_have_an_address__c = oConsentWrapper.sAddressNotProvided;
                            objSepCase.Primary_Email_Address__c = oConsentWrapper.sPrimaryEmailAddress;
                            objSepCase.Minimum_Self_Exclusion_Period__c = oConsentWrapper.sMinimumSelfExclusionPeriod;
                            objSepCase.Unverified_Alternate_Email_Address_1__c = oConsentWrapper.sAlternateEmailAddress1;
                            objSepCase.Unverified_Alternate_Email_Address_2__c = oConsentWrapper.sAlternateEmailAddress2;
                            objSepCase.Unverified_Alternate_Email_Address_3__c = oConsentWrapper.sAlternateEmailAddress3;
                            objSepCase.Unverified_Alternate_Email_Address_4__c = oConsentWrapper.sAlternateEmailAddress4;
                            objSepCase.Unverified_Alternate_Email_Address_5__c = oConsentWrapper.sAlternateEmailAddress5;
                            objSepCase.Unverified_Primary_Phone_Number__c = oConsentWrapper.sPrimaryPhoneNumber;
                            objSepCase.Unverified_Alternate_Phone_Number__c = oConsentWrapper.sAlternatePhoneNumber;
                            objSepCase.Overall_Consent_Provided__c = oConsentWrapper.sConsentProvided;
                            objSepCase.Self_Exclusion_Registration_Source__c = oConsentWrapper.sExclusionSource;
                            objSepCase.Online_Gaming_Operator_License__c = oConsentWrapper.sVendorName;
                            objSepCase.Language_Preference__c = oConsentWrapper.sLanguagePreference;
                            objSepCase.Error_Message__c = objResult.sErrorMessage;
                            objSepCase.Case_Status__c = 'Open';
                            lstCase.add(objSepCase);
                    }
                }
                List<SEP_Exclusion_Consent__c> lstExistingConsentRecords = [SELECT id,First_Name__c,Middle_Name__c,Last_Name__c,Date_Of_Birth__c,Unique_Identifier_Number__c,
                                                                            Address_Not_Provided__c,Address__c,Unit_Apt__c,City__c,State__c,Zip_Code__c,Minimum_Self_Exclusion_Period__c,
                                                                            Consent_Provided__c,Exclusion_Source__c,Consent_Record_Unique_Id__c,Vendor_Name__c,Language_Preference__c,Exclusion_End_DateTime__c,
                                                                            Exclusion_Start_DateTime__c,Retrigger_Notification__c,Exclusion_Status_Change_Date__c,Exclusion_Consent_Status__c,Self_Exclusion_Removal_Source__c FROM SEP_Exclusion_Consent__c WHERE Consent_Record_Unique_Id__c in: mapOfUniqueIdandConsentRecord.keyset()];

                for(SEP_Exclusion_Consent__c objExclusionConsent : lstExistingConsentRecords){
                    mapOfUniqueIdandExistingConsentRecords.put(objExclusionConsent.Consent_Record_Unique_Id__c,objExclusionConsent);
                }
                Integer iIndex = 0;
                for(SEP_Exclusion_Consent__c objConsent : lstConsentRecordIterator){
                    String sUniqueIdentifier = ObjConsent.Unique_Identifier_Number__c+String.ValueOf(objConsent.Date_Of_Birth__c).split(' ')[0];

                    if(mapOfUniqueIdandExistingConsentRecords.containsKey(sUniqueIdentifier)){
                        SEP_Exclusion_Consent__c objExistingConsentRecord = mapOfUniqueIdandExistingConsentRecords.get(sUniqueIdentifier);
                        Datetime dtExclusionDate = System.now();
                        if(objConsent.Minimum_Self_Exclusion_Period__c == '1'){
                            dtExclusionDate = dtExclusionDate.addYears(1);
                        }else if(objConsent.Minimum_Self_Exclusion_Period__c  == '5'){
                            dtExclusionDate = dtExclusionDate.addYears(5);
                        }else if(objConsent.Minimum_Self_Exclusion_Period__c  == 'L'){
                            dtExclusionDate = DateTime.newInstanceGmt(4000, 1, 1, 0, 0, 0);
                        }
                        if(objExistingConsentRecord.Minimum_Self_Exclusion_Period__c == 'L' || dtExclusionDate < objExistingConsentRecord.Exclusion_End_DateTime__c){
                            
                            lstInvalidRecordIndex.add(iIndex);
                            mapOfUniqueIdandlstContactDetails.remove(sUniqueIdentifier);
                            SEP_ConsentRequestWrapper.Consentwrapper oConsentWrapper = mapOfUniqueIdandRequestWrapper.get(sUniqueIdentifier);
                            SEP_Exclusion_Case__c objSepCase =  new SEP_Exclusion_Case__c();
                            objSepCase.First_Name__c = oConsentWrapper.sFirstName;
                            objSepCase.Last_Name__c = oConsentWrapper.sLastName;
                            objSepCase.Middle_Name__c = oConsentWrapper.sMiddleName;
                            objSepCase.Date_Of_Birth__c = oConsentWrapper.sDateOfBirth;
                            objSepCase.SSN_Tax_ID_Number__c = oConsentWrapper.sUniqueIdentifierNumber;
                            objSepCase.Current_Residential_Address__c = oConsentWrapper.sAddress;
                            objSepCase.Unit_Apt_Number__c = oConsentWrapper.sUnitApt;
                            objSepCase.City__c = oConsentWrapper.sCity;
                            objSepCase.State__c = oConsentWrapper.sState;
                            objSepCase.Zip_Code__c = oConsentWrapper.sZipCode;
                            objSepCase.I_don_t_have_an_address__c = oConsentWrapper.sAddressNotProvided;
                            objSepCase.Primary_Email_Address__c = oConsentWrapper.sPrimaryEmailAddress;
                            objSepCase.Minimum_Self_Exclusion_Period__c = oConsentWrapper.sMinimumSelfExclusionPeriod;
                            objSepCase.Unverified_Alternate_Email_Address_1__c = oConsentWrapper.sAlternateEmailAddress1;
                            objSepCase.Unverified_Alternate_Email_Address_2__c = oConsentWrapper.sAlternateEmailAddress2;
                            objSepCase.Unverified_Alternate_Email_Address_3__c = oConsentWrapper.sAlternateEmailAddress3;
                            objSepCase.Unverified_Alternate_Email_Address_4__c = oConsentWrapper.sAlternateEmailAddress4;
                            objSepCase.Unverified_Alternate_Email_Address_5__c = oConsentWrapper.sAlternateEmailAddress5;
                            objSepCase.Unverified_Primary_Phone_Number__c = oConsentWrapper.sPrimaryPhoneNumber;
                            objSepCase.Unverified_Alternate_Phone_Number__c = oConsentWrapper.sAlternatePhoneNumber;
                            objSepCase.Overall_Consent_Provided__c = oConsentWrapper.sConsentProvided;
                            objSepCase.Self_Exclusion_Registration_Source__c = oConsentWrapper.sExclusionSource;
                            objSepCase.Online_Gaming_Operator_License__c = oConsentWrapper.sVendorName;
                            objSepCase.Language_Preference__c = oConsentWrapper.sLanguagePreference;
                            objSepCase.Error_Message__c = 'Invalid Request';
                            objSepCase.Case_Status__c = 'Closed';
                            lstCase.add(objSepCase);
                        }else{
                            SEP_ConsentRequestWrapper.Consentwrapper oConsentWrapper = mapOfUniqueIdandRequestWrapper.get(sUniqueIdentifier);
                            objExistingConsentRecord.First_Name__c = oConsentWrapper.sFirstName;
                            objExistingConsentRecord.Middle_Name__c = oConsentWrapper.sMiddleName;
                            objExistingConsentRecord.Last_Name__c = oConsentWrapper.sLastName;
                            objExistingConsentRecord.Address__c = oConsentWrapper.sAddress;
                            objExistingConsentRecord.Unit_Apt__c = oConsentWrapper.sUnitApt;
                            objExistingConsentRecord.City__c = oConsentWrapper.sCity;
                            objExistingConsentRecord.State__c = oConsentWrapper.sState;
                            objExistingConsentRecord.Zip_Code__c = oConsentWrapper.sZipCode;
                            objExistingConsentRecord.Address_Not_Provided__c = oConsentWrapper.sAddressNotProvided == 'false'? false : true;
                            objExistingConsentRecord.Minimum_Self_Exclusion_Period__c = oConsentWrapper.sMinimumSelfExclusionPeriod;
                            objExistingConsentRecord.Consent_Provided__c = oConsentWrapper.sConsentProvided == 'false'? false : true;
                            objExistingConsentRecord.Exclusion_Source__c = oConsentWrapper.sExclusionSource;
                            objExistingConsentRecord.Vendor_Name__c = oConsentWrapper.sVendorName;
                            objExistingConsentRecord.Language_Preference__c = oConsentWrapper.sLanguagePreference;
                            objExistingConsentRecord.Send_Mail__c = true;
                            objExistingConsentRecord.Exclusion_Consent_Status__c = 'Active';
                            objExistingConsentRecord.Self_Exclusion_Removal_Source__c = 'Not Applicable';
                            objExistingConsentRecord.Retrigger_Notification__c = true;
                            Datetime now = Datetime.now();
                            Integer offset = UserInfo.getTimezone().getOffset(now);
                            Datetime local = now.addSeconds(offset/1000);
                            objExistingConsentRecord.Exclusion_Status_Change_Date__c = System.now(); 
                            if(objExistingConsentRecord.Minimum_Self_Exclusion_Period__c == '1'){
                                objExistingConsentRecord.Removal_Allowed_DateTime__c = System.now().addYears(1).addDays(1);
                                objExistingConsentRecord.Exclusion_End_DateTime__c = System.now().addYears(1);
                                
                            }else if(objExistingConsentRecord.Minimum_Self_Exclusion_Period__c  == '5'){
                                objExistingConsentRecord.Removal_Allowed_DateTime__c = System.now().addYears(5).addDays(1);
                                objExistingConsentRecord.Exclusion_End_DateTime__c = System.now().addYears(5);
                            }else if(objExistingConsentRecord.Minimum_Self_Exclusion_Period__c  == 'L'){
                                objExistingConsentRecord.Exclusion_End_DateTime__c = DateTime.newInstance(4000,System.now().month(),System.now().day());
                                objExistingConsentRecord.Removal_Allowed_DateTime__c = DateTime.newInstance(4000,System.now().month(),System.now().day());
                            }
                            lstConsentToUpsert.add(objExistingConsentRecord);
                        }
                    }else{

                        objConsent.Send_Mail__c = true;
                        objConsent.Self_Exclusion_Removal_Source__c = 'Not Applicable';
                        objConsent.Exclusion_Status_Change_Date__c = System.now();
                        objConsent.Exclusion_Start_DateTime__c = System.now();
                        if(objConsent.Minimum_Self_Exclusion_Period__c == '1'){
                            objConsent.Removal_Allowed_DateTime__c = System.now().addYears(1).addDays(1);
                            objConsent.Exclusion_End_DateTime__c = System.now().addYears(1);
                            
                        }else if(objConsent.Minimum_Self_Exclusion_Period__c  == '5'){
                            objConsent.Removal_Allowed_DateTime__c = System.now().addYears(5).addDays(1);
                            objConsent.Exclusion_End_DateTime__c = System.now().addYears(5);
                        }else if(objConsent.Minimum_Self_Exclusion_Period__c  == 'L'){
                            objConsent.Exclusion_End_DateTime__c = DateTime.newInstance(4000,System.now().month(),System.now().day());
                            objConsent.Removal_Allowed_DateTime__c = DateTime.newInstance(4000,System.now().month(),System.now().day());
                        }
                      
                        lstConsentToUpsert.add(objConsent);
                    }
                    iIndex = iIndex+1;
                }

                lstConsentRecordIterator.clear();
                Integer iCount = 0;
                if(lstInvalidRecordIndex.size() > 0){
                    for(Integer index : lstInvalidRecordIndex){
                        if(iCount > 0){
                            lstConsentRecord.remove(index-iCount);
                        }else{
                            lstConsentRecord.remove(iCount);
                        }
                    }
                }

                if(lstConsentToUpsert.size() > 0){
                    Database.UpsertResult[] srList = Database.Upsert(lstConsentToUpsert, false);
                        for (Database.UpsertResult sr : srList) {
                                if (sr.isSuccess()) {
                                }else{             
                                for(Database.Error err : sr.getErrors()) {
                                
                                    sErrorMessage = sErrorMessage + err.getMessage();
                                
                                    sFieldNames = sFieldNames + err.getFields();
        
                                    SEP_ConsentRequestWrapper.Consentwrapper objConsentWrapper = lstConsentRecord.get(srList.indexof(sr));
                                    SEP_Exclusion_Case__c objSepCase =  new SEP_Exclusion_Case__c();
                                    objSepCase.First_Name__c = objConsentWrapper.sFirstName;
                                    objSepCase.Last_Name__c = objConsentWrapper.sLastName;
                                    objSepCase.Middle_Name__c = objConsentWrapper.sMiddleName;
                                    objSepCase.Date_Of_Birth__c = objConsentWrapper.sDateOfBirth;
                                    objSepCase.SSN_Tax_ID_Number__c = objConsentWrapper.sUniqueIdentifierNumber;
                                    objSepCase.Current_Residential_Address__c = objConsentWrapper.sAddress;
                                    objSepCase.Unit_Apt_Number__c = objConsentWrapper.sUnitApt;
                                    objSepCase.City__c = objConsentWrapper.sCity;
                                    objSepCase.State__c = objConsentWrapper.sState;
                                    objSepCase.Zip_Code__c = objConsentWrapper.sZipCode;
                                    objSepCase.I_don_t_have_an_address__c = objConsentWrapper.sAddressNotProvided;
                                    objSepCase.Primary_Email_Address__c = objConsentWrapper.sPrimaryEmailAddress;
                                    objSepCase.Minimum_Self_Exclusion_Period__c = objConsentWrapper.sMinimumSelfExclusionPeriod;
                                    objSepCase.Unverified_Alternate_Email_Address_1__c = objConsentWrapper.sAlternateEmailAddress1;
                                    objSepCase.Unverified_Alternate_Email_Address_2__c = objConsentWrapper.sAlternateEmailAddress2;
                                    objSepCase.Unverified_Alternate_Email_Address_3__c = objConsentWrapper.sAlternateEmailAddress3;
                                    objSepCase.Unverified_Alternate_Email_Address_4__c = objConsentWrapper.sAlternateEmailAddress4;
                                    objSepCase.Unverified_Alternate_Email_Address_5__c = objConsentWrapper.sAlternateEmailAddress5;
                                    objSepCase.Unverified_Primary_Phone_Number__c = objConsentWrapper.sPrimaryPhoneNumber;
                                    objSepCase.Unverified_Alternate_Phone_Number__c = objConsentWrapper.sAlternatePhoneNumber;
                                    objSepCase.Overall_Consent_Provided__c = objConsentWrapper.sConsentProvided;
                                    objSepCase.Self_Exclusion_Registration_Source__c = objConsentWrapper.sExclusionSource;
                                    objSepCase.Online_Gaming_Operator_License__c = objConsentWrapper.sVendorName;
                                    objSepCase.Language_Preference__c = objConsentWrapper.sLanguagePreference;
                                    objSepCase.Error_Message__c = err.getMessage();
                                    objSepCase.Case_Status__c = 'Open';
                                    lstCase.add(objSepCase);
                                    break;
                                }
                            }
                        }
                    }

                    lstConsentToUpsert.clear();
                    List<SEP_Exclusion_Consent__c> lstBackendConsentRecords = new List<SEP_Exclusion_Consent__c>();
                    
                    lstBackendConsentRecords = [SELECT id,Consent_Record_Unique_Id__c FROM SEP_Exclusion_Consent__c WHERE Consent_Record_Unique_Id__c in: mapOfUniqueIdandlstContactDetails.keyset()];
                    for(SEP_Exclusion_Consent__c objConsent : lstBackendConsentRecords){
                        list<SEP_Contact_Detail__c> lstOfContactDetails = new List<SEP_Contact_Detail__c>();
                        lstOfContactDetails = mapOfUniqueIdandlstContactDetails.get(objConsent.Consent_Record_Unique_Id__c);
                        for(SEP_Contact_Detail__c objChildrecords : lstOfContactDetails){
                            SEP_Contact_Detail__c objConDetailRecords = new SEP_Contact_Detail__c(); 
                            objChildrecords.SEP_Exclusion_Consent__c = objConsent.id;
                            objConDetailRecords = objChildrecords;
                            lstExclusionContactDetail.add(objConDetailRecords);
                        }
                    }
 
                    if(lstExclusionContactDetail.size() > 0){
                        Database.SaveResult[] srListChild = Database.insert(lstExclusionContactDetail, false);
                        for (Database.SaveResult sr : srListChild) {
                                if (sr.isSuccess()) {
                                }else{             
                                for(Database.Error err : sr.getErrors()) {
                                    sErrorMessage = sErrorMessage + err.getMessage();
                                    sFieldNames = sFieldNames + err.getFields();
                                    if(err.getMessage() != 'Duplicate Record Found'){
                                        SEP_Contact_Detail__c objCasechild = lstExclusionContactDetail.get(srListChild.indexof(sr));
                                        SEP_Exclusion_Case__c objSepCase =  new SEP_Exclusion_Case__c();
                                        objSepCase.Contact_Detail_Email__c = objCasechild.Email_Address__c;
                                        objSepCase.Contact_Detail_Is_Primary__c = String.ValueOf(objCasechild.IsPrimary__c);
                                        objSepCase.Contact_Detail_Phone__c= objCasechild.Phone_number__c;
                                        objSepCase.Contact_Detail_Is_Verified__c = String.ValueOf(objCasechild.IsVerified__c);
                                        objSepCase.Error_Message__c = err.getMessage();
                                        objSepCase.SEP_Exclusion_Consent__c = objCasechild.SEP_Exclusion_Consent__c;
                                        objSepCase.Case_Status__c = 'Open';
                                        lstCase.add(objSepCase);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    lstExclusionContactDetail.clear();
                    if(lstCase.size() > 0){
                    Database.SaveResult[] srListCase = Database.insert(lstCase, false);
                        for (Database.SaveResult sr : srListCase) {
                            if (sr.isSuccess()) {
                                SetCaseId.add(sr.getId());  
                            }else{    
                                for(Database.Error err : sr.getErrors()) {        
                                SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','',sSeverity,null,'Error creating case record : '+err.getMessage()+', '+ err.getFields());
                                }
                            }
                        }
                    }
                    if(SetCaseId.size() > 0){
                        SEP_Utility.sendCaseEmail(SetCaseId);
                    }

            }else{
                SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','',sSeverity,null,'Inbound Response : 400,Bad Request,Incorrect input');
                sResponse = populateIntegrationError(null, 400,'Bad Request', 'Incorrect input');

            }
            SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','',sSeverity,null,'Inbound Response : 200,Success');
            sResponse = populateIntegrationError(null, 200, 'Success','Success');   

        }catch(Exception oEException){
            SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','createConsentRecords','','',sSeverity,oEException,'Inbound Response : 500,Internal Server Error '+oEException.getMessage());
            sResponse = populateIntegrationError(null, 500, 'Internal Server Error', oEException.getMessage());
        }
    }

    /*
    * Description:      Method that defined the response of the api
    * Param 1:          Exception object,Integer status code,string message,string description
    * Return Type:      String
    *
    */
    private static String populateIntegrationError(Exception oEx, Integer iStatusCode, String sMessage, String sDescription) {
    try{ 
            RestContext.response.statusCode = iStatusCode;
            RestContext.response.addHeader('Content-Type', 'application/json');
            String sReturnedMssg = String.isBlank(sMessage)?oEx.getMessage():sDescription;
            String sJsonResponse = '{"ResponseMetadata": {"responseText": "'+  sMessage +'", "responseCode": "'+ iStatusCode +'", "responseDescriptionText": "' + sReturnedMssg + '" }}';
            RestContext.response.responseBody = blob.valueOf(sJsonResponse);
            return sJsonResponse;
        }catch(Exception objExp){
        SEP_Utility.SEPExceptionHandler('SEP_GenerateConsentService','populateIntegrationError','','',sSeverity,objExp,'Inbound Response : Error in Response creation method');
        return 'Error in Response';
       }
    }
    
}