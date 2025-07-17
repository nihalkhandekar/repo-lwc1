/* DESCRIPTION: This class contains my filings history page 
*
* @AUTHOR:  Sarita Nayak
* @DATE:    03/19/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Sarita Nayak                    03/19/2021                           Created the first version
* Shreya						  7/12/21								BRS-7809 | Get Copy Requests on MyFilings dashboard 
*********************************************************************************************/
public without sharing class brs_myFilingsClass {
    public static Final String className = 'brs_myFilingsClass';
    public static final List<String> businessStatuses = getBusinessStatuses();  //added as part of 8390
    public static Set<String> finalRecIds = new Set<String>();  //added as part of 8390
    
    /********************************************************************************************
        METHOD NAME    : getAllData
        DESCRIPTION    : to Get all Filing Data created bythe LoggedIn User
        RETURN TYPE    : List of Json wrapper
        PARAMETER      : List of Json wrapper
        Author         : Sushri Sarita Nayak
        Date           : 19th-Mar-2021
    ********************************************************************************************/
	@AuraEnabled
    public static AllDataWrapper getAllData(String genericObj) {
        AllDataWrapper allDataWrapObj = new AllDataWrapper();
        allDataWrapObj.objList = new List<filingsinfoWrapper>();
        
        mainWrapper wrapInst = (mainWrapper) system.JSON.deserialize(genericObj, mainWrapper.class);
        User currentUser = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :wrapInst.UserId WITH SECURITY_ENFORCED
        ];
        
        if (wrapInst.filters != null && !wrapInst.filters.IsEmpty()) {
            for (filterWrapper filInst: wrapInst.filters) {
                if(!filInst.selectedOptions.IsEmpty()) {
                    //1. Biz
                    allDataWrapObj.objList.addAll(
                        filInst.searchType.startsWithIgnoreCase(System.label.Business_Dashboard_Label)
                            ? getBusinessFilingData(wrapInst.UserId, wrapInst.filters)
                            : new List<filingsinfoWrapper>()
                    );
                    //2. UCC
                    allDataWrapObj.objList.addAll(
                        filInst.searchType.startsWithIgnoreCase(System.label.Lien_Dashboard_Label)
                            ? getUCCFilingData(wrapInst.UserId, wrapInst.filters)
                            : new List<filingsinfoWrapper>()
                    );
                    //3. Certificates
                    allDataWrapObj.objList.addAll(
                        filInst.searchType.startsWithIgnoreCase(System.label.Certificate_Dashboard_Label)
                            ? getCertificateData(currentUser.ContactId, wrapInst.filters)
                            : new List<filingsinfoWrapper>()
                    );
                    //4. Copy Requests
                    allDataWrapObj.objList.addAll(
                        'Copy Requests Dashboard'.equalsIgnoreCase(filInst.searchType) ? getCopyRequests(currentUser.ContactId, new List<FilterWrapper> { filInst }) : new List<filingsinfoWrapper>()
                    );
                }
            }
        } else {
            allDataWrapObj.objList.addAll(getBusinessFilingData(wrapInst.UserId, wrapInst.filters));
            allDataWrapObj.objList.addAll(getUCCFilingData(wrapInst.UserId, wrapInst.filters));
            allDataWrapObj.objList.addAll(getCertificateData(currentUser.ContactId, wrapInst.filters));
            allDataWrapObj.objList.addAll(getCopyRequests(currentUser.ContactId, wrapInst.filters));
        }
        
        allDataWrapObj.Count = allDataWrapObj.objList.size();
        allDataWrapObj.resumeFlowURL = getResumeFlowURLS();

        return allDataWrapObj;
    }

    /********************************************************************************************
        METHOD NAME    : getBusinessFilingData
        DESCRIPTION    : to Get all the resume flow URLs 
        RETURN TYPE    : List of Resume_Flow_URLs metadata records
        PARAMETER      : List of Resume_Flow_URLs metadata records
        Author         : Sushri Sarita Nayak
        Date           : 5th-Apr-2021
    ********************************************************************************************/

    @AuraEnabled
    public static List<BRS_Resume_Flow_URLs__mdt> getResumeFlowURLS(){
    try{
        List<BRS_Resume_Flow_URLs__mdt> resumeURLList = new List<BRS_Resume_Flow_URLs__mdt>([Select Id,DeveloperName,MasterLabel,URL_For_Flow__c from BRS_Resume_Flow_URLs__mdt]);
        return resumeURLList;

    }catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, 'getResumeFlowURLS', '', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
    }

    }

    /********************************************************************************************
        METHOD NAME    : getBusinessFilingData
        DESCRIPTION    : to Get all Business Filing Data created bythe LoggedIn User
        RETURN TYPE    : List of Json wrapper
        PARAMETER      : List of Json wrapper
        Author         : Sushri Sarita Nayak
        Date           : 19th-Mar-2021
    ********************************************************************************************/

    @AuraEnabled
    public static List<filingsinfoWrapper> getBusinessFilingData(String UserId, List<filterWrapper> busfilters){
    try{
        List<String> filingFilterOptions = new List<String>();
        List<String> statusFilterOptions = new List<String>();
        List<Business_Filing__c> businessFilingList = new List<Business_Filing__c>();
        String online_Label = System.label.Online_Label;
        List<String> sourceList = new List<String>{online_Label,'Digital Mail'};
        if(busfilters != null)
            {
            for(filterWrapper filter : busfilters)
            {
                if(filter.type == System.label.BusinessFiling_Label && !filter.selectedOptions.IsEmpty())
                {   
                    filingFilterOptions = filter.selectedOptions;
                }
                else if(filter.type == System.label.BusinessStatus_Label && !filter.selectedOptions.IsEmpty())
                {
                    statusFilterOptions = filter.selectedOptions;
                }
            }
        }
        Set<Id> accountConcIds = new Set<Id>();
        List<AccountContactRelation> acrRecList =BRS_Utility.getAccContactList();
        if(!acrRecList.isEmpty()){
            for(AccountContactRelation acrRecObj : acrRecList){
                accountConcIds.add(acrRecObj.AccountId);
            }
        }
        String queryString = 'Select Id,Filing_Type__c,Sdoc_Filing_Number__c,Account__r.Name,Name,Reserved_Name__c,Source__c,Status__c,CreatedDate,Type__c,Is_Rejected_Instantiated__c,Filing_Date__c,work_order__r.Name from Business_Filing__c where (CreatedById =:UserId OR OwnerId =: UserId) ';
        String whereclause = '';
        if(!filingFilterOptions.Isempty() && statusFilterOptions.Isempty()){
                         whereclause = 'and Type__c IN: filingFilterOptions and Status__c IN : businessStatuses and Source__c in:sourceList';
        }
        else if(filingFilterOptions.Isempty()  && !statusFilterOptions.Isempty()){ 
                        whereclause = 'and Status__c IN: statusFilterOptions and Source__c in:sourceList';
        }
        else if(!filingFilterOptions.Isempty() && !statusFilterOptions.Isempty()){
                         whereclause = 'and Status__c IN: statusFilterOptions and Type__c IN: filingFilterOptions and Source__c in:sourceList';
        }
        else{
            whereclause = 'and Status__c IN : businessStatuses and Source__c in:sourceList';
        }
        whereclause=whereclause +' WITH SECURITY_ENFORCED';
        queryString = queryString + whereclause;
        businessFilingList = database.query(queryString);
        List<filingsinfoWrapper> wrapAllDataList = new List<filingsinfoWrapper>();
        for(Business_Filing__c businessFilingInst : businessFilingList){
            //start - added as part of 8390
                if(finalRecIds.contains(businessFilingInst.Id))
                    continue;
                finalRecIds.add(businessFilingInst.Id);
            //end - added as part of 8390
            filingsinfoWrapper wrapInst = new filingsinfoWrapper();
            wrapInst.recId = businessFilingInst.Id;
            if(businessFilingInst.work_order__r.Name != null){
                wrapInst.workOrderNum = 'WO#' +' '+businessFilingInst.work_order__r.Name;
            }
            if(businessFilingInst.Type__c == System.label.BRS_Name_Reservation_Flow){
                                 wrapInst.filingName = businessFilingInst.Reserved_Name__c;
            }
            else{
                if(businessFilingInst.Source__c=='Digital Mail' && businessFilingInst.Account__c==null){
                                      wrapInst.filingName = businessFilingInst.Name.replace('BF-','T-');
                }
                else{
                    wrapInst.filingName = businessFilingInst.Account__r.Name;
                }
            }
            wrapInst.isDeleteable =false;
            wrapInst.createdDate = businessFilingInst.CreatedDate.format().replaceAll(',','');
            wrapInst.filingNumber = businessFilingInst.Sdoc_Filing_Number__c;
            wrapInst.filingOrCertType = businessFilingInst.Type__c;
            wrapInst.Status = businessFilingInst.Status__c;
            wrapInst.FilingType = System.label.Business_Label;
            if(businessFilingInst.Status__c != null){
                if(businessFilingInst.Status__c == System.label.BRS_UCC_StatusInProgress && businessFilingInst.Type__c != 'Annual Report' && businessFilingInst.Type__c != 'First Report'){
                        wrapInst.isDeleteable =true;
                    
                }
            
                    if(businessFilingInst.Status__c == System.label.BRS_UCC_StatusInProgress && businessFilingInst.Type__c!=System.label.BRS_Name_Reservation_Flow && businessFilingInst.Source__c != 'Digital Mail'){
                              wrapInst.isContinueFiling = true;

                }
                else if(businessFilingInst.Status__c == System.label.Approved){
                    wrapInst.isAcceptanceNotice = true;
                    wrapInst.isviewFiling = true;
                    if(businessFilingInst.Filing_Date__c != null){ 
                        wrapInst.filingDate = businessFilingInst.Filing_Date__c.format();
                    }
                }
                else if(businessFilingInst.Status__c == System.label.BRS_FilingStatus_Rejected){
                    wrapInst.isRejectionNotice = true;
                    if(!businessFilingInst.Is_Rejected_Instantiated__c){
                        wrapInst.isResubmit = true;
                    }
                    else{
                        wrapInst.isResubmit = false; 
                    }
                    if(businessFilingInst.Source__c=='Digital Mail'){
                                                 wrapInst.isResubmit = false; 
                    } 
                }
            }
            wrapInst.FilingTypeSdocs = businessFilingInst.Filing_Type__c;
            wrapAllDataList.add(wrapInst);
        }
        return wrapAllDataList;
    }catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, 'getBusinessFilingData', '', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
    } 
    }

    /********************************************************************************************
            METHOD NAME    : getBusinessStatuses
            DESCRIPTION    : to Get getBusinessStatuses
            RETURN TYPE    : List<String>
            PARAMETER      : NA
            Author         : Mousumi
            Date           : 04-01-2022
********************************************************************************************/     
         //start - added as part of 8390
        public static List<String> getBusinessStatuses(){
                   
       	List<String> businessStatusList = new List<String>();
        
        for (BRS_online_enquiry_Filters__mdt type: [
            SELECT id, DeveloperName, Search_Type__c, MasterLabel, API_Name__c, Filter_Icon__c, data_type__c, IsActive__c, Order__c, 
                (
                    SELECT Id, DeveloperName, BRS_Online_Enquiry_Filter_option__r.DeveloperName, MasterLabel, IsActive__c, Picklist_API_Name__c, Order__c 
                    FROM BRS_Online_Enquiry_Filter_Options__r
                ) 
            FROM BRS_online_enquiry_Filters__mdt 
            WHERE Search_Type__c LIKE 'Business Dashboard Status' 
            ORDER BY Order__c
        ]) {
           
            
            for (BRS_Online_Enquiry_Filter_Options__mdt typeOption: type.BRS_Online_Enquiry_Filter_Options__r) {
                if (typeOption.BRS_Online_Enquiry_Filter_option__r.DeveloperName == 'Business_Status_Dashboard') {
                    businessStatusList.add(typeOption.Picklist_API_Name__c);
                }
            }
        }
            return businessStatusList;
        }
        //end - added as part of 8390
    /********************************************************************************************
        METHOD NAME    : getUCCFilingData
        DESCRIPTION    : to Get all UCC Filing Data created bythe LoggedIn User
        RETURN TYPE    : List of Json wrapper
        PARAMETER      : List of Json wrapper
        Author         : Sushri Sarita Nayak
        Date           : 19th-Mar-2021
    ********************************************************************************************/
    @AuraEnabled
    public static List<filingsinfoWrapper> getUCCFilingData(String UserId, List<filterWrapper> uccFilters){
    try{
        List<String> filingFilterOptions = new List<String>();
        List<String> statusFilterOptions = new List<String>();
        List<UCC_Filing__c> UCCFilingList = new List<UCC_Filing__c>();
        String online_Label = System.label.Online_Label;
        String Label_Submitter = System.label.Label_Submitter_BE;
        if(uccFilters != null)
            {
            for(filterWrapper filter : uccFilters)
            {
                if(filter.type == System.label.lien_type && !filter.selectedOptions.Isempty())
                {
                    filingFilterOptions = filter.selectedOptions;
                }
                else if(filter.type == System.label.Lien_Status_Label && !filter.selectedOptions.Isempty())
                {
                    statusFilterOptions = filter.selectedOptions;
                }
            }
        }
        String queryString = 'Select Id,Name,Amendment_Type__c,UCC_Lien_Type__c,Sdoc_Filing_Number__c,CreatedDate,Filing_Source__c,Is_Rejected_Instantiated__c,Type__c,Filing_Number__c,Status__c,UCC_Lien_Id__r.Type__c,Filing_Date__c,work_order__r.Name,(Select Id,Name__c,Type__c from UCC_Related_Info__r where Type__c=: Label_Submitter) from UCC_Filing__c where CreatedById =:UserId ';
        String whereclause = '';
        if(!filingFilterOptions.Isempty() && statusFilterOptions.Isempty()){
                         whereclause = ' and Type__c IN: filingFilterOptions and Filing_Source__c=: online_Label';
        }
        else if(filingFilterOptions.Isempty() && !statusFilterOptions.Isempty()){
                         whereclause = ' and Status__c IN: statusFilterOptions and Filing_Source__c=: online_Label';
        }
        else if(!filingFilterOptions.Isempty() && !statusFilterOptions.Isempty()){
                         whereclause = 'and Status__c IN: statusFilterOptions and Type__c IN: filingFilterOptions and Filing_Source__c=: online_Label';
        }
        else {
            whereclause = 'and Filing_Source__c=: online_Label';
        }
        whereclause=whereclause +' WITH SECURITY_ENFORCED';
        queryString = queryString+ whereclause;
        UCCFilingList = database.query(queryString);
        List<filingsinfoWrapper> wrapAllDataList = new List<filingsinfoWrapper>();
        for(UCC_Filing__c uccFilingInst : UCCFilingList){
            filingsinfoWrapper wrapInst = new filingsinfoWrapper();
            wrapInst.recId = uccFilingInst.Id;
            if(uccFilingInst.work_order__r.Name != null){
                wrapInst.workOrderNum = 'WO#' + ' '+ uccFilingInst.work_order__r.Name;
            }
            wrapInst.isDeleteable =false;
            wrapInst.filingName = uccFilingInst.Filing_Number__c;
            wrapInst.createdDate = uccFilingInst.CreatedDate.format().replaceAll(',','');
            if(uccFilingInst.Type__c == System.label.OFS_Label_Dashboard){
                wrapInst.filingOrCertType = System.label.OriginalfinancingstatementText;
            }
            else{
                wrapInst.filingOrCertType = uccFilingInst.Type__c;
            }
            wrapInst.Status = uccFilingInst.Status__c;
            wrapInst.FilingType = System.label.UCC_Label;
            if(uccFilingInst.Type__c == System.label.OFS_Label_Dashboard){
                wrapInst.LienType = System.label.OriginalfinancingstatementText;
            }
            else{
                wrapInst.LienType = uccFilingInst.UCC_Lien_Id__r.Type__c;
            }
            
            if(uccFilingInst.Status__c == System.label.BRS_UCC_StatusInProgress){
                wrapInst.isContinueFiling = true;
   wrapInst.isDeleteable =true;
    
            }
            else if(uccFilingInst.Status__c == System.label.Approved){
                wrapInst.isAcceptanceNotice = true;
                wrapInst.isviewFiling = true;
                wrapInst.filingNumber = uccFilingInst.Sdoc_Filing_Number__c;
                if(uccFilingInst.Filing_Date__c != null){
                    Date filingTempDt = Date.valueOf(uccFilingInst.Filing_Date__c);
                    wrapInst.filingDate = filingTempDt.format();
                } 
            }
            else if(uccFilingInst.Status__c == System.label.BRS_FilingStatus_Rejected){
                wrapInst.isRejectionNotice = true;
                if(!uccFilingInst.Is_Rejected_Instantiated__c){
                    wrapInst.isResubmit = true;
                }
                else{
                    wrapInst.isResubmit = false; 
                }
            }
            else if(uccFilingInst.Status__c == System.label.BRS_FilingStatus_Pending){
                wrapInst.isviewFiling = true;
            }
            if(uccFilingInst.type__c == System.label.brs_InfoStatement ){
                                 wrapInst.FilingTypeSdocs = uccFilingInst.type__c;
            }
            else {
                wrapInst.FilingTypeSdocs = uccFilingInst.Amendment_Type__c != null ?uccFilingInst.Amendment_Type__c:uccFilingInst.UCC_Lien_Type__c;
            }
            wrapAllDataList.add(wrapInst);
        }
        return wrapAllDataList; 
    }catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, 'getUCCFilingData', '', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
    }     
    }
    /********************************************************************************************
        METHOD NAME    : getCertificateData
        DESCRIPTION    : to Get all Cetificate created bythe LoggedIn User
        RETURN TYPE    : List of Json wrapper
        PARAMETER      : List of Json wrapper
        Author         : Sushri Sarita Nayak
        Date           : 22nd-Mar-2021
    ********************************************************************************************/
	@AuraEnabled
    public static List<filingsinfoWrapper> getCertificateData(String contactId, List<filterWrapper> filters) {
        List<String> certFilterOptions = new List<String>();
        List<filingsinfoWrapper> wrapAllDataList = new List<filingsinfoWrapper>();
        
        if(filters != null) {
            for (filterWrapper filter: filters) {
                if (filter.type == System.label.Certificate_Type_Label && !filter.selectedOptions.IsEmpty()) {
                    certFilterOptions = filter.selectedOptions;
                }
            }
        }
    
        for (Certficate__c otherRequest : (List<Certficate__c>)Database.query(
            'SELECT Id,RecordType.developername,Name,Certificate_Type__c,Business__r.Name,CreatedDate,work_order__c, work_order__r.Name,Debtor_Full_Name__c,status__c'
            + ' FROM Certficate__c'
            + ' WHERE Work_Order__r.Customer__c = \'' + contactId + '\''
            + ' AND Status__c IN (\'Approved\', \'Rejected\')'
            + (!certFilterOptions.IsEmpty() ? ' AND Certificate_Type__c IN: certFilterOptions' : '')
			+ ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC'
        )) {
                         wrapAllDataList.add(new filingsinfoWrapper(otherRequest));
        }

        return wrapAllDataList;
    }

    /**
     * @desc: BRS-7809 | Get copy requests for my filings dashboard
     * 1. copy requests createdByid = userid & copydetails.otherrequest.workorder.customerid = userid
     * 2. If biz => show account name.
     * If mark => filing no
     * if ucc => filing no
     * 3. only approved/rejected copy requests
     */
    private static List<FilingsinfoWrapper> getCopyRequests(String contactId, List<FilterWrapper> filters) {
        List<FilingsinfoWrapper> listFilings = new List<FilingsinfoWrapper>();
        List<String> certFilterOptions = new List<String>();
        
        if(filters != null) {
            for (filterWrapper filter: filters) {
                if(!filter.selectedOptions.IsEmpty() && 'Copy Requests Dashboard'.equalsIgnoreCase(filter.searchType)) {
                    certFilterOptions = filter.selectedOptions;
                }
            }
        }

        for(Copy_Request_Details__c copyRequest : (List<Copy_Request_Details__c>) Database.query(
            'SELECT Id, Name, Copy_Type__c, CreatedDate, Other_Request__r.Status__c, Other_Request__r.Name, Other_Request__r.Work_Order__r.Name,'
            + ' Business_Filing__r.Account__r.Name, UCC_Filing__r.Name, Mark_Filing__r.Name'
            + ' FROM Copy_Request_Details__c'
            + ' WHERE Other_Request__r.Work_Order__r.Customer__c = \'' + contactId + '\''
            + ' AND Other_Request__r.Status__c IN (\'Approved\', \'Rejected\')'
            + (!certFilterOptions.IsEmpty() ? ' AND Copy_Type__c IN :certFilterOptions' : '')
            + ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC'
        )) {
                         listFilings.add(new FilingsInfoWrapper(copyRequest));
        }

        return listFilings;
    }

    /********************************************************************************************
        METHOD NAME    : getDocuments
        DESCRIPTION    : to Get all the documents generated by Sdocs for different Filing Statuses
        RETURN TYPE    : String
        PARAMETER      : String
        Author         : Sushri Sarita Nayak
        Date           : 22nd-Mar-2021
    
        @update: BRS-7809 | Shreya | Get copy requests
        @usage: my filings dashboard
    ********************************************************************************************/
    @AuraEnabled
    public static allDocumentInfo getDocuments(Id recId, String FilingType) {
        String documentName = '';
        String obj = SchemaUtility.getObjectFROMId(recId).getName();
        sObject record = Database.query('SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
            + ' FROM ' + obj
            + ' WHERE Id = :recId WITH SECURITY_ENFORCED');

        if (System.label.brs_viewFiling.equalsIgnoreCase(filingType) || System.label.CertificatesStage.equalsIgnoreCase(FilingType) || 'Copy Type'.equalsIgnoreCase(filingType) ) { //1. filing output
            documentName = UCCFileMerge.getFilingOutputName(record) + '%';
        } else if (System.label.brs_ApprovalEmailMessage.equalsIgnoreCase(filingType)) { //2. Acceptance notice
            documentName = System.label.Acceptance_N_Comparable;
        } else if (System.label.brs_RejectionNotice.equalsIgnoreCase(filingType)) { //3. Rejection Notice
            documentName = System.label.Rejection_N_Comparable;
        }

        //for BO filing record sharing
        if(obj=='Copy_Request_Details__c'){
            Id certificateRec = String.valueOf(record.get('Other_Request__c'));
            List<Certficate__c> cerList =[Select id,ownerId from Certficate__c where id =:certificateRec WITH SECURITY_ENFORCED Limit 1];
            if(UserInfo.getUserId() != cerList[0].ownerId){
                cerList[0].ownerId = UserInfo.getUserId();
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(cerList, 'update');
                update cerList;
            }
        }
        else if(UserInfo.getUserId() != record.get('OwnerId')) {
            record.put('OwnerId', UserInfo.getUserId());
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {record}, 'update');
            update record;
        }

        allDocumentInfo allDocInst = new allDocumentInfo();
        
        List<ContentDocumentLink> listFilingOutput = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recId
                AND ContentDocument.Title LIKE :documentName WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!listFilingOutput.IsEmpty()) {
            allDocInst.documentId = listFilingOutput.get(0).ContentDocumentId;
            allDocInst.AttachDocStr = System.label.Content_Label;
        } else {
            List<Attachment> listFilingOutputA = [
                SELECT Id 
                FROM Attachment 
                WHERE Name LIKE :documentName 
                    AND ParentId = :recId WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (!listFilingOutputA.IsEmpty()) {
                allDocInst.documentId = listFilingOutputA.get(0).Id;
                allDocInst.AttachDocStr = System.label.Attachment;
            }
        }

        return allDocInst;
    }
    
    
    public class filterWrapper{
        @AuraEnabled public String type {get;set;} 
        @AuraEnabled public List<String> selectedOptions{get;set;}
        @AuraEnabled public String searchType {get;set;} 
    }

    public class mainWrapper{
        @AuraEnabled public String UserId {get;set;} 
        @AuraEnabled public List<filterWrapper> filters{get;set;}
        
    }

    public class filingsinfoWrapper{
        @AuraEnabled public String recId {get;set;}
        @AuraEnabled public String workOrderNum {get;set;}
        @AuraEnabled public String filingName {get;set;}
        @AuraEnabled public String createdDate {get;set;}
        @AuraEnabled public string filingOrCertType {get;set;}
        @AuraEnabled public string Status {get;set;}
        @AuraEnabled public string certNum{get;set;}
        @AuraEnabled public string FilingType{get;set;}
        @AuraEnabled public string LienType{get;set;}
        @AuraEnabled public String filingDate {get;set;}
        @AuraEnabled public boolean isContinueFiling {get;set;}
        @AuraEnabled public boolean isAcceptanceNotice {get;set;}
        @AuraEnabled public boolean isRejectionNotice {get;set;}
        @AuraEnabled public boolean isviewFiling {get;set;}
        @AuraEnabled public boolean isViewCertificate {get;set;}
        @AuraEnabled public boolean isViewReport {get;set;}
        @AuraEnabled public boolean isResubmit{get;set;}
        @AuraEnabled public String filingNumber {get;set;}
        @AuraEnabled public String FilingTypeSdocs {get;set;}
        @AuraEnabled public boolean isDeleteable{get;set;}

		public FilingsinfoWrapper() {}

        //3. Other Request
        public FilingsInfoWrapper(Certficate__c otherRequest) {
            this.recId = otherRequest.Id;
            this.isDeleteable = false;
            this.workOrderNum = otherRequest.work_order__c != null ? 'WO# ' + otherRequest.work_order__r.Name : '';
            if(otherRequest.CreatedDate!=null){
                this.createdDate = otherRequest.CreatedDate.format().replaceAll(',', '');
            }
            this.certNum = otherRequest.Name;
            this.FilingType = System.label.Certificate_Label;
            this.Status = otherRequest.status__c;

            //i. for RFI, get AN/RN & filing output
            if(System.Label.Request_for_Information_RecordTypeAPI.equalsIgnoreCase(otherRequest.RecordType.developername)) {
                this.isAcceptanceNotice = System.Label.Approved.equalsIgnoreCase(otherRequest.Status__c);
                this.isRejectionNotice = System.Label.Rejected.equalsIgnoreCase(otherRequest.Status__c);
                
                this.filingOrCertType = system.Label.Request_for_Information;
                this.filingName = otherRequest.Debtor_Full_Name__c;
            } 
            //for cert of legal existence, show only filing output
            else {
                this.isViewCertificate = true;
                this.filingOrCertType = otherRequest.Certificate_Type__c;
                this.filingName = otherRequest.Name;
            }
        }

        //4. copy request
        public FilingsInfoWrapper(Copy_Request_Details__c copyRequest) {
            this.isDeleteable = false;
            this.recId = copyRequest.Id;
            if(copyRequest.CreatedDate!=null){
                this.createdDate = copyRequest.CreatedDate.format().replaceAll(',', '');
            }
            this.certNum = copyRequest.Name;
            this.filingOrCertType = copyRequest.Copy_Type__c;
            this.Status = copyRequest.Other_Request__r.Status__c;
            this.workOrderNum = copyRequest.Other_Request__r.Work_Order__r != null ? 'WO# ' + copyRequest.Other_Request__r.Work_Order__r.Name : '';
            //if certified + approved = show filing output
            this.isViewCertificate = System.Label.Approved.equalsIgnoreCase(copyRequest.Other_Request__r.Status__c) && System.Label.Certified.equalsIgnoreCase(copyRequest.Copy_Type__c);
            
            //copy request type
            if(copyRequest.UCC_Filing__r != null) {
                                              this.filingName = copyRequest.UCC_Filing__r.Name; //ucc = filingno 
            } else if(copyRequest.Business_Filing__r != null) {
                                  this.filingName = copyRequest.Business_Filing__r.Account__r.Name; //biz = account name
            } else if(copyRequest.Mark_Filing__r != null) {
                                      this.filingName = copyRequest.Mark_Filing__r.Name; //mark = filingno
            }
        }
    }
    
    public class AllDataWrapper{
        @AuraEnabled public Integer Count{get;set;}
        @AuraEnabled public List<filingsinfoWrapper> objList{get;set;}
        @AuraEnabled public List<BRS_Resume_Flow_URLs__mdt> resumeFlowURL{get;set;}
    }
    
    public class allDocumentInfo{
        @AuraEnabled public String documentId{get;set;}
        @AuraEnabled public String AttachDocStr{get;set;}
        @AuraEnabled public String publicLink{get;set;}

    }
    @AuraEnabled
    public static string deleteFiling(String recordId){
try{
User userdata = BOS_Utility.getLoggedinUserDetail();
    List<SObject> objectToDelete = new List<SObject>();
    if(String.isNotBlank(recordId))
    {
    if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.BRS_UCCFilingObject){
   
            UCC_Filing__c filing = [Select id,RecordTypeId,UCC_Lien_Id__c,Status__c from UCC_Filing__c where id = :recordId WITH SECURITY_ENFORCED Limit 1];
            if(filing.Status__c == 'Approved' || filing.Status__c == 'Submitted - Agency review pending'){
                                return System.label.MyFilingsApproveMessage;
            }
List<UCC_Related_Info__c>  allcontacts = [Select id from UCC_Related_Info__c where Filing_Id__c =:filing.id WITH SECURITY_ENFORCED];
if(allcontacts!=null && !allcontacts.isEmpty()){
    objectToDelete.addAll(allcontacts);
}
ID storeRecordTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();
if(filing.RecordTypeId == storeRecordTypeId)       
{
 UCC_Lien__c uccLien = new UCC_Lien__c();
 uccLien.id = filing.UCC_Lien_Id__c;
 objectToDelete.add(uccLien);
}
 
        
   objectToDelete.add(filing);




    }else if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.Business_Filing_API_Name){
  Business_Filing__c filing = [Select id,Type__c,Account__c,Status__c from Business_Filing__c where id = :recordId WITH SECURITY_ENFORCED Limit 1];
        if(filing.Status__c == 'Approved' || filing.Status__c == 'Submitted - Agent acceptance pending' || filing.Status__c == 'Submitted - Agency review pending'){
            return System.label.MyFilingsApproveMessage;
        }
  if(filing!=null && filing.Account__c !=null){

    if(filing.Type__c == 'Business Formation' || filing.Type__c == 'Business Registration'){
List<Agent__c> agents = [Select id from Agent__c where Agent_Account_ID__c = :filing.Account__c WITH SECURITY_ENFORCED];
If(agents!=null && !agents.isEmpty())
{
objectToDelete.addAll(agents);
}
    }
    if(filing.Type__c == 'Business Formation' || filing.Type__c == 'Business Registration'){
        List<Principal__c> principals = [Select id from Principal__c where Principal_Account_ID__c = :filing.Account__c OR Business_ID__c = :filing.Account__c WITH SECURITY_ENFORCED];
        If(principals!=null && !principals.isEmpty())
        {
        objectToDelete.addAll(principals);
        }
            }

 if(filing.Type__c == 'Business Formation' || filing.Type__c == 'Business Registration'){
                List<Contact> allcontacts = [Select id from Contact where AccountId = :filing.Account__c and ID != :userdata.ContactID WITH SECURITY_ENFORCED];
                If(allcontacts!=null && !allcontacts.isEmpty())
                {
                objectToDelete.addAll(allcontacts);
                }
                    }

                    if(filing.Type__c == 'Business Formation' || filing.Type__c == 'Business Registration'){
                        List<Stock_Classification__c> stocks = [Select id from Stock_Classification__c where AccountId__c = :filing.Account__c WITH SECURITY_ENFORCED];
                        If(stocks!=null && !stocks.isEmpty())
                        {
                        objectToDelete.addAll(stocks);
                        }
                            }

  }
if(String.isNotBlank(filing.Account__c) &&  (filing.Type__c == 'Business Formation' || filing.Type__c == 'Business Registration'
|| filing.Type__c == 'Business Name Reservation' || filing.Type__c == 'Registration of Name')){
  Account acc = new Account();
  acc.id = filing.Account__c;
  objectToDelete.add(acc);
}
  objectToDelete.add(filing);
  
  
    }else if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.Other_Request_API_Name){
   
        Certficate__c cert = [Select id from Certficate__c where id = :recordId WITH SECURITY_ENFORCED];

        objectToDelete.add(cert);
   
    }else if(SchemaUtility.getObjectFromId(recordId).getName() == 'Temp_History__c'){
   
        Temp_History__c temphistory = [Select id from Temp_History__c where id = :recordId WITH SECURITY_ENFORCED];

        objectToDelete.add(temphistory);
   
    }

}

if(!objectToDelete.isEmpty()){   
    delete objectToDelete;
}
return 'success';
}catch(Exception e){
 BOS_Utility.ExceptionHandler(className,'DeleteFilings',null,null,BOS_Utility.sSeverity,e,null);
 throw new AuraHandledException(e.getMessage());
}
}
}