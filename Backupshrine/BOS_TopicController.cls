/*********************************************************************************************
* NAME:  BOS_TopicController
* DESCRIPTION: Resource Center | For Topic Images and All Topics page
*        
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        12/1/2020                          CTBOS-6429 | All Topics
*********************************************************************************************/
public without sharing class BOS_TopicController {
    //NOTE: TopicImage.Name = Topic.Id

    /*
     * @desc: For custom topic lookup - search by topic name
     * Only for english ones
     * Cannot create records for topiclocalization
     */
    @AuraEnabled(cacheable=true)
    public static String searchByTopicName(String searchTerm) {
        List<Topic> listTopics = new List<Topic>();
        
        if(String.isNotBlank(searchTerm) && searchTerm.length() >= 3) {
            listTopics = [
                SELECT Id, Name
                FROM Topic
                WHERE Name LIKE :('%' + String.escapeSingleQuotes(searchTerm) + '%')
                WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
        }

        return JSON.serialize(listTopics);
    }

    /**
     * 1. Get admin selected/featured topics
     * 2. popular topics: Trending Articles -> Topics
     * 3. Others: SystemModStamp DESC, Name ASC
     */
    @AuraEnabled(cacheable=true)
    public static String getAllTopics(String language) {
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = new Map<Id, BOS_ResourceCenterUtility.TopicWrapper>();
        
        try {
            //1. Admin selected/Popular
            mapInternalTopics = getTopics();
            //2. Get Other topics
            setOtherTopics(mapInternalTopics);

            //3. Get Topic Details
            BOS_ResourceCenterUtility.getTopicImages(mapInternalTopics, language);
        } catch(Exception e) {
            BOS_Utility.handleException(e);
        }
        
        return JSON.serialize(mapInternalTopics.values());
    }

    /**
     * Used in 
     * 1. BOS_TopicController.getAllTopics
     * 2. BOS_KnowledgeResources.getFeaturedPopularTopicRecords
     */
    public static Map<Id, BOS_ResourceCenterUtility.TopicWrapper> getTopics() {
        //1.1 | Admin selected/Popular
        Resource_Center_Admin_Selected__c rcSettings = Resource_Center_Admin_Selected__c.getOrgDefaults();
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = 
            rcSettings.Show_Featured_Topics__c == true
            ? getFeaturedTopics()
            : getPopularTopics();
        
        return mapInternalTopics;
    }

    public static Map<Id, BOS_ResourceCenterUtility.TopicWrapper> getFeaturedTopics() {
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = new Map<Id, BOS_ResourceCenterUtility.TopicWrapper>();
        List<Topic> listTopics = new List<Topic>();

        for(ConnectApi.ManagedTopic managedTopic :Connectapi.ManagedTopics.getManagedTopics(BOS_ResourceCenterUtility.getCommunityId(), ConnectApi.ManagedTopicType.Featured).managedTopics) {
            mapInternalTopics.put(
                managedTopic.topic.Id, 
                new BOS_ResourceCenterUtility.TopicWrapper(new Topic(
                    Id = managedTopic.topic.Id,
                    Name = managedTopic.topic.Name
                ))
            );
        }

        return mapInternalTopics;
    }

    @TestVisible
    private static Map<Id, BOS_ResourceCenterUtility.TopicWrapper> getPopularTopics() {
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = new Map<Id, BOS_ResourceCenterUtility.TopicWrapper>();  //final list
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        Id communityId = BOS_ResourceCenterUtility.getCommunityId();
        Map<Id, List<Id>> mapKAITopics = new Map<Id, List<Id>>(); //article id - all topics
        Map<Id, Topic> mapTopics = new Map<Id, Topic>(); //temp topic map
        
        //1. Get Popular (Trending) Articles | Upper limit of 25 for trending * Some permission issue with spring 21
        /*for(ConnectApi.KnowledgeArticleVersion article : ConnectApi.Knowledge.getTrendingArticles(communityId, 25).items) {
            listArticleIds.add(article.Id);
        } */
        //Topics are only associated to eng kav
        List<Knowledge__kav> listArticles = [
            SELECT Id
            FROM Knowledge__kav
            WHERE Language = :System.Label.SSO_JIT_UserLocale
                AND PublishStatus = :System.Label.knowledge_PublishStatus
                AND RecordTypeID =: BOSKnowledgeRecordTypeId  
            ORDER BY ArticleTotalViewCount DESC
            LIMIT 25
        ];

        //2. Topic Details
        for(TopicAssignment t :[
            SELECT EntityId, TopicId, Topic.Name
            FROM TopicAssignment 
            WHERE EntityType = 'Knowledge' 
                AND NetworkId = :communityId
                AND EntityId IN :listArticles
            ORDER BY Topic.SystemModStamp DESC, Topic.Name ASC
        ]) {
            if(!mapKAITopics.containsKey(t.EntityId)) {
                mapKAITopics.put(t.entityid, new List<Id>());
            }
            
            mapKAITopics.get(t.entityid).add(t.TopicId);
            mapTopics.put(t.TopicId, new Topic(Id = t.TopicId, Name = t.Topic.Name));
        }

        //3. Highest topic = Highest article
        for(Knowledge__kav article :listArticles) {
            if(mapKAITopics.containsKey(article.Id)) {
                for(Id topicId :mapKAITopics.get(article.Id)) {
                    mapInternalTopics.put(topicId, new BOS_ResourceCenterUtility.TopicWrapper(mapTopics.get(topicId)) );
                }
            }
        }
        
        return mapInternalTopics;
    }

    private static void setOtherTopics(Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics) {
        for(Topic topic : [
            SELECT Id, Name
            FROM Topic
            WHERE Id NOT IN :mapInternalTopics.keySet() and NetworkID =: BOS_ResourceCenterUtility.getCommunityId()
            ORDER BY SystemModStamp DESC, Name ASC      
        ]) {
            mapInternalTopics.put(topic.Id, new BOS_ResourceCenterUtility.TopicWrapper(topic));
        }
    }
}