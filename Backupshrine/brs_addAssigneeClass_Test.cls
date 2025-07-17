@isTest
private class brs_addAssigneeClass_Test {
    
    @testSetup 
    static void setup() {
       
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        List<UCC_Filing__c> testFiling = new List<UCC_Filing__c>();
        for(Integer i=0;i<2;i++) {
            testFiling.add(new UCC_Filing__c(Type__c = 'Amendments',Status__c = 'In-Progress'));
        }
        insert testFiling; 
     
     	List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
        
         UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
         objRelatedInfo.City__c = 'City';   
         objRelatedInfo.Country__c = 'country';
         objRelatedInfo.isAuthorizer__c = true;
         objRelatedInfo.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
         objRelatedInfo.Org_Name__c = 'Orgname';
         objRelatedInfo.Type__c = 'Secured Party';
         //objRelatedInfo.Individual_SurName__c = 'surname'; 
         objRelatedInfo.Street__c = 'Street';
         objRelatedInfo.Zip_Code__c = '11111';
         //objRelatedInfo.Individual_Middle_Name__c = 'Middlename';
         objRelatedInfo.Suffix__c = 'Suffix';   
         objRelatedInfo.Filing_Id__c = testFiling[0].id;
		 objRelatedInfo.state__c = 'Test';
         lstRelatedInfo.add(objRelatedInfo);
            
         UCC_Related_Info__c objRelatedInfo2 = new UCC_Related_Info__c();  
         objRelatedInfo2.City__c = 'City';   
         objRelatedInfo2.Country__c = 'country';
         //objRelatedInfo2.Individual_First_Name__c = 'FirstName';
         objRelatedInfo2.isAuthorizer__c = true;
          //Added as Part of BRS-2366
          objRelatedInfo2.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType());
          objRelatedInfo2.Org_Name__c = 'Orgname';
         objRelatedInfo2.Type__c = 'Secured Party';
         //objRelatedInfo2.Individual_SurName__c = 'surname'; 
         objRelatedInfo2.Street__c = 'Street';
         objRelatedInfo2.Zip_Code__c = '11111';
         //objRelatedInfo2.Individual_Middle_Name__c = 'Middlename';
         objRelatedInfo2.Suffix__c = 'Suffix';   
         objRelatedInfo2.Filing_Id__c = testFiling[0].id;
		 objRelatedInfo2.state__c = 'Test';
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
         objEntityInfo2.Secured_Party_ID__c = objRelatedInfo2.id ;
         lstUccEntityInfo.add(objEntityInfo2); 
            
         insert lstUccEntityInfo;    
        }
    
    @isTest
    static void getSecuredPartiesTest(){
         
         String filingId  = (String)[Select id from UCC_Filing__c Limit 1].id;
         System.assertNotEquals(null,filingId);
        
         Test.startTest();
         try{
               brs_addAssigneeClass.getSecuredParties(filingId,'LienData');
          }catch(Exception e){
               System.assertEquals('Script-thrown exception',e.getMessage());
          }
         Test.stopTest();
     }  
    
    @isTest
    static void insertAssinorRelatedEntityTest(){
        
        String filingId  = (String)[Select id from UCC_Filing__c Limit 1].id;
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        List<String> listSecuredIds = new List<String>();
        
        System.assertEquals(2,lstObjRelatedInfo.size());
        System.assertNotEquals(null,filingId);
        
        listSecuredIds.add(lstObjRelatedInfo[0].id);
        listSecuredIds.add(lstObjRelatedInfo[1].id);
        
        Test.startTest();
         try{
             brs_addAssigneeClass.insertAssinorRelatedEntity(lstObjRelatedInfo[0],listSecuredIds,filingId,'LienData');
          }catch(Exception e){
             System.assertEquals('Script-thrown exception',e.getMessage());
          }
         Test.stopTest();
    }
    
    @isTest
    static void insertOnNextButtonTest(){
        
        String filingId  = (String)[Select id from UCC_Filing__c Limit 1].id;
         List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        List<String> listSecuredIds = new List<String>();
        List< brs_addAssigneeClass.assignorWrapper> lstwrapper = new List< brs_addAssigneeClass.assignorWrapper>();
        brs_addAssigneeClass.assignorWrapper objWrapper = new brs_addAssigneeClass.assignorWrapper();
        objWrapper.uccAssignor = lstObjRelatedInfo[0];
        objWrapper.uccAssignees = lstObjRelatedInfo;
        lstwrapper.add(objWrapper);
        
        listSecuredIds.add(lstObjRelatedInfo[0].id);
        listSecuredIds.add(lstObjRelatedInfo[1].id);
        
        System.assertEquals(2,lstObjRelatedInfo.size());
        System.assertNotEquals(null,filingId);
        
        Test.startTest();
         try{
             
             brs_addAssigneeClass.insertOnNextButton(lstwrapper,filingId,'LienData');
             brs_addAssigneeClass.insertOnNextButton(null,filingId,'LienData');
                 
         }catch(Exception e){
             System.assertEquals('Script-thrown exception',e.getMessage());
         }
         Test.stopTest();
    }
    
    @isTest
    static void deleteRelatedInfoTest(){
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        List<UCC_Related_Info__c> lstObjRelatedInfo = [SELECT Id, Name, Individual_First_Name__c,isAuthorizer__c, RecordTypeId,RecordType.DeveloperName, Org_Name__c, Type__c, Individual_SurName__c, City__c, Street__c, Zip_Code__c, Individual_Middle_Name__c, Suffix__c, State__c, Country__c,Filing_Id__c FROM UCC_Related_Info__c];
        
        System.assertEquals(2,lstObjRelatedInfo.size());
        System.assertNotEquals(null,filingId);
        
        Test.startTest();
        try{ 
            brs_addAssigneeClass.DeleteRelatedInfo(''+lstObjRelatedInfo[0].id, ''+filingId, 'TestLien');
            brs_addAssigneeClass.DeleteRelatedInfo(''+lstObjRelatedInfo[0], ''+filingId, 'TestLien');
        }catch(Exception e){
             System.assertEquals('Script-thrown exception',e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void assignorWrapperTest()
    {
        Id filingId  = [Select id from UCC_Filing__c Limit 1].id;
        
        UCC_Related_Info__c relatedInfo= new UCC_Related_Info__c(/*Individual_First_Name__c = 'Amend',*/RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label, Schema.UCC_Related_Info__c.getSObjectType()),Filing_Id__c=filingId,Org_Name__c='Dell',Type__c='Secured Party',Country__c='US',International_Address__c = 'Test');
        List<UCC_Related_Info__c> testRelatedInfo = new List<UCC_Related_Info__c>();
        for(Integer i=0;i<2;i++) {
            
        testRelatedInfo.add(new UCC_Related_Info__c(RecordTypeId=Wizard_Utlity.getRecordTypeId(System.Label.Organization_Label,
													Schema.UCC_Related_Info__c.getSObjectType()),
													Filing_Id__c=filingId,Org_Name__c='Dell',
													Type__c='Secured Party',Country__c='US',
													International_Address__c = 'Test'));
        }
        insert testRelatedInfo;
        
        System.assertEquals(2,testRelatedInfo.size());
        
        List< brs_addAssigneeClass.assignorWrapper> lstwrapper = new List< brs_addAssigneeClass.assignorWrapper>();
        brs_addAssigneeClass.assignorWrapper test = new brs_addAssigneeClass.assignorWrapper();
    }
}