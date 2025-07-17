public without sharing class AccountTriggerHelper {

    /********************************************************************************************
        METHOD NAME    : updateAccountBackendName
        DESCRIPTION    : Method to update Backend Account Name after removing the Legal designators
						 and Noise words from the Business Name.
        PARAMETER      : List<Account> and Map<ID, Account>
    ********************************************************************************************/
    public static void setNameForForeignMerger(List<Account> newTriggerList){
        for(Account account : newTriggerList){
            
            if(account.Citizenship__c == 'Foreign' && account.Business_Type__c =='Unauthorized' && account.Surviving_Account__c!=null){
                account.AccountNumber = '0000000';
            }

        }
    }

    /**
     * @desc: BRS-7805 | Copy relevant address as admin dissolution address
     * priority: Billing, Shipping, Agent.Residence, Agent.Mailing, Agent.Business
     * @author: Sonika
     * @update: BRS-8638 | Shreya | Update logic
     */
    public static void updateAdmindissolutionAddress(List<Account> listRecords, Map<Id,SObject> oldMap) {
        List<Account> listDissolutionAccounts = new List<Account>();

        for(Account newAccount :listRecords) {
            if(System.Label.Ready_for_dissolution_Comparable.equalsIgnoreCase(newAccount.Sub_status__c)
                &&
                newAccount.Sub_status__c != oldMap.get(newAccount.Id).get('Sub_status__c')
            ) {
                listDissolutionAccounts.add(newAccount);
            }
        }

        //if dissolution to be initiated
        if(!listDissolutionAccounts.isEmpty()) {
            Map<Id, Agent__c> mapBusinessAgent = new Map<Id, Agent__c>();
        
            for(Agent__c agent : [
                SELECT Business_ID__c,
                    Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,
                    Residence_City__c,Residence_State__c,Residence_Country__c,Residence_Zip_Code__c,
                    Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,
                    Mailing_City__c, Mailing_State__c,Mailing_Country__c,Mailing_Zip_Code__c,
                    Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                    Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c
                FROM Agent__c 
                WHERE Business_ID__c IN :listDissolutionAccounts
                WITH SECURITY_ENFORCED
            ]){
                mapBusinessAgent.put(agent.Business_ID__c, agent);
            }

            //Set dissolution address
            for(Account account :listDissolutionAccounts) {
                //1. Billing Address
                if(account.BillingStreet != null 
                    && account.BillingCity != null 
                    && account.BillingState != null 
                    && account.BillingPostalCode != null
                ) {
                    account.Admin_Dissolution_Address__c = account.BillingStreet;
                    account.Admin_Dissolution_City__c = account.BillingCity;
                    account.Admin_Dissolution_State__c = account.BillingState;
                    account.Admin_Dissolution_Zip_Code__c = account.BillingPostalCode;
                    account.Admin_Dissolution_Country__c = account.BillingCountry;
                }

                //2. Shipping Address
                else if(account.ShippingStreet != null 
                    && account.ShippingCity != null 
                    && account.ShippingState != null 
                    && account.ShippingPostalCode != null
                ) {
                    account.Admin_Dissolution_Address__c = account.ShippingStreet;
                    account.Admin_Dissolution_City__c = account.ShippingCity;
                    account.Admin_Dissolution_State__c = account.ShippingState;
                    account.Admin_Dissolution_Zip_Code__c = account.ShippingPostalCode;
                    account.Admin_Dissolution_Country__c = account.ShippingCountry;
                }

                //3. if no account address, search agent
                else if(mapBusinessAgent.containsKey(account.Id)) {
                    Agent__c agent = mapBusinessAgent.get(account.Id);

                    //3.1. Residence
                    if(agent.Residence_Street_Address_1__c != null 
                        && agent.Residence_City__c != null 
                        && agent.Residence_State__c != null 
                        && agent.Residence_Zip_Code__c != null
                    ) {
                        account.Admin_Dissolution_Address__c = agent.Residence_Street_Address_1__c 
                            + (agent.Residence_Street_Address_2__c != null ? ', ' + agent.Residence_Street_Address_2__c : '') 
                            + (agent.Residence_Street_Address_3__c != null ? ', ' + agent.Residence_Street_Address_3__c : '');
                        account.Admin_Dissolution_City__c = agent.Residence_City__c;
                        account.Admin_Dissolution_State__c = agent.Residence_State__c;
                        account.Admin_Dissolution_Zip_Code__c = agent.Residence_Zip_Code__c;
                        account.Admin_Dissolution_Country__c = agent.Residence_Country__c;
                    }

                    //3.2. Mailing
                    else if(agent.Mailing_Street_Address_1__c != null 
                        && agent.Mailing_City__c != null 
                        && agent.Mailing_State__c != null 
                        && agent.Mailing_Zip_Code__c != null
                    ) {
                        account.Admin_Dissolution_Address__c = agent.Mailing_Street_Address_1__c 
                            + (agent.Mailing_Street_Address_2__c != null ? ', ' + agent.Mailing_Street_Address_2__c : '') 
                            + (agent.Mailing_Street_Address_3__c != null ? ', ' + agent.Mailing_Street_Address_3__c : '');
                        account.Admin_Dissolution_City__c = agent.Mailing_City__c;
                        account.Admin_Dissolution_State__c = agent.Mailing_State__c;
                        account.Admin_Dissolution_Zip_Code__c = agent.Mailing_Zip_Code__c;
                        account.Admin_Dissolution_Country__c = agent.Mailing_Country__c;
                    }

                    //3.3. Business
                    else if(agent.Business_Street_Address_1__c != null 
                        && agent.Business_City__c != null 
                        && agent.Business_State__c != null 
                        && agent.Business_Zip_Code__c != null
                    ) {
                        account.Admin_Dissolution_Address__c = agent.Business_Street_Address_1__c 
                            + (agent.Business_Street_Address_2__c != null ? ', ' + agent.Business_Street_Address_2__c : '') 
                            + (agent.Business_Street_Address_3__c != null ? ', ' + agent.Business_Street_Address_3__c : '');
                        account.Admin_Dissolution_City__c = agent.Business_City__c;
                        account.Admin_Dissolution_State__c = agent.Business_State__c;
                        account.Admin_Dissolution_Zip_Code__c = agent.Business_Zip_Code__c;
                        account.Admin_Dissolution_Country__c = agent.Business_Country__c;
                    }
                }
            }
        }
    }
    
    public static void updateAccountBackendName(List<Account> newTriggerList, Map<Id,SObject> oldTriggerMap){
        Boolean updateTrigger = false;
		Boolean isDefaultAccountName = false;
        String initialFlowBusinessName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
		String tempAccountName = System.Label.New_Business;
		List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();		
        List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
		Map<Id, Account>  accountMap = new Map<Id, Account>();
        /** Get business record type id **/
        Id businessRecordTypeId = Wizard_Utlity.getRecordTypeId(system.label.AccountRecordType_Business,Schema.Account.getSObjectType());
        Id personRECORDTYPEID = Wizard_Utlity.getRecordTypeId(system.label.AccountRecordType_Person,Schema.Account.getSObjectType());
        
        
        
        for (Account account : newTriggerList){
            Integer count = 1;
            updateTrigger = false;
            
            if (account.RecordTypeId == personRecordTypeId) { continue; } // Skip the rest of the loop for Person Accounts if no further processing is required
            
			/***
                Once an account status is changed to Active - Ready for Admin Dissolution 
                (this status automation is taken care in other stories) there must be a validation check 
                on the account addresses.
                    First check if there is a Principal Office address on record
                    Second check if there is a mailing address on record
                    Third check if the agent associated with the business account has an address
            **/
            if(account.sub_status__c == system.label.Active_Ready_for_Admin_Dissolution && account.RecordTypeId == businessRecordTypeId &&
                   ( (account.BillingStreet == null && account.BillingCity == null && account.BillingCountry == null &&
                    account.BillingState == null && account.BillingPostalCode == null &&
                    account.ShippingStreet == null && account.ShippingCity == null && account.ShippingCountry == null &&
                    account.ShippingState == null && account.ShippingPostalCode == null) ||
                    ((account.Business_Address_1__c != null && (String.valueOf(account.Business_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(account.Business_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ((account.Mailing_Address_1__c != null && (String.valueOf(account.Mailing_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(account.Mailing_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) || account.Mailing_Address_1__c == null)) ||
                    ((account.Mailing_Address_1__c != null && (String.valueOf(account.Mailing_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(account.Mailing_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ((account.Business_Address_1__c != null && (String.valueOf(account.Business_Address_1__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(account.Business_Address_1__c).toLowerCase().contains(system.label.None.toLowerCase()))) || account.Business_Address_1__c == null)) ||
                    (account.citizenship__c == system.label.Foreign && account.Business_Type__c == system.label.Statutory_Trust))){
                accountMap.put(account.Id,account);
            }
            if(account.sub_status__c != null && account.status__c != null && (account.sub_status__c == system.label.Admin_Dissolution_Initiated_Label || account.sub_status__c == system.label.Ready_for_dissolution_Comparable || account.sub_status__c == system.label.brs_AdminDissolveReady_for_Forfeiture || account.sub_status__c == system.label.brs_AdminDissolveReady_for_Revocation) && 
               (account.Status__c != system.label.Active && account.Status__c != system.label.brsstatus_conversionPending && account.Status__c != system.label.brs_Domistication_Accepted_Domestication_Pending))
            {
                account.sub_status__c = null;
            }
            if((oldTriggerMap!=null && !oldTriggerMap.isEmpty()) || UserInfo.getName()==System.Label.Data_Admin_Label){
                updateTrigger = true;
                if((account.Name != oldTriggerMap.get(account.Id).get('Name')) || UserInfo.getName()==System.Label.Data_Admin_Label){
                    isDefaultAccountName = ((account.Name).containsIgnoreCase(initialFlowBusinessName))?true:((account.Name).equalsIgnoreCase(tempAccountName)?true:false);
                }
                else if(account.Status__c != oldTriggerMap.get(account.Id).get('Status__c') && account.Status__c != system.label.Active && account.Status__c != system.label.brsstatus_conversionPending && account.Status__c != system.label.brs_Domistication_Accepted_Domestication_Pending && account.sub_status__c != null && account.status__c != null && (account.sub_status__c == system.label.Ready_for_dissolution || account.sub_status__c == system.label.brs_AdminDissolveReady_for_Forfeiture || account.sub_status__c == system.label.brs_AdminDissolveReady_for_Revocation || account.sub_status__c == system.label.Admin_Dissolution_Initiated_Label))
                {
                    account.sub_status__c = null;
                }
                else{
                    break;
                }
            }
            else{
                updateTrigger = false;
                isDefaultAccountName = ((account.Name).containsIgnoreCase(initialFlowBusinessName))?true:((account.Name).equalsIgnoreCase(tempAccountName)?true:false);                
            }
			
            String tempAccount_Name_Without_Designators = ' ' + (account.Name).normalizeSpace() + ' ';
            if(tempAccount_Name_Without_Designators.contains('Professional Corporation')){
                tempAccount_Name_Without_Designators = tempAccount_Name_Without_Designators.replace('Professional Corporation', 'ProfessionalCorporation');
            }
            for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                if (!isDefaultAccountName) {
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
                else{
                    if(count==1){
                        account.Account_Name_Without_Designators__c = QnA_Constants.EMPTY_STRING;
                        count++;
                    }
                }                 
            }
            count = 1;
            for(brs_SortLegalDesignators desgn : listOfDesignators){
                if(!isDefaultAccountName){            
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                    if((' '+tempAccount_Name_Without_Designators+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                        tempAccount_Name_Without_Designators= ' ' + (((tempAccount_Name_Without_Designators).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                    }
                }
                else{
                    if(count == 1){
                        account.Account_Name_Without_Designators__c = QnA_Constants.EMPTY_STRING;
                        count++;
                    }
                }
            }  
            tempAccount_Name_Without_Designators = Accents.removeDiacritics(tempAccount_Name_Without_Designators);   
            tempAccount_Name_Without_Designators = ((tempAccount_Name_Without_Designators).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
            account.Account_Name_Without_Designators__c = tempAccount_Name_Without_Designators;
        }
		/** Third check if the agent associated with the business account has an address **/
		for(Agent__c agent : [SELECT Id, Business_Address__c,Agent_Residence_Address__c,Mailing_Address__c, Business_ID__c
                                FROM Agent__c 
                                WHERE Business_ID__c IN: accountMap.keyset() AND Business_ID__c!=null WITH SECURITY_ENFORCED]){
            Account account = accountMap.get(agent.Business_ID__c);
            
            if(account.citizenship__c == system.label.Foreign && account.Business_Type__c == system.label.Statutory_Trust){
                account.addError(system.label.Foreign_Statutory_Trust_error_message);
            }
            
           if((agent.Business_Address__c == null && agent.Agent_Residence_Address__c == null && agent.Mailing_Address__c == null) ||
                ((agent.Business_Address__c != null && (string.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (agent.Agent_Residence_Address__c == null || (agent.Agent_Residence_Address__c != null && (string.valueOf(agent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (agent.Mailing_Address__c == null || ( agent.Mailing_Address__c != null && (string.valueOf(agent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(agent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))))) ||
                ((agent.Business_Address__c == null || (agent.Business_Address__c != null && (string.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (agent.Agent_Residence_Address__c != null && (string.valueOf(agent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress) || String.valueOf(agent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (agent.Mailing_Address__c == null || ( agent.Mailing_Address__c != null && (string.valueOf(agent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase())))) ||
                ((agent.Business_Address__c == null || (agent.Business_Address__c != null && (string.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Business_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && (agent.Agent_Residence_Address__c == null || (agent.Agent_Residence_Address__c != null && (string.valueOf(agent.Agent_Residence_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Agent_Residence_Address__c).toLowerCase().contains(system.label.None.toLowerCase()))) && ( agent.Mailing_Address__c != null && (string.valueOf(agent.Mailing_Address__c ).toLowerCase().contains(system.label.brs_AdminDissolveNoInfoAddress)) || String.valueOf(agent.Mailing_Address__c).toLowerCase().contains(system.label.None.toLowerCase())))){
                account.No_address_found__c = true;
            }
            
            accountMap.remove(agent.Business_ID__c);
		}
		/** if no agent is associated update reason **/
        for(Account account : accountMap.values()){
            //account.Reason_for_Administrative_Dissolution__c = system.label.Failure_to_appoint_or_maintain_an_agent_for_service;
			account.No_address_found__c = true;
        }
    }
	
	/********************************************************************************************
        METHOD NAME    : checkForDuplicates
        DESCRIPTION    : Method to check if the account name used already exists.
        PARAMETER      : List<Account> and Map<ID, Account>
    ********************************************************************************************/
    public static void checkForDuplicates(List<Account> newTriggerList, Map<Id,SObject> oldTriggerMap){
        if(!newTriggerList.isEmpty())
        {
            Set<String> accountNameSet = new Set<String>();
            Set<String> accountNameSetWithDesgntrs = new Set<String>();
            List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();        
            List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
            Map<String,Account> existingAccMap = new Map<String,Account>();         
            Boolean checkForDuplicates = false;
            Boolean checkReservedNames = false;

            for(Account account: newTriggerList)
            {
                if(oldTriggerMap!=null && !oldTriggerMap.isEmpty()){                    
                    if(account.Name != oldTriggerMap.get(account.Id).get('Name')){
                        checkForDuplicates = true;
                    }
                    else{
                        break;
                    }
                }
                else{
                    checkForDuplicates = true;
                }
                if(checkForDuplicates){
                    if((account.Business_Type__c != null && account.Business_Sub_Type__c != null &&  !(account.Business_Sub_Type__c.equalsIgnoreCase(System.label.brs_GeneralPartnership))) && (!(account.Business_Type__c.equalsIgnoreCase(System.label.brs_GeneralPartnership)))){
                        if(account.Account_Name_Without_Designators__c != NULL)
                        {
                            accountNameSet.add(account.Account_Name_Without_Designators__c);
                        }
                    }
                }
            }
            
            if(checkForDuplicates){
                if(!accountNameSet.isEmpty())
                {
                    for(Account existingAccount : [Select Id, Name, Account_Name_Without_Designators__c from Account where (Status__c =: System.label.ACTIVE OR Status__c =: System.label.brs_BusinessReservationStatus) AND (Business_Sub_Type__c !=: System.label.brs_GeneralPartnership AND Business_Type__c !=: System.label.brs_GeneralPartnership) AND Reserved_Name_Used__c = false AND Is_Intake_Filing__c= false AND (Account_Name_Without_Designators__c IN: accountNameSet) WITH SECURITY_ENFORCED])
                    {
                        existingAccMap.put(existingAccount.Account_Name_Without_Designators__c,existingAccount);                      
                    }

                    for(Temp_History__c tempRecords : [Select Id, BusinessName_New_Without_Designators__c, Business_Filing__c, Business_Filing__r.Type__c, Business_Filing__r.Status__c, Business_Filing__r.Account__c, Business_Filing__r.Account__r.Name, Business_Filing__r.Account__r.Account_Name_Without_Designators__c, Business_Name_New__c from Temp_History__c where (Business_Filing__r.type__c =: System.label.Name_Change_Amendment OR Business_Filing__r.type__c =: System.label.Business_Formation_Label OR Business_Filing__r.type__c =: System.label.Business_Registration_Label) AND (Business_Filing__r.Status__c =: System.label.BRS_Submitted_Agent_acceptance_pending OR Business_Filing__r.Status__c =: System.label.Submitted_Agency_review_pending OR Business_Filing__r.Status__c =: System.label.Label_Pending_Filing_1) AND BusinessName_New_Without_Designators__c IN: accountNameSet WITH SECURITY_ENFORCED]){
                        if(tempRecords.Business_Filing__r.type__c == System.label.Name_Change_Amendment){
                            if(tempRecords.BusinessName_New_Without_Designators__c != null){
                                accountNameSetWithDesgntrs.add(tempRecords.BusinessName_New_Without_Designators__c);
                            }
                        }
                    }
                    
                    for(Business_Filing__c filinRec : [Select Id, Type__c, Status__c, Account__c, Account__r.Name, Account__r.Account_Name_Without_Designators__c from Business_Filing__c where (type__c =: System.label.Name_Change_Amendment OR type__c =: System.label.Business_Formation_Label OR type__c =: System.label.Business_Registration_Label) AND (Status__c =: System.label.BRS_Submitted_Agent_acceptance_pending OR Status__c =: System.label.Submitted_Agency_review_pending OR Status__c =: System.label.Label_Pending_Filing_1) AND Account__r.Account_Name_Without_Designators__c IN: accountNameSet WITH SECURITY_ENFORCED]){
                        if(filinRec.type__c == System.label.Business_Formation_Label || filinRec.type__c == System.label.Business_Registration_Label){
                            if(filinRec.Account__r.Account_Name_Without_Designators__c != null){
                                accountNameSetWithDesgntrs.add(filinRec.Account__r.Account_Name_Without_Designators__c);
                            }
                        }
                    }                    
                }
                
                for(Account accountRecord: newTriggerList)
                {
                    if(accountRecord.Account_Name_Without_Designators__c != NULL){
                        if(existingAccMap.containsKey(accountRecord.Account_Name_Without_Designators__c))
                        {
                            if(existingAccMap.get(accountRecord.Account_Name_Without_Designators__c).id != accountRecord.Id){
                                accountRecord.addError(System.label.brs_DuplicateNameErrorMssg);
                            }
                            else if(accountNameSetWithDesgntrs.contains(accountRecord.Account_Name_Without_Designators__c)){
                                accountRecord.addError(System.label.brs_DuplicateNameErrorMssg);
                            }
                        }
                        else{
                            checkReservedNames = true;
                        }              
                    }
                }

                if(checkReservedNames){
                    Map<String,Account> checkReservedAccs = checkForReservedAccounts(listOfDesignators, listOfNoiseWords);
                    
                    for(Account accountRecord: newTriggerList)
                    {
                        if(checkReservedAccs.containsKey(accountRecord.Account_Name_Without_Designators__c)){
                            Account accObject = checkReservedAccs.get(accountRecord.Account_Name_Without_Designators__c);
                            if(accountRecord.Reserved_Account_Id__c == null || accObject.Id!=accountRecord.Reserved_Account_Id__c){
                                accountRecord.addError(System.label.brs_DuplicateNameErrorMssg);
                            }
                        }
                    }
                }
            }
        }
    }

    /**********************************************************************************************************************
        METHOD NAME    : checkForReservedAccounts
        DESCRIPTION    : Method to check acroos all reserved names with Account_Name_Without_Designators__c as null/blank.
        PARAMETER      : List<brs_SortLegalDesignators> and List<Business_Name_Noisewords__mdt>
    ***********************************************************************************************************************/

    public static Map<String,Account> checkForReservedAccounts(List<brs_SortLegalDesignators> listOfDesignators, List<Business_Name_Noisewords__mdt> listOfNoiseWords){
        Map<String,Account> checkReservedAccs = new Map<String,Account>();
        
        for(Account reservedAccs : [Select Id, Name,Reserved_Account_Id__c, Account_Name_Without_Designators__c from Account where Status__c =: System.label.brs_BusinessReservationStatus AND Reserved_Name_Used__c = false AND AccNameWithoutDesignatorsIsNull__c = true AND Reserved_User__c != :UserInfo.getUserId() AND Is_Intake_Filing__c= false WITH SECURITY_ENFORCED LIMIT 50000])
        {
            String tempReservedAccName = ' ' + (reservedAccs.Name).normalizeSpace() + ' ';
            for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                if((tempReservedAccName != '' || tempReservedAccName != null) && noiseWrd.Label!='.' && ((tempReservedAccName).containsIgnoreCase(noiseWrd.Label))){                           
                    // Added if condition for 'The' and 'AND'
                    if(!(noiseWrd.Label).isAlpha()){
                        tempReservedAccName = ' ' + (((tempReservedAccName).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                    }
                    else{
                        tempReservedAccName = ' ' + (((tempReservedAccName).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                    }
                }                    
            }
            for(brs_SortLegalDesignators desgn : listOfDesignators) {               
                if((' '+tempReservedAccName+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                    tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                }
                if((' '+tempReservedAccName+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                    tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                }
                if((' '+tempReservedAccName+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                    tempReservedAccName= ' ' + (((tempReservedAccName).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                }
            }
            tempReservedAccName = ((tempReservedAccName).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
            checkReservedAccs.put(tempReservedAccName, reservedAccs);
        }
        return checkReservedAccs;
    }

    public static void createNameHistoryTableRecs(Map<Id, SObject> newItems,Map<Id, SObject> oldMap) {
        Set<Id> accIds = new Set<Id>();
        for(Id inst : newItems.keyset()){
            accIds.add(inst);
        }
        List<Business_Filing__c> BusinessFileList = new List<Business_Filing__c>();
        try {
            BusinessFileList = [Select Status__c,Type__c,Sub_Type__c,Account__r.Name,(Select Id,Business_Name__c,Business_Name_New__c,Business_Name_in_state_country_New__c,Business_Name_in_state_country__c from Temp_History__r where Type_of_Update__c = 'Name') from Business_Filing__c where Account__c IN: accIds  AND Source__c!='Online' AND (Status__c='In-Progress' OR Status__c='Submitted - Intake pending' ) WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            BOS_Utility.handleException(e);
            /**
             * Debug chatbot issue
             * 
            Map<String,Set<String>> inaccessible_field_map = e.getInaccessibleFields();
            for (String key : inaccessible_field_map.keySet())
            {
                system.debug('---key---: ' + key);
                for (String value : inaccessible_field_map.get(key)) {
                    system.debug('value: ' + value);
                }
            }
             *
             */
        }
        List<Temp_History__c> historyList = new List<Temp_History__c>();
        for(SObject sobj : BusinessFileList){
            Business_Filing__c obj = (Business_Filing__c)sobj;
            if(((obj.Type__c == System.label.Amendment_label_Comparable || obj.Type__c == system.label.brs_name_change_amendment_flow ||
            obj.Type__c == System.label.Merger_Label || obj.Type__c == System.label.Conversion_Label || obj.Type__c == System.label.Domestication_Label) ||
            (obj.Type__c == System.label.RevocationDissolution_Header_Question && obj.Sub_Type__c == system.label.With_NameChange_Label)||
            (obj.Type__c == System.label.brs_Reinstatement && (obj.Sub_Type__c == system.label.withAnnual_NameChange || obj.Sub_Type__c == system.label.FirstReport_NameChange_Label)))){
                if((newItems.get(obj.Account__c).get('Name') != oldMap.get(obj.Account__c).get('Name')) || (newItems.get(obj.Account__c).get('Business_Name_in_state_country__c') != oldMap.get(obj.Account__c).get('Business_Name_in_state_country__c'))){
                    Temp_History__c tempHisInst = new Temp_History__c();
                    tempHisInst.Account__c = obj.Account__c;
                    tempHisInst.Business_Filing__c = obj.Id;
                    if(!obj.Temp_History__r.isEmpty()){
                        tempHisInst.Id=obj.Temp_History__r[0].Id;
                            tempHisInst.Business_Name__c = obj.Temp_History__r[0].Business_Name__c!=null?obj.Temp_History__r[0].Business_Name__c:null;
                            tempHisInst.Business_Name_New__c = String.valueOf(newItems.get(obj.Account__c).get('Name'));
                            tempHisInst.Business_Name_in_state_country_New__c = String.valueOf(newItems.get(obj.Account__c).get('Business_Name_in_state_country__c'));
                            tempHisInst.Business_Name_in_state_country__c = obj.Temp_History__r[0].Business_Name_in_state_country__c!=null?obj.Temp_History__r[0].Business_Name_in_state_country__c:null;                    
                    }else{
                    if(newItems.get(obj.Account__c).get('Name') != null || newItems.get(obj.Account__c).get('Name') != ''){
                        tempHisInst.Business_Name_New__c = String.valueOf(newItems.get(obj.Account__c).get('Name'));
                        tempHisInst.Business_Name__c = String.valueOf(oldMap.get(obj.Account__c).get('Name'));
                    }
                    if(newItems.get(obj.Account__c).get('Business_Name_in_state_country__c') != null || newItems.get(obj.Account__c).get('Business_Name_in_state_country__c') != ''){
                        tempHisInst.Business_Name_in_state_country_New__c = String.valueOf(newItems.get(obj.Account__c).get('Business_Name_in_state_country__c'));
                        tempHisInst.Business_Name_in_state_country__c = String.valueOf(oldMap.get(obj.Account__c).get('Business_Name_in_state_country__c'));
                    }
                    tempHisInst.Type_of_Update__c = 'Name';
                }
                    historyList.add(tempHisInst);
                }

            }
            
        }
        if(!historyList.IsEmpty()){
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(historyList, 'upsert');
                if(bAccessCheck){
                    Upsert historyList;
                }
        }
    }
    public static void createFirstReport(Map<Id, Sobject> newItems,Map<Id, Sobject> oldMap) {
        Set<Id> accountIds=new Set<Id>();
        for(sObject sobj: newItems.values()){
            Account account = (Account)sobj;
            if(account.Status__c != oldMap.get(account.Id).get('Status__c')  && account.Date_Registration__c!=null && account.Status__c == System.label.ACTIVE && account.Citizenship__c == System.label.Domestic && (account.Business_Type__c==System.label.Stock || Account.Business_Type__c == System.label.Non_Stock || Account.Business_Type__c ==System.label.businessTypeB_Corp)){
                accountIds.add(account.Id);
            }
        }
        if(!accountIds.isEmpty()){
        List<Business_Filing__c> ExistingFirstReportfilings = [Select Id,Name,Type__c,Account__c from Business_Filing__c where ( (Type__c =: System.label.First_Report_Comparable) OR (Type__c=: System.label.brs_Reinstatement AND Status__c=:System.label.Approved) ) AND Account__c IN:accountIds WITH SECURITY_ENFORCED];
       Set<Id> accWithFRFilings=new Set<Id>();
        for(Business_Filing__c filing:ExistingFirstReportfilings){
            accWithFRFilings.add(filing.Account__c); 
        }
        List<Business_Filing__c> firstReportFilings=new List<Business_Filing__c>();
     for(Id accId:accountIds){
        Account acc = (Account)newItems.get(accId);
            if(!accWithFRFilings.contains(acc.Id)){
                Business_Filing__c frFiling=new Business_Filing__c();
                frFiling.Account__c=acc.Id;
                frFiling.Business_Type__c = acc.Business_Type__c;
                frFiling.Citizenship__c = acc.Citizenship__c;
                frFiling.Due_Date__c = acc.Date_Registration__c+90;
                frFiling.Filing_Type__c=System.label.Organization_and_First_Report;
                frFiling.Status__c=System.label.Due;
                frFiling.Type__c=System.label.First_Report_Comparable;
                firstReportFilings.add(frFiling);

            }
        }
        if(!firstReportFilings.isEmpty()){
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(firstReportFilings, 'insert');
				if(bAccessCheck){
                    insert firstReportFilings;
                }
        } 
        }       
    }
    /**********************************************************************************************************************
        METHOD NAME    : setBillingCityIndexed
        DESCRIPTION    : Method to set billing city by removing all the noise words, legal designation and accents 
        PARAMETER      : List<Account>
        Owner          : Priyanka
    ***********************************************************************************************************************/

    public static void setBillingCityIndexed(List<Account> newTriggerList){
        if(!newTriggerList.isEmpty()){
            for(Account acc : newTriggerList){
                if(acc.BillingCity!=null){
                    String billingCityIndexed=acc.BillingCity;
                    List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
                    List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();

                    billingCityIndexed = ' ' + (billingCityIndexed).normalizeSpace() + ' ';

                    for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                        if((billingCityIndexed != '' || billingCityIndexed != null) && noiseWrd.Label!='.' && (billingCityIndexed.containsIgnoreCase(noiseWrd.Label))){
                            if(!(noiseWrd.Label).isAlpha()){
                                billingCityIndexed = ' ' + (((billingCityIndexed).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                            }
                            else{
                                billingCityIndexed = ' ' + (((billingCityIndexed).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                            }
                        }
                    }

                    for(brs_SortLegalDesignators desgn : listOfDesignators) {                    
                        if((' '+billingCityIndexed+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                            Integer matchCount = (billingCityIndexed.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                            if(matchCount >= 1){
                                for(Integer i=0; i<matchCount; i++){
                                    billingCityIndexed= ' ' + (((billingCityIndexed).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                                }
                            }
                        }
                    } 
                    billingCityIndexed = Accents.removeDiacritics(billingCityIndexed);
                    billingCityIndexed = ((billingCityIndexed).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
                    acc.Billing_City_Indexed__c = billingCityIndexed;
                }
            }
        }
    }

 

        
        public static void updateMailingAddressSameasBusiness(List<Account> newTriggerList,Map<Id, Sobject> oldMap){
        
        try{
        
        for(Account acc:newTriggerList){

if(acc.Same_as_Principal_Office_Address__c == true  && (oldMap ==null  || oldMap.size()>1) ){
    acc.ShippingCity=acc.BillingCity;
    acc.ShippingCountry=acc.BillingCountry;
    acc.ShippingPostalCode=acc.BillingPostalCode;
    acc.ShippingState=acc.BillingState;
    acc.ShippingStreet=acc.BillingStreet;
}else if(acc.Same_as_Principal_Office_Address__c == true  && oldMap !=null && oldMap.get(acc.Id).get('Same_as_Principal_Office_Address__c') == false ){
    acc.ShippingCity=acc.BillingCity;
    acc.ShippingCountry=acc.BillingCountry;
    acc.ShippingPostalCode=acc.BillingPostalCode;
    acc.ShippingState=acc.BillingState;
    acc.ShippingStreet=acc.BillingStreet;
}
        }
        
        }catch(Exception e){
        BOS_Utility.handleException(e);
        
        }
        
        
        }

    /**
     * @desc: If account ShippingAddress changed, copy to FI
     *  Note: Only on afterupdate - as afterinsert cannot have FI
     * @author: BRS-6372 | BRS-7785 | Shreya
     */
    public static void cloneForeignInvestigation(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        Map<Id, Account> mapAccountsChanged = new Map<Id, Account>();   

        for(Account account :(List<Account>) newMap.values()) {
            Account oldAccount = (Account) oldMap.get(account.Id);

            if(account.ShippingStreet != oldAccount.ShippingStreet 
                || account.ShippingCity != oldAccount.ShippingCity 
                || account.ShippingState != oldAccount.ShippingState 
                || account.ShippingPostalCode != oldAccount.ShippingPostalCode 
                || account.ShippingCountry != oldAccount.ShippingCountry 
                || account.Principle_Office_International_Address__c != oldAccount.Principle_Office_International_Address__c
            ) {
                mapAccountsChanged.put(account.Id, account);
            }
        }

        if(!mapAccountsChanged.isEmpty()) {
            updateForeignInvestigationAddress(mapAccountsChanged);
        }
    }

    @TestVisible
    private static void updateForeignInvestigationAddress(Map<Id, Account> mapAccounts) {
        List<Foreign_Investigation__c> listFI = [
            SELECT Id, Business__c, International_Address__c,
                Business_Street_Address_1__c, Business_City__c, Business_State__c, Business_Zip_Code__c, Business_Country__c
            FROM Foreign_Investigation__c
            WHERE Business__c IN :mapAccounts.keySet()
                AND Closed_Date__c = null 
                WITH SECURITY_ENFORCED
        ];

        for(Foreign_Investigation__c fi :listFI) {
            Account business = mapAccounts.get(fi.Business__c);

            fi.Business_Street_Address_1__c = business.ShippingStreet;
            fi.Business_Street_Address_2__c = '';
            fi.Business_Street_Address_3__c = '';
            fi.Business_City__c = business.ShippingCity;
            fi.Business_State__c = business.ShippingState;
            fi.Business_Country__c = business.ShippingCountry;
            fi.Business_Zip_Code__c = business.ShippingPostalCode;
            fi.International_Address__c = business.Principle_Office_International_Address__c;
        }

        if(!listFI.isEmpty()) {
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(listFI, 'update');
			if(bAccessCheck){
                update listFI;
            }
        }
    }

/**********************************************************************************************************************
METHOD NAME    : fetchStatePickListValue
DESCRIPTION    : Method to fetch the API name and label of the State__c picklist value in a map 
PARAMETER      : NA
Owner          : Mousumi
***********************************************************************************************************************/

public static Map<String, String> fetchStatePickListValue(){

Map<String, String> statePickListValues = new Map<String, String>();
Schema.DescribeFieldResult fieldResult = Account.State__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
for (Schema.PicklistEntry v : ple) {
    statePickListValues.put(v.getLabel().toLowerCase(),v.getValue().toLowerCase()); 

} 

return statePickListValues;
}

/**********************************************************************************************************************
METHOD NAME    : validateStateValue
DESCRIPTION    : Method to check if the value entered in State_or_Territory_Formation__c field is present in the State__c picklist 
PARAMETER      : List<Account> newTriggerList
Owner          : Mousumi
***********************************************************************************************************************/
public static void validateStateValue(List<Account> newTriggerList,Map<Id, sObject> oldItems){

if(!newTriggerList.isEmpty()){

    Map<String, String> statePickListValues=fetchStatePickListValue();


    for(Account acc:newTriggerList){
        if(acc.State_or_Territory_Formation__c!=null){
            if(oldItems!=null){
                Account oldAccount = (Account) oldItems.get(acc.Id);

                if   (   String.isNotBlank(oldAccount.State_or_Territory_Formation__c) && oldAccount.State_or_Territory_Formation__c!=acc.State_or_Territory_Formation__c){

                    if(!statePickListValues.keySet().contains(acc.State_or_Territory_Formation__c.toLowerCase()) && !statePickListValues.values().contains(acc.State_or_Territory_Formation__c.toLowerCase()) ){
                        acc.addError('Please enter a valid State.');
                }
                }
                
            }
            else{

                if(String.isNotBlank(acc.State_or_Territory_Formation__c) && !statePickListValues.keySet().contains(acc.State_or_Territory_Formation__c.toLowerCase()) && !statePickListValues.values().contains(acc.State_or_Territory_Formation__c.toLowerCase()) ){
                    acc.addError('Please enter a valid State.');
            }

            }
        
        }
    }
}
}


public static void validateOfficeAndMailingState(List<Account> newTriggerList,Map<Id, sObject> oldItems){

if(!newTriggerList.isEmpty()){
    Map<String, String> statePickListValues=fetchStatePickListValue();

    Map<String, String> apiToLabelMap = new Map<String, String>();

    for(String val : statePickListValues.keySet()){
                apiToLabelMap.put(statePickListValues.get(val).toLowerCase(), val.toLowerCase());
    }

    for(Account acc:newTriggerList){
        String labelValue = '';
        String apiValue = '';
        if(acc.State_or_Territory_Formation__c!=null){
            
                    if(statePickListValues.keySet().contains(acc.State_or_Territory_Formation__c.toLowerCase())){
                        labelValue = acc.State_or_Territory_Formation__c.toLowerCase();
                        apiValue = statePickListValues.get(acc.State_or_Territory_Formation__c.toLowerCase()).toLowerCase();
            }else{
                        labelValue = apiToLabelMap.get(acc.State_or_Territory_Formation__c.toLowerCase())!=null ? apiToLabelMap.get(acc.State_or_Territory_Formation__c.toLowerCase()).toLowerCase():null;
                        apiValue = acc.State_or_Territory_Formation__c.toLowerCase();
            }
        }

        if(oldItems!=null){
            Account oldAccount = (Account) oldItems.get(acc.Id);

            if(oldAccount.State_or_Territory_Formation__c!=acc.State_or_Territory_Formation__c || oldAccount.Mailing_Jurisdiction_BusinessState__c!=acc.Mailing_Jurisdiction_BusinessState__c || oldAccount.Office_Jurisdiction_BusinessState__c!=acc.Office_Jurisdiction_BusinessState__c){
                if(acc.Mailing_Jurisdiction_BusinessState__c!=null && acc.Office_Jurisdiction_BusinessState__c!=null){
                           if((acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue )|| (acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue)){
                        acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                    }
                    
                }else if(acc.Mailing_Jurisdiction_BusinessState__c==null && acc.Office_Jurisdiction_BusinessState__c!=null){
                            if((acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue)){
                        acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                    }
        
                }else if(acc.Mailing_Jurisdiction_BusinessState__c!=null && acc.Office_Jurisdiction_BusinessState__c==null){
                           if((acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue )){
                        acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                    }
        
                }
            }

        }else{
            if(acc.Mailing_Jurisdiction_BusinessState__c!=null && acc.Office_Jurisdiction_BusinessState__c!=null){
                        if((acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue )|| (acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue)){
                    acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                }
                
            }else if(acc.Mailing_Jurisdiction_BusinessState__c==null && acc.Office_Jurisdiction_BusinessState__c!=null){
                        if((acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Office_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue)){
                    acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                }
    
            }else if(acc.Mailing_Jurisdiction_BusinessState__c!=null && acc.Office_Jurisdiction_BusinessState__c==null){
                        if((acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=labelValue && acc.Mailing_Jurisdiction_BusinessState__c.toLowerCase()!=apiValue )){
                    acc.addError('Office in Jurisdiction State and Mailing Address Jurisdiction State must match the State or Territory of Formation.');
                }
    
            }
        }

        

    
    }
}
}
public static void deleteActionItems(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        Set<Id> accIds = new Set<Id>();
        for(Account account :(List<Account>) newMap.values()) {          
               Account oldAccount = (Account)oldMap.get(account.Id);
                if(account.Status__c != oldAccount.Status__c && oldAccount.Status__c == 'Active'){
                accIds.add(account.Id);    
            }          
            
        }
        if(!accIds.isEmpty()){
            brs_ActionItemUtility.deleteAccountActionitems(accIds);           
        }
    }

}