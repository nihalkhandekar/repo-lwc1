/*********************************************************************************************
 * NAME:  BRS_AddressValidationService
 * DESCRIPTION: Generic class to interate melissa API for address validation
 *
 * @AUTHOR: Pooja Dubey
 * @DATE: 08/01/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Pooja Dubey                     21/05/2020                         Created the first version
*********************************************************************************************/
public with sharing class AddressValidationService{
    public static final string CLASSNAME = 'AddressValidationService';    
    public static final String userObject = 'User';
    public static final String severity = 'High';
    public static string addressResult;
    public static string apiName;
    public static Boolean isVerifyCalled = false;
    
    /********************************************************************************************
        METHOD NAME    : getAddressSuggestions
        DESCRIPTION    : calling the Melissa API to get address suggestions
        RETURN TYPE    : Address List
        PARAMETER      : String,String
    ********************************************************************************************/
    @AuraEnabled
    public static string getAddressSuggestions(string requestString,string country, string filterwith, string filterlist){
        try{
             requestString = requestString.replace(' ','%20');
            apiName = System.label.MelissaAddressAPI;
            makeAPICall(requestString,country,filterlist,filterwith);
        }catch(Exception ex){
             BOS_Utility.ExceptionHandler(className, 'getAddressSuggestions', userObject, null, BOS_Utility.sSeverity, ex, null);
             throw new AuraHandledException('Unexpected error occured '+ex.getMessage());
        }
        return addressResult;
    }
    
    
    /********************************************************************************************
        METHOD NAME    : getAddressSuggestions
        DESCRIPTION    : calling the Melissa API to get address suggestions
        RETURN TYPE    : Address List
        PARAMETER      : String,String
    ********************************************************************************************/
    @AuraEnabled
    public static string verifyAddress(string requestString){
        try{
             requestString = requestString.replace(' ','%20');
            isVerifyCalled = true;
            apiName = System.label.MelissaVerifyAddressAPI;
            makeAPICall(requestString, null, null,null);
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'verifyAddress', userObject, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException('Unexpected error occured '+ex.getMessage());
        }
        return addressResult;
    }
    
    /********************************************************************************************
        METHOD NAME    : makeAPICall
        DESCRIPTION    : calling the Melissa API 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    public static void makeAPICall(String requestString, string country, string filterlist, string filterwith){
       try{
            system.debug('requestString: '+requestString);
            if(requestString!=null){
                API_Interface_Configuration__mdt addressConfig = BRS_Utility.fetchAPIInterfaceConfig(apiName);
                //string requestURL = addressConfig.End_Point_URL__c+addressConfig.Parameters__c+requestString;
                createURL urlObject = (createURL)JSON.deserialize(addressConfig.Parameters__c, createURL.class);
                string urlString = urlObject.createURLforGetCall(requestString,filterwith,country,filterlist,isVerifyCalled);
                string requestURL = addressConfig.End_Point_URL__c+ urlString;
                system.debug(requestURL) ;  
                GenericApiClass.makeApiClass(new AddressListener(), requestURL,null,addressConfig.Call_Type__c , Integer.valueOf(addressConfig.Timeout_Value__c));
            }else{
                throw new AuraHandledException('Please provide some input to get suggestions');
            }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'makeAPICall', userObject, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException('Unexpected error occured '+ex.getMessage());
            
        } 
    }
    
    /********************************************************************************************
        Class Name   : AddressListener
        Description  : 
    ********************************************************************************************/
    public with sharing class AddressListener implements TaskCompletedListner {
        
        public void onSuccess(String result) {
            addressResult = isVerifyCalled ? result :  AddressResponseParser.parse(result);
        }
        
        public void onError(String message) {
            System.debug('Final message' + message);
            addressResult = message;
        }
    }
    

    
    public with sharing class createURL{
        public string Id;
        public string format;
        public string ff;
        public string filterterm;
        public string listwhite;
        public string filterlist;
        public string country;
        public string maxrecords;
        public string a1;
        
        
        public string createURLforGetCall(string requestString, string filterwith, string country, string filterlist, Boolean isVerifyCalled){
            string urlString = '?Id='+this.Id+'&format='+this.format;
            if(filterwith!=null){
                urlString += '&country='+country+'&filterterm='+filterwith+'&filterlist='+filterlist+'&listwhite=true';
            }
            if(requestString!=null){
                if(isVerifyCalled){
                    urlString += '&a1='+requestString;
                }else{
                    urlString += '&ff='+requestString+'&maxrecords='+this.maxrecords;
                }
            }
            
            return urlString;
        }
    }
        
    
}