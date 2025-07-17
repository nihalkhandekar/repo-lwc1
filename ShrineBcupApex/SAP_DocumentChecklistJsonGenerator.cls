/**
 * @description Controller class for generating JSON data from Document Checklist Items.
 */
public without sharing class SAP_DocumentChecklistJsonGenerator {
	/**
	 * @description Represents the input containing an Individual Application ID.
	 */
	public class IdInput {
		@InvocableVariable(required=true)
		public String individualApplicationId;
	}
	/**
	 * @description Represents the JSON output data structure.
	 */
	public class JsonOutput {
		@InvocableVariable
		public String jsonData;
	}
	/**
	 * @description Invocable method to generate JSON data from Document Checklist Items based on the given Individual Application ID.
	 * @param idInputs List of input objects containing the Individual Application ID.
	 * @return List containing the JSON output.
	 */
	@InvocableMethod(
		label='Generate JSON from Document Checklist Items by Parent ID'
		description='Generates JSON data from Document Checklist Items based on the given Individual Application ID'
	)
	public static List<JsonOutput> generateJsonFromChecklistItemsByParentId(List<IdInput> idInputs) {
		List<JsonOutput> outputList = new List<JsonOutput>();

		if (idInputs == null || idInputs.isEmpty()) {
			return outputList;
		}

		IdInput input = idInputs[0];
		String individualApplicationIdString = input.individualApplicationId;

		Id individualApplicationId;
		try {
			individualApplicationId = Id.valueOf(individualApplicationIdString);
		} catch (StringException e) {
			return outputList;
		}

		Boolean isExpedited = false;
		try {
			IndividualApplication application = [
				SELECT SAP_Expedited__c
				FROM IndividualApplication
				WHERE Id = :individualApplicationId
				LIMIT 1
			];
			isExpedited = application.SAP_Expedited__c;
		} catch (Exception e) {
			return outputList;
		}

		List<DocumentChecklistItem> checklistItems = [
			SELECT
				Id,
				Name,
				SAP_country__c,
				SAP_Fees__c,
				SAP_SOTS_Certified_copy_number__c,
				ParentRecordId,
				DocumentType.MasterLabel,
				SAP_Hague_Status__c,
				SAP_isAddedByAgent__c,
				SAP_isNoFee__c
			FROM DocumentChecklistItem
			WHERE ParentRecordId = :individualApplicationId
		];

		if (checklistItems == null || checklistItems.isEmpty()) {
			return outputList;
		}
		List<Id> checklistItemIds = new List<Id>();
		for (DocumentChecklistItem item : checklistItems) {
			checklistItemIds.add(item.Id);
		}

		List<ContentDocumentLink> contentDocumentLinks = [
			SELECT ContentDocumentId, LinkedEntityId
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :checklistItemIds
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
				WHERE ContentDocumentId IN :contentDocumentIds
			];
		}

		Map<Id, String> contentDocumentIdToTitle = new Map<Id, String>();
		for (ContentVersion cv : contentVersions) {
			contentDocumentIdToTitle.put(cv.ContentDocumentId, cv.Title);
		}

		List<DocumentChecklistItemWrapperLwc> wrappers = new List<DocumentChecklistItemWrapperLwc>();
		Integer rowId = 1;

		for (DocumentChecklistItem item : checklistItems) {
			DocumentChecklistItemWrapperLwc wrapper = new DocumentChecklistItemWrapperLwc();
			wrapper.id = String.valueOf(item.Id);
			wrapper.type = '';
			wrapper.country = '';
			wrapper.hague = item.SAP_Hague_Status__c;
			wrapper.person = '';
			wrapper.fee = String.valueOf(item.SAP_Fees__c);
			wrapper.baseFee = isExpedited ? String.valueOf(item.SAP_Fees__c - 50) : String.valueOf(item.SAP_Fees__c);
			wrapper.expediteFee = '0.00';
			wrapper.typeOfDocument = item.DocumentType.MasterLabel;
			wrapper.destinationCountry = item.SAP_country__c;
			wrapper.personName = item.Name;
			wrapper.copyNumber = item.SAP_SOTS_Certified_copy_number__c;
			wrapper.rowId = rowId++;
			wrapper.isAddedByAgent = item.SAP_isAddedByAgent__c;
			wrapper.isNoFee = item.SAP_isNoFee__c;

			wrapper.uploadedFiles = new List<Map<String, String>>();

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
		String jsonOutput = JSON.serialize(wrappers);
		JsonOutput output = new JsonOutput();
		output.jsonData = jsonOutput;
		outputList.add(output);

		return outputList;
	}

	/*********************************************************************************************
	 * INNER CLASS: DocumentChecklistItemWrapper
	 * DESCRIPTION: Wrapper class to hold document checklist item details.
	 *********************************************************************************************/
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
		public Boolean isAddedByAgent;
		public Boolean isNoFee;
		public Datetime certificateApprovedDateRaw;
	}

	/*********************************************************************************************
	 * INNER CLASS: PaymentDetailsItemWrapper
	 * DESCRIPTION: Wrapper class to hold payment transaction details.
	 *********************************************************************************************/
	public class PaymentDetailsItemWraper {
		public String id;
		public String transactionType;
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

	/**
	 * @description Retrieves document checklist items and payment details associated with a given
	 * Individual Application record and returns the data in JSON format for use in a Lightning Web Component (LWC).
	 *
	 * @param {String} individualApplicationId - The ID of the Individual Application record.
	 * @return {String} - A JSON string containing the checklist items and payment details,
	 *                    or null if the ID is invalid.
	 */

	@AuraEnabled(cacheable=true)
	public static String generateJsonFromChecklistItemsByParentIdLwc(String individualApplicationId) {
		List<DocumentChecklistItemWrapper> wrappers = new List<DocumentChecklistItemWrapper>();
		List<PaymentDetailsItemWraper> paymentDetailsList = new List<PaymentDetailsItemWraper>();
		Map<String, Object> result = new Map<String, Object>();

		Id individualApplicationIdConverted;
		try {
			individualApplicationIdConverted = Id.valueOf(individualApplicationId);
		} catch (StringException e) {
			return null;
		}

		Boolean isExpedited = false;

		IndividualApplication individualApplication = [
			SELECT Id, SAP_Sequence_Number__c, SAP_Expedited__c
			FROM IndividualApplication
			WHERE Id = :individualApplicationIdConverted
			LIMIT 1
		];

		isExpedited = individualApplication.SAP_Expedited__c;

		List<DocumentChecklistItem> checklistItems = [
			SELECT
				Id,
				Name,
				SAP_country__c,
				SAP_Fees__c,
				ParentRecordId,
				DocumentType.MasterLabel,
				Signed_By__r.Id,
				Signed_By__r.SAP_Seal_Stramp_of__c,
				Signed_By__r.Name,
				Signed_By__r.SAP_Position__c,
				Status,
				SAP_RejectionReason__c,
				SAP_Hague_Status__c,
				Signing_Authority__c,
				Signing_Authority__r.Name,
				Signing_Authority__r.SAP_Staff_Title__c,
				SAP_Start_Term__c,
				SAP_End_Term__c,
				SAP_SOTS_Certified_copy_number__c,
				SAP_Certificate_Number__c,
				SAP_Rejection_Reason__c,
				SAP_isAddedByAgent__c,
				SAP_isNoFee__c,
				SAP_ApprovedDate__c
			FROM DocumentChecklistItem
			WHERE ParentRecordId = :individualApplicationIdConverted
		];

		List<RegulatoryTrxnFee> trxnFees = [
			SELECT
				Id,
				SAP_Payment_Type__c,
				SAP_amount__c,
				TotalFeeAmount,
				Status,
				SAP_Card_Number__c,
				SAP_CK_Number__c,
				SAP_Card_Type__c,
				SAP_Auth_Code__c,
				SAP_Brand__c,
				RecordType.Name,
				CreatedDate,
				ParentRecordId
			FROM RegulatoryTrxnFee
			WHERE ParentRecordId = :individualApplicationIdConverted
		];

		for (RegulatoryTrxnFee fee : trxnFees) {
			PaymentDetailsItemWraper paymentDetailsItemWraper = new PaymentDetailsItemWraper();
			paymentDetailsItemWraper.id = fee.Id;
			paymentDetailsItemWraper.transactionType = fee.RecordType.Name;
			paymentDetailsItemWraper.paymentType = fee.SAP_Payment_Type__c;
			paymentDetailsItemWraper.paymentAmount = fee.TotalFeeAmount != null ? String.valueOf(fee.TotalFeeAmount) : null;
			paymentDetailsItemWraper.cardType = fee.SAP_Brand__c;
			paymentDetailsItemWraper.ckNumber = fee.SAP_CK_Number__c != null ? String.valueOf(fee.SAP_CK_Number__c) : null;
			paymentDetailsItemWraper.authCode = fee.SAP_Auth_Code__c;
			paymentDetailsItemWraper.dateOfPayment = fee.CreatedDate != null ? fee.CreatedDate.date().format() : null;
			paymentDetailsItemWraper.last4Digits = fee.SAP_Card_Number__c != null ? String.valueOf(fee.SAP_Card_Number__c) : null;
			paymentDetailsItemWraper.status = fee.Status;
			paymentDetailsItemWraper.showRemoveButton = false;
			paymentDetailsItemWraper.readOnlyMode = true;

			paymentDetailsList.add(paymentDetailsItemWraper);
		}

		List<Id> checklistItemIds = new List<Id>();
		for (DocumentChecklistItem item : checklistItems) {
			checklistItemIds.add(item.Id);
		}

		List<ContentDocumentLink> contentDocumentLinks = [
			SELECT ContentDocumentId, LinkedEntityId
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :checklistItemIds
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
				WHERE ContentDocumentId IN :contentDocumentIds
			];
		}

		Map<Id, String> contentDocumentIdToTitle = new Map<Id, String>();
		for (ContentVersion cv : contentVersions) {
			contentDocumentIdToTitle.put(cv.ContentDocumentId, cv.Title);
		}

		for (DocumentChecklistItem item : checklistItems) {
			DocumentChecklistItemWrapper wrapper = new DocumentChecklistItemWrapper();
			wrapper.id = String.valueOf(item.Id);
			wrapper.type = '';
			wrapper.country = '';
			wrapper.hague = item.SAP_Hague_Status__c;
			wrapper.person = '';
			wrapper.fee = String.valueOf(item.SAP_Fees__c);
			wrapper.baseFee = isExpedited ? String.valueOf(item.SAP_Fees__c - 50) : String.valueOf(item.SAP_Fees__c);
			wrapper.feeDisplay = '$' + String.valueOf(item.SAP_Fees__c);
			wrapper.expediteFee = '0.00';
			wrapper.isExpedited = isExpedited;
			wrapper.typeOfDocument = item.DocumentType.MasterLabel;
			wrapper.destinationCountry = item.SAP_country__c;
			wrapper.personName = item.Name;
			wrapper.copyNumber = item.SAP_SOTS_Certified_copy_number__c;
			wrapper.signedByName = item.Signed_By__r != null ? item.Signed_By__r.Name : null;
			wrapper.signedStamp = item.Signed_By__r != null ? item.Signed_By__r.SAP_Seal_Stramp_of__c : null;
			wrapper.signedByPosition = item.Signed_By__r != null ? item.Signed_By__r.SAP_Position__c : null;
			wrapper.selectedContactID = item.Signed_By__r != null ? item.Signed_By__r.Id : null;
			wrapper.status = item.Status;
			wrapper.autority = item.Signing_Authority__c;
			wrapper.autorityName = item.Signing_Authority__r != null ? item.Signing_Authority__r.Name : null;
			wrapper.authorityTitle = item.Signing_Authority__r != null ? item.Signing_Authority__r.SAP_Staff_Title__c : null;
			wrapper.rejectionReason = item.SAP_RejectionReason__c;
			wrapper.customRejectionReason = item.SAP_Rejection_Reason__c;
			wrapper.termStart = item.SAP_Start_Term__c;
			wrapper.termEnd = item.SAP_End_Term__c;
			wrapper.checkDocumentType = (item.DocumentType.MasterLabel == 'SOTS Certified Copies');
			wrapper.certificateNumber = item.SAP_Certificate_Number__c != null ? item.SAP_Certificate_Number__c : null;
			wrapper.isAddedByAgent = item.SAP_isAddedByAgent__c;
			wrapper.isNoFee = item.SAP_isNoFee__c;
			wrapper.certificateApprovedDateRaw = item.SAP_ApprovedDate__c;
			wrapper.uploadedFiles = new List<Map<String, String>>();

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

		result.put('sequenceNumber', individualApplication.SAP_Sequence_Number__c);

		result.put('documentChecklistItems', wrappers);
		result.put('paymentDetails', paymentDetailsList);

		return JSON.serialize(result);
	}

	/*********************************************************************************************
	 * INNER CLASS: DocumentChecklistItemWrapperLwc
	 * DESCRIPTION: Wrapper class to hold document checklist item details.
	 *********************************************************************************************/

	public class DocumentChecklistItemWrapperLwc {
		public String id;
		public String type;
		public String country;
		public String hague;
		public String person;
		public String fee;
		public String baseFee;
		public String feeDisplay;
		public String expediteFee;
		public String typeOfDocument;
		public String destinationCountry;
		public String personName;
		public String copyNumber;
		public List<Map<String, String>> uploadedFiles;
		public Integer rowId;
		public Boolean isAddedByAgent;
		public Boolean isNoFee;
	}

	/**
	 * @description Searches for contacts based on a provided search key and optional position,
	 * retrieving relevant contact details and returning the results in JSON format.
	 *
	 * @param {String} searchKey - The search term used to find matching contacts.
	 * @param {String} position - (Optional) The specific position to filter contacts by.
	 * @return {String} - A JSON string containing a list of matching contacts and their details.
	 */
	@AuraEnabled
	//   public static String searchContacts(String searchKey, String position) {
	//     System.debug('searchKey is : '+ searchKey);
	//     String originalKey = searchKey.trim();

	//     List<Contact> result;
	//     List<String> searchTerms = originalKey.split(' ');

	//     String queryBase = 'SELECT Id, Name, SAP_Seal_Stramp_of__c, SAP_Start_Term__c, SAP_End_Term__c, SAP_Indefinite_Term__c, SAP_Status__c, SAP_Town__c, SAP_Position__c ' +
	//                      'FROM Contact ' +
	//                      'WHERE RecordType.DeveloperName = \'Apostille_Official\'';

	//     if (String.isNotBlank(position)) {
	//         String escapedPosition = String.escapeSingleQuotes(position);
	//         queryBase += ' AND Position__c = \'' + escapedPosition + '\'';
	//         System.debug('Position is ==>' + escapedPosition);
	//     }

	//     if (searchTerms.size() > 1) {
	//         String exactMatchQuery = queryBase + ' AND Name = \'' + String.escapeSingleQuotes(originalKey) + '\'';
	//         System.debug('Exact match query: ' + exactMatchQuery);
	//         List<Contact> exactMatches = Database.query(exactMatchQuery);

	//         if (!exactMatches.isEmpty()) {
	//             result = exactMatches;
	//         }
	//     }

	//     if (result == null || result.isEmpty()) {
	//         List<String> searchConditions = new List<String>();

	//         if (searchTerms.size() > 1) {
	//             searchConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(originalKey) + '%\'');
	//             List<String> termConditions = new List<String>();
	//             for (String term : searchTerms) {
	//                 if (term.length() > 1) {
	//                     termConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(term) + '%\'');
	//                 }
	//             }

	//             if (!termConditions.isEmpty()) {
	//                 searchConditions.add('(' + String.join(termConditions, ' AND ') + ')');
	//             }
	//         } else {
	//             searchConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(originalKey) + '%\'');
	//         }
	//         String finalQuery = queryBase + ' AND (' + String.join(searchConditions, ' OR ') + ')';
	//         Integer maxRows = 99;
	//         finalQuery += ' LIMIT ' + maxRows;

	//         System.debug('SOQL Query: ' + finalQuery);
	//         System.debug('SOQL Queries Used: ' + Limits.getQueries());
	//         System.debug('SOQL Queries Allowed: ' + Limits.getLimitQueries());

	//         result = Database.query(finalQuery);
	//     }

	//     List<ContactWrapper> wrappers = new List<ContactWrapper>();

	//     try {
	//         Set<Id> contactIds = new Set<Id>();
	//         for (Contact res : result) {
	//             contactIds.add(res.Id);
	//         }

	//         List<String> contactIdList = new List<String>();
	//         for (Id contactId : contactIds) {
	//             contactIdList.add(String.valueOf(contactId));
	//         }

	//         Map<Id, List<Map<String, Object>>> nameHistoryMap = processNameFieldHistory(contactIdList);
	//         Map<Id, List<Map<String, Object>>> termHistoryMap = processTermFieldHistory(contactIdList);

	//         for (Contact res : result) {
	//             ContactWrapper wrapper = new ContactWrapper();
	//             wrapper.Id = String.valueOf(res.Id);
	//             wrapper.Name = res.Name;
	//             wrapper.sealStramp = res.SAP_Seal_Stramp_of__c;
	//             wrapper.StartTerm = formatCustomDate(res.SAP_Start_Term__c);
	//             wrapper.EndTerm = formatCustomDate(res.SAP_End_Term__c);
	//             wrapper.IndefiniteTerm = res.SAP_Indefinite_Term__c;
	//             wrapper.Status = res.SAP_Status__c;
	//             wrapper.Position = res.SAP_Position__c;
	//             wrapper.Town = res.SAP_Town__c;

	//             wrapper.nameHistory = nameHistoryMap.containsKey(res.Id) ? nameHistoryMap.get(res.Id) : new List<Map<String, Object>>();
	//             wrapper.termHistory = termHistoryMap.containsKey(res.Id) ? termHistoryMap.get(res.Id) : new List<Map<String, Object>>();

	//             wrapper.hasTermHistory = !wrapper.termHistory.isEmpty();

	//             wrappers.add(wrapper);
	//         }
	//     } catch (Exception e) {
	//         System.debug('Error fetching contacts: ' + e.getMessage());
	//         throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
	//     }

	//     System.debug('Final contact wrappers result is ==>> ' + JSON.serialize(wrappers));
	//     return JSON.serialize(wrappers);
	// }

	public static String searchContacts(String searchKey, String position) {
		System.debug('searchKey is : ' + searchKey);

		if (String.isBlank(searchKey)) {
			return JSON.serialize(new List<ContactWrapper>());
		}

		String originalKey = searchKey.trim();
		List<Contact> result;
		List<String> searchTerms = originalKey.split(' ');

		Map<String, Object> queryParams = new Map<String, Object>{ 'recordTypeName' => 'Apostille_Official', 'maxRows' => 99 };

		String queryBase =
			'SELECT Id, Name, SAP_Seal_Stramp_of__c, SAP_NotaryCredentialId__c, SAP_Start_Term__c, SAP_End_Term__c, ' +
			'SAP_Indefinite_Term__c, SAP_Status__c, SAP_Town__c, SAP_Position__c ' +
			'FROM Contact ' +
			'WHERE RecordType.DeveloperName = :recordTypeName';

		if (String.isNotBlank(position)) {
			queryBase += ' AND SAP_Position__c = :position';
			queryParams.put('position', position);
			System.debug('Position is ==>' + position);
		}

		if (searchTerms.size() > 1) {
			String exactMatchQuery = queryBase + ' AND Name = :originalKey';
			queryParams.put('originalKey', originalKey);

			System.debug('Exact match query: ' + exactMatchQuery);

			result = Database.queryWithBinds(exactMatchQuery, queryParams, AccessLevel.USER_MODE);
		}

		if (result == null || result.isEmpty()) {
			List<String> searchConditions = new List<String>();

			if (searchTerms.size() > 1) {
				searchConditions.add('Name LIKE :fullKeySearch');
				queryParams.put('fullKeySearch', '%' + originalKey + '%');

				List<String> termConditions = new List<String>();
				for (Integer i = 0; i < searchTerms.size(); i++) {
					String term = searchTerms[i];
					if (term.length() > 1) {
						String paramName = 'term' + i;
						termConditions.add('Name LIKE :' + paramName);
						queryParams.put(paramName, '%' + term + '%');
					}
				}

				if (!termConditions.isEmpty()) {
					searchConditions.add('(' + String.join(termConditions, ' AND ') + ')');
				}
			} else {
				searchConditions.add('Name LIKE :singleKeySearch');
				queryParams.put('singleKeySearch', '%' + originalKey + '%');
			}

			String finalQuery = queryBase + ' AND (' + String.join(searchConditions, ' OR ') + ') LIMIT :maxRows';

			System.debug('SOQL Query: ' + finalQuery);
			System.debug('SOQL Queries Used: ' + Limits.getQueries());
			System.debug('SOQL Queries Allowed: ' + Limits.getLimitQueries());

			result = Database.queryWithBinds(finalQuery, queryParams, AccessLevel.USER_MODE);
		}

		List<ContactWrapper> wrappers = new List<ContactWrapper>();

		try {
			// Collect contact IDs
			Set<Id> contactIds = new Set<Id>();
			Set<String> notaryCredentialIds = new Set<String>();
			for (Contact res : result) {
				if (res.SAP_Position__c != 'Notary Public') {
					contactIds.add(res.Id);
				} else if (String.isNotBlank(res.SAP_NotaryCredentialId__c)) {
					notaryCredentialIds.add(res.SAP_NotaryCredentialId__c);
				}
			}

			// Step 3: Convert Contact IDs to a List<String> for Processing
			List<String> contactIdList = new List<String>();
			for (Id contactId : contactIds) {
				contactIdList.add(String.valueOf(contactId));
			}

			// // Process histories
			// Map<Id, List<Map<String, Object>>> nameHistoryMap = processNameFieldHistory(contactIdList);
			// Map<Id, List<Map<String, Object>>> termHistoryMap = processTermFieldHistory(contactIdList);
			// Map<String, List<Map<String, Object>>> notaryNameHistoryMap = notaryCredentialIds.isEmpty()
			//     ? new Map<String, List<Map<String, Object>>>()
			//     : processNotaryNameHistory(notaryCredentialIds);

			// Map<String, List<Map<String, Object>>> notaryTermHistoryMap = notaryCredentialIds.isEmpty()
			//     ? new Map<String, List<Map<String, Object>>>()
			//     : processNotaryTermHistory(notaryCredentialIds);

			// Create wrappers
			for (Contact res : result) {
				ContactWrapper wrapper = new ContactWrapper();
				wrapper.Id = String.valueOf(res.Id);
				wrapper.Name = res.Name;
				wrapper.sealStramp = res.SAP_Seal_Stramp_of__c;
				wrapper.StartTerm = formatCustomDate(res.SAP_Start_Term__c);
				wrapper.EndTerm = formatCustomDate(res.SAP_End_Term__c);
				wrapper.IndefiniteTerm = res.SAP_Indefinite_Term__c;
				wrapper.NotaryCredentianId = res.SAP_NotaryCredentialId__c;
				wrapper.Status = res.SAP_Status__c;
				wrapper.Position = res.SAP_Position__c;
				wrapper.Town = res.SAP_Town__c;

				//   if (contactIds.contains(res.Id)) {
				//     if (nameHistoryMap.containsKey(res.Id)) {
				//         wrapper.nameHistory = nameHistoryMap.get(res.Id);
				//     } else {
				//         wrapper.nameHistory = new List<Map<String, Object>>();
				//     }

				//     if (termHistoryMap.containsKey(res.Id)) {
				//         wrapper.termHistory = termHistoryMap.get(res.Id);
				//     } else {
				//         wrapper.termHistory = new List<Map<String, Object>>();
				//     }
				// }

				//   if (res.SAP_Position__c == 'Notary Public' && String.isNotBlank(res.SAP_NotaryCredentialId__c)) {
				//     String notaryCredId = res.SAP_NotaryCredentialId__c;

				//     // Assign Notary Name History (now formatted like regular history)
				//     if (notaryNameHistoryMap.containsKey(notaryCredId)) {
				//         wrapper.nameHistory = notaryNameHistoryMap.get(notaryCredId);
				//     } else {
				//         wrapper.nameHistory = new List<Map<String, Object>>();
				//     }

				//     // Assign Notary Term History (now formatted like regular history)
				//     if (notaryTermHistoryMap.containsKey(notaryCredId)) {
				//         wrapper.termHistory = notaryTermHistoryMap.get(notaryCredId);
				//     } else {
				//         wrapper.termHistory = new List<Map<String, Object>>();
				//     }
				//   }

				//   wrapper.hasTermHistory = !wrapper.termHistory.isEmpty();

				wrappers.add(wrapper);
			}
		} catch (Exception e) {
			System.debug('Error fetching contacts: ' + e.getMessage());
			throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
		}

		System.debug('Final contact wrappers result is ==>> ' + JSON.serialize(wrappers));
		return JSON.serialize(wrappers);
	}

	/**
	 * @description Updates the seal stamp value of a contact based on the provided contact data in JSON format.
	 *
	 * @param {String} contactJson - A JSON string containing the contact ID and the new seal stamp value.
	 *
	 * @return {void} - This method does not return a value but updates the contact's seal stamp.
	 *
	 */
	@AuraEnabled
	public static void updateContactSealStamp(String contactJson) {
		try {
			Map<String, Object> contactData = (Map<String, Object>) JSON.deserializeUntyped(contactJson);

			Id contactId = (Id) contactData.get('Id');
			String sealStrampValue = (String) contactData.get('SAP_Seal_Stramp_of__c');

			Contact contactToUpdate = [
				SELECT Id, SAP_Seal_Stramp_of__c
				FROM Contact
				WHERE Id = :contactId
				LIMIT 1
			];

			contactToUpdate.SAP_Seal_Stramp_of__c = sealStrampValue;

			Database.update(contactToUpdate, AccessLevel.USER_MODE);
		} catch (Exception e) {
			throw new AuraHandledException('Failed to update contact: ' + e.getMessage());
		}
	}

	/*********************************************************************************************
	 * INNER CLASS: ContactWrapper
	 * DESCRIPTION: Wrapper class to hold Contact Details details.
	 *********************************************************************************************/
	public class ContactWrapper {
		public String Id;
		public String Name;
		public String sealStramp;
		public String StartTerm;
		public String EndTerm;
		public Boolean IndefiniteTerm;
		public String NotaryCredentianId;
		public String Status;
		public String Position;
		public String Town;
		public Boolean hasTermHistory;
		public List<Map<String, Object>> nameHistory;
		public List<Map<String, Object>> termHistory;
	}
	/**
	 * @description Formats a given date into the MM/DD/YYYY format.
	 *
	 * @param {Date} inputDate - The date to be formatted.
	 *
	 * @return {String} - The formatted date as a string in MM/DD/YYYY format, or null if the input date is null.
	 */
	private static String formatCustomDate(Date inputDate) {
		if (inputDate == null)
			return null;
		String formattedMonth = (inputDate.month() < 10) ? '0' + String.valueOf(inputDate.month()) : String.valueOf(inputDate.month());
		String formattedDay = (inputDate.day() < 10) ? '0' + String.valueOf(inputDate.day()) : String.valueOf(inputDate.day());
		return formattedMonth + '/' + formattedDay + '/' + String.valueOf(inputDate.year());
	}

	/**
	 * @description Processes the history of name field changes (FirstName, MiddleName, LastName)
	 * for a list of contact IDs, and returns the changes in a structured map.
	 *
	 * @param {List<String>} contactIds - A list of contact IDs for which name field history is to be retrieved.
	 *
	 * @return {Map<Id, List<Map<String, Object>>>} - A map where the key is the contact ID,
	 * and the value is a list of maps containing the history of field changes for the contact.
	 *         Each map contains 'Field', 'OldValue', 'NewValue', and 'CreatedDate' for each change.
	 */
	public static Map<Id, List<Map<String, Object>>> processNameFieldHistory(List<String> contactIds) {
		Map<Id, List<Map<String, Object>>> historyMap = new Map<Id, List<Map<String, Object>>>();

		if (contactIds.isEmpty()) {
			return historyMap;
		}

		Set<Id> contactIdSet = new Set<Id>();
		for (String contactId : contactIds) {
			contactIdSet.add(Id.valueOf(contactId));
		}

		Map<Id, Contact> contactRecords = new Map<Id, Contact>(
			[
				SELECT Id, FirstName, MiddleName, LastName, CreatedDate
				FROM Contact
				WHERE Id IN :contactIdSet
			]
		);

		List<ContactHistory> historyRecords = [
			SELECT ContactId, Field, OldValue, NewValue, CreatedDate
			FROM ContactHistory
			WHERE ContactId IN :contactIdSet AND Field IN ('FirstName', 'MiddleName', 'LastName')
			ORDER BY CreatedDate ASC
		];

		for (ContactHistory history : historyRecords) {
			Id contactId = history.ContactId;
			if (!historyMap.containsKey(contactId)) {
				historyMap.put(contactId, new List<Map<String, Object>>());
			}

			Map<String, Object> recordData = new Map<String, Object>();
			recordData.put('Field', history.Field);
			recordData.put('OldValue', history.OldValue);
			recordData.put('NewValue', history.NewValue);
			recordData.put('CreatedDate', history.CreatedDate);

			historyMap.get(contactId).add(recordData);
		}

		return historyMap;
	}

	/**
	 * @description Processes the history of term field changes (Start_Term__c, End_Term__c)
	 * for a list of contact IDs, and returns the changes in a structured map.
	 *
	 * @param {List<String>} contactIds - A list of contact IDs for which term field history is to be retrieved.
	 *
	 * @return {Map<Id, List<Map<String, Object>>>} - A map where the key is the contact ID,
	 * and the value is a list of maps containing the history of term field changes for the contact.
	 *         Each map contains 'Field', 'OldValue', 'NewValue', and 'CreatedDate' for each change.
	 */
	public static Map<Id, List<Map<String, Object>>> processTermFieldHistory(List<String> contactIds) {
		Map<Id, List<Map<String, Object>>> historyMap = new Map<Id, List<Map<String, Object>>>();

		if (contactIds.isEmpty()) {
			return historyMap;
		}

		Set<Id> contactIdSet = new Set<Id>();
		for (String contactId : contactIds) {
			contactIdSet.add(Id.valueOf(contactId));
		}

		Map<Id, Contact> contactRecords = new Map<Id, Contact>(
			[
				SELECT Id, SAP_Start_Term__c, SAP_End_Term__c
				FROM Contact
				WHERE Id IN :contactIdSet
			]
		);

		List<ContactHistory> historyRecords = [
			SELECT ContactId, Field, OldValue, NewValue, CreatedDate
			FROM ContactHistory
			WHERE ContactId IN :contactIdSet AND Field IN ('Start_Term__c', 'End_Term__c')
			ORDER BY CreatedDate ASC
		];

		for (ContactHistory history : historyRecords) {
			Id contactId = history.ContactId;
			if (!historyMap.containsKey(contactId)) {
				historyMap.put(contactId, new List<Map<String, Object>>());
			}

			Map<String, Object> recordData = new Map<String, Object>();
			recordData.put('Field', history.Field);
			recordData.put('OldValue', history.OldValue);
			recordData.put('NewValue', history.NewValue);
			recordData.put('CreatedDate', history.CreatedDate);

			historyMap.get(contactId).add(recordData);
		}

		return historyMap;
	}

	public static Map<String, List<Map<String, Object>>> processNotaryNameHistory(Set<String> credentialIds) {
		Map<String, List<Map<String, Object>>> notaryNameHistoryMap = new Map<String, List<Map<String, Object>>>();

		if (credentialIds.isEmpty()) {
			return notaryNameHistoryMap; // Return empty map if no credential IDs
		}

		List<SAP_Notary_Public_Name_History__c> nameHistories = [
			SELECT CredentialId__c, FirstName__c, MiddleName__c, LastName__c, Name_Modified_Date__c
			FROM SAP_Notary_Public_Name_History__c
			WHERE CredentialId__c IN :credentialIds
			ORDER BY Name_Modified_Date__c ASC
		];

		for (SAP_Notary_Public_Name_History__c history : nameHistories) {
			String credentialId = history.CredentialId__c;

			if (!notaryNameHistoryMap.containsKey(credentialId)) {
				notaryNameHistoryMap.put(credentialId, new List<Map<String, Object>>());
			}

			// Standardizing history format
			Map<String, Object> recordData = new Map<String, Object>();
			recordData.put('Field', 'Name'); // Unified field name
			recordData.put('OldValue', history.FirstName__c + ' ' + history.MiddleName__c + ' ' + history.LastName__c);
			recordData.put('NewValue', null); // No explicit new value in history tracking
			recordData.put('CreatedDate', history.Name_Modified_Date__c);

			notaryNameHistoryMap.get(credentialId).add(recordData);
		}

		return notaryNameHistoryMap;
	}

	public static Map<String, List<Map<String, Object>>> processNotaryTermHistory(Set<String> credentialIds) {
		Map<String, List<Map<String, Object>>> notaryTermHistoryMap = new Map<String, List<Map<String, Object>>>();

		if (credentialIds.isEmpty()) {
			return notaryTermHistoryMap; // Return empty map if no credential IDs
		}

		List<SAP_Notary_Public_Term_History__c> termHistories = [
			SELECT CredentialId__c, Start_Term__c, End_Term__c, IndefiniteTerm__c, Term_Modified_Date__c
			FROM SAP_Notary_Public_Term_History__c
			WHERE CredentialId__c IN :credentialIds
			ORDER BY Start_Term__c ASC
		];

		for (SAP_Notary_Public_Term_History__c history : termHistories) {
			String credentialId = history.CredentialId__c;

			if (!notaryTermHistoryMap.containsKey(credentialId)) {
				notaryTermHistoryMap.put(credentialId, new List<Map<String, Object>>());
			}

			// Standardizing history format
			Map<String, Object> recordData = new Map<String, Object>();
			recordData.put('Field', 'Term'); // Unified field name
			recordData.put('OldValue', history.Start_Term__c + ' - ' + history.End_Term__c);
			recordData.put('NewValue', history.IndefiniteTerm__c ? 'Indefinite Term' : null);
			recordData.put('CreatedDate', history.Term_Modified_Date__c);

			notaryTermHistoryMap.get(credentialId).add(recordData);
		}

		return notaryTermHistoryMap;
	}

	@AuraEnabled(cacheable=true)
	public static Boolean isCurrentUserAdmin() {
		// Get current user's email
		String loggedInEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;

		// Get the admin email list from custom label
		String adminEmailsRaw = Label.SAP_Apostille_Admins;

		if (String.isBlank(adminEmailsRaw) || String.isBlank(loggedInEmail)) {
			return false;
		}

		// Split and normalize email list using correct Apex syntax
		List<String> adminEmailList = new List<String>();
		for (String email : adminEmailsRaw.split(',')) {
			if (!String.isBlank(email)) {
				adminEmailList.add(email.trim().toLowerCase());
			}
		}

		return adminEmailList.contains(loggedInEmail.toLowerCase());
	}
}