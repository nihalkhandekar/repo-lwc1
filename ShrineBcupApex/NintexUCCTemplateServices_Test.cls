@isTest
public class NintexUCCTemplateServices_Test {

    @isTest private static void nintexUCCTemplate() {
              OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
      UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien(System.Label.OFS_Label);
        UCC_Filing__c uccFiling = new UCC_Filing__c();    
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable',System.Label.BRS_UCC_StatusInProgress,uccLien.Id,System.Label.OFS_Label);
        uccFiling.Type_of_Update__c='Add';
        uccFiling.Amendment_Type__c='Amendment';
        uccFiling.Amendment_Entity__c='Debtor';
        update uccFiling;
              Id individualUCCContactRecTypeId = Schema.getGlobalDescribe().get('UCC_Related_Info__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
          UCC_Related_Info__c objRelatedInfo4 = new UCC_Related_Info__c();  
         objRelatedInfo4.Type__c = 'Debtor';
         objRelatedInfo4.State__c = 'State';
     objRelatedInfo4.Street__c = 'Street';
     objRelatedInfo4.Zip_Code__c = '11111';
     objRelatedInfo4.Suffix__c = 'Suffix';
          objRelatedInfo4.City__c = 'City';   
     objRelatedInfo4.Country__c = 'country';
     objRelatedInfo4.isAuthorizer__c = true;  
            objRelatedInfo4.Deleted_Flag__c = false;
            objRelatedInfo4.Status__c = 'Completed';
            objRelatedInfo4.Individual_First_Name__c = 'FirstName';
            objRelatedInfo4.Individual_SurName__c = 'surname';
            objRelatedInfo4.RecordTypeId = individualUCCContactRecTypeId;
        objRelatedInfo4.isCloned__c=false;
            insert objRelatedInfo4;
      NintexUCCTemplateServices ucctemplate=new NintexUCCTemplateServices();
        ucctemplate.getGlobalDescribe();
      ucctemplate.getChildRelationships('UCC_Filing__c');
      List<string> fields = new List<string>();
      fields.add('debtorAdd');
      fields.add('debtorUpdate');
      fields.add('debtorDelete');
      fields.add('securedPartyAdd');
      fields.add('securedPartyUpdate');
      fields.add('securedPartyDelete');
      ucctemplate.describeObjects(fields);
      Loop.ExternalData.QueryRequestInfo requestInfo1 = new Loop.ExternalData.QueryRequestInfo();
      requestInfo1.RecordId=uccFiling.id;
      ucctemplate.query(requestInfo1);
        ucctemplate.getUCCContacts(requestInfo1,'debtorAdd');
        ucctemplate.getFieldValue(uccFiling,'Type_of_Update__c');
    }
}