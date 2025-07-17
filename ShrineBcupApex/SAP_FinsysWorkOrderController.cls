/**
 * SAP_FinsysWorkOrderController.cls
 *
 * This Apex controller manages Work Orders and their related transactions within the Finsys system.
 *
 * Features:
 * - Retrieves Activity Data and Fees
 * - Searches for contacts associated with Work Orders
 * - Creates and updates Work Orders
 * - Handles transaction fees, payments, and document uploads
 * - Supports refunds and regulatory transaction deletions
 * - Provides Work Order details for BRS (Business Registration System)
 *
 * Security:
 * - Enforces field- and object-level security using WITH SECURITY_ENFORCED
 * - Uses AccessLevel.USER_MODE for safe DML operations
 * - Ensures proper validation of Work Order updates and refunds
 *
 * Related Objects:
 * - Contact, IndividualApplication, SAP_Batch__c, RegulatoryTrxnFee, RegulatoryTrxnFeeItem, Work_Order__c, ContentDocumentLink
 *
 * Last Modified: Mar-05-2025
 */ public class SAP_FinsysWorkOrderController {
	@AuraEnabled(cacheable=true)
	public static List<Map<String, Object>> getActivityData() {
		List<Map<String, Object>> activityDataList = new List<Map<String, Object>>();

		for (SAP_FinSys_Activity_SubActivity__mdt record : [
			SELECT Activity__c, Sub_Activity__c, Program_Code__c
			FROM SAP_FinSys_Activity_SubActivity__mdt
			WITH SECURITY_ENFORCED
		]) {
			Map<String, Object> activityData = new Map<String, Object>();
			activityData.put('activity', record.Activity__c);
			activityData.put('subActivity', record.Sub_Activity__c);
			activityData.put('programCode', record.Program_Code__c);
			activityDataList.add(activityData);
		}

		return activityDataList;
	}

	@AuraEnabled(cacheable=true)
	public static Decimal getActivityFee(String activity, String subActivity) {
    try {
      List<SAP_FinSys_Activity_SubActivity_Fees__mdt> feeMdt = [
        SELECT Fee__c
        FROM SAP_FinSys_Activity_SubActivity_Fees__mdt
        WHERE Activity__c = :activity AND Sub_Activity__c = :subActivity
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      if(!feeMdt.isEmpty()){
        return feeMdt[0].Fee__c;
      } else {
        return 0;
      } 
    } catch (Exception e) {
			throw new AuraHandledException('Error retrieving activity fee: ' + e.getMessage());
    }

	}

	@AuraEnabled
	public static List<Contact> searchContacts(String searchName) {
		if (String.isBlank(searchName)) {
			return null;
		}

		// Get the Record Type ID for "FinSys Customers"
		Id recordTypeId = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers'
			WITH SECURITY_ENFORCED
			LIMIT 1
		]
		.Id;

		// Query matching contacts by name, filtering by the specific record type
		List<Contact> contacts = [
			SELECT
				Id,
				Salutation,
				FirstName,
				LastName,
				MiddleName,
				Suffix,
				SAP_Organization__c,
				MailingStreet,
				SAP_MailingAddress2__c,
				MailingCity,
				MailingState,
				MailingPostalCode,
				MailingCountry,
				SAP_Deliquent__c,
				Email,
				Phone,
				SAP_Customer_Account_Balance__c
			FROM Contact
			WHERE Name LIKE :('%' + searchName + '%')
			WITH SECURITY_ENFORCED
		];

		// Modify data if any contacts are found
		if (!contacts.isEmpty()) {
			for (Contact c : contacts) {
				if (c.FirstName != null) {
					c.FirstName = capitalizeFirstLetter(c.FirstName);
				}
			}
		}

		return contacts.isEmpty() ? null : contacts;
	}

	@AuraEnabled(cacheable=true)
	public static String getContactFirstName(String contactId) {
		try {
			Id conId = Id.valueOf(contactId);

			Contact contact = [
				SELECT FirstName
				FROM Contact
				WHERE Id = :conId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			return contact.FirstName;
		} catch (IllegalArgumentException e) {
			throw new AuraHandledException('Invalid Contact ID format');
		} catch (Exception e) {
			throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
		}
	}

	private static String capitalizeFirstLetter(String inputString) {
		if (String.isBlank(inputString)) {
			return '';
		}
		String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
		return formattedString;
	}

	@AuraEnabled
	public static Map<String, Object> createWorkOrder(String workOrderDataJson) {
		try {
			// Deserialize JSON string to a Map for easy access
			Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(workOrderDataJson);

			// Extract customer details from the input
			String selectedCustomerId = (String) workOrderData.get('selectedCustomerId');
			Date workOrderDate = Date.valueOf(String.valueOf(workOrderData.get('workOrderDate')));
			String batchId;
			Contact customer;
			Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');
			Map<String, Object> addressDetails = (Map<String, Object>) customerDetails.get('address');

			String recordId = (String) workOrderData.get('recordId');

			String defaultActivity = (String) workOrderData.get('defaultActivity');

			// Ensure defaultActivity is not blank
			if (String.isBlank(defaultActivity)) {
				throw new AuraHandledException('Default activity is required to create a work order.');
			}

			// Calculate the start and end of the day for the workOrderDate
			DateTime startOfDay = DateTime.newInstance(workOrderDate.year(), workOrderDate.month(), workOrderDate.day());
			DateTime endOfDay = startOfDay.addDays(1).addSeconds(-1);

			// Query SAP_Batch__c to find an existing batch for the default activity created today
			SAP_Batch__c existingBatch;
			List<SAP_Batch__c> batchList = [
				SELECT Id, Name, SAP_Batch_Status__c, SAP_Batch_Name__c, SAP_Batch_Date__c
				FROM SAP_Batch__c
				WHERE SAP_Batch_Name__c = :defaultActivity AND SAP_Batch_Date__c = :workOrderDate
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			// Assign the first record if found
			if (!batchList.isEmpty()) {
				existingBatch = batchList[0];
			} else {
				existingBatch = null;
			}

			// Check if a batch exists
			if (existingBatch == null) {
				SAP_Batch__c newBatch = new SAP_Batch__c();
				newBatch.SAP_Batch_Name__c = defaultActivity;
				newBatch.Name = defaultActivity;
				newBatch.SAP_Batch_Status__c = 'Open';
				newBatch.SAP_Batch_Date__c = workOrderDate;
				Database.insert(newBatch, AccessLevel.USER_MODE);

				workOrderData.put('defaultBatchId of new created', newBatch.Id);
				batchId = newBatch.Id;
			} else {
				if (existingBatch.SAP_Batch_Status__c == 'Sealed' || existingBatch.SAP_Batch_Status__c == 'Closed') {
					throw new AuraHandledException(
						'Batch "' + existingBatch.Name + '" for activity "' + existingBatch.SAP_Batch_Name__c + '" is sealed/closed. Please reopen the batch to proceed.'
					);
				}
				workOrderData.put('defaultBatchId', existingBatch.Id);
				batchId = existingBatch.Id;
			}

			if (!String.isBlank(selectedCustomerId)) {
				customer = new Contact(
					Id = selectedCustomerId,
					FirstName = (String) customerDetails.get('firstName'),
					MiddleName = (String) customerDetails.get('middleInitial'),
					LastName = (String) customerDetails.get('lastName'),
					SAP_Organization__c = (String) customerDetails.get('organizationName'),
					Email = (String) customerDetails.get('emailAddress'),
					Phone = (String) customerDetails.get('phoneNumber'),
					MailingStreet = (String) addressDetails.get('street'),
					SAP_MailingAddress2__c = (String) addressDetails.get('address2'),
					MailingCity = (String) addressDetails.get('city'),
					MailingState = (String) addressDetails.get('state'),
					MailingPostalCode = (String) addressDetails.get('zipCode'),
					MailingCountry = (String) addressDetails.get('country')
				);
			} else {
				// Create a new contact if no selectedCustomerId is provided
				customer = createNewContact(customerDetails, addressDetails);
			}

			// Get work order result map
			Map<String, Object> workOrderResult = createWorkOrderForCustomer(customer, workOrderData);

			// Extract ID and Sequence Number
			Id workOrderId = (Id) workOrderResult.get('id');

			List<Object> rawTransactions = (List<Object>) workOrderData.get('transactions');
			List<Object> rawPayments = (List<Object>) workOrderData.get('payments');
			Boolean isSinglePayment = (Boolean) workOrderData.get('isSinglePayment');

			upsertTransactionFeeAndItem(rawTransactions, workOrderId, workOrderDate, batchId);

			String transactionType = (String) workOrderData.get('transactionType');

			uploadAndLinkDocuments(workOrderData, workOrderId);

			IndividualApplication insertedRecord = [
				SELECT Id, SAP_Sequence_Number__c
				FROM IndividualApplication
				WHERE Id = :workOrderId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			workOrderResult.put('sequenceNumber', insertedRecord.SAP_Sequence_Number__c);

			return workOrderResult;
		} catch (AuraHandledException ahe) {
			throw ahe;
		} catch (Exception e) {
			throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
		}
	}

	private static Contact createNewContact(Map<String, Object> customerDetails, Map<String, Object> addressDetails) {
		Contact newCustomer = new Contact();
		newCustomer.RecordTypeId = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers'
			WITH SECURITY_ENFORCED
			LIMIT 1
		]
		.Id;
		newCustomer.FirstName = (String) customerDetails.get('firstName');
		newCustomer.MiddleName = (String) customerDetails.get('middleInitial');
		newCustomer.LastName = (String) customerDetails.get('lastName');
		newCustomer.SAP_Organization__c = (String) customerDetails.get('organizationName');
		newCustomer.Email = (String) customerDetails.get('emailAddress');
		newCustomer.Phone = (String) customerDetails.get('phoneNumber');
		newCustomer.MailingStreet = (String) addressDetails.get('street');
		newCustomer.SAP_MailingAddress2__c = (String) addressDetails.get('address2');
		newCustomer.MailingCity = (String) addressDetails.get('city');
		newCustomer.MailingState = (String) addressDetails.get('state');
		newCustomer.MailingPostalCode = (String) addressDetails.get('zipCode');
		newCustomer.MailingCountry = (String) addressDetails.get('country');

		Database.insert(newCustomer, AccessLevel.USER_MODE);

		return newCustomer;
	}

	private static Map<String, Object> createWorkOrderForCustomer(Contact customer, Map<String, Object> workOrderData) {
		String recordId = (String) workOrderData.get('recordId');

		Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');
		Map<String, Object> address = (Map<String, Object>) customerDetails.get('address');

		IndividualApplication individualAppWorkOrder;

		if (String.isNotBlank(recordId)) {
			individualAppWorkOrder = [
				SELECT
					Id,
					SAP_Destination__c,
					LicenseTypeId,
					Category,
					Contact__c,
					AppliedDate,
					SAP_Last_Name__c,
					SAP_Middle_Name__c,
					SAP_First_Name__c,
					SAP_Address_Line_1__c,
					SAP_Suite_Apartment_Floor__c,
					SAP_City__c,
					SAP_State__c,
					SAP_Country__c,
					SAP_Zip_Code__c,
					SAP_Organization_Name__c,
					SAP_Email_Address__c,
					SAP_Sequence_Number__c,
					SAP_Cell_Phone_Number__c,
					SAP_Work_Order_Status__c,
					SAP_Work_Order_Comments__c
				FROM IndividualApplication
				WHERE Id = :recordId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
		} else {
			// Create new work order
			individualAppWorkOrder = new IndividualApplication();
			individualAppWorkOrder.RecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SObjectType = 'IndividualApplication' AND DeveloperName = 'FinSys'
				WITH SECURITY_ENFORCED
				LIMIT 1
			]
			.Id;
			// Map work order-specific fields
			individualAppWorkOrder.SAP_Destination__c = 'Destination';
			individualAppWorkOrder.LicenseTypeId = '0eh3S0000003Ix2QAE';
			individualAppWorkOrder.Category = 'License';
		}

		// Map fields from the passed customer object
		individualAppWorkOrder.Contact__c = customer.Id;
		individualAppworkOrder.SAP_Last_Name__c = (String) customerDetails.get('lastName');
		individualAppworkOrder.SAP_Middle_Name__c = (String) customerDetails.get('middleInitial');
		individualAppworkOrder.SAP_First_Name__c = (String) customerDetails.get('firstName');
		individualAppworkOrder.SAP_Organization_Name__c = (String) customerDetails.get('organizationName');
		individualAppWorkOrder.SAP_Email_Address__c = (String) customerDetails.get('emailAddress');
		individualAppworkOrder.SAP_Cell_Phone_Number__c = (String) customerDetails.get('phoneNumber');
		individualAppworkOrder.SAP_Address_Line_1__c = (String) address.get('street');
		individualAppworkOrder.SAP_Suite_Apartment_Floor__c = (String) address.get('address2');
		individualAppworkOrder.SAP_City__c = (String) address.get('city');
		individualAppworkOrder.SAP_State__c = (String) address.get('state');
		individualAppworkOrder.SAP_Country__c = (String) address.get('country');
		individualAppworkOrder.SAP_Zip_Code__c = (String) address.get('zipCode');

		individualAppWorkOrder.AppliedDate = workOrderData.get('workOrderDate') != null
			? DateTime.newInstance(Date.valueOf((String) workOrderData.get('workOrderDate')), Time.newInstance(0, 0, 0, 0))
			: null;

		individualAppworkOrder.SAP_Work_Order_Status__c = (String) workOrderData.get('workOrderStatus');
		individualAppWorkOrder.SAP_Work_Order_Comments__c = (String) workOrderData.get('comment');

		// Perform Insert or Update
		if (String.isNotBlank(recordId)) {
			Database.update(individualAppWorkOrder, AccessLevel.USER_MODE);
		} else {
			Database.insert(individualAppWorkOrder, AccessLevel.USER_MODE);
		}

		return new Map<String, Object>{ 'id' => individualAppWorkOrder.Id, 'sequenceNumber' => individualAppWorkOrder.SAP_Sequence_Number__c };
	}

	private static void upsertTransactionFeeAndItem(List<Object> tnxTransactions, Id workOrderId, Date workOrderDate, Id batchId) {
		// Fetch Record Type IDs
		Id newTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByName().get('New Transaction').getRecordTypeId();
		Id createTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByName().get('Create Transaction').getRecordTypeId();

		// Lists to hold records for bulk upsert
		List<RegulatoryTrxnFee> regulatoryFees = new List<RegulatoryTrxnFee>();
		List<RegulatoryTrxnFeeItem> feeItems = new List<RegulatoryTrxnFeeItem>();

		// Get existing fees for this work order to check for updates
		Map<String, RegulatoryTrxnFee> existingFees = new Map<String, RegulatoryTrxnFee>();
		for (RegulatoryTrxnFee fee : [
			SELECT
				Id,
				ParentRecordId,
				SAP_Payment_Collection__c,
				SAP_Payment_Type__c,
				SAP_Card_Type__c,
				SAP_Card_Number__c,
				SAP_CK_Number__c,
				SAP_Money_Order_Number__c,
				SAP_Amount__c,
				SAP_Transaction_Date__c,
				SAP_Batch_Look_Up__c
			FROM RegulatoryTrxnFee
			WHERE ParentRecordId = :workOrderId
			WITH SECURITY_ENFORCED
		]) {
			if (fee != null) {
				existingFees.put(fee.Id, fee);
			}
		}

		// Map to store fee Id to existing fee items
		Map<Id, RegulatoryTrxnFeeItem> existingFeeItems = new Map<Id, RegulatoryTrxnFeeItem>();
		for (RegulatoryTrxnFeeItem item : [
			SELECT Id, RegulatoryTrxnFeeId, SAP_Select_Activity__c, SAP_Select_Sub_Activity__c, SAP_Select_Program_Code__c, FeeAmount, SAP_Tax_Exempt__c, SAP_Transaction_Date__c,SAP_Notary_First_Name__c, SAP_Notary_Last_Name__c 
			FROM RegulatoryTrxnFeeItem
			WHERE RegulatoryTrxnFeeId IN :existingFees.values()
			WITH SECURITY_ENFORCED
		]) {
			existingFeeItems.put(item.RegulatoryTrxnFeeId, item);
		}

		// Loop through each tnxTransaction
		for (Object tnxTransaction : tnxTransactions) {
			Map<String, Object> payment = (Map<String, Object>) tnxTransaction;
			String transactionId = (String) payment.get('tnxId');

			// Check if fee already exists
			RegulatoryTrxnFee regFee;
			if (transactionId != null) {
				if (existingFees.containsKey(transactionId)) {
					regFee = existingFees.get(transactionId);
				}
			} else {
				regFee = new RegulatoryTrxnFee();
				regFee.RecordTypeId = newTransactionRecordTypeId;
				regFee.ParentRecordId = workOrderId;
				regFee.Status = 'Draft';
			}

			// Update/Set fee fields
			String paymentAmount = (String) payment.get('paymentAmount');
			String paymentType = (String) payment.get('paymentType');
			regFee.SAP_Batch_Look_Up__c = batchId;
			regFee.SAP_Payment_Collection__c = (String) payment.get('paymentCollection');
			regFee.SAP_Payment_Type__c = paymentType;
			regFee.SAP_Card_Type__c = (String) payment.get('cardType');
			regFee.SAP_Transaction_Date__c = workOrderDate;
			regFee.SAP_Tax_Exempt__c = (Boolean) payment.get('taxExempt');
			regFee.SAP_Reporting_Only__c = (Boolean) payment.get('reportingOnly');

			// Map optional fields with casting
			if (payment.containsKey('cardDigit') && payment.get('cardDigit') != null) {
				regFee.SAP_Card_Number__c = Decimal.valueOf(String.valueOf(payment.get('cardDigit')));
			}
			if (payment.containsKey('ckNumber') && payment.get('ckNumber') != null) {
				regFee.SAP_CK_Number__c = Decimal.valueOf(String.valueOf(payment.get('ckNumber')));
			}
			if (payment.containsKey('serialNumber') && payment.get('serialNumber') != null) {
				regFee.SAP_Money_Order_Number__c = Decimal.valueOf(String.valueOf(payment.get('serialNumber')));
			}
			regFee.SAP_Amount__c = Decimal.valueOf(paymentAmount);

			regulatoryFees.add(regFee);
		}

		// Upsert the RegulatoryTrxnFee records
		if (!regulatoryFees.isEmpty()) {
			Database.upsert(regulatoryFees, AccessLevel.USER_MODE);

			// Create or update corresponding RegulatoryTrxnFeeItem records
			for (Integer i = 0; i < regulatoryFees.size(); i++) {
				RegulatoryTrxnFee insertedFee = regulatoryFees[i];
				Map<String, Object> tnxPayment = (Map<String, Object>) tnxTransactions[i];

				// Check if fee item exists
				RegulatoryTrxnFeeItem feeItem;
				if (existingFeeItems.containsKey(insertedFee.Id)) {
					feeItem = existingFeeItems.get(insertedFee.Id);
				} else {
					feeItem = new RegulatoryTrxnFeeItem();
					feeItem.RecordTypeId = createTransactionRecordTypeId;
					feeItem.RegulatoryTrxnFeeId = insertedFee.Id;
				}

				// Update/Set fee item fields
				feeItem.Name = 'Fee Item for ' + tnxPayment.get('activity');
				feeItem.SAP_Payment_Type__c = insertedFee.SAP_Payment_Type__c;
				feeItem.SAP_Select_Activity__c = (String) tnxPayment.get('activity');
				feeItem.SAP_Transaction_Date__c = workOrderDate;
				feeItem.SAP_Select_Sub_Activity__c = (String) tnxPayment.get('activityCode');
				feeItem.SAP_Select_Program_Code__c = (String) tnxPayment.get('programCode');
				feeItem.FeeAmount = tnxPayment.containsKey('paymentAmount') ? Decimal.valueOf(String.valueOf(tnxPayment.get('paymentAmount'))) : null;
				feeItem.SAP_Tax_Exempt__c = tnxPayment.containsKey('taxExempt') ? (Boolean) tnxPayment.get('taxExempt') : false;
				feeItem.SAP_Notary_First_Name__c = (String) tnxPayment.get('trxnLastName');
				feeItem.SAP_Notary_Last_Name__c = (String) tnxPayment.get('trxnFirstName');

				feeItems.add(feeItem);
			}

			// Upsert the RegulatoryTrxnFeeItem records
			if (!feeItems.isEmpty()) {
				Database.upsert(feeItems, AccessLevel.System_MODE);
			}
		}
	}

	private static void uploadAndLinkDocuments(Map<String, Object> workOrderData, Id individualApplicationId) {
		try {
			// Step 1: Delete documents specified in deletedFiles
			if (workOrderData.containsKey('deletedFiles')) {
				List<Object> rawDeletedFileIds = (List<Object>) workOrderData.get('deletedFiles');
				List<String> deletedFileIds = new List<String>();

				for (Object fileId : rawDeletedFileIds) {
					deletedFileIds.add((String) fileId);
				}

				if (!deletedFileIds.isEmpty()) {
					List<ContentDocumentLink> linksToDelete = [
						SELECT Id, ContentDocumentId
						FROM ContentDocumentLink
						WHERE ContentDocumentId IN :deletedFileIds AND LinkedEntityId = :individualApplicationId
						WITH SECURITY_ENFORCED
					];
					database.delete(linksToDelete, AccessLevel.USER_MODE);
				}
			}

			// Step 2: Handle new and updated documents
			List<ContentVersion> contentVersionsToInsertOrUpdate = new List<ContentVersion>();
			Map<String, String> documentToTypeMap = new Map<String, String>();

			// Query existing documents linked to the application
			Map<String, ContentDocumentLink> existingLinksMap = new Map<String, ContentDocumentLink>();
			List<ContentDocumentLink> existingLinks = [
				SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
				FROM ContentDocumentLink
				WHERE LinkedEntityId = :individualApplicationId
				WITH SECURITY_ENFORCED
			];

			for (ContentDocumentLink link : existingLinks) {
				existingLinksMap.put(link.ContentDocumentId, link);
			}

			// Process documents
			if (workOrderData.containsKey('documents')) {
				List<Object> documents = (List<Object>) workOrderData.get('documents');
				for (Object docObj : documents) {
					Map<String, Object> document = (Map<String, Object>) docObj;

					if (document != null) {
						String docType = (String) document.get('docType');
						String existingDocId = document.containsKey('documentId') ? (String) document.get('documentId') : null;

						// Retrieve nested `docFile` object
						Map<String, Object> docFile = document.containsKey('docFile') ? (Map<String, Object>) document.get('docFile') : null;

						if (docFile != null) {
							String fileName = (String) docFile.get('fileName');
							String base64Data = (String) docFile.get('base64Data');
							String contentType = (String) docFile.get('contentType');

							// Validate base64Data and fileName
							if (String.isNotBlank(base64Data) && String.isNotBlank(fileName)) {
								// Create or update ContentVersion
								ContentVersion contentVersion = new ContentVersion();
								contentVersion.Title = fileName;
								contentVersion.PathOnClient = fileName;
								contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);

								if (existingDocId != null && existingLinksMap.containsKey(existingDocId)) {
									// Update existing document by linking new version
									contentVersion.ContentDocumentId = existingDocId;
								}
								contentVersionsToInsertOrUpdate.add(contentVersion);

								documentToTypeMap.put(existingDocId != null ? existingDocId : contentVersion.Id, docType);
							}
						}
					}
				}
			}

			// Upsert ContentVersion records
			if (!contentVersionsToInsertOrUpdate.isEmpty()) {
				Database.insert(contentVersionsToInsertOrUpdate, AccessLevel.USER_MODE);

				// Fetch newly created ContentDocuments for linking
				List<ContentDocument> contentDocuments = [
					SELECT Id
					FROM ContentDocument
					WHERE
						Id IN (
							SELECT ContentDocumentId
							FROM ContentVersion
							WHERE Id IN :contentVersionsToInsertOrUpdate
						)
					WITH SECURITY_ENFORCED
				];

				// Step 3: Link documents and associate docType
				List<ContentDocumentLink> documentLinksToInsert = new List<ContentDocumentLink>();
				for (ContentDocument contentDocument : contentDocuments) {
					if (!existingLinksMap.containsKey(contentDocument.Id)) {
						ContentDocumentLink link = new ContentDocumentLink();
						link.ContentDocumentId = contentDocument.Id;
						link.LinkedEntityId = individualApplicationId;
						link.ShareType = 'I';
						link.Visibility = 'AllUsers';
						documentLinksToInsert.add(link);
					}
				}

				if (!documentLinksToInsert.isEmpty()) {
					Database.insert(documentLinksToInsert, AccessLevel.USER_MODE);
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException('An error occurred while uploading and linking documents: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> getWorkOrderDetailsUpdated(String requestData) {
		try {
			// Deserialize input
			Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String workOrderId = (String) params.get('workOrderId');
			String transactionType = (String) params.get('transactionType');

			if (String.isBlank(workOrderId)) {
				throw new AuraHandledException('Work Order ID is required.');
			}

			// Fetch the work order
			IndividualApplication workOrder = [
				SELECT
					Id,
					SAP_Destination__c,
					LicenseTypeId,
					Category,
					Contact__c,
					Contact__r.SAP_Customer_Account_Balance__c,
					AppliedDate,
					SAP_Last_Name__c,
					SAP_Middle_Name__c,
					SAP_First_Name__c,
					SAP_Address_Line_1__c,
					SAP_Suite_Apartment_Floor__c,
					SAP_City__c,
					SAP_State__c,
					SAP_Country__c,
					SAP_Zip_Code__c,
					SAP_Organization_Name__c,
					SAP_Email_Address__c,
					SAP_Cell_Phone_Number__c,
					SAP_Work_Order_Status__c,
					SAP_Work_Order_Comments__c
				FROM IndividualApplication
				WHERE Id = :workOrderId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			// Fetch transactions (fees) and their items
			List<RegulatoryTrxnFee> txnFees = [
				SELECT
					Id,
					RecordType.Name,
					ParentRecordId,
					SAP_Batch_Look_Up__c,
					Status,
					SAP_Payment_Collection__c,
					SAP_Payment_Type__c,
					SAP_Card_Type__c,
					SAP_Card_Number__c,
					SAP_CK_Number__c,
					SAP_Money_Order_Number__c,
					SAP_Amount__c,
					TotalFeeAmount,
					SAP_Transaction_Date__c,
					SAP_Tax_Exempt__c,
					SAP_Reporting_Only__c,
					SAP_Batch_Look_Up__r.CreatedDate,
					SAP_Batch_Look_Up__r.SAP_Batch_Name__c
				FROM RegulatoryTrxnFee
				WHERE ParentRecordId = :workOrderId
				WITH SECURITY_ENFORCED
			];

			List<RegulatoryTrxnFeeItem> txnFeeItems = [
				SELECT Id, RegulatoryTrxnFeeId, SAP_Select_Activity__c, SAP_Select_Sub_Activity__c, SAP_Select_Program_Code__c, FeeAmount, SAP_Transaction_Date__c, SAP_Tax_Exempt__c, SAP_Notary_First_Name__c, SAP_Notary_Last_Name__c  
				FROM RegulatoryTrxnFeeItem
				WHERE RegulatoryTrxnFeeId IN :txnFees
				WITH SECURITY_ENFORCED
			];

			// Map Fee ID to Fee Items
			Map<Id, RegulatoryTrxnFeeItem> feeItemMap = new Map<Id, RegulatoryTrxnFeeItem>();
			for (RegulatoryTrxnFeeItem item : txnFeeItems) {
				feeItemMap.put(item.RegulatoryTrxnFeeId, item);
			}

			// Fetch documents linked to the work order
			List<ContentDocumentLink> documentLinks = [
				SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
				FROM ContentDocumentLink
				WHERE LinkedEntityId = :workOrderId
				WITH SECURITY_ENFORCED
			];

			// Map document links to FileInfo objects
			List<Map<String, Object>> documentList = new List<Map<String, Object>>();
			for (ContentDocumentLink link : documentLinks) {
				documentList.add(
					new Map<String, Object>{
						'title' => link.ContentDocument.Title,
						'documentId' => link.ContentDocumentId,
						'versionId' => link.ContentDocument.LatestPublishedVersionId,
						'id' => link.Id
					}
				);
			}

			// Combine transactions with fee items
			List<Map<String, Object>> transactions = new List<Map<String, Object>>();
			for (RegulatoryTrxnFee fee : txnFees) {
				RegulatoryTrxnFeeItem feeItem = feeItemMap.get(fee.Id);
				if (fee.RecordType.Name == 'New Transaction') {
					transactions.add(
						new Map<String, Object>{
							'id' => fee.Id,
							'tnxId' => fee.Id,
							'activity' => feeItem != null ? feeItem.SAP_Select_Activity__c : null,
							'activityCode' => feeItem != null ? feeItem.SAP_Select_Sub_Activity__c : null,
							'programCode' => feeItem != null ? feeItem.SAP_Select_Program_Code__c : null,
							'feeAmount' => feeItem != null && feeItem.FeeAmount != null ? String.valueOf(feeItem.FeeAmount) : null,
							'taxExempt' => fee.SAP_Tax_Exempt__c,
							'reportingOnly' => fee.SAP_Reporting_Only__c,
							'transactionDate' => fee.SAP_Transaction_Date__c != null ? String.valueOf(fee.SAP_Transaction_Date__c) : null,
							'paymentCollection' => fee.SAP_Payment_Collection__c,
							'paymentType' => fee.SAP_Payment_Type__c,
							'cardType' => fee.SAP_Card_Type__c,
							'cardDigit' => fee.SAP_Card_Number__c,
							'serialNumber' => fee.SAP_Money_Order_Number__c,
							'ckNumber' => fee.SAP_CK_Number__c,
							'paymentAmount' => fee.TotalFeeAmount != null ? String.valueOf(fee.TotalFeeAmount) : null,
							'batchId' => fee.SAP_Batch_Look_Up__r.Id,
							'recordType' => fee.RecordType.Name,
							'trxnLastName' => feeItem != null ? feeItem.SAP_Notary_Last_Name__c : null,
							'trxnFirstName' => feeItem != null ? feeItem.SAP_Notary_First_Name__c : null
						}
					);
				}
			}

			// Extract batch ID and date
			Id batchId = txnFees.isEmpty() ? null : txnFees[0].SAP_Batch_Look_Up__c;
			Date batchDate = txnFees.isEmpty() || txnFees[0].SAP_Batch_Look_Up__r.CreatedDate == null ? null : txnFees[0].SAP_Batch_Look_Up__r.CreatedDate.date();

			String defaultActivity = txnFees.isEmpty() ? null : txnFees[0].SAP_Batch_Look_Up__r.SAP_Batch_Name__c;

			// Prepare response
			Map<String, Object> response = new Map<String, Object>();
			response.put(
				'workOrder',
				new Map<String, Object>{
					'id' => workOrder.Id,
					'destination' => workOrder.SAP_Destination__c,
					'licenseTypeId' => workOrder.LicenseTypeId,
					'category' => workOrder.Category,
					'contactId' => workOrder.Contact__c,
					'lastName' => workOrder.SAP_Last_Name__c,
					'middleName' => workOrder.SAP_Middle_Name__c,
					'firstName' => workOrder.SAP_First_Name__c,
					'addressLine1' => workOrder.SAP_Address_Line_1__c,
					'suiteApartmentFloor' => workOrder.SAP_Suite_Apartment_Floor__c,
					'city' => workOrder.SAP_City__c,
					'state' => workOrder.SAP_State__c,
					'country' => workOrder.SAP_Country__c,
					'zipCode' => workOrder.SAP_Zip_Code__c,
					'organizationName' => workOrder.SAP_Organization_Name__c,
					'emailAddress' => workOrder.SAP_Email_Address__c,
					'phoneNumber' => workOrder.SAP_Cell_Phone_Number__c,
					'status' => workOrder.SAP_Work_Order_Status__c,
					'woDate' => workOrder.AppliedDate.date(),
					'comments' => workOrder.SAP_Work_Order_Comments__c,
					'customerAccountBal' => workOrder.Contact__r.SAP_Customer_Account_Balance__c
				}
			);

			if (transactionType == 'Refund Transaction') {
				// Fetch all refund transactions linked to the work order
				List<RegulatoryTrxnFee> refundPayments = [
					SELECT
						Id,
						Name,
						RecordType.Name,
						SAP_Refund_ID__c,
						Related_to_Transaction__c,
						SAP_Payment_Type__c,
						TotalFeeAmount,
						SAP_Refund_Voucher_ID__c,
						SAP_Refund_Reason__c,
						SAP_Transaction_Date__c,
						SAP_Transaction_Status__c
					FROM RegulatoryTrxnFee
					WHERE ParentRecordId = :workOrderId AND RecordType.Name = 'Refund Transaction'
					WITH SECURITY_ENFORCED
				];

				// Fetch associated refund items for each refund transaction
				List<RegulatoryTrxnFeeItem> refundFeeItems = [
					SELECT Id, RegulatoryTrxnFeeId, FeeAmount, CreatedDate, SAP_Transaction_Date__c
					FROM RegulatoryTrxnFeeItem
					WHERE RegulatoryTrxnFeeId IN :refundPayments
					WITH SECURITY_ENFORCED
				];

				// Map refund transaction IDs to their fee items
				Map<Id, List<RegulatoryTrxnFeeItem>> refundToFeeItemsMap = new Map<Id, List<RegulatoryTrxnFeeItem>>();
				for (RegulatoryTrxnFeeItem feeItem : refundFeeItems) {
					if (!refundToFeeItemsMap.containsKey(feeItem.RegulatoryTrxnFeeId)) {
						refundToFeeItemsMap.put(feeItem.RegulatoryTrxnFeeId, new List<RegulatoryTrxnFeeItem>());
					}
					refundToFeeItemsMap.get(feeItem.RegulatoryTrxnFeeId).add(feeItem);
				}

				// Prepare refund transaction data for response
				List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
				for (RegulatoryTrxnFee refund : refundPayments) {
					DateTime refundDate = refund.SAP_Transaction_Date__c != null ? (DateTime) refund.SAP_Transaction_Date__c : null;
					String formattedrefundDate = refundDate != null ? refundDate.format('MM/dd/yyyy', 'GMT') : null;

					RegulatoryTrxnFee relatedTransaction;
					if (refund.Related_to_Transaction__c != null && refund.SAP_Payment_Type__c == 'Card') {
						relatedTransaction = [
							SELECT SAP_Card_Number__c, Transaction_ID_Count__c
							FROM RegulatoryTrxnFee
							WHERE Id = :refund.Related_to_Transaction__c
							WITH SECURITY_ENFORCED
							LIMIT 1
						];
					}

					refundTransactions.add(
						new Map<String, Object>{
							'id' => refund.Id,
							'refundId' => refund.SAP_Refund_ID__c,
							'originalCardId' => refund.Related_to_Transaction__c != null ? refund.Related_to_Transaction__c : null,
							'originalTransactionId' => refund.Related_to_Transaction__c != null ? relatedTransaction.Transaction_ID_Count__c : null,
							'refundPaymentMethod' => refund.SAP_Payment_Type__c,
							'cardNumber' => relatedTransaction != null ? relatedTransaction.SAP_Card_Number__c : null,
							'refundAmount' => refund.TotalFeeAmount != null ? String.valueOf(refund.TotalFeeAmount) : null,
							'refundDate' => refund.SAP_Transaction_Date__c != null ? refund.SAP_Transaction_Date__c : null,
							'refundDateFormatted' => formattedrefundDate != null ? formattedrefundDate : null,
							'voucherId' => refund.SAP_Refund_Voucher_ID__c,
							'refundReason' => refund.SAP_Refund_Reason__c != null ? refund.SAP_Refund_Reason__c : null,
							'status' => refund.SAP_Transaction_Status__c,
							'recordType' => refund.RecordType.Name
						}
					);
				}

				response.put('refundTransactions', refundTransactions);
			} else {
				response.put('documents', documentList);
			}
			response.put('transactions', transactions);
			response.put('batchId', batchId);
			response.put('defaultActivity', defaultActivity);
			response.put('batchDate', batchDate);

			return response;
		} catch (Exception e) {
			throw new AuraHandledException('An error occurred: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> getWorkOrderDetailsFinsys(String requestData) {
		try {
			// Deserialize the input JSON string
			Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String workOrderId = (String) params.get('workOrderId');
			String transactionType = (String) params.get('transactionType');

			if (String.isBlank(workOrderId)) {
				throw new AuraHandledException('Work Order ID is required.');
			}

			// Fetch the work order
			IndividualApplication workOrder = [
				SELECT
					Id,
					SAP_Destination__c,
					LicenseTypeId,
					Category,
					Contact__c,
					SAP_Last_Name__c,
					SAP_Middle_Name__c,
					SAP_First_Name__c,
					SAP_Address_Line_1__c,
					SAP_Suite_Apartment_Floor__c,
					SAP_City__c,
					SAP_State__c,
					SAP_Country__c,
					SAP_Zip_Code__c,
					SAP_Organization_Name__c,
					SAP_Email_Address__c,
					SAP_Cell_Phone_Number__c,
					SAP_Work_Order_Status__c,
					SAP_Work_Order_Comments__c
				FROM IndividualApplication
				WHERE Id = :workOrderId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			// Fetch the child records
			List<RegulatoryTrxnFee> childRecords = [
				SELECT
					Id,
					ParentRecordId,
					SAP_Payment_Collection__c,
					SAP_Payment_Type__c,
					SAP_Card_Type__c,
					SAP_Card_Number__c,
					SAP_Money_Order_Number__c,
					SAP_CK_Number__c,
					TotalFeeAmount,
					SAP_Transaction_Date__c,
					Status
				FROM RegulatoryTrxnFee
				WHERE ParentRecordId = :workOrderId
				WITH SECURITY_ENFORCED
			];

			List<RegulatoryTrxnFeeItem> subChildRecords = [
				SELECT Id, RegulatoryTrxnFeeId, SAP_Select_Activity__c, SAP_Select_Sub_Activity__c, SAP_Select_Program_Code__c, FeeAmount, CreatedDate
				FROM RegulatoryTrxnFeeItem
				WHERE RegulatoryTrxnFeeId IN :childRecords
				WITH SECURITY_ENFORCED
			];

			// Refund Transaction Flow
			List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
			if (transactionType == 'Refund Transaction') {
				List<RegulatoryTrxnFee> refundPayments = [
					SELECT Id, SAP_Payment_Collection__c, SAP_amount__c, SAP_Payment_Method__c, SAP_Refund_Voucher_ID__c, SAP_Transaction_Date__c, Related_to_Transaction__c
					FROM RegulatoryTrxnFee
					WHERE ParentRecordId = :workOrderId
					WITH SECURITY_ENFORCED
				];

				for (RegulatoryTrxnFee refundPayment : refundPayments) {
					refundTransactions.add(
						new Map<String, Object>{
							'id' => refundPayment.Id,
							'originalTransactionId' => refundPayment.Related_to_Transaction__c,
							'refundPaymentMethod' => refundPayment.SAP_Payment_Method__c,
							'refundAmount' => refundPayment.SAP_amount__c,
							'refundDate' => refundPayment.SAP_Transaction_Date__c
						}
					);
				}
			}

			List<ContentDocumentLink> documentLinks = [
				SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
				FROM ContentDocumentLink
				WHERE LinkedEntityId = :workOrderId
				WITH SECURITY_ENFORCED
			];

			// Map document links to FileInfo objects
			List<FileInfo> documentList = new List<FileInfo>();
			for (ContentDocumentLink link : documentLinks) {
				FileInfo fileInfo = new FileInfo(link.ContentDocument.Title, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId, link.Id);
				documentList.add(fileInfo);
			}

			// Prepare the response
			Map<String, Object> response = new Map<String, Object>();

			// Add Work Order details
			response.put(
				'workOrder',
				new Map<String, Object>{
					'id' => workOrder.Id,
					'destination' => workOrder.SAP_Destination__c,
					'licenseTypeId' => workOrder.LicenseTypeId,
					'category' => workOrder.Category,
					'contactId' => workOrder.Contact__c,
					'lastName' => workOrder.SAP_Last_Name__c,
					'middleName' => workOrder.SAP_Middle_Name__c,
					'firstName' => workOrder.SAP_First_Name__c,
					'addressLine1' => workOrder.SAP_Address_Line_1__c,
					'suiteApartmentFloor' => workOrder.SAP_Suite_Apartment_Floor__c,
					'city' => workOrder.SAP_City__c,
					'state' => workOrder.SAP_State__c,
					'country' => workOrder.SAP_Country__c,
					'zipCode' => workOrder.SAP_Zip_Code__c,
					'organizationName' => workOrder.SAP_Organization_Name__c,
					'emailAddress' => workOrder.SAP_Email_Address__c,
					'phoneNumber' => workOrder.SAP_Cell_Phone_Number__c,
					'status' => workOrder.SAP_Work_Order_Status__c,
					'comments' => workOrder.SAP_Work_Order_Comments__c
				}
			);

			List<Map<String, Object>> transactionList = new List<Map<String, Object>>();

			for (RegulatoryTrxnFeeItem item : subChildRecords) {
				transactionList.add(
					new Map<String, Object>{
						'id' => item.Id,
						'activity' => item.SAP_Select_Activity__c,
						'activityCode' => item.SAP_Select_Sub_Activity__c,
						'programCode' => item.SAP_Select_Program_Code__c,
						'feeAmount' => item.FeeAmount,
						'createdDate' => item.CreatedDate
					}
				);
			}

			response.put('transactions', transactionList);

			List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
			for (RegulatoryTrxnFee payment : childRecords) {
				paymentList.add(
					new Map<String, Object>{
						'id' => payment.Id,
						'paymentCollection' => payment.SAP_Payment_Collection__c,
						'paymentType' => payment.SAP_Payment_Type__c,
						'cardType' => payment.SAP_Card_Type__c,
						'cardDigit' => payment.SAP_Card_Number__c,
						'serialNumber' => payment.SAP_Money_Order_Number__c,
						'ckNumber' => payment.SAP_CK_Number__c,
						'paymentAmount' => payment.TotalFeeAmount,
						'transactionDate' => payment.SAP_Transaction_Date__c,
						'status' => payment.Status
					}
				);
			}

			response.put('payments', paymentList);

			if (transactionType == 'Refund Transaction') {
				// Add refund transaction details
				response.put('refundTransactions', refundTransactions);
			} else {
				response.put('documents', documentList);
			}

			return response;
		} catch (Exception e) {
			throw new AuraHandledException('An error occurred: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> getWorkOrderDetails(String requestData) {
		try {
			// Deserialize the input JSON string
			Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String workOrderId = (String) params.get('workOrderId');
			String activityId = (String) params.get('activityId');
			String transactionType = (String) params.get('transactionType');

			if (String.isBlank(workOrderId)) {
				throw new AuraHandledException('Work Order ID is required.');
			}
			if (String.isBlank(activityId)) {
				throw new AuraHandledException('Activity ID is required.');
			}

			// Fetch the work order
			IndividualApplication workOrder = [
				SELECT
					Id,
					SAP_Destination__c,
					LicenseTypeId,
					Category,
					Contact__c,
					SAP_Last_Name__c,
					SAP_Middle_Name__c,
					SAP_First_Name__c,
					SAP_Address_Line_1__c,
					SAP_Suite_Apartment_Floor__c,
					SAP_City__c,
					SAP_State__c,
					SAP_Country__c,
					SAP_Zip_Code__c,
					SAP_Organization_Name__c,
					SAP_Email_Address__c,
					SAP_Cell_Phone_Number__c,
					SAP_Work_Order_Status__c,
					SAP_Work_Order_Comments__c
				FROM IndividualApplication
				WHERE Id = :workOrderId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			// Fetch all related activities (transactions)
			List<SAP_Activity__c> activities = [
				SELECT Id, Activity_Name__c, Sub_Activity_Name__c, Program_Name__c, FeeAmount__c, TaxExempt__c, TransactionDate__c
				FROM SAP_Activity__c
				WHERE Id = :activityId
				WITH SECURITY_ENFORCED
			];

			Map<Id, Id> paymentToActivityMap = new Map<Id, Id>();
			List<SAP_ActivityTransactionItemMapping__c> mappings = [
				SELECT Regulatory_Transaction_Fee__c, Activity__c, Transaction_Type__c
				FROM SAP_ActivityTransactionItemMapping__c
				WHERE Activity__c = :activityId
				WITH SECURITY_ENFORCED
			];

			// Separate mappings for "New Transaction" and "Refund Transaction"
			Map<Id, Id> refundTransactionMap = new Map<Id, Id>();
			for (SAP_ActivityTransactionItemMapping__c mapping : mappings) {
				if (mapping.Transaction_Type__c == 'New Transaction' && mapping.Regulatory_Transaction_Fee__c != null) {
					paymentToActivityMap.put(mapping.Regulatory_Transaction_Fee__c, mapping.Activity__c);
				} else if (mapping.Transaction_Type__c == 'Refund Transaction' && mapping.Regulatory_Transaction_Fee__c != null) {
					refundTransactionMap.put(mapping.Regulatory_Transaction_Fee__c, mapping.Activity__c);
				}
			}

			// Fetch Payments (New Transactions) from RegulatoryTrxnFee using the Payment IDs
			List<RegulatoryTrxnFee> payments = new List<RegulatoryTrxnFee>();
			Set<String> batchIds = new Set<String>();
			if (!paymentToActivityMap.isEmpty()) {
				payments = [
					SELECT
						Id,
						SAP_Payment_Collection__c,
						SAP_Payment_Type__c,
						SAP_Card_Type__c,
						SAP_Card_Number__c,
						SAP_Batch_Look_Up__c,
						SAP_Money_Order_Number__c,
						SAP_CK_Number__c,
						TotalFeeAmount,
						Status,
						SAP_Transaction_Date__c
					FROM RegulatoryTrxnFee
					WHERE Id IN :paymentToActivityMap.keySet()
					WITH SECURITY_ENFORCED
				];

				for (RegulatoryTrxnFee payment : payments) {
					if (payment.SAP_Batch_Look_Up__c != null) {
						batchIds.add(payment.SAP_Batch_Look_Up__c);
					}
				}
			}

			// Refund Transaction Flow
			List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
			if (transactionType == 'Refund Transaction' && !refundTransactionMap.isEmpty()) {
				List<RegulatoryTrxnFee> refundPayments = [
					SELECT Id, SAP_Payment_Collection__c, SAP_amount__c, SAP_Payment_Method__c, SAP_Refund_Voucher_ID__c, SAP_Transaction_Date__c, Related_to_Transaction__c
					FROM RegulatoryTrxnFee
					WHERE Id IN :refundTransactionMap.keySet()
					WITH SECURITY_ENFORCED
				];

				for (RegulatoryTrxnFee refundPayment : refundPayments) {
					refundTransactions.add(
						new Map<String, Object>{
							'id' => refundPayment.Id,
							'originalTransactionId' => refundPayment.Related_to_Transaction__c,
							'refundPaymentMethod' => refundPayment.SAP_Payment_Method__c,
							'refundAmount' => refundPayment.SAP_amount__c,
							'refundDate' => refundPayment.SAP_Transaction_Date__c
						}
					);
				}
			}

			// Fetch documents linked to the work order
			List<ContentDocumentLink> documentLinks = [
				SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
				FROM ContentDocumentLink
				WHERE LinkedEntityId = :workOrderId
				WITH SECURITY_ENFORCED
			];

			// Map document links to FileInfo objects
			List<FileInfo> documentList = new List<FileInfo>();
			for (ContentDocumentLink link : documentLinks) {
				FileInfo fileInfo = new FileInfo(link.ContentDocument.Title, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId, link.Id);
				documentList.add(fileInfo);
			}

			// Prepare the response
			Map<String, Object> response = new Map<String, Object>();

			// Add Work Order details
			response.put(
				'workOrder',
				new Map<String, Object>{
					'id' => workOrder.Id,
					'destination' => workOrder.SAP_Destination__c,
					'licenseTypeId' => workOrder.LicenseTypeId,
					'category' => workOrder.Category,
					'contactId' => workOrder.Contact__c,
					'lastName' => workOrder.SAP_Last_Name__c,
					'middleName' => workOrder.SAP_Middle_Name__c,
					'firstName' => workOrder.SAP_First_Name__c,
					'addressLine1' => workOrder.SAP_Address_Line_1__c,
					'suiteApartmentFloor' => workOrder.SAP_Suite_Apartment_Floor__c,
					'city' => workOrder.SAP_City__c,
					'state' => workOrder.SAP_State__c,
					'country' => workOrder.SAP_Country__c,
					'zipCode' => workOrder.SAP_Zip_Code__c,
					'organizationName' => workOrder.SAP_Organization_Name__c,
					'emailAddress' => workOrder.SAP_Email_Address__c,
					'phoneNumber' => workOrder.SAP_Cell_Phone_Number__c,
					'status' => workOrder.SAP_Work_Order_Status__c,
					'comments' => workOrder.SAP_Work_Order_Comments__c
				}
			);

			// Add activities as transactions
			List<Map<String, Object>> transactionList = new List<Map<String, Object>>();
			for (SAP_Activity__c activity : activities) {
				transactionList.add(
					new Map<String, Object>{
						'id' => activity.Id,
						'activity' => activity.Activity_Name__c,
						'activityCode' => activity.Sub_Activity_Name__c,
						'programCode' => activity.Program_Name__c,
						'feeAmount' => activity.FeeAmount__c,
						'taxExempt' => activity.TaxExempt__c,
						'transactionDate' => activity.TransactionDate__c
					}
				);
			}
			response.put('transactions', transactionList);

			// Add payments to the response, including activityId
			List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
			for (RegulatoryTrxnFee payment : payments) {
				paymentList.add(
					new Map<String, Object>{
						'id' => payment.Id,
						'paymentCollection' => payment.SAP_Payment_Collection__c,
						'paymentType' => payment.SAP_Payment_Type__c,
						'cardType' => payment.SAP_Card_Type__c,
						'cardDigit' => payment.SAP_Card_Number__c,
						'serialNumber' => payment.SAP_Money_Order_Number__c,
						'ckNumber' => payment.SAP_CK_Number__c,
						'paymentAmount' => payment.TotalFeeAmount,
						'transactionDate' => payment.SAP_Transaction_Date__c,
						'status' => payment.Status,
						'activityId' => paymentToActivityMap.get(payment.Id)
					}
				);
			}
			response.put('payments', paymentList);

			// Add batchID (single value, or empty if no batch IDs exist)
			response.put('batchID', batchIds.isEmpty() ? null : batchIds.iterator().next());

			// Add documents
			if (transactionType == 'Refund Transaction') {
				// Add refund transaction details
				response.put('refundTransactions', refundTransactions);
			} else {
				response.put('documents', documentList);
			}

			return response;
		} catch (Exception e) {
			throw new AuraHandledException('An error occurred: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> updateWorkOrder(String workOrderDataJson) {
		try {
			// Deserialize the JSON input
			Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(workOrderDataJson);
			String batchId = (String) workOrderData.get('batchId');
			String workOrderId = (String) workOrderData.get('recordId');
			String defaultActivity = (String) workOrderData.get('defaultActivity');
			String updatedActivity = (String) workOrderData.get('updatedActivity');
			Date workOrderDate = Date.valueOf(String.valueOf(workOrderData.get('workOrderDate')));

			Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');

			String errorMessage = '';
			SAP_Batch__c batchToUse = null;

			if (String.isNotBlank(batchId)) {
				List<SAP_Batch__c> batches = [
					SELECT Id, SAP_Batch_Status__c, SAP_Batch_Name__c, SAP_Batch_Date__c
					FROM SAP_Batch__c
					WHERE Id = :batchId AND SAP_Batch_Date__c = :workOrderDate AND SAP_Batch_Name__c = :defaultActivity
					WITH SECURITY_ENFORCED
					LIMIT 1
				];

				if (!batches.isEmpty()) {
					// Check status even when found by batchId
					if (batches[0].SAP_Batch_Status__c == 'Sealed' || batches[0].SAP_Batch_Status__c == 'Closed') {
						DateTime batchDateTime = (DateTime) batches[0].SAP_Batch_Date__c;
						String formattedDate = batchDateTime.format('MM/dd/yyyy', 'GMT');

						errorMessage = 'Batch "' + batches[0].SAP_Batch_Name__c + '" for date "' + formattedDate + '" is currently "' + batches[0].SAP_Batch_Status__c + '"';
						throw new AuraHandledException(errorMessage);
					}
					batchToUse = batches[0];
				}
			}

			// Step 3: If batch not found by ID, search by defaultActivity and date
			if (batchToUse == null && String.isNotBlank(defaultActivity) && workOrderDate != null) {
				List<SAP_Batch__c> batches = [
					SELECT Id, SAP_Batch_Status__c, SAP_Batch_Name__c, SAP_Batch_Date__c
					FROM SAP_Batch__c
					WHERE SAP_Batch_Name__c = :defaultActivity AND SAP_Batch_Date__c = :workOrderDate
					WITH SECURITY_ENFORCED
					LIMIT 1
				];

				if (!batches.isEmpty()) {
					// Check status for batch found by defaultActivity
					if (batches[0].SAP_Batch_Status__c == 'Sealed' || batches[0].SAP_Batch_Status__c == 'Closed') {
						DateTime batchDateTime = (DateTime) batches[0].SAP_Batch_Date__c;
						String formattedDate = batchDateTime.format('MM/dd/yyyy', 'GMT');

						errorMessage = 'Batch "' + batches[0].SAP_Batch_Name__c + '" for date "' + Date.valueOf(formattedDate) + '" is currently "' + batches[0].SAP_Batch_Status__c + '"';
						throw new AuraHandledException(errorMessage);
					}
					batchToUse = batches[0];
				}
			}

			// Step 4: Handle case when no batch is found
			if (batchToUse == null) {
				SAP_Batch__c newBatch = new SAP_Batch__c();
				newBatch.SAP_Batch_Name__c = defaultActivity;
				newBatch.Name = defaultActivity;
				newBatch.SAP_Batch_Status__c = 'Open';
				newBatch.SAP_Batch_Date__c = workOrderDate;
				Database.insert(newBatch, AccessLevel.USER_MODE);

				batchId = newBatch.Id;
			}

			// Step 2: Update Work Order
			String selectedCustomerId = (String) workOrderData.get('selectedCustomerId');

			Contact customer = [
				SELECT
					Id,
					LastName,
					FirstName,
					MiddleName,
					SAP_Organization__c,
					Email,
					Phone,
					MailingStreet,
					SAP_MailingAddress2__c,
					MailingCity,
					MailingState,
					MailingCountry,
					MailingPostalCode
				FROM Contact
				WHERE Id = :selectedCustomerId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			Map<String, Object> workOrderResult = createWorkOrderForCustomer(customer, workOrderData);

			// Step 3: Update Activities
			List<Object> rawTransactions = (List<Object>) workOrderData.get('transactions');
			if (rawTransactions != null && !rawTransactions.isEmpty()) {
				upsertTransactionFeeAndItem(rawTransactions, workOrderId, workOrderDate, batchId);
			}

			uploadAndLinkDocuments(workOrderData, workOrderId);

			return workOrderResult;
		} catch (AuraHandledException ahe) {
			throw ahe;
		} catch (Exception e) {
			throw new AuraHandledException('Error updating Work Order: ' + e.getMessage());
		}
	}

	private static void updateActivitiesAndFees(List<Object> transactionDataList) {
		try {
			// Lists to hold records for update
			List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();
			List<RegulatoryTrxnFee> feesToUpdate = new List<RegulatoryTrxnFee>();

			for (Object trxObj : transactionDataList) {
				if (!(trxObj instanceof Map<String, Object>)) {
					continue;
				}

				Map<String, Object> trxData = (Map<String, Object>) trxObj;
				String transactionId = (String) trxData.get('Id');
				String feeId = (String) trxData.get('tnxId');

				// Update Fee Item
				if (String.isNotBlank(transactionId)) {
					RegulatoryTrxnFeeItem feeItem = [
						SELECT
							Id,
							Name,
							SAP_Select_Activity__c,
							SAP_Select_Sub_Activity__c,
							SAP_Select_Program_Code__c,
							FeeAmount,
							SAP_Tax_Exempt__c,
							SAP_Transaction_Date__c,
							RegulatoryTrxnFeeId
						FROM RegulatoryTrxnFeeItem
						WHERE RegulatoryTrxnFeeId = :transactionId
						WITH SECURITY_ENFORCED
						LIMIT 1
					];

					feeItem.SAP_Select_Activity__c = (String) trxData.get('activity');
					feeItem.SAP_Select_Sub_Activity__c = (String) trxData.get('activityCode');
					feeItem.SAP_Select_Program_Code__c = (String) trxData.get('programCode');
					feeItem.FeeAmount = trxData.containsKey('feeAmount') ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount'))) : null;
					feeItem.SAP_Transaction_Date__c = trxData.containsKey('transactionDate') ? Date.valueOf(String.valueOf(trxData.get('transactionDate'))) : null;
					feeItem.SAP_Tax_Exempt__c = trxData.containsKey('taxExempt') ? (Boolean) trxData.get('taxExempt') : false;

					feeItemsToUpdate.add(feeItem);
				}

				// Update Regulatory Fee
				if (String.isNotBlank(transactionId)) {
					RegulatoryTrxnFee regulatoryFee = [
						SELECT Id, SAP_Payment_Collection__c, SAP_Payment_Type__c, SAP_Card_Type__c, SAP_Card_Number__c, SAP_CK_Number__c, SAP_Money_Order_Number__c, SAP_Amount__c
						FROM RegulatoryTrxnFee
						WHERE Id = :transactionId
						WITH SECURITY_ENFORCED
						LIMIT 1
					];

					regulatoryFee.SAP_Payment_Collection__c = (String) trxData.get('paymentCollection');
					regulatoryFee.SAP_Payment_Type__c = (String) trxData.get('paymentType');
					regulatoryFee.SAP_Card_Type__c = (String) trxData.get('cardType');
					regulatoryFee.SAP_Card_Number__c = trxData.containsKey('cardDigit') && trxData.get('cardDigit') != null
						? Decimal.valueOf(String.valueOf(trxData.get('cardDigit')))
						: null;
					regulatoryFee.SAP_CK_Number__c = trxData.containsKey('ckNumber') && trxData.get('ckNumber') != null ? Decimal.valueOf(String.valueOf(trxData.get('ckNumber'))) : null;
					regulatoryFee.SAP_Money_Order_Number__c = trxData.containsKey('serialNumber') && trxData.get('serialNumber') != null
						? Decimal.valueOf(String.valueOf(trxData.get('serialNumber')))
						: null;
					regulatoryFee.SAP_Amount__c = trxData.containsKey('paymentAmount') && trxData.get('paymentAmount') != null
						? Decimal.valueOf(String.valueOf(trxData.get('paymentAmount')))
						: null;

					feesToUpdate.add(regulatoryFee);
				}
			}

			// Perform batch updates
			if (!feeItemsToUpdate.isEmpty()) {
				Database.update(feeItemsToUpdate, AccessLevel.USER_MODE);
			}

			if (!feesToUpdate.isEmpty()) {
				Database.update(feesToUpdate, AccessLevel.USER_MODE);
			}
		} catch (Exception e) {
			throw new AuraHandledException('Error updating activities and fees: ' + e.getMessage());
		}
	}

	private static void updateActivities(List<Object> transactionDataList) {
		try {
			List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();

			for (Object trxObj : transactionDataList) {
				if (!(trxObj instanceof Map<String, Object>)) {
					continue;
				}

				Map<String, Object> trxData = (Map<String, Object>) trxObj;
				String transactionId = (String) trxData.get('Id');

				if (String.isNotBlank(transactionId)) {
					// Fetch the existing transaction fee item for update
					RegulatoryTrxnFeeItem feeItem = [
						SELECT
							Id,
							Name,
							SAP_Select_Activity__c,
							SAP_Select_Sub_Activity__c,
							SAP_Select_Program_Code__c,
							FeeAmount,
							SAP_Tax_Exempt__c,
							SAP_Transaction_Date__c,
							RegulatoryTrxnFeeId
						FROM RegulatoryTrxnFeeItem
						WHERE Id = :transactionId
						WITH SECURITY_ENFORCED
						LIMIT 1
					];

					// Map fields from the transaction data
					feeItem.SAP_Select_Activity__c = (String) trxData.get('activity');
					feeItem.SAP_Select_Sub_Activity__c = (String) trxData.get('activityCode');
					feeItem.SAP_Select_Program_Code__c = (String) trxData.get('programCode');
					feeItem.FeeAmount = trxData.containsKey('feeAmount') ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount'))) : null;
					feeItem.SAP_Transaction_Date__c = trxData.containsKey('transactionDate') ? Date.valueOf(String.valueOf(trxData.get('transactionDate'))) : null;
					feeItem.SAP_Tax_Exempt__c = trxData.containsKey('taxExempt') ? (Boolean) trxData.get('taxExempt') : false;

					feeItemsToUpdate.add(feeItem);
				}
			}

			// Perform batch update
			if (!feeItemsToUpdate.isEmpty()) {
				Database.update(feeItemsToUpdate, AccessLevel.USER_MODE);
			}
		} catch (Exception e) {
			throw new AuraHandledException('Error updating Regulatory Transaction Fee Items: ' + e.getMessage());
		}
	}

	// Helper class for File Info
	public class FileInfo {
		@AuraEnabled
		public String title { get; set; }
		@AuraEnabled
		public String documentId { get; set; }
		@AuraEnabled
		public String versionId { get; set; }
		@AuraEnabled
		public String Id { get; set; }

		public FileInfo(String title, String documentId, String versionId, String Id) {
			this.title = title;
			this.documentId = documentId;
			this.versionId = versionId;
			this.Id = Id;
		}
	}

	@AuraEnabled
	public static string createRefundTransaction(String refundTransactionJSON) {
		try {
			List<Object> refundTransactions = (List<Object>) JSON.deserializeUntyped(refundTransactionJSON);

			Map<String, Object> refundTransactionData = (Map<String, Object>) refundTransactions[0];

			String recordId = (String) refundTransactionData.get('wordOrderId');
			String selectedRefundCard = (String) refundTransactionData.get('selectedRefundCard');
			String batchId = (String) refundTransactionData.get('batchId');
			String refundMethod = (String) refundTransactionData.get('refundMethod');
			Date refundDate = refundTransactionData.containsKey('refundDate') ? Date.valueOf((String) refundTransactionData.get('refundDate')) : null;
			String voucherId = (String) refundTransactionData.get('voucherId');

			String transactionType = (String) refundTransactionData.get('transactionType');
			String refundReason = (String) refundTransactionData.get('refundReason');

			Map<String, List<RegulatoryTrxnFee>> feesByRecordType = new Map<String, List<RegulatoryTrxnFee>>();
			Map<String, Decimal> totalAmountByRecordType = new Map<String, Decimal>();

			List<RegulatoryTrxnFee> existingFees = [
				SELECT Id, RecordType.DeveloperName, TotalFeeAmount
				FROM RegulatoryTrxnFee
				WHERE ParentRecordId = :recordId
				WITH SECURITY_ENFORCED
			];

			// Categorize fees by record type and calculate totals
			for (RegulatoryTrxnFee fee : existingFees) {
				String recordTypeName = fee.RecordType.DeveloperName;

				// Initialize lists and totals if not exists
				if (!feesByRecordType.containsKey(recordTypeName)) {
					feesByRecordType.put(recordTypeName, new List<RegulatoryTrxnFee>());
					totalAmountByRecordType.put(recordTypeName, 0);
				}

				// Add fee to appropriate list
				feesByRecordType.get(recordTypeName).add(fee);

				// Update total amount
				Decimal currentTotal = totalAmountByRecordType.get(recordTypeName);
				totalAmountByRecordType.put(recordTypeName, currentTotal + (fee.TotalFeeAmount != null ? fee.TotalFeeAmount : 0));
			}

			// Calculate maximum possible refund
			Decimal totalNewTransactions = totalAmountByRecordType.get('New_Transaction') != null ? totalAmountByRecordType.get('New_Transaction') : 0;
			Decimal totalRefunds = totalAmountByRecordType.get('Refund_Transaction') != null ? totalAmountByRecordType.get('Refund_Transaction') : 0;
			Decimal maxPossibleRefund = totalNewTransactions - totalRefunds;

			Decimal refundAmount = refundTransactionData.containsKey('refundAmount') ? Decimal.valueOf((String) refundTransactionData.get('refundAmount')) : 0;

			// Validate refund amount
			if (refundAmount > maxPossibleRefund) {
				String errorMsg =
					'Refund amount $' +
					refundAmount +
					' exceeds the maximum allowed refund of $' +
					maxPossibleRefund +
					'. Total transactions: $' +
					totalNewTransactions +
					', Already refunded: $' +
					totalRefunds;
				AuraHandledException e = new AuraHandledException(errorMsg);
				e.setMessage(errorMsg);
				throw e;
			}
			// Additional validation for card refunds
			if (selectedRefundCard != null && refundMethod == 'Card') {
				// Get the original transaction
				RegulatoryTrxnFee originalTransaction = [
					SELECT Id, TotalFeeAmount
					FROM RegulatoryTrxnFee
					WHERE Id = :selectedRefundCard
					WITH SECURITY_ENFORCED
					LIMIT 1
				];

				// Get all existing refunds for this card transaction
				List<RegulatoryTrxnFee> existingCardRefunds = [
					SELECT Id, TotalFeeAmount, Related_to_Transaction__c
					FROM RegulatoryTrxnFee
					WHERE RecordType.DeveloperName = 'Refund_Transaction' AND Related_to_Transaction__c = :selectedRefundCard
					WITH SECURITY_ENFORCED
				];

				// Calculate total already refunded for this card
				Decimal totalCardRefunds = 0;
				for (RegulatoryTrxnFee refund : existingCardRefunds) {
					totalCardRefunds += (refund.TotalFeeAmount != null ? refund.TotalFeeAmount : 0);
				}

				// Calculate maximum possible refund for this card
				Decimal originalAmount = originalTransaction.TotalFeeAmount != null ? originalTransaction.TotalFeeAmount : 0;
				Decimal maxCardRefund = originalAmount - totalCardRefunds;

				// Validate card refund amount
				if (refundAmount > maxCardRefund) {
					String errorMsg =
						'Card refund amount $' +
						refundAmount +
						' exceeds the maximum allowed refund of $' +
						maxCardRefund +
						' for this card transaction. Original amount: $' +
						originalAmount +
						', Already refunded: $' +
						totalCardRefunds;
					AuraHandledException e = new AuraHandledException(errorMsg);
					e.setMessage(errorMsg);
					throw e;
				}
			}

			Id feeRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

			RegulatoryTrxnFee regulatoryFee = new RegulatoryTrxnFee();
			if (feeRecordTypeId != null) {
				regulatoryFee.RecordTypeId = feeRecordTypeId;
				regulatoryFee.ParentRecordId = recordId;
				regulatoryFee.SAP_Transaction_Status__c = 'Completed';
				regulatoryFee.Status = 'Draft';
				if (refundMethod == 'Card') {
					regulatoryFee.Related_to_Transaction__c = selectedRefundCard;
				}

				// Add all additional fields to Fee
				regulatoryFee.SAP_Payment_Type__c = refundMethod;
				regulatoryFee.SAP_Transaction_Date__c = refundDate;
				regulatoryFee.SAP_Refund_Voucher_ID__c = voucherId;
				regulatoryFee.SAP_Refund_Reason__c = refundReason;
				regulatoryFee.SAP_amount__c = refundAmount;
				regulatoryFee.SAP_Batch_Look_Up__c = batchId;

				Database.insert(regulatoryFee, AccessLevel.USER_MODE);
			}

			// Step 2: Create a Regulatory Transaction Fee Item Record
			Id feeItemRecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SObjectType = 'RegulatoryTrxnFeeItem' AND DeveloperName = 'Refund_Transaction'
				WITH SECURITY_ENFORCED
				LIMIT 1
			]
			.Id;

			RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
			feeItem.RecordTypeId = feeItemRecordTypeId;
			feeItem.RegulatoryTrxnFeeId = regulatoryFee.Id;
			feeItem.FeeAmount = refundAmount;
			feeItem.Name = regulatoryFee.Id;

			// Add all additional fields to Fee Item
			feeItem.SAP_Payment_Type__c = refundMethod;
			feeItem.SAP_Transaction_Date__c = refundDate;
			feeItem.SAP_Refund_Voucher_ID__c = voucherId;
			feeItem.SAP_Refund_Reason__c = refundReason;

			Database.insert(feeItem, AccessLevel.USER_MODE);

			return recordId;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String updateRefundTransaction(String refundTransactionJSON) {
		try {
			// Deserialize the JSON to a list of maps
			List<Object> refundTransactions = (List<Object>) JSON.deserializeUntyped(refundTransactionJSON);

			// Collect IDs to validate records in the database
			Set<Id> feeIds = new Set<Id>();

			// Collect all fee IDs and map them to their refund reasons
			Map<Id, String> feeToReasonMap = new Map<Id, String>();
			for (Object trans : refundTransactions) {
				Map<String, Object> trxn = (Map<String, Object>) trans;
				if (trxn.containsKey('id')) {
					Id feeId = (Id) trxn.get('id');
					String refundReason = (String) trxn.get('refundReason');
					feeIds.add(feeId);
					feeToReasonMap.put(feeId, refundReason);
				}
			}

			// Query for both Fee and Fee Items in one go
			List<RegulatoryTrxnFee> feesToUpdate = [
				SELECT
					Id,
					SAP_Refund_Reason__c,
					(
						SELECT Id, SAP_Refund_Reason__c
						FROM RegulatoryTrxnFeeItems
						WHERE RecordType.DeveloperName = 'Refund_Transaction'
					)
				FROM RegulatoryTrxnFee
				WHERE Id IN :feeIds
				WITH SECURITY_ENFORCED
			];

			List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();

			// Update both Fee and Fee Items
			for (RegulatoryTrxnFee fee : feesToUpdate) {
				String newReason = feeToReasonMap.get(fee.Id);
				fee.SAP_Refund_Reason__c = newReason;

				// Update related fee items
				for (RegulatoryTrxnFeeItem feeItem : fee.RegulatoryTrxnFeeItems) {
					feeItem.SAP_Refund_Reason__c = newReason;
					feeItemsToUpdate.add(feeItem);
				}
			}

			// Perform updates
			if (!feesToUpdate.isEmpty()) {
				Database.update(feesToUpdate, AccessLevel.System_MODE);
			}
			if (!feeItemsToUpdate.isEmpty()) {
				Database.update(feeItemsToUpdate, AccessLevel.System_MODE);
			}

			return 'Success';
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	// method written for fetch data of WOrk Order Object related to BRS.
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getBRSdata(String recordId) {
		Map<String, Object> brsData = new Map<String, Object>();
		Work_Order__c workOrder = [
			SELECT
				Id,
				Status__c,
				CreatedDate,
				Type__c,
				Customer__r.FirstName,
				Customer__r.LastName,
				Customer__r.MiddleName,
				Customer__r.SAP_Organization__c,
				Customer__r.Email,
				Customer__r.Phone,
				Customer__r.SAP_Customer_Account_Balance__c,
				Customer__r.MailingStreet,
				Customer__r.MailingCity,
				Customer__r.MailingState,
				Customer__r.MailingPostalCode,
				Customer__r.MailingCountry
			FROM Work_Order__c
			WHERE Id = :recordId
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
		List<bt_stripe__Transaction__c> transactionData = [
			SELECT
				Id,
				Work_Order__c,
				bt_stripe__Payment_Method__c,
				bt_stripe__Payment_Method__r.bt_stripe__Funding__c,
				bt_stripe__Payment_Method__r.bt_stripe__Brand__c,
				bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c,
				bt_stripe__Payment_Method__r.RecordType.DeveloperName,
				bt_stripe__Amount__c
			FROM bt_stripe__Transaction__c
			WHERE Work_Order__c = :recordId
			WITH SECURITY_ENFORCED
		];

		Map<String, String> typeMap = new Map<String, String>{ 'UCC' => 'UCC Filing', 'Business' => 'Business Filing' };

		List<Map<String, Object>> transactionList = new List<Map<String, Object>>();
		for (bt_stripe__Transaction__c trxn : transactionData) {
			Map<String, Object> transactionMap = new Map<String, Object>();
			transactionMap.put('id', trxn.Id);
			transactionMap.put('category', workOrder.Type__c != null ? typeMap.get(workOrder.Type__c) : '');
			transactionMap.put('paymentMethodId', trxn.bt_stripe__Payment_Method__c);
			transactionMap.put('funding', trxn.bt_stripe__Payment_Method__r.bt_stripe__Funding__c);
			transactionMap.put('brand', trxn.bt_stripe__Payment_Method__r.bt_stripe__Brand__c);
			transactionMap.put('cardLast4Digits', trxn.bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c);
			transactionMap.put('recordType', trxn.bt_stripe__Payment_Method__r.RecordType.DeveloperName);
			transactionMap.put('amount', trxn.bt_stripe__Amount__c);
			transactionList.add(transactionMap);
		}
		brsData.put('transactions', transactionList);

		brsData.put('status', workOrder.Status__c);
		brsData.put('createdDate', workOrder.CreatedDate);
		brsData.put('customerFirstName', workOrder.Customer__r.FirstName);
		brsData.put('customerLastName', workOrder.Customer__r.LastName);
		brsData.put('customerMiddleName', workOrder.Customer__r.MiddleName);
		brsData.put('customerOrganization', workOrder.Customer__r.SAP_Organization__c);
		brsData.put('customerEmail', workOrder.Customer__r.Email);
		brsData.put('customerPhone', workOrder.Customer__r.Phone);
		brsData.put('customerAccountBalance', workOrder.Customer__r.SAP_Customer_Account_Balance__c);
		brsData.put('mailingStreet', workOrder.Customer__r.MailingStreet);
		brsData.put('mailingCity', workOrder.Customer__r.MailingCity);
		brsData.put('mailingState', workOrder.Customer__r.MailingState);
		brsData.put('mailingPostalCode', workOrder.Customer__r.MailingPostalCode);
		brsData.put('mailingCountry', workOrder.Customer__r.MailingCountry);

		return brsData;
	}

	@AuraEnabled
	public static void deleteRegulatoryTransaction(Id recordId) {
		try {
			RegulatoryTrxnFee recordToDelete = [
				SELECT Id
				FROM RegulatoryTrxnFee
				WHERE Id = :recordId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			delete recordToDelete;
		} catch (Exception e) {
			throw new AuraHandledException('Error deleting transaction: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static void updateRefundReason(String jsonRequest) {
		try {
			// Deserialize JSON request
			Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);

			// Extract parameters
			Id recordId = (Id) params.get('recordId');
			String refundReason = (String) params.get('refundReason');

			// Validate inputs
			if (recordId == null || String.isBlank(refundReason)) {
				throw new AuraHandledException('Invalid data: recordId and refundReason are required.');
			}

			// Fetch and update the record
			RegulatoryTrxnFee recordToUpdate = [
				SELECT Id, SAP_Refund_Reason__c
				FROM RegulatoryTrxnFee
				WHERE Id = :recordId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			recordToUpdate.SAP_Refund_Reason__c = refundReason;
			update recordToUpdate;
		} catch (Exception e) {
			throw new AuraHandledException('Error updating refund reason: ' + e.getMessage());
		}
	}
}