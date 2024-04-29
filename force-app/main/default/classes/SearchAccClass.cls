public with sharing class SearchAccClass {
    @AuraEnabled(cacheable=true)
    public static list<Account> getAllAccountDetails(String accName){

        return [SELECT id, Name FROM Account WHERE Name LIKE: accName];
    }
}