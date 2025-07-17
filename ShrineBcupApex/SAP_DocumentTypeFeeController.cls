public without sharing class SAP_DocumentTypeFeeController {
    @AuraEnabled(cacheable=true)
    public static List<SAP_DocumentTypeAndFee__mdt> getDocumentTypesAndFees() {
        return [SELECT Label, SAP_Fee__c FROM SAP_DocumentTypeAndFee__mdt  WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<SAP_Country_Hague_Mapping__mdt> getCountryHagueMappings() {
        return [SELECT SAP_Country__c, SAP_Hague_Status__c FROM SAP_Country_Hague_Mapping__mdt  WITH SECURITY_ENFORCED];
    }
}