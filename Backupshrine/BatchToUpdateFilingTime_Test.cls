/*********************************************************************************************
* NAME:  BatchToUpdateFilingTime_Test
* DESCRIPTION: Test class for BatchToUpdateFilingTime
*          
*
* @AUTHOR: Mousumi Patro
* @DATE: 01/10/2022
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
Mousumi Patro         01/10/2022                             Created
*********************************************************************************************/
@isTest
public class BatchToUpdateFilingTime_Test {
    @testSetup
    private static void setup(){
        
      
    }
    
    @isTest
    public static void testmethod1() {
        
          Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        insert acc;
        
        
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Amendment_Type__c ='Amend Name'; 
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        insert filing;
        List<Business_Filing__c> data = new List<Business_Filing__c>();
data.add(filing);
        Test.startTest();
      
        
          Database.QueryLocator QL;
        Database.BatchableContext BC;
        BatchToUpdateFilingTime batchInstance = new BatchToUpdateFilingTime();
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, data);
        batchInstance.finish(BC); 
        
        
        
        Test.stopTest();
    }  
    
    
    
    
    
}