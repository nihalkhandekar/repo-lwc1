/*********************************************************************************************
* NAME:  AccountDashboard
* DESCRIPTION: This class reteives all the Account records and related Contacts, Action items
and credentials required to render the business profile page
*                
*
* @AUTHOR: Piyush Jogdand
* @DATE: 9/1/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
Piyush Jogdand                  9/1/2020                              Created
*********************************************************************************************/
public without sharing class AccountDashboard {  
    public static final String blankSpace=' ';
    public static final String className='AccountDashboard';
    public static final String businessDetailsMethod='getBusinessDetails';
    public static final String businessMethod='getBusinesses';
    public static final String unlinkBusinessMethod = 'unlinkBusiness';
    public static final String unlinkCredentialMethod = 'unlinkCredential';
    public static final String accountObject='Account';
    public static final String accountContactRel='AccountContactRelation';
    public static final String accountCredRel='AccountCredentialRelation';
    
    
    /********************************************************************************************
        METHOD NAME    : getBusinesses
        DESCRIPTION    : Method to get all businesses(Accounts) from a contact. This method queries contact from 
        logged-in user and fetches all related accounts from AccountContactRelation object
        RETURN TYPE    : DashboardWrapper
        PARAMETER      : None
    ********************************************************************************************/
    @AuraEnabled
    public static DashboardWrapper getBusinesses() {
        List<DashboardBusinesses> businessesWrapper = new List<DashboardBusinesses>();
        List<Contact> contactList = New List<Contact>();
        List<Id> ids = new List<Id>();
        List<Id> credIds = new List<Id>();
        List<Action_Item__c> actionItems = new List<Action_Item__c>();
        List<Credential__c> credentials = new List<Credential__c>();
            
        List<User> userList = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];
        if(!userList.isEmpty() && userList[0].ContactId != null) {
            contactList = [
                SELECT Id, 
                    (
                        SELECT Id, AccountId 
                        FROM AccountContactRelations
                    ),
                (Select Credential__c From Contact_Credential_Relationships__r WHERE OwnerId =: UserInfo.getUserId())
                FROM Contact 
                WHERE Id =: userList[0].ContactId
            ];

            if(!contactList.isEmpty()){
                for(AccountContactRelation relation : contactList[0].AccountContactRelations) {
                    ids.add(relation.AccountId);
                }
                for(Contact_Credential_Relationship__c relation : contactList[0].Contact_Credential_Relationships__r){
                    credIds.add(relation.Credential__c);
                }
            }
        }
            
        for(Account acc : [
            SELECT Id, NAICS_Code__c,toLabel(Status__c), AccountNumber,Name,
                billingstreet,billingcity,billingstate,billingPostalCode,BillingCountry,
                (
                    SELECT Id,Account__r.Name,Name,Action_Item_Name__c,Description__c,Agency__c,Link_Text__c,Link_URL__c, Due_Date__c,toLabel(Status__c),Account__c,Credential__c,Credential__r.Credential_Type__c,Credential__r.Name 
                    FROM Action_Items__r Where Contact__c =: userList[0].ContactId AND Account__r.Status__c ='Active' AND Due_Date__c <= NEXT_N_DAYS:90
                )
            FROM Account 
            WHERE Id IN: ids 
                AND RecordType.DeveloperName =: System.label.ActionItem_AccountRecordType
        ]) {
            actionItems.addAll(acc.Action_Items__r);
            DashboardBusinesses business = new DashboardBusinesses(acc, acc.Action_Items__r);
            businessesWrapper.add(business);
        }
        if(!credIds.isEmpty()){
            credentials = [SELECT Id, toLabel(Credential_Status__c), Name,Expiration_Date__c,Credential_Status_Reason__c,Issue_Date__c,Effective_Date__c,
                           Full_Credential_Code__c,Credential_Type__c,isActive__c 
                           FROM Credential__c Where Id IN: credIds];
        }
        //CTBOS-4294 | Real time translation
        String userLocale = UserInfo.getLocale();
        if(!System.Label.LanguageCode_English.equals(userLocale)) {
            List<List<sObject>> records = new List<List<sObject>> {
                actionItems
            };
    
            TranslateRecordsBatch.translateMultipleObjects(records, userLocale);
        }
                
        DashboardWrapper wrapper = new DashboardWrapper(businessesWrapper,actionItems,credentials);
        return wrapper;
    }
    
    /*
     * Method to get all business details on business profile page.
     * This method accepts account Id as a parameter
     * and returns all related Account fields, Contacts, Action items and Credentials
     **/
    @AuraEnabled(cacheable=true)
    public static List<BusinessWrapper> getBusinessDetails(String accId){
        List<BusinessWrapper> wrappers = new List<BusinessWrapper>();
        List<Id> credentialIds = new List<Id>();
        List<User> userList = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];
        if(String.isNotBlank(accId)) {
            Account acc = [
                SELECT Id, 
                    (
                        SELECT Id,Name__c, toLabel(Type__c), Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                            Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Mailing_City__c,Mailing_Country__c,Mailing_State__c,
                            Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,Mailing_Zip_Code__c,Residence_City__c,
                            Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c
                            FROM Agents__r
                    ),
                    (
                        SELECT Id,Name__c, toLabel(Principal_Type__c), Principal_Title__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                            Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Residence_City__c,
                            Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,
                            Residence_Street_Address_3__c,Residence_Zip_Code__c 
                        FROM Principals__r
                    ),
                    Business_Type__c,NAICS_Code__c,NAICS_Sub_Code__c,toLabel(Status__c),AccountNumber,Name,Business_Email_Address__c,
                    billingstreet,billingcity,billingstate,billingPostalCode,BillingCountry,Date_of_Formation__c,toLabel(Citizenship__c),
                    shippingstreet,shippingcity,shippingstate,shippingPostalCode,shippingCountry,Formation_Place__c
                FROM Account 
                WHERE Id =: accId
            ];
                
            //Can be inner query on account
            List<Action_Item__c> actionItems = [
                SELECT Id,Name,Action_Item_Name__c,Description__c,Agency__c,Link_Text__c,Link_URL__c, Due_Date__c,Status__c,Credential__c,Credential__r.Name,Credential__r.Credential_Type__c
                FROM Action_Item__c 
                WHERE Account__c =: accId AND Account__r.Status__c ='Active' AND Contact__c =: userList[0].ContactId
            ];
                
            //Can be inner query on account
            for(Account_Credential_Relationship__c acr : [
                SELECT Credential__c 
                FROM Account_Credential_Relationship__c 
                WHERE Account__c =: accId AND OwnerId =: UserInfo.getUserId()
            ]) {
                credentialIds.add(acr.Credential__c);
            }
            
            List<Credential__c> listCredentials = [
                SELECT Id,Credential_Id__c,toLabel(Credential_Status__c), Name,Expiration_Date__c,Credential_Status_Reason__c,Issue_Date__c,Effective_Date__c,Credential_Type__c,isActive__c 
                FROM Credential__c 
                WHERE Id IN: credentialIds 
                ORDER BY Expiration_Date__c ASC
            ];
            List<String> eLicensecredIds = new List<String>();
            for(Credential__c cred : listCredentials){
                if(cred.Credential_Id__c != Null){
                    eLicensecredIds.add(cred.Credential_Id__c);
                }
            }
            //Object obj = BusinessSearchController.doCredentialIDSearch(eLicensecredIds);
            List<Business_Status_Mapping__mdt> businessStatusMappings = [
                SELECT Description__c 
                FROM Business_Status_Mapping__mdt 
                WHERE Status__c != null
                    AND toLabel(Status__c) = :acc.Status__c
            ];
                
            //CTBOS-4294 | Real time language translation
            String userLocale = UserInfo.getLocale();
            if(!System.Label.LanguageCode_English.equals(userLocale)) {
                List<List<sObject>> records = new List<List<sObject>> {
                    new List<Account>{ acc },
                    actionItems,
                    listCredentials,
                    businessStatusMappings,
                    acc.Agents__r,
                    acc.Principals__r
                };
        
                TranslateRecordsBatch.translateMultipleObjects(records, userLocale);
            }

            BusinessWrapper businesswrapper = new BusinessWrapper(acc, actionItems, listCredentials, businessStatusMappings);
            List<ContactWrapper> contactwrappers = new List<ContactWrapper>();
            
            for(Agent__c agent : acc.Agents__r){
                contactwrappers.add(new ContactWrapper(agent));
            }
            for(Principal__c principal : acc.Principals__r){
                contactwrappers.add(new ContactWrapper(principal));
            }

            businesswrapper.contacts = contactwrappers;
            wrappers.add(businesswrapper);
        }
        
        return wrappers;
    }
	//Method to get all agents and principals related to account - CTBOS-4605
	@AuraEnabled
    public static List<ContactWrapper> getAgentsAndPrincipals(String accId){
        List<ContactWrapper> contactwrappers = new List<ContactWrapper>();
        if(accId != Null){
            Account acc = [
                SELECT Id,
                (
                    SELECT Id,Name__c, toLabel(Type__c), Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                        Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Mailing_City__c,Mailing_Country__c,Mailing_State__c,
                        Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,Mailing_Zip_Code__c,Residence_City__c,
                        Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c 
                    FROM Agents__r Where Type__c =: system.label.Individual
                ),
                (
                    SELECT Id,Name__c, toLabel(Principal_Type__c), Principal_Title__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                            Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Residence_City__c,
                            Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,
                            Residence_Street_Address_3__c,Residence_Zip_Code__c 
                    FROM Principals__r Where Principal_Type__c =: system.label.Individual
            	) 
            	FROM Account 
                WHERE Id =: accId
            ];

            //CTBOS-4294 | Real time translation
            String userLocale = UserInfo.getLocale();
            if(!System.Label.LanguageCode_English.equals(userLocale)) {
                List<List<sObject>> records = new List<List<sObject>> {
                    acc.Agents__r,
                    acc.Principals__r
                };
        
                TranslateRecordsBatch.translateMultipleObjects(records, userLocale);
            }

            for(Agent__c agent : acc.Agents__r){
                contactwrappers.add(new ContactWrapper(agent));
            }
            for(Principal__c principal : acc.Principals__r){
                contactwrappers.add(new ContactWrapper(principal));
            }
        }
        return contactwrappers;
    }
    /*
     * Method to unlink Business from User.
     * This method accepts account Id as a parameter and removes the Account Contact Relationship record of the Current User's contact and the given account.
     **/
    @AuraEnabled
    public static void unlinkBusiness(String accId){
        try{
            User currentUser = [SELECT Id,ContactId FROM User WHERE Id =: userInfo.getUserId()];
            Id conId;
            if(currentUser!=null && currentUser.ContactId!=null){
                conId = currentUser.ContactId;
            }
            Account acc = [Select Id,(Select Id From AccountContactRelations Where ContactId=:conId),
                           (Select Id From Action_Items__r Where Contact__c =: conId),
                           (Select Id From Account_Credential_Relationships__r Where OwnerId =: currentUser.Id)
                           From Account Where Id =: accId];
            
            List<AccountContactRelation> acrRec = acc.AccountContactRelations;
            List<Action_Item__c> actionItems = acc.Action_Items__r;
            List<Account_Credential_Relationship__c> accCredRelation = acc.Account_Credential_Relationships__r;
            List<Sobject> objsToDelete = new List<Sobject>();
            if(!acrRec.isEmpty()){
                objsToDelete.addAll(acrRec);
            }
            if(!actionItems.isEmpty()){
                objsToDelete.addAll(actionItems);
            }
            if(!accCredRelation.isEmpty()){
                objsToDelete.addAll(accCredRelation);
            }
            if(!objsToDelete.isEmpty()){
                delete objsToDelete;
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,unlinkBusinessMethod,accountContactRel,null,null,e,null);
            Throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
     * Method to unlink Credential from Business.
     * This method accepts accountId and credentialId as a parameter and removes the Account Credential Relationship record of the given account.
     **/
    @AuraEnabled
    public static void unlinkCredential(String accId, String credId){
        try{
            Account_Credential_Relationship__c accCredRelRec= [Select Id,Account__c,Credential__c from Account_Credential_Relationship__c Where Account__c =: accId and Credential__r.Credential_Id__c =: credId];
            if(accCredRelRec!=null){
                delete accCredRelRec;
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,unlinkCredentialMethod,accountCredRel,null,null,e,null);
            Throw new AuraHandledException(e.getMessage());
        }
    }
	 @AuraEnabled
    public static void unlinkProfessionalCredential(String credId){
        system.debug('credId: '+credId);
        try{
            List<User> userList = [
                SELECT Id, ContactId 
                FROM User 
                WHERE Id =: UserInfo.getUserId()
            ];
            if(!userList.isEmpty() && userList[0].ContactId != null) {
                
                Contact_Credential_Relationship__c conCredRelRec= [Select Id,Contact__c,Credential__c from Contact_Credential_Relationship__c Where Contact__c =: userList[0].ContactId and Credential__r.Credential_Id__c =: credId];
                if(conCredRelRec!=null){
                    delete conCredRelRec;
                }
                
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,unlinkCredentialMethod,accountCredRel,null,null,e,null);
            Throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void searchCredential(String keyword){
        String searchQuery = 'FIND \'' + keyword + '\' IN ALL FIELDS RETURNING Credential__c(Id,Credential_Status__c,Name,Full_Credential_Code__c)'; 
        List<List<sObject>> searchList = search.query(searchQuery);
    }
    public class DashboardWrapper{
        @AuraEnabled public List<DashboardBusinesses> DashboardBusinesses;
        @AuraEnabled public List<Action_Item__c> ActionItems;
        @AuraEnabled public List<Credential__c> credentials;
        
        public DashboardWrapper(List<DashboardBusinesses> DashboardBusinesses,List<Action_Item__c> ActionItems,List<Credential__c> credentials){
            this.DashboardBusinesses = DashboardBusinesses;
            this.ActionItems = ActionItems;
            this.credentials = credentials;
        }
    }
    public class DashboardBusinesses{
        @AuraEnabled public Id accId;
        @AuraEnabled public String IdNumber;
        @AuraEnabled public String name;
        @AuraEnabled public String address1;
        @AuraEnabled public String address2;
        @AuraEnabled public String statusMessage;
        @AuraEnabled public String naicsCode;
        @AuraEnabled public List<Action_Item__c> actionItems;
        
        DashboardBusinesses(Account acc, List<Action_Item__c> actionItems){
            accId = acc.Id;
            IdNumber = acc.AccountNumber;
            naicsCode = acc.NAICS_Code__c;
            name = acc.Name;
            address1 = acc.billingstreet;
            address2 = acc.billingcity + blankSpace + acc.billingstate + blankSpace + acc.billingPostalCode + blankSpace + acc.BillingCountry ;
            statusMessage = acc.Status__c;
            this.actionItems = actionItems;
        }
    }
    
    public class BusinessWrapper { 
        @AuraEnabled public Id accId;
        @AuraEnabled public String IdNumber;
        @AuraEnabled public String name;
        @AuraEnabled public String mailingAddress1;
        @AuraEnabled public String mailingAddress2;
        @AuraEnabled public String businessAddress1;
        @AuraEnabled public String businessAddress2;
        @AuraEnabled public String statusMessage;
        @AuraEnabled public String statusDescription;
        @AuraEnabled public String naicsCode;
        @AuraEnabled public String naicsSubCode;
        @AuraEnabled public Integer activeLicenses;
        @AuraEnabled public String dateOfFormation;
        @AuraEnabled public String citizenship;
        @AuraEnabled public String state;
        @AuraEnabled public String businessEmail;
        @AuraEnabled public String businessDesignation;
        @AuraEnabled public List<Action_Item__c> actionItems;
        @AuraEnabled public List<Credential__c> credentials;
        @AuraEnabled public List<ContactWrapper> contacts;
        
        @TestVisible
        BusinessWrapper(Account acc,List<Action_Item__c> actionItems, List<Credential__c> creds, List<Business_Status_Mapping__mdt> businessStatusMappings){
            accId = acc.Id;
            IdNumber = acc.AccountNumber;
            naicsCode = acc.NAICS_Code__c;
            naicsSubCode = acc.NAICS_Sub_Code__c;
            name = acc.Name;
            businessEmail = acc.Business_Email_Address__c;
            businessDesignation = acc.Business_Type__c;
            mailingAddress1 = (acc.shippingstreet == null ? '' : acc.shippingstreet);
            mailingAddress2 = (acc.shippingcity == null ? '' : acc.shippingcity) + blankSpace + (acc.shippingstate == null ? '' : acc.shippingstate) + blankSpace + (acc.shippingPostalCode == null ? '' : acc.shippingPostalCode) + blankSpace + (acc.shippingCountry == null ? '' : acc.shippingCountry);
            businessAddress1 = (acc.billingstreet == null ? '' : acc.billingstreet);
            businessAddress2 = (acc.billingcity == null ? '' : acc.billingcity + blankSpace) + (acc.billingstate == null ? '' : acc.billingstate + blankSpace) + (acc.billingPostalCode == null ? '' : acc.billingPostalCode + blankSpace) + (acc.billingCountry == null ? '' : acc.billingCountry);
            statusMessage = acc.Status__c;
            this.statusDescription = !businessStatusMappings.isEmpty()
                ? businessStatusMappings.get(0).Description__c
                : '';
            dateOfFormation = string.valueOf(acc.Date_of_Formation__c);
            citizenship = acc.Citizenship__c;
            state = acc.Formation_Place__c;
            activeLicenses = creds.size();
            credentials = creds;
            this.actionItems = actionItems;
        }
    }
    public class ContactWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String mailingAddress1;
        @AuraEnabled public String mailingAddress2;
        @AuraEnabled public String businessAddress1;
        @AuraEnabled public String businessAddress2;
        @AuraEnabled public String residenceAddress1;
        @AuraEnabled public String residenceAddress2;
        @AuraEnabled public String contactType;
        @AuraEnabled public String title;
        @AuraEnabled public String type;
		@AuraEnabled public String id;
         public String businessId;
         public String boldLabel;
         public String address;
         public String value;
         public String checked;
         public String subtext;
        
        public ContactWrapper(Agent__c agent){
			id = agent.id;
            name = agent.Name__c;
            contactType = System.Label.Agent;
            type = agent.Type__c;
            mailingAddress1 = (agent.Mailing_Street_Address_1__c == null ? '' : agent.Mailing_Street_Address_1__c) + blankSpace + (agent.Mailing_Street_Address_2__c == null ? '' : agent.Mailing_Street_Address_2__c) + blankSpace + (agent.Mailing_Street_Address_3__c == null ? '' : agent.Mailing_Street_Address_3__c);
            mailingAddress2 = (agent.Mailing_City__c == null ? '' : agent.Mailing_City__c) + blankSpace + (agent.Mailing_State__c == null ? '' : agent.Mailing_State__c) + blankSpace + (agent.Mailing_Zip_Code__c == null ? '' : agent.Mailing_Zip_Code__c) + blankSpace + (agent.Mailing_Country__c == null ? '' : agent.Mailing_Country__c);
            businessAddress1 = (agent.Business_Street_Address_1__c == null ? '' : agent.Business_Street_Address_1__c) + blankSpace + (agent.Business_Street_Address_2__c == null ? '' : agent.Business_Street_Address_2__c) + blankSpace + (agent.Business_Street_Address_3__c == null ? '' : agent.Business_Street_Address_3__c);
            businessAddress2 = (agent.Business_City__c == null ? '' : agent.Business_City__c) + blankSpace + (agent.Business_State__c == null ? '' : agent.Business_State__c) + blankSpace + (agent.Business_Zip_Code__c == null ? '' : agent.Business_Zip_Code__c) + blankSpace + (agent.Business_Country__c == null ? '' : agent.Business_Country__c);
            residenceAddress1 = (agent.Residence_Street_Address_1__c == null ? '' : agent.Residence_Street_Address_1__c);
            residenceAddress2 = (agent.Residence_City__c == null ? '' : agent.Residence_City__c) + blankSpace + (agent.Residence_State__c == null ? '' : agent.Residence_State__c) + blankSpace + (agent.Residence_Zip_Code__c == null ? '' : agent.Residence_Zip_Code__c) + blankSpace + (agent.Residence_Country__c == null ? '' : agent.Residence_Country__c);
        }
        public ContactWrapper(Principal__c principal){
			id = principal.id;
            name = principal.Name__c;
            title = principal.Principal_Title__c;
            contactType = System.Label.Principal;
            type = principal.Principal_Type__c;
            /*mailingAddress1 = (principal.mailingstreet == null ? '' : principal.mailingstreet);
            mailingAddress2 = (principal.mailingcity == null ? '' : principal.mailingcity) + blankSpace + (principal.mailingstate == null ? '' : principal.mailingstate) + blankSpace + (principal.mailingPostalCode == null ? '' : principal.mailingPostalCode) + blankSpace + (principal.mailingCountry == null ? '' : principal.mailingCountry);*/
            businessAddress1 = (principal.Business_Street_Address_1__c == null ? '' : principal.Business_Street_Address_1__c) + blankSpace + (principal.Business_Street_Address_2__c == null ? '' : principal.Business_Street_Address_2__c) + blankSpace + (principal.Business_Street_Address_3__c == null ? '' : principal.Business_Street_Address_3__c);
            businessAddress2 = (principal.Business_City__c == null ? '' : principal.Business_City__c) + blankSpace + (principal.Business_State__c == null ? '' : principal.Business_State__c) + blankSpace + (principal.Business_Zip_Code__c == null ? '' : principal.Business_Zip_Code__c) + blankSpace + (principal.Business_Country__c == null ? '' : principal.Business_Country__c);
            mailingAddress1 = (principal.Residence_Street_Address_1__c == null ? '' : principal.Residence_Street_Address_1__c) + blankSpace + (principal.Residence_Street_Address_2__c == null ? '' : principal.Residence_Street_Address_2__c) + blankSpace + (principal.Residence_Street_Address_3__c == null ? '' : principal.Residence_Street_Address_3__c);
            mailingAddress2 = (principal.Residence_City__c == null ? '' : principal.Residence_City__c) + blankSpace + (principal.Residence_State__c == null ? '' : principal.Residence_State__c) + blankSpace + (principal.Residence_Zip_Code__c == null ? '' : principal.Residence_Zip_Code__c) + blankSpace + (principal.Residence_Country__c == null ? '' : principal.Residence_Country__c);
        }
    }

    /********************************************************************************************
    METHOD NAME    : getRightPaneResources
    DESCRIPTION    : Method to get all CT Resources 
    RETURN TYPE    : List
    PARAMETER      : None
    ********************************************************************************************/
    @AuraEnabled
    public static List<Right_Pane_Resources__c> getRightPaneResources(String functionality, Boolean hasScholarsColumn){
        return [
            SELECT Id, Right_pane_content__c,Identifier__c
            FROM Right_Pane_Resources__c
            WHERE Identifier__c=: new List<String>{functionality, System.Label.All }
                AND Language__c =: userInfo.getLanguage()
                AND Scholars_Column__c =: hasScholarsColumn
            ORDER BY Identifier__c ASC
        ];
    }

    /********************************************************************************************
    METHOD NAME    : getScholarsColumn
    DESCRIPTION    : CTBOS-5251 | Add Scholar's column | get help texts
    RETURN TYPE    : List<Right_Pane_Resources__c>
    PARAMETER      : compTitle : component name   
    ********************************************************************************************/
    @AuraEnabled
    public static List<Right_Pane_Resources__c> getScholarsColumn(String compTitle){
        return [
            SELECT Id, Right_pane_content__c
            FROM Right_Pane_Resources__c
            WHERE Title__c =: compTitle
                AND Language__c =: userInfo.getLanguage()
                AND Scholars_Column__c = true
        ];
    }
}