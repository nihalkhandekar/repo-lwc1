public with sharing class ExtraditionPublicOfficialController {
    @AuraEnabled
    public static Map<String, Object> fetchPublicOfficialData(Id recordId) {

    if (recordId == null) {
        throw new AuraHandledException('Record ID cannot be null');
    }
        
        List<Contact > records = [
            SELECT Id,Prefix__c, FirstName, MiddleName, LastName, Suffix__c, Start_Term__c, End_Term__c, Position__c, GA__c,
            Indefinite_Term__c , Judicial_District__c, Seal_Stramp_of__c,  
            Notes__c, SignedBy__c,letterType__c, Esquire__c, Wet_Signature__c  FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

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