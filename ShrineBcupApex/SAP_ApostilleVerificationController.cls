public without sharing class SAP_ApostilleVerificationController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getApplications(String certificateNumber) {
        // Query SAP_Document_Checklist__c based on certificate number
        List<DocumentChecklistItem> documents = [
            SELECT Id,
                   SAP_Certificate_Number__c,
                   ParentRecordId,
                   SAP_country__c,
                   Status,
                   Signed_By__r.Name,
                   Signed_By__r.SAP_position__c,
                   SAP_ApprovedDate__c,  Signing_Authority__r.Name
            FROM DocumentChecklistItem
            WHERE SAP_Certificate_Number__c = :certificateNumber WITH SECURITY_ENFORCED
        ];
        // Initialize result list
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // Iterate through each document
        for (DocumentChecklistItem doc : documents) {

            // Prepare the record map to return to the LWC
            Map<String, Object> record = new Map<String, Object>();
            record.put('certificateNumber', doc.SAP_Certificate_Number__c);
            record.put('signedBy', doc.Signed_By__r != null ? doc.Signed_By__r.Name : null);
            record.put('officialCapacity', doc.Signed_By__r != null ? doc.Signed_By__r.SAP_Position__c : null);
            record.put('status', doc.Status != null ? doc.Status : null);
            record.put('approvedDate', doc.SAP_ApprovedDate__c != null ? formatCustomDateTime(doc.SAP_ApprovedDate__c) : null);
            record.put('countryToBeUsed', doc.SAP_country__c);
            record.put('signingAutority', doc.Signing_Authority__r.Name != null ? doc.Signing_Authority__r.Name : null);

            // Add the record to the result list
            result.add(record);
        }

        return result;
    }

      private static String formatCustomDateTime(DateTime dt) {
        if (dt == null) return null;
        Date dateOnly = dt.dateGmt();
        return dateOnly.month() + '/' + dateOnly.day() + '/' + dateOnly.year();
    }
}