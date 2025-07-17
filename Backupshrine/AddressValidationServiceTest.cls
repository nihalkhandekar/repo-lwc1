@isTest
private class AddressValidationServiceTest {
    testmethod static void getAddressSuggestionsTest1() {
        HttpResponseMock mock = new HttpResponseMock(createResponseBody(true), 200, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
            AddressValidationService.getAddressSuggestions('test request', 'India', '702 Adam', 'Test');
        Test.stopTest();
    }
    
    testmethod static void getAddressSuggestionsTest2() {
        HttpResponseMock mock = new HttpResponseMock(createResponseBody(false), 200, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	AddressValidationService.getAddressSuggestions('test request', 'India', '702 Adam', 'Test');   
        Test.stopTest();
    }
    
    testmethod static void getAddressSuggestionsTest3() {
        try{
            Test.startTest();
            	AddressValidationService.getAddressSuggestions('test request', 'India', '702 Adam', 'Test');
            Test.stopTest();
        }
        catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    
    testmethod static void verifyAddressTest1() {
        try{
        HttpResponseMock mock = new HttpResponseMock(createResponseBody(true), 200, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	AddressValidationService.verifyAddress('test request');
        Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    testmethod static void verifyAddressTest2() {
        try{
        HttpResponseMock mock = new HttpResponseMock('Error', 400, 'OK');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	AddressValidationService.verifyAddress('test request'); 
        Test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    testmethod static void verifyAddressTest3() {
        try{
            Test.startTest();
            	AddressValidationService.verifyAddress('test request');
            Test.stopTest();
        }
        catch(Exception ex) {
            System.debug(ex);
        }
    }
    
    static String createResponseBody(Boolean addAddress) {
        List<AddressResponseParser.AddressWrapper> addressList = new List<AddressResponseParser.AddressWrapper>();
        if(addAddress == true) {
            AddressResponseParser.AddressWrapper newAddress1 = new AddressResponseParser.AddressWrapper();
            newAddress1.address = new AddressResponseParser.Address('702 Adam', 'Bengaluru', 'Karnataka', '560066');
            newAddress1.address.CountryName = 'India';
            newAddress1.address.ISO3166_3 = 'IN';
            newAddress1.address.secondary = '222222';
            addressList.add(newAddress1);
            
            AddressResponseParser.AddressWrapper newAddress2 = new AddressResponseParser.AddressWrapper();
            newAddress2.address = new AddressResponseParser.Address();
            addressList.add(newAddress2);
        }
        
        
        Map<String, List<AddressResponseParser.AddressWrapper>> testResponse = new Map<String, List<AddressResponseParser.AddressWrapper>>();
        testResponse.put('results', addressList);
        
        return JSON.serialize(testResponse);        
    }
}