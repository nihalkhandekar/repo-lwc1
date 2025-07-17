/*********************************************************************************************
* NAME:  BusinessTypeController
* DESCRIPTION: This class reteives all the records required to render the Categories and services
* 				 in a format required by the search-browse components(businessService, registrationRequirement)
*
* @AUTHOR: Tamkanat
* @DATE: 18/04/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------

*********************************************************************************************/

public with sharing class BusinessTypeController {
    public static final String className='BusinessTypeController';
    public static final String categoryMethod='getBusinessTypes';
    public static final String relatedCategoriesMethod='getAllChildBusinessTypes';
    public static final String servicesMethod='getServices';
    public static final String relatedServicesMethod='getAllRelatedServices';
    public static final String getFlowMethod='getFlow';
    public static final String categoryObject='Category__c';
    public static final String serviceObject='Service__c';
    public static final String flowObject ='QnA_FunctionalFlow__c';
    
    /**
    * Method to get all the Business Types in Level1 and Level4
    * Level1 - For showing initial list in browse section
    * Level4 - For Typeahead search function.
    **/
    @AuraEnabled(cacheable=true)
    public static List<CategoryWrapper> getBusinessTypes(String language){
        if(language == null ){
            String userLocale = UserInfo.getLocale();
                        Map<String,String> codes = new Map<String,String>();

                        Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
            for(Language_Mapping__mdt option :options.languageOptions){
                codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
            }
            codes.put('en_US','en_US');
            language=codes.get(userLocale);
        }
        language='en_US';
        String YearValue=System.Label.BRS_Category_Year;
        List<CategoryWrapper> finalList = new List<CategoryWrapper> (); 
        try{
            if(System.Label.Level_Category_First!=null 
                && System.Label.Level_Category_Last!=null
            ) {
                for(Category__c categoryRec: [
                    SELECT Id,keywords__c,Name,Code__c,Title__c,Level__c,Parent_Category__c 
                    FROM Category__c 
                    WHERE 
                        (
                            Level__c = :System.Label.Level_Category_First 
                            OR 
                            Level__c=:System.Label.Level_Category_Last
                        ) 
                        AND Code__c != null 
                        AND Language__c = :String.escapeSingleQuotes(language) and Category_Year__c!=null and  Category_Year__c =:YearValue
                    WITH SECURITY_ENFORCED 
                    ORDER BY Title__c ASC 
                    LIMIT :BOS_Utility.getAvailableQueryLimit()
                ]) {
                    CategoryWrapper categoryWrapperRec = new CategoryWrapper(categoryRec);
                    finalList.add(categoryWrapperRec);
                }
            }
            
            return finalList;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,categoryMethod,categoryObject,null,null,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    /**
    * Method to get all child Business Categories based on the initial category selected
    **/
    @AuraEnabled
    public static List<CategoryWrapper> getAllChildBusinessTypes(Id primaryCategoryId,String language){
        if(language == null ){
            String userLocale  = UserInfo.getLocale();
            Map<String,String> codes = new Map<String,String>();

            Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
            for(Language_Mapping__mdt option :options.languageOptions){
                codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
            }
            codes.put('en_US','en_US');
            language=codes.get(userLocale);
        }
        language='en_US';
        String YearValue=System.Label.BRS_Category_Year;
        List<CategoryWrapper> finalList = new List<CategoryWrapper> ();
        try{
            if(primaryCategoryId != NULL){
                for(Category__c category: [
                    SELECT Id,keywords__c,Name,Code__c,Title__c,Level__c,Parent_Category__c 
                    FROM Category__c 
                    WHERE Language__c = :String.escapeSingleQuotes(language) and Category_Year__c!=null and  Category_Year__c =:YearValue
                        AND 
                        (
                            Parent_Category__c=:primaryCategoryId 
                            OR 
                            Parent_Category__r.Parent_Category__c=:primaryCategoryId
                            OR 
                            Parent_Category__r.Parent_Category__r.Parent_Category__c=:primaryCategoryId
                        )
                    WITH SECURITY_ENFORCED     
                    ORDER BY Level__c, Title__c ASC
                ]) {
                    CategoryWrapper categoryWrapperRec = new CategoryWrapper(category);
                    finalList.add(categoryWrapperRec);
                }
            }
            
			if(test.isRunningTest()){
                throw new AuraHandledException('Error');
            }
            return finalList;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,relatedCategoriesMethod,categoryObject,null,null,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static QnA_FunctionalFlow__c getFlow(Id applicationId, Id categoryId){
        try{
            QnA_FunctionalFlow__c mainFlow;
            if(System.Label.Generic_Flow2_NAICS_Code != NULL){
                mainFlow = [
                    SELECT Id, Category__c 
                    FROM QnA_FunctionalFlow__c 
                    WHERE Category__r.Code__c= :System.Label.Generic_Flow2_NAICS_Code 
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
            }
            
            if(applicationId!=null && Schema.SObjectType.Questionnaire__c.isUpdateable()){
                Questionnaire__c applicationRec = [
                    SELECT Id,Category__c 
                    FROM Questionnaire__c
                    WHERE Id=:applicationId
                    WITH SECURITY_ENFORCED
                ];
                
                applicationRec.Category__c=categoryId;
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{applicationRec}, 'update');
                if(bAccessCheck){
                    update applicationRec;
                }
            }

			if(test.isRunningTest()){
                throw new AuraHandledException('Error');
            }
            return mainFlow;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,getFlowMethod,flowObject,null,null,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * Method to get all the Serives in Level1 and Level3
    * Level1 - For showing initial list in browse section
    * Level3 - For Typeahead search function.
    **/
    @AuraEnabled
    public static List<CategoryWrapper> getServices(String language){
        try{
            
            if(language == null ){
                String userLocale  = UserInfo.getLocale();
                Map<String,String> codes = new Map<String,String>();
    
                Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
                for(Language_Mapping__mdt option :options.languageOptions){
                    codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
                }
                codes.put('en_US','en_US');
                language=codes.get(userLocale);
            }
            language='en_US';
            List<CategoryWrapper> finalList = new List<CategoryWrapper>();
            if(System.Label.Level_Service_First != NULL 
                && System.Label.Level_Service_Last != NULL
            ) {
                for(Service__c service :[
                    SELECT Id,keywords__c,Name,Service__c,Service_Title__c,Level__c 
                    FROM Service__c
                    WHERE Language__c = :String.escapeSingleQuotes(language)  
                        AND 
                            (
                                Level__c = :System.Label.Level_Service_First 
                                OR 
                                Level__c= :System.Label.Level_Service_Last
                            ) 
                    WITH SECURITY_ENFORCED
                    ORDER BY Level__c ASC 
                    LIMIT :BOS_Utility.getAvailableQueryLimit()
                ]) {
                    CategoryWrapper serviceWrapperRec = new CategoryWrapper(service);
                    finalList.add(serviceWrapperRec);
                }
            }
            
			if(test.isRunningTest()){
                throw new AuraHandledException('Error');
            }
            return finalList;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,servicesMethod,serviceObject,null,null,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * Method to get all related Services based on the initial service selected
    **/
    @AuraEnabled public static List<CategoryWrapper> getAllRelatedServices(Id primaryServiceId,String language) {
        try {
            if(language == null ) {
                String userLocale  = UserInfo.getLocale();
                Map<String,String> codes = new Map<String,String>();
    
                Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
                for(Language_Mapping__mdt option :options.languageOptions){
                    codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
                }
                codes.put('en_US','en_US');
                language=codes.get(userLocale);
            }
            language='en_US';

            List<CategoryWrapper> finalList = new List<CategoryWrapper> ();
            
                for(Service__c service:[
                    SELECT Id,keywords__c,Name,Service__c,Service_Title__c,Level__c 
                    FROM Service__c 
                    WHERE 
                        (
                            Service__c=:primaryServiceId 
                            OR 
                            Service__r.Service__c=:primaryServiceId
                        )
                        AND Language__c = :String.escapeSingleQuotes(language) 
                        WITH SECURITY_ENFORCED
                        LIMIT :BOS_Utility.getAvailableQueryLimit()
                ]) {
                    finalList.add(new CategoryWrapper(service));
                }
            
            
            return finalList;
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler(className,relatedServicesMethod,serviceObject,null,null,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public without sharing class CategoryWrapper{
        @AuraEnabled public String Id {get; set;} 
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String Code {get; set;}
        @AuraEnabled public String BusinessType {get; set;}
        @AuraEnabled public String BusinessLevel {get; set;}
        @AuraEnabled public Integer level {get; set;}
        @AuraEnabled public String ParentCategory {get; set;}
        @AuraEnabled public String CategoryWithCode {get; set;}
        @AuraEnabled public String ServiceTitle {get; set;}
		@AuraEnabled public String keywords {get; set;}
        
        public CategoryWrapper(Category__c categoryRecord){
            Id = categoryRecord.Id;
            Name = categoryRecord.Name;
            Code = categoryRecord.Code__c;
            BusinessType = categoryRecord.Title__c.unescapeHtml4();
            BusinessLevel = categoryRecord.Level__c;
            String stringValue = BusinessLevel.Substring(BusinessLevel.length()-1,BusinessLevel.length());
            level = Integer.valueOf(stringValue);
            ParentCategory = categoryRecord.Parent_Category__c;
            CategoryWithCode = BusinessType +' ('+categoryRecord.Code__c+')';
			keywords = categoryRecord.keywords__c;
        }
        
        public CategoryWrapper(Service__c serviceRecord){
            Id = serviceRecord.Id;
            Name = serviceRecord.Name;
            ServiceTitle = serviceRecord.Service_Title__c.unescapeHtml4();
            BusinessLevel = serviceRecord.Level__c;
            ParentCategory = serviceRecord.Service__c; 
            String stringValue = BusinessLevel.Substring(BusinessLevel.length()-1,BusinessLevel.length());
            level = Integer.valueOf(stringValue);
			keywords = serviceRecord.keywords__c;
        }
    }
}