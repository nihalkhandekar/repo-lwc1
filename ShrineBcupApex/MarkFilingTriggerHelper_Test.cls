@isTest
public class MarkFilingTriggerHelper_Test {
    @TestSetup
    static void testSetup() {
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();//Annual Report / First Report
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Mark__c mark =new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        
        ID storeRecordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        
        List<Mark_Filing__c> listMarkfiling=new List<Mark_Filing__c>();
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
        markfiling.RecordTypeId=storeRecordTypeId;
        markfiling.Owner_Zip_Code__c='12345';
        markfiling.Partner_Names__c='alex';
        markfiling.Registration_Date__c=System.today();
        markfiling.Renewal_Date__c=System.today();
        markfiling.Work_Order__c=workOrder.Id;
        markfiling.State_Country_of_Formation__c='AK';
        markfiling.Status__c='Approved';
        markfiling.Mark__c=Mark.id;
        insert markfiling;
        
        ID storeRecordTypeId1 = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Owner Updates').getRecordTypeId();
        
        markfiling=new Mark_Filing__c();
        markfiling.Filing_Type__c='State of Formation Change';
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
        markfiling.RecordTypeId=storeRecordTypeId1;
        markfiling.Partner_Names__c='alex';
        markfiling.Registration_Date__c=System.today();
        markfiling.Renewal_Date__c=System.today();
        markfiling.Work_Order__c=workOrder.Id;
        markfiling.State_Country_of_Formation__c='AK';
        markfiling.Status__c='Approved';
        markfiling.Mark__c=Mark.id;
        insert markfiling;
        markfiling=new Mark_Filing__c();
        markfiling.Filing_Type__c='Owner Name Change';
        markfiling.Ist_Expiration_Date__c=System.today();
        markfiling.Class_of_Goods_Service__c='Paints';
        markfiling.RecordTypeId=storeRecordTypeId1;
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
        markfiling.Work_Order__c=workOrder.Id;
        markfiling.State_Country_of_Formation__c='AK';
        markfiling.Status__c='Approved';
        markfiling.Mark__c=Mark.id;
        insert markfiling;
        //listMarkfiling=BRS_TestDataFactory.createListMarkFiling(mark.id,workorder.id);
    }
    testmethod public static void processMaintenanceFilings() {
        List<Mark_Filing__c> filing = [Select id,Mark__r.Renewal_Date__c,Mark__r.Expiration_Date__c,Filing_Type__c,Federal_Registration_Number_s__c,Mark_Type__c,Class_of_Goods_Service__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,
                                       Owner_Name__c,Owner_Type__c,State_Country_of_Formation__c , Owner_Street_Address__c,Owner_Country__c,Owner_State__c,Mark__c,
                                       Owner_City__c,Owner_Zip_Code__c,Work_Order__c,Registration_Date__c,Date_of_1st_Use_in_CT__c,Date_of_1st_Use_Anywhere__c,Federal_Registration_of_Mark__c,Number_of_Pages__c From
                                       Mark_Filing__c];
        Map<Id,Mark_Filing__c> oldMap = new Map<Id, Mark_Filing__c>();
        oldMap.put(filing[0].id,filing[0]);
        Master_Fee__c masterFee =new Master_Fee__c();
        try{
            masterFee=BRS_TestDataFactory.createListMasterFee();
        }catch(Exception ex){
            System.debug('error'+ex);
        }
        test.startTest();
        try{
            MarkFilingTriggerHelper.updateFilingFee(filing,oldMap);
        }catch(Exception ex){
            System.debug('error'+ex);
        }
        test.stopTest();
    }
}