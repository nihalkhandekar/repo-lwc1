/*********************************************************************************************
 * NAME:  AddressResponseParser
 * DESCRIPTION: Generic class to parse results of melissa
 *
 * @AUTHOR: Pooja Dubey
 * @DATE: 08/01/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Pooja Dubey                     08/01/2021                        Created the first version
*********************************************************************************************/

public with sharing class AddressResponseParser {
    @AuraEnabled
    public Address address{get;set;}
    @AuraEnabled
    public List<AddressWrapper> results{get;set;}
    @AuraEnabled
    public string ErrorString{get;set;}
    @AuraEnabled
    public string ResultCode{get;set;}
    
    public static String parse(String resultJSON) {
        List<Address> addressList = new List<Address>();
        List<AddressWrapper> addresses = new List<AddressWrapper>();
        AddressResponseParser adrswpr = (AddressResponseParser)JSON.deserialize(resultJSON, AddressResponseParser.class);
        addresses = adrswpr.results;
        
        for(integer i=0; i<addresses.size();i++){
            Address adrs = addresses[i].address;
            adrs.assignVariables(adrs.Address1, adrs.locality, adrs.administrativeArea,adrs.postalCode);
            addressList.add(adrs);
        }
        return JSON.serialize(addressList);
    }
    
    
    /**
		parse Melissa address results and also contains
		output format variables also
    **/
    public with sharing class Address{
        @AuraEnabled
        public string text{get;set;}
        @AuraEnabled
        public string AddressLine1{get;set;}
        @AuraEnabled
        public string PostalCode{get;set;}
        @AuraEnabled
        public string street_line{get;set;}
        @AuraEnabled
        public string city{get;set;}
        @AuraEnabled
        public string state{get;set;}
        @AuraEnabled
        public string zipcode{get;set;}
		@AuraEnabled
        public string locality{get;set;}
        @AuraEnabled
        public string administrativeArea{get;set;}
        @AuraEnabled
        public string address1{get;set;}
        @AuraEnabled
        public string address{get;set;}
        @AuraEnabled
        public string CountryName{get;set;}
        @AuraEnabled
        public string ISO3166_3{get;set;}
        @AuraEnabled
        public string secondary{get;set;}
        
        public Address(string street_line, string city, string state, string zipcode){
            this.text = street_line +', '+ city +', '+ state +', '+ zipcode;
            this.street_line = street_line;
            this.AddressLine1 = AddressLine1;
            this.city = city;
            this.state = state;
            this.zipcode = zipcode;
        }
        
        public void assignVariables(string street_line, string city, string state, string zipcode){
            
            this.zipcode = zipcode;
            this.text = address;
            this.street_line = street_line;
			this.city = city;
            this.state = state;
        }
		
		public Address(){
            this.text = system.label.NO_ADDRESS_FOUND;
        }
    }
    /**
    **/
    public with sharing class AddressWrapper{
        @AuraEnabled
        public Address address{get;set;}
    }
}