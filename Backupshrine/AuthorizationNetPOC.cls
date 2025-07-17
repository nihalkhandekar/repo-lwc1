public with sharing class AuthorizationNetPOC {
    
    private static final String APPLICATION_NAME = 'Authorize.Net POC';
    
    private static Authorize_net__c authorizationNetSettings;
    
    // Not Required
    public static String validateCreditCardNumber(String validationInput) {
        if (String.isBlank(validationInput)) {
            return 'Failure: No Input';
        }
        
        ValidateInputWrapper validateWrap = (ValidateInputWrapper) JSON.deserialize(validationInput, ValidateInputWrapper.class);
        
        return (validateWrap == null || String.isBlank(validateWrap.cardNumber)) 
            ? 'Failure: Invalid Input details.'
            : '';
    }
    
    private static Authorize_net__c fetchAuthorizationNetSettings() {
        if (authorizationNetSettings == null) {
            authorizationNetSettings = [
                SELECT Id, API_Login_Id__c, Transaction_Key__c, Application_Name__c 
                FROM Authorize_net__c 
                WHERE Application_Name__c = :APPLICATION_NAME 
                LIMIT 1
            ];
        }
        return authorizationNetSettings;
    }
    
    @AuraEnabled
    public static String paymentProcess(String paymentString) {
        
        if (String.isBlank(paymentString)) {
            return 'Failure: No Input';
        }
        
        PaymentInputWrapper paymentWrap = (PaymentInputWrapper) JSON.deserialize(paymentString, PaymentInputWrapper.class);
        
        if (paymentWrap == null) {
            return 'Failure: Invalid Input details.';
        }
        
        String chargeCreditCard = createTransactionReqBodyUsingParser(paymentWrap);
        
        System.debug('@@ Request Body ==>'+chargeCreditCard);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Authorization_net');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(chargeCreditCard);
        
        HttpResponse res = new Http().send(req);
        String responseBody = res.getBody();
        
        System.debug('@@ Response Body ==>'+responseBody);
        
        if (String.isNotBlank(responseBody)) {
            if (responseBody.contains('"description":"This transaction has been approved."') 
                    || responseBody.contains('"description":"Your order has been received. Thank you for your business!"')) {
                        
                        
                //AuthorizeNetResponse authorizeNetResponse = (AuthorizeNetResponse) JSON.deserialize(fixedString,AuthorizeNetResponse.class);
                // 'Please refer your transactionId is :'+authorizeNetResponse?.transactionResponse?.transId;
                return 'This transaction has been approved.'; 
                        
            } else {
                String error = responseBody.substringBetween('"errorText":"', '"');
                error = String.isNotBlank(error) ? error : 'This transaction request has failed.';
                throw newMessageException('Error encountered: ' + error);
            }
        } else {
            throw newMessageException('Error encountered. Status Code: ' + res.getStatus());
        } 
    }
    
    private static AuraHandledException newMessageException(String message) {
       	AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
    
   	// Not using for now only showing success message not transacationId (transId) 
    public class AuthorizeNetResponse{
        public cls_transactionResponse transactionResponse;
    }
    
    public class cls_transactionResponse {
		public String responseCode;	
		public String authCode;	
		public String avsResultCode;
		public String cvvResultCode;	
		public String cavvResultCode;	
		public String transId;
		public String refTransID;
		public String transHash;	
		public String testRequest;	
		public String accountNumber;	
		public String accountType;	
		public String transHashSha2;	
		public Integer SupplementalDataQualificationIndicator;	
		public String networkTransId;	
	}
    
    public class ValidateInputWrapper {
        @AuraEnabled public String cardNumber { get; set; }
    }
    
    public class PaymentInputWrapper {
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String cardNumber { get; set; }
        @AuraEnabled public String amount { get; set; }
        @AuraEnabled public String cardMonth { get; set; }
        @AuraEnabled public String cardYear { get; set; }
        @AuraEnabled public String cvv { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String zip { get; set; }
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String email { get; set; }
    }
    
    public static String createTransactionReqBodyUsingParser(PaymentInputWrapper paymentWrap){
        
        JSONGenerator payBody = JSON.createGenerator(true);
        
        payBody.writeStartObject();//1
        payBody.writeFieldName('createTransactionRequest');
         
        payBody.writeStartObject();//2
        payBody.writeFieldName('merchantAuthentication');
         
        payBody.writeStartObject();//3
        payBody.writeStringField('name', fetchAuthorizationNetSettings().API_Login_Id__c);
        payBody.writeStringField('transactionKey', fetchAuthorizationNetSettings().Transaction_Key__c);
        payBody.writeEndObject();
        
        Integer randomNumber = (Integer)(Math.random() * 100000000);
        payBody.writeStringField('refId', randomNumber < 10000000 ? String.valueOf(randomNumber + 10000000) : String.valueOf(randomNumber));
        payBody.writeFieldName('transactionRequest');
         
        payBody.writeStartObject();//4
        payBody.writeStringField('transactionType', 'authCaptureTransaction');
        payBody.writeStringField('amount', paymentWrap.amount);
        payBody.writeFieldName('payment');
         
        payBody.writeStartObject();//5
        payBody.writeFieldName('creditCard');
         
        payBody.writeStartObject();//6
        payBody.writeStringField('cardNumber', paymentWrap.cardNumber);
        payBody.writeStringField('expirationDate', paymentWrap.cardYear + '-' + paymentWrap.cardMonth);
        payBody.writeStringField('cardCode', paymentWrap.cvv);
        payBody.writeEndObject();
         
         
        payBody.writeEndObject();
         
        payBody.writeFieldName('customer');
        payBody.writeStartObject();
        if(String.isNotBlank(paymentWrap.email)){
            payBody.writeStringField('email', paymentWrap.email);    
        }
        payBody.writeEndObject();
         
        payBody.writeFieldName('billTo');
        payBody.writeStartObject();
         
        if(String.isNotBlank(paymentWrap.firstName)){
            payBody.writeStringField('firstName', paymentWrap.firstName);
        }
         
        if(String.isNotBlank(paymentWrap.lastName)){
            payBody.writeStringField('lastName', paymentWrap.lastName);
        }
        
        String fullName = paymentWrap.firstName + ' ' + paymentWrap.lastName;
        if(string.isNotBlank(fullName)){
            payBody.writeStringField('company', fullName);
        }
        if(string.isNotBlank(paymentWrap.street)){
            payBody.writeStringField('address', paymentWrap.street);
        }
        if(String.isNotBlank(paymentWrap.city)){
            payBody.writeStringField('city', paymentWrap.city);
        }
        if(String.isNotBlank(paymentWrap.state)){
            payBody.writeStringField('state', paymentWrap.state);
        }
        if(String.isNotBlank(paymentWrap.zip)){
            payBody.writeStringField('zip', paymentWrap.zip);
        }
        
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
        
        return payBody.getAsString();
    }

}