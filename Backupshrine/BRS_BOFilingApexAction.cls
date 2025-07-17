/******************************************************************************************************
* NAME:  		BRS_BOFilingApexAction
* DESCRIPTION:  This class hosts an Invocable method called from BO flows
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		22 May, 2021
*******************************************************************************************************/
public without sharing class BRS_BOFilingApexAction {
    @InvocableMethod
    public static void boFilingApexAction(List<Input> lstInputs) {

        // This logic is for renaming Rejection Notices from BO flows
        if(lstInputs[0].filing != null){
            sObject filing = lstInputs[0].filing;
            String obj = SchemaUtility.getObjectFromId(filing.Id).getName();
            Set<Id> setContentDocumentIds = new Set<Id>(); 
            List<ContentVersion> listContentVersions = new List<ContentVersion>();
            
            for(ContentDocumentLink ContentDoc :[
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :filing.Id
            ]) {
                setContentDocumentIds.add(contentDoc.ContentDocumentId);
            }

            if(!setContentDocumentIds.isEmpty()) {
                for(ContentVersion contentVersion :[
                    SELECT Title
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :setContentDocumentIds
                ]) {
                    contentVersion.Title = System.Label.Rejected + ' - ' + filing.get('Type__c');
                    listContentVersions.add(contentVersion);
                }
                
                if(ContentVersion.SObjectType.getDescribe().isUpdateable()){
                    update listContentVersions;
                }
            }
        }
    }

    public class Input{
        @InvocableVariable public sObject filing;
    }
}