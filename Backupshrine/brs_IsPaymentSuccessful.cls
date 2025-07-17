/******************************************************************************************************
* NAME:  		brs_IsPaymentSuccessful
* DESCRIPTION:  This class hosts an Invocable method called from a flow & used for setting and 
*				checking conditions required for verifying if the user has passed the Payment screen 
*				with a successful payment record.
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		16th Feb, 2021
*******************************************************************************************************/
global with sharing class brs_IsPaymentSuccessful {

    /**********************************************************************************************
     METHOD NAME    : isPaymentSuccess (Invocable Method)
     DESCRIPTION    : Method executes when the flow refreshes after payment, to verify if payment 
                      has been made successfully and fetch related record Ids to process logic
                      post payment screen.
     PARAMETER      : List<Input> (Custom Wrapper)
    ***********************************************************************************************/

    @InvocableMethod
    public static List<Result> isPaymentSuccess(List<Input> lstInput){
        Result res = new Result();
        List<Result> lstResult = new List<Result>();

        // Fetch the work order record
        if(!lstInput.isEmpty() && !String.isBlank(lstInput[0].workOrderId)){
            Id workOrderId = lstInput[0].workOrderId;
            Schema.SObjectType objType = workOrderId.getSObjectType();
            
            if(objType == Schema.Work_Order__c.getSObjectType()){
                List<bt_stripe__Transaction__c> lstTxn = new List<bt_stripe__Transaction__c>();
                lstTxn = [SELECT Id, bt_stripe__Related_Contact__c, bt_stripe__Payment_Status__c, bt_stripe__Transaction_Status__c, 
                                bt_stripe__Error_Type__c, bt_stripe__Error_Message__c, bt_stripe__Error_Code__c, bt_stripe__Authorize_Only__c
                        FROM bt_stripe__Transaction__c 
                        WHERE Work_Order__c = :workOrderId
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC
                        LIMIT 1];

                if(!lstTxn.isEmpty()){
                    res.txnId = lstTxn[0].Id;
                    if(((lstTxn[0].bt_stripe__Authorize_Only__c == true && lstTxn[0].bt_stripe__Payment_Status__c == System.Label.brs_Authorized) || 
                        lstTxn[0].bt_stripe__Payment_Status__c == System.Label.Captured_Value) && 
                        lstTxn[0].bt_stripe__Transaction_Status__c == System.Label.BRS_Status_Value_Completed && 
                        String.isBlank(lstTxn[0].bt_stripe__Error_Type__c) && String.isBlank(lstTxn[0].bt_stripe__Error_Message__c) && 
                        String.isBlank(lstTxn[0].bt_stripe__Error_Code__c)) 
                    {
                        res.isPaymentSuccess = true;
						BRS_PaymentUtility.createDebitRecordsForOnlineFiling(workOrderId,lstInput[0].recordId);
                    }
                }
            }
        }

        // Fetch the UCC Filing record
        if(!lstInput.isEmpty() && !String.isBlank(lstInput[0].recordId) && lstInput[0].recordId != null){
            Id recordId = lstInput[0].recordId;
            Schema.SObjectType objType = recordId.getSObjectType();
            if(objType == Schema.UCC_Filing__c.getSObjectType()){
                List<UCC_Filing__c> lstFilings = [SELECT Id, UCC_Lien_Id__r.Id, Contact__r.Id
                                                  FROM UCC_Filing__c 
                                                  WHERE Id = :recordId
                                                  WITH SECURITY_ENFORCED];

                if(!lstFilings.isEmpty()) {
                    res.lienId = lstFilings[0].UCC_Lien_Id__r.Id;

                }
            }
        }
        lstResult.add(res);
        return lstResult;
    }

    global class Input {
        @InvocableVariable global Id recordId;
        @InvocableVariable global Id workOrderId;
    }

    global class Result {
        @InvocableVariable global Boolean isPaymentSuccess = false;
        @InvocableVariable global Id txnId;
        @InvocableVariable global Id lienId;
    }
}