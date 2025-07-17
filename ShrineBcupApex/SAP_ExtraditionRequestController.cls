public class SAP_ExtraditionRequestController {

    public class AKAEntry {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String akalastName { get; set; }
        @AuraEnabled
        public String akamiddleInitial { get; set; }
        @AuraEnabled
        public String akafirstName { get; set; }
        @AuraEnabled
        public String akasuffix { get; set; }
        @AuraEnabled
        public Boolean akaesq { get; set; }
    }
    
    @AuraEnabled
    public static Map<String, string> getDetailsforExtradictionReceiptPdf(Id extradictionRequestId){
        
        IndividualApplication requestData = [SELECT Id, SAP_Attorney_Inspector__c,
                                             SAP_Office__c, SAP_Address_Line_1__c, SAP_City__c, SAP_State__c, SAP_Zip_Code__c, SAP_Country__c,
                                             SAP_Last_Name__c, SAP_Middle_Name__c, SAP_First_Name__c, SAP_Suffix__c, SAP_Extradiction_PC__c, 
                                             SAP_Extradiction_Auth__c, SAP_Notes_on_Receipt__c, RecordTypeId 
                                             ,(SELECT Id, Name, Middle_Name__c, First_Name__c, Suffix__c FROM Persons_AKA__r) 
                                             FROM IndividualApplication
                                             WHERE Id = :extradictionRequestId
                                             WITH SECURITY_ENFORCED
                                             LIMIT 1];
        
        Map<String, String> recipientDetails = new Map<String, String>();
        
        String personSoughtName = (requestData.SAP_Suffix__c != null ? requestData.SAP_Suffix__c + ' ' : '') + 
                               (requestData.SAP_First_Name__c != null ? requestData.SAP_First_Name__c + ' ' : '') + 
                               (requestData.SAP_Middle_Name__c != null ? requestData.SAP_Middle_Name__c + ' ' : '') + 
                               (requestData.SAP_Last_Name__c != null ? requestData.SAP_Last_Name__c : '');
    
        recipientDetails.put('personSoughtName', personSoughtName.trim());
        
        recipientDetails.put('attorenyInspectorName', requestData.SAP_Attorney_Inspector__c != null ? requestData.SAP_Attorney_Inspector__c : '');
        recipientDetails.put('attorenyInspectorOffice', requestData.SAP_Office__c != null ? requestData.SAP_Office__c : '');
    
        recipientDetails.put('attorenyInspectorStreet', requestData.SAP_Address_Line_1__c != null ? requestData.SAP_Address_Line_1__c : '');
        recipientDetails.put('attorenyInspectorCity', requestData.SAP_City__c != null ? requestData.SAP_City__c : '');
        recipientDetails.put('attorenyInspectorState', requestData.SAP_State__c != null ? requestData.SAP_State__c : '');
        recipientDetails.put('attorenyInspectorPostalCode', requestData.SAP_Zip_Code__c != null ? requestData.SAP_Zip_Code__c : '');
    
        recipientDetails.put('PlainPC', requestData.SAP_Extradiction_PC__c != null ? String.valueOf(requestData.SAP_Extradiction_PC__c) : '');
        recipientDetails.put('Authentication', requestData.SAP_Extradiction_Auth__c != null ? String.valueOf(requestData.SAP_Extradiction_Auth__c) : '');

        
        // Handle multiple AKA persons
        List<String> akaPersonNames = new List<String>();
    
        if (requestData.Persons_AKA__r != null && !requestData.Persons_AKA__r.isEmpty()) {
            for (Person_AKA__c akaPerson : requestData.Persons_AKA__r) {
                String akaName = (akaPerson.Suffix__c != null ? akaPerson.Suffix__c + ' ' : '') + 
                                 (akaPerson.First_Name__c != null ? akaPerson.First_Name__c + ' ' : '') + 
                                 (akaPerson.Middle_Name__c != null ? akaPerson.Middle_Name__c + ' ' : '') + 
                                 (akaPerson.Name != null ? akaPerson.Name : '');
                akaPersonNames.add(akaName.trim());
            }
        }
    
        recipientDetails.put('akaPersonNames', String.join(akaPersonNames, ', '));


		return recipientDetails;
    }
    
    @AuraEnabled
    public static IndividualApplication fetchExtradictionrequestData(Id recordId) {
        IndividualApplication requestData = [SELECT Id, Received_for_filling_with_Governor_s_Act__c, SAP_Extradicted_File_Number__c, SAP_Attorney_Inspector__c,
                                             SAP_Office__c, SAP_Address_Line_1__c, SAP_Suite_Apartment_Floor__c, SAP_City__c, SAP_State__c, SAP_Zip_Code__c, SAP_Country__c, SAP_Comments_for_SOTS_use_only__c, SAP_Extradicted_From__c,
                                             SAP_Esq__c, SAP_Last_Name__c, SAP_Middle_Name__c, SAP_First_Name__c, SAP_Suffix__c, SAP_Request_Date__c, SAP_Response_Date__c, SAP_Extradiction_PC__c, 
                                             SAP_Extradiction_Auth__c, SAP_Notes_on_Receipt__c, RecordTypeId, AccountId, LicenseTypeId, SAP_Destination__c 
                                             ,(SELECT Id, Name, Middle_Name__c, First_Name__c, ESQ__c,  Suffix__c FROM Persons_AKA__r) 
                                             FROM IndividualApplication
                                             WHERE Id = :recordId
                                             WITH SECURITY_ENFORCED
                                             LIMIT 1];
    
        return requestData;
    }

    @AuraEnabled
    public static Id upsertNewRequestData(String requestDataString)
  		  {
            // Deserialize the JSON string into a map
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestDataString);

            // Extract values from the map
                Id idofrecord = (Id) requestData.get('idofrecord');
                // Date receivedForFillingDate = (Date) requestData.get('receivedForFillingDate');
                Date receivedForFillingDate = requestData.containsKey('receivedForFillingDate') && requestData.get('receivedForFillingDate') != null
                ? Date.valueOf((String) requestData.get('receivedForFillingDate'))
                : null;
                String extractedFileNumber = (String) requestData.get('extractedFileNumber');
                String attorneyInspector = (String) requestData.get('sap_AttorneyInspector');
                String office = (String) requestData.get('office');
                String location = (String) requestData.get('location');
                String address2 = (String) requestData.get('address2');
                String city = (String) requestData.get('city');
                String state = (String) requestData.get('state');
                String zipCode = (String) requestData.get('zipCode');
                String country = (String) requestData.get('country');
                String comments = (String) requestData.get('comments');
                String extradictedFrom = (String) requestData.get('extradictedFrom');
                Boolean esq = requestData.containsKey('esq') && String.valueOf(requestData.get('esq')).toLowerCase() == 'true';
                // Boolean esq = (Boolean) requestData.get('esq');
                String lastName = (String) requestData.get('lastName');
                String middleInitial = (String) requestData.get('middleInitial');
                String firstName = (String) requestData.get('firstName');
                String suffix = (String) requestData.get('suffix');
                // Date requestDate = (Date) requestData.get('requestDate');
                Date requestDate = requestData.containsKey('requestDate') && requestData.get('requestDate') != null
                ? Date.valueOf((String) requestData.get('requestDate'))
                : null;
                // Date responseDate = (Date) requestData.get('responseDate');
                Date responseDate = requestData.containsKey('responseDate') && requestData.get('responseDate') != null
                ? Date.valueOf((String) requestData.get('responseDate'))
                : null;

                Integer extradictionpc = requestData.containsKey('extradictionpc') && requestData.get('extradictionpc') != null
    ? (requestData.get('extradictionpc') instanceof Integer 
        ? (Integer) requestData.get('extradictionpc') 
        : Integer.valueOf((String) requestData.get('extradictionpc')))
    : null;

Integer extradictionAuth = requestData.containsKey('extradictionAuth') && requestData.get('extradictionAuth') != null
    ? (requestData.get('extradictionAuth') instanceof Integer 
        ? (Integer) requestData.get('extradictionAuth') 
        : Integer.valueOf((String) requestData.get('extradictionAuth')))
    : null;

                String notes = (String) requestData.get('notes');
                String destination = (String) requestData.get('destination');
              // Optionally handle akaList if it's passed as part of JSON
              List<Map<String, Object>> akaList = new List<Map<String, Object>>();
                if (requestData.containsKey('akaList') && requestData.get('akaList') != null) {
                    // Cast requestData.get('akaList') to List<Object> first
                    List<Object> tempList = (List<Object>) requestData.get('akaList');
                    
                    // Iterate through the list and cast each element to Map<String, Object>
                    for (Object obj : tempList) {
                        akaList.add((Map<String, Object>) obj);
                    }
                }

              Id recordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('State_Extraditions').getRecordTypeId();
              
                RegulatoryAuthorizationType licenseType = [select ID,name from RegulatoryAuthorizationType where Name ='Extradition License' WITH SECURITY_ENFORCED lIMIT 1];
                
        IndividualApplication newRequest = idofrecord != null 
            ? [SELECT Id FROM IndividualApplication WHERE Id = :idofrecord LIMIT 1]
            : new IndividualApplication();
 

        newRequest.Received_for_filling_with_Governor_s_Act__c = receivedForFillingDate;
        newRequest.SAP_Extradicted_File_Number__c = extractedFileNumber;
        newRequest.SAP_Attorney_Inspector__c = attorneyInspector;
        newRequest.SAP_Office__c = office;
        newRequest.SAP_Address_Line_1__c = location;
        newRequest.SAP_Suite_Apartment_Floor__c = address2;
        newRequest.SAP_City__c = city;
        newRequest.SAP_State__c = state;
        newRequest.SAP_Zip_Code__c = zipCode;
        newRequest.SAP_Country__c = country;
        newRequest.SAP_Comments_for_SOTS_use_only__c = comments;
        newRequest.SAP_Extradicted_From__c = extradictedFrom;
        newRequest.SAP_Esq__c = esq;
        newRequest.SAP_Last_Name__c = lastName;
        newRequest.SAP_Middle_Name__c = middleInitial;
        newRequest.SAP_First_Name__c = firstName;
        newRequest.SAP_Suffix__c = suffix;
        newRequest.SAP_Request_Date__c = requestDate;
        newRequest.SAP_Response_Date__c = responseDate;
        newRequest.SAP_Extradiction_PC__c = extradictionpc;
        newRequest.SAP_Extradiction_Auth__c = extradictionAuth;
        newRequest.SAP_Notes_on_Receipt__c = notes;
        newRequest.RecordTypeId = recordTypeId; 
        newRequest.LicenseTypeId = licenseType.Id; 
        newRequest.SAP_Destination__c = destination;

       try {
        Database.upsert(newRequest, false, AccessLevel.USER_MODE);
        
        if (akaList != null && !akaList.isEmpty()) {
            Map<Id, Person_AKA__c> existingAkaRecords = new Map<Id, Person_AKA__c>([
                SELECT Id, First_Name__c, Name, Middle_Name__c, Suffix__c, 	ESQ__c 
                FROM Person_AKA__c 
                WHERE Individual_Application__c = :newRequest.Id
            ]);
            
            List<Person_AKA__c> akaRecordsToUpsert = new List<Person_AKA__c>();

              // Correct loop variable type to match AKAEntry
              for (Map<String, Object> akaData : akaList) {
                // Extract AKA data from the map
        Id akaId = (Id) akaData.get('id');
        String akaFirstName = (String) akaData.get('akafirstName');
        String akaLastName = (String) akaData.get('akalastName');
        String akaMiddleInitial = (String) akaData.get('akamiddleInitial');
        String akaSuffix = (String) akaData.get('akasuffix');
        Boolean akaEsq = (Boolean) akaData.get('akaesq');

        // Check if the record exists or create a new one
        Person_AKA__c akaPerson = (akaId != null && existingAkaRecords.containsKey(akaId))
            ? existingAkaRecords.get(akaId)
            : new Person_AKA__c(Individual_Application__c = newRequest.Id);

        // Assign the fields
        akaPerson.First_Name__c = akaFirstName;
        akaPerson.Name = akaLastName;
        akaPerson.Middle_Name__c = akaMiddleInitial;
        akaPerson.Suffix__c = akaSuffix;
        akaPerson.ESQ__c = akaEsq;

        // Add to the list for upsert
        akaRecordsToUpsert.add(akaPerson);
            }
            Database.upsert(akaRecordsToUpsert, false, AccessLevel.USER_MODE);
            
            // Remove AKA records that are no longer in the list
            Set<Id> currentAkaIds = new Set<Id>();
            for (Person_AKA__c aka : akaRecordsToUpsert) {
                if (aka.Id != null) {
                    currentAkaIds.add(aka.Id);
                }
            }
            
            List<Person_AKA__c> akaRecordsToDelete = new List<Person_AKA__c>();
            for (Id existingAkaId : existingAkaRecords.keySet()) {
                if (!currentAkaIds.contains(existingAkaId)) {
                    akaRecordsToDelete.add(new Person_AKA__c(Id = existingAkaId));
                }
            }
            
            if (!akaRecordsToDelete.isEmpty()) {
                Database.delete(akaRecordsToDelete, AccessLevel.USER_MODE);
            }
        }

        return newRequest.Id;
    } catch (Exception e) {
        throw new AuraHandledException('Error processing request: ' + e.getMessage());
    }
                            
  }
}