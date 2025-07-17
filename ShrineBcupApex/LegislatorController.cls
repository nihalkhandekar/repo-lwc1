public with sharing class LegislatorController {
    @AuraEnabled
    public static Map<String, Object> fetchLegislativeData(Id recordId) {
        List<Contact> records = [
            SELECT Id, Name, prefix_values__c, LastName, MiddleName, FirstName, Suffix_values__c, Legislator_Title__c, Phone, Email, 
                   MailingStreet, MailingCity, MailingState, MailingAddress2__c, MailingPostalCode, MailingCountry, 
                   Party__c, Fax, Extension__c, DistrictID__c, Personal_Name__c, Preffered_address__c,
                   Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_City__c, 
                   Residence_State__c, Residence_Country__c, Residence_Zip_Code__c,
                   Residential_Phone__c,  Residential_Extension__c,Residential_Fax__c,
                   OtherCity, OtherState, OtherStreet, OtherCountry, OtherPostalCode, OtherPhone, 
                   Other_Address2__c, Other_Extension__c, Other_Fax__c,LastModifiedDate
            FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Map<String, Object> result = new Map<String, Object>();
        system.debug('------Apex going data--->' + result);
        system.debug('------id going data--->' + recordId);
        result.put('records', records);
        return result;
    }

    @AuraEnabled
    public static void updateLegislativeData(Map<String, Object> data) {
        // Fetch the Contact record to update
        Id recordId = (Id)data.get('recordId');  // Cast to Id explicitly
        system.debug('record id coming from js is '+recordId);

        Contact recordToUpdate = [
            SELECT  Id, Name, prefix_values__c, LastName, MiddleName, FirstName, Suffix_values__c, Legislator_Title__c, Phone, Email, 
                   MailingStreet, MailingCity, MailingState, MailingAddress2__c, MailingPostalCode, MailingCountry, 
                   Party__c, Fax, Extension__c, DistrictID__c, DistrictType__c, Personal_Name__c, Preffered_address__c,
                   Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_City__c, 
                   Residence_State__c, Residence_Country__c, Residence_Zip_Code__c,
                   Residential_Phone__c,  Residential_Extension__c,Residential_Fax__c,
                   OtherCity, OtherState, OtherStreet, OtherCountry, OtherPostalCode, OtherPhone, 
                   Other_Address2__c, Other_Extension__c, Other_Fax__c,LastModifiedDate
            FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED
            LIMIT 1
        ];    

            // Map the fields
    recordToUpdate.prefix_values__c = (String)data.get('prefix');
    recordToUpdate.FirstName = (String)data.get('firstname');
    recordToUpdate.MiddleName = (String)data.get('middlename');
    recordToUpdate.LastName = (String)data.get('lastname');
    recordToUpdate.Suffix_values__c = (String)data.get('suffix');
    recordToUpdate.Legislator_Title__c = (String)data.get('title');
    recordToUpdate.Email = (String)data.get('email');
    recordToUpdate.Party__c = (String)data.get('party');
    recordToUpdate.MailingStreet = (String)data.get('address1');
    recordToUpdate.MailingAddress2__c = (String)data.get('address2');
    recordToUpdate.MailingCity = (String)data.get('city');
    recordToUpdate.MailingState = (String)data.get('state');
    recordToUpdate.MailingPostalCode = (String)data.get('pincode'); 
    recordToUpdate.MailingCountry = (String)data.get('country');
    recordToUpdate.Phone = (String)data.get('telephone');
    recordToUpdate.Fax = (String)data.get('fax');
    recordToUpdate.Extension__c = (String)data.get('extension');
    recordToUpdate.DistrictID__c = (String)data.get('judicialdistrict');
    recordToUpdate.DistrictType__c = (String)data.get('districtName');
    recordToUpdate.Personal_Name__c = (String)data.get('personalname');
    recordToUpdate.Preffered_address__c = (String)data.get('preferredaddress');

    recordToUpdate.Residence_Street_Address_1__c = (String)data.get('resaddress1');
    recordToUpdate.Residence_Street_Address_2__c = (String)data.get('resaddress2');
    recordToUpdate.Residence_City__c = (String)data.get('rescity');
    recordToUpdate.Residence_State__c = (String)data.get('resstate');
    recordToUpdate.Residence_Zip_Code__c = (String)data.get('respincode');
    recordToUpdate.Residence_Country__c = (String)data.get('rescountry');
    recordToUpdate.Residential_Phone__c = (String)data.get('resphone');
    recordToUpdate.Residential_Fax__c = (String)data.get('resfax');
    recordToUpdate.Residential_Extension__c = (String)data.get('resextension');

    recordToUpdate.OtherStreet = (String)data.get('otheraddress1');
    recordToUpdate.Other_Address2__c = (String)data.get('otheraddress2');
    recordToUpdate.OtherCity = (String)data.get('othercity');
    recordToUpdate.OtherState = (String)data.get('otherstate');
    recordToUpdate.OtherPostalCode = (String)data.get('otherpincode');
    recordToUpdate.OtherCountry = (String)data.get('othercountry');
    recordToUpdate.OtherPhone = (String)data.get('otherphone');
    recordToUpdate.Other_Fax__c = (String)data.get('otherfax');
    recordToUpdate.Other_Extension__c = (String)data.get('otherextension');

        // Update the record in the database
        //update recordToUpdate;
        Database.update(recordToUpdate, false, AccessLevel.USER_MODE);

    }
}