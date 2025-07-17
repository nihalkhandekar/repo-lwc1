public with sharing class CTBOT_BusinessSearchByName {
    
    @InvocableMethod(label = 'Business search by name')
    public static List<Output> getBusinessInfoByName(List<Input> input) {
        brs_onlineEnquiryBusinessSearchBusCls.businessDetails businessDetails = new brs_onlineEnquiryBusinessSearchBusCls.businessDetails();
        brs_onlineEnquiryBusinessSearchBusCls.results searchResults = new brs_onlineEnquiryBusinessSearchBusCls.results();
        brs_genericSearchBusinessClass.filterWrapper filterOptions = new brs_genericSearchBusinessClass.filterWrapper();
        Set<Id> accountIds = new Set<Id>();
        Output results = new Output();

        filterOptions.type = 'Business Status';
        filterOptions.selectedOptions = new List<String>{ 'Active' };

        searchResults = brs_onlineEnquiryBusinessSearch.getBusiness(input[0].name, 'Business Name', 
            new List<brs_genericSearchBusinessClass.filterWrapper>{ filterOptions }, false, '');

        for (brs_onlineEnquiryBusinessSearchBusCls.searchData data : searchResults.resultList) {
            accountIds.add(data.accountId);
        }

        List<Account> accountQuery = [
            SELECT Name, Annual_Report_Due_Date__c, Chatbot_Annual_Report_Due_Date__c, AccountNumber, 
            BillingPostalCode, BillingCity
            FROM Account
            WHERE Id
            IN :accountIds
        ];

        results.resultCount = searchResults.resultCount;
        results.accounts = accountQuery;

        return new List<Output>{ results };
    }

    public class Input {
        @InvocableVariable(label = 'Business name')
        public String name;
    }

    public class Output {
        @InvocableVariable(label = 'Returned accounts')
        public List<Account> accounts;

        @InvocableVariable(label = 'Result count')
        public Integer resultCount;
    }
}