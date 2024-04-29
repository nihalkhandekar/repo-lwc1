public class carDetailsSearch {
    @AuraEnabled(cacheable=true)
    public static list<Car_Detail__c> getAllCarDeatils () {
        return [SELECT id, Name, Type__c,Model__c,Price__c FROM Car_Detail__c LIMIT 10];
    }
}