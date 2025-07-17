/**********************************************************************************************
NAME: brs_BackendFlowConfigutaionController
DESCRIPTION: This class returns all the fiedls of a particualr page layout
@AUTHOR:Mangesh Abhang
@DATE:21-October-2020

MODIFICATION LOG:
DEVELOPER                         DATE: 21-October-2020       DESCRIPTION
_____________________________________________________________________________________________
Mangesh Abhang                                                  Created the first version                                                                                                                                                                updated framework logic
***********************************************************************************************/
global with sharing class brs_BackendFlowConfigutaionController {
    public static  Map<String, Schema.SObjectField> allFields;
    public static  Map<String,String> parentRecordDetail = new Map<String,String>();
    public static  Map<String,Boolean> parentRecordReadOnly = new Map<String,Boolean>();
    @AuraEnabled 
    public static FinalResult getPageLayoutFields(string objectname,string flowName, string recordType,String parentRecordMap,String recordTypename,String type,String btype,Boolean readonlypage,String typeField,String recordID) {
        if(String.isBlank(recordType) && String.isNotBlank(recordTypename)){
     List<RecordType> typed=    [Select id, name from RecordType where sobjectType =: objectname and IsActive=true and name =:recordTypename];
     if(!typed.isEmpty())      
     recordType = typed[0].id;
     parentRecordDetail.put('RecordTypeId',recordType);
}
         
    
 //  List<RecordType> lstrr=[Select id, name from RecordType where Id =: recordType and IsActive=true];
        List<BRS_Worker_Flow_Config_Data__mdt> lstmdt;
        if(objectname == 'Account' && String.isNotBlank(type) && String.isNotBlank(btype)){
            lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
            where Object_Name__c=:objectname and Flow_Name__c=:flowName and Citizenship__c =:type and Business_Type__c = :btype
             Limit 1];
        }
        else if(objectname == 'Account' && String.isNotBlank(type) && String.isNotBlank(typeField)  ){
            lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
            where Object_Name__c=:objectname and Flow_Name__c=:flowName and Type__c =:typeField and Citizenship__c =:type
             Limit 1];
        }
       else if(objectname == 'Account' && String.isNotBlank(typeField) ){
        lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
            where Object_Name__c=:objectname and Flow_Name__c=:flowName and Type__c =:typeField 
             Limit 1];
        }
        else if(objectname == 'Account' && String.isNotBlank(flowName) && String.isNotBlank(objectname)){
            lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
            where Object_Name__c=:objectname and Flow_Name__c=:flowName 
             Limit 1];
        }
        else{
            lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
                                                        where Object_Name__c=:objectname and Flow_Name__c=:flowName and 
                                                        Type__c =null and Citizenship__c =null and Business_Type__c =null
                                                         Limit 1];
        }
        if(objectname == 'Business_History__c'){
            lstmdt=   [select id,Page_Layout_Name__c from BRS_Worker_Flow_Config_Data__mdt
                                                        where Object_Name__c=:objectname ];
        }
      
        List<LayoutSection> lstSections = new List<LayoutSection>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        allFields = new Map<String, Schema.SObjectField>();
        allFields = schemaMap.get(objectname).getDescribe().fields.getMap();
        string pageLayoutstr;
        if(!lstmdt.IsEmpty())
        {
            pageLayoutstr=lstmdt[0].Page_Layout_Name__c;
        }  
        if(String.isNotBlank(parentRecordMap)){
            List<ParentRecord> records = (List<ParentRecord>) JSON.deserialize(parentRecordMap, ParentRecord[].class);
            
            for(ParentRecord rec: records){
                parentRecordDetail.put(rec.FieldApiname,rec.RecordId);
                parentRecordReadOnly.put(rec.FieldApiname,rec.isReadonly);
            }
        }
        

        try {
            // Provide the page layout name here
            
            List<String> componentNameList = new List<String>{pageLayoutstr};
                // This is a salesforce class to retrive page layout details
                List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                
                LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                
                List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                Integer maxFieldsInColumn = 0;
                System.debug('Lc'+JSON.serialize(ls));
                for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                    
                    LayoutColumn column = new LayoutColumn();
                    // check if there are fields available in that column
                    if( lc.layoutItems != null ) { 
                        // Get the max number of fields in a column to preserve the alignment 
                        if( maxFieldsInColumn < lc.layoutItems.size() ) {
                            maxFieldsInColumn = lc.layoutItems.size();
                        }
                        for( Metadata.LayoutItem li : lc.layoutItems ) {
                            
                            // Pass the LayoutItem object in the LayoutField consturctor        
                            column.lstFields.add( new LayoutField( li,readonlypage,objectname,recordID ) );
                        }
                    }
                    // No need to add a column in the section if there is no field available 
                    if( column.lstFields.size() > 0 ) {
                        lstColumns.add( column );
                    }
                }
                
                // Now, we need to arrange the fields in section so we can use them in the iteration 
                // on the component so we will have to arrange them in the order 
                if( maxFieldsInColumn > 0 ) {
                    for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                        // System
                        for( Integer j = 0; j < lstColumns.size(); j++ ){
                            if( lstColumns[j].lstFields.size() > i ) {
                                section.displaySection = true;
                                if(lstColumns[j].lstFields[i] !=null) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );   
                                }
                                
                            }    
                            else {
                                section.lstFields.add( new LayoutField() );
                            }
                        }    
                    }    
                }
                
                lstSections.add( section );
            }
        }
        catch( Exception e ){
            System.debug('error is '+ e.getMessage() );
        }
       
        FinalResult result = new FinalResult();
        result.sections = lstSections;
        result.recordType = recordType;
        return result;
    }
    
    public class FinalResult{
        @AuraEnabled
     public List<LayoutSection> sections;
     @AuraEnabled
     public String recordType ;
    }

    public class LayoutSection {   
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        @AuraEnabled public string columnsize;
        @AuraEnabled public Boolean displaySection=false ;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
            this.columnsize = String.valueOf(12/totalColumns);
            
        }
    }
    
    private class LayoutColumn {
        private List<LayoutField> lstFields;  
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    @testVisible
    private class ParentRecord {
        public String FieldApiname;
        public String RecordId;
        public Boolean isReadonly = false;
    }
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        @AuraEnabled public Boolean isValueAvailable=false;
        @AuraEnabled public Boolean isDateavailable=false;
        @AuraEnabled public string fieldLable;
        @AuraEnabled public String fieldvalue;
        @AuraEnabled public Datetime datevalue;
        
        @AuraEnabled public Boolean isDisable=false;
        // @AuraEnabled public Boolean ;        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li,Boolean readonlypage ,String objectName,String recordID) {
            this.fieldName = li.field;
            
            // String fieldLabel = allFields.get(fieldName).getDescribe().getLabel() !=null? allFields.get(fieldName).getDescribe().getLabel():'';
            // system.debug('allFields'+JSON.serialize(allFields));
            String fieldLabel = allFields.get(fieldName)!=null? allFields.get(fieldName).getDescribe().getLabel():'';
            this.fieldLable = fieldLabel;
            this.fieldvalue ='';
            
            if(String.isNotBlank(parentRecordDetail.get(this.fieldName))){
                this.fieldvalue =parentRecordDetail.get(this.fieldName);
                this.isValueAvailable = true;
            }
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            } 
            //Extend this to make fields readonly only for this component
            if(readonlypage!=null && readonlypage==true) {
                this.isReadOnly = true;
                this.isRequired = false;
            }
          if(parentRecordReadOnly.get(this.fieldName)==true ){
                this.isDisable = true;
            }
            if(String.isNotBlank(objectName) && objectName.equals('Work_Order__c') && this.fieldName == 'Received_Date__c' ){
               try{
                List<User> currentUser =[Select id ,Received_date__c from User where id = :UserInfo.getUserId()];
                    if(currentUser!=null && currentUser.size()>0 && currentUser[0].Received_date__c!=null  && String.isBlank(recordID))  {
                this.datevalue = currentUser[0].Received_date__c;
                this.isDateavailable = true;
                this.isValueAvailable=true;
            }
            
            }catch(Exception e){}
                
            }
        }
    }
    @AuraEnabled
    public static string findRecordTypes(string objName){
        string returnString='';
        string queryString='Select id, name from RecordType where sobjectType =: objName and IsActive=true';
        List<sobject> recordList= Database.query(queryString);
        List<RecordTypeWrapper> wrapperList=new List<RecordTypeWrapper>();
        for(sobject sb : recordList)  {
            RecordTypeWrapper rw=new RecordTypeWrapper();
            rw.recordTypeLabel=string.valueof(sb.get('name'));
            rw.recordTypeId=string.valueof(sb.get('id'));
            wrapperList.add(rw);
        } 
        returnString= JSON.serialize(wrapperList);
        system.debug('*****'+returnString);
        return returnString;
    }
    public class RecordTypeWrapper{
        public string recordTypeLabel{get;set;}
        public string recordTypeId{get;set;}
    }
    @AuraEnabled
    public static  List<DefaultValues>  fetchParentRecord(string objectname,string fieldName,  string parentRecordId ){
        String query = 'Select '+fieldName+' From '+objectname+' WHERE ' + 'Id= :parentRecordId ';
        system.debug('query'+query);
        List<SObject> lstobject= Database.query(String.escapeSingleQuotes(query));
        List<DefaultValues> lstdefault = new List<DefaultValues>();
        List<String> lststring = fieldName.split(',');
        for(SObject sobj :lstobject){
            for(String fields :lststring){
                DefaultValues dval = new DefaultValues();
                object value = sobj.get(fields);
                dval.name = fields;
                dval.value =value ==null?'':string.valueOf(value);
                lstdefault.add(dval);
            }
            //  val.name =
            system.debug('abc'+lstdefault);
        }
        return lstdefault;
    }
    public class DefaultValues{
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string value;
    }
    public class MyPickListInfo
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    public static MyPickListInfo[] getFieldDependencies(String object_name, String field_name)
    {

        MyPickListInfo[] values = new MyPickListInfo[]{};
                String[] types = new String[]{object_name};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                for(Schema.DescribeSobjectResult res : results) {
                   for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                      if (entry.isActive()) {
                        MyPickListInfo adddata = new MyPickListInfo();
                        adddata.label = entry.getValue();
                        adddata.value = entry.getValue();
                        values.add(adddata);}
                   }
                }
                return values;
             }


             @AuraEnabled
