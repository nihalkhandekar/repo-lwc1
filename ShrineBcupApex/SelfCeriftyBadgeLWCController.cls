/*********************************************************************************************
 * NAME:  SelfCeriftyBadgeLWCController
 * DESCRIPTION: controller for BadgeRecoveryLWC form.
 *
 * @AUTHOR: Mohan Mullapudi
 * @DATE: 06/10/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Mohan Mullapudi                  06/10/2020                         Created the first version
 *
*************************************************************************************************/
public without sharing class SelfCeriftyBadgeLWCController {
    // wrapper class 
    public without sharing class ResponseWrapper {
        @AuraEnabled public boolean success {get;set;}
        @AuraEnabled public string message {get;set;}       
    }
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper emailIdExists(String SearchEmail) {
         ResponseWrapper response = new ResponseWrapper();
        String email1 = SearchEmail.trim();
         response.message = 'Emailid from browswer' + SearchEmail;
         try{
              List<Business_Reopen_Certification__c> businessObjectList = new List<Business_Reopen_Certification__c>();
              businessObjectList = [SELECT Email_Address__c FROM Business_Reopen_Certification__c where Email_Address__c =:email1];
               
             If(businessObjectList.size() >= 1){
              response.success = true;
              response.message = 'emailId verified';
                  }
             else {
                response.success = false;
                response.message = 'emailId not verified';
                 }  
               }
       catch(Exception error){           
           response.success = false;
           response.message = error.getMessage();
       }
       return response;  
    }

}