global class brs_BackOfficeCardTransactionCheck {
    
    global without sharing class Requests {
        @InvocableVariable
        global string workOrderId;
    }
    global without sharing class Results {
        @InvocableVariable
        global string message;      
    }
    @InvocableMethod
    public static List<Results> getPaymentVerificationStatusFlow(List<Requests> Requests) {
        List<String> ids = new List<String>();
        String message = '';
        try{            
            String recordId = Requests[0].workOrderId;
            
            if(String.isNotBlank(recordId))
            {
              //  List<Business_Filing__c> approvedFilings=[Select Id, Status__c,work_Order__c from Business_Filing__c where work_Order__c=:recordId AND Status__c='Approved'];
              //  if(!approvedFilings.isEmpty()){
                    List<Payment_Method__c> cardPayments=[Select Id,Payment_Source__c, Amount__c,Work_Order__c  FROM Payment_Method__c WHERE Payment_Source__c = 'Card' AND Work_Order__c =:recordId];
                    if(!cardPayments.isEmpty()){
                        List<bt_stripe__Transaction__c> transactions=[SELECT Id, bt_stripe__Amount__c,Work_Order__c FROM bt_stripe__Transaction__c WHERE bt_stripe__Transaction_Status__c = 'Completed' AND bt_stripe__Payment_Status__c = 'Captured' AND Work_Order__c =:recordId];
                        if(transactions.isEmpty()){
                            message=System.label.CardTransactionError; 
                        }                        
                    }
              //  }
            }        
            List<Results> lstResults = new List<Results>();
            Results r = new Results();
            r.message =message;            
            lstResults.add(r);            
            return lstResults;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler('brs_BackOfficeCardTransactionCheck', 'getPaymentVerificationStatusFlow', null, null, 'High', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}