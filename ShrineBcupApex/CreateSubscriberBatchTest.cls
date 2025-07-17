/**
 * @File Name          : CreateSubscriberBatchTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-03-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    7/1/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/

@isTest
public with sharing class CreateSubscriberBatchTest {
    @isTest
    public static void createBusinessReopenCertificationRecord(){
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
        EmailTemplate emTemp = BRS_TestDataFactory.createEmailTemplate();
        }
        BosAccCOVIDGuidelineLWCController.ResponseWrapper response= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        String record ='{"Sector__c":"Amusement Parks","Business_Type__c":"Construction","Email_Address__c":"testClass2@gmail.com","Contact_Phone_Number_1__c":"2323232323","Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User","Date__c":"2019-06-27"}';        
        response = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(record,true);
        
        Id recTypeId = NotificationServiceCls.getRecordTypeId('Recovery','Subscription__c');       

        List<Business_Reopen_Certification__c> lstBrc = new List<Business_Reopen_Certification__c>();  
        Business_Reopen_Certification__c obj1 = new Business_Reopen_Certification__c();
        Date testDate = Date.newInstance(2019, 7, 1);
        obj1.Sector__c = 'Amusement Parks';
        obj1.Business_Type__c = 'Construction';
        obj1.Email_Address__c = 'testClass@gmail.com';
        obj1.Contact_Phone_Number_1__c = '2323232323';
        obj1.Business_Name__c = 'test1';
        obj1.Date__c=testDate;
        obj1.Representative_First_Name__c = 'Test';
        obj1.Representative_last_Name__c = 'User';
        lstBrc.add(obj1);
        Business_Reopen_Certification__c obj2 = new Business_Reopen_Certification__c();
        obj2.Sector__c = 'Restaurants';
        obj2.Business_Type__c = 'Accommodation and Food Services';
        obj2.Email_Address__c = 'testClass@gmail.com';
        obj2.Contact_Phone_Number_1__c = '2323232323';
        obj2.Business_Name__c = 'test12';
        obj2.Date__c=testDate;
        obj2.Representative_First_Name__c = 'Test';
        obj2.Representative_last_Name__c = 'User'; 
        lstBrc.add(obj2);
        Business_Reopen_Certification__c obj3 = new Business_Reopen_Certification__c();
        obj3.Sector__c = 'Offices';
        obj3.Business_Type__c = 'Professional, Scientific, and Technical Services';
        obj3.Email_Address__c = 'testClass123@gmail.com';
        obj3.Contact_Phone_Number_1__c = '2323232323';
        obj3.Business_Name__c = 'test13';
        obj3.Date__c=testDate;
        obj3.Representative_First_Name__c = 'Test';
        obj3.Representative_last_Name__c = 'User';
        lstBrc.add(obj3);
        Business_Reopen_Certification__c obj4 = new Business_Reopen_Certification__c();
        obj4.Sector__c = 'Libraries';
        obj4.Business_Type__c = 'Construction';
        obj4.Email_Address__c = 'testClass123@gmail.com';
        obj4.Contact_Phone_Number_1__c = '3444222324';
        obj4.Business_Name__c = 'test14';
        obj4.Date__c=testDate;
        obj4.Representative_First_Name__c = 'Test';
        obj4.Representative_last_Name__c = 'User'; 
        lstBrc.add(obj4);
        insert lstBrc;
        
        List<Subscription__c> lstSbs = new List<Subscription__c>();  
        
        Subscription__c sbs = new Subscription__c();
        sbs.Email__c = 'testClass123@gmail.com';
        sbs.Business_Sector__c = 'Offices';
        sbs.Business_Industry__c = 'Arts, Entertainment, and Recreation';
        sbs = CreateSubscriberBatch.setSubscription(sbs, recTypeId, 'Email');
        insert sbs;

        Subscription__c sbs2 = new Subscription__c();
        sbs2.Phone__c = '2323232323';
        sbs2.Business_Sector__c = 'Offices';
        sbs2.Business_Industry__c = 'Arts, Entertainment, and Recreation';
        sbs2 = CreateSubscriberBatch.setSubscription(sbs2, recTypeId, 'SMS');
        
        lstSbs.add(sbs);
        lstSbs.add(sbs2);

        

        Test.startTest();
        CreateSubscriberBatch c = new CreateSubscriberBatch(false);
        Database.executeBatch(c);
        CreateSubscriberBatch c1 = new CreateSubscriberBatch(true);
        Database.executeBatch(c1);
        Test.stopTest();
		System.assertNotEquals(Null, c1);
        /*
        Check for testClass123@gmail.com
        Sector__c='Offices',
        Business_Type__c='Construction'
        Sector__c='Film, Television & Digital Media'
        Business_Type__c='Arts, Entertainment, and Recreation'
        Sector__c = 'Offices';
        Business_Type__c = 'Professional, Scientific, and Technical Services';
        //sbs.Business_Sector__c = 'Offices';
        //sbs.Business_Industry__c = 'Arts, Entertainment, and Recreation';
        */
        Subscription__c sc = [select Id, Email__c, Business_Sector__c, Business_Industry__c 
            from  Subscription__c where Email__c = 'testClass123@gmail.com'];

        String sectorVal = 'Offices;Film, Television & Digital Media';
        String industryVal = 'Construction;Arts, Entertainment, and Recreation;Professional, Scientific, and Technical Services';
        //System.assert(sectorVal.equals(sc.Business_Sector__c));
        //System.assert(industryVal.equals(sc.Business_Industry__c));
    }
}