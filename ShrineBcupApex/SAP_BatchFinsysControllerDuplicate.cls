/**
 * Class Name: SAP_BatchFinsysControllerDuplicate
 * @description This class handles batch operations for the SAP financial system integration
 * It provides functionality to retrieve transaction data and update batch statuses
 */
public with sharing class SAP_BatchFinsysControllerDuplicate {
	/**
	 * @description Retrieves batch and related transaction data when only the batch ID is available
	 * @param searchParamsJson The ID of the batch to retrieve data for
	 * @return Map<String, Object> Contains batch details and associated transaction fees
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getActivityTransactionDataWhenOnlyIdIsAvailable(Id searchParamsJson) {
		Map<String, Object> result = new Map<String, Object>();
		List<Map<String, Object>> dataList = new List<Map<String, Object>>();

		try {
			String batchQuery = 'select id,SAP_Batch_Name__c, SAP_Batch_Date__c, CreatedBy.Name, SAP_Batch_Status__c, SAP_Transacation_Count__c, SAP_Transacation_Amount__c, LastModifiedDate FROM SAP_Batch__c WHERE Id=:searchParamsJson LIMIT 1';
			// Execute Batch query
			List<SAP_Batch__c> batches = Database.query(batchQuery);
			// Query related regulatory transaction fees
			String feeQuery = 'SELECT Id, SAP_Payment_Type__c, TotalFeeAmount, CreatedDate, SAP_Batch_Look_Up__r.SAP_Batch_Name__c, SAP_Batch_Look_Up__r.SAP_Batch_Date__c, SAP_Batch_Look_Up__r.CreatedBy.Name, SAP_Batch_Look_Up__r.SAP_Batch_Status__c, SAP_Batch_Look_Up__r.SAP_Transacation_Count__c, SAP_Batch_Look_Up__r.SAP_Transacation_Amount__c,ParentRecordId, SAP_Batch_Look_Up__r.LastModifiedDate, RecordType.DeveloperName FROM RegulatoryTrxnFee WHERE SAP_Batch_Look_Up__r.id =:searchParamsJson AND ParentRecordId in (select id from IndividualApplication)';
			List<RegulatoryTrxnFee> fees = Database.query(feeQuery);
			Map<String, Object> batchData = new Map<String, Object>();
			// Collect all parent record IDs for application lookup
			Set<Id> parentRecordIds = new Set<Id>();
			for (RegulatoryTrxnFee fee : fees) {
				parentRecordIds.add(fee.ParentRecordId);
			}
			// Query IndividualApplication records based on collected ParentRecordIds
			List<IndividualApplication> individualApplications = [
				SELECT Id, Name, SAP_First_Name__c, SAP_Last_Name__c
				FROM IndividualApplication
				WHERE Id IN :parentRecordIds
				WITH SECURITY_ENFORCED
			];
			// Create a map for easy lookup by ParentRecordId
			Map<Id, IndividualApplication> individualApplicationMap = new Map<Id, IndividualApplication>();
			for (IndividualApplication app : individualApplications) {
				individualApplicationMap.put(app.Id, app);
			}
			// Initialize variable to track total transaction amount
			Decimal totalTrxnAmount = 0;
			id RegulatoryTrxnFeeId;
			// Process batch data
			for (SAP_Batch__c batch : batches) {
				batchData.put('Id', batch.Id);
				batchData.put('BatchCode', batch.SAP_Batch_Name__c);
				batchData.put('CreatedDate', batch.SAP_Batch_Date__c);
				batchData.put('CreatedBy', batch.CreatedBy.Name);
				batchData.put('BatchStatus', batch.SAP_Batch_Status__c);
				batchData.put('TransactionCount', batch.SAP_Transacation_Count__c);
				batchData.put('LastModifiedDate', batch.LastModifiedDate);

				// Collect Fees under this batch
				List<Map<String, Object>> feeList = new List<Map<String, Object>>();
				for (RegulatoryTrxnFee fee : fees) {
					Map<String, Object> feeData = new Map<String, Object>();
					feeData.put('Id', fee.Id);
					RegulatoryTrxnFeeId = fee.id;
					feeData.put('PaymentType', fee.SAP_Payment_Type__c);
                    feeData.put('TransactionType', fee.RecordType.DeveloperName);
					feeData.put('TotalFeeAmount', formatAmount((Double) fee.TotalFeeAmount));
					// Accumulate total transaction amount
					totalTrxnAmount += fee.TotalFeeAmount;
					feeData.put('CreatedDate', fee.CreatedDate.format('MM/dd/yyyy', 'GMT'));
					feeData.put('ParentRecordId', fee.ParentRecordId);
					feeData.put('BatchStatus', fee.SAP_Batch_Look_Up__r.SAP_Batch_Status__c);
					feeData.put('TransactionAmount', fee.SAP_Batch_Look_Up__r.SAP_Transacation_Amount__c);
					// Add IndividualApplication info if available
					IndividualApplication app = individualApplicationMap.get(fee.ParentRecordId);
					if (app != null) {
						feeData.put('firstName', app.SAP_First_Name__c);
						feeData.put('lastName', app.SAP_Last_Name__c);
						feeData.put('individualApplicationId', app.id);
					}
					feeList.add(feeData);
				}
				// Add the calculated total transaction amount to batch data
				batchData.put('TransactionAmount', formatAmount((Double) totalTrxnAmount));
				batchData.put('Fees', feeList);
			}
			result.put('BatchData', batchData);
		} catch (Exception e) {
			result.put('error', e.getMessage());
			throw new AuraHandledException('Error Message: ' + e.getMessage());
		}
		return result;
	}
	/**
	 * @description Formats a numeric amount to a standard 2-decimal place format
	 * @param amount The amount to format
	 * @return Decimal The formatted amount with 2 decimal places
	 */
	private static Decimal formatAmount(Double amount) {
		if (amount == 0 || amount == null) {
			return 0.00;
		}
		Decimal decAmount = Decimal.valueOf(amount).setScale(2);
		return decAmount;
	}
	/**
	 * @description Retrieves activity IDs associated with a regulatory fee
	 * @param regulatoryFeeId The ID of the regulatory fee to get activities for
	 * @return set<id> Set of activity IDs linked to the regulatory fee
	 */
	private static set<id> GetActivityId(id regulatoryFeeId) {
		set<id> activityId = new Set<id>();
		// Query mapping objects that link activities to the regulatory fee
		list<SAP_ActivityTransactionItemMapping__c> mappingObject = [
			SELECT Id, Activity__c, Regulatory_Transaction_Fee_Item__c, Regulatory_Transaction_Fee__c, Refund_Transaction_Id__c, Transaction_Type__c
			FROM SAP_ActivityTransactionItemMapping__c
			WHERE Regulatory_Transaction_Fee__c = :regulatoryFeeId
			WITH SECURITY_ENFORCED
		];
		// Extract activity IDs from the mapping objects
		for (SAP_ActivityTransactionItemMapping__c mapObj : mappingObject) {
			activityId.add(mapObj.Activity__c);
		}
		return activityId;
	}
	/**
	 * @description Updates the status of a batch based on provided data
	 * @param BatchData JSON string containing batch ID and new status
	 * @return String Success message if update is successful
	 */
	@AuraEnabled
	public static String UpdateBatchStatus(String BatchData) {
		try {
			// Deserialize JSON data
			Map<String, Object> batchDataRetrieved = (Map<String, Object>) JSON.deserializeUntyped(BatchData);
			String batchId = (String) batchDataRetrieved.get('BatchId');
			String batchStatus = (String) batchDataRetrieved.get('NewBatchStatus');

			// Query and update in one transaction
			SAP_Batch__c batchToUpdate = [
				SELECT Id
				FROM SAP_Batch__c
				WHERE Id = :batchId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			batchToUpdate.SAP_Batch_Status__c = batchStatus;
			Database.update(batchToUpdate, false, AccessLevel.USER_MODE);
			return 'Success';
		} catch (Exception e) {
			throw new AuraHandledException('Error Message: ' + e.getMessage());
		}
	}
}