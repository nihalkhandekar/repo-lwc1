/**
* @File Name : Apostille_AuthorizationNetController.cls
* @Description : Authorization.net Payment Controller
* @Author : Jay Patel
* @Last Modified By : Jay Patel
* @Last Modified On : December 2, 2024
* @Modification Log : Created
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 2, 2024 | Jay Patel | Initial Version
**/

public Without sharing class Apostille_AuthorizationNetController {

    
    private static Set<Integer> FAILURE_STATUS_CODES = new Set<Integer>{ 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 421, 422, 423, 424, 425, 426, 428, 429, 431, 451, 500, 501, 502, 503, 504, 505, 506, 507, 508, 510, 511 };

	@AuraEnabled
	public static String generatePaymentToken(String paymentGatewayData){

		try{
			if(String.isBlank(paymentGatewayData)){
				return 'Error: No data found to initiate Payement Gateway.';
			}

			PaymentGatewayWrapper paymentWrap = (PaymentGatewayWrapper) JSON.deserialize(paymentGatewayData, PaymentGatewayWrapper.class);

			if(paymentWrap == null){
				return 'Error: Data Conversation Failure.';
			}

			String requestBody = generateAuthTokenForPayment(paymentWrap);
            System.debug('Raw Response Body: ' + requestBody);
            
			HttpRequest httpReq = new HttpRequest();
			httpReq.setEndpoint('callout:AuthorizationNet_Payment_Gateway');
			httpReq.setMethod('POST');
			httpReq.setHeader('Content-Type', 'application/json; charset=utf-8');
			httpReq.setBody(requestBody);
			httpReq.setTimeout(120000);
			HttpResponse httpRes = new Http().send(httpReq);
            
            System.debug('HTTP Status Code: ' + httpRes.getStatusCode());
	        System.debug('Raw Response Body: ' + httpRes.getBody());
            


			if(FAILURE_STATUS_CODES.contains(httpRes.getStatusCode())){
				return 'Error: Unable to initiate Payment Gateway. please provide error message to System Administrator, '+httpRes.getBody();
			}

			String responseBody = httpRes.getBody();
            System.debug('Raw Response: ' + responseBody);

			String fixedString = EncodingUtil.convertFromHex(
  				EncodingUtil.convertToHex(Blob.valueOf(responseBody))
    			.removeStart('feff').removeStart('fffe').removeStart('efbbbf')
			).toString();
            
            if (responseBody != null && responseBody.startsWith('\uFEFF')) {
            responseBody = responseBody.substring(1);
        }

			TokenResponseWrapper tokenWrapper = (TokenResponseWrapper) JSON.deserialize(responseBody, TokenResponseWrapper.class);
			if (tokenWrapper != null && String.isNotBlank(tokenWrapper.token)) {
				return tokenWrapper.token;
			}

			return 'Error: Unable to initiate Payment Gateway. please contact your System Administrator.';

		}catch(Exception ex){
			throw new AuraHandledException ('Something went wrong while initiating Payment Gateway. '+ex.getMessage());
		}

	}

	private static String generateAuthTokenForPayment(PaymentGatewayWrapper paymentWrap){ 

		Apostille_Authorization_net_Payment_Form__mdt paymentMdt = Apostille_Authorization_net_Payment_Form__mdt.getInstance('Online_Apostille');
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('getHostedPaymentPageRequest');
		gen.writeStartObject();
		
		gen.writeFieldName('merchantAuthentication');
		gen.writeStartObject();
		gen.writeStringField('name', '{!$Credential.AuthorizationNet_Payment_Gateway.name}');
		gen.writeStringField('transactionKey', '{!$Credential.AuthorizationNet_Payment_Gateway.transactionKey}');
		gen.writeEndObject();
		
		gen.writeFieldName('transactionRequest');
		gen.writeStartObject();
		gen.writeStringField('transactionType', 'authCaptureTransaction');
		gen.writeStringField('amount', paymentWrap.amount);
		
		gen.writeFieldName('profile');
		gen.writeStartObject();
		gen.writeStringField('customerProfileId', '12345'); // Current Logged in User Id
		gen.writeEndObject();
		
		gen.writeFieldName('customer');
		gen.writeStartObject();
		gen.writeStringField('email', paymentWrap.email);
		gen.writeEndObject();
		
		gen.writeFieldName('billTo');
		gen.writeStartObject();
		gen.writeStringField('firstName', paymentWrap.firstName);
		gen.writeStringField('lastName', paymentWrap.lastName);
		gen.writeStringField('company', '');
		gen.writeStringField('address', paymentWrap.address);
		gen.writeStringField('city', paymentWrap.city);
		gen.writeStringField('state', paymentWrap.state);
		gen.writeStringField('zip', paymentWrap.zip);
		gen.writeStringField('country', paymentWrap.country);
		gen.writeEndObject();
		
		gen.writeEndObject();
		
		gen.writeFieldName('hostedPaymentSettings');
		gen.writeStartObject();
		gen.writeFieldName('setting');
		gen.writeStartArray();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentReturnOptions');
		gen.writeStringField('settingValue', '{"showReceipt": '+paymentMdt.showReceipt__c+', "url": "https://ctds--sapdev001.sandbox.my.site.com/eApostille/eApostilleform", "urlText": "Continue", "cancelUrl": "https://ctds--sapdev001.sandbox.my.site.com/eApostille/eApostilleform", "cancelUrlText": "Cancel"}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentButtonOptions');
		gen.writeStringField('settingValue', '{"text": "Pay Securely"}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentStyleOptions');
		gen.writeStringField('settingValue', '{"bgColor": "blue"}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentPaymentOptions');
		gen.writeStringField('settingValue', '{"cardCodeRequired":'+ paymentMdt.cardCodeRequired__c+', "showCreditCard": '+paymentMdt.showCreditCard__c+', "showBankAccount": '+paymentMdt.showBankAccount__c+'}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentSecurityOptions');
		gen.writeStringField('settingValue', '{"captcha": '+paymentMdt.captcha__c+'}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentShippingAddressOptions');
		gen.writeStringField('settingValue', '{"show": false, "required": false}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentBillingAddressOptions');
		gen.writeStringField('settingValue', '{"show": false, "required": false}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentCustomerOptions');
		gen.writeStringField('settingValue', '{"showEmail": false, "requiredEmail": false, "addPaymentProfile": true}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentOrderOptions');
		gen.writeStringField('settingValue', '{"show": true, "merchantName": "'+paymentMdt.merchantName__c+'"}');
		gen.writeEndObject();
		
		gen.writeStartObject();
		gen.writeStringField('settingName', 'hostedPaymentIFrameCommunicatorUrl');
		gen.writeStringField('settingValue', '{"url": "https://ctds--sapdev001--c.sandbox.vf.force.com/apex/authorization_net"}');
		gen.writeEndObject();
		
		gen.writeEndArray();
		gen.writeEndObject();
		
		gen.writeEndObject();
		
		gen.writeEndObject();

		return gen.getAsString();
	}

	public class PaymentGatewayWrapper{
		@AuraEnabled
		public String amount{get; set;} 
		@AuraEnabled
		public String firstName{get; set;}
		@AuraEnabled
		public String lastName{get; set;}
		@AuraEnabled
		public String company{get; set;}
		@AuraEnabled
		public String address{get; set;}
		@AuraEnabled
		public String city{get; set;}
		@AuraEnabled
		public String state{get; set;}
		@AuraEnabled
		public String zip{get; set;}
		@AuraEnabled
		public String country{get; set;}
		@AuraEnabled
		public String email{get; set;}
		@AuraEnabled
		public String contactNo{get; set;}
	}

	public class TokenResponseWrapper{
		@AuraEnabled
		public String token{get; set;}
	}

}