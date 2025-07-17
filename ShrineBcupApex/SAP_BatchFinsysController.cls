/**
 * @description Controller class for SAP Batch Financial System integration
 * Handles batch transaction data retrieval and batch status updates
 */
public with sharing class SAP_BatchFinsysController {
	/**
	 * @description Retrieves activity transaction data based on search parameters
	 * @param searchParamsJson JSON string containing search parameters
	 * @return Map<String, Object> Result containing transaction records and total count
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getActivityTransactionData(String searchParamsJson) {
		Map<String, Object> result = new Map<String, Object>();
		List<Map<String, Object>> dataList = new List<Map<String, Object>>();

		try {
			Map<String, Object> searchParams = (Map<String, Object>) JSON.deserializeUntyped(searchParamsJson);
			String workorderNumber = (String) searchParams.get('workorderNumber');
			String batchCode = (String) searchParams.get('batchCode');
			String batchDate = (String) searchParams.get('batchtDate');
			String batchStatus = (String) searchParams.get('status');
			Integer transactionCount = Integer.valueOf(searchParams.get('transactionCount'));
			String paymentTypeFilter = (String) searchParams.get('paymentType');
			String fromDate = (String) searchParams.get('fromDate');
			String toDate = (String) searchParams.get('toDate');
			Integer offsetVal = (Integer) searchParams.get('offsetVal');
			Integer pageSize = (Integer) searchParams.get('pageSize');
			String sortBy = (String) searchParams.get('sortBy');
			String sortDirection = (String) searchParams.get('sortDirection');

			Set<Id> relevantBatchIds = new Set<Id>();

			String individualApplicationPrefix = Schema.getGlobalDescribe().get('IndividualApplication')?.getDescribe()?.getKeyPrefix();
			String initialFeeQuery = '';
			if (paymentTypeFilter != null && paymentTypeFilter != '' && paymentTypeFilter != 'All') {
				initialFeeQuery =
					'SELECT ParentRecordId, SAP_Batch_Look_Up__c FROM RegulatoryTrxnFee ' +
					'WHERE SAP_Batch_Look_Up__c != null AND ParentRecordId != null ' +
					'AND SAP_Payment_Type__c = \'' +
					String.escapeSingleQuotes(paymentTypeFilter) +
					'\'';
			} else {
				initialFeeQuery = 'SELECT ParentRecordId,SAP_Batch_Look_Up__c FROM RegulatoryTrxnFee ' + 'WHERE SAP_Batch_Look_Up__c != null AND ParentRecordId != null';
			}

			for (RegulatoryTrxnFee fee : Database.query(initialFeeQuery, AccessLevel.USER_MODE)) {
				if (String.valueOf(fee.ParentRecordId).startsWith(individualApplicationPrefix)) {
					relevantBatchIds.add(fee.SAP_Batch_Look_Up__c);
				}
			}

			String batchQuery =
				'SELECT Id, SAP_Batch_Name__c, SAP_Batch_Status__c, SAP_Transacation_Count__c, SAP_Batch_Date__c ' +
				'FROM SAP_Batch__c WHERE SAP_Batch_Name__c != null AND SAP_Transacation_Count__c > 0';

			if (!relevantBatchIds.isEmpty()) {
				batchQuery += ' AND Id IN :relevantBatchIds';
			}

			if (batchCode != null && batchCode != '') {
				batchQuery += ' AND SAP_Batch_Name__c = \'' + String.escapeSingleQuotes(batchCode) + '\'';
			}

			if (batchDate != null && batchDate != '') {
				Date batchCreatedDate = Date.valueOf(batchDate);
				batchQuery += ' AND SAP_Batch_Date__c = :batchCreatedDate';
			}

			if (fromDate != null && toDate != null) {
				Date batchFromDate = Date.valueOf(fromDate);
				Date batchToDate = Date.valueOf(toDate);
				batchQuery += ' AND SAP_Batch_Date__c >= :batchFromDate AND SAP_Batch_Date__c <= :batchToDate';
			}

			if (batchStatus != null && batchStatus != '') {
				batchQuery += ' AND SAP_Batch_Status__c = \'' + String.escapeSingleQuotes(batchStatus) + '\'';
			}

			if (transactionCount != null) {
				batchQuery += ' AND SAP_Transacation_Count__c = ' + transactionCount;
			}

			String sortField = String.isNotBlank(sortBy) ? sortBy : 'CreatedDate';
			String sortOrder = (sortDirection == 'asc' || sortDirection == 'desc') ? sortDirection : 'desc';
			batchQuery += ' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST ';

			batchQuery += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

			String countQuery = 'SELECT COUNT() ' + batchQuery.substring(batchQuery.indexOf('FROM'));
			Integer orderByIndex = countQuery.indexOf('ORDER BY');
			if (orderByIndex != -1) {
				countQuery = countQuery.substring(0, orderByIndex);
			}

			Integer totalCount = Database.countQuery(countQuery, AccessLevel.USER_MODE);
			result.put('totalRecords', totalCount);
			List<SAP_Batch__c> batches = Database.query(batchQuery, AccessLevel.USER_MODE);

			Set<Id> batchIds = new Set<Id>();
			for (SAP_Batch__c batch : batches) {
				batchIds.add(batch.Id);
			}

			String feeQuery =
				'SELECT Id, Name, SAP_Batch_Look_Up__c, SAP_Batch_Look_Up__r.SAP_Batch_Name__c, ' +
				'SAP_Batch_Look_Up__r.SAP_Batch_Status__c, SAP_Batch_Look_Up__r.SAP_Batch_Date__c, ' +
				'SAP_Payment_Type__c, TotalFeeAmount, ParentRecordId ' +
				'FROM RegulatoryTrxnFee ' +
				'WHERE SAP_Batch_Look_Up__c IN :batchIds AND ParentRecordId != null';

			if (paymentTypeFilter != null && paymentTypeFilter != '' && paymentTypeFilter != 'All') {
				feeQuery += ' AND SAP_Payment_Type__c = \'' + String.escapeSingleQuotes(paymentTypeFilter) + '\'';
			}
      feeQuery += ' AND RecordType.DeveloperName != \'Refund_Transaction\'';

			List<RegulatoryTrxnFee> feeRecords = Database.query(feeQuery, AccessLevel.SYSTEM_MODE);

			Map<String, Map<String, Object>> groupedData = new Map<String, Map<String, Object>>();

			for (SAP_Batch__c batch : batches) {
				String formattedDate = '';
				if (batch.SAP_Batch_Date__c != null) {
					formattedDate = (batch.SAP_Batch_Date__c.month() + '/' + batch.SAP_Batch_Date__c.day() + '/' + batch.SAP_Batch_Date__c.year());
				}

				String groupKey = batch.SAP_Batch_Name__c + ' - ' + formattedDate + ' ' + batch.SAP_Batch_Status__c;

				groupedData.put(
					groupKey,
					new Map<String, Object>{
						'id' => batch.Id,
						'UniqueId' => groupKey,
						'BatchName' => batch.SAP_Batch_Name__c +
						' - ' +
						formattedDate,
						'BatchStatus' => batch.SAP_Batch_Status__c,
						'CheckAmount' => 0.0,
						'MoneyOrderAmount' => 0.0,
						'CardAmount' => 0.0,
						'CashAmount' => 0.0,
						'OtherAmount' => 0.0,
						'totalAmount' => 0.0,
						'sequenceNumber' => '',
						'TransactionCount' => 0,
						'noOfSequenceNumber' => 0
					}
				);
			}

			for (RegulatoryTrxnFee fee : feeRecords) {
				if (
					fee.SAP_Batch_Look_Up__r == null ||
					fee.SAP_Batch_Look_Up__r.SAP_Batch_Name__c == null ||
					fee.SAP_Batch_Look_Up__r.SAP_Batch_Date__c == null ||
					fee.SAP_Batch_Look_Up__r.SAP_Batch_Status__c == null
				) {
					continue;
				}

				String formattedDate = '';
				if (fee.SAP_Batch_Look_Up__r.SAP_Batch_Date__c != null) {
					formattedDate = (fee.SAP_Batch_Look_Up__r.SAP_Batch_Date__c.month() +
					'/' +
					fee.SAP_Batch_Look_Up__r.SAP_Batch_Date__c.day() +
					'/' +
					fee.SAP_Batch_Look_Up__r.SAP_Batch_Date__c.year());
				}

				String groupKey = fee.SAP_Batch_Look_Up__r.SAP_Batch_Name__c + ' - ' + formattedDate + ' ' + fee.SAP_Batch_Look_Up__r.SAP_Batch_Status__c;

				Map<String, Object> currentGroup = groupedData.get(groupKey);
				if (currentGroup == null)
					continue;

				String paymentType = fee.SAP_Payment_Type__c != null ? fee.SAP_Payment_Type__c : null;
				String parentObjectType = fee.ParentRecordId.getSObjectType().getDescribe().getName();

				String sequenceNumber = '';
				if (parentObjectType == 'IndividualApplication') {
					IndividualApplication parentRecord = [
						SELECT Id, SAP_Sequence_Number__c
						FROM IndividualApplication
						WHERE Id = :fee.ParentRecordId
						WITH SECURITY_ENFORCED
						LIMIT 1
					];
					sequenceNumber = parentRecord.SAP_Sequence_Number__c;
				}

				String sequenceNumbers = (String) currentGroup.get('sequenceNumber');

				if (String.isNotBlank(sequenceNumber) && !sequenceNumbers.contains(sequenceNumber)) {
					sequenceNumbers += String.isEmpty(sequenceNumbers) ? sequenceNumber : ', ' + sequenceNumber;
				}

				currentGroup.put('sequenceNumber', sequenceNumbers);
				currentGroup.put('noOfSequenceNumber', String.isEmpty(sequenceNumbers) ? 0 : sequenceNumbers.split(',').size());

				if (paymentType == 'Check') {
					currentGroup.put('CheckAmount', (Double) currentGroup.get('CheckAmount') + fee.TotalFeeAmount);
				} else if (paymentType == 'Money Order') {
					currentGroup.put('MoneyOrderAmount', (Double) currentGroup.get('MoneyOrderAmount') + fee.TotalFeeAmount);
				} else if (paymentType == 'Card') {
					currentGroup.put('CardAmount', (Double) currentGroup.get('CardAmount') + fee.TotalFeeAmount);
				} else if (paymentType == 'Cash') {
					currentGroup.put('CashAmount', (Double) currentGroup.get('CashAmount') + fee.TotalFeeAmount);
				} else {
					currentGroup.put('OtherAmount', (Double) currentGroup.get('OtherAmount') + fee.TotalFeeAmount);
				}

				currentGroup.put('TransactionCount', (Integer) currentGroup.get('TransactionCount') + 1);
				currentGroup.put(
					'totalAmount',
					(Double) currentGroup.get('CheckAmount') +
						(Double) currentGroup.get('MoneyOrderAmount') +
						(Double) currentGroup.get('CardAmount') +
						(Double) currentGroup.get('CashAmount') +
						(Double) currentGroup.get('OtherAmount')
				);
			}

			for (String groupKey : groupedData.keySet()) {
				try {
					Map<String, Object> currentGroup = groupedData.get(groupKey);

					if (!currentGroup.containsKey('CheckAmount') || !currentGroup.containsKey('totalAmount')) {
						continue;
					}

					currentGroup.put('CheckAmount', formatAmount((Double) currentGroup.get('CheckAmount')));
					currentGroup.put('MoneyOrderAmount', formatAmount((Double) currentGroup.get('MoneyOrderAmount')));
					currentGroup.put('CardAmount', formatAmount((Double) currentGroup.get('CardAmount')));
					currentGroup.put('CashAmount', formatAmount((Double) currentGroup.get('CashAmount')));
					currentGroup.put('OtherAmount', formatAmount((Double) currentGroup.get('OtherAmount')));
					currentGroup.put('totalAmount', formatAmount((Double) currentGroup.get('totalAmount')));

					dataList.add(currentGroup);
				} catch (Exception e) {
					throw new AuraHandledException('Error processing groupKey: ' + e.getMessage());
				}
			}

			result.put('records', dataList);
		} catch (Exception e) {
			result.put('error', 'Error processing data: ' + e.getMessage() + '. Stack trace: ' + e.getStackTraceString());
			throw new AuraHandledException('Error details: ' + e.getMessage());
		}
		return result;
	}
	/**
	 * @description Updates the status of a batch record
	 * @param recordId ID of the SAP_Batch__c record to update
	 * @param status New status value to set
	 * @return String Success message or error details
	 */
	@AuraEnabled
	public static String updateStatus(String recordId, String status) {
		try {
			if (String.isEmpty(recordId) || String.isEmpty(status)) {
				return 'Error: Record ID or Status is empty.';
			}

			if (status.equalsIgnoreCase('Unseal')) {
				status = 'Open';
			}

			SAP_Batch__c batchRecord = [
				SELECT Id, SAP_Batch_Status__c
				FROM SAP_Batch__c
				WHERE Id = :recordId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			if (batchRecord == null) {
				return 'Error: No record found with the provided ID.';
			}
			batchRecord.SAP_Batch_Status__c = status;

			Database.update(batchRecord, AccessLevel.SYSTEM_MODE);

			return 'Success';
		} catch (DmlException dmlEx) {
			throw new AuraHandledException('Error details: ' + dmlEx.getMessage());
		}
	}

	/**
	 * @description Formats a double amount value to a 2-decimal place Decimal
	 * @param amount Double value to format
	 * @return Decimal Formatted amount with 2 decimal places
	 */
	private static Decimal formatAmount(Double amount) {
		if (amount == 0 || amount == null) {
			return 0.00;
		}
		Decimal decAmount = Decimal.valueOf(amount).setScale(2);
		return decAmount;
	}
}