public static Map<String,List<MyPickListInfo>>getAllPickList(){
    Map<String,List<MyPickListInfo>> picklists = new Map<String,List<MyPickListInfo>>();
    picklists.put( 'Citizenship__c' ,getFieldDependencies('Business_Filing__c','Citizenship__c'));
    picklists.put( 'Business_Type__c' ,getFieldDependencies('Business_Filing__c','Business_Type__c'));
    
return picklists;
}

global without sharing class Requests {
    @InvocableVariable
    global string recordid;
    global string workorderid;
} 
global without sharing class Results {
    @InvocableVariable
    global string message;
    @InvocableVariable
    global List<string> records;
}

@InvocableMethod
public static List<Results> getFilingforAnualFirstFlow(List<Requests> Requests) {
    List<String> ids = new List<String>();
 try{

    String recordId = Requests[0].recordid;
    List<String>  idlist = new List<String>();
    if(String.isNotBlank(recordId))
     idlist = (List<String>) JSON.deserialize(recordId, String[].class);
    // List<String> statuses = new List<String>{'Due','In-Progress','Past Due'};
    // List<String> reports = new List<String>{'Annual Report','First Report'};
    // List<String> reporttypes = new List<String>{'Annual Report','First Report'};
    // List<Business_filing__c>  filings = [Select id,Work_Order__c from Business_Filing__c where Status__c in :statuses and 
    // Type__c in :reports and Account__c =:recordId ];
    List<Business_filing__c>  filings = [Select id,Work_Order__c from Business_Filing__c where id in :idlist];
   
     for(Business_filing__c filing: filings){
    ids.add(filing.id);
    
     }
       }catch(Exception e){}
       List<Results> lstResults = new List<Results>();
    Results r = new Results();
    r.message ='Success';
    r.records =ids;
    lstResults.add(r);

    system.debug('lstResults'+lstResults);    
    return lstResults;
}

