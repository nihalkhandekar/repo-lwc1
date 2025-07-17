public without sharing class ApostileTransactionController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getTransaction() {
 
        List<RegulatoryTrxnFee> regTrnxFee = [
            SELECT Id, Transaction_Date__c,Auth_Code__c, Name, Status, TotalFeeAmount, ParentRecordId
            FROM RegulatoryTrxnFee ];

            Schema.SObjectType individualApplicationType = Schema.getGlobalDescribe().get('IndividualApplication');

            List<RegulatoryTrxnFee> filterTrnxnFee = new List<RegulatoryTrxnFee>();
            List<Id> individualApplicationIds = new List<Id>();

            for (RegulatoryTrxnFee trnxn : regTrnxFee) {
                // Check if ParentRecordId is not null
                if (trnxn.ParentRecordId != null) {
                    // Compare the SObjectType of ParentRecordId with IndividualApplication
                    if (trnxn.ParentRecordId.getSObjectType() == individualApplicationType) {
                        // Add matching records to the filterTrnxnFee list
                        filterTrnxnFee.add(trnxn);
                        individualApplicationIds.add(trnxn.ParentRecordId);
                    }
                }
            }
            
        Map<Id, IndividualApplication> indivAppMap = new Map<Id, IndividualApplication>(
            [SELECT Id,Name, First_Name__c,Last_Name__c, Organization_Name__c FROM IndividualApplication WHERE Id IN :individualApplicationIds]
        );

        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (RegulatoryTrxnFee trnxFee : filterTrnxnFee) {
            IndividualApplication indivApp = indivAppMap.get(trnxFee.ParentRecordId);
            
            Map<String, Object> dataMap = new Map<String, Object>();
            dataMap.put('TransactionDate', trnxFee.Transaction_Date__c);
            String firstName = indivApp.First_Name__c != null ? indivApp.First_Name__c : '';
            String lastName =  indivApp.Last_Name__c !=null ? indivApp.Last_Name__c :'';
            dataMap.put('Name', indivApp.Organization_Name__c != null ? indivApp.Organization_Name__c : firstName+' '+lastName);
            dataMap.put('PaymentType', 'CC');
            dataMap.put('PaymentAmount', trnxFee.TotalFeeAmount);
            dataMap.put('AuthCode', trnxFee.Auth_Code__c);
            dataMap.put('WorkorderNumber', indivApp.Name != null ? indivApp.Name : null);
            dataMap.put('Status', trnxFee.Status );

            results.add(dataMap);
        }
        
        return results;
    }
}