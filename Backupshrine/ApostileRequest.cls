public class ApostileRequest {
        @AuraEnabled(cacheable=true)
        public static Map<String, Object> getApostileRequests (
            Date transactionFromDate, 
            Date transactionToDate,
            String applicationid,
            String Name,
            String organisationName,
            Date appliedDate,
            String emailAddress,
            String selectStatus,
            String statusSelect,
            Boolean expediteDate
            ) {
    
            String query = 'SELECT Id, Name, Status, CreatedDate, ParentRecordId, ParentRecord.Name, Public_Officials__r.position__c, Account.Organization_Name__c, Account.Email_Address__c ' +
            'FROM DocumentChecklistItem WHERE ParentRecordId != null';

            if (Name != null) {
                query += ' AND Name = :Name';
            }

            if (selectStatus != null) {
                query += ' AND Status = :selectStatus';
            }

            if (statusSelect != null) {
                query += ' AND Status = :statusSelect';
            }

            if (applicationid != null) {
                query += ' AND ParentRecord.Name = :applicationid';
            }

            if (organisationName != null) {
                query += ' AND Account.Organization_Name__c = :organisationName';
            }

            if (emailAddress != null) {
                query += ' AND Account.Email_Address__c = :emailAddress';
            }

            if (appliedDate != null) {
                query +=  ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE AppliedDate = :appliedDate)';
            }

            // if (expediteDate != null) {
            //     query += ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE Expedite_Fee__c = :expediteDate';
            // }

            if (transactionFromDate != null && transactionToDate != null) {
                query += ' AND CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate';
            }
            
            // Execute the query
            List<DocumentChecklistItem> records = Database.query(query);
            List<Id> individualApplicationIds = new List<Id>();
            
            for (DocumentChecklistItem docItem : records) {
                individualApplicationIds.add(docItem.ParentRecordId);
            }
    
            Map<Id, IndividualApplication> indivAppMap = new Map<Id, IndividualApplication>(
                [SELECT Id,Application_ID__c, Expedite_Fee__c, AppliedDate FROM IndividualApplication WHERE Id IN :individualApplicationIds]
            );
    
            List<DocumentCheckListWithApplication> wrappers = new List<DocumentCheckListWithApplication>();
            
            for (DocumentChecklistItem docItem : records) {
                IndividualApplication indivApp = indivAppMap.get(docItem.ParentRecordId);
                DocumentCheckListWithApplication wrapper = new DocumentCheckListWithApplication(docItem, indivApp);
                wrappers.add(wrapper);
            }
    
            System.debug('---records-->'+records);
            Integer recordCount = records.size();
    
            Map<String, Object> result = new Map<String, Object>();
            result.put('records', wrappers);
            result.put('count', recordCount);
    
            return result;
        }
    }