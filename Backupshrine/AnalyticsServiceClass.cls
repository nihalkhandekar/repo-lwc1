/*********************************************************************************************
 * NAME:  AnalyticsService
 * DESCRIPTION: This class inserts records into the 'Analytics Events' object.
*********************************************************************************************/

public without sharing class AnalyticsServiceClass {
	public static Final String className='AnalyticsServiceClass';
    public static final String objectName ='Analytics_Event__c';
    public static final String insertAnalyticsRecordMethod='insertAnalyticsRecord';
    
    @AuraEnabled
    public static void insertAnalyticsRecord(String responses) { 
        try{
            JSONParser parser = JSON.createParser(responses);
            Analytics_Event__c captureEvent = (Analytics_Event__c)parser.readValueAs(Analytics_Event__c.class);
			if(captureEvent != null){  //added null check 
				insert captureEvent;
			}
           	
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,insertAnalyticsRecordMethod,objectName,null,null,e,null);
            throw new AuraHandledException(e.getMessage());
        }    
    }
}