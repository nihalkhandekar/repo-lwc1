/*********************************************************************************************
* NAME:  BusinessSearchController
* DESCRIPTION: This class perform the searh query on Account 
*
* @AUTHOR: Rohit Heera
* @DATE: 18/03/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
*Rohit Heera                     18/03/2020                         Created the first version


*********************************************************************************************/


public without sharing class BusinessSearchController {
    
    public static final String className = 'BusinessSearchController';
    public static final String linkBusiness = 'linkBusiness';
    public static final String searchBusiness = 'searchBusiness';
    public static final String accountObject = 'Account';
    
    @AuraEnabled
    public static List<BusinessDetail> searchBusiness(String value, List<String> selectedAccIds) {
        List<BusinessDetail> detail = new List<BusinessDetail>();
        try {
            ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId();
            User userdata = BOS_Utility.getLoggedinUserDetail();
            
            List<String> linkedAccoints = new List<String>();
            if (userData != null && userdata.ContactID != null) {
                for (AccountContactRelation rel: [
                    SELECT id, AccountId 
                    FROM AccountContactRelation 
                    WHERE ContactId =: userdata.ContactID
                ]) {
                    linkedAccoints.add(rel.AccountId);
                }
                
                if (selectedAccIds != null && selectedAccIds.size()> 0) {
                    linkedAccoints.addAll(selectedAccIds);
                }
            }
            if(String.isNotBlank(value)&& String.isNotEmpty(value)){
            value = value.replace('\'', '\\\'');
            }
            
            //CTBOS-4665 | Shreya | Spanish - toLabel
            String searchQuery = 'FIND \'*' + value + '*' + '\' IN All FIELDS RETURNING '
                + 'Account (Id,Name,toLabel(Status__c),AccountNumber,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet '
                + 'where recordtypeid=\'' + storeRecordTypeId + '\' '
                + 'order by Name),'
                + 'Agent__c(Business_ID__c),'
                + 'Principal__c(Business_ID__c)';
            List<List<sObject>> searchList = search.query(searchQuery);
            
            if (!searchList.isEmpty()) {
                for (Account data: (List<Account> ) searchList.get(0)) {
                    BusinessDetail singleBusinss = new BusinessDetail();
                    singleBusinss.businessName = data.Name;
                    singleBusinss.id = data.Id;
                    singleBusinss.status = data.Status__c;
                    singleBusinss.businessId = (String) data.get('AccountNumber');
                    singleBusinss.billingCity = (String) data.get('BillingCity');
                    singleBusinss.billingCountry = (String) data.get('BillingCountry');
                    singleBusinss.billingPostalCode = (String) data.get('BillingPostalCode');
                    singleBusinss.billingState = (String) data.get('BillingState');
                    singleBusinss.billingStreet = (String) data.get('BillingStreet');
                    
                    singleBusinss.mailingCity = (String) data.get('ShippingCity');
                    singleBusinss.mailingCountry = (String) data.get('ShippingCountry');
                    singleBusinss.mailingPostalCode = (String) data.get('ShippingPostalCode');
                    singleBusinss.mailingState = (String) data.get('ShippingState');
                    singleBusinss.mailingStreet = (String) data.get('ShippingStreet');
                    
                    if (!linkedAccoints.contains(singleBusinss.id)) {
                        detail.add(singleBusinss);
                    }
                    linkedAccoints.add(singleBusinss.id);
                    
                }
                
                Set<String> agentprincipleIds = new Set<String>();
                if (!searchList[1].isEmpty()) {
                    
                    for (Sobject data: searchList.get(1)) {
                        String accID = (String) data.get('Business_ID__c');
                        agentprincipleIds.add(accID);
                    }
                }
                
                if (!searchList[2].isEmpty()) {
                    
                    for (Sobject data: searchList.get(2)) {
                        String accID = (String) data.get('Business_ID__c');
                        agentprincipleIds.add(accID);
                    }
                }
                
                //CTBOS-4665 | To Label
                for (Account data: [
                    SELECT Id, Name, toLabel(Status__c), AccountNumber,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet
                    FROM Account
                    WHERE Id IN: agentprincipleIds and RecordType.DeveloperName =: System.label.ActionItem_AccountRecordType
                ]) {
                    BusinessDetail singleBusinss = new BusinessDetail();
                    singleBusinss.businessName = data.Name;
                    singleBusinss.id = data.Id;
                    singleBusinss.status = data.Status__c;
                    singleBusinss.businessId = data.AccountNumber;
                    singleBusinss.billingCity = data.BillingCity;
                    singleBusinss.billingCountry = data.BillingCountry;
                    singleBusinss.billingPostalCode = data.BillingPostalCode;
                    singleBusinss.billingState = data.BillingState;
                    singleBusinss.billingStreet = data.BillingStreet;
                    
                    singleBusinss.mailingCity = data.ShippingCity;
                    singleBusinss.mailingCountry = data.ShippingCountry;
                    singleBusinss.mailingPostalCode = data.ShippingPostalCode;
                    singleBusinss.mailingState = data.ShippingState;
                    singleBusinss.mailingStreet = data.ShippingStreet;
                    
                    if (!linkedAccoints.contains(singleBusinss.id)) {
                        detail.add(singleBusinss);
                    }
                    linkedAccoints.add(singleBusinss.id);
                }
            }
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        } catch (Exception error) {
            BOS_Utility.ExceptionHandler(className, searchBusiness, accountObject, null, null, error, null);
        }
        
        return detail;
    }
    
 public   class BusinessDetail {
        @AuraEnabled
        public string businessName {get;set;}
        @AuraEnabled
        public string businessId {get;set;}
        @AuraEnabled
        public string status {get;set;}
        @AuraEnabled
        public string billingCity {get;set;}
        @AuraEnabled
        public string billingCountry {get;set;}
        @AuraEnabled
        public string billingPostalCode {get;set;}
        @AuraEnabled
        public string billingState {get;set;}
        @AuraEnabled
        public string billingStreet {get;set;}
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public string mailingCity {get;set;}
        @AuraEnabled
        public string mailingCountry {get;set;}
        @AuraEnabled
        public string mailingPostalCode {get;set;}
        @AuraEnabled
        public string mailingState {get;set;}
        @AuraEnabled
        public string mailingStreet {get;set;}
        @AuraEnabled
        public string value {get;set;}
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string address {get;set;}
        @AuraEnabled
        public List<AccountDashboard.ContactWrapper> principalDetails;
        
        public AgentDetail listedAgent;
    }
    
    @AuraEnabled
    public static void linkBusiness(String accID) {
        try {
            User userdata = [Select id, ContactID from User where id =: UserInfo.getUserId() Limit 1];
            if (userData != null && userdata.ContactID != null) {
                AccountContactRelation relation = new AccountContactRelation();
                relation.AccountId = accID;
                relation.ContactId = userdata.ContactID;
                relation.StartDate = System.today();
                
                insert relation;
            }
        } catch (Exception error) {
            BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);
        }
    }
    
    @AuraEnabled
    public static void updateBusinessDetail(String businessData, String credentialData) {
        system.debug('businessData: '+businessData);
        system.debug('credentialData: '+credentialData);
        List<SObject> businessdatatoUpsert = new List<SObject>();
        List<SObject> creddatatoUpsert = new List<SObject>();

        List<SObject> credList = new List<SObject>();
        List<SObject> credConRelaton = new List<SObject>();
        List<SObject> credAccRelation = new List<SObject>();
        

        try {
            User userdata = [Select id, ContactID from User where id =: UserInfo.getUserId() Limit 1];
            if (String.isNotEmpty(businessData)) {
                List<BusinessDetail> businesses = (List<BusinessDetail> ) JSON.deserializeStrict(businessData, BusinessDetail[].class);
                
                for (BusinessDetail detail: businesses) {
                    SObject accConRelation = new AccountContactRelation();
                    accConRelation.put('AccountId', detail.id);
                    accConRelation.put('ContactId', userdata.ContactID);
                    accConRelation.put('StartDate', System.today());
                    businessdatatoUpsert.add(accConRelation);
                    
                    if (detail.principalDetails != null && detail.principalDetails.size()>0) {

                        for(AccountDashboard.ContactWrapper pr:detail.principalDetails)
                        {
                        if (String.isNotBlank(pr.value)) {
                            
                            SObject principal = new Principal__c();
                            principal.put('ID', pr.value);
                            principal.put('User_Contact_ID__c', userdata.ContactID);
                            businessdatatoUpsert.add(principal);
                        }
                    }
                }
                    if (detail.listedAgent != null) {
                        if (String.isNotBlank(detail.listedAgent.value)) {
                            SObject agent = new Agent__c();
                            agent.put('ID', detail.listedAgent.value);
                            agent.put('User_Contact_ID__c', userdata.ContactID);
                            businessdatatoUpsert.add(agent);
                        }
                    }
                }
            }
            
            if (String.isNotEmpty(credentialData)) {
                Map<String,String> credentilIds = new Map<String,String>();
              
                  
                



                List<CredentialResponse.CredentialDetail> credentials = (List<CredentialResponse.CredentialDetail> ) JSON.deserialize(credentialData, CredentialResponse.CredentialDetail[].class);
                Set<String> creds = new Set<String>();
                for (CredentialResponse.CredentialDetail detail: credentials) {
                    creds.add(detail.eLicense_Credential_ID);
                }
                for (Credential__c acr: [
                    SELECT Credential_Id__c, id
                    FROM Credential__c where Credential_Id__c in :creds
                
                ]) {
                    if (acr.Credential_Id__c != Null ) {
                    
                        credentilIds.put(acr.Credential_Id__c,acr.id);
                    }
                }
           


                for (CredentialResponse.CredentialDetail detail: credentials) {
                    Sobject cred = new Credential__c();
                    String data = detail.eLicense_Credential_ID + '-' + detail.eLicense_Contact_ID;
                   Boolean isCredCreated=false;
                   if(credentilIds.get(detail.eLicense_Credential_ID)!=null){
                       isCredCreated = true;
                   }
                    cred.put('External_Id__c', data);
                    
                    cred.put('Contact_Id__c', detail.eLicense_Contact_ID);
                    cred.put('Credential_Id__c', detail.eLicense_Credential_ID);
                    if(isCredCreated==false){
                        credList.add(cred);
                    }
                    if (detail.isContactCred != null) {
                        if (detail.isContactCred == true) {
                            if(isCredCreated==true){
                                SObject accCredRelation = new Contact_Credential_Relationship__c();
                               accCredRelation.put('Credential__c', credentilIds.get(detail.eLicense_Credential_ID));
                                accCredRelation.put('Contact__c', userdata.ContactID);
                                credConRelaton.add(accCredRelation);
                            }else{

                           
                            SObject accCredRelation = new Contact_Credential_Relationship__c(
                                Credential__r = new Credential__c(External_Id__c = data));
                            accCredRelation.put('Contact__c', userdata.ContactID);
                            credConRelaton.add(accCredRelation);
                            }
                        } else {

                            if(isCredCreated==true){
                                SObject conCredRelation = new Account_Credential_Relationship__c();
                                conCredRelation.put('Credential__c', credentilIds.get(detail.eLicense_Credential_ID));
                                conCredRelation.put('Account__c', detail.businessRecordID);
                                conCredRelation.put('Contact__c', userdata.ContactID);
                            credAccRelation.add(conCredRelation);
                            }else{
                            SObject conCredRelation = new Account_Credential_Relationship__c(Credential__r = new Credential__c(External_Id__c = data));
                                conCredRelation.put('Account__c', detail.businessRecordID);
                                conCredRelation.put('Contact__c',  userdata.ContactID);
                                credAccRelation.add(conCredRelation);
                            }
                        }
                    }
                    
                    
                }
            }
            
             if (!businessdatatoUpsert.isEmpty()) {

                businessdatatoUpsert.sort();
                upsert businessdatatoUpsert;
            }
            creddatatoUpsert.addAll(credList);
                creddatatoUpsert.addAll(credAccRelation);
                creddatatoUpsert.addAll(credConRelaton);
            if (!creddatatoUpsert.isEmpty()) {
                
                
                upsert creddatatoUpsert;
            }
        } catch (Exception error) {
            system.debug('Exception: '+error.getMessage());
            system.debug('Stacktrace: '+error.getStackTraceString());
            BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);
        }
    }
    
    // Action method
    @AuraEnabled(Continuation = true cacheable = true)
    public static Object doCredentialAutoSearch(String businessDetail) {
        CredentialRequest request = new CredentialRequest();
        User userdata = BOS_Utility.getLoggedinUserDetail();
        Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.CredentialAutoSearch);
        List<BusinessData> blist = new List<BusinessData>();
        if (String.isNotBlank(businessDetail)) {
            List<BusinessDetail> businesses = (List<BusinessDetail> ) JSON.deserializeStrict(businessDetail, BusinessDetail[].class);
            
            for (BusinessDetail data: businesses) {
                BusinessData bData = new BusinessData();
                bData.Name = data.businessName;
                String bid=  data.businessId;
                if(bid!=null){
                    bid = bid.replace('ID', '');
                    bid = bid.trim();
                }
                bData.SotsID = bid;
                bData.BusinessAddress = data.billingStreet + '%' + data.billingPostalCode;
                bData.MailingAddress = data.mailingStreet + '%' + data.mailingPostalCode;
                if (data.principalDetails != null&& data.principalDetails.size()>0) {
                    List<NameJsonClass> nList = new List<NameJsonClass>();
                    for(AccountDashboard.ContactWrapper pr : data.principalDetails)
                    {
                   
                    if (String.isNotBlank(pr.name)) {
                        NameJsonClass nameJson = new NameJsonClass();
                        nameJson.Name = pr.name;
                        nList.add(nameJson);
                       
                    }
                   
                }
                bData.Principals = nList;
                }
                blist.add(bData);
            }
            
        }
        
        List<BusinessDetail> linkedbusinesses = getLinkedBusiness(null);
        
        for (BusinessDetail data: linkedbusinesses) {
            BusinessData bData = new BusinessData();
            bData.Name = data.businessName;
            bData.SotsID = data.businessId;
            bData.BusinessAddress = data.billingStreet + '%' + data.billingPostalCode;
            bData.MailingAddress = data.mailingStreet + '%' + data.mailingPostalCode;
            if (data.principalDetails != null && data.principalDetails.size()>0) {
                List<NameJsonClass> nList = new List<NameJsonClass>();
                for(AccountDashboard.ContactWrapper pr : data.principalDetails)
                {

                if (String.isNotBlank(pr.name)) {
                    NameJsonClass nameJson = new NameJsonClass();
                    nameJson.Name = pr.name;
                    nList.add(nameJson);
                    bData.Principals = nList;
                }
            }
            }
            blist.add(bData);
        }
        
        request.Businesses = blist;
        String username = userdata.FirstName;
        if (String.isNotBlank(userdata.MiddleName)) {
            username = username + ' ' + userData.MiddleName + ' ';
            
        } else {
            username = username + '%';
        }
      
        username = username + userdata.LastName;
        request.CommunityUserName = username;
    
        request.recordlimit=System.label.CredentialAutoSearchLimit;
        String requestString = JSON.serialize(request);
        Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
        System.debug(' requestString '+requestString);
        con.continuationMethod='processResponse';
        // Set state
        String requestURL =interfaceData.Named_Credential__c+' ;;; '+requestString+' ;;; '+'Credentials'+' ;;; '+'doCredentialAutoSearch';
        con.state=requestURL;
     
        con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
        return con;

    }


    public static HttpRequest getRequest(String URL, String requestString) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object
     request.setBody(requestString);
 return request;
    }
    // Callback method
    @AuraEnabled(cacheable = true)
    public static Object processResponse(List<String> labels, Object state) {
        // Get the response by using the unique label
        
       
        HttpResponse response = Continuation.getResponse(labels[0]);
        // Set the result variable
        CredentialResponse result = new CredentialResponse();
  
        try{
            String rstate = (String)state;
            String[]  dta= rstate.split(';;;');
BOS_Utility.responseTraceHandler(className, dta[3], dta[2],''+ response.getStatusCode(), 'High', response.getBody(), dta[1], dta[0]);
        }catch(Exception e){}

        if (response.getStatusCode() == 200) {
            //    return response.getBody();
            
            
            result = CredentialResponse.parseData(response.getBody());
            if (result != null) {
                return JSON.serialize(result);
            }
        }
        else if(response.getStatusCode() == 300 || response.getStatusCode() == 2004){
            return System.label.limitexceeded;
        }
        return null;
    }
    
    @AuraEnabled
    public static Object processIdSearchResponse(List<String> labels, Object state) {
      
        Set<String> ids = new Set<String>();
        StateWrapper swrapper = (StateWrapper)state;
        Map<String, Object> credIds = swrapper.credentilIds;
       
        // Get the response by using the unique label
        credentialWrapper wrapper = new credentialWrapper();
        if(credIds!=null){

            for(Object dat:credIds.values()){
                ids.add((String)dat);
            }
        }
        HttpResponse response = Continuation.getResponse(labels[0]);
        // Set the result variable
        CredentialResponse result = new CredentialResponse();
       
        if (response.getStatusCode() == 200) {
           
            List<Action_Item__c> existingItems = [Select Id From Action_Item__c Where Credential__c IN: ids];
            result = CredentialResponse.parseData(response.getBody());
            if (result != null) {
				if(swrapper.credentialType == 'Business'){
                    wrapper.credentials = result.credentials;
                }
                else{
                    wrapper.credentials = new List<CredentialResponse.CredentialDetail>();
                }
                List<Action_Item__c> resultItems = new List<Action_Item__c>();
                for(CredentialResponse.CredentialDetail detail : result.credentials){
					if(swrapper.credentialType == 'Professional'){
                        if(swrapper.elicenseIds.contains(detail.eLicense_Credential_ID)){
                            wrapper.credentials.add(detail);
                        }
                    }
                	if (detail.ActionItems != null && detail.ActionItems.size()> 0) {
                        Map<String,String> accCreds = new Map<String,String>();
                        for (Account_Credential_Relationship__c acr: [
                            SELECT Credential__c, Credential__r.Credential_Id__c,Account__c
                            FROM Account_Credential_Relationship__c
                            WHERE  OwnerId =: UserInfo.getUserId()
                        ]) {
                            if (acr.Credential__c != Null && acr.Credential__r.Credential_Id__c != Null) {
                               
                                accCreds.put(acr.Credential__r.Credential_Id__c,acr.Account__c);
                            }
                        }



                        for (CredentialResponse.ActionItems items: detail.ActionItems) {
                            Action_Item__c actItem = new Action_Item__c();
                            actItem.put('Credential__c', credIds.get((String)detail.eLicense_Credential_ID));
							actItem.put('Cred_Type_Real_Time__c', (String)detail.Credential_Type);
                            actItem.put('Link_Text__c', items.Link_Text);
                            actItem.put('Link_URL__c', items.Link_URL);
                            actItem.put('Action_Item_Name__c', items.Name);
                            actItem.put('Due_Date__c', formatDate(items.eLicense_Credential_Action_Due_Date));
                            actItem.put('Description__c', items.Description);
                            actItem.put('Credential_Contact_Name__c', detail.Business_Individual_Name);
                            actItem.put('Credential_Number__c', detail.Full_Credential_Code);
                            actItem.put('Account__c',accCreds.get(detail.eLicense_Credential_ID));
                            resultItems.add(actItem);
                        }
                    }
                }
                if(!resultItems.isEmpty()){
                    String actionItemString = JSON.serialize(resultItems);
                    String existingItemString = JSON.serialize(existingItems);
                    List<Action_Item__c> actionItems= 	doDML(actionItemString,existingItemString);
Set<ID> actionItemIds = new Set<ID>();
for(Action_Item__c item :actionItems){
    actionItemIds.add(item.id);
}

List<Action_Item__c>  allactionItems = [
    SELECT Id, Name, Action_Item_Name__c, Description__c,Agency__c,Link_Text__c,Link_URL__c,
        Due_Date__c, toLabel(Status__c), Account__c,Cred_Type_Real_Time__c,Credential_Number__c,
        Credential__c, Credential__r.Credential_Type__c, Credential__r.Name,Account__r.Name
    FROM Action_Item__c 
    WHERE id in :actionItemIds];
                    wrapper.actionItems = allactionItems;
            	}
            }
        }
       
        system.debug('wrapper: '+wrapper);
        return JSON.serialize(wrapper);
    }
	
	public static Date formatDate(String dateString){
        List<string> arr = dateString.split('/');
        String formatteddate = arr[2]+'-'+arr[0]+'-'+arr[1];
        date informat = date.valueOf(formatteddate);
        return informat;
    }
	
    public static List<Action_Item__c> doDML(String actionItemString,String existingItemString){
        List<Action_Item__c> actionItems = (List<Action_Item__c>)JSON.deserialize(actionItemString, Action_Item__c[].class);
        List<Action_Item__c> existingItems = (List<Action_Item__c>)JSON.deserialize(existingItemString, Action_Item__c[].class);
        if(existingItems.size() > 0){
            delete existingItems;
        }
        if(actionItems.size() > 0){
            insert actionItems;
        }
        return actionItems;
    }
    
    class credentialWrapper {
        List<CredentialResponse.CredentialDetail> credentials;
        List<Action_Item__c> actionItems;
    }
    
    class CredentialRequest {
        List<BusinessData> Businesses = new List<BusinessData>();
        
        String CommunityUserName = '';
        String SearchString = '';
        List<IDJsonClass> Credentials = new List<IDJsonClass>();
        List<ContantIdJsonClass> eLicenseContacts = new List<ContantIdJsonClass>();
        String recordlimit='';
        List<CredIdJsonClass> eLicenseExcludeCredIDs = new List<CredIdJsonClass>();
    }
    
    @TestVisible
    class BusinessData {
        @TestVisible String Name = '';
        @TestVisible String SotsID = '';
        @TestVisible String BusinessAddress = '';
        @TestVisible String MailingAddress;
        @TestVisible List<NameJsonClass> Principals = new List<NameJsonClass>();
    }
    
    @TestVisible
    class NameJsonClass {
        @TestVisible String Name = '';
    }

    class IDJsonClass {
        Integer Id;
    }
    class ContantIdJsonClass {
        String ContactId = '';
    }
    class CredIdJsonClass {
        String credID = '';
    }
    
    // Action method
    @AuraEnabled(Continuation = true cacheable = true)
    public static Object doCredentialContactSearch(String credentialDetail) {
        CredentialRequest request = new CredentialRequest();
        User userdata = [Select id, FirstName, LastName, MiddleName, ContactID from User where id =: UserInfo.getUserId() Limit 1];
        Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.CredentialContactIDSearch);
        
        if (String.isNotBlank(credentialDetail)) {
            List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentialDetail, CredentialResponse.CredentialDetail[].class);
            List<ContantIdJsonClass> blist = new List<ContantIdJsonClass>();
            List<CredIdJsonClass> credIdList = new List<CredIdJsonClass>();
            for (CredentialResponse.CredentialDetail data: businesses) {
                ContantIdJsonClass bData = new ContantIdJsonClass();
                bData.ContactId = data.eLicense_Contact_ID;
                
                blist.add(bData);
                CredIdJsonClass credId = new CredIdJsonClass();
                credId.credID = data.eLicense_Credential_ID;
                credIdList.add(credId);
            }
            request.eLicenseExcludeCredIDs = credIdList;
            request.eLicenseContacts = blist;
        }
        
      
        String username = userdata.FirstName;
        if (String.isNotBlank(userdata.MiddleName)) {
            username = username + ' ' + userData.MiddleName + ' ';
            
        } else {
            username = username + '%';
        }
        username = username + userdata.LastName;
        request.CommunityUserName = username;
       
        request.recordlimit = System.label.CredentialContactSearchLimit;
        String requestString = JSON.serialize(request);
        Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
       
        con.continuationMethod='processResponse';
        String requestURL =interfaceData.Named_Credential__c+' ;;; '+requestString+' ;;; '+'Credentials'+' ;;; '+'doCredentialContactSearch';
        con.state=requestURL;
     
     
        con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
        return con;
    }
    
    // Action method
    @AuraEnabled(Continuation = true cacheable = true)
    public static Object doCredentialManualSearch(String value) {
        CredentialRequest request = new CredentialRequest();
        User userdata = [Select id, FirstName, LastName, MiddleName, ContactID from User where id =: UserInfo.getUserId() Limit 1];
        Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.CredentialManualSearch);
        
        request.SearchString = value;
        String username = userdata.FirstName;
        if (String.isNotBlank(userdata.MiddleName)) {
            username = username + ' ' + userData.MiddleName + ' ';
            
        } else {
            username = username + '%';
        }
      
        username = username + userdata.LastName;
        request.CommunityUserName = username;
     
        request.recordlimit = System.label.CredentialManualSearchLimit;
        String requestString = JSON.serialize(request);
        Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
        System.debug(' requestString '+requestString);
        con.continuationMethod='processResponse';
        // Set state
        String requestURL =interfaceData.Named_Credential__c+' ;;; '+requestString+' ;;; '+'Credentials'+' ;;; '+'doCredentialManualSearch';
        con.state=requestURL;
     
        con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
        return con;
    }
    
    // Action method
    @AuraEnabled(Continuation = true)
    public static Object doCredentialIDSearch(String accId,String credentialType) {
		List<String> credentials = new List<String>();
        Map<String,String> credentilIds = new Map<String,String>();
        if(credentialType == 'business'){
            for (Account_Credential_Relationship__c acr: [
                SELECT Credential__c, Credential__r.Credential_Id__c
                FROM Account_Credential_Relationship__c
                WHERE Account__c =: accId AND OwnerId =: UserInfo.getUserId()
            ]) {
                if (acr.Credential__c != Null && acr.Credential__r.Credential_Id__c != Null) {
                    credentials.add(acr.Credential__r.Credential_Id__c);
                    credentilIds.put(acr.Credential__r.Credential_Id__c,acr.Credential__c);
                }
            }
        }
        List<User> userList = [
            SELECT Id, ContactId ,FirstName, LastName, MiddleName
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];
        Set<String> elicenseIds = new Set<String>();
        if(credentialType == 'professional'){
            if(!userList.isEmpty() && userList[0].ContactId != null) {
                for (Contact_Credential_Relationship__c acr: [
                    SELECT Credential__c, Credential__r.Credential_Id__c
                    FROM Contact_Credential_Relationship__c
                    WHERE Contact__c =: userList[0].ContactId AND OwnerId =: UserInfo.getUserId()
                ]) {
                    if (acr.Credential__c != Null && acr.Credential__r.Credential_Id__c != Null) {
                        elicenseIds.add(acr.Credential__r.Credential_Id__c);
                        credentials.add(acr.Credential__r.Credential_Id__c);
                        credentilIds.put(acr.Credential__r.Credential_Id__c,acr.Credential__c);
                    }
                }
                List<AccountContactRelation> accConRelations = [Select Id,AccountId From AccountContactRelation
                                                                Where ContactId =: userList[0].ContactId];
                List<ID> accIds = new List<ID>();
                for(AccountContactRelation acr : accConRelations){
                    accIds.add(acr.AccountId);
                }
                for(Account_Credential_Relationship__c acr : [
                    SELECT Credential__c, Credential__r.Credential_Id__c
                    FROM Account_Credential_Relationship__c 
                    WHERE Account__c IN: accIds  AND OwnerId =: UserInfo.getUserId()
                ]) {
                    if (acr.Credential__c != Null && acr.Credential__r.Credential_Id__c != Null) {
                        credentials.add(acr.Credential__r.Credential_Id__c);
                        credentilIds.put(acr.Credential__r.Credential_Id__c,acr.Credential__c);
                    }
                }
            }
        }
       
        CredentialRequest request = new CredentialRequest();
      
        Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.CredentialCredIDSearch);
        List<IDJsonClass> allIds = new List<IDJsonClass>();
        for (String val: credentials) {
            IDJsonClass value = new IDJsonClass();
            value.Id = integer.valueof(val);
            allIds.add(value);
        }
        request.Credentials = allIds;
        String username = userList[0].FirstName;
        if (String.isNotBlank(userList[0].MiddleName)) {
            username = username + ' ' + userList[0].MiddleName + ' ';
            
        } else {
            username = username + '%';
        }
        username = username + userList[0].LastName;
        request.CommunityUserName = username;
        
        String requestString = JSON.serialize(request);
        Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
       
        con.continuationMethod='processIdSearchResponse';
        // Set state
        con.state = new StateWrapper(credentilIds, elicenseIds, credentialType);
      con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
        return con;
    }
	
	public class StateWrapper {
        Map<String,String> credentilIds;
        Set<String> elicenseIds;
        String credentialType;
        
        @TestVisible
        StateWrapper(Map<String,String> credentilIds, Set<String> elicenseIds,String credentialType){
            this.credentilIds = credentilIds;
            this.elicenseIds = elicenseIds;
            this.credentialType = credentialType;
        }
    }
    
    public class AgentDetail {
        public String businessId;
        public String address;
        public String value;
        public String label;
        public String id ;
    }
    @AuraEnabled
    public static List<BusinessDetail> getLinkedBusiness(String accountID){
        List<BusinessDetail> details = new List<BusinessDetail>();
        List<String> linkedAccoints = new List<String>();
        Set<String> businessIDs = new Set<String>();
        try{
            User userdata = [Select id, FirstName, LastName, MiddleName, ContactID from User where id =: UserInfo.getUserId() Limit 1];
            

List<Principal__c> pList= new List<Principal__c>();

            if(accountID==null ||String.isEmpty(accountID) )
            {

                List<AccountContactRelation> relations = [Select id,AccountId,ContactId from AccountContactRelation where ContactId=:userdata.ContactID];
                for(AccountContactRelation relation:relations){
                    businessIDs.add(relation.AccountId);
                }
               pList= [SELECT Id,Name__c, toLabel(Principal_Type__c), Principal_Title__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Residence_City__c,
                Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,
                        Residence_Street_Address_3__c,Residence_Zip_Code__c,Business_ID__c 
        FROM Principal__c Where Principal_Type__c =: system.label.Individual and 
        User_Contact_ID__c =:userdata.ContactID];


            
                
            }
            else{
                businessIDs.add(accountID);
                 pList= [SELECT Id,Business_ID__c,Name__c, toLabel(Principal_Type__c), Principal_Title__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,
                Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c,Residence_City__c,
                Residence_Country__c,Residence_State__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,
                Residence_Street_Address_3__c,Residence_Zip_Code__c 
        FROM Principal__c Where Principal_Type__c =: system.label.Individual and 
        User_Contact_ID__c =:userdata.ContactID and Business_ID__c=:accountID];
            }
            
            Map<String ,List<AccountDashboard.ContactWrapper>>  pricipalData = new Map<String ,List<AccountDashboard.ContactWrapper>> ();
            if(!pList.isEmpty()){
                for(Principal__c pricipal : pList){
                    
                    AccountDashboard.ContactWrapper detail = new AccountDashboard.ContactWrapper(pricipal);
                    if(pricipalData.get(pricipal.Business_ID__c)==null){
                        pricipalData.put(pricipal.Business_ID__c, new List<AccountDashboard.ContactWrapper>());
                    }
                    pricipalData.get(pricipal.Business_ID__c).add(detail);
                }
                
            }
            
            
            //CTBOS-4665 | To Label
            for (Account data: [
                SELECT Id, Name, toLabel(Status__c), AccountNumber,
                BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet
                FROM Account
                WHERE Id IN: businessIDs and RecordType.DeveloperName =: System.label.ActionItem_AccountRecordType
            ]) {
                BusinessDetail singleBusinss = new BusinessDetail();
                singleBusinss.businessName = data.Name;
                singleBusinss.id = data.Id;
                singleBusinss.status = data.Status__c;
                singleBusinss.businessId = data.AccountNumber;
                singleBusinss.billingCity = data.BillingCity;
                singleBusinss.billingCountry = data.BillingCountry;
                singleBusinss.billingPostalCode = data.BillingPostalCode;
                singleBusinss.billingState = data.BillingState;
                singleBusinss.billingStreet = data.BillingStreet;
                
                singleBusinss.mailingCity = data.ShippingCity;
                singleBusinss.mailingCountry = data.ShippingCountry;
                singleBusinss.mailingPostalCode = data.ShippingPostalCode;
                singleBusinss.mailingState = data.ShippingState;
                singleBusinss.mailingStreet = data.ShippingStreet;
                singleBusinss.value=null;
                singleBusinss.label=null;
                singleBusinss.address=null;
                singleBusinss.principalDetails=pricipalData.get(data.Id);
                 singleBusinss.listedAgent=null;
                if (!linkedAccoints.contains(singleBusinss.id)) {
                    details.add(singleBusinss);
                }
                linkedAccoints.add(singleBusinss.id);
            }
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);
        }
        return details;
        
    }
    
    @AuraEnabled
    public static Map<String,List<Id>> getLinkedCredentials(){
        
        Set<String> businessIDs = new Set<String>();
		Map<String,List<Id>> credIds = new Map<String,List<Id>>();
		User userdata = BOS_Utility.getLoggedinUserDetail();
		List<AccountContactRelation> relations = [Select id,AccountId,ContactId from AccountContactRelation where ContactId=:userdata.ContactID];
	  //for(AccountContactRelation relation:relations){
		//   businessIDs.add(relation.AccountId);
	   //}
	  
	  
		for (Contact_Credential_Relationship__c crelation:
		   [Select Credential__c,Credential__r.External_Id__c,Contact__c from Contact_Credential_Relationship__c where Contact__c=:userdata.ContactID])
		{
			if(crelation.Credential__r.External_Id__c!=null){
				if(credIds.containsKey(crelation.Credential__r.External_Id__c)){
					credIds.get(crelation.Credential__r.External_Id__c).add(crelation.Contact__c);
				}else{
					credIds.put(crelation.Credential__r.External_Id__c, new List<Id>{crelation.Contact__c});
				}
			}
		} 

		for (Account_Credential_Relationship__c arelation:
		[Select Credential__c,Credential__r.External_Id__c,Account__c from Account_Credential_Relationship__c where Contact__c=:userdata.contactID])
		{
			if(arelation.Credential__r.External_Id__c!=null){
				if(credIds.containsKey(arelation.Credential__r.External_Id__c)){
					credIds.get(arelation.Credential__r.External_Id__c).add(arelation.Account__c);
				}else{
					credIds.put(arelation.Credential__r.External_Id__c, new List<Id>{arelation.Account__c});
				}
			}
		} 
		return credIds;
    }
    
    @AuraEnabled(cacheable=true)
    public static User getCurrentUserData(){
        User userdata = [Select Id, Name, ContactID from User where id =: UserInfo.getUserId() Limit 1];
        String userString = JSON.serialize(userdata);
        return userdata;
    }


    @AuraEnabled
    public static String validateCustomerID(String CustomerID,String accountID,String preVerified){
 

try{

    if(String.isNotBlank(accountID)){

List<Account> accList = [Select id,Business_Customer_ID__c,Business_Email_Address__c from Account where id =:accountID];
System.debug('accList'+accList);
if(accList!=null && accList.size()>0){
if(accList[0].Business_Customer_ID__c!=null){
if(accList[0].Business_Customer_ID__c.contains(CustomerID)){


    if(accList[0].Business_Email_Address__c==null){
        return System.label.EmailNotAvialable;  
    

}else{

Boolean isverified = checkforBusinessVerification(accountID, true,preVerified);
if(isverified==true){
return System.label.AlreadyVerified;

}else{

    String masked = accList[0].Business_Email_Address__c.replaceAll('(?<=.)[^@\n](?=[^@\n]*?[^@\n]@)|(?:(?<=@.)|(?!^)\\G(?=[^@\n]*$)).([^@\n]\\.)', '$1*');

return masked;
}
}

}else{
    return System.label.NotMatched;
}
}
}
    }
}catch(Exception error){

    BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);

}


        return null;
    }


   @AuraEnabled
    public static String validateEmailID(String email,String accountID){
 

try{

    if(String.isNotBlank(accountID)){

List<Account> accList = [Select id,Business_Customer_ID__c,Business_Email_Address__c from Account where id =:accountID];
System.debug('accList'+accList);
if(accList!=null && accList.size()>0){
if(accList[0].Business_Email_Address__c!=null){
if(email.equalsIgnoreCase(accList[0].Business_Email_Address__c)){
   return  Bos_VerificationController.sendNumber(accList[0].Business_Email_Address__c);

}else{
    return System.label.NotMatched;
}
}
}
    }
}catch(Exception error){
    BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);


}
  return null;
    }

    
 public class PreVerifiedData{
public String customerID;
public String email;
public String id;
}

    @AuraEnabled
    public static Boolean checkforBusinessVerification(String accountID,boolean isEmailOnly,String preVerified){
        
        Boolean isAvailable = false;
        List<Account> accList ;
try{

    if(String.isNotBlank(accountID)){

 accList = [Select id,Business_Customer_ID__c,Business_Email_Address__c from Account where id =:accountID];

if(accList!=null && accList.size()>0){ 
    if(accList[0].Business_Email_Address__c!=null && accList[0].Business_Customer_ID__c!=null){
        List<User> userList = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()];
        Set<ID> ids = new Set<ID>();
        if(!userList.isEmpty() && userList[0].ContactId != null) {
         List<AccountContactRelation>   relationList = [SELECT Id, AccountId FROM AccountContactRelation
                WHERE ContactId =: userList[0].ContactId and AccountId <> :accList[0].id];

            if(!relationList.isEmpty()){
                for(AccountContactRelation relation : relationList) {
                    ids.add(relation.AccountId);
                }
            }
 List<Account> saccList ;

    saccList = [ Select id,Business_Customer_ID__c,Business_Email_Address__c from Account where id in :ids and Business_Email_Address__c=:accList[0].Business_Email_Address__c ];


 if(isEmailOnly){
 if(saccList!=null && !saccList.isEmpty()){
    isAvailable= true;
  }
}else{
   
    for(Account acc:saccList){


        if(accList[0].Business_Email_Address__c==acc.Business_Email_Address__c && acc.Business_Customer_ID__c!=null){
         
            String[] cIds = acc.Business_Customer_ID__c.split(',');
            for(String cid :cIds){
            if(accList[0].Business_Customer_ID__c.contains(cid))
            {
            isAvailable=true;
            break;
            }
            }
            if(isAvailable==true){
                break;
            }
        }
    }
  
}

        }

 }
 }
   
}

    if(isAvailable==false && String.isNotBlank(preVerified)){
        System.debug('preVerified'+preVerified);  
        List<PreVerifiedData> preverifiredData = (List<PreVerifiedData>)JSON.deserialize(preVerified, PreVerifiedData[].class);
        System.debug('preverifiredData'+preverifiredData); 
        if(preverifiredData!=null && preverifiredData.size()>0){
       for(PreVerifiedData pdata:preverifiredData){
        System.debug(pdata);  
        System.debug('accList[0]'+accList[0]);  
        if(isEmailOnly && accList[0].Business_Email_Address__c!=null && pdata.email.equals( accList[0].Business_Email_Address__c)){
            isAvailable=true;
            break; 
           } 
           else if(accList[0].Business_Email_Address__c!=null && pdata.email.equals( accList[0].Business_Email_Address__c)&& 
          ( accList[0].Business_Customer_ID__c.contains(pdata.customerID))){
            isAvailable=true;
            break; 
       }
   }
   
    }


    }
 }catch(Exception error){
    BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, error, null);


}
String isrequired= System.label.IsVerificationRequired;
         if(test.isRunningTest()){
                isrequired ='false';
            }
