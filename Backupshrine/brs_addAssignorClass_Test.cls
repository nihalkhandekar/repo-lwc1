@isTest
public class brs_addAssignorClass_Test {
    @testSetup 
    static void setup() {
     OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
     List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        for(Integer i=0;i<2;i++) {
            testFiling.add(new UCC_Filing__c(Type__c = 'Amendments'));
        }
        insert testFiling; 
     
     List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        
     UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
     objRelatedInfo.City__c = 'City';   
     objRelatedInfo.Country__c = 'country';
     
     objRelatedInfo.isAuthorizer__c = true;
     //Added as Part of BRS-2491
     objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
    
     objRelatedInfo.Org_Name__c = 'Orgname';
     objRelatedInfo.Type__c = 'Secured Party';
     objRelatedInfo.State__c = 'State';
     objRelatedInfo.Street__c = 'Street';
     objRelatedInfo.Zip_Code__c = '11111';
    
     objRelatedInfo.Suffix__c = 'Suffix';   
     objRelatedInfo.Filing_Id__c = testFiling[0].id;
     lstRelatedInfo.add(objRelatedInfo);
        
    UCC_Related_Info__c objRelatedInfoInd = new UCC_Related_Info__c();  
     objRelatedInfoInd.City__c = 'City';   
     objRelatedInfoInd.Country__c = 'country';
     objRelatedInfoInd.Individual_First_Name__c = 'FirstName';
     objRelatedInfoInd.isAuthorizer__c = true;
     //Added as Part of BRS-2491
     objRelatedInfoInd.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.label.Individual).getRecordTypeId();
     
     objRelatedInfoInd.Type__c = 'Secured Party';
     objRelatedInfoInd.Individual_SurName__c = 'Ind Surname'; 
     objRelatedInfoInd.Street__c = 'Street';
	 objRelatedInfoInd.State__c = 'State';
     objRelatedInfoInd.Zip_Code__c = '11111';
     objRelatedInfoInd.Individual_Middle_Name__c = 'Middlename';
     objRelatedInfoInd.Suffix__c = 'Suffix';   
     objRelatedInfoInd.Filing_Id__c = testFiling[0].id;
     lstRelatedInfo.add(objRelatedInfoInd);
        
     UCC_Related_Info__c objRelatedInfo2 = new UCC_Related_Info__c();  
     objRelatedInfo2.City__c = 'City';   
     objRelatedInfo2.Country__c = 'country';
     
     objRelatedInfo2.isAuthorizer__c = true;
     //Added as Part of BRS-2491
     objRelatedInfo2.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
    
     objRelatedInfo2.Org_Name__c = 'Orgname';
     objRelatedInfo2.Type__c = 'Secured Party';
	 objRelatedInfo2.State__c = 'State';
     objRelatedInfo2.Street__c = 'Street';
     objRelatedInfo2.Zip_Code__c = '11111';
     
     objRelatedInfo2.Suffix__c = 'Suffix';   
     objRelatedInfo2.Filing_Id__c = testFiling[0].id;
     lstRelatedInfo.add(objRelatedInfo2);
     insert lstRelatedInfo;
     
     List<UCC_Entity_Info__c> lstUccEntityInfo = new List<UCC_Entity_Info__c>();

     UCC_Entity_Info__c objEntityInfo = new UCC_Entity_Info__c();
     objEntityInfo.Assignor_ID__c = objRelatedInfo.id;
     objEntityInfo.Filing_ID__c = testFiling[0].id;
     objEntityInfo.Secured_Party_ID__c = objRelatedInfo.id;
     lstUccEntityInfo.add(objEntityInfo);   
     
     UCC_Entity_Info__c objEntityInfo2 = new UCC_Entity_Info__c();
     objEntityInfo2.Assignor_ID__c = objRelatedInfo2.id;
     objEntityInfo2.Filing_ID__c = testFiling[0].id ;
     objEntityInfo2.Secured_Party_ID__c = objRelatedInfo.id ;
     lstUccEntityInfo.add(objEntityInfo2);
        
