public without sharing class brs_onlineEnquiryBusinessSearchBusCls {
    public static Final String className='brs_onlineEnquiryBusinessSearch';
    public static Final String getBusiness='getBusiness';
    public static Final String getBusinessDetails='getBusinessDetails';

    public class results{
        @AuraEnabled public Integer resultCount {get; set;}
        @AuraEnabled public Set<searchData> resultList {get; set;}
        @AuraEnabled public Boolean showAttentionCard{get;set;}  
    }

    public class nameWrapper{
        public String firstName {get; set;}
        public String surName {get; set;}
    }

    public class searchData{
        //Account Details
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String businessALEI {get;set;}
        @AuraEnabled
        public String connecticutAlei {get;set;}
        @AuraEnabled
        public String zipCode {get;set;}
        @AuraEnabled
        public String businessName{get;set;}
        @AuraEnabled
        public String businessAddress{get;set;}
        @AuraEnabled
        public String businessAgentName{get;set;}
        @AuraEnabled
        public String businessStatus{get;set;}
        @AuraEnabled
        public String businessPrincipalsNames{get;set;}
        @AuraEnabled
        public Integer businessPrincipalsCount{get;set;}
        @AuraEnabled
        public List<String> principalList{get;set;}
        @AuraEnabled
        public String citizenship{get;set;}
        @AuraEnabled
        public String entityType{get;set;}          
        
        
        //Filing Details
       /* @AuraEnabled
        public date filingDate{get;set;}
        @AuraEnabled
        public String filingName{get;set;}
        @AuraEnabled
        public String filingNumber{get;set;} */
    }

        
    public static results getBusiness(String searchString,String type, List<brs_genericSearchBusinessClass.filterWrapper> filterList,Boolean isExportClicked, String name) {
        try{
            List<String> accStatusNotIn = new List<String>{system.label.BRS_UCC_StatusInProgress,System.label.Rejected,System.label.businessProfile_credentialsPending,System.label.Label_Expired,System.label.Label_Expired_Reservation,System.label.Label_Pending_Filing_1,System.label.brsStatus_ReservedCancel};
            String searchType=type;
            String firstName;
            String lastName;
            nameWrapper nameWrapObj;
            Boolean isMaxLimit = false;
            Boolean showAttentionCard = false;
            integer  resultcount=0;
            List<string> searchAddress;
            if(!String.isBlank(name)){
                nameWrapObj = (nameWrapper)JSON.deserialize(name,nameWrapper.class);
                firstName = !String.isBlank(nameWrapObj.firstName)?nameWrapObj.firstName:null;
                lastName = searchStringCleanup(nameWrapObj.surName);
                if(firstName!=null){
                searchString = searchStringCleanup(firstName)+'%'+lastName;                
                }
                else{
                    searchString = lastName;
                }
            }
            else{
                if(searchType!='Business Address'){
                    searchString =searchStringCleanup(searchString);
                }                
            }
            if(!String.isBlank(searchString) && searchString.contains(System.Label.Connecticut_ALEI_Prefix)){
                searchString = searchString.remove(System.Label.Connecticut_ALEI_Prefix);
            }
            results returnObj = new results();
            Set<searchData> brsBusDtList = new Set<searchData>();
            Map<Id,Principal__c> accIdPrincipalMap = new Map<Id,Principal__c>();
            Map<Id,String> accIdAgentNameMap = new Map<Id,String>();
            /** use metadata for limit **/
            BRS_online_enquiry__mdt onlineEnquiry = new BRS_online_enquiry__mdt();            
            Set<String> accIdSet = new Set<String>();
            Set<String> accNameHistIdSet = new Set<String>();
            if(!String.isBlank(searchString)){
            List<String> statuses = new List<String>();
            for(BRS_Online_Enquiry_Filter_Options__mdt mdttype : [SELECT Id, DeveloperName, MasterLabel, Label, BRS_Online_Enquiry_Filter_option__r.developername FROM BRS_Online_Enquiry_Filter_Options__mdt where BRS_Online_Enquiry_Filter_option__r.developername = 'Business_Status']){
                statuses.add(mdttype.Label);
            }
            String accPrincipalAgentQuery;
            String accPrincipalSearchQuery;
            String accAgentSearchQuery;
            String accFilingSearchQuery;
            String businessCityWhereClause;
            String businessNameWhereClause;
            String businessIdWhereClause;
            String businessAddressWhereClause; 
            String nameHistoryQuery;   
            String resultCountquery ;
            
            system.debug('searchString---'+searchString);
            String searchQuery = 'FIND \'*' + searchString+ '*\'  IN All FIELDS returning ';
                String whereClause;
                if(String.isBlank(searchType)){
                    searchQuery = searchQuery+' account (id,name,accountnumber,Status__c,Principle_Office_International_Address__c,BillingCity, BillingStreet, BillingState, BillingPostalCode,Connecticut_Alei__c) ,  business_filing__c(name,account__r.name,account__c,Filing_Date__c,Type__c),Name_Change_History__c(id,Account__c)  ' ;
                } 
                else if(searchType=='Business Name'){
                    businessNameWhereClause = ' and (Account_Name_Without_Designators__c like \''+searchString+'%\' OR Id in:accNameHistIdSet)  '; 
                    nameHistoryQuery = 'Select Id,Account__c from Name_Change_History__c where Account__r.status__c not in:accStatusNotIn AND Account__r.Reserved_Name_Used__c != true AND Business_Name_Old_Indexed__c like \''+searchString+'%\' '; 
                    
                } 
                else if(searchType=='Business Address'){
                    if(searchString.contains(',')){
                        searchAddress = searchString.split(',');
                    }
                    if(searchAddress!=null){
                        businessAddressWhereClause = ' and ( BillingCity in :searchAddress or  BillingStreet in :searchAddress or  BillingState in :searchAddress or  BillingPostalCode in :searchAddress or  BillingCountry in :searchAddress)';
                    }
                    else{
                        businessAddressWhereClause = ' and ( BillingCity like \'%'+searchString+'%\' or  BillingStreet like \'%'+searchString+'%\' or  BillingState like \'%'+searchString+'%\' or  BillingPostalCode like \'%'+searchString+'%\' or  BillingCountry like \'%'+searchString+'%\')';
                        }
                    }
                    else if(searchType=='Business ALEI'){
                        businessIdWhereClause = ' and accountnumber = \''+searchString+'\'';  
                    }
                    else if(searchType=='Filing Number'){
                    accFilingSearchQuery  = 'select id,account__c from business_filing__c where Sdoc_Filing_Number__c =\''+searchString+'\'';
                    
            } 
            else if(searchType=='Principal Name'){
                
                if(nameWrapObj!=null){ 
                    system.debug('@@nameWrapObj'+nameWrapObj);
                    if(String.isBlank(firstName) && !string.isBlank(lastName)){
                        accPrincipalSearchQuery = 'Select Id, Name__c,Business_ID__c from Principal__c where Last_Name_Indexed__c = \''+searchString+'\'';
                        System.debug('@@accPrincipalSearchQuery'+'Select Id, Name__c,Business_ID__c from Principal__c where Last_Name_Indexed__c = \''+searchString+'\'');
                    }
                    else if (!String.isBlank(firstName)){
                         accPrincipalSearchQuery = 'Select Id, Name__c,Business_ID__c from Principal__c where Principal_Name_Indexed__c like \''+searchString+'\' and Last_Name_Indexed__c  = \''+lastName+'\'';
                    }
                }   
                else{

                    accPrincipalSearchQuery = 'Select Id, Name__c,Business_ID__c from Principal__c where Principal_Name_Indexed__c like \''+searchString+'%\'';
                }
            }
            else if(searchType=='Agent Name'){
                if(nameWrapObj!=null ){
                    if(String.isBlank(firstName) && !string.isBlank(lastName)){
                        accAgentSearchQuery = 'Select Id, Name__c,Business_ID__c from Agent__c where Last_Name_Indexed__c   = \''+searchString+'\'';
                    }
                    else if (!String.isBlank(firstName)){
                        accAgentSearchQuery = 'Select Id, Name__c,Business_ID__c from Agent__c where Agent_Name_Indexed__c like \''+searchString+'\'  and Last_Name_Indexed__c  = \''+lastName+'\'';
                    }
                }
                else{
                	accAgentSearchQuery = 'Select Id, Name__c,Business_ID__c from Agent__c where Agent_Name_Indexed__c like \''+searchString+'%\'';
                }
            }
            else if(searchType=='Business City'){
                
                businessCityWhereClause = ' AND (Billing_City_Indexed__c = \''+searchString+'\')';
            }
            
            
            onlineEnquiry = [Select Search_Object__c,Search_Limit__c,Include_Filters__c,Inner_Query_Limit__c,Download_Limit__c,Search_Object_fields__c,DeveloperName from BRS_online_enquiry__mdt where DeveloperName ='Business_Search' limit 1];
            integer queryLimit = (integer)(isExportClicked ?  onlineEnquiry.Download_Limit__c : onlineEnquiry.Search_Limit__c);
            integer innerqueryLimit = (integer)onlineEnquiry.Inner_Query_Limit__c;
            if(searchString != '' && searchString != null){
                if(String.isBlank(searchType)){ 
                    searchQuery = whereClause!=null ?  searchQuery + whereClause:  searchQuery;
                    List<List<sObject>> searchAccountFiling = search.query(searchQuery);
                    List<Account> accountList = New List<Account>();
                    List<Business_Filing__c> busFilingList = New List<Business_Filing__c>();
                    List<Name_Change_History__c> nameChangeList = new List<Name_Change_History__c>();
                    accountList = ((List<Account>)searchAccountFiling[0]);
                    busFilingList = ((List<Business_Filing__c>)searchAccountFiling[1]);
                    nameChangeList = (List<Name_Change_History__c>)searchAccountFiling[2];
                    if(!accountList.isEmpty()){
                        for(Account accObj : accountList){
                            accIdSet.add(accObj.Id);
                        }
                    }
                    if(busFilingList!=null){
                        for(Business_Filing__c  filingObj : busFilingList){
                            accIdSet.add(filingObj.Account__c);
                        }
                    }
                    if(nameChangeList!=null){
                        for(Name_Change_History__c  nhObj : nameChangeList){
                            accIdSet.add(nhObj.Account__c);
                        }
                    }
                }
                else{
                    if( searchType=='Principal Name'){ 
                        accPrincipalSearchQuery = accPrincipalSearchQuery + ' WITH SECURITY_ENFORCED';
                        List<Principal__c> princiAccList = Database.query(accPrincipalSearchQuery);
                        system.debug('@@princiAccList'+princiAccList);
                        if(Limits.getQueryRows()>25000){
                            isMaxLimit  = true;
                        }
                        if(!princiAccList.isEmpty()){
                            for(Principal__c data: princiAccList)
                            {
                                String accID = data.Business_ID__c; 
                                accIdSet.add(accID);
                            }
                        }
                        else{
                            returnObj.resultCount = 0;
                            return returnObj;
                        }
                        
                    }
                    else if( searchType=='Agent Name'){ 
                        accAgentSearchQuery = accAgentSearchQuery + ' WITH SECURITY_ENFORCED';
                        List<Agent__c> agentAccList = Database.query(accAgentSearchQuery);
                        if(Limits.getQueryRows()>25000){
                            isMaxLimit  = true;
                        }
                        if(!agentAccList.isEmpty()){
                            for(Agent__c data: agentAccList)
                            {
                                String accID = data.Business_ID__c; 
                                accIdSet.add(accID);
                            }
                        }
                        else{
                            returnObj.resultCount = 0;
                            return returnObj;
                        }
                        
                    }
                    else if( searchType=='Filing Number'){ 
                        accFilingSearchQuery = accFilingSearchQuery +' WITH SECURITY_ENFORCED';
                        List<Business_filing__c> filingAccList = Database.query(accFilingSearchQuery);
                        if(!filingAccList.isEmpty()){
                            for(Business_filing__c data: filingAccList)
                            {
                                String accID = data.Account__c; 
                                accIdSet.add(accID);
                            }
                        }
                        else{
                            returnObj.resultCount = 0;
                            return returnObj;
                        }
                    }  
                    else if( searchType=='Business Name'){ 
                        nameHistoryQuery = nameHistoryQuery + ' WITH SECURITY_ENFORCED';
                        List<Name_Change_History__c> nameHistoryList = Database.query(nameHistoryQuery);
                        if(!nameHistoryList.isEmpty()){
                            for(Name_Change_History__c data: nameHistoryList)
                            {
                                String accID = data.Account__c; 
                                accNameHistIdSet.add(accID);
                            }
                        }                        
                    }             
                }
                if(!accIdSet.isEmpty()){
                    accPrincipalAgentQuery = 'Select id,name,accountnumber,citizenship__c,Business_Type__c ,Status__c,Principle_Office_International_Address__c,BillingCity, BillingStreet, BillingState, BillingPostalCode,BillingCountry,Connecticut_Alei__c,Billing_Unit__c, (Select Id, Name__c,Business_ID__c from Principals__r Limit 25),(Select Agent_Name__c,name__c,Business_ID__c from Agents__r Limit 1) from Account where id in:accIdSet AND Status__c not in:accStatusNotIn  AND Reserved_Name_Used__c != true AND Is_Intake_Filing__c!=true ';
                    resultCountquery = 'select count() from account where id in:accIdSet AND Status__c != null AND Status__c not in:accStatusNotIn  AND Reserved_Name_Used__c != true AND Is_Intake_Filing__c!=true ';
                    
                }
               else if(!String.isBlank(searchType)){
                    accPrincipalAgentQuery = 'Select id,name,accountnumber,citizenship__c,Business_Type__c ,Status__c,Principle_Office_International_Address__c,BillingCity, BillingStreet, BillingState, BillingPostalCode,BillingCountry,Connecticut_Alei__c,Billing_Unit__c, (Select Id, Name__c,Business_ID__c from Principals__r Limit 25),(Select Agent_Name__c,name__c,Business_ID__c from Agents__r Limit 1 ) from Account where Status__c not in:accStatusNotIn AND Reserved_Name_Used__c != true AND Is_Intake_Filing__c!=true ';
                	resultCountquery = 'select count() from account where Status__c not in:accStatusNotIn  AND Reserved_Name_Used__c != true AND Is_Intake_Filing__c!=true ';
                }
                if(searchType=='Business City'){
                    accPrincipalAgentQuery = accPrincipalAgentQuery+ businessCityWhereClause;
                    resultCountquery = resultCountquery+businessCityWhereClause;
                }
                else if(searchType=='Business ALEI'){
                    accPrincipalAgentQuery = accPrincipalAgentQuery + businessIdWhereClause;
                    resultCountquery = resultCountquery+businessIdWhereClause;
                }
                else if(searchType=='Business Name'){
                    accPrincipalAgentQuery = accPrincipalAgentQuery + businessNameWhereClause;
                    resultCountquery = resultCountquery+businessNameWhereClause;
                }
                else if(searchType=='Business Address'){
                    accPrincipalAgentQuery = accPrincipalAgentQuery + businessAddressWhereClause;
                    resultCountquery = resultCountquery+businessAddressWhereClause;
                }
            
	       	String filterWhereClause='';
                
                List<String> busStatusOptions = new List<String>();
                List<String> busTypeOptions = new List<String>();
                List<String> busEntityOptions = new List<String>();
                if(!filterList.isEmpty()){
                    for(brs_genericSearchBusinessClass.filterWrapper filObj : filterList){
                        if(filObj.type == 'Business Start Date' && !filObj.selectedOptions.isEmpty())
                        {
                            List<String> selectedOptions = filObj.selectedOptions;
                            Date startDate = selectedOptions[0]!=null?date.valueof(selectedOptions[0]):null;
                            if(startDate!=null){
                                filterWhereClause = filterWhereClause+' and Date_Registration__c>=:startDate ';
                            }
                        }
                        if(filObj.type == 'Business End Date' && !filObj.selectedOptions.isEmpty())
                        {
                            List<String> selectedOptions = filObj.selectedOptions;
                            Date endDate = selectedOptions[0]!=null?date.valueof(selectedOptions[0]):null;
                            filterWhereClause = filterWhereClause+' and Date_Registration__c<=:endDate';
                        }
                        if(filObj.type == 'Business Status' && !filObj.selectedOptions.isEmpty())
                        {
                            busStatusOptions = filObj.selectedOptions;
                            filterWhereClause = filterWhereClause+'  and status__c in:busStatusOptions ';
                        }
                        if(filObj.type == 'Business Type' && !filObj.selectedOptions.isEmpty())
                        {
                            busTypeOptions = filObj.selectedOptions;
                            filterWhereClause = filterWhereClause+' and citizenship__c in :busTypeOptions ';
                        }
                        if(filObj.type == 'Entity Type' && !filObj.selectedOptions.isEmpty())
                        {
                            busEntityOptions = filObj.selectedOptions;
                            filterWhereClause = filterWhereClause+'  and business_type__c =:busEntityOptions ';
                        }
                    }
                    
                    accPrincipalAgentQuery = accPrincipalAgentQuery + filterWhereClause;
                    resultCountquery = resultCountquery+filterWhereClause;
                }
                if(resultCountquery!=null){
                    resultcount = database.countQuery(resultCountquery);
                }
                List<Account> accountPAList = new  List<Account>();
                if(accPrincipalAgentQuery!=null){
                    if(isMaxLimit || resultcount>25000 ||  ( resultcount>1000 && (searchType=='Business Address' ||  searchType=='Business City'))){ 
                        showAttentionCard = true;
                        accPrincipalAgentQuery += ' WITH SECURITY_ENFORCED LIMIT 10000';
                    }
                    else{
                        accPrincipalAgentQuery += ' WITH SECURITY_ENFORCED LIMIT 1000';
                    }
                    accountPAList = Database.query(accPrincipalAgentQuery);
                }               
                
                Map<Id,Account> accountPAMap = new Map<Id,Account>();
                if(!accountPAList.isEmpty()){
                    for(Account accObj : accountPAList){
                        //if(accountPAMap.get(accObj.Id)==null){
                        accountPAMap.put(accObj.Id,accObj);
                        accIdSet.add(accObj.Id);
                        //}
                    }
                }
                if(!accIdSet.isEmpty()){
                    for(Id accId : accIdSet){
                        Account accObj = accountPAMap.get(accId);
                        if(accObj!=null){
                            if(accObj.Status__c != null && accObj.Status__c != '' && accObj.Status__c != system.label.BRS_UCC_StatusInProgress){
                                List<String> principalStringList = new List<String>();
                                searchData businessResultObj = new searchData();
                                Agent__c agentObj = new Agent__c();
                                String principalsNamesAndCount = '';
								Map<String,String>  labelMaps = new Map<String,String>();
                                labelMaps = getTranslatedMap();
                                Integer principalsCount=0;
                                if( accObj.getSObjects('Principals__r')!=null){
                                    List<Principal__c> principalList =  (List<Principal__c>)accObj.getSObjects('Principals__r');
                                    principalsCount = principalList.size();
                                    //principalsCount = principalsCount-2;
                                    Integer count = 0;
                                    for(Principal__c principalObj : principalList){
                                        principalStringList.add(principalObj.name__c);
                                        accIdPrincipalMap.put(accObj.Id,principalObj);
                                        if(count < 2){
                                            principalsNamesAndCount = principalsNamesAndCount != '' ? principalsNamesAndCount + ', ' + principalObj.Name__c : principalObj.Name__c;
                                            count = count + 1;
                                        } else {
                                            break;
                                        }
                                    }
                                }
                                if(accObj.getSObjects('Agents__r')!=null){
                                    List<Agent__c> agentList =  (List<Agent__c>)accObj.getSObjects('Agents__r');
                                    agentObj = (Agent__c)agentList[0];
                                }
                                if(!isExportClicked){
                                    List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
                                    businessResultObj.businessAddress = accObj.Principle_Office_International_Address__c!= null && accObj.BillingCountry!=null ? accObj.Principle_Office_International_Address__c + ', ' + accObj.BillingCountry: BRS_Utility.getAddress(accObj, billingAddrFields);
                                    businessResultObj.accountId = accObj.Id;
                                    businessResultObj.businessALEI = accObj.accountnumber;
                                    businessResultObj.connecticutAlei = accObj.Connecticut_Alei__c;
                                    businessResultObj.zipCode = accObj.BillingPostalCode!=null?accObj.BillingPostalCode:accObj.BillingPostalCode;
                                    businessResultObj.businessName = accObj.Name;
                                    businessResultObj.businessAgentName = agentObj.Name__c!=null?agentObj.Name__c:null;
                                    businessResultObj.businessStatus = accObj.Status__c!=null? (labelMaps.containsKey(accObj.Status__c)? labelMaps.get(accObj.Status__c).toUppercase() : accObj.Status__c.toUppercase() ) : null;    //accObj.Status__c.toUppercase():null;
                                    businessResultObj.businessPrincipalsNames = principalsNamesAndCount;
                                    businessResultObj.businessPrincipalsCount = principalsCount;
                                    businessResultObj.principalList = principalStringList;
                                    
                                }
                                else{
                                    businessResultObj.businessALEI = accObj.accountnumber;
                                    businessResultObj.connecticutAlei = accObj.Connecticut_Alei__c;
                                    businessResultObj.businessName = accObj.Name;
                                    businessResultObj.citizenship = accObj.Citizenship__c!=null?accObj.Citizenship__c:null; 
                                    businessResultObj.entityType = accObj.Business_Type__c!=null?accObj.Business_Type__c:null;
                                    List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
                                    businessResultObj.businessAddress = accObj.Principle_Office_International_Address__c!= null && accObj.BillingCountry!=null ? accObj.Principle_Office_International_Address__c + ', ' + accObj.BillingCountry: BRS_Utility.getAddress(accObj, billingAddrFields);
                                    businessResultObj.businessStatus = accObj.Status__c!=null? (labelMaps.containsKey(accObj.Status__c)? labelMaps.get(accObj.Status__c).toUppercase() : accObj.Status__c.toUppercase() ) : null;    //accObj.Status__c.toUppercase():null;
                                    businessResultObj.businessPrincipalsNames = principalsNamesAndCount;
                                    businessResultObj.businessAgentName = agentObj.Name__c!=null?agentObj.Name__c:null;
                                    
                                }
                                brsBusDtList.add(businessResultObj); 
                            } 
                        }
                    }
                }
            }
        }
        returnObj.resultCount = resultcount; //brsBusDtList.size();
        returnObj.resultList = brsBusDtList;
        returnObj.showAttentionCard = showAttentionCard	;
        return returnObj;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, getBusiness, null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class businessDetails{
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String businessId {get;set;}
        @AuraEnabled
        public String connecticutAlei {get;set;}
        @AuraEnabled
        public String businessName{get;set;}
        @AuraEnabled
        public String businessAddress{get;set;}
        @AuraEnabled
        public String businessAgentName{get;set;}
        @AuraEnabled
        public String businessStatus{get;set;}
        @AuraEnabled
        public String  dateFormed{get;set;}
        @AuraEnabled
        public String placeOfFormation{get;set;}
        @AuraEnabled
        public String businessType{get;set;}
        @AuraEnabled
        public String mailingAddress{get;set;}
        @AuraEnabled
        public String serviceOfProcessAddr{get;set;}
        @AuraEnabled
        public String annualReportDue{get;set;}
        @AuraEnabled
        public String lastReportFiled{get;set;}
        @AuraEnabled
        public String naicsCode{get;set;}
        @AuraEnabled
        public String naicsSubCode{get;set;}
        @AuraEnabled
        public String agentResidenceAddress{get;set;}
        @AuraEnabled
        public String agentBusinessAddress{get;set;}
        @AuraEnabled
        public String agentMailingAddress{get;set;}
        @AuraEnabled
        public Decimal totalShares{get;set;}
        @AuraEnabled
        public String officeInJurisdictionAddress{get;set;}
        @AuraEnabled
        public String mailingJurisdictionAddress{get;set;}
        
        @AuraEnabled public List<filingDetails> filingList {get; set;}
        @AuraEnabled public List<nameHistoryDetails> nameHistoryList {get; set;}
        @AuraEnabled public List<shareDetails> shareDetailsList {get; set;}
        @AuraEnabled public List<principalDetails> principalDetailsList {get; set;}
        
    }
    
    public class filingDetails{
        @AuraEnabled
        public String filingId{get;set;}
        @AuraEnabled
        public String filingDateTime{get;set;}
        @AuraEnabled
        public String filingTime{get;set;} //BRS-7631
        @AuraEnabled
        public String filingVolumeType{get;set;}
        @AuraEnabled
        public String filingPages{get;set;}
        @AuraEnabled
        public Integer filingVolume{get;set;}
        @AuraEnabled
        public String filingType{get;set;}
        @AuraEnabled
        public String filinTerminatedBusinessId{get;set;}
        @AuraEnabled
        public String filingTerminatedBusinessName{get;set;}
        @AuraEnabled
        public String filingTerminatedDate{get;set;}
        @AuraEnabled
        public String filingDigitalCopy{get;set;}
        // Added as part of BRS-5316
        @AuraEnabled
        public String startPage{get;set;}

        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-3772,3773,3770
        * Change(s)/Modification(s) Description : Added wrapper variable for search addition for mergers,conversions and domestication      
        * Change(s)/Modification(s) Made on : 05-08-2021
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        @AuraEnabled
        public boolean showViewDetailsBtn{get;set;}
        @AuraEnabled
        public String businessFilingId{get;set;}
        @AuraEnabled
        public String businessName{get;set;}
        @AuraEnabled
        public String businessId{get;set;}
        @AuraEnabled
        public String changingbusinessName{get;set;}
        @AuraEnabled
        public String changedbusinessName{get;set;}
        @AuraEnabled
        public String changingbusinessId{get;set;}
        @AuraEnabled
        public String changedbusinessId{get;set;}
        @AuraEnabled
        public String changingbusinesstype{get;set;}
        @AuraEnabled
        public String changedbusinesstype{get;set;}
        @AuraEnabled
        public String changingbusinessDate{get;set;}
        @AuraEnabled
        public String changedbusinessDate{get;set;}
        @AuraEnabled
        public String changedBusinessStateOrCountry{get;set;}
        @AuraEnabled
        public List<mergedAccountDetails> mergedAccountList{get;set;}
    }

    public class mergedAccountDetails{
        @AuraEnabled
        public String changingbusinessName{get;set;}
        @AuraEnabled
        public String changingbusinessId{get;set;}
        @AuraEnabled
        public String changingbusinesstype{get;set;}
        @AuraEnabled
        public String changingbusinessDate{get;set;}
    }
    
    public class nameHistoryDetails{
        @AuraEnabled
        public String nameHistoryNumber{get;set;}
        @AuraEnabled
        public String nameHistoryName{get;set;}
        @AuraEnabled
        public String nameHistoryfilingDate{get;set;}
    }
    
    public class shareDetails{
        @AuraEnabled
        public String shareClass{get;set;}
        @AuraEnabled
        public Decimal shareNumber{get;set;}
        @AuraEnabled
        public Decimal valuePerShare{get;set;}
    }
    public class principalDetails{
        @AuraEnabled
        public String businessPrincipalName{get;set;}
        @AuraEnabled
        public String principalResidenceAddress{get;set;}
        @AuraEnabled
        public String principalBusinessAddress{get;set;}
        @AuraEnabled
        public String principalTitle{get;set;}
    }

    
    public static businessDetails getBusinessDetails(String accountId){
        try{
            businessDetails businessDetailsObj = new businessDetails();
            Set<String> typeToShowViewDetailsButton = new Set<String>{System.Label.Domestication_Label, System.Label.Conversion_Label, System.Label.Merger_Label};
            String nameChange = System.label.Name_Change;
            if(accountId!=null){
                Set<Id> filingId = new Set<Id>();
                String query = 'Select id,name,accountnumber,Annual_Report_Due_Date__c,NAICS_Code__c,Date_Registration__c,NAICS_Sub_Code__c,Mailing_International_Address__c,State_or_Territory_Formation__c,Country_Formation__c,ShippingState,ShippingCity,ShippingPostalCode,ShippingStreet,Shipping_Unit__c,ShippingCountry,Total_Authorized_Shares__c,Status__c,Connecticut_Alei__c,Citizenship__c,Business_Type__c,Formation_Place__c,Date_of_Formation__c,Principle_Office_International_Address__c,Office_Jurisdiction_Address__c,Office_in_Jurisdiction_Country__c,Jurisdiction_International_address__c,Mailing_Jurisdiction_Address__c,Mailing_Jurisdiction_Country__c,Mail_Jurisdiction_International_address__c,BillingCity, BillingStreet, BillingState, BillingPostalCode,BillingCountry,Billing_Unit__c,Service_Of_Process_Mailing_Address__c, (Select Id, Name__c,Principal_Title__c,Business_Address_1__c,Residence_Address__c,Business_InternationalAddress__c,Residence_InternationalAddress__c,Business_Country__c,Residence_Country__c from Principals__r),(Select Agent_Name__c,name__c,Mailing_Address__c,  Business_Address__c, Agent_Residence_Address__c,Business_InternationalAddress__c,Business_Country__c from Agents__r),(select id,Name,due_date__c,type__c,status__c,Filing_Date__c,Start_Page__c,Volume_Type__c, Pages__c, Terminated_Business_Id__c, Terminated_Business_Name__c, Terminated_Business_Date__c, Volume__c,Due_Year__c,Filing_Type__c,Amendment_Type__c,Filing_Time__c,Work_Order_Received_Date__c from business_filings__r where Status__c != \'' + System.label.Label_Pending_Filing_1+'\''+ ' AND Status__c != \'' + System.label.UCC_LIEN_STATUS+'\''+ ' AND Status__c != \'' + System.label.BRS_Submitted_Intake_pending+'\''+ ' AND Status__c!=\'' + System.label.In_Progress_Label+'\''+ ' AND Status__c!=\'' + System.label.Rejected+'\''+ ' AND Status__c!=\'' + System.label.Due_Label_Comparable+'\'' + ' AND Status__c!=\'' + System.label.PastDue+'\'' + ' AND Status__c!=\'' + System.label.Overdue+'\'' + ' AND Status__c!=\'' + System.label.Submitted_Label_Comparable+'\''+ ' AND Status__c!=\'' + System.label.BRS_Submitted_Agent_acceptance_pending+'\''+ ' AND Status__c!=\'' + System.label.Submitted_Agency_review_pending+'\''+'order by  Filing_Date__c  asc,Due_Year__c asc ,name asc),(Select id,Business_Name_New__c,createdDate,Business_Name_Old__c,Business_Filing__r.Name,Business_Filing__r.Filing_Date__c,Name_Change_Date__c from Name_Change_Histories__r ),(select Number_of_Stocks__c,  Par_Value__c, AccountId__c, Stock_Class__c  FROM Stock_Classifications_del__r) from Account where id=:accountId WITH SECURITY_ENFORCED LIMIT 1'; 
                Account accountDetails = Database.query(query);
                if(accountDetails!=null){                
                    List<Principal__c> principalList =  (List<Principal__c>)accountDetails.getSObjects('Principals__r');
                    List<Agent__c> agentList =  (List<Agent__c>)accountDetails.getSObjects('Agents__r');
                    List<Business_Filing__c> filingList =  (List<Business_Filing__c>)accountDetails.getSObjects('business_filings__r');
                    List<Name_Change_History__c> historyList =  (List<Name_Change_History__c>)accountDetails.getSObjects('Name_Change_Histories__r');
                    List<Stock_Classification__c > stockList =  (List<Stock_Classification__c >)accountDetails.getSObjects('Stock_Classifications_del__r');
                    Agent__c agentObj = new Agent__c();
                    Date annualReportDue;
                    Integer lastReportFiled;
                    if(agentList!=null){
                        agentObj = agentList[0];
                    }
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX:BRS-6868 FIX
                    * Change(s)/Modification(s) Description : Adding condition to show details regarding Mergers/ Domestication/ COnversions on surviving accounts as well.
                    * Change(s)/Modification(s) Made on : 17-08-2021
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    Set<Id> filingIdsToExcludeINMergers = new Set<id>();
                    Map<Id,Business_Filing__c> allMergerCOnversionDomesticatedFilings = new Map<Id,Business_Filing__c>();
                    if(filingList==null){
                        allMergerCOnversionDomesticatedFilings = getConversionMergerDomesticationFiling(new Set<Id>(), accountId);
                    } else {
                        for(Business_Filing__c filingObj: filingList){
                            filingIdsToExcludeINMergers.add(filingObj.Id);
                        }
                        allMergerCOnversionDomesticatedFilings = getConversionMergerDomesticationFiling(filingIdsToExcludeINMergers, accountId);
                    }
                    If(!allMergerCOnversionDomesticatedFilings.isEmpty()){
                        filingId.addAll(allMergerCOnversionDomesticatedFilings.keyset());
                        if(filingList!= null) {
                            filingList.addAll(allMergerCOnversionDomesticatedFilings.values());
                        }
                        else{
                            filingList = new List<Business_Filing__c>();
                            filingList.addAll(allMergerCOnversionDomesticatedFilings.values());
                        }
                    }
                    if(filingList!=null){    
                        for(Business_Filing__c filingObj: filingList){
                            filingId.add(filingObj.Id);
                        }
                        Map<Id,String> filingDocMap = getFilingRelatedDocs(filingId,'Business');
                        List<filingDetails> filingDetailList = new List<filingDetails>();
                        for(Business_Filing__c filingObj: filingList){
                            filingDetails filingObjWrap = new filingDetails();
                            if(typeToShowViewDetailsButton.contains(filingObj.Type__c)){
                                filingObjWrap.showViewDetailsBtn = true;
                            } else {
                                filingObjWrap.showViewDetailsBtn = false;
                            }
                            filingObjWrap.businessFilingId = filingObj.Id;
                            filingObjWrap.filingId = filingObj.Name.remove(System.Label.BF_tag);
                            //filingObjWrap.filingDateTime = filingObj.Filing_Date__c!=null?filingObj.Filing_Date__c.format():null; // confirm on date time
                            if(filingObj.Work_Order_Received_Date__c!=null){
                                filingObjWrap.filingDateTime=filingObj.Work_Order_Received_Date__c.date().format();
                            }else if(filingObj.Filing_Date__c!=null){
                                filingObjWrap.filingDateTime=filingObj.Filing_Date__c.format();   
                            }
                            String filingtime;
                            if(filingObj.Filing_Time__c!=null){
                              Datetime myDateTime = Datetime.newInstance(Date.today(), filingObj.Filing_Time__c);
                              filingtime = myDateTime.format('h:mm a');
                            }

                            filingObjWrap.filingTime=filingObj.Work_Order_Received_Date__c!=null?filingObj.Work_Order_Received_Date__c.format('hh:mm a'):filingtime;
                            filingObjWrap.filingVolumeType = filingObj.Volume_Type__c!=null?filingObj.Volume_Type__c:null;
                            filingObjWrap.filingPages = filingObj.Pages__c!=null?filingObj.Pages__c:null;
                            filingObjWrap.filingVolume = filingObj.Volume__c!=null?(Integer)filingObj.Volume__c:null;
                            filingObjWrap.filingType = filingObj.Type__c!=null&& filingObj.Due_Year__c!=null?filingObj.Type__c+'('+filingObj.Due_Year__c+')':filingObj.Type__c!=null&& filingObj.Due_Year__c==null?filingObj.Amendment_Type__c!=null?filingObj.Type__c + ' - '+ filingObj.Amendment_Type__c:filingObj.Type__c + ' - '+ filingObj.Filing_Type__c:null;
                            filingObjWrap.filinTerminatedBusinessId = filingObj.Terminated_Business_Name__c!=null?filingObj.Terminated_Business_Name__c:null;
                            filingObjWrap.filingTerminatedBusinessName = filingObj.Terminated_Business_Name__c!=null?filingObj.Terminated_Business_Name__c:null;
                            filingObjWrap.filingTerminatedDate = filingObj.Terminated_Business_Date__c!=null?filingObj.Terminated_Business_Date__c.format():null;
                            filingObjWrap.filingDigitalCopy = filingDocMap.containsKey(filingObj.Id)?filingDocMap.get(filingObj.Id):null;
                            filingObjWrap.startPage = filingObj.Start_Page__c!=null?String.ValueOf(filingObj.Start_Page__c):null;
                            /**
                            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4303 FIX
                            * Change(s)/Modification(s) Description : Adding condition to show latest filed date for Annual/ First report filings only
                            * Change(s)/Modification(s) Made on : 2021-05-18
                            * Change(s)/Modification(s) Made by : Avinash Shukla
                            */
                            if(filingObj.Status__c!=null && filingObj.Status__c == System.label.Latest_Filed_Status && (filingObj.Type__c == System.label.Annual_Report || filingObj.Type__c == System.label.BRS_First_Report) && filingObj.Due_Date__c != NULL && filingObj.Type__c != NULL){
                                if(lastReportFiled != NULL){
                                    lastReportFiled = lastReportFiled < filingObj.Due_Date__c.Year() ? filingObj.Due_Date__c.Year() : lastReportFiled;
                                } else {
                                    lastReportFiled = filingObj.Due_Date__c.Year();
                                }
                            }
                            else if(filingObj.Type__c == System.Label.brs_Reinstatement && filingObj.Filing_Type__c == 'Certificate of Reinstatement' && filingObj.Status__c == System.label.Latest_Filed_Status) {
                                lastReportFiled = filingObj.Filing_Date__c.Year();
                            }
                            
                            if(annualReportDue==null && (filingObj.Status__c == system.label.Due ||filingObj.Status__c== system.label.overDue)){
                                annualReportDue = filingObj.Due_Date__c;
                            }
                            filingDetailList.add(filingObjWrap);
                        }
                        businessDetailsObj.filingList = filingDetailList;
                    }
                    if(historyList!=null){
                        List<nameHistoryDetails> nameHistoryList = new List<nameHistoryDetails>();
                        for(Name_Change_History__c tempHisObj :historyList ){
                            nameHistoryDetails nameObj = new nameHistoryDetails();
                            nameObj.nameHistoryfilingDate = tempHisObj.Name_Change_Date__c!=null?date.valueOf(tempHisObj.Name_Change_Date__c).format():null;
                            nameObj.nameHistoryName = tempHisObj.Business_Name_Old__c!=null? tempHisObj.Business_Name_Old__c:'';
                            nameObj.nameHistoryNumber = tempHisObj.Business_Filing__r.Name.remove(System.Label.BF_tag);
                            nameHistoryList.add(nameObj);
                        }
                        businessDetailsObj.nameHistoryList = nameHistoryList;
                    }
                    if(principalList!=null){
                        List<principalDetails> principalDetailsList = new List<principalDetails>();
                        for(Principal__c princObj:principalList){
                            principalDetails principalObj = new principalDetails();
                            principalObj.businessPrincipalName = princObj.Name__c;
                            principalObj.principalResidenceAddress = (princObj.Residence_InternationalAddress__c!=null && princObj.Residence_Country__c != NULL)?princObj.Residence_InternationalAddress__c+', '+ princObj.Residence_Country__c: princObj.Residence_Address__c;
                            principalObj.principalBusinessAddress = (princObj.Business_InternationalAddress__c!=null && princObj.Business_Country__c!=NULL)? princObj.Business_InternationalAddress__c+', '+princObj.Business_Country__c: princObj.Business_Address_1__c;
                            principalObj.principalTitle = princObj.Principal_Title__c!=null ? princObj.Principal_Title__c:'';
                            principalDetailsList.add(principalObj);
                        }
                        businessDetailsObj.principalDetailsList = principalDetailsList;
                    }
                    if(stockList!=null){
                        List<shareDetails> shareDetailsDetailsList = new List<shareDetails>();
                        for(Stock_Classification__c  stockObj : stockList){
                            shareDetails shareObj = new shareDetails();
                            shareObj.shareClass = stockObj.Stock_Class__c!=null?stockObj.Stock_Class__c:'';
                            shareObj.valuePerShare = stockObj.Par_Value__c!=null?stockObj.Par_Value__c:null;
                            shareObj.shareNumber = stockObj.Number_of_Stocks__c!=null?stockObj.Number_of_Stocks__c:null;
                            shareDetailsDetailsList.add(shareObj);
                        }
                        businessDetailsObj.shareDetailsList = shareDetailsDetailsList;
                    }
                    List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
					Map<String,String>  labelMaps = new Map<String,String>();
					labelMaps = getTranslatedMap();
                    businessDetailsObj.businessAddress = accountDetails.Principle_Office_International_Address__c!= null && accountDetails.BillingCountry!=null? accountDetails.Principle_Office_International_Address__c + ', ' + accountDetails.BillingCountry: BRS_Utility.getAddress(accountDetails, billingAddrFields) != NULL ? BRS_Utility.getAddress(accountDetails, billingAddrFields) : '';
                    businessDetailsObj.accountId = accountDetails.Id;
                    businessDetailsObj.businessId = accountDetails.accountnumber;
                    businessDetailsObj.connecticutAlei = accountDetails.Connecticut_Alei__c;
                    businessDetailsObj.businessName = accountDetails.Name;
                    businessDetailsObj.businessAgentName = agentObj.Name__c!=null?agentObj.Name__c:'';
                    businessDetailsObj.businessStatus = accountDetails.Status__c!=null? (labelMaps.containsKey(accountDetails.Status__c)?labelMaps.get(accountDetails.Status__c).toUppercase() : accountDetails.Status__c.toUppercase() ) :'';
					//accountDetails.Status__c.toUppercase():'';
                    businessDetailsObj.dateFormed =accountDetails.Date_Registration__c!=null?accountDetails.Date_Registration__c.format() :'';
                    businessDetailsObj.placeOfFormation = accountDetails.State_or_Territory_Formation__c!=null? accountDetails.citizenship__c +'/' + accountDetails.State_or_Territory_Formation__c:accountDetails.Country_Formation__c!=null? accountDetails.citizenship__c +'/' +accountDetails.Country_Formation__c:'';
                    businessDetailsObj.businessType = accountDetails.Business_Type__c!=null?accountDetails.Business_Type__c:'';
                    List<String> shippingAddrFields = System.Label.BRS_ShippingAddrFields.split(',');
                    businessDetailsObj.mailingAddress = (accountDetails.Mailing_International_Address__c != null && accountDetails.ShippingCountry != NULL)? accountDetails.Mailing_International_Address__c + ', ' + accountDetails.ShippingCountry : BRS_Utility.getAddress(accountDetails, shippingAddrFields) != NULL ? BRS_Utility.getAddress(accountDetails, shippingAddrFields) : '';
                    businessDetailsObj.annualReportDue = accountDetails.Annual_Report_Due_Date__c!=null ? accountDetails.Annual_Report_Due_Date__c.format():'';
                    businessDetailsObj.lastReportFiled =lastReportFiled!=null?String.ValueOf(lastReportFiled):'';
                    businessDetailsObj.naicsCode = accountDetails.NAICS_Code__c!=null?accountDetails.NAICS_Code__c:'';
                    businessDetailsObj.naicsSubCode = accountDetails.NAICS_Sub_Code__c!=null?accountDetails.NAICS_Sub_Code__c:'';
                    businessDetailsObj.agentResidenceAddress = agentObj.Agent_Residence_Address__c!=null?agentObj.Agent_Residence_Address__c:''; 
                    businessDetailsObj.agentBusinessAddress = agentObj.Business_InternationalAddress__c!=null ? agentObj.Business_InternationalAddress__c+', '+ agentObj.Business_Country__c: agentObj.Business_Address__c!=null?agentObj.Business_Address__c:''; 
                    businessDetailsObj.agentMailingAddress = agentObj.Mailing_Address__c!=null?agentObj.Mailing_Address__c:''; 
                    businessDetailsObj.totalShares = accountDetails.Total_Authorized_Shares__c!=null?accountDetails.Total_Authorized_Shares__c:null;
                    businessDetailsObj.serviceOfProcessAddr = accountDetails.Service_Of_Process_Mailing_Address__c !=null?accountDetails.Service_Of_Process_Mailing_Address__c : null;
                    businessDetailsObj.officeInJurisdictionAddress = accountDetails.Jurisdiction_International_address__c!= null  && accountDetails.Jurisdiction_International_address__c !=QnA_Constants.EMPTY_STRING ? String.valueOf(accountDetails.Jurisdiction_International_address__c) + ', '+ String.valueOf(accountDetails.Office_in_Jurisdiction_Country__c) : accountDetails.Office_Jurisdiction_Address__c!=null ? String.valueOf(accountDetails.Office_Jurisdiction_Address__c): null ;                
                    businessDetailsObj.mailingJurisdictionAddress = accountDetails.Mail_Jurisdiction_International_address__c!= null  && accountDetails.Mail_Jurisdiction_International_address__c !=QnA_Constants.EMPTY_STRING ? String.valueOf(accountDetails.Mail_Jurisdiction_International_address__c) + ', '+ String.valueOf(accountDetails.Mailing_Jurisdiction_Country__c) : accountDetails.Mailing_Jurisdiction_Address__c!=null ? String.valueOf(accountDetails.Mailing_Jurisdiction_Address__c): null ;               

                }
            }
            return businessDetailsObj;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, getBusinessDetails, null, null, BOS_Utility.sSeverity, ex, null);
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
        return labelMaps;
    }

    public static map<Id,String> getFilingRelatedDocs (Set<Id> filingIds,String Type){
        map<Id,String> filingDocMap = new map<Id,String>();
        List<String> filingNumbers = new List<String>();
        List<String> filingNumberwithOutPdf = new List<String>();
        Set<String> ConversionIds = new Set<String>();
        List<ContentDocumentLink> documentDetails = new List<ContentDocumentLink>();
        Map<Id,Id> BusFilingMassAgentMap = new Map<Id,Id>();
        Set<Id> WOIds = new Set<Id>();
        List<Mass_Agent_Change__c> massAgentList = new List<Mass_Agent_Change__c>();
        
        if(Type == 'UCC'){
            List<UCC_Filing__c> uccFilingList = new List<UCC_Filing__c>([Select Id,Sdoc_Filing_Number__c,UCC_Filing_Number__c,Amendment_Type__c,Type__c from UCC_Filing__c where ID IN: filingIds WITH SECURITY_ENFORCED Limit 50000]);
            if(!uccFilingList.isEmpty()){
                for(UCC_Filing__c uccFile : uccFilingList){
                   if(uccFile.UCC_Filing_Number__c != null && uccFile.UCC_Filing_Number__c != ''){
                        ConversionIds.add(uccFile.ID);
                   }
                   else{
                        String strTitle = UCCFileMerge.getFilingOutputName(uccFile) + '.pdf';
                        filingNumbers.add(strTitle);
                        filingNumberwithOutPdf.add(UCCFileMerge.getFilingOutputName(uccFile));
                   }
                   
                }
            }
        }
        else{
            List<Business_Filing__c> businessfileList = new List<Business_Filing__c>([Select Id,External_ID__c,Type__c,Work_Order__c,Sdoc_Filing_Number__c,Filing_Type__c,Amendment_Type__c from Business_Filing__c where ID IN: filingIds WITH SECURITY_ENFORCED Limit 50000]);
            
            for(Business_Filing__c busFile : businessfileList){
                    if(busFile.Type__c.containsIgnoreCase(System.label.MassAgentChangeLabel)){
                    WOIds.add(busFile.Work_Order__c);
                }
            }
            if(!WOIds.isEmpty()){
                massAgentList = [SELECT Id,Work_Order__c FROM Mass_Agent_Change__c WHERE Work_Order__c IN: WOIds WITH SECURITY_ENFORCED];
            }

            if(!businessfileList.isEmpty()){
                for(Business_Filing__c busFile : businessfileList){
                    if(busFile.External_ID__c != null && busFile.External_ID__c != ''){
                        ConversionIds.add(busFile.Id);
                    }
                    else if(busFile.Type__c.containsIgnoreCase(System.label.MassAgentChangeLabel)){
                        for(Mass_Agent_Change__c mac: massAgentList){
                            if((mac.Work_Order__c == busFile.Work_Order__c) && (!BusFilingMassAgentMap.containsKey(busFile.Id))){
                                BusFilingMassAgentMap.put(busFile.Id, mac.Id);
                            }
                        }
                    }
                    else{
                        String strTitle = UCCFileMerge.getFilingOutputName(busFile) + '.pdf';
                        filingNumbers.add(strTitle);
                        filingNumberwithOutPdf.add(UCCFileMerge.getFilingOutputName(busFile));
                    }                    
                }
            }  
        }

        if(!filingIds.isEmpty()){
             if(!filingNumbers.Isempty() || !filingNumberwithOutPdf.Isempty() || !ConversionIds.Isempty()){
                documentDetails=  [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize , ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension  
                FROM ContentDocumentLink where (LinkedEntityId in:filingIds AND (ContentDocument.Title IN: filingNumbers OR ContentDocument.Title IN: filingNumberwithOutPdf)) OR LinkedEntityId IN: ConversionIds WITH SECURITY_ENFORCED];
            }
            Set<ID> ContentDocumentIds = new Set<ID>();
            if(!documentDetails.isEmpty()){
                for(ContentDocumentLink contentInst : documentDetails){  
                    ContentDocumentIds.add(contentInst.ContentDocumentId);
                }
                List<ContentDistribution> conDocVersion = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN: ContentDocumentIds ];
                for(ContentDocumentLink doc: documentDetails){
                    for(ContentDistribution conVer : conDocVersion){
                        if(doc.ContentDocumentId == conVer.ContentDocumentId){
                            filingDocMap.put(doc.LinkedEntityId,conVer.DistributionPublicUrl);
                        }
                    }
                }
            }

            if(!BusFilingMassAgentMap.isEmpty()){
                List<ContentDocumentLink> macDocumentsLst = [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :BusFilingMassAgentMap.values() ];
                Map<Id,ContentDocumentLink> busFilingdocumentMap = new Map<Id,ContentDocumentLink>();
                Set<ID> macContentDocumentIds = new Set<ID>();
                
                for(Id busFile: BusFilingMassAgentMap.keySet()){
                    for(ContentDocumentLink con: macDocumentsLst){
                        if((con.LinkedEntityId == BusFilingMassAgentMap.get(busFile)) && (!busFilingdocumentMap.containsKey(busFile))){
                            busFilingdocumentMap.put(busFile,con);
                            macContentDocumentIds.add(con.ContentDocumentId);
                        }
                    }
                }

                if(!busFilingdocumentMap.isEmpty()){
                    List<ContentDistribution> macConDocVersion = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN: macContentDocumentIds ];
                    for(Id busFile: busFilingdocumentMap.keySet()){
                        for(ContentDistribution conVer : macConDocVersion){
                            if((busFilingdocumentMap.get(busFile)).ContentDocumentId == conVer.ContentDocumentId){
                                filingDocMap.put(busFile,conVer.DistributionPublicUrl);
                            }
                        }
                    }
                }
            }
        }
        return filingDocMap;
    }

    /**
     * Author : Avinash Shukla
     * Method : getConversionMergerDomesticationFiling
     * Desc   : Get business filign for account for merger, conversion and domestication 
     */
    public static Map<Id, Business_Filing__c> getConversionMergerDomesticationFiling(Set<Id> businessFilingIds, Id accountId){
        try{
            Set<Id> businessFilingIdsToReturn = new Set<Id>();
            Set<String> bfStatusesToIgnore = new Set<String>{System.Label.Due, System.Label.PastDue, System.label.In_Progress_Label, System.Label.Submitted_Agency_review_pending, System.Label.Submitted_Agent_acceptance_pending, System.Label.BRS_FilingStatus_Rejected,System.label.Overdue,System.label.Submitted_Label_Comparable};
            List<Business_History__c> obhList = new List<Business_History__c>();
            String query = 'SELECT Id, Name, Business_Filing__c, Old_Business_Type__c, Merging_Business__c, Status__c, Surviving_Business__c FROM Business_History__c WHERE Business_Filing__c NOT IN : businessFilingIds AND (Surviving_Business__c =: accountId OR Merging_Business__c =: accountId) WITH SECURITY_ENFORCED';
            obhList = Database.query(query);
            for(Business_History__c obh : obhList){
                if(obh.Business_Filing__c != NULL) businessFilingIdsToReturn.add(obh.Business_Filing__c);
            }
            Map<Id,Business_Filing__c> obfMap = new Map<Id, Business_Filing__c>([select id,Name,due_date__c,type__c,status__c,Filing_Date__c,Start_Page__c,Volume_Type__c, Pages__c, Terminated_Business_Id__c, Terminated_Business_Name__c, Terminated_Business_Date__c, Volume__c,Due_Year__c,Filing_Type__c,Amendment_Type__c,Filing_Time__c,Work_Order_Received_Date__c  from business_filing__c where Status__c NOT IN : bfStatusesToIgnore AND Id IN :businessFilingIdsToReturn WITH SECURITY_ENFORCED]);
            return obfMap;
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getConversionMergerDomesticationFiling', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * Author : Priyanka
     * Method : searchStringCleanup
     * Desc   : Removing noise keywords and legal designationa from the search sting 
     */
    public static string searchStringCleanup(string searchString){
        try{
            if(!String.isBlank(searchString)){
                List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
                List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
                
                searchString = ' ' + (searchString).normalizeSpace() + ' ';
                
                for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                    if((searchString != '' || searchString != null) && noiseWrd.Label!='.' && (searchString.containsIgnoreCase(noiseWrd.Label))){
                        if(!(noiseWrd.Label).isAlpha()){
                            searchString = ' ' + (((searchString).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                        else{
                            searchString = ' ' + (((searchString).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), '  ')) + ' ';//.normalizeSpace()
                        }
                    }
                }
                 
                for(brs_SortLegalDesignators desgn : listOfDesignators) {                    
                    if((' '+searchString+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        Integer matchCount = (searchString.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                        if(matchCount >= 1){
                            for(Integer i=0; i<matchCount; i++){
                                searchString= ' ' + (((searchString).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                        }
                    }
                    if((' '+searchString+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                        searchString= ' ' + (((searchString).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                    if((' '+searchString+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                        searchString= ' ' + (((searchString).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                } 
                searchString = Accents.removeDiacritics(searchString);
                searchString = ((searchString).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
            }            
            return searchString;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'searchStringCleanup', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }       
    }

    public static filingDetails getFilingDetails(Id businessFilingId) {
        try{
            List<Business_Filing__c> oBf = new List<Business_Filing__c>();
            String query = 'Select Id, Name,Filing_Number__c,Type__c,Amendment_Type__c,Business_Type__c,Citizenship__c,Work_Order__c, Work_Order__r.Received_Date__c,Effective_Date__c,Effective_Time__c, Account__c, Account__r.Name, Account__r.AccountNumber, Account__r.Citizenship__c,Filing_Date__c, (SELECT Id, Name, Merging_Business__c, Merging_Business__r.Name, Merging_Business__r.AccountNumber, Merging_Business__r.Business_Type__c, Merging_Business__r.Date_Registration__c, Business_Filing__c, Surviving_Business__c, Surviving_Business__r.Name, Surviving_Business__r.AccountNumber, Surviving_Business__r.Business_Type__c, Surviving_Business__r.State_or_Territory_Formation__c, Status__c, Old_Business_Type__c FROM Business_Histories__r), (Select Id, Business_Name_Old__c, Business_Name_New__c, Account__c from Name_Change_Histories__r)  from Business_Filing__c  WHERE Id =:businessFilingId  WITH SECURITY_ENFORCED';
            oBf = Database.query(query);
        
            filingDetails ofilingDetails = new filingDetails();    
            if (!oBf.isEmpty()) {
                Business_Filing__c oBfRec = oBf.get(0);
                String filingDateTime = '';
                ofilingDetails.filingId = oBfRec.Name.remove(System.Label.BF_tag);
                if (oBfRec.Work_Order__c != NULL) {
                    filingDateTime = oBfRec.Work_Order__r.Received_Date__c != NULL ? oBfRec.Work_Order__r.Received_Date__c.format() : '';
                    ofilingDetails.filingDateTime = filingDateTime;
                } else {
                    filingDateTime = oBfRec.Filing_Date__c != NULL ? oBfRec.Filing_Date__c.format() : '';
                    ofilingDetails.filingDateTime = filingDateTime;
                }
                
                ofilingDetails.changingbusinessDate = filingDateTime;
                ofilingDetails.changedbusinessDate = filingDateTime;
                ofilingDetails.businessName = oBfRec.Account__r.Name;
                ofilingDetails.businessId = oBfRec.Account__r.AccountNumber;
                ofilingDetails.filingType = oBfRec.Type__c;
        
                if (!oBfRec.Business_Histories__r.IsEmpty()) {
                    Business_History__c oBhrec = oBfRec.Business_Histories__r.get(0);
                    //Converted/ Domesticated Business Details
                    ofilingDetails.changedbusinessName = oBhrec.Surviving_Business__r.Name;
                    ofilingDetails.changedbusinessId = oBhrec.Surviving_Business__r.AccountNumber;
                    ofilingDetails.changedBusinessStateOrCountry = oBhrec.Surviving_Business__r.State_or_Territory_Formation__c;
                    // Case when D2D Conversion is done, the same account is updated and no new account is created.
                    if (oBhrec.Surviving_Business__c == oBhrec.Merging_Business__c && oBhrec.Surviving_Business__c != NULL && oBfRec.Type__c == System.Label.Conversion_Label) {
                        //Converting Business Details
                        //Check if Name is Changed then show old name else we show same name in the converting business name.
                        If(!oBfRec.Name_Change_Histories__r.IsEmpty()){
                            Name_Change_History__c oNCH =  oBfRec.Name_Change_Histories__r.get(0);
                            ofilingDetails.changingbusinessName = oNCH.Business_Name_Old__c;
                        } else {
                            ofilingDetails.changingbusinessName = oBhrec.Surviving_Business__r.Name;
                        }
                        ofilingDetails.changingbusinesstype = oBhrec.Old_Business_Type__c;
                        ofilingDetails.changingbusinessId = oBhrec.Surviving_Business__r.AccountNumber;
                    } else {
                        //Domesticating Business Details
                        ofilingDetails.changingbusinessName = oBhrec.Merging_Business__r.Name;
                        ofilingDetails.changingbusinesstype = oBhrec.Merging_Business__r.Business_Type__c;
                        ofilingDetails.changingbusinessId = oBhrec.Merging_Business__r.AccountNumber;
                    }
                }
                if (oBfRec.Type__c == System.Label.Merger_Label) {
                    List<mergedAccountDetails> allMergedBusinesses = new List<mergedAccountDetails>();
                    Id survivingAccountId;
                    for (Business_History__c oBh : oBfRec.Business_Histories__r) {
                        mergedAccountDetails ofilingDetailsMerged = new mergedAccountDetails();
                        survivingAccountId = oBh.Surviving_Business__c;
                        ofilingDetailsMerged.changingbusinessId = oBh.Merging_Business__r.AccountNumber != NULL ? oBh.Merging_Business__r.AccountNumber : '';
                        ofilingDetailsMerged.changingbusinessName = oBh.Merging_Business__r.Name != NULL ? oBh.Merging_Business__r.Name : '';
                        ofilingDetailsMerged.changingbusinessDate = filingDateTime;
                        allMergedBusinesses.add(ofilingDetailsMerged);
                    }
                    Account survivingAccount = BRS_Utility.getAccount(survivingAccountId);
                    ofilingDetails.businessName = survivingAccount.Name;
                    ofilingDetails.businessId = survivingAccount.AccountNumber;
                    ofilingDetails.mergedAccountList = allMergedBusinesses;
                }
            }
            return ofilingDetails;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getFilingDetails', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

}