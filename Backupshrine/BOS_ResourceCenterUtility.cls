/*********************************************************************************************
 * NAME:  BOS_ResourceCenterUtility
 * DESCRIPTION: Resource Center
 *
 * @AUTHOR: Shreya Bordia
 * @DATE: 12/11/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Shreya Bordia                     12/11/2020                         Resource Center
 *********************************************************************************************/
public without sharing class BOS_ResourceCenterUtility {
    public class CollectionWrapper {
        public Collection__c collection;
        public List<Collection_Folder__c> folders;

        public CollectionWrapper(Collection__c collection) {
            this.collection = collection;
            this.folders = new List<Collection_Folder__c>();
        }
    }

    public class LandingPageWrapper {
        List<TopicWrapper> listTopics;
        List<ResourceWrapper> listResources; //includes both media & text
        List<CollectionWrapper> listCollectionWrapper;
    }

    /*
     * @desc: wrapper for dual list as select option is not supported
     */
    public class OptionWrapper {
        public String label;
        public String value;

        public OptionWrapper(String value, String label) {
            this.label = label;
            this.value = value;
        }
    }

    /*
     * @desc: wrapper for knowledge articles
     */
    public class ResourceWrapper {
        public String imgSrc;
        public Knowledge__kav article;
        public ID kaArticleId;
        public List<String> listDataCategories;
        public Boolean isSaved;
        public List<SavedCollectionWrapper> listSavedCollection;

        public ResourceWrapper(
            Knowledge__kav article,
            List<String> listDataCategories
        ) {
            this.article = new Knowledge__kav(
                Id = article.Id,
                Title = article.Title,
                Summary = article.Summary,
                Resource_Type__c = article.Resource_Type__c,
                Resource_Title_URL__c = article.Resource_Title_URL__c
            );

            if (article.Resource_Title_URL__c == System.Label.knowledge_Media) {
                this.imgSrc = article.Resource_Title_URL__c;
            }

            this.kaArticleId = article.KnowledgeArticleId;
            this.listDataCategories = listDataCategories;
            this.isSaved = false;
            this.listSavedCollection = new List<SavedCollectionWrapper>();
        }
    }

    public class SavedCollectionWrapper {
        public Boolean isSaved;
        public Collection__c collection;

        public SavedCollectionWrapper(
            Boolean isSaved,
            Collection__c collection
        ) {
            this.isSaved = isSaved;
            this.collection = new Collection__c(
                Id = collection.Id,
                Name = collection.Name
            );
        }
    }

    public class TopicWrapper {
        public String imgSrc;
        public Topic topicRec;

        public TopicWrapper(Topic topic) {
            this.topicRec = topic;
        }
    }

    public static Map<String, List<ResourceWrapper>> getResourceMap(
        List<Knowledge__kav> listArticles,
        String categoryFilters
    ) {
        Set<Id> setMasterVersionIds = new Set<Id>();
        Map<Id, Id> mapContentIds = new Map<Id, Id>();
        Map<Id, BOS_ResourceCenterUtility.ResourceWrapper> mapArticles = new Map<Id, BOS_ResourceCenterUtility.ResourceWrapper>();

        for (Knowledge__kav article : listArticles) {
            //1. Get data category from masterversion id
            setMasterVersionIds.add(article.MasterVersionId);

            //2. Get image details
            if (!article.ContentDocumentLinks.isEmpty()) {
                mapContentIds.put(
                    article.ContentDocumentLinks[0].ContentDocumentId,
                    article.ContentDocumentLinks[0].LinkedEntityId
                );
            }
        }

        Map<Id, List<String>> mapVersionIdCategories = new Map<Id, List<String>>();
        for (Knowledge__DataCategorySelection category : [
            SELECT DataCategoryName, ParentId
            FROM Knowledge__DataCategorySelection
            WHERE ParentId = :setMasterVersionIds
        ]) {
            if (!mapVersionIdCategories.containsKey(category.ParentId)) {
                mapVersionIdCategories.put(
                    category.ParentId,
                    new List<String>()
                );
            }

            mapVersionIdCategories.get(category.ParentId)
                .add(category.DataCategoryName);
        }

        Map<String, String> mapCategory = BOS_ResourceCenterUtility.getMapDataCategory();
        for (Knowledge__kav article : listArticles) {
            Map<String, String> mapSelectedCategories = new Map<String, String>();

            if (mapVersionIdCategories.containsKey(article.MasterVersionId)) {
                for (
                    String category : mapVersionIdCategories.get(
                        article.MasterVersionId
                    )
                ) {
                    //Should always
                    if (mapCategory.containsKey(category)) {
                        //Should always
                        mapSelectedCategories.put(
                            category,
                            mapCategory.get(category)
                        );
                    }
                }
            }

            //5. filter based on category
            BOS_ResourceCenterUtility.ResourceWrapper wrapper = getWrapperByCategory(
                article,
                mapSelectedCategories,
                categoryFilters
            );

            if (wrapper != null) {
                mapArticles.put(wrapper.article.Id, wrapper);
            }
        }

        //6. Get images
        getResourceImages(mapContentIds, mapArticles);
        //7. Get logged in user's collection details
        if (UserInfo.getUserType() != 'Guest') {
            getUserCollections(mapArticles);
        }
        //8. ---------- FINAL WRAPPER ---------- //
        return getMapWrapper(mapArticles);
    }

    //get wrapper based on category filter
    private static ResourceWrapper getWrapperByCategory(
        Knowledge__kav article,
        Map<String, String> mapSelectedCategories,
        String categoryFilters
    ) {
        BOS_ResourceCenterUtility.ResourceWrapper wrapper;
        Boolean hasAllCategory = true;

        //for filtering
        if (String.isNotBlank(categoryFilters)) {
            List<String> listCategoryFilters = (List<String>) JSON.deserialize(
                categoryFilters,
                List<String>.class
            );

            for (String catFilter : listCategoryFilters) {
                if (!mapSelectedCategories.containsKey(catFilter)) {
                    hasAllCategory = false;
                    break;
                }
            }
        }

        if (hasAllCategory) {
            wrapper = new BOS_ResourceCenterUtility.ResourceWrapper(
                article,
                mapSelectedCategories.values()
            );
        }

        return wrapper;
    }

    public static void getResourceImages(
        Map<Id, Id> mapContentIds,
        Map<Id, ResourceWrapper> mapArticles
    ) {
        //6. Get images
        if (!mapContentIds.isEmpty()) {
            for (ContentDistribution content : [
                SELECT ContentDocumentId, ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentDocumentId IN :mapContentIds.keySet()
            ]) {
                Id articleId = mapContentIds.get(content.ContentDocumentId);

                if (mapArticles.containsKey(articleId)) {
                    mapArticles.get(articleId)
                        .imgSrc = content.ContentDownloadUrl;
                }
            }
        }
    }

    public static void getTopicImages(
        Map<Id, TopicWrapper> mapInternalTopics,
        String language
    ) {
        Map<Id, Id> mapContentIds = new Map<Id, Id>();
        language = String.isNotBlank(language)
            ? language
            : UserInfo.getLocale();

        //1. If spanish
        if (!System.Label.SSO_JIT_UserLocale.equalsIgnoreCase(language)) {
            for (TopicLocalization localeTopic : [
                SELECT ParentId, Value
                FROM TopicLocalization
                WHERE
                    ParentId IN :mapInternalTopics.keySet()
                    AND Language = :language
                WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ]) {
                mapInternalTopics.get(localeTopic.ParentId)
                    .topicRec.Name = localeTopic.Value;
            }
        }

        //2. Get Topic - File junction
        //3. Get Images
        for (Topic_Image__c topicImage : [
            SELECT Name, Topic_Image_Source__c
            FROM Topic_Image__c
            WHERE Name IN :mapInternalTopics.keySet()
            LIMIT :BOS_Utility.getAvailableQueryLimit()
        ]) {
            if (mapInternalTopics.containsKey(topicImage.Name)) {
                mapInternalTopics.get(topicImage.Name)
                    .imgSrc = topicImage.Topic_Image_Source__c;
            }
        }
    }

    public static Map<String, List<ResourceWrapper>> getMapWrapper(
        Map<Id, ResourceWrapper> mapArticles
    ) {
        Map<String, List<ResourceWrapper>> mapResources = new Map<String, List<ResourceWrapper>>();

        for (ResourceWrapper wrapper : mapArticles.values()) {
            if (!mapResources.containsKey(wrapper.article.Resource_Type__c)) {
                mapResources.put(
                    wrapper.article.Resource_Type__c,
                    new List<ResourceWrapper>()
                );
            }

            mapResources.get(wrapper.article.Resource_Type__c).add(wrapper);
        }

        return mapResources;
    }

    public static Map<Id, ResourceWrapper> getUserCollections(
        Map<Id, ResourceWrapper> mapArticles
    ) {
        //1. Get all collections
        List<Collection__c> listCollections = getAllCollections();
        //2. Get saved articles
        Map<Id, Set<Id>> mapArticleColId = getCollectionArticles(
            mapArticles.keyset()
        );

        for (ResourceWrapper resource : mapArticles.values()) {
            //1.1. Add all collection to wrapper
            for (Collection__c collection : listCollections) {
                //2.1. Check if this is saved
                //2.2. If this is saved + in this collection
                Boolean isSaved =
                    mapArticleColId.containsKey(resource.kaArticleId) &&
                    mapArticleColId.get(resource.kaArticleId)
                        .contains(collection.Id);

                resource.listSavedCollection.add(
                    new SavedCollectionWrapper(isSaved, collection)
                );
            }
        }

        return mapArticles;
    }

    public static Map<String, String> getMapDataCategory() {
        Map<String, String> mapLevel1 = new Map<String, String>();
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

        for (
            DescribeDataCategoryGroupResult dataCategory : Schema.describeDataCategoryGroups(
                new List<String>{ System.Label.knowledge_ArticleVersion }
            )
        ) {
            //Data Category Group Name for BOS
            if (
                System.Label.ActionItem_AccountRecordType.equalsIgnoreCase(
                    dataCategory.getName()
                )
            ) {
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(dataCategory.getSobject());
                p.setDataCategoryGroupName(dataCategory.getName());

                pairs.add(p);
            }
        }

        for (
            DescribeDataCategoryGroupStructureResult dataCategory : Schema.describeDataCategoryGroupStructures(
                pairs,
                false
            )
        ) {
            // Get the top-level categories | Level 1 = Business
            for (DataCategory topCategory : dataCategory.getTopCategories()) {
                //Level 2
                for (DataCategory l2 : topCategory.getChildCategories()) {
                    mapLevel1.put(l2.getName(), l2.getLabel());
                }
            }
        }

        return mapLevel1;
    }

    public static Id getContactId() {
        return [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()]
            .get(0)
            .ContactId;
    }

    public static List<Collection__c> getAllCollections() {
        return [
            SELECT Id, Name, Contact__c
            FROM Collection__c
            WHERE Contact__c = :getContactId() AND isDeleted = FALSE
            ORDER BY CreatedDate DESC
        ];
    }

    private static Map<Id, Set<Id>> getCollectionArticles(
        Set<Id> setArticleIds
    ) {
        Map<Id, Set<Id>> mapKnowIdColId = new Map<Id, Set<Id>>();

        for (Collection_Folder__c detail : [
            SELECT Knowledge__c, Knowledge__r.KnowledgeArticleId, Collection__c
            FROM Collection_Folder__c
            WHERE Collection__r.Contact__c = :getContactId()
            ORDER BY CreatedDate DESC
            LIMIT :BOS_Utility.getAvailableQueryLimit()
        ]) {
            if (
                !mapKnowIdColId.containsKey(
                    detail.Knowledge__r.KnowledgeArticleId
                )
            ) {
                mapKnowIdColId.put(
                    detail.Knowledge__r.KnowledgeArticleId,
                    new Set<Id>()
                );
            }

            mapKnowIdColId.get(detail.Knowledge__r.KnowledgeArticleId)
                .add(detail.Collection__c);
        }

        return mapKnowIdColId;
    }

    public static Id getCommunityId() {
        return [
            SELECT Id
            FROM Network
            WHERE Name = :System.Label.ActionItem_AccountRecordType
        ]
        .Id;
    }
}