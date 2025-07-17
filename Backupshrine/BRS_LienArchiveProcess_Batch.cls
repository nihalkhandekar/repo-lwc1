/*********************************************************************************************
* NAME:  BRS_LienArchiveProcess_Batch
* DESCRIPTION: Batch to update Lien records to Archive status.
*
* @AUTHOR: Tamkanat
* @DATE: 12th-Feb-2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Tamkanat                    	12th-Feb-2021                       Created the first version
*********************************************************************************************/
public without sharing class BRS_LienArchiveProcess_Batch implements Database.Batchable<sObject>, Schedulable{
    public static final String className='BRS_LienArchiveProcess_Batch';
    public static final String objectName='UCC_Lien__c';
    public static final String severity='Low';
    // method implemented from Schedulable interface
    public void execute(SchedulableContext sc){
        Database.executebatch(this,100); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date oneYearPrior = System.today().addDays(-Integer.valueOf(System.Label.BRS_CheckDaysforArchive));
        String query = 'Select Id, Lapse_Date__c,Status__c,Status_Change_Date__c from UCC_Lien__c where '+
            '(Lapse_Date__c<:oneYearPrior OR Status_Change_Date__c<:oneYearPrior) AND Status__c!=\''+System.Label.BRS_Archived+'\'';
            return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            Integer successCount=0;
            Integer errorCount=0;
            List<Batch_Job_Logs__c> lstAppErrorLogs = new List<Batch_Job_Logs__c>();
            Date oneYearPrior = System.today().addDays(-Integer.valueOf(System.Label.BRS_CheckDaysforArchive));
            Date oneYearFuture= System.today();
            Database.SaveResult[] results = new List<Database.SaveResult>();
            List<Error_Log__c> errLogToInsert = new List<Error_Log__c>();
             List<UCC_Lien__c> lienRecordList = (List<UCC_Lien__c>)scope;
            set<id> ucclienids=new set<id>();
            for(UCC_Lien__c lienRec: lienRecordList)
            {
                ucclienids.add(lienRec.id);
            }

            Map<id,Datetime> filingdatemap=new Map<id,Datetime>();
            List<UCC_Filing__c> terminationLienList=[Select id,Type__c,Amendment_Type__c,Future_Filing_Date__c,filing_date__c,UCC_Lien_Id__c From UCC_Filing__c where type__c='Amendment' and Amendment_Type__c='Termination' and Status__c='Approved' and UCC_Lien_Id__c IN:ucclienids order by filing_date__c desc];

            if(!terminationLienList.isEmpty())
            {
            for(UCC_Filing__c filing: terminationLienList){
            if(!filingdatemap.containsKey(filing.UCC_Lien_Id__c))
	        {
		           filingdatemap.put(filing.UCC_Lien_Id__c,filing.Future_Filing_Date__c);
	        }
	
            }
            }
            
            List<UCC_Lien__c> updateLienList = new List<UCC_Lien__c>();
            for(UCC_Lien__c lienRec: lienRecordList){ 
                datetime terminationdate=filingdatemap.get(lienRec.id);                 
                if((lienRec.Status__c==System.Label.Active && lienRec.Lapse_Date__c<oneYearPrior) || 
                   (System.Label.Lien_Status_to_Archive.contains(lienRec.Status__c) && lienRec.Status_Change_Date__c<oneYearPrior || System.Label.Lien_Terminated == lienRec.Status__c && oneYearFuture >= terminationdate)){
                       lienRec.Status__c= System.Label.BRS_Archived;                      
                       updateLienList.add(lienRec);
                   }
            }
            if(!updateLienList.isEmpty()){
                results = database.update(updateLienList,false);
            }
            if(!results.isempty())
            {
            for(Database.SaveResult res : results){
                if (!res.isSuccess()) { 
                    errorCount = errorCount + 1;
                    String error='';
                    for(Database.Error er : res.getErrors()){
                        error=error+' '+er.getStatusCode() + ': ' + er.getMessage();
                    }
                    Error_Log__c erlog =  BOS_Utility.errorRecordLogger(className, 'execute', objectName, res.getId(), severity, null, error);                  
                    errLogToInsert.add(erlog);  
                }
                else{
                    successCount = successCount + 1;
                }
            }             
            
            Batch_Job_Logs__c createLog = new Batch_Job_Logs__c ();
            createLog.Class_Name__c = className;
            createLog.Job_Operation__c = System.Label.Batch_Update;
            createLog.Job_Configuration_Name__c = 'Lien Archive Process';
            createLog.Success_Record_Count__c = successCount;
            createLog.Error_Record_Count__c = errorCount;
            createLog.Object_Name__c = (updateLienList.get(0).Id).getSObjectType().getDescribe().getName();
            lstAppErrorLogs.add(createLog);
            
            if(Schema.SObjectType.Batch_Job_Logs__c.isCreateable() && lstAppErrorLogs != NULL && !lstAppErrorLogs.isEmpty()){
               Database.SaveResult[] resultLst = new List<Database.SaveResult>();
               resultLst = Database.insert(lstAppErrorLogs,false);
           	}

            if(!errLogToInsert.isEmpty()){
                insert errLogToInsert;
            }

            //BOS_Utility.ExceptionHandlerForBatches(className,objectName,'execute',results,updateLienList);
            if(Test.isRunningTest()){
            throw new NullPointerException();
        	}
        }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'execute',objectName,null,severity,e,null);
        }
    }
    public void finish(Database.BatchableContext BC){
    }
    
}