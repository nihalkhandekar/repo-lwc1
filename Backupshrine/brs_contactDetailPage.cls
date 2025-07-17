/* DESCRIPTION: This class contains business Contact detail method for BRS.
*
* @AUTHOR: 	Subham Agarwal
* @DATE: 	11/03/2020
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Subham Agarwal                   11/03/2020                   Created the first version
*********************************************************************************************/
public without sharing class brs_contactDetailPage {
    
    public static Final String className='brs_contactDetailPage';
    /********************************************************************************************
        METHOD NAME    : getAgentRecords
        DESCRIPTION    : to Get All Business Agent records while searching
        RETURN TYPE    : List of Agent Records
        PARAMETER      : String
    ********************************************************************************************/
     public class AccountWrapper {        
        @AuraEnabled
        public Integer totalNumberOfRecords {get;set;}
        @AuraEnabled
        public List<Account> accountListToSend {get;set;}
    }
    @AuraEnabled(cacheable = true)
    public static AccountWrapper getAccountRecords(String whereClause){
        List<BRS_online_enquiry__mdt> queryObj = new List<BRS_online_enquiry__mdt>();
        Integer varLimit;
        queryObj = BRS_Utility.getQueryConfig('Business_Search');
        if(!queryObj.isEmpty()){
            varLimit = Integer.valueOf(queryObj[0].Search_Limit__c);
        }
        AccountWrapper accWrapper = new AccountWrapper();
        List<Account> l_AccountRec = new List<Account>();
        Integer totalRecords;
             try{
                 if (whereClause != null && whereClause != '') {
                      // start of BRS-5263
                     System.debug('whereClause >> '+ whereClause);
                    List<brs_SortLegalDesignators> listOfDesignators = brs_SortLegalDesignators.getSortedList();
                    List<Business_Name_Noisewords__mdt> listOfNoiseWords = BRS_Utility.getNoiseWords();
    
                    whereClause = ' ' + (whereClause).normalizeSpace() + ' ';
    
                    for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                        if((whereClause != '' || whereClause != null) && noiseWrd.Label!='.' && (whereClause.containsIgnoreCase(noiseWrd.Label))){
                            if(!(noiseWrd.Label).isAlpha()){
                                whereClause = ' ' + (((whereClause).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                            }
                            else{
                                whereClause = ' ' + (((whereClause).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), ' ').normalizeSpace()) + ' ';
                            }
                        }
                    }
    
                    for(brs_SortLegalDesignators desgn : listOfDesignators) {                    
                        if((' '+whereClause+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                            Integer matchCount = (whereClause.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                            if(matchCount >= 1){
                                for(Integer i=0; i<matchCount; i++){
                                    whereClause= ' ' + (((whereClause).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                                }
                            }
                        }
                    } 
                    whereClause = Accents.removeDiacritics(whereClause);
                    whereClause = ((whereClause).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
                    System.debug('whereClause >> '+ whereClause);
                    // End of BRS-5263
                    if (whereClause != null && whereClause != '') {
                            l_AccountRec = [Select id,Name,AccountNumber,Billing_Unit__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,
                                    ShippingStreet,Shipping_Unit__c, ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry,Principle_Office_International_Address__c,Mailing_International_Address__c
                                    from Account Where Account_Name_Without_Designators__c LIKE :whereClause+'%'
                                    and Status__c = 'Active' ORDER BY Name LIMIT : varLimit];
                            totalRecords = [SELECT COUNT() FROM Account Where Account_Name_Without_Designators__c LIKE :whereClause+'%' and Status__c = 'Active'];                              
                        }
                    }  
                 accWrapper.totalNumberOfRecords = totalRecords;
                 accWrapper.accountListToSend = l_AccountRec;                 
                 return accWrapper;      

                } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getAccountRecords', 'Account', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : insertAgentRecord
        DESCRIPTION    : Used to insert Agent Record 
        RETURN TYPE    : Agent record
        PARAMETER      : Agent Record
    ********************************************************************************************/
    
    @AuraEnabled
    public static Agent__c insertAgentRecord(Agent__c agentRec){
        try {
            if(agentRec!=null && Schema.SObjectType.Agent__c.isAccessible()){
                insert agentRec;
            }
            return agentRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'insertAgentRecord', 'Agent__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : updateAgentRecord
        DESCRIPTION    : used to update Agent Record
        RETURN TYPE    : sobject
        PARAMETER      : sobject
    ********************************************************************************************/
    
    @AuraEnabled
    public static Agent__c updateAgentRecord(Agent__c AgentRec){
        try {
            if(AgentRec!=null && Schema.SObjectType.Agent__c.isAccessible() && Schema.SObjectType.Agent__c.isUpdateable()){
                update AgentRec;
            }
            return AgentRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'updateAgentRecord','Agent__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : deleteAgentRecord
        DESCRIPTION    : to delete Agent Record 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    
    @AuraEnabled
    public static void deleteAgentRecord(String sId) {
        
        List < Agent__c > l_AgentRec = new List < Agent__c > ();
        try {
            if (sId != null && sId != '') {
                l_AgentRec = [Select id, Name__c, Type__c, Business_City__c, Name, Business_Address__c,Email__c from Agent__c Where id=:sId limit 1];
            }
            if(!l_AgentRec.isEmpty())
                delete l_AgentRec;        
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'deleteAgentRecord', 'Agent__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : getPrincipalRecordsonLoad
        DESCRIPTION    : to Get All Princiapl records on loading
        RETURN TYPE    : List of Principal Records
        PARAMETER      : String
    ********************************************************************************************/

    @AuraEnabled
    public static List < Principal__c > getPrincipalRecordsonLoad(String sId) {
        List < Principal__c > l_PrincipalRec = new List < Principal__c > ();
        try {
            if (sId != null && sId != '') {
                l_PrincipalRec = [Select id, Name__c, Type__c,Business_ID__r.AccountNumber,Business_ID__c,Principal_Account_ID__c,Principal_Type__c,Principal_Account_ID__r.AccountNumber,Business_Name__c,FirstName__c,LastName__c, Principal_Title__c, Name,Email__c, Created_From_Agent__c,
                                  Business_City__c,Business_Country__c,Business_State__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,Business_Zip_Code__c,
                                  Residence_State__c,Residence_City__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c,Residence_Country__c,Residence_InternationalAddress__c,Business_InternationalAddress__c,Designation__c from Principal__c Where Business_ID__c=:sId
                            order by CreatedDate asc     
                                 ];
            }
            return l_PrincipalRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getPrincipalRecordsonLoad', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
         /********************************************************************************************
        METHOD NAME    : getAgentRecordsonLoad
        DESCRIPTION    : to Get All Agent records on loading
        RETURN TYPE    : List of Agent Records
        PARAMETER      : String
    ********************************************************************************************/
    
    @AuraEnabled
    public static Agent__c getAgentRecordsonLoad(String sId) {
        Agent__c AgentRec = null;
        List<Agent__c> lstAgent = new List <Agent__c>();
        try {
            if (sId != null && sId != '') {
                lstAgent = [Select id, Name__c, Type__c,Agent_Phone__c,Business_ID__r.AccountNumber,Business_ID__c,Agent_Account_ID__c,Agent_Account_ID__r.AccountNumber,Business_Name__c,FirstName__c,LastName__c, Name,Email__c,
                                  Business_City__c,Business_Country__c,Business_State__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,Business_Zip_Code__c,
                              Mailing_City__c,Mailing_Country__c,Mailing_State__c,Mailing_Street_Address_1__c,Mailing_Zip_Code__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,    
                              Residence_State__c,Residence_City__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c,Residence_Country__c,Business_InternationalAddress__c from Agent__c Where Business_ID__c=:sId
                            limit 1     
                                 ];
            }
             if(!lstAgent.IsEmpty()){
                 AgentRec = lstAgent[0];
             }
            return AgentRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getAgentRecordsonLoad', 'Agent__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : deletePrincipalRecord
        DESCRIPTION    : Used to delete Principal records 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    
    @AuraEnabled
    public static void deletePrincipalRecord(String sId) {
        
        List < Principal__c > l_PrincipalRec = new List < Principal__c > ();
        try {
            if (sId != null && sId != '') {
                l_PrincipalRec = [Select id, Name__c, Type__c,Principal_Type__c, Principal_Title__c, Business_City__c, Name, Business_Address__c,Email__c from Principal__c Where id=:sId limit 1];
            }
            if(!l_PrincipalRec.isEmpty())
                delete l_PrincipalRec;        
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getPrincipalRecords', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : updatePrincipalRecord
        DESCRIPTION    : Used to update Principal Record
        RETURN TYPE    : sObject
        PARAMETER      : sObject
    ********************************************************************************************/
    @AuraEnabled
    public static Principal__c updatePrincipalRecord(Principal__c principalRec){
        try {
            if(principalRec!=null && Schema.SObjectType.Principal__c.isAccessible() && Schema.SObjectType.Principal__c.isUpdateable()){
                update principalRec;
            }
            return principalRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'updatePrincipalRecord','Principal__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : insertPrincipalRecord
        DESCRIPTION    : Used to insert Principal Record 
        RETURN TYPE    : Agent record
        PARAMETER      : String
    ********************************************************************************************/
    @AuraEnabled
    public static Principal__c insertPrincipalRecord(Principal__c principalRec){
        try {
            if(principalRec!=null && Schema.SObjectType.Principal__c.isAccessible()){
                insert principalRec;
            }
            return principalRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'insertPrincipalRecord','Principal__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : updateAgentOnAccount
        DESCRIPTION    : to update Agent Record on Account
        RETURN TYPE    : Agent record
        PARAMETER      : String,String
    ********************************************************************************************/
    @AuraEnabled
    public static Agent__c updateAgentOnAccount(String accId, String businessAgent){
        try {
            Agent__c agentRec = new Agent__c();
            if(businessAgent!=null){
                agentRec = [select Id,Agent_Account_ID__c from Agent__c where Id=:businessAgent limit 1];
                if(businessAgent !='undefined'){
                    agentRec.Agent_Account_ID__c = accId;
                }
                if(businessAgent != null && Schema.SObjectType.Agent__c.isAccessible() && Schema.SObjectType.Agent__c.isUpdateable()){
                    update agentRec;
                }
            }
            return agentRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'updateAgentOnAccount','Agent__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : getAgentVisible
        DESCRIPTION    : to see agent button based on entity
        RETURN TYPE    : boolean
        PARAMETER      : Id
    ********************************************************************************************/
    @AuraEnabled(cacheable = true)
    public static boolean getAgentVisible(String QuestionnaireId){
        try {
            Boolean agentVisible;
            Boolean isDomestic = false;
            Boolean isLLP = false;
            Boolean isInConnecticut = true;
            List<QnA_QuestionResponse__c> l_Quest = [Select id,Question_Body__c,
                                                     name,Given_Response__c,Given_Response_Value__c,
                                                     Question_Summary__c from QnA_QuestionResponse__c Where Questionnaire__c =: QuestionnaireId];
            if(!l_Quest.isEmpty() && l_Quest.size()>0 ){
                for(QnA_QuestionResponse__c QnA :l_Quest){
                    if(QnA.Question_Summary__c == 'Foreign or Domestic' && QnA.Given_Response_Value__c == 'Domestic'){
                        isDomestic = true;
                    }
                    if(QnA.Question_Summary__c == 'Legal Structure' && QnA.Given_Response_Value__c =='Limited Liability Partnership'){
                        isLLP = true;
                    }
                    if(QnA.Question_Summary__c == 'Location'){
                        
                    }
                }
            }
            if(isDomestic && isLLP && isInConnecticut){
                agentVisible = true;
            }else {
                agentVisible = true;
            }
            return agentVisible;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'getAgentVisible','QnA_QuestionResponse__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : getStates
        DESCRIPTION    : Used to get Picklist values from State
        RETURN TYPE    : list
        PARAMETER      : 
    ********************************************************************************************/
   @AuraEnabled (cacheable = true)
    public static string getStates(){
        List<option> options = new List<option>();
        List<String> lstStates = new List<String>();
        Schema.DescribeFieldResult fieldResult = Principal__c.Residence_State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new option(f.getLabel(), f.getValue()));
        }     
        return JSON.serialize(options) ;
    }
	public class option{
		@AuraEnabled
		public string label, value;
		
		public option(string label, string value){
			this.label = label;
			this.value = value;
		}
		
	}
    /********************************************************************************************
        METHOD NAME    : getPrincipalAsAgentRecords
        DESCRIPTION    : get All Principal records as Agent
        RETURN TYPE    : list
        PARAMETER      : String
    ********************************************************************************************/
    @AuraEnabled
    public static List<Principal__c> getPrincipalAsAgentRecords(String accId){
        try {
            List<Principal__c> l_PrincipalRec  = new List<Principal__c>();
            if(accId!=null && accId!= ''){
                l_PrincipalRec = [Select id, Name__c,FirstName__c,LastName__c, Type__c,Principal_Type__c,Principal_Account_ID__c, Principal_Title__c, Business_City__c,Business_Street_Address_1__c,Business_State__c,Business_Street_Address_2__c,Business_Zip_Code__c, Name,Email__c,
                                  Residence_City__c ,Residence_Country__c, Residence_State__c , Residence_Street_Address_1__c , 
                                  Residence_Street_Address_2__c , Residence_Street_Address_3__c , Residence_Zip_Code__c,Business_ID__c,Business_ID__r.AccountNumber
                                  from Principal__c 
                                  Where ((Principal_Type__c = 'Individual' and Residence_State__c = 'CT' ) OR (Principal_Type__c = 'Business' and Business_State__c = 'CT')) and Principal_Account_ID__c =:accId];
            }
            return l_PrincipalRec;
        }
        catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'getPrincipalAsAgentRecords','Principal__c',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
    METHOD NAME    : fetchInterfaceConfig
    DESCRIPTION    : This method fetch the custom metadata 'Interface configuration' which contains
    the URL to be redirected on clicking 'Create an Account' on getstarted link.
    RETURN TYPE    : Interface_Configuration__mdt
    PARAMETER      : String labelName (Label of Custom Metadatda record)
    ********************************************************************************************/
    @AuraEnabled
    public static Interface_Configuration__mdt fetchInterfaceConfig(){
        Interface_Configuration__mdt interfaceConfig;
        try{
            if(Schema.SObjectType.Interface_Configuration__mdt.isAccessible() && interfaceConfig == null){
                interfaceConfig = [SELECT Current_Environment__c,AuthId__c,AuthToken__c,DeveloperName,Id,End_URL__c,API_Key__c FROM Interface_Configuration__mdt
                                   WHERE MasterLabel ='SmartyStreets'];
            }
            return interfaceConfig;
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'fetchInterfaceConfig','Interface_Configuration__mdt',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    
    // Incorporator One
    // Author : Ashish Narang
     /********************************************************************************************
        METHOD NAME    : insertIncorporatorRecord
        DESCRIPTION    : Used to insert Incorporator Record 
        RETURN TYPE    : Contact
        PARAMETER      : Contact
    ********************************************************************************************/
    
    @AuraEnabled
    public static Contact insertIncorporatorRecord(Contact incorpRec){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Incorporator').getRecordTypeId();
        try {
            if(incorpRec!=null && Schema.SObjectType.Contact.isAccessible()){
                incorpRec.RecordTypeId = devRecordTypeId;
                insert incorpRec;   
            }
            return incorpRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'insertIncorporatorRecord', 'Contact', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : updateIncorporatorRecord
        DESCRIPTION    : used to update Incorporator Record
        RETURN TYPE    : Contact
        PARAMETER      : Contact
    ********************************************************************************************/
    
    @AuraEnabled
    public static Contact updateIncorporatorRecord(Contact incorpRec){
        try {
            if(incorpRec!=null && Schema.SObjectType.Contact.isAccessible() && Schema.SObjectType.Contact.isUpdateable()){
                update incorpRec;
            }
            return incorpRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className,'updateIncorporatorRecord','Contact',null,BOS_Utility.sSeverity,e,null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
        METHOD NAME    : deleteIncorporatorRecord
        DESCRIPTION    : to delete Agent Record 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    
    @AuraEnabled
    public static void deleteIncorporatorRecord(String sId) {
        
        List < Contact > l_IncorpRec = new List < Contact > ();
        try {
            if (sId != null && sId != '') {
                l_IncorpRec = [Select id, Name from Contact Where id=:sId];
            }
            if(!l_IncorpRec.isEmpty())
                delete l_IncorpRec;        
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'deleteIncorporatorRecord', 'Contact', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List < Contact > getIncorporatorRecordsonLoad(String sId) {
        List < Contact > l_IncorporatorRec = new List < Contact > ();
        try {
            if (sId != null && sId != '') {
                l_IncorporatorRec = [Select id, Name,FirstName,LastName,Type__c,Business_Name__c, accountid,Email, Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c,Residence_Country__c,
                Residence_City__c,Residence_State__c,Residence_InternationalAddress__c from Contact Where AccountId=:sId
                            order by CreatedDate asc     
                                 ];
            }
            return l_IncorporatorRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getIncorporatorRecordsonLoad', 'Contact', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

   /********************************************************************************************
        METHOD NAME    : getTempRecordsonLoad
        DESCRIPTION    : To get temporary history records based on type and related account id on loading
        RETURN TYPE    : List of Temporary Records
        PARAMETER      : String
    ********************************************************************************************/

    @AuraEnabled
    public static List<Temp_History__c> getTempRecordsonLoad(String sId, string type, String filingId) {
        List<Temp_History__c> TempRec = new List<Temp_History__c>();
        try {
            if(filingId != null)
            {
                TempRec = [Select id, Name, Title__c,Designation__c,Agent__c,Principal__c,Type__c,Temp_Type__c,Phone__c,Business_Name__c,Business_ID__c,Business_ID__r.AccountNumber,Account__c,Account__r.AccountNumber,FirstName__c,LastName__c, Name__c,Email__c,Business_Filing__c,Business_InternationalAddress__c,  Residence_InternationalAddress__c,Created_From_Agent__c,
                Business_City__c,Business_Country__c,Business_State__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,Business_Zip_Code__c,
                Mailing_City__c,Mailing_Country__c,Mailing_State__c,Mailing_Street_Address_1__c,Mailing_Zip_Code__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,    
                Residence_State__c,Residence_City__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c,Residence_Country__c from Temp_History__c Where Business_ID__c=:sId AND Type__c=:type AND Change_Type__c !=: System.Label.Deleted and Business_Filing__c =: filingId order by CreatedDate DESC                          
                                 ];
            }
            else
            {
                TempRec = [Select id, Name, Title__c,Designation__c,Agent__c,Principal__c,Type__c,Temp_Type__c,Phone__c,Business_Name__c,Business_ID__c,Business_ID__r.AccountNumber,Account__c,Account__r.AccountNumber,FirstName__c,LastName__c, Name__c,Email__c,Business_Filing__c,Business_InternationalAddress__c,  Residence_InternationalAddress__c,Created_From_Agent__c,
                Business_City__c,Business_Country__c,Business_State__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,Business_Zip_Code__c,
                Mailing_City__c,Mailing_Country__c,Mailing_State__c,Mailing_Street_Address_1__c,Mailing_Zip_Code__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,    
                Residence_State__c,Residence_City__c,Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_Zip_Code__c,Residence_Country__c from Temp_History__c Where Business_ID__c=:sId AND Change_Type__c !=: System.Label.Deleted AND Type__c=:type order by CreatedDate DESC                          
                                 ];
            }
            
            return TempRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'getTempAgentRecordsonLoad', 'Temp_History__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************
        METHOD NAME    : upsertTempRecord
        DESCRIPTION    : To insert/update temporary history records
        RETURN TYPE    : List of Temporary Records
        PARAMETER      : String
    ********************************************************************************************/

    @AuraEnabled
    public static Temp_History__c upsertTempRecord(Temp_History__c tempRec){
        try {
            if(tempRec.Type__c=='Agent' && (String.isNotBlank(tempRec.Agent__c))){
                String accId = tempRec.Business_Id__c;
                Agent__c actualAgent = getAgentRecordsonLoad(accId);
            if(actualAgent!=null){
                tempRec.Email_Old__c = actualAgent.Email__c;             
                tempRec.Agent_Phone_Old__c = actualAgent.Agent_Phone__c;
                tempRec.FirstName_Old__c = actualAgent.FirstName__c;
                tempRec.LastName_Old__c = actualAgent.LastName__c; 
                tempRec.Business_InternationalAddress_Old__c = actualAgent.Business_InternationalAddress__c;          
                tempRec.Business_City_Old__c = actualAgent.Business_City__c;
                tempRec.Business_Country_Old__c = actualAgent.Business_Country__c;
                tempRec.Business_State_Old__c = actualAgent.Business_State__c;
                tempRec.Business_Zip_Code_Old__c = actualAgent.Business_Zip_Code__c;   
                tempRec.Business_Street_Address_1_Old__c = actualAgent.Business_Street_Address_1__c;      
                tempRec.Business_Street_Address_2_Old__c = actualAgent.Business_Street_Address_2__c;      
                tempRec.Mailing_City_Old__c = actualAgent.Mailing_City__c;
                tempRec.Mailing_Country_Old__c = actualAgent.Mailing_Country__c;
                tempRec.Mailing_State_Old__c = actualAgent.Mailing_State__c;   
                tempRec.Mailing_Zip_Code_Old__c = actualAgent.Mailing_Zip_Code__c;
                tempRec.Mailing_Street_Address_1_Old__c = actualAgent.Mailing_Street_Address_1__c;
                tempRec.Mailing_Street_Address_2_Old__c = actualAgent.Mailing_Street_Address_2__c;
                tempRec.Residence_Street_Address1_Old__c = actualAgent.Residence_Street_Address_1__c;
                tempRec.Residence_Street_Address_2_Old__c = actualAgent.Residence_Street_Address_2__c;
                tempRec.Residence_City_Old__c = actualAgent.Residence_City__c;
                tempRec.Residence_Country_Old__c = actualAgent.Residence_Country__c;
                tempRec.Residence_State_Old__c = actualAgent.Residence_State__c;   
                tempRec.Residence_Zip_Code_Old__c = actualAgent.Residence_Zip_Code__c; 
                tempRec.Account__c = actualAgent.Agent_Account_ID__c!=null?actualAgent.Agent_Account_ID__c:null;
                tempRec.Business_Id__c= actualAgent.Business_Id__c;	
            }              
        }
        
            if(tempRec!=null && Schema.SObjectType.Temp_History__c.isAccessible()){
               upsert tempRec;               
            }
            return tempRec;
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'upsertTempRecord', 'Temp_History__c', null, BOS_Utility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    } 
   /********************************************************************************************
        METHOD NAME    : getAllRecordsonLoad
        DESCRIPTION    : To get all original and temp history records
        RETURN TYPE    : Wrapper of original and temp records
        PARAMETER      : String
    ********************************************************************************************/


    @AuraEnabled
    public static BRS_AnnualReportWrapper getAllRecordsonLoad(String sId, String filingId) {
    List < Principal__c > l_PrincipalRec = new List < Principal__c > ();
    List < string > pIDList = new List < string > ();
    List < Temp_History__c > tempRecList = new List < Temp_History__c > ();
    List < Temp_History__c > tempRecListToSend = new List < Temp_History__c > ();
    Boolean isPrincpalChange = false;
    try {
        //Added for BRS-1691 to include filing id and send temp record related to that
        if(filingId != null)
        {
            tempRecList = [Select id, Name, Title__c, Designation__c, Agent__c, Principal__c, Change_Type__c, Type__c, Temp_Type__c, Phone__c, Business_Name__c, Business_ID__c, Business_ID__r.AccountNumber, Account__c, Account__r.AccountNumber, FirstName__c, LastName__c, Name__c, Email__c, Business_Filing__c,Business_Filing__r.Type__c, Business_InternationalAddress__c, Residence_InternationalAddress__c, Created_From_Agent__c,
            Business_City__c, Business_Country__c, Business_State__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,
            Mailing_City__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,
            Residence_State__c, Residence_City__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_Country__c from Temp_History__c Where Business_ID__c =: sId AND Type__c =: System.Label.Principal and Business_Filing__c =: filingId
        ];
        }
        else
        {
        tempRecList = [Select id, Name, Title__c, Designation__c, Agent__c, Principal__c, Change_Type__c, Type__c, Temp_Type__c, Phone__c, Business_Name__c, Business_ID__c, Business_ID__r.AccountNumber, Account__c, Account__r.AccountNumber, FirstName__c, LastName__c, Name__c, Email__c, Business_Filing__c,Business_Filing__r.Type__c, Business_InternationalAddress__c, Residence_InternationalAddress__c, Created_From_Agent__c,
            Business_City__c, Business_Country__c, Business_State__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,
            Mailing_City__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c, Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,
            Residence_State__c, Residence_City__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_Country__c from Temp_History__c Where Business_ID__c =: sId AND Type__c =: System.Label.Principal
        ];
        }
        for (Temp_History__c tempRecord: tempRecList) {
            pIDList.add(tempRecord.Principal__c);
            if (tempRecord.Change_Type__c != System.Label.Deleted) {
                tempRecListToSend.add(tempRecord);
            }
            //Added for BRS-1691 to check if any change being done or not for principal
            if(filingId != null && tempRecord.Business_Filing__c != null && tempRecord.Business_Filing__r.Type__c == 'Interim notice' && isPrincpalChange == false)
                isPrincpalChange = true;
        }

        if (sId != null && sId != '') {
            l_PrincipalRec = [Select id, Name__c, Type__c, Business_ID__r.AccountNumber, Business_ID__c, Principal_Account_ID__c, Principal_Account_ID__r.AccountNumber, Principal_Type__c, Business_Name__c, FirstName__c, LastName__c, Principal_Title__c, Name, Email__c, Created_From_Agent__c,
                Business_City__c, Business_Country__c, Business_State__c, Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,Designation__c,
                Residence_State__c, Residence_City__c, Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c, Residence_Country__c, Residence_InternationalAddress__c, Business_InternationalAddress__c from Principal__c Where Business_ID__c =: sId AND ID Not In: pIDList
                order by CreatedDate asc
            ];
        }
        BRS_AnnualReportWrapper wrapObj = new BRS_AnnualReportWrapper();
        wrapObj.l_PrincipalRec = l_PrincipalRec;
        wrapObj.tempRecListToSend = tempRecListToSend;
        wrapObj.isPrincipalChanged = isPrincpalChange;
        return wrapObj;
    } catch (Exception e) {
        BOS_Utility.ExceptionHandler(className, 'getPrincipalRecordsonLoad', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
        throw new AuraHandledException(e.getMessage());
    }
}


 public with sharing class BRS_AnnualReportWrapper {
        @AuraEnabled  
       public list<Principal__c> l_PrincipalRec {get;set;}
       @AuraEnabled 
       public list<Temp_History__c> tempRecListToSend {get;set;} 
	   @AuraEnabled 
       public Boolean isPrincipalChanged {get;set;} 

    
}
/********************************************************************************************
        METHOD NAME    : deleteTempAgentRecord
        DESCRIPTION    : to delete temp History Agent Record 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    
    @AuraEnabled
    public static void deleteTempRecord(String sId) {
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: FOR Agent Change MAintenace flow removing all temp for agent when not changing an agent.
        * Change(s)/Modification(s) Description : Adding logic to get temp records of agent type delete based on the type= "Agent". sId here is the business filing passed from FE where the filing is being conducted.
        * Change(s)/Modification(s) Made on : 2021-04-11
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        try {
            // prev code
            // List < Temp_History__c> l_TempRec = new List < Temp_History__c> {new Temp_History__c(Id=sId)};
            // BOS_utility.deleteRecords(l_TempRec);
            // New change
            List<Temp_History__c> lstBF = new List<Temp_History__c>();
            lstBF = [Select Id, Type__c from Temp_History__c WHERE Business_filing__c =: sId AND Type__c =: Label.Agent];
            if(!lstBF.isEmpty()){
                BOS_utility.deleteRecords(lstBF);
            }
            
        } catch (Exception e) {
           BOS_Utility.ExceptionHandler(className, 'deleteTempRecord', 'Temp_History__c', null, BOS_Utility.sSeverity, e, null);
           throw new AuraHandledException(e.getMessage());
        }
    }
}