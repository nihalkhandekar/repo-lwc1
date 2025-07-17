@isTest
public with sharing class brs_TradeAndServiceSearchController_TEST {
    @testSetup static void setup() {
        Mark__C mObj = BRS_TestDataFactory.createMark();
        Mark_Filing__c mFilingObj = BRS_TestDataFactory.createMarkFiling(mObj.Id);
        mFilingObj.Status__c = 'Approved';
        Update mFilingObj;
        Attachment attach=new Attachment();       
        attach.Name='Registration';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=mFilingObj.id;
        Insert attach;
        ContentVersion cv3 = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv3;
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv3.id Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = mFilingObj.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
        ContentDocumentLink cdl = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink where linkedentityid =: mFilingObj.Id LIMIT 1];
        ContentVersion cv = [select id from contentversion where contentdocumentid = :cdl.contentdocument.id LIMIT 1];
       
    }
    testmethod static void testMethod1() {
        brs_genericSearchBusinessClass.filterWrapper filterObj = new brs_genericSearchBusinessClass.filterWrapper();
        filterObj.selectedOptions = new List<String>{'Collective Mark'};
        Mark__c mObj = [Select Id from Mark__c LIMIT 1];
        TEST.setFixedSearchResults(new List<String> {mObj.Id});
        brs_TradeAndServiceSearchController.getMarkSearchList('1924', new List<brs_genericSearchBusinessClass.filterWrapper>(), false);
        brs_TradeAndServiceSearchController.getSelectedTradeAndServiceMarkDetails(mObj.Id);
    }
    testmethod static void testMethod2() {
        test.startTest();
        brs_genericSearchBusinessClass.filterWrapper filterObj = new brs_genericSearchBusinessClass.filterWrapper();
        filterObj.selectedOptions = new List<String>{'Collective Mark'};
        brs_TradeAndServiceSearchController.getMarkSearchList('1924', new List<brs_genericSearchBusinessClass.filterWrapper>{filterObj}, true);
        Mark__c mObj = [Select Id,Registration_Date__c from Mark__c LIMIT 1]; 
        brs_TradeAndServiceSearchController.getSelectedTradeAndServiceMarkDetails(mObj.Id);
        brs_TradeAndServiceSearchController.retFormattedDate(mObj.Registration_Date__c);
        test.stopTest();
    }
}