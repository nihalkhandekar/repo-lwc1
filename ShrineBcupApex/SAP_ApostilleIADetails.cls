public with sharing class SAP_ApostilleIADetails {
    @AuraEnabled
    public static Map<String, String> getApplicationDetails(Id recordId) {
        // Fetch the details from the record using the recordId
        IndividualApplication indApp = [SELECT Id, Name, SAP_Sequence_Number__c, SAP_First_Name__c, SAP_Last_Name__c, SAP_Email_Address__c  FROM IndividualApplication WHERE Id = :recordId LIMIT 1];

        // Return the details in a Map
        Map<String, String> result = new Map<String, String>();
        result.put('firstName', String.valueOf(indApp.SAP_First_Name__c));
        result.put('lastName', String.valueOf(indApp.SAP_Last_Name__c));
        result.put('sequanceNumber', String.valueOf(indApp.SAP_Sequence_Number__c));
        result.put('emailAddress', String.valueOf(indApp.SAP_Email_Address__c));

               List<RegulatoryTrxnFee> feesList = [
            SELECT Id, SAP_Auth_Code__c, TotalFeeAmount, SAP_Transaction_Date__c, SAP_Payment_Method__c, SAP_Payment_Type__c, SAP_Card_Number__c, SAP_Brand__c
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :indApp.Id
            LIMIT 1
        ];

        if (!feesList.isEmpty()) {
            RegulatoryTrxnFee fees = feesList[0];

            result.put('AuthenticationCode', String.valueOf(fees.SAP_Auth_Code__c));
            result.put('TotalFees', fees.TotalFeeAmount != null ? String.valueOf(fees.TotalFeeAmount) : '0.00');
            result.put('MethodofPayment', String.valueOf(fees.SAP_Payment_Type__c));
            result.put('DateofPayment', String.valueOf(fees.SAP_Transaction_Date__c));
            result.put('CardLastDigit', String.valueOf(fees.SAP_Card_Number__c));
            result.put('CreditCardName', String.valueOf(fees.SAP_Brand__c));
        } else {
            // Set SAP_Payment_Type__c as 'Check' when no record is found
            result.put('AuthenticationCode', '');
            result.put('TotalFees', '0.00');
            result.put('MethodofPayment', 'Check');
            result.put('DateofPayment', '');
            result.put('CardLastDigit', '');
            result.put('CreditCardName', '');
        }

        return result;
    }
}