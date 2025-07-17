/*********************************************************************************************
* NAME:  BOS_Topics
* DESCRIPTION: Resource Center | Recommended Topics
*
* MODIFICATION LOG:
* DEVELOPER                 DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                    1/6/21                             Recommended Topics
*********************************************************************************************/
public without sharing class BOS_Topics {
    private static Integer MAX_TOPICS = 6;

    @AuraEnabled(cacheable=true)
    public static String getRecommendedTopics() {
        RecommendedCondition condition = new RecommendedCondition();
        Id contactId = BOS_ResourceCenterUtility.getContactId();
        String language = UserInfo.getLocale();
        Id communityId = BOS_ResourceCenterUtility.getCommunityId();
        
        //1. Questionnaire
        getRecommendationsFromQuestionnare(condition, contactId);
        //2. Business
        getRecommendationsFromBusiness(condition, contactId);

        //3. Recom Articles --> Topics
        List<Knowledge__kav> listRecommendedArticles = getRecommendedArticles(condition, language);
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = getArticleTopics(listRecommendedArticles, communityId);

        //4. Admin selected
        if(mapInternalTopics.size() < MAX_TOPICS) {
            for(BOS_ResourceCenterUtility.TopicWrapper wrapper :BOS_TopicController.getFeaturedTopics().values()) {
                if(mapInternalTopics.size() == MAX_TOPICS) {
                    break;
                }

                mapInternalTopics.put(wrapper.topicRec.Id, wrapper);
            }
        }

        //5. Topic Images
        BOS_ResourceCenterUtility.getTopicImages(mapInternalTopics, language);

        return JSON.serialize(mapInternalTopics.values());
    }

    private static List<Knowledge__kav> getRecommendedArticles(RecommendedCondition condition, String language) {
        List<Knowledge__kav> listRecommendedArticles = new List<Knowledge__kav>();
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('BOS_Resource_Content').getRecordTypeId();    //get RecordType by Developer Name
        if(String.isNotBlank(condition.quesNaicsCode) || !condition.listIdentifiedGroups.isEmpty() || !String.isNotBlank(condition.businessNaicsCode)) {
            listRecommendedArticles = [
                SELECT Id, MasterVersionId
                FROM Knowledge__kav
                WHERE PublishStatus = :System.Label.knowledge_PublishStatus
                    AND RecordTypeID =: BOSKnowledgeRecordTypeId  
                    AND Language = :language
                    AND
                        (
                            NAICS_Code__c LIKE :condition.quesNaicsCode
                            OR
                            NAICS_Code__c LIKE :condition.businessNaicsCode
                            OR
                            Identified_Group__c IN :condition.listIdentifiedGroups
                        )
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
        }
        
        return listRecommendedArticles;
    }

    /*Method to get topics from knowledge articles*/
    private static Map<Id, BOS_ResourceCenterUtility.TopicWrapper> getArticleTopics(List<Knowledge__kav> listRecommendedArticles, Id communityId) {
        Map<Id, BOS_ResourceCenterUtility.TopicWrapper> mapInternalTopics = new Map<Id, BOS_ResourceCenterUtility.TopicWrapper>();
        Map<Id, List<Id>> mapKAITopics = new Map<Id, List<Id>>(); //article id - all topics
        Map<Id, Topic> mapTopics = new Map<Id, Topic>(); //temp topic map
        
        //2. Topic Details
            for(TopicAssignment t :[
            SELECT EntityId, TopicId, Topic.Name
            FROM TopicAssignment 
            WHERE EntityType = 'Knowledge' 
                AND NetworkId = :communityId
                AND EntityId IN :listRecommendedArticles
            //ORDER BY Topic.SystemModStamp DESC, Topic.Name ASC
            ]) {
                if(mapTopics.size() >= MAX_TOPICS) {
                    break;
                }

                if(!mapKAITopics.containsKey(t.EntityId)) {
                    mapKAITopics.put(t.entityid, new List<Id>());
                }
            
                mapKAITopics.get(t.entityid).add(t.TopicId);
                mapTopics.put(t.TopicId, new Topic(Id = t.TopicId, Name = t.Topic.Name));
            }

        //3. Highest topic = Highest article
        for(Knowledge__kav article :listRecommendedArticles) {
            if(mapKAITopics.containsKey(article.Id)) {
                for(Id topicId :mapKAITopics.get(article.Id)) {
                    mapInternalTopics.put(topicId, new BOS_ResourceCenterUtility.TopicWrapper(mapTopics.get(topicId)) );
                }
            }
        }

        return mapInternalTopics;
    }

    private static void getRecommendationsFromQuestionnare(RecommendedCondition condition, Id contactId) {
        List<Questionnaire__c> listQuestionnaires = [
            SELECT Id, Category__r.Code__c, 
                (
                    SELECT Given_Response_Value__c 
                    FROM QA_Question_Responses__r 
                    WHERE Question_Summary__c = 'Identified Groups'
                )
            FROM Questionnaire__c
            WHERE Contact__c = :contactId
                AND Status__c = :System.Label.Questionnaire_Status_Update
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        if(!listQuestionnaires.isEmpty()) {
            Questionnaire__c questionnaire = listQuestionnaires.get(0);

            condition.quesNaicsCode = '%' + questionnaire.Category__r.Code__c.substring(0,2) + '%';
            condition.listIdentifiedGroups = !questionnaire.QA_Question_Responses__r.isEmpty()
                ? questionnaire.QA_Question_Responses__r.get(0).Given_Response_Value__c.split(System.Label.PIPELINE_SEPARATOR)
                : new List<String>();
        }
    }

    private static void getRecommendationsFromBusiness(RecommendedCondition condition, Id contactId) {
        List<Account> listLinkedAccounts = [
            SELECT NAICS_Code__c
            FROM Account
            WHERE Id IN 
                (
                    SELECT AccountId
                    FROM AccountContactRelation
                    WHERE ContactId = :contactId
                )
                AND RecordType.Name = :System.Label.ActionItem_AccountRecordType
            ORDER BY SystemModStamp DESC
            LIMIT 1
        ];
        
        if(!listLinkedAccounts.isEmpty()) {
            condition.businessNaicsCode = listLinkedAccounts.get(0).NAICS_Code__c;
        }
    }

    private class RecommendedCondition {
        String businessNaicsCode;
        String quesNaicsCode;
        List<String> listIdentifiedGroups;
        
        private RecommendedCondition() {
            this.listIdentifiedGroups = new List<String>();
        }
    }
}