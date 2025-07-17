public with sharing class SAP_BatchPDFController {
  public class BatchWrapper {
    @AuraEnabled
    public String batchId;
    @AuraEnabled
    public String batchName;
    @AuraEnabled
    public String createdDate;
    @AuraEnabled
    public String lastModifiedDate;
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public String batchStatus;
    @AuraEnabled
    public Decimal transactionCount;
    @AuraEnabled
    public Decimal transactionAmount;
    @AuraEnabled
    public List<FeeWrapper> fees;
  }

  public class FeeWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String paymentType;
    @AuraEnabled
    public Decimal amount;
    @AuraEnabled
    public String createdDate;
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String lastName;
    @AuraEnabled
    public String individualApplicationId;
  }

  @AuraEnabled(cacheable=true)
  public static BatchWrapper getBatchData(String batchId) {
    BatchWrapper batchData = new BatchWrapper();

    try {
      // Query SAP_Batch__c record
      SAP_Batch__c batch = [
        SELECT
          Id,
          SAP_Batch_Name__c,
          CreatedDate,
          LastModifiedDate,
          CreatedBy.Name,
          SAP_Batch_Status__c,
          SAP_Transacation_Count__c
        FROM SAP_Batch__c
        WHERE Id = :batchId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      batchData.batchId = batch.Id;
      batchData.batchName = batch.SAP_Batch_Name__c;
      batchData.createdDate = batch.CreatedDate.format('MM/dd/yyyy', 'GMT');
      batchData.lastModifiedDate = batch.LastModifiedDate.format(
        'MM/dd/yyyy',
        'GMT'
      );
      batchData.createdBy = batch.CreatedBy.Name;
      batchData.batchStatus = batch.SAP_Batch_Status__c;
      batchData.transactionCount = batch.SAP_Transacation_Count__c;

      // Query RegulatoryTrxnFee records related to the Batch
      List<RegulatoryTrxnFee> fees = [
        SELECT
          Id,
          SAP_Payment_Type__c,
          TotalFeeAmount,
          CreatedDate,
          ParentRecordId
        FROM RegulatoryTrxnFee
        WHERE SAP_Batch_Look_Up__c = :batchId
        WITH SECURITY_ENFORCED
      ];

      // Calculate the total of TotalFeeAmount
      Decimal totalFeeAmountSum = 0;
      for (RegulatoryTrxnFee fee : fees) {
        totalFeeAmountSum += fee.TotalFeeAmount;
      }
      batchData.transactionAmount = totalFeeAmountSum;

      // Query IndividualApplication based on ParentRecordId
      Set<Id> parentRecordIds = new Set<Id>();
      for (RegulatoryTrxnFee fee : fees) {
        parentRecordIds.add(fee.ParentRecordId);
      }

      Map<Id, IndividualApplication> individualApplicationMap = new Map<Id, IndividualApplication>(
        [
          SELECT Id, SAP_First_Name__c, SAP_Last_Name__c
          FROM IndividualApplication
          WHERE Id IN :parentRecordIds
        ]
      );

      // Map fees into FeeWrapper list
      List<FeeWrapper> feeWrappers = new List<FeeWrapper>();
      for (RegulatoryTrxnFee fee : fees) {
        FeeWrapper feeData = new FeeWrapper();
        feeData.id = fee.Id;
        feeData.paymentType = fee.SAP_Payment_Type__c;
        feeData.amount = fee.TotalFeeAmount;
        feeData.createdDate = fee.CreatedDate.format('MM/dd/yyyy', 'GMT');

        // Add IndividualApplication data if available
        IndividualApplication app = individualApplicationMap.get(
          fee.ParentRecordId
        );
        if (app != null) {
          feeData.firstName = app.SAP_First_Name__c;
          feeData.lastName = app.SAP_Last_Name__c;
          feeData.individualApplicationId = app.Id;
        }

        feeWrappers.add(feeData);
      }

      batchData.fees = feeWrappers;
    } catch (Exception e) {
      System.debug('### ERROR: ' + e.getMessage());
      throw new AuraHandledException(
        'Unable to fetch batch data: ' + e.getMessage()
      );
    }

    return batchData;
  }
}