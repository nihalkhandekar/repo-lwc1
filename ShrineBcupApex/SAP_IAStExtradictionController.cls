public class SAP_IAStExtradictionController {
    @AuraEnabled
    public static Map<String, Object> getStateExtradictionApplications(Map<String, Object> searchParams) {
        try{
        String firstName = (String) searchParams.get('firstName'); 
        String lastName = (String) searchParams.get('lastName'); 
        String requestDate = (String) searchParams.get('requestDate'); 
        String responseDate = (String) searchParams.get('responseDate'); 
        String extradictedFrom = (String) searchParams.get('extradictedFrom'); 
        String extradictedFileNo = (String) searchParams.get('extradictedFileNo'); 
        String akaFirstName = (String) searchParams.get('akaFirstName'); 
        String akaLastName = (String) searchParams.get('akaLastName'); 
        String actionYear = (String) searchParams.get('actionYear');
        String fromDateString = (String) searchParams.get('fromDate'); 
        String toDateString = (String) searchParams.get('toDate'); 
        Integer offsetVal = searchParams.containsKey('offsetVal') ? ((Decimal) searchParams.get('offsetVal')).intValue() : 0;
        Integer pageSize = searchParams.containsKey('pageSize') ? ((Decimal) searchParams.get('pageSize')).intValue() : 0;
        String sortField = (String) searchParams.get('sortField');
        String sortDirection = (String) searchParams.get('sortDirection');
        String lastSortField = (String) searchParams.get('lastSortField');
    	String lastSortDirection = (String) searchParams.get('lastSortDirection');
        Date fromDate = null;
        Date toDate = null;
        String office = (String) searchParams.get('office');
        if (String.isNotBlank(fromDateString)) {
            fromDate = Date.valueOf(fromDateString);
            system.debug('fromDate@@'+fromDate);
        }
        if (String.isNotBlank(toDateString)) {
            toDate = Date.valueOf(toDateString);
            system.debug('toDate@@'+toDate);
        }
 
        String query = 'SELECT Id, SAP_First_Name__c, SAP_Last_Name__c, SAP_Middle_Name__c, SAP_Extradicted_From__c, SAP_Extradicted_File_Number__c, SAP_Cancellation_Date__c, CreatedDate, Received_for_filling_with_Governor_s_Act__c, SAP_Office__c ' +
                       'FROM IndividualApplication WHERE RecordType.Name = \'State Extraditions\'';
        
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(firstName)) {
            conditions.add('SAP_First_Name__c LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
        }
        if (String.isNotBlank(lastName)) {
            conditions.add('SAP_Last_Name__c LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
        }
        if (String.isNotBlank(office)) {
            conditions.add('SAP_Office__c LIKE \'%' + String.escapeSingleQuotes(office) + '%\'');
        }
        if (fromDate != null && toDate != null) {
            if (fromDate == toDate) {
            	conditions.add('CreatedDate = TODAY');
            } else {
                conditions.add('CreatedDate >= :fromDate AND CreatedDate <= :toDate');
            }
        }  
        if (String.isNotBlank(requestDate)) {
            conditions.add('SAP_Request_Date__c >= ' + String.escapeSingleQuotes(requestDate));
        }
        if (String.isNotBlank(responseDate)) {
            conditions.add('SAP_Response_Date__c <= ' + String.escapeSingleQuotes(responseDate));
        }
        if (String.isNotBlank(extradictedFrom)) {
            conditions.add('SAP_Extradicted_From__c LIKE \'%' + String.escapeSingleQuotes(extradictedFrom) + '%\'');
        }
        if (String.isNotBlank(extradictedFileNo)) {
            conditions.add('SAP_Extradicted_File_Number__c LIKE \'%' + String.escapeSingleQuotes(extradictedFileNo) + '%\'');
        }
        
        if (String.isNotBlank(akaFirstName) || String.isNotBlank(akaLastName)) {
            String akaSubquery = 'Id IN (SELECT Individual_Application__c FROM Person_AKA__c WHERE ';
            List<String> akaConditions = new List<String>();
            
            if (String.isNotBlank(akaFirstName)) {
                akaConditions.add('First_Name__c LIKE \'%' + String.escapeSingleQuotes(akaFirstName) + '%\'');
            }
            if (String.isNotBlank(akaLastName)) {
                akaConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(akaLastName) + '%\'');
            }
            
            akaSubquery += String.join(akaConditions, ' AND ') + ')';
            conditions.add(akaSubquery);
        }
        
        if (String.isNotBlank(actionYear)) {
            conditions.add('CALENDAR_YEAR(Received_for_filling_with_Governor_s_Act__c) = ' + String.escapeSingleQuotes(actionYear));
        }
    
        if (!conditions.isEmpty()) {
            query += ' AND ' + String.join(conditions, ' AND ');
        }
        /*Here */ 

        if (String.isNotBlank(sortField)) {
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection) + ' NULLS LAST';
            if (String.isNotBlank(lastSortField) && lastSortField != sortField) {
                query += ', ' + String.escapeSingleQuotes(lastSortField) + ' ' + String.escapeSingleQuotes(lastSortDirection) + ' NULLS LAST';
            }
            query += ', LastModifiedDate DESC, CreatedDate DESC NULLS LAST';
        } else {
            query += ' ORDER BY LastModifiedDate DESC NULLS LAST, CreatedDate DESC NULLS LAST';
        }        
        
        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
        
        System.debug('Final query: ' + query);
        /* Here */
        List<IndividualApplication> records = Database.query(query, AccessLevel.USER_MODE);
        String countQuery = 'SELECT COUNT() FROM IndividualApplication WHERE RecordType.Name = \'State Extraditions\'';
        if (!conditions.isEmpty()) {
            countQuery += ' AND ' + String.join(conditions, ' AND ');
           }
        Integer recordCount = Database.countQuery(countQuery);
        System.debug('Records found: ' + recordCount);
        
        Map<String, Object> result = new Map<String, Object>();
        
        List<Map<String, Object>> formattedRecords = new List<Map<String, Object>>();
        
        for (IndividualApplication record : records) {
            Map<String, Object> formattedRecord = new Map<String, Object>();
            formattedRecord.put('Id', record.Id);
            formattedRecord.put('SAP_First_Name__c', record.SAP_First_Name__c);
            formattedRecord.put('SAP_Last_Name__c', record.SAP_Last_Name__c);
            formattedRecord.put('SAP_Middle_Name__c', record.SAP_Middle_Name__c);
            formattedRecord.put('SAP_Extradicted_From__c', record.SAP_Extradicted_From__c);
            formattedRecord.put('SAP_Extradicted_File_Number__c', record.SAP_Extradicted_File_Number__c);
            formattedRecord.put('SAP_Office__c', record.SAP_Office__c);
            formattedRecord.put('SAP_Cancellation_Date__c', record.SAP_Cancellation_Date__c);
    
            if (record.Received_for_filling_with_Governor_s_Act__c != null) {
                formattedRecord.put('Received_for_filling_with_Governor_s_Act__c', 
                    formatCustomDateTime(record.Received_for_filling_with_Governor_s_Act__c));
            } else {
                formattedRecord.put('Received_for_filling_with_Governor_s_Act__c', null);
            }
    
            formattedRecords.add(formattedRecord);
        }
        result.put('records', formattedRecords);
        result.put('count', recordCount);
        return result;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error fetching data: ' + e.getMessage());
        }
    }
    
    private static String formatCustomDateTime(DateTime dt) {
        if (dt == null){
            return null;
        } 
        Date dateOnly = dt.dateGmt();
        String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
        String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
        return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
    }

}