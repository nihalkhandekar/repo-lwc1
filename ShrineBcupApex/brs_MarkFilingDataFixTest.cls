@isTest
public class brs_MarkFilingDataFixTest {
    @isTest static void testBatch(){
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        mark.Class_of_Goods_Service__c='Paints';
        update mark;
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        markfiling.Class_of_Goods_Service__c='Chemicals';
        markfiling.recordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Assignment').getRecordTypeId();
        update markfiling;
        Test.startTest();
        Database.executeBatch(new brs_MarkFilingDataFix(false));
        Test.stopTest();
    }
    @isTest static void testBatch1(){
       Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.Filing_Type__c='Registration';
        markfiling.Ist_Expiration_Date__c=System.today();
        markfiling.Class_of_Goods_Service__c='Paints';
        markfiling.Date_of_1st_Use_Anywhere__c=System.today();
        markfiling.Date_of_1st_Use_in_CT__c=System.today();
        markfiling.Disclaimer__c='Disclamied Data';
        markfiling.Expiration_Date__c=system.today();
        markfiling.Federal_Registration_Number_s__c='Date number';
        markfiling.Federal_Registration_of_Mark__c='Yes';
        markfiling.Keywords__c='keywords';
  		markfiling.Mark_Type__c='Certification Mark';
		markfiling.Mark_used_for__c='AlMark';
		markfiling.Method_of_use__c='Method used';
		markfiling.Number_of_Pages__c=23;
		markfiling.Other_Owner_Type__c='Owner Type';
		markfiling.Owner_City__c='Washington';
		markfiling.Owner_Country__c='United States';
		markfiling.Owner_Name__c='Jhon';
		markfiling.Owner_State__c='AK';
		markfiling.Owner_Street_Address__c='123 street';
		markfiling.Owner_Type__c='Corporation';
		markfiling.Owner_Unit__c='as123';
		markfiling.Owner_Zip_Code__c='12345';
		markfiling.Partner_Names__c='alex';
		markfiling.Registration_Date__c=System.today();
		markfiling.Renewal_Date__c=System.today();

		markfiling.State_Country_of_Formation__c='AK';
		markfiling.Status__c='Approved';
        markfiling.Class_of_Goods_Service__c='Chemicals';
        markfiling.recordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Assignment').getRecordTypeId();
     
        new brs_MarkFilingDataFix(false).execute(null,new List<Mark_Filing__c>{markfiling});
    }
}