@AuraEnabled
public static List<String> getFilingforAnualFirstReport(String accountID,String workorderID,String BusinessFilingList) {
    List<String> ids = new List<String>();
 try{
    List<String>  idlist = new List<String>();
    if(String.isNotBlank(BusinessFilingList))
     idlist = (List<String>) JSON.deserialize(BusinessFilingList, String[].class);

    Id recordId =accountID;

    List<String> statuses = new List<String>{'Due','In-Progress','Past Due'};
    List<String> reports = new List<String>{'Annual Report','First Report'};
    List<String> reporttypes = new List<String>{'Annual Report','First Report'};
    // List<Business_filing__c>  filings = [Select id,Work_Order__c from Business_Filing__c where Status__c in :statuses and 
    // Type__c in :reports and Account__c =:recordId ];

    List<Business_filing__c>  filings = [Select id,Work_Order__c from Business_Filing__c where id in :idlist];
     Work_Order__c wo=[Select Id,Name,Received_Date__c from Work_Order__c where Id=:workorderID];
     for(Business_filing__c filing: filings){
    ids.add(filing.id);
    filing.Work_Order__c=workorderID;
    filing.Filing_Date__c= Date.valueOf(wo.Received_Date__c);
     }

     update filings;
       }catch(Exception e){}
         
    return ids;
}

@AuraEnabled
global static void updateWorkorder(String recordId,String label){
    try {
        String workorderID;
        if(label == 'Business Filing')
        {
     List<Business_Filing__c> filings=   [Select id, Work_Order__c from Business_Filing__c where id =:recordId ];
     if(filings!=null && !filings.isEmpty()){
        workorderID =filings[0].Work_Order__c;
    }
}else{
    List<Payment_Method__c> payments=   [Select id, Work_Order__c from Payment_Method__c where id =:recordId ];
     if(payments!=null && !payments.isEmpty()){
        workorderID =payments[0].Work_Order__c;
    } 
}
       List<Work_Order__c> orders = [Select id, Payments_Verified__c from Work_Order__c where id=: workorderID];
       if(orders!=null && !orders.isEmpty()){
        orders[0].Payments_Verified__c =false;
        update orders;
       }
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
@AuraEnabled
    public static void setFormationFiling(String accId,String filingId){
        try{
        Business_Filing__c bf=[Select Id,Name,Account__c from Business_Filing__c where Id=:filingId];
        bf.Account__c=accId;       
        update bf;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler('brs_BackendFlowConfigutaionController', 'setFormationFiling', 'Business_Filing__c', null,'Medium', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
}