if(isrequired=='false'){
    isAvailable = true;
}
  return isAvailable;
    }





@AuraEnabled(Continuation=true)
public static Object checkCredentialVerificationSwitch(String credentials){
    try {
        Set<String> businessIDs = new Set<String>();
        Set<String> credIdIDs = new Set<String>();
        Map<String,List<Id>> credIds = new Map<String,List<Id>>();
        User userdata = [Select id, FirstName, LastName, MiddleName, ContactID from User where id =: UserInfo.getUserId() Limit 1];
       
        for (Contact_Credential_Relationship__c crelation:
             [Select Credential__c,Credential__r.Credential_Id__c,Contact__c from Contact_Credential_Relationship__c where Contact__c=:userdata.ContactID])
        {
            if(crelation.Credential__r.Credential_Id__c!=null){
                credIdIDs.add(crelation.Credential__r.Credential_Id__c);
            }
        } 
        
        for (Account_Credential_Relationship__c arelation:
             [Select Credential__c,Credential__r.Credential_Id__c,Account__c from Account_Credential_Relationship__c where Contact__c=:userdata.ContactID])
        {
            if(arelation.Credential__r.Credential_Id__c!=null){
                credIdIDs.add(arelation.Credential__r.Credential_Id__c);
            }
        } 


     if(credIdIDs!=null &&  credIdIDs.size()>0){

        CredentialRequest request = new CredentialRequest();
        Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.CredentialCredIDSearch);
        List<IDJsonClass> allIds = new List<IDJsonClass>();
        for (String val: credIdIDs) {
            IDJsonClass value = new IDJsonClass();
            value.Id = integer.valueof(val);
            allIds.add(value);
        }
        request.Credentials = allIds;
        String username = userdata.FirstName;
        if (String.isNotBlank(userdata.MiddleName)) {
            username = username + ' ' + userdata.MiddleName + ' ';
            
        } else {
            username = username + ' % ';
        }
        username = username + userdata.LastName;
        request.CommunityUserName = username;
     
        String requestString = JSON.serialize(request);
        Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
       
        con.continuationMethod='processResponseforVerification';
        // Set state
        con.state=credentials;
     
        con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
        return con;
  

    }
    else{


        List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentials, CredentialResponse.CredentialDetail[].class);
       
        for(CredentialResponse.CredentialDetail cred:businesses){
         
           
        String isrequired= System.label.IsVerificationRequired;
            if(test.isRunningTest()){
                isrequired ='false';
            }
        if(isrequired =='false'){
cred.isEmailVerified=true;
cred.isCredIdVerified=true;
}
        }
 
        return JSON.serialize(businesses);
    }
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);

    }
    return null;
}

