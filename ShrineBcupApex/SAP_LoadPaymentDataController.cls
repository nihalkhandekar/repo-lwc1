public with sharing class SAP_LoadPaymentDataController {
    @AuraEnabled
    public static Map<String, Object> loadPaymentData(Id recordId) {
        list<IndividualApplication> records = [
            SELECT Id, Name,SAP_Sequence_Number__c
            FROM IndividualApplication WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1
        ];
        // Query for the related DocumentChecklistItem records
        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, SAP_Fees__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :recordId
        ];

        // Calculate the sum of Fees__c values from the checklist items
        Decimal totalFees = 0;
        for (DocumentChecklistItem item : checklistItems) {
            if (item.SAP_Fees__c != null) {
                totalFees += item.SAP_Fees__c;
            }
        }
        system.debug('------Apex coming record ID-->' + recordId);
        Map<String, Object> result = new Map<String,Object>();
        system.debug('------Apex going data--->' + result);
        result.put('records', records);
        result.put('totalFees', totalFees);
        system.debug('------Apex going data--->' + result);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> loadPreviousPayment(Id recordId) {
    // Fetch records from RegulatoryTrxnFee based on the given recordId
    List<RegulatoryTrxnFee> records = [
        SELECT Id, Name, SAP_Payment_Type__c, TotalFeeAmount,SAP_Card_Number__c, CreatedDate, SAP_Auth_Code__c, SAP_CK_Number__c,
        SAP_Money_Order_Number__c, SAP_Brand__c, SAP_Card_Type__c, CreatedBy.Profile.Name
        FROM RegulatoryTrxnFee WHERE ParentRecordId = :recordId WITH SECURITY_ENFORCED
    ];

    // Log the retrieved records
    System.debug('Retrieved RegulatoryTrxnFee records: ' + records);

    // Calculate the total amount from the records
    Decimal totalAmount = 0;
    for (RegulatoryTrxnFee record : records) {
        totalAmount += record.TotalFeeAmount;
        // Log each record's TotalFeeAmount as it's being added
        System.debug('Adding TotalFeeAmount from record: ' + record.Id + ', Amount: ' + record.TotalFeeAmount);
    }

    // Log the calculated total amount
    System.debug('Calculated totalAmount: ' + totalAmount);

    // Prepare result map to return
    Map<String, Object> result = new Map<String, Object>();
    result.put('records', records);
    result.put('totalAmount', totalAmount);

    // Log the final result map
    System.debug('Final result map: ' + result);

    return result;
}




    @AuraEnabled
    //public static boolean createNewRegulatoryTrxnFee(Id recordId,String PaymentType,String CardType,String Last_Four_digits_of_CreditCard,String Payment_Amount,string checkNumber)
    public static boolean createNewRegulatoryTrxnFee(map<String,Object> addPaymentvalues) {

        RegulatoryTrxnFee newFee=new RegulatoryTrxnFee();
        id RegulatoryTrxnFee_id=newFee.id;
        RegulatoryTrxnFeeItem newFeeItem = new RegulatoryTrxnFeeItem();
        boolean result = false;

        integer lengthOfMap = addPaymentvalues.size();

        system.debug('addPaymentvalues'+addPaymentvalues);

        //for(map<String,Object> IndividualpaymentValue:addPaymentvalues){

        //}






        /*newFeeItem.SAP_Payment_Amount__c=Decimal.valueOf(Payment_Amount);

        boolean result=false;

        if(PaymentType=='Check'){
           newFeeItem.SAP_Payment_Type__c='CK';
           newFeeItem.SAP_CK_Number__c=checkNumber;
            result=true;
        }
        else if(PaymentType=='Credit Card'){
           newFeeItem.SAP_Payment_Type__c='CC';
           //newFeeItem.SAP_Credit_Card_Type__c=CardType;
           newFeeItem.SAP_Credit_Card_Number__c=Integer.valueOf(Last_Four_digits_of_CreditCard);
            result=true;
        }*/


        return result;
    }

}