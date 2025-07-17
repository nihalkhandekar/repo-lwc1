/*********************************************************************************************
 * NAME:  LanguageConversionBatch
 * DESCRIPTION: This class contans the generic code to  reteives all the records required to convert in other languages based on english language
 * and do the conversions and create the proper records in all the 12 objects.
 *
 * @AUTHOR:Rohit heera
 * @DATE: 08/31/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Rohit heera                      08/31/2020                        Created the first version

*********************************************************************************************/

public with sharing class LanguageConversionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
  public static List<sObject> dataListToInsert = new List<sObject>();
 //this variable contains the null value in other languages.
  public static String OtherLanguageNullValue = System.Label.OtherLanguageNullValue;
   public static String LanguageFieldApiName = System.Label.LanguageFieldApiName;
   public static String EnglishVersionApiName = System.Label.EnglishVersionApiName;
        String language;
    String target;
   List<FlowConversionConfiguration__mdt> configList;
    Integer counter;
    public  LanguageConversionBatch(  List<FlowConversionConfiguration__mdt> configList,String target,Integer counter){
        this.language = language;
        this.target = target;
        this.counter = counter;
        this.configList= configList;
    }
    

public Database.QueryLocator start(Database.BatchableContext BC){

       FlowConversionConfiguration__mdt configData = this.configList[this.counter];
    String query = 'Select '+configData.AllFieldsToQuery__c + ' From '+ configData.Object_Name__c + ' where ' + configData.Where_Condition__c;

    return Database.getQueryLocator(query);
    }



    public void execute(Database.BatchableContext BC, List<sObject> scope){
      FlowConversionConfiguration__mdt configData = this.configList[this.counter];
        
     
        dataListToInsert.clear();
           String fieldsToConvert =configData.AllFieldsToConvert__c;
        if(String.isNotEmpty(fieldsToConvert))
        {
            // this section handles the conversion or text and creation of master data
            String data=''; 
        List<String> sectionData = new List<String>();
  
         for(SObject dataObject:scope){
           doDataConversion(target,dataObject,scope,configData);
            
         }
        }
        else {
            // this section handles the creation  of junction objects as there is no fields required to convert
             
            for(sObject dataToConvert:scope){
                      String requiredfieldsToConvert =configData.RequiredFieldsToAdd__c;
                
                
        if(String.isNotEmpty(requiredfieldsToConvert))
        {
            String responsestr2 = requiredfieldsToConvert.replace(',', ';;;');
         
                 
                    String convertedString2 = responsestr2;
                    List<String> fields = convertedString2.split(';;;');
            
             sObject sObj = Schema.getGlobalDescribe().get( configData.Object_Name__c).newSObject() ;
           
            
            for(String field:fields){
               
                if(field.equalsIgnoreCase(LanguageConversionBatch.LanguageFieldApiName)){
                  sObj.put(field, target)  ;
                }
            
                else if(field.equalsIgnoreCase(LanguageConversionBatch.EnglishVersionApiName)){
                    sObj.put(field, dataToConvert.get('id'))  ;
                }else{
                   sObj.put(field, dataToConvert.get(field))  ;  
                }
                 
                
        }
            dataListToInsert.add(sObj);
        } 
                  
            }
            if(!dataListToInsert.isEmpty()){
                upsert dataListToInsert;
            }
        }
    }
    
    /* from finish mehtod we do the actualy linking of records to any object
   we also call the next batch based on the order we set.
   */
      public void finish(Database.BatchableContext BC){
       
          
     FlowConversionConfiguration__mdt configData = this.configList[this.counter];
           if(String.isNotEmpty(configData.Linked_Object__c) && String.isNotEmpty(configData.LinkedField__c)){
              doLinking(configData);
              
          }
          
          
          
          // here is the calling of next batch for next object
          if((counter+1) <this.configList.size()){
         Database.executeBatch(new LanguageConversionBatch(this.configList,this.target,this.counter+1),50);
          }
      
    }
    /*  this method do the actual conversion of records to any target language
    */
    public static void doDataConversion(String target,SObject dataToConvert,List<sObject> scope,FlowConversionConfiguration__mdt configData){
        String data=''; 
        List<String> sectionData = new List<String>();
        String fieldsToConvert =configData.AllFieldsToConvert__c;
       
        String[] fields = fieldsToConvert.split(',');
        for(STring field : fields){
            if(String.isEmpty(data))
            {
                  data= (String)dataToConvert.get(field);
            }else{
            data= data +'||'+ dataToConvert.get(field);
            }
        }
     
        sectionData.add(data);
        
       
        
        LanguageRequestWrapper wrapper = new LanguageRequestWrapper(sectionData,target,'html');
        String requestData = JSON.serialize(wrapper);
      
       GenericApiClass.makeApiClass(new ApiCompleteListener(target, dataToConvert,scope,configData),Label.TranslationAPI,requestData,'POST',12000);
    }
    
    /* this class implemets the listener and perform insertion 
    operation of new records with new language*/
    without sharing class ApiCompleteListener implements TaskCompletedListner{
      public  String target;
       public SObject dataToConvert;
       public List<sObject> scope;
        
      public  FlowConversionConfiguration__mdt configData;
       public Integer index;
        public ApiCompleteListener(String target,SObject dataToConvert,List<sObject> scope,FlowConversionConfiguration__mdt configData){
            this.target = target;
            this.dataToConvert = dataToConvert;
            this.scope = scope;
            this.configData = configData;
        }
        public void onSuccess(String result){
           
            LanguageRessponseParser response =      LanguageRessponseParser.parse(result);
            LanguageRessponseParser.Translations tdata =  response.data;
            
            for(LanguageRessponseParser.Translation resultData:tdata.getTranslation()){
              String translatedText = resultData.translatedText;

                if(!String.isEmpty(translatedText)){
                   
                    String responsestr = translatedText.replace('||', ';;;');
          
                    String convertedString = responsestr;
                    List<String> values = convertedString.split(';;;');
                    sObject sObj = Schema.getGlobalDescribe().get( configData.Object_Name__c).newSObject() ;
                
                     String requiredfieldsToConvert =configData.RequiredFieldsToAdd__c;
        if(String.isNotEmpty(requiredfieldsToConvert))
        {
          String responsestr2 = requiredfieldsToConvert.replace(',', ';;;');
         
                    String convertedString2 = responsestr2;
                    List<String> fields = convertedString2.split(';;;');
            
            
            for(String field:fields){
                
                   
                if(field.equalsIgnoreCase(LanguageConversionBatch.LanguageFieldApiName)){
                  sObj.put(field, target)  ;
                }
            
                else if(field.equalsIgnoreCase(LanguageConversionBatch.EnglishVersionApiName)){
                   
                    sObj.put(field, dataToConvert.get('id'))  ;
                }else{
                    sObj.put(field, dataToConvert.get(field))  ;  
                }
        }
        } 
                    
                     String fieldsToConvert =configData.AllFieldsToConvert__c;
     
                    String responsestr1 = fieldsToConvert.replace(',', ';;;');
         
                      String convertedString1 = responsestr1;
                    List<String> translationfields = convertedString1.split(';;;');
                    
                    
                    
        if(String.isNotEmpty(fieldsToConvert))
            { 
                Integer counter=0;
                for(STring field : translationfields){
                    
                    if(counter<values.size())
                    {
                     
                    String val = values[counter];
                    if(LanguageConversionBatch.OtherLanguageNullValue.contains(val.trim()) || values[counter]==null){
                           sObj.put(field, null);   
                    }
                 else   if((String)dataToConvert.get(field)!=null && (((String)dataToConvert.get(field)).stripHtmlTags()==System.Label.Category ||((String)dataToConvert.get(field)).stripHtmlTags()==System.Label.Service)){
                         sObj.put(field,(String)dataToConvert.get(field)); 
                    }
                    else{
                      String decodeValue=  Charset.decode(Charset.encode(values[counter],System.Label.UTFValue),System.Label.UTFValue);   
                         sObj.put(field, decodeValue.unescapeHtml4());    
                    
                    }
                    counter++;
                    }
            }
        }                    
                
                    
                    dataListToInsert.add(sObj);
                }
            }
            
            if(!dataListToInsert.isEmpty() && dataListToInsert.size() == this.scope.size()){
                upsert dataListToInsert;
            }
            
        }
        public void onError(String message){
      
        }
        
        
    }
    
    // This method perfroms the linking of objects.
    private  void doLinking(FlowConversionConfiguration__mdt configData){
     String query = 'Select id,'+configData.LinkedField__c+','+EnglishVersionApiName + ' From '+ configData.Object_Name__c + ' where ' + LanguageFieldApiName+' = \''+target+'\'';

        List<SObject> data = Database.query(query);   
         Map<String,String> linkingData = new Map<String,String>();
        if(configData.Object_Name__c == configData.Linked_Object__c){
           
            for(sObject sdata:data){
                
                String key =(String)sdata.get(EnglishVersionApiName);
                String value = (String)sdata.get('id');
                linkingData.put(key,value);
            }
            
            for(sObject sdata:data){
                if( sdata.get(configData.LinkedField__c)!=null){
                sdata.put(configData.LinkedField__c,linkingData.get((String)sdata.get(configData.LinkedField__c)));
            
                }
                }
			if(!data.isEmpty())
            {
                update data;
            }
        }else{
            Map<String,Map<String,String>> linkingMap = new Map<String,Map<String,String>>();
            String linkedObject = configData.Linked_Object__c;
             String  responsestr = linkedObject.replace(',', ';;');
                   
                    String convertedString = responsestr;
                    List<String> linkedObjectArray = convertedString.split(';;');
            
                    List<String> dataList = new List<String>();
            for(String obj :linkedObjectArray){
          String  responsestr1 = obj.replace(':', ';;');
                  
                    String convertedString1 = responsestr1;
                     dataList = convertedString1.split(';;');
            }
        { 
            String query1 = 'Select id,'+EnglishVersionApiName + ' From '+ dataList[0] + ' where ' + LanguageFieldApiName+' = \''+target+'\'';

                List<SObject> data1 = Database.query(query1);   
       Map<String,String> linkingData1 = new Map<String,String>();
                for(sObject sdata:data1){
                
                String key =(String)sdata.get(EnglishVersionApiName);
                String value = (String)sdata.get('id');
                linkingData1.put(key,value);
            }
              linkingMap.put(dataList[1],linkingData1)  ;
                
            }
            
            for(sObject sdata:data){
                String linkedFields = configData.LinkedField__c;

                String  responsestr3 = linkedFields.replace(',', ';;');
                   
                String convertedString3 = responsestr3;
                List<String> fields = convertedString3.split(';;');
                for(String field:fields){
                if( sdata.get(field)!=null){
                    
                    Map<String,String> dataMap = linkingMap.get(field);
                       sdata.put(field,dataMap.get((String)sdata.get(field)));
                }
                }
                }
			if(!data.isEmpty())
            {
                update data;
            }
            
            
        }
        
        
    }
}