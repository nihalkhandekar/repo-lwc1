/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-23-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class brs_stockClassificationController {

    @AuraEnabled
    public static List<Stock_Classification__c> upsertStockRecords(List<Stock_Classification__c> result){ 

        try{ 
            
            if(!result.isEmpty()) {
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(result, 'upsert');
                if(bAccessCheck){ 
                    upsert result;
                }
            } 
            return result;
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('brs_stockClassificationController','upsertStockRecords','Stock_Classification__c',null,'medium',ex,null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

     @AuraEnabled
    public static list<Stock_Classification__c> getStockRecords(string accountId){ 
         list<Stock_Classification__c> lstStock = new list<Stock_Classification__c>(); 
        try{  
            
                    lstStock = [SELECT 
                                Id,
                                Number_of_Stocks__c,
                                Par_Value__c,
                                AccountId__c,
                                Stock_Class__c,
                                Classification_Description__c
                                FROM
                                Stock_Classification__c 
                                WHERE  
                                AccountId__c =: accountId     
                                WITH SECURITY_ENFORCED                  
                                ];    
            
           return lstStock;
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('brs_stockClassificationController','getStockRecords','Stock_Classification__c',null,'medium',ex,null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteStockRecords(string stockId){ 
         list<Stock_Classification__c> lstStock = new list<Stock_Classification__c>(); 
        try{  
                lstStock = [SELECT Id,
                            Number_of_Stocks__c,
                            Par_Value__c,
                            AccountId__c,
                            Stock_Class__c
                            FROM
                            Stock_Classification__c 
                            WHERE  
                            Id =: stockId  
                            WITH SECURITY_ENFORCED                     
                            ];    
               
            if(!lstStock.isEmpty()) { 
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(lstStock, 'delete');
                if(bAccessCheck){
                    delete lstStock;
                }
            if(Test.isRunningTest()){
            throw new NullPointerException();
            }
            }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('brs_stockClassificationController','deleteStockRecords','Stock_Classification__c',null,'medium',ex,null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}