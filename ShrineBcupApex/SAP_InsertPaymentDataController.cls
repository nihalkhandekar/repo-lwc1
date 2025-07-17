public class SAP_InsertPaymentDataController {

    @AuraEnabled
    public static Decimal createMultipleTransaction(List<Map<String, Object>> rows) {

        List<RegulatoryTrxnFee> parentRecords = new List<RegulatoryTrxnFee>();
        List<RegulatoryTrxnFeeItem> childRecords = new List<RegulatoryTrxnFeeItem>();

        Decimal totalSum = 0;
        System.debug('Rows: ' + rows);

        for (Map<String, Object> row : rows) {
            RegulatoryTrxnFee parent = new RegulatoryTrxnFee(
                SAP_Auth_Code__c = String.valueOf(row.get('authCode')),
                SAP_Payment_Type__c = String.valueOf(row.get('type')),
                Status = 'Paid',
                SAP_Brand__c = String.valueOf(row.get('cardType')),
                SAP_Card_Number__c = Decimal.valueOf(String.valueOf(row.get('last4Digits'))),
                SAP_amount__c = Decimal.valueOf(String.valueOf(row.get('paymentAmount'))),
                SAP_Money_Order_Number__c = Decimal.valueOf(String.valueOf(row.get('moneyOrder'))),
                SAP_CK_Number__c = Decimal.valueOf(String.valueOf(row.get('checkNumber'))),
                ParentRecordId = String.valueOf(row.get('recordIdIndApp'))
            );
            System.debug('Parent: ' + parent);
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
        insert parentRecords;

        for (Integer i = 0; i < parentRecords.size(); i++) {
            childRecords[i].RegulatoryTrxnFeeId = parentRecords[i].Id;
            childRecords[i].Name = 'Transaction fee Item' + ' [' + String.valueOf(i) + ']';
        }
        insert childRecords;

        return totalSum;
    }

    @AuraEnabled
    public static Decimal updateTransaction(String paymentJson) {
        // Convert JSON string to a Map<String, Object>
        Map<String, Object> payment = (Map<String, Object>) JSON.deserializeUntyped(paymentJson);

        RegulatoryTrxnFee transactionFee;
        RegulatoryTrxnFeeItem transactionFeeItem;

        // Check if recordIdTnnx exists (Update existing record)
        if (payment.containsKey('recordIdTnnx') && String.isNotBlank(String.valueOf(payment.get('recordIdTnnx')))) {
            transactionFee = [SELECT Id, SAP_Auth_Code__c, SAP_Payment_Type__c, SAP_CK_Number__c, Status,
                                SAP_Brand__c, SAP_Card_Number__c, SAP_Money_Order_Number__c, SAP_Amount__c, ParentRecordId
                                FROM RegulatoryTrxnFee
                                WHERE Id = :String.valueOf(payment.get('recordIdTnnx'))
                                LIMIT 1];

            // Update fields
            transactionFee.SAP_Auth_Code__c = String.valueOf(payment.get('authCode'));
            transactionFee.SAP_Payment_Type__c = String.valueOf(payment.get('type'));
            transactionFee.SAP_CK_Number__c = Decimal.valueOf(String.valueOf(payment.get('checkNumber')));
            transactionFee.SAP_Money_Order_Number__c = Decimal.valueOf(String.valueOf(payment.get('moneyOrder')));
            transactionFee.Status = 'Paid';
            transactionFee.SAP_Brand__c = String.valueOf(payment.get('cardType'));
            transactionFee.SAP_Card_Number__c = Decimal.valueOf(String.valueOf(payment.get('last4Digits')));

            update transactionFee;
            transactionFeeItem = [SELECT Id, FeeAmount
                                    FROM RegulatoryTrxnFeeItem
                                    WHERE RegulatoryTrxnFeeId = :String.valueOf(payment.get('recordIdTnnx'))
                                    LIMIT 1];

            transactionFeeItem.FeeAmount = Decimal.valueOf(String.valueOf(payment.get('paymentAmount')));
            update transactionFeeItem;



        } else {

        }

        return transactionFeeItem.FeeAmount; // Return saved amount
    }


    @AuraEnabled
    public static void deleteTransaction(Id transactionId) {
        if (String.isEmpty(transactionId)) {
            throw new AuraHandledException('Invalid Transaction ID');
        }

        try {
            // Query related FeeItem records
            List<RegulatoryTrxnFeeItem> feeItems = [SELECT Id FROM RegulatoryTrxnFeeItem WHERE RegulatoryTrxnFeeId = :transactionId];

            // Delete FeeItems first to avoid foreign key constraint issues
            if (!feeItems.isEmpty()) {
                delete feeItems;
            }

            // Delete the RegulatoryTnxFee record
            RegulatoryTrxnFee txn = [SELECT Id FROM RegulatoryTrxnFee WHERE Id = :transactionId LIMIT 1];
            delete txn;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting transaction: ' + e.getMessage());
        }
    }





}