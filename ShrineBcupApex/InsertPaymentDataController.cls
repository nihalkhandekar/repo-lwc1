public class InsertPaymentDataController {

    @AuraEnabled
    public static Decimal createMultipleTransaction(List<Map<String, Object>> rows) {
        // Ensure input is not null or empty
        if (rows == null || rows.isEmpty()) {
            return 0;
        }

        // Check if the user has insert access on RegulatoryTrxnFee and RegulatoryTrxnFeeItem objects
        if (!Schema.sObjectType.RegulatoryTrxnFee.isCreateable() || !Schema.sObjectType.RegulatoryTrxnFeeItem.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create records.');
        }

        List<RegulatoryTrxnFee> parentRecords = new List<RegulatoryTrxnFee>();
        List<RegulatoryTrxnFeeItem> childRecords = new List<RegulatoryTrxnFeeItem>();

        Decimal totalSum = 0;

        for (Map<String, Object> row : rows) {
            RegulatoryTrxnFee parent = new RegulatoryTrxnFee(
                Auth_Code__c = String.valueOf(row.get('authCode')),
                Payment_Type__c = String.valueOf(row.get('type')),
                Status = 'Paid',
                Brand__c = String.valueOf(row.get('cardType')),
                Card_Number__c = Decimal.valueOf(String.valueOf(row.get('last4Digits'))),
                amount__c = Decimal.valueOf(String.valueOf(row.get('paymentAmount'))),
                ParentRecordId = String.valueOf(row.get('recordIdIndApp'))
            );
            parentRecords.add(parent);
            
            Decimal totalAmount = null;
            String paymentAmount = String.valueOf(row.get('paymentAmount'));
            String paymentAmountCheck = String.valueOf(row.get('paymentAmountCheck'));

            if (String.isNotBlank(paymentAmount)) {
                totalAmount = Decimal.valueOf(paymentAmount);  
            } else if (String.isNotBlank(paymentAmountCheck)) {
                totalAmount = Decimal.valueOf(paymentAmountCheck);  
            }

            if (totalAmount != null) {
                totalSum += totalAmount;
            }

            RegulatoryTrxnFeeItem child = new RegulatoryTrxnFeeItem(
                FeeAmount = totalAmount
            );
            childRecords.add(child);
        }

        // Enforce user mode before DML operations using Security.stripInaccessible
        SObjectAccessDecision sanitizedParentRecords = Security.stripInaccessible(AccessType.CREATABLE, parentRecords);
        List<RegulatoryTrxnFee> insertableParentRecords = (List<RegulatoryTrxnFee>) sanitizedParentRecords.getRecords();
        
        insert insertableParentRecords;

        for (Integer i = 0; i < insertableParentRecords.size(); i++) {
            childRecords[i].RegulatoryTrxnFeeId = insertableParentRecords[i].Id;
            childRecords[i].Name = 'Transaction fee Item' + ' [' + String.valueOf(i) + ']';
        }

        // Enforce user mode for child records before insert
        SObjectAccessDecision sanitizedChildRecords = Security.stripInaccessible(AccessType.CREATABLE, childRecords);
        List<RegulatoryTrxnFeeItem> insertableChildRecords = (List<RegulatoryTrxnFeeItem>) sanitizedChildRecords.getRecords();
        
        insert insertableChildRecords;

        return totalSum;
    }
}