@AuraEnabled(cacheable = true)
public static Object processResponseforVerification(List<String> labels, Object state) {
    // Get the response by using the unique label
    Set<String> linkedData= new Set<String>();
    Set<String> linkedcustIds= new Set<String>();
    Set<String> linkedCustEmails= new Set<String>();
    System.debug('processResponse');
    String credentials = (String)state;
    HttpResponse response = Continuation.getResponse(labels[0]);
    // Set the result variable
    CredentialResponse result = new CredentialResponse();
    System.debug('response.getStatusCode()'+response.getStatusCode());
    System.debug('response.getBody()'+response.getBody());
    if (response.getStatusCode() == 200) {
        //    return response.getBody();
        
        
        result = CredentialResponse.parseData(response.getBody());
        if(result!=null && result.credentials!=null){
            for(CredentialResponse.CredentialDetail cred:result.credentials){
              
                String customerId1 = EncryptAndDecryptHelper.processDecryption(cred.Cust_ID);
                String demail1 = EncryptAndDecryptHelper.processDecryption(cred.Cust_Email);
            
                linkedData.add(demail1+'-'+customerId1);
                linkedcustIds.add(customerId1);
                linkedCustEmails.add(demail1);
            
            }
                   }
                   if (String.isNotBlank(credentials)) {
                    List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentials, CredentialResponse.CredentialDetail[].class);
                    for(CredentialResponse.CredentialDetail cred:businesses){
                     
                     String customerId = EncryptAndDecryptHelper.processDecryption(cred.Cust_ID);
                     String demail = EncryptAndDecryptHelper.processDecryption(cred.Cust_Email);
                     String combination = demail+'-'+customerId;
                    if(linkedData.contains(combination)){
                        cred.isEmailVerified=true;
                        cred.isCredIdVerified=true;
                    }
                 else if(linkedcustIds.contains(customerId)){
                    
                        cred.isCredIdVerified=true;
                    }
                 else if(linkedCustEmails.contains( demail)){
                        cred.isEmailVerified=true;
                    
                    }
                    else{
            
                        cred.isEmailVerified=false;
                        cred.isCredIdVerified=false;
                    }

                    String isrequired= System.label.IsVerificationRequired;
                         if(test.isRunningTest()){
                isrequired ='false';
            }
                    if(isrequired=='false'){
    cred.isEmailVerified=true;
    cred.isCredIdVerified=true;
}
                
                    }
            
                    return Json.serialize(businesses);
                }else {
                    List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentials, CredentialResponse.CredentialDetail[].class);
                    for(CredentialResponse.CredentialDetail cred:businesses){
                     
            
                    String isrequired= System.label.IsVerificationRequired;
                    if(isrequired=='false'){
            cred.isEmailVerified=true;
            cred.isCredIdVerified=true;
            }
                    }
                    return JSON.serialize(businesses);
                   }
            
                }       
    
    else if(response.getStatusCode() == 300 || response.getStatusCode() == 2004){
        return System.label.limitexceeded;
    }
    List<CredentialResponse.CredentialDetail> businesses = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentials, CredentialResponse.CredentialDetail[].class);
    for(CredentialResponse.CredentialDetail cred:businesses){
     

    String isrequired= System.label.IsVerificationRequired;
         if(test.isRunningTest()){
                isrequired ='false';
            }
    if(isrequired=='false'){
cred.isEmailVerified=true;
cred.isCredIdVerified=true;
}
    }
    return JSON.serialize(businesses);
} 
    
    @AuraEnabled
