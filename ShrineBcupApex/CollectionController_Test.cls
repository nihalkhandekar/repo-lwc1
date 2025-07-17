@isTest
public class CollectionController_Test {
    
     @testSetup
    private static void initData(){
        Contact con = new Contact(LastName= 'Test LastName');
        insert con;
        Collection__c collection = new Collection__c(Name='test' , Contact__c = con.Id );
        insert collection;
        knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',urlname='xyz');
        insert newArticle;
        topic newTopic = new topic(NetworkId = '0DB0Y000000CablWAC', name = 'test');
      	insert newTopic;
    }
    
     @isTest
    public static void createCollection_Test(){
       Test.startTest();
        String result = CollectionController.createCollection('Test collection');
        Test.stopTest();
        system.assertNotEquals(Null, result); 
    }
    
     @isTest
    public static void getAllCollections_Test(){
       Test.startTest();
        String result = CollectionController.getAllCollections();
        Test.stopTest();
        system.assertNotEquals(Null, result); 
    }
    
    
     @isTest
    public static void updateCollection_Test(){
        List<Collection__c> collectionlist = [Select Id, Name From Collection__c limit 1];
       Test.startTest();
        
        String result = CollectionController.updateCollection(collectionlist[0].Id , collectionlist[0].Name);
        String deletecoll = CollectionController.deleteCollection(collectionlist[0].Id);
        Test.stopTest();
        system.assertNotEquals(Null, result); 
    }
    
     @isTest
    public static void addResource_Test(){
        List<Collection__c> collectionlist = [Select Id, Name From Collection__c limit 1];
        list<String> collectIds = new list<String>{collectionlist[0].Id} ;
        List<Knowledge__kav> knowledge = [Select Id From Knowledge__kav limit 1];
        String knowlId = String.valueOf(knowledge[0].Id);
       Test.startTest();
        
        
        
        Boolean result = CollectionController.addResource(JSON.serialize(collectIds) ,knowlId);
        String getlang = CollectionController.getCollectionResources(JSON.serialize(collectIds) , 'EN_us');
        Boolean removeresource = CollectionController.removeResource(JSON.serialize(collectIds) , knowlId,'');
        //String getcoll = = CollectionController.getCollections();
       
        Test.stopTest();
        system.assertNotEquals(Null, result); 
    }

}