     insert lstUccEntityInfo;  
        
    }
    
    @isTest
    static void getSecuredPartiesTest() {
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as Part of BRS-2491
        UCC_Related_Info__c relatedInfo= new UCC_Related_Info__c(RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId(),
										Filing_Id__c=filingId,Org_Name__c='Dell',Type__c='Secured Party',Country__c='US', 
														International_Address__c='test');
        insert relatedInfo;
        
        Test.startTest();
        List<SObject> uccInfo = brs_addAssignorClass.getSecuredParties(filingId,relatedInfo.Type__c,true);
        List<SObject> uccInfo1 = brs_addAssignorClass.getSecuredParties('','',true);
        Test.stopTest();
        
    }
    
    @isTest
    static void insertAssinorRelatedEntityTest() {
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as Part of BRS-2491
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
       
        List<String> emptyListSecuredIds = new List<String>();
        List<String> listSecuredIds = new List<String>();
        listSecuredIds.add(lstObjRelatedInfo[0].id);
        listSecuredIds.add(lstObjRelatedInfo[1].id);
        
        List<String> removedIds = new List<String>();
        removedIds.add(lstObjRelatedInfo[0].id);
            
        Test.startTest();
        try{
            
             brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], listSecuredIds, filingId, 'LienType', removedIds);
             brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], emptyListSecuredIds , filingId, system.label.Assignor, removedIds);
             brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], listSecuredIds, '', 'LienType', removedIds);
           
            
        }catch(Exception e){ }
        Test.stopTest();
    }
    
    @isTest
    static void insertOnNextButtonTest(){
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as part of BRS-2491
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,recordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        String StringifyObjRelatedInfo = '[{"uccAssignor":{"attributes":{"type":"UCC_Related_Info__c"},"Individual_First_Name__c":"Amend","RecordTypeId":"'+Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId()+'","Filing_Id__c":"'+filingId+'","Org_Name__c":"Dell","Type__c":"Secured Party","City__c":"US"},"uccAssignees":[{"attributes":{"type":"UCC_Related_Info__c","url":"/services/data/v50.0/sobjects/UCC_Related_Info__c/a0kr0000001lrk9AAA"},"Individual_First_Name__c":"Amend 0","RecordTypeId":"'+Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId()+'","Filing_Id__c":"a0mr0000001UpSzAAK","Org_Name__c":"Dell","Type__c":"Secured Party","City__c":"US","Id":"a0kr0000001lrk9AAA"},{"attributes":{"type":"UCC_Related_Info__c","url":"/services/data/v50.0/sobjects/UCC_Related_Info__c/a0kr0000001lrkAAAQ"},"Individual_First_Name__c":"Amend 1","RecordTypeId":"'+Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId()+'","Filing_Id__c":"a0mr0000001UpSzAAK","Org_Name__c":"Dell","Type__c":"Secured Party","City__c":"US","Id":"a0kr0000001lrkAAAQ"}]}]';
       
        Test.startTest();
        try{
            brs_addAssignorClass.insertOnNextButton(StringifyObjRelatedInfo, ''+filingId, 'TestLien');    
            brs_addAssignorClass.insertOnNextButton(''+lstObjRelatedInfo[0], ''+filingId, 'TestLien');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void DeleteRelatedInfoTest(){
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as Part of BRS-2491
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        
        Test.startTest();
        try{ 
            brs_addAssignorClass.DeleteRelatedInfo(''+lstObjRelatedInfo[0].id, ''+filingId, 'TestLien');
            brs_addAssignorClass.DeleteRelatedInfo(''+lstObjRelatedInfo[0], ''+filingId, 'TestLien');
        }catch(Exception e){}
        Test.stopTest();
        
    }
    
    @isTest
    static void getAllAssignorAndAssigneeTest(){
        
     Test.startTest();
    
     UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
     objRelatedInfo.City__c = 'City';   
     objRelatedInfo.Country__c = 'country';
     objRelatedInfo.isAuthorizer__c = true;
     //Added as Part of BRS-2491
     objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
   objRelatedInfo.Org_Name__c = 'Orgname';
     objRelatedInfo.Type__c = 'Secured Party';
     objRelatedInfo.Street__c = 'Street';
	 objRelatedInfo.State__c = 'state';
     objRelatedInfo.Zip_Code__c = '11111';
     objRelatedInfo.Suffix__c = 'Suffix';   
     insert objRelatedInfo;
        
     UCC_Entity_Info__c objEntityInfo2 = new UCC_Entity_Info__c();
     objEntityInfo2.Assignor_ID__c = objRelatedInfo.id;
     objEntityInfo2.Secured_Party_ID__c = objRelatedInfo.id ;
     insert objEntityInfo2;  
        
       
      
        Test.stopTest();
    }
	
	@isTest
    static void getAllAssignorAndAssigneeTestIndv(){
    
        
     List<UCC_Related_Info__c> uccrel = new  List<UCC_Related_Info__c>([Select id from UCC_Related_Info__c where recordType.name = 'Individual']);
        
     UCC_Entity_Info__c objEntityInfo2 = new UCC_Entity_Info__c();
     objEntityInfo2.Assignor_ID__c = uccrel[0].id;
     objEntityInfo2.Secured_Party_ID__c = uccrel[0].id ;
     insert objEntityInfo2;  
        
        Test.startTest();
       
        Test.stopTest();
    }
    
 
    @isTest
    static void assignorWrapperTest()
    {
        
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as Part of BRS-2491
        UCC_Related_Info__c relatedInfo= new UCC_Related_Info__c(recordTypeId= Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId(),
														Filing_Id__c=filingId,Org_Name__c='Dell',
														Type__c='Secured Party',Country__c='US', 
														International_Address__c='test');
        List<UCC_Related_Info__c> testRelatedInfo = new List<UCC_Related_Info__c>();
        
        for(Integer i=0;i<2;i++) {
            //Added as Part of BRS-2491
        testRelatedInfo.add(new UCC_Related_Info__c(recordTypeId= Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId(),Filing_Id__c=filingId,Org_Name__c='Dell',Type__c='Secured Party',Country__c='US', 
														International_Address__c='test'));
        }
        insert testRelatedInfo;
        
        system.assertEquals(2,testRelatedInfo.size());
        
        List< brs_addAssignorClass.assignorWrapper> lstwrapper = new List< brs_addAssignorClass.assignorWrapper>();
        brs_addAssignorClass.assignorWrapper test = new brs_addAssignorClass.assignorWrapper();
    }
     @isTest
    static void insertAssinorRelatedEntityTest1() {
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        //Added as Part of BRS-2491
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        
        List<String> emptyListSecuredIds = new List<String>();
        List<String> listSecuredIds = new List<String>();
        listSecuredIds.add(lstObjRelatedInfo[0].id);
        listSecuredIds.add(lstObjRelatedInfo[1].id);
        
        List<String> removedIds = new List<String>();
        removedIds.add(lstObjRelatedInfo[0].id);
        
        Test.startTest();
        try{
            
            brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], listSecuredIds, filingId, 'Assignor', removedIds);
            brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], emptyListSecuredIds , filingId, system.label.Assignor, removedIds);
            brs_addAssignorClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0], listSecuredIds, '', 'Assignor', removedIds);
            
            
        }catch(Exception e){ }
        Test.stopTest();
    }
}