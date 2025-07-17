public without sharing class brs_TradeAndServiceSearchCntrlBusCls {
	public static Final String className = 'brs_TradeAndServiceSearchController';
    public static Final String getMarkSearchList = 'getMarkSearchList';
    public static Final String getSelectedTradeAndServiceMarkDetails = 'getSelectedTradeAndServiceMarkDetails';
    public static Final String retFormattedDate = 'retFormattedDate';
    public static Final String retAssociatedAttachments = 'retAssociatedAttachments';
    
    public class results {
        @AuraEnabled public Integer resultCount {get; set;}
        @AuraEnabled public Integer resultAllCount {get; set;}
        @AuraEnabled public Set<searchData> resultList {get; set;}
        @AuraEnabled public List<BRS_Utility.ColumnsWrapper> tableColumns {get; set;}
    }
    public class searchData {
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String registrationNumber {get; set;}
        @AuraEnabled
        public String ownerName {get; set;}
        @AuraEnabled
        public String ownerAddStreet {get; set;}
        @AuraEnabled
        public String ownerAddUnit {get; set;}
        @AuraEnabled
        public String ownerAddCity {get; set;}
        @AuraEnabled
        public String ownerAddState {get; set;}
        @AuraEnabled
        public String ownerAddCountry {get; set;}
        @AuraEnabled
        public String ownerAddZipCode {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String registrationDateFormatted {get; set;}
        @AuraEnabled
        public String renewalDateFormatted {get; set;}
        @AuraEnabled
        public String descOfMark {get; set;}
        @AuraEnabled
        public String markType {get; set;}
        //@AuraEnabled
        private Date renewalDate {get; set;}
        @AuraEnabled
        public Date registrationDate {get; set;}
        @AuraEnabled
        public String clsOfGoodsAndServices {get; set;}
        @AuraEnabled
        public String datefFirstUseInCT {get; set;}
        @AuraEnabled
        public String datefFirstUseInAnywhere {get; set;}
        @AuraEnabled
        public String expirationDate {get; set;}
        @AuraEnabled
        public String firstexpirationDate {get; set;}
        @AuraEnabled
        public String disclaimer {get; set;}
        @AuraEnabled
        public String keyWords {get; set;}
        @AuraEnabled
        public String markUsedFor {get; set;}
        @AuraEnabled
        public String methodOfUse {get; set;}
        @AuraEnabled
        public String ownerType {get; set;}
        @AuraEnabled
        public String stateCountryOfFormation {get; set;}
        @AuraEnabled
        public String partnerNames {get; set;}
        @AuraEnabled public List<searchDataMarkFilings> markHistory {get; set;}
        @AuraEnabled public List<searchDataMarkFilings> filingHistory {get; set;}
        
    }
    public class searchDataMarkFilings {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String filingNumber {get; set;}
        @AuraEnabled
        public String filingType {get; set;}
        @AuraEnabled
        public String filingDate {get; set;}
        @AuraEnabled
        public Integer volume {get; set;}
        @AuraEnabled
        public Integer startPage {get; set;}
        @AuraEnabled
        public Integer noOfPages {get; set;}
        @AuraEnabled
        public String markImage {get; set;}
        @AuraEnabled
        public String digitalCopy {get; set;}
    }
    public static results getMarkSearchLists(String searchString, List<brs_genericSearchBusinessClass.filterWrapper> filterList, Boolean isExportClicked) {
        try {
            BRS_online_enquiry__mdt onlineEnquiry = new BRS_online_enquiry__mdt();
            results returnObj = new results();
            List<Mark__c> markPAListGetAllMatchedCount = new List<Mark__c>();
            List<BRS_Utility.ColumnsWrapper> columnWrapperList = new List<BRS_Utility.ColumnsWrapper>();
            Set<searchData> brsBusDtList = new Set<searchData>();
            Set<String> markIdSet = new Set<String>();
            Map<String,String>  labelMaps = new Map<String,String>();
            labelMaps = getTranslatedMap(); 
            if (!String.isBlank(searchString)) {
                String markDataQuery;
                String whereClause;
                String filterWhereClause = '';
                Set<String> statusFilter = new Set<String>(System.Label.Marks_Statuses.split(System.Label.PIPELINE_SEPARATOR));
                onlineEnquiry = [Select Search_Object__c, Search_Limit__c, Include_Filters__c, Inner_Query_Limit__c, Download_Limit__c, Search_Object_fields__c, DeveloperName from BRS_online_enquiry__mdt where DeveloperName = : System.Label.Mark_Online_Enquiry_Developer_Name limit 1];
                Integer queryLimit = (integer)(isExportClicked ?  onlineEnquiry.Download_Limit__c : onlineEnquiry.Search_Limit__c);
                String originalSearchTerm = searchString.toLowerCase();
                originalSearchTerm=originalSearchTerm.replace(' ',',');
                List<String> lstSearchString = originalSearchTerm.split(',');
                searchString = removeReservedKeyWords(searchString);
                searchString=searchString.replace(' ','* OR *');
                String searchQuery = 'FIND \'*' + searchString + '*\' IN ALL FIELDS returning ';
                searchQuery = searchQuery + ' Mark__c (Id, Description_of_Mark__c, Keywords__c,Owner_Name__c,Registration_number__c) ' ;
                searchQuery = whereClause != null ?  searchQuery + whereClause :  searchQuery;
                List<List<sObject>> searchMarkObj = search.query(searchQuery);
                List<Mark__c> markList = New List<Mark__c>();
                markList = ((List<Mark__c>)searchMarkObj[0]);
                if (!markList.isEmpty()) {
                    for (Mark__c mObj : markList) {
                        for(String str : lstSearchString )
                        {
                            if ((mObj.Registration_number__c != NULL && mObj.Registration_number__c.toLowerCase().contains(str)) || (mObj.Owner_Name__c!= NULL && mObj.Owner_Name__c.toLowerCase().contains(str)) || (mObj.Keywords__c!= NULL && mObj.Keywords__c.toLowerCase().Contains(str)) || (mObj.Description_of_Mark__c != NULL && mObj.Description_of_Mark__c.toLowerCase().Contains(str))) {
                                if(!markIdSet.contains(mObj.Id)){
                                     markIdSet.add(mObj.Id);
                                }
                            }
                        }
                    }
                }

                markDataQuery = 'SELECT Id, Owner_Name__c, Owner_Street_Address__c, Owner_Unit__c, Owner_City__c, Owner_State__c, Owner_Country__c, Owner_Zip_Code__c, Registration_number__c, Status__c, Registration_Date__c, Description_of_Mark__c, Mark_Type__c, Renewal_Date__c FROM Mark__c WHERE Id IN : markIdSet AND Status__c IN : statusFilter';

                List<String> busStatusOptions = new List<String>();
                if (!filterList.isEmpty()) {
                    for (brs_genericSearchBusinessClass.filterWrapper filObj : filterList) {
                        busStatusOptions = filObj.selectedOptions;
                        filterWhereClause = filterWhereClause + '  AND Mark_Type__c in:busStatusOptions ';
                    }
                    filterWhereClause = filterWhereClause + ' WITH SECURITY_ENFORCED';
                    markDataQuery = markDataQuery + filterWhereClause;
                }
                markPAListGetAllMatchedCount = Database.query(markDataQuery);
                markDataQuery += ' LIMIT :queryLimit';
                List<Mark__c> markPAList = Database.query(markDataQuery);
                
                Map<Id, Mark__c> markPAMap = new Map<Id, Mark__c>();
                if (!markPAList.isEmpty()) {
                    for (Mark__c mObj : markPAList) {
                        if (!markPAMap.containsKey(mObj.Id)) {
                            markPAMap.put(mObj.Id, mObj);
                        }
                    }
                }
                for (Id mId : markPAMap.keySet()) {
                    searchData markResultObj = new searchData();
                    Mark__c mObj = markPAMap.get(mId);
                    markResultObj.recordId = mObj.Id;
                    markResultObj.registrationNumber = mObj.Registration_Number__c;
                    markResultObj.markType = mObj.Mark_Type__c;
                    markResultObj.ownerName = mObj.Owner_Name__c;
                    markResultObj.ownerAddStreet = mObj.Owner_Street_Address__c;
                    markResultObj.ownerAddUnit = mObj.Owner_Unit__c;
                    markResultObj.ownerAddCity = mObj.Owner_City__c;
                    markResultObj.ownerAddState = mObj.Owner_State__c;
                    markResultObj.ownerAddCountry = mObj.Owner_Country__c;
                    markResultObj.ownerAddZipCode = mObj.Owner_Zip_Code__c;
                    markResultObj.registrationDateFormatted = retFormattedDate(mObj.Registration_Date__c);
                    markResultObj.descOfMark = mObj.Description_of_Mark__c;
                    markResultObj.status = labelMaps.containsKey(mObj.Status__c) ? labelMaps.get(mObj.Status__c) : mObj.Status__c;
                    if (isExportClicked) {
                        markResultObj.registrationDate = mObj.Registration_Date__c;
                        markResultObj.renewalDate = mObj.Renewal_Date__c;
                    }
                    brsBusDtList.add(markResultObj);
                }
            }
            if (isExportClicked) {
                for (BRS_Trade_Marks_Columns__mdt otradeColumns : [select Id, MasterLabel, DeveloperName, Order__c from BRS_Trade_Marks_Columns__mdt Order By Order__c limit 100]) {
                    BRS_Utility.ColumnsWrapper column = new BRS_Utility.ColumnsWrapper();
                    column.fieldName = otradeColumns.DeveloperName;
                    column.label = otradeColumns.MasterLabel;
                    columnWrapperList.add(column);
                }
            }
            returnObj.resultCount = brsBusDtList.size();
            returnObj.tableColumns = columnWrapperList;
            returnObj.resultAllCount = markPAListGetAllMatchedCount != NULL ? markPAListGetAllMatchedCount.size() : 0;
            returnObj.resultList = brsBusDtList;
            return returnObj;
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, getMarkSearchList, null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public static Map<String,String> getTranslatedMap(){
        Map<String,String>  labelMaps = new Map<String,String>();
        labelMaps.put('Withdrawn', System.label.Withdrawn_Label);
        labelMaps.put('Forfieted', System.label.Forfeited_Label);
        labelMaps.put('Dissolved',System.label.Dissolved_Label);
        labelMaps.put('Revoked',System.label.Revoked_Label1);
        labelMaps.put('Active',System.label.Active_Label);
        labelMaps.put('ACTIVE',System.label.Active_Label);
        labelMaps.put('Cancelled',System.label.Cancelled_Label);
        labelMaps.put('Merged',System.label.Merged_Label);
        labelMaps.put('Recorded', System.label.RECORDED_Label);
        labelMaps.put('Expired', System.label.brs_BusFileStatusExpired);
        labelMaps.put('Assignment', System.label.Mark_Filing_Status_Assignment);
        labelMaps.put('Cancellation', System.label.brs_Mark_Cancellation);
        labelMaps.put('Owner Address Change', System.label.brs_BusFileStatusExpired);
        labelMaps.put('Registration', System.label.Mark_Filing_Status_Registration);
        labelMaps.put('Owner Name Change', System.label.BRS_Trade_Owner_Name_Change);
        labelMaps.put('State of Formation Change', System.label.BRS_Trade_State_of_Formation_Change);
        labelMaps.put('Renewal', System.label.Mark_Filing_Status_Renewal);
        return labelMaps;
    }
    
    public static searchData getSelectedTradeAndServiceMarkDetails(String markId) {
        try {
            Map<String,String>  labelMaps = new Map<String,String>();
            labelMaps = getTranslatedMap(); 
            searchData markResultObj = new searchData();
            Set<Id> filingIds = new Set<Id>();//WITH SECURITY_ENFORCED
            String approvedStatus = System.Label.Approved;
            String search = 'SELECT Id, Owner_Name__c, Owner_Street_Address__c, Owner_Unit__c, Owner_City__c, Owner_State__c, Owner_Country__c, Owner_Zip_Code__c, Registration_number__c, Status__c, Registration_Date__c, Description_of_Mark__c, Mark_Type__c, Renewal_Date__c, Disclaimer__c, Class_of_Goods_Service__c, Method_of_use__c, Mark_used_for__c, Owner_Type__c, State_Country_of_Formation__c, Partner_Names__c, Keywords__c, Date_of_1st_Use_in_CT__c, Date_of_1st_Use_Anywhere__c, Expiration_Date__c, X1st_Expiration_Date__c, (Select Id, Filing_Type__c, Filing_number__c, Filing_Date__c, Number_of_Pages__c, Volume__c, Start_Page__c FROM Mark_Filings__r WHERE STATUS__c =: approvedStatus) FROM Mark__c WHERE Id =: markId WITH SECURITY_ENFORCED';
            List<Mark__c> markData = new List<Mark__c>();
            markData = Database.Query(search);
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, markData);
system.debug('=======securityDecision.createCustomerBalanceTransactions()======>'+securityDecision.getRemovedFields());
           // markData = Database.Query(search);
            if (!markData.isEmpty()) {
                List<searchDataMarkFilings> markHistory = new List<searchDataMarkFilings>();
                List<searchDataMarkFilings> markFilingHistory = new List<searchDataMarkFilings>();
                Mark__c mObj = markData.get(0);
                markResultObj.registrationNumber = mObj.Registration_Number__c;
                markResultObj.registrationDateFormatted = retFormattedDate(mObj.Registration_Date__c);
                markResultObj.descOfMark = mObj.Description_of_Mark__c;
                markResultObj.markType = mObj.Mark_Type__c;
                markResultObj.clsOfGoodsAndServices = mObj.Class_of_Goods_Service__c;
                markResultObj.disclaimer = mObj.Disclaimer__c;
                markResultObj.markUsedFor = mObj.Mark_used_for__c;
                markResultObj.keyWords = mObj.Keywords__c;
                markResultObj.methodOfUse = mObj.Method_of_use__c;
                markResultObj.status = labelMaps.containsKey(mObj.Status__c) ? labelMaps.get(mObj.Status__c) : mObj.Status__c;
                markResultObj.renewalDateFormatted = retFormattedDate(mObj.Renewal_Date__c);
                markResultObj.firstexpirationDate = retFormattedDate(mObj.X1st_Expiration_Date__c);
                markResultObj.expirationDate = retFormattedDate(mObj.Expiration_Date__c);
                markResultObj.datefFirstUseInAnywhere = retFormattedDate(mObj.Date_of_1st_Use_Anywhere__c);
                markResultObj.datefFirstUseInCT = retFormattedDate(mObj.Date_of_1st_Use_in_CT__c);
                markResultObj.ownerName = mObj.Owner_Name__c;
                markResultObj.ownerType = mObj.Owner_Type__c;
                markResultObj.ownerAddStreet = mObj.Owner_Street_Address__c;
                markResultObj.ownerAddUnit = mObj.Owner_Unit__c;
                markResultObj.ownerAddCity = mObj.Owner_City__c;
                markResultObj.ownerAddState = mObj.Owner_State__c;
                markResultObj.ownerAddCountry = mObj.Owner_Country__c;
                markResultObj.ownerAddZipCode = mObj.Owner_Zip_Code__c;
                markResultObj.partnerNames = mObj.Partner_Names__c;
                markResultObj.stateCountryOfFormation = mObj.State_Country_of_Formation__c;
                for (Mark_Filing__c mfObj : mObj.Mark_Filings__r) {
                    if (mfObj.Filing_number__c != NULL) {
                        filingIds.add(mfObj.Id);
                    }
                }
                // Get Related attachments
                Map<Id, Map<String, String>> filingAttachmentsMap = retAssociatedAttachments(filingIds);
                for (Mark_Filing__c mfObj : mObj.Mark_Filings__r) {
                    // Mark History object
                    searchDataMarkFilings mfObjWrap1 = new searchDataMarkFilings();
                    mfObjWrap1.Id = mfObj.Id;
                    mfObjWrap1.filingNumber = mfObj.Filing_number__c;
                    mfObjWrap1.filingType = labelMaps.containsKey(mfObj.Filing_Type__c) ? labelMaps.get(mfObj.Filing_Type__c) : mfObj.Filing_Type__c;
                    if (filingAttachmentsMap.containsKey(mfObj.Id)) {
                        Map<String, String> allAssociatedAttachmentsWithLink = filingAttachmentsMap.get(mfObj.Id);
                        mfObjWrap1.markImage = allAssociatedAttachmentsWithLink.containsKey(System.Label.Mark_Label_Mark_Image) ? allAssociatedAttachmentsWithLink.get(System.Label.Mark_Label_Mark_Image) : '';
                    }
                    markHistory.add(mfObjWrap1);
                    // Filing History object
                    searchDataMarkFilings mfObjWrap2 = new searchDataMarkFilings();
                    mfObjWrap2.Id = mfObj.Id;
                    mfObjWrap2.filingNumber = mfObj.Filing_number__c;
                    mfObjWrap2.filingType = labelMaps.containsKey(mfObj.Filing_Type__c) ? labelMaps.get(mfObj.Filing_Type__c) : mfObj.Filing_Type__c;

                    mfObjWrap2.filingDate = retFormattedDate(mfObj.Filing_Date__c);
                    mfObjWrap2.volume = Integer.ValueOf(mfObj.Volume__c) != NULL ? Integer.ValueOf(mfObj.Volume__c) : NULL;
                    mfObjWrap2.startPage = Integer.ValueOf(mfObj.Start_Page__c) != NULL ? Integer.ValueOf(mfObj.Start_Page__c) : NULL;
                    mfObjWrap2.noOfPages = Integer.ValueOf(mfObj.Number_of_Pages__c) != NULL ? Integer.ValueOf(mfObj.Number_of_Pages__c) : NULL;
                    if (filingAttachmentsMap.containsKey(mfObj.Id)) {
                        Map<String, String> allAssociatedAttachmentsWithLink = filingAttachmentsMap.get(mfObj.Id);
                        mfObjWrap2.markImage = allAssociatedAttachmentsWithLink.containsKey(System.Label.Mark_Label_Mark_Image) ? allAssociatedAttachmentsWithLink.get(System.Label.Mark_Label_Mark_Image) : '';
                        if (mfObj.Filing_Type__c == System.Label.Mark_Filing_Status_Registration) {
                            mfObjWrap2.digitalCopy = allAssociatedAttachmentsWithLink.containsKey(System.Label.Mark_Filing_Status_Registration) ? allAssociatedAttachmentsWithLink.get(System.Label.Mark_Filing_Status_Registration) : '';
                        } else if (mfObj.Filing_Type__c == System.Label.Mark_Filing_Status_Assignment || mfObj.Filing_Type__c == System.Label.Mark_Filing_Status_Owner_Name_Change || mfObj.Filing_Type__c == System.Label.Mark_Filing_Status_State_of_Formation_Change) {
                            mfObjWrap2.digitalCopy = allAssociatedAttachmentsWithLink.containsKey(System.Label.Mark_Label_Substitute) ? allAssociatedAttachmentsWithLink.get(System.Label.Mark_Label_Substitute) : '';
                        } else if (mfObj.Filing_Type__c == System.Label.Mark_Filing_Status_Renewal) {
                            mfObjWrap2.digitalCopy = allAssociatedAttachmentsWithLink.containsKey(System.Label.Mark_Filing_Status_Renewal) ? allAssociatedAttachmentsWithLink.get(System.Label.Mark_Filing_Status_Renewal) : '';
                        }
                    }
                    markFilingHistory.add(mfObjWrap2);
                }
                markResultObj.filingHistory = markFilingHistory;
                markResultObj.markHistory = markHistory;
            }
            return markResultObj;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getSelectedTradeAndServiceMarkDetails, null, null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static string retFormattedDate(Date dateVal) {
         try {
            String formattedDate = '';
            Datetime dateTimeVal;
            if (dateVal != NULL) {
                dateTimeVal = Datetime.newInstance(dateVal.Year(), dateVal.Month(), dateVal.Day());
                formattedDate = dateTimeVal.format(System.Label.Date_Format);
            }
            return formattedDate;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, retFormattedDate, null, null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Map<Id, Map<String, String>> retAssociatedAttachments(Set<Id> parentId) {
        try {
            Map<Id, Map<String, String>> filingAttachmentMap = new Map<Id, Map<String, String>>();
            List<ContentDocumentLink> documentDetails = new List<ContentDocumentLink>();
            if (!parentId.isEmpty()) {
                if (!parentId.Isempty()) {
                    documentDetails =  [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize , ContentDocument.CreatedDate, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.FileExtension
                                        FROM ContentDocumentLink where (LinkedEntityId IN : parentId)];
                }
                Set<ID> ContentDocumentIds = new Set<ID>();
                if (!documentDetails.isEmpty()) {
                    for (ContentDocumentLink contentInst : documentDetails) {
                        ContentDocumentIds.add(contentInst.ContentDocumentId);
                    }
                    List<ContentDistribution> conDocVersion = [Select Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl from ContentDistribution where ContentDocumentId IN: ContentDocumentIds];
                    for (ContentDocumentLink doc : documentDetails) {
                        for (ContentDistribution conVer : conDocVersion) {
                            if (doc.ContentDocumentId == conVer.ContentDocumentId) {
                                String filingAttachmentType = '';
                                if (doc.ContentDocument.Title.toLowerCase().contains(System.Label.Mark_Filing_Status_Registration.toLowerCase())) {
                                    filingAttachmentType = System.Label.Mark_Filing_Status_Registration;
                                } else if (doc.ContentDocument.Title.toLowerCase().contains(System.Label.Mark_Label_Substitute.toLowerCase())) {
                                    filingAttachmentType = System.Label.Mark_Label_Substitute;
                                } else if (doc.ContentDocument.Title.toLowerCase().contains(System.Label.Mark_Filing_Status_Renewal.toLowerCase())) {
                                    filingAttachmentType = System.Label.Mark_Filing_Status_Renewal;
                                } else if (doc.ContentDocument.Title.toLowerCase().contains(System.Label.Mark_Label_Mark_Image.toLowerCase())) {
                                    filingAttachmentType = System.Label.Mark_Label_Mark_Image;
                                }
                                if (filingAttachmentMap.containsKey(doc.LinkedEntityId)) {
                                    if (!filingAttachmentMap.get(doc.LinkedEntityId).containsKey(filingAttachmentType)) {
                                        filingAttachmentMap.get(doc.LinkedEntityId).put(filingAttachmentType, conVer.DistributionPublicUrl);
                                    }
                                } else  {
                                    Map<String, String> mapFilingTypevsAttachmentLink = new Map<String, String>();
                                    mapFilingTypevsAttachmentLink.put(filingAttachmentType, conVer.DistributionPublicUrl);
                                    filingAttachmentMap.put(doc.LinkedEntityId, mapFilingTypevsAttachmentLink);
                                }
                            }
                        }
                    }
                }
            }
            return filingAttachmentMap;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, retAssociatedAttachments, null, null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
        
        Public Static String removeReservedKeyWords(String searchedTerm){
        List<SOSL_Reserved_Keywords__mdt> listOfReservedKeyWords = new List<SOSL_Reserved_Keywords__mdt>();
        listOfReservedKeyWords = [Select Id, Label, Replace_With__c from SOSL_Reserved_Keywords__mdt];
        for(SOSL_Reserved_Keywords__mdt reservedKeyWord : listOfReservedKeyWords){
            if(searchedTerm.contains(reservedKeyWord.Label)){
                searchedTerm = searchedTerm.replace(reservedKeyWord.Label, reservedKeyWord.Replace_With__c);
            }
        }
        return searchedTerm;
    }
}