public with sharing class ApostillePrintSubmissionDocController {
        @AuraEnabled(cacheable=true)
       public static Map<String, Object> getDocDetails(String recordId) {
        // Fetch DocumentChecklistItems
        List<DocumentChecklistItem> documentList = [
            SELECT Id, Name, DocumentType.MasterLabel, ParentRecordId, ParentRecord.Name,
                   Country__c, Requester_Name__c,SOTS_Certified_copy_number__c, Hague_Status__c, Fees__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :recordId 
        ];

        // Fetch the IndividualApplication data for the recordId
        IndividualApplication individualApp = [
            SELECT Id,Name, First_Name__c, Last_Name__c, Organization_Name__c ,Expedited__c,Sequence_Number__c
            FROM IndividualApplication
            WHERE Id = :recordId WITH SECURITY_ENFORCED
            LIMIT 1
        ];

         Map<String, Object> result = new Map<String, Object>();
         List<Map<String, Object>> documentDataList = new List<Map<String, Object>>();

         Decimal totalFees = 0;
         Decimal expedited = 0;
         Decimal finalTotal =0;

            // Populate the document data
        for (DocumentChecklistItem doc : documentList) {
            Map<String, Object> documentData = new Map<String, Object>();
            documentData.put('id', doc.Id);
             if (doc.DocumentType.MasterLabel == 'SOTS Certified Copies') {
        		documentData.put('name', doc.SOTS_Certified_copy_number__c);
    		} else {
        		documentData.put('name', doc.Name);
    		}
            //documentData.put('name', doc.Name);
            documentData.put('documentType', doc.DocumentType.MasterLabel);
            documentData.put('parentRecordName', doc.ParentRecord.Name);
            documentData.put('country', doc.Country__c);
            documentData.put('requesterName', doc.Requester_Name__c);
            documentData.put('hagueStatus', doc.Hague_Status__c);
            if(individualApp.Expedited__c){
                documentData.put('fees', doc.Fees__c-50);
            }else{
                documentData.put('fees', doc.Fees__c);
            }

            if(doc.Fees__c != null)
                totalFees += doc.Fees__c;
            documentDataList.add(documentData);
        }

        Map<String, Object> individualAppData = new Map<String, Object>();
        individualAppData.put('name', individualApp.Name);
        individualAppData.put('firstName', individualApp.First_Name__c);
        individualAppData.put('lastName', individualApp.Last_Name__c);
        individualAppData.put('orgnization', individualApp.Organization_Name__c);
        individualAppData.put('sequenceNumber', individualApp.Sequence_Number__c);
        if(individualApp.Expedited__c)
        {
            expedited = 50*(documentDataList.size());
            individualAppData.put('expedited',expedited);
            finalTotal =totalFees+expedited;
        }
        individualAppData.put('totalFees', totalFees);
        individualAppData.put('finalTotal',totalFees);


        // Prepare final result
        result.put('documents', documentDataList);   // List of document details
        result.put('individualApplication', individualAppData);  // Single individual application
        System.debug('result data is -- '+ result);
         return result;
      }

}