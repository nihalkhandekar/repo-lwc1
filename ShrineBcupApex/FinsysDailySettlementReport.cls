public with sharing class FinsysDailySettlementReport {

    // Wrapper class for card type-wise transactions including refund
    public class CardTransactionWrapper {
        @AuraEnabled public String cardType;
        @AuraEnabled public Integer transactionCount;
        @AuraEnabled public Decimal totalAmount;
        @AuraEnabled public Decimal refundAmount;
        @AuraEnabled public Decimal totalBalance;

        public CardTransactionWrapper(String cardType, Integer transactionCount, Decimal totalAmount, Decimal refundAmount, Decimal totalBalance) {
            this.cardType = cardType;
            this.transactionCount = transactionCount;
            this.totalAmount = totalAmount;
            this.refundAmount = refundAmount;
            this.totalBalance = totalBalance;
        }
    }

    @AuraEnabled
    public static List<CardTransactionWrapper> getDailySettlementReport(String paramsJson) {
        try {
            // Parse input parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);

            // Extract the date parameter, default to today if not provided
            Date transactionDate = params.containsKey('transactionDate') && params.get('transactionDate') != null 
                ? Date.valueOf((String) params.get('transactionDate')) 
                : Date.today();

            // **Step 1: Fetch IndividualApplication IDs for Finsys and Apostille**
            List<Id> finsysIds = new List<Id>();
            List<Id> apostilleIds = new List<Id>();

            for (IndividualApplication app : [
                SELECT Id, RecordType.DeveloperName 
                FROM IndividualApplication 
                WHERE RecordType.DeveloperName IN ('Finsys', 'Apostille')
            ]) {
                if (app.RecordType.DeveloperName == 'Finsys') {
                    finsysIds.add(app.Id);
                } else if (app.RecordType.DeveloperName == 'Apostille') {
                    apostilleIds.add(app.Id);
                }
            }

            if (finsysIds.isEmpty() && apostilleIds.isEmpty()) {
                throw new AuraHandledException('No Finsys or Apostille records found.');
            }

            // **Step 2: Fetch Sales Transactions (Card Payments)**
            List<RegulatoryTrxnFee> regTransactions = [
                SELECT Card_Type__c, TotalFeeAmount
                FROM RegulatoryTrxnFee
                WHERE Payment_Type__c = 'Card' 
                AND RecordType.DeveloperName = 'New_Transaction'
                AND Transaction_Date__c = :transactionDate
                AND (ParentRecordId IN :finsysIds OR ParentRecordId IN :apostilleIds)
            ];

            // **Step 3: Fetch Refund Transactions**
            Map<Id, String> transactionCardTypeMap = new Map<Id, String>();
            for (RegulatoryTrxnFee txn : regTransactions) {
                transactionCardTypeMap.put(txn.Id, txn.Card_Type__c);
            }

            List<RegulatoryTrxnFee> refundTransactions = [
                SELECT Related_to_Transaction__c, TotalFeeAmount
                FROM RegulatoryTrxnFee
                WHERE Payment_Type__c = 'Card' 
                AND RecordType.DeveloperName = 'Refund_Transaction'
                AND Transaction_Date__c = :transactionDate
                AND Related_to_Transaction__c IN :transactionCardTypeMap.keySet()
            ];

            // **Step 4: Process Data - Group transactions and refunds by card type**
            Map<String, Map<String, Object>> cardTypeData = new Map<String, Map<String, Object>>();
            Integer grandTotalTransactions = 0;
            Decimal grandTotalAmount = 0.00;
            Decimal grandTotalRefund = 0.00;
            Decimal grandTotalBalance = 0.00;

            // Process Sales Transactions
            for (RegulatoryTrxnFee txn : regTransactions) {
                String cardType = txn.Card_Type__c != null ? txn.Card_Type__c : 'Unknown';
                Decimal amount = txn.TotalFeeAmount != null ? txn.TotalFeeAmount : 0;

                if (!cardTypeData.containsKey(cardType)) {
                    cardTypeData.put(cardType, new Map<String, Object>{
                        'TransactionCount' => 0,
                        'TotalAmount' => 0.00,
                        'RefundAmount' => 0.00
                    });
                }

                Map<String, Object> cardDetails = cardTypeData.get(cardType);
                cardDetails.put('TransactionCount', ((Integer) cardDetails.get('TransactionCount')) + 1);
                cardDetails.put('TotalAmount', ((Decimal) cardDetails.get('TotalAmount')) + amount);

                grandTotalTransactions += 1;
                grandTotalAmount += amount;
            }

            // Process Refund Transactions
            for (RegulatoryTrxnFee refund : refundTransactions) {
                Id originalTxnId = refund.Related_to_Transaction__c;
                String cardType = transactionCardTypeMap.containsKey(originalTxnId) ? transactionCardTypeMap.get(originalTxnId) : 'Unknown';
                Decimal refundAmount = refund.TotalFeeAmount != null ? refund.TotalFeeAmount : 0;

                if (!cardTypeData.containsKey(cardType)) {
                    cardTypeData.put(cardType, new Map<String, Object>{
                        'TransactionCount' => 0,
                        'TotalAmount' => 0.00,
                        'RefundAmount' => 0.00
                    });
                }

                Map<String, Object> cardDetails = cardTypeData.get(cardType);
                cardDetails.put('RefundAmount', ((Decimal) cardDetails.get('RefundAmount')) + refundAmount);

                grandTotalRefund += refundAmount;
            }

            // **Step 5: Build Final Report with Grand Total**
            List<CardTransactionWrapper> results = new List<CardTransactionWrapper>();

            for (String cardType : cardTypeData.keySet()) {
                Map<String, Object> details = cardTypeData.get(cardType);
                Decimal totalAmount = (Decimal) details.get('TotalAmount');
                Decimal refundAmount = (Decimal) details.get('RefundAmount');
                Decimal totalBalance = totalAmount - refundAmount;

                results.add(new CardTransactionWrapper(
                    cardType,
                    (Integer) details.get('TransactionCount'),
                    totalAmount,
                    refundAmount,
                    totalBalance
                ));

                grandTotalBalance += totalBalance;
            }

            // **Add Grand Total row**
            results.add(new CardTransactionWrapper('Grand Total', grandTotalTransactions, grandTotalAmount, grandTotalRefund, grandTotalBalance));

            return results;

        } catch (Exception ex) {
            System.debug('Error in getDailySettlementReport: ' + ex.getMessage());
            throw new AuraHandledException('Unable to generate the daily settlement report. Please try again.');
        }
    }
}