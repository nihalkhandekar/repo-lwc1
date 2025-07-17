public with sharing  class ACHPaymentRequest {
    
    public class paymentParams
    {
        public string selectedAccOwnerType;
        public string selectedAccType;
        public string accNo;
        public string accNoConfirm;
        public string routingNo;
        public string firstName;
        public string lastName;
        public string companyName;
        public string attention;
        public String city;
        public String state;
        public String zip;
        public String street;
        public String unit;
        public String country;
        public String internationalAddress;        
        public string phone;
        public string email;
        public String amount;
        public Id workOrderId;
        public Id filingId;
        public Id customerId;        
    }
    
    public class ACHPaymentResponse {
        public string remittanceId;
        public string transactionId;
        public string BOAtransactionNumber;
        public string responseCode;
        public string responseMessage;
        public string errorCode;
        public string errorMessage;
        public string filler;
        public string status;
        public string statusCode;
        public string errorType;
        public string timeStamp;
        public string correlationId;
    }
    
    public class ACHPaymentReq{
        public string firstName;        // Required Max Length = 20
            public string lastName;           // Required Max Length = 30
            public string address;           // Required Max Length = 50
            public string city;               // Required Max Length = 30
            public string state;              // Required Max Length = 2
            public string zip;               // Required Max Length = 10
            public string accountNum;            // Required Max Length = 21
			public string company;				// Required Max Length = 50 --- Only applicable for Commercial
            public string accountType;             // Required "1" "2" (1 for checking 2 for savings) -- Only applicable for Personal
            public string routingNumber;           // Required Max Length = 15
            public string amount;                  // Required Max Length = 9  format 999999.99 (Final Amount)
			public string accountOwnerType;      	// Required. Possible Values P - Personal or C - Commercial
			public string email;				// Optional Max Length 50
			public string transactionId;			// Required alphanumeric random number which will be used internally for tracking purpose across a transactionId
    }
}