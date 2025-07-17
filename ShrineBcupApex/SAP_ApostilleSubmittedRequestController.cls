/* DESCRIPTION:This class handles fetching and processing Apostille submitted requests.
 * It retrieves application data based on user input filters and formats results.
 **********************************************************************************************/
public with sharing class SAP_ApostilleSubmittedRequestController {
	public static final String className = 'SAP_ApostilleSubmittedRequestController';
	public static final String relatedInfoObject = 'IndividualApplication';
	public static final String severity = 'High';

	/**
	 * Retrieves a list of Apostille applications based on user-provided filters.
	 * @param paramsJson A JSON string containing filter criteria.
	 * @return A list of applications formatted as key-value maps.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Map<String, Object>> getApplications(String paramsJson) {
		try {
			String query = buildQuery(paramsJson);
			List<IndividualApplication> applications = Database.query(query, AccessLevel.USER_MODE);
			return processApplicationResults(applications);
		} catch (Exception e) {
			BOS_Utility.ExceptionHandler(className, 'getApplications', relatedInfoObject, null, severity, e, null);
			throw new AuraHandledException('Error fetching data. Please try again later.');
		}
	}

	/**
	 * Builds a dynamic SOQL query based on user-provided filters.
	 * @param paramsJson JSON string with filtering parameters.
	 * @return A dynamically constructed SOQL query string.
	 */
	private static String buildQuery(String paramsJson) {
		Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);

		String workOrder = (String) params.get('workOrder');
		String requestDate = (String) params.get('requestDate');
		String requesterName = (String) params.get('requesterName');
		Integer offsetVal = (Integer) params.get('offsetVal');
		Integer pageSize = (Integer) params.get('pageSize');
		String sortBy = (String) params.get('sortBy');
		String sortDirection = (String) params.get('sortDirection');
		String documentType = (String) params.get('documentType');
		String workOrderStatus = (String) params.get('workOrderStatus');

		String recordId = params.containsKey('recordId') ? (String) params.get('recordId') : '';

		String query =
			'SELECT Id, SAP_Sequence_Number__c, SAP_Organization_Name__c, SAP_First_Name__c, SAP_Last_Name__c, AppliedDate, SAP_Country__c, Status ' +
			'FROM IndividualApplication ' +
			'WHERE RecordType.Name = \'Apostille\' AND Status IN (\'Submitted\', \'Payment Pending\', \'Payment Captured\')';

		if (String.isNotBlank(workOrder)) {
			query += ' AND SAP_Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
		}

		if (String.isNotBlank(recordId)) {
			query += ' AND Id = \'' + recordId + '\'';
		}

		if (String.isNotBlank(workOrderStatus)) {
			query += ' AND Status = \'' + String.escapeSingleQuotes(workOrderStatus) + '\'';
		}

		if (String.isNotBlank(documentType)) {
			query += ' AND Id IN (SELECT ParentRecordId FROM DocumentChecklistItem WHERE DocumentType.MasterLabel = \'' + String.escapeSingleQuotes(documentType) + '\')';
		}

		if (String.isNotBlank(requesterName)) {
			query +=
				' AND (SAP_Organization_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\' ' +
				'OR (SAP_Organization_Name__c = null AND (SAP_First_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\' ' +
				'OR SAP_Last_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\')))';
		}

		if (String.isNotBlank(requestDate)) {
			try {
				Date receivedDate = Date.valueOf(requestDate);

				Datetime startOfDay = Datetime.newInstance(receivedDate, Time.newInstance(0, 0, 0, 0));
				Datetime endOfDay = Datetime.newInstance(receivedDate, Time.newInstance(23, 59, 59, 999));

				query += ' AND AppliedDate >= ' + startOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND AppliedDate <= ' + endOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
			} catch (Exception e) {
				BOS_Utility.ExceptionHandler(className, 'buildQuery', relatedInfoObject, null, severity, e, null);
				throw new AuraHandledException('Invalid date format. Please use YYYY-MM-DD format.');
			}
		}

		if (String.isNotBlank(sortBy)) {
			String sortField = getSortField(sortBy);
			query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
		}

		query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

		return query;
	}

	/**
	 * Maps sorting parameters to corresponding database field names.
	 * @param sortBy The user-provided sort key.
	 * @return The corresponding field name for sorting.
	 */
	@TestVisible
	private static String getSortField(String sortBy) {
		Map<String, String> sortFieldMap = new Map<String, String>{
			'ApplicationID' => 'SAP_Sequence_Number__c',
			'requestorName' => 'SAP_Organization_Name__c',
			'AppliedDate' => 'AppliedDate',
			'SAP_Destination__c' => 'SAP_Country__c',
			'Status' => 'Status'
		};
		return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
	}

	/**
	 * Processes and structures the retrieved application records.
	 * @param applications List of applications retrieved from the database.
	 * @return A structured list of key-value maps with application details.
	 */
	private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications) {
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		Set<Id> applicationIds = new Set<Id>();
		for (IndividualApplication app : applications) {
			applicationIds.add(app.Id);
		}

		Map<Id, List<DocumentChecklistItem>> documentsByApplication = getDocumentsByApplication(applicationIds);

		for (IndividualApplication app : applications) {
			Map<String, Object> record = new Map<String, Object>();
			List<DocumentChecklistItem> docs = documentsByApplication.get(app.Id);
			DocumentChecklistItem firstDoc = docs != null && !docs.isEmpty() ? docs[0] : null;

			String name = String.isNotBlank(app.SAP_Organization_Name__c) ? app.SAP_Organization_Name__c : (app.SAP_First_Name__c + ' ' + app.SAP_Last_Name__c).trim();

			record.put('Id', app.Id);
			record.put('ApplicationID', app.SAP_Sequence_Number__c);
			record.put('requestorName', name);
			record.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
			record.put('Status', app.Status);

			if (firstDoc != null) {
				record.put('signedByName', firstDoc.Signed_By__r.Name);
				record.put('signedByPosition', firstDoc.SAP_signedBy_Position__c);
				record.put('SAP_Destination__c', firstDoc.SAP_Country__c);
				record.put('documentType', firstDoc.DocumentType.MasterLabel);
			} else {
				record.put('signedByName', '');
				record.put('signedByPosition', '');
				record.put('SAP_Destination__c', app.SAP_Country__c);
				record.put('documentType', '');
			}

			String unexpandedStatus = app.Status + (firstDoc != null ? ' / ' + firstDoc.Status : '');
			record.put('unexpandedStatus', unexpandedStatus);
			record.put('expandedStatus', (firstDoc != null ? firstDoc.Status + ' / ' : '') + app.Status);

			List<Map<String, Object>> documents = processDocuments(docs, app, name);
			record.put('docCount', documents.size());
			record.put('hasDocuments', !documents.isEmpty());
			record.put('documents', documents);

			result.add(record);
		}

		return result;
	}

	/**
	 * Retrieves and processes document checklist items for Apostille applications.
	 * Fetches documents associated with given application IDs and structures them for use.
	 */
	@TestVisible
	private static Map<Id, List<DocumentChecklistItem>> getDocumentsByApplication(Set<Id> applicationIds) {
		Map<Id, List<DocumentChecklistItem>> documentsByApplication = new Map<Id, List<DocumentChecklistItem>>();
		for (DocumentChecklistItem doc : [
			SELECT Id, ParentRecordId, Signed_By__r.Name, SAP_signedBy_Position__c, SAP_Country__c, DocumentType.MasterLabel, Status, CreatedDate
			FROM DocumentChecklistItem
			WHERE ParentRecordId IN :applicationIds
			ORDER BY CreatedDate ASC
		]) {
			if (!documentsByApplication.containsKey(doc.ParentRecordId)) {
				documentsByApplication.put(doc.ParentRecordId, new List<DocumentChecklistItem>());
			}
			documentsByApplication.get(doc.ParentRecordId).add(doc);
		}
		return documentsByApplication;
	}

	/**
	 * Converts document checklist items into a structured format.
	 * @param docs List of document checklist items.
	 * @param app The parent application record.
	 * @param name Requestor name associated with the application.
	 * @return A list of maps containing structured document details.
	 */
	private static List<Map<String, Object>> processDocuments(List<DocumentChecklistItem> docs, IndividualApplication app, String name) {
		List<Map<String, Object>> documents = new List<Map<String, Object>>();
		if (docs != null) {
			for (Integer i = 1; i < docs.size(); i++) {
				DocumentChecklistItem doc = docs[i];
				Map<String, Object> document = new Map<String, Object>{
					'Id' => doc.Id,
					'ApplicationID' => app.SAP_Sequence_Number__c,
					'requestorName' => name,
					'AppliedDate' => formatCustomDateTime(app.AppliedDate),
					'signedByName' => doc.Signed_By__r.Name,
					'signedByPosition' => doc.SAP_signedBy_Position__c,
					'SAP_Destination__c' => doc.SAP_Country__c,
					'documentType' => doc.DocumentType.MasterLabel,
					'Status' => doc.Status
				};
				documents.add(document);
			}
		}
		return documents;
	}

	/**
	 * Retrieves the count of Apostille applications based on provided filter criteria.
	 * @param paramsJson JSON string containing filtering parameters.
	 * @return The count of matching applications.
	 */
	@AuraEnabled(cacheable=true)
	public static Integer getApplicationsCount(String paramsJson) {
		Map<String, Object> params = new Map<String, Object>();
		if (paramsJson != null) {
			params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
		}

		String workOrder = (String) params.get('workOrder');
		String requestDate = (String) params.get('requestDate');
		String requesterName = (String) params.get('requesterName');
		String documentType = (String) params.get('documentType');
		String workOrderStatus = (String) params.get('workOrderStatus');
		String recordId = (String) params.get('recordId');

		String query = buildCountQuery(params);
		List<AggregateResult> countResult = Database.query(query, AccessLevel.USER_MODE);
		return (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;
	}

	/**
	 * Builds a query to count the number of IndividualApplication records based on provided filters.
	 * @param params A map containing filtering parameters like workOrder, requestDate, requesterName, etc.
	 * @return A dynamically constructed SOQL query string.
	 */
	public static String buildCountQuery(Map<String, Object> params) {
		String workOrder = (String) params.get('workOrder');
		String requestDate = (String) params.get('requestDate');
		String requesterName = (String) params.get('requesterName');
		String documentType = (String) params.get('documentType');
		String workOrderStatus = (String) params.get('workOrderStatus');
		String recordId = (String) params.get('recordId');

		String query =
			'SELECT COUNT(Id) cnt FROM IndividualApplication ' + 'WHERE RecordType.Name = \'Apostille\' AND Status IN (\'Submitted\', \'Payment Pending\', \'Payment Captured\')';

		if (String.isNotBlank(workOrder)) {
			query += ' AND SAP_Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
		}

		if (String.isNotBlank(recordId)) {
			query += ' AND Id = \'' + recordId + '\'';
		}

		if (String.isNotBlank(workOrderStatus)) {
			query += ' AND Status = \'' + String.escapeSingleQuotes(workOrderStatus) + '\'';
		}

		if (String.isNotBlank(documentType)) {
			query += ' AND Id IN (SELECT ParentRecordId FROM DocumentChecklistItem WHERE DocumentType.MasterLabel = \'' + String.escapeSingleQuotes(documentType) + '\')';
		}

		if (String.isNotBlank(requesterName)) {
			query +=
				' AND (SAP_Organization_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\' ' +
				'OR (SAP_Organization_Name__c = null AND (SAP_First_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\' ' +
				'OR SAP_Last_Name__c LIKE \'%' +
				String.escapeSingleQuotes(requesterName) +
				'%\')))';
		}

		if (String.isNotBlank(requestDate)) {
			try {
				Date receivedDate = Date.valueOf(requestDate);

				Datetime startOfDay = Datetime.newInstance(receivedDate, Time.newInstance(0, 0, 0, 0));
				Datetime endOfDay = Datetime.newInstance(receivedDate, Time.newInstance(23, 59, 59, 999));

				query += ' AND AppliedDate >= ' + startOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND AppliedDate <= ' + endOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
			} catch (Exception e) {
				BOS_Utility.ExceptionHandler(className, 'buildCountQuery', relatedInfoObject, null, severity, e, null);
				throw new AuraHandledException('Invalid date format. Please use YYYY-MM-DD format.');
			}
		}

		return query;
	}

	/**
	 * Formats a DateTime value into a MM/DD/YYYY string format.
	 * @param dt The DateTime value to format.
	 * @return A formatted date string or null if input is null.
	 */
	@TestVisible
	private static String formatCustomDateTime(DateTime dt) {
		if (dt == null)
			return null;
		Date dateOnly = dt.dateGmt();
		String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
		String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
		return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
	}

	@AuraEnabled
	public static Map<String, Object> checkCancelEligibility(String recordId) {
		try {
			Map<String, Object> result = new Map<String, Object>{ 'isEligible' => false, 'message' => '', 'isWithin24Hours' => false, 'isBeyond180Days' => false };

			RegulatoryTrxnFee fee = [
				SELECT CreatedDate, SAP_Gateway_Provider__c
				FROM RegulatoryTrxnFee
				WHERE ParentRecordId = :recordId AND RecordType.DeveloperName = 'New_Transaction'
				LIMIT 1
			];

			// For non-Authorize.net payments, always eligible
			if (fee.SAP_Gateway_Provider__c != 'Authorization.net') {
				result.put('isEligible', true);
				result.put('message', '');
				return result;
			}

			Datetime now = Datetime.now();
			Long hoursSinceCreated = now.getTime() - fee.CreatedDate.getTime();
			Decimal hoursElapsed = hoursSinceCreated / (1000 * 60 * 60);
			Decimal daysElapsed = hoursElapsed / 24;

			if (hoursElapsed < 24) {
				result.put('isWithin24Hours', true);
				result.put('message', 'Payment is within 24 hours and can be voided.');
				result.put('isEligible', true);
			} else if (daysElapsed > 180) {
				result.put('isBeyond180Days', true);
				result.put('message', 'Payment is older than 180 days and cannot be refunded.');
				result.put('isEligible', false);
			} else {
				result.put('message', 'Payment can be refunded.');
				result.put('isEligible', true);
			}

			return result;
		} catch (Exception e) {
			throw new AuraHandledException('Unable to check cancel eligibility: ' + e.getMessage());
		}
	}

	/**
	 * Updates the status of an application to 'Cancelled'.
	 * @param recordId The ID of the application to be updated.
	 * @return True if the update is successful, false otherwise.
	 */
	@AuraEnabled
	public static Boolean updateApplicationStatusToCancelled(String recordId, Boolean is24Hours, Boolean isInHouse) {
		try {
			IndividualApplication app = getApplicationRecord(recordId);
			RegulatoryTrxnFee originalFee = getLatestPaidFeeForApplication(recordId);

			if (
				app == null ||
				originalFee == null ||
				originalFee.SAP_Auth_Code__c == null ||
				originalFee.SAP_Transaction_Id__c == null ||
				originalFee.TotalFeeAmount == null ||
				originalFee.SAP_Card_Number__c == null
			) {
				return false;
			}

			Decimal feeAmount = originalFee.SAP_Amount__c != null ? originalFee.SAP_Amount__c : 0;
			Decimal totalRefunded = app.SAP_Total_Refund__c != null ? app.SAP_Total_Refund__c : 0;
			Decimal remainingAmount = feeAmount - totalRefunded;

			String transactionType = is24Hours ? 'voidTransaction' : 'refundTransaction';

			if (remainingAmount > 0) {
				Object response;

				if (originalFee.SAP_Gateway_Provider__c == 'PayPal') {
					response = processPayPalRefund(originalFee.SAP_Auth_Code__c, remainingAmount);
				} else if (originalFee.SAP_Gateway_Provider__c == 'Authorization.net') {
					response = processAuthNetTransaction(originalFee, transactionType, String.valueOf(remainingAmount.setScale(2)));
				}

				createRefundFeeRecord(originalFee, response, app, remainingAmount);
			}
			updateIndividualApplicationRefund(app, remainingAmount);
			if (!isInHouse) {
				updateApplicationToCancelled(app);
			}
			return true;
		} catch (Exception e) {
			BOS_Utility.ExceptionHandler(className, 'updateApplicationStatusToCancelled', relatedInfoObject, null, severity, e, null);
			throw new AuraHandledException('Error updating application status: ' + e.getMessage());
		}
	}

	/**
	 * Response class for Authorization.net refund processing.
	 */
	public class AuthNetRefundResponse {
		public Boolean success;
		public String refundId;
		public String authCode;
		public String accountType;
		public String responseMessage;
		public String errorMessage;

		public AuthNetRefundResponse() {
			this.success = false;
			this.refundId = '';
			this.authCode = '';
			this.accountType = '';
			this.responseMessage = '';
			this.errorMessage = '';
		}
	}

	public static AuthNetRefundResponse processAuthNetTransaction(RegulatoryTrxnFee fee, String transactionType, String amount) {
		AuthNetRefundResponse response = new AuthNetRefundResponse();
		try {
			String endpoint = 'callout:AuthorizationNet_Payment_Gateway';
			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint);
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setTimeout(120000);

			String cardNumber = '';
			if (fee.SAP_Card_Number__c != null) {
				String originalCardNumber = String.valueOf(fee.SAP_Card_Number__c.intValue());
				Integer digits = originalCardNumber.length();

				if (digits < 4) {
					cardNumber = originalCardNumber.leftPad(4, '0');
				} else {
					cardNumber = digits > 4 ? originalCardNumber.substring(digits - 4, digits) : originalCardNumber;
				}
			}

			String requestBody =
				'{"createTransactionRequest":{"merchantAuthentication":{"name":"{!$Credential.AuthorizationNet_Payment_Gateway.name}","transactionKey":"{!$Credential.AuthorizationNet_Payment_Gateway.transactionKey}"},"transactionRequest":{"transactionType":"' +
				transactionType +
				'","amount":"' +
				amount +
				'","payment":{"creditCard":{"cardNumber":"' +
				cardNumber +
				'","expirationDate":"XXXX"}},"refTransId":"' +
				fee.SAP_Transaction_Id__c +
				'"}}}';
			req.setBody(requestBody);

			Http http = new Http();
			HttpResponse res = http.send(req);

			String responseBody = res.getBody();
			if (responseBody.startsWith('\uFEFF')) {
				responseBody = responseBody.substring(1);
			}

			if (res.getStatusCode() == 200) {
				Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

				Map<String, Object> transactionResponse = (Map<String, Object>) responseMap.get('transactionResponse');
				if (transactionResponse != null) {
					String responseCode = String.valueOf(transactionResponse.get('responseCode'));

					if (responseCode == '1') {
						response.success = true;
						response.refundId = String.valueOf(transactionResponse.get('transId'));
						response.authCode = String.valueOf(transactionResponse.get('authCode'));
						response.accountType = String.valueOf(transactionResponse.get('accountType'));

						if (transactionResponse.containsKey('messages')) {
							List<Object> messageList = (List<Object>) transactionResponse.get('messages');
							if (messageList != null && !messageList.isEmpty()) {
								Map<String, Object> messageMap = (Map<String, Object>) messageList[0];
								response.responseMessage = String.valueOf(messageMap.get('description'));
							}
						}
					} else {
						response.success = false;
						if (transactionResponse.containsKey('errors')) {
							List<Object> errors = (List<Object>) transactionResponse.get('errors');
							if (errors != null && !errors.isEmpty()) {
								Map<String, Object> error = (Map<String, Object>) errors[0];
								response.errorMessage = 'Error: ' + error.get('errorText');
							}
						} else {
							response.errorMessage = 'Transaction declined. Response code: ' + responseCode;
						}
					}
				} else {
					if (responseMap.containsKey('messages')) {
						Map<String, Object> messages = (Map<String, Object>) responseMap.get('messages');
						String resultCode = String.valueOf(messages.get('resultCode'));

						if (resultCode == 'Error') {
							List<Object> messageList = (List<Object>) messages.get('message');
							if (messageList != null && !messageList.isEmpty()) {
								Map<String, Object> messageMap = (Map<String, Object>) messageList[0];
								response.success = false;
								response.errorMessage = String.valueOf(messageMap.get('text'));
							}
						}
					} else {
						response.success = false;
						response.errorMessage = 'Invalid response format from Authorization.net';
					}
				}
			} else {
				response.success = false;
				response.errorMessage = 'Authorization.net API Error: ' + res.getStatusCode() + ' ' + responseBody;
			}
		} catch (Exception e) {
			response.success = false;
			response.errorMessage = 'Exception: ' + e.getMessage() + ' Line: ' + e.getLineNumber();
			BOS_Utility.ExceptionHandler(className, 'processAuthNetTransaction', 'RegulatoryTrxnFee', null, severity, e, null);
		}
		return response;
	}

	/**
	 * Retrieves an IndividualApplication record based on the provided record ID.
	 * @param recordId The ID of the application record to retrieve.
	 * @return The IndividualApplication record if found, otherwise null.
	 */
	public static IndividualApplication getApplicationRecord(String recordId) {
		List<IndividualApplication> apps = [
			SELECT Id, Status, SAP_Cancellation_Type__c, SAP_Reason_for_Cancellation__c, SAP_Cancellation_Date__c, SAP_Total_Refund__c
			FROM IndividualApplication
			WHERE Id = :recordId
			LIMIT 1
		];

		if (apps.isEmpty()) {
			return null;
		}
		return apps[0];
	}

	/**
	 * Updates an application record to reflect a cancellation by the customer.
	 * Sets the cancellation status, reason, and date accordingly.
	 * @param app The IndividualApplication record to update.
	 */
	public static void updateApplicationToCancelled(IndividualApplication app) {
		app.Status = 'Cancelled By Customer';
		app.SAP_Cancellation_Type__c = 'Cancelled by Customer';
		app.SAP_Reason_for_Cancellation__c = 'Cancelled by Customer';
		app.SAP_Cancellation_Date__c = Date.today();
		update app;
	}

	public static void updateIndividualApplicationRefund(IndividualApplication app, Decimal remainingAmount) {
		if (app == null) {
			return;
		}
		app.SAP_Total_Refund__c = app.SAP_Total_Refund__c != null ? app.SAP_Total_Refund__c + remainingAmount : remainingAmount;
		update app;
	}

	public static RegulatoryTrxnFee getLatestPaidFeeForApplication(String recordId) {
		List<RegulatoryTrxnFee> fees = [
			SELECT
				Id,
				SAP_Amount__c,
				SAP_Transaction_Id__c,
				SAP_Auth_Code__c,
				SAP_Card_Number__c,
				SAP_Brand__c,
				SAP_Gateway_Provider__c,
				SAP_payerName__c,
				SAP_Authorization_Id__c,
				TotalFeeAmount,
				CreatedDate
			FROM RegulatoryTrxnFee
			WHERE ParentRecordId = :recordId AND SAP_Transaction_Id__c != NULL AND SAP_Auth_Code__c != NULL
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
		if (fees.isEmpty()) {
			return null;
		}
		return fees[0];
	}

	/**
	 * Creates a refund fee record based on the original transaction and PayPal refund response.
	 * @param originalFee The original regulatory transaction fee.
	 * @param response Updates the createRefundFeeRecord method to handle both PayPal and Auth.net responses
	 * @param app The associated Individual Application.
	 */

	public static void createRefundFeeRecord(RegulatoryTrxnFee originalFee, Object responseObj, IndividualApplication app, Decimal refundAmount) {
		Date today = Date.today();
		Id refundRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

		Boolean isSuccess = false;
		String refundId = '';
		String errorMessage = '';
		String authCode = null;
		String accountType = null;

		if (responseObj instanceof PayPalRefundResponse) {
			PayPalRefundResponse response = (PayPalRefundResponse) responseObj;
			isSuccess = response.success;
			refundId = response.refundId;
			errorMessage = response.errorMessage;
		} else if (responseObj instanceof AuthNetRefundResponse) {
			AuthNetRefundResponse response = (AuthNetRefundResponse) responseObj;
			isSuccess = response.success;
			refundId = response.refundId;
			errorMessage = response.errorMessage;
			authCode = response.authCode;
			accountType = response.accountType;
		}

		if (!isSuccess) {
			throw new AuraHandledException('Refund Failed. Please try again later.');
		}

		// Only create and insert the fee if refund was successful
		RegulatoryTrxnFee refundFee = new RegulatoryTrxnFee(
			RecordTypeId = refundRecordTypeId,
			ParentRecordId = app.Id,
			Status = 'Draft',
			SAP_Card_Number__c = originalFee.SAP_Card_Number__c,
			SAP_Brand__c = accountType != null && accountType != '' ? accountType : originalFee.SAP_Brand__c,
			SAP_Amount__c = refundAmount,
			SAP_Gateway_Provider__c = originalFee.SAP_Gateway_Provider__c,
			Date_of_Refund__c = today,
			Refund_Amount__c = refundAmount,
			SAP_payerName__c = originalFee.SAP_payerName__c != null ? originalFee.SAP_payerName__c : null,
			SAP_Refund_ID__c = refundId,
			Refund_Method__c = 'Card',
			SAP_Refund_Reason__c = 'Application cancelled by customer',
			SAP_Transaction_Status__c = 'Refunded',
			SAP_Authorization_Id__c = originalFee.SAP_Authorization_Id__c
		);

		if (authCode != null && authCode != '') {
			refundFee.SAP_Auth_Code__c = authCode;
		}

		insert refundFee;
		createRefundFeeItemRecords(refundFee, isSuccess, refundId, errorMessage, originalFee);
	}

	public static void createRefundFeeItemRecords(RegulatoryTrxnFee refundFee, Boolean isSuccess, String refundId, String errorMessage, RegulatoryTrxnFee originalFee) {
		Date today = Date.today();

		Id refundItemRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

		List<RegulatoryTrxnFeeItem> originalFeeItems = [
			SELECT Id, Name, FeeAmount, SAP_Refund_Amount__c
			FROM RegulatoryTrxnFeeItem
			WHERE RegulatoryTrxnFeeId = :originalFee.Id
			ORDER BY FeeAmount DESC
		];

		Decimal totalRefundAmount = refundFee.Refund_Amount__c;
		Decimal remainingRefundAmount = totalRefundAmount;

		List<RegulatoryTrxnFeeItem> refundFeeItems = new List<RegulatoryTrxnFeeItem>();

		for (RegulatoryTrxnFeeItem originalItem : originalFeeItems) {
			if (remainingRefundAmount <= 0)
				break;

			Decimal itemAmount = originalItem.FeeAmount;
			Decimal alreadyRefunded = originalItem.SAP_Refund_Amount__c != null ? originalItem.SAP_Refund_Amount__c : 0;
			Decimal itemRefundableAmount = itemAmount - alreadyRefunded;
			Decimal itemRefundAmount = 0;

			if (remainingRefundAmount >= itemRefundableAmount) {
				itemRefundAmount = itemRefundableAmount;
			} else {
				itemRefundAmount = remainingRefundAmount;
			}

			if (itemRefundAmount == null) {
				itemRefundAmount = 0;
			}
			if (remainingRefundAmount == null) {
				remainingRefundAmount = 0;
			}
			remainingRefundAmount -= itemRefundAmount;

			RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem(RegulatoryTrxnFeeId = refundFee.Id, RecordTypeId = refundItemRecordTypeId, Name = 'Refund - ' + originalItem.Name);

			if (isSuccess) {
				feeItem.SAP_Refund_Amount__c = itemRefundAmount;
				feeItem.FeeAmount = itemRefundAmount;
				feeItem.Date_of_Refund__c = today;
				feeItem.SAP_Refund_ID__c = refundId;
				feeItem.SAP_Refund_Method__c = 'Card';
				feeItem.SAP_Refund_Reason__c = 'Application cancelled by customer';
				feeItem.SAP_Refund_Status__c = 'Approved';
			} else {
				throw new AuraHandledException('Refund Failed. Please try again later.');
			}

			refundFeeItems.add(feeItem);
		}

		if (!refundFeeItems.isEmpty()) {
			insert refundFeeItems;
		}
	}

	/**
	 * Processes a refund request through PayPal API.
	 * @param captureId The PayPal capture ID of the transaction.
	 * @param amount The refund amount.
	 * @return PayPalRefundResponse containing refund details.
	 */
	public static PayPalRefundResponse processPayPalRefund(String captureId, Decimal amount) {
		PayPalRefundResponse response = new PayPalRefundResponse();

		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('callout:PayPal_Endpoint/v2/payments/captures/' + captureId + '/refund');
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setTimeout(120000);

			// Prepare request body
			String requestBody = '{"amount":{"value":"' + amount + '","currency_code":"USD"}}';
			req.setBody(requestBody);

			Http http = new Http();
			HttpResponse res = http.send(req);

			if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
				Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
				response.success = true;
				response.refundId = (String) responseMap.get('id');
			} else {
				response.success = false;
				response.errorMessage = 'PayPal API Error: ' + res.getStatusCode() + ' ' + res.getBody();
			}
		} catch (Exception e) {
			response.success = false;
			response.errorMessage = 'Exception: ' + e.getMessage() + ' Line: ' + e.getLineNumber();

			// Log the exception to an error handler
			BOS_Utility.ExceptionHandler('processPayPalRefund', 'processPayPalRefund', 'RegulatoryTrxnFee', null, 'ERROR', e, null);
		}

		return response;
	}

	/**
	 * Response class for PayPal refund processing.
	 */
	public class PayPalRefundResponse {
		public Boolean success;
		public String refundId;
		public String errorMessage;

		public PayPalRefundResponse() {
			this.success = false;
			this.refundId = '';
			this.errorMessage = '';
		}
	}

	/**
	 * Custom exception for PayPal API-related errors.
	 */
	public class PayPalApiException extends Exception {
	}

	/**
	 * Retrieves the count of applications by status within a given date range.
	 * @param startDateForQuery Start date for filtering applications
	 * @param endDateForQuery End date for filtering applications
	 * @return A map containing application status as keys and count as values
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, Integer> getApplicationCountsByStatus(Date startDateForQuery, Date endDateForQuery) {
		Map<String, Integer> statusCounts = new Map<String, Integer>{ 'submitted' => 0, 'completed' => 0, 'draft' => 0 };

		String query = 'SELECT Status, COUNT(Id) cnt FROM IndividualApplication ' + 'WHERE RecordType.Name = \'Apostille\' ';

		if (startDateForQuery != null) {
			query += 'AND AppliedDate >= :startDateForQuery ';
		}
		if (endDateForQuery != null) {
			query += 'AND AppliedDate <= :endDateForQuery ';
		}

		query += 'GROUP BY Status';

		for (AggregateResult ar : Database.query(query, AccessLevel.USER_MODE)) {
			String status = (String) ar.get('Status');
			Integer count = (Integer) ar.get('cnt');

			if (status == 'Submitted' || status == 'Payment Captured' || status == 'Payment Pending') {
				statusCounts.put('submitted', count);
			} else if (status == 'Completed') {
				statusCounts.put('completed', count);
			} else if (status == 'Draft') {
				statusCounts.put('draft', count);
			} else if (status == 'Cancelled') {
				statusCounts.put('draft', count);
			} else if (status == 'In Review') {
				statusCounts.put('in_review', count);
			} else if (status == 'Application Accepted') {
				statusCounts.put('application_accepted', count);
			} else if (status == 'Approved') {
				statusCounts.put('approved', count);
			} else if (status == 'Denied') {
				statusCounts.put('denied', count);
			} else if (status == 'Order Completed - Mail') {
				statusCounts.put('order_completed_mail', count);
			} else if (status == 'Order Completed – Pick Up') {
				statusCounts.put('Order_completed_pick_up', count);
			} else if (status == 'Cancelled') {
				statusCounts.put('cancelled', count);
			}
		}

		return statusCounts;
	}

	@AuraEnabled
	public static void inHousePartialRefundFee(Id documentChecklistId) {
		// Query for the document checklist item
		DocumentChecklistItem doc = [
			SELECT Id, DocumentType.MasterLabel, SAP_Fees__c, ParentRecordId
			FROM DocumentChecklistItem
			WHERE Id = :documentChecklistId AND SAP_isAddedByAgent__c = FALSE
			LIMIT 1
		];

		if (doc == null || doc.ParentRecordId == null) {
			return; // Nothing to process
		}

		// Get the application record
		IndividualApplication app = getApplicationRecord(doc.ParentRecordId);
		if (app == null) {
			return;
		}

		// Query for the fee record
		RegulatoryTrxnFee fee = [
			SELECT
				Id,
				TotalFeeAmount,
				SAP_Gateway_Provider__c,
				SAP_payerName__c,
				SAP_Transaction_Id__c,
				SAP_Card_Number__c,
				SAP_Brand__c,
				SAP_Auth_Code__c,
				SAP_Amount__c,
				SAP_Authorization_Id__c
			FROM RegulatoryTrxnFee
			WHERE ParentRecordId = :doc.ParentRecordId AND RecordType.DeveloperName = 'New_Transaction' AND SAP_Payment_Type__c = 'Card'
			LIMIT 1
		];

		if (fee == null) {
			return;
		}

		Boolean is24Hours = false;
		Object response;

		if (fee.SAP_Gateway_Provider__c == 'Authorization.net') {
			Map<String, Object> eligibility = checkCancelEligibility(app.Id);
			if (eligibility == null || !(Boolean) eligibility.get('isEligible')) {
				return;
			}
			is24Hours = (Boolean) eligibility.get('isWithin24Hours');
		}

		if (fee.SAP_Gateway_Provider__c == 'PayPal') {
			response = processPayPalRefund(fee.SAP_Auth_Code__c, doc.SAP_Fees__c);
		} else if (fee.SAP_Gateway_Provider__c == 'Authorization.net') {
			if (fee.SAP_Transaction_Id__c == null || fee.TotalFeeAmount == null || fee.SAP_Card_Number__c == null) {
				return;
			}
			String transactionType = is24Hours ? 'voidTransaction' : 'refundTransaction';
			response = processAuthNetTransaction(fee, transactionType, String.valueOf(doc.SAP_Fees__c.setScale(2)));
		}

		updateIndividualApplicationRefund(app, doc.SAP_Fees__c);

		createPatialRefundFeeRecord(fee, response, doc);
	}

	public static void createPatialRefundFeeRecord(RegulatoryTrxnFee originalFee, Object responseObj, DocumentChecklistItem doc) {
		Date today = Date.today();

		Id refundRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

		RegulatoryTrxnFee refundFee = new RegulatoryTrxnFee(
			RecordTypeId = refundRecordTypeId,
			ParentRecordId = doc.ParentRecordId,
			Status = 'Draft',
			SAP_Card_Number__c = originalFee.SAP_Card_Number__c,
			SAP_Brand__c = originalFee.SAP_Brand__c,
			SAP_Amount__c = doc.SAP_Fees__c,
			SAP_Gateway_Provider__c = originalFee.SAP_Gateway_Provider__c
		);

		Boolean isSuccess = false;
		String refundId = '';
		String errorMessage = '';

		if (responseObj instanceof PayPalRefundResponse) {
			PayPalRefundResponse response = (PayPalRefundResponse) responseObj;
			isSuccess = response.success;
			refundId = response.refundId;
			errorMessage = response.errorMessage;
		} else if (responseObj instanceof AuthNetRefundResponse) {
			AuthNetRefundResponse response = (AuthNetRefundResponse) responseObj;
			isSuccess = response.success;
			refundId = response.refundId;
			errorMessage = response.errorMessage;

			// Set Auth.net specific fields if available
			if (response.authCode != null && response.authCode != '') {
				refundFee.SAP_Auth_Code__c = response.authCode;
			}

			// Set card brand if available from response
			if (response.accountType != null && response.accountType != '') {
				refundFee.SAP_Brand__c = response.accountType;
			}
		}

		if (isSuccess) {
			refundFee.Date_of_Refund__c = today;
			refundFee.Refund_Amount__c = doc.SAP_Fees__c;
			refundFee.SAP_payerName__c = originalFee.SAP_payerName__c != null ? originalFee.SAP_payerName__c : null;
			refundFee.SAP_Refund_ID__c = refundId;
			refundFee.Refund_Method__c = 'Card';
			refundFee.SAP_Refund_Reason__c = 'Application cancelled by customer';
			refundFee.SAP_Transaction_Status__c = 'Refunded';
			refundFee.SAP_Authorization_Id__c = originalFee.SAP_Authorization_Id__c;
			//refundFee.Status = 'Refunded';
		} else {
			refundFee.SAP_Refund_ID__c = 'Failed';
			refundFee.SAP_Transaction_Status__c = 'Rejected';
			refundFee.SAP_Refund_Denied_Reason__c = errorMessage.length() > 255 ? errorMessage.substring(0, 255) : errorMessage;
			refundFee.SAP_Refund_Reason__c = 'Application cancelled by customer - Refund failed';
		}

		insert refundFee;

		createPatialRefundFeeItemRecords(refundFee, isSuccess, refundId, errorMessage, originalFee, doc);
	}

	public static void createPatialRefundFeeItemRecords(
		RegulatoryTrxnFee refundFee,
		Boolean isSuccess,
		String refundId,
		String errorMessage,
		RegulatoryTrxnFee originalFee,
		DocumentChecklistItem doc
	) {
		Date today = Date.today();

		Id refundItemRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

		RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem(
			RegulatoryTrxnFeeId = refundFee.Id,
			RecordTypeId = refundItemRecordTypeId,
			Name = 'Refund - ' + doc.DocumentType.MasterLabel
		);

		if (isSuccess) {
			feeItem.SAP_Refund_Amount__c = doc.SAP_Fees__c;
			feeItem.FeeAmount = doc.SAP_Fees__c;
			feeItem.Date_of_Refund__c = today;
			feeItem.SAP_Refund_ID__c = refundId;
			feeItem.SAP_Refund_Method__c = 'Card';
			feeItem.SAP_Refund_Reason__c = 'Application cancelled by customer';
			feeItem.SAP_Refund_Status__c = 'Approved';
			//feeItem.SAP_Transaction_Status__c = 'Refunded';
		} else {
			feeItem.FeeAmount = 0;
			feeItem.SAP_Refund_ID__c = 'Failed';
			feeItem.SAP_Refund_Status__c = 'Rejected';
			feeItem.SAP_Refund_Denied_Reason__c = 'Filing Expired';
			feeItem.SAP_Refund_Reason__c = 'Application cancelled by customer - Refund failed';
			//feeItem.SAP_Transaction_Status__c = 'Rejected';
		}

		insert feeItem;
	}

	@AuraEnabled
	public static void fetchDoctoRefund(Id recordId) {
		if (recordId == null) {
			return;
		}

		try {
			IndividualApplication app = [
				SELECT Id, Status, SAP_Cancellation_Type__c, SAP_Reason_for_Cancellation__c, SAP_Cancellation_Date__c, SAP_Total_Refund__c
				FROM IndividualApplication
				WHERE Id = :recordId
				LIMIT 1
			];

			if (app == null || app.Status != 'Payment Captured') {
				return;
			}

			List<DocumentChecklistItem> docs = [
				SELECT Id, Status, SAP_Fees__c, Name, DocumentType.MasterLabel, ParentRecordId
				FROM DocumentChecklistItem
				WHERE ParentRecordId = :recordId AND SAP_isAddedByAgent__c = FALSE AND Status != 'Rejected'
			];

			// Calculate the remaining amount
			Decimal totalFees = 0;
			for (DocumentChecklistItem doc : docs) {
				if (doc.SAP_Fees__c != null) {
					totalFees += doc.SAP_Fees__c;
				}
			}

			RegulatoryTrxnFee fee = [
				SELECT
					Id,
					TotalFeeAmount,
					SAP_Gateway_Provider__c,
					SAP_payerName__c,
					SAP_Transaction_Id__c,
					SAP_Card_Number__c,
					SAP_Brand__c,
					SAP_Auth_Code__c,
					SAP_Amount__c,
					SAP_Authorization_Id__c
				FROM RegulatoryTrxnFee
				WHERE ParentRecordId = :recordId AND RecordType.DeveloperName = 'New_Transaction' AND SAP_Payment_Type__c = 'Card'
				LIMIT 1
			];

			if (fee == null) {
				return;
			}

			Boolean is24Hours = false;
			Object response;

			if (fee.SAP_Gateway_Provider__c == 'Authorization.net') {
				Map<String, Object> eligibility = checkCancelEligibility(app.Id);

				if (eligibility == null || !(Boolean) eligibility.get('isEligible')) {
					return;
				}
				is24Hours = (Boolean) eligibility.get('isWithin24Hours');
			}

			if (fee.SAP_Gateway_Provider__c == 'PayPal') {
				response = processPayPalRefund(fee.SAP_Auth_Code__c, totalFees);
			} else if (fee.SAP_Gateway_Provider__c == 'Authorization.net') {
				if (fee.SAP_Transaction_Id__c == null || fee.TotalFeeAmount == null || fee.SAP_Card_Number__c == null) {
					return;
				}
				String transactionType = is24Hours ? 'voidTransaction' : 'refundTransaction';
				response = processAuthNetTransaction(fee, transactionType, String.valueOf(totalFees.setScale(2)));
			}

			createRefundFeeRecord(fee, response, app, totalFees);
			updateIndividualApplicationRefund(app, totalFees);
		} catch (Exception e) {
			System.debug('Error in fetchDoctoRefund: ' + e.getMessage());
		}
	}
}