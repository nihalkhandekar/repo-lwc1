@isTest
public class DependentPicklistControllerTest {
    @testSetup
    static void setup() {
        // Insert sample Account records for testing
         Account acc1 = new Account(Name = 'Account 1', Type = 'Competitor', Rating = 'Hot', Industry = 'Apparel');
    Account acc2 = new Account(Name = 'Account 2', Type = 'Investor', Rating = 'Warm', Industry = 'Communications');
    Account acc3 = new Account(Name = 'Account 3', Type = 'Competitor', Rating = 'Cold', Industry = 'Apparel');
    Account acc4 = new Account(Name = 'Account 4', Type = 'Investor', Rating = 'Hot', Industry = 'Communications');
    Account acc5 = new Account(Name = 'Account 5', Type = 'Competitor', Rating = 'Warm', Industry = 'Banking');
    insert new List<Account>{acc1, acc2, acc3, acc4, acc5};
    }

    @isTest
    static void testFetchDependentPicklistValues() {
        // Call the fetchDependentPicklistValues method
        String jsonResult = DependentPicklistController.fetchDependentPicklistValues();

        // Deserialize the JSON string into a Map
        Map<String, List<Map<String, List<String>>>> resultMap = 
            (Map<String, List<Map<String, List<String>>>>) JSON.deserializeUntyped(jsonResult);

        // Assertions to verify the map structure and contents
        System.assert(resultMap.containsKey('Customer'), 'Expected "Customer" type to be in the result map.');
        System.assert(resultMap.containsKey('Partner'), 'Expected "Partner" type to be in the result map.');

        // Verify "Customer" entries
        List<Map<String, List<String>>> customerList = resultMap.get('Customer');
        System.assertEquals(2, customerList.size(), 'Expected 2 entries for "Customer" type.');

        // Validate entries for "Hot" rating in "Customer" type
        Map<String, List<String>> customerHotMap = customerList[0];
        System.assert(customerHotMap.containsKey('Hot'), 'Expected "Hot" rating to be present in "Customer" type.');
        System.assert(customerHotMap.get('Hot').contains('Technology'), 'Expected "Technology" in "Hot" rating for "Customer" type.');
        System.assert(customerHotMap.get('Hot').contains('Finance'), 'Expected "Finance" in "Hot" rating for "Customer" type.');

        // Validate entries for "Warm" rating in "Customer" type
        Map<String, List<String>> customerWarmMap = customerList[1];
        System.assert(customerWarmMap.containsKey('Warm'), 'Expected "Warm" rating to be present in "Customer" type.');
        System.assert(customerWarmMap.get('Warm').contains('Healthcare'), 'Expected "Healthcare" in "Warm" rating for "Customer" type.');

        // Verify "Partner" entries
        List<Map<String, List<String>>> partnerList = resultMap.get('Partner');
        System.assertEquals(2, partnerList.size(), 'Expected 2 entries for "Partner" type.');

        // Validate entries for "Cold" rating in "Partner" type
        Map<String, List<String>> partnerColdMap = partnerList[0];
        System.assert(partnerColdMap.containsKey('Cold'), 'Expected "Cold" rating to be present in "Partner" type.');
        System.assert(partnerColdMap.get('Cold').contains('Education'), 'Expected "Education" in "Cold" rating for "Partner" type.');

        // Validate entries for "Warm" rating in "Partner" type
        Map<String, List<String>> partnerWarmMap = partnerList[1];
        System.assert(partnerWarmMap.containsKey('Warm'), 'Expected "Warm" rating to be present in "Partner" type.');
        System.assert(partnerWarmMap.get('Warm').contains('Retail'), 'Expected "Retail" in "Warm" rating for "Partner" type.');
    }
}