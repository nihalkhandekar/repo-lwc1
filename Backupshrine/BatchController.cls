public class BatchController {    
    @AuraEnabled(cacheable=false)
    public static List<Batch__c> batchItems(
        String batchCode,
        Integer transactionCount,
        String transactionAmount,
        Date batchDate,
        String batchStatus,
        String dateFilter,
        Integer pageNumber,
        Integer pageSize
    ) {
        system.debug('batchCode'+batchCode);
        system.debug('transactionCount'+transactionCount);
        system.debug('transactionAmount'+transactionAmount);
        String query = 'SELECT Id, Batch_Code__c, Transacation_Count__c, Transacation_Amount__c, Batch_Date__c, Batch_Status__c FROM Batch__c';
        List<String> conditions = new List<String>();

        if (String.isNotEmpty(batchCode)) {
            conditions.add('Batch_Code__c LIKE \'%' + String.escapeSingleQuotes(batchCode) + '%\'');
        }
         
       // if (transactionCount != null) {
       //     conditions.add('Transacation_Count__c = :transactionCount');
       // }
        
        if (String.isNotEmpty(transactionAmount)) {
                if (transactionAmount == '0 - 1000') {
                    conditions.add('Transacation_Amount__c >= 0 AND Transacation_Amount__c <= 1000');
                } else if (transactionAmount == '1000 - 5000') {
                    conditions.add('Transacation_Amount__c >= 1000 AND Transacation_Amount__c <= 5000');
                }
             }
        
        //if (transactionAmount != null) {
        //    conditions.add('Transacation_Amount__c = :transactionAmount');
        //}
        if (batchDate != null) {
            conditions.add('Batch_Date__c = :batchDate');
        }
        if (String.isNotEmpty(batchStatus)) {
            List<String> validStatuses = new List<String>{'Open', 'Closed', 'Sealed', 'Unseal'};
            if (validStatuses.contains(batchStatus)) {
                conditions.add('Batch_Status__c = \'' + String.escapeSingleQuotes(batchStatus) + '\'');
            }
        }
        if (String.isNotEmpty(dateFilter)) {
            Date startDate;
            Date endDate;
            try {
                if (dateFilter == 'ThisWeek') {
                    startDate = Date.today().toStartOfWeek();
                    endDate = startDate.addDays(6); // End of the week is 6 days after the start
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisMonth') {
                    startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1); // Start of the month
                    endDate = Date.newInstance(Date.today().year(), Date.today().month() + 1, 1).addDays(-1); // End of the month
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisQuarter') {
                    Integer startMonth = (Date.today().month() - 1) / 3 * 3;
                    startDate = Date.newInstance(Date.today().year(), startMonth + 1, 1); // Start of the quarter
                    endDate = Date.newInstance(Date.today().year(), startMonth + 4, 0); // End of the quarter
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisYear') {
                    startDate = Date.newInstance(Date.today().year(), 1, 1); // Start of the year
                    endDate = Date.newInstance(Date.today().year(), 12, 31); // End of the year
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else {
                    startDate = Date.valueOf(dateFilter);
                    endDate = startDate;
                    conditions.add('Batch_Date__c = :startDate');
                }
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
            }
        }

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        Integer offset = (pageNumber - 1) * pageSize;
        query += ' ORDER BY Batch_Date__c LIMIT :pageSize OFFSET :offset';

        System.debug('Query: ' + query); // Debug log to check the final query
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=false)
    public static Integer getBatchItemCount(
        String batchCode,
        Integer transactionCount,
        String transactionAmount,
        Date batchDate,
        String batchStatus,
        String dateFilter
    ) {
        String countQuery = 'SELECT COUNT() FROM Batch__c';
        List<String> conditions = new List<String>();

        if (String.isNotEmpty(batchCode)) {
            conditions.add('Batch_Code__c LIKE \'%' + String.escapeSingleQuotes(batchCode) + '%\'');
        }
         if (String.isNotEmpty(transactionAmount)) {
                if (transactionAmount == '0 - 1000') {
                    conditions.add('Transacation_Amount__c >= 0 AND Transacation_Amount__c <= 1000');
                } else if (transactionAmount == '1000 - 5000') {
                    conditions.add('Transacation_Amount__c >= 1000 AND Transacation_Amount__c <= 5000');
                }
             }
        
       // if (transactionCount != null) {
       //     conditions.add('Transacation_Count__c = :transactionCount');
       // }
     
        if (batchDate != null) {
            conditions.add('Batch_Date__c = :batchDate');
        }
        if (String.isNotEmpty(batchStatus)) {
            List<String> validStatuses = new List<String>{'Open', 'Closed', 'Sealed', 'Unseal'};
            if (validStatuses.contains(batchStatus)) {
                conditions.add('Batch_Status__c = \'' + String.escapeSingleQuotes(batchStatus) + '\'');
            }
        }
        if (String.isNotEmpty(dateFilter)) {
            Date startDate;
            Date endDate;
            try {
                if (dateFilter == 'ThisWeek') {
                    startDate = Date.today().toStartOfWeek();
                    endDate = startDate.addDays(6); // End of the week is 6 days after the start
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisMonth') {
                    startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1); // Start of the month
                    endDate = Date.newInstance(Date.today().year(), Date.today().month() + 1, 1).addDays(-1); // End of the month
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisQuarter') {
                    Integer startMonth = (Date.today().month() - 1) / 3 * 3;
                    startDate = Date.newInstance(Date.today().year(), startMonth + 1, 1); // Start of the quarter
                    endDate = Date.newInstance(Date.today().year(), startMonth + 4, 0); // End of the quarter
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else if (dateFilter == 'ThisYear') {
                    startDate = Date.newInstance(Date.today().year(), 1, 1); // Start of the year
                    endDate = Date.newInstance(Date.today().year(), 12, 31); // End of the year
                    conditions.add('Batch_Date__c >= :startDate AND Batch_Date__c <= :endDate');
                } else {
                    startDate = Date.valueOf(dateFilter);
                    endDate = startDate;
                    conditions.add('Batch_Date__c = :startDate');
                }
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
            }
        }

        if (!conditions.isEmpty()) {
            countQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }

        // Execute the count query
        Long count = Database.countQuery(countQuery);
        return count != null ? count.intValue() : 0; // Convert Long to Integer and handle null
    }
}