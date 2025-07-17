@istest(seeAllData = false)
public with sharing class BRS_UploadImageControllerTest {

    @isTest
    static void testmethod1(){
         
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        Knowledge__kav kw = new Knowledge__kav();
        kw.title = 'Test';
        kw.UrlName = 'test';
        kw.Language='en_US';
        kw.Selected_Featured_Resource__c=true;
        kw.Resource_Type__c='Resource';
        kw.RecordTypeID=BOSKnowledgeRecordTypeId;
        insert kw;
        
        /*Knowledge__kav kw2 = new Knowledge__kav();
        kw2.title = 'Test2';
        kw2.UrlName = 'test2';
        kw2.Language='en_US';
        kw2.Selected_Featured_Resource__c=true;
        kw2.Resource_Type__c='Media';
        kw2.RecordTypeID=BOSKnowledgeRecordTypeId;
        insert kw2;*/
        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Owner Address Change');
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.FirstPublishLocationId =kw2.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=markfiling.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink; 
        BRS_UploadImageController.updatePicturePath(markfiling.id);
        

        

    }

    @isTest
    static void testmethod2(){

        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark1();
        RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling1(mark.id,rt.id,'Owner Address Change');
        test.startTest();
        BRS_UploadImageController.checkFilingData(markfiling.id);
        test.stopTest();

    }

    
    @isTest
    static void testmethod3(){

        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        //RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        test.startTest();
        BRS_UploadImageController.checkFilingData(markfiling.id);
        test.stopTest();

    }

    @isTest
    static void testmethod4(){

        Mark__c mark=new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        //RecordType rt =[select id,Name,developername from RecordType where developername='Owner_Updates'];
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling=BRS_TestDataFactory.createMarkFiling(mark.id);
        markfiling.Status__c = '';
        markfiling.Image_Path__c = 'jhghg/fg';
        update markfiling;
        test.startTest();
        BRS_UploadImageController.checkFilingData(markfiling.id);
        test.stopTest();

    }
}