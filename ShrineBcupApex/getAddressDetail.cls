public class getAddressDetail {
 	@AuraEnabled(cacheable=true)
    public static Account getAccountDetails(Id accountId) {
        try {
            return [
                SELECT Id,FirstName, LastName,PersonEmail,Phone,Customer_ID__pc, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving account details: ' + e.getMessage());
        }
    }			
}