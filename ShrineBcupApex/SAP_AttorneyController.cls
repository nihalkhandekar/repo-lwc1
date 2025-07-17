public with sharing class SAP_AttorneyController {
    @AuraEnabled
    public static Map<String, Object> fetchAttorneyData(Id recordId) {
        List<Contact> records = [
            SELECT Id, Name, Salutation, LastName, MiddleName, FirstName, Suffix, Phone,
                   MailingStreet, MailingCity, MailingState, SAP_MailingAddress2__c, MailingPostalCode, MailingCountry
            FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1
        ];

        Map<String, Object> result = new Map<String, Object>();
        system.debug('------Apex going data--->' + result);
        system.debug('------id going data--->' + recordId);
        result.put('records', records);
        return result;
    }

@AuraEnabled
public static void updateAttorneyData(Map<String, Object> data) {
    Id recordId = (Id)data.get('recordId');
    Contact recordToUpdate;

    Id recordTypeId = getRecordTypeId('Attorney_Inspector');

    if (recordId != null) {
        recordToUpdate = [
            SELECT Id, Name, Salutation, LastName, MiddleName, FirstName, Suffix, Phone,
                   MailingStreet, MailingCity, MailingState, SAP_MailingAddress2__c, MailingPostalCode, MailingCountry
            FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1
        ];
    } else {
        recordToUpdate = new Contact();
        recordToUpdate.RecordTypeId = recordTypeId;
    }

    recordToUpdate.Salutation = (String)data.get('prefix');
    recordToUpdate.FirstName = (String)data.get('firstname');
    recordToUpdate.MiddleName = (String)data.get('middlename');
    recordToUpdate.LastName = (String)data.get('lastname');
    recordToUpdate.Suffix = (String)data.get('suffix');
    recordToUpdate.Phone = (String)data.get('phone');
    recordToUpdate.MailingStreet = (String)data.get('address1');
    recordToUpdate.SAP_MailingAddress2__c = (String)data.get('address2');
    recordToUpdate.MailingCity = (String)data.get('city');
    recordToUpdate.MailingState = (String)data.get('state');
    recordToUpdate.MailingPostalCode = (String)data.get('pincode');
    recordToUpdate.MailingCountry = (String)data.get('country');

    if (recordId != null) {
        Database.update(recordToUpdate, AccessLevel.USER_MODE);
    } else {
        System.debug('### Inserting new Contact record: ' + recordToUpdate);
        Database.insert(recordToUpdate, AccessLevel.USER_MODE);
    }
}


private static Id getRecordTypeId(String recordTypeName) {
    // Query the Record Type Id based on the record type name
    List<RecordType> recordTypes = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Contact' AND DeveloperName = :recordTypeName WITH SECURITY_ENFORCED
        LIMIT 1
    ];
    return (recordTypes.size() > 0) ? recordTypes[0].Id : null;
}

}