public with sharing class CTBOT_BusinessSearchByID {
    
    @InvocableMethod(label = 'Get business details by ID')
    public static List<Output> getBusinessInfoByID(List<String> ids) {
        Output output = new Output();
        brs_onlineEnquiryBusinessSearchBusCls.businessDetails details = new brs_onlineEnquiryBusinessSearchBusCls.businessDetails();
        brs_onlineEnquiryBusinessSearchBusCls.results results = new brs_onlineEnquiryBusinessSearchBusCls.results();
        brs_genericSearchBusinessClass.filterWrapper filterOptions = new brs_genericSearchBusinessClass.filterWrapper();
        filterOptions.type = 'Business Status';
        filterOptions.selectedOptions = new List<String>{ 'Active' };

        results = brs_onlineEnquiryBusinessSearch.getBusiness(ids[0], 'Business ALEI', 
            new List<brs_genericSearchBusinessClass.filterWrapper>{ filterOptions }, false, '');

        System.debug('results from CTBOT_BusinessSearchByID: ' + results);
        
        if (results.resultCount == 1) {
            brs_onlineEnquiryBusinessSearchBusCls.searchData account = new List<brs_onlineEnquiryBusinessSearchBusCls.searchData>(results.resultList)[0];
            details = brs_onlineEnquiryBusinessSearch.getBusinessDetails(account.accountId);
            output.dueDate = details.annualReportDue;
            output.businessName = details.businessName;
            output.businessAddress = details.businessAddress;
            if (Date.today().addDays(90) > Date.parse(details.annualReportDue)) {
                output.withinNinetyDays = true;
            } else output.withinNinetyDays = false;
        }

        return new List<Output>{ output };
    }

    public class Output {
        @InvocableVariable(label = 'Annual Report due date')
        public String dueDate;

        @InvocableVariable(label = 'Business name')
        public String businessName;

        @InvocableVariable(label = 'Business address')
        public String businessAddress;

        @InvocableVariable(label = 'Due date within 90 days')
        public Boolean withinNinetyDays;
    }
}