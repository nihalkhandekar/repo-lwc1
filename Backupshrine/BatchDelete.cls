/*********************************************************************************************
* NAME:  BatchDelete
* DESCRIPTION: Generic Batch class to handle Delete/Update operations for various objects 
*
* @AUTHOR: Tamkanat
* @DATE: 20/05/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Tamkanat                    	 20/05/2020                        Created the first version
* Aparna S                       28/09/2021                        Updated to save success and 
error logs
***********************************************************************************************/

public with sharing class BatchDelete implements Database.Batchable<sObject> {
    public String query;
    public String operation;
    public String jobName;
    public List<Update_Job_Configuration__mdt> updateConfigurations;
    public static final String className='BatchDelete';
    public static final String methodName='execute';
    public static final String severity='Low';
    
    public BatchDelete(String queryParam,String operationParam,String jobNameParam,List<Update_Job_Configuration__mdt> updateConfigList) {
        query = queryParam;
        operation = operationParam;
        jobName = jobNameParam;
        updateConfigurations = updateConfigList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            Integer successCount=0;
            Integer errorCount=0;
            Integer successCountUpdate=0;
            Integer errorCountUpdate=0;
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            Database.DeleteResult[] drList = new List<Database.DeleteResult>();
            Database.SaveResult[] srList = new List<Database.SaveResult>();
            
            if(operation == System.Label.Batch_Delete ){
                if(!scope.isEmpty())
                {
                    drList = Database.delete(scope,false);
                    if(!drList.IsEmpty()){
                        for(Integer i=0; i < drList.size(); i++) {
                            if(drList.get(i).isSuccess()) {
                                successCount = successCount + 1;
                            }
                            else{
                                errorCount = errorCount + 1;
                            }
                        }
                    }
                    Batch_Job_Logs__c deleteInfo = new Batch_Job_Logs__c ();
                    deleteInfo.Class_Name__c = className;
                    deleteInfo.Job_Operation__c = operation;
                    deleteInfo.Job_Configuration_Name__c = jobName;
                    deleteInfo.Success_Record_Count__c = successCount;
                    deleteInfo.Error_Record_Count__c = errorCount;
                    deleteInfo.Object_Name__c = (scope.get(0).Id).getSObjectType().getDescribe().getName();
                    lstAppErrorLogs.add(deleteInfo);
                }
                DataBase.emptyRecycleBin(scope);
            }
            else if(operation == System.Label.Batch_Update){
                if(updateConfigurations.size()>0){
                    for(Update_Job_Configuration__mdt updateRec : updateConfigurations)
                    {
                        for(Sobject rec : scope){
                            if(updateRec.Data_Type__c =='Boolean')
                            {
                                Boolean FieldValue=Boolean.valueOf(updateRec.Field_Value__c);
                                rec.put(updateRec.Field_API_Name__c,FieldValue);
                            }
                            else
                            {
                                rec.put(updateRec.Field_API_Name__c,updateRec.Field_Value__c);                                    
                            }
                        }                        
                    }
                    
                    if(!scope.isEmpty())
                    {
                        // Adding database.update.to pass success records.
                        srList = Database.update(scope,false);
                        if(!srList.IsEmpty()){
                            for(Integer i=0; i < srList.size(); i++) {
                                if(srList.get(i).isSuccess()) {
                                    successCountUpdate = successCountUpdate + 1;
                                }
                                else{
                                    errorCountUpdate = errorCountUpdate + 1;
                                }
                            }
                        }
                        Batch_Job_Logs__c updateInfo = new Batch_Job_Logs__c ();
                        updateInfo.Class_Name__c = className;
                        updateInfo.Job_Operation__c = operation;
                        updateInfo.Job_Configuration_Name__c = jobName;
                        updateInfo.Success_Record_Count__c = successCountUpdate;
                        updateInfo.Error_Record_Count__c = errorCountUpdate;
                        updateInfo.Object_Name__c = (scope.get(0).Id).getSObjectType().getDescribe().getName();
                        lstAppErrorLogs.add(updateInfo);
                    }
                }
            }
            
            if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
                Database.SaveResult[] resultLst = new List<Database.SaveResult>();
                resultLst = Database.insert(lstAppErrorLogs,false);
            }
            
            BOS_Utility.ExceptionHandlerForBatches(className,null,'execute',srList,scope);
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,methodName,operation,null,severity,e,null);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}