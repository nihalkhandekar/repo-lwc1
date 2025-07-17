public without sharing class SAP_LoggedInUserController {
    
    @AuraEnabled(cacheable=true)
    public static UserCityStateCountryWrapper getUserDetailsCityStateCountryOptions() {
        // Fetch logged-in user details
        User loggedInUser = [
            SELECT Id, Contact.Account.FirstName, Contact.Account.LastName, Contact.Account.SAP_Business_Email_Address__c, Contact.Account.Phone, Contact.Account.Name, 
                   Contact.Account.BillingStreet, Contact.Account.BillingCity, 
                   Contact.Account.BillingState, Contact.Account.BillingPostalCode, 
                   Contact.Account.BillingCountry
            FROM User 
            WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        // // Fetch unique city options
        // Set<String> citySet = new Set<String>();
        // for (Account acc : [SELECT BillingCity FROM Account WHERE BillingCity != NULL]) {
        //     citySet.add(acc.BillingCity);
        // }
        // List<String> cityList = new List<String>(citySet);
        // cityList.sort();
        
        // // Fetch unique state options
        // Set<String> stateSet = new Set<String>();
        // for (Account acc : [SELECT BillingState FROM Account WHERE BillingState != NULL]) {
        //     stateSet.add(acc.BillingState);
        // }
        // List<String> stateList = new List<String>(stateSet);
        // stateList.sort();
        
        // // Fetch unique country options
        // Set<String> countrySet = new Set<String>();
        // for (Account acc : [SELECT BillingCountry FROM Account WHERE BillingCountry != NULL]) {
        //     countrySet.add(acc.BillingCountry);
        // }
        // List<String> countryList = new List<String>(countrySet);
        // countryList.sort();
        
        // Return the wrapper object
        return new UserCityStateCountryWrapper(loggedInUser);
    }
    
    public class UserCityStateCountryWrapper {
        @AuraEnabled
        public User userDetails { get; set; }
        
        // @AuraEnabled
        // public List<String> cityOptions { get; set; }
        
        // @AuraEnabled
        // public List<String> stateOptions { get; set; }
        
        // @AuraEnabled
        // public List<String> countryOptions { get; set; }
        
        public UserCityStateCountryWrapper(User userDetails) {
            this.userDetails = userDetails;
            // this.cityOptions = cityOptions;
            // this.stateOptions = stateOptions;
            // this.countryOptions = countryOptions;
        }
    }
}