/*********************************************************************************************
 * NAME:  BosAccCOVIDGuidelineLWCController
 * DESCRIPTION: controller for BosAccCOVIDGuidelineLWC form. . 
 *
 * @AUTHOR: Devesh Murdiya
 * @DATE: 05/12/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Devesh Murdiya                    05/12/2020                         Created the first version
 *
*************************************************************************************************/
public without sharing class BosAccCOVIDGuidelineLWCController {
// wrapper class 
    public with sharing class FatchValueWrapper {
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string value {get;set;}
        @AuraEnabled public String fieldName {get;set;}
    }
    // wrapper class 
    public with sharing class ResponseWrapper {
        @AuraEnabled public boolean success {get;set;}
        @AuraEnabled public string message {get;set;}       
        @AuraEnabled public String certificationId {get;set;}
    }
    /********************************************************************************************
        METHOD NAME    : fatchPickListValue
        DESCRIPTION    : Fatch the picklist values from object and fields.
        RETURN TYPE    : List<FatchValueWrapper>
        PARAMETER      : sObject objInfo, List<string> picklistFieldApi
    ********************************************************************************************/
    @AuraEnabled(cacheable = true)
    public static List < FatchValueWrapper > fatchPickListValue(sObject objInfo, List<string> picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Create a list of wrapper to store picklist value/lable
        list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > (); 
        // Get the list of picklist values for this field.
        for(String fieldApiName : picklistFieldApi){
            for (Schema.PicklistEntry picklistValue: fieldMap.get(fieldApiName).getDescribe().getPickListValues()) {
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.label = picklistValue.getLabel();
                oFatchValueWrapper.value = picklistValue.getValue();
                oFatchValueWrapper.fieldName = fieldApiName;
                objWrapper.add(oFatchValueWrapper);
            }
        }
        return objWrapper; 
    }
    /********************************************************************************************
        METHOD NAME    : createBusinessReopenCertificationRecord
        DESCRIPTION    : Create the record of Business Reopen Certification Object.
        RETURN TYPE    : ResponseWrapper
        PARAMETER      : string businessReOpenString, Boolean isSubscribed
    ********************************************************************************************/
    @AuraEnabled
    public static ResponseWrapper createBusinessReopenCertificationRecord(String businessReOpenString, Boolean isSubscribed){
      ResponseWrapper response = new ResponseWrapper();
      JSONParser parser = JSON.createParser(businessReOpenString);
      Business_Reopen_Certification__c businessReOpenObj = (Business_Reopen_Certification__c)parser.readValueAs(Business_Reopen_Certification__c.class);      
      try{
          if(businessReOpenObj != Null && Schema.sObjectType.Business_Reopen_Certification__c.isAccessible())    //added null check
          {
           insert businessReOpenObj;
		   response.message = 'Registration Completed!!';	
          }
           if(isSubscribed){
               createSubscription(businessReOpenObj);
               EmailVerificationServiceCls.ResponseWrapper res = EmailVerificationServiceCls.generateVerificationLink(EmailVerificationServiceCls.getSuscriptionRecord(null,businessReopenObj.Email_Address__c.toLowerCase()));               
               if(res.verificationStatus == 'Verification Requested'){
                   response.message = 'Verification Requested'; 
               }
               else if(res.verificationStatus == 'Verification Not Required'){
                   response.message = 'Verification Not Required'; 
               }
           }           
           response.success = true; 	   
           response.certificationId = String.valueOf(businessReOpenObj.Id);
       }
       catch(DMLException error){           
           response.success = false;
           response.message = error.getMessage();
       }
       return response;
    }
    /********************************************************************************************
        METHOD NAME    : getSector
        DESCRIPTION    : Fetch the Meatada Records for PDF Links.
        RETURN TYPE    : Map<String,String>
        PARAMETER      : String code
    ********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getSector(String code){
        Map<String,String> sectorMap = new Map<String,String>();
        for(COVID_Sector__mdt sectorMdt : [SELECT MasterLabel,PDF_Link__c,Sector__c FROM COVID_Sector__mdt where Language__c=:code]){
            sectorMap.put(sectorMdt.Sector__c,sectorMdt.PDF_Link__c);
        }
        
        return sectorMap;
    }
    /********************************************************************************************
        METHOD NAME    : createFeedbackRecord
        DESCRIPTION    : Create the record of Feedback.
        RETURN TYPE    : ResponseWrapper
        PARAMETER      : String feedbackString
    ********************************************************************************************/
    @AuraEnabled
    public static ResponseWrapper createFeedbackRecord(String feedbackString){
      ResponseWrapper response = new ResponseWrapper();
      JSONParser parser = JSON.createParser(feedbackString);
      Feedback__c feedbackObj = (Feedback__c)parser.readValueAs(Feedback__c.class);      
      try{
          if(feedbackObj != Null && Schema.sObjectType.Feedback__c.isAccessible())    //added null check
          {
           insert feedbackObj;
          }
           response.success = true;
           response.message = 'Thank You for submitting Feedback.';
           response.certificationId = String.valueOf(feedbackObj.Id);
       }
       catch(DMLException error){           
           response.success = false;
           response.message = error.getMessage();
       }
       return response;
    }
    /********************************************************************************************
        METHOD NAME    : createSubscription
        DESCRIPTION    : Create the record of Subscription.
        RETURN TYPE    : Void
        PARAMETER      : Business_Reopen_Certification__c businessReopenObj
    ********************************************************************************************/
    public static void createSubscription(Business_Reopen_Certification__c businessReopenObj){
        NotificationServiceCls.wrapperResult wrapper = NotificationServiceCls.checkUniqueness(businessReopenObj.Email_Address__c.toLowerCase(),businessReopenObj.Contact_Phone_Number_1__c,'Subscription__c');
        List<Subscription__c> lstSubscription = new List<Subscription__c>();
        Map<String,SObject> mapSubscription = NotificationServiceCls.getSubscriptionRecord(businessReopenObj.Email_Address__c.toLowerCase(),businessReopenObj.Contact_Phone_Number_1__c,'Subscription__c');
        if(wrapper.emailSubscription == 'Insert' && wrapper.phoneSubscription == 'Insert'){
            lstSubscription.add(SubscriptionServiceCls.setEmailSubscription(businessReopenObj.Email_Address__c.toLowerCase(),businessReopenObj.Sector__c,businessReopenObj.Business_Type__c,businessReopenObj.Language__c));
            lstSubscription.add(SubscriptionServiceCls.setPhoneSubscription(businessReopenObj.Contact_Phone_Number_1__c,businessReopenObj.Sector__c,businessReopenObj.Business_Type__c,businessReopenObj.Language__c));
            NotificationServiceCls.dmlOperation('Insert',lstSubscription);
        }
        else if(wrapper.emailSubscription == 'Update' && wrapper.phoneSubscription == 'Update'){
            lstSubscription.add(SubscriptionServiceCls.updateEmailSubscription((Subscription__c )mapSubscription.get(businessReopenObj.Email_Address__c.toLowerCase()), businessReopenObj.Sector__c,businessReopenObj.Business_Type__c));
            lstSubscription.add(SubscriptionServiceCls.updatePhoneSubscription((Subscription__c )mapSubscription.get(businessReopenObj.Contact_Phone_Number_1__c), businessReopenObj.Sector__c,businessReopenObj.Business_Type__c));
            NotificationServiceCls.dmlOperation('Update',lstSubscription);
        }
        else if(wrapper.emailSubscription == 'Insert' && wrapper.phoneSubscription == 'Update'){
            lstSubscription.add(SubscriptionServiceCls.setEmailSubscription(businessReopenObj.Email_Address__c.toLowerCase(),businessReopenObj.Sector__c,businessReopenObj.Business_Type__c,businessReopenObj.Language__c));
            lstSubscription.add(SubscriptionServiceCls.updatePhoneSubscription((Subscription__c )mapSubscription.get(businessReopenObj.Contact_Phone_Number_1__c), businessReopenObj.Sector__c,businessReopenObj.Business_Type__c));
            NotificationServiceCls.dmlOperation('upsert',lstSubscription);
        }
        else if(wrapper.emailSubscription == 'Update' && wrapper.phoneSubscription == 'Insert'){
            lstSubscription.add(SubscriptionServiceCls.setPhoneSubscription(businessReopenObj.Contact_Phone_Number_1__c,businessReopenObj.Sector__c,businessReopenObj.Business_Type__c,businessReopenObj.Language__c));
            lstSubscription.add(SubscriptionServiceCls.updateEmailSubscription((Subscription__c )mapSubscription.get(businessReopenObj.Email_Address__c.toLowerCase()), businessReopenObj.Sector__c,businessReopenObj.Business_Type__c));
            NotificationServiceCls.dmlOperation('Upsert',lstSubscription);
        }
    } 
}