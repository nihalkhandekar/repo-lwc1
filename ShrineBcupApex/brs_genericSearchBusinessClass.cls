public without sharing class brs_genericSearchBusinessClass {

    public static Final String className = 'brs_genericSearchBusinessClass';
    public static Final List<String> businessStatuses = new List<String>();
    @AuraEnabled
    public static void sendSearchURLEmail(List<String> toAddress,String link,String searchType) {         
        Messaging.reserveSingleEmailCapacity(1);
        try{
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1924.
            * Change(s)/Modification(s) Description : Added email functionality from search screen
            * Change(s)/Modification(s) Made on : 30-06-2021
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if(searchType == System.Label.Trade_Label){
                List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
                List<EmailTemplate> etObjLst = new List<EmailTemplate>();
                etObjLst = [Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: System.Label.Mark_Email_Template_Developer_Name];
                owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address = : System.label.BRS_sotsOrgWideEmailAddr limit 1];
                if(!etObjLst.isEmpty()){
                    EmailTemplate etObj = etObjLst.get(0);
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(etObj.Id, null, null);
                    String htmlBody = email.getHtmlBody();
                    if (!owa.isEmpty()) {
                        email.setOrgWideEmailAddressId(owa.get(0).Id);
                    }
                    email.setTemplateId(etObj.Id);
                    htmlBody = htmlBody.replace(System.Label.Mark_Url, link);
                    email.setHtmlBody(htmlBody);
                    email.setToAddresses(toAddress);
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<messaging.SingleEmailMessage> {email});
                }
            } else{
                messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();     
                mail.setToAddresses(toAddress);
                mail.setReplyTo(System.Label.BRS_Online_Enquiry_Email);
                
                String body = 'Hello,' + '<br/><br/>';
                if(searchType==System.Label.Lien){
                    mail.setSubject(System.Label.BRS_Online_Enquiries_SubjectLine);
                    body += 'Please find the URL below for your UCC search results.'  + '<br/><br/>';
                }
                else{
                    mail.setSubject(System.Label.BRS_Business_Search_Subject);
                    body += 'Please find below the URL below for your Business Registry Search results.'  + '<br/><br/>';
                }
                body += link +  + '<br/><br/>';
                body += 'Sincerely,'  + '<br/>';
                body += 'Connecticut Secretary of the State '  + '<br/><br/>';
                body += 'This e-mail has been sent from an automated system. Please do not reply.' + '<br/>';
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
            }
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<BRS_Lien_Search_Dates__c> retrieveUCCDates() {
        return [
            SELECT IRS_Lien_through_date__c,UCC_filing_through_Date__c 
            FROM BRS_Lien_Search_Dates__c 
            LIMIT 1
        ];
    }
    
    /**
     * @desc: get all dashboard filters for myfilings page
     * @uage: brs_myFilingHistory.js
     */
    @AuraEnabled
    public static List<filterTypeWrapper> retrieveFilters(String searchTypeString) {
        String searchType = String.escapeSingleQuotes(searchTypeString);
        Map<String, String> labelMaps = getTranslatedMap();
        List<filterTypeWrapper> filterType = new List<filterTypeWrapper>();
        
        for (BRS_online_enquiry_Filters__mdt type: [
            SELECT Id, DeveloperName, Search_Type__c, MasterLabel, API_Name__c, Filter_Icon__c, data_type__c, IsActive__c, Order__c, 
                (
                    SELECT Id, DeveloperName, BRS_Online_Enquiry_Filter_option__r.DeveloperName, MasterLabel, IsActive__c, Picklist_API_Name__c, Order__c 
                    FROM BRS_Online_Enquiry_Filter_Options__r
                ) 
            FROM BRS_online_enquiry_Filters__mdt 
            WHERE Search_Type__c LIKE :searchType  //%Dashboard%
            ORDER BY Order__c
        ]) {
            List<filterOptionWrapper> filterTypeOptions = new List<filterOptionWrapper>();
            
            for (BRS_Online_Enquiry_Filter_Options__mdt typeOption: type.BRS_Online_Enquiry_Filter_Options__r) {
                filterOptionWrapper filterOption = new filterOptionWrapper(typeOption);
                filterOption.MasterLabel = labelMaps.containsKey(typeOption.DeveloperName) 
                    ? labelMaps.get(typeOption.DeveloperName) 
                    : typeOption.MasterLabel;
                
                filterTypeOptions.add(filterOption);
                
                if (typeOption.BRS_Online_Enquiry_Filter_option__r.DeveloperName == 'Business_Status_Dashboard') {
                    businessStatuses.add(typeOption.Picklist_API_Name__c);
                }
            }

            filterTypeOptions.sort();
            filterTypeWrapper filter = new filterTypeWrapper(type, filterTypeOptions);
            filter.MasterLabel = labelMaps.containsKey(type.DeveloperName) 
                ? labelMaps.get(type.DeveloperName) 
                : type.MasterLabel;
            
            filterType.add(filter);
        }
        System.debug('&&&&&&&&&&&&&&&&&&3'+filterType);
        return filterType;
    }

    public static Map<String,String> getTranslatedMap(){
        Map<String,String>  labelMaps = new Map<String,String>();
         labelMaps.put('Lien_In_Progress',System.label.In_Progress_Filing);
        labelMaps.put('Lien_Approved',System.label.Approved_Filing);
        labelMaps.put('Lien_Rejected',System.label.Rejected_Filing);
        labelMaps.put('Lien_Submitted_Agency_review_pending',System.label.Submitted_Agency_review_pending_Filing);
        labelMaps.put('Lien_Status_Dashboard',System.label.Status_Filing);
        labelMaps.put('In_Progress',System.label.In_Progress_Filing);
        labelMaps.put('Business_Approved',System.label.Approved_Filing);
        labelMaps.put('Business_Rejected',System.label.Rejected_Filing);
        labelMaps.put('Submitted_Agency_review_pending',System.label.Submitted_Agency_review_pending_Filing);
        labelMaps.put('Business_Status_Dashboard',System.label.Status_Filing);
        labelMaps.put('Submitted_Agent_acceptance_pending',System.label.Submitted_Agent_acceptance_pending_Filing);
        labelMaps.put('Lien_OFS',System.label.Original_Financing_Statement_Label);
        labelMaps.put('Dashboard_Vessel',System.label.Vessel);
        labelMaps.put('Dashboard_Aircraft',System.label.Aircraft_Label);
        labelMaps.put('Judgment_Personal_Property',System.label.Judgement_PersonalProperty);
        labelMaps.put('Dashboard_Amendment',System.label.Amendment_Label);
        labelMaps.put('Information_Statement',System.label.brs_InfoStatement);
        labelMaps.put('Filing_Type_Dashboard',System.label.Filing_Type_Filing);
        labelMaps.put('Certificate_Type_Dashboard',System.label.Certificate_Type_Label);
        labelMaps.put('Cert_Express',System.label.Express_Filing);
        labelMaps.put('Cert_Standard',System.label.Standard_Filing);
        labelMaps.put('Cert_Longform',System.label.Longform_Filing);
        labelMaps.put('Plain_Label',System.label.Plain_Label);
        labelMaps.put('Certified_Label',System.label.Certified_Label);
        labelMaps.put('Copy_type',System.label.Copy_type);
        labelMaps.put('Name_Change_Amendment',System.label.Name_Change_Amendment_Filing);
        labelMaps.put('Withdrawal',System.label.Withdrawal_Filing);
        labelMaps.put('Annual_Report',System.label.Annual_Report_Filing);
        labelMaps.put('First_Report',System.label.First_Report_Filing);
        labelMaps.put('Change_of_NAICS_Code',System.label.Change_of_NAICS_Code_Filing);
        labelMaps.put('Change_of_Agent',System.label.Change_of_Agent_Filing);
        labelMaps.put('Business_Formation',System.label.Business_Formation_Filing);
        labelMaps.put('Name_Reservation',System.label.Name_Reservation_Filing);
        labelMaps.put('Address_Change',System.label.Change_of_Address_Filing);
        labelMaps.put('Agent_Resignation',System.label.Agent_Resignation_Filing);
        labelMaps.put('Change_of_Email_Address',System.label.Change_of_Email_Address_Filing);
        labelMaps.put('Renunciation_of_Status',System.label.Renunciation_of_Status_Filing);
        labelMaps.put('Business_Registration',System.label.Business_Registration);
        labelMaps.put('Dissolution',System.label.Dissolution_Filing);
        labelMaps.put('Interim_Notice',System.label.Interim_Notice_Filing);
        labelMaps.put('Change_of_Agent_Address',System.label.Change_of_Agent_Address_Filing);

        labelMaps.put('Lien_Status',System.label.Lien_Status_Label);
        labelMaps.put('Lien_Type',System.label.LienTypeLabel);
        labelMaps.put('Include_Lapsed_Liens',System.label.Include_Lapsed_Liens);
        labelMaps.put('OFS',System.label.Original_Financing_Statement_Label);
        labelMaps.put('Vessel',System.label.Vessel);
        labelMaps.put('Aircraft',System.label.Aircraft_Label);
        labelMaps.put('Judgment',System.label.Judgement_Label);
        //
        labelMaps.put('Domestic',System.label.Domestic);
        labelMaps.put('Foreign',System.label.Foreign_1);
        labelMaps.put('Business_Start_Date',System.label.Business_Start_Date);
        labelMaps.put('Business_End_Date',System.label.Business_End_Date);
        labelMaps.put('Date',System.label.Date);
        labelMaps.put('Business_Status', System.label.businessProfile_bstatus);
        labelMaps.put('Withdrawn', System.label.Withdrawn_Label);
        labelMaps.put('Forfieted', System.label.Forfeited_Label);
        labelMaps.put('Dissolved',System.label.Dissolved_Label);
        labelMaps.put('Revoked',System.label.Revoked_Label1);
        labelMaps.put('Active',System.label.Active_Label);
        labelMaps.put('Cancelled',System.label.Cancelled_Label);
        labelMaps.put('Merged',System.label.Merged_Label);
        labelMaps.put('Recorded', System.label.RECORDED_Label);
        labelMaps.put('Business_Type',System.label.Business_type_1);
        labelMaps.put('Entity_Type',System.label.Entity_Type);
        labelMaps.put('Mark_Filters',System.label.Mark_type);
        labelMaps.put('Service',System.label.Service);
        labelMaps.put('Certification',System.label.Certifications);
        labelMaps.put('Collective',System.label.Collective);
        labelMaps.put('Trade',System.label.Trade);
        
        return labelMaps;

    }

    /**
     * @update: BRS-6673 | Update debtor logic
     */
    @AuraEnabled
    public static GenericSearchWrapper retrieveAllRecords(String searchObj) {
        System.debug('&&&&&&&&&2'+searchObj);        
        GenericSearchWrapper genericWrap = new GenericSearchWrapper();
        BRS_online_enquiry__mdt onlineEnquiry =new BRS_online_enquiry__mdt();
        SearchString wrapObj = new SearchString();
        
        SearchObjFromUIWrapper searchIndiDebtor = new SearchObjFromUIWrapper();
        SearchObjFromUIWrapperNONDebtorInd searchNonDebtor = new SearchObjFromUIWrapperNONDebtorInd(); //also org debtor
        
        if(String.isNotBlank(searchObj)) {
            if(!searchObj.contains(System.Label.DebtorSearchIndividual)) {
                searchNonDebtor = (searchObjFromUIWrapperNONDebtorInd) System.JSON.deserialize(searchObj,searchObjFromUIWrapperNONDebtorInd.class);
                onlineEnquiry = [
                    SELECT Search_Object__c,Search_Limit__c,Include_Filters__c,Download_Limit__c,Search_Object_fields__c,DeveloperName 
                    FROM BRS_online_enquiry__mdt 
                    WHERE DeveloperName =: String.escapeSingleQuotes(searchNonDebtor.type)                   
                ];
            }
            else{
                searchIndiDebtor = (searchObjFromUIWrapper) System.JSON.deserialize(searchObj, searchObjFromUIWrapper.class);
                wrapObj = searchIndiDebtor.searchString;
                onlineEnquiry = [
                    SELECT Search_Object__c,Search_Limit__c,Include_Filters__c,Download_Limit__c,Search_Object_fields__c,DeveloperName 
                    FROM BRS_online_enquiry__mdt 
                    WHERE DeveloperName =: String.escapeSingleQuotes(searchIndiDebtor.type)
                ];
            }

            if(searchNonDebtor.type == 'LienSearch') {
                genericWrap = retrieveLienRecord(searchObj, onlineEnquiry, searchNonDebtor);         
            }
            else if(searchNonDebtor.type == 'Business_Search') {
                brs_onlineEnquiryBusinessSearch.getBusiness(searchNonDebtor.searchString, searchNonDebtor.type, searchNonDebtor.filters, null, null);
            }
            else {
                LienSearchWrapper searchWrapper = System.Label.DebtorSearchIndividual.equalsIgnoreCase(searchIndiDebtor.type)
                    ? new LienSearchWrapper(searchIndiDebtor) //indi
                    : new LienSearchWrapper(searchNonDebtor); //org

                genericWrap = retrieveDebtorInfo(onlineEnquiry, searchWrapper, false);
            }
        }
        return genericWrap;
    }

    /**
     * @update: BRS-6673 | Exact/Starts with match
     * Combine the logic for download CSV and onlineenquiry page
     */
    public static GenericSearchWrapper retrieveDebtorInfo(BRS_online_enquiry__mdt onlineEnquiry, LienSearchWrapper searchWrapper, Boolean isDownload) {
        System.debug('&&&&&&&&&&&1'+searchWrapper);
        List<String> typeFilterOptions = new List<String> ();
        Boolean includeLapseLien = false;
        List<String> listDebtorTypes = RequestForInformationController.listDebtorTypes;
        List<String> listLienStatus = new List<String>{'Archived','In-Progress'};
        Boolean isValidSearch = false;
        
        /**
         * negation queries are costly
         * ANDing is costly
         * Querying on parent field is costly
         */
        String queryString = 'SELECT ' + onlineEnquiry.Search_Object_fields__c 
            + ',Filing_Id__r.UCC_Lien_Id__r.Type__c,Filing_Id__r.Filing_Date__c,Filing_Id__r.UCC_Lien_Id__r.UCC_Lien_Number__c,Filing_Id__r.Filing_Number__c,Filing_Id__r.Type__c' 
            + ' FROM ' + onlineEnquiry.Search_Object__c 
            + ' WHERE Filing_Id__r.Status__c = \'' + System.Label.Approved + '\'' 
            + ' AND Type__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.UCC_Lien_Id__r.Status__c NOT IN :listLienStatus';
    
        List<FilterWrapper> filters = System.Label.DebtorSearchOrganisation.equalsIgnoreCase(searchWrapper.type)
            ? searchWrapper.filters
            : searchWrapper.filters;
    
        if (filters != null) {
            for (filterWrapper filter: filters) {
                if ('Type__c'.equalsIgnoreCase(filter.type)) {
                    typeFilterOptions = filter.selectedOptions;
                } else if (filter.selectedOptions.contains(System.Label.Include_Lapsed_Liens_Label)) {
                    includeLapseLien = true;
                }
            }
        }
    
        Set<String> setOfNoiseWords = RequestForInformationController.getNoiseWords();
        
        if (System.Label.DebtorSearchOrganisation.equalsIgnoreCase(searchWrapper.type)) {
                    //String searchString = RequestForInformationController.convertFieldToSearchString(searchWrapper.orgName, true, setOfNoiseWords);   
                    String searchString=RequestForInformationController.convertDebtorOrgToSearchString(searchWrapper.orgName); 
            
            //BRS-6673 | Starts with
            if (String.isNotBlank(searchString)) {
                isValidSearch = true;
                queryString += searchWrapper.isStartsWithSearch  
                    ? ' AND Org_Name_Indexed__c LIKE \''+ searchString +'%\''
                    : ' AND Org_Name_Indexed__c = \''+ searchString +'\'';
            }
        } else if (System.Label.DebtorSearchIndividual.equalsIgnoreCase(searchWrapper.type) && String.isBlank(searchWrapper.firstName)) {
            String lastName = RequestForInformationController.convertFieldToSearchString(searchWrapper.lastName, false, setOfNoiseWords);    
            
            if(String.isNotBlank(lastName)) {
                isValidSearch = true;
                queryString += searchWrapper.isStartsWithSearch  
                    ? ' AND Individual_Last_Name_Indexed__c LIKE \''+ lastName +'%\''
                    : ' AND Individual_Last_Name_Indexed__c = \'' + lastName + '\'';
            }
        } else if(System.Label.DebtorSearchIndividual.equalsIgnoreCase(searchWrapper.type) && String.isNotBlank(searchWrapper.firstName)) {
            String lastName = RequestForInformationController.convertFieldToSearchString(searchWrapper.lastName, false, setOfNoiseWords);    
            String firstName = RequestForInformationController.convertFieldToSearchString(searchWrapper.firstName, false, setOfNoiseWords);
            
            if(String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
                isValidSearch = true;
                queryString += ' AND Individual_First_Name_Indexed__c = \'' + firstName +'\'';
                queryString += searchWrapper.isStartsWithSearch  
                    ? ' AND Individual_Last_Name_Indexed__c LIKE \''+ lastName +'%\''
                    : ' AND Individual_Last_Name_Indexed__c = \'' + lastName + '\'';
            }
        }
    
        queryString += includeLapseLien
            ? ' AND Filing_Id__r.UCC_Lien_Id__r.Lapse_Date__c < TODAY '
            : '';
    
        queryString += !typeFilterOptions.isEmpty()
            ? ' AND Filing_Id__r.UCC_Lien_Id__r.Type__c IN :typeFilterOptions'
            : '';   
        
        queryString += ' WITH SECURITY_ENFORCED ORDER BY Filing_Id__r.Filing_Date__c ASC'
            + ' LIMIT '+ Integer.valueOf( isDownload ? onlineEnquiry.Download_Limit__c : onlineEnquiry.Search_Limit__c);
        System.debug('----------------'+queryString);
        System.debug('---------------Types-'+listDebtorTypes);
        List<UCC_Related_Info__c> sObjList = isValidSearch
            ? (List<UCC_Related_Info__c>) Database.query(queryString)
            : new List<UCC_Related_Info__c>();
        
        GenericSearchWrapper genericWrap = new GenericSearchWrapper();
        genericWrap.Count = 0;
        genericWrap.hasSameDebtorName = false;
        genericWrap.actualCount = sObjList.size();
        genericWrap.objList = new List<ObjWrapper>();
    
        /** To-Do | Do common */
        if(!sObjList.isEmpty()) {
            if(isDownload) {  //for csv
                genericWrap.objList = retrieveExportRecords(sObjList);
            } else { //for onlineenquiry
                Map<String, Set<String>> mapNameLien = new Map<String, Set<String>>(); //Group same name debtor together, irrespective of lien
                List<String> nameList = new List<String>(); //to keep order
                Map<String, String> debtorNameIndexedMap = new Map<String, String>();
                Map<String, Set<String>> debtorOrgNameMap = new Map<String, Set<String>>(); //debtor x lien count

                //custom grouping
                for (UCC_Related_Info__c uccInst: (List<UCC_Related_Info__c>) sObjList) {
                    //group by Name__c
                    if(!mapNameLien.containsKey(uccInst.Name__c)) {
                        mapNameLien.put(uccInst.Name__c, new Set<String>());
                        nameList.add(uccInst.Name__c);
                    }
                    mapNameLien.get(uccInst.Name__c).add(uccInst.Filing_Id__r.UCC_Lien_Id__c);

                    //group by Org_Name_Indexed__c
                    if (String.isNotBlank(uccInst.Org_Name_Indexed__c)) {
                        debtorNameIndexedMap.put(uccInst.Name__c, uccInst.Org_Name_Indexed__c);
                        
                        if (!debtorOrgNameMap.containsKey(uccInst.Org_Name_Indexed__c)) {
                            debtorOrgNameMap.put(uccInst.Org_Name_Indexed__c, new Set<String> {});
                        }
            
                        debtorOrgNameMap.get(uccInst.Org_Name_Indexed__c).add(uccInst.Filing_Id__r.UCC_Lien_Id__c);
                    }
                }
                
                //nameList.sort(); | sorted in query
                for (String debtorName: nameList) {
                    if(debtorName !=null)
                    {
                         objWrapper objInst = new objWrapper();
                    objInst.debtorName = debtorName;
                    objInst.debtorNameIndexed = debtorNameIndexedMap.containsKey(debtorName) 
                        ? debtorNameIndexedMap.get(debtorName)
                        : null;
                    objInst.LienIDsForOrgIndexed = debtorOrgNameMap.containsKey(objInst.debtorNameIndexed)
                        ? debtorOrgNameMap.get(objInst.debtorNameIndexed) 
                        : new Set<String>();
                    objInst.LienIDs = mapNameLien.containsKey(debtorName) 
                        ? mapNameLien.get(debtorName) 
                        : null;
                    objInst.lienCountForDebtor = mapNameLien.containsKey(debtorName) 
                        ? mapNameLien.get(debtorName).size() 
                        : 0;
                    
                    genericWrap.objList.add(objInst);
                    }
                   
                }
                
                genericWrap.Count = mapNameLien.size();
                genericWrap.hasSameDebtorName = debtorOrgNameMap.size() == 1;
            }
        }
        return genericWrap;
    }
 
    /**
     * @update: BRS-6319 | Update sorting logic oldest OFS to newest OFS
     *          grouped by amendments
     */
    @TestVisible
    private static List<ObjWrapper> retrieveExportRecords(List<UCC_Related_Info__c> listRelatedInfos) {
        List<ObjWrapper> listRecords = new List<ObjWrapper>();
        
        Map<Id, List<String>> filingNumSecuredPartyMap = new Map<Id, List<String>>();
        Set<String> filingNumSet = new Set<String>();
        Map<Id, List<UCC_Related_Info__c>> mapLienFilings = new Map<Id, List<UCC_Related_Info__c>>();
        List<RequestForInformationController.FilingWrapper> listOFSFilings = new List<RequestForInformationController.FilingWrapper>(); //sort ofs
        
        for(UCC_Related_Info__c relatedInfo : listRelatedInfos) {
            if(!RequestForInformationController.setAmendmentTypes.contains(relatedInfo.Filing_Id__r.Type__c)) {
                listOFSFilings.add(new RequestForInformationController.FilingWrapper(new UCC_Filing__c(
                    Id = relatedInfo.Filing_Id__c,
                    Filing_Date__c = relatedInfo.Filing_Id__r.Filing_Date__c,
                    UCC_Lien_Id__c = relatedInfo.Filing_Id__r.UCC_Lien_Id__c
                ), null));
            }

            if(!mapLienFilings.containsKey(relatedInfo.Filing_Id__r.UCC_Lien_Id__c)) {
                mapLienFilings.put(relatedInfo.Filing_Id__r.UCC_Lien_Id__c, new List<UCC_Related_Info__c>());
            }
            mapLienFilings.get(relatedInfo.Filing_Id__r.UCC_Lien_Id__c).add(relatedInfo);
            
            filingNumSet.add(relatedInfo.Filing_Id__c);
        }

        if(!filingNumSet.isEmpty()) {
            for(UCC_Related_Info__c securedParty : [
                SELECT id, Name__c, Filing_Id__c
                FROM UCC_Related_Info__c
                WHERE Type__c IN :RequestForInformationController.listSecuredParties
                    AND Filing_Id__c IN: filingNumSet
                    WITH SECURITY_ENFORCED
                ORDER BY Name__c
            ]) {
                if(!filingNumSecuredPartyMap.containsKey(securedParty.Filing_Id__c)) {
                    filingNumSecuredPartyMap.put(securedParty.Filing_Id__c, new List<String>());
                }

                filingNumSecuredPartyMap.get(securedParty.Filing_Id__c).add(securedParty.Name__c);
            }
        }

        listOFSFilings.sort(); //sort OFS based on filing date
        for(RequestForInformationController.FilingWrapper w : listOFSFilings) {
            if(mapLienFilings.containsKey(w.filing.UCC_Lien_Id__c)) {
                for(UCC_Related_Info__c relatedInfo : mapLienFilings.get(w.filing.UCC_Lien_Id__c)) {
                    ObjWrapper wrapper = new ObjWrapper(relatedInfo);
                    wrapper.securedParty = filingNumSecuredPartyMap.containsKey(relatedInfo.Filing_Id__c)
                        ? String.join(filingNumSecuredPartyMap.get(relatedInfo.Filing_Id__c), ',')
                        : '';

                    listRecords.add(wrapper);
                }
            }
        }
        
        return listRecords;
    }

    @AuraEnabled
    public static genericSearchWrapper retrieveAllLiens(List<String> LienIds) {
        try{
        Set<ID> LienIdsUniq = new Set<ID>();
        for(String strInst : LienIds){
            LienIdsUniq.add(strInst);
        }
        genericSearchWrapper wraperInst = new genericSearchWrapper();
        List<objWrapper> objectList = new List<objWrapper>();
            System.debug('---------->'+LienIdsUniq);
        for(UCC_Lien__c lienInst : [Select id,Type__c,Lapse_Date_Formula__c,Lapse_Date__c,IRS_Number__c,UCC_Lien_Number__c,(Select id,Name,UCC_Lien_Type__c,Filing_Number__c,Filing_Date__c,toLabel(Type__c),UCC_Lien_Id__c,Microfilm_volume_number__c,Start_Page__c from UCC_Filings__r where status__c = 'Approved' order by Filing_Date__c desc) from Ucc_Lien__c where Id IN:LienIdsUniq and Status__c != 'Archived' WITH SECURITY_ENFORCED order by UCC_Lien_Number__c ]){
           system.debug('lienInst--'+lienInst);
            objWrapper objWrap = new objWrapper();
            objWrap.lienType = lienInst.Type__c;
            objWrap.lapseDate  = lienInst.Lapse_Date__c != null ? String.valueOf(Date.valueOf(lienInst.Lapse_Date__c).format()) : null;
            objWrap.lienNumber = lienInst.UCC_Lien_Number__c;
        //    objWrap.IRSNumber = lienInst.IRS_Number__c;
        //    objWrap.lienSfId = lienInst.id;
            if(lienInst.Lapse_Date__c >= system.today() || lienInst.Lapse_Date__c == null){
                objWrap.activeLien = True;
                objWrap.LapsedLien = False;
            }
            else if(lienInst.Lapse_Date__c < system.today()){
                objWrap.activeLien = False;
                objWrap.LapsedLien = True; 
            }
            List<relatedFilingWrapper> filingWrapList = new List<relatedFilingWrapper>();
            String filingDateStr;
            for(UCC_Filing__c uccFilingObj : lienInst.UCC_Filings__r){
                
                relatedFilingWrapper uccFilingRec = new relatedFilingWrapper();
                uccFilingRec.filingNumber = uccFilingObj.Filing_Number__c;
                if(uccFilingObj.Filing_Date__c != null){
                    Date filingdT = Date.valueOf(uccFilingObj.Filing_Date__c);
                    uccFilingRec.filingDate = String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format());
                }
                uccFilingRec.filingType = uccFilingObj.Type__c;
            //    uccFilingRec.filingSfId = uccFilingObj.Id;
                uccFilingRec.volume = uccFilingObj.Microfilm_volume_number__c != null ? uccFilingObj.Microfilm_volume_number__c : null;
                uccFilingRec.pages = uccFilingObj.Start_Page__c != null ? String.valueOf(uccFilingObj.Start_Page__c) : null ;
                filingWrapList.add(uccFilingRec);
                if(uccFilingObj.UCC_Lien_Type__c != null){
                    if(uccFilingObj.UCC_Lien_Type__c.contains(System.label.lien_Type_Irs) || uccFilingObj.UCC_Lien_Type__c.contains(System.label.OFS_Label) || uccFilingObj.UCC_Lien_Type__c == System.label.Vessel_Label || uccFilingObj.UCC_Lien_Type__c == System.label.Judgement_PersonalProperty || uccFilingObj.UCC_Lien_Type__c == System.label.LaborLabel || uccFilingObj.UCC_Lien_Type__c == System.label.Judgement_Lien_Type || uccFilingObj.UCC_Lien_Type__c == System.label.Aircraft_Label || uccFilingObj.UCC_Lien_Type__c == System.label.MunicipalLabel || uccFilingObj.UCC_Lien_Type__c == System.label.State_Label || uccFilingObj.UCC_Lien_Type__c == System.label.Public_OFS || uccFilingObj.UCC_Lien_Type__c == System.label.TransmittingUtilityLabel || uccFilingObj.UCC_Lien_Type__c == System.label.revenueServicesLabel || uccFilingObj.UCC_Lien_Type__c == System.label.Notice_of_Attachment || uccFilingObj.UCC_Lien_Type__c == System.label.Railroad){
                        filingDateStr  = uccFilingObj.Filing_Date__c != null ? String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format()) : ' ';
                    }
                }else if(uccFilingObj.UCC_Lien_Type__c == null && uccFilingObj.Type__c!=null && uccFilingObj.Type__c.contains('IRS')){
                    	filingDateStr  = uccFilingObj.Filing_Date__c != null ? String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format()) : ' ';
                }
            }
            objWrap.OFSFilingDate =  filingDateStr;
            objWrap.relatedFilingLst = filingWrapList;
            objectList.add(objWrap);
            wraperInst.objList = objectList;
        }
        System.debug('@@@@@@'+wraperInst);
        return wraperInst;
        }
        catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, 'retrieveAllLiens', '', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
        }  
    }
    
    /********************************************************************************************
    METHOD NAME    : getLienRecord
    DESCRIPTION    : to Get lien record and its rleated filing record
    RETURN TYPE    : List of Json wrapper
    PARAMETER      : List of Json wrapper
    Author         : Rahul Sharma
    Date           : 4th-Feb-2021
    ********************************************************************************************/
    public static genericSearchWrapper retrieveLienRecord( String searchObj,BRS_online_enquiry__mdt onlineEnquiry,searchObjFromUIWrapperNONDebtorInd lieanWrap)
    {       
        try
        {
        genericSearchWrapper genericLienWrap2= new genericSearchWrapper();
            List<filterWrapper> filters= new List<filterWrapper>();
            filters = lieanWrap.filters;
            List<String> typeFilterOptions = new List<String>();
            Boolean includeLapseLien = false;
            Date dt =Date.valueOf(System.now());
            List<String> filterTypes = new List<String>{system.label.brs_uccFilingStatus,System.label.In_Progress_Label,System.label.Rejected};
            if(filters != null)
            {
                for(filterWrapper filter : filters)
                {
                    if(filter.type == 'Type__c')
                    {
                        typeFilterOptions = filter.selectedOptions;
                    }
                    else if(filter.selectedOptions.contains(System.label.Include_Lapsed_Liens_Label))
                    {
                        includeLapseLien = true;
                    }
                }
            }
            
            String  queryString = 'SELECT Type__c,UCC_Lien_Number__c,' + '  ' +onlineEnquiry.Search_Object_fields__c + ' '+ 'FROM' + ' '+ onlineEnquiry.Search_Object__c +' '+'where Status__c!=\''+System.Label.BRS_Archived+'\'' + 'AND Status__c!=\'' + System.label.In_Progress_Label+'\'' ;

            if(includeLapseLien == true && typeFilterOptions.Isempty()){
                queryString += ' ' + 'and UCC_Lien_Number__c = \''+ lieanWrap.searchString+'\' and Lapse_Date__c <=: dt';
            }else if( !typeFilterOptions.IsEmpty() && includeLapseLien == true){
                queryString += ' ' + 'and UCC_Lien_Number__c = \''+ lieanWrap.searchString+'\' and Type__c in: typeFilterOptions and Lapse_Date__c <=: dt';
            }else if( !typeFilterOptions.IsEmpty() && includeLapseLien == false){
                queryString += ' ' + 'and UCC_Lien_Number__c = \''+ lieanWrap.searchString+'\' and Type__c in: typeFilterOptions';
            }else{
                queryString += ' ' + 'and UCC_Lien_Number__c = \''+ lieanWrap.searchString+'\'';
            }
            queryString += ' WITH SECURITY_ENFORCED';
            System.debug('----------------'+queryString);
            List<Sobject> sObjList = Database.query(queryString);
            map<id,List<relatedFilingWrapper>> objWrapList2 = new map<id,List<relatedFilingWrapper>>();
            List<objWrapper> objList = new List<objWrapper> ();
            List<relatedFilingWrapper> filingLst = new List<relatedFilingWrapper>();
            if(!sObjList.IsEmpty() && sObjList.size() == 1)
            {
                for(UCC_Lien__c lien : (List<UCC_Lien__c>)sObjList)
                {
                    String filingDateStr;
                    if(lien.getSObjects('UCC_Filings__r')!=null){
                        List<Sobject> uccFilingLst = lien.getSObjects('UCC_Filings__r');
                        for(Sobject sobj : uccFilingLst){
                            relatedFilingWrapper uccFilingRec = new relatedFilingWrapper();
                            UCC_Filing__c uccFilingObj = (UCC_Filing__c)sobj;
                            if(uccFilingObj.Filing_Number__c != null)
                            {
                                uccFilingRec.filingNumber = uccFilingObj.Filing_Number__c;
                                if(uccFilingObj.Filing_Date__c != null){
                                    uccFilingRec.filingDate = String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format());
                                }
                                uccFilingRec.filingType = uccFilingObj.Type__c;
                            //    uccFilingRec.filingSfId = uccFilingObj.Id;
                                uccFilingRec.volume = uccFilingObj.Microfilm_volume_number__c;
                                uccFilingRec.pages = String.valueOf(uccFilingObj.Start_Page__c);
                                if(uccFilingObj.UCC_Lien_Type__c != null && uccFilingObj.Type__c !='Office Correct'){
                                    if(filingDateStr ==null && (uccFilingObj.UCC_Lien_Type__c.contains(System.label.lien_Type_Irs) || uccFilingObj.UCC_Lien_Type__c.contains(System.label.OFS_Label) || uccFilingObj.UCC_Lien_Type__c == System.label.Vessel_Label || uccFilingObj.UCC_Lien_Type__c == System.label.Judgement_PersonalProperty || uccFilingObj.UCC_Lien_Type__c == System.label.LaborLabel || uccFilingObj.UCC_Lien_Type__c == System.label.Judgement_Lien_Type || uccFilingObj.UCC_Lien_Type__c == System.label.Aircraft_Label || uccFilingObj.UCC_Lien_Type__c == System.label.MunicipalLabel || uccFilingObj.UCC_Lien_Type__c == System.label.State_Label || uccFilingObj.UCC_Lien_Type__c == System.label.Public_OFS || uccFilingObj.UCC_Lien_Type__c == System.label.TransmittingUtilityLabel || uccFilingObj.UCC_Lien_Type__c == System.label.revenueServicesLabel || uccFilingObj.UCC_Lien_Type__c == System.label.Notice_of_Attachment|| uccFilingObj.UCC_Lien_Type__c == System.label.Railroad)){
                                        filingDateStr  = uccFilingObj.Filing_Date__c != null ? String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format()) : ' ';
                                    }
                                }
								else if(uccFilingObj.UCC_Lien_Type__c == null && uccFilingObj.Type__c!=null && uccFilingObj.Type__c.contains('IRS')){
                                    filingDateStr  = uccFilingObj.Filing_Date__c != null ? String.valueOf(Date.valueOf(uccFilingObj.Filing_Date__c).format()) : ' ';
                                }
                                filingLst.add(uccFilingRec);
                            }
                        }
                    }
                    objWrapper obj = new objWrapper();
                    objWrapList2.put(lien.id,filingLst);
                    genericLienWrap2.Count = sObjList.size();
                    obj.lienType = lien.Type__c;
                    obj.lapseDate  = lien.Lapse_Date__c != null ? String.valueOf(Date.valueOf(lien.Lapse_Date__c).format()) : null;
                    obj.lienNumber = lien.UCC_Lien_Number__c;
                //    obj.IRSNumber = lien.IRS_Number__c;
                //    obj.lienSfId = lien.id;
                    obj.OFSFilingDate = filingDateStr;
                    if(lien.Lapse_Date__c >=dt || lien.Lapse_Date__c == null){
                        obj.activeLien = True;
                        obj.LapsedLien = False;
                    }
                    else if(lien.Lapse_Date__c < dt){
                        obj.activeLien = False;
                        obj.LapsedLien = True; 
                    }
                    obj.relatedFilingLst = objWrapList2.get(lien.Id);
                    objList.add(obj);
                    genericLienWrap2.objList =objList;
                    
                }
            }
            else
            {
                genericLienWrap2.Count = sObjList.size();
                genericLienWrap2.objList =objList;
            }
            return genericLienWrap2;
        }
        catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'retrieveLienRecord', 'UCC_Lien__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }    
    }

	/**
	 * @update: BRS-6673 | BRS-6319
	 * Update the CSV logic to sort based on onlineenquiry
	 * Additional logic to pull in Secured Party
	 */
    @AuraEnabled
    public static List<objWrapper> retrieveInfoForCSV(String searchObj) {
        List<objWrapper> objWrapList = new List<objWrapper>();
        SearchObjFromUIWrapper searchIndiDebtor = new SearchObjFromUIWrapper();
        SearchString wrapObj = new SearchString();
        BRS_online_enquiry__mdt onlineEnquiry =new BRS_online_enquiry__mdt();
        SearchObjFromUIWrapperNONDebtorInd searchNonDebtor = new SearchObjFromUIWrapperNONDebtorInd();
        
        if(searchObj != null){
            if(!searchObj.contains(System.Label.DebtorSearchIndividual)){
                searchNonDebtor = (searchObjFromUIWrapperNONDebtorInd) System.JSON.deserialize(searchObj,searchObjFromUIWrapperNONDebtorInd.class);
                onlineEnquiry = [
                    SELECT Search_Object__c,Search_Limit__c,Include_Filters__c,Download_Limit__c,Search_Object_fields__c,DeveloperName
                    FROM BRS_online_enquiry__mdt
                    WHERE DeveloperName =: String.escapeSingleQuotes(searchNonDebtor.type)
                    
                ];
            }
            else {
                searchIndiDebtor = (SearchObjFromUIWrapper) System.JSON.deserialize(searchObj,searchObjFromUIWrapper.class);
                wrapObj = searchIndiDebtor.searchString;
            
                onlineEnquiry = [
                    SELECT Search_Object__c,Search_Object_fields__c,Search_Limit__c,Include_Filters__c,Download_Limit__c,DeveloperName
                    FROM BRS_online_enquiry__mdt
                    WHERE DeveloperName =: String.escapeSingleQuotes(searchIndiDebtor.type)
                    
                ];
            }

            // For Lien Search CSV Download
            if(searchNonDebtor.type == 'LienSearch') { 
                objWrapList = retrieveLienExportRecords(searchNonDebtor, onlineEnquiry);
            }

            //BRS-6673 | Update on debtor search
            else if(searchNonDebtor.type!= 'Business_Search' && searchNonDebtor.type != 'LienSearch') {
                LienSearchWrapper searchWrapper = System.Label.DebtorSearchIndividual.equalsIgnoreCase(searchIndiDebtor.type)
                    ? new LienSearchWrapper(searchIndiDebtor) //indi
                    : new LienSearchWrapper(searchNonDebtor); //org
                    
                objWrapList = retrieveDebtorInfo(onlineEnquiry, searchWrapper, true).objList;
            }
        }

        return objWrapList;
    }
    
    @TestVisible
    private static List<ObjWrapper> retrieveLienExportRecords(SearchObjFromUIWrapperNONDebtorInd searchNonDebtor, BRS_online_enquiry__mdt onlineEnquiry) {
        List<objWrapper> objWrapList = new List<objWrapper>();
        List<String> filterTypes = new List<String> { 
            System.label.brs_uccFilingStatus, 
            System.label.In_Progress_Label
        };
        List<String> typeFilterOptions = new List<String>();
        Boolean includeLapseLien = false;
        
        if(searchNonDebtor.filters != null) {
            for(filterWrapper filter :searchNonDebtor.filters) {
                if(filter.type == 'Type__c') {
                    typeFilterOptions = filter.selectedOptions;
                } else if(filter.selectedOptions.contains(System.label.Include_Lapsed_Liens_Label)) {
                    includeLapseLien = true;
                }
            }
        }

        String queryString = 'SELECT Type__c,UCC_Lien_Number__c,' + onlineEnquiry.Search_Object_fields__c 
            + ' FROM '+ onlineEnquiry.Search_Object__c
            + ' WHERE Status__c!=\''+System.Label.BRS_Archived+'\''
            + ' AND UCC_Lien_Number__c=\'' + searchNonDebtor.searchString+'\'';
        queryString += !typeFilterOptions.IsEmpty()
            ? ' AND Type__c IN: typeFilterOptions'
            : '';
        queryString += !includeLapseLien
            ? ' AND Lapse_Date__c >= TODAY'
            : '';
            queryString += ' WITH SECURITY_ENFORCED';
            System.debug('----------------'+queryString);
        List<Sobject> sObjList = Database.query(queryString);

        if(!sObjList.IsEmpty() && sObjList.size() == 1) {
            UCC_Lien__c lien = (UCC_Lien__c) sObjList.get(0);
            String lienNumber = lien.UCC_Lien_Number__c;
            String lienType = lien.Type__c;
            String lapseDate = lien.Lapse_Date__c != null 
                ? Date.valueOf(lien.Lapse_Date__c).format() 
                : null;
            List<UCC_Filing__c> listFilings = (List<UCC_Filing__c>) lien.getSObjects('UCC_Filings__r');
            
            if(!listFilings.isEmpty()) {
                List<RequestForInformationController.FilingWrapper> listOFSFilings = new List<RequestForInformationController.FilingWrapper>();
                Map<Id, List<UCC_Filing__c>> mapLienFilings = new Map<Id, List<UCC_Filing__c>>();
                Map<Id, List<String>> mapFilingDebtors = new Map<Id, List<String>>();
                Map<Id, List<String>> mapFilingSecuredParties = new Map<Id, List<String>>();
                
                List<String> listChildTypes = new List<String>();
                listChildTypes.addAll(RequestForInformationController.listDebtorTypes);
                listChildTypes.addAll(RequestForInformationController.listSecuredParties);
                
                for(UCC_Filing__c filing : [
                    SELECT Id, Type__c, Filing_Date__c, Filing_Number__c, UCC_Lien_Id__c,
                        (
                            SELECT Type__c, Name__c, Filing_Id__c
                            FROM UCC_Related_Info__r
                            WHERE Status__c = :System.Label.UCC_CONTACTS_STATUS
                                AND Type__c IN :listChildTypes
                                AND UCC_Related_Info__c = null
                                AND Deleted_Flag__c = false	
                        )
                    FROM UCC_Filing__c
                    WHERE Id IN :listFilings
                    WITH SECURITY_ENFORCED
                    ORDER BY Filing_Date__c ASC
                ]) {
                    //all ofs filings
                    if(!RequestForInformationController.setAmendmentTypes.contains(filing.Type__c)) {
                        listOFSFilings.add(new RequestForInformationController.FilingWrapper(filing, null));
                    }

                    //All filings grouped by lien id
                    if(!mapLienFilings.containsKey(filing.UCC_Lien_Id__c)) {
                        mapLienFilings.put(filing.UCC_Lien_Id__c, new List<UCC_Filing__c>());
                    }
                    mapLienFilings.get(filing.UCC_Lien_Id__c).add(filing);

                    for(UCC_Related_Info__c relatedInfo :filing.UCC_Related_Info__r) {
                        //Debtor
                        if(RequestForInformationController.listDebtorTypes.contains(relatedInfo.Type__c)) {
                            if(!mapFilingDebtors.containsKey(relatedInfo.Filing_Id__c)) {
                                mapFilingDebtors.put(relatedInfo.Filing_Id__c, new List<String>());
                            }
                            mapFilingDebtors.get(relatedInfo.Filing_Id__c).add(relatedInfo.Name__c);
                        } 
                        //Secured Party
                        else {
                            if(!mapFilingSecuredParties.containsKey(relatedInfo.Filing_Id__c)) {
                                mapFilingSecuredParties.put(relatedInfo.Filing_Id__c, new List<String>());
                            }
                            mapFilingSecuredParties.get(relatedInfo.Filing_Id__c).add(relatedInfo.Name__c);
                        }
                    }
                }

                //Sort based on filing date
                listOFSFilings.sort();

                //group filings based on OFS oldest to newest
                for(RequestForInformationController.FilingWrapper filingWrapper :listOFSFilings) {
                    for(UCC_Filing__c filing : mapLienFilings.get(filingWrapper.filing.UCC_Lien_Id__c)) {
                        objWrapper wrapper = new objWrapper(lienNumber, lienType, lapseDate, filing);
                        wrapper.debtorName = mapFilingDebtors.containsKey(filing.Id)
                            ? String.join(mapFilingDebtors.get(filing.Id), ',')
                            : '';
                        wrapper.securedParty = mapFilingSecuredParties.containsKey(filing.Id)
                            ? String.join(mapFilingSecuredParties.get(filing.Id), ',')
                            : '';

                        objWrapList.add(wrapper);
                    }
                }
            }
        }

        return objWrapList;
    }
    @AuraEnabled
    public static  list<filingRelatedInfoWrap> retrieveUCCRelatedRecord(string FilingNumber) {
        list<UCC_Filing__c > lstuccrel = new list<UCC_Filing__c>();
        list<filingRelatedInfoWrap> wrapList = new list<filingRelatedInfoWrap>();
        Set<Id> FilingIds = new Set<Id>();
        
        try {
            lstuccrel = [SELECT Id, Name,toLabel(Type__c),Start_Page__c,Filing_Number__c,Filing_Date__c,Lapse_Date__c,Microfilm_volume_number__c,Pages__c,IRS_SLID_Number__c,
                         (Select Secured_Party_ID__r.Assignor_Name__c,Assignor_ID__c,Secured_Party_ID__c,Filing_ID__c from UCC_Assignee_Info__r),
                         (Select Id,Type__c,Address__c,City__c,Country__c,Unit__c,Debtor_Is__c,Deleted_Flag__c,External_ID__c,Filing_Id__c,Individual_First_Name__c,Individual_Middle_Name__c,RecordTypeId,RecordType.DeveloperName,Individual_Salutation__c,Individual_SurName__c,International_Address__c,isAuthorizer__c,Name,Name__c,Org_Name__c,OwnerId,State__c,Status__c,Street__c,Suffix__c,UCC_Related_Info__c,Zip_Code__c,Assignor_Name__c from UCC_Related_Info__r),UCC_Lien_Id__r.UCC_Lien_Number__c, UCC_Lien_Id__r.Type__c,UCC_Lien_Id__r.Lapse_Date__c,UCC_Lien_Type__c
                         FROM  UCC_Filing__c where Filing_Number__c =: FilingNumber WITH SECURITY_ENFORCED];//Filing_Number__c
            for(UCC_Filing__c uccFile : lstuccrel){
                filingRelatedInfoWrap wrapInst = new filingRelatedInfoWrap();
                FilingRecordWrapper frw = new FilingRecordWrapper();
                frw.LienType=uccFile.UCC_Lien_Id__r.Type__c; 
                frw.IRSNumber=uccFile.IRS_SLID_Number__c; 
                frw.Type=uccFile.Type__c; 
                frw.FilingNumber=uccFile.Filing_Number__c; 
                frw.FilingDate=uccFile.Filing_Date__c; 
                if(uccFile.Lapse_Date__c!=null){
                frw.LapseDate=uccFile.Lapse_Date__c; 
                }
                frw.VolumeNumber=uccFile.Microfilm_volume_number__c; 
                frw.StartPage=uccFile.Start_Page__c;   
                frw.Page= uccFile.Pages__c; 
                List<RelatedInfoWrapper> riwList = new List<RelatedInfoWrapper>();
                for(UCC_Related_Info__c uri: uccFile.UCC_Related_Info__r){
                    RelatedInfoWrapper riw = new RelatedInfoWrapper();
                    riw.Name = uri.Name__c;
                    riw.InternationalAddress = uri.International_Address__c;
                    riw.Country = uri.Country__c;
                    riw.Street = uri.Street__c;
                    riw.City = uri.City__c;
                    riw.State = uri.State__c;
                    riw.Zipcode = uri.Zip_Code__c;
                    riw.AssignorName = uri.Assignor_Name__c;
                    riw.Unit = uri.Unit__c;
                    riw.Type = uri.Type__c;
                    riwList.add(riw);
                }    
                frw.relatedList=  riwList;       
                wrapInst.FilingRec = frw;
                FilingIds.add(uccFile.Id);
                Map<Id,String> filingDocMap = brs_onlineEnquiryBusinessSearchBusCls.getFilingRelatedDocs(FilingIds,'UCC');
                wrapInst.publicLink = filingDocMap.containsKey(uccFile.Id)?filingDocMap.get(uccFile.Id):null;
                wrapList.add(wrapInst);
            }
            return wrapList;
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'retrieveUCCRelatedRecord', 'UCC_Filing__c', null, 'medium', ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

   
    public static String encrypt(String toEncrypt){
        BRS_Encryption_Key_Setting__c setting = BRS_Encryption_Key_Setting__c.getInstance();
        Blob cryptoKey = EncodingUtil.base64Decode(setting.Crypto_Key__c);
        
        Blob data = Blob.valueOf(toEncrypt);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        String encryptedDataStr = EncodingUtil.base64Encode(encryptedData);
        
        return encryptedDataStr;
    }

   
    public static String decrypt(String toDecrypt){
        Blob encryptedData = EncodingUtil.base64Decode(toDecrypt);
        BRS_Encryption_Key_Setting__c setting = BRS_Encryption_Key_Setting__c.getInstance();
        Blob cryptoKey = EncodingUtil.base64Decode(setting.Crypto_Key__c);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
        return decryptedData.toString();
    }

    @AuraEnabled
    public static InterfaceConfigWrapper fetchInterfaceConfig(String labelName){
        Interface_Configuration__mdt interfaceConfig;
        InterfaceConfigWrapper icw = new InterfaceConfigWrapper();
        try{
            if(String.isNotBlank(labelName)) {
                interfaceConfig = [
                    SELECT Current_Environment__c,MasterLabel,Id,End_URL__c,ForgeRock_End_URL__c
                    FROM Interface_Configuration__mdt
                    WHERE MasterLabel =:labelName 
                        AND Current_Environment__c =: System.Label.CURRENT_ENVIRONMENT
                ];  
               
                icw.endUrl = interfaceConfig.End_URL__c;
                icw.forgeRockEndUrl = interfaceConfig.ForgeRock_End_URL__c;
            }
            return icw;
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'fetchInterfaceConfig','Interface_Configuration__mdt',null,'medium',e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    public class InterfaceConfigWrapper {
        @AuraEnabled public string endUrl{get;set;}
		@AuraEnabled public string forgeRockEndUrl{get;set;}
		  
    }
    public class GenericSearchWrapper {
        @AuraEnabled public Integer Count{get;set;}
		@AuraEnabled public Integer actualCount{get;set;}
		private Boolean hasSameDebtorName{get;set;}
        @AuraEnabled public List<objWrapper> objList{get;set;}  
    }  
    
    public class objWrapper{
        @AuraEnabled public String debtorName{get;set;}
        private String debtorNameIndexed{get;set;}
        @AuraEnabled public Set<String> LienIDs{get;set;}
		@AuraEnabled public Set<String> LienIDsForOrgIndexed{get;set;}
        @AuraEnabled public Integer lienCountForDebtor{get;set;}
        @AuraEnabled public String lienType{get;set;}
        @AuraEnabled public String lapseDate  {get;set;}
        @AuraEnabled public String lienNumber {get;set;}
    //    @AuraEnabled public String IRSNumber {get;set;}
    //    @AuraEnabled public String lienSfId {get;set;}
        @AuraEnabled public List<relatedFilingWrapper> relatedFilingLst {get;set;}
        @AuraEnabled public Boolean activeLien{get;set;}
        @AuraEnabled public Boolean LapsedLien{get;set;}
    //    @AuraEnabled public String filingNumber{get;set;}
    //    @AuraEnabled public String filingType{get;set;}
        @AuraEnabled public String OFSFilingDate{get;set;}
    //    @AuraEnabled public String filingDate{get;set;}
        private String securedParty{get;set;} //BRS-6139 | Add secured parties

        public ObjWrapper() {}
		public ObjWrapper(String lienNumber, String lienType, String lapseDate, UCC_Filing__c filing) { //for lien search CSV
            this.lienNumber = lienNumber;
            this.lienType = lienType;
            this.lapseDate = lapseDate;

    //        this.filingNumber = filing.Filing_Number__c;
    //        this.filingType = filing.Type__c;
    //        this.filingDate = filing.Filing_Date__c != null ? Date.valueOf(filing.Filing_Date__c).format() : null;
        }

        public ObjWrapper(UCC_Related_Info__c relatedInfo) { //for debtor CSV
            this.debtorName = relatedInfo.Name__c;
            this.lienNumber = relatedInfo.Filing_Id__r.UCC_Lien_Id__r.UCC_Lien_Number__c;
    //        this.filingNumber = relatedInfo.Filing_Id__r.Filing_Number__c;
            this.lienType = relatedInfo.Filing_Id__r.UCC_Lien_Id__r.Type__c;
    //        this.filingType = relatedInfo.Filing_Id__r.Type__c;
    //        this.filingDate = relatedInfo.Filing_Id__r.Filing_Date__c != null ? Date.valueOf(relatedInfo.Filing_Id__r.Filing_Date__c).format() : null;

        }
    }
    
    public class searchObjFromUIWrapper{
        @AuraEnabled public SearchString searchString{get;set;}
        @AuraEnabled public String type{get;set;}  
        @AuraEnabled public List<filterWrapper> filters{get;set;}
        @testVisible private Boolean isStartsWithSearch;
    }
    
    public class searchObjFromUIWrapperNONDebtorInd{
        @AuraEnabled public String searchString {get;set;}
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public List<FilterWrapper> filters {get;set;}
        @testVisible private Boolean isStartsWithSearch;
    }

    //BRS-6673 | common wrapper class
    public class LienSearchWrapper {
        public String orgName;
        public String lastName;
        public String firstName;
        public String type;
        public List<FilterWrapper> filters;
        public Boolean isStartsWithSearch;

        public LienSearchWrapper(searchObjFromUIWrapperNONDebtorInd searchOrgDebtor) {
            this.orgName = searchOrgDebtor.searchString;
            this.type = System.Label.DebtorSearchOrganisation;
            this.isStartsWithSearch = searchOrgDebtor.isStartsWithSearch;
            this.filters = searchOrgDebtor.filters;
        }

        public LienSearchWrapper(searchObjFromUIWrapper searchIndiDebtor) {
            this.lastName = searchIndiDebtor.searchString.surName;
            this.firstName = searchIndiDebtor.searchString.firstName;
            this.type = System.Label.DebtorSearchIndividual;
            this.isStartsWithSearch = searchIndiDebtor.isStartsWithSearch;
            this.filters = searchIndiDebtor.filters;
        } 
    }
    
    public class SearchString{
        @AuraEnabled public String surName{get;set;}
        @AuraEnabled public String firstName{get;set;}
    }
    public class relatedFilingWrapper{
        @AuraEnabled public String filingNumber {get;set;} 
        @AuraEnabled public String filingDate {get;set;}
        @AuraEnabled public String filingType {get;set;}
    //    @AuraEnabled public String filingSfId {get;set;}
        @AuraEnabled public String volume {get;set;}
        @AuraEnabled public String pages {get;set;}
    }
    
    public class filterWrapper{ 
        @AuraEnabled public String type {get;set;} 
        @AuraEnabled public List<String> selectedOptions{get;set;}
    }

    public class filterTypeWrapper{
    //    @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String MasterLabel {get;set;}
        @AuraEnabled public String apiName {get;set;}
        @AuraEnabled public String filterIcon{get;set;}
        @AuraEnabled public String dataType{get;set;}
        @AuraEnabled public String searchType{get;set;}
        @AuraEnabled public List<filterOptionWrapper> filterOptions{get;set;}

     public   FilterTypeWrapper(){}

     public   FilterTypeWrapper(BRS_online_enquiry_Filters__mdt type, List<filterOptionWrapper> filterOptions) {
    //        this.Id = type.Id;
            this.apiName = type.API_Name__c;
            this.filterIcon = type.Filter_Icon__c;
            this.dataType = type.Data_Type__c;
            this.searchType = type.Search_Type__c;
            this.filterOptions = filterOptions;
        }
    }
    
    public class filterOptionWrapper implements Comparable{
    //    @AuraEnabled public String parentTypeId {get;set;}
    //    @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String MasterLabel {get;set;}
        @AuraEnabled public String picklistApiName {get;set;}
        @AuraEnabled public Decimal order {get;set;}
        
        FilterOptionWrapper() {}

        FilterOptionWrapper(BRS_Online_Enquiry_Filter_Options__mdt typeOption) {
    //        this.parentTypeId = parentTypeId;
    //        this.Id = typeOption.Id;
            this.picklistApiName = typeOption.Picklist_API_Name__c;
            this.order = typeOption.Order__c;
        }

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            filterOptionWrapper compareToEmp = (filterOptionWrapper)compareTo;
            if (order == compareToEmp.order ){ return 0;}
            if (order > compareToEmp.order ){ return 1;}
            return -1;        
        }
    }
    //FinancialStatement Wrappers
    public class filingRelatedInfoWrap{
        @AuraEnabled public FilingRecordWrapper FilingRec{get;set;}
        @AuraEnabled public String publicLink{get;set;}
    }
    
    public class FilingRecordWrapper{
        @AuraEnabled public String LienType{get;set;}
        @AuraEnabled public String IRSNumber{get;set;}
        @AuraEnabled public String Type{get;set;}
        @AuraEnabled public String FilingNumber{get;set;}
        @AuraEnabled public Datetime FilingDate{get;set;}
        @AuraEnabled public Date LapseDate{get;set;}
        @AuraEnabled public String VolumeNumber{get;set;}
        @AuraEnabled public Decimal StartPage{get;set;}
        @AuraEnabled public String Page{get;set;}
        @AuraEnabled public List<RelatedInfoWrapper> relatedList{get;set;}
    }
    public class RelatedInfoWrapper{
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String AssignorName{get;set;}
        @AuraEnabled public String InternationalAddress{get;set;}
        @AuraEnabled public String Country{get;set;}
        @AuraEnabled public String Street{get;set;}
        @AuraEnabled public String City{get;set;}
        @AuraEnabled public String State{get;set;}
        @AuraEnabled public String Zipcode{get;set;}
        @AuraEnabled public String Unit{get;set;}
        @AuraEnabled public String Type{get;set;}
    }
}