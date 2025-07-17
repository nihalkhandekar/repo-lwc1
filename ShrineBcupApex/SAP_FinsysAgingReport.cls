public with sharing class SAP_FinsysAgingReport {
    @AuraEnabled
    public static List<Map<String, Object>> agingReport(String jsonInput) {
        try {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('Input is null or empty.');
            }
    
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            String nameSearch = (String) params.get('customerName');
            Date reportDate = params.containsKey('reportDate') && params.get('reportDate') != null 
                ? Date.valueOf((String) params.get('reportDate')) 
                : Date.today();
    
            Integer currentPage = params.containsKey('currentPage') ? (Integer) params.get('currentPage') : 1;
            Integer recordsPerPage = params.containsKey('recordsPerPage') ? (Integer) params.get('recordsPerPage') : 10;
            String sortedBy = params.containsKey('sortedBy') ? (String) params.get('sortedBy') : 'Customer__c';
            String sortedDirection = params.containsKey('sortedDirection') ? (String) params.get('sortedDirection') : 'ASC';
    
            System.debug('Input Parameters for Results: ' + params);
    
            Id finsysCustomerRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers' LIMIT 1].Id;
            System.debug('Finsys Customer RecordTypeId for Results: ' + finsysCustomerRecordTypeId);
    
            // Build the query
            String query = 'SELECT Id, Customer__c, Name, Email, Phone, SAP_Customer_Account_Balance__c, SAP_Last_Balance_Update__c ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND SAP_Customer_Account_Balance__c > 0';
    
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
    
            // Apply sorting
            query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
    
            // Apply pagination
            Integer offset = (currentPage - 1) * recordsPerPage;
            query += ' LIMIT :recordsPerPage OFFSET :offset';
    
            System.debug('SOQL Query for Results: ' + query);
    
            // Execute query
            List<Contact> customers = Database.query(query);
            System.debug('Number of Customers Fetched for Results: ' + customers.size());
    
            // Prepare results
            List<Map<String, Object>> agingReport = new List<Map<String, Object>>();
            for (Contact customer : customers) {
                Decimal totalBalance = customer.SAP_Customer_Account_Balance__c != null ? customer.SAP_Customer_Account_Balance__c : 0;
    
                Integer daysSinceUpdate = customer.SAP_Last_Balance_Update__c != null
                    ? customer.SAP_Last_Balance_Update__c.date().daysBetween(reportDate)
                    : 0;
    
                Decimal balance1Day = (daysSinceUpdate >= 1 && daysSinceUpdate < 30) ? totalBalance : 0;
                Decimal balance30Days = (daysSinceUpdate >= 30 && daysSinceUpdate < 60) ? totalBalance : 0;
                Decimal balance60Days = (daysSinceUpdate >= 60 && daysSinceUpdate < 90) ? totalBalance : 0;
                Decimal balance90Days = (daysSinceUpdate >= 90 && daysSinceUpdate < 120) ? totalBalance : 0;
                Decimal balance120PlusDays = (daysSinceUpdate >= 120) ? totalBalance : 0;
    
                agingReport.add(new Map<String, Object>{
                    'CustomerId' => customer.Id,
                    'CustomerID' => customer.Customer__c,
                    'Name' => customer.Name,
                    'Email' => customer.Email,
                    'PhoneNumber' => customer.Phone,
                    '1Day' => balance1Day,
                    '30Days' => balance30Days,
                    '60Days' => balance60Days,
                    '90Days' => balance90Days,
                    '120PlusDays' => balance120PlusDays,
                    'TotalBalance' => totalBalance
                });
            }
    
            System.debug('Aging Report Results Data: ' + agingReport);
            return agingReport;
    
        } catch (Exception e) {
            System.debug('Error in agingReportResults: ' + e.getMessage());
            throw new AuraHandledException('Error fetching aging report results: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer agingReportCount(String jsonInput) {
        try {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('Input is null or empty.');
            }
    
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            String nameSearch = (String) params.get('Name');
    
            System.debug('Input Parameters for Count: ' + params);
    
            Id finsysCustomerRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers' LIMIT 1].Id;
            System.debug('Finsys Customer RecordTypeId for Count: ' + finsysCustomerRecordTypeId);
    
            // Build the query
            String query = 'SELECT COUNT() ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND SAP_Customer_Account_Balance__c > 0';
    
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
    
            System.debug('SOQL Query for Count: ' + query);
    
            // Execute query
            Integer totalCount = Database.countQuery(query);
            System.debug('Total Records Found: ' + totalCount);
    
            return totalCount;
    
        } catch (Exception e) {
            System.debug('Error in agingReportCount: ' + e.getMessage());
            throw new AuraHandledException('Error fetching record count: ' + e.getMessage());
        }
    }
}