public without sharing class getCustomMetaDataPaymentField {
	 @AuraEnabled(cacheable=true)
    public static List<Application_Switch__mdt> getPaymentGateways() {
        return [SELECT Id, Payment_Gateway__c FROM Application_Switch__mdt WITH SECURITY_ENFORCED];
    }
}