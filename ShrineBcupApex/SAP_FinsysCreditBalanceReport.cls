public with sharing class SAP_FinsysCreditBalanceReport {

    @AuraEnabled
    public static List<Map<String, Object>> creditBalanceReport(String jsonInput) {
        try {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('Input is null or empty.');
            }

            // Parse input JSON parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            String customerId = (String) params.get('customerId');                        
            String nameSearch = (String) params.get('name');

            Date createddate = params.containsKey('createddate') && params.get('createddate') != null 
                ? Date.valueOf((String) params.get('createddate')) 
                : null;
           
            Date transactionFromDate = params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null 
                ? Date.valueOf((String) params.get('transactionFromDate')) 
                : null;
            Date transactionToDate = params.containsKey('transactionToDate') && params.get('transactionToDate') != null 
                ? Date.valueOf((String) params.get('transactionToDate')) 
                : null;

            Integer currentPage = params.containsKey('currentPage') ? (Integer) params.get('currentPage') : 1;
            Integer pageSize = params.containsKey('pageSize') ? (Integer) params.get('pageSize') : 10;
            String sortedBy = params.containsKey('sortedBy') ? (String) params.get('sortedBy') : 'Name';
            String sortedDirection = params.containsKey('sortedDirection') ? (String) params.get('sortedDirection') : 'ASC';

            //System.debug('Input Parameters for Results: ' + params);

            // Fetch the RecordTypeId for "FinSys Customers"
            Id finsysCustomerRecordTypeId = [
                SELECT Id 
                FROM RecordType 
                WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers'
                LIMIT 1
            ].Id;

            // Build the query for Contacts
            String query = 'SELECT Id, Name, Customer__c, Email, Phone, SAP_Customer_Account_Balance__c, ' +
                           'SAP_Last_Balance_Update__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, CreatedDate ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND SAP_Customer_Account_Balance__c > 0';
				System.debug(customerId);
            if (!String.isBlank(customerId)) {
                query += ' AND Customer__c = :customerId';
            }
            if (createddate != null) {
                query += ' AND CreatedDate = :createddate';
            }
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
            if (transactionFromDate != null) {
                query += ' AND CreatedDate >= :transactionFromDate';
            }
            if (transactionToDate != null) {
                query += ' AND CreatedDate <= :transactionToDate';
            }
           
            // Apply sorting
            query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
	      // Apply pagination
            Integer offset = (currentPage - 1) * pageSize;
            query += ' LIMIT :pageSize OFFSET :offset';
            
            System.debug('SOQL Query for Results: ' + query);

            // Execute query
            List<Contact> customers = Database.query(query);
            System.debug('Number of Customers Fetched for Results: ' + customers);

            // Prepare results
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            for (Contact customer : customers) {
                String formattedAddress = (customer.MailingStreet != null ? customer.MailingStreet + ', ' : '') +
                                          (customer.MailingCity != null ? customer.MailingCity + ', ' : '') +
                                          (customer.MailingState != null ? customer.MailingState + ', ' : '') +
                                          (customer.MailingPostalCode != null ? customer.MailingPostalCode + ', ' : '') +
                                          (customer.MailingCountry != null ? customer.MailingCountry : '');

                results.add(new Map<String, Object>{
                    'Customer__c' => customer.Customer__c,
                    'Name' => customer.Name,
                    'MailingAddress' => formattedAddress,
                    'SAP_Customer_Account_Balance__c' => customer.SAP_Customer_Account_Balance__c,
                    'CreatedDate' => customer.CreatedDate
                });
            }
		
            return results;

        } catch (Exception e) {
            System.debug('Error in creditBalanceReport: ' + e.getMessage());
            throw new AuraHandledException('Error fetching credit balance report: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer creditBalanceReportCount(String jsonInput) {
        try {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('Input is null or empty.');
            }

            // Parse input JSON parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            String customerId = (String) params.get('customerId');
            String nameSearch = (String) params.get('name');
            Date createddate = params.containsKey('createddate') && params.get('createddate') != null 
            ? Date.valueOf((String) params.get('createddate')) 
            : null;
            Date transactionFromDate = params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null 
                ? Date.valueOf((String) params.get('transactionFromDate')) 
                : null;
            Date transactionToDate = params.containsKey('transactionToDate') && params.get('transactionToDate') != null 
                ? Date.valueOf((String) params.get('transactionToDate')) 
                : null;

            // Fetch the RecordTypeId for "FinSys Customers"
            Id finsysCustomerRecordTypeId = [
                SELECT Id 
                FROM RecordType 
                WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers'
                LIMIT 1
            ].Id;

            // Build the count query
            String query = 'SELECT COUNT() ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND SAP_Customer_Account_Balance__c > 0';

            if (!String.isBlank(customerId)) {
                query += ' AND Customer__c = :customerId';
            }
            if (createddate != null) {
                query += ' AND CreatedDate = :createddate';
            }
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
            if (transactionFromDate != null) {
                query += ' AND CreatedDate >= :transactionFromDate';
            }
            if (transactionToDate != null) {
                query += ' AND CreatedDate <= :transactionToDate';
            }

          //  System.debug('SOQL Query for Count: ' + query);

            // Execute query
            Integer totalCount = Database.countQuery(query);
           System.debug('Total Records Found: ' + totalCount);

            return totalCount;

        } catch (Exception e) {
            System.debug('Error in creditBalanceReportCount: ' + e.getMessage());
            throw new AuraHandledException('Error fetching record count: ' + e.getMessage());
        }
    }
}