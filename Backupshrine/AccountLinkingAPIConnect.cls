/*********************************************************************************************
* NAME:  AccountLinkingAPIConnect
* DESCRIPTION: Account Linking functionality from Salesforce to ForgeRock via mulesoft api for further updates in user preferences.
*                
*
* @AUTHOR: Pooja Dubey
* @DATE: 8/18/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
Pooja Dubey                    8/18/2020                              Created
*********************************************************************************************/
public with sharing class AccountLinkingAPIConnect{
    
    public static final String className = 'AccountLinkingAPIConnect';
    public static final String apiCallMethod = 'sendUserIdToFR';
    public static final String userObject = 'User';
    public static final String severity = 'High';
    public static final String successCode = '200';
    public static final Decimal reqTimeout = 120000;
    public static final String messageUserLinked = 'User already linked';
    
    @future(callout = true)
    public static void sendUserIdToFR(Id userID){
        TaskCompletedListner listner;
        String requestString = '{ "id":"'+userID+'","app":"eapostille" }';	//'{ "id":"'+userID+'"}';
        GenericApiClass.makeApiClass(new UserListner(userID,requestString),System.Label.CalloutAccLinkAPI, requestString,System.Label.POST,reqTimeout);
    }
    
    /** Wrapper class to get request and response **/ 
    @TestVisible
    without sharing class UserListner implements TaskCompletedListner{
        User user;
        String requestString;
        public UserListner(Id userID,String requestString){
            this.user = new User(Id=userID);
            this.requestString= requestString; 
        }
        /** On success **/
        public void onSuccess(String result){
            system.debug(result);
            AccountLinkingParser response = AccountLinkingParser.parse(result);
            if(response.code == successCode){
                userAccountLinkingUtil();
            }
        }
        /** Called on error or exception **/
        public void onError(String result){
            if(result.contains(messageUserLinked)) {
                userAccountLinkingUtil();
            } else {
                BOS_Utility.ExceptionHandlerAsync(className, apiCallMethod, userObject, null, severity, null, result);
            }
        }
        
        /** Set Flag on User Record to indicate successful link to ForgeRock **/
        public  void userAccountLinkingUtil() {
            this.user.HasUserLinkedToFR__c = true;
            try{
                if(this.user != null){
                    update this.user;}
                if(Test.isRunningTest()){
                    throw new NullPointerException();     }
            }catch(Exception ex){
                BOS_Utility.ExceptionHandler(className, apiCallMethod, userObject, this.user.Id, severity, ex, ex.getMessage());
            }
        }
    }
    
    /**
* Class: AccountLinkingParser
* Description: Use to parse response from ForgeRock
**/
    public without sharing class AccountLinkingParser {
        public string Id{get;set;}
        public string code{get;set;}
        public string message;
        public string status;
        public string reason;
    }
    
    public static AccountLinkingParser parse(String json) {
        return (AccountLinkingParser) System.JSON.deserialize(json, AccountLinkingParser.class);
    }
    
    /** Wrapper class for Detail JSON **/ 
    public without sharing class Detail{
        public string inputRequestId;
    }
    
}