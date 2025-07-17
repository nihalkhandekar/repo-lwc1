public with sharing class CTBOT_BusinessSearchDueDateChecker {
    
    @InvocableMethod(label='Is due date within 90 days?')
    public static List<Boolean> dueDateWithinNinetyDays(List<Account> accounts) {

        if (Date.today().addDays(90) > accounts[0].Annual_Report_Due_Date__c) {
            return new List<Boolean>{ true };
        } else return new List<Boolean>{ false };
    }
}