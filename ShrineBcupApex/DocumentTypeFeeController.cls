public without sharing class DocumentTypeFeeController {
    @AuraEnabled(cacheable=true)
    public static List<DocumentTypeAndFee__mdt> getDocumentTypesAndFees() {
        return [SELECT Label, Fee__c FROM DocumentTypeAndFee__mdt  WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<Country_Hague_Mapping__mdt> getCountryHagueMappings() {
        // Fetching all custom metadata records
        return [SELECT Country__c, Hague_Status__c FROM Country_Hague_Mapping__mdt  WITH SECURITY_ENFORCED];
    }
}