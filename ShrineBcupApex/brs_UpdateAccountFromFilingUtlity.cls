public without sharing class brs_UpdateAccountFromFilingUtlity {
    public brs_UpdateAccountFromFilingUtlity() {

    }
    public static Final String className = 'brs_UpdateAccountFromFilingUtlity';

    public String query = '';
    public Integer priorDayCount = Integer.valueOf(system.label.brs_updateMaintenanceFilings_Days);
    public Date today = Date.today();
    public Date priorDay = Date.today().addDays(priorDayCount);
    public List<String> filingStatus = new List<String>{'Approved'};

    public class Requests {
        @InvocableVariable
        public Business_filing__c busFilObj;        
    }

    @Future
    public static void updateAccountFromFilingfromTrigger(Map<Id, Boolean> mapIdAutoApprove){
        List<String> filingStatus = new List<String>{'Approved'};
        Set<Id> busFilingIDList = new Set<Id>();
        
        try{
            if(!mapIdAutoApprove.isEmpty()) {
                for(Id bf : mapIdAutoApprove.keySet()) {
                    if(!mapIdAutoApprove.get(bf)) {
                        busFilingIDList.add(bf);
                    }
                    //busFilingIDList.add(bf);
                }
                String query  = System.label.Update_Sobject_AnnualFirst_Business_Filing_Query;
                String securityEnforced = ' WITH SECURITY_ENFORCED';
                query = query + securityEnforced;
                List<Business_Filing__c> businessFilings = Database.query(query);
                updateAccountFromFiling(businessFilings);
            }
            
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, 'BusinessMaintenance', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
        }
    }

    @InvocableMethod
    public static void updateAccountFromFiling(List<Requests> results){
        try{
            List<Business_Filing__c> businessFilings = new List<Business_Filing__c>();
            if(results.size()>0 && results[0].busFilObj!=null){
                businessFilings.add(results[0].busFilObj);
                updateAccountFromFiling(businessFilings);
            }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'Annual Report',null,null,BOS_Utility.sSeverity,ex,ex.getMessage());
        }
    }

    public static void updateAccountFromFiling(List<Business_Filing__c> busFilingList){
        map<String,List<maintenanceFilingUpdateWrapper>> maintenanceFilingMap = new map<String,List<maintenanceFilingUpdateWrapper>>();
        List<Account> accLst = new List<Account>();
        set<String> busFileIds = new set<String>();
        List<Temp_History__c> TempRecs = new List<Temp_History__c>();
        List<Principal__c> insertPrincipal = new List<Principal__c>();
        List<Principal__c> deletePrincipal = new List<Principal__c>();
        List<Agent__c> upsertAgent = new List<Agent__c>();
        List<Agent__c> deleteAgent = new List<Agent__c>();
        List<id> eliminateDuplicateAccountId=new List<id>();
        for(Update_SObject_Automation__mdt config : [Select Id, MasterLabel, DeveloperName, Business_Filing_Type__c, Status_Value__c, Target_Object__c from Update_SObject_Automation__mdt where Business_Filing_Type__c in ('First Report','Annual Report')])
        {
            List<maintenanceFilingUpdateWrapper> maintenanceFileLst = new List<maintenanceFilingUpdateWrapper>();
            for(Business_Filing__c busFile : busFilingList)
            {    
                if(config.Business_Filing_Type__c == busFile.Type__c)
                {
                    maintenanceFilingUpdateWrapper maintenanceFile = new maintenanceFilingUpdateWrapper();
                    maintenanceFile.busFilingId = busFile.Id;
                    maintenanceFile.busId = busFile.Account__c;
                    maintenanceFile.tarObj = config.Target_Object__c;
                    maintenanceFile.statusValue = config.Status_Value__c;
                    maintenanceFile.filingType = config.Business_Filing_Type__c;
                    maintenanceFileLst.add(maintenanceFile);
                }
            }
            maintenanceFilingMap.put(config.Business_Filing_Type__c,maintenanceFileLst);
        }
        for(String str : maintenanceFilingMap.keySet())
        {
            List<maintenanceFilingUpdateWrapper> maintenanceFileLst2 = maintenanceFilingMap.get(str);
            for(maintenanceFilingUpdateWrapper file : maintenanceFileLst2)
            {  
                
                   busFileIds.add(file.busFilingId); 
             
            }
        }
        
        if(!busFileIds.IsEmpty())
        {
           String queryString = 'Select id, Name, Title__c, Designation__c, Agent__c,NAICS_Code_New__c,Business_Name_New__c,';
           queryString+='Business_Email_Address__c, Principal__c, Type__c, Temp_Type__c, Phone__c, Business_Name__c,';
           queryString+='Business_ID__c, Business_ID__r.AccountNumber, Account__c,Account__r.AccountNumber, FirstName__c,';
           queryString+='LastName__c, Name__c, Email__c, Business_Filing__c,Business_Filing__r.Type__c,Business_Filing__r.Status__c, Business_InternationalAddress__c,';
           queryString+='Residence_InternationalAddress__c, Created_From_Agent__c,Business_City__c, Business_Country__c, Business_State__c,';
           queryString+='Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,';
           queryString+='Mailing_City__c, Change_Type__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c,';
           queryString+='Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,Principal_Title__c, Residence_State__c, Residence_City__c,';
           queryString+='Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c,';
           queryString+='Billing_City_New__c, Billing_Country_New__c, BillingPostalCode_New__c, BillingState_New__c,BillingStreet_New__c,Business_Name_in_state_country__c,';
           queryString+='ShippingCity_New__c, Shipping_Country_New__c, ShippingPostalCode_New__c, ShippingState_New__c,ShippingStreet_New__c,Principle_Office_International_Address_N__c,';
           queryString+='Office_Jurisdiction_BusinessZipCode_New__c, Office_Jurisdiction_BusinessStreet_New__c, Office_Jurisdiction_BusinessState_New__c, Office_Jurisdiction_BusinessCity_New__c,Jurisdiction_International_address_New__c,Date_of_Organization_Meeting__c,';
           queryString+='Mailing_Jurisdiction_BusinessZipCode_New__c, Mailing_Jurisdiction_BusinessStreet_New__c,Mailing_Jurisdiction_BusinessState_New__c, Mailing_Jurisdiction_BusinessCity_New__c,Mailing_International_Address_New__c,NAICS_Code__c,Billing_City__c,Billing_Country__c,BillingPostalCode__c,BillingState__c,BillingStreet__c,Business_Unit_New__c,Principle_Office_International_Address__c,';
           queryString+='ShippingCity__c,Shipping_Country__c,ShippingPostalCode__c,ShippingState__c,ShippingStreet__c,Mailing_International_Address__c,Office_Jurisdiction_BusinessZipCode__c,Office_Jurisdiction_BusinessStreet__c,Office_Jurisdiction_BusinessState__c,Office_Jurisdiction_BusinessCity__c,Office_Jurisdiction_Country__c,Office_Jurisdiction_BusinessUnit__c,Jurisdiction_International_address__c,Mailing_Jurisdiction_BusinessZipCode__c,Mailing_Jurisdiction_BusinessStreet__c,Mailing_Jurisdiction_BusinessState__c,Mailing_Jurisdiction_BusinessCity__c,Mail_Jurisdiction_International_address__c,Mailing_Jurisdiction_BusinessUnit__c,Mailing_Jurisdiction_Country__c,Mailing_Unit_New__c,';
           queryString+='Category_Survey_Email_Address_New__c,Minority_Owned_Organization_New__c,None_of_the_listed_Organizations_New__c,Opt_Out_of_Category_Survey_New__c,Veteran_Owned_Organization_New__c,Woman_Owned_Organization_New__c,Prefer_not_to_answer_New__c,Organization_is_LGBTQI_Owned_New__c,Org_Owned_by_Person_with_disabilitiesNew__c,Date_of_Organization_Meeting_New__c,Business_Unit__c,Mailing_Unit__c,Office_Jurisdiction_Country_New__c,Office_Jurisdiction_BusinessUnit_New__c,Mail_JurisdictionInternationaladdress_N__c,Mailing_Jurisdiction_BusinessUnit_New__c,Mailing_Jurisdiction_Country_New__c,Email_New__c,';
           queryString+='Residence_Country__c from Temp_History__c';

           String whereClause = ' Where Business_Filing__c in: busFileIds WITH SECURITY_ENFORCED' ;
           queryString = queryString + whereClause;
           TempRecs = Database.query(queryString);
           if (!TempRecs.IsEmpty()) {
               for(Temp_History__c rec : TempRecs)
               {
                   if(rec.Type__c == system.label.Principal && ( rec.Business_Filing__r.Type__c == 'First Report' || rec.Business_Filing__r.Type__c == 'Annual Report' ) && rec.Business_Filing__r.Status__c == 'Approved')
                   {
                       Principal__c pr = new Principal__c();
                       if(rec.Change_Type__c == system.label.brs_maintenance_tempCreated || rec.Change_Type__c == system.label.brs_maintenance_tempEdited)
                       {
                          
                           pr.id = rec.Principal__c;
                           pr.Business_City__c = rec.Business_City__c;
                           pr.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                           pr.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                           pr.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                           pr.Business_State__c = rec.Business_State__c;
                           pr.Business_Country__c = rec.Business_Country__c;
                           pr.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                           pr.Principal_Title__c = rec.Title__c;
                           pr.FirstName__c = rec.FirstName__c;
                           pr.LastName__c = rec.LastName__c;
                           pr.Name__c = rec.Name__c;
                           pr.Email__c = rec.Email__c;
                           pr.Residence_City__c = rec.Residence_City__c;
                           pr.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                           pr.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                           pr.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                           pr.Residence_State__c = rec.Residence_State__c;
                           pr.Residence_Country__c = rec.Residence_Country__c;
                           pr.Residence_InternationalAddress__c = rec.Residence_InternationalAddress__c;
                           pr.Principal_Account_ID__c = rec.Account__c;
                           pr.Business_ID__c = rec.Business_Id__c;
                           pr.Designation__c = rec.Designation__c;
                           pr.Business_Name__c = rec.temp_type__c !=NULL && rec.temp_type__c == System.Label.Agent_Business_Option ? rec.Name__c : '';
                           pr.Principal_Type__c = rec.temp_type__c;
                           insertPrincipal.add(pr);
                       } else if(rec.Change_Type__c == system.label.Deleted && rec.Principal__c != null)
                       {
                           pr.Id = rec.Principal__c;
                           deletePrincipal.add(pr);
                       }
                   }
                   else if(rec.Type__c == system.label.Agent && ( rec.Business_Filing__r.Type__c == 'First Report' || rec.Business_Filing__r.Type__c == 'Annual Report' ) && rec.Business_Filing__r.Status__c == 'Approved')
                   {   
                       Agent__c ag = new Agent__c();
                       if(rec.Change_Type__c == system.label.brs_maintenance_tempCreated || rec.Change_Type__c == system.label.brs_maintenance_tempEdited)
                       {
                               ag.Id = rec.Agent__c;
                               ag.Business_City__c = rec.Business_City__c;
                               ag.Business_Street_Address_1__c = rec.Business_Street_Address_1__c;
                               ag.Business_Street_Address_2__c = rec.Business_Street_Address_2__c;
                               ag.Business_Zip_Code__c = rec.Business_Zip_Code__c;
                               ag.Business_State__c = rec.Business_State__c;
                               ag.Business_Country__c = rec.Business_Country__c;
                               ag.Business_InternationalAddress__c = rec.Business_InternationalAddress__c;
                               ag.Residence_City__c = rec.Residence_City__c;
                               ag.Residence_Street_Address_1__c = rec.Residence_Street_Address_1__c;
                               ag.Residence_Street_Address_2__c = rec.Residence_Street_Address_2__c;
                               ag.Residence_Zip_Code__c = rec.Residence_Zip_Code__c;
                               ag.Residence_State__c = rec.Residence_State__c;
                               ag.Residence_Country__c = rec.Residence_Country__c;
                               ag.Mailing_City__c = rec.Mailing_City__c;
                               ag.Mailing_Street_Address_1__c = rec.Mailing_Street_Address_1__c;
                               ag.Mailing_Street_Address_2__c = rec.Mailing_Street_Address_2__c;
                               ag.Mailing_Zip_Code__c = rec.Mailing_Zip_Code__c;
                               ag.Mailing_State__c = rec.Mailing_State__c;
                               ag.Mailing_Country__c = rec.Mailing_Country__c;
                               ag.Business_ID__c = rec.Business_ID__c;
                               ag.Agent_Account_ID__c = rec.temp_type__c == System.Label.Business_Comparable ?rec.Account__c:null;
                               ag.FirstName__c = rec.FirstName__c;
                               ag.LastName__c = rec.LastName__c;
                               ag.Name__c = rec.Name__c; 
                               ag.Email__c = rec.Email__c;
                               ag.Agent_Phone__c = rec.Phone__c;
                               ag.Business_Name__c = rec.temp_type__c !=NULL && rec.temp_type__c == System.Label.Agent_Business_Option ? rec.Name__c : '';
                               ag.Type__c = rec.temp_type__c;
                               upsertAgent.add(ag);
                       }
                       else if(rec.Change_Type__c == system.label.Deleted  && rec.Agent__c != null)
                       {
                               ag.Id = rec.Agent__c;
                               deleteAgent.add(ag);
                       }
                   }
                   else if(rec.Type__c == system.label.Account && ( rec.Business_Filing__r.Type__c == 'First Report' || rec.Business_Filing__r.Type__c == 'Annual Report' ) && rec.Account__c != null && rec.Business_Filing__r.Status__c == 'Approved')
                   {
                    if(!eliminateDuplicateAccountId.contains(rec.Account__c))
                    {
                        Account acc2 = new Account(Id=rec.Account__c);
                    
                        // Primary details information.
                        if(rec.NAICS_Code__c != NULL || rec.NAICS_Code_New__c != NULL){
                            acc2.NAICS_Code__c = rec.NAICS_Code_New__c;
                        }
                        if(rec.Email_New__c != NULL || rec.Business_Email_Address__c != NULL){
                            acc2.Business_Email_Address__c = rec.Email_New__c;
                        }
                        if(rec.Date_of_Organization_Meeting_New__c != NULL || rec.Date_of_Organization_Meeting__c != NULL){
                            acc2.Date_of_Organization_Meeting__c = rec.Date_of_Organization_Meeting_New__c;
                        }
                        if(rec.Business_filing__r.Type__c == Label.Annual_Report){
                            if(rec.Veteran_Owned_Organization_New__c || rec.Woman_Owned_Organization_New__c || rec.Prefer_not_to_answer_New__c || rec.Organization_is_LGBTQI_Owned_New__c || rec.Org_Owned_by_Person_with_disabilitiesNew__c || rec.Opt_Out_of_Category_Survey_New__c || rec.None_of_the_listed_Organizations_New__c || rec.Minority_Owned_Organization_New__c){
                                acc2.Veteran_Owned_Organization__c = rec.Veteran_Owned_Organization_New__c;
                                acc2.Woman_Owned_Organization__c = rec.Woman_Owned_Organization_New__c;
                                acc2.Prefer_not_to_answer__c = rec.Prefer_not_to_answer_New__c;
                                acc2.Organization_is_LGBTQI_Owned__c = rec.Organization_is_LGBTQI_Owned_New__c;
                                acc2.Org_Owned_by_Person_s_with_disabilities__c = rec.Org_Owned_by_Person_with_disabilitiesNew__c;
                                acc2.Opt_Out_of_Survey_Email_Notification__c = rec.Opt_Out_of_Category_Survey_New__c;
                                acc2.None_of_the_listed_Organizations__c = rec.None_of_the_listed_Organizations_New__c;
                                acc2.Minority_Owned_Organization__c = rec.Minority_Owned_Organization_New__c;
                                acc2.Category_Survey_Email_Address__c = rec.Category_Survey_Email_Address_New__c;
                            }
                        }

                        // Billing information
                        if(rec.Billing_City_New__c != NULL || rec.Billing_City__c != NULL){
                            acc2.BillingCity = rec.Billing_City_New__c;
                        }
                        if(rec.Billing_Country_New__c != NULL || rec.Billing_Country__c != NULL){
                            acc2.BillingCountry = rec.Billing_Country_New__c;
                        }
                        if(rec.BillingPostalCode_New__c != NULL || rec.BillingPostalCode__c != NULL){
                            acc2.BillingPostalCode = rec.BillingPostalCode_New__c;
                        }
                        if(rec.BillingState_New__c != NULL || rec.BillingState__c != NULL){
                            acc2.BillingState = rec.BillingState_New__c;
                        }
                        if(rec.BillingStreet_New__c != NULL || rec.BillingStreet__c != NULL){
                            acc2.BillingStreet = rec.BillingStreet_New__c;
                        }
                        if(rec.Business_Unit_New__c != NULL || rec.Business_Unit__c != NULL){
                            acc2.Billing_Unit__c = rec.Business_Unit_New__c;
                        }
                        if(rec.Principle_Office_International_Address_N__c != NULL || rec.Principle_Office_International_Address__c != NULL){
                            acc2.Principle_Office_International_Address__c = rec.Principle_Office_International_Address_N__c;
                        }
                    

                        // Mailing Information
                        if(rec.ShippingCity_New__c != NULL || rec.ShippingCity__c != NULL){
                            acc2.ShippingCity = rec.ShippingCity_New__c;
                        }
                        if(rec.Shipping_Country_New__c != NULL || rec.Shipping_Country__c != NULL){
                            acc2.ShippingCountry = rec.Shipping_Country_New__c;
                        }
                        if(rec.ShippingPostalCode_New__c != NULL || rec.ShippingPostalCode__c != NULL){
                            acc2.ShippingPostalCode = rec.ShippingPostalCode_New__c;
                        }
                        if(rec.ShippingState_New__c != NULL || rec.ShippingState__c != NULL){
                            acc2.ShippingState = rec.ShippingState_New__c;
                        }
                        if(rec.ShippingStreet_New__c != NULL || rec.ShippingStreet__c != NULL){
                            acc2.ShippingStreet = rec.ShippingStreet_New__c;
                        }
                        if(rec.Mailing_Unit_New__c != NULL || rec.Mailing_Unit__c != NULL){
                            acc2.Shipping_Unit__c = rec.Mailing_Unit_New__c;
                        }
                        if(rec.Mailing_International_Address_New__c != NULL || rec.Mailing_International_Address__c != NULL){
                            acc2.Mailing_International_Address__c = rec.Mailing_International_Address_New__c;
                        }


                        //Office Jurisdiction Information
                        if(rec.Office_Jurisdiction_BusinessZipCode_New__c != NULL || rec.Office_Jurisdiction_BusinessZipCode__c != NULL){
                            acc2.Office_Jurisdiction_BusinessZipCode__c = rec.Office_Jurisdiction_BusinessZipCode_New__c;
                        }
                        if(rec.Office_Jurisdiction_BusinessStreet_New__c != NULL || rec.Office_Jurisdiction_BusinessStreet__c != NULL){
                            acc2.Office_Jurisdiction_BusinessStreet__c = rec.Office_Jurisdiction_BusinessStreet_New__c;
                        }
                        if(rec.Office_Jurisdiction_BusinessState_New__c != NULL || rec.Office_Jurisdiction_BusinessState__c != NULL){
                            acc2.Office_Jurisdiction_BusinessState__c = rec.Office_Jurisdiction_BusinessState_New__c;
                        }
                        if(rec.Office_Jurisdiction_BusinessCity_New__c != NULL || rec.Office_Jurisdiction_BusinessCity__c != NULL){
                            acc2.Office_Jurisdiction_BusinessCity__c = rec.Office_Jurisdiction_BusinessCity_New__c;
                        }
                        if(rec.Office_Jurisdiction_Country_New__c != NULL || rec.Office_Jurisdiction_Country__c != NULL){
                            acc2.Office_in_Jurisdiction_Country__c = rec.Office_Jurisdiction_Country_New__c;
                        }
                        if(rec.Office_Jurisdiction_BusinessUnit_New__c != NULL || rec.Office_Jurisdiction_BusinessUnit__c != NULL){
                            acc2.Office_Jurisdiction_BusinessUnit__c = rec.Office_Jurisdiction_BusinessUnit_New__c;
                        }
                        if(rec.Jurisdiction_International_address_New__c != NULL || rec.Jurisdiction_International_address__c != NULL){
                            acc2.Jurisdiction_International_address__c = rec.Jurisdiction_International_address_New__c;
                        }

                        //Mailing jurisdiction Information
                        if(rec.Mailing_Jurisdiction_BusinessZipCode_New__c != NULL || rec.Mailing_Jurisdiction_BusinessZipCode__c != NULL){
                            acc2.Mailing_Jurisdiction_BusinessZipCode__c = rec.Mailing_Jurisdiction_BusinessZipCode_New__c;
                        }
                        if(rec.Mailing_Jurisdiction_BusinessStreet_New__c != NULL || rec.Mailing_Jurisdiction_BusinessStreet__c != NULL){
                            acc2.Mailing_Jurisdiction_BusinessStreet__c = rec.Mailing_Jurisdiction_BusinessStreet_New__c;
                        }
                        if(rec.Mailing_Jurisdiction_BusinessState_New__c != NULL || rec.Mailing_Jurisdiction_BusinessState__c != NULL){
                            acc2.Mailing_Jurisdiction_BusinessState__c = rec.Mailing_Jurisdiction_BusinessState_New__c;
                        }
                        if(rec.Mailing_Jurisdiction_BusinessCity_New__c != NULL || rec.Mailing_Jurisdiction_BusinessCity__c != NULL){
                            acc2.Mailing_Jurisdiction_BusinessCity__c = rec.Mailing_Jurisdiction_BusinessCity_New__c;
                        }
                        if(rec.Mail_JurisdictionInternationaladdress_N__c != NULL || rec.Mail_Jurisdiction_International_address__c != NULL){
                            acc2.Mail_Jurisdiction_International_address__c = rec.Mail_JurisdictionInternationaladdress_N__c;
                        }
                        if(rec.Mailing_Jurisdiction_BusinessUnit_New__c != NULL || rec.Mailing_Jurisdiction_BusinessUnit__c != NULL){
                            acc2.Mailing_Jurisdiction_BusinessUnit__c = rec.Mailing_Jurisdiction_BusinessUnit_New__c;
                        }
                        if(rec.Mailing_Jurisdiction_Country_New__c != NULL || rec.Mailing_Jurisdiction_Country__c != NULL){
                            acc2.Mailing_Jurisdiction_Country__c = rec.Mailing_Jurisdiction_Country_New__c;
                        }
                        eliminateDuplicateAccountId.add(acc2.Id);
                        accLst.add(acc2);
                    }
                        
                   }
               }
           }
           
        }
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(deletePrincipal, 'delete');
            Boolean accessCheck1 = BRS_SecurityUtility.checkDMLAccess(insertPrincipal, 'upsert');
            Boolean accessCheck2 = BRS_SecurityUtility.checkDMLAccess(accLst, 'update');
            Boolean accessCheck3 = BRS_SecurityUtility.checkDMLAccess(upsertAgent, 'upsert');
            Boolean accessCheck4 = BRS_SecurityUtility.checkDMLAccess(deleteAgent, 'delete');
           if (!deletePrincipal.IsEmpty() && Schema.SObjectType.Principal__c.isAccessible()) {
               delete deletePrincipal;
           }
           if (!insertPrincipal.IsEmpty() && Schema.SObjectType.Principal__c.isAccessible()) {
               upsert insertPrincipal;
           }
           if (!accLst.IsEmpty() && Schema.SObjectType.Account.isAccessible()) {
               update accLst;
           }
           if (!upsertAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible()) {
               upsert upsertAgent;
           }
           if (!deleteAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible()) {
               delete deleteAgent;
           }
       } catch (Exception e) {
           Database.rollback(sp);
           BOS_Utility.ExceptionHandler(className, 'BusinessMaintenance', 'Principal__c', null, BOS_Utility.sSeverity, e, null);
       }
    }


    public class maintenanceFilingUpdateWrapper{
        @AuraEnabled public String busFilingId {get;set;}
        @AuraEnabled public String tarObj {get;set;}
        @AuraEnabled public String statusValue {get;set;}
        @AuraEnabled public String filingType {get;set;}
        @AuraEnabled public String busId {get;set;}
    }
}