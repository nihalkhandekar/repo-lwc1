/*********************************************************************************************
 * NAME:  BOS_Utility
 * DESCRIPTION: This class contains all the hardcoded values
 *
 * @AUTHOR: Balaji Kotte
 * @DATE: 06/05/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Balaji Kotte                     06/05/2020                   Created the first version
 * Piyush Jogdand                   13/05/2020                   Added generic method for deletion
 * Piyush Jogdand                   15/05/2020                   Added exception handler framework for LWC
*********************************************************************************************/
public without sharing class BOS_Utility {
    public static final String className='BOS_Utility';
    public static final String fetchInterfaceConfigMethod='fetchInterfaceConfig';
    public static final String getApplicationIdMethod='getApplicationId';
    public static final String getIDProofingDetail='getIDProofingDetail';
    public static final String getUserLocale='getUserLocale';
    public static final String getJobConfigMetadataMethod='getJobConfigMetadata';
    public static final String scheduleJobMethod='scheduleJob';
    public static Final String createAccountMethod='createAccount';
	public static Final String accountObject='Account';
    public static final String interfaceMetadata='Interface_Configuration__mdt';
    public static final String questionnaireObject='Questionnaire__c';
    public static final String jobConfigMetadata ='Job_Configuration__mdt';
    public static final String sSeverity = 'Medium';


    public static void handleException(Exception e) {
        String errorMsg = e.getStackTraceString().substringAfter('\n');
        ExceptionHandler(getClassName(errorMsg), getMethod(errorMsg), null, null, 'High', e, null);
    }

    private static String getClassName(String line) {
        if (line.startsWith('Class.'))
            line = line.substringAfter('Class.');
        return line.substringBefore(':').substringBeforeLast('.');
    }

    private static String getMethod(String line) {
        return line.substringBefore(':').substringAfterLast('.');
    }

    public static Map<String, Object> ExceptionHandler(String sClass,String sClassMethod, String objectName, String recId, String sSeverity, Exception e, String sAddlErrorInfo)    {
        Map<String, Object> mapErrorInfo = new Map<String, Object>{};
        mapErrorInfo.put(System.Label.Class_Name, sClass);
        mapErrorInfo.put(System.Label.Class_Method, sClassMethod);
        mapErrorInfo.put(System.Label.Object_Name, objectName);
        mapErrorInfo.put(System.Label.Record, recId);
        mapErrorInfo.put(System.Label.Severity, sSeverity);
        mapErrorInfo.put(System.Label.User_Info, UserInfo.getUserId());
        mapErrorInfo.put(System.Label.Language, UserInfo.getLanguage());
        mapErrorInfo.put(System.Label.Additional_Information, sAddlErrorInfo);
        if(e != Null){        //added
        mapErrorInfo.put(System.Label.Error_Message, e.getTypeName() + ' >>> ' + e.getMessage());
        mapErrorInfo.put(System.Label.Stack_Trace, e.getStackTraceString());
        //mapErrorInfo.put(System.Label.Additional_Information, sAddlErrorInfo);
        mapErrorInfo.put(System.Label.Error_Cause, e.getCause());
        List<String> aDMLFieldNames = new List<String>();
        List<String> aDMLRecordIds = new List<String>();
        List<String> aDMLMessages = new List<String>();
        if(e.getTypeName() == 'System.DmlException')    {
            for(Integer i=0; i<e.getNumDml(); i++)  {
                aDMLFieldNames.add(JSON.serialize(e.getDmlFieldNames(i)));
                aDMLRecordIds.add(e.getDmlId(i));
                aDMLMessages.add(e.getDmlMessage(i));
            }
        }
        mapErrorInfo.put(System.Label.DML_Field_Names, aDMLFieldNames);
        mapErrorInfo.put(System.Label.DML_Record_Ids, aDMLRecordIds);
        mapErrorInfo.put(System.Label.DML_Messages, aDMLMessages);
        }
        String sErrorInfoUpd = JSON.serialize(mapErrorInfo);
        if(!(System.isFuture() || System.isBatch() || System.isScheduled()))
        {
            insertErrorRecord(sErrorInfoUpd);
        }
        else
        {
            insertErrorRecord2(sErrorInfoUpd);
        }        
        return mapErrorInfo;
    }

    public static Map<String, Object> ExceptionHandlerAsync(String sClass,String sClassMethod, String objectName, String recId, String sSeverity, Exception e, String sAddlErrorInfo)    {    //added
        Map<String, Object> mapErrorInfo = new Map<String, Object>{};
        mapErrorInfo.put(System.Label.Class_Name, sClass);
        mapErrorInfo.put(System.Label.Class_Method, sClassMethod);
        mapErrorInfo.put(System.Label.Object_Name, objectName);
        mapErrorInfo.put(System.Label.Record, recId);
        mapErrorInfo.put(System.Label.Severity, sSeverity);
        mapErrorInfo.put(System.Label.User_Info, UserInfo.getUserId());
        mapErrorInfo.put(System.Label.Language, UserInfo.getLanguage());
        mapErrorInfo.put(System.Label.Additional_Information, sAddlErrorInfo);
        if(e != Null){
        mapErrorInfo.put(System.Label.Error_Message, e.getTypeName() + ' >>> ' + e.getMessage());
        mapErrorInfo.put(System.Label.Stack_Trace, e.getStackTraceString());
        //mapErrorInfo.put(System.Label.Additional_Information, sAddlErrorInfo);
        mapErrorInfo.put(System.Label.Error_Cause, e.getCause());
        List<String> aDMLFieldNames = new List<String>();
        List<String> aDMLRecordIds = new List<String>();
        List<String> aDMLMessages = new List<String>();
        if(e.getTypeName() == 'System.DmlException')    {
            for(Integer i=0; i<e.getNumDml(); i++)  {
                aDMLFieldNames.add(JSON.serialize(e.getDmlFieldNames(i)));
                aDMLRecordIds.add(e.getDmlId(i));
                aDMLMessages.add(e.getDmlMessage(i));
            }
        }
        mapErrorInfo.put(System.Label.DML_Field_Names, aDMLFieldNames);
        mapErrorInfo.put(System.Label.DML_Record_Ids, aDMLRecordIds);
        mapErrorInfo.put(System.Label.DML_Messages, aDMLMessages);
        }
        String sErrorInfoUpd = JSON.serialize(mapErrorInfo);
        insertErrorRecord2(sErrorInfoUpd);     
        return mapErrorInfo;
    }

    @AuraEnabled
    public static void ExceptionHandlerLWC(String compName, String methodName, String objectName, String recId, String sSeverity, String error){
		try{
			Map<String, Object> mapErrorInfo = new Map<String, Object>{};
			mapErrorInfo.put(System.Label.Component_Name, compName);
			mapErrorInfo.put(System.Label.Component_method, methodName);
			mapErrorInfo.put(System.Label.Object_Name, objectName);
			mapErrorInfo.put(System.Label.Record, recId);
			mapErrorInfo.put(System.Label.Severity, sSeverity);
			mapErrorInfo.put(System.Label.Error_Message, error);
			String sErrorInfoUpd = JSON.serialize(mapErrorInfo);
			if(!(System.isFuture() || System.isBatch() || System.isScheduled()))
            {
                insertErrorRecord(sErrorInfoUpd);
            }
            else
            {
                insertErrorRecord2(sErrorInfoUpd);
            }
		}catch(Exception e){
            Throw new AuraHandledException(e.getMessage());
        }
    }

    @future    
    public static void insertErrorRecord(String sErrorInfo){
        Map<String, Object> mapErrorDetails = (Map<String, Object>) JSON.deserializeUntyped(sErrorInfo);
        List<Error_Log__c> lstAppErrorLogs = new List<Error_Log__c>();
        lstAppErrorLogs.add(getErrorLogDetails(mapErrorDetails));
        
        if(Schema.SObjectType.Error_Log__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
            insert lstAppErrorLogs;
        }
    }
  
  public static void insertErrorRecord2(String sErrorInfo){
        Map<String, Object> mapErrorDetails = (Map<String, Object>) JSON.deserializeUntyped(sErrorInfo);
        List<Error_Log__c> lstAppErrorLogs = new List<Error_Log__c>();
        lstAppErrorLogs.add(getErrorLogDetails(mapErrorDetails));
        
        if(Schema.SObjectType.Error_Log__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
            insert lstAppErrorLogs;
        }
    }
    public static void ExceptionHandlerForBatches(String sClass,String objectName, String sSeverity, Database.SaveResult[] ErrorList, List<SObject> sObjLst) {
       List< Map<String, Object>> allmapErrorInfo = new List< Map<String, Object>>();
        if(!ErrorList.IsEmpty()){
            for(Integer i=0; i < ErrorList.size(); i++) {
                if(!ErrorList.get(i).isSuccess()) {
                    Database.Error errors =  ErrorList.get(i).getErrors().get(0);
                    Map<String, Object> mapErrorInfo = new Map<String, Object>{};
                    mapErrorInfo.put(System.Label.Class_Name, sClass);
                    mapErrorInfo.put(System.Label.Object_Name, objectName);
                    mapErrorInfo.put(System.Label.Severity, 'Medium');
                    mapErrorInfo.put(System.Label.User_Info, UserInfo.getUserId());
                    mapErrorInfo.put(System.Label.Language, UserInfo.getLanguage());
                    mapErrorInfo.put(System.Label.Error_Message,errors.getMessage());
                    mapErrorInfo.put(System.Label.DML_Field_Names, errors.getFields());
                    mapErrorInfo.put(System.Label.Additional_Information, String.valueOf(errors.getStatusCode()));
                    if(sObjLst != NULL){
                        mapErrorInfo.put('Record_Id__c', String.valueOf(sObjLst.get(i).Id));
                    }
                    allmapErrorInfo.add(mapErrorInfo);
                }
            }
        }
        
        if(allmapErrorInfo != NULL && !allmapErrorInfo.isEmpty()){
          insertErrorRecordForBatches(allmapErrorInfo);
        } 
    }
        public static void insertErrorRecordForBatches(List< Map<String, Object>> mapErrorDetails){
               List<Error_Log__c> lstAppErrorLogs = new List<Error_Log__c>();
               for(Integer i=0;I<mapErrorDetails.size(); i++)
               {
                   lstAppErrorLogs.add(getErrorLogDetails(mapErrorDetails[i]));
           }
                if(Schema.SObjectType.Error_Log__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
                   insert lstAppErrorLogs;
               }
    }
    /********************************************************************************************
    METHOD NAME    : getErrorLogDetails
    DESCRIPTION    : Method to format the exception
    RETURN TYPE    : Map<String, Object>
    PARAMETER      : Exception
    AUTHOR         : Balaji Kotte
    ********************************************************************************************/
    public static Error_Log__c getErrorLogDetails( Map<String, Object> mapErrorDetails ) {
        String sBrowser = ''; 
        String sDevice = '';
        String sClassMethod = '' ;
        String sClassName = '';
        String sCmpName = '';
        String sCmpMethod = '';
        String sErrorMessage = '';
        String sStackTrace = '' ; 
        String sLanguage = '' ;  
        String sStatus = '' ; 
        String sRecordType = '';
        String sObjName = '';
        String sRecId = '';
        String componentName='';
        String componentMethod='';
        
        Error_Log__c oAppErrorLog = new Error_Log__c ();
        
        //Setting value for Application Type
        oAppErrorLog.Application_Type__c = System.Label.Application_Type;
        
        /* class information */ 
        if(isMapValString(mapErrorDetails, System.Label.Class_Name))    {
            sClassName = (String)mapErrorDetails.get(System.Label.Class_Name);
            oAppErrorLog.Class_Name__c = sClassName;
            oAppErrorLog.Source_of_error__c = System.Label.Server;
        }
        if(isMapValString(mapErrorDetails, System.Label.Class_Method))    {
            sClassMethod = (String)mapErrorDetails.get (System.Label.Class_Method) ;
            oAppErrorLog.Class_Method__c= sClassMethod;
        }
        
        /* Object and Record information */ 
        if(isMapValString(mapErrorDetails, System.Label.Object_Name))    {
            sObjName = (String)mapErrorDetails.get(System.Label.Object_Name);
            oAppErrorLog.Object_Name__c = sObjName;
        }
        if(isMapValString(mapErrorDetails, System.Label.Record))    {
            sRecId = (String)mapErrorDetails.get (System.Label.Record) ;
            oAppErrorLog.Record_Id__c= sRecId;
        }
        
        /* generic error information */
        if(isMapValString(mapErrorDetails, System.Label.Error_Message))    {
            sErrorMessage = ( String)mapErrorDetails.get(System.Label.Error_Message ) ;
            oAppErrorLog.Error_Message__c= trimFieldValue(sErrorMessage, 1000);
        } 
        if(isMapValString(mapErrorDetails, System.Label.Severity))    {
            oAppErrorLog.Severity__c = (String)mapErrorDetails.get (System.Label.Severity);
        } 
        if(isMapValString(mapErrorDetails, System.Label.Stack_Trace))    {
            sStackTrace = (String)mapErrorDetails.get(System.Label.Stack_Trace);
            oAppErrorLog.Stack_Trace__c= trimFieldValue(sStackTrace, 32768);
        }
        if(isMapValString(mapErrorDetails, System.Label.Component_Name))    {
           componentName = (String)mapErrorDetails.get(System.Label.Component_Name);
            oAppErrorLog.Component_Name__c = componentName;
            oAppErrorLog.Source_of_error__c = System.Label.Client;
        }
        if(isMapValString(mapErrorDetails, System.Label.Component_method))    {
           componentMethod = (String)mapErrorDetails.get(System.Label.Component_method);
            oAppErrorLog.Component_Method__c = componentMethod;
        }
        
        /* error cause information */
        String sErrorCause = '' ; 
        if(mapErrorDetails.containsKey(System.Label.DML_Messages))    {     
            List<String> lstDMLMessages = new List<String>();   
            for(Object obj: (List<Object>) mapErrorDetails.get(System.Label.DML_Messages))  {
                lstDMLMessages.add(String.valueOf(obj));
            }
            List<String> lstDMLRecordIds = new List<String>();
            if(mapErrorDetails.containsKey(System.Label.DML_Record_Ids))    {
                for(Object obj: (List<Object>) mapErrorDetails.get(System.Label.DML_Record_Ids))   {
                    lstDMLRecordIds.add(String.valueOf(obj));
                }
            }
            List<String> lstDMLFieldNames  = new List<String>();
            if(mapErrorDetails.containsKey(System.Label.DML_Field_Names))    {
                for(Object obj: (List<Object>) mapErrorDetails.get(System.Label.DML_Field_Names)) {
                    lstDMLFieldNames.add(String.valueOf(obj));
                }
            }
            if(!lstDMLMessages.IsEmpty()) {
                Integer iErrorMsgSize = lstDMLMessages.Size() ; 
                if (iErrorMsgSize > 0) {
                    for(Integer i=0; i < iErrorMsgSize; i++) {
                        sErrorCause += (i < lstDMLRecordIds.size() ? (String.isNotBlank(lstDMLRecordIds[i]) ? 'DML Record Id: ' + lstDMLRecordIds[i] : ''): '');
                        sErrorCause += String.isNotBlank(sErrorCause) ? ' >> ' : '';
                        sErrorCause += String.isNotBlank(lstDMLMessages[i]) ? 'DML Message: ' + lstDMLMessages[i] : '';
                        sErrorCause += String.isNotBlank(sErrorCause) ? ' >> ' : '';
                        sErrorCause += (i < lstDMLFieldNames.size() ? (String.isNotBlank(lstDMLFieldNames[i]) ? 'DML Field Names: ' + lstDMLFieldNames[i] : ''): '');
                        sErrorCause += String.isNotBlank(sErrorCause) ? ' |' : '';
                    } 
                } 
            }
        }
        if (!String.IsBlank(sErrorCause)) {
            sErrorCause = sErrorCause.substringBeforeLast ( '|') ; 
        }
        if(isMapValString(mapErrorDetails, System.Label.Additional_Information))    {
            sErrorCause = (String)mapErrorDetails.get(System.Label.Additional_Information) + ' ;; ' + sErrorCause;
        }
        if (!String.IsBlank(sErrorCause)) {
           oAppErrorLog.Additional_Error_Information__c = trimFieldValue(sErrorCause, 32768); 
        }
        
        /* user information */
        if(isMapValString(mapErrorDetails, System.Label.User_Info))    {
            oAppErrorLog.User_Info__c = (String)mapErrorDetails.get(System.Label.User_Info) ;
        }
        if(isMapValString(mapErrorDetails, 'Record_Id__c'))    {
            oAppErrorLog.Record_Id__c = (String)mapErrorDetails.get('Record_Id__c') ;
        }
                   
        return oAppErrorLog ;
    }
    
    public static Boolean isMapValString(Map<String, Object> mapObject, String key)    {
        return mapObject.containsKey(key) && String.isNotBlank((String)mapObject.get(key));
    }

    public static String trimFieldValue(String sFieldValue, Integer iLengthLimit)    {
        return (sFieldValue.length() > iLengthLimit) ? sFieldValue.substring(0, iLengthLimit) : sFieldValue;
    }
    
         /********************************************************************************************
    METHOD NAME    : fetchInterfaceConfig
    DESCRIPTION    : This method fetch the custom metadata 'Interface configuration' which contains
                     the URL to be redirected on clicking 'Create an Account' on getstarted link.
    RETURN TYPE    : Interface_Configuration__mdt
    PARAMETER      : String labelName (Label of Custom Metadatda record)
    ********************************************************************************************/
    @AuraEnabled
    public static Interface_Configuration__mdt fetchInterfaceConfig(String labelName){
        Interface_Configuration__mdt interfaceConfig;
        try{
            if(Schema.SObjectType.Interface_Configuration__mdt.isAccessible() 
                && String.isNotBlank(labelName)) {
                interfaceConfig = [
                    SELECT Current_Environment__c,DeveloperName,Id,End_URL__c,ForgeRock_End_URL__c,ForgeRock_Profile_End_URL__c,
                        Is_Active__c,Label,Language,MasterLabel,NamespacePrefix,Parameters__c,API_Key__c,Named_Credential__c,
                        QualifiedApiName,Timeout_Value__c,Call_Type__c 
                    FROM Interface_Configuration__mdt
                    WHERE MasterLabel =:labelName 
                        AND Current_Environment__c =: System.Label.CURRENT_ENVIRONMENT
                ];
            }
            return interfaceConfig;
        }catch(Exception e){
            ExceptionHandler(className,fetchInterfaceConfigMethod,interfaceMetadata,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
        
     /********************************************************************************************
    METHOD NAME    : checkUserLoggedIn
    DESCRIPTION    : The method fetch the current user information.If the user go to the community
                     page from Salesforce, it is marked as logged in. If the user hits the URL
                     outside browser, it is marked as logged out.
    RETURN TYPE    : Boolean
    PARAMETER      : No parameters
    ********************************************************************************************/
    @AuraEnabled
    public static Boolean checkUserLoggedIn(){
        return UserInfo.getUserType() != 'Guest';
    }
    
    @AuraEnabled
    public static Questionnaire__c getApplicationId(String language){
        try{
            Map<String,String> codes = new Map<String,String>();

            Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
            for(Language_Mapping__mdt option :options.languageOptions){
                codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
                codes.put('en_US','en_US');
            }
            User currentUser = getLoggedinUserDetail();
            
            Questionnaire__c newQuestionnaireRec = new Questionnaire__c(
                Status__c= System.Label.Questionnaire_Status
            );
            if(currentUser!=null && currentUser.ContactId!=null){
                newQuestionnaireRec.Contact__c = currentUser.ContactId;
            }
            if(language != Null){
                newQuestionnaireRec.Language__c = codes.get(language);
            }else{
                newQuestionnaireRec.Language__c = codes.get(UserInfo.getLocale());
            }

            if(Schema.SObjectType.Questionnaire__c.isCreateable() && newQuestionnaireRec.Status__c != null){
                insert newQuestionnaireRec;
            }
            return newQuestionnaireRec;
        }catch(Exception e){
            ExceptionHandler(className,getApplicationIdMethod,questionnaireObject,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    @AuraEnabled
    public static Boolean matchUserLocale(String questionnaireId,String status){
        try{
            Boolean localeMatched = true;

            if(Schema.SObjectType.Questionnaire__c.isAccessible()) {
                List<Questionnaire__c> questionnaires = [
                    SELECT Id,Language__c 
                    FROM Questionnaire__c 
                    WHERE Id =: questionnaireId
                ];
                
                if(!questionnaires.isEmpty() && questionnaires[0].Language__c != Null){
                    localeMatched = questionnaires[0].Language__c == UserInfo.getLocale();
                    
                    if(!localeMatched && status == system.label.In_Progress_Status){
                        delete questionnaires;
                    }
                }    
            }

            return localeMatched;
        }catch(Exception e){
            ExceptionHandler(className,'matchUserLocale',null,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    } 

    @AuraEnabled
    public static String deleteRecords(List<SObject> objects){
        try{
            if(!objects.isEmpty())
            Database.delete(objects);
            return System.Label.SUCCESS_MESSAGE;
        }
        catch(Exception e){
            ExceptionHandler(className,getApplicationIdMethod,questionnaireObject,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static List<Job_Configuration__mdt> getJobConfigMetadata(){
        try{
            List<Job_Configuration__mdt> jobConfigurationList = new List<Job_Configuration__mdt>();
            if(Schema.SObjectType.Job_Configuration__mdt.isAccessible()){
                jobConfigurationList = [
                    SELECT Id,Active__c,Batch_Limit__c,Batch_Size__c,Description__c,Job_Operation__c,Parent_Object__c,
                        Parent_Object_API_Name__c,DeveloperName,MasterLabel, Query__c 
                    FROM Job_Configuration__mdt 
                    WHERE Active__c = true
                ];
            }

            return jobConfigurationList;
        }catch(Exception e){
            ExceptionHandler(className,getJobConfigMetadataMethod,jobConfigMetadata,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static void scheduleJob(String jobConfigId, String frequency, String weekdays, String timeValue){
        Job_Configuration__mdt jobConfig = new Job_Configuration__mdt();
        String CRONEXP;
        String jobName;
        Time scheduleTime = (Time) JSON.deserialize(timeValue, Time.class);
        if(Schema.SObjectType.Job_Configuration__mdt.isAccessible() && jobConfigId!=null){
            jobConfig = [select Id,DeveloperName from Job_Configuration__mdt where Id=:jobConfigId limit 1];
            if(jobConfig!=null){
                jobName = jobConfig.DeveloperName;
            }
        }
        if(frequency == 'Weekly'){
            CRONEXP = scheduleTime.second()+' '+scheduleTime.minute()+' '+scheduleTime.hour()+' ? * '+weekdays;
        }else{
            CRONEXP = scheduleTime.second()+' '+scheduleTime.minute()+' '+scheduleTime.hour()+' ? * *';
        }
        
        try{
            String jobId = System.schedule(jobName,CRONEXP, new Batch_Scheduler(jobName));
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }catch(Exception e){
            ExceptionHandler(className,scheduleJobMethod,null,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
   
    public static Integer getAvailableQueryLimit() {
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }
    
    public without sharing class ExtensionMalformedCallException extends Exception {}

    //Used in FE
    @AuraEnabled
    public static String getUserLocale(){
        return UserInfo.getLocale();
    }

    @AuraEnabled
    public static Contact getIDProofingDetail() {
        try{
            if(Schema.SObjectType.Contact.isAccessible()) {
                List<Contact> contactList = [
                    SELECT id, No_of_times_called_Id_proofing__c,ID_Proof_status__c,ID_Proof_Source__c 
                    FROM contact 
                    WHERE id = :getLoggedinUserDetail().contactId
                ];

                if(!contactList.isEmpty()) {
                    return contactList.get(0);
                }
            }

            return null;
        } catch(Exception e){
            ExceptionHandler(className,getIDProofingDetail,questionnaireObject,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
            
        }        
    }
    
    @AuraEnabled
    public static void updateIdProofingCounter(String id,Integer counter){
        try{
            
           Contact contactdata = new Contact();
            contactdata.ID = id;
            contactdata.No_of_times_called_Id_proofing__c = counter+1;
            if(contactdata != Null)
                update contactdata;
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }catch(Exception e){
            ExceptionHandler(className,getIDProofingDetail,questionnaireObject,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
        public static Map<String, Object> responseTraceHandler(String sClass,String sClassMethod, String objectName, String statusCode, String sSeverity, String response, String requestString,String url)    {
        Map<String, Object> mapErrorInfo = new Map<String, Object>{};
        mapErrorInfo.put(System.Label.Class_Name, sClass);
        mapErrorInfo.put(System.Label.Class_Method, sClassMethod);
        mapErrorInfo.put(System.Label.Object_Name, objectName);
        mapErrorInfo.put('Error_Message__c', url);
        mapErrorInfo.put(System.Label.Severity, sSeverity);
        mapErrorInfo.put(System.Label.User_Info, UserInfo.getUserId());
        mapErrorInfo.put(System.Label.Language, UserInfo.getLanguage());
       
        mapErrorInfo.put(System.Label.Stack_Trace,'response : '+response);
        mapErrorInfo.put(System.Label.Additional_Information,'reuqest : ' +requestString);
        mapErrorInfo.put(System.Label.Error_Cause, statusCode);
        mapErrorInfo.put('Source_of_error__c','API');
        List<String> aDMLFieldNames = new List<String>();
        List<String> aDMLRecordIds = new List<String>();
        List<String> aDMLMessages = new List<String>();
      /*  if(e.getTypeName() == 'System.DmlException')    {
            for(Integer i=0; i<e.getNumDml(); i++)  {
                aDMLFieldNames.add(JSON.serialize(e.getDmlFieldNames(i)));
                aDMLRecordIds.add(e.getDmlId(i));
                aDMLMessages.add(e.getDmlMessage(i));
            }
        }
        mapErrorInfo.put(System.Label.DML_Field_Names, aDMLFieldNames);
        mapErrorInfo.put(System.Label.DML_Record_Ids, aDMLRecordIds);
        mapErrorInfo.put(System.Label.DML_Messages, aDMLMessages);*/
        String sErrorInfoUpd = JSON.serialize(mapErrorInfo);
        if(!(System.isFuture() || System.isBatch() || System.isScheduled()))
        {
            insertErrorRecord(sErrorInfoUpd);
        }
        else
        {
            insertErrorRecord2(sErrorInfoUpd);
        }         
        return mapErrorInfo;
    }
	
	@AuraEnabled
    public static User getLoggedinUserDetail() {
	return [
				SELECT Id, FederationIdentifier,FirstName, LastName, MiddleName, ContactID, Received_date__c 
				FROM User 
				WHERE Id =: UserInfo.getUserId() 
			];
    }
	
	@AuraEnabled
	public static String getLoggedinUserType(){
        return UserInfo.getUserType();
    }

@AuraEnabled
    public static List<Id> createAccount(){
        List<Id> returnList = new List<Id>();
        try{
        String currentUserName = UserInfo.getName();
        Account newAccount = new Account();
        newAccount.Name=currentUserName;
        if(newAccount.Name!=null){
            insert newAccount;
            returnList.add(newAccount.Id);
        }

        /** Creating and returing questionnaire record till the flowcontainer code shifts to account.*/
        Questionnaire__c newQuestionnaireRec = new Questionnaire__c();
            newQuestionnaireRec.Status__c= System.Label.Questionnaire_Status;
            if(Schema.SObjectType.Questionnaire__c.isCreateable() && newQuestionnaireRec.Status__c != null){
                insert newQuestionnaireRec;
                returnList.add(newQuestionnaireRec.Id);
            }
        return returnList;
        }catch(Exception e){
            ExceptionHandler(className,createAccountMethod,accountObject,null,sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Error_Log__c errorRecordLogger(String sClass,String sClassMethod, String objectName, String recId, String sSeverity, Exception e, String sAddlErrorInfo){
        Error_Log__c err = new Error_Log__c();
        err.Class_Name__c  = sClass;
        err.Class_Method__c = sClassMethod;
        err.Object_Name__c = objectName;
        err.Record_Id__c = recId;
        err.Severity__c = sSeverity;
        err.Error_Message__c = e != NULL ? e.getTypeName() + ' >>> ' + e.getMessage() : '';
        err.Additional_Error_Information__c = sAddlErrorInfo;
        return err;
    }

    public static void insertErrorRecordLst(List<Error_Log__c> errLst)
    {
        try
        {
            if (!errLst.IsEmpty() && Schema.SObjectType.Error_Log__c.isAccessible() && Schema.SObjectType.Error_Log__c.isCreateable()) 
                insert errLst;
        }
        catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'BusinessMaintenance', 'Business_Filing__c', null, BOS_Utility.sSeverity, e, null);
        }
    }

}