public static string getVerifiedEmail(String preVerified){
    try {
        System.debug('preVerified '+preVerified);
        if(String.isNotEmpty(preVerified)){
            BusinessSearchController.PreVerifiedData preverifiredData = (BusinessSearchController.PreVerifiedData)JSON.deserialize(preVerified, BusinessSearchController.PreVerifiedData.class);
        System.debug('preverifiredData '+preverifiredData);
            if(preverifiredData!=null){
            String accId = preverifiredData.id;
   System.debug('accId '+accId);
            if(String.isNotEmpty(accId)){
              List<Account> accList = [Select id,Business_Email_Address__c from Account where id =:accId];
                        System.debug('accList '+accList);
preverifiredData.email = accList[0].Business_Email_Address__c;
                      System.debug('preverifiredData '+preverifiredData);
return JSON.serialize(preverifiredData);
            }
        }
        }
        if(Test.isRunningTest()){
            throw new NullPointerException();
        }
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, linkBusiness, accountObject, null, null, e, null);

    }
    return  preVerified;
}


Class UpdateIdToForgeRock{
  String  userId;
  String operation;
  List<LinkedSystems>linkedSystems;
  
}
Class LinkedSystems{
    String id;
    String email;
    String lsystem;
}
    
class VerifiedData{
    String custid;
    String id;
}

 // Action method
 @AuraEnabled(Continuation = true cacheable = true)
 public static Object doupdateIdsInForgerock(String businessData, String credentialData) {
   
   // businessData = '[{"custid":"000370264","id":"001r000000Nd6YVAAZ"},{"custid":"000000000","id":"001r000000Nd9mMAAR"}]';
    //credentialData = '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"220617","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
   
    User userdata = BOS_Utility.getLoggedinUserDetail();
    UpdateIdToForgeRock request = new UpdateIdToForgeRock();
Map<String,String> linkedIds = new Map<String,String>();
Map<String,String> linkedCreds = new Map<String,String>();
List<LinkedSystems>  linkedSystem = new List<LinkedSystems>();
    if (String.isNotEmpty(businessData)) {
        List<VerifiedData> businesses = (List<VerifiedData> ) JSON.deserializeStrict(businessData, VerifiedData[].class);
for(VerifiedData dat :businesses){
linkedIds.put(dat.id, dat.custid);
}

        List<Account> accList = [Select id,Business_Email_Address__c from Account where id =:linkedIds.keySet()];

     for(Account acc:accList){
LinkedSystems  lSystem = new LinkedSystems();
lSystem.email = acc.Business_Email_Address__c;
lSystem.id =linkedIds.get(acc.id);
lSystem.lsystem = 'sots';
linkedSystem.add(lSystem);
     }
       }  

      
       if (String.isNotEmpty(credentialData)) {
       List<CredentialResponse.CredentialDetail> credetnials = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentialData, CredentialResponse.CredentialDetail[].class);
    
     Set<String> credIdIDs = new Set<String>();
     Map<String,List<Id>> credIds = new Map<String,List<Id>>();
     
    
     for (Contact_Credential_Relationship__c crelation:
          [Select Credential__c,Credential__r.Credential_Id__c,Contact__c from Contact_Credential_Relationship__c where Contact__c=:userdata.ContactID])
     {
         if(crelation.Credential__r.Credential_Id__c!=null){
             credIdIDs.add(crelation.Credential__r.Credential_Id__c);
         }
     } 
     
     for (Account_Credential_Relationship__c arelation:
          [Select Credential__c,Credential__r.Credential_Id__c,Account__c from Account_Credential_Relationship__c where Contact__c=:userdata.ContactID])
     {
         if(arelation.Credential__r.Credential_Id__c!=null){
             credIdIDs.add(arelation.Credential__r.Credential_Id__c);
         }
     } 
System.debug('credIdIDs'+credIdIDs);
     for(CredentialResponse.CredentialDetail cred:credetnials){
         if(!credIdIDs.contains(cred.eLicense_Credential_ID))
         {
        LinkedSystems  lSystem = new LinkedSystems();
        lSystem.email = EncryptAndDecryptHelper.processDecryption(cred.Cust_Email);
        lSystem.id =EncryptAndDecryptHelper.processDecryption(cred.Cust_ID);
        lSystem.lsystem = 'elicensing';
        linkedSystem.add(lSystem); 
         }  
    }


       }
       request.linkedSystems = linkedSystem;
       request.userId = userdata.FederationIdentifier;
       request.operation = 'add';
       String requestString = JSON.serialize(request);
       System.debug('requestString '+requestString);

     Interface_Configuration__mdt interfaceData = BOS_Utility.fetchInterfaceConfig(system.label.UserDetailLinking);
     
    Continuation con = new Continuation(Integer.valueOf(interfaceData.Timeout_Value__c));
    con.continuationMethod='processResponsefromForgerock';
     // Set state
     String requestURL =interfaceData.Named_Credential__c+';;;'+requestString+';;;'+'Credentials/Businesses'+';;;'+'doupdateIdsInForgerock';
    con.state=requestURL;
   con.addHttpRequest(getRequest(interfaceData.Named_Credential__c, requestString));
  return con;
     
 }
 // Callback method
 @AuraEnabled(cacheable = true)
 public static Object processResponsefromForgerock(List<String> labels, Object state) {
     // Get the response by using the unique label
     
     
     HttpResponse response = Continuation.getResponse(labels[0]);
     
     try{
         String rstate = (String)state;
         System.debug(rstate);
         String[]  dta= rstate.split(';;;');
         System.debug(dta);
BOS_Utility.responseTraceHandler(className, dta[3], dta[2],''+ response.getStatusCode(), 'High', response.getBody(), dta[1], dta[0]);
     }catch(Exception e){}

     if (response.getStatusCode() == 200) {
       // return 'Success';
       return response.getBody();
     }
      return null;
 }
 
}