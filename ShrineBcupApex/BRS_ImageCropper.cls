public class BRS_ImageCropper {
// Controller Class to Save Image to Document of Salesforce	
	public BRS_ImageCropper(){
	}	
	@AuraEnabled
    public static string saveFile(String basebob, String recId){
        try {
            blob propFileBody;
            string propFileName;
            string propContentType;
            if(!string.isblank(basebob))
            {
                List<String> datalist = basebob.split(',');
                if(datalist.size()>0)
                {
                    propContentType=datalist[0].split(';')[0];
                    propContentType=propContentType.removeStart('data:');
                    basebob=datalist[1].trim();
                }
                propFileBody=EncodingUtil.base64Decode(basebob);
                Mark_Filing__c mfiling = [SELECT Id, Sdoc_Filing_Number__c, Image_Path__c, Filing_Type__c, Mark__c FROM Mark_Filing__c WHERE Id =:recId];
				//Create image file
				ContentVersion fileVersion = new ContentVersion(
					ContentLocation = 'S',
					PathOnClient = mfiling.Sdoc_Filing_Number__c + ' - Mark Image' + '.png', 
					Title = mfiling.Sdoc_Filing_Number__c + ' - Mark Image',
					VersionData = propFileBody
					);
				insert fileVersion;
				List<ContentVersion> listFileVersions = [
					SELECT ContentDocumentId
					FROM ContentVersion
					WHERE Id = :fileVersion.Id
					];
				List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
				ContentDocumentLink contentDocLinkMarkFiling = new ContentDocumentLink(
					ContentDocumentId = listFileVersions.get(0).ContentDocumentId,
					LinkedEntityId = recId
					);
				lstContentDocLink.add(contentDocLinkMarkFiling);
            
				//Query the related mark object record if filing type != Registration
				Mark__c objMark = new Mark__c();
				if(mfiling.Filing_Type__c != 'Registration')
				{
					objMark = [SELECT id, Image_Path__c FROM Mark__c WHERE id = :mfiling.Mark__c];
					//Delete previous mark image file (if present) in the mark object record
					if(objMark.Image_Path__c != null || !String.isBlank(objMark.Image_Path__c))
					{
						ContentDocumentLink objContentDocLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :objMark.Id LIMIT 1];
						delete objContentDocLink;
					}
					ContentDocumentLink contentDocLinkMark = new ContentDocumentLink(
						ContentDocumentId = listFileVersions.get(0).ContentDocumentId,
						LinkedEntityId = objMark.Id
						);
					lstContentDocLink.add(contentDocLinkMark);
				}
            
				//inserting contentdocumentlink records                
				if(!lstContentDocLink.isEmpty())
					insert lstContentDocLink;
				
                            
				//In lighting, the attachments are stored in content documents
				ContentDocumentLink docLink = [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recId order by Id desc LIMIT 1]; 
				//ContentVersion Id uniquely identifies the attachment
				ContentVersion version = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId]; 
				//Update the Image_Path field on Mark Filing with the url of the image
				
				String imagePath = '/sfc/servlet.shepherd/version/download/' + version.Id;
				mfiling.Image_Path__c = imagePath;
				update mfiling;
				//Update the Image_Path field on Mark with the url of the image if Mark Filing's filing type != Registration
				if(mfiling.Filing_Type__c != 'Registration')
				{
					objMark.Image_Path__c = imagePath;
					update objMark;
				}
			}
            return 'Success';           
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}