/* @AUTHOR:  Sarita
* @DATE:    06/04/2021
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita                            06/04/2021                           Created the first version
* Shreya                            07/02/2021                           BRS-5171 | Support for docs
* Avinash Shukla                            07/19/2021                   BRS-6219 | Added image formats.
*********************************************************************************************/
public with sharing class contentVersionTriggerHelper {
    public static User currUser = [SELECT Bypass_trigger__c FROM User WHERE Id =: userInfo.getUserId() WITH SECURITY_ENFORCED];
    
    public static void createPublicLinkForFile(Map<Id, SObject> ContentVersions) {
        List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-6219
        * Change(s)/Modification(s) Description : Adding JPEG,JPG and PNG formats so connectdistribution is created to be viewed from public community pages
        * Change(s)/Modification(s) Made on : \20-07-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        List<String> markImageAcceptedFormats = System.Label.Mark_Image_Accepted_Formats.Split(QnA_Constants.COMMA_SEPARATOR);
        if(!currUser.Bypass_trigger__c && !contentVersions.Isempty()) {
            for(ContentVersion objContentVersion : (List<ContentVersion>)contentVersions.values()) {
                if('pdf'.equalsIgnoreCase(objContentVersion.FileType) || 'word'.equalsIgnoreCase(objContentVersion.FileType) || markImageAcceptedFormats.contains(objContentVersion.FileType.toLowercase())) {
                    distributionsToInsert.add(createContentDistribution(objContentVersion));
                }
            }  
            
            if(!distributionsToInsert.isEmpty() && BRS_SecurityUtility.checkDMLAccess(distributionsToInsert, 'insert')) {
                insert distributionsToInsert;
            }  
        }
    }
    
    public static ContentDistribution createContentDistribution(ContentVersion contentVersion) {
        return new ContentDistribution(
            ContentVersionId = contentVersion.Id,
            Name = (contentVersion.Title.length()>100)?contentVersion.Title.substring(0,99):contentVersion.Title, //Fix for Bug-8835
            PreferencesNotifyOnVisit = false,
            PreferencesAllowViewInBrowser = true,
            PreferencesAllowOriginalDownload = true
        ); 
    }
}