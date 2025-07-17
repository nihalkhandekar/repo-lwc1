public without sharing class DocumentChecklistJsonGenerator {

    public class IdInput {
        @InvocableVariable(required=true)
        public String individualApplicationId;
    }

    public class JsonOutput {
        @InvocableVariable
        public String jsonData;
    }
    
	@InvocableMethod(label='Generate JSON from Document Checklist Items by Parent ID' description='Generates JSON data from Document Checklist Items based on the given Individual Application ID')
    public static List<JsonOutput> generateJsonFromChecklistItemsByParentId(List<IdInput> idInputs) {
        List<JsonOutput> outputList = new List<JsonOutput>();

        if (idInputs == null || idInputs.isEmpty()) {
            return outputList;
        }

        IdInput input = idInputs[0];
        String individualApplicationIdString = input.individualApplicationId;

        // Validate and convert the individualApplicationId string to an Id
        Id individualApplicationId;
        try {
            individualApplicationId = Id.valueOf(individualApplicationIdString);
        } catch (StringException e) {
            System.debug('Error: Invalid Individual Application Id provided. ' + e.getMessage());
            return outputList; // Exit the method if the Id is invalid
        }
        
        Boolean isExpedited = false;
        try {
            IndividualApplication application = [
                SELECT Expedited__c
                FROM IndividualApplication
                WHERE Id = :individualApplicationId  WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            isExpedited = application.Expedited__c;
        } catch (Exception e) {
            System.debug('Error: Unable to retrieve Individual Application. ' + e.getMessage());
            return outputList;
        }

        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, Name, country__c, Fees__c, SOTS_Certified_copy_number__c, ParentRecordId,DocumentType.MasterLabel,Hague_Status__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :individualApplicationId WITH SECURITY_ENFORCED
        ];
        
       if (checklistItems == null || checklistItems.isEmpty()) {
        	return outputList;
    	}   
    List<Id> checklistItemIds = new List<Id>();
    for (DocumentChecklistItem item : checklistItems) {
        checklistItemIds.add(item.Id);
    }
    // Log the checklistItemIds being processed
    System.debug('checklistItemIds: ' + checklistItemIds);

    List<ContentDocumentLink> contentDocumentLinks = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :checklistItemIds WITH SECURITY_ENFORCED
    ];

// Log the number of contentDocumentLinks fetched
System.debug('Fetched contentDocumentLinks count: ' + contentDocumentLinks.size());

 Map<Id, Id> checklistItemIdToContentDocumentId = new Map<Id, Id>();
    for (ContentDocumentLink link : contentDocumentLinks) {
        checklistItemIdToContentDocumentId.put(link.LinkedEntityId, link.ContentDocumentId);
        System.debug('Mapping ChecklistItemId to ContentDocumentId: ' + link.LinkedEntityId + ' -> ' + link.ContentDocumentId);
    }

    // Fetch ContentVersions
    List<Id> contentDocumentIds = new List<Id>();
    for (ContentDocumentLink link : contentDocumentLinks) {
        contentDocumentIds.add(link.ContentDocumentId);
    }

    List<ContentVersion> contentVersions = new List<ContentVersion>();
    if (!contentDocumentIds.isEmpty()) {
        contentVersions = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED
        ];
    }

    // Map ContentDocumentId to Title
    Map<Id, String> contentDocumentIdToTitle = new Map<Id, String>();
    for (ContentVersion cv : contentVersions) {
        contentDocumentIdToTitle.put(cv.ContentDocumentId, cv.Title);
        System.debug('Mapping ContentDocumentId to Title: ' + cv.ContentDocumentId + ' -> ' + cv.Title);
    }

        List<DocumentChecklistItemWrapperLwc> wrappers = new List<DocumentChecklistItemWrapperLwc>();
        Integer rowId = 1; 

       for (DocumentChecklistItem item : checklistItems) {
    DocumentChecklistItemWrapperLwc wrapper = new DocumentChecklistItemWrapperLwc();
    wrapper.id = String.valueOf(item.Id);
    wrapper.type = '';
    wrapper.country = '';
    wrapper.hague = item.Hague_Status__c;
    wrapper.person = '';
    wrapper.fee = String.valueOf(item.Fees__c);
    wrapper.baseFee = isExpedited ? String.valueOf(item.Fees__c - 50) : String.valueOf(item.Fees__c);
    wrapper.expediteFee = '0.00';
    wrapper.typeOfDocument = item.DocumentType.MasterLabel;
    wrapper.destinationCountry = item.country__c;
    wrapper.personName = item.Name;
    wrapper.copyNumber = item.SOTS_Certified_copy_number__c;
    wrapper.rowId = rowId++;

    // Create the uploadedFiles list
    wrapper.uploadedFiles = new List<Map<String, String>>();

    // Fetch ContentDocumentId and Title
    Id contentDocumentId = checklistItemIdToContentDocumentId.get(item.Id);
    if (contentDocumentId != null) {
        String contentTitle = contentDocumentIdToTitle.get(contentDocumentId);

        // Add the file details to the uploadedFiles list
        Map<String, String> fileDetails = new Map<String, String>();
        fileDetails.put('filename', contentTitle != null ? contentTitle : 'No Title');
        fileDetails.put('documentId', contentDocumentId);

        wrapper.uploadedFiles.add(fileDetails);
    }

    wrappers.add(wrapper);
}
 String jsonOutput = JSON.serialize(wrappers);
        JsonOutput output = new JsonOutput();
        output.jsonData = jsonOutput;
        outputList.add(output);

        return outputList;
    }

    public class DocumentChecklistItemWrapper {
        public String id;
        public String type;
        public String country;
        public String hague;
        public String person;
        public String fee;
        public String baseFee;
        public String feeDisplay;
        public String expediteFee;
        public Boolean isExpedited;
        public String typeOfDocument;
        public String destinationCountry;
        public String personName;
        public String copyNumber;
        public String signedByName;
        public String signedStamp;
        public String signedByPosition;
        public String selectedContactID;
        public String status;
        public String autority;
        public String autorityName;
        public String authorityTitle;
        public String rejectionReason;
        public String customRejectionReason;
        public Date termStart;
        public Date termEnd;
        public List<Map<String, String>> uploadedFiles;
        public Boolean checkDocumentType;
        public String certificateNumber;
        
    }

    public class PaymentDetailsItemWraper{
        public String id;
        public String paymentType;
        public String cardType;
        public String authCode;
        public String dateOfPayment;
        public String last4Digits;
        public String ckNumber;
        public String paymentAmount;
        public String status;
        public Boolean showRemoveButton;
        public Boolean readOnlyMode;
    }
    
    @AuraEnabled(cacheable=true)
    public static String generateJsonFromChecklistItemsByParentIdLwc(String individualApplicationId) {
        List<DocumentChecklistItemWrapper> wrappers = new List<DocumentChecklistItemWrapper>(); 
        List<PaymentDetailsItemWraper> paymentDetailsList = new List<PaymentDetailsItemWraper>();
        Map<String, Object> result = new Map<String, Object>();
        // Map<String, Object> paymentDetails = new Map<String, Object>();
        
        Id individualApplicationIdConverted;
        try {
            individualApplicationIdConverted = Id.valueOf(individualApplicationId);
        } catch (StringException e) {
            System.debug('Error: Invalid Individual Application Id provided. ' + e.getMessage());
            return null; // Exit the method if the Id is invalid
        }

        Boolean isExpedited = false;
    
        // Retrieve IndividualApplication to get Sequence_Number__c
        IndividualApplication individualApplication = [
            SELECT Id, Sequence_Number__c, Expedited__c
            FROM IndividualApplication
            WHERE Id = :individualApplicationIdConverted  WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        isExpedited =individualApplication.Expedited__c;
    
        // Retrieve DocumentChecklistItems
        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, Name, country__c, Fees__c, ParentRecordId, DocumentType.MasterLabel, Signed_By__r.Id, Signed_By__r.Seal_Stramp_of__c, Signed_By__r.Name, Signed_By__r.Position__c, Status, RejectionReason__c, Rejection_Reason__c, Hague_Status__c,
            Signing_Authority__c, Signing_Authority__r.Name, Signing_Authority__r.Staff_Title__c, Start_Term__c, End_Term__c, SOTS_Certified_copy_number__c,Certificate_Number__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :individualApplicationIdConverted WITH SECURITY_ENFORCED
        ];
    
        // Retrieve RegulatoryTrxnFee records
        List<RegulatoryTrxnFee> trxnFees = [
            SELECT Id, Payment_Type__c, amount__c,TotalFeeAmount,Status, Card_Number__c, CK_Number__c, Card_Type__c, Auth_Code__c, Brand__c, CreatedDate, ParentRecordId
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :individualApplicationIdConverted WITH SECURITY_ENFORCED
        ];

        for(RegulatoryTrxnFee fee : trxnFees) {
            PaymentDetailsItemWraper paymentDetailsItemWraper = new PaymentDetailsItemWraper();
            paymentDetailsItemWraper.id = fee.Id;
            paymentDetailsItemWraper.paymentType = fee.Payment_Type__c;
            paymentDetailsItemWraper.paymentAmount = fee.TotalFeeAmount != null ? String.valueOf(fee.TotalFeeAmount) : null;
            paymentDetailsItemWraper.cardType = fee.Brand__c;
            paymentDetailsItemWraper.ckNumber = fee.CK_Number__c != null ? String.valueOf(fee.CK_Number__c) : null;
            paymentDetailsItemWraper.authCode = fee.Auth_Code__c;
            paymentDetailsItemWraper.dateOfPayment = fee.CreatedDate != null ? fee.CreatedDate.date().format() : null;
            paymentDetailsItemWraper.last4Digits = fee.Card_Number__c != null ? String.valueOf(fee.Card_Number__c) : null;
            paymentDetailsItemWraper.status = fee.Status;
            paymentDetailsItemWraper.showRemoveButton = false;
            paymentDetailsItemWraper.readOnlyMode = true;

            paymentDetailsList.add(paymentDetailsItemWraper);
        }

    
        // Process payment details only once
        // if (!trxnFees.isEmpty()) {
        //     RegulatoryTrxnFee fee = trxnFees[0];
        //     paymentDetails.put('paymentType', fee.Payment_Type__c);
        //     paymentDetails.put('cardType', fee.Card_Type__c);
        //     paymentDetails.put('authCode', fee.Auth_Code__c);
        //     paymentDetails.put('cardBrand', fee.Brand__c);
        //     paymentDetails.put('dateOfPayment', fee.CreatedDate != null ? fee.CreatedDate.date().format() : null);
        //     paymentDetails.put('last4Digits', fee.Card_Number__c != null ? String.valueOf(fee.Card_Number__c) : null);
        //     paymentDetails.put('paymentAmount', fee.TotalFeeAmount != null ? String.valueOf(fee.TotalFeeAmount) : null);
        // }
    
        // Process content document links for checklist items
        List<Id> checklistItemIds = new List<Id>();
        for (DocumentChecklistItem item : checklistItems) {
            checklistItemIds.add(item.Id);
        }
        
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :checklistItemIds WITH SECURITY_ENFORCED
        ];
    
        Map<Id, Id> checklistItemIdToContentDocumentId = new Map<Id, Id>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            checklistItemIdToContentDocumentId.put(link.LinkedEntityId, link.ContentDocumentId);
        }
    
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
    
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        if (!contentDocumentIds.isEmpty()) {
            contentVersions = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED
            ];
        }
    
        Map<Id, String> contentDocumentIdToTitle = new Map<Id, String>();
        for (ContentVersion cv : contentVersions) {
            contentDocumentIdToTitle.put(cv.ContentDocumentId, cv.Title);
        }
    
        // Iterate through checklist items and map to wrapper class
        for (DocumentChecklistItem item : checklistItems) {
            DocumentChecklistItemWrapper wrapper = new DocumentChecklistItemWrapper();
            wrapper.id = String.valueOf(item.Id);  
            wrapper.type = ''; 
            wrapper.country = '';  
            wrapper.hague = item.Hague_Status__c; 
            wrapper.person = '';  
            wrapper.fee = String.valueOf(item.Fees__c); 
            // wrapper.baseFee = String.valueOf(item.Fees__c); 
            wrapper.baseFee = isExpedited ? String.valueOf(item.Fees__c - 50) : String.valueOf(item.Fees__c);
            wrapper.feeDisplay = '$' + String.valueOf(item.Fees__c);
            wrapper.expediteFee = '0.00';
            wrapper.isExpedited = isExpedited;
            wrapper.typeOfDocument = item.DocumentType.MasterLabel;
            wrapper.destinationCountry = item.country__c;
            wrapper.personName = item.Name;
            wrapper.copyNumber = item.SOTS_Certified_copy_number__c;
            wrapper.signedByName = item.Signed_By__r != null ? item.Signed_By__r.Name : null;  
            wrapper.signedStamp = item.Signed_By__r != null ? item.Signed_By__r.Seal_Stramp_of__c : null;
            wrapper.signedByPosition = item.Signed_By__r != null ? item.Signed_By__r.Position__c : null;
            wrapper.selectedContactID = item.Signed_By__r != null ? item.Signed_By__r.Id : null;
            wrapper.status = item.Status;
            wrapper.autority = item.Signing_Authority__c;
            wrapper.autorityName = item.Signing_Authority__r != null ? item.Signing_Authority__r.Name : null;
            wrapper.authorityTitle = item.Signing_Authority__r !=null ? item.Signing_Authority__r.Staff_Title__c : null ;
            wrapper.rejectionReason = item.RejectionReason__c;
            wrapper.customRejectionReason = item.Rejection_Reason__c;
            wrapper.termStart = item.Start_Term__c;
            wrapper.termEnd = item.End_Term__c;
            wrapper.checkDocumentType = (item.DocumentType.MasterLabel == 'SOTS Certified Copies');
            wrapper.certificateNumber = item.Certificate_Number__c !=null ? item.Certificate_Number__c : null;
            wrapper.uploadedFiles = new List<Map<String, String>>();
    
            // Handle uploaded files for checklist item
            Id contentDocumentId = checklistItemIdToContentDocumentId.get(item.Id);
            if (contentDocumentId != null) {
                String contentTitle = contentDocumentIdToTitle.get(contentDocumentId);
    
                Map<String, String> fileDetails = new Map<String, String>();
                fileDetails.put('filename', contentTitle != null ? contentTitle : 'No Title');
                fileDetails.put('documentId', contentDocumentId);
    
                wrapper.uploadedFiles.add(fileDetails);
            }
    
            wrappers.add(wrapper);
        }
    
        // Add the Sequence_Number__c field from IndividualApplication to result map
        result.put('sequenceNumber', individualApplication.Sequence_Number__c);
        
        // Add DocumentChecklistItems and PaymentDetails to the result map
        result.put('documentChecklistItems', wrappers);
        result.put('paymentDetails', paymentDetailsList);
    
        // Convert the result to JSON
        return JSON.serialize(result);
    }
    
    



    // Wrapper class to hold the document checklist details
    public class DocumentChecklistItemWrapperLwc {
        public String id;  // Checklist Item Id (as a string for Salesforce compatibility)
        public String type; // Type of document
        public String country; // Country associated with the document
        public String hague; // Hague convention status (example field)
        public String person; // Person associated with the document
        public String fee; // Fee associated with the document
        public String baseFee; // Base fee (same as Fees__c in this case)
        public String feeDisplay; // Fee display formatted for UI (e.g., "$50.00")
        public String expediteFee; // Expedite fee (default value in this case)
        //public Boolean isExpedited; // Whether the document is expedited
        public String typeOfDocument; // Document type (e.g., "Passport")
        public String destinationCountry; // Destination country (from country__c field)
        public String personName; // Name of the person (from Name field)
        public String copyNumber;
        public List<Map<String, String>> uploadedFiles;
        public Integer rowId; 
    }

    @AuraEnabled
    public static String searchContacts(String searchKey, String position) {
        // Escape single quotes to prevent SOQL injection
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
    
       // String pos = '%' + String.escapeSingleQuotes(position) + '%';
        System.debug('Key is ==>'+ key);
        List<Contact> result;

        // Constructing the SOQL query as a string
        String query = 'SELECT Id, Name, Start_Term__c, End_Term__c, Indefinite_Term__c,Status__c,Town__c, Position__c ' +
                        'FROM Contact ' +
                        'WHERE Name LIKE :key ' +
                        'AND RecordType.DeveloperName = \'Apostille_Official\'';
        
         if(String.isNotBlank(position)){
            String escapedPosition = String.escapeSingleQuotes(position);
            query += ' AND Position__c = \'' + escapedPosition + '\'';
            System.debug('Position is ==>'+ escapedPosition);
        }

        Integer maxRows = 99; // Define your desired row limit
        query += ' LIMIT ' + maxRows;

        // Print the query for debugging purposes   
        System.debug('SOQL Query: ' + query);
        System.debug('SOQL Queries Used: ' + Limits.getQueries());
        System.debug('SOQL Queries Allowed: ' + Limits.getLimitQueries());


        List<ContactWrapper> wrappers = new List<ContactWrapper>();

        try {
            // Execute the dynamic query
            result = Database.query(query,AccessLevel.USER_MODE);

            for(Contact res : result){
                ContactWrapper wrapper = new ContactWrapper();
                wrapper.Id = String.valueOf(res.Id);
                wrapper.Name = res.Name;
                wrapper.StartTerm = formatCustomDate(res.Start_Term__c);
                wrapper.EndTerm = formatCustomDate(res.End_Term__c);
                wrapper.IndefiniteTerm = res.Indefinite_Term__c;
                wrapper.Status = res.Status__c;
                wrapper.Position = res.Position__c;
                wrapper.Town = res.Town__c;
                List<Map<String, Object>> nameHostoryRecord = InHousePublicOfficialController.processNameFieldHistory(res.Id);    // reusing code for Name History 
                List<Map<String, Object>> termHostoryRecord = InHousePublicOfficialController.processTermFieldHistory(res.Id);
                wrapper.nameHistory = nameHostoryRecord;
                System.debug('Name history for contact ' + res.Id + ': ' + wrapper.nameHistory);
               // wrapper.hasNameHistory = nameHostoryRecord.size() > 0;
                System.debug('Term history for contact ' + res.Id + ': ' + termHostoryRecord);
                wrapper.termHistory = termHostoryRecord;
                wrapper.hasTermHistory = termHostoryRecord.size() > 0;
                wrappers.add(wrapper);
            }
        } catch (Exception e) {
            System.debug('Error fetching contacts: ' + e.getMessage());
            throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
        }

        System.debug('Final contact  result is ==>> ' + result);

        System.debug('Final contact wrappers result is ==>> ' + wrappers);
        System.debug('Final contact wrappers result is ==>> ' + JSON.serialize(wrappers));
        return JSON.serialize(wrappers);
    }


    public class ContactWrapper{
        public String Id;
        public String Name;
        public String StartTerm;
        public String EndTerm;
        public Boolean IndefiniteTerm;
        public String Status;
        public String Position;
        public String Town;
        public Boolean hasTermHistory;
        public List<Map<String, Object>> nameHistory;
        public List<Map<String, Object>> termHistory;
    }

    private static String formatCustomDate(Date inputDate) {
        if (inputDate == null) return null;
        String formattedMonth = (inputDate.month() < 10) ? '0' + String.valueOf(inputDate.month()) : String.valueOf(inputDate.month());
        String formattedDay = (inputDate.day() < 10) ? '0' + String.valueOf(inputDate.day()) : String.valueOf(inputDate.day());
        return formattedMonth + '/' + formattedDay + '/' + String.valueOf(inputDate.year());
    }

   

    
}