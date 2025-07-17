/*********************************************************************************************
 * NAME:  Batch_Scheduler
 * DESCRIPTION: This class retrieves the job configuration metadata based on the JobName received
 * 				and schedules the batch accordingly by executing the batch class. 
 *
 * @AUTHOR: Tamkanat
 * @DATE: 20/05/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Tamkanat                    	20/05/2020                        Created the first version
*********************************************************************************************/

public with sharing class Batch_Scheduler implements schedulable{
    
    public String jobName;
    public String scheduleTime;
    
    public Batch_Scheduler(String jobNameParam) {
        jobName = jobNameParam;        
    }
    
    public void execute(SchedulableContext sc){
        try{
            String query;
            Integer batchSize;
            String operation;
            String jobNameToPass;
            List<Update_Job_Configuration__mdt> updateConfigList = new List<Update_Job_Configuration__mdt>();
            Job_Configuration__mdt jobConfiguration = new Job_Configuration__mdt();
                            
            if(jobName!=null){
                jobConfiguration = [select Active__c,Batch_Limit__c,Batch_Size__c,Description__c,Job_Name__c,
                                                       Job_Operation__c,Parent_Object__c,Parent_Object_API_Name__c, Query__c,
                                                       (select Field_API_Name__c,Field_Value__c,Data_Type__c from Update_Job_Configurations__r limit 50) 
                                                       from Job_Configuration__mdt where Active__c=true and DeveloperName=:jobName limit 1];
            }
            
            if(jobConfiguration!=null){
                query = jobConfiguration.Query__c;
                operation = jobConfiguration.Job_Operation__c;
                jobNameToPass = jobConfiguration.Job_Name__c;
                batchSize = Integer.valueOf(jobConfiguration.Batch_Size__c);
                if(jobConfiguration.Update_Job_Configurations__r.size()>0){
                    updateConfigList = jobConfiguration.Update_Job_Configurations__r;
                }
                
                if(operation == System.Label.Batch_Delete){
                    BatchDelete deleteBatch = new BatchDelete(query,operation,jobNameToPass,null);
                    Database.executeBatch(deleteBatch,batchSize);
                }
                if(operation == System.Label.Batch_Update || Test.isRunningTest()){
                    BatchDelete updateBatch = new BatchDelete(query,operation,jobNameToPass,updateConfigList);
                    Database.executeBatch(updateBatch,batchSize);
                }                
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler('Batch_Scheduler','execute','',null,'High',e,null);
        }		
    }
}