/******************************************************************************************************
* NAME:  		brs_paymentSubFlow
* DESCRIPTION:  This class hosts an Invocable method called from a flow & used for setting and 
*				checking conditions required for making a payment using Blackthorn.io
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		2nd Feb, 2021
*******************************************************************************************************/
global without sharing class brs_paymentSubFlow {   
    public static final String EMPTY_STRING = '';
    /**********************************************************************************************
     METHOD NAME    : paymentSubFlowServerCall (Invocable Method)
     DESCRIPTION    : Method executes as part of the Payment subflow, which fetches fee amount, 
                      and the main flow object name.
     PARAMETER      : List<Request> (Custom Wrapper)
    ***********************************************************************************************/

    @InvocableMethod
    public static List<Result> paymentSubFlowServerCall(List<Request> input){             
        Result res = new Result();
        String recordId;
        List<Result> lstResults = new List<Result>();

        User userDetails = [SELECT Id, Name, Email, isGovernmentUser__c 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()
                            WITH SECURITY_ENFORCED];
        
        // BRS-2472 To determine if current user is Government Community User
        if(!userDetails.isGovernmentUser__c){
            res.isGov = false;
        }
        else {
            res.isGov = true;
        }	
        
        // Update the SObject with the Amount to be charged
        if(!input.isEmpty() && !String.isBlank(input[0].parentRecordId) && input[0].parentRecordId != null){
            Id parentRecId = input[0].parentRecordId;
            Decimal fee = 0;
            Schema.SObjectType objType = parentRecId.getSObjectType();
            
            // If SObject is UCC_Filing__c, update the amount on it
            if(objType == Schema.UCC_Filing__c.getSObjectType()){
                res.objectName = String.valueOf(objType);
                recordId = input[0].parentRecordId;
                UCC_Filing__c uccFilingRec = new UCC_Filing__c();
                if(!String.isBlank(recordId)){
                    uccFilingRec = [SELECT Id, Type__c,Parent_Lien_Type__c, UCC_Lien_Id__r.Type__c, Amount__c,Amendment_Type__c 
                                    FROM UCC_Filing__c
                                    WHERE Id = :recordId 
                                    WITH SECURITY_ENFORCED];
                }
                string filingType = uccFilingRec.Amendment_Type__c!=null? uccFilingRec.Amendment_Type__c : uccFilingRec.Type__c;
                string lienType = (uccFilingRec.Amendment_Type__c == system.label.Termination_value && uccFilingRec.Parent_Lien_Type__c != system.label.LaborLabel && uccFilingRec.Parent_Lien_Type__c != system.label.State_Label_Comparable && uccFilingRec.Parent_Lien_Type__c != system.label.revenueServicesLabel && uccFilingRec.Parent_Lien_Type__c != system.label.MunicipalLabel) ? null : uccFilingRec.Parent_Lien_Type__c;
                fee = fetchFeeAmount(EMPTY_STRING, filingType,lienType, EMPTY_STRING, EMPTY_STRING, res.isGov);
            }
             // If SObject is Business_Filing__c, update the amount on it
            else if(objType == Schema.Business_Filing__c.getSObjectType()){
                res.objectName = String.valueOf(objType);
                recordId = input[0].parentRecordId;
                Business_Filing__c businessFilingRec = new Business_Filing__c();
                if(!String.isBlank(recordId)){
                    businessFilingRec = [SELECT Id, Type__c, Citizenship__c, Business_Type__c, Filing_Type__c,  Due_Year__c, Due_Date__c
                                         FROM Business_Filing__c
                                         WHERE Id = :recordId
                                         WITH SECURITY_ENFORCED];
                }
                if(businessFilingRec.Business_Type__c==System.Label.Business_Type_LLC && businessFilingRec.Filing_Type__c==System.Label.Annual_Report_Label && businessFilingRec.Due_Year__c<=System.Label.Annual_Report_Year){
                    fee = Decimal.valueOf(System.Label.Filing_Fee_for_Annual_Prior_to_2020);
                }else{
                    fee = fetchFeeAmount(businessFilingRec.Type__c, businessFilingRec.Filing_Type__c, EMPTY_STRING, businessFilingRec.Citizenship__c, businessFilingRec.Business_Type__c, false);
                }
            }
             // If SObject is Temp_History__c, update the amount on it
            else if(objType == Schema.Temp_History__c.getSObjectType()){
                res.objectName = String.valueOf(objType);
                recordId = input[0].parentRecordId;
                Temp_History__c tempHistRec = new Temp_History__c();
                if(!String.isBlank(recordId)){
                    tempHistRec = [SELECT Id, Certificate_Types__c, Account__c, Account__r.Business_Type__c 
                                   FROM Temp_History__c
                                   WHERE Id = :recordId
                                   WITH SECURITY_ENFORCED];
                }
                for(String certificateType : tempHistRec.Certificate_Types__c.split(';')){
                    fee = fee + fetchFeeAmount(EMPTY_STRING, certificateType, EMPTY_STRING, EMPTY_STRING, tempHistRec.Account__r.Business_Type__c, res.isGov);
                }
            }
            else if(objType == Schema.Certficate__c.getSObjectType()){
                res.objectName = String.valueOf(objType);
                recordId = input[0].parentRecordId;
                Certficate__c otherReqRec = new Certficate__c();
                if(!String.isBlank(recordId)){
                    otherReqRec = [SELECT Id, Filing_Fee__c
                                   FROM Certficate__c
                                   WHERE Id = :recordId
                                   WITH SECURITY_ENFORCED];
                }
                fee = otherReqRec.Filing_Fee__c!=null?otherReqRec.Filing_Fee__c:0;
                
            }
            res.fee = fee;
        }
        lstResults.add(res);
        return lstResults;
    }
    
    public static Decimal fetchFeeAmount(String type, String filingType, String lienType, String citizenship, String businessType, Boolean isGov){
        Decimal fee = 0.0;
        Date processingDate = System.today();
        List<Master_Fee__c> lstFees = new List<Master_Fee__c>();
        
        if(!isGov){
            lstFees = [SELECT Id, Amount__c 
                       FROM Master_Fee__c 
                       WHERE Type__c = :type AND 
                       Filing_Type__c = :filingType AND 
                       Lien_Type__c = :lienType AND
                       Citizenship__c = :citizenship AND
                       Business_Type__c = :businessType AND
                       Status__c = 'Active' AND
                       Start_Date__c <= :processingDate AND
                       (End_Date__c = null OR
                        End_Date__c >= :processingDate)
                       WITH SECURITY_ENFORCED
                       LIMIT 1];
            
            if(!lstFees.isEmpty()){
                fee = lstFees[0].Amount__c;
            }            
        }
        return fee;
    }
    
    global without sharing class Request {
        @InvocableVariable global String parentRecordId;
    }
    
    global without sharing class Result {
        @InvocableVariable global Decimal fee;
        @InvocableVariable global Boolean isGov;
        @InvocableVariable global String objectName;
        @InvocableVariable global Boolean bypassPayment;
    }
}