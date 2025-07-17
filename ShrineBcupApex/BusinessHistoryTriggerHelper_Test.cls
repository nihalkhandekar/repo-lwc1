@isTest
public with sharing class BusinessHistoryTriggerHelper_Test {
    testMethod static void testGetBusinessDetailsMergers(){
        ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();
           
        Account acc = new Account();
        acc.Name = 'Test,LTD.';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
         acc.Business_Type__c = System.Label.Stock;
        acc.Citizenship__c = 'Domestic';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.RecordTypeId = storeRecordTypeId;
        acc.Total_Authorized_Shares__c = 100;
        insert acc;
       
        Account acc1 = new Account();
        acc1.Name = 'Test,LTD.111';
        acc1.citizenship__c = 'Domestic';
        acc1.Business_Type__c = System.Label.Stock;
        acc1.Business_Registration_ID__c = '1234';
        acc1.AccountNumber = '1234';
        acc1.BillingStreet = 'Market St';
        acc1.BillingCity = 'San Francisco';
        acc1.BillingState = 'CA';
         acc1.RecordTypeId = storeRecordTypeId;
        acc1.BillingPostalCode = '9400';
        acc1.BillingCountry = 'US';
        acc1.Total_Authorized_Shares__c = 100;
        insert acc1;
         Account acc2 = new Account();
        acc2.Name = 'Test,LTD.111';
        acc2.citizenship__c = 'Domestic';
        acc2.Business_Type__c = 'LLC';
        acc2.Business_Registration_ID__c = '1234';
        acc2.AccountNumber = '1234';
        acc2.BillingStreet = 'Market St';
        acc2.BillingCity = 'San Francisco';
        acc2.BillingState = 'CA';
         acc2.RecordTypeId = storeRecordTypeId;
        acc2.BillingPostalCode = '9400';
        acc2.BillingCountry = 'US';
                acc2.ShippingStreet = 'Market St';
        acc2.ShippingCity = 'San Francisco';
        acc2.ShippingState = 'CA';
        acc2.ShippingPostalCode = '9400';
        acc2.ShippingCountry = 'US';
        acc2.Total_Authorized_Shares__c = 100;
        insert acc2;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.Status__c = 'Approved';
        businessFiling.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling.Work_Order__c = workorder.Id;
        businessFiling.Total_Authorized_Shares__c = 10;
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Type__c = 'Conversion';
        insert businessFiling;
        
        Business_Filing__c businessFiling1 = new Business_Filing__c();
        businessFiling1.Account__c = acc1.Id;
        businessFiling1.Status__c = 'Approved';
        businessFiling1.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling1.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling1.Work_Order__c = workorder.Id;
        businessFiling1.Total_Authorized_Shares__c = 10;
        businessFiling1.Citizenship__c = 'Domestic';
        businessFiling1.Type__c = 'Merger';
        insert businessFiling1;
                
        List<Business_Filing__c> filingList = new List<Business_Filing__c>();
        filingList.add(businessFiling);
        filingList.add(businessFiling1);
        
        Name_Change_History__c hisInst = new Name_Change_History__c();
        hisInst.Account__c = acc.Id;
        hisInst.Business_Filing__c = businessFiling.Id;
        hisInst.Business_Name_New__c = 'abc';
        hisInst.Business_Name_Old__c = 'xyz';
        hisInst.Name_Change_Date__c = system.today();
        insert hisInst; 
        
        Business_History__c obh = new Business_History__c();
       // obh.Name = 'Test';
        obh.Surviving_Business__c = acc.id;
        obh.Business_Filing__c = businessFiling.id;
        obh.Merging_Business__c = acc.id;
        insert obh;
        
        Business_History__c obh1 = new Business_History__c();
       // obh1.Name = 'Test';
        obh1.Surviving_Business__c = acc.id;
        obh1.Business_Filing__c = businessFiling1.id;
        obh1.Merging_Business__c = acc1.id;
        insert obh1;
        
          Business_Filing__c businessFiling2 = new Business_Filing__c();
      
        businessFiling2.Status__c = 'Approved';
        businessFiling2.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling2.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling2.Work_Order__c = workorder.Id;
        businessFiling2.Total_Authorized_Shares__c = 10;
        businessFiling2.Citizenship__c = 'Domestic';
        businessFiling2.Type__c = 'Merger';
        insert businessFiling2;
        Business_History__c obh2 = new Business_History__c();
       // obh1.Name = 'Test';
        obh2.Surviving_Business__c = acc2.id;
        obh2.Business_Filing__c = businessFiling2.id;
        obh2.Merging_Business__c = acc1.id;
        insert obh2;
        
                Business_Filing__c businessFiling3 = new Business_Filing__c();
        businessFiling3.Account__c = acc2.Id;
        businessFiling3.Status__c = 'Approved';
        businessFiling3.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling3.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling3.Work_Order__c = workorder.Id;
        businessFiling3.Total_Authorized_Shares__c = 10;
        businessFiling3.Citizenship__c = 'Domestic';
        businessFiling3.Type__c = 'Merger';
        insert businessFiling3;
            Business_History__c obh3 = new Business_History__c();
       // obh1.Name = 'Test';
        obh3.Surviving_Business__c = acc2.id;
        obh3.Business_Filing__c = businessFiling.id;
        obh3.Merging_Business__c = acc2.id;
        insert obh3;
        Test.startTest();
        obh3.status__C = 'Merged';
        update obh3;
        List<sObject> oldRecordsList = new List<sObject>();
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        //delete obh3;
        oldRecordsList.add(obh3);
        oldItems.put(obh3.id,obh3);
        BusinessHistoryTriggerHandler kk = new BusinessHistoryTriggerHandler();
        kk.beforeDelete(oldRecordsList,oldItems);
        kk.afterDelete(oldItems);
        kk.afterUndelete(oldRecordsList,oldItems);
        Test.stopTest();  
    }
    
      /********************************************************************************************
        METHOD NAME    : coverNullMethods
        DESCRIPTION    : to cover trigger contexts
    ********************************************************************************************/
    @isTest
    static void coverNullMethods(){
        BusinessHistoryTriggerHandler objHandler = new BusinessHistoryTriggerHandler();
        objHandler.beforeInsert(null);
        objHandler.beforeUpdate(null,null);
        objHandler.afterUpdate(null,null);
        objHandler.afterDelete(null);
        objHandler.afterUndelete(null,null);
    }
    
     testMethod static void testGetBusinessDetailsMergers2(){
        ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();
           
        Account acc = new Account();
        acc.Name = 'Test,LTD.';
        acc.Business_Registration_ID__c = '1234';
        acc.AccountNumber = '1234';
        acc.BillingStreet = 'Market St';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
         acc.Business_Type__c = System.Label.Stock;
        acc.Citizenship__c = 'Domestic';
        acc.BillingPostalCode = '9400';
        acc.BillingCountry = 'US';
        acc.RecordTypeId = storeRecordTypeId;
        acc.Total_Authorized_Shares__c = 100;
        insert acc;
       
        Account acc1 = new Account();
        acc1.Name = 'Test,LTD.111';
        acc1.citizenship__c = System.Label.Domestic;
        acc1.Business_Type__c = System.Label.Stock;
        acc1.Business_Registration_ID__c = '1234';
        acc1.AccountNumber = '1234';
        // acc1.Sub_Status__c = ;
        acc1.BillingStreet = 'Market St';
        acc1.BillingCity = 'San Francisco';
        acc1.BillingState = 'CA';
        acc1.RecordTypeId = storeRecordTypeId;
        acc1.BillingPostalCode = '9400';
        acc1.BillingCountry = 'US';
        acc1.Total_Authorized_Shares__c = 100;
        insert acc1;
         
       
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling.Account__c = acc.Id;
        businessFiling.Status__c = 'Approved';
        businessFiling.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling.Work_Order__c = workorder.Id;
        businessFiling.Total_Authorized_Shares__c = 10;
        businessFiling.Citizenship__c = 'Domestic';
        businessFiling.Type__c = System.Label.Merger_Label;
        businessFiling.Type_of_Merger__c = System.Label.Merge_into_New_Domestic_Business;
        insert businessFiling;
        
       
              
        Name_Change_History__c hisInst = new Name_Change_History__c();
        hisInst.Account__c = acc.Id;
        hisInst.Business_Filing__c = businessFiling.Id;
        hisInst.Business_Name_New__c = 'abc';
        hisInst.Business_Name_Old__c = 'xyz';
        hisInst.Name_Change_Date__c = system.today();
        insert hisInst; 
        
        Business_History__c obh = new Business_History__c();
        obh.Surviving_Business__c = acc.id;
        obh.Business_Filing__c = businessFiling.id;
        obh.Merging_Business__c = acc.id;
        insert obh;

        List<sObject> oldRecordsList = new List<sObject>();
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        //delete obh3;
       /* oldRecordsList.add(obh3);
        oldItems.put(obh3.id,obh3);
        BusinessHistoryTriggerHandler kk = new BusinessHistoryTriggerHandler();
        kk.beforeDelete(oldRecordsList,oldItems);
        kk.afterDelete(oldItems);
        kk.afterUndelete(oldRecordsList,oldItems);*/
       // Test.stopTest();  
    }
    
      testMethod static void testGetBusinessDetailsMergers3(){       
	   ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();

 
 Account acc2 = new Account();
        acc2.Name = 'Test,LTD.111';
        acc2.citizenship__c = System.Label.Domestic;
       // acc2.Business_Type__c = 'Cemetery';
        acc2.Business_Registration_ID__c = '1234';
        acc2.AccountNumber = '1234';
        acc2.Business_Type__c = System.Label.Business_Type_LLC;
        acc2.BillingStreet = 'Market St';
        acc2.BillingCity = 'San Francisco';
        acc2.BillingState = 'CA';
        acc2.RecordTypeId = storeRecordTypeId;
        acc2.BillingPostalCode = '9400';
        acc2.BillingCountry = 'US';
        acc2.Total_Authorized_Shares__c = 100;
         acc2.Mailing_International_Address__c ='Add' ;
        insert acc2;
		
		        Contact con = BRS_TestDataFactory.createContactObject(acc2.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
		
		  Business_Filing__c businessFiling1 = new Business_Filing__c();
        businessFiling1.Account__c = acc2.Id;
        businessFiling1.Status__c = 'Approved';
        businessFiling1.RecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
        businessFiling1.Filing_Date__c = System.Today().addDays(-30); 
        businessFiling1.Work_Order__c = workorder.Id;
        businessFiling1.Total_Authorized_Shares__c = 10;
        businessFiling1.Citizenship__c = 'Domestic';
        businessFiling1.Type__c = System.Label.Conversion_Label;
        //businessFiling1.Type_of_Merger__c = '';
        insert businessFiling1;
		
		 Business_History__c obh2 = new Business_History__c();
        obh2.Surviving_Business__c = acc2.id;
        obh2.Business_Filing__c = businessFiling1.id;
        obh2.Merging_Business__c = acc2.id;
        insert obh2;
		
		}
    
    
}