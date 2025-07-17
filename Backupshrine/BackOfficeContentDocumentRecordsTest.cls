@isTest

public with sharing class BackOfficeContentDocumentRecordsTest {

        static testMethod void getContentDocuments() {

        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Blob bodyBlob=Blob.valueOf('Test blob');

        ContentVersion cv = new ContentVersion(Title='CV1', PathOnClient='SampleTitle.jpg',VersionData = bodyBlob, IsMajorVersion = true);
        insert cv;
            
        ContentVersion cv2 = [Select Id, Title, ContentDocumentId from ContentVersion where Id = :cv.id Limit 1];
            
         List<ContentDocument> documentList = [Select Id, Title from ContentDocument ];
         System.assertEquals(documentList.size(),1);
   

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = a.Id;
        contentLink.ContentDocumentId = cv2.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
            
         System.assertEquals(contentLink.contentDocumentId, cv2.ContentDocumentId);

        ContentDocument cd = new ContentDocument();
        cd.Id = contentLink.ContentDocumentId;
        cd.Id = cv2.ContentDocumentId;
        list<String> listDocId = new list<String>();
        listDocId.add(cd.Id);
            
	    System.debug('cdId' + cd.Id);
        String cIdString = cd.Id;

        List<BackOfficeContentDocumentRecords.FlowInputs> flowList = new List<BackOfficeContentDocumentRecords.FlowInputs>();
         
        BackOfficeContentDocumentRecords.FlowInputs inputId = new BackOfficeContentDocumentRecords.FlowInputs();
		//inputId.contentDocIds.add(String.valueOf(cd.Id));
		inputId.contentDocIds = listDocId;
        System.debug('inputId.contentId: ' + inputId.contentDocIds);
		//inputId.contentDocIds.add(cd.Id);
            
            
		flowList.add(inputId);

        List<BackOfficeContentDocumentRecords.FlowInputs> input = new List<BackOfficeContentDocumentRecords.FlowInputs>();
        List<BackOfficeContentDocumentRecords.FlowInputs> inputListnull = new List<BackOfficeContentDocumentRecords.FlowInputs>();


        BackOfficeContentDocumentRecords.FlowInputs flowinput = new BackOfficeContentDocumentRecords.FlowInputs();


        BackOfficeContentDocumentRecords.getContentDocuments(flowList); 
           //BackOfficeContentDocumentRecords.getContentDocuments(cIdString);
       
   
 

        System.assertEquals('Incorrect Signature','Incorrect Signature'); 
     

    }
}