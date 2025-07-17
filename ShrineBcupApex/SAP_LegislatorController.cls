public with sharing class SAP_LegislatorController {
    @AuraEnabled
    public static Map<String, Object> fetchLegislativeData(Id recordId) {
        List<Contact> records = [
            SELECT Id, Name, SAP_prefix_values__c, LastName, MiddleName, FirstName, SAP_Suffix_values__c, SAP_Legislator_Title__c, Phone, Email, 
                   MailingStreet, MailingCity, MailingState, SAP_MailingAddress2__c, MailingPostalCode, MailingCountry, 
                   SAP_Party__c, Fax, SAP_Extension__c, SAP_DistrictID__c, SAP_Personal_Name__c, SAP_Preffered_address__c,
                   SAP_Residence_Street_Address_1__c, SAP_Residence_Street_Address_2__c, SAP_Residence_City__c, 
                   SAP_Residence_State__c, SAP_Residence_Country__c, SAP_Residence_Zip_Code__c,
                   SAP_Residential_Phone__c,  SAP_Residential_Extension__c,SAP_Residential_Fax__c,
                   OtherCity, OtherState, OtherStreet, OtherCountry, OtherPostalCode, OtherPhone, 
                   SAP_Other_Address2__c, SAP_Other_Extension__c, SAP_Other_Fax__c,LastModifiedDate
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
            SELECT  Id, Name, SAP_prefix_values__c, LastName, MiddleName, FirstName, SAP_Suffix_values__c, SAP_Legislator_Title__c, Phone, Email, 
                   MailingStreet, MailingCity, MailingState, SAP_MailingAddress2__c, MailingPostalCode, MailingCountry, 
                   SAP_Party__c, Fax, SAP_Extension__c, SAP_DistrictID__c, SAP_DistrictType__c, SAP_Personal_Name__c, SAP_Preffered_address__c,
                   SAP_Residence_Street_Address_1__c, SAP_Residence_Street_Address_2__c, SAP_Residence_City__c, 
                   SAP_Residence_State__c, SAP_Residence_Country__c, SAP_Residence_Zip_Code__c,
                   SAP_Residential_Phone__c,  SAP_Residential_Extension__c,SAP_Residential_Fax__c,
                   OtherCity, OtherState, OtherStreet, OtherCountry, OtherPostalCode, OtherPhone, 
                   SAP_Other_Address2__c, SAP_Other_Extension__c, SAP_Other_Fax__c,LastModifiedDate
            FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED
            LIMIT 1
        ];    

            // Map the fields
    recordToUpdate.SAP_prefix_values__c = (String)data.get('prefix');
    recordToUpdate.FirstName = (String)data.get('firstname');
    recordToUpdate.MiddleName = (String)data.get('middlename');
    recordToUpdate.LastName = (String)data.get('lastname');
    recordToUpdate.SAP_Suffix_values__c = (String)data.get('suffix');
    recordToUpdate.SAP_Legislator_Title__c = (String)data.get('title');
    recordToUpdate.Email = (String)data.get('email');
    recordToUpdate.SAP_Party__c = (String)data.get('party');
    recordToUpdate.MailingStreet = (String)data.get('address1');
    recordToUpdate.SAP_MailingAddress2__c = (String)data.get('address2');
    recordToUpdate.MailingCity = (String)data.get('city');
    recordToUpdate.MailingState = (String)data.get('state');
    recordToUpdate.MailingPostalCode = (String)data.get('pincode'); 
    recordToUpdate.MailingCountry = (String)data.get('country');
    recordToUpdate.Phone = (String)data.get('telephone');
    recordToUpdate.Fax = (String)data.get('fax');
    recordToUpdate.SAP_Extension__c = (String)data.get('extension');
    recordToUpdate.SAP_DistrictID__c = (String)data.get('judicialdistrict');
    recordToUpdate.SAP_DistrictType__c = (String)data.get('districtName');
    recordToUpdate.SAP_Personal_Name__c = (String)data.get('personalname');
    recordToUpdate.SAP_Preffered_address__c = (String)data.get('preferredaddress');

    recordToUpdate.SAP_Residence_Street_Address_1__c = (String)data.get('resaddress1');
    recordToUpdate.SAP_Residence_Street_Address_2__c = (String)data.get('resaddress2');
    recordToUpdate.SAP_Residence_City__c = (String)data.get('rescity');
    recordToUpdate.SAP_Residence_State__c = (String)data.get('resstate');
    recordToUpdate.SAP_Residence_Zip_Code__c = (String)data.get('respincode');
    recordToUpdate.SAP_Residence_Country__c = (String)data.get('rescountry');
    recordToUpdate.SAP_Residential_Phone__c = (String)data.get('resphone');
    recordToUpdate.SAP_Residential_Fax__c = (String)data.get('resfax');
    recordToUpdate.SAP_Residential_Extension__c = (String)data.get('resextension');

    recordToUpdate.OtherStreet = (String)data.get('otheraddress1');
    recordToUpdate.SAP_Other_Address2__c = (String)data.get('otheraddress2');
    recordToUpdate.OtherCity = (String)data.get('othercity');
    recordToUpdate.OtherState = (String)data.get('otherstate');
    recordToUpdate.OtherPostalCode = (String)data.get('otherpincode');
    recordToUpdate.OtherCountry = (String)data.get('othercountry');
    recordToUpdate.OtherPhone = (String)data.get('otherphone');
    recordToUpdate.SAP_Other_Fax__c = (String)data.get('otherfax');
    recordToUpdate.SAP_Other_Extension__c = (String)data.get('otherextension');

        // Update the record in the database
        //update recordToUpdate;
        Database.update(recordToUpdate, false, AccessLevel.USER_MODE);

    }
}