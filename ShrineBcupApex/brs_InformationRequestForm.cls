/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-25-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-20-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class brs_InformationRequestForm {
    /**
     * @desc: This Method is Used to Retrieve Data from UCC Contact and Search based on first Name ,Last Name,Business Name
     * @update: BRS-6673 | Updated to fetch from RequestForInformationController
     */
    @AuraEnabled
    public static List<RequestForInformationController.FilingWrapper> getRequestedInformation(Certficate__c request) {
        Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{request}, 'update');
		if(bAccessCheck){
            update request;
        }
        RequestForInformationController info = new RequestForInformationController(request.Id);
        return info.filings;
    }
	
    /**
     * @desc: This Method is Used to Retrieve Data from UCC Contact and Search based on first Name ,Last Name,Business Name
     * @update: Shreya | BRS-2958 | Additional fields/params needed for sdoc template
     */
    @AuraEnabled
    public static List<DataWrapper> getInformationRequestforSearch(String searchby, String searchfor, String recordId, Boolean isUpdate) {
        Set<Id> filingIds = new Set<Id>();
      
        try {
if(searchfor!=null && searchby !=null){
    List<Mark__c> filingList =new  List<Mark__c>();
        String query = 'Select id,Mark_Type__c,Registration_number__c,Owner_Name__c,Owner_Type__c,Renewal_Date__c,Expiration_Date__c,Class_of_Goods_Service__c,Description_of_Mark__c,Registration_Date__c from Mark__c ';
         if(searchby == 'Registration #'){
             query = query+ 'where Registration_number__c like \'%'+String.escapeSingleQuotes(searchfor) +'%\'';
       filingList =(List<Mark__c>) Database.Query(query);
            }
         if(searchby == 'Owner Name'){
            query = query+ 'where Owner_Name__c like \'%'+String.escapeSingleQuotes(searchfor) +'%\'';
            filingList =(List<Mark__c>) Database.Query(query);
        }
        if(searchby == 'Description'){

            String searchQuery = 'FIND \'*' + String.escapeSingleQuotes(searchfor) + '*' + '\' IN ALL FIELDS RETURNING '
            + 'Mark__c (id,Mark_Type__c,Disclaimer__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,Registration_number__c,Owner_Name__c,Owner_Type__c,Renewal_Date__c,Expiration_Date__c,Class_of_Goods_Service__c,Registration_Date__c) ';
        List<List<sObject>> searchList = search.query(searchQuery);

        if(searchList!=null && searchList.get(0)!=null){
            For(Mark__c mark:(List<Mark__c>)  searchList.get(0))
            {
               
                if(mark.Description_of_Mark__c!=null && mark.Description_of_Mark__c.containsIgnoreCase(searchfor)){
 filingList.add(mark);
                }
            }
            }
        }
        if(searchby == 'Keyword'){
            query = query+ 'where Keywords__c like \'%'+String.escapeSingleQuotes(searchfor) +'%\'';
            filingList =(List<Mark__c>) Database.Query(query);
        }
        if(searchby == 'Disclaimer'){
            String searchQuery = 'FIND \'*' + String.escapeSingleQuotes(searchfor) + '*' + '\' IN ALL FIELDS RETURNING '
            + 'Mark__c (id,Mark_Type__c,Disclaimer__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,Registration_number__c,Owner_Name__c,Owner_Type__c,Renewal_Date__c,Expiration_Date__c,Class_of_Goods_Service__c,Registration_Date__c) ';
        List<List<sObject>> searchList = search.query(searchQuery);

           if(searchList!=null && searchList.get(0)!=null){
           For(Mark__c mark:(List<Mark__c>)  searchList.get(0))
           {
               if(mark.Disclaimer__c!=null && mark.Disclaimer__c.containsIgnoreCase(searchfor)){
filingList.add(mark);
               }
           }
           }
        }
        if(searchby == 'Method of Use'){
            String searchQuery = 'FIND \'*' + String.escapeSingleQuotes(searchfor) + '*' + '\' IN ALL FIELDS RETURNING '
            + 'Mark__c (id,Mark_Type__c,Disclaimer__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,Registration_number__c,Owner_Name__c,Owner_Type__c,Renewal_Date__c,Expiration_Date__c,Class_of_Goods_Service__c,Registration_Date__c) ';
        List<List<sObject>> searchList = search.query(searchQuery);

        if(searchList!=null && searchList.get(0)!=null){
            For(Mark__c mark:(List<Mark__c>)  searchList.get(0))
            {
                if(mark.Method_of_use__c!=null && mark.Method_of_use__c.containsIgnoreCase(searchfor)){
 filingList.add(mark);
                }
            }
            }
        }
        if(searchby == 'Mark Used For'){
            String searchQuery = 'FIND \'*' + String.escapeSingleQuotes(searchfor) + '*' + '\' IN ALL FIELDS RETURNING '
            + 'Mark__c (id,Disclaimer__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,Mark_Type__c,Registration_number__c,Owner_Name__c,Owner_Type__c,Renewal_Date__c,Expiration_Date__c,Class_of_Goods_Service__c,Registration_Date__c) ';
        List<List<sObject>> searchList = search.query(searchQuery);

        if(searchList!=null && searchList.get(0)!=null){
            For(Mark__c mark:(List<Mark__c>)  searchList.get(0))
            {
                if(mark.Mark_used_for__c!=null && mark.Mark_used_for__c.containsIgnoreCase(searchfor)){
 filingList.add(mark);
                }
            }
            }
           
        }
        
        

        List<DataWrapper> dataList = new List<DataWrapper>();
             if(filingList.size()>0){
              for(Mark__c uccFiling : filingList){
                    DataWrapper dataRec = new DataWrapper();
                    dataRec.dataId = uccFiling.Registration_number__c;
                    dataRec.filingNumber = uccFiling.Registration_number__c;
                    dataRec.filingType = uccFiling.Mark_Type__c;
                    dataRec.lapseDate = uccFiling.Renewal_Date__c;
                    dataRec.filingDate =uccFiling.Expiration_Date__c;
                    dataRec.contactName =uccFiling.Owner_Name__c;
                    dataRec.contactType =uccFiling.Owner_Type__c;
                    dataRec.goodsClass = uccFiling.Class_of_Goods_Service__c;
                    dataRec.description = uccFiling.Description_of_Mark__c;
                    dataRec.registerationDate = uccFiling.Registration_Date__c;

                    dataList.add(dataRec);
                }
             }
             
            if(isUpdate) {
                
                        Certficate__c crtRecUpt = new Certficate__c();
                        crtRecUpt.Id = recordId;
                        crtRecUpt.Search_for__c = String.escapeSingleQuotes(searchfor);
                        crtRecUpt.Search_by__c = searchby;
                        
                        Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{crtRecUpt}, 'update');
						if(bAccessCheck){
                            update crtRecUpt;
                        }

            }
            
            return dataList;
}
        }catch (Exception exe) {
            BOS_Utility.ExceptionHandler('brs_InformationRequestForm', 'getInformationRequest', 'UCC_Related_Info__c', null, 'medium', exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
        return null;
    }
	

	// Method to retrieve Other request record from Id.
	 @AuraEnabled
    public static Certficate__c getSearchRecordData(String recordId){
        try {
            Certficate__c otherRequest = [select Id,Search_by__c,Search_for__c from Certficate__c where Id=:recordId WITH SECURITY_ENFORCED];
            return otherRequest;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }	// Method to retrieve Other request record from Id.
	
    //This Method is Used to Retrieve Data from UCC Filing and Search based on Filing Number
    @AuraEnabled
    public static  list<UCC_Filing__c> getCopyRequest(string filingNumber,String workOrder) {
        list<UCC_Filing__c > lstuccrel = new list<UCC_Filing__c>();
        List<Work_Order__c> lstwo = new List<Work_Order__c>(); 
        List<Work_Order__c> lstwo1 = new List<Work_Order__c>();
        try {
            lstuccrel = [SELECT Id,Work_Order__c, Name,Type__c,Filing_Number__c,Filing_Date__c,Lapse_Date__c,Microfilm_volume_number__c,Pages__c,UCC_Lien_Id__r.UCC_Lien_Number__c, UCC_Lien_Id__r.Type__c 
                         FROM  UCC_Filing__c where Name =: filingNumber WITH SECURITY_ENFORCED];
            lstwo = [select Id,Filing_Number__c,UCC_Individual_Last_Name__c,UCC_Individual_First_Name__c,UCC_Org_Name__c from Work_Order__c where Id =:workOrder WITH SECURITY_ENFORCED];
            if(lstwo.size() > 0){
                Work_Order__c wo = new Work_Order__c();
                wo.Filing_Number__c =filingNumber;
                wo.Id =lstwo[0].id;
                lstwo1.add(wo);
                if(!lstwo1.isEmpty()){
                update lstwo1; 
                }
            }
            return lstuccrel;
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler('brs_InformationRequestForm', 'getCopyRequest', 'UCC_Filing__c', null, 'medium', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public without sharing class DataWrapper {
        @AuraEnabled public String dataId {get; set;}
        @AuraEnabled public String filingNumber {get; set;}
        @AuraEnabled public String filingType {get; set;}
        @AuraEnabled public Date lapseDate {get; set;}
        @AuraEnabled public DateTime filingDate {get; set;}
        @AuraEnabled public String contactName {get; set;}
        @AuraEnabled public String contactType {get; set;}

        //update | for template
        public String description;
        public String goodsClass;
        public Date registerationDate;
        
        public DataWrapper() {}
    }
    
    public without sharing class LastModifiedWrapper {
        public String profileName;
        public LastModifiedWrapper() {}
    }
    /**
        @desc: BRS-7573 | Get Business filings for Longform certificate
        @author: Rabbani
     */
    public without sharing class ChangeHistoryWrapper {
        public String filingType;
        public String filingDate;
        public String effectiveDate;
        public String changeHistoryOldValue;
        public String changeHistoryNewValue;
        
        public ChangeHistoryWrapper(String filingType, String filingDate, String effectiveDate) {
            this.effectiveDate = effectiveDate;
            this.filingDate = filingDate;
            this.filingType = filingType;
        }
    }

    /**
        @desc: BRS-7573 | Get Business filings for Longform certificate
        @author: Rabbani
        @update: BRS-8650 | Shreya | Add support for Fiing time
     */
    public static List<ChangeHistoryWrapper> getChangeHistoryData(String recordId) {
        List<ChangeHistoryWrapper> dataList = new List<ChangeHistoryWrapper>();
        
        for(Business_Filing__c filing : [
            SELECT Filing_Date__c, Filing_Time__c, Effective_Date__c, Effective_Time__c, Filing_Type__c, Type__c, Due_Year__c,
                //,Nintex_Effective_Date_Time__c | Deprecating
                Work_Order__c, Work_Order__r.Received_Date__c,
                (
                    SELECT Business_Name_Old__c, Business_Name_New__c 
                    FROM Name_Change_Histories__r
                    LIMIT 1
                )
            FROM Business_Filing__c 
            WHERE Account__c IN
                (
                    SELECT Business__c
                    FROM Certficate__c
                    WHERE Id = :recordId    
                )
                AND Status__c = :System.Label.Approved 
                WITH SECURITY_ENFORCED 
            ORDER BY Filing_Date__c ASC NULLS LAST,
                Work_Order__r.Received_Date__c ASC NULLS LAST
        ]) {
            String filingDateTime = '', effectiveDateTime = '';

            //2. Filing Date Time
            if(filing.Work_Order__c != null && filing.Work_Order__r.Received_Date__c != null) {
                filingDateTime = filing.Work_Order__r.Received_Date__c.format('MM/dd/yyyy hh:mm a');
            } else if(filing.Filing_Date__c != null && filing.Filing_Time__c != null) {
                filingDateTime = DateTime.newInstance(filing.Filing_Date__c, filing.Filing_Time__c).format('MM/dd/yyyy hh:mm a');
            } else if(filing.Filing_Date__c != null) {
                filingDateTime = filing.Filing_Date__c.format();
            }

            //3. Effective date time
            if(filing.Effective_Date__c != null && filing.Effective_Time__c != null) {
                effectiveDateTime = DateTime.newInstance(filing.Effective_Date__c, filing.Effective_Time__c).format('MM/dd/yyyy hh:mm a');
            } else if(filing.Effective_Date__c != null) {
                effectiveDateTime = filing.Effective_Date__c.format();
            }

            ChangeHistoryWrapper dataRec = new ChangeHistoryWrapper(
                //1. Annual Report (Year)
                System.Label.Annual_Report_Comparable.equalsIgnoreCase(filing.Type__c)
                    ? filing.Type__c + '(' + filing.Due_Year__c + ')'
                    : filing.Filing_Type__c,
                filingDateTime,
                effectiveDateTime
            );

            if(!filing.Name_Change_Histories__r.isEmpty()) {
                dataRec.changeHistoryOldValue = filing.Name_Change_Histories__r[0].Business_Name_Old__c;
                dataRec.changeHistoryNewValue = filing.Name_Change_Histories__r[0].Business_Name_New__c;
            }

            dataList.add(dataRec);
        }

        return dataList;
    }

    public without sharing class CopyRequestDetails {
        public String Filing_Number;
        public String Copy_Type;
        public String No_Of_Copies;
        public String Volume_Type;
        public String Volume;
        public String Start_Page;
        public String Pages;
    }
    public static List<CopyRequestDetails> getCopyDetailsData(String recordId) {
        List<CopyRequestDetails> copyList = new List<CopyRequestDetails>();
        for(Copy_Request_Details__c requestDetail : [
            SELECT Number_of_Copies__c, Copy_Type__c,
                Business_Filing__c, Business_Filing__r.Sdoc_Filing_Number__c, Business_Filing__r.Volume_Type__c, Business_Filing__r.Volume__c, Business_Filing__r.Start_Page__c, Business_Filing__r.Pages__c, //Business Filing
                Mark_Filing__c, Mark_Filing__r.Sdoc_Filing_Number__c, Mark_Filing__r.Volume_Type__c, Mark_Filing__r.Volume__c, Mark_Filing__r.Start_Page__c, Mark_Filing__r.Pages__c, Mark_Filing__r.Number_of_Pages__c, //Mark Filing
                UCC_Filing__c, UCC_Filing__r.Sdoc_Filing_Number__c, /*UCC_Filing__r.Volume_Type__c,*/ UCC_Filing__r.Microfilm_volume_number__c, UCC_Filing__r.Start_Page__c, UCC_Filing__r.Pages__c //UCC
            FROM Copy_Request_Details__c
            WHERE Other_Request__c = :recordId 
            WITH SECURITY_ENFORCED
        ]) {

            sObject lookupObj;    
            if(requestDetail.Business_Filing__c != null) {
                lookupObj = requestDetail.Business_Filing__r;
            } else if(requestDetail.Mark_Filing__c != null) {
                lookupObj = requestDetail.Mark_Filing__r;
            } else if(requestDetail.UCC_Filing__c != null) {
                lookupObj = requestDetail.UCC_Filing__r;
            }

            String volumeType = requestDetail.UCC_Filing__c != null
                    ? ''
                    : String.valueOf(lookupObj.get('Volume_Type__c'));
                String volume = requestDetail.UCC_Filing__c != null
                    ? String.valueOf(lookupObj.get('Microfilm_volume_number__c'))
                    : String.valueOf(lookupObj.get('Volume__c'));
                    CopyRequestDetails copyDetailsWrapper=new CopyRequestDetails();

                    copyDetailsWrapper.Filing_Number=String.valueOf(lookupObj.get('Sdoc_Filing_Number__c'));
                    copyDetailsWrapper.Copy_Type=requestDetail.Copy_Type__c;
                    copyDetailsWrapper.No_Of_Copies=requestDetail.Number_of_Copies__c != null ? String.valueOf(requestDetail.Number_of_Copies__c) : '1';
                    copyDetailsWrapper.Volume_Type=volumeType;
                    copyDetailsWrapper.Volume=volume;
                    copyDetailsWrapper.Start_Page=String.valueOf(lookupObj.get('Start_Page__c'));
                    copyDetailsWrapper.Pages= requestDetail.Mark_Filing__c != null ? String.valueOf(lookupObj.get('Number_of_Pages__c')) : String.valueOf(lookupObj.get('Pages__c'));
                    copyList.add(copyDetailsWrapper);

        }

        return copyList;
    }
     public without sharing class FilingDateTimeformat {
        public String FilingDateTime;
    }
    public static List<FilingDateTimeformat> getFilingDateTimeformat(String recordId) {
        List<FilingDateTimeformat> FilingDateList = new List<FilingDateTimeformat>();
        String objName = SchemaUtility.getObjectFromId(recordId).getName();
        FilingDateTimeformat filingdatetimeInfo=new FilingDateTimeformat();
        for(Copy_Request_Details__c dateTimeValue : [
            Select id,Mark_Filing__c,Mark_Filing__r.Filing_Time__c,Mark_Filing__r.Filing_Date__c,
            Business_Filing__c,Business_Filing__r.Filing_Time__c, Business_Filing__r.Filing_Date__c 
            from Copy_Request_Details__c 
            where id =: recordId
                AND (Mark_Filing__c != null OR Business_Filing__c !=null) 
                WITH SECURITY_ENFORCED
        ]) {
            if(dateTimeValue.Mark_Filing__c != null){
                if(dateTimeValue.Mark_Filing__r.Filing_Time__c !=null)
                {
                    DateTime dt=DateTime.newInstance(dateTimeValue.Mark_Filing__r.Filing_Date__c.year(), dateTimeValue.Mark_Filing__r.Filing_Date__c.month(), dateTimeValue.Mark_Filing__r.Filing_Date__c.day(),dateTimeValue.Mark_Filing__r.Filing_Time__c.Hour(),dateTimeValue.Mark_Filing__r.Filing_Time__c.Minute(),dateTimeValue.Mark_Filing__r.Filing_Time__c.Second());
                    filingdatetimeInfo.FilingDateTime = dt.format('MM/dd/yyyy hh:mm a');  
                }
                else{
                    filingdatetimeInfo.FilingDateTime = dateTimeValue.Mark_Filing__r.Filing_Date__c.format();
                }              
            }else if(dateTimeValue.Business_Filing__c != null){
                 if(dateTimeValue.Business_Filing__r.Filing_Time__c !=null)
                {
                    DateTime dt=DateTime.newInstance(dateTimeValue.Business_Filing__r.Filing_Date__c.year(), dateTimeValue.Business_Filing__r.Filing_Date__c.month(), dateTimeValue.Business_Filing__r.Filing_Date__c.day(),dateTimeValue.Business_Filing__r.Filing_Time__c.Hour(),dateTimeValue.Business_Filing__r.Filing_Time__c.Minute(),dateTimeValue.Business_Filing__r.Filing_Time__c.Second());
                    filingdatetimeInfo.FilingDateTime = dt.format('MM/dd/yyyy hh:mm a');  
                }
                else{
                    filingdatetimeInfo.FilingDateTime = dateTimeValue.Business_Filing__r.Filing_Date__c.format();
                }               
            }
             FilingDateList.add(filingdatetimeInfo);
        }
        return FilingDateList;
    }
}