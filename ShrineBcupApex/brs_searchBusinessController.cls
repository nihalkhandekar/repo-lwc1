/* DESCRIPTION: This class contains methods to search businesses for annual and first report.
*
* @AUTHOR:  Priyanka
* @DATE:    1/12/2021
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka                         1/12/2021                           Created the first version
* Avinash Shukla                   2021-02-05                          Added functionality for BRS-1690
* Priyanka                         2/10/2021                           Bug fix 2400
* Priyanka                         3/9/2021                            BRS-2619
* Avinash Shukla                   2021-02-05                          Added functionality for BRS-2476
*********************************************************************************************/
global without sharing class brs_searchBusinessController {
    public static Final String className='brs_searchBusinessController';
    @AuraEnabled
    public String accountId {get;set;}
    @AuraEnabled
    public String businessId {get;set;}
    @AuraEnabled
    public String ConnecticutAlei {get;set;}
    @AuraEnabled
    public String businessNameStateFormation{get;set;}
    @AuraEnabled
    public String businessNameStateFormationWithoutLegalDesignator{get;set;}
    @AuraEnabled
    public String businessName{get;set;}
    @AuraEnabled
    public String businessAddress{get;set;}
    @AuraEnabled
    public String businessDueFilings{get;set;}
    @AuraEnabled
    public String businessAgentName{get;set;}
    @AuraEnabled
    public String agentType{get;set;}
    @AuraEnabled
    public String businessStatus{get;set;}
	//BRS-2619
	@AuraEnabled
    public String businessSubStatus{get;set;}
    @AuraEnabled
    public String businessType{get;set;}
    @AuraEnabled
    public String businessCitizen{get;set;}
    @AuraEnabled
    public Boolean isFirstReport{get;set;}
    @AuraEnabled
    public Boolean filingfee{get;set;}
    @AuraEnabled
    public Boolean isFirstReportDue{get;set;}
    @AuraEnabled
    public Boolean isAnnualReportDue{get;set;}
    @AuraEnabled
    public Integer annualDueCount{get;set;}
    @AuraEnabled
    public Integer firstDueCount{get;set;}
    @AuraEnabled
    public Boolean isPrincipleAddressOfCT{get;set;}
    @AuraEnabled
    public String filingId{get;set;}
    // Adding rejected scenario BRS-5164
    @AuraEnabled
    public Boolean isBusinessFilingRejected{get;set;}
    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1690
    * Change(s)/Modification(s) Description : Adding new wrapper variables to hold information for Principals and their count.
    * Change(s)/Modification(s) Made on : 2021-02-01
    */
    @AuraEnabled
    public String principalName{get;set;}
    @AuraEnabled
    public Integer principalCount{get;set;}
    @AuraEnabled
    public Boolean hasZeroPrincipal{get;set;}
    @AuraEnabled
    public Boolean isAnnualorFirst{get;set;}
	@AuraEnabled
    public Boolean showLegalExistenancePopup{get;set;}
    @AuraEnabled
    public Boolean isFilingOverDue{get;set;}
    @AuraEnabled
    public Boolean isAgentAcceptancePending{get;set;}
    @AuraEnabled
    public Boolean isAgentReviewPending{get;set;}
    @AuraEnabled
    public Date certRequestDate{get;set;}

    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
    * Change(s)/Modification(s) Description : Adding a new string wrapper variable to store information if the dissolution was done in last 120 days.
    * Change(s)/Modification(s) Made on : 2021-03-15
    * Change(s)/Modification(s) Made by : Avinash Shukla
    */
    @AuraEnabled
    public Boolean dissolvedWithIn120Days{get;set;}
    @AuraEnabled
    public String businessNameWithoutLegalDesignation{get;set;}
	
	 /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2671
    * Change(s)/Modification(s) Description : Adding a new string wrapper variable to store information if the account has a Foreign Investigation.
    * Change(s)/Modification(s) Made on : 24-06-2021
    * Change(s)/Modification(s) Made by : Tamkanat
    */
    @AuraEnabled
    public Boolean isFIPresent{get;set;}
	 @AuraEnabled
    public String fIName{get;set;}
				

    @AuraEnabled    
    public static List<brs_searchBusinessController> getBusiness(String busStr, String flowName) {
        try{
            Set<String> citizenShipClause = new Set<String>{Label.Non_Stock,Label.Stock,Label.B_Corp};
            Boolean isCommunityUser = false;
            Boolean isSysAdmin = false;
            String profileName = BRS_Utility.getLoggedInUserProfile();
            if(profileName!=null && profileName == System.label.Community_User_Profile) {
             isCommunityUser = true;
            } else if (profileName!=null && profileName == System.label.System_Admin_Label){
               isSysAdmin = true;
            }
            List<Results> lstResults = new List<Results>();
            List<String> statuses;

            if(flowName!=null && (flowName.endsWithIgnoreCase('First Report')|| 
            flowName.endsWithIgnoreCase('Annual Report') ) )
{
    statuses = new List<String>{system.label.Due, system.label.overDue,system.label.PastDue,
        system.label.In_Progress_Label,system.label.Submitted_Agent_acceptance_pending,system.label.Submitted_Agency_review_pending,system.label.Rejected};

}else{

            statuses = new List<String>{system.label.Due, system.label.overDue,system.label.PastDue,
                                                    system.label.In_Progress_Label,system.label.Approved,system.label.Rejected,
                                                    system.label.Submitted_Agent_acceptance_pending,system.label.Submitted_Agency_review_pending};
}
            List<brs_searchBusinessController> brsBusDtList = new List<brs_searchBusinessController>();
             List<String> changeAgentAddressStatus = new List<String>{system.label.ACTIVE,system.label.Forfeited,system.label.DISSOLVED_STATUS,system.label.Renunciated,system.label.Domesticated,system.label.Converted,system.label.Merged};
            List<String> agentResignationStatus = new List<String>{system.label.ACTIVE,system.label.Forfeited,system.label.DISSOLVED_STATUS,system.label.Cancelled,system.label.Renunciated,system.label.Domesticated,system.label.Converted,system.label.Merged};
            List<String> changeAddressStatus = new List<String>{system.label.ACTIVE,system.label.Cancelled,System.label.Withdrawn};
			List<String> foreignInvestigatonStatus = new List<String>{system.label.ACTIVE,system.label.Revoked_Label,System.label.Withdrawn};
			List<String> copyRequestStatus = new List<String>(Label.CopyRequestOnlineStatus.split(System.Label.PIPELINE_SEPARATOR));
			/**
            * Change(s)/Modification(s) for TICKET: BRS-6136
            * Change(s)/Modification(s) Description : Added foreign investigation query to search accounts based on Foreign Investigation Name.
            * Change(s)/Modification(s) Made on : 2021-08-27
            * Author :  Tamkanat
            */
			List<Id> fIAccIds = new List<Id>();
            if(flowName == Label.foreign_investigation_comparable){
                String listFIQuery = 'select Id, Business__c from Foreign_Investigation__c where Name like \'%'+String.escapeSingleQuotes(busStr)+'%\' WITH SECURITY_ENFORCED';
                List<Foreign_Investigation__c> listFI = Database.query(listFIQuery);
                if(!listFI.isEmpty()){
                    for(Foreign_Investigation__c fIInves : listFI){
                        if(fIInves.Business__c!=null){
                            fIAccIds.add(fIInves.Business__c);
                        }
                    }
                }
            }
			
            Set<Id> accIdSet = new Set<Id>();
            Map<Id,String> accIdAgentMap = new Map<Id,String>();
            Map<Id,business_filing__c> accIdFilingMap = new Map<Id,business_filing__c>();
            Map<Id,Integer> accIdFilingCountMap = new Map<Id,Integer>();
            List<Id> accountConcIds = new List<Id>();
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1690
            * Change(s)/Modification(s) Description : Added inner query to add related Principals for the account.
            * Change(s)/Modification(s) Made on : 2021-02-01
            * Author :  Avinash Shukla
            */
			/**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1695
            * Change(s)/Modification(s) Description : Added inner query to query generated certificates
            * Change(s)/Modification(s) Made on : 2021-02-02
            * Author : Rahul Sharma
            */
            //Added variables for QA Fix script exception.
            string firstReportType = Label.First_Report_Comparable;
            string annualReportType = Label.Annual_Report;
            string LLCType = System.Label.businessTypeLLC;
            String queryString = 'Select id, Name, Principle_Office_International_Address__c,accountnumber,Business_Type__c,Citizenship__c, toLabel(Status__c),Sub_status__c,Dissolution_date__c,Account_Name_Without_Designators__c,Business_Name_in_state_country__c,BillingAddress,Billing_Unit__c,BillingCity, BillingStreet, BillingState, BillingPostalCode,BillingCountry,Connecticut_ALEI__c,(select id,due_date__c,type__c,status__c from business_filings__r where status__c in: statuses AND Is_Rejected_Instantiated__c = false AND( (due_date__c<=NEXT_N_DAYS:30 AND Type__c=:annualReportType)  or Type__c=:firstReportType or (Account__r.Business_Type__c = : LLCType AND Due_Date__c <= THIS_YEAR)) order by due_date__c asc),(Select Requested_On__c,Name,Business__c from Certficates__r where Requested_On__c >= LAST_N_DAYS:90 AND Type__c=\'Certificate of Legal Existence\' order by Requested_On__c desc), (Select name__c,Agent_Account_ID__c,Type__c from Agents__r),(Select Id, Name__c,Business_ID__c from Principals__r ),(Select Id,Name,Case_Status__c from Foreign_Investigations__r ) from Account ';
            String whereClause = '';
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
            * Change(s)/Modification(s) Description : Adding where clause conditions
            * Change(s)/Modification(s) Made on : 2021-03-15
            * Change(s)/Modification(s) Made by : Avinash Shukla
            */
            if(flowName == Label.Revocation_Dissolution_Flow){
                whereClause = ' where Status__c=\'Dissolved\' AND Citizenship__c = \'Domestic\' AND Business_Type__c IN : citizenShipClause AND Dissolution_date__c = LAST_N_DAYS:121';
            }else if(flowName == Label.brs_maintenance_Address ){
                whereClause = ' where Status__c IN:changeAddressStatus';
            }else if(flowName == Label.brs_maintenance_address_agent ){
                whereClause = ' where (Status__c IN:changeAgentAddressStatus OR (Status__c=\''+System.label.Withdrawn+'\' AND Business_Type__c =\''+System.label.LLP+'\') OR (Status__c=\''+system.label.Cancelled+'\' AND Business_Type__c =\''+System.label.Limited_Partnership+'\'))';
            }else if(flowName == Label.brs_AgentResignation ){
                whereClause = ' where Status__c IN:agentResignationStatus';
            }
            else if(flowName == 'Online Intake Category' ){
                whereClause = ' where Status__c != null and Status__c != \'Pending\'  AND Is_Intake_Filing__c!=true';
            }
            
            else if(flowName == Label.foreign_investigation_comparable){
                whereClause = ' where Status__c IN:foreignInvestigatonStatus';
				if(!fIAccIds.isEmpty()){
                    whereClause= ' where (Status__c IN:foreignInvestigatonStatus AND Id IN :fIAccIds)';
                }
            }
			else if(flowName == Label.Request_for_copy_comparable){
                whereClause = ' where Status__c IN:copyRequestStatus  AND Is_Intake_Filing__c!=true';
            } else {
                whereClause = ' where Status__c=\''+system.label.ACTIVE+'\'  AND Is_Intake_Filing__c!=true';
            }
            if(!String.isBlank( busStr)){
                
                List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
                List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();

                busStr = ' ' + (busStr).normalizeSpace() + ' ';

                for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                    if((busStr != '' || busStr != null) && noiseWrd.Label!='.' && (busStr.containsIgnoreCase(noiseWrd.Label))){
                        if(!(noiseWrd.Label).isAlpha()){
                            busStr = ' ' + (((busStr).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                        else{
                            busStr = ' ' + (((busStr).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                    }
                }

                for(brs_SortLegalDesignators desgn : listOfDesignators) {                    
                    if((' '+busStr+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        Integer matchCount = (busStr.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                        if(matchCount >= 1){
                            for(Integer i=0; i<matchCount; i++){
                                busStr= ' ' + (((busStr).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                            }
                        }
                    }
                } 
                busStr = Accents.removeDiacritics(busStr);
                busStr = ((busStr).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
                * Change(s)/Modification(s) Description : Adding where clause conditions for searching functionality.
                * Change(s)/Modification(s) Made on : 2021-03-15
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if(flowName == Label.Revocation_Dissolution_Flow){
                    whereClause = ' where Status__c=\'Dissolved\'';
                }
                if(busStr!=null && busStr!=''){
                    if(fIAccIds.isEmpty()){
                        whereClause = whereClause+ ' and (accountnumber = \''+  busStr + '\' or Account_Name_Without_Designators__c like \''+  busStr+'%\' or Connecticut_ALEI__c like \'%'+  busStr+'%\')';
                    }
                } 
                else{
                    return brsBusDtList;
                }
            }
            else if(isSysAdmin){
                whereClause = whereClause+ ' and ownerId =\''+ UserInfo.getUserId()+'\'' ;
            }
            else if(isCommunityUser){
                List<AccountContactRelation> acrRecList =BRS_Utility.getAccContactList();
                if(!acrRecList.isEmpty()){
                    for(AccountContactRelation acrRecObj : acrRecList){
                        accountConcIds.add(acrRecObj.AccountId);
                    }
                    whereClause = whereClause+ ' and id in:accountConcIds ' ;
                }
            }
            whereClause = whereClause+ 'WITH SECURITY_ENFORCED Limit ' + System.label.Business_Search_Limit;
            queryString = queryString+ whereClause;
            List<Account> businessList = Database.query(queryString);
            for(Account acc : businessList){
                Boolean isFirstReportDue = false;
                Boolean isAnnualReportDue = false;
                Integer annualDueCount;
                Boolean showLegalExistenancePopup = false;
                Boolean isFilingOverDue = false;
                Boolean isAgentAcceptancePending = false;
                Boolean isAgentReviewPending = false;
                Boolean isBusinessFilingRejected = false;
                Date certRequestDate = null;
				Boolean foreignInvsPresent = false;
				String foreignInvNumber;
                accIdSet.add(acc.Id);
                
                if(acc.getSObjects('business_filings__r')!=null && !acc.getSObjects('business_filings__r').isEmpty()){
                    List<Sobject> busFilingList = acc.getSObjects('business_filings__r');
                    business_filing__c busfilingObj = (business_filing__c)busFilingList[0]; 
                    business_filing__c busfilingObjforAnnualReport = new business_filing__c();
                    for(Sobject sobj : busFilingList){
                        business_filing__c busfiObj = (business_filing__c)sobj;
                        if(busfiObj.Status__c ==System.Label.Submitted_Agent_acceptance_pending){
                            isAgentAcceptancePending = true;
                        }
                        else if(busfiObj.Status__c ==System.Label.Submitted_Agency_review_pending){
                            isAgentReviewPending = true;
                        }                      
                        if(busfiObj.type__c ==System.Label.Annual_Report_Label && busfiObj.Status__c !=System.Label.Approved){
                            isAnnualReportDue = true;
							if(busfiObj.Status__c ==System.Label.overDue || busfiObj.Status__c == System.Label.PastDue){
                                isFilingOverDue = true;
                            }
                            if(busfiObj.Status__c != System.Label.Approved && busfilingObjforAnnualReport == null){
                                busfilingObjforAnnualReport = busfiObj;
                            }
                            if(accIdFilingCountMap.get(acc.Id)==null){
                                if(busfiObj.Status__c !=System.Label.Approved){
                                    accIdFilingCountMap.put(acc.Id,1);
                                }
                            }
                            else{
                                Integer count = accIdFilingCountMap.get(acc.Id);
                                count= count+1;
                                if(busfiObj.Status__c !=System.Label.Approved){
                                    accIdFilingCountMap.put(acc.Id,count);
                                }
                                
                            }
                        }
                        else{
                             if((busfiObj.Status__c ==System.Label.overDue || busfiObj.Status__c==system.label.Due  || busfiObj.Status__c==system.label.PastDue ||  busfiObj.Status__c==system.label.In_Progress_Label || busfiObj.Status__c==system.label.Rejected) && busfiObj.type__c==firstReportType)
                             {
                                 isFirstReportDue = true;
                             } 
                             if(busfiObj.Status__c==system.label.Rejected){
                                isBusinessFilingRejected = true;
                             }
                            if((busfiObj.Status__c ==System.Label.overDue || busfiObj.Status__c==system.label.PastDue) && busfiObj.type__c==System.Label.First_Report) {
                                isFilingOverDue = true;
                            }
                        }
                        // Added as part of bug fix - BRS-4033
                        if(busfiObj.Status__c !=System.Label.Approved && accIdFilingMap.get(acc.Id)==null){
                            accIdFilingMap.put(acc.Id,busfiObj);  
                            if(busfiObj.Status__c==system.label.Rejected){
                                isBusinessFilingRejected = true;
                            }
                        }
                    }
                    if(isFirstReportDue && isAnnualReportDue){
                        busfilingObj = (business_filing__c)busFilingList[1];   
                        accIdFilingMap.put(acc.Id,busfilingObjforAnnualReport);
                        if(busfilingObjforAnnualReport.Status__c==system.label.Rejected){
                                isBusinessFilingRejected = true;
                        }
                    }
                    
                }
                Agent__c agentObj = new Agent__c();
                if(acc.getSObjects('Agents__r')!=null){
                    List<Sobject> busAgentList = acc.getSObjects('Agents__r');
                    agentObj = (Agent__c)busAgentList[0];
                }
				/**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1695
                * Change(s)/Modification(s) Description : Added inner query to query generated certificates
                * Change(s)/Modification(s) Made on : 2021-02-02
                * Author : Rahul Sharma
                */
                Certficate__c certObj = new Certficate__c();
                if(acc.getSObjects('Certficates__r')!=null){
                    List<Sobject> busCertList = acc.getSObjects('Certficates__r');
                    if(busCertList.size() > 0)
                    {
                         showLegalExistenancePopup= true;
                          certObj = (Certficate__c)busCertList[0];
                         certRequestDate = certObj.Requested_On__c;
                    }
                }
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1690
                * Change(s)/Modification(s) Description : Adding loop for principal names and count, to add to the business list.
                * Change(s)/Modification(s) Made on : 2021-02-01
				* Author : Avinash Shukla
                */
                             Integer principalCount = 0;   
                String principalName = '';
                if(acc.getSObjects('Principals__r')!=null && !acc.getSObjects('Principals__r').isEmpty()){
                principalCount = acc.getSObjects('Principals__r').size();
                Integer count = 0;
                
                    for(Principal__c oPrin : acc.getSObjects('Principals__r')){
                        if(count < 2){
                            principalName = principalName != '' ? principalName + ', ' + oPrin.Name__c : oPrin.Name__c;
                            count = count + 1;
                        } else {
                            break;
                        }
                    }
                
                if(!String.isEmpty(principalName)){
                    if(principalCount > 0){
                    principalCount = principalCount - count;
                    }
                }
                }
				/**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2671
                * Change(s)/Modification(s) Description : Check if the account has a Foreign Investigation.
                * Change(s)/Modification(s) Made on : 24-06-2021
                * Change(s)/Modification(s) Made by : Tamkanat
                */
                if(acc.getSObjects('Foreign_Investigations__r')!=null){
                    List<Sobject> fIList = acc.getSObjects('Foreign_Investigations__r');
                    if(fIList.size() > 0){
                        String fIStatus = (String)fIList[0].get('Case_Status__c');
                        if(fIStatus.contains('Open')){
                            foreignInvsPresent=true;
                        }else{
                            foreignInvsPresent=false;
                        }
                        foreignInvNumber = (String)fIList[0].get('Name');
                    }
                }
                
                brs_searchBusinessController brsBusDtObj = new brs_searchBusinessController();
                brsBusDtObj.accountId = acc.Id;
                brsBusDtObj.businessId = acc.accountnumber;
                brsBusDtObj.ConnecticutAlei = acc.Connecticut_ALEI__c;
                brsBusDtObj.businessName = acc.Name;
                brsBusDtObj.businessNameWithoutLegalDesignation = !String.isBlank(acc.Account_Name_Without_Designators__c)?acc.Account_Name_Without_Designators__c:getNameWithoutDesignators(acc.Name);
                brsBusDtObj.businessNameStateFormation = acc.Business_Name_in_state_country__c;
                brsBusDtObj.businessNameStateFormationWithoutLegalDesignator = !String.isBlank(acc.Business_Name_in_state_country__c)?getNameWithoutDesignators(acc.Business_Name_in_state_country__c):'';
                brsBusDtObj.businessAgentName = agentObj.Name__c!=null?agentObj.Name__c:null;
                brsBusDtObj.agentType = agentObj.Type__c!=null?agentObj.Type__c:null;
                brsBusDtObj.businessStatus = acc.Status__c!=null?acc.Status__c.toUppercase():null; 
                brsBusDtObj.businessType = acc.Business_Type__c!=null?acc.Business_Type__c:null;  
                brsBusDtObj.businessCitizen = acc.Citizenship__c!=null?acc.Citizenship__c:null;
                brsBusDtObj.showLegalExistenancePopup= showLegalExistenancePopup;
                brsBusDtObj.certRequestDate = certRequestDate;
                brsBusDtObj.isFilingOverDue= isFilingOverDue;
                brsBusDtObj.isAgentAcceptancePending= isAgentAcceptancePending;
                brsBusDtObj.isAgentReviewPending = isAgentReviewPending;
                brsBusDtObj.dissolvedWithIn120Days = acc.Dissolution_date__c != null ? (acc.Dissolution_date__c.daysBetween(Date.today()) > 120) ? false : true :false;
                brsBusDtObj.isAnnualReportDue = isAnnualReportDue;
                // adding rejected business filing variable to throw error on search and select BRS-5164
                brsBusDtObj.isBusinessFilingRejected = isBusinessFilingRejected;
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1690
                * Change(s)/Modification(s) Description : Adding the new wrapper variable to showing principal and count
                * Change(s)/Modification(s) Made on : 2021-02-01
                * Author : Avinash Shukla
                */
				brsBusDtObj.principalName = principalName;
                brsBusDtObj.principalCount = principalCount;
                // Added fix for BRS-2160
                brsBusDtObj.hasZeroPrincipal = principalCount < 1 ? true : false;
				/**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2671
                * Change(s)/Modification(s) Description : Assigning the boolean value of foreign investigation check to isFIPresent.
                * Change(s)/Modification(s) Made on : 24-06-2021
                * Change(s)/Modification(s) Made by : Tamkanat
                */
                brsBusDtObj.isFIPresent = foreignInvsPresent;
				brsBusDtObj.fIName=foreignInvNumber;
				// Changes made for BRS-2619
                
				if(flowName==System.Label.First_Report_Label|| flowName==System.Label.Annual_Report_Label || flowName==System.Label.Maintenance_Flow && accIdFilingMap.get(acc.Id)!=null){
                    brsBusDtObj.isFirstReportDue = isFirstReportDue;
                }                
                brsBusDtObj.businessSubStatus = accIdFilingMap.get(acc.Id)!=null && acc.Sub_status__c!=null? brs_searchBusinessController.checkAccSubStatus(acc.Sub_status__c, null):null;
                
                if(acc.BillingState == system.label.brs_maintenance_stateinCT)
                {
                    brsBusDtObj.isPrincipleAddressOfCT = true; 
                } 
                else
                {
                    brsBusDtObj.isPrincipleAddressOfCT = false;
                }
                // End for BRS-1694
                List<String> billingAddrFields = System.Label.BRS_BillingAddrFields.split(',');
                String businessAddress = acc.Principle_Office_International_Address__c!= null ? acc.Principle_Office_International_Address__c + ', ' + acc.BillingCountry!=null?acc.BillingCountry:'': BRS_Utility.getAddress(acc, billingAddrFields);
                brsBusDtObj.businessAddress = businessAddress;
                business_filing__c busfilingObject = new  business_filing__c();
                if(accIdFilingMap.get(acc.Id)!=null){                    
                    busfilingObject = accIdFilingMap.get(acc.Id);
                    brsBusDtObj.filingId = busfilingObject.Id;
                        if(busfilingObject.Type__c==System.Label.First_Report_Label && (flowName==System.Label.First_Report_Label || flowName==System.Label.Annual_Report_Label || flowName==System.Label.Maintenance_Flow)) {
                            brsBusDtObj.businessDueFilings = busfilingObject.Due_Date__c != null ? String.valueOf(busfilingObject.Due_Date__c.format()):null;
                            brsBusDtObj.firstDueCount= busfilingObject.Due_Date__c != null ? (system.today()).daysBetween(Date.valueOf(busfilingObject.Due_Date__c)):null;
							// Change made for 1099 Updates BRS-2400
							brsBusDtObj.isAnnualorFirst = true;
							brsBusDtObj.isFirstReport = true;
							brsBusDtObj.isFirstReportDue = isFirstReportDue;
							if(String.isBlank(busStr)){
								brsBusDtList.add(brsBusDtObj);
							}
                        if(acc.Sub_status__c==System.label.Ready_for_dissolution || acc.Sub_status__c==System.Label.Admin_Dissolution_Initiated_Label || acc.Sub_status__c==System.Label.brs_AdminDissolveReady_for_Forfeiture|| acc.Sub_status__c==System.Label.brs_AdminDissolveReady_for_Revocation){
								brsBusDtObj.businessSubStatus = acc.Sub_status__c!=null? brs_searchBusinessController.checkAccSubStatus(acc.Sub_status__c, System.Label.The_First_Report_translation):null;
                        }
                        }
                    else if(busfilingObject.Type__c==System.Label.Annual_Report_Label){
                         brsBusDtObj.isFirstReport = false;
						 brsBusDtObj.isFirstReportDue = isFirstReportDue;
                        if(accIdFilingCountMap.get(acc.Id)!=null && accIdFilingCountMap.get(acc.Id)>1){
                            annualDueCount =  accIdFilingCountMap.get(acc.Id);
                            brsBusDtObj.businessDueFilings = busfilingObject.Due_Date__c != null ? BRS_Utility.getMonth(busfilingObject.Due_Date__c.Month())+' '+busfilingObject.Due_Date__c.Year()+' (+'+accIdFilingCountMap.get(acc.Id) +')' : null;
                        } 
                        else{
                            annualDueCount =  1;
                            brsBusDtObj.businessDueFilings = busfilingObject.Due_Date__c != null ? BRS_Utility.getMonth(busfilingObject.Due_Date__c.Month())+' '+busfilingObject.Due_Date__c.Year() : null;
							
                        }
                        if(acc.Sub_status__c==System.label.Ready_for_dissolution || acc.Sub_status__c==System.Label.Admin_Dissolution_Initiated_Label || acc.Sub_status__c==System.Label.brs_AdminDissolveReady_for_Forfeiture|| acc.Sub_status__c==System.Label.brs_AdminDissolveReady_for_Revocation){
                            brsBusDtObj.businessSubStatus = acc.Sub_status__c!=null? brs_searchBusinessController.checkAccSubStatus(acc.Sub_status__c, System.Label.The_Annual_Report_translation):null;
                        }
                        if(((busfilingObject.Status__c !=System.Label.Approved && (flowName==System.Label.Annual_Report_Comparable || flowName==System.Label.First_Report)) ||  (busfilingObject.Status__c !=system.label.Submitted_Agent_acceptance_pending && busfilingObject.Status__c !=system.label.Submitted_Agency_review_pending && busfilingObject.Status__c !=System.Label.Approved && flowName==System.Label.Maintenance_Flow ))){
                            brsBusDtObj.annualDueCount = annualDueCount;
                        }			
						/**
						* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1690  
						* Change(s)/Modification(s) Description : Adding condition to show message for Annual report due or first report due
						* Change(s)/Modification(s) Made on : 2021-02-04
						* Author : Avinash Shukla
						*/
						brsBusDtObj.isAnnualorFirst = true;
						// Change made for 1099 Updates BRS-2400
						if(String.isBlank(busStr)){
                            brsBusDtList.add(brsBusDtObj);
                        }
                    } 
                }
                /**
                * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-2476
                * Change(s)/Modification(s) Description : Adding condition to show account details when the flow is 'Revocation'.
                * Change(s)/Modification(s) Made on : 2021-03-152021-03-15
                * Change(s)/Modification(s) Made by : Avinash Shukla
                */
                if((!String.isBlank( busStr) || flowName==System.Label.Maintenance_Flow || flowName == Label.Revocation_Dissolution_Flow) && !brsBusDtList.contains(brsBusDtObj)){
                    brsBusDtList.add(brsBusDtObj);
                }
            }
            return brsBusDtList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, className, null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @InvocableMethod
    public static List<Results> getBusinessInv(List<Requests> Requests) {
        List<Results> lstResults = new List<Results>();
        List<brs_searchBusinessController> brsBusDtList = brs_searchBusinessController.getBusiness(Requests[0].busStr,Requests[0].flowName);
            if(!brsBusDtList.isEmpty()){
                    Results r = new Results();
                    r.records = Json.serialize(brsBusDtList);
                    lstResults.add(r);
                
            }
            return lstResults;
    }
     global with sharing class Requests {
        @InvocableVariable
        global string busStr;
         @InvocableVariable
        global string flowName;
         
    }    
      global with sharing class Results {
        @InvocableVariable
        global string records;
    }
	/********************************************************************************************
        METHOD NAME    : checkAccSubStatus
        RETURN TYPE    : String
        PARAMETER      : String, String
		Date           : 3/9/2021
    ********************************************************************************************/
    public static string checkAccSubStatus(String subStatus, String firstOrAnnualPrefix){
        String subStatusStr = '';
        if(subStatus==System.label.Annual_Report_Due1_Comparable){
            subStatusStr = System.label.Annual_report_is_coming_due +' '+ System.label.Faliure_to_file;
        }
        else if(subStatus==System.label.Annual_report_past_due){
            subStatusStr = System.label.Annual_report_is_past_due +' '+ System.label.Faliure_to_file;
        }
        else if(subStatus==System.label.First_Report_Due_Comparable){
            subStatusStr = System.label.First_report_is_coming_due +' '+ System.label.Faliure_to_file;
        }
        else if(subStatus==System.label.First_report_past_due_Comparable){
            subStatusStr = System.label.First_report_is_past_due+' '+ System.label.Faliure_to_file;
        }
        else if(subStatus==System.label.Ready_for_dissolution || subStatus==System.Label.Admin_Dissolution_Initiated_Label || subStatus==System.Label.brs_AdminDissolveReady_for_Forfeiture|| subStatus==System.Label.brs_AdminDissolveReady_for_Revocation){
            subStatusStr = firstOrAnnualPrefix +' '+System.label.is_past_due+' '+ System.label.Faliure_to_file;
        }
        return subStatusStr;
    }
    /********************************************************************************************
    METHOD NAME    : checkAvailability
    DESCRIPTION    : returns the name of account that exactly matches the search account name
    RETURN TYPE    : String
    PARAMETER      : Account name to search
    ********************************************************************************************/
    @AuraEnabled    
    public static String checkAvailability(String accName) {
        String response = '';
        String activeStatus = System.label.ACTIVE;
        List<Account> acList = new List<Account>();
        if(String.isNotBlank(accName)){
            acList = [Select Id, Name, Account_Name_Without_Designators__c from Account WHERE Account_Name_Without_Designators__c LIKE : accName AND Status__c=:activeStatus WITH SECURITY_ENFORCED];
            if(!acList.isEmpty()){
                response = acList.get(0).Name;
            } else {
                response = Label.businessNameAvailableMessage;
            }
        } else {
            response = Label.businessNameAvailableMessage;
        }
        return response;
    }
    public static String getNameWithoutDesignators(String businessName){
        try{
        
            List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
            List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
            Integer count = 1;
            String tempAccount_Name_Without_Designators;
            if(businessName !=null  || businessName == ''){ 
                tempAccount_Name_Without_Designators= ' ' + businessName.normalizeSpace() + ' ';
                for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                    if((tempAccount_Name_Without_Designators != '' || tempAccount_Name_Without_Designators != null) && noiseWrd.Label!='.' && ((tempAccount_Name_Without_Designators).containsIgnoreCase(noiseWrd.Label))){                           
                        // Added if condition for 'The' and 'AND'
                        if(!(noiseWrd.Label).isAlpha()){
                            tempAccount_Name_Without_Designators = ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                        else{
                            tempAccount_Name_Without_Designators = ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                        }
                    }                    
                }
                for(brs_SortLegalDesignators desgn : listOfDesignators) {
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                }
                tempAccount_Name_Without_Designators = ((tempAccount_Name_Without_Designators).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
            }
            return  tempAccount_Name_Without_Designators;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getNameWithoutDesignators', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled    
    public static Boolean checkAccountHasDuplicateDissolution(String accId) {
        Boolean responseDissolution = false;
        String activeStatus = System.label.ACTIVE;
        List<Business_Filing__c> busList = new List<Business_Filing__c>();
        if(String.isNotBlank(accId)){
            busList=[select Type__c,Name,id,Effective_Date__c from Business_Filing__c where Type__c='Dissolution' and Status__c='Approved' and Account__r.Status__c=:activeStatus and Effective_Date__c >= TODAY and Account__c=:accId];
            if(!busList.isEmpty()){
                responseDissolution=true;
            }
        } 
        return responseDissolution;
    }
}