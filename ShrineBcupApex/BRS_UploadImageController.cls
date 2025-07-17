public  class BRS_UploadImageController { 
    @AuraEnabled
    public static void updatePicturePath(String recId){  
        //In lighting, the attachments are stored in content documents
        ContentDocumentLink docLink = [ SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId order by Id desc LIMIT 1]; 
        //ContentVersion Id uniquely identifies the attachment
        ContentVersion version = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId]; 
        //Update the Image_Path field with the url of the image
        Mark_Filing__c mfiling = [SELECT Id FROM Mark_Filing__c WHERE Id =:recId];
        mfiling.Image_Path__c = '/sfc/servlet.shepherd/version/download/' + version.Id; 
        upsert mfiling;        
    }
    @AuraEnabled
    public static String checkFilingData(String recId){
        String retMsg = '';
        Mark_Filing__c objMarkfiling = [SELECT id, Image_Path__c, Filing_Type__c, Status__c FROM Mark_Filing__c WHERE id = :recId LIMIT 1];
        if(objMarkfiling.Status__c == 'Approved' || objMarkfiling.Status__c == 'Rejected')
        {
            String status = objMarkfiling.Status__c;
            retMsg = 'This filing is already ' + status + '.';
        }
        else if(objMarkfiling.Filing_Type__c == System.Label.brs_Mark_Cancellation || objMarkfiling.Filing_Type__c == System.Label.brs_Mark_Owner_Address_Change)
        {
            retMsg = 'This filing does not require a mark image.';
        }
        else if(objMarkfiling.Image_Path__c != null || !String.isBlank(objMarkfiling.Image_Path__c))
        {
            retMsg = 'This Filing already contains Image of Mark. Please go on and approve/reject the filing.';
        }
        else
        {
            retMsg = 'Success';
        }
        return retMsg;
    }
}