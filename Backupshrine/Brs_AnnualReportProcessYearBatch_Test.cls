@isTest
public class Brs_AnnualReportProcessYearBatch_Test {
    
     testmethod static void test1(){
         Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Date_Registration__c=Date.today().addDays(-365);
         acc.Annual_Report_Due_Date__c=Date.today().addDays(-65);
         insert acc;
                  Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.Citizenship__c='Domestic';
        acc1.Business_Type__c='LLP';
        acc1.ClientAccountNum__c='12345';
        acc1.Purpose_of_Business__c = 'Test business run';
        acc1.Annual_Report_Processing_Year__c=2024;
        acc1.Status__c='Active';
        acc1.Date_Registration__c=Date.today().addDays(-365);
         acc1.Annual_Report_Due_Date__c=Date.today().addDays(-65);
         insert acc1;
                 
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
         Business_Filing__c businessFiling = new Business_Filing__c();
                businessFiling.Type__c = System.Label.Annual_Report_Label;
                businessFiling.Account__c = acc1.Id;
                businessFiling.recordTypeId = rt.Id;
         		businessFiling.Due_Date__c=System.today().addDays(100);
                businessFiling.Business_Type__c  = acc.Business_Type__c;
                businessFiling.Filing_Type__c = System.Label.Annual_Report_Label;
                businessFiling.Status__c = System.Label.Due;
                businessFiling.Citizenship__c = acc.Citizenship__c;
                businessFiling.Batch_Created__c = true;
         insert businessFiling;
         
            Test.startTest();

            Brs_AnnualReportProcessYearBatch obj = new Brs_AnnualReportProcessYearBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
         
     }

}