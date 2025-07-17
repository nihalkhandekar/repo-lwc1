/*********************************************************************************************
* NAME:  BOS_ResourceCenterBatchUtility 
* DESCRIPTION: Class used for updating Knowledge Resources
*
* @AUTHOR: Nancy Gupta
* @DATE: 1/5/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* _____________________________________________________________________________________________
* Nancy Gupta                   1/5/2021                          Created the first version -  This batch is used during go live - can be deleted later
*
*************************************************************************************************/

global class BOS_ResourceCenterBatchUtility implements Database.Batchable<sObject>{
    
     String query = '';
     String actionVal = '';
    global BOS_ResourceCenterBatchUtility(String actionVal){
        this.actionVal = actionVal;
        if(actionVal == 'PublishArticles'){
            query = 'Select id, knowledgeArticleId from Knowledge__kav where PublishStatus = \'Draft\' and Language =\'en_US\' ';
        }
        if(actionVal == 'UnPublishArticles'){
            query = 'Select id, knowledgeArticleId from Knowledge__kav where PublishStatus = \'Online\' and Language =\'en_US\'';
        }
        if(actionVal == 'CreateTranslatedVersions'){
            query = 'Select Id,KnowledgeArticleId,Title,IsLatestVersion,UrlName from Knowledge__kav where IsLatestVersion = true and PublishStatus =\'Online\' and Language =\'en_US\' ';
        }
        if(actionVal == 'CompleteTranslations'){
            query = 'Select Id,KnowledgeArticleId,Title,IsLatestVersion,UrlName from Knowledge__kav where IsLatestVersion = true and PublishStatus =\'Draft\' and Language =\'es\' ';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Knowledge__kav> kavList) {
        try{
        if(actionVal == 'PublishArticles'){
            for(Knowledge__kav kav: kavList){ 
                KbManagement.PublishingService.publishArticle(String.valueOf(kav.get('KnowledgeArticleId')), true);
            }
        }
        if(actionVal == 'UnPublishArticles'){
            for(Knowledge__kav kav: kavList){ 
                KbManagement.PublishingService.editOnlineArticle(String.valueOf(kav.get('KnowledgeArticleId')), true);
            }
        }
        if(actionVal == 'CreateTranslatedVersions'){
            for(Knowledge__kav kav: kavList){
                String language = 'es';
                String assigneeId = userInfo.getUserId();
                Datetime dueDate = System.now();
                String id = KbManagement.PublishingService.submitForTranslation(kav.KnowledgeArticleId, language, assigneeId, dueDate);
            }
        }
        if(actionVal == 'CompleteTranslations'){
            for(Knowledge__kav kav: kavList){
                KbManagement.PublishingService.completeTranslation(kav.ID);
            }
        }
        }
        catch(Exception e) {    BOS_Utility.handleException(e);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    
    }
}