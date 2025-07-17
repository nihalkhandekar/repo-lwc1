public class BackOfficeContentDocumentRecords {
    
    @InvocableMethod(label='Content Documents')
        public static List<List<ContentDocument>> getContentDocuments(List<FlowInputs> documentIds){
  
        
		List<Id> cID2 = new List<Id>();
        List<String> cdocumentIds = new List<String>();
        List<String> newDocumentIds = new List<String>();

         String inputList = JSON.serializePretty(documentIds);
        System.debug('json:' + inputList);
  		List<Object> result = (List<Object>)JSON.deserializeUntyped(inputList);

        for(Object obj : result) { 
           Map<String,Object> map1 = (Map<String,Object>)obj;
            List<Object> items = (List<Object>)map1.get('contentDocIds');
    
            System.debug('items' + items);
            
            for(Object v: items){
                if(v !=null){
                String a = String.valueOf(v);
				String newA = '\''+a+'\'';
                System.debug('newA:' + newA);
                newDocumentIds.add(a);   
                }
  
            }
                        
            for(String str: newDocumentIds){
                Id valv = str;
                cID2.add(valv);
                System.debug('Id values:' + valv);
            }
        }
        
        List<ContentDocument> cdList = [Select Id, Title, Description, FileType from ContentDocument where Id In: cID2]; 
        System.debug('ContentDocument records ' + cdList);
                
        List<List<ContentDocument>> llc = new List<List<ContentDocument>>();
        llc.add(cdList);
        
        System.debug('CD records returned:' + llc);


  	return llc;
    }
    
    public class FlowInputs{
              
          @InvocableVariable
        public List<String> contentDocIds;   

     }
    
     public class FlowOutputs{
              
          @InvocableVariable
        public String contentDocumentRecords;   
         
           @invocableVariable 
        public ContentDocument[] filteredcontentDocumentCollection;
         
         @invocableVariable
         public List<List<ContentDocument>> listContentDocument;

     }
}