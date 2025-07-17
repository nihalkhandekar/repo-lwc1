public with sharing class appostileWorkOrderController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDocumentChecklistItem (
        Date transactionFromDate, 
        Date transactionToDate,
        String selectStatus,
        String signedby,
        String requestorName,
        DateTime appliedDate,
        String certificateNumber,
        String country,
        String position,
        String applicationid) {

        String query = 'SELECT Id, Signed_By_picklist__c, Requester_Name__c, Certificate_Number__c, country__c, Status,ParentRecordId, CreatedDate, ParentRecord.Name ' +
        'FROM DocumentChecklistItem WHERE ParentRecordId != null';

        if (signedby != null) {
            query += ' AND Signed_By_picklist__c = :signedby';
        }
        if (requestorName != null) {
            query += ' AND Requester_Name__c = :requestorName';
        }
        if (certificateNumber != null) {
            query += ' AND Certificate_Number__c = :certificateNumber';
        }
        if (country != null) {
            query += ' AND country__c = :country';
        }
        if (selectStatus != null) {
            query += ' AND Status = :selectStatus';
        }
/*
        if (position != null) {
            query += ' AND Public_Officials__r.position__c = :position';
        }
*/
        if (applicationid != null) {
            query += ' AND ParentRecord.Name = :applicationid';
        }
        if (transactionFromDate != null && transactionToDate != null) {
            query += ' AND CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate';
        }
        if (appliedDate != null) {
            query +=  ' AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE AppliedDate = :appliedDate)';
        }
        
        // Execute the query
        List<DocumentChecklistItem> records = Database.query(query);
        List<Id> individualApplicationIds = new List<Id>();
        
        for (DocumentChecklistItem docItem : records) {
            individualApplicationIds.add(docItem.ParentRecordId);
        }

        Map<Id, IndividualApplication> indivAppMap = new Map<Id, IndividualApplication>(
            [SELECT Id,Application_ID__c, Expedited__c,Status, AppliedDate FROM IndividualApplication WHERE Id IN :individualApplicationIds]
        );

        List<DocumentCheckListWithApplication> wrappers = new List<DocumentCheckListWithApplication>();
        
        for (DocumentChecklistItem docItem : records) {
            IndividualApplication indivApp = indivAppMap.get(docItem.ParentRecordId);
            DocumentCheckListWithApplication wrapper = new DocumentCheckListWithApplication(docItem, indivApp);
            wrappers.add(wrapper);
        }

        System.debug('records-->'+records);
        Integer recordCount = records.size();

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', wrappers);
        result.put('count', recordCount);

        return result;
    }
}