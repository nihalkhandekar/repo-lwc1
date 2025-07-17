public with sharing class SAP_ApostillePrntSubmDocController {
        @AuraEnabled(cacheable=true)
       public static Map<String, Object> getDocDetails(String recordId) {
        // Fetch DocumentChecklistItems
        List<DocumentChecklistItem> documentList = [
            SELECT Id, Name, DocumentType.MasterLabel, ParentRecordId, ParentRecord.Name,
                   SAP_Country__c, SAP_Requester_Name__c,SAP_SOTS_Certified_copy_number__c, SAP_Hague_Status__c, SAP_Fees__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :recordId 
        ];

        // Fetch the IndividualApplication data for the recordId
        IndividualApplication individualApp = [
            SELECT Id,Name, SAP_First_Name__c, SAP_Last_Name__c, SAP_Organization_Name__c ,SAP_Expedited__c,SAP_Sequence_Number__c
            FROM IndividualApplication
            WHERE Id = :recordId
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
        		documentData.put('name', doc.SAP_SOTS_Certified_copy_number__c);
    		} else {
        		documentData.put('name', doc.Name);
    		}
            //documentData.put('name', doc.Name);
            documentData.put('documentType', doc.DocumentType.MasterLabel);
            documentData.put('parentRecordName', doc.ParentRecord.Name);
            documentData.put('country', doc.SAP_Country__c);
            documentData.put('requesterName', doc.SAP_Requester_Name__c);
            documentData.put('hagueStatus', doc.SAP_Hague_Status__c);
            if(individualApp.SAP_Expedited__c){
                documentData.put('fees', doc.SAP_Fees__c-50);
            }else{
                documentData.put('fees', doc.SAP_Fees__c);
            }

            if(doc.SAP_Fees__c != null)
                totalFees += doc.SAP_Fees__c;
            documentDataList.add(documentData);
        }

        Map<String, Object> individualAppData = new Map<String, Object>();
        individualAppData.put('name', individualApp.Name);
        individualAppData.put('firstName', individualApp.SAP_First_Name__c);
        individualAppData.put('lastName', individualApp.SAP_Last_Name__c);
        individualAppData.put('orgnization', individualApp.SAP_Organization_Name__c);
        individualAppData.put('sequenceNumber', individualApp.SAP_Sequence_Number__c);
        if(individualApp.SAP_Expedited__c)
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