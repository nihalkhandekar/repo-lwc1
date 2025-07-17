public class getReceiptDetail {
    @AuraEnabled(cacheable=true)
    public static List<RegulatoryTrxnFeeItem> getReceipt(String Name) {
        // Check if Application Id is empty
        if (String.isBlank(Name)) {
            System.debug('Application Id is empty');
            //return new List<RegulatoryWrapper>();
        }
        
        List<RegulatoryTrxnFeeItem> feeItems = [
            SELECT Id, Payment_Type__c, 
                   FeeAmount, Transaction_Date__c
            FROM RegulatoryTrxnFeeItem
            WHERE RegulatoryTrxnFee.ParentRecordId =: Name
        ];
        
        return feeItems;
    }
        
}