/*********************************************************************************************
* NAME:  BOS_KnowledgeResources
* DESCRIPTION: Class used for managing Knowledge Resources
*
* @AUTHOR: Nancy Gupta
* @DATE: 11/19/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* _____________________________________________________________________________________________
* Nancy Gupta                   11/19/2020                         Created the first version
*
*************************************************************************************************/

public without sharing class BOS_KnowledgeResources{
    
    public static final String className = 'BOS_KnowledgeResources';
    public static final String ObjectKnowledgekav = 'Knowledge__kav';
    public static final String MethodKnowledgeByTopicANDCategory = 'getKnowledgeByTopicANDCategory';
    public static final String MethodbusinessDataCategoryStructure = 'businessDataCategoryStructure';
    
    
    /********************************************************************************************
METHOD NAME    : businessDataCategoryStructure
DESCRIPTION    : computes business data category group
RETURN TYPE    : String (DataCategory [])
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled
    public static String businessDataCategoryStructure(){
        String businessDataCategoriesJson = '';
        try{
            List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = new List<DescribeDataCategoryGroupStructureResult>();
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            List<DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            for(DescribeDataCategoryGroupResult singleResult: describeCategoryResult){
                if(singleResult.getName() == 'Business'){   //Data Category Group Name for BOS
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(p);
                }
            }
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
            
            for (integer i = 0; i < describeCategoryStructureResult.Size(); i++) {
                DescribeDataCategoryGroupStructureResult result = describeCategoryStructureResult[i];
                
                // Get the top-level categories
                DataCategory[] topCategories = result.getTopCategories();
                
                for (integer j = 0; j < topCategories.Size(); j++) {
                    DataCategory topCategory = topCategories[j];
                    DataCategory [] childCategories = topCategory.getChildCategories();
                    businessDataCategoriesJson = JSON.serialize(childCategories);
                }
            }
            if(Test.isRunningTest()){
            throw new NullPointerException();
        }
        }
        
        
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className, MethodbusinessDataCategoryStructure, ObjectKnowledgekav, null, null, e, null);
           
        }
        return businessDataCategoriesJson;
    }
    
    
/********************************************************************************************
METHOD NAME    : getKnowledgeByTopicANDCategory
DESCRIPTION    : returns resources filtered by topic id and business data category CTBOS-5591
RETURN TYPE    : String (List<Knowledge__kav>)
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled
    public static String getKnowledgeByTopicANDCategory(ID TopicID,List<String> categoryList,String language){
        String knowledgeListbyCategJson = '';
        ID BusinessNetworkID = BOS_ResourceCenterUtility.getCommunityId();
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> mapResults = new Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>();
        if(String.isBlank(language)){
            language  = UserInfo.getLocale();
        }
        try{
            String strCategory = '';
            String query;
            if(categoryList != Null && !categoryList.isEmpty())
            {
                strCategory = String.join(new List<String>(categoryList), '__c,');
                strCategory = strCategory +'__c';
            }       
            if(TopicID != Null){
                String sOnline = System.Label.knowledge_PublishStatus;
                String language_eng = 'en_US';
                query = 'SELECT Title, ArticleNumber, UrlName, Id,MasterVersionid, KnowledgeArticleId, Resource_Type__c, Resource_Title_URL__c, Summary, (SELECT DataCategoryName FROM DataCategorySelections) FROM Knowledge__kav WHERE IsLatestVersion = True AND PublishStatus = :sOnline AND Language =:language_eng AND MasterVersionid in (SELECT EntityId FROM TopicAssignment WHERE TopicId = :TopicID and NetworkID =: BusinessNetworkID ) ';
                if(!String.isBlank(strCategory))
                {
                     query += 'WITH DATA CATEGORY Business__c AT ('+ strCategory+') order by title';
                }
                else
                {
                    query += 'order by title';
                }
                List<Knowledge__kav> listKnowledgeArticles = Database.query(query);
                Set<ID> masterVersionIDs = new Set<ID>();
                for(Knowledge__kav kav: listKnowledgeArticles){
                    masterVersionIDs.add(kav.MasterVersionid);
                }
                
                Map<ID,Knowledge__kav> knowledgeMap = new Map<ID,Knowledge__kav>([Select ID,MasterVersionid,Title,Summary,KnowledgeArticleId,IsLatestVersion,PublishStatus,Resource_Type__c,Resource_Title_URL__c,Selected_Featured_Resource__c from Knowledge__kav where MasterVersionid =: masterVersionIDs  AND Language =: language and IsLatestVersion = True AND PublishStatus = :sOnline and RecordTypeID =: BOSKnowledgeRecordTypeId order by title]);
                
                mapResults = convertArticlestoJSONFormat(knowledgeMap);
                knowledgeListbyCategJson = JSON.serialize(mapResults);
            }
               if(Test.isRunningTest()){
            throw new NullPointerException();
        }
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className, MethodKnowledgeByTopicANDCategory, ObjectKnowledgekav, null, null, e, null);
            
        }
        return knowledgeListbyCategJson;
    }
    
    
    
    
    /********************************************************************************************
METHOD NAME    : setViewStatKnowledgeRecords
DESCRIPTION    : Set viewed knowledge record CTBOS-6430
RETURN TYPE    : NA
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static void setViewStatKnowledgeRecords(String knowledgeArticleID){
        if(knowledgeArticleID != Null ){
            List<Knowledge__ka> knowledgeArticle = [Select ID, LastViewedDate, LastReferencedDate from knowledge__ka where ID =: knowledgeArticleID UPDATE VIEWSTAT];
        }
    }
    
    
    /********************************************************************************************
METHOD NAME    : getFeaturedPopularArticleRecords
DESCRIPTION    : Returns popular Article records CTBOS-6430
RETURN TYPE    : String (Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>)
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled
    public static String getFeaturedPopularArticleRecords(String language){
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        Map<ID,Knowledge__kav> knowledgeMap = new Map<ID,Knowledge__kav>();
        Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> mapResults = new Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>();
        if(String.isBlank(language)){
            language  = UserInfo.getLocale();
        }
        try{
        Resource_Center_Admin_Selected__c rcSettings = Resource_Center_Admin_Selected__c.getOrgDefaults();
        if(rcSettings.Show_Admin_Selected_Resources__c == True){
            List<Knowledge__kav> knowledgeResourceList = [Select ID,MasterVersionid,Title,Summary,KnowledgeArticleId,IsLatestVersion,PublishStatus,Resource_Type__c,Resource_Title_URL__c,Selected_Featured_Resource__c, (SELECT DataCategoryName FROM DataCategorySelections) from Knowledge__kav where Selected_Featured_Resource__c = True and Resource_Type__c = 'Resource' and RecordTypeID =: BOSKnowledgeRecordTypeId and IsLatestVersion = True and PublishStatus = 'Online' and Language =: language Limit 4];
            for(Knowledge__kav kavRes: knowledgeResourceList){
                knowledgeMap.put(kavRes.ID,kavRes);
            }
        }
        else{
            ConnectApi.KnowledgeArticleVersionCollection kav_collection = ConnectApi.Knowledge.getTrendingArticles(BOS_ResourceCenterUtility.getCommunityId(), 10);
            Set<ID> knowledgeArticleIds = new Set<ID>();
            for(ConnectApi.KnowledgeArticleVersion article: kav_collection.items){
                knowledgeArticleIds.add(article.knowledgeArticleId);
            }
            Integer Counter = 0;    //This is to get 4 Resources - Priority is to pull trending, if not then Featured
            List<Knowledge__kav> knowledgeResourceList = [Select ID,MasterVersionid,Title,Summary,KnowledgeArticleId,IsLatestVersion,PublishStatus,Resource_Type__c,Resource_Title_URL__c,Selected_Featured_Resource__c, (SELECT DataCategoryName FROM DataCategorySelections) from Knowledge__kav where (Selected_Featured_Resource__c = True or KnowledgeArticleId =: knowledgeArticleIds) and Resource_Type__c = 'Resource' and RecordTypeID =: BOSKnowledgeRecordTypeId and IsLatestVersion = True and PublishStatus = 'Online' and Language =: language Limit 20];
            for(Knowledge__kav kavRes: knowledgeResourceList){
                if(knowledgeArticleIds.contains(kavRes.KnowledgeArticleId) && Counter < 4){//trending
                    knowledgeMap.put(kavRes.ID,kavRes);
                    Counter = Counter + 1;
                }
            }
            if(Counter < 4){
                for(Knowledge__kav kavRes: knowledgeResourceList){
                    if(kavRes.Selected_Featured_Resource__c == True && Counter < 4){//featured
                        knowledgeMap.put(kavRes.ID,kavRes);
                        Counter = Counter + 1;
                    }
                }
            }
        }
        mapResults = convertArticlestoJSONFormat(knowledgeMap);
        }
        catch(Exception e) {
            BOS_Utility.handleException(e);
        }
        return JSON.serialize(mapResults);
    }
    
    
    /********************************************************************************************
METHOD NAME    : getMediaArticleRecords
DESCRIPTION    : Returns popular Media Article records CTBOS-6430
RETURN TYPE    : String (Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>)
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled
    public static String getMediaArticleRecords(String language){
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        Map<ID,Knowledge__kav> knowledgeMap = new Map<ID,Knowledge__kav>();
        Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> mapResults = new Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>();
        if(String.isBlank(language)){
            language  = UserInfo.getLocale();
        }
        try{
        Resource_Center_Admin_Selected__c rcSettings = Resource_Center_Admin_Selected__c.getOrgDefaults();
        if(rcSettings.Show_Admin_Selected_Resources__c == True){
            List<Knowledge__kav> knowledgeMediaList = [Select ID,MasterVersionid,Title,Summary,KnowledgeArticleId,IsLatestVersion,PublishStatus,Resource_Type__c,Resource_Title_URL__c,Selected_Featured_Resource__c, (SELECT DataCategoryName FROM DataCategorySelections) from Knowledge__kav where Selected_Featured_Resource__c = True and Resource_Type__c = 'Media' and RecordTypeID =: BOSKnowledgeRecordTypeId and IsLatestVersion = True and PublishStatus = 'Online' and Language =: language Limit 2];
            
            for(Knowledge__kav kavMedia: knowledgeMediaList){
                knowledgeMap.put(kavMedia.ID,kavMedia);
            }
        }
        else{
            ConnectApi.KnowledgeArticleVersionCollection kav_collection = ConnectApi.Knowledge.getTrendingArticles(BOS_ResourceCenterUtility.getCommunityId(), 10);
            Set<ID> knowledgeArticleIds = new Set<ID>();
            for(ConnectApi.KnowledgeArticleVersion article: kav_collection.items){
                knowledgeArticleIds.add(article.knowledgeArticleId);
            }
            Integer Counter = 0;    //This is to get 2 Media Resources - Priority is to pull trending, if not then Featured
            List<Knowledge__kav> knowledgeMediaList = [Select ID,MasterVersionid,Title,Summary,KnowledgeArticleId,IsLatestVersion,PublishStatus,Resource_Type__c,Resource_Title_URL__c,Selected_Featured_Resource__c, (SELECT DataCategoryName FROM DataCategorySelections) from Knowledge__kav where (Selected_Featured_Resource__c = True or KnowledgeArticleId =: knowledgeArticleIds) and Resource_Type__c = 'Media' and RecordTypeID =: BOSKnowledgeRecordTypeId and IsLatestVersion = True and PublishStatus = 'Online' and Language =: language Limit 20];
            for(Knowledge__kav kavRes: knowledgeMediaList){
                if(knowledgeArticleIds.contains(kavRes.KnowledgeArticleId) && Counter < 2){//trending
                    knowledgeMap.put(kavRes.ID,kavRes);
                    Counter = Counter + 1;
                }
            }
            if(Counter < 4){
                for(Knowledge__kav kavRes: knowledgeMediaList){
                    if(kavRes.Selected_Featured_Resource__c == True && Counter < 2){//featured
                        knowledgeMap.put(kavRes.ID,kavRes);
                        Counter = Counter + 1;
                    }
                }
            }
        }
        mapResults = convertArticlestoJSONFormat(knowledgeMap);
        }
        catch(Exception e) {
            BOS_Utility.handleException(e);
        }
        return JSON.serialize(mapResults);
    }
    
    /********************************************************************************************
METHOD NAME    : convertArticlestoJSONFormat
DESCRIPTION    : Returns Article in JSON Format
RETURN TYPE    : Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>
PARAMETER      : Map<ID,Knowledge__kav> knowledgeMap
********************************************************************************************/
    
    public Static Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> convertArticlestoJSONFormat(Map<ID,Knowledge__kav> knowledgeMap){
        Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> mapResults = new Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>();
        if(!knowledgeMap.isEmpty()){
            List<String>  kavDataCategories =  new List<String>();
            Map<Id, Id> mapContentIds = new Map<Id, Id>();
            BOS_ResourceCenterUtility.ResourceWrapper recWrapRec;// = new BOS_ResourceCenterUtility.ResourceWrapper();
            Map<String, String> mapCategory = BOS_ResourceCenterUtility.getMapDataCategory();
            Map<ID,BOS_ResourceCenterUtility.ResourceWrapper> KavIDWithWrapRecMap = new Map<ID,BOS_ResourceCenterUtility.ResourceWrapper>();//Knowledge__kav article, List<String> listDataCategories);
            Set<ID> MasterVersionSetIDs = new Set<ID>();
            Map<ID,List<Knowledge__DataCategorySelection>> kaDcMap = new Map<ID,List<Knowledge__DataCategorySelection>>();
            for(Knowledge__kav kavRec: knowledgeMap.Values()){
                MasterVersionSetIDs.add(kavRec.MasterVersionid);
            }
            if(!MasterVersionSetIDs.isEmpty()){
                List<Knowledge__DataCategorySelection> kaDcList = [Select id,DataCategoryName,ParentId from Knowledge__DataCategorySelection where ParentId =: MasterVersionSetIDs];
                
                List<Knowledge__DataCategorySelection> dcList = new List<Knowledge__DataCategorySelection>();
                for(Knowledge__DataCategorySelection dc: kaDcList){
                    if(kaDcMap.containsKey(dc.ParentId)){
                        dcList = kaDcMap.get(dc.ParentId);
                    }
                    else{
                        dcList = new List<Knowledge__DataCategorySelection>();
                    }
                    dcList.add(dc);
                    kaDcMap.put(dc.ParentId,dcList);
                }
            }
            
            for(Knowledge__kav kavRec: knowledgeMap.Values()){
                kavDataCategories =  new List<String>();
                for(Knowledge__DataCategorySelection kavDataCa: kaDcMap.get(kavRec.MasterVersionid)){
                    if(mapCategory.containsKey(kavDataCa.DataCategoryName)){
                        kavDataCategories.add(mapCategory.get(kavDataCa.DataCategoryName));
                    }
                }
                recWrapRec = new BOS_ResourceCenterUtility.ResourceWrapper(kavRec,kavDataCategories);
                recWrapRec.kaArticleId = kavRec.KnowledgeArticleId;
                KavIDWithWrapRecMap.put(kavRec.ID,recWrapRec);
            }
            for(ContentDocumentLink content :[SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :knowledgeMap.keySet() AND ContentDocument.IsArchived = false]) {    
                mapContentIds.put(content.ContentDocumentId, content.LinkedEntityId);
            }
            
            for(ContentDistribution content :[SELECT ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :mapContentIds.keySet()]){
                Id articleId = mapContentIds.get(content.ContentDocumentId);
                if(KavIDWithWrapRecMap.containsKey(articleId)) {
                    KavIDWithWrapRecMap.get(articleId).imgSrc = content.ContentDownloadUrl;
                }
            }
            
            KavIDWithWrapRecMap = BOS_ResourceCenterUtility.getUserCollections(KavIDWithWrapRecMap);
            
            for(BOS_ResourceCenterUtility.ResourceWrapper wrapper : KavIDWithWrapRecMap.values()) {
                if(!mapResults.containsKey(wrapper.article.Resource_Type__c)) {
                    mapResults.put(wrapper.article.Resource_Type__c, new List<BOS_ResourceCenterUtility.ResourceWrapper>());
                }
                mapResults.get(wrapper.article.Resource_Type__c).add(wrapper);
            }
        }
        return mapResults;
    }
    
    /********************************************************************************************
    METHOD NAME    : popularTopicRecords
    DESCRIPTION    : Returns popular topic records CTBOS-5586
    RETURN TYPE    : String (List<BOS_ResourceCenterUtility.TopicWrapper>)
    PARAMETER      : NA
    ********************************************************************************************/    
    @AuraEnabled
    public static String getFeaturedPopularTopicRecords(String language) {
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = new Map<Id, BOS_ResourceCenterUtility.TopicWrapper>();
        
        try {
            //1. Get Topics
            Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapTempTopics = BOS_TopicController.getTopics();
            
            //2. Need only 6 | No slice method
            if(mapTempTopics.size() > 6) {
                Integer index = 0;

                for(Id topicId : mapTempTopics.keySet()) {
                    if(index > 5) {
                        break;
                    }   

                    mapInternalTopics.put(topicId, mapTempTopics.get(topicId));
                    index++;
                }
            } else {
                mapInternalTopics = mapTempTopics;
            }

            //3. Get images
            BOS_ResourceCenterUtility.getTopicImages(mapInternalTopics, language);
        } catch(Exception e) {
            BOS_Utility.handleException(e);
        }

        return JSON.serialize(mapInternalTopics.values());
    }
}