public class ApostilleIndividualApplicationDetails {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getApplicationDetails(Id recordId) {
        // Fetch the details from the record using the recordId
        IndividualApplication indApp = [SELECT Id, Name, Sequence_Number__c, First_Name__c, Last_Name__c  FROM IndividualApplication WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        // Return the details in a Map
        Map<String, String> result = new Map<String, String>();
        result.put('firstName', String.valueOf(indApp.First_Name__c));
        result.put('lastName', String.valueOf(indApp.Last_Name__c));
        result.put('sequanceNumber', String.valueOf(indApp.Sequence_Number__c));

        RegulatoryTrxnFee fees = [
            SELECT Id, Auth_Code__c, TotalFeeAmount, Transaction_Date__c, Payment_Method__c,Payment_Type__c,Card_Number__c,Brand__c
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :indApp.Id WITH SECURITY_ENFORCED LIMIT 1];

        result.put('AuthenticationCode', String.valueOf(fees.Auth_Code__c));
        result.put('TotalFees', String.valueOf(fees.TotalFeeAmount));
        result.put('MethodofPayment', String.valueOf(fees.Payment_Type__c));
        result.put('DateofPayment', String.valueOf(fees.Transaction_Date__c));
        result.put('CardLastDigit',String.valueOf(fees.Card_Number__c));
        result.put('CreditCardName',String.valueOf(fees.Brand__c));

        return result;
    }
}