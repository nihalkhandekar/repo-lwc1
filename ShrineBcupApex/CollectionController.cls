/*********************************************************************************************
 * NAME:  CollectionController
 * DESCRIPTION: CTBOS-6435 | Resource Center - Collections
 *
 * @AUTHOR: Shreya Bordia
 * @DATE: 12/11/2020 
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Shreya Bordia                     12/11/2020                         CTBOS-6435 | Resource Center - Collections
*********************************************************************************************/
public without sharing class CollectionController {
    /** -------------------- COLLECTION -------------------- */
    //CREATE
    @AuraEnabled
    public static String createCollection(String collectionName) {
        Map<Id, BOS_ResourceCenterUtility.CollectionWrapper> mapCollections = getCollections();
        collectionName = String.isBlank(collectionName)
            ? System.Label.collection_DefaultCollection
            : collectionName.trim();
        
        try {
            if(Schema.SObjectType.Collection__c.isCreateable()) {
                Collection__c collection = new Collection__c(
                    Name = collectionName,
                    Contact__c = BOS_ResourceCenterUtility.getContactId() //If no other collection exists
                );
                insert collection;

                mapCollections.put(collection.Id, new BOS_ResourceCenterUtility.CollectionWrapper(collection));
            }
        } catch(Exception e){
            BOS_Utility.handleException(e);
        }
        
         return JSON.serialize(mapCollections.values());
    }

    //READ
    @AuraEnabled
    public static String getAllCollections() {
        return JSON.serialize(getCollections().values());
    }

    //UPDATE | Only ollection name
    @AuraEnabled
    public static String updateCollection(String collectionId, String collectionName) {
        if(String.isNotBlank(collectionId) && String.isNotBlank(collectionName)) {
            collectionName = String.isBlank(collectionName)
                ? System.Label.collection_DefaultCollection
                : collectionName.trim();
            
            if(Schema.SObjectType.Collection__c.isUpdateable()) {
                update new Collection__c(
                    Id = collectionId,
                    Name = collectionName
                );    
            }
        }

        return collectionName;
    }

    //DELETE
    @AuraEnabled
    public static String deleteCollection(String collectionId) {
        try {
            if(String.isNotBlank(collectionId) && Schema.SObjectType.Collection__c.isDeletable()) {
                delete new Collection__c(
                    Id = collectionId
                );
            }
        } catch(Exception e){
            BOS_Utility.handleException(e);
        }

        return JSON.serialize(getCollections().values());
    }

    /** -------------------- KNOWLEDGE ARTICLE -------------------- */
    //CREATE | ADD TO MULTIPLE COLLECTIONS
    @AuraEnabled
    public static Boolean addResource(String collectionIds, String articleIds) {
        Boolean isAdded = false;
        List<Collection_Folder__c> listNewFolders = new List<Collection_Folder__c>();
        Map<Id, Set<Id>> mapColIdKai = new Map<Id, Set<Id>>();
        
        if(String.isNotBlank(collectionIds) && String.isNotBlank(articleIds)) {
            List<String> listCollections = (List<String>) JSON.deserialize(collectionIds, List<String>.class);

            if(Schema.SObjectType.Knowledge__kav.isAccessible()) {
                List<Knowledge__kav> listArticles = [
                    SELECT KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Id = :articleIds
                ];

                if(!listArticles.isEmpty()) {
                    Id kai = listArticles.get(0).KnowledgeArticleId;
					for(Collection_Folder__c detail : [
                        SELECT Collection__c, Knowledge__r.KnowledgeArticleId
                        FROM Collection_Folder__c
                        WHERE Collection__c IN :listCollections
                            AND Knowledge__r.KnowledgeArticleId = :kai
                    ]) {
                        if(!mapColIdKai.containsKey(detail.Collection__c)) {
                            mapColIdKai.put(detail.Collection__c, new Set<Id>());
                        }

                        mapColIdKai.get(detail.Collection__c).add(detail.Knowledge__r.KnowledgeArticleId);
                    }

                    for(String collection :listCollections) {
                        if(!mapColIdKai.containsKey(collection) || !mapColIdKai.get(collection).contains(kai)) {
                            listNewFolders.add(new Collection_Folder__c(
                                Collection__c = collection,
                                Knowledge__c = articleIds
                            ));
                        }
                    }

                    if(!listNewFolders.isEmpty()) {
                        insert listNewFolders;
                        isAdded = true;
                    }
                }   
            }
        }

        return isAdded;
    }

    //READ | list knowledge articles for this collection
    /**
     * Language param is not required for logged in user
     */
    @AuraEnabled
    public static String getCollectionResources(String collectionId, String language) {
        Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>> mapResources = new Map<String, List<BOS_ResourceCenterUtility.ResourceWrapper>>();
        Set<Id> setArticleIds = new Set<Id>();

        //1. Get KnowArticleId from collection
        if(String.isNotBlank(collectionId) && Schema.SObjectType.Collection_Folder__c.isAccessible()) {
            for(Collection_Folder__c detail :[
                SELECT Knowledge__r.KnowledgeArticleId
                FROM Collection_Folder__c
                WHERE Collection__c = :collectionId
                ORDER BY CreatedDate DESC
            ]) {
                setArticleIds.add(detail.Knowledge__r.KnowledgeArticleId);
            }

            //2. Get kav details
            if(Schema.SObjectType.Knowledge__kav.isAccessible()) {
                mapResources = BOS_ResourceCenterUtility.getResourceMap([
                    SELECT Id, Title, Summary, Resource_Type__c, Resource_Title_URL__c, KnowledgeArticleId, MasterVersionId,
                        (
                            SELECT LinkedEntityId, ContentDocumentId
                            FROM ContentDocumentLinks LIMIT :BOS_Utility.getAvailableQueryLimit() 
                        )
                    FROM Knowledge__kav
                    WHERE KnowledgeArticleId IN :setArticleIds
                        AND Resource_Type__c != null
                        AND PublishStatus = :System.Label.knowledge_PublishStatus
                        AND Language = :UserInfo.getLocale()
                    LIMIT :BOS_Utility.getAvailableQueryLimit()
                ], null);
            }
        }

        return JSON.serialize(mapResources);
    }

    //UPDATE | NA

    //DELETE | remove all old/new versions of this KAI
    @AuraEnabled
    public static Boolean removeResource(String collectionIds, String articleIds,String devicetype) {
        Boolean isDeleted = false;
        List<Collection_Folder__c> listToDelete = new List<Collection_Folder__c>();
List<Analytics_Event__c> allEvents = new List<Analytics_Event__c>();
        if(String.isNotBlank(collectionIds) && String.isNotBlank(articleIds)) { 
            Set<Id> setArticleIds = new Set<Id>();
            List<String> listCollections = (List<String>)JSON.deserialize(collectionIds, List<String>.class);
         
                List<Knowledge__kav> listArticles = [
                    SELECT KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Id = :articleIds
                ]; 

                if(!listArticles.isEmpty() && Schema.SObjectType.Collection_Folder__c.isAccessible()) {
                    Id kai = listArticles.get(0).KnowledgeArticleId;
                
                    for(Collection_Folder__c detail :[
                        SELECT Knowledge__r.KnowledgeArticleId,id,name,Collection__r.name,Collection__r.Contact__c,Collection__r.Contact__r.AccountID,CreatedDate, Knowledge__r.Resource_Title_URL__c, Knowledge__r.Title
                        FROM Collection_Folder__c
                        WHERE Collection__c IN :listCollections
                        //Doesn't work with: AND Knowledge__r.KnowledgeArticleId = :kai
                        LIMIT :BOS_Utility.getAvailableQueryLimit()
                    ]) {
                        if(detail.Knowledge__r.KnowledgeArticleId == kai) {
                            listToDelete.add(detail);

                             Analytics_Event__c event=new Analytics_Event__c (
                                Contact__c = detail.Collection__r.Contact__c,
                                Section__c= detail.Knowledge__r.Title,
                                Subsection__c= detail.Collection__r.name,
                                Response__c = detail.id,
                                Community_Page_Name__c ='Resource Center Landing',
                                Event_Type__c = 'Delete Resource',
                                External_Link__c = detail.Knowledge__r.Resource_Title_URL__c,
                                Link_Name__c = detail.Knowledge__r.KnowledgeArticleId,
                                Event_Start_Time__c = detail.CreatedDate,
                                Event_Stop_Time__c = System.now(),
                                
                                Device_Type__c = devicetype
                             );
                             allEvents.add(event);

                        }
                        setArticleIds.add(detail.Knowledge__r.KnowledgeArticleId);
                    }
                    if(!allEvents.isEmpty()){
                        insert allEvents;
                    }
                    if(!listToDelete.isEmpty()) {
                        delete listToDelete;
                        isDeleted = true;
                    }
                }   
        }

        return isDeleted;
    }

    /** -------------- PRIVATE -------------- */
    private static Map<Id, BOS_ResourceCenterUtility.CollectionWrapper> getCollections() {
        Map<Id, BOS_ResourceCenterUtility.CollectionWrapper> mapCollections = new Map<Id, BOS_ResourceCenterUtility.CollectionWrapper>();
        
        if(Schema.SObjectType.Collection__c.isAccessible()) {
            for(Collection__c collection :BOS_ResourceCenterUtility.getAllCollections()) {
                mapCollections.put(collection.Id, new BOS_ResourceCenterUtility.CollectionWrapper(collection));
            } 

            if(Schema.SObjectType.Collection_Folder__c.isAccessible()) {
                for(Collection_Folder__c detail :[
                    SELECT Id, Collection__c, Knowledge__c
                    FROM Collection_Folder__c
                    WHERE Collection__c IN :mapCollections.keySet()
                ]) {
                    mapCollections.get(detail.Collection__c).folders.add(detail);
                }
            }
        }

        return mapCollections;
    }
}