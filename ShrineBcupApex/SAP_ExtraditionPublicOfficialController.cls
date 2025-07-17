public with sharing class SAP_ExtraditionPublicOfficialController {
    @AuraEnabled
    public static Map<String, Object> fetchPublicOfficialData(Id recordId) {

    if (recordId == null) {
        throw new AuraHandledException('Record ID cannot be null');
    }
        
        List<Contact > records = [
            SELECT Id,SAP_Prefix__c, FirstName, MiddleName, LastName, SAP_Suffix__c, SAP_Start_Term__c, SAP_End_Term__c, SAP_Position__c, SAP_GA__c,
            SAP_Indefinite_Term__c , SAP_Judicial_District__c, SAP_Seal_Stramp_of__c,  
            SAP_Notes__c, SignedBy__c,SAP_letterType__c, SAP_Esquire__c, SAP_Wet_Signature__c  FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        Map<String, Object> result = new Map<String, Object>();
        system.debug('------Apex going data--->'+result);
        system.debug('------id going data--->'+recordId);
        result.put('records', records);
        return result;
    }

    @AuraEnabled
    public static Id updatePublicOfficialData(Contact newRecord) {
    Id officialRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Extradition_Official').getRecordTypeId();
	system.debug('--newRecord--'+newRecord);
        try {

        if (newRecord == null) {
        throw new AuraHandledException('Record cannot be null'); // Throw an exception if newRecord is null
    }


            if (newRecord.Id == null) {
            newRecord.RecordTypeId = officialRecordTypeId;
            system.debug('Record is being created, setting RecordTypeId to Official.');
        }
        Database.upsert(newRecord, false, AccessLevel.USER_MODE);
    }   catch (DmlException e) {
                Throw new AuraHandledException(e.getMessage());

                // Process exception here
            }
            system.debug('success'+newRecord.id);
            return newRecord.id;
    }
   

}