/*********************************************************************************************
* NAME:  BatchToUpdateFilingTime 
* DESCRIPTION: Batch class to update Filing time for existing Business Filing Records
*
* @AUTHOR: Mousumi Patro
* @DATE: 01/10/2022
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* _____________________________________________________________________________________________
* Mousumi Patro                     01/10/2022                       Created the first version
*
*************************************************************************************************/

global class BatchToUpdateFilingTime implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return database.getQueryLocator('Select id from Business_Filing__c');
    }
    
    global void execute(Database.BatchableContext BC,List<Business_Filing__c> bfilList){
        
        if(!bfilList.isEmpty()){
            
          update bfilList;  
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}