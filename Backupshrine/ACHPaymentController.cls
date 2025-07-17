public with sharing class ACHPaymentController {
    
    @auraEnabled
    public static String getPaymentDetails(String requestString){
        String returnString;
        String AmountValue;
        try{
            ACHPaymentRequest.paymentParams reqStrObj = (ACHPaymentRequest.paymentParams)JSON.deserialize(requestString, ACHPaymentRequest.paymentParams.class);   
            Customer_Balance_Transaction__c cbTrans = new Customer_Balance_Transaction__c();
            cbTrans.Account_Owner__c = reqStrObj.selectedAccOwnerType!='Personal'?'Commercial':reqStrObj.selectedAccOwnerType;
            cbTrans.First_Name__c = reqStrObj.firstName;
            cbTrans.Last_Name__c = reqStrObj.lastName;
            cbTrans.Account_Type__c = reqStrObj.selectedAccType;
            cbTrans.Amount__c = Integer.ValueOf(reqStrObj.amount);
            Schema.SObjectType sobjectType = reqStrObj.filingId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();            
            cbTrans.Business_Filing__c = sobjectName!=null && sobjectName == 'Business_Filing__c' ? reqStrObj.filingId:null;
            cbTrans.Certificate__c = sobjectName!=null && sobjectName == 'Certficate__c' ? reqStrObj.filingId:null;
            cbTrans.UCC_Filing__c = sobjectName!=null && sobjectName == 'UCC_Filing__c' ? reqStrObj.filingId:null;
            cbTrans.Work_Order__c= reqStrObj.workOrderId;
            cbTrans.Email__c = reqStrObj.email;
            cbTrans.Payment_Source__c ='ACH Payment';
            cbTrans.company__c=reqStrObj.companyName;
            cbTrans.Contact__c =reqStrObj.customerId;
            cbTrans.Transaction_Date_Time__c = System.now();
            cbTrans.Type__c = 'Debit';
            cbTrans.Start_Date__c = System.Today();
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTrans}, 'insert');
                if(bAccessCheck){
                	insert cbTrans;
            }

            Customer_Balance_Transaction__c cbTransCredit = new Customer_Balance_Transaction__c();
            cbTransCredit.Account_Owner__c = reqStrObj.selectedAccOwnerType!='Personal'?'Commercial':reqStrObj.selectedAccOwnerType;
            cbTransCredit.First_Name__c = reqStrObj.firstName;
            cbTransCredit.Last_Name__c = reqStrObj.lastName;
            cbTransCredit.Account_Type__c = reqStrObj.selectedAccType;
            cbTransCredit.Amount__c = Integer.ValueOf(reqStrObj.amount);
            Schema.SObjectType sobjectType1 = reqStrObj.filingId.getSObjectType();
            String sobjectName1 = sobjectType1.getDescribe().getName();            
            cbTransCredit.Business_Filing__c = sobjectName1!=null && sobjectName1 == 'Business_Filing__c' ? reqStrObj.filingId:null;
            cbTransCredit.Certificate__c = sobjectName1!=null && sobjectName1 == 'Certficate__c' ? reqStrObj.filingId:null;
            cbTransCredit.UCC_Filing__c = sobjectName1!=null && sobjectName1 == 'UCC_Filing__c' ? reqStrObj.filingId:null;
            cbTransCredit.Work_Order__c= reqStrObj.workOrderId;
            cbTransCredit.Email__c = reqStrObj.email;
            cbTransCredit.Payment_Source__c ='ACH Payment';
            cbTransCredit.company__c=reqStrObj.companyName;
            cbTransCredit.Contact__c =reqStrObj.customerId;
            cbTransCredit.Transaction_Date_Time__c = System.now();
            cbTransCredit.Type__c = 'Credit';
            cbTransCredit.Start_Date__c = System.Today();
            Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTransCredit}, 'insert');
            if(bAccessCheck1){
                	insert cbTransCredit;
            }
            
            ACHPaymentRequest.ACHPaymentReq reqObj = new ACHPaymentRequest.ACHPaymentReq();
            if(reqStrObj.amount !=null)
            {
                AmountValue=reqStrObj.amount + '.00';
            }
            
            if(reqStrObj.selectedAccOwnerType=='Personal'){
                
                reqObj.firstName = reqStrObj.firstName;
                reqObj.lastName = reqStrObj.lastName;
                reqObj.address  = reqStrObj.internationalAddress!=null && reqStrObj.internationalAddress!=''? reqStrObj.internationalAddress : reqStrObj.street + ' '+ reqStrObj.unit;
                reqObj.city = reqStrObj.city;
                reqObj.state =reqStrObj.state;
                reqObj.zip = reqStrObj.zip.replace('-','');
                reqObj.accountNum = reqStrObj.accNo;
                reqObj.company = reqStrObj.companyName;
                reqObj.accountType = reqStrObj.selectedAccType;
                reqObj.routingNumber = reqStrObj.routingNo;
                reqObj.amount = AmountValue;
                reqObj.accountOwnerType = 'P';
                reqObj.email = reqStrObj.email;
                reqObj.transactionId = cbTrans.Id;
                
            }
            if(reqStrObj.selectedAccOwnerType=='Business'){
                
                reqObj.firstName = reqStrObj.firstName;
                reqObj.lastName = reqStrObj.lastName;
                reqObj.address  = reqStrObj.internationalAddress!=null && reqStrObj.internationalAddress!=''? reqStrObj.internationalAddress : reqStrObj.street + ' '+ reqStrObj.unit;
                reqObj.city = reqStrObj.city;
                reqObj.state =reqStrObj.state;
                reqObj.zip = reqStrObj.zip.replace('-','');
                reqObj.accountNum = reqStrObj.accNo;
                reqObj.company = reqStrObj.companyName;
                reqObj.accountType = reqStrObj.selectedAccType;
                reqObj.routingNumber = reqStrObj.routingNo;
                reqObj.amount = AmountValue;
                reqObj.accountOwnerType = 'C';
                reqObj.email = reqStrObj.email;
                reqObj.transactionId = cbTrans.Id; 
                
            }
            returnString = JSON.serialize(reqObj);
            return returnString;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler('ACHPaymentController', 'getPaymentDetails',null,null,null,ex,ex.getMessage()); 
            return returnString;
        }       
        
    }
    
    @auraEnabled
    public static String achPaymentCallout(string requestString){
        List<Error_log__c> errorLogList=new List<Error_log__c>();
        String responseStr ;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACH_Payments');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(requestString);
        ACHPaymentRequest.ACHPaymentReq requestData=(ACHPaymentRequest.ACHPaymentReq)JSON.deserializeStrict(requestString, ACHPaymentRequest.ACHPaymentReq.class);
        Error_Log__c loginformation=new Error_Log__c(Class_Name__c ='ACHPaymentController',Class_Method__c='achPaymentCallout',Stack_Trace__c='ACH Request Transaction Id :'+requestData.transactionId);
        errorLogList.add(loginformation);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        ACHPaymentRequest.ACHPaymentResponse response = (ACHPaymentRequest.ACHPaymentResponse)JSON.deserializeStrict(res.getBody(), ACHPaymentRequest.ACHPaymentResponse.class);
        ACHPaymentRequest.ACHPaymentResponse faliureResponse = new ACHPaymentRequest.ACHPaymentResponse();
        if(res.getStatusCode()==200){
            if(response.responseMessage.contains('Transaction approved')){
                Error_Log__c loginformationApproved=new Error_Log__c(Class_Name__c ='ACHPaymentController',Class_Method__c='achPaymentCallout',Error_Message__c=response.responseMessage,Record_Id__c=response.transactionId,Stack_Trace__c=string.ValueOf(response));
                 errorLogList.add(loginformationApproved);
                Customer_Balance_Transaction__c cbTrans = new Customer_Balance_Transaction__c(id=response.transactionId,BOA_Transaction_Number__c=response.BOAtransactionNumber,status__c='Complete' );
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTrans}, 'update');
                if(bAccessCheck){
                    update cbTrans;
                }
            }
            else{
                Error_Log__c loginformationFailed=new Error_Log__c(Class_Name__c ='ACHPaymentController',Class_Method__c='achPaymentCallout',Error_Message__c=response.responseMessage,Record_Id__c=response.transactionId,Stack_Trace__c=string.ValueOf(response));
                errorLogList.add(loginformationFailed);
                Customer_Balance_Transaction__c cbTrans = new Customer_Balance_Transaction__c(id=response.transactionId,BOA_Transaction_Number__c=response.BOAtransactionNumber,status__c='Failed',ACH_Error_Message__c=response.errorMessage );
                Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTrans}, 'update');
                if(bAccessCheck1){
                    update cbTrans;
                }
            }  
        }        
        else{
            if(response!=null){
                ACHPaymentRequest.ACHPaymentReq requestObj  = (ACHPaymentRequest.ACHPaymentReq)JSON.deserialize(requestString, ACHPaymentRequest.ACHPaymentReq.class);
                Error_Log__c loginformationFailed1=new Error_Log__c(Class_Name__c ='ACHPaymentController',Class_Method__c='achPaymentCallout',Error_Message__c=response.responseMessage,Record_Id__c=requestObj.transactionId,Stack_Trace__c=string.ValueOf(response));
                errorLogList.add(loginformationFailed1);
                Customer_Balance_Transaction__c cbTrans = new Customer_Balance_Transaction__c(id=requestObj.transactionId,BOA_Transaction_Number__c=response.BOAtransactionNumber,status__c='Failed',ACH_Error_Message__c=response.errorMessage );
                Boolean bAccessCheck2 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTrans}, 'update');
                if(bAccessCheck2){
                    update cbTrans;
                }
                
            }
            else{
                ACHPaymentRequest.ACHPaymentReq requestObj  = (ACHPaymentRequest.ACHPaymentReq)JSON.deserialize(requestString, ACHPaymentRequest.ACHPaymentReq.class);
                Customer_Balance_Transaction__c cbTrans = new Customer_Balance_Transaction__c(id=requestObj.transactionId,status__c='Failed',ACH_Error_Message__c=res.getStatusCode()+' - '+ res.getStatus() );
                Boolean bAccessCheck3 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{cbTrans}, 'update');
                if(bAccessCheck3){
                    update cbTrans;
                }
                faliureResponse.errorMessage = res.getStatus();
            }
            
        }
        Insert errorLogList;
        if(response.errorMessage.contains('Invalid Routing Transit Number')){
            response.errorMessage = System.Label.Invalid_Routing_Number;
        }
        if(response.errorMessage.contains('General platform system error')){
            response.errorMessage = System.Label.General_Platform_Error;
        }
        if(response.errorMessage.contains('Sign on authentication error')){
            response.errorMessage = System.Label.Sign_On_Error;
        }
        if(response.errorMessage.contains('Transaction already voided')){
            response.errorMessage = System.Label.Transaction_already_voided;
        }
        if(response.errorMessage.contains('Invalid transaction type')){
            response.errorMessage = System.Label.Invalid_transaction_type;
        }
        if(response.errorMessage.contains('Invalid Message Version #')){
            response.errorMessage = System.Label.Invalid_Message;
        }
        if(response.errorMessage.contains('Bank Account type not valid')){
            response.errorMessage = System.Label.Bank_Account_type_not_valid;
        }
        if(response.errorMessage.contains('Processor reported error')){
            response.errorMessage = System.Label.Processor_reported_error;
        }
        if(response.errorMessage.contains('Remittance ID does not match')){
            response.errorMessage = System.Label.Remittance_ID_does_not_match;
        }
        if(response.errorMessage.contains('Duplicate Transaction')){
            response.errorMessage = System.Label.Duplicate_Transaction;
        }
        if(response.errorMessage.contains('Payment Application Disabled')){
            response.errorMessage = System.Label.Payment_Application_Disabled;
        }
        
        return JSON.serialize(response!=null?response:faliureResponse);
    }
    
}