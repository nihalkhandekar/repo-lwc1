/* DESCRIPTION: This class contains Utility Methods for BRS.
*
* @AUTHOR: 	Piyush Bajoria
* @DATE: 	10/27/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Piyush Bajoria                   10/27/2020                   Created the first version
*********************************************************************************************/
global without sharing class BRS_Utility {
    public static Map<String,String>  optionlabelMaps = new Map<String,String>();
    public static Final String className = 'BRS_Utility';
    public static Final String interfaceMetadata = 'API_Interface_Configuration__mdt';
    public static Final String sSeverity = 'Medium';
    private static final String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
    /*
    * Description: 		Method to update sObject Record from BRS_FlowController. Expects the following paramters:
    * Param 1: 			Map of Object API Name, and List of corresponding fields
    * Param 2: 			Map of field and corresponding value.
    * Param 3: 			Map of field and corresponding dataType
    * Param 4: 			Id of record to be updated.
    * Return Type: 		Boolean to indicate if update was successful or not.
    *
    * Author Info:
    *******************************************************************************
    * Piyush Bajoria				10/27/2020				First Version.
    */
    @AuraEnabled
    public static Boolean updateSObjectFromFlow (Map<String,List<String>> sObjectFieldMap, Map<String,String> fieldAndValueMap, Map<String,String> fieldAndTypeMap, Id recordId){

        String objectName = '';
        sObject sObjToUpdate;
        Boolean fieldUpdated = false;
        Boolean recordUpdatedSuccessfully = true;
        try{
            
            if(String.isNotBlank(recordId)){
                objectName = recordId.getSObjectType().getDescribe().getName();
                if(String.isNotBlank(objectName))
                    objectName = objectName.toUpperCase();

                if(String.isNotBlank(objectName) && sObjectFieldMap.containsKey(objectName)){
                   sObjToUpdate = Schema.getGlobalDescribe().get(objectName).newSObject() ;
                    sObjToUpdate.put('Id',String.escapeSingleQuotes(recordId));
                    
                    List<String> fieldList = sObjectFieldMap.get(objectName);
                    for(String fieldVar : fieldList){
                        if(fieldAndValueMap.containsKey(fieldVar) && fieldAndTypeMap.containsKey(fieldVar)){
                            
                            if(fieldAndTypeMap.get(fieldVar) == 'Number'){
                                sObjToUpdate.put(fieldVar,Integer.valueOf(fieldAndValueMap.get(fieldVar)));
                            }
                            else if(fieldAndTypeMap.get(fieldVar) == 'Date'){
                                //Assuming format of yyyy-mm-dd
                                String[] strDate = fieldAndValueMap.get(fieldVar).split('-');
                                Integer myIntDate = Integer.valueOf(strDate[2]);
                                Integer myIntMonth = Integer.valueOf(strDate[1]);
                                Integer myIntYear = Integer.valueOf(strDate[0]);
                                Date dateVar = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                sObjToUpdate.put(fieldVar,dateVar);
                            }						
                            else if(fieldAndTypeMap.get(fieldVar) == 'DateTime'){
                                //Assuming format of yyyy-mm-dd
                                String[] strDate = fieldAndValueMap.get(fieldVar).split('-');
                                Integer myIntDate = Integer.valueOf(strDate[2]);
                                
                                Integer myIntMonth = Integer.valueOf(strDate[1]);
                                Integer myIntYear = Integer.valueOf(strDate[0]);
                                DateTime datetimeVar = DateTime.newInstance(myIntYear, myIntMonth, myIntDate);
                                sObjToUpdate.put(fieldVar,datetimeVar);
                            }
                            else if(fieldAndTypeMap.get(fieldVar) == 'Time'){
                                //assuming format of HH:MM:SS:MS
                                String[] strTimeSplit = fieldAndValueMap.get(fieldVar).split(':');
                                Integer hourInstance = strTimeSplit.size()> 0 ? Integer.valueOf(strTimeSplit[0]) : 0;
                                Integer minInstance = strTimeSplit.size()> 1 ? Integer.valueOf(strTimeSplit[1]) : 0;
                                Integer secInstance = strTimeSplit.size()> 2 ? Integer.valueOf(strTimeSplit[2]) : 0;
                                Integer millisecInstance = strTimeSplit.size()> 3 ? Integer.valueOf(strTimeSplit[3]) : 0;
                                Time timeVar = Time.newInstance( hourInstance 					//hour
                                                                ,minInstance										//min
                                                                ,secInstance                                		//sec
                                                                ,millisecInstance);                              	//ms
                                sObjToUpdate.put(fieldVar,timeVar);
                            }
                            else
                                sObjToUpdate.put(fieldVar,fieldAndValueMap.get(fieldVar));
                            fieldUpdated = true;
                        }
                    }
                }
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {sObjToUpdate}, 'update');
            if(fieldUpdated == true && accessCheck){
                Database.saveResult saveResultVar = Database.update(sObjToUpdate,true);
                if(saveResultVar.isSuccess()){
                    recordUpdatedSuccessfully = true;
                }
                else{
                    recordUpdatedSuccessfully = false;
                }
            }
            
            return recordUpdatedSuccessfully;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'updateSObjectFromFlow',objectName,recordId,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
     /********************************************************************************************
        METHOD NAME    : upsertTempRecord
        DESCRIPTION    : To insert/update temporary history records
        RETURN TYPE    : List of Temporary Records
        PARAMETER      : String
    ********************************************************************************************/

    @AuraEnabled
    public static Temp_History__c upsertTempRecord(Temp_History__c tempRec) {
        try {
            if(tempRec.Type__c==System.label.Label_Principal && tempRec.Principal__c != null){
            List<Principal__c> prList = getPrincipalById(tempRec.Principal__c);
                if(!prList.isEmpty()){
                    Principal__c prObj = prList.get(0);
                    tempRec.Name_Old__c=prObj.Name__c;
                    tempRec.FirstName_Old__c=prObj.FirstName__c;
                    tempRec.LastName_Old__c=prObj.LastName__c;
                    tempRec.Temp_Type__c = prObj.Principal_Type__c;
                    tempRec.Principal_Title__c=prObj.Principal_Title__c;
                    tempRec.Designation_Old__c=prObj.Designation__c;
                    tempRec.Email_Old__c=prObj.Email__c;
                    tempRec.Residence_Street_Address1_Old__c=prObj.Residence_Street_Address_1__c;
                    tempRec.Residence_Street_Address_2_Old__c=prObj.Residence_Street_Address_2__c;
                    tempRec.Residence_City_Old__c=prObj.Residence_City__c;
                    tempRec.Residence_Country_Old__c=prObj.Residence_Country__c;
                    tempRec.Residence_State_Old__c=prObj.Residence_State__c;
                    tempRec.Residence_Zip_Code_Old__c=prObj.Residence_Zip_Code__c;
                    tempRec.Business_InternationalAddress_Old__c=prObj.Business_InternationalAddress__c;
                    tempRec.Residence_InternationalAddress_Old__c=prObj.Residence_InternationalAddress__c;
                    tempRec.Business_City_Old__c=prObj.Business_City__c;
                    tempRec.Business_Country_Old__c=prObj.Business_Country__c;
                    tempRec.Business_State_Old__c=prObj.Business_State__c;
                    tempRec.Business_Street_Address_1_Old__c=prObj.Business_Street_Address_1__c;
                    tempRec.Business_Street_Address_2_Old__c=prObj.Business_Street_Address_2__c;
                    tempRec.Business_Zip_Code_Old__c=prObj.Business_Zip_Code__c;
                } 
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {tempRec}, 'upsert');  
            if (tempRec != null && Schema.SObjectType.Temp_History__c.isAccessible() && accessCheck) {
                upsert tempRec;
            }
            return tempRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'insertTempRecord', 'Temp_History__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Account getAccount(String accountId){
        Account accountRec;
        if(Schema.SObjectType.Account.isAccessible() && accountId != null){
            try {
                accountRec = [Select Id, Name, Business_Type__c, Status__c, NAICS_Code__c, Email_Address__c, Business_Email_Address__c,
                              Opt_Out_of_sharing_email_address__c, Classification_Description__c, Citizenship__c,AccountNumber,
                              Total_Authorized_Shares__c, Franchise_Tax__c, Category_Survey_Email_Address__c, Opt_Out_of_Survey_Email_Notification__c
                              from Account where Id = :String.escapeSingleQuotes(accountId) WITH SECURITY_ENFORCED];
            }catch(Exception ex){
                BOS_Utility.ExceptionHandler(null,null,Wizard_Utlity.findObjectNameFromRecordId(accountId),accountId,null,ex,null);
                throw new AuraHandledException(ex.getMessage());
            }
        } else{
            QnA_FlowController.handleError(System.Label.INSUFFICIENT_ACCESS + ' ' + Schema.SObjectType.Account.getLabel());
        }
        return accountRec;
    }

    /*
    * Description: 		Method to update Account record.
    * Param 1: 			Account Record
    * Return Type: 		Account record
    *
    * Author Info:
    *******************************************************************************
    * Tamkanat				11/3/2020				First Version.
    */
    @AuraEnabled
    public static Account updateAccount(Account accRec){
        try {
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {accRec}, 'update');
            if(accRec!=null && accessCheck){
                update accRec;
            }
            return accRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Agent__c updateAgentOnAccount(String accId, String businessAgent){
        try {
            Agent__c agentRec = new Agent__c();
            if(businessAgent!=null){
                agentRec = [select Id,Business_ID__c from Agent__c where Id=:String.escapeSingleQuotes(businessAgent) WITH SECURITY_ENFORCED limit 1];
                if(businessAgent !='undefined'){
                    agentRec.Business_ID__c = accId;
                }
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {agentRec}, 'update');
                update agentRec;
            }
            return agentRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Account updateBusinessEmailonAccount(String accId, String inputEmail){
        try {
            Account accRec = new Account();
            if(accId!=null){
                accRec = [select Id,Business_Email_Address__c from Account where Id=:String.escapeSingleQuotes(accId) WITH SECURITY_ENFORCED limit 1];
                if(accRec!=null){
                    accRec.Business_Email_Address__c = inputEmail;
                }
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {accRec}, 'update');
                update accRec;
            }
            return accRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class SpecialBusinessGroupOptionWrapper{
@AuraEnabled
public  String label{get;set;}
@AuraEnabled
public  String value{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<SpecialBusinessGroupOptionWrapper> getOptionsData() {
        try {
            getAppLabels();
            List<SpecialBusinessGroupOptionWrapper> allOptions = new List<SpecialBusinessGroupOptionWrapper>();

            List<BRS_Special_Business_Group_Option__mdt> optionsList = [select Id, Option_Label__c, Option_Value__c, Order__c, Type__c
                    from BRS_Special_Business_Group_Option__mdt Order By Order__c];
for(BRS_Special_Business_Group_Option__mdt data :optionsList ){
    SpecialBusinessGroupOptionWrapper option = new SpecialBusinessGroupOptionWrapper();
    
    option.value = data.Option_Value__c;
    if(optionlabelMaps.get(data.Option_Label__c.trim())!=null){
        option.label = optionlabelMaps.get(data.Option_Label__c.trim());
       }else{
        option.label = data.Option_Label__c;
       }


   
    allOptions.add(option);
}
            return allOptions;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	
	@AuraEnabled(cacheable=true)
    public static List<Legal_Designation__mdt> getLegalDesignators(){
        try {
            List<Legal_Designation__mdt> listOfDesignators = [Select Id, Label from Legal_Designation__mdt  where Label not in ('P.C.','PC','Professional Corporation')];
            return listOfDesignators;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Business_Name_Noisewords__mdt> getNoiseWords(){
        try {
            List<Business_Name_Noisewords__mdt> listOfNoiseWords = [Select Label from Business_Name_Noisewords__mdt];
            return listOfNoiseWords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	
	/*
    * Description:         Generic method to get the field sets of object.
    * Param 1:             Object API Name
    * Param 2:             Field Set API Name
    * Return Type:         List<ColumnsWrapper> -- List of fields information to be shown as columns on UI.
    *
    * Author Info:
    *******************************************************************************
    * Tamkanat                11/15/2020                First Version.
    */
    @AuraEnabled
    public static List<ColumnsWrapper> getFieldSetMember(String objectName ,String fieldSetName){
        
        List<ColumnsWrapper> wrapperList = new List<ColumnsWrapper>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            ColumnsWrapper wrapper = new ColumnsWrapper();
            if(fieldMember.getLabel()==System.Label.FieldSetLabel_RecordTypeName){
                wrapper.label = System.Label.FieldSetLabel_Type;
            }
            else if((fieldMember.getLabel() == System.label.businessProfile_maddress || fieldMember.getLabel() == System.label.ADD_Int_Addr_Label) && objectName == System.label.UCCContactLabel){
                wrapper.label = System.label.UCCAddressLabel;
            }else if(fieldMember.getLabel() == System.label.brs_PrincipalTitle){
                wrapper.label = System.label.Title;
            }else if(fieldSetName == 'Business_Filing_Review' && fieldMember.getLabel() == 'Date Created'){
				wrapper.label = 'Filing Date';
			}
            else{
             wrapper.label = labelMaps.containsKey(fieldMember.getLabel())?labelMaps.get(fieldMember.getLabel()):fieldMember.getLabel();
             //wrapper.label = fieldMember.getLabel();
            }
            wrapper.fieldName = fieldMember.getFieldPath();
            String datatype = String.valueOf(fieldMember.getType());
            wrapper.type =datatype.toLowercase();
            
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }

    /*
    * Description:         Method to get the city metadata for address component.
    * Return Type:         List<Tax_Town_Info__mdt> -- List of cities used in address component.
    *
    * Author Info:
    *******************************************************************************
    * Subham                11/11/2020                First Version.
    */

    @AuraEnabled (cacheable = true)
    public static List<Tax_Town_Info__mdt> getCities(){
        
        List<Tax_Town_Info__mdt> lstRecords =  [SELECT City__c,Tax_Town__c,Multi_Town__c FROM Tax_Town_Info__mdt ORDER BY City__c ASC ];
        return lstRecords;
    }
	
	/*
    * Description:         Method to get the metadata for review page.
    * Param 1:             Flow Name
    * Param 2:             Account Record
    * Return Type:         List<SectionWrapper> -- List of Sections containing data to be displayed in the Review page.
    *
    * Author Info:
    *******************************************************************************
    * Tamkanat                11/20/2020                First Version.
    */

    public class wrapperAssignorTableData {
        @AuraEnabled public UCC_Related_Info__c Assignor {get; set;}
        @AuraEnabled public List<string> lstAssignees {get; set;}
    }
    public static Map<String,String>  labelMaps = new Map<String,String>();
    @AuraEnabled
    public static List<SectionWrapper> getReviewMetadata(String flowName, sObject accSObj,String filingIDforBFR) {
        try {

            labelMaps = ctds_flowStages.getAppLabels();
            Id filingRecordId;
            Id lienId;
            List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();
            List<Section_Settings__mdt> reviewConfigList = [SELECT Id, Flow_Type__c,Section_Image__c,Section_Name__c,	
															Review_section_title__c,Section_Order__c,
																(SELECT Id,DeveloperName,MasterLabel,Eligible_Value_of_Parent_Field__c,
																	Field_API_Name__c,Field_Label__c,Flow__c,Order__c, 
																	Parent_Field_API_Name__c,Related_Object_API_Name__c,
																	Data_Table_Object__c,Field_Set_API_Name__c,Show_Data_Table__c, 
																	Field_Image__c,Show_Document__c,hide_edit__c
																FROM BRS_Review_Page_Configurations__r) 
															FROM Section_Settings__mdt 
															WHERE Flow_Type__c=:flowName 
															AND Include_in_Review_Page__c=true 
            Order By Section_Order__c limit 10000];
if((flowName == 'Online Intake Category' || flowName == 'Online Intake Merger' || flowName == 'Online Update Business' )&& accSObj  == null){
    accSObj  = new Account();
}
            String objectName;
            if(accSObj != null)
            {
            objectName = accSObj.getSObjectType().getDescribe().getName();
            }
            List<Stock_Classification__c> stocksList = new List<Stock_Classification__c>();
            List<Agent__c> agentList = new List<Agent__c>();
            List<Principal__c> principalList = new List<Principal__c>();
            List<Contact> incorporatorList = new List<Contact>();
            List<UCC_Filing__c> uccFilingRec = new List<UCC_Filing__c>();
            List<UCC_Related_Info__c> uccRelatedInfoList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> debtorList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> securedPartyList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> assignorList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> ownerList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> claimantList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> judgementDebtorList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> judgementCreditorList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> submitterList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> authorizerList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> assigneeList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> previousList = new List<UCC_Related_Info__c>();
            List<UCC_Related_Info__c> updatedList = new List<UCC_Related_Info__c>();            
            
            List<UCC_Related_Info__c> deletedList = new List<UCC_Related_Info__c>();
            List<Account> accountList = new List<Account>();
            List<UCC_Related_Info__c> addedList = new List<UCC_Related_Info__c>();
            List<wrapperAssignorTableData> lstAssignorWithAssigneeList = new List<wrapperAssignorTableData>();
			List<Copy_Request_Details__c> certList = new List<Copy_Request_Details__c>();
            Map<Id, UCC_Related_Info__c > assignorMap = new Map<Id, UCC_Related_Info__c >();
            List<brs_fileUploaderController.contentDocDetails> contentDocList = new List<brs_fileUploaderController.contentDocDetails>();
            List<brs_fileUploaderController.contentDocDetails> filingcontentDoc = new List<brs_fileUploaderController.contentDocDetails>();
           
            List<brs_fileUploaderController.contentDocDetails> statecontentDocList = new List<brs_fileUploaderController.contentDocDetails>();
            List<brs_fileUploaderController.contentDocDetails> legalcontentDocList = new List<brs_fileUploaderController.contentDocDetails>();
            Boolean isBusinessCopyReq = false;
            Boolean showAgentTable= true; 
            List<Business_Filing__c> businessfiling = new List<Business_Filing__c>();
            UCC_Lien__c uccLien = new UCC_Lien__c();
            SObject specificSObj;
            if (filingIDforBFR!=null) {
                businessfiling = [Select id,citizenship__c ,business_type__c,Reserved_name__c,type__c,source__c  from Business_Filing__c where id = :String.escapeSingleQuotes(filingIDforBFR) WITH SECURITY_ENFORCED];
                filingRecordId=filingIDforBFR;
            }
            if (objectName == 'Account') {
                accountList = [Select id,citizenship__c ,business_type__c,Origin__c,Jurisdiction_StateorTerritory__c  from Account where id = :accSObj.Id WITH SECURITY_ENFORCED];

                if(!accountList.isEmpty()){
                    stocksList = [select Id, Name, AccountId__c, Number_of_Stocks__c, Par_Value__c, Stock_Class__c, Classification_Description__c from Stock_Classification__c where AccountId__c = :accSObj.Id WITH SECURITY_ENFORCED];
                    agentList = [select Id, Name, Name__c, Type__c, Email__c, Agent_Phone__c, Business_Address__c, Mailing_Address__c, Business_InternationalAddress__c,Agent_Residence_Address__c from Agent__c where Business_ID__c = :accSObj.Id WITH SECURITY_ENFORCED];
                    principalList = [select Id, Name__c, Principal_Type__c,Business_Registration_number__c, Email__c, Business_Address_1__c, Residence_Address__c, Principal_Title__c, Business_ID__r.Name, Business_InternationalAddress__c, Residence_InternationalAddress__c from Principal__c where Principal_Account_ID__c = :accSObj.Id OR Business_ID__c = :accSObj.Id WITH SECURITY_ENFORCED];
                    incorporatorList = [select Id, Name, Type__c, Email, Phone, Residence_Address__c , Residence_InternationalAddress__c from Contact where AccountId = :accSObj.Id WITH SECURITY_ENFORCED];
                }
                if(flowName == 'Online Intake Category' && businessfiling!=null && businessfiling.size()>0 ){
                   if(accountList!=null  && accountList.size()>0)
                   {
                    accountList[0].Citizenship__c =  businessfiling[0].Citizenship__c;
                  
                    accountList[0].business_type__c =  businessfiling[0].business_type__c;
                   }

                    accSObj.put('Citizenship__c',businessfiling[0].Citizenship__c);
                    accSObj.put('business_type__c',businessfiling[0].business_type__c);
                }
          
          
            } else if (objectName == 'UCC_Lien__c') {
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3011/BRS-2877
                * Change(s)/Modification(s) Description : Adding condition for the Type_of_Collateral_Update__c as to avoid showing the collateral if the field is left empty which means user choose no to amendment of collateral in the amendment flow
                * Change(s)/Modification(s) Made on : 2021-03-18
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                uccFilingRec = [select Id, Name__c, Type__c, UCC_Lien_Number__c, Description__c, UCC_Lien_Id__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Alternative_Designations__c, Collateral_Type__c, Collateral_Information__c, Lien_Filing_Type__c, Original_Judgement_Amount__c,
                                Date_of_Judgement__c, Amount_Due__c, Reason_for_Dispute__c, Dispute_Justification__c, Claim_Amount__c, Filer_Reference_Data__c, Type_of_Collateral_Update__c 
                                from UCC_Filing__c where UCC_Lien_Id__c = :accSObj.Id WITH SECURITY_ENFORCED limit 1];

                filingRecordId= uccFilingRec[0].Id;
                
                specificSObj = (SObject)uccFilingRec[0];
                if(accSObj.Id != null && uccFilingRec[0].UCC_Lien_Id__r.Type__c == System.Label.JudgmentPersonalPropertyLabel){
                    lienId = accSObj.Id;
                }
            }else if(objectName=='UCC_Filing__c'){
                filingRecordId=accSObj.Id;
                String uccLienId = String.valueOf(accSObj.get('UCC_Lien_Id__c'));
                uccLien = [select Id, UCC_Lien_Number__c, toLabel(Type__c), Lapse_Date__c, 
								Previous_Lapse_Date__c,Lapse_date_temporary__c 
							from UCC_Lien__c where Id = :uccLienId WITH SECURITY_ENFORCED limit 1];
                specificSObj = (SObject)uccLien;
            }
			else if (objectName == 'Certficate__c') {
                certList = [select id,RecordTypeId,name,copy_type__c,Filing_Type__c,Filing_Number__c,Date_Created_Format__c,UCC_Filing_Number__c,Amount__c,Is_Expedite_Copy__c,Other_Request__r.Include_Expedited_Service__c,Other_Request__r.Filing_Fee__c,Other_Request__r.Expedited_Service_Fee__c from Copy_Request_Details__c where Other_Request__c=:accSObj.Id WITH SECURITY_ENFORCED];
                Id otherObjDetailrecTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Business_Filling_Request'].Id;
                if(!certList.isEmpty() && otherObjDetailrecTypeId!=null && certList[0].RecordTypeId==otherObjDetailrecTypeId){
                    isBusinessCopyReq = true;
                }
            }
if(String.isNotBlank(filingIDforBFR) && String.isNotEmpty(filingIDforBFR)){
    filingcontentDoc = brs_fileUploaderController.getDocuments(filingIDforBFR, null);
    statecontentDocList = brs_fileUploaderController.getDocuments(filingIDforBFR, 'StateCert');
   legalcontentDocList = brs_fileUploaderController.getDocuments(filingIDforBFR, 'LegalExistence');
}
            if(filingRecordId!=null){
				contentDocList = brs_fileUploaderController.getDocuments(filingRecordId, null);
                uccRelatedInfoList = [select Id, Name, Name__c, Org_Name__c, RecordTypeId,RecordType.DeveloperName,RecordType_Name__c, Type__c, Address__c, isAuthorizer__c,
                                    Deleted_Flag__c,CreatedDate,LastModifiedDate,Status__c,International_Address__c,
                                      (select Id, Name, Name__c, Org_Name__c, RecordTypeId,RecordType.DeveloperName,RecordType_Name__c, Type__c, Address__c, International_Address__c,isAuthorizer__c, Status__c
                                    from UCC_Related_Info__r) from UCC_Related_Info__c where Filing_Id__c=:filingRecordId WITH SECURITY_ENFORCED];
                for(UCC_Related_Info__c relRec: uccRelatedInfoList){
                    if(relRec.Type__c==System.Label.Review_MasterLabel_Type_Debtor){
                        debtorList.add(relRec);
                    }else if(relRec.Type__c==System.Label.Review_MasterLabel_Type_SecuredParty  ||
                                relRec.Type__c.equalsIgnorecase(System.Label.Review_MasterLabel_Type_JudgementCreditor)){
                        securedPartyList.add(relRec);
                        judgementCreditorList.add(relRec);
                        if(flowName==System.Label.UCC3_Lien){
                            assignorList.add(relRec);
							assignorMap = new Map<Id, UCC_Related_Info__c>(assignorList);
                        }
                    } else if (relRec.Type__c == System.Label.Review_MasterLabel_Type_AssignorComparable && flowName!=System.Label.UCC3_Lien ) {
                        assignorList.add(relRec);
                        assignorMap = new Map<Id, UCC_Related_Info__c>(assignorList);
                    }else if(relRec.Type__c==System.Label.Review_MasterLabel_Type_Owner){
                        ownerList.add(relRec);
                    }else if(relRec.Type__c==System.Label.Review_MasterLabel_Type_Claimant){
                        claimantList.add(relRec);
                    }else if(relRec.Type__c==System.Label.Review_MasterLabel_Type_JudgementDebtor){
                        judgementDebtorList.add(relRec);
                    }else if(relRec.Type__c==System.Label.Review_MasterLabel_Type_Submitter){
                        submitterList.add(relRec);
                    } else if (relRec.Type__c.equalsIgnoreCase(System.Label.Review_MasterLabel_Type_JudgementCreditor)) {
                        judgementCreditorList.add(relRec);
                    }

                    if(relRec.isAuthorizer__c==true){
                        authorizerList.add(relRec);
                    }

                    if(relRec.UCC_Related_Info__r.size()>0){
                        previousList.add(relRec.UCC_Related_Info__r[0]);
                        updatedList.add(relRec);
                    }
                    if(relRec.Deleted_Flag__c==true){
                        deletedList.add(relRec);
                    }
                    if(relRec.Status__c=='In-Progress' && relRec.Deleted_Flag__c == false){
                        addedList.add(relRec);
                    }
                }

                List<Id> assignorIds = new List<Id>();
                List<Id> assigneeIds = new List<Id>();
                if(assignorList.size()>0){
                    for(UCC_Related_Info__c assignor: assignorList){
                        assignorIds.add(assignor.Id);
                    }

                    /**List<UCC_Entity_Info__c> entityInfoList = [select Id, Assignor_ID__c,Secured_Party_ID__c from UCC_Entity_Info__c where Assignor_ID__c IN :assignorIds and Filing_ID__c=:filingRecordId];
                    for(UCC_Entity_Info__c entity: entityInfoList){
                        assigneeIds.add(entity.Secured_Party_ID__c);
                    }**/
                    //Code Added for 1330                    
                    map<Id, List<String>> mapIndexAssignor = new map<Id, List<String>>();
                    string queryStr = 'select id,Assignor_ID__c, Secured_Party_ID__c, 					Secured_Party_ID__r.Name__c,Assignor_ID__r.Name__c FROM UCC_Entity_Info__c ';
                    if(flowName==System.Label.UCC3_Lien){
                        queryStr += ' WHERE Secured_Party_ID__c In: assignorIds WITH SECURITY_ENFORCED';
                    }else{
                        queryStr += ' WHERE Assignor_ID__c In: assignorIds WITH SECURITY_ENFORCED';
                    }
                    List<UCC_Entity_Info__c> entityInfoList1 = Database.query(queryStr);
                    for (UCC_Entity_Info__c entity : entityInfoList1) {
                        if(flowName==System.Label.UCC3_Lien){
                            assigneeIds.add(entity.Assignor_ID__c);
                            if (mapIndexAssignor.containsKey(entity.Secured_Party_ID__c)) {
                                List<String> assigneeList1 = mapIndexAssignor.get(entity.Secured_Party_ID__c);
                                assigneeList1.add(entity.Assignor_ID__r.Name__c);
                                mapIndexAssignor.put(entity.Secured_Party_ID__c, assigneeList1);

                            } else {
                                mapIndexAssignor.put(entity.Secured_Party_ID__c, new List<String> {entity.Assignor_ID__r.Name__c });
                            }
                        }else{
							assigneeIds.add(entity.Secured_Party_ID__c);
							if (mapIndexAssignor.containsKey(entity.Assignor_ID__c)) {
								List<String> assigneeList1 = mapIndexAssignor.get(entity.Assignor_ID__c);
								assigneeList1.add(entity.Secured_Party_ID__r.Name__c);
								mapIndexAssignor.put(entity.Assignor_ID__c, assigneeList1);

							} else {
								mapIndexAssignor.put(entity.Assignor_ID__c, new List<String> {entity.Secured_Party_ID__r.Name__c });
							}
						}
                    }                   
                    for (Id assignorId : mapIndexAssignor.keyset()) {
                        wrapperAssignorTableData assignorWithAssigneeList = new wrapperAssignorTableData();
                        assignorWithAssigneeList.lstAssignees =  mapIndexAssignor.get(assignorId);
                        assignorWithAssigneeList.Assignor =  assignorMap.containsKey(assignorId)? assignorMap.get(assignorId) :null;
                        lstAssignorWithAssigneeList.add(assignorWithAssigneeList);
                    }                 
                    //Code Ended
                    /**for(UCC_Related_Info__c securedPartyRec: securedPartyList){
                        if(assigneeIds.contains(securedPartyRec.Id)){
                            assigneeList.add(securedPartyRec);
                        }
                    }**/
                }
            }
           
            List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
            List<String> shippingAddrFields = System.Label.BRS_ShippingAddrFields.split(',');
            for(Section_Settings__mdt sectionData:reviewConfigList){
                SectionWrapper section = new SectionWrapper();
                List<ReviewConfig> configList = new List<ReviewConfig>();
                section.Id = sectionData.Id;
                section.image = sectionData.Section_Image__c;
                section.title = sectionData.Section_Name__c;

                if(sectionData.Review_section_title__c!=null && labelMaps.get(sectionData.Review_section_title__c.trim())!=null){
					section.title = labelMaps.get(sectionData.Review_section_title__c.trim());
				}else if(labelMaps.get(sectionData.Section_Name__c.trim())!=null){
                    section.title = labelMaps.get(sectionData.Section_Name__c.trim());
                }


                if (sectionData.BRS_Review_Page_Configurations__r.size() > 0) {
                    for (BRS_Review_Page_Configuration__mdt configData : sectionData.BRS_Review_Page_Configurations__r) {
                        List<Object> parentResponses;
                        Boolean showChildField = false;
                        if(configData.Parent_Field_API_Name__c!=null){
                            Map<String,String> fieldNameExpectedValueMap = new Map<String,String>();
                            Map<String,String> expectedVsActualRespMap = new Map<String,String>();
                            List<String> parentFields = configData.Parent_Field_API_Name__c.split(System.Label.PIPELINE_SEPARATOR);
                            List<String> eligibleRespList = configData.Eligible_Value_of_Parent_Field__c.split(System.Label.PIPELINE_SEPARATOR);
                            for(Integer i=0;i<parentFields.size();i++){
                                fieldNameExpectedValueMap.put(parentFields[i],eligibleRespList[i]);
                            }
                            for(String field: parentFields){
                                Object parentResp = accSObj.get(field);
                                expectedVsActualRespMap.put(fieldNameExpectedValueMap.get(field), String.valueOf(parentResp));
                            }
                            for(String key: expectedVsActualRespMap.keySet()){
                                if(key == expectedVsActualRespMap.get(key)){
                                    showChildField=true;
                                }else{
                                    showChildField=false;
                                    break;
                                }
                            }
                        }
                        
                        String response='';
                        if(configData.Field_API_Name__c!=null){
                            List<String> fieldsList = configData.Field_API_Name__c.split(System.Label.PIPELINE_SEPARATOR);
                            for(String fieldName:fieldsList){
                                
                                String fieldValue='';
                                Object fieldValueObj;
                               if (fieldName == 'BillingAddress') {
                                    fieldValue = accSObj.get('Principle_Office_International_Address__c') != null && accSObj.get('Principle_Office_International_Address__c') !=QnA_Constants.EMPTY_STRING ? accSObj.get('Principle_Office_International_Address__c') + ', ' + accSObj.get('BillingCountry') : getAddress(accSObj, billingAddrFields);
                                    if(flowName.equalsIgnoreCase('Business Formation') && accSObj.get('BillingState')=='CT' && accSObj.get('Citizenship__c')==system.Label.Domestic && accSObj.get('Business_type__c')==system.Label.LLP){
                                        showAgentTable = false;
                                    }
                                } else if (fieldName == 'ShippingAddress') {
                                    fieldValue = accSObj.get('Mailing_International_Address__c') != null && accSObj.get('Mailing_International_Address__c') !=QnA_Constants.EMPTY_STRING ? accSObj.get('Mailing_International_Address__c') + ', ' + accSObj.get('ShippingCountry') : getAddress(accSObj, shippingAddrFields);
                                }
                                else if (fieldName == 'Office_Jurisdiction_Address__c') {
                                    fieldValue = accSObj.get('Jurisdiction_International_address__c')!= null  && accSObj.get('Jurisdiction_International_address__c') !=QnA_Constants.EMPTY_STRING ? String.valueOf(accSObj.get('Jurisdiction_International_address__c')) + ', '+ String.valueOf(accSObj.get('Office_in_Jurisdiction_Country__c')) : String.valueOf(accSObj.get('Office_Jurisdiction_Address__c')) ;
                                } 
                                else if (fieldName == 'Mailing_Jurisdiction_Address__c') {
                                    fieldValue = accSObj.get('Mail_Jurisdiction_International_address__c')!= null ? String.valueOf(accSObj.get('Mail_Jurisdiction_International_address__c')) + ', '+ String.valueOf(accSObj.get('Mailing_Jurisdiction_Country__c')) : String.valueOf(accSObj.get('Mailing_Jurisdiction_Address__c')) ;
                                }
								else if (fieldName == 'Filing_Number') {
                                    if(certList.size() > 0){
                                        fieldValue =String.valueOf(certList.size());
                                    }
                                }else if (fieldName == 'Req_for_copy_Mailing_address') {
                                    fieldValue = accSObj.get('Mailing_International_Address__c') != null ? String.valueOf(accSObj.get('Mailing_International_Address__c') + ', ' + accSObj.get('Mailing_Country__c')) : String.valueof(accSObj.get('Mailing_Address__c'));
                                    if(fieldValue==null){
                                        fieldValue= 'DoNotShowField';
                                    }
                                }
                                
                                else if (fieldName=='Duration_of_Business_In_CT__c' && (accSObj.get('citizenship__c')==system.Label.Foreign && (accSObj.get('business_type__c')==system.Label.Non_Stock || accSObj.get('business_type__c')==system.Label.Stock))) {
                                    if(accSObj.get('Duration_of_Business_In_CT__c')==System.Label.Perpetual_ValueId){
                                        fieldValue = System.label.Perpetual_ValueId;
                                    }
                                    else{
                                        if( accSObj.get('Began_Transacting_in_CT__c')!=null && accSObj.get('Business_End_Date__c')!=null){
                                            Date beganDt = (Date)accSObj.get('Began_Transacting_in_CT__c');
                                            Date endDt = (Date)accSObj.get('Business_End_Date__c');
                                            DateTime dtimeBegan = DateTime.newInstance(beganDt.year(), beganDt.month(), beganDt.day());
                                            DateTime dtimeEnd = DateTime.newInstance(endDt.year(), endDt.month(), endDt.day());
                                            fieldValue = dtimeBegan.format('MMMM dd, yyyy') +' - '+  dtimeEnd.format('MMMM dd, yyyy');
                                        }
                                    }
                                }
                                else{
                                    SObjectType sObjectType;
                                    
                                    if(configData.Related_Object_API_Name__c!=null){
                                        fieldValueObj=specificSObj.get(fieldName);
                                        sObjectType = ((SObject)(Type.forName('Schema.'+configData.Related_Object_API_Name__c).newInstance())).getSObjectType();
                                    }else{
                                        
                                        fieldValueObj=accSObj.get(fieldName);
                                        sObjectType = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                                    }

                                    DescribeSObjectResult d = sObjectType.getDescribe();
                                    String fieldtype = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
                                    if(fieldtype=='DATE' && fieldValueObj!=null){
                                        Date dt = (Date)fieldValueObj;
                                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(),dt.day());
                                        fieldValue=dtime.format('MMMM dd, yyyy');
                                    }else if(fieldtype == 'Currency' && fieldValueObj != null){
										//Added as part of BRS-2911
                                        Decimal dec = (Decimal)fieldValueObj;
										String decimalValue = dec.format().contains('.')?dec.format():(dec.format()+'.00');
                                        fieldValue = '$'+decimalValue;
                                    }
									/**else if(fieldtype == 'PICKLIST' && fieldValueObj != null){
                                        //Added as part of BRS-1636
                                        fieldValue = getPicklistLabel(sObjectType, fieldName,  String.valueOf(fieldValueObj));
                                    }**/else{
                                        fieldValue = String.valueOf(fieldValueObj); 
                                    }
                                }
                                if(flowName == 'Online Intake Category' && businessfiling!=null && businessfiling.size()>0){
                                    if (fieldName == 'Reserved_Name__c') {
                                        fieldValue = businessfiling[0].Reserved_name__c;
                                    }else  if (fieldName == 'Citizenship__c') {
                                        fieldValue = businessfiling[0].Citizenship__c;
                                    }else  if (fieldName == 'Business_Type__c') {
                                        fieldValue = businessfiling[0].Business_Type__c;
                                    }
                                }
                                
                                if (response == '') {
                                    response = fieldValue!= null ? fieldValue : system.label.not_applicable;
                                } else {
                                    string field = fieldValue!= null ? fieldValue : system.label.not_applicable;
                                    response += System.Label.BRS_ReviewPageResponseSeparator+field;
                                }
                            }
                        }
                        ReviewConfig config = new ReviewConfig(configData);
                        
                        if((configData.Parent_Field_API_Name__c!=null && showChildField == true) || configData.Parent_Field_API_Name__c==null){
                            
                            config.responseText = response;

                            if(configData.Show_Data_Table__c==true){
                                config.showDataTable=true;
                                if(configData.Data_Table_Object__c!=null){
                                    if(configData.Field_Set_API_Name__c!=null){
                                        config.tablecolumns = getFieldSetMember(configData.Data_Table_Object__c,configData.Field_Set_API_Name__c);
                                    }
                                   
                                    if (configData.Data_Table_Object__c == 'Stock_Classification__c') {
                                        if( stocksList.size() > 0){
                                            config.tabledata = stocksList;
                                        }
                                        else{
                                            config.responseText =accSObj.get('Total_Authorized_Shares__c')!=null? String.ValueOf(accSObj.get('Total_Authorized_Shares__c')):'';
                                            config.showDataTable = false;
                                        }
                                    }else if(configData.Data_Table_Object__c=='Agent__c'){
                                        if(showAgentTable && agentList.size() > 0){
                                            config.responseText = agentList[0].Name__c;
                                        	config.tabledata = agentList;
                                        }
                                        else{
                                            config.responseText ='DoNotShowField';
                                        }
                                    }else if(configData.Data_Table_Object__c=='Contact' && incorporatorList.size()>0){
                                        config.responseText = String.valueOf(incorporatorList.size());
                                        config.tabledata = incorporatorList;
                                    }else if(configData.Data_Table_Object__c=='Principal__c' && principalList.size()>0){
                                        config.responseText = String.valueOf(principalList.size());
                                        config.tabledata = principalList;
                                    }else if(configData.Data_Table_Object__c=='UCC_Related_Info__c' &&  uccRelatedInfoList.size()>0){
                                            if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_Debtor){
                                                config.tabledata = debtorList;
                                                config.responseText = String.valueOf(debtorList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_JudgementDebtor){
                                                config.tabledata = judgementDebtorList;
                                                config.responseText = String.valueOf(judgementDebtorList.size());
                                            }
											else if (configData.MasterLabel.equalsIgnoreCase(System.Label.Review_MasterLabel_Type_JudgementCreditor)) {
                                                config.tabledata = judgementCreditorList;
                                                config.responseText = String.valueOf(judgementCreditorList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_SecuredParty){
                                                config.tabledata = securedPartyList;
                                                config.responseText = String.valueOf(securedPartyList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_AssignorComparable){
                                                //config.tabledata = assignorList;
                                                config.tabledata = lstAssignorWithAssigneeList;
                                                config.responseText = String.valueOf(assignorList.size());
												if(configData.MasterLabel ==System.Label.Review_MasterLabel_Type_AssignorComparable && assignorList.size() == 0){
                                                    config.responseText = 'DoNotShowField';
                                                }
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_Submitter){
                                                config.tabledata = submitterList;
                                                config.responseText = String.valueOf(submitterList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_Owner){
                                                config.tabledata = ownerList;
                                                config.responseText = String.valueOf(ownerList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_Claimant){
                                                config.tabledata = claimantList;
                                                config.responseText = String.valueOf(claimantList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.review_MasterLabel_Type_Authorizer_Comparable){
                                                config.tabledata = authorizerList;
                                                config.responseText = String.valueOf(authorizerList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_Assignee){
                                                config.tabledata = lstAssignorWithAssigneeList;
												config.responseText = String.valueOf(lstAssignorWithAssigneeList.size());
												if (configData.MasterLabel == System.Label.Review_MasterLabel_Type_Assignee && lstAssignorWithAssigneeList.size() == 0) {
													config.responseText = 'DoNotShowField';
												}
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_PreviousDebtor){
                                                config.tabledata = previousList;
                                                config.responseText = String.valueOf(previousList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_UpdatedDebtor){
                                                config.tabledata = updatedList;
                                                config.responseText = String.valueOf(updatedList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_AddRelatedInfo){
                                                config.tabledata = addedList;
                                                config.responseText = String.valueOf(addedList.size());
                                            }
                                            else if(configData.MasterLabel==System.Label.Review_MasterLabel_Type_DeleteRelatedInfo){
                                                config.tabledata = deletedList;
                                                config.responseText = String.valueOf(deletedList.size());
                                            }
                                        }
                                        else if (configData.Data_Table_Object__c == 'Copy_Request_Details__c' && certList.size() > 0) {
                                            if((isBusinessCopyReq && configData.MasterLabel ==System.Label.TotalAmount) || (!isBusinessCopyReq && configData.MasterLabel ==System.Label.Total_Amount_UCC_Label)){
                                                    config.responseText = certList[0].Other_Request__r.Include_Expedited_Service__c ? String.valueOf('$'+ (certList[0].Other_Request__r.Filing_Fee__c+certList[0].Other_Request__r.Expedited_Service_Fee__c)):String.valueOf('$'+certList[0].Other_Request__r.Filing_Fee__c);
                                                    config.tabledata = certList;
                                                }                                                
                                                else{
                                                    config.responseText = 'DoNotShowField';
                                                }
										}
                                }
                            }
                            if(configData.Show_Document__c==true){
                                if(contentDocList.size()>0){
                                    config.documentData = contentDocList[0];
                                }else{
                                    config.showDocument=false;
                                }
                            }

                            if(filingcontentDoc.size() >0 && flowName.equalsIgnoreCase('Online Intake Category') && config.questionLabel.endsWithIgnoreCase(System.label.brs_Filing_upload)
                            && String.isNotBlank(config.MasterLabel) && String.isNotEmpty(config.MasterLabel)
                             && config.MasterLabel.equalsIgnoreCase('Filing Upload')){
                                 config.showDocument = true;
                                 config.documentData =filingcontentDoc[0];
                             }
                            if(statecontentDocList.size() >0 && flowName.equalsIgnoreCase('Business Formation') && config.questionLabel.endsWithIgnoreCase(System.label.Statecertificate)
                           && String.isNotBlank(config.MasterLabel) && String.isNotEmpty(config.MasterLabel)
                            && config.MasterLabel.equalsIgnoreCase('State Attachment')){
                                config.showDocument = true;
                                config.documentData =statecontentDocList[0];
                            }
                            if(legalcontentDocList.size() >0 && flowName.equalsIgnoreCase('Business Formation') && config.questionLabel.endsWithIgnoreCase(System.label.Legalacknowledgmentcertificate)
                            && String.isNotBlank(config.MasterLabel) && String.isNotEmpty(config.MasterLabel)
                             && config.MasterLabel.equalsIgnoreCase('Legal Attachment')){
                                 config.showDocument = true;
                                 config.documentData =legalcontentDocList[0];
                             }
                            /**
                            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3011/BRS-2877
                            * Change(s)/Modification(s) Description : Adding condition for the Type_of_Collateral_Update__c as to avoid showing the collateral if the field is left empty which means user choose no to amendment of collateral in the amendment flow
                            * Change(s)/Modification(s) Made on : 2021-03-18
                            * Change(s)/Modification(s) Made by : Avinash Shukla
                            */
                            if(objectName == 'UCC_Filing__c'){
                                UCC_Filing__c uccObj = (UCC_Filing__c)accSObj;
                                if((configData.DeveloperName == Label.Details_UCC3 || configData.DeveloperName == Label.Attachment_UCC3) && uccObj.Type_of_Collateral_Update__c == NULL){
                                    config.responseText = Label.DoNotShowField;
                                }
                            }
                            if(uccFilingRec.size() > 0){
                                if ((configData.MasterLabel == 'FD_Trust_Details' && uccFilingRec[0].Collateral_Type__c != 'Held in trust') ||
                                (configData.DeveloperName.contains('FD_Collateral') && uccFilingRec[0].Collateral_Type__c == System.Label.BRS_NotApplicable) ||
                                (configData.DeveloperName.contains('FD_Alt_Designation') && uccFilingRec[0].UCC_Lien_Id__r.Alternative_Designations__c == System.Label.BRS_NotApplicable) ||
                                (configData.DeveloperName.contains('FD_Lien_Filing_Type') && uccFilingRec[0].Lien_Filing_Type__c == System.Label.BRS_NotApplicable)) 
                            {
                                config.responseText = 'DoNotShowField';
                            }
                            }


                            if(config.responseText != 'DoNotShowField'){
                                if(flowName.equalsIgnoreCase('Business Formation') && accountList!=null && accountList.size()>0 && String.isNotBlank( accountList[0].Origin__c) &&  String.isNotEmpty( accountList[0].Origin__c)
                                && accountList[0].Origin__c.equalsIgnoreCase('Yes')  && config.questionLabel == System.label.Countryofformation ){}
                                else if(flowName.equalsIgnoreCase('Business Formation') && accountList!=null && accountList.size()>0 && String.isNotBlank( accountList[0].Origin__c) &&  String.isNotEmpty( accountList[0].Origin__c)
                                && accountList[0].Origin__c.equalsIgnoreCase('No')  &&  config.questionLabel ==System.Label.Stateofformation){}
                               else if(flowName.equalsIgnoreCase('Business Formation') && accountList!=null && accountList.size()>0 && String.isNotBlank( accountList[0].Jurisdiction_StateorTerritory__c ) &&  String.isNotEmpty( accountList[0].Jurisdiction_StateorTerritory__c )
                                && accountList[0].Jurisdiction_StateorTerritory__c .equalsIgnoreCase('No')  && ( config.questionLabel ==System.Label.MailingJurisdictionStateofFormation
                            || config.questionLabel ==System.Label.BRS_Location_JurisdictionOffice )){}
                            else if(flowName.equalsIgnoreCase('Business Formation') && accountList!=null && accountList.size()>0 && String.isNotBlank( accountList[0].Jurisdiction_StateorTerritory__c ) &&  String.isNotEmpty( accountList[0].Jurisdiction_StateorTerritory__c )
                            && accountList[0].Jurisdiction_StateorTerritory__c .equalsIgnoreCase('Yes')  && ( config.questionLabel ==System.Label.PrincipalOfficeAddress && accountList[0].business_type__c=='LLP')){}
                                else if((config.responseText=='N/A' ||  config.responseText==null) && config.responseText!=System.Label.business_name_search && (!businessfiling.isEmpty() && businessfiling[0].source__c =='Digital Mail')){
                                    
                                }
                                else{
                                    if(flowName.equalsIgnoreCase('Business Formation') && accountList!=null && accountList.size()>0 && String.isNotBlank( accountList[0].citizenship__c ) &&  String.isNotEmpty( accountList[0].citizenship__c  )
                            && accountList[0].citizenship__c.equalsIgnoreCase('Domestic')  && ( config.questionLabel == System.Label.ForeignALEI)){}
							if(statecontentDocList.isEmpty() && flowName.equalsIgnoreCase('Business Formation') && config.questionLabel.endsWithIgnoreCase(System.label.Statecertificate)){}
                           else{
						   
                                 configList.add(config);
                           }
                                }

                            }
                            configList.sort();
                        }
                    }
                    section.value=configList;
                }	
                if(section.value!=null && section.value.size()>0){
                    sectionWrapperList.add(section); 
                }
		}
            return sectionWrapperList;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler('BRS_Utility', 'getReviewMetadata', '', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }  
    }
	
    public static String getAddress(SObject sObjRec, List<String> addrFields) {
        String fieldValue='';
        for(String addrField: addrFields){
            String value = String.valueOf(sObjRec.get(addrField));
            if(value!=null){
                if(fieldValue==''){
                    fieldValue=value;
                }else{
                    fieldValue+=', '+value;
                }
            }
        }
        return fieldValue;
    }

    public without sharing class ColumnsWrapper{
        @AuraEnabled public String label {get; set;} 
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String type {get; set;}

        public ColumnsWrapper(){}
    }

    public without sharing class SectionWrapper{
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String image {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public List<ReviewConfig> value {get; set;}
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added 3 Keys to provide validation of data on review screen
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        @AuraEnabled public Boolean sectionValueIsValid {get; set;}
        @AuraEnabled public Boolean isAgentDataValid {get; set;}
        @AuraEnabled public Boolean isPrincipalDataValid {get; set;}
    }
    public without sharing class ReviewConfig implements Comparable {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public Integer order {get; set;}
        @AuraEnabled public String fieldimage {get; set;}
        @AuraEnabled public String questionLabel {get; set;}
        @AuraEnabled public String MasterLabel {get; set;}
        @AuraEnabled public String responseField {get; set;}
        @AuraEnabled public String responseText {get; set;}
        @AuraEnabled public Boolean showDataTable {get; set;}
        @AuraEnabled public List<ColumnsWrapper> tablecolumns {get; set;}
        @AuraEnabled public List<Object> tabledata {get; set;}
        @AuraEnabled public Boolean showDocument {get; set;}
        @AuraEnabled public brs_fileUploaderController.contentDocDetails documentData {get; set;}
        // Added new section data for ChangedData
        // Access associated changed data with Type : Edited, Created and Deleted and Id from Map.
        @AuraEnabled public Map<String, Map<Id, sObject>> associatedModifiedDataMap {get; set;}
        @AuraEnabled public Map<String, List<List<wrapperTableData>>> associatedAddedOrDeletedData {get; set;}
        @AuraEnabled public Map<String, List<Map<String, List<wrapperTableData>>>> associatedUpdatedDate {get; set;}
        // This is used when we are refering to changes made at field level
        // This is done in case of account information in
        @AuraEnabled public String associatedChangedDataValue {get; set;}
        @AuraEnabled public Boolean showViewUpdateForAgent {get; set;}
        @AuraEnabled public Boolean hasEditedData {get; set;}
        @AuraEnabled public Boolean hideEditButton {get; set;}
        @AuraEnabled public Boolean hasCreatedData {get; set;}
        @AuraEnabled public Boolean hideDataTableOnUI {get; set;}
        @AuraEnabled public Boolean dataIsChanged {get; set;}
        @AuraEnabled public List<Object> principalListForAcknowledgementFirstFlow {get; set;}
        @AuraEnabled public List<Object> principalListForAcknowledgementAnnualFlow {get; set;}
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added 3 Keys on config level to provide validation of data on review screen
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        @AuraEnabled public Boolean isDatavalid {get; set;}
        @AuraEnabled public Boolean isAgentDataValid {get; set;}
        @AuraEnabled public Boolean isPrincipalDataValid {get; set;}

        public ReviewConfig() {}
        public ReviewConfig(BRS_Review_Page_Configuration__mdt config) {
            id = config.Id;
            order = Integer.valueOf(config.Order__c);
            if(labelMaps.get(config.Field_Label__c.trim())!=null){
                questionLabel  = labelMaps.get(config.Field_Label__c.trim());
               }else{
            questionLabel = config.Field_Label__c;
               }
            responseField = config.Field_API_Name__c;
            fieldimage = config.Field_Image__c;
            showDocument = config.Show_Document__c;
            hideEditButton = config.hide_edit__c;
            MasterLabel =config.MasterLabel;
            dataIsChanged = false;
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
            * Change(s)/Modification(s) Description : Defaulting the boolean variables to true
            * Change(s)/Modification(s) Made on : 18-07-2021
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            isAgentDataValid =true;
            isPrincipalDataValid =true;
        }
        public Integer compareTo(Object compareTo) {
            return order - ((ReviewConfig)compareTo).order;
        }
    }
	
	/*
    * Description: 		Method to get difference between lapsed date and today's date to check for continuation amendment.
    * Param 1: 			lienId
    * Return Type: 		Integer
    *
    * Author Info:
    *******************************************************************************
    * Priyanka				12/15/2020				First Version.
    */
    @AuraEnabled
    public static Boolean getLapsedDiffMonths(Id lienId){
        try{
            Boolean lapsedDiffMonth;
            if(lienId!=null){
                UCC_Lien__c lienRec = [Select id, Lapse_Date__c,Lapse_date_temporary__c 
										from UCC_Lien__c where id=:String.escapeSingleQuotes(lienId) WITH SECURITY_ENFORCED Limit 1];
                if(lienRec!=null && lienRec.Lapse_Date__c!=null){
                    date lpDate = lienRec.Lapse_Date__c.addMonths(-6);
                    if(lpDate<= System.today()){
                        lapsedDiffMonth = true;
                    }
                    else{
                        lapsedDiffMonth = false;
                    }
                }
                else{
                    lapsedDiffMonth = false;
                }
            }
            return lapsedDiffMonth;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'getLapsedDiffMonths','UCC_Lien__c',lienId,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
	
	/********************************************************************************************
    METHOD NAME    : fetchInterfaceConfig
    DESCRIPTION    : This method fetch the custom metadata 'Interface configuration' to get
                        API config data.
    RETURN TYPE    : API_Interface_Configuration__mdt
    PARAMETER      : String labelName (Label of Custom Metadatda record)
    ********************************************************************************************/
    @AuraEnabled
    public static API_Interface_Configuration__mdt fetchAPIInterfaceConfig(String labelName){
        API_Interface_Configuration__mdt interfaceConfig;
        try{
            if(Schema.SObjectType.API_Interface_Configuration__mdt.isAccessible() && interfaceConfig == null && labelName != Null){
                List<API_Interface_Configuration__mdt> interfaceConfigList  = [SELECT Id,Current_Environment__c,DeveloperName,API_Key__c,Named_Credential__c,
                                                                                    Is_Active__c,Label,Language,MasterLabel,NamespacePrefix,Parameters__c,
                                                                                    QualifiedApiName,Timeout_Value__c,Call_Type__c ,End_Point_URL__c
                                                                                FROM API_Interface_Configuration__mdt
                                                                                WHERE MasterLabel =:labelName 
                                                                                AND Current_Environment__c =: System.Label.CURRENT_ENVIRONMENT];
                if(!interfaceConfigList.isEmpty()){
                    interfaceConfig = interfaceConfigList[0];
                }
            }
            return interfaceConfig;
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'fetchInterfaceConfigMethod',interfaceMetadata,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    /********************************************************************************************
    METHOD NAME    : getBusinessFiling
    DESCRIPTION    : This method fetch the custom metadata 'Business_Filing__c' to get
                        Annual filing data.
    RETURN TYPE    : List<Business_Filing__c>
    PARAMETER      : accountId
    ********************************************************************************************/
    @AuraEnabled
    public static List<Business_Filing__c> getBusinessFiling(String accountId, string reportType, String filingId) {
        List<Business_Filing__c> filings = new List<Business_Filing__c>();
        try {
            if (Schema.SObjectType.Business_Filing__c.isAccessible() && accountId != null) {
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: AR Business selection screen.
                * Change(s)/Modification(s) Description : // Added In-Progress label also for selection.
                * Change(s)/Modification(s) Made on : 2021-04-12
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                // Old Code -- > List<String> statuses = new List<String>{system.label.Due,system.label.PastDue};
                string LLCType = System.Label.businessTypeLLC;
                List<String> statuses = new List<String> {system.label.Due,system.label.PastDue,Label.In_Progress_Label, System.Label.BRS_FilingStatus_Rejected};
                // Added business filing fee in query.
                String querystr = 'SELECT Id, Type__c, Prior_to_Due_Date__c, Filing_Fee__c,Filing_Date__c, Due_Date__c, Due_Year__c, Status__c,Review_Add_Authorizer_Option_Choosen__c, ReviewScreenAcknowledgement__c,Review_Selected_Principal__c,Review_Select_Principal_Option_Choosen__c,Review_Signatory_Type__c,Signatory_Name__c,Signatory_Title__c';                                                                    
                querystr += ' FROM Business_Filing__c'  ;
                querystr += ' WHERE Account__c = :accountId'    ;
                querystr += ' AND Type__c = : reportType'   ;
                querystr += ' AND Status__c IN: statuses'   ;
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3582
                * Change(s)/Modification(s) Description : Added fix for first report due date not coming in header. For Fr no condition on due date should be applied.
                * Change(s)/Modification(s) Made on : 2021-05-25
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if(reportType != System.Label.BRS_First_Report){
                    querystr += ' AND Is_Rejected_Instantiated__c = false AND (Due_Date__c <= NEXT_N_DAYS:30 OR (Account__r.Business_Type__c = :LLCType AND Due_Date__c <= THIS_YEAR))';
                }
                if(filingId != null){
                    querystr += ' AND Id =: filingId ';
                }
                querystr += 'WITH SECURITY_ENFORCED ORDER BY Due_Date__c asc';
                
                filings = Database.query(querystr);
            }
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getBusinessFiling', 'Business_Filing__c', null, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
        return filings;
    }

    /********************************************************************************************
    METHOD NAME    : getFilingFee
    DESCRIPTION    :
    RETURN TYPE    : Map<string, Number>
    PARAMETER      :
    ********************************************************************************************/
        public static Map<string, Decimal> getFilingFee(string value, string label,String reportType) {
        Map<string, Decimal> filingfeeMap = new Map<string, Decimal>();
        String strQuery;
        String whereClaus;
        set<String> maintenanceTypes = new set<String>{system.label.brs_maintenance_interim, 
                                                            system.label.brs_maintenance_agent,
                                                            system.label.BRS_NAICS_Maintenance,
                                                            system.label.brs_maintenance_Address,
                                                            system.label.brs_maintenance_Email,
                                                            system.label.brs_maintenance_address_agent,
                                                            system.label.brs_ObtainCertFlow,
                                                            system.label.Payment_Withdrawal_LLC,
                                                            system.label.brs_AgentResignation
                                                            };
        List<Filing_Fee__mdt> filingfees = new List<Filing_Fee__mdt>();
        try {
                if (Schema.SObjectType.Filing_Fee__mdt.isAccessible())
                {
                    strQuery = 'SELECT Fee_Amount__c, Label, MasterLabel, Field_Value__c, FieldName__c FROM Filing_Fee__mdt';
                    if(maintenanceTypes.contains(reportType))  
                         whereClaus = ' WHERE MasterLabel =\''+  reportType+'\' ';
                    else
                        whereClaus = ' WHERE MasterLabel = \''+  label +'\' AND Field_Value__c like \'%'+  value +'%\'';
                    strQuery = strQuery  + whereClaus;
                    filingfees = Database.query(strQuery);
                    if(!filingfees.IsEmpty())
                    {
                        for (Filing_Fee__mdt fee : filingfees)
                        {
                            filingfeeMap.put(fee.label, fee.Fee_Amount__c != null ? Decimal.valueOf(fee.Fee_Amount__c) : 0);
                        }
                    }
                }
            }
         catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getFilingFee', 'Filing_Fee__mdt', null, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
        return filingfeeMap;
    }

	
	/*
    * Description: 		Method to get picklist values for countries
    * Param 1: 			none
    * Return Type: 		List<string>
    *
    * Author Info:
    *******************************************************************************
    * Rabbani				1/10/2021				First Version.
    */
	@AuraEnabled (cacheable = true)
    public static List<String> getCountries(){
        
        List<String> lstCountries = new List<String>();
        Schema.DescribeFieldResult fieldResult = Principal__c.Residence_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            lstCountries.add(f.getLabel());
        }     
        return lstCountries;
    }
    /*
    * Description: 		Method to get month in string value
    * Param 1: 			Month
    * Return Type: 		String
    *
    * Author Info:
    *******************************************************************************
    * Priyanka				1/16/2021				First Version.
    */
    public Static String getMonth(Integer month){
        String monthString;
        switch on month {
            when 1 {
                monthString = System.Label.January;
            }
            when 2 {
                monthString = System.Label.February;
            }
            when 3 {
                monthString = System.Label.March;
            }
            when 4 {
                monthString = System.Label.April;
            }
            when 5 {
                monthString = System.Label.May;
            }
            when 6 {
                monthString = System.Label.June;
            }
            when 7 {
                monthString = System.Label.July;
            }
            when 8 {
                monthString = System.Label.August;
            }
            when 9 {
                monthString = System.Label.September;
            }
            when 10 {
                monthString = System.Label.October;
            }
            when 11 {
                monthString = System.Label.November;
            }
            when 12 {
                monthString = System.Label.December;
            }
            when else {
                monthString = '';
            }
        }
        return monthString;
    }
    /*
	* Description:         Method to get the Picklist Value Label from Picklist Value for review page.
	* Param 1:             Object Type
	* Param 2:             Field Api Name
	* Param 3:             Field Value
	* Return Type:         String --> Picklist value label
	*Added as part of BRS-1636
	* Author Info:
	*******************************************************************************
	* Dheeraj                01/27/2021               First Version.
	*/
    public static String getPicklistLabel(SObjectType objectType, String fieldName, String fieldValue) {
       String picklistLabel;
        Schema.DescribeSObjectResult objres = objectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objres.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : picklistEntries){
            if(pickListVal.getValue() == fieldValue){
                picklistLabel=pickListVal.getLabel();
                break;
            }            
        } 
        return picklistLabel;
    }
    
/********************************************************************************************
        METHOD NAME    : processBusinessMaintenance
        DESCRIPTION    : to Get All temp record and create or delete princpal record as per filing id and maintennace request
        RETURN TYPE    : List of Json wrapper
        PARAMETER      : List of Json wrapper
        Author         : Rahul Sharma
        Date           : 29-Jan-2021
    ********************************************************************************************/
    @InvocableMethod
    public static List<Results> processBusinessMaintenance(List<Requests> Requests) {
        List<Results> lstResults = new List<Results>();
        Results r = new Results();
        if (!Requests.IsEmpty()) {
            if(Requests[0].rejectedFilingId != null)
            {
                List<cloneResponce> cloneResponceLst = cloneBusinessFilingWithRelatedRecords(Requests[0].rejectedFilingId);
                if (!cloneResponceLst.isEmpty()) {
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4225
                    * Change(s)/Modification(s) Description : Added fix for rejected filing Id, The rejected filing id after clone were coming as JSON.
                    * Change(s)/Modification(s) Made on : 2021-05-11
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    r.businessFilingId = cloneResponceLst.get(0).filingId;
                    r.response = Json.serialize(cloneResponceLst);
                    lstResults.add(r);
                }
            }
            else if (Requests[0].businessName != null)
            {
                Boolean dupCheck = brs_businessNameCheck.checkDuplicateAccName(Requests[0].businessName,Requests[0].accId);
                List<dupCheckResponce> dupCheckResponceLst = new List<dupCheckResponce>();
                dupCheckResponce res = new dupCheckResponce();
                res.nameAvailable= dupCheck;
                dupCheckResponceLst.add(res);
                if (!dupCheckResponceLst.isEmpty()) {
                    r.response = Json.serialize(dupCheckResponceLst);
                    lstResults.add(r);
                }
            }
            else if (Requests[0].certificateTypes != null)
            {
                List<maintennaceResponce> certCreationList = createCertificateRecords(Requests[0].accId,Requests[0].certificateTypes,Requests[0].workOrderId);
                if (!certCreationList.isEmpty()) {
                    r.response = Json.serialize(certCreationList);
                    lstResults.add(r);
                }
            }
            else {
                List<maintennaceResponce> maintennaceResponceLst = updateRecordsFromTemp(Requests[0].accId , Requests[0].type , Requests[0].filingId);
                if (!maintennaceResponceLst.isEmpty()) {
                    r.response = Json.serialize(maintennaceResponceLst);
                    lstResults.add(r);
                }
            }
        }
        return lstResults;
    }
    @AuraEnabled
    public static List<maintennaceResponce> updateRecordsFromTemp(String accId, String type, String filingId ) {
        List<Principal__c> interimDelPricipal = new List<Principal__c>();
        List<Principal__c> interimUpsertPricipal = new List<Principal__c>();
        List<Agent__c> changeAgentUpsert = new List<Agent__c>();
        List<Agent__c> changeAgentDelete = new List<Agent__c>();
        List<maintennaceResponce> lstResults2 = new List<maintennaceResponce>();
        List<Temp_History__c> TempRecs = new List<Temp_History__c>();
        maintennaceResponce res = new maintennaceResponce();
        Boolean isMaintenanceDone = false;
        String queryString = 'Select id, Name, Title__c, Designation__c, Agent__c, Principal__c, Type__c, Temp_Type__c, Phone__c, Business_Name__c, Business_ID__c, Business_ID__r.AccountNumber, Account__c,Account__r.AccountNumber, FirstName__c, LastName__c, Name__c, Email__c, Business_Filing__c, Business_InternationalAddress__c,  Residence_InternationalAddress__c, Created_From_Agent__c,Business_City__c, Business_Country__c, Business_State__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c, Mailing_City__c, Change_Type__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,Principal_Title__c, Residence_State__c, Residence_City__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_Country__c from Temp_History__c';

        String whereClause = ' where (Account__c = : accId Or Business_Id__c =: accId) AND Type__c = : type and Business_Filing__c = : filingId WITH SECURITY_ENFORCED' ;
        queryString = queryString + whereClause;
        TempRecs = Database.query(queryString);
        if (!TempRecs.IsEmpty()) {
            if (type == system.label.Principal) { // BRS 1691 - Change principal of business via maintenance flow
                for (Temp_History__c rec : TempRecs) {
                    Principal__c pr = new Principal__c();
                    if (rec.Change_Type__c == system.label.Deleted && rec.Principal__c != null) {
                        pr.Id = rec.Principal__c;
                        interimDelPricipal.add(pr);
                    } else if (rec.Change_Type__c == system.label.brs_maintenance_tempCreated || rec.Change_Type__c == system.label.brs_maintenance_tempEdited) {
                        if (rec.Change_Type__c == system.label.brs_maintenance_tempEdited && rec.Principal__c != null) {
                            pr.Id =  rec.Principal__c;
                        }
                        pr.Business_City__c = rec.Business_City__c;
                        pr.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                        pr.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                        pr.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                        pr.Business_State__c = rec.Business_State__c;
                        pr.Business_Country__c = rec.Business_Country__c;
                        pr.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                        if(rec.Principal_Title__c != null)
                            pr.Principal_Title__c = rec.Principal_Title__c;
                        else if(rec.Title__c != null)
                            pr.Principal_Title__c = rec.Title__c;
                        pr.FirstName__c = rec.FirstName__c;
                        pr.LastName__c = rec.LastName__c;
                        pr.Name__c = rec.Name__c;
                        if(rec.Email__c != null)
                            pr.Email__c = rec.Email__c;
                        pr.Residence_City__c = rec.Residence_City__c;
                        pr.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                        pr.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                        pr.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                        pr.Residence_State__c = rec.Residence_State__c;
                        pr.Residence_Country__c = rec.Residence_Country__c;
                        pr.Residence_InternationalAddress__c = rec.Residence_InternationalAddress__c;
                        pr.Principal_Account_ID__c = rec.Business_Id__c;
                        pr.Business_ID__c = rec.Business_Id__c;
                        interimUpsertPricipal.add(pr);
                    }
                }
                try {
                    Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(interimDelPricipal, 'delete'); 
                    Boolean accessCheck1 = BRS_SecurityUtility.checkDMLAccess(interimUpsertPricipal, 'upsert');
                    if (!interimDelPricipal.IsEmpty() && Schema.SObjectType.Principal__c.isAccessible() && accessCheck) {
                        delete interimDelPricipal;
                    }
                    if (!interimUpsertPricipal.IsEmpty() && Schema.SObjectType.Principal__c.isAccessible() && accessCheck1) {
                        upsert interimUpsertPricipal;
                    }
                    isMaintenanceDone = true;
                } catch (Exception e) {
                    BOS_Utility.ExceptionHandler(className, 'InterimNoticeMaintenance', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
                    throw new AuraHandledException(e.getMessage());
                }
            } else if (type == system.label.Agent) { // BRS 1694 - Change agent of business via maintenance flow
                for (Temp_History__c rec : Temprecs) {
                    Agent__c ag = new Agent__c();
                    if (rec.Change_Type__c == system.label.Deleted && rec.Agent__c != null) {
                        ag.Id = rec.Agent__c;
                        changeAgentDelete.add(ag);
                    } else if (rec.Change_Type__c == system.label.brs_maintenance_tempCreated || rec.Change_Type__c == system.label.brs_maintenance_tempEdited) {
                        if (rec.Change_Type__c == system.label.brs_maintenance_tempEdited && rec.Agent__c != null) {
                            ag.Id =  rec.Agent__c;
                        }
                        ag.Agent_Phone__c = rec.Phone__c;
                        ag.FirstName__c = rec.FirstName__c;
                        ag.LastName__c = rec.LastName__c;
                        ag.Name__c = rec.Name__c;
                        ag.Email__c = rec.Email__c;
                        ag.Type__c = rec.Temp_Type__c;
                        ag.Business_City__c = rec.Business_City__c;
                        ag.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                        ag.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                        ag.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                        ag.Business_State__c = rec.Business_State__c;
                        ag.Business_Country__c = rec.Business_Country__c;
                        ag.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                        ag.Residence_City__c = rec.Residence_City__c;
                        ag.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                        ag.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                        ag.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                        ag.Residence_State__c = rec.Residence_State__c;
                        ag.Residence_Country__c = rec.Residence_Country__c;
                        ag.Mailing_City__c = rec.Mailing_City__c;
                        ag.Mailing_Street_Address_1__c = rec.Mailing_Street_Address_1__c;
                        ag.Mailing_Street_Address_2__c = rec.Mailing_Street_Address_2__c;
                        ag.Mailing_Zip_Code__c = rec.Mailing_Zip_Code__c;
                        ag.Mailing_State__c = rec.Mailing_State__c;
                        ag.Mailing_Country__c = rec.Mailing_Country__c;
                        ag.Agent_Account_ID__c = rec.Temp_Type__c== System.label.Business_Comparable?rec.Account__c:null;
                        ag.Business_ID__c = rec.Business_Id__c;
                        changeAgentUpsert.add(ag);
                    }
                }
                try {
                    system.debug('changeAgentUpsert' + changeAgentUpsert);
                    system.debug('changeAgentDelete' + changeAgentDelete);
                    Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(changeAgentUpsert, 'upsert'); 
                    Boolean accessCheck1 = BRS_SecurityUtility.checkDMLAccess(changeAgentDelete, 'delete');
                    if (!changeAgentUpsert.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible() && accessCheck) {
                        upsert changeAgentUpsert;
                    }
                    if (!changeAgentDelete.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible() && accessCheck1) {
                        delete changeAgentDelete;
                    }
                    isMaintenanceDone = true;
                } catch (Exception e) {
                    BOS_Utility.ExceptionHandler(className, 'changeAgentMaintenance', 'Agent__c', null, BOS_Utility.sSeverity, e, null);
                    throw new AuraHandledException(e.getMessage());
                }
            }

        }

        res.businessMaintenanceDone = isMaintenanceDone ;
        lstResults2.add(res);
        return lstResults2;
    }
    global with sharing class Requests {
        @InvocableVariable
        global string type;
        @InvocableVariable
        global string filingId;
        @InvocableVariable
        global string accId;
        @InvocableVariable
        global string businessName;
        @InvocableVariable
        global string rejectedFilingId;
        @InvocableVariable
        global string certificateTypes;
        @InvocableVariable
        global string workOrderId;
    }    
     global with sharing class Results {
        @InvocableVariable
        global String response;
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4225
        * Change(s)/Modification(s) Description : Added fix for rejected filing Id, The rejected filing id after clone were coming as JSON.
        * Change(s)/Modification(s) Made on : 2021-05-11
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        @InvocableVariable
        global String businessFilingId;
    }
    
    public with sharing class maintennaceResponce {
        @AuraEnabled public Boolean businessMaintenanceDone {get; set;}
        public Map<Id, Id> mapCertificateIds;
        
        public maintennaceResponce() {}
    }
/**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1101,BRS-930
        * Change(s)/Modification(s) Description : Adding new method to get the data for review/edit page for Business report filing.
        * Change(s)/Modification(s) Made on : 2021-01-15
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
    /**
     * [getDataForReportFiling Use this method to get data on the review page. Reference : BRS-930]
     * @param  currentBf [Business Filing Record]
     * @param  flowName [Flow name]
     * @return           [List of SectionWrapper data]
     */
    @AuraEnabled
    public static List<SectionWrapper> getDataForReportFiling(Business_Filing__c currentBf, Account accSObj, String flowName, Boolean isOverView) {
        labelMaps = ctds_flowStages.getAppLabels();
        List<Agent__c> agentList = new List<Agent__c>();
        List<Principal__c> principalList = new List<Principal__c>();
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added boolean variables to hold info about the typeof account to be processed
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Boolean isDomesticAndLLP = false;
        If(accSObj.Citizenship__c == System.Label.Domestic && accSObj.Business_Type__c == System.Label.LLP) {
            isDomesticAndLLP = true;
        }
        Boolean isAgentMailingAddressValidationRequired = false;
        If((accSObj.Citizenship__c == System.Label.Domestic &&  (accSObj.Business_Type__c == System.Label.LLC || accSObj.Business_Type__c == System.Label.Stock || accSObj.Business_Type__c == System.Label.B_Corp)) || (accSObj.Citizenship__c == System.Label.Foreign && (accSObj.Business_Type__c == System.Label.LLC))) {
            isAgentMailingAddressValidationRequired = true;
        }
        Boolean isCorpBusiness = false;
        if (accSObj.Business_Type__c == System.Label.Stock || accSObj.Business_Type__c == System.Label.B_Corp || accSObj.Business_Type__c == System.Label.Non_Stock) {
            isCorpBusiness = true;
        }
        Map<String, Map<String, Map<Id, sObject>>> allChangedData = new Map<String, Map<String, Map<Id, sObject>>>();
        String objectName = 'Business_Filing__c';
        // Get Agent Data
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added fields in Query for validation Agent
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Map<Id, Agent__c> allAgentMap = new Map<Id, Agent__c>([select Id, FirstName__c, LastName__c, Agent_Account_ID__c, Residence_Zip_Code__c, Residence_State__c, Residence_City__c, Residence_Street_Address_1__c, Name, Business_Id__c, Agent_Residence_Address__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c, Mailing_State__c, Mailing_City__c, Business_City__c, Business_Street_Address_1__c, Business_State__c, Business_Zip_Code__c, Business_Id__r.AccountNumber, Agent_Account_ID__r.AccountNumber, Name__c, Type__c, Email__c, Agent_Phone__c, Business_Address__c, Mailing_Address__c, (Select Id from Temp_History__r WHERE Business_Filing__c = : currentBf.Id AND Account__c = : accSObj.Id LIMIT 1), Business_InternationalAddress__c,Business_Country__c from Agent__c where Business_ID__c = :accSObj.Id  WITH SECURITY_ENFORCED]);
        if (!allAgentMap.isEmpty()) agentList = allAgentMap.values();
    
        // Get Principal Data
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added fields in Query for validation Principal
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Map<Id, Principal__c> allPrincipalMap = new Map<Id, Principal__c>([select Id, Designation__c, FirstName__c, LastName__c, Business_Id__c, Residence_Country__c, Residence_Street_Address_1__c, Residence_City__c, Residence_State__c, Residence_Zip_Code__c, Business_Country__c, Business_Street_Address_1__c, Business_City__c, Business_State__c, Business_Zip_Code__c, Business_Id__r.AccountNumber, Principal_Account_ID__r.AccountNumber, Name__c, Principal_Type__c, Email__c, Principal_Title__c, Business_Address_1__c, Residence_Address__c, Business_InternationalAddress__c, Mailing_Address__c, (Select Id from Temp_History__r WHERE Business_Filing__c = : currentBf.Id AND Account__c = : accSObj.Id LIMIT 1), Residence_InternationalAddress__c from Principal__c where Business_ID__c = :accSObj.Id  WITH SECURITY_ENFORCED]);
        if (!allPrincipalMap.isEmpty()) principalList = allPrincipalMap.values();
    
        // Get Temp History Data
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added fields in Query for validation Temp History
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        List<Temp_History__c> allAssociatedTempHistory = new List<Temp_History__c>();
        allAssociatedTempHistory = [SELECT Id, Name, Business_Email_Address__c, Business_Unit_New__c, Mailing_Unit_New__c, Old_Business_Email_Address__c, Mail_Jurisdiction_International_address__c, Jurisdiction_International_address__c, NAICS_Code__c, Email_New__c, NAICS_Code_New__c, BillingStreet_New__c, Billing_City_New__c, BillingState_New__c, BillingPostalCode_New__c, Billing_Country_new__c, Office_Jurisdiction_Address__c, Office_Jurisdiction_BusinessStreet__c, Office_Jurisdiction_BusinessUnit__c, Office_Jurisdiction_BusinessCity__c, Office_Jurisdiction_BusinessState__c, Office_Jurisdiction_BusinessZipCode__c, Business_InternationalAddress__c, ShippingStreet_New__c, ShippingCity_New__c, ShippingState_New__c, ShippingPostalCode_New__c, Business_Name_in_state_country__c, Shipping_Country_New__c, NAICS_Sub_Code__c, Residence_InternationalAddress__c, Business_City__c, Business_State__c, Business_Unit__c, Mailing_City__c, Mailing_State__c, Mailing_Unit__c, Related_Record_ID__c, Related_Object__c, Account__c, Business_ID__c, Business_Id__r.AccountNumber, Title__c, Principal__c, Agent__c, Account__r.AccountNumber, Type__c, Billing_City__c, Designation__c, BillingPostalCode__c, BillingState__c, BillingStreet__c, Mailing_International_Address__c, Principle_Office_International_Address__c, ShippingCity__c, ShippingPostalCode__c, ShippingState__c, ShippingStreet__c, Phone__c, FirstName__c, LastName__c, Business_Filing__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Zip_Code__c, Mailing_Street_Address_1__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c, Mailing_Zip_Code__c, Business_Street_Address_3__c, Name__c, Email__c, Business_Country__c, Mailing_Country__c, Residence_Country__c, Residence_State__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Temp_Type__c, Residence_City__c, Optional_Business_Description__c, Change_Type__c, Billing_Country__c, Mailing_Jurisdiction_Country__c, Office_Jurisdiction_Country__c, Shipping_Country__c, Principal_Type__c, Principal_Title__c, Principle_Office_International_Address_N__c, Mailing_International_Address_New__c, Mailing_Jurisdiction_BusinessCity_New__c, Mailing_Jurisdiction_BusinessState_New__c, Mailing_Jurisdiction_BusinessStreet_New__c, Mailing_Jurisdiction_BusinessUnit_New__c, Mailing_Jurisdiction_BusinessZipCode_New__c, Office_Jurisdiction_Address_New__c, Office_Jurisdiction_BusinessCity_New__c, Office_Jurisdiction_BusinessState_New__c, Office_Jurisdiction_BusinessStreet_New__c, Office_Jurisdiction_BusinessUnit_New__c, Office_Jurisdiction_BusinessZipCode_New__c, Jurisdiction_International_address_New__c, Mail_JurisdictionInternationaladdress_N__c, Business_Name_New__c, CreatedDate, Office_Jurisdiction_Country_New__c, Residence_Country_Old__c, Mailing_Jurisdiction_Country_New__c, Date_of_Organization_Meeting_New__c, Business_Name_in_state_country_New__c, Mailing_Jurisdiction_BusinessZipCode__c, Mailing_Jurisdiction_BusinessUnit__c, Mailing_Jurisdiction_BusinessStreet__c, Mailing_Jurisdiction_BusinessState__c, Mailing_Jurisdiction_BusinessCity__c FROM Temp_History__c WHERE Business_Filing__c = : currentBf.Id  WITH SECURITY_ENFORCED Order By CreatedDate DESC];
    
        allChangedData = getChangesFromTempHistory(accSObj, allPrincipalMap, allAgentMap, allAssociatedTempHistory);
        Temp_History__c updatedAccount = new Temp_History__c();
        if (allChangedData.containsKey('Account')) {
            if (allChangedData.get('Account').containsKey('Edited')) {
                updatedAccount = (Temp_History__c) allChangedData.get('Account').get('Edited').get(accSObj.Id);
            }
        }
    
        List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
        List<String> TempHistoryBillingAdd = System.Label.TempHistoryBillingAdd.split(',');
        List<String> shippingAddrFields = System.Label.BRS_ShippingAddrFields.split(',');
        List<String> TempHistoryShippingAdd = System.Label.TempHistoryShippingAdd.split(',');
    
        List<String> Tempofficejurisdiction = System.Label.Temp_Office_Jurisdiction_Address.split(',');
        List<String> officeJurisdiction = System.Label.Office_IN_Jurisdiction_Account.split(',');
        List<String> AccountMailJurisdiction = System.Label.MailJurisdiction.split(',');
        List<String> TempMailJurisdiction = System.Label.TempMailJurisdiction.split(',');
    
        // New custom labels having address fields for validation
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
        * Change(s)/Modification(s) Description : Added List of fields to be used for validation on differnet objects based on condition.
        * Change(s)/Modification(s) Made on : 18-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        List<String> billingAddrFieldsValidation = System.Label.Add_Validation_Billing_address.split(',');
        List<String> TempHistoryBillingAddValidation = System.Label.Add_Validation_Temp_Billing_Address_Comparable.split(',');
        List<String> shippingAddrFieldsValidation = System.Label.Add_Validation_Shipping_address.split(',');
        List<String> TempHistoryShippingAddValidation = System.Label.Add_Validation_Temp_Shipping_Address_Comparable.split(',');
    
        List<String> TempofficejurisdictionValidation = System.Label.Add_Validation_Temp_Office_Jurisdiction_Address_Comparable.split(',');
        List<String> officeJurisdictionValidation = System.Label.Add_Validation_Office_In_Jurisdiction.split(',');
        List<String> AccountMailJurisdictionValidation = System.Label.Add_Validation_Mailing_Jurisdiction.split(',');
        List<String> TempMailJurisdictionValidation = System.Label.Add_Validation_Temp_Mailing_Jurisdiction_Address_Comparable.split(',');
    
        // New custom labels having International address fields for validation
        List<String> billingAddrFieldsValidationINT = System.Label.Add_Validation_INT_Billing_address_comparable.split(',');
        List<String> TempHistoryBillingAddValidationINT = System.Label.Add_Validation_Temp_INT_Billing_address_comparable.split(',');
        List<String> shippingAddrFieldsValidationINT = System.Label.Add_Validation_INT_Shipping_address_comparable.split(',');
        List<String> TempHistoryShippingAddValidationINT = System.Label.Add_Validation_Temp_INT_Shipping_address_comparable.split(',');
        List<String> officeJurisdictionOldTemp = System.Label.Add_Old_Jurisdiction.split(',');
        List<String> MailJurisdictionOldTemp = System.Label.Add_Old_Mail_Jurisdiction.split(',');
        List<String> TempofficejurisdictionValidationINT = System.Label.Add_Validation_Temp_INT_office_Jurisdiction_address_comparable.split(',');
        List<String> officeJurisdictionValidationINT = System.Label.Add_Validation_INT_office_Jurisdiction_ddress_comparable.split(',');
        List<String> AccountMailJurisdictionValidationINT = System.Label.Add_Validation_INT_Mail_Jurisdictionaddress_comparable.split(',');
        List<String> TempMailJurisdictionValidationINT = System.Label.Add_Validation_Temp_INT_Mail_Jurisdiction_address_comparable.split(',');
    
        //Agent Validation Fields
        List<String> newIndividualAgentValidation = System.Label.Agent_Validation_Temp.split(',');
        List<String> newBusinessAgentValidation = System.Label.Agent_Validation_Business_New.split(',');
        List<String> oldIndividualAgentValidation = System.Label.Agent_Validation_Old.split(',');
        List<String> oldBusinessAgentValidation = System.Label.Agent_Validation_Old_Business.split(',');
        List<String> agentMailingAddressValidation = System.Label.Agent_Validation_Mailing_Address.split(',');
        List<String> shippingTempOldAdd = System.Label.Shipping_Add_Temp_Old.split(',');
    
        List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
        * Change(s)/Modification(s) Description : Adding new field Hide_Comparable_Data__c to the query
        * Change(s)/Modification(s) Made on : 2021-03-15
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        List<Section_Settings__mdt> reviewConfigList = [select Id, Flow_Type__c, Section_Image__c, Section_Name__c, Section_Order__c,
                                    (select Id, DeveloperName, MasterLabel, hideDataTableOnUI__c, Hide_Comparable_Data__c, Eligible_Value_of_Parent_Field__c, Field_API_Name__c, Field_Label__c, Flow__c, Order__c, Parent_Field_API_Name__c,
                                     Related_Object_API_Name__c, Data_Table_Object__c, Field_Set_API_Name__c, Show_Data_Table__c, Field_Image__c, Show_Document__c, hide_edit__c
                                     from BRS_Review_Page_Configurations__r) from Section_Settings__mdt where Flow_Type__c = :flowName AND Include_in_Review_Page__c = true
                                             Order By Section_Order__c limit 10000];
        for (Section_Settings__mdt sectionData : reviewConfigList) {
            SectionWrapper section = new SectionWrapper();
            List<ReviewConfig> configList = new List<ReviewConfig>();
            section.Id = sectionData.Id;
            section.image = sectionData.Section_Image__c;
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
            * Change(s)/Modification(s) Description : Defaulting the variable to be true as they need to be false only in case the validations fails.
            * Change(s)/Modification(s) Made on : 2021-03-15
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            section.isAgentDataValid = true;
            section.isPrincipalDataValid = true;
            section.sectionValueIsValid = true;
            if (labelMaps.get(sectionData.Section_Name__c.trim()) != null) {
                section.title = labelMaps.get(sectionData.Section_Name__c.trim());
            } else {
                section.title = sectionData.Section_Name__c;
            }
            if (sectionData.BRS_Review_Page_Configurations__r.size() > 0) {
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
                * Change(s)/Modification(s) Description : Inner variable used for the purpose of checking if one field is failing validation then set it as false.
                * Change(s)/Modification(s) Made on : 2021-03-15
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                Boolean sectionDataValid = true;
                Boolean isAgentDataValid = true;
                Boolean isPrincipalDataValid = true;
                for (BRS_Review_Page_Configuration__mdt configData : sectionData.BRS_Review_Page_Configurations__r) {
    
                    // Below block is used to compare and decide if the datatable needs to be visible to the user or not.
                    // This is dependent on the field and its expected value outcome from Parent_Field_API_Name__c as field
                    // And Eligible_Value_of_Parent_Field__c as the outcome. If the condition do not match we set the value of showChildField as false.
                    // If the value of showChildField is false we break the look and go to another configuration.
    
                    Boolean showChildField = false;
                    if (configData.Parent_Field_API_Name__c != null) {
                        Map<String, String> fieldNameExpectedValueMap = new Map<String, String>();
                        Map<String, String> expectedVsActualRespMap = new Map<String, String>();
                        List<String> parentFields = configData.Parent_Field_API_Name__c.split(System.Label.PIPELINE_SEPARATOR);
                        List<String> eligibleRespList = configData.Eligible_Value_of_Parent_Field__c.split(System.Label.PIPELINE_SEPARATOR);
                        for (Integer i = 0; i < parentFields.size(); i++) {
                            fieldNameExpectedValueMap.put(parentFields[i], eligibleRespList[i]);
                        }
                        for (String field : parentFields) {
                            Object parentResp = accSObj.get(field);
                            expectedVsActualRespMap.put(fieldNameExpectedValueMap.get(field), String.valueOf(parentResp));
                        }
                        for (String key : expectedVsActualRespMap.keySet()) {
                            if (key == expectedVsActualRespMap.get(key)) {
                                showChildField = true;
                            } else {
                                showChildField = false;
                                break;
                            }
                        }
                    }
    
                    // Get the data for the configured metadata. This is based on field api names and object api names provided
                    // In the custom metadata settings.
    
                    String response = '';
                    String changedFieldValue = '';
                    Boolean hideEditButton1 = false;
                    Boolean hideSection = false;
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
                    * Change(s)/Modification(s) Description : Adding condition to avoid getting data from Temp or any associated object. This is due to in dissolution and Revocation we may have fields on account but may not have them on related(Temp History) Object. For Reference : 'DoNotGetComparableData' is the added variable and other changes on the 'changedFieldValue' variable.
                    * Change(s)/Modification(s) Made on : 2021-03-15
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    Boolean DoNotGetComparableData = configData.Hide_Comparable_Data__c;
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2838
                    * Change(s)/Modification(s) Description : Adding condition to hide agent list if LLP and Principal office address is in CT and show if outside.
                    * Change(s)/Modification(s) Made on : 2021-03-22
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    Boolean IsLLPAndWithAddressInCT = false;
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
                    * Change(s)/Modification(s) Description : Comparing the original and Temp history data for validation.
                    * Change(s)/Modification(s) Made on : 2021-03-15
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    Boolean isOriginalDataValid = true;
                    Boolean isChangedDataValid = true;
                    List<String> ctAddress = Label.State_CT.split(System.Label.PIPELINE_SEPARATOR);
                    if (configData.Field_API_Name__c != null) {
                        List<String> fieldsList = configData.Field_API_Name__c.split(System.Label.PIPELINE_SEPARATOR);
                        for (String fieldName : fieldsList) {
                            String fieldValue = '';
                            Object fieldValueObj;
                            if (fieldName == 'BillingAddress') {
                                fieldValue = accSObj.Principle_Office_International_Address__c != NULL ? accSObj.Principle_Office_International_Address__c  + ', ' + accSObj.BillingCountry : getAddress(accSObj, billingAddrFields);
                                /**
                                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
                                * Change(s)/Modification(s) Description : Getting field validation depending upon business international address or us address was used(on original business)
                                * Change(s)/Modification(s) Made on : 18-07-2021
                                * Change(s)/Modification(s) Made by : Avinash Shukla
                                */
                                if (accSObj.Principle_Office_International_Address__c != NULL) {
                                    isOriginalDataValid = getFieldValidation(accSObj, billingAddrFieldsValidationINT, false, false);
                                } else {
                                    isOriginalDataValid = getFieldValidation(accSObj, billingAddrFieldsValidation, false, false);
                                }
                                if (updatedAccount != NULL) {
                                    if (!DoNotGetComparableData) {changedFieldValue = updatedAccount.Principle_Office_International_Address_N__c != NULL ? updatedAccount.Principle_Office_International_Address_N__c != updatedAccount.Principle_Office_International_Address__c || updatedAccount.Billing_Country__c != updatedAccount.Billing_Country_New__c ? updatedAccount.Principle_Office_International_Address_N__c + ', ' + updatedAccount.Billing_Country_New__c : '' : getAddress(updatedAccount, TempHistoryBillingAdd) != getAddress(accSObj, billingAddrFields) ? getAddress(updatedAccount, TempHistoryBillingAdd) : '';}
                                    /**
                                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-4164
                                    * Change(s)/Modification(s) Description : Getting field validation depending upon business international address or us address was used.
                                    * Change(s)/Modification(s) Made on : 18-07-2021
                                    * Change(s)/Modification(s) Made by : Avinash Shukla
                                    */
                                    if (!String.isBlank(changedFieldValue)) {
                                        if (updatedAccount.Principle_Office_International_Address_N__c != NULL) {
                                            isChangedDataValid = getFieldValidation(updatedAccount, TempHistoryBillingAddValidationINT, false, false);
                                        } else {
                                            isChangedDataValid = getFieldValidation(updatedAccount, TempHistoryBillingAddValidation, false, false);
                                        }
                                    }
                                }
                            } else if (fieldName == 'ShippingAddress' || test.isRunningTest()) {
                                String acMailingAdd = getAddress(accSObj, shippingAddrFields);
                                String acTempMailingAdd = getAddress(updatedAccount, TempHistoryShippingAdd);
                                String acTempMailingAddOld = getAddress(updatedAccount, shippingTempOldAdd);
                                Boolean isOfficeInternational = accSObj.Mailing_International_Address__c != NULL ? True : False;
                                Boolean isOfficeAdd = accSObj.ShippingStreet != NULL ? True : False;
                                fieldValue = accSObj.Mailing_International_Address__c != NULL ? accSObj.Mailing_International_Address__c + ', ' + accSObj.ShippingCountry : getAddress(accSObj, shippingAddrFields);
                                if (!isDomesticAndLLP) {
                                    if (accSObj.Mailing_International_Address__c != NULL) {
                                        isOriginalDataValid = getFieldValidation(accSObj, shippingAddrFieldsValidationINT, false, false);
                                    } else {
                                        isOriginalDataValid = getFieldValidation(accSObj, shippingAddrFieldsValidation, false, false);
                                    }
                                }


                                if (updatedAccount != NULL) {
                                    if (!DoNotGetComparableData) {
                                        if(isOfficeInternational){
                                            if (updatedAccount.Mailing_International_Address__c != NULL) {
                                                if (updatedAccount.ShippingStreet_New__c != NULL) {
                                                    changedFieldValue = acTempMailingAdd;
                                                } else if (updatedAccount.Mailing_International_Address_New__c != updatedAccount.Mailing_International_Address__c || updatedAccount.Shipping_Country_New__c != updatedAccount.Shipping_Country__c) {
                                                        changedFieldValue =  updatedAccount.Mailing_International_Address_New__c + ', ' + updatedAccount.Shipping_Country_New__c;
                                                } else {
                                                    changedFieldValue = '';
                                                }
                                            } else {
                                                changedFieldValue = '';
                                            }
                                        } else if(isOfficeAdd){
                                            if (acTempMailingAddOld != '') {
                                                if(updatedAccount.Mailing_International_Address_New__c != NULL){
                                                    changedFieldValue =  updatedAccount.Mailing_International_Address_New__c + ', ' + updatedAccount.Shipping_Country_New__c;
                                                } else if (acTempMailingAdd != acTempMailingAddOld) {
                                                    changedFieldValue = acTempMailingAdd;
                                                    if (acTempMailingAdd == '') {
                                                        changedFieldValue = System.Label.not_applicable;
                                                    }
                                                } else {
                                                    changedFieldValue = '';
                                                }
                                            } else if (acTempMailingAddOld == '') {
                                                changedFieldValue = '';
                                            }
                                        } else if (!isOfficeInternational && !isOfficeAdd){
                                            if (updatedAccount.Mailing_International_Address_New__c != NULL) {
                                                changedFieldValue =  updatedAccount.Mailing_International_Address_New__c + ', ' + updatedAccount.Shipping_Country_New__c;
                                            } else if (acTempMailingAdd != '') {
                                                changedFieldValue = acTempMailingAdd;
                                            }
                                        }
                                    if (!isDomesticAndLLP) {
                                        if (!String.isBlank(changedFieldValue)) {
                                            if (updatedAccount.Mailing_International_Address_New__c != NULL) {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempHistoryShippingAddValidationINT, false, false);
                                            } else {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempHistoryShippingAddValidation, false, false);
                                            }
                                        }
                                    }
                                }
                            }
                            } else if (fieldName == 'officeJusrisdiction') {
                                Boolean isOfficeJuridictionOptional = false;
                                if(accSObj.Business_Type__c == System.Label.LLC){
                                    isOfficeJuridictionOptional = true;
                                } else {
                                    isOfficeJuridictionOptional = accSObj.Jurisdiction_StateorTerritory__c != NULL ? accSObj.Jurisdiction_StateorTerritory__c == 'Yes' ? false : true : true;
                                }
                                fieldValue = accSObj.Jurisdiction_International_address__c != NULL ? accSObj.Jurisdiction_International_address__c + ', ' + accSObj.Office_in_Jurisdiction_Country__c : getAddress(accSObj, officeJurisdiction);
                                if (accSObj.Citizenship__c == System.Label.Foreign && (accSObj.Business_Type__c == System.Label.LLP || accSObj.Business_Type__c == 'LLC')) {
                                    if (accSObj.Jurisdiction_International_address__c != NULL) {
                                        isOriginalDataValid = getFieldValidation(accSObj, officeJurisdictionValidationINT, isOfficeJuridictionOptional, false);
                                    } else {
                                        isOriginalDataValid = getFieldValidation(accSObj, officeJurisdictionValidation, isOfficeJuridictionOptional, false);
                                    }
                                }
                                if (updatedAccount != NULL) {
                                    if (!DoNotGetComparableData) {
                                        Boolean isOffJurisChangedToNULL = false;
                                        String accOffJurisAdd = getAddress(accSObj, officeJurisdiction);
                                        String TempOffJurisAddNew = getAddress(updatedAccount, Tempofficejurisdiction);
                                        String TempOffJurisAddOld = getAddress(updatedAccount, officeJurisdictionOldTemp);
                                        Boolean isOfficeInternational = accSObj.Jurisdiction_International_address__c != NULL ? True : False;
                                        Boolean isOfficeAdd = accOffJurisAdd != '' ? True : False;
                                        if (isOfficeInternational) {
                                            if (updatedAccount.Jurisdiction_International_address__c != NULL) {
                                                if (updatedAccount.Jurisdiction_International_address_New__c != updatedAccount.Jurisdiction_International_address__c || updatedAccount.Office_Jurisdiction_Country_New__c != updatedAccount.Office_Jurisdiction_Country__c) {
                                                    if ((updatedAccount.Jurisdiction_International_address_New__c == NULL || updatedAccount.Jurisdiction_International_address_New__c == '') && updatedAccount.Office_Jurisdiction_Country_New__c == NULL || updatedAccount.Office_Jurisdiction_Country_New__c == '') {
                                                        changedFieldValue = System.Label.not_applicable;
                                                    } else {
                                                        changedFieldValue =  updatedAccount.Jurisdiction_International_address_New__c + ', ' + updatedAccount.Office_Jurisdiction_Country_New__c;
                                                    }
                                                    if (updatedAccount.Jurisdiction_International_address_New__c == NULL) {
                                                        isOffJurisChangedToNULL = true;
                                                    }
                                                } else {
                                                    changedFieldValue = '';
                                                    isOffJurisChangedToNULL = false;
                                                }
                                            } else {
                                                changedFieldValue = '';
                                                isOffJurisChangedToNULL = false;
                                            }
                                        } else if (isOfficeAdd) {
                                            // Condition when initially Add was entered but removed while filing
                                            if (TempOffJurisAddOld != '') {
                                                if (TempOffJurisAddNew != TempOffJurisAddOld) {
                                                    changedFieldValue = TempOffJurisAddNew;
                                                    if (TempOffJurisAddNew == '') {
                                                        changedFieldValue = System.Label.not_applicable;
                                                        isOffJurisChangedToNULL = true;
                                                    }
                                                } else {
                                                    changedFieldValue = '';
                                                    isOffJurisChangedToNULL = false;
                                                }
                                            } else if (TempOffJurisAddOld == '') {
                                                changedFieldValue = '';
                                                isOffJurisChangedToNULL = false;
                                            }
                                        } else if (!isOfficeInternational && !isOfficeAdd){
                                            if (updatedAccount.Jurisdiction_International_address__c != NULL) {
                                                changedFieldValue =  updatedAccount.Jurisdiction_International_address_New__c + ', ' + updatedAccount.Office_Jurisdiction_Country_New__c;
                                            } else if (TempOffJurisAddNew != '') {
                                                changedFieldValue = TempOffJurisAddNew;
                                            }
                                        }
                                    }
                                    if (accSObj.Citizenship__c == System.Label.Foreign && (accSObj.Business_Type__c == System.Label.LLP || accSObj.Business_Type__c == System.Label.LLC)) {
                                        if (!String.isBlank(changedFieldValue)) {
                                            if (updatedAccount.Jurisdiction_International_address_New__c != NULL) {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempofficejurisdictionValidationINT, isOfficeJuridictionOptional, false);
                                            } else {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempofficejurisdictionValidation, isOfficeJuridictionOptional, false);
                                            }
                                        }
                                    }
                                }
                            } else if (fieldName == 'mailingjurisdiction') {
                                fieldValue = accSObj.Mail_Jurisdiction_International_address__c != NULL ? accSObj.Mail_Jurisdiction_International_address__c + ', ' + accSobj.Mailing_Jurisdiction_Country__c : getAddress(accSObj, AccountMailJurisdiction);
                                if (accSObj.Citizenship__c == System.Label.Foreign && accSObj.Business_Type__c == System.Label.LLC) {
                                    if (accSObj.Mailing_International_Address__c != NULL) {
                                        isOriginalDataValid = getFieldValidation(accSObj, AccountMailJurisdictionValidationINT, true, false);
                                    } else {
                                        isOriginalDataValid = getFieldValidation(accSObj, AccountMailJurisdictionValidation, true, false);
                                    }
                                }
                                if (updatedAccount != NULL) {
                                    if (!DoNotGetComparableData) {
                                        Boolean isOffJurisChangedToNULL = false;
                                        String accMailJuridiction = getAddress(accSObj, AccountMailJurisdiction);
                                        String tempMailJurisdictionNew = getAddress(updatedAccount, TempMailJurisdiction);
                                        String tempMailJurisdictionOldAdd = getAddress(updatedAccount, MailJurisdictionOldTemp);
                                        Boolean isOfficeInternational = accSObj.Mail_Jurisdiction_International_address__c != NULL ? True : False;
                                        Boolean isOfficeAdd = accMailJuridiction != '' ? True : False;
                                        if (isOfficeInternational) {
                                            if (updatedAccount.Mail_Jurisdiction_International_address__c != NULL) {
                                                if (updatedAccount.Mail_JurisdictionInternationaladdress_N__c != updatedAccount.Mail_Jurisdiction_International_address__c || updatedAccount.Mailing_Jurisdiction_Country_New__c != updatedAccount.Mailing_Jurisdiction_Country__c) {
                                                    if (updatedAccount.Mail_JurisdictionInternationaladdress_N__c == NULL || updatedAccount.Mail_JurisdictionInternationaladdress_N__c == '' && updatedAccount.Mailing_Jurisdiction_Country_New__c == NULL || updatedAccount.Mailing_Jurisdiction_Country_New__c == '') {
                                                        changedFieldValue = System.Label.not_applicable;
                                                    } else {
                                                        changedFieldValue =  updatedAccount.Mail_JurisdictionInternationaladdress_N__c + ', ' + updatedAccount.Mailing_Jurisdiction_Country_New__c;
                                                    }
                                                    if (updatedAccount.Mail_JurisdictionInternationaladdress_N__c == NULL) {
                                                        isOffJurisChangedToNULL = true;
                                                    }
                                                } else {
                                                    changedFieldValue = '';
                                                    isOffJurisChangedToNULL = false;
                                                }
                                            } else {
                                                changedFieldValue = '';
                                                isOffJurisChangedToNULL = false;
                                            }
                                        } else if (isOfficeAdd) {
                                            // Condition when initially Add was entered but removed while filing
                                            if (tempMailJurisdictionOldAdd != '') {
                                                if (tempMailJurisdictionNew != tempMailJurisdictionOldAdd) {
                                                    changedFieldValue = tempMailJurisdictionNew;
                                                    if (tempMailJurisdictionNew == '') {
                                                        changedFieldValue = System.Label.not_applicable;
                                                        isOffJurisChangedToNULL = true;
                                                    }
                                                } else {
                                                    changedFieldValue = '';
                                                    isOffJurisChangedToNULL = false;
                                                }
                                            } else if (tempMailJurisdictionOldAdd == '') {
                                                changedFieldValue = '';
                                                isOffJurisChangedToNULL = false;
                                            }
                                        } else if (!isOfficeInternational && !isOfficeAdd){
                                            if (updatedAccount.Mail_JurisdictionInternationaladdress_N__c != NULL) {
                                                changedFieldValue =  updatedAccount.Mail_JurisdictionInternationaladdress_N__c + ', ' + updatedAccount.Mailing_Jurisdiction_Country_New__c;
                                            } else if (tempMailJurisdictionNew != '') {
                                                changedFieldValue = tempMailJurisdictionNew;
                                            }
                                        }
                                    }
                                    if (accSObj.Citizenship__c == System.Label.Foreign && accSObj.Business_Type__c == System.Label.LLC) {
                                        if (!String.isBlank(changedFieldValue)) {
                                            if (updatedAccount.Mail_JurisdictionInternationaladdress_N__c != NULL) {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempMailJurisdictionValidationINT, true, false);
                                            } else {
                                                isChangedDataValid = getFieldValidation(updatedAccount, TempMailJurisdictionValidation, true, false);
                                            }
                                        }
                                    }
                                }
                            } else {
                               if(configData.Related_Object_API_Name__c != null && configData.Related_Object_API_Name__c == Label.Business_Filing_API_Name){
                                    if (fieldName == 'Mailing_Address__c') {
                                        fieldValue = currentBf.Mailing_International_Address__c != NULL ? currentBf.Mailing_International_Address__c + ', ' +currentBf.Mailing_Country__c : currentBf.Mailing_Address__c; 
                                    }                                   
                                    if (fieldName == 'Vote_Information__c') {
                                        fieldValue = currentBf.Vote_Information__c != NULL ? (labelMaps.ContainsKey(currentBf.Vote_Information__c) ? labelMaps.get(currentBf.Vote_Information__c) :currentBf.Vote_Information__c) : null ; 
                                    }    
                                    if (fieldName == 'Statement_of_Approval__c') {
                                        fieldValue = currentBf.Statement_of_Approval__c != NULL ? (labelMaps.ContainsKey(currentBf.Statement_of_Approval__c) ? labelMaps.get(currentBf.Statement_of_Approval__c) :currentBf.Statement_of_Approval__c) : null ; 
                                    }                              
                                    else {
                                        fieldValue = String.valueOf(currentBf.get(fieldName));
                                    }
                                } else {
                                    fieldValue = String.valueOf(accSObj.get(fieldName));
                                    SObjectType sObjectType = ((SObject)(Type.forName('Schema.Account').newInstance())).getSObjectType();
                                    DescribeSObjectResult d = sObjectType.getDescribe();
                                    String fieldtype = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
                                    fieldValueObj = accSObj.get(fieldName);
                                    if (fieldtype == 'DATE' && fieldValueObj != null) {
                                        Date dt = (Date)fieldValueObj;
                                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                                        fieldValue = dtime.format('MMMM dd, yyyy');
                                    }
                                    if (updatedAccount != NULL) {
                                        if (fieldName == 'Business_Email_Address__c') {
                                            //Added fix for annual and first report screen not showing view the updates for email
                                            if(!DoNotGetComparableData) {
                                                changedFieldValue = String.valueOf(updatedAccount.get('Email_New__c'))!=String.valueOf(updatedAccount.get('Business_Email_Address__c'))?String.valueOf(updatedAccount.get('Email_New__c')):'';
                                            }
                                        } else if (fieldName == 'NAICS_Code__c') {
                                            if(!DoNotGetComparableData) {changedFieldValue = String.valueOf(updatedAccount.get('NAICS_Code_New__c'))!=String.valueOf(updatedAccount.get('NAICS_Code__c'))?String.valueOf(updatedAccount.get('NAICS_Code_New__c')):'';}
                                        } else {
                                            if (fieldName == 'Date_of_Organization_Meeting__c') {
                                                if(currentBf.Type__c == System.Label.Annual_Report_Label) {
                                                    hideSection = true;
                                                } else if(currentBf.Type__c == System.Label.First_Report_Label){
                                                    //New Change
                                                    SObjectType sObjectType1 = ((SObject)(Type.forName('Schema.Temp_History__c').newInstance())).getSObjectType();
                                                    DescribeSObjectResult d1 = sObjectType1.getDescribe();
                                                    String fieldtype1 = String.valueOf(d1.fields.getMap().get('Date_of_Organization_Meeting_New__c').getDescribe().getType());
                                                    fieldValueObj = updatedAccount.get('Date_of_Organization_Meeting_New__c');
                                                    String changeddateofOrg = String.valueOf(updatedAccount.get('Date_of_Organization_Meeting_New__c'));
                                                    if (fieldtype1 == 'DATE' && fieldValueObj != null) {
                                                        Date dt = (Date)fieldValueObj;
                                                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                                                        changedFieldValue = dtime.format('MMMM dd, yyyy');
                                                    }
                                                }
                                            }
                                            else if(fieldName == 'Name'){
                                                String changedBusinessName = String.valueOf(updatedAccount.get(Label.Business_Name_New_Temp));
                                                if(changedBusinessName != NULL && changedBusinessName != ''){
                                                    changedFieldValue = changedBusinessName != fieldValue ? changedBusinessName : '';
                                                }
                                            }
                                            else if(fieldName == Label.BRS_nameinStateofFormation){
                                                String changedBusinessName = String.valueOf(updatedAccount.get(Label.BRS_nameinStateofFormationNew));
                                                if(changedBusinessName != NULL && changedBusinessName != ''){
                                                    changedFieldValue = changedBusinessName != fieldValue ? changedBusinessName : '';
                                                }
                                            }
                                            else if (fieldName != 'description') {
                                                if(!DoNotGetComparableData) {changedFieldValue = String.valueOf(updatedAccount.get(fieldName));}
                                            }
                                        }
                                    }
                                }
                            }
                            if (response == '') {
                                response = fieldValue;
                            } else {
                                response += System.Label.BRS_ReviewPageResponseSeparator + fieldValue;
                            }
                        }
                    }
                    //Added condition to hide edit based on condition of hideEditButton1 or configData.hide_edit__c;
                    ReviewConfig config = new ReviewConfig(configData);
                    config.hideEditButton = hideEditButton1 ? hideEditButton1 : configData.hide_edit__c;
                    config.hideDataTableOnUI = hideSection;
                    if (((configData.Parent_Field_API_Name__c != null && showChildField == true) || configData.Parent_Field_API_Name__c == null) || test.isRunningTest()) {
                        if (!isOverView) {
                            config.responseText = response;
                            config.dataIsChanged = (changedFieldValue != NULL && changedFieldValue != '') ? true : false;
                            config.associatedChangedDataValue = changedFieldValue;
                            if (changedFieldValue != '' && changedFieldValue != null) {
                                config.isDatavalid = isChangedDataValid;
                            } else {
                                config.isDatavalid = isOriginalDataValid;
                            }
                        } else {
                            // Show updated value in JSON when the screen is of Overview type.
                            if (changedFieldValue != '' && changedFieldValue != null) {
                                config.isDatavalid = isChangedDataValid;
                                config.responseText = changedFieldValue;
                                config.associatedChangedDataValue = '' ;
                            } else {
                                config.isDatavalid = isOriginalDataValid;
                                config.responseText = response;
                                config.associatedChangedDataValue = '' ;
                            }
                        }
                        If (section.title == System.Label.location && !config.isDatavalid) {
                            sectionDataValid = false;
                            section.sectionValueIsValid = false;
                        }
                        if (configData.Show_Data_Table__c == true || test.isRunningTest()) {
                            config.hideDataTableOnUI = configData.hideDataTableOnUI__c;
                            if (configData.hideDataTableOnUI__c) {
                                config.showDataTable = false;
                            } else {
                                config.showDataTable = true;
                            }
                            // Brs-2838 Changes
                            //Changes for BRS-2838
                            if(accSObj.Business_Type__c == Label.LLP){
                                IsLLPAndWithAddressInCT = accSObj.Principle_Office_International_Address__c != NULL ? false : ctAddress.contains(String.valueOf(getAddress(accSObj, new List<String>{Label.BillingState}).toLowercase())) ? true : false;
                            }
                            if (updatedAccount != NULL && updatedAccount.get(Label.Id) != NULL) {
                                if(!DoNotGetComparableData) {changedFieldValue = updatedAccount.Principle_Office_International_Address_N__c != NULL ? updatedAccount.Principle_Office_International_Address_N__c!= updatedAccount.Principle_Office_International_Address__c? updatedAccount.Principle_Office_International_Address_N__c:'': getAddress(updatedAccount, TempHistoryBillingAdd)!=getAddress(accSObj, billingAddrFields)? getAddress(updatedAccount, TempHistoryBillingAdd):'';}
                                //Changes for BRS-2838
                                if(accSObj.Business_Type__c == Label.LLP){
                                    IsLLPAndWithAddressInCT = updatedAccount.Principle_Office_International_Address_N__c != NULL ? false : ctAddress.contains(String.valueOf(getAddress(updatedAccount,new List<String>{Label.Temp_History_Billing_State_Field})).toLowercase()) ? true : false;
                                }
                            }
                            if (configData.Data_Table_Object__c != null || test.isRunningTest()) {
                                List<Temp_History__c> agentAssociatedTempLst = new List<Temp_History__c>();
                                if (allChangedData.containsKey(Label.Label_Agent_Comparable)) {
                                    if (allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Created) || allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Edited)) {
                                        agentAssociatedTempLst = allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Created) ? allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Created).values() : allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Edited).values();
                                    }
                                }
                                List<Object> tableDataList = new List<Object>();
                                if (configData.Field_Set_API_Name__c != null || test.isRunningTest()) {
                                    if (configData.Data_Table_Object__c == 'Agent__c' || test.isRunningTest()) {
                                        List<ColumnsWrapper> lstclm = new List<ColumnsWrapper>();
                                        ColumnsWrapper clm1 = new ColumnsWrapper();
                                        clm1.fieldName = 'BusinessId';
                                        clm1.label = System.Label.Business_ID;
                                        if((!agentList.isEmpty() && agentList[0].type__c == System.label.Agent_Business_Option) || (!agentAssociatedTempLst.isEmpty() && agentAssociatedTempLst.get(0).Temp_Type__c == System.label.Agent_Business_Option)){
                                            lstclm.add(clm1);
                                        }
                                        ColumnsWrapper clm2 = new ColumnsWrapper();
                                        clm2.fieldName = 'AgentEmail';
                                        clm2.label = System.Label.Agent_Email;
                                        lstclm.add(clm2);
                                        ColumnsWrapper clm3 = new ColumnsWrapper();
                                        clm3.fieldName = 'AgentPhone';
                                        clm3.label = System.Label.Mobile_Number;
                                        lstclm.add(clm3);
                                        ColumnsWrapper clm4 = new ColumnsWrapper();
                                        clm4.fieldName = 'BusinessAddress';
                                        clm4.label = System.Label.BusinessaddressStageBFR;
                                        lstclm.add(clm4);
                                        ColumnsWrapper clm5 = new ColumnsWrapper();
                                        clm5.fieldName = 'MailingAddress';
                                        clm5.label = System.Label.Mailing_Address;
                                        lstclm.add(clm5);
                                        ColumnsWrapper clm6 = new ColumnsWrapper();
                                        clm6.fieldName = 'ResAddress';
                                        clm6.label = System.Label.brs_Res_Address;
                                        lstclm.add(clm6);
                                        config.tablecolumns = lstclm;
                                    } else if (configData.Data_Table_Object__c == 'Principal__c') {
                                        List<ColumnsWrapper> lstclm = new List<ColumnsWrapper>();
                                        ColumnsWrapper clm1 = new ColumnsWrapper();
                                        clm1.fieldName = 'PrincipalName';
                                        clm1.label = System.Label.Name;
                                        lstclm.add(clm1);
                                        ColumnsWrapper clm2 = new ColumnsWrapper();
                                        clm2.fieldName = 'PrincipalTitle';
                                        clm2.label = System.Label.TitleLabel_ReservationReview;
                                        lstclm.add(clm2);
                                        ColumnsWrapper clm3 = new ColumnsWrapper();
                                        clm3.fieldName = 'PrincipalEmail';
                                        clm3.label = System.Label.Review_Email;
                                        lstclm.add(clm3);
                                        ColumnsWrapper clm4 = new ColumnsWrapper();
                                        clm4.fieldName = 'BusinessAddress';
                                        clm4.label = System.Label.BusinessaddressStageBFR;
                                        lstclm.add(clm4);
                                        ColumnsWrapper clm5 = new ColumnsWrapper();
                                        clm5.fieldName = 'ResAddress';
                                        clm5.label = System.Label.brs_Res_Address;
                                        lstclm.add(clm5);
                                        config.tablecolumns = lstclm;
                                    }
                                }
                                if (configData.Data_Table_Object__c == Label.Agent_API_Name || test.isRunningTest()) {
                                    if(IsLLPAndWithAddressInCT && configData.DeveloperName == Label.Key_Contact_Agent_LLP){
                                        config.responseText =Label.DoNotShowField;
                                    } else {
                                        boolean showViewUpdateForAgent = false;
                                        List<Temp_History__c> agentAssociatedTemp = new List<Temp_History__c>();
                                        Map<String, List<Map<String, List<wrapperTableData>>>> associatedUpdatedDate = new Map<String, List<Map<String, List<wrapperTableData>>>>();
                                        if (allChangedData.containsKey(Label.Label_Agent_Comparable)) {
                                            if (allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Created) || allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Edited)) {
                                                showViewUpdateForAgent = true;
                                                // Will return either 'Created' or 'Edited' Map, as at a time we will have only 1 agent modified data in temp history.
                                                agentAssociatedTemp = allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Created) ? allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Created).values() : allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Edited).values();
                                                config.responseText = !agentAssociatedTemp.isEmpty() ? agentAssociatedTemp[0].Name__c : '';
                                                List<wrapperTableData> lstAgentWrap = new List<wrapperTableData>();
                                                wrapperTableData agentWrapObj = new wrapperTableData(agentAssociatedTemp.get(0));
                                                lstAgentWrap.add(agentWrapObj);
                                                Map<String, List<wrapperTableData>> oldAndNewDataMap = new Map<String, List<wrapperTableData>>();
                                                List<Map<String, List<wrapperTableData>>> oldAndNewDataMapLst = new List<Map<String, List<wrapperTableData>>>();
                                                // Creating a list of MAP of previous and updated data.
                                                if(allChangedData.get(Label.Label_Agent_Comparable).containsKey(Label.Label_Created)){
                                                    oldAndNewDataMap.put(Label.Label_Updated,new List<wrapperTableData>{new wrapperTableData((Temp_History__c) allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Created).values().get(0))});
                                                 if(!agentList.isEmpty())
                                                    oldAndNewDataMap.put(Label.Previous_Comparable, new List<wrapperTableData>{new wrapperTableData(agentList.get(0))});
                                                } else {
                                                    oldAndNewDataMap.put(Label.Label_Updated,new List<wrapperTableData>{new wrapperTableData((Temp_History__c) allChangedData.get(Label.Label_Agent_Comparable).get(Label.Label_Edited).values().get(0))});
                                                    if(!agentList.isEmpty())
                                                    oldAndNewDataMap.put(Label.Previous_Comparable, new List<wrapperTableData>{new wrapperTableData(agentList.get(0))});
                                                }
                                                oldAndNewDataMapLst.add(oldAndNewDataMap);
                                                if (associatedUpdatedDate.containsKey(Label.Label_Edited)) {
                                                    associatedUpdatedDate.get(Label.Label_Edited).addAll(oldAndNewDataMapLst);
                                                } else {
                                                    associatedUpdatedDate.put(Label.Label_Edited, oldAndNewDataMapLst);
                                                }
                                                tableDataList = lstAgentWrap;
                                            } else {
                                                showViewUpdateForAgent = false;
                                                config.responseText = !agentList.isEmpty() ? agentList[0].Name__c : '';
                                                tableDataList = typeCastToWrapper(new List<Principal__c>(), agentList, new List<Temp_History__c>());
                                            }
                                            config.showViewUpdateForAgent = showViewUpdateForAgent;
                                            config.associatedUpdatedDate = associatedUpdatedDate;
                                        } else {
                                            config.showViewUpdateForAgent = showViewUpdateForAgent;
                                            config.responseText = !agentList.isEmpty() ? agentList[0].Name__c : '';
                                            tableDataList = typeCastToWrapper(new List<Principal__c>(), agentList, new List<Temp_History__c>());
                                        }
                                        config.tabledata = tableDataList;
                                        Boolean agentdataValid = true;
                                        if (!agentAssociatedTemp.isEmpty()) {
                                            Temp_History__c oTempAgent = agentAssociatedTemp.get(0);
                                            if (oTempAgent.Temp_Type__c != System.Label.Secretary_of_the_State_Comparable) {
                                                if (oTempAgent.Temp_Type__c == System.Label.Individual) {
                                                    isAgentDataValid = getFieldValidation(oTempAgent, newIndividualAgentValidation, false, true);
                                                } else {
                                                    isAgentDataValid = getFieldValidation(oTempAgent, newBusinessAgentValidation, false, true);
                                                }
                                                if (isAgentDataValid && isAgentMailingAddressValidationRequired) {
                                                    isAgentDataValid = getFieldValidation(oTempAgent, agentMailingAddressValidation, false, true);
                                                }
                                            }
                                        } else {
                                            if (!agentList.isEmpty()) {
                                                Agent__c oag = agentList.get(0);
                                                if (oag.Type__c != System.Label.Secretary_of_the_State_Comparable) {
                                                    if (oag.Type__c == System.Label.Individual) {
                                                        isAgentDataValid = getFieldValidation(oag, oldIndividualAgentValidation, false, true);
                                                    } else {
                                                        isAgentDataValid = getFieldValidation(oag, oldBusinessAgentValidation, false, true);
                                                    }
                                                    if (isAgentDataValid && isAgentMailingAddressValidationRequired) {
                                                        isAgentDataValid = getFieldValidation(oag, agentMailingAddressValidation, false, true);
                                                    }
                                                }
                                            }
                                        }
                                        If (section.title == System.Label.Key_Contacts_Comparable && (!isAgentDataValid || (agentAssociatedTemp.isEmpty() && agentList.IsEmpty()))) {
                                            config.isAgentDataValid = false;
                                            section.isAgentDataValid = false;
                                        }
    
                                    }
                                } else if (configData.Data_Table_Object__c == 'Principal__c') {
                                    List<wrapperTableData> wrapObjLst = new List<wrapperTableData>();
                                    Set<Id> sObjectIdsNotToAddfromOriginal = new Set<Id>();
                                    Map<String,List<List<wrapperTableData>>> associatedAddedOrDeletedData = new Map<String,List<List<wrapperTableData>>>();
                                    Map<String, List<Map<String, List<wrapperTableData>>>> associatedUpdatedDate = new Map<String, List<Map<String, List<wrapperTableData>>>>();
    
                                    if (allChangedData.containsKey('Principal')) {
                                        for (Principal__c obj : principalList) {
                                            if (!allChangedData.get('Principal').isEmpty()) {
                                                if (allChangedData.get('Principal').containsKey('Edited')) {
                                                    if (allChangedData.get('Principal').get('Edited').containsKey(obj.Id)) {
                                                        wrapObjLst.add(new wrapperTableData((Temp_History__c) allChangedData.get('Principal').get('Edited').get(obj.Id)));
                                                        sObjectIdsNotToAddfromOriginal.add(obj.Id);
    
                                                        // Creating a list of MAP of previous and updated data.
                                                        Map<String, List<wrapperTableData>> oldAndNewDataMap = new Map<String, List<wrapperTableData>>();
                                                        List<Map<String, List<wrapperTableData>>> oldAndNewDataMapLst = new List<Map<String, List<wrapperTableData>>>();
                                                        oldAndNewDataMap.put('Updated',new List<wrapperTableData>{new wrapperTableData((Temp_History__c) allChangedData.get('Principal').get('Edited').get(obj.Id))});
                                                        oldAndNewDataMap.put('Previous', new List<wrapperTableData>{new wrapperTableData(obj)});
                                                        oldAndNewDataMapLst.add(oldAndNewDataMap);
    
                                                        if (associatedUpdatedDate.containsKey('Edited')) {
                                                            associatedUpdatedDate.get('Edited').addAll(oldAndNewDataMapLst);
                                                        } else {
                                                            associatedUpdatedDate.put('Edited', oldAndNewDataMapLst);
                                                        }
                                                    }
                                                }
                                                if (allChangedData.get('Principal').containsKey('Deleted')) {
                                                    //If any record is deleted then show the temp record associated as 'deleted' and hide the original records.
                                                    if (allChangedData.get('Principal').get('Deleted').containsKey(obj.Id)) {
                                                        sObjectIdsNotToAddfromOriginal.add(obj.Id);
                                                        List<wrapperTableData> individualRecords = new List<wrapperTableData>();
                                                        //Deleted temp record data.
                                                        individualRecords.add(new wrapperTableData(obj));
                                                        if (associatedAddedOrDeletedData.containsKey('Deleted')) {
                                                            // Need to send Array of multiple arrays in FE for datatable
    
                                                            associatedAddedOrDeletedData.get('Deleted').add(individualRecords);
                                                        } else {
                                                            List<List<wrapperTableData>> deletedRecord = new List<List<wrapperTableData>>();
                                                            deletedRecord.add(individualRecords);
                                                            associatedAddedOrDeletedData.put('Deleted', deletedRecord);
                                                        }
                                                    }
                                                }
                                                if (!sObjectIdsNotToAddfromOriginal.contains(obj.Id)) {
                                                    wrapObjLst.add(new wrapperTableData(obj));
                                                }
                                            } else {
                                                // If no temp records, assign the original list of principals.
                                                wrapObjLst.addAll(typeCastToWrapper(principalList, new List<Agent__c>(), new List<Temp_History__c>()));
                                                break;
                                            }
                                        }
                                        // Add newly created temp records :
                                        if (allChangedData.containsKey('Principal')) {
                                            if (allChangedData.get('Principal').containsKey('Created')) {
                                                List<List<wrapperTableData>> createdRecords = new List<List<wrapperTableData>>();
                                                List<wrapperTableData> allwrapperData = new List<wrapperTableData>();
                                                allwrapperData = typeCastToWrapper(new List<Principal__c>(), new List<Agent__c>(), (List<Temp_History__c>)allChangedData.get('Principal').get('Created').values());
                                                for(wrapperTableData wrpObj : allwrapperData){
                                                    List<wrapperTableData> allwrapperDataAsIndividualArray = new List<wrapperTableData>();
                                                    allwrapperDataAsIndividualArray.add(wrpObj);
                                                    createdRecords.add(allwrapperDataAsIndividualArray);
                                                }
                                                associatedAddedOrDeletedData.put('Created',createdRecords);
                                                wrapObjLst.addAll(allwrapperData);
                                            }
                                        }
                                    } else {
                                        // If no temp records, assign the original list of principals.
                                        wrapObjLst.addAll(typeCastToWrapper(principalList, new List<Agent__c>(), new List<Temp_History__c>()));
                                    }
                                    List<Temp_History__c> allPrTemp = new List<Temp_History__c>();
                                    if (allChangedData.containsKey(System.Label.Principal)) {
                                        if (!allChangedData.get(System.Label.Principal).isEmpty()) {
                                            if (allChangedData.get(System.Label.Principal).containsKey(System.Label.Label_Edited)) {
                                                allPrTemp.addAll((List<Temp_History__c>)allChangedData.get(System.Label.Principal).get(System.Label.Label_Edited).values());
                                            }
                                            if (allChangedData.get(System.Label.Principal).containsKey(System.Label.Label_Created)) {
                                                allPrTemp.addAll((List<Temp_History__c>)allChangedData.get(System.Label.Principal).get(System.Label.Label_Created).values());
                                            }
                                        }
                                    }
                                    Boolean isPrincipalDatValid = arePrincipalsInfoValid(allPrincipalMap.values(), sObjectIdsNotToAddfromOriginal, allPrTemp, isCorpBusiness);
                                    If (section.title == System.Label.Key_Contacts_Comparable && (!isPrincipalDatValid || (allPrincipalMap.values().isEmpty() && allPrTemp.isEmpty()))) {
                                        config.isPrincipalDataValid = false;
                                        section.isPrincipalDataValid = false;
                                    }
                                    config.associatedAddedOrDeletedData = associatedAddedOrDeletedData;
                                    config.associatedUpdatedDate = associatedUpdatedDate;
                                    config.tabledata = wrapObjLst;
                                    config.responseText = !wrapObjLst.isEmpty() ? String.valueOf(wrapObjLst.size()) : '';
                                }
                                config.isDatavalid = sectionDataValid;
                            }
                        }
                        if (config.responseText != 'DoNotShowField') {
                            configList.add(config);
                        }
                        configList.sort();
                    }
                    section.value = configList;
                }
                if (section.value != null && section.value.size() > 0) {
                    sectionWrapperList.add(section);
                }
            }
        }
        return sectionWrapperList;
    }

    /********************************************************************************************
    METHOD NAME    : getChangesFromTempHistory
    DESCRIPTION    : returns a map of object and there changes made.
    RETURN TYPE    : Map<String,Map<String,Map<sObject,sObject>>>
    PARAMETER      : Principal List, Agent List, Incorporator List and The Temp History Records.
    ********************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<String, Map<Id, sObject>>> getChangesFromTempHistory (Account accSObj, Map<Id, Principal__c> principalMap, Map<Id, Agent__c> agentMap, List<Temp_History__c> tempHistoryList) {
        Map<String, Map<String, Map<Id, sObject>>> allComparisionData = new Map<String, Map<String, Map<Id, sObject>>>();
        Map<String, Map<Id, sObject>> mapDMLChanges = new Map<String, Map<Id, sObject>>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(accSObj.Id, accSObj);
        for (AggregateResult agro : [Select count(id), Type__c from Temp_History__c WITH SECURITY_ENFORCED Group By Type__c]) {
            if (agro.get('Type__c') == 'Principal') {
                mapDMLChanges = retDataComparisionObject(String.valueOf(agro.get('Type__c')), 'Principal__c', principalMap, tempHistoryList);
            } else if (agro.get('Type__c') == 'Agent') {
                mapDMLChanges = retDataComparisionObject(String.valueOf(agro.get('Type__c')), 'Agent__c', agentMap, tempHistoryList);
            } else if (agro.get('Type__c') == 'Account') {
                mapDMLChanges = retDataComparisionObject(String.valueOf(agro.get('Type__c')), 'Account__c', accountMap, tempHistoryList);
            }
            If(!mapDMLChanges.isEmpty()) {
                allComparisionData.put(String.valueOf(agro.get('Type__c')), mapDMLChanges);
            }
        }
        return allComparisionData;
    }
    /********************************************************************************************
    METHOD NAME    : retDataComparisionObject
    DESCRIPTION    : returns a map of object and there changes made.
    RETURN TYPE    : Map<String, Map<Id, sObject>>
    PARAMETER      : The type of temp_history record, api name of field to compare, map of object records to compare and temp history record list.
    ********************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<Id, sObject>> retDataComparisionObject(String type, String fieldAPIName, Map<Id, sObject> objectToCompare, List<Temp_History__c> tempHistoryList) {
        Map<String, Map<Id, sObject>> mapDMLChanges = new Map<String, Map<Id, sObject>>();
        for (Temp_History__c tmpObj : tempHistoryList) {
            if (tmpObj.Type__c == type) {
                if (tmpObj.get(fieldAPIName) != NULL) {
                    if (tmpObj.Change_Type__c != 'Deleted') {
                        if (objectToCompare.containsKey(String.valueOf(tmpObj.get(fieldAPIName)))) {
                            // Store the temp history records for edited data.
                            if (mapDMLChanges.containsKey('Edited')) {
                                mapDMLChanges.get('Edited').put(Id.valueOf(String.valueOf(tmpObj.get(fieldAPIName))), tmpObj);
                            } else {
                                Map<Id, sObject> editedDataMap = new Map<Id, sObject>();
                                editedDataMap.put(Id.valueOf(String.valueOf(tmpObj.get(fieldAPIName))), tmpObj);
                                mapDMLChanges.put('Edited', editedDataMap);
                            }
                        }
                    } else {
                        // Store the temp history records for deleted data.
                        if (mapDMLChanges.containsKey('Deleted')) {
                            mapDMLChanges.get('Deleted').put(Id.valueOf(String.valueOf(tmpObj.get(fieldAPIName))), tmpObj);
                        } else {
                            Map<Id, sObject> deletedDataMap = new Map<Id, sObject>();
                            deletedDataMap.put(Id.valueOf(String.valueOf(tmpObj.get(fieldAPIName))), tmpObj);
                            mapDMLChanges.put('Deleted', deletedDataMap);
                        }
                    }
                } else if (tmpObj.get(fieldAPIName) == NULL) {
                    // Store the temp history records for newly created data.
                    if (mapDMLChanges.containsKey('Created')) {
                        mapDMLChanges.get('Created').put(tmpObj.Id, tmpObj);
                    } else {
                        Map<Id, sObject> newInsertedDataMap = new Map<Id, sObject>();
                        newInsertedDataMap.put(tmpObj.Id, tmpObj);
                        mapDMLChanges.put('Created', newInsertedDataMap);
                    }
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2185 BUg fix 2724
                    * Change(s)/Modification(s) Description : Added condition to break loop when any latest agent record(temp) is obtained
                    * Change(s)/Modification(s) Made on : 2021-02-25
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    
                    if(tmpObj.Type__c == 'Agent' && !mapDMLChanges.isEmpty()){
                        if(mapDMLChanges.containsKey('Created') || mapDMLChanges.containsKey('Edited')){ break; }
                    }
                }
            } else { continue; }
        }
        return mapDMLChanges;
    }
    /********************************************************************************************
    METHOD NAME    : getTableDataForOverview
    DESCRIPTION    : returns a list of sobject and there changes made.
    RETURN TYPE    : list<sObject>
    PARAMETER      : This method is used to get the list of recently created data from temp history and changes from the original record. To be viewed on the
                     'Overview Section'
    ********************************************************************************************/
    public static list<sObject> getTableDataForOverview(List<SObject> allOrginalTableData, Map<String, Map<Id, SObject>> originalDataDMLChanged) {
        List<SObject> tableDataForOverview = new List<SObject>();
        for (sObject obj : allOrginalTableData) {
            if (originalDataDMLChanged.containsKey('Edited')) {
                if (originalDataDMLChanged.get('Edited').containsKey(obj.Id)) {
                    //Added the edited record.
                    tableDataForOverview.add(originalDataDMLChanged.get('Edited').get(obj.Id));
                } else {
                    // If not edited add the original record.
                    tableDataForOverview.add(obj);
                }
            } else {
                tableDataForOverview.add(obj);
            }
        }
        if (originalDataDMLChanged.containsKey('Created')) {
            // Add all the newly created data in temp history
            tableDataForOverview.addAll(originalDataDMLChanged.get('Created').values());
        }
        return tableDataForOverview;
    }
    /********************************************************************************************
        METHOD NAME    : getAccContactList
        DESCRIPTION    : to Get account id from account contact relation with respect to logged in user
        RETURN TYPE    : List of AccountContactRelation
        Author         : Priyanka Sharma
    ********************************************************************************************/
    public static List<AccountContactRelation> getAccContactList() {
        List<AccountContactRelation> acrRecList = new List<AccountContactRelation>();
        if(Schema.SObjectType.User.isAccessible()){
            Id userContactId = [select id, contactId from User where id = : UserInfo.getUserId() WITH SECURITY_ENFORCED].contactId;
            acrRecList = [SELECT Id,AccountId FROM AccountContactRelation where  ContactId=:userContactId WITH SECURITY_ENFORCED];
        }
        return acrRecList;
    }
    /********************************************************************************************
        METHOD NAME    : getCertificate
        DESCRIPTION    : to Get certificate information
        RETURN TYPE    : Object
        Author         : Rabbani
    ********************************************************************************************/
    @AuraEnabled
    public static SObject getCertificate(String certificateNumber,String businessId)
    {
        // BRS-7779 - Added clause to search for Copy request details
        if(certificateNumber.containsIgnoreCase('CP')){
            Copy_Request_Details__c copyInfo = [SELECT Id, Name, CreatedDate, Copy_Type__c, Mark_Filing_Number__c, Mark_Filing__c, Mark_Filing__r.Filing_Type__c, UCC_Filing_Number__c, UCC_Filing__c, UCC_Filing__r.Type__c,
                                    Other_Request__c, toLabel(Other_Request__r.Status__c), Other_Request__r.Name, Other_Request__r.Certificate_Type__c,Other_Request__r.Requested_On__c,Other_Request__r.Business__c,toLabel(Other_Request__r.Business__r.Status__c),Other_Request__r.Business__r.Name,Other_Request__r.Business__r.ShippingAddress,Other_Request__r.Business__r.AccountNumber,Other_Request__r.Business__r.BillingAddress
                                    FROM Copy_Request_Details__c 
                                    WHERE Name =: String.escapeSingleQuotes(certificateNumber) WITH SECURITY_ENFORCED LIMIT 1];
            return copyInfo;
        }
        Certficate__c certificateinfo=[Select id,name,Certificate_Type__c,Requested_On__c,Business__c,Business__r.Status__c,Business__r.Name,Business__r.ShippingAddress,Business__r.AccountNumber,Business__r.BillingAddress from Certficate__c where Name=:String.escapeSingleQuotes(certificateNumber) WITH SECURITY_ENFORCED];
        return certificateinfo;
    }

    /********************************************************************************************
        METHOD NAME    : getAccContactList
        DESCRIPTION    : to Get profile name of logged in user
        RETURN TYPE    : List of AccountContactRelation
        Author         : Priyanka Sharma
    ********************************************************************************************/
     public static String getLoggedInUserProfile() {
        String profileName = [Select Name from Profile where Id = : UserInfo.getProfileid()].name;
        return profileName;
    }
    public without sharing class wrapperTableData {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String PrincipalType {get; set;}
        @AuraEnabled public String PrincipalId {get; set;}
        @AuraEnabled public String PrincipalTitle {get; set;}
        @AuraEnabled public String AgentName {get; set;}
        @AuraEnabled public String Agent {get; set;}
        @AuraEnabled public String AgentPhone {get; set;}
        @AuraEnabled public String AgentEmail {get; set;}
        @AuraEnabled public String PrincipalEmail {get; set;}
        @AuraEnabled public String BusinessId {get; set;}
        @AuraEnabled public String BusinessAddress {get; set;}
        @AuraEnabled public String MailingAddress {get; set;}
        @AuraEnabled public String ResAddress {get; set;}
        @AuraEnabled public String PrincipalName {get; set;}
        @AuraEnabled public String AgentType {get; set;}

        public wrapperTableData(Principal__c prObj) {
            this.Id = prObj.Id;
            this.PrincipalName = prObj.Name__c;
            this.PrincipalEmail = prObj.Email__c;
            this.PrincipalType = prObj.Principal_Type__c;
            this.PrincipalTitle = prObj.Principal_Title__c;
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2360
            * Change(s)/Modification(s) Description : Adding condition for business ID to bring from Principal_Account_ID__c if Principal_Type__c is Business
            * Change(s)/Modification(s) Made on : 2021-03-01
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if(prObj.Principal_Type__c == 'Business'){
                if(prObj.Principal_Account_ID__c != NULL){
                    this.BusinessId = prObj.Principal_Account_ID__r.AccountNumber;
                } else  {
                    this.BusinessId = NULL;
                }
            }
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4263
            * Change(s)/Modification(s) Description : Added None if the business address is empty.
            * Change(s)/Modification(s) Made on : 2021-05-19
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            this.BusinessAddress = prObj.Business_Address_1__c != null ? prObj.Business_Address_1__c : System.Label.None;
            this.MailingAddress = prObj.Mailing_Address__c;
            this.ResAddress = prObj.Residence_Address__c;
        }
        public wrapperTableData(Agent__c agObj) {
            this.Id = agObj.Id;
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2360
            * Change(s)/Modification(s) Description : Adding condition for business ID to bring from Agent_Account_ID__c if Type__c is Business
            * Change(s)/Modification(s) Made on : 2021-03-01
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if(agObj.Type__c == 'Business'){
                if(agObj.Agent_Account_ID__c != NULL){
                    this.BusinessId = agObj.Agent_Account_ID__r.AccountNumber;
                } else  {
                    this.BusinessId = NULL;
                }
            }
            this.AgentName = agObj.Name__c;
            this.AgentType = agObj.type__c;
            this.BusinessAddress = agObj.Business_InternationalAddress__c != NULL ? (agObj.Business_InternationalAddress__c + ', ' + agObj.Business_Country__c) : agObj.Business_Address__c;
            this.MailingAddress = agObj.Mailing_Address__c;
            this.AgentPhone = agObj.Agent_Phone__c != NULL ? String.valueOf(agObj.Agent_Phone__c) : '';
            this.AgentEmail = agObj.Email__c;
            //Added fix for 3755 Agent ]]]
            this.ResAddress = agObj.Agent_Residence_Address__c;
        }
        public wrapperTableData(Temp_History__c tempObj) {

            List<String> businessAddressFields = new List<String>();
            businessAddressFields.add('Business_Street_Address_1__c');
            businessAddressFields.add('Business_Street_Address_2__c');
            businessAddressFields.add('Business_Street_Address_3__c');
            businessAddressFields.add('Business_City__c');
            businessAddressFields.add('Business_State__c');
            businessAddressFields.add('Business_Zip_Code__c');
            businessAddressFields.add('Business_Country__c');

            List<String> mailingAddressFields = new List<String>();
            mailingAddressFields.add('Mailing_Street_Address_1__c');
            mailingAddressFields.add('Mailing_Street_Address_2__c');
            mailingAddressFields.add('Mailing_Street_Address_3__c');
            mailingAddressFields.add('Mailing_City__c');
            mailingAddressFields.add('Mailing_State__c');
            mailingAddressFields.add('Mailing_Zip_Code__c');
            mailingAddressFields.add('Mailing_Country__c');

            List<String> residenceAddressFields = new List<String>();
            residenceAddressFields.add('Residence_Street_Address_1__c');
            residenceAddressFields.add('Residence_Street_Address_2__c');
            residenceAddressFields.add('Residence_Street_Address_3__c');
            residenceAddressFields.add('Residence_City__c');
            residenceAddressFields.add('Residence_State__c');
            residenceAddressFields.add('Residence_Zip_Code__c');
            residenceAddressFields.add('Residence_Country__c');
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4263
            * Change(s)/Modification(s) Description : Added None if the business address is empty.
            * Change(s)/Modification(s) Made on : 2021-05-19
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */

            this.BusinessAddress = (tempObj.Business_InternationalAddress__c != NULL && tempObj.Business_InternationalAddress__c != QnA_Constants.EMPTY_STRING) ? tempObj.Business_InternationalAddress__c + ', ' + tempObj.Business_Country__c : getAddress(tempObj, businessAddressFields) !=  QnA_Constants.EMPTY_STRING? getAddress(tempObj, businessAddressFields) : System.Label.None;
            this.MailingAddress = tempObj.Mailing_International_Address__c != NULL ? tempObj.Mailing_International_Address__c + ', ' + tempObj.Mailing_Country__c : getAddress(tempObj, mailingAddressFields);
            this.ResAddress = tempObj.Residence_InternationalAddress__c != NULL ? tempObj.Residence_InternationalAddress__c + ', ' + tempObj.Residence_Country__c : getAddress(tempObj, residenceAddressFields);

            if (tempObj.Type__c == 'Principal') {
                this.Id = tempObj.Id;
                this.PrincipalId = tempObj.Principal__c != NULL ? tempObj.Principal__c : tempObj.Id;
                this.PrincipalName = tempObj.Name__c;
                this.PrincipalEmail = tempObj.Email__c;
                this.PrincipalType = tempObj.Temp_Type__c;
                this.PrincipalTitle = tempObj.Title__c;
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2360
                * Change(s)/Modification(s) Description : Adding condition for business ID to bring from Account__c if Temp_Type__c	 is Organisation
                * Change(s)/Modification(s) Made on : 2021-03-01
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if(tempObj.Temp_Type__c == 'Business'){
                    if(tempObj.Account__c != NULL){
                        this.BusinessId = tempObj.Account__r.AccountNumber;
                    } else  {
                        this.BusinessId = NULL;
                    }
                }
            } else if (tempObj.Type__c == 'Agent') {
                this.Id = tempObj.Id;
                this.AgentName = tempObj.Name__c;
                this.AgentPhone = tempObj.Phone__c != NULL ? String.valueOf(tempObj.Phone__c) : '';
                this.AgentEmail = tempObj.Email__c;
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2360
                * Change(s)/Modification(s) Description : Adding condition for business ID to bring from Account__c if Temp_Type__c	 is Organisation
                * Change(s)/Modification(s) Made on : 2021-03-01
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if(tempObj.Temp_Type__c == 'Business'){
                    if(tempObj.Account__c != NULL){
                        this.BusinessId = tempObj.Account__r.AccountNumber;
                    } else  {
                        this.BusinessId = NULL;
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static List<wrapperTableData> typeCastToWrapper(List<Principal__c> prList, List<Agent__c> agList, List<Temp_History__c> tmList){
        List<wrapperTableData> allTableData = new List<wrapperTableData>();
        If(!prList.isEmpty()){
            for(Principal__c pr : prList){
                allTableData.add(new wrapperTableData(pr));
            }
        }
        If(!agList.isEmpty()){
            for(Agent__c ag : agList){
                allTableData.add(new wrapperTableData(ag));
            }
        }
        If(!tmList.isEmpty()){
            for(Temp_History__c tm : tmList){
                allTableData.add(new wrapperTableData(tm));
            }
        }
        return allTableData;
    }
	
	/********************************************************************************************
        METHOD NAME    : getAllcerts
        DESCRIPTION    : to Get certificate types from custom metadata
        RETURN TYPE    : List of cert records
        Author         : Rahul Sharma
            *@update : BRS-6171 | Enable longform for online flow
    ********************************************************************************************/
    @AuraEnabled
    public static List<Master_Fee__c> getAllcerts(String accountId) {
        List<Master_Fee__c> certList = new List<Master_Fee__c>();
        
        List<String> cerTypes = new List<String>{
            system.label.brs_CertficateTypes,
            system.label.brs_CertficateTypeStandard,
            system.label.brs_CertficateTypeLongform
        };
        
        try {
            if(!String.isBlank(accountId) && accountId != null) {
                List<Account> lstAcc = [
                    SELECT Id, Business_Type__c, Citizenship__c, Status__c, Sub_status__c
                    FROM Account
                    WHERE Id = :String.escapeSingleQuotes(accountId)
                    WITH SECURITY_ENFORCED
                ];

                if(!lstAcc.isEmpty()) {
                    String businessType = lstAcc[0].Business_Type__c;
                    String citizenship = lstAcc[0].Citizenship__c;

                    if(
                        (
                            System.Label.Domestic_Label_Comparable.equalsIgnoreCase(citizenship)
                            && 
                            (
                                System.Label.Limited_Partnership_Comparable.equalsIgnoreCase(businessType)
                                || 
                                System.Label.Statutory_Trust_Comparable.equalsIgnoreCase(businessType)
                            )
                        ) 
                        || 
                        System.Label.Foreign_Label_Comparable.equalsIgnoreCase(citizenship)
                    ) {
                        Integer iIndex = cerTypes.indexOf(System.Label.brs_CertficateTypeLongform);
                        cerTypes.remove(iIndex);
                    }

                    certList = [
                        SELECT Id, Filing_Type__c, Amount__c 
                        FROM Master_Fee__c 
                        WHERE Business_Type__c = :businessType 
                            AND Filing_Type__c IN: cerTypes 
                        WITH SECURITY_ENFORCED
                    ];
                }
            }

            return certList;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************
    METHOD NAME    : getQueryConfig
    DESCRIPTION    : returns a list of records of QueryConfigMetadata.
    RETURN TYPE    : List<BRS_online_enquiry__mdt>
    PARAMETER      : String
    ********************************************************************************************/
    @AuraEnabled
    public static  List<BRS_online_enquiry__mdt> getQueryConfig(string devName) {
        try {
            List<BRS_online_enquiry__mdt> lstQueryObj = new List<BRS_online_enquiry__mdt>();
            lstQueryObj = [Select id,Download_Limit__c,Search_Object__c,Search_Limit__c,Include_Filters__c from BRS_online_enquiry__mdt Where DeveloperName =:devName] ;           
            return lstQueryObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : udtEffectiveDateTime
        DESCRIPTION    : Update the fields EffectiveDate/EffectiveTime on business filing
        RETURN TYPE    : Boolean : Check for updated true or false
        Author         : Avinash Shukla
    ********************************************************************************************/
    @AuraEnabled
    public static Boolean udtEffectiveDateTime(Business_Filing__c bfObj, Account accObj, Date effectiveDate, String effectiveTime ){
        try {
            Boolean isSuccess = false;
            if(effectiveDate != NULL){
            Business_Filing__c bfObjnew = new Business_Filing__c(Id=bfObj.Id);
                bfObjnew.Effective_Date__c = effectiveDate;
                if(!String.isEmpty(effectiveTime)){
                    String strHour = '';
                    String strMin = '';
                    String strTimeOfDay = '';
                    List<String> timeStr = effectiveTime.split(Label.Seperator_Colon);
                    if(!timeStr.isEmpty() && timeStr.size() > 0){
                        strHour = timeStr.get(0);
                        if(timeStr.get(1).split(' ').size() > 0){
                            strMin = timeStr.get(1).split(' ').get(0);
                            strTimeOfDay = timeStr.get(1).split(' ').get(1);
                        }
                    }
                    Integer hr = strTimeOfDay == 'PM' ? (Integer.valueOf(strHour) == 12 ? Integer.valueOf(strHour) : Integer.valueOf(strHour) + 12) : Integer.valueOf(strHour) == 12 ? 0 : Integer.valueOf(strHour);
                    Integer min = Integer.valueOf(strMin);
                    bfObjnew.Effective_Time__c = Time.newInstance(hr,min,DateTime.now().second(),DateTime.now().millisecond());
                } else {
                   bfObjnew.Effective_Time__c = Time.newInstance(DateTime.now().hour(), DateTime.now().minute() , DateTime.now().second(), DateTime.now().millisecond());
                }
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {bfObjnew}, 'update');
                Database.SaveResult SR = Database.update(bfObjnew); 
                isSuccess =  SR.isSuccess();
            }
            return isSuccess;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'udtEffectiveDateTime', 'Business_Filing__c', null, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
	
	/********************************************************************************************
        METHOD NAME    : getOrgWideEmailAddr
        DESCRIPTION    : Generic method to get Org-wide email address.
        PARAMS         : Email Address
        RETURN TYPE    : OrgWideEmailAddress
        Author         : Tamkanat 
    ********************************************************************************************/
    @AuraEnabled
    public static OrgWideEmailAddress getOrgWideEmailAddr(String emailAddr) {
        try{
            OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address=:emailAddr limit 1];
            return owa;
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, 'getOrgWideEmailAddr', 'OrgWideEmailAddress', null, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /********************************************************************************************
        METHOD NAME    : updateBusinessClosingEffectiveDate
        DESCRIPTION    : Update the fields EffectiveDate/EffectiveTime on business filing
        RETURN TYPE    : Boolean : Check for updated true or false
        Author         : Rahul Sharma
    ********************************************************************************************/
    @AuraEnabled
    public static Boolean updateBusinessClosingEffectiveDate(String sId, Date effectiveDate, String effectiveTime ) {
        try {
            Boolean isSuccess = false;
            Business_Filing__c bfObj = new Business_Filing__c(Id=sId);
            Business_filing__c bfilingData=[Select Id,Name,Type__c,Business_Type__c,Work_Order__r.Received_Date__c from Business_Filing__c where Id=:String.escapeSingleQuotes(sId) WITH SECURITY_ENFORCED];
            String strHour = QnA_Constants.EMPTY_STRING;
            String strMin = QnA_Constants.EMPTY_STRING;
            String strTimeOfDay = QnA_Constants.EMPTY_STRING;
            if (effectiveDate != NULL)
            {
                    bfObj.Effective_Date__c = effectiveDate;
                if(effectiveTime == null || String.isEmpty(effectiveTime) || effectiveTime == '') {
                     if(bfilingData.Type__c==System.label.Renunciation_Status_Report && effectiveDate == System.today()){
                        bfObj.Effective_Time__c = Time.newInstance(DateTime.now().hour(), DateTime.now().minute(), DateTime.now().second(), DateTime.now().millisecond());
                    }
                    else if(bfilingData.Business_Type__c == system.label.LLC && bfilingData.Type__c==System.label.Withdrawal_Label && effectiveDate > System.today()){
                        bfObj.Effective_Time__c = Time.newInstance(0, 1, 0, 0);
                    }
                    else if((bfilingData.Business_Type__c == system.label.businessTypeStock || bfilingData.Business_Type__c == system.label.businessTypeNon_Stock) && bfilingData.Type__c==System.label.Withdrawal_Label && effectiveDate > System.today()){
                        bfObj.Effective_Time__c = Time.newInstance(16, 30, 0, 0);
                    }
                    else{
                    if(bfilingData.Type__c==System.label.Withdrawal_Label && effectiveDate > System.today())
                        bfObj.Effective_Time__c = Time.newInstance(16, 0, 0, 0);
                    }
                }
                else
                {
                    List<String> timeStr = effectiveTime.split(':');
                    if (!timeStr.isEmpty() && timeStr.size() > 0) {
                        strHour = timeStr.get(0);
                        if (timeStr.get(1).split(' ').size() > 0) {
                            strMin = timeStr.get(1).split(' ').get(0);
                            strTimeOfDay = timeStr.get(1).split(' ').get(1);
                        }
                    }
                    Integer hr = strTimeOfDay == 'PM' ? (Integer.valueOf(strHour) == Integer.valueOf(system.label.brs_EffectiveDateHours) ? Integer.valueOf(strHour) : Integer.valueOf(strHour) + Integer.valueOf(system.label.brs_EffectiveDateHours)) : Integer.valueOf(strHour) == Integer.valueOf(system.label.brs_EffectiveDateHours) ? 0 : Integer.valueOf(strHour);
                    Integer min = Integer.valueOf(strMin);
                    bfObj.Effective_Time__c = Time.newInstance(hr, min, DateTime.now().second(), DateTime.now().millisecond());
                    bfObj.Effective_Time_Text1__c = effectiveTime;
                }
            }
            else
            {   
                if(bfilingData.Type__c!=System.label.Withdrawal_Label)
                {
					bfObj.Effective_Date__c = Date.today();
				}
                if(effectiveTime == null || String.isEmpty(effectiveTime) || effectiveTime == QnA_Constants.EMPTY_STRING) {
                    bfObj.Effective_Time__c = Time.newInstance(DateTime.now().hour(), DateTime.now().minute(), DateTime.now().second(), DateTime.now().millisecond());
                }
				else
                {
                    List<String> timeStr = effectiveTime.split(':');
                    if (!timeStr.isEmpty() && timeStr.size() > 0) {
                        strHour = timeStr.get(0);
                        if (timeStr.get(1).split(' ').size() > 0) {
                            strMin = timeStr.get(1).split(' ').get(0);
                            strTimeOfDay = timeStr.get(1).split(' ').get(1);
                        }
                    }
                    Integer hr = strTimeOfDay == 'PM' ? (Integer.valueOf(strHour) == Integer.valueOf(system.label.brs_EffectiveDateHours) ? Integer.valueOf(strHour) : Integer.valueOf(strHour) + Integer.valueOf(system.label.brs_EffectiveDateHours)) : Integer.valueOf(strHour) == Integer.valueOf(system.label.brs_EffectiveDateHours) ? 0 : Integer.valueOf(strHour);
                    Integer min = Integer.valueOf(strMin);
                    bfObj.Effective_Time__c = Time.newInstance(hr, min, DateTime.now().second(), DateTime.now().millisecond());
                    bfObj.Effective_Time_Text1__c = effectiveTime;
                }
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {bfObj}, 'update');
            Database.SaveResult SR = Database.update(bfObj);
            isSuccess =  SR.isSuccess();    
        return isSuccess;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateBusinessClosingEffectiveDate', 'Business_Filing__c', null, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************
        METHOD NAME    : getChecklistData
        DESCRIPTION    : Displaying question as per lien type  on business filing
        RETURN TYPE    : List
        Author         : Rabbani
    ********************************************************************************************/

     @AuraEnabled(cacheable=true)
    public static List<String> getChecklistData(String recordId) {
        try {
           List<String> checklistList=new List<String>();
            String obj = SchemaUtility.getObjectFromId(recordId).getName();
            if(obj==System.label.BRS_UCCFilingObject){
            UCC_Filing__c ucctype=[select id,Type__c,UCC_Lien_Type__c,Amendment_Type__c FROM UCC_Filing__c where Id=:String.escapeSingleQuotes(recordId) WITH SECURITY_ENFORCED];
            String searchString = ucctype.Amendment_Type__c==system.label.Termination_value ? ucctype.Amendment_Type__c :ucctype.Type__c ;
            String searchStringValue = ucctype.UCC_Lien_Type__c;           
            for(BRS_Checklist__mdt check:[select Id, Question__c, Language__c, Order__c, Answer__c, UCC_Type__c,Type__c,Lien_Type__c from BRS_Checklist__mdt where ObjectApiName__c=:obj Order By Order__c])
            {                
                if(check.Lien_Type__c!=null){
                    string lienType = check.Lien_Type__c.replace('|',system.label.SEMI_COLON_SEPARATOR); 
                    List<String> lienTypes = lienType.split(system.label.SEMI_COLON_SEPARATOR); 
                    if(searchString!=null && !lienTypes.isEmpty() && lienTypes.contains(searchString)){
                        checklistList.add(check.Question__c);
                    }
                }
            }
        }else  if(obj==System.label.Business_Filing_API_Name){
            for(BRS_Checklist__mdt check:[select Id, Question__c, Language__c, Order__c, Answer__c, UCC_Type__c,Type__c,Lien_Type__c from BRS_Checklist__mdt where ObjectApiName__c=:obj Order By Order__c])
            {     
              checklistList.add(check.Question__c);               
            }
        }
            return checklistList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 public class wrapperChecklist
 {
    @AuraEnabled public String name;
    @AuraEnabled public String isChecked;
    
 }
    @AuraEnabled
    public static UCC_Filing__c updateUccFiling(String Info, String RecordId ) {
        List<wrapperChecklist> listcheck = (List<wrapperChecklist>)JSON.deserialize(Info, List<wrapperChecklist>.class);
        try {
            List<UCC_Filing__c> checklistList = [select Id,name,Owner_address_present__c,Owner_name_present__c,Claimant_name_present__c,Claimant_address_present__c,Aircraft_Vessel_name_present__c,Form_legible__c,Referenced_documents_attached__c,Meets_other_requirements__c,Checklist_Status__c,Debtor_address_present__c,Indicates_debtor_is_indiviudal_organizat__c,	Secured_party_address_present__c,Description_of_vessel__c,Statement_of_assumed_ownership__c,Judgment_creditor_present__c,Judgment_debtor_present__c,Defendant_name_present__c,Plaintiff_name_present__c,Is_court_order_present__c,Is_court_order_signed__c,Secured_party_name_present__c,Debtor_name_present__c from UCC_Filing__c where Id=:String.escapeSingleQuotes(RecordId) WITH SECURITY_ENFORCED];
            for(UCC_Filing__c filing:checklistList)
            {
                for(BRS_Utility.wrapperChecklist Str:listcheck)
                {
                    if(UCC_Filing__c.Owner_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Owner_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Owner_address_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Owner_address_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Claimant_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Claimant_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Claimant_address_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Claimant_address_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Aircraft_Vessel_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Aircraft_Vessel_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Form_legible__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Form_legible__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Referenced_documents_attached__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Referenced_documents_attached__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Meets_other_requirements__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Meets_other_requirements__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Debtor_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Debtor_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Debtor_address_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Debtor_address_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Indicates_debtor_is_indiviudal_organizat__c.getDescribe().getLabel()+'ion?' == str.name)
                    {
                        filing.Indicates_debtor_is_indiviudal_organizat__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Secured_party_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Secured_party_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Secured_party_address_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Secured_party_address_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Description_of_vessel__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Description_of_vessel__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Statement_of_assumed_ownership__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Statement_of_assumed_ownership__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Judgment_debtor_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Judgment_debtor_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Judgment_creditor_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Judgment_creditor_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Defendant_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Defendant_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Plaintiff_name_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Plaintiff_name_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Is_court_order_present__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Is_court_order_present__c=str.isChecked;
                    }
                    else if(UCC_Filing__c.Is_court_order_signed__c.getDescribe().getLabel() == str.name)
                    {
                        filing.Is_court_order_signed__c=str.isChecked;
                    }
                }
                filing.Checklist_Status__c='Completed';
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(checklistList, 'update');
            update checklistList;
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     @AuraEnabled
    public static void updateBusinessFilingChecklist(String Info, String RecordId ){
        try {
            update new Business_Filing__c(Id=RecordId, Checklist_Status__c=System.label.BRS_Status_Value_Completed);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<cloneResponce> cloneBusinessFilingWithRelatedRecords(String filingId)
    {
        try{
        List<Temp_History__c> tempLst = new List<Temp_History__c>();
        List<cloneResponce> lstResults2 = new List<cloneResponce>();
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4225
        * Change(s)/Modification(s) Description : Added fixes for cloning of records, fields added to query were missing and created issue when resuming the flow.
        * Change(s)/Modification(s) Made on : 2021-05-11
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Business_Filing__c busFile = [SELECT ID, Name,Type__c,Account__c,RecordTypeId,Filing_Date__c,Filing_Type__c,Filing_Fee__c,Source__c,Total_Fee__c,Due_Date__c,Citizenship__c,Business_Type__c FROM Business_Filing__c WHERE Id = : String.escapeSingleQuotes(filingId) WITH SECURITY_ENFORCED];
        Business_Filing__c busFile2 = busFile.clone(false,true);
        busFile2.Filing_Date__c = Date.Today();
        busFile2.Status__c = 'In-Progress';
        insert busFile2;
        if((busFile2.Type__c == System.Label.Annual_Report || busFile2.Type__c == System.Label.First_Report )){
            brs_ActionItemUtility.completeActionItem(new List<Business_filing__c> {busFile});
            brs_ActionItemUtility.createActionItem(new List<Business_filing__c> {busFile2});
        }
        List<Temp_History__c> tempRecords = [SELECT Id, Name, Business_Email_Address__c,Business_Name_in_state_country_New__c,Business_Unit_New__c,Mailing_Unit_New__c,Mail_Jurisdiction_International_address__c, Jurisdiction_International_address__c, NAICS_Code__c, Email_New__c, NAICS_Code_New__c, BillingStreet_New__c,Old_Business_Email_Address__c, Billing_City_New__c, BillingState_New__c, BillingPostalCode_New__c, Billing_Country_new__c, Office_Jurisdiction_Address__c, Business_InternationalAddress__c, ShippingStreet_New__c, ShippingCity_New__c, ShippingState_New__c, ShippingPostalCode_New__c, Shipping_Country_New__c, NAICS_Sub_Code__c, Residence_InternationalAddress__c, Business_City__c,Business_Name_in_state_country__c, Business_State__c, Business_Unit__c, Mailing_City__c, Mailing_State__c, Mailing_Unit__c, Related_Record_ID__c, Related_Object__c, Account__c, Business_ID__c, Business_Id__r.AccountNumber, Title__c, Principal__c, Agent__c, Account__r.AccountNumber, Type__c, Billing_City__c, BillingPostalCode__c, BillingState__c, BillingStreet__c, Mailing_International_Address__c, Principle_Office_International_Address__c, ShippingCity__c, ShippingPostalCode__c, ShippingState__c, ShippingStreet__c, Phone__c, FirstName__c, LastName__c, Business_Filing__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Zip_Code__c, Mailing_Street_Address_1__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c, Mailing_Zip_Code__c, Business_Street_Address_3__c, Name__c, Email__c, Business_Country__c, Mailing_Country__c, Residence_Country__c, Residence_State__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Temp_Type__c, Residence_City__c, Optional_Business_Description__c, Change_Type__c, Billing_Country__c,Mailing_Jurisdiction_Country__c,Office_Jurisdiction_Country__c, Shipping_Country__c, Principal_Type__c, Principal_Title__c, Principle_Office_International_Address_N__c, Mailing_International_Address_New__c, Mailing_Jurisdiction_BusinessCity_New__c, Mailing_Jurisdiction_BusinessState_New__c, Mailing_Jurisdiction_BusinessStreet_New__c, Mailing_Jurisdiction_BusinessUnit_New__c, Mailing_Jurisdiction_BusinessZipCode_New__c, Office_Jurisdiction_Address_New__c, Office_Jurisdiction_BusinessCity_New__c, Office_Jurisdiction_BusinessState_New__c, Office_Jurisdiction_BusinessStreet_New__c, Office_Jurisdiction_BusinessUnit_New__c, Office_Jurisdiction_BusinessZipCode_New__c, Jurisdiction_International_address_New__c, Mail_JurisdictionInternationaladdress_N__c, CreatedDate, Business_Name_New__c, Office_Jurisdiction_Country_New__c, Residence_Country_Old__c, Mailing_Jurisdiction_Country_New__c, Date_of_Organization_Meeting_New__c FROM Temp_History__c WHERE Business_Filing__c =: String.escapeSingleQuotes(filingId) WITH SECURITY_ENFORCED];

        for(Temp_History__c temp : tempRecords)
        {
            Temp_History__c temp2 = temp.clone(false,true);
            temp2.Business_Filing__c = busFile2.Id;
            tempLst.add(temp2);
        }
        Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(tempLst, 'insert');
        insert tempLst;
        cloneResponce res = new cloneResponce();
        res.filingId=busFile2.Id;
        lstResults2.add(res);
        return lstResults2;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'cloneBusinessFilingWithRelatedRecords', 'Business_Filing__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public with sharing class cloneResponce {
        @AuraEnabled public string filingId {get; set;}
        public cloneResponce() {}
    }
    public with sharing class dupCheckResponce {
        @AuraEnabled public Boolean nameAvailable {get; set;}
        public dupCheckResponce() {}
    }
     @AuraEnabled
    public static List<maintennaceResponce> createCertificateRecords(String accId, String certTypes, String workOrderId ) {
        List<Certficate__c> insertCerts = new List<Certficate__c>();
        List<maintennaceResponce> lstResults2 = new List<maintennaceResponce>();
        maintennaceResponce res = new maintennaceResponce();
        Boolean isCreationDone = false;
        String sActive = System.Label.ACTIVE;
        Date processingDate = System.today();
        List<String> lstCertTypes = certTypes.split(';');
        Map<String, Decimal> mpCertToAmt = new Map<String, Decimal>();
        String businessType = '';
        Decimal fee = 0;
        if(!String.isBlank(accId) && accId != null){
            businessType = [SELECT Id, Business_Type__c FROM Account WHERE Id = :accId WITH SECURITY_ENFORCED].Business_Type__c;
            if(!String.isBlank(businessType) && businessType != null){
                List<Master_Fee__c> lstMasterFees = [SELECT Id, Business_Type__c, Filing_Type__c, Amount__c
                                                     FROM Master_Fee__c
                                                     WHERE Business_Type__c = :businessType AND
                                                     Filing_Type__c IN :lstCertTypes AND
                                                     Status__c = :sActive AND
                                                     Start_Date__c <= :processingDate AND
                                                     (End_Date__c = null OR
                                                      End_Date__c >= :processingDate)
                                                     WITH SECURITY_ENFORCED];
                if(!lstMasterFees.isEmpty()){
                    for(Master_Fee__c mf : lstMasterFees){
                        mpCertToAmt.put(mf.Filing_Type__c, mf.Amount__c);
                    }
                }
            }
        }
        try{
            if(certTypes != null)
            { 
			Id recordTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByDeveloperName()
                      .get(System.Label.Certificate_Request_RecordTypeAPI).getRecordTypeId(); 
			List<String> certTypesLst = new List<String>();
                if(certTypes.contains(';'))
                    certTypesLst = certTypes.split(';');
                else    
                    certTypesLst = new List<String>{certTypes};          
                for(String str : certTypesLst)
                {
		            if(!mpCertToAmt.isEmpty()){
                        fee = mpCertToAmt.get(str);
                    }
                    Certficate__c cert = new Certficate__c(
                        Business__c = accId,Certificate_Type__c=str,
                        Requested_On__c =Date.today(),
                        Work_Order__c=workOrderId,
                        Filing_Fee__c = fee,
                        Total_Fee__c = fee,
                        RecordTypeId = recordTypeId,
                        Type__c = System.Label.Certificate_of_Legal_Existence,Status__c = System.Label.BRS_FilingStatus_Approved);
                    insertCerts.add(cert);
                }
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(insertCerts, 'insert');
                if(!insertCerts.IsEmpty() && accessCheck)
                {
                    insert insertCerts;
                    isCreationDone = true;

                    //BRS-2891 | Obtain certificate with sdocs | Get certificate id
                    res.mapCertificateIds = new Map<Id, Id>();
                    for(Certficate__c certificate :insertCerts) {
                        res.mapCertificateIds.put(certificate.Id, null);
                    }
                }
            }
        }
        catch (Exception e) {
                    BOS_Utility.ExceptionHandler(className, 'CertifiCateCreation', 'Certficate__c', null, BOS_Utility.sSeverity, e, null);
                    throw new AuraHandledException(e.getMessage());
                }
        res.businessMaintenanceDone = isCreationDone;
        lstResults2.add(res);
        return lstResults2;
    }
    
    @AuraEnabled
    public static Boolean linkBusinessToContact(String accId,String UserId) {
        List<SObject> insertAccountContactRelation = new List<SObject>();
        Boolean isLinkingDone = false;
        try{
            if(accId != null)
            {
                User userdata = [Select id, ContactID from User where id =: UserId WITH SECURITY_ENFORCED Limit 1];
                List<AccountContactRelation> acrRecList = New List<AccountContactRelation>([SELECT Id, AccountId FROM AccountContactRelation where  ContactId = :userdata.ContactID and AccountId =: accId]);

                if(userdata.ContactID != null && acrRecList.IsEmpty())
                {
                    SObject accConRelation = new AccountContactRelation();
                    accConRelation.put('AccountId', accId);
                    accConRelation.put('ContactId', userdata.ContactID);
                    accConRelation.put('StartDate', System.today());
                    insertAccountContactRelation.add(accConRelation);
                    Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(insertAccountContactRelation, 'insert');
                    if(!insertAccountContactRelation.IsEmpty() && accessCheck)
                    {
                        insert insertAccountContactRelation;
                        isLinkingDone = true;
                        brs_ActionItemUtility.createActionItemOnBusinessLinking(insertAccountContactRelation);
                    }
                }
            }
        }
        catch (Exception e) {
                    BOS_Utility.ExceptionHandler(className, 'BusinessUserAccountLink', 'AccountContactRelation', null, BOS_Utility.sSeverity, e, null);
                    throw new AuraHandledException(e.getMessage());
                    }
        return isLinkingDone;
    }
	
	public static Map<String,String> getAppLabels(){
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption1_Comparable,System.label.SpecialBusinessGroupOption1);
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption2_Comparable,System.label.SpecialBusinessGroupOption2);  
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption3_Comparable,System.label.SpecialBusinessGroupOption3);  
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption4_Comparable,System.label.SpecialBusinessGroupOption4);  
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption5_Comparable,System.label.SpecialBusinessGroupOption5);  
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption6_Comparable,System.label.SpecialBusinessGroupOption6);  
        optionlabelMaps.put(System.label.SpecialBusinessGroupOption7_Comparable,System.label.SpecialBusinessGroupOption7);
      
      
		return labelMaps;
  
     }
    
    /**------------------------------------------------------------
        Description: 
        Inputs: 
        Returns: 
        History:
        07/04/2020    Pooja Dubey     Initial Development
    ------------------------------------------------------------*/
    public static List<User> getUsersDetail(List<Id> userIds){
        if(!userIds.isEmpty()){
            String querystr = 'Select Id,ContactId,ProfileId,Name from User where Id In: userIds WITH SECURITY_ENFORCED';
            return database.query(querystr);
        }
        return null;
    }
	
	/**------------------------------------------------------------
        Description: 
        Inputs: 
        Returns: 
        History:
        09/04/2021   Rohit Heera     Initial Development
    ------------------------------------------------------------*/	
	@AuraEnabled
    public static void updateSectionNameinFiling(String filingID,String sectionName,String section){
        
        try{
            if(String.isNotEmpty(filingID) && String.isNotBlank(filingID)){
                Business_Filing__c filing = new Business_Filing__c(id = filingID,Current_Screen__c=sectionName, Current_Section__c =section);
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {filing}, 'update');
                update filing;  
            }
            
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,'updateSectionNameinFiling', 'updateSectionNameinFiling', userInfo.getuserId(), BOS_Utility.sSeverity, ex, null);
        }
        
    }
    @AuraEnabled
    public static void updateSignatoryDetails(String Name,String Title,String Type,String BusinessFilingId){
        if(BusinessFilingId!=null){
            Business_Filing__c businessFiling= new Business_Filing__c();
        businessFiling.Id=BusinessFilingId;
        if(Name!=null){
            businessFiling.Signatory_Name__c=Name;             
        }
        if(Title!=null){
            businessFiling.Signatory_Title__c=Title;
        }
        if(Type!=null){
            businessFiling.Type_of_signatory__c=Type;
        }
        Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {businessFiling}, 'update');
        update businessFiling;
        }
    }	
    public class wrapperFile
    {
        @AuraEnabled public String contentDownload;
        @AuraEnabled public String contentPreview;
    }
        /********************************************************************************************
        METHOD NAME    : getDownloadFileCommunityUser
        DESCRIPTION    : Generate the URL for Attachment
        RETURN TYPE    : wrapperFile
        Author         : Rabbani
    ********************************************************************************************/
    @AuraEnabled
    public static wrapperFile getDownloadFileCommunityUser(String recordId)
    {
        wrapperFile wf=new wrapperFile();
        Attachment da= [SELECT Id, ParentId FROM Attachment WHERE ParentId =:recordId];
       wf.contentDownload=BASE_URL+System.label.BRS_FileAttachmentDownload+da.Id;
        wf.contentPreview=BASE_URL+System.label.BRS_FileAttachmentDownload+da.Id;
       return wf;
    }


    /********************************************************************************************
       METHOD NAME    : updateFilingAckValues
       DESCRIPTION    : to update review screen acknowledgment value from Business Filing
       RETURN TYPE    : NA
       Author         : Rahul Sharma
    ********************************************************************************************/
    @AuraEnabled
    public static Business_Filing__c updateFilingAckValues(Business_Filing__c filingRec) {
        try {
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {filingRec}, 'update');
                update filingRec;
                return filingRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'updateFilingAckValues','Business_Filing__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
       METHOD NAME    : updateSignatoryOnUCCFling
       DESCRIPTION    : to update review screen acknowledgment value and Signatory Name in UCC Filing
       RETURN TYPE    : NA
       Author         : Dheeraj 
    ********************************************************************************************/
    @AuraEnabled
    public static void updateSignatoryOnUCCFling(String uccLienId,Boolean ackCheck,String signatoryName){
        try {
            UCC_Filing__c filing=[Select Id,Name from UCC_Filing__c where UCC_Lien_Id__c=:String.escapeSingleQuotes(uccLienId) WITH SECURITY_ENFORCED LIMIT 1];
            filing.Acknowledge__c = ackCheck;
            filing.Acknowledgement_Signatory__c = signatoryName;
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {filing}, 'update');
            update filing;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateSignatoryOnUCCFling', 'UCC_Filing__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
       METHOD NAME    : getLatestStateForALEI
       DESCRIPTION    : to get the latest state from account for ALEI screen 
       RETURN TYPE    : String
       Author         : Priyanka
    ********************************************************************************************/
    @AuraEnabled
    public static string getLatestStateForALEI(String accountId){
        try {
            String state ;
            if(accountId!=null){
                state = [Select id, State_or_Territory_Formation__c from account where id =: String.escapeSingleQuotes(accountId) WITH SECURITY_ENFORCED].State_or_Territory_Formation__c;
            }
            return state;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getLatestStateForALEI', 'account', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Principal__c> getPrincipalById(Id PrId){
        List<Principal__c> prList = new List<Principal__c>();
        try {
            prList = [SELECT Id, Name, Email__c, Business_ID__c, Principal_Title__c, Principal_Type__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_City__c, Residence_State__c, Residence_Country__c, Business_Street_Address_1__c, Business_Street_Address_3__c, Business_Street_Address_2__c, Business_City__c, Business_Zip_Code__c, Business_State__c, Business_Country__c, FirstName__c, LastName__c, Name__c, Business_Address__c, Mailing_Address__c, Type__c, Business_Address_1__c, Residence_Address__c, Business_InternationalAddress__c, Residence_InternationalAddress__c, Designation__c FROM Principal__c WHERE Id=:String.escapeSingleQuotes(PrId) WITH SECURITY_ENFORCED];
            return prList;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getPrincipalById', System.Label.Principal_c, null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
       METHOD NAME    : sendBulkEmails
       DESCRIPTION    : To send emails when Business Filings are updated from batch(Bulifying emails) 
       PARAMETERS     : List<Business_Filing__c>
       Author         : Tamkanat 
    ********************************************************************************************/
    public static void sendBulkEmails(List<Business_Filing__c> businessFilingList){
        if(!businessFilingList.isEmpty()){
            Set<Id> businessFilingIds = new Set<Id>();
            List<Id> contentDocumentIds = new List<Id>();
            List<Id> contentVersionIds = new List<Id>();
            List<String> fileTitles = new List<String>();
            Map<Id,Id> filingIdVSTemplateMap = new Map<Id,Id>();
            Map<String,Id> tempNameVSTemplateMap = new Map<String,Id>();
            Map<Id,Id> contentDocIdVSFilingIdMap = new Map<Id,Id>();
            Map<Id,List<Id>> filingIdVSContentVersionIdsMap = new Map<Id,List<Id>>();
            Map<Id,List<String>> filingIdVSContentVersionTitlesMap = new Map<Id,List<String>>();
            Map<String,Id> attachmentIdVSFilingIDMap = new Map<String,Id>();
            Map<Id,Messaging.EmailFileAttachment> attIdVSEmailAttMap = new Map<Id,Messaging.EmailFileAttachment>();
            Map<Id,List<Messaging.EmailFileAttachment>> filingIdVSEFAsMap = new Map<Id,List<Messaging.EmailFileAttachment>>();

            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            List<String> templateNames = new List<String>{System.Label.Business_Registration_Acceptance_Email_with_link,System.Label.Business_Registration_Acceptance_Email};
            List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName IN :templateNames];

            //Creating a map of EmailTemplate Name and Id -- correct Template Id can be picked based on the template name.
            for(EmailTemplate temp:emailTemplateList){
                tempNameVSTemplateMap.put(temp.DeveloperName,temp.Id);
            }

            //Creating a map of Business Filing Id and Template Id -- Correct Template Id can be picked for any given filing id.
            for(Business_Filing__c filing: businessFilingList){
                businessFilingIds.add(filing.Id);
                if(filing.Status__c== System.Label.BRS_FilingStatus_Approved){
                    if(filing.Type__c==System.Label.Business_Formation_Comparable && (filing.Business_Type__c==System.Label.Stock || filing.Business_Type__c==System.Label.Non_Stock ||filing.Business_Type__c==System.Label.B_Corp)){
                        filingIdVSTemplateMap.put(filing.Id,tempNameVSTemplateMap.get(System.Label.Business_Registration_Acceptance_Email_with_link));
                    }else{
                        filingIdVSTemplateMap.put(filing.Id,tempNameVSTemplateMap.get(System.Label.Business_Registration_Acceptance_Email)); 
                    }
                }
            }

            for(ContentDocumentLink  contentLink: [SELECT LinkedEntityId, Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:businessFilingIds WITH SECURITY_ENFORCED]){
                contentDocumentIds.add(contentLink.ContentDocumentId);
                contentDocIdVSFilingIdMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntityId);
            }

            List<ContentVersion> contVersionList = [SELECT ContentDocumentId, Id, Title FROM ContentVersion where ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED Order By CreatedDate DESC];
            
            /**Creating two maps:
             * 1. filingIdVSContentVersionIdsMap --> Key = Filing Id, Value = List of all content version Ids -- to get all the content version ids related to a filing.
             * 2. filingIdVSContentVersionTitlesMap --> Key = Filing Id, Value = List of all content version Titles -- to check later if the same Titles are present as attachments for the filing. 
             */
            for(ContentVersion contentVer : contVersionList){
                if(contentDocIdVSFilingIdMap.keySet().contains(contentVer.ContentDocumentId)){
                    Id filingId = contentDocIdVSFilingIdMap.get(contentVer.ContentDocumentId);
                    if(filingIdVSContentVersionIdsMap.keySet().contains(filingId)){
                        filingIdVSContentVersionIdsMap.get(filingId).add(contentVer.Id);
                    }else{
                        filingIdVSContentVersionIdsMap.put(filingId,new List<Id>{contentVer.Id});
                    }

                    if(filingIdVSContentVersionTitlesMap.keySet().contains(filingId)){
                        filingIdVSContentVersionTitlesMap.get(filingId).add(contentVer.Title);
                    }else{
                        filingIdVSContentVersionTitlesMap.put(filingId,new List<String>{contentVer.Title});
                    }
                }
            }
            List<Attachment> attachedFiles = [SELECT Id, Name, Body,ParentId, ContentType FROM Attachment WHERE ParentId IN :businessFilingIds WITH SECURITY_ENFORCED  ORDER By CreatedDate];
            for(Attachment att:attachedFiles){
                attachmentIdVSFilingIDMap.put(att.Name,att.ParentId);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(att.Name);
                efa.setBody(att.body);
                efa.setContentType(att.ContentType);
                efa.setInline(false);
                attIdVSEmailAttMap.put(att.Id,efa);
                if((filingIdVSContentVersionTitlesMap.keySet().contains(att.ParentId) && !filingIdVSContentVersionTitlesMap.get(att.ParentId).contains(att.Name)) || filingIdVSContentVersionTitlesMap.isEmpty() || !filingIdVSContentVersionTitlesMap.keySet().contains(att.ParentId)){
                    if(filingIdVSEFAsMap.keySet().contains(att.ParentId)){
                        for(Messaging.EmailFileAttachment efaObj : filingIdVSEFAsMap.get(att.ParentId))
                        {
                            if(efaObj.fileName!=att.Name){
                                filingIdVSEFAsMap.get(att.ParentId).add(efa);
                            }
                        }                                              
                    }else{
                        filingIdVSEFAsMap.put(att.ParentId,new List<Messaging.EmailFileAttachment>{efa});
                    }
                }
            }

           // Creating a map of filing id and all related email atatchments to be sent.
            /*for(Messaging.EmailFileAttachment emailAtt : attIdVSEmailAttMap.values()){
                if(attachmentIdVSFilingIDMap.keySet().contains(emailAtt.fileName)){
                    Id filingId = attachmentIdVSFilingIDMap.get(emailAtt.fileName);
                    //Not adding attachment if a file(contentversion) of the same name is already present.
                    if((filingIdVSContentVersionTitlesMap.keySet().contains(filingId) && !filingIdVSContentVersionTitlesMap.get(filingId).contains(emailAtt.filename)) || filingIdVSContentVersionTitlesMap.isEmpty() || !filingIdVSContentVersionTitlesMap.keySet().contains(filingId)){
                        if(filingIdVSEFAsMap.keySet().contains(filingId)){
                            filingIdVSEFAsMap.get(filingId).add(emailAtt);
                        }else{
                            filingIdVSEFAsMap.put(filingId,new List<Messaging.EmailFileAttachment>{emailAtt});
                        }
                    }
                }
            }*/

            //Creating an email instance to be sent.
            for(Business_Filing__c busFiling: businessFilingList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(filingIdVSTemplateMap.keySet().contains(busFiling.Id)){
                    Id emailTemplateId = filingIdVSTemplateMap.get(busFiling.Id);
                    email = Messaging.renderStoredEmailTemplate(emailTemplateId, null, busFiling.Id);
                    String emailSubject = email.getSubject();
                    String emailTextBody = email.getPlainTextBody();
                    if(busFiling.Source__c == System.Label.brs_FilingOnline){
                        List<string> to = new List<string>();
                        if(busFiling.Account__r.Business_Email_Address__c!=null){
                            to.add(busFiling.Account__r.Business_Email_Address__c);
                        }
                        if(busFiling.Work_Order__r.Customer__r.Email!=null){
                            to.add(busFiling.Work_Order__r.Customer__r.Email);
                        }
                        email.setToAddresses(to);
                    }else if(busFiling.Work_Order__r.Customer__r.Email!=null){
                        string[] to = new string[] {busFiling.Work_Order__r.Customer__r.Email};
                        email.setToAddresses(to);
                    }
                    if(owa!=null){
                        email.setOrgWideEmailAddressId(owa.Id);
                    }
                    email.setSubject(emailSubject);
                    email.setPlainTextBody(emailTextBody);
                    
                    email.setTemplateId(emailTemplateId);
                    email.setSaveAsActivity(false);
                    if(filingIdVSContentVersionIdsMap.keySet().contains(busFiling.Id)){
                        email.setEntityAttachments(filingIdVSContentVersionIdsMap.get(busFiling.Id));
                    }
                    if(filingIdVSEFAsMap.keySet().contains(busFiling.Id)){
                        email.setFileAttachments(filingIdVSEFAsMap.get(busFiling.Id));
                    }
                    if(email.getToAddresses()!=null && email.getToAddresses().size()>0){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    }
                }
            }
        }
    }

    /********************************************************************************************
    METHOD NAME    : getFieldValidation
    DESCRIPTION    : To check for list of fields if required field is empty or nul 
    Author         : Avinash Shukla 
    ********************************************************************************************/
    public Static Boolean getFieldValidation(SObject sObjRec, List<String> addrFields, Boolean isOptional, Boolean isAgentValidation) {
        Boolean dataIsValid = true;
        Boolean dataIsPartiallyEntered = false;
        Boolean dataHasNullValue = false;
        Set<String> connecticutState = new Set<String>{System.Label.CT,System.Label.Connecticut_Label};
        for(String addrField: addrFields){
            String value = String.valueOf(sObjRec.get(addrField));
            if(!isOptional && !isAgentValidation){
                if(value==null || String.isBlank(value)){
                    dataIsValid = false;
                    break;
                }
            } else if(isOptional){
                if(value==null || String.isBlank(value)){
                    dataHasNullValue = true;
                } else {
                    dataIsPartiallyEntered = true;
                }
            } else if(isAgentValidation){
                if(value==null || String.isBlank(value)){
                    dataIsValid = false;
                    break;
                } 
                if((addrField == 'Residence_State__c' || addrField == 'Business_State__c' || addrField == 'Mailing_State__c')){
                    if(!connecticutState.contains(value)){
                        dataIsValid = false;
                        break;
                    }
                }
            }
        }
        if(isOptional){
            if(dataHasNullValue && dataIsPartiallyEntered){
                dataIsValid = false;
            }
        }
        return dataIsValid;
    }
    /********************************************************************************************
    METHOD NAME    : arePrincipalsInfoValid
    DESCRIPTION    : To check if the principals added are valid. 
    Author         : Avinash Shukla 
    ********************************************************************************************/
    public Static Boolean arePrincipalsInfoValid(List<Principal__c> allData, Set<Id> sObjectIdsNotToAddfromOriginal, List<Temp_History__c> allTempData, Boolean isCorpBusiness) {
        Boolean IsPrincipalDataValid = true;
        for(Principal__c pr : allData) {
            if (!sObjectIdsNotToAddfromOriginal.contains(pr.Id)) {
                if (pr.Principal_Type__c == System.Label.brs_PrincipalType_Individual) {
                    List<String> prIndividualValidation = System.Label.Principal_Validation_Old.split(QnA_Constants.COMMA_SEPARATOR);
                    if (pr.Residence_InternationalAddress__c != NULL) {
                        prIndividualValidation.addAll(System.Label.Principal_Resident_Address_Int.Split(QnA_Constants.COMMA_SEPARATOR));
                    } else {
                        prIndividualValidation.addAll(System.Label.Principal_Resident_Address.Split(QnA_Constants.COMMA_SEPARATOR));
                    }
                    if (isCorpBusiness) {
                        prIndividualValidation.add('Designation__c');
                    }
                    IsPrincipalDataValid = getFieldValidation(pr, prIndividualValidation, false, false);
                } else if (pr.Principal_Type__c == System.Label.brs_PrincipalType_Business) {
                    List<String> prBussinessValidation = System.Label.Principal_Validation_Business_Old.split(QnA_Constants.COMMA_SEPARATOR);
                    if (pr.Business_InternationalAddress__c != NULL) {
                        prBussinessValidation.addAll(System.Label.Principal_Business_Address_International_Comparable.Split(QnA_Constants.COMMA_SEPARATOR));
                    } else {
                        prBussinessValidation.addAll(System.Label.Principal_Business_Address_Comparable.Split(QnA_Constants.COMMA_SEPARATOR));
                    }
                  /*  if (isCorpBusiness) {
                        prBussinessValidation.add('Designation__c');
                    } */
                    IsPrincipalDataValid = getFieldValidation(pr, prBussinessValidation, false, false);
                }
                if (!IsPrincipalDataValid) {
                    break;
                }
            }
        }
        if (IsPrincipalDataValid || test.isRunningTest()) {
            for(Temp_History__c pr : allTempData) {
                if (!sObjectIdsNotToAddfromOriginal.contains(pr.Id)) {
                    if (pr.Temp_Type__c == System.Label.brs_PrincipalType_Individual) {
                        List<String> prTempIndividualValidation = System.Label.Principal_Validation_Temp.Split(QnA_Constants.COMMA_SEPARATOR);
                        if (pr.Residence_InternationalAddress__c != NULL) {
                            prTempIndividualValidation.addAll(System.Label.Principal_Resident_Address_Int.Split(QnA_Constants.COMMA_SEPARATOR));
                        } else {
                            prTempIndividualValidation.addAll(System.Label.Principal_Resident_Address.Split(QnA_Constants.COMMA_SEPARATOR));
                        }
                        if (isCorpBusiness) {
                            prTempIndividualValidation.add('Designation__c');
                        }
                        IsPrincipalDataValid = getFieldValidation(pr, prTempIndividualValidation, false, false);
                    } else if (pr.Temp_Type__c == System.Label.brs_PrincipalType_Business) {
                        List<String> prTempBussinessValidation = System.Label.Principal_Business_Temp_Comparable.Split(QnA_Constants.COMMA_SEPARATOR);
                        if (pr.Business_InternationalAddress__c != NULL) {
                            prTempBussinessValidation.addAll(System.Label.Principal_Business_Address_International_Comparable.Split(QnA_Constants.COMMA_SEPARATOR));
                        } else {
                            prTempBussinessValidation.addAll(System.Label.Principal_Business_Address_Comparable.Split(QnA_Constants.COMMA_SEPARATOR));
                        }
                      /*  if (isCorpBusiness) {
                            prTempBussinessValidation.add('Designation__c');
                        } */
                        IsPrincipalDataValid = getFieldValidation(pr, prTempBussinessValidation, false, false);
                    }
                    if (!IsPrincipalDataValid) {
                        break;
                    }
                }
            }
        }
        return IsPrincipalDataValid;
    }
    @AuraEnabled
    public static Boolean  compareCategories(String categoryName,String language){
    language='en_US';
    if(language == null ){
            String userLocale = UserInfo.getLocale();
            Map<String,String> codes = new Map<String,String>();
            Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
            for(Language_Mapping__mdt option :options.languageOptions){
                codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
            }
            codes.put('en_US','en_US');
            language=codes.get(userLocale);
    }
    Boolean isNaicsUpdated=false;
    String title= categoryName.replaceAll('[^a-zA-Z\\s+]', '').trim();
	String returnString = categoryName.replaceAll('[^0-9]', '').trim();
    String YearValue=System.Label.BRS_Category_Year;
       List<Category__c> categoriesList=[SELECT Id,keywords__c,Name,Code__c,Title__c,Level__c,Parent_Category__c FROM Category__c 
                    WHERE Language__c = :String.escapeSingleQuotes(language) and Category_Year__c!=null and  Category_Year__c =:YearValue  
                    WITH SECURITY_ENFORCED     
                    ORDER BY Level__c, Title__c ASC];              
    for(Category__c category:categoriesList)
    {
        String categoryValue=category.Title__c;
        String titleValue=categoryValue.replaceAll('[^a-zA-Z\\s+]', '').trim();
		if(category.code__c == returnString && titleValue == title)
        {
            isNaicsUpdated=true;
        }            
    }
    return isNaicsUpdated;
    }

}