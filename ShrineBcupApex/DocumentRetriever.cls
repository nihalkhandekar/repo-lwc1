public class DocumentRetriever {
    
    @InvocableMethod(label='Get Documents Info' description='Retrieves information for all documents associated with a record ID')
    public static List<List<DocumentInfo>> getDocumentsInfo(List<Id> recordIds) {
        List<List<DocumentInfo>> results = new List<List<DocumentInfo>>();
        
        if (recordIds == null || recordIds.isEmpty()) {
            return results;
        }
        
        Id recordId = recordIds[0]; // Assuming we're processing one record at a time
        
        // Query for all ContentDocumentLinks related to the given record ID
        List<ContentDocumentLink> links = [
            SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];
        
        List<DocumentInfo> documentInfos = new List<DocumentInfo>();
        
        for (ContentDocumentLink link : links) {
            documentInfos.add(new DocumentInfo(
                link.ContentDocument.Title,
                link.ContentDocument.Id,
                link.ContentDocument.FileExtension
            ));
        }
        
        results.add(documentInfos);
        return results;
    }
    
    // Wrapper class to hold document information
    public class DocumentInfo {
        @InvocableVariable(label='Document Title' description='The title of the document')
        public String documentTitle;
        
        @InvocableVariable(label='Document ID' description='The ID of the document')
        public Id documentId;
        
        @InvocableVariable(label='File Extension' description='The file extension of the document')
        public String fileExtension;
        
        public DocumentInfo(String title, Id docId, String extension) {
            this.documentTitle = title;
            this.documentId = docId;
            this.fileExtension = extension;
        }
    }
}