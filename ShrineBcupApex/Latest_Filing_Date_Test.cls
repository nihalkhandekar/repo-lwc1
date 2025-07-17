@IsTest
public class Latest_Filing_Date_Test {
    testmethod static void test1(){
        Id RecordTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Lien__c ucclien = BRS_TestDataFactory.createUCCLien('OFC');
        UCC_Filing__c ucc = BRS_TestDataFactory.createUCCFiling('Not Applicable', 'Approved', ucclien.Id, 'OFC');
        ucc.Filing_Date__c=System.today();
        ucc.Filing_Source__c='Mail';
        ucc.RecordTypeId=RecordTypeId;
        update ucc;
        Id RecordTypeId1 = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('IRS').getRecordTypeId();
        UCC_Lien__c ucclien1 = BRS_TestDataFactory.createUCCLien('IRS');
        UCC_Filing__c ucc1 = BRS_TestDataFactory.createUCCFiling('Not Applicable', 'Approved', ucclien1.Id, 'IRS');
        ucc1.Filing_Date__c=System.today();
        ucc1.Filing_Source__c='Mail';
        ucc1.RecordTypeId=RecordTypeId1;
        update ucc1;
        RequestInformation_LatestFillingDate__c reqdate = new RequestInformation_LatestFillingDate__c(Name='XYZ');
        reqdate.New_Lien_Date__c=System.now();
        insert reqdate;
        SchedulableContext sc;
        Test.startTest();
        Latest_Filing_Date.execute(sc);
        Test.stopTest();
    }
}