public class ExtraditionRequestController {

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
        
        IndividualApplication requestData = [SELECT Id, Attorney_Inspector__c,
                                             Office__c, Address_Line_1__c, City__c, State__c, Zip_Code__c, Country__c,
                                             Last_Name__c, Middle_Name__c, First_Name__c, Suffix__c, Extradiction_PC__c, 
                                             Extradiction_Auth__c, Notes_on_Receipt__c, RecordTypeId 
                                             ,(SELECT Id, Name, Middle_Name__c, First_Name__c, Suffix__c FROM Persons_AKA__r) 
                                             FROM IndividualApplication
                                             WHERE Id = :extradictionRequestId
                                             WITH SECURITY_ENFORCED
                                             LIMIT 1];
        
        Map<String, String> recipientDetails = new Map<String, String>();
        
        String personSoughtName = (requestData.Suffix__c != null ? requestData.Suffix__c + ' ' : '') + 
                               (requestData.First_Name__c != null ? requestData.First_Name__c + ' ' : '') + 
                               (requestData.Middle_Name__c != null ? requestData.Middle_Name__c + ' ' : '') + 
                               (requestData.Last_Name__c != null ? requestData.Last_Name__c : '');
    
        recipientDetails.put('personSoughtName', personSoughtName.trim());
        
        recipientDetails.put('attorenyInspectorName', requestData.Attorney_Inspector__c != null ? requestData.Attorney_Inspector__c : '');
        recipientDetails.put('attorenyInspectorOffice', requestData.Office__c != null ? requestData.Office__c : '');
    
        recipientDetails.put('attorenyInspectorStreet', requestData.Address_Line_1__c != null ? requestData.Address_Line_1__c : '');
        recipientDetails.put('attorenyInspectorCity', requestData.City__c != null ? requestData.City__c : '');
        recipientDetails.put('attorenyInspectorState', requestData.State__c != null ? requestData.State__c : '');
        recipientDetails.put('attorenyInspectorPostalCode', requestData.Zip_Code__c != null ? requestData.Zip_Code__c : '');
    
        recipientDetails.put('PlainPC', requestData.Extradiction_PC__c != null ? String.valueOf(requestData.Extradiction_PC__c) : '');
        recipientDetails.put('Authentication', requestData.Extradiction_Auth__c != null ? String.valueOf(requestData.Extradiction_Auth__c) : '');

        
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
        IndividualApplication requestData = [SELECT Id, Received_for_filling_with_Governor_s_Act__c, Extradicted_File_Number__c, Attorney_Inspector__c,
                                             Office__c, Address_Line_1__c, Suite_Apartment_Floor__c, City__c, State__c, Zip_Code__c, Country__c, Comments_for_SOTS_use_only__c, Extradicted_From__c,
                                             Esq__c, Last_Name__c, Middle_Name__c, First_Name__c, Suffix__c, Request_Date__c, Response_Date__c, Extradiction_PC__c, 
                                             Extradiction_Auth__c, Notes_on_Receipt__c, RecordTypeId, AccountId, LicenseTypeId, Destination__c 
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
                String attorneyInspector = (String) requestData.get('attorneyInspector');
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
                Integer extradictionpc = (Integer) requestData.get('extradictionpc');
                Integer extradictionAuth = (Integer) requestData.get('extradictionAuth');
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
        newRequest.Extradicted_File_Number__c = extractedFileNumber;
        newRequest.Attorney_Inspector__c = attorneyInspector;
        newRequest.Office__c = office;
        newRequest.Address_Line_1__c = location;
        newRequest.Suite_Apartment_Floor__c = address2;
        newRequest.City__c = city;
        newRequest.State__c = state;
        newRequest.Zip_Code__c = zipCode;
        newRequest.Country__c = country;
        newRequest.Comments_for_SOTS_use_only__c = comments;
        newRequest.Extradicted_From__c = extradictedFrom;
        newRequest.Esq__c = esq;
        newRequest.Last_Name__c = lastName;
        newRequest.Middle_Name__c = middleInitial;
        newRequest.First_Name__c = firstName;
        newRequest.Suffix__c = suffix;
        newRequest.Request_Date__c = requestDate;
        newRequest.Response_Date__c = responseDate;
        newRequest.Extradiction_PC__c = extradictionpc;
        newRequest.Extradiction_Auth__c = extradictionAuth;
        newRequest.Notes_on_Receipt__c = notes;
        newRequest.RecordTypeId = recordTypeId; 
        newRequest.LicenseTypeId = licenseType.Id; 
        newRequest.Destination__c = destination;

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