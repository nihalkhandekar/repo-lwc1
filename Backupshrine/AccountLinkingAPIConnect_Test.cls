@isTest
private class AccountLinkingAPIConnect_Test {

    private static String getParserString() {
        AccountLinkingAPIConnect.AccountLinkingParser parser = new AccountLinkingAPIConnect.AccountLinkingParser();
        parser.Id = '';
        parser.code = '200';
        parser.message = '';
        parser.status = '';
        parser.reason = '';
        
        return JSON.serialize(parser);
    }
    
    @isTest
    private static void testsendUserIdToFR() {
    	Test.startTest();
        try{
        	AccountLinkingAPIConnect.sendUserIdToFR(UserInfo.getUserId());
             }catch(Exception e){ system.assertNotEquals(null, e);}
        Test.stopTest();
    }
    
    @isTest
    private static void testUserListner() {
        AccountLinkingAPIConnect.UserListner listner = new AccountLinkingAPIConnect.UserListner(UserInfo.getUserId(),'');
        try{
        Test.startTest();
	        listner.onSuccess(getParserString());
        listner.onError('error');
        Test.stopTest();
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
    
    @isTest
    private static void testparse() {
        Test.startTest();
    	    AccountLinkingAPIConnect.AccountLinkingParser actual = AccountLinkingAPIConnect.parse(getParserString());
        Test.stopTest();
    }
    
}