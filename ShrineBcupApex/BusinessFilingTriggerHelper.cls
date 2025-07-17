public without sharing class BusinessFilingTriggerHelper {
    public static final String SEMI_COLON = ';';
    public static final String sActive = System.Label.ACTIVE;
    public static Final String className = 'BusinessFilingTriggerHelper';
    
    public static final String NEW_BUSINESS_RECORDTYPE = System.Label.New_Business_Label;
    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Added fix based on the BRS-3070 Clarification.
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-04-21
    * Change(s)/Modification(s) Made by : Avinash Shukla
    */
    public static void processBusinessFilingUpdateOnAccount(Map<Id, SObject> newItems, Map<Id,SObject> oldItems, Boolean IsInsert) {
        List<Account> accLst = new List<Account>();
        Set<Id> accountIdToProcess = new Set<Id>();
        Set<Id> accountIdsWithOutAnnualOrFirstReportFiling = new Set<Id>();
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3950 FIX
        * Change(s)/Modification(s) Description : Added map to hold information about the related business filing of approved and type Business formation.SELECT  FROM Account
        * Change(s)/Modification(s) Made on : 2021-05-16
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Database.SaveResult[] srList = new List<Database.SaveResult>();
        Map<Id, business_filing__c> accountToBusinessFormationApproved = new Map<Id, business_filing__c>();
        for (sObject sobj : newItems.values()) {
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
            if(businessfiling.business_type__c != 'Statutory Trust')
            {
            if ((businessfiling.Account__c != NULL && businessfiling.Status__c != System.Label.BRS_FilingStatus_Rejected && businessfiling.Status__c == System.Label.Approved) && (businessfiling.Type__c == Label.Annual_Report_Label || businessfiling.Type__c == Label.First_Report_Status)) {
                accountIdToProcess.add(businessfiling.Account__c);
                System.debug('Is Initiated by FIRST OR REPORT');
                System.debug('Business Filing : ' + sobj.Id);
            }
            else if (businessfiling.Account__c != NULL) {
                if (businessfiling.Status__c == System.Label.Approved && ( businessfiling.Type__c == System.label.Business_Formation_Label || businessfiling.Type__c == System.Label.Business_Registration_Label)) {
                    if (!IsInsert && oldItems.containsKey(sobj.Id)) {
                        /**
                        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Making changes for BRS-4397/BRS-433
                        * Change(s)/Modification(s) Description : Making sure that annual report due date is updated if a new business of annual or first report is inserted or edeited. If business is newly created then on update when approved we updated the annual report due date to some future value based on date of registration.
                        * Change(s)/Modification(s) Made on : 2021-05-20
                        * Change(s)/Modification(s) Made by : Avinash Shukla
                        */
                        Business_Filing__c oldbusinessfiling = (Business_Filing__c)oldItems.get(sobj.Id);
                        if (oldbusinessfiling.Status__c != System.Label.Approved) {
                            accountIdsWithOutAnnualOrFirstReportFiling.add(businessfiling.Account__c);
                        }
                    }
                }
            }
        }
        }
        if (!accountIdToProcess.isEmpty() || !accountIdsWithOutAnnualOrFirstReportFiling.isEmpty()) {
            Set<String> bfTypeFirstOrAnnual = new Set<String> {'Annual Report', 'First Report'};
            Map<Id, Account> acMap = new Map<Id, Account>([Select Id, Date_of_Formation__c, Date_Registration__c, Business_Type__c,Citizenship__c, (Select Id, Due_Date__c, Type__c, Filing_Date__c, Status__c from Business_Filings__r WHERE Type__c IN : bfTypeFirstOrAnnual AND Status__c != 'Rejected' AND Due_Date__c != NULL AND Is_Rejected_Instantiated__c = FALSE Order By Due_Date__c ASC) from Account WHERE Id IN : accountIdToProcess OR ID IN: accountIdsWithOutAnnualOrFirstReportFiling With SECURITY_ENFORCED]);
            for (Account acc : acMap.values()) {
                Account acc2 = new Account(Id = acc.Id);
                Boolean isModified = false;
                if (accountIdToProcess.contains(acc.Id)) {
                    if (!acc.Business_Filings__r.isEmpty()) {
                        Date latestFiled;
                        Date OldesDueDate;
                        Boolean hasApprovedFilingRecord = false;
                        Date frFilingDate;
                        Date ArDueDate;
                        Boolean latestApprovedIsFr = false;
                        Boolean latestApprovedIsAr = false;
                        Boolean hasDueFilingRecord = false;
                        for (Business_filing__c bfObj1 : acc.Business_Filings__r) {
                            if (bfObj1.Status__c == 'Approved') {
                                hasApprovedFilingRecord = true;
                                if (bfObj1.Type__c == Label.First_Report) {
                                    hasDueFilingRecord = true;
                                    latestApprovedIsFr = true;
                                    latestApprovedIsAr = false;
                                    if (bfObj1.Filing_Date__c!= NULL) {
                                        frFilingDate = bfObj1.Filing_Date__c;
                                    }
                                } else if (bfObj1.Type__c == Label.Annual_Report) {
                                    hasDueFilingRecord = true;
                                    latestApprovedIsFr = false;
                                    latestApprovedIsAr = true;
                                    if (bfObj1.Due_date__c != NULL) {
                                        ArDueDate = bfObj1.Due_date__c;
                                    }
                                }
                                if (bfObj1.Filing_Date__c != NULL) {
                                    if (latestFiled != NULL) {
                                        if (latestFiled < bfObj1.Filing_Date__c) {
                                            latestFiled = bfObj1.Filing_Date__c;
                                        }
                                    } else {
                                        latestFiled = bfObj1.Filing_Date__c;
                                    }
                                }
                            } else {
                                if (OldesDueDate != NULL) {
                                    if (OldesDueDate > bfObj1.Due_Date__c) {
                                        OldesDueDate = bfObj1.Due_Date__c;
                                    }
                                } else {
                                    OldesDueDate = bfObj1.Due_Date__c;
                                }
                            }
                        }
                        if (latestFiled != NULL) {
                            acc2.Latest_Report__c = datetime.newinstance(latestFiled.year(), latestFiled.month(), latestFiled.day());
                            isModified = true;
                        }
                        if (OldesDueDate != NULL) {
                            acc2.Annual_Report_Due_Date__c = OldesDueDate;
                            isModified = true;
                        }
                        if (hasDueFilingRecord && hasApprovedFilingRecord) {
                            if (latestApprovedIsAr && ArDueDate != NULL) {
                                if (acc.Business_Type__c == Label.LLC) {
                                    acc2.Annual_Report_Due_Date__c = date.newinstance(ArDueDate.year() + Integer.valueOf(System.Label.LLC_Add_Year) , Integer.valueOf(System.Label.LLC_Month), Integer.valueOf(System.Label.LLC_Date));
                                    isModified = true;
                                } else {
                                    acc2.Annual_Report_Due_Date__c = date.newinstance(ArDueDate.year() + Integer.valueOf(System.Label.Next_AR_Due_Year_After_AR_Filed), ArDueDate.month(), ArDueDate.day());
                                    isModified = true;
                                }
                            } else if (latestApprovedIsFr) {
                                if (frFilingDate != NULL) {
                                    acc2.Annual_Report_Due_Date__c = date.newinstance(frFilingDate.year() + Integer.valueOf(System.Label.Next_AR_Due_Year_After_FR_Filed), frFilingDate.month(), frFilingDate.day());
                                    isModified = true;
                                }
                            }
                        }
                    }
                } else if (accountIdsWithOutAnnualOrFirstReportFiling.contains(acc.id)) {
                    /**
                    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4397 Changes
                    * Change(s)/Modification(s) Description : This is to implement annual report due date(future) but since in one self approved flow we do not have the date of registration, we consider in that case todays date as the date of registration is the day business is formed.
                    * Change(s)/Modification(s) Made on : 2021-05-20
                    * Change(s)/Modification(s) Made by : Avinash Shukla
                    */
                    if (acc.Date_Registration__c != NULL) {
                        if (acc.Business_Type__c == Label.LLC) {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(acc.Date_Registration__c.year() + Integer.valueOf(System.Label.LLC_Add_Year) , Integer.valueOf(System.Label.LLC_Month), Integer.valueOf(System.Label.LLC_Date));
                            isModified = true;
                        } else {
                            if(acc.Citizenship__c == 'Domestic' && (acc.Business_Type__c == 'Stock' || acc.Business_Type__c == 'Non-Stock' || acc.Business_Type__c == 'B corp'))
                            {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(acc.Date_Registration__c.year(), acc.Date_Registration__c.month(), acc.Date_Registration__c.day()+90);
                            isModified = true;
                            }
                            else
                            {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(acc.Date_Registration__c.year() + Integer.valueOf(System.Label.Next_AR_Due_Year_FIRST_AR), acc.Date_Registration__c.month(), acc.Date_Registration__c.day());
                            isModified = true;
                            }
                        }
                    } else{
                        if (acc.Business_Type__c == Label.LLC) {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + Integer.valueOf(System.Label.LLC_Add_Year) , Integer.valueOf(System.Label.LLC_Month), Integer.valueOf(System.Label.LLC_Date));
                            isModified = true;
                        } else {
                            if(acc.Citizenship__c == 'Domestic' && (acc.Business_Type__c == 'Stock' || acc.Business_Type__c == 'Non-Stock' || acc.Business_Type__c == 'B corp'))
                            {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year(), Date.Today().month(), Date.Today().day()+90);
                            isModified = true;
                            }
                            else
                            {
                            acc2.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + Integer.valueOf(System.Label.Next_AR_Due_Year_FIRST_AR), Date.Today().month(), Date.Today().day());
                            isModified = true;
                            }
                        }
                    }
                }
                if (isModified) {
                    // Updating acc2.Annual_Report_Due_Date__c date same as Annual_Report_Due_Date__c.
                    // This is done as a part of 4952. For annual report notification.
                    if (acc2.Annual_Report_Due_Date__c!= NULL) {
                        acc2.Annual_report_past_due_date__c = date.newinstance(acc2.Annual_Report_Due_Date__c.year(), acc2.Annual_Report_Due_Date__c.month(), acc2.Annual_Report_Due_Date__c.day());
                    }
                    accLst.add(acc2);
                }
            }
        }
        try {
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(accLst, 'update');
            if (!accLst.IsEmpty() && Schema.SObjectType.Account.isAccessible() && bAccessCheck) {
                srList = database.update(accLst,false);
            }
            BOS_Utility.ExceptionHandlerForBatches(className,'Business_Filing__c',BOS_Utility.sSeverity,srList,accLst);
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'processBusinessFilingUpdateOnAccount', 'Account', null, BOS_Utility.sSeverity, e, null);
        }
    }

    /*
    ********************************************************************************************
     * NAME:  processMaintenanceFilings
     * DESCRIPTION: Method to update account/principal/agent on business filing once approved
     *
     * @AUTHOR: Rahul Sharma
     * @DATE: 03/24/2021
     *
     *
     * MODIFICATION LOG:
     * DEVELOPER                         DATE                               DESCRIPTION
     * _____________________________________________________________________________________________
     * Rahul Sharma                     03/24/2021                        Created the first version
     *
    ************************************************************************************************
    */
    public static void processMaintenanceFilings(Map<Id, SObject> newItems,Map<Id, SObject> oldItems) {
        Map<Id, Boolean> approveARsFrs = new Map<Id, Boolean>();
        set<String> busFileIds = new set<String>();
        List<Account> accLst = new List<Account>();
        List<Agent__c> insertAgent = new List<Agent__c>();
        List<Agent__c> deleteAgent = new List<Agent__c>();
        List<Temp_History__c> TempRecs = new List<Temp_History__c>();
        Map<String,Map<Id,Id>> acIds = new Map<String,Map<Id,Id>>();
        for(sObject sobj : newItems.values()) {
            if ((sobj.get('Type__c') == System.Label.First_Report || sobj.get('Type__c') == System.Label.Annual_Report) && sobj.get('Status__c') == System.Label.Approved && oldItems.get(sobj.Id).get('Status__c') != System.Label.Approved) {
                approveARsFrs.put(sobj.Id, (Boolean) sobj.get('isAutoApproved__c'));
            }
             Business_Filing__c oldFiling = (Business_Filing__c)oldItems.get(sobj.Id);
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
            if (businessfiling.Status__c == system.label.BRS_FilingStatus_Approved && oldFiling.Status__c !=system.label.BRS_FilingStatus_Approved  && (businessfiling.Type__c == system.label.brs_AgentChange_FilingType || ( businessfiling.Type__c == system.label.brs_name_change_amendment_flow && oldFiling.Status__c==System.label.brs_uccFilingStatus)))
            {
                busFileIds.add(sobj.Id);
            }
        }
        if (!busFileIds.IsEmpty())
        {
            String queryString = 'Select id, Name, Title__c, Designation__c, Agent__c,NAICS_Code_New__c,Business_Name_New__c,';
            queryString+='Business_Email_Address__c, Principal__c, Type__c, Temp_Type__c, Phone__c, Business_Name__c,Business_Name_in_state_country__c,Business_Name_in_state_country_New__c,';
            queryString+='Business_ID__c, Business_ID__r.AccountNumber, Account__c,Account__r.AccountNumber,Account__r.Citizenship__c, FirstName__c,';
            queryString+='LastName__c, Name__c, Email__c, Business_Filing__c,Business_Filing__r.Type__c, Business_InternationalAddress__c,';
            queryString+='Residence_InternationalAddress__c, Created_From_Agent__c,Business_City__c, Business_Country__c, Business_State__c,';
            queryString+='Business_Street_Address_1__c, Business_Street_Address_2__c, Business_Street_Address_3__c, Business_Zip_Code__c,';
            queryString+='Mailing_City__c, Change_Type__c, Mailing_Country__c, Mailing_State__c, Mailing_Street_Address_1__c, Mailing_Zip_Code__c,';
            queryString+='Mailing_Street_Address_2__c, Mailing_Street_Address_3__c,Principal_Title__c, Residence_State__c, Residence_City__c,';
            queryString+='Residence_Street_Address_1__c, Residence_Street_Address_2__c, Residence_Street_Address_3__c, Residence_Zip_Code__c,';
            queryString+='Residence_Country__c from Temp_History__c';

            String whereClause = ' where Business_Filing__c in: busFileIds WITH SECURITY_ENFORCED' ;
            queryString = queryString + whereClause;
            TempRecs = Database.query(queryString);
            if (!TempRecs.IsEmpty()) {
                for(Temp_History__c rec : TempRecs)
                {
                    Agent__c ag = new Agent__c();
                    if (rec.Business_Filing__r.Type__c == system.label.brs_AgentChange_FilingType)
                    {
                        if (rec.Change_Type__c == system.label.brs_maintenance_tempCreated)
                        {
                            ag.Agent_Phone__c = rec.Phone__c;
                            ag.Type__c = rec.temp_type__c; // Fix BRS-4378
                            ag.FirstName__c = rec.FirstName__c;
                            ag.LastName__c = rec.LastName__c;
                            ag.Name__c = rec.Name__c;
                            ag.Email__c = rec.Email__c;
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
                            ag.Agent_Account_ID__c = rec.temp_type__c== System.label.Business_Comparable?rec.Account__c:null;
                            ag.Business_ID__c = rec.Business_Id__c;
                            insertAgent.add(ag);
                        }
                        else if (rec.Change_Type__c == system.label.Deleted && rec.Agent__c != null && rec.Business_Filing__r.Type__c == system.label.brs_AgentChange_FilingType) {
                            ag.Id = rec.Agent__c;
                            deleteAgent.add(ag);
                        }
                    }
                    else if (rec.Business_Filing__r.Type__c == system.label.brs_name_change_amendment_flow && rec.Type__c == system.label.Account && rec.Account__c != null)
                    {
                        Account acc2 = new Account(Id=rec.Account__c);
                        acc2.Name = rec.Business_Name_New__c;
                        if (!String.isBlank(rec.Business_Name_in_state_country_New__c)) {
                        acc2.Business_Name_in_state_country__c = rec.Business_Name_in_state_country_New__c;
                        }  
                        accLst.add(acc2);
                    }
                }
            }
        }
        
        try {
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(accLst, 'update');
            if (!accLst.IsEmpty() && Schema.SObjectType.Account.isAccessible() && bAccessCheck) {
                update accLst;
            }
            Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(insertAgent, 'insert');
            if (!insertAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible() && bAccessCheck1) {
                insert insertAgent;
            }
            Boolean bAccessCheck2 = BRS_SecurityUtility.checkDMLAccess(deleteAgent, 'delete');
            if (!deleteAgent.IsEmpty() && Schema.SObjectType.Agent__c.isAccessible() && bAccessCheck2) {
                delete deleteAgent;
            }
            //Calling AR & FR automation future method.
            if (!approveARsFrs.isEmpty()) {
               brs_UpdateAccountFromFilingUtlity.updateAccountFromFilingfromTrigger(approveARsFrs);
            }
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'BusinessMaintenance', 'Agent__c', null, BOS_Utility.sSeverity, e, null);
        }
    }
    
    /**********************************************************************************************
    METHOD NAME    : checkPaymentVerification
    DESCRIPTION    : Method to restrict user from Approving Fling before checking the 'Verify Payments' checkbox on workorder.
    PARAMETER      : List<SObject> newBusinessFilings, Map<Id, SObject> oldFilingMap
    ***********************************************************************************************/    
    public static void checkPaymentVerification(List<SObject> newBusinessFilings, Map<Id, SObject> oldFilingMap) {
        try{
            Set<Id> workOrderIds = new Set<Id>();
            for(SObject sobj: newBusinessFilings) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                if(businessfiling.Status__c == System.Label.BRS_FilingStatus_Approved){                   
                    workOrderIds.add(businessfiling.Work_Order__c);
                }
            }
            if(!workOrderIds.isEmpty()){
                Map<Id,Work_Order__c> workOrderMap= new Map<Id,Work_Order__c>([select Id, Payments_Verified__c, Customer__c, Customer__r.Allow_negative_balances__c from Work_Order__c where Id IN :workOrderIds With SECURITY_ENFORCED]);
                Boolean statusChanged = false;
                for(SObject sobj: newBusinessFilings) {
                    Business_Filing__c newFiling = (Business_Filing__c)sobj;
                    if (oldFilingMap!=null) {
                        Business_Filing__c oldFiling = (Business_Filing__c)oldFilingMap.get(newFiling.Id);
                        if (newFiling.Status__c!=oldFiling.Status__c) {
                            statusChanged=true;
                        }
                    }
                    
                    if ((newFiling.Status__c==System.Label.BRS_FilingStatus_Approved) && ((oldFilingMap!=null && statusChanged==true) || oldFilingMap==null)) {
                        if (workOrderMap.keySet().contains(newFiling.Work_Order__c)) {
                            Work_Order__c workorder = workOrderMap.get(newFiling.Work_Order__c);
                            if (workorder.Payments_Verified__c==false && workorder.Customer__r.Allow_negative_balances__c==false && newFiling.Source__c!=System.Label.brs_FilingOnline && newFiling.Source__c!=System.Label.brs_FilingAPI &&newFiling.Source__c != 'Digital Mail') {
                                newFiling.addError(System.Label.PaymentVerificationCheckErrorMessage);
                            }
                        }
                    }
                }
            }
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'checkPaymentVerification', 'Work_Order__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }
    }
    public static void updateFilingTypeAndFee(List<SObject> allnewItems ,Map<ID,SObject> oldItems) {
      
        List<SObject> newItems =new List<SObject>();
        List<Business_Filing__c> domesticMergerConversionItems =new List<Business_Filing__c>();
        try{
        for(sObject sobj : allnewItems) {
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
if (businessfiling.Type__c == 'Domestication' || businessfiling.Type__c == 'Conversion' || businessfiling.Type__c == 'Merger') {
    domesticMergerConversionItems.add(businessfiling);
} else {
    newItems.add(sobj);
}

        }
if (!domesticMergerConversionItems.isEmpty()) {
    updateFeeforMergerConversionandDoemstication(domesticMergerConversionItems, oldItems);
}
       if (newItems!=null && !newItems.isEmpty()) {
      
      
        List<String> lstType = new List<String>();
        Map<String, Decimal> mapKeyToAmount = new Map<String, Decimal>();
        Map<String, String> mapKeyToFiling = new Map<String, String>();
Decimal expiditionFee;
        List<Franchise_Tax__mdt> mdtlst=[SELECT Id,label,Max_Value__c,Min_Value__c,Multiply_Value__c FROM Franchise_Tax__mdt where Type__c ='BFR' order by label];
        for(SObject obj : newItems) {
            Business_Filing__c businessfiling = (Business_Filing__c)obj;
            if (businessfiling.Type__c != null && !String.isBlank(businessfiling.Type__c)) {
                lstType.add(businessfiling.Type__c);
            }   
 if (businessfiling.Type__c != null && !String.isBlank(businessfiling.Type__c) && businessfiling.Type__c == 'Name Change Amendment') {
            businessfiling.Amendment_Type__c ='Amend Name';
            }              
        }

        if (!lstType.isEmpty()&& Schema.SObjectType.Master_Fee__c.isAccessible()) {
            Date processingDate = System.today();
             List<Master_Fee__c> allMasterFee = [SELECT Id,Business_Type__c,Service_Type__c,Filing_Type__c,Citizenship__c,Amount__c,Type__c,Sub_type__c 
                                                FROM Master_Fee__c 
                                                WHERE (Type__c IN :lstType  AND
                                                Status__c = :sActive AND
                                                Start_Date__c <= :processingDate AND
                                                (End_Date__c = null OR
                                                 End_Date__c >= :processingDate)) OR 
                                                 Service_Type__c = :System.Label.FilingExpediteFee.trim()
                                                WITH SECURITY_ENFORCED];
            
            if (!allMasterFee.isEmpty()) {
                for(Master_Fee__c mf : allMasterFee) {
                    String key = (mf.Type__c != null ? mf.Type__c : '') + SEMI_COLON + (mf.Citizenship__c != null ? mf.Citizenship__c : '') + SEMI_COLON + (mf.Business_Type__c != null ? mf.Business_Type__c : '') + SEMI_COLON + (mf.Sub_type__c != null ? mf.Sub_type__c : '');
                    mapKeyToAmount.put(key, mf.Amount__c);
                    mapKeyToFiling.put(key, mf.Filing_Type__c);
                     if (String.isNotBlank(mf.Service_Type__c)) {
                        expiditionFee = mf.Amount__c;
                    }
                }

                for(sObject sobj : newItems) {
                    Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                     Business_Filing__c oldbusinessfiling ;
                    
                    
                    if (oldItems!=null) {
                        oldbusinessfiling =(Business_Filing__c) oldItems.get(businessfiling.Id);
                    }
                    
                    String searchKey = (businessfiling.Type__c != null ? businessfiling.Type__c : '') + SEMI_COLON + (businessfiling.Citizenship__c != null ? businessfiling.Citizenship__c : '') + SEMI_COLON + (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '')  + SEMI_COLON + (businessfiling.Sub_type__c != null ? businessfiling.Sub_type__c: '');
                    Decimal filingFee = mapKeyToAmount.get(searchKey);
                    if(filingFee == null && businessfiling.Type__c != 'Administrative Dissolution'){
                        filingFee=0;
                    }
                    String filingType = mapKeyToFiling.get(searchKey);
                    if (filingFee != null) {

                        
                    if ((businessfiling.Type__c=='Business Formation' || businessfiling.Type__c=='Business Registration') && businessfiling.Citizenship__c == 'Domestic'  && businessfiling.Source__c!=System.label.Online_Label && (businessfiling.Business_Type__c == 'Stock'
                    ||businessfiling.Business_Type__c == 'B Corp'
                    ||businessfiling.Business_Type__c == 'Cooperative Association'
                    ||businessfiling.Business_Type__c == 'Bank Stock'
                    ||businessfiling.Business_Type__c == 'Credit Union Stock'
                    ||businessfiling.Business_Type__c == 'Insurance Stock'
                    )) {
                       if (businessfiling.Total_Authorized_Shares__c == null || businessfiling.Total_Authorized_Shares__c == 0) {
                           businessfiling.addError(System.Label.NewShareError);
                       } else {
                        businessfiling.Franchise_Tax__c =updateTotalShareBRSFee(businessfiling, oldItems, mdtlst);
                       }
                    }
                    businessfiling.Filing_Fee__c = (filingFee != null) ? filingFee : 0;
                    if(businessfiling.Due_Year__c<=System.Label.Annual_Report_Year && businessfiling.type__c == System.Label.Annual_Report && businessfiling.Business_Type__c==System.Label.Business_Type_LLC){
                        if(businessfiling.Filing_Date__c!=null){
                            if(businessfiling.Filing_Date__c<=date.newinstance(2021, 7,13)){
                                businessfiling.Filing_Fee__c = (filingFee != null) ? filingFee : 0; 
                            }else{
                                businessfiling.Filing_Fee__c  = Decimal.valueOf(System.Label.Filing_Fee_for_Annual_Prior_to_2020) ;
                            }
                        }
                        else if(businessfiling.status__c == System.Label.BRS_UCC_StatusInProgress || businessfiling.status__c ==System.Label.Due_Label_Comparable || businessfiling.status__c ==System.Label.PastDue){
                            businessfiling.Filing_Fee__c  = Decimal.valueOf(System.Label.Filing_Fee_for_Annual_Prior_to_2020) ;
                            
                        }
                    }
                    businessfiling.Filing_Type__c = (filingType != null && !String.isBlank(filingType) && businessfiling.Filing_Type__c==null) ? filingType :businessfiling.Filing_Type__c!=null?businessfiling.Filing_Type__c:'';
                    businessfiling.Franchise_Tax__c = businessfiling.Franchise_Tax__c!=null?businessfiling.Franchise_Tax__c:0;
                    businessfiling.Total_Fee__c= businessfiling.Filing_Fee__c+businessfiling.Franchise_Tax__c;
              
                    }
                    if (oldbusinessfiling == null && businessfiling.Include_Expedited_Service__c == true) {
                    businessfiling.Total_Fee__c = businessfiling.Total_Fee__c + expiditionFee; 
                   
                    businessFiling.Expedited_Service_Fee__c = expiditionFee;
                }
             else if (oldItems != null && oldbusinessfiling != null &&  businessfiling.Include_Expedited_Service__c == true
                  && oldbusinessfiling.Include_Expedited_Service__c == false) {
                   
                    businessfiling.Total_Fee__c = businessfiling.Total_Fee__c!=null? businessfiling.Total_Fee__c + expiditionFee : expiditionFee; 
                    businessFiling.Expedited_Service_Fee__c = expiditionFee;
                  }
                      else if (oldItems != null && oldbusinessfiling != null &&  businessfiling.Include_Expedited_Service__c == true
                      && oldbusinessfiling.Include_Expedited_Service__c == true) {
                       
                        businessfiling.Total_Fee__c = businessfiling.Total_Fee__c + expiditionFee; 
                        businessFiling.Expedited_Service_Fee__c = expiditionFee;
                      }
                      else if (oldItems != null && oldbusinessfiling != null && businessfiling.Include_Expedited_Service__c == false
                  && oldbusinessfiling.Include_Expedited_Service__c == true) {
                    businessFiling.Expedited_Service_Fee__c =0;
                  }
                  
                    
                    
                    
                }
            }
        }
    }
    }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateFilingTypeAndFee', 'Business_Filing__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }
}
         /*
    ********************************************************************************************
    * NAME:  updateTotalShare
    * DESCRIPTION: update Total New Share on business filing 
    *
    * @AUTHOR: Satakshi Chaudhary
    * @DATE: 04/01/2021
    *
    *
    * MODIFICATION LOG:
    * DEVELOPER                         DATE                               DESCRIPTION
    * _____________________________________________________________________________________________
    * Satakshi Chaudhary                    04/05/2021                        Created the first version
    *
    ************************************************************************************************
    */
     public static void updateTotalShare(List<SObject> newFilingList, Map<Id, SObject> oldMap) {
        try{
            Decimal taxdiff;
Boolean iscalculateFurther=true;
            Decimal totaltax=0.0;
            List<Franchise_Tax__mdt> mdtlst=[SELECT Id,label,Max_Value__c,Min_Value__c,Multiply_Value__c FROM Franchise_Tax__mdt where Type__c ='Amd' order by label];
  
            for(SObject filing:newFilingList) {           
                Business_Filing__c newFiling = (Business_Filing__c)filing;
                if ( newFiling.Type__c=='Merger' || (newFiling.Type__c!='Business Formation' && newFiling.Type__c!='Business Registration' && (newFiling.Business_Type__c=='B Corp' || newFiling.Business_Type__c=='Stock' || newFiling.Business_Type__c == 'Bank Stock' || newFiling.Business_Type__c == 'Credit Union Stock' || newFiling.Business_Type__c == 'Insurance Stock'))) {
                
                   
                    if (newFiling.Total_Authorized_Shares__c > newFiling.Total_Authorized_Shares_on_Account__c) {
                        taxdiff = newFiling.Total_Authorized_Shares__c - newFiling.Total_Authorized_Shares_on_Account__c;
                    }

                    Decimal balance;
                    if (taxdiff != Null && taxdiff >0)
                    {

                 if (newFiling.Total_Authorized_Shares_on_Account__c>= 0 && newFiling.Total_Authorized_Shares__c  <mdtlst[0].Max_Value__c ) {
                 totaltax=calculateTax(totaltax, taxdiff, mdtlst, 1);  
                 iscalculateFurther =false; 
                  }  



                   Decimal band = mdtlst[0].Max_Value__c - newFiling.Total_Authorized_Shares_on_Account__c;
                if (iscalculateFurther ==true) {
                if (band>0 && band <= mdtlst[0].Max_Value__c ) {
              totaltax=calculateTax(totaltax, band, mdtlst, 1);
               }
    
                  else if (band <0) {
                   band =0;
                   }
                balance = taxdiff -band;
               band = (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ) - balance;
                }
                  if (iscalculateFurther ==true) {
                if (band>=0 && band <= mdtlst[1].Max_Value__c) {
if (newFiling.Total_Authorized_Shares__c  <=mdtlst[1].Max_Value__c) {

                  totaltax=calculateTax(totaltax, balance, mdtlst, 2);
                iscalculateFurther =false;
} else if (newFiling.Total_Authorized_Shares__c  >mdtlst[1].Max_Value__c) {
    Decimal newBand = mdtlst[1].Max_Value__c -newFiling.Total_Authorized_Shares_on_Account__c;
    if(newBand >=0)
    {
    totaltax=calculateTax(totaltax, newBand, mdtlst, 2);
    balance = balance-newBand;
    }
}
                  }
   
                   else if (band <0) {
                      Decimal newBand =    (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ) - newFiling.Total_Authorized_Shares_on_Account__c;
                       if (newBand == 0) {
                          totaltax=calculateTax(totaltax, mdtlst[0].Max_Value__c, mdtlst, 2);
                          balance = balance -  mdtlst[0].Max_Value__c ;

                        } else if (newFiling.Total_Authorized_Shares_on_Account__c < mdtlst[1].Max_Value__c) {
if (newFiling.Total_Authorized_Shares_on_Account__c < mdtlst[0].Max_Value__c)
{
                    totaltax=calculateTax(totaltax, (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ), mdtlst, 2);
                     balance = balance -  (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ) ;
} else {

    Decimal newBand1 = mdtlst[1].Max_Value__c -newFiling.Total_Authorized_Shares_on_Account__c;
    totaltax=calculateTax(totaltax, newBand1, mdtlst, 2);
    balance = balance - newBand1 ;
}      
                    
                    }  
}    
}         
if (iscalculateFurther ==true) {
band =  (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c )  - balance;

 if (band>=0 && newFiling.Total_Authorized_Shares__c <= mdtlst[2].Max_Value__c) {
  if (newFiling.Total_Authorized_Shares__c  <=mdtlst[2].Max_Value__c) {

    totaltax=calculateTax(totaltax, balance, mdtlst, 3);
  iscalculateFurther =false;
} else if (newFiling.Total_Authorized_Shares__c  >mdtlst[2].Max_Value__c) {
Decimal newBand = mdtlst[2].Max_Value__c -newFiling.Total_Authorized_Shares_on_Account__c;
totaltax=calculateTax(totaltax, newBand, mdtlst, 3);

balance = balance-newBand;
}


    }
   
    else if (band <0 && band <mdtlst[2].Max_Value__c) {
        Decimal newBand =    (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c ) - newFiling.Total_Authorized_Shares_on_Account__c;
        if (newBand == 0) {
            totaltax=calculateTax(totaltax, mdtlst[1].Max_Value__c, mdtlst, 3);
            balance = balance -  mdtlst[1].Max_Value__c ;
        
        } else if (newFiling.Total_Authorized_Shares_on_Account__c < mdtlst[2].Max_Value__c) {
            if (newFiling.Total_Authorized_Shares_on_Account__c < mdtlst[1].Max_Value__c)
            {
   totaltax=calculateTax(totaltax, (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c ), mdtlst, 3);
   balance = balance - (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c ) ;
    }  else{
        Decimal newBand1 = mdtlst[2].Max_Value__c -newFiling.Total_Authorized_Shares_on_Account__c;
        totaltax=calculateTax(totaltax, newBand1, mdtlst, 3);
        balance = balance - newBand1 ;
    }
}
    }
}
if (iscalculateFurther ==true) {
totaltax=calculateTax(totaltax, balance, mdtlst, 4);
}
     newFiling.Franchise_Tax__c=totaltax;

                     } else {

                        if (oldMap!=null && oldMap.size()>0) {
Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(newFiling.id);

                            newFiling.Franchise_Tax__c=    oldFiling.Franchise_Tax__c;

                        } else {
                        newFiling.Franchise_Tax__c=0;
                        }
                    }

                  
                } else {
                    newFiling.Franchise_Tax__c= newFiling.Account_Franchise_Tax__c;
                }
            
                
            }
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateTotalShare', 'Business_Filing__c',null,'medium',e,null);
        }
    }
@testVisible 
 static   Decimal calculateTax(Decimal newFilingtax,Decimal taxdiff,List<Franchise_Tax__mdt> mdtlst,Integer casevalue) {
    
        if (casevalue ==1) {
            newFilingtax= newFilingtax+(taxdiff *mdtlst[0].Multiply_Value__c);       
        }
        else if (casevalue ==2) {
            newFilingtax= newFilingtax+(taxdiff *mdtlst[1].Multiply_Value__c);  
        }
        else if (casevalue ==3) {
            newFilingtax= newFilingtax+(taxdiff *mdtlst[2].Multiply_Value__c);      
        }
        else if (casevalue ==4) {
            newFilingtax=newFilingtax+ (taxdiff *mdtlst[3].Multiply_Value__c);        
        }
    return newFilingtax;
}
    
    public static void updateCitizenship(List<SObject> newItems,Map<Id, SObject> oldMap) {
       
        Set<Id> accIds=new Set<Id>();
        for(sObject sobj : newItems) {
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
          if ((businessfiling.Source__c==System.label.Online_Label && businessfiling.RecordTypeId!=Wizard_Utlity.getRecordTypeId(System.label.BRS_Name_Reservation,Schema.Business_Filing__c.getSObjectType())) || (businessfiling.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.Maintenance,Schema.Business_Filing__c.getSObjectType()) ||
                businessfiling.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.CloseReinstateLabel,Schema.Business_Filing__c.getSObjectType()))) {
                        if (oldMap!=null && !oldMap.isEmpty()) {
                    Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
                    if (!String.isBlank(businessfiling.Account__c) && businessfiling.Account__c!=null && oldFiling.Account__c!=null && businessfiling.Account__c !=oldFiling.Account__c) {
                        accIds.add(businessfiling.Account__c);
                    }
                }
                else{
                    if (!String.isBlank(businessfiling.Account__c)  && businessfiling.Account__c!=null) {
                        accIds.add(businessfiling.Account__c);
                    }
                }
            }
        }
        if (!accIds.isEmpty()) {
            Map<Id,Account> accMap=new Map<Id,Account>([Select id,Name,Citizenship__c,Business_Type__c from Account where Id IN:accIds With SECURITY_ENFORCED]);
            for(sObject sobj : newItems) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
             if ((businessfiling.Source__c==System.label.Online_Label && businessfiling.RecordTypeId!=Wizard_Utlity.getRecordTypeId(System.label.BRS_Name_Reservation,Schema.Business_Filing__c.getSObjectType())) || (businessfiling.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.Maintenance,Schema.Business_Filing__c.getSObjectType()) ||
                businessfiling.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.CloseReinstateLabel,Schema.Business_Filing__c.getSObjectType()))) {
                                if (oldMap!=null && !oldMap.isEmpty()) {
                        Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
                        if (!String.isBlank(businessfiling.Account__c) && businessfiling.Account__c!=null && oldFiling.Account__c!=null && businessfiling.Account__c !=oldFiling.Account__c) {
                            businessfiling.Citizenship__c = accMap.get(businessfiling.Account__c).Citizenship__c;
                            businessfiling.Business_Type__c = accMap.get(businessfiling.Account__c).Business_Type__c;
                        }
                    }
                    else{
                        if (businessfiling.Account__c!=null) {
                            businessfiling.Citizenship__c = accMap.get(businessfiling.Account__c).Citizenship__c;
                            businessfiling.Business_Type__c = accMap.get(businessfiling.Account__c).Business_Type__c;
                        }
                    }
                }
            }
         }        
    }
        public static void updateAccountPin(List<SObject> newFilingList, Map<Id, SObject> oldMap) {
        List<String> accIdList=new List<String>();
        for(SObject filing:newFilingList) {            
            Business_Filing__c newFiling = (Business_Filing__c)filing;
            if (oldMap!=NULL) {
                Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(filing.Id);
                if (oldFiling.Status__c!=null && newFiling.Status__c !=oldFiling.Status__c && (newFiling.Type__c=='Name Reservation' || newFiling.Type__c=='Registration of Corporate Name' ||  newFiling.Type__c=='Registration of Name') && newFiling.Status__c=='Approved' && newFiling.Account__c!=null) {
                    accIdList.add(newFiling.Account__c);
                }
            } else {
                if (newFiling.Type__c=='Name Reservation' && newFiling.Status__c=='Approved' && newFiling.Account__c!=null) {
                    accIdList.add(newFiling.Account__c);
                }
            }
        }
        if(!accIdList.isEmpty()){
        brs_businessPinGeneration.updateAccountPin(accIdList);
        }
    }    
    
    
    public static void checkOldFilingForFormations(List<SObject> newItems,Map<Id, SObject> oldMap) {
        
        try{
            Set<String> accountIDS = new Set<String>();
            Map<String,Business_Filing__c> filingMap = new Map<String,Business_Filing__c>();
            List<String> types = new List<String>{System.Label.Business_Formation_Label,System.Label.Business_Registration_Label};
            List<String> types2 = new List<String>{System.Label.Domestication_Label,System.label.Merger_Label,System.label.Conversion_Label};
            List<String> btypes = new List<String>();
            List<String> status = new List<String>{System.Label.Rejected};
                for(sObject sobj : newItems) {                   
                    Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                    if (businessfiling.Account__c!=null && (types.contains(businessfiling.Type__c) || types2.contains(businessfiling.Type__c))) {
                    accountIDS.add(businessfiling.Account__c);
                    btypes.add(businessfiling.Type__c);
                    System.debug('businessfiling.Account__c'+businessfiling.Account__c);
                   filingMap.put(businessfiling.Account__c,businessfiling);
                    System.debug('businessfiling'+businessfiling);
                    }
                }
            
            List<Business_Filing__c> filingList = [Select id,Account__c,Business_Type__c,status__c,Type__c from Business_Filing__c where Account__c in :accountIDS and  Type__c in :btypes and status__c NOT IN :status With SECURITY_ENFORCED];
            
            // for(Business_Filing__c sobj : filingList) {    
            //     filingMap.put(sobj.Account__c,sobj);
            //     //Business_filing__c filing =  filingMap.get(sobj.Account__c);
            // }
            for(Business_Filing__c sobj : filingList) {
                Business_Filing__c  businessfiling =filingMap.get(sobj.Account__c);
                if (businessfiling != null && types.contains(businessfiling.Type__c) && (businessfiling.Type__c == System.Label.Business_Formation_Label || businessfiling.Type__c == System.Label.Business_Registration_Label)) {
                    businessfiling.addError(System.Label.BusinessFilingError); 
                }
                else if (businessfiling != null && types2.contains(businessfiling.Type__c) && (businessfiling.Type__c == System.Label.Domestication_Label || businessfiling.Type__c == System.Label.Merger_Label )) {
                    businessfiling.addError(System.Label.BusinessFilingError); 
                }
                else if (sobj.Type__c == System.Label.Conversion_Label && sobj.Status__c !='Approved')
                {
                    System.debug('inside data@@@'+businessfiling.Type__c);
                    System.debug('businessfiling.Status__c'+businessfiling.Status__c);
                    businessfiling.addError(System.Label.BusinessFilingError);
                }
            }
        }catch(Exception e) {
            BOS_Utility.handleException(e);
        }
    }
        public static void updateReservedAccountsForRejectedFilings(List<SObject> newItems,Map<Id, SObject> oldMap) {
        List<Account> reserveAccountList=new List<Account>();
        for(sObject sobj : newItems) {                   
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
            Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
            if (((businessfiling.Type__c==System.Label.brs_name_change_amendment_flow && businessfiling.Citizenship__c == System.label.Foreign) ||
            businessfiling.Type__c==System.label.Business_Formation_Comparable || businessfiling.Type__c==System.label.Business_Registeration_Comparable)
            && businessfiling.Status__c!=oldFiling.Status__c && businessfiling.Status__c==System.Label.BRS_FilingStatus_Rejected  && businessfiling.Reserved_Name__c!=null && businessfiling.Source__c!='Digital Mail') {      
                reserveAccountList.add(new Account(Id=businessfiling.Reserved_Name__c, Reserved_Name_Used__c=false));
            }
        }
       Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(reserveAccountList, 'update'); 
        if(bAccessCheck && reserveAccountList.size() > 0){
       		update reserveAccountList;
        }
    }
    public static void createBusinessFilingRecordType (List<SObject> newItems)
    {
        for(sObject sobj : newItems)
        {
            Business_Filing__c business = (Business_Filing__c)sobj;
            if (business.Type__c == System.Label.First_Report_Label || business.Type__c == System.Label.Annual_Report_Comparable && business.Status__c==System.Label.Due)
            {
                business.RecordTypeId=Wizard_Utlity.getRecordTypeId(System.label.AnnualFirstReportHeader,Schema.Business_Filing__c.getSObjectType());
            }
        }
    }

    public static void createNameHistoryTableRecs(Map<Id, SObject> newItems,Map<Id, SObject> oldMap) {
    Map<Id,Business_filing__c> newBusinessFilings = (Map<Id,Business_filing__c>)newItems;
        Set<Id> busFileIds = new Set<Id>();
        for(String inst : newItems.keyset()) {



            Business_Filing__c newFiling=newBusinessFilings.get(inst);
       
            String filingStatus = String.valueOf(newFiling.get('Status__c'));
            String oldstatus = String.valueOf(oldMap.get(inst).get('Status__c'));
            String type =  String.valueOf(newFiling.get('Type__c'));
            String subtype =  String.valueOf(newFiling.get('Sub_Type__c'));




            if (filingStatus==System.label.Approved && filingStatus!= oldstatus 
            ){

                if(type == System.label.Amendment_label_Comparable || type == System.label.brs_name_change_amendment_flow
                || type == System.label.Merger_Label ||type == System.label.Conversion_Label || type == System.label.Domestication_Label)
                {

                   
                    busFileIds.add(inst);
                   
                }
                else if((type== System.label.RevocationDissolution_Header_Question && subtype == system.label.With_NameChange_Label)||
                (type == System.label.brs_Reinstatement && (subtype == system.label.withAnnual_NameChange || subtype == system.label.FirstReport_NameChange_Label)))
                {
            busFileIds.add(inst);
                }
        }
        }
        if (!busFileIds.isEmpty()) {
        List<Name_Change_History__c> historyList = new List<Name_Change_History__c>();
        
        List<Temp_History__c> tempHistoryList = new List<Temp_History__c>([Select id,Account__c,business_filing__r.Effective_Date__c,business_filing__r.Filing_Date__c,Business_Name_in_state_country_New__c,Business_Name_in_state_country__c,business_filing__c,Business_Name__c,Business_Name_New__c,Change_Type__c,Business_Filing__r.Account__c,Business_Filing__r.Status__c,Business_Filing__r.type__c,business_filing__r.Sub_Type__c from Temp_History__c where Type_of_Update__c =: System.label.Name and business_filing__c IN: busFileIds With SECURITY_ENFORCED]);
        if (tempHistoryList.size() > 0) {
            for(Temp_History__c tempHistInst : tempHistoryList) {
                Business_Filing__c bfiling=newBusinessFilings.get(tempHistInst.business_filing__c);
                if (bfiling.status__c == System.label.Approved &&
                ((bfiling.Type__c == System.label.Amendment_label_Comparable || bfiling.Type__c == System.label.brs_name_change_amendment_flow
                || bfiling.Type__c == System.label.Merger_Label || bfiling.Type__c == System.label.Conversion_Label || bfiling.Type__c == System.label.Domestication_Label) ||
                (bfiling.Type__c == System.label.RevocationDissolution_Header_Question && bfiling.Sub_Type__c == system.label.With_NameChange_Label)||
                (bfiling.Type__c == System.label.brs_Reinstatement && (bfiling.Sub_Type__c == system.label.withAnnual_NameChange || bfiling.Sub_Type__c == system.label.FirstReport_NameChange_Label)))) {
                if (tempHistInst.Business_Name_New__c != null && tempHistInst.Business_Name_New__c != '') {
                    Name_Change_History__c hisInst = new Name_Change_History__c();
                    hisInst.Account__c = tempHistInst.Account__c;
                    hisInst.Business_Filing__c = tempHistInst.business_filing__c;
                    hisInst.Business_Name_New__c = tempHistInst.Business_Name_New__c;
                    hisInst.Business_Name_Old__c = tempHistInst.Business_Name__c;               
                    hisInst.Name_Change_Date__c = bfiling.Effective_Date__c == null ? bfiling.Filing_Date__c:bfiling.Effective_Date__c;
                    historyList.add(hisInst); 
                }
            }
            }
        } 
        if (historyList.size() > 0) {
            Insert historyList;   
        }
        }
    }
    public static void LinkBusinessOnApproval(List<SObject> newItems,Map<Id, SObject> oldMap) {
        List<Business_filing__c> businessFiling = (List<Business_filing__c>)newItems;
        for(Business_filing__c Inst : businessFiling) {
            Business_filing__c busFiling = (Business_filing__c)oldMap.get(Inst.Id);
            if (((busFiling.Status__c == System.label.Submitted_Agent_acceptance_pending || busFiling.Status__c == System.label.brs_uccFilingStatus) && Inst.Status__c == System.label.Latest_Filed_Status) && ((Inst.Type__c == System.label.brs_name_change_amendment_flow && Inst.Citizenship__c == System.label.Foreign) || Inst.Type__c == System.label.AgentChange_comparable)) {
                BRS_Utility.linkBusinessToContact(Inst.Account__c,Inst.CreatedbyId);
            }
            else if (Inst.Type__c == System.label.First_Report || Inst.Type__c == System.label.Annual_Report_Comparable) {
                if ((busFiling.Status__c == System.label.Submitted_Agent_acceptance_pending || busFiling.Status__c == System.label.brs_uccFilingStatus) && Inst.Status__c == System.label.Latest_Filed_Status) {
                    BRS_Utility.linkBusinessToContact(Inst.Account__c,Inst.OwnerId);
                }
            }
            else if ((Inst.Type__c == System.label.Business_Formation_Comparable || Inst.Type__c == System.label.Business_Registration_Label) && Inst.Status__c == System.label.Latest_Filed_Status) {
                BRS_Utility.linkBusinessToContact(Inst.Account__c,Inst.CreatedbyId);
            }
        }
    }


    /**********************************************************************************************
    METHOD NAME    : refundRejectedOnlineFilings
    DESCRIPTION    : Method to create refund transaction
    PARAMETER      : List<Business_Filing__c>
    ***********************************************************************************************/
    public static void refundRejectedOnlineFilings(List<Business_Filing__c> newFilingList, Map<Id, SObject> mapOfOldFiling) {
        Set<Id> setOfBizFilingIds = new Set<Id>();
        List<String> statusesNotToConsider = new List<String>{System.Label.Declined, System.Label.Rejected_No_Reply};
        List<String> agentAutoRejectFlowTypes = new List<String>{System.Label.Label_Change_Agent, System.Label.Annual_Report_Comparable, System.Label.BRS_First_Report};
        for (Business_Filing__c newBizFiling : newFilingList) {
            Business_Filing__c oldBizFiling = (Business_Filing__c) mapOfOldFiling.get(newBizFiling.Id);
            if (newBizFiling.Status__c != null && newBizFiling.Status__c == System.Label.BRS_FilingStatus_Rejected && oldBizFiling.Status__c != newBizFiling.Status__c && 
                !(  
                    (   agentAutoRejectFlowTypes.contains(newBizFiling.Type__c) || 
                        (   newBizFiling.Type__c == System.label.Business_Formation_Comparable && 
                            newBizFiling.Citizenship__c == System.Label.Domestic && 
                            newBizFiling.Business_Type__c == System.Label.LLC
                        )
                    ) && 
                    statusesNotToConsider.contains(newBizFiling.Agent_Selection__c)
                )
            ) {
                
                    setOfBizFilingIds.add(newBizFiling.Id);
            }

            if (!setOfBizFilingIds.isEmpty()) {
                processBlackthornRefund(setOfBizFilingIds);
            }
        }
    }

    /**********************************************************************************************
    METHOD NAME    : processBlackthornRefund
    DESCRIPTION    : Method to process refund transactions from any class
    PARAMETER      : Set<Id>
    ***********************************************************************************************/

    public static void processBlackthornRefund (Set<Id> setOfBizFilingIds) {
        OnOff_Filing_Auto_Refund__c onOffSwich = OnOff_Filing_Auto_Refund__c.getall().values()[0];
        if (!onOffSwich.Auto_Refund_Business_Filing__c) {
            return;
        }
        Set<Id> workOrderIds = new Set<Id>();
        for(Business_Filing__c bf: [Select Id,Status__c,Work_Order__c from Business_Filing__c where ID IN:setOfBizFilingIds AND Status__c = 'Rejected' WITH SECURITY_ENFORCED]){           
            workOrderIds.add(bf.Work_Order__c);         
        }
        List<bt_stripe__Transaction__c> transactions2Insert = new List<bt_stripe__Transaction__c>();
        for (Work_Order__c wo: [SELECT Id, Total_Hold_Amount__c, Final_Amount_Payable__c,
                                    (SELECT Id,Include_Expedited_Service__c,Expedited_Service_Fee__c,Work_Order__c from Business_Filings__r), 
                                    (SELECT Id, bt_stripe__Payment_Status__c, bt_stripe__Transaction_Status__c, bt_stripe__Transaction_Type__c,
                                            bt_stripe__Amount__c, bt_stripe__Payment_Gateway__c, bt_stripe__Stripe_Customer__c, bt_stripe__Related_Contact__c,
                                            bt_stripe__Related_Account__c, bt_stripe__Payment_Method__c 
                                     FROM Transactions__r) 
                                FROM Work_Order__c 
                                WHERE Id IN :workOrderIds AND 
                                     (Source__c = 'Online' OR Source__c = 'Digital Mail') WITH SECURITY_ENFORCED]) {
        if(!wo.Transactions__r.isEmpty()){
            Boolean validTransaction = false;
            Boolean alreadyRefunded = false;
            Decimal totalCapturedAmt = 0;
            Decimal totalRefundedAmt = 0;
            bt_stripe__Transaction__c transactionToRefund = new bt_stripe__Transaction__c();
            List<bt_stripe__Transaction__c> lstOfCapturedTxn = new List<bt_stripe__Transaction__c>();
            List<bt_stripe__Transaction__c> lstOfRefundedTxn = new List<bt_stripe__Transaction__c>();
			Decimal paidFromBalance = 0;
            Decimal amountToRetain = 0;
            if(wo.Total_Hold_Amount__c!=null && wo.Final_Amount_Payable__c!=null){
                paidFromBalance = wo.Total_Hold_Amount__c - wo.Final_Amount_Payable__c;
            }

            if(!wo.Business_Filings__r.isEmpty() && wo.Business_Filings__r[0].Include_Expedited_Service__c == true){
                if(paidFromBalance<wo.Business_Filings__r[0].Expedited_Service_Fee__c){
                    amountToRetain = wo.Business_Filings__r[0].Expedited_Service_Fee__c - paidFromBalance;
                }
            }

            if (!wo.Transactions__r.isEmpty()) {

                // segregate captured and already/partially refunded transactions
                for (bt_stripe__Transaction__c btTransaction : wo.Transactions__r) {
                    String txnStatus = btTransaction.bt_stripe__Transaction_Status__c;
                    String tType = btTransaction.bt_stripe__Transaction_Type__c;
                    String payStatus = btTransaction.bt_stripe__Payment_Status__c;

                    if (tType == 'Normal' && txnStatus == 'Completed' && (payStatus == 'Captured' || payStatus == 'Partially Refunded')) {
                        lstOfCapturedTxn.add(btTransaction);
                        totalCapturedAmt += btTransaction.bt_stripe__Amount__c;
                    }
                    else if (tType == 'Refund' && txnStatus == 'Completed' && payStatus == 'Refunded') {
                        lstOfRefundedTxn.add(btTransaction);
                        totalRefundedAmt += Math.abs(btTransaction.bt_stripe__Amount__c);
                    }
                }

                // create the refund Blackthorn transaction
                if (!lstOfCapturedTxn.isEmpty() && (totalCapturedAmt - totalRefundedAmt) > 0) {
                    bt_stripe__Transaction__c refundTransaction = new bt_stripe__Transaction__c();
                    refundTransaction.bt_stripe__Amount__c = (-1 * (totalCapturedAmt - totalRefundedAmt- amountToRetain));
                    refundTransaction.bt_stripe__Transaction_Type__c = 'Refund';
                    refundTransaction.bt_stripe__Payment_Gateway__c = lstOfCapturedTxn[0].bt_stripe__Payment_Gateway__c;
                    refundTransaction.bt_stripe__Stripe_Customer__c = lstOfCapturedTxn[0].bt_stripe__Stripe_Customer__c;
                    refundTransaction.bt_stripe__Related_Contact__c = lstOfCapturedTxn[0].bt_stripe__Related_Contact__c;
                    refundTransaction.bt_stripe__Related_Account__c = lstOfCapturedTxn[0].bt_stripe__Related_Account__c;
                    refundTransaction.bt_stripe__Payment_Method__c = lstOfCapturedTxn[0].bt_stripe__Payment_Method__c;
                    refundTransaction.bt_stripe__Capture__c = true;
                    refundTransaction.bt_stripe__Parent_Transaction__c = lstOfCapturedTxn[0].Id;
                    refundTransaction.Work_Order__c = wo.id;
                    transactions2Insert.add(refundTransaction);
                }
            }
        }
        }
        Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(transactions2Insert, 'insert');
        if (!transactions2Insert.isEmpty() && bAccessCheck) {
            insert transactions2Insert;
        }
    }

    public static Decimal updateTotalShareBRSFee(SObject newFilingList, Map<Id, SObject> oldMap,List<Franchise_Tax__mdt> mdtlst) {
       
        Decimal totaltax=0.0;
         try{
        
            Boolean iscalculateFurther=true;
            
            Decimal balance;   
            System.debug(' 1 newFilingList '+newFilingList);
               Business_Filing__c newFiling = (Business_Filing__c)newFilingList;
                if (newFiling.Type__c=='Business Formation' || newFiling.Type__c=='Business Registration' ||
                newFiling.Type__c == 'Domestication' || newFiling.Type__c == 'Conversion' || newFiling.Type__c == 'Merger') {
                    System.debug(' 1 newFiling.Total_Authorized_Shares__c '+newFiling.Total_Authorized_Shares__c);
                    if (newFiling.Total_Authorized_Shares__c != Null && newFiling.Total_Authorized_Shares__c >0)
                    {

                 if (newFiling.Total_Authorized_Shares__c> 0 && newFiling.Total_Authorized_Shares__c  <= mdtlst[0].Max_Value__c ) {
                 totaltax=calculateTaxforBFR(totaltax, newFiling.Total_Authorized_Shares__c, mdtlst, 1);  
                 iscalculateFurther =false; 
                 System.debug(' 1 '); 
                }  

              Decimal band = 0;
                if (iscalculateFurther ==true) {
            totaltax=calculateTaxforBFR(totaltax, mdtlst[0].Max_Value__c, mdtlst, 1);
               balance = newFiling.Total_Authorized_Shares__c -mdtlst[0].Max_Value__c;
               band = (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ) - balance;
               System.debug(' 2 ');   
            }
            System.debug(' 3 balance '+balance);
                  if (iscalculateFurther ==true) {
                if (band>=0) {
if (newFiling.Total_Authorized_Shares__c  <=mdtlst[1].Max_Value__c) {
    System.debug(' 3 ');
                  totaltax=calculateTaxforBFR(totaltax, balance, mdtlst, 2);
                iscalculateFurther =false;
} else if (newFiling.Total_Authorized_Shares__c  >mdtlst[1].Max_Value__c) {
    System.debug(' 4 ');
    totaltax=calculateTaxforBFR(totaltax,  (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ), mdtlst, 2);

    balance = balance-(mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c );
}
                  }
   
                   else if (band <0) {
                    if (newFiling.Total_Authorized_Shares__c  <=mdtlst[1].Max_Value__c) {
                        System.debug(' 5 ');
                        System.debug(' 5 balance '+balance);
                        totaltax=calculateTaxforBFR(totaltax, balance, mdtlst, 2);
                      iscalculateFurther =false;
      } else if (newFiling.Total_Authorized_Shares__c  >mdtlst[1].Max_Value__c) {
        System.debug(' 6 ');
        System.debug(' 6 balance '+balance);
          totaltax=calculateTaxforBFR(totaltax,  (mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c ), mdtlst, 2);
      
          balance = balance-(mdtlst[1].Max_Value__c-mdtlst[0].Max_Value__c );
      }
}    
}         
if (iscalculateFurther ==true) {
band =  (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c )  - balance;

 if (band>=0 ) {
    System.debug(' 7 ');
    System.debug(' 7 balance '+balance);
  if (newFiling.Total_Authorized_Shares__c  <= mdtlst[2].Max_Value__c) {

    totaltax=calculateTaxforBFR(totaltax, balance, mdtlst, 3);
  iscalculateFurther =false;
} else if (newFiling.Total_Authorized_Shares__c  >mdtlst[2].Max_Value__c) {
Decimal newBand =  (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c );
totaltax=calculateTaxforBFR(totaltax, newBand, mdtlst, 3);

balance = balance-newBand;
}


    }
   
    else if (band <0 ) {
        if (newFiling.Total_Authorized_Shares__c  <= mdtlst[2].Max_Value__c) {

            totaltax=calculateTaxforBFR(totaltax, balance, mdtlst, 3);
          iscalculateFurther =false;
        } else if (newFiling.Total_Authorized_Shares__c  >mdtlst[2].Max_Value__c) {
        Decimal newBand =  (mdtlst[2].Max_Value__c-mdtlst[1].Max_Value__c );
        totaltax=calculateTaxforBFR(totaltax, newBand, mdtlst, 3);
        
        balance = balance-newBand;
    }
}
if (iscalculateFurther ==true) {
totaltax=calculateTaxforBFR(totaltax, balance, mdtlst, 4);
}
     newFiling.Franchise_Tax__c=totaltax;

                     }
                      }
                     else{

                   
                        newFiling.Franchise_Tax__c=0;
                        
                    }

                  
               
            
                
                }
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateTotalShare', 'Business_Filing__c',null,'medium',e,null);
        }

        return totaltax;
    }
    static   Decimal calculateTaxforBFR(Decimal newFilingtax,Decimal taxdiff,List<Franchise_Tax__mdt> mdtlst,Integer casevalue) {
    
        if (casevalue ==1) {
            newFilingtax= mdtlst[0].Multiply_Value__c;
       
        }
        else if (casevalue ==2) {
            newFilingtax= newFilingtax+(taxdiff *mdtlst[1].Multiply_Value__c);
  
        }
        else if (casevalue ==3) {
            newFilingtax= newFilingtax+(taxdiff *mdtlst[2].Multiply_Value__c);
      
        }
        else if (casevalue ==4) {
            newFilingtax=newFilingtax+ (taxdiff *mdtlst[3].Multiply_Value__c);
        
        }
    return newFilingtax;
}
/**********************************************************************************************
    METHOD NAME    : rejectAccountOnFilingReject
    DESCRIPTION    : Method to reject account when business formation/registration filings are rejected
    PARAMETER      : List<Business_Filing__c>
    ***********************************************************************************************/
    public static void rejectAccountOnFilingReject(List<Business_Filing__c> newFilingList)
    {
        try{
            set<Id> accSetToReject = new set<Id>();
            if (!newFilingList.isEmpty()) {
                for(Business_Filing__c busFiObj : newFilingList) {
                    if ((busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label)&& busFiObj.status__c ==System.Label.Rejected) {
                        accSetToReject.add(busFiObj.Account__c);
                    }

                }
                if (!accSetToReject.isEmpty()) {
                    List<Account> accListToReject = new List<Account>();
                    accListToReject = [Select id, status__c from Account where id in: accSetToReject];
                    if (!accListToReject.isEmpty()) {
                        for(Account accObj: accListToReject) {
                            accObj.status__c = System.Label.Rejected;
                        }
                        Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(accListToReject, 'update');
                        if(bAccessCheck && accListToReject.size() > 0){
                       		 update accListToReject;
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'rejectAccountOnFilingReject',null,null,null,ex,ex.getMessage());
        }
    }

    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Updated latest filing date on account for approved/rejected filings
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-06-28
    * Change(s)/Modification(s) Made by : Rahul Sharma
    */
    public static void processMostRecentFilingDate(Map<Id, SObject> newItems, Map<Id,SObject> oldItems) {
        try{
            List<Account> accUpdateLst = new List<Account>();
            set<String> accUpdateIdSet = new set<String>();
            set<String> accUpdateIdSet2 = new set<String>();
            map<String,Account> accUpdateIdMap = new map<String,Account>();
            map<String,Business_Filing__c> accIdBusFileMap = new map<String,Business_Filing__c>();
            List<String> statuses = new List<String>{system.label.brs_BusinessReservationStatus,system.label.brsStatus_ReservedCancel,system.label.BRS_FilingStatus_Rejected,system.label.brs_BusFileStatusRemoved,system.label.brs_BusFileStatusExpired,system.label.brs_BusFileStatusExpiredReservation,system.label.brs_BusFileStatusRegistered,system.label.brs_BusFileStatusCancelled,system.label.Withdrawn,system.label.DISSOLVED_STATUS,system.label.Renunciated,system.label.Revoked_Label,system.label.Forfeited};
            for (sObject sobj : newItems.values()) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                if (businessfiling.Status__c == System.Label.Approved && businessfiling.Type__c== System.Label.Annual_Report_Comparable && businessfiling.Filing_Date__c != null)
                {
                    accUpdateIdSet2.add(businessfiling.Account__c);
                    accIdBusFileMap.put(businessfiling.Account__c,businessfiling);
                }
                else if (oldItems != null && businessfiling.Filing_Date__c != null && (businessfiling.Status__c != System.Label.Approved && businessfiling.Type__c== System.Label.Annual_Report_Comparable) )
                {
                    Business_Filing__c oldbusinessfiling = (Business_Filing__c)oldItems.get(sobj.Id);
                    if (oldbusinessfiling.Status__c == System.Label.Approved)
                        accUpdateIdSet2.add(businessfiling.Account__c);
                }
            }
            if (!accUpdateIdSet2.IsEmpty())
            {
                List<Account> acclst = [SELECT ID,status__c FROM Account WHERE Id in: accUpdateIdSet2 and Status__c not in: statuses With SECURITY_ENFORCED];
                if (!acclst.IsEmpty())
                {
                    for(Account acc : acclst)
                    {
                        accUpdateIdSet.add(acc.Id);
                    }
                }
            }
            if (!accUpdateIdSet.IsEmpty())
            {
                List<Business_Filing__c> lstBusFile = [Select Id, Filing_Date__c,Account__c,Type__c From Business_Filing__c where Account__c in: accUpdateIdSet and Status__c =: System.Label.Approved and Type__c =: System.Label.Annual_Report_Comparable  And Filing_Date__c != null With SECURITY_ENFORCED];
                if (!accIdBusFileMap.IsEmpty())
                {
                    for(String str : accIdBusFileMap.keyset())
                    {
                        lstBusFile.add(accIdBusFileMap.get(str));
                    }                    
                }
                if (!lstBusFile.IsEmpty())
                {
                    for(Business_Filing__c busFile : lstBusFile)
                    {
                        if (accUpdateIdSet.contains(busFile.Account__c))
                        {
                            if (!accUpdateIdMap.keyset().contains(busFile.Account__c))
                            {
                                Account acc = new Account(Id=busFile.Account__c,Most_Recent_Filing_Date__c=busFile.Filing_Date__c);
                                accUpdateIdMap.put(busFile.Account__c,acc);
                            }
                            else
                            {
                                Account acc2 = accUpdateIdMap.get(busFile.Account__c);
                                if (busFile.Filing_Date__c > acc2.Most_Recent_Filing_Date__c)
                                {
                                    accUpdateIdMap.remove(busFile.Account__c);
                                    Account acc3 = new Account(Id=busFile.Account__c,Most_Recent_Filing_Date__c=busFile.Filing_Date__c);
                                    accUpdateIdMap.put(busFile.Account__c,acc3);
                                }
                            }
                        }
                        else
                        {
                            Account acc = new Account(Id=busFile.Account__c,Most_Recent_Filing_Date__c=null);
                            accUpdateLst.add(acc);
                        }
                    }
                }
                else
                {
                    for(String str : accUpdateIdSet)
                    {
                        Account acc = new Account(Id=str,Most_Recent_Filing_Date__c=null);
                        accUpdateLst.add(acc);
                    }
                }
            }
            if (!accUpdateIdMap.IsEmpty())
            {
                for(String str : accUpdateIdMap.keyset())
                    accUpdateLst.add(accUpdateIdMap.get(str));
            }
            if (!accUpdateLst.IsEmpty())
                update accUpdateLst;
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'processMostRecentFilingDate', 'Account', null, null, ex, ex.getMessage());
        }
        
    }
        
    /**********************************************************************************************
    METHOD NAME    : createForeignInvestigationCase
    DESCRIPTION    : Method to create a FI case record 
    PARAMETER      : List<SObject> newBusinessFilings, Map<Id, SObject> oldFilingMap
    ***********************************************************************************************/    
    public static void createForeignInvestigationCase(List<SObject> newBusinessFilings, Map<Id, SObject> oldFilingMap) {
        try{
            List<Foreign_Investigation__c> newFIList = new List<Foreign_Investigation__c>();
            Set<Id> filingsSet = new Set<Id>();
            Boolean statusChanged = false;

            for(SObject sobj: newBusinessFilings) {
                Business_Filing__c newFiling = (Business_Filing__c)sobj;
                if (oldFilingMap!=null) {
                    Business_Filing__c oldFiling = (Business_Filing__c)oldFilingMap.get(newFiling.Id);
                    if (newFiling.Status__c!=oldFiling.Status__c && newFiling.Status__c == System.label.BRS_FilingStatus_Approved) {
                        statusChanged=true;
                    }
                }
                
                if ((newFiling.Type__c.equalsIgnoreCase(System.label.Business_Registration_Label)) && (newFiling.Status__c == System.Label.BRS_FilingStatus_Approved && newFiling.Days_between_Filing_and_Transacting__c > 90) && ((oldFilingMap!=null && statusChanged==true) || oldFilingMap==null)) {
                    Foreign_Investigation__c newFI = new Foreign_Investigation__c();
                    newFI.Case_Status__c = System.label.Pending;
                    newFI.Business__c = newFiling.Account__c;
                    newFi.Case_Initiated_By__c = System.label.Registration_Filing;
                    newFI.isFromBusinessRegistration__c = true;
                    newFI.Date_Began_Transacting_Business_in_CT__c = newFiling.Began_Transacting_in_CT__c;
                    newFI.Registration_Date__c = newFiling.Filing_Date__c;
                    newFIList.add(newFi);
                }
            }

            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(newFIList, 'insert');
            if (newFIList.size()>0 && bAccessCheck) {
                insert newFIList;
            }
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'createForeignInvestigationCase', 'Business_Filing__c', null, null, ex, ex.getMessage());
        }
    }

    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Update effective date on bus FIle from work order received date
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-07-12
    * Change(s)/Modification(s) Made by : Rahul Sharma
    */
    public static void updateEffectiveDate(List<SObject> newItems,Map<Id, SObject> oldMap) {
        Set<Id> wrkOrderIds=new Set<Id>();
        Map<String, Id> mapRecordTypes = SchemaUtility.getRecordTypes('Business_Filing__c');
        Set<Id> requiredRecordTypes = new Set<Id> {
            mapRecordTypes.get(System.label.Maintenance),
            mapRecordTypes.get('Mergers_Conversions_Domestications'),
            mapRecordTypes.get('Close_Reinstate'),
            mapRecordTypes.get('Other_Business_Filings')
        };

        for(sObject sobj : newItems) {
            Business_Filing__c businessfiling = (Business_Filing__c)sobj;
            if (oldMap==null 
                && !String.isBlank(businessfiling.Work_Order__c) 
                &&  businessfiling.Work_Order__c!=null 
                && 
                (
                    (
                        businessfiling.Effective_Date_Time__c == null 
                        && businessfiling.Source__c!=System.label.Online_Label
                    ) 
                    || 
                    (
                        businessfiling.Source__c==System.label.Online_Label 
                        && 
                        businessfiling.Type__c == System.label.Withdrawal_Label 
                        && 
                        businessfiling.Effective_Date__c == null
                    )
                ) 
                && 
                requiredRecordTypes.contains(businessfiling.RecordTypeId)
            ) {
                wrkOrderIds.add(businessfiling.Work_Order__c);
            }
        }
        if (!wrkOrderIds.isEmpty()) {
                Map<Id,Work_Order__c> wrkOrderMap = new Map<Id,Work_Order__c>([
                    Select id,Received_Date__c 
                    from Work_Order__c 
                    where Id IN:wrkOrderIds With SECURITY_ENFORCED
                ]);
                
                for(Business_Filing__c businessfiling : (List<Business_Filing__c>) newItems) {
                    if (
                        oldMap==null 
                        && !String.isBlank(businessfiling.Work_Order__c) 
                        && businessfiling.Work_Order__c!=null 
                        && 
                        (
                            (
                                businessfiling.Effective_Date_Time__c == null 
                                && 
                                businessfiling.Source__c!=System.label.Online_Label
                            ) 
                            || 
                            (
                                businessfiling.Source__c==System.label.Online_Label 
                                && 
                                businessfiling.Type__c==System.label.Withdrawal_Label 
                                && businessfiling.Effective_Date__c == null
                            )
                        ) 
                        && 
                        requiredRecordTypes.contains(businessfiling.RecordTypeId)
                    ) {
                        if (wrkOrderMap.get(businessfiling.Work_Order__c).Received_Date__c != null) {
                                businessfiling.Effective_Date__c  = Date.valueOf(wrkOrderMap.get(businessfiling.Work_Order__c).Received_Date__c);
                                businessfiling.Effective_Date_Time__c  = wrkOrderMap.get(businessfiling.Work_Order__c).Received_Date__c;
                                businessfiling.Effective_Time__c  = wrkOrderMap.get(businessfiling.Work_Order__c).Received_Date__c.time();
                        }
                    }
            }
        }
    }
    
    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Update effective date/Time on bus FIle from work order received date
    * Change(s)/Modification(s) Description : 
    * Change(s)/Modification(s) Made on : 2021-07-13
    * Change(s)/Modification(s) Made by : Rahul Sharma
    */
    public static void updateEffectiveDateAndTime(List<SObject> newItems,Map<Id, SObject> oldMap) {
        Set<Id> wrkOrderIds = new Set<Id>();
        Map<String, Id> mapRecordTypes = SchemaUtility.getRecordTypes('Business_Filing__c');
        Set<Id> requiredRecordTypes = new Set<Id> {
            mapRecordTypes.get(System.label.Maintenance),
            mapRecordTypes.get('Mergers_Conversions_Domestications'),
            mapRecordTypes.get('Close_Reinstate'),
            mapRecordTypes.get('Other_Business_Filings')
        };

        for(Business_Filing__c businessfiling : (List<Business_Filing__c>) newItems) {
            if (oldMap == null 
                && businessfiling.Effective_Date_Time__c != null 
                && businessfiling.Source__c != System.label.Online_Label 
                && requiredRecordTypes.contains(businessFiling.RecordTypeId)
            ) {
                wrkOrderIds.add(businessfiling.Work_Order__c);
            }
            else if (oldMap != null 
                && businessfiling.Effective_Date_Time__c != null 
                && businessfiling.Source__c != System.label.Online_Label 
                && requiredRecordTypes.contains(businessfiling.RecordTypeId)
            ) {
                Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.id);
                if (oldFiling.Effective_Date_Time__c != businessfiling.Effective_Date_Time__c) {
					Datetime effectiveDateTime = businessfiling.Effective_Date_Time__c;
                    Integer offset = UserInfo.getTimezone().getOffset(effectiveDateTime);
                    Datetime convertedDateTime = effectiveDateTime.addSeconds(offset/1000);
                    businessfiling.Effective_Date__c = Date.valueOf(convertedDateTime);
                    businessfiling.Effective_Time__c = businessfiling.Effective_Date_Time__c.time();
                }
            }
        }
        
        if (!wrkOrderIds.isEmpty()) {
            Map<Id,Work_Order__c> wrkOrderMap = new Map<Id,Work_Order__c>([Select id,Received_Date__c from Work_Order__c where Id IN:wrkOrderIds With SECURITY_ENFORCED]);
            
            for(Business_Filing__c businessfiling : (List<Business_Filing__c>)newItems) {
                if (oldMap==null 
                    && businessfiling.Effective_Date_Time__c != null 
                    && businessfiling.Source__c!=System.label.Online_Label 
                    && requiredRecordTypes.contains(businessfiling.RecordTypeId)
                ) {
                    businessfiling.Filing_Date__c  = Date.valueOf(wrkOrderMap.get(businessfiling.Work_Order__c).Received_Date__c);
					Datetime effectiveDateTime = businessfiling.Effective_Date_Time__c;
                    Integer offset = UserInfo.getTimezone().getOffset(effectiveDateTime);
                    Datetime convertedDateTime = effectiveDateTime.addSeconds(offset/1000);
                    businessfiling.Effective_Date__c  = Date.valueOf(convertedDateTime);
                    businessfiling.Effective_Time__c  = businessfiling.Effective_Date_Time__c.time();
                }
            }
        }
    }

      /**
* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Update date intend forfeiture on account from Business filing (Type as notice of intent to dissolve)
* Change(s)/Modification(s) Description : 
* Change(s)/Modification(s) Made on : 2021-07-27
* Change(s)/Modification(s) Made by : Rahul Sharma
*/
public static void updateForfeitureDate(List<SObject> newItems) {
   
    Map<String,List<Business_Filing__c>> accFilingMap =new Map<String,List<Business_Filing__c>>();
    Map<String,Date> accDateMap =new Map<String,Date>();
    List<Account> accLst2 = new List<Account>();
    for(sObject sobj : newItems) {
        Business_Filing__c businessfiling = (Business_Filing__c)sobj;
        if (businessfiling.Account__c != null && businessfiling.Filing_Type__c == system.label.Notice_of_Intent_to_Dissolve_Revoke_Label && businessfiling.Date_Intend_Forfeited__c !=null && businessfiling.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.CloseReinstateLabel,Schema.Business_Filing__c.getSObjectType())) {
            if (!accFilingMap.keyset().contains(businessfiling.Account__c))
            {
                List<Business_Filing__c> busFileList2 = new List<Business_Filing__c>();
                busFileList2.add(businessfiling);
                accFilingMap.put(businessfiling.Account__c,busFileList2);
            }
            else
            {
                List<Business_Filing__c> busFileList = accFilingMap.get(businessfiling.Account__c);
                busFileList.add(businessfiling);
                accFilingMap.remove(businessfiling.Account__c);
                accFilingMap.put(businessfiling.Account__c,busFileList);
            }
        }
    }
    if (!accFilingMap.IsEmpty())
    {
        for(String str : accFilingMap.keyset())
        {
            List<Business_Filing__c> busFileList3 = accFilingMap.get(str);
            Date forfeiteDate = null;
            for(Business_Filing__c bus : busFileList3)
            {
                forfeiteDate = forfeiteDate == null? bus.Date_Intend_Forfeited__c : (forfeiteDate < bus.Date_Intend_Forfeited__c ? bus.Date_Intend_Forfeited__c : forfeiteDate);
            }
            accDateMap.put(str,forfeiteDate);
        }
    }
    if (!accDateMap.IsEmpty())
    {
        List<Account> accLst = [Select Id, Date_Intend_Forfeited__c from Account where id in : accDateMap.keyset() With SECURITY_ENFORCED];
        for(Account acc : accLst)
        {
            Account acc2 = new Account(id=acc.Id);
            if (acc.Date_Intend_Forfeited__c == null || acc.Date_Intend_Forfeited__c < accDateMap.get(acc.Id))
                acc2.Date_Intend_Forfeited__c = accDateMap.get(acc.Id);
            accLst2.add(acc2);
        }
    }
    Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(accLst2, 'update');
    if (!accLst2.IsEmpty() && bAccessCheck)
        update accLst2;
    }
    
    
    
    
    
    public static void updateFeeforMergerConversionandDoemstication(List<Business_Filing__c> filings,Map<ID,SObject> oldItems) {
        Date processingDate = System.today();
        Map<String,Decimal>  mapKeyToAmount = new  Map<String,Decimal>();
        Map<String,Decimal>  filingKeyToAmount = new  Map<String,Decimal>();
        Decimal dFilingExpediteFee = 0;
        List<Franchise_Tax__mdt> mdtlst=[SELECT Id,label,Max_Value__c,Min_Value__c,Multiply_Value__c FROM Franchise_Tax__mdt where Type__c ='BFR' order by label];
       
        List<Master_Fee__c> allMasterFee = [SELECT Id,Business_Type__c,Service_Type__c,Filing_Type__c,Citizenship__c,Amount__c,Type__c,Sub_type__c 
        FROM Master_Fee__c 
        WHERE (Type__c = 'Business Formation' AND
        Status__c = :sActive AND
        Start_Date__c <= :processingDate AND
        (End_Date__c = null OR
         End_Date__c >= :processingDate)) OR 
         Service_Type__c = :System.Label.FilingExpediteFee.trim()
        WITH SECURITY_ENFORCED];
    
        if (!allMasterFee.isEmpty()) {
            for(Master_Fee__c mf : allMasterFee) {
                if (mf.Service_Type__c == System.Label.FilingExpediteFee.trim()) {
                    dFilingExpediteFee = mf.Amount__c;
                } else {
                    String key = mf.Business_Type__c != null ? mf.Business_Type__c : '';
                    mapKeyToAmount.put(key, mf.Amount__c);
                }
            }
        }
        
        List<String> typeList = new List<String>{'Domestication','Conversion','Merger'};
        List<Master_Fee__c> allfilingMasterFee = [SELECT Id,Business_Type__c,Service_Type__c,Filing_Type__c,Citizenship__c,Amount__c,Type__c,Sub_type__c 
        FROM Master_Fee__c 
        WHERE (Type__c IN :typeList  AND
        Status__c = :sActive AND
        Start_Date__c <= :processingDate AND
        (End_Date__c = null OR
        End_Date__c >= :processingDate))
        WITH SECURITY_ENFORCED];
        
        if (!allfilingMasterFee.isEmpty()) {
            for(Master_Fee__c mf : allfilingMasterFee) {
                String key = (mf.Type__c != null ? mf.Type__c : '') + (mf.Business_Type__c != null? ';'+mf.Business_Type__c : '');
                filingKeyToAmount.put(key, mf.Amount__c);
            }
        }
        
    
        for(Business_Filing__c businessfiling  : filings) {
    
            Business_Filing__c oldbusinessfiling ;
            if (oldItems!=null) {
                oldbusinessfiling =(Business_Filing__c) oldItems.get(businessfiling.Id);
            }
            String key = (businessfiling.Type__c != null ? businessfiling.Type__c : '') + (businessfiling.Business_Type__c != null? ';'+businessfiling.Business_Type__c : '');
            
            Decimal filingFee = filingKeyToAmount.containsKey(key) ? filingKeyToAmount.get(key) : filingKeyToAmount.get(businessfiling.Type__c) ;
        
            if (filingFee != null) {
                businessfiling.Filing_Fee__c = (filingFee != null) ? filingFee : 0;
                if (businessfiling.Type__c == 'Domestication') {
                    if ( businessfiling.Citizenship__c == 'Foreign'  && businessfiling.Source__c!=System.label.Online_Label  &&  (businessfiling.Business_Type__c == 'Stock'

                    ||businessfiling.Business_Type__c == 'B Corp'
                    ||businessfiling.Business_Type__c == 'Cooperative Association'
                    ||businessfiling.Business_Type__c == 'Bank Stock'
                    ||businessfiling.Business_Type__c == 'Credit Union Stock'
                    ||businessfiling.Business_Type__c == 'Insurance Stock'
                    )) {

                        if (businessfiling.Total_Authorized_Shares__c == null || businessfiling.Total_Authorized_Shares__c == 0) {
                            if(businessfiling.Source__c!='Digital Mail'){

                                businessfiling.addError(System.Label.NewShareError);
    }
                        } else {
                            businessfiling.Franchise_Tax__c =updateTotalShareBRSFee(businessfiling, oldItems, mdtlst);
                        }
                        String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                        Decimal filingFee1 = mapKeyToAmount.get(key1);
                        if (filingFee1!=null) {
                            businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                    } else if (businessfiling.Citizenship__c == 'Foreign') {
                            String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                            Decimal filingFee1 = mapKeyToAmount.get(key1);
                            if (filingFee1!=null) {
                                businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                        businessfiling.Franchise_Tax__c =0;
                    }
                }
                else if (businessfiling.Type__c == 'Merger') {
                    if ( businessfiling.Citizenship__c == 'Domestic'  && businessfiling.Source__c!=System.label.Online_Label && businessfiling.Source__c!='Digital Mail' && (businessfiling.Business_Type__c == 'Stock'
                    ||businessfiling.Business_Type__c == 'B Corp'
                    ||businessfiling.Business_Type__c == 'Cooperative Association'
                    ||businessfiling.Business_Type__c == 'Bank Stock'
                    ||businessfiling.Business_Type__c == 'Credit Union Stock'
                    ||businessfiling.Business_Type__c == 'Insurance Stock'
                    )) {
            
                        System.debug('businessfiling.Total_Authorized_Shares__c NewShareError'+businessfiling.Business_Type__c);
                        if (businessfiling.Total_Authorized_Shares__c == null || businessfiling.Total_Authorized_Shares__c == 0) {
                            businessfiling.Franchise_Tax__c =0;
                        } else {
                        //  businessfiling.Franchise_Tax__c =updateTotalShareBRSFee(businessfiling, oldItems, mdtlst);
                        }
                        String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                        Decimal filingFee1 = mapKeyToAmount.get(key1);
                        if (filingFee1!=null && businessfiling.Type_of_Merger__c!=null && businessfiling.Type_of_Merger__c!='Merge into Existing Business') {
                            businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                    } else if (businessfiling.Citizenship__c == 'Domestic') {
                        String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                        Decimal filingFee1 = mapKeyToAmount.get(key1);
                        if (filingFee1!=null && businessfiling.Type_of_Merger__c!=null && businessfiling.Type_of_Merger__c!='Merge into Existing Business') {
                        businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                    }
                    else  if ( businessfiling.Citizenship__c == 'Foreign'  && businessfiling.Source__c!=System.label.Online_Label && businessfiling.Source__c!='Digital Mail' && (businessfiling.Business_Type__c == 'Stock'
                    ||businessfiling.Business_Type__c == 'B Corp'
                    ||businessfiling.Business_Type__c == 'Cooperative Association'
                    ||businessfiling.Business_Type__c == 'Bank Stock'
                    ||businessfiling.Business_Type__c == 'Credit Union Stock'
                    ||businessfiling.Business_Type__c == 'Insurance Stock'
                    )) {
                        if (businessfiling.Total_Authorized_Shares__c == null || businessfiling.Total_Authorized_Shares__c == 0) {
                            businessfiling.Franchise_Tax__c =0;
                            
                        //    businessfiling.addError(System.Label.NewShareError);
                        } else {
                        //  businessfiling.Franchise_Tax__c =updateTotalShareBRSFee(businessfiling, oldItems, mdtlst);
                        }
                    } else {
                        businessfiling.Franchise_Tax__c =0;
                    }
                }
                else if (businessfiling.Type__c == 'Conversion') {
                    if ( businessfiling.Citizenship__c == 'Domestic'  && businessfiling.Source__c!=System.label.Online_Label &&   (businessfiling.Business_Type__c == 'Stock'
                    ||businessfiling.Business_Type__c == 'B Corp'
                    ||businessfiling.Business_Type__c == 'Cooperative Association'
                    ||businessfiling.Business_Type__c == 'Bank Stock'
                    ||businessfiling.Business_Type__c == 'Credit Union Stock'
                    ||businessfiling.Business_Type__c == 'Insurance Stock'
                    )) {
                        if (businessfiling.Total_Authorized_Shares__c == null || businessfiling.Total_Authorized_Shares__c == 0) {
if(businessfiling.Source__c!='Digital Mail'){
                            businessfiling.addError(System.Label.NewShareError);
}
                        } else {
                            businessfiling.Franchise_Tax__c =updateTotalShareBRSFee(businessfiling, oldItems, mdtlst);
                        }
                        String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                        Decimal filingFee1 = mapKeyToAmount.get(key1);
                        if (filingFee1!=null) {
                            businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                    } else if (businessfiling.Citizenship__c == 'Domestic') {
                        String key1 =  (businessfiling.Business_Type__c != null ? businessfiling.Business_Type__c : '') ;
                        Decimal filingFee1 = mapKeyToAmount.get(key1);
                        if (filingFee1!=null) {
                                businessfiling.Filing_Fee__c= businessfiling.Filing_Fee__c+filingFee1;
                        }
                        businessfiling.Franchise_Tax__c =0;
                    }
                }
                businessfiling.Franchise_Tax__c = businessfiling.Franchise_Tax__c!=null?businessfiling.Franchise_Tax__c:0;
                businessfiling.Total_Fee__c= businessfiling.Filing_Fee__c+businessfiling.Franchise_Tax__c;
                if (oldbusinessfiling == null && businessfiling.Include_Expedited_Service__c == true) {
                    businessfiling.Total_Fee__c = businessfiling.Total_Fee__c + dFilingExpediteFee; 
                    businessFiling.Expedited_Service_Fee__c = dFilingExpediteFee;
                }
                else if (oldItems != null && oldbusinessfiling != null &&  businessfiling.Include_Expedited_Service__c == true
                  && oldbusinessfiling.Include_Expedited_Service__c == false) {
                   
                    businessfiling.Total_Fee__c = businessfiling.Total_Fee__c!=null? businessfiling.Total_Fee__c + dFilingExpediteFee : dFilingExpediteFee; 
                    businessFiling.Expedited_Service_Fee__c = dFilingExpediteFee;
                } else if (oldItems != null && oldbusinessfiling != null &&  businessfiling.Include_Expedited_Service__c == true
                      && oldbusinessfiling.Include_Expedited_Service__c == true) {
                    businessfiling.Total_Fee__c = businessfiling.Total_Fee__c + dFilingExpediteFee; 
                    businessFiling.Expedited_Service_Fee__c = dFilingExpediteFee;
                } else if (oldItems != null && oldbusinessfiling != null && businessfiling.Include_Expedited_Service__c == false
                  && oldbusinessfiling.Include_Expedited_Service__c == true) {
                    businessFiling.Expedited_Service_Fee__c =0;
                }
            }
        }
    }
    
    
    /**********************************************************************************************
    METHOD NAME    : processWithdrwalUpdates
    DESCRIPTION    : Method to update account address and agent
    PARAMETER      : List<Business_Filing__c>
    Author         : Rahul Sharma
    ***********************************************************************************************/
    public static void processWithdrwalUpdates(List<Business_Filing__c> newFilingList)
    {
        try{
            map<String,Business_Filing__c> accMap = new map<String,Business_Filing__c>();
            if (!newFilingList.isEmpty()) {
                for(Business_Filing__c busFiObj : newFilingList) {
                    if (busFiObj.Type__c == System.label.Withdrawal_Label && busFiObj.status__c ==System.Label.BRS_FilingStatus_Approved && busFiObj.Account__c != null &&
                    busFiObj.RecordTypeId==Wizard_Utlity.getRecordTypeId(System.label.CloseReinstateLabel,Schema.Business_Filing__c.getSObjectType()) &&
                    (busFiObj.Business_Type__c == system.label.LLC || busFiObj.Business_Type__c == system.label.Stock || busFiObj.Business_Type__c == system.label.Non_Stock) &&
                    busFiObj.Citizenship__c == system.label.Foreign) {
                        accMap.put(busFiObj.Account__c,busFiObj);
                    }

                }
                if (!accMap.isEmpty()) {
                    List<Agent__c> agLstInsert = new List<Agent__c>();
                    List<Account> accUpdateLst = new List<Account>();
                    set<String> accId = new set<String>();
                    List<Account> acclst = [select id,business_type__c,citizenship__c,status__c from account where id in: accMap.keyset() and status__c =: system.label.Withdrawn and Business_type__c =: system.label.LLC and citizenship__c =: system.label.Foreign With SECURITY_ENFORCED];
                    if (!acclst.isEmpty())
                    {
                        for(Account acc : acclst)
                        {
                            accId.add(acc.id);
                        }
                    }
                    List<Agent__c> agLst = [Select id from Agent__c where Business_ID__c in: accMap.keyset() With SECURITY_ENFORCED];
                    if (!agLst.IsEmpty())
                        delete agLst;
                    for(String str : accMap.keyset())
                    {
                        
                        Business_Filing__c busFile = accMap.get(str);
                        if (busFile.Business_Type__c == system.label.Stock || busFile.Business_Type__c == system.label.Non_Stock)
                        {
                            Agent__c ag = new Agent__c(Business_ID__c=str,Type__c = system.label.Secretary_of_the_State_Comparable);
                            agLstInsert.add(ag);
                            if (busFile.Mailing_Address__c != null) {
                                Account acc = new Account(id=str);
                                acc.ShippingStreet = busFile.Mailing_Unit__c != null? busFile.Mailing_Street__c  +', '+busFile.Mailing_Unit__c: busFile.Mailing_Street__c;
                                acc.ShippingCity = busFile.Mailing_City__c;
                                acc.ShippingState = busFile.Mailing_State__c;
                                acc.ShippingPostalCode = busFile.Mailing_Zip_Code__c;
                                acc.ShippingCountry = busFile.Mailing_Country__c;
                                accUpdateLst.add(acc);
                            }
                        }
                        else if ( !accId.isEmpty() && accId.contains(str) && busFile.Business_Type__c == system.label.LLC)
                        {
							Agent__c ag = new Agent__c(Business_ID__c=str,Type__c = system.label.Secretary_of_the_State_Comparable);
							agLstInsert.add(ag);
                            if (busFile.Mailing_Address__c != null) {
                                Account acc = new Account(id=str);
                                acc.Mailing_Unit__c = busFile.Mailing_Unit__c;
                                acc.Mailing_Street__c = busFile.Mailing_Street__c;
                                acc.Mailing_City__c = busFile.Mailing_City__c;
                                acc.Mailing_State__c = busFile.Mailing_State__c;
                                acc.Mailing_Zip_Code__c = busFile.Mailing_Zip_Code__c;
                                acc.Mailing_Country__c = busFile.Mailing_Country__c;
                                accUpdateLst.add(acc);
                            }
                        }
                    }
                    if (!accUpdateLst.IsEmpty())
                        update accUpdateLst;
                    if (!agLstInsert.IsEmpty())
                        insert agLstInsert;
                }
            }
        }
        catch(Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'processWithdrwalUpdates',null,null,null,ex,ex.getMessage());
        }
    }  
    
    
public static void updateIntakeFlowToProcesss(List<Business_Filing__c> newFilingList)
{
   Set<ID> ids= new Set<Id>();
    Map<Id,String> workordermap= new  Map<Id,String>();
      ID newBusinessReservation = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Name Reservation').getRecordTypeId();
ID annualreporttype  = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
    ID newBusinessID = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
    ID maintenanceID = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
    ID closeReinstateID = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
    ID mergerID = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
for(Business_Filing__c   filing : newFilingList ){
    ids.add(filing.Work_order__c);
    if(filing.RecordTypeId == newBusinessID){
filing.FlowNameToProcess__c = 'Back_Office_New_Business';
    }else  if(filing.RecordTypeId == maintenanceID){
        filing.FlowNameToProcess__c = 'Back_Office_Maintenance_Flow';
    }
    else  if(filing.RecordTypeId == closeReinstateID){
        filing.FlowNameToProcess__c = 'Back_Office_Dissolution_Reinstate';
    }
    else  if(filing.RecordTypeId == mergerID  && filing.Type__c  == 'Merger'){filing.FlowNameToProcess__c = 'BRS_Business_Merger_Filing';}
    else  if(filing.RecordTypeId == mergerID  && filing.Type__c  == 'Domestication'){filing.FlowNameToProcess__c = 'BRS_Business_Domestication';}
    else  if(filing.RecordTypeId == mergerID  && filing.Type__c  == 'Conversion'){filing.FlowNameToProcess__c = 'BRS_Business_Conversions';}
}
 List<Work_Order__c> orders = [Select id , Last_In_Progress_Flow__c	 from Work_Order__c where id in :ids ];
    
    for(Work_Order__c   order : orders ){
        workordermap.put(order.id,order.Last_In_Progress_Flow__c);
    }
    
    for(Business_Filing__c   filing : newFilingList ){

    if(filing.RecordTypeId == newBusinessReservation){
filing.FlowNameToProcess__c = 'Back_Office_Name_Reservation';
    }

    if(filing.RecordTypeId == annualreporttype){
        filing.FlowNameToProcess__c = 'Back_Office_First_Annual';
            }
    }
}
   /**********************************************************************************************
    METHOD NAME    : updateReservedAccountForIntake
    DESCRIPTION    : Method to update reserved accounts reserved name used field to true once the intake filing is approved.
    PARAMETER      : List<Business_Filing__c>
    Author         : Priyanka Sharma
    ***********************************************************************************************/
    public static void updateReservedAccountForIntake(List<SObject> newItems,Map<Id, SObject> oldMap){
        try{
            List<Account> reserveAccountList=new List<Account>();
            for(sObject sobj : newItems) {                   
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
                if (businessfiling.Status__c!=oldFiling.Status__c && oldFiling.Status__c=='Submitted - Intake pending'  && (businessfiling.Status__c=='Approved' ||  businessfiling.Status__c=='Rejected')  && businessfiling.Intake_Reserved_Name__c!=null ) {      
                        reserveAccountList.add(new Account(Id=businessfiling.Intake_Reserved_Name__c, Status__c='Expired Reservation'));
                    }
            }
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(reserveAccountList, 'update'); 
            if(bAccessCheck && reserveAccountList.size() > 0){
       			update reserveAccountList;
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateReservedAccountForIntake',null,null,null,ex,ex.getMessage());
        } 
    }
            /**********************************************************************************************
    METHOD NAME    : updateAgentEmailAddress
    DESCRIPTION    : Method to update email address on agent object of agent email is changed on business filing.
    PARAMETER      : List<Business_Filing__c>
    Author         : Priyanka Sharma
    **********************************************************************************************/
    public static void updateAgentEmailAddress(List<SObject> newItems,Map<Id, SObject> oldMap){
        try{
            List<Agent__c> agentUpdateList = new List<Agent__c>();
            List<Temp_History__c> tempHistUpdateList = new List<Temp_History__c>();
            for(sObject sobj : newItems) {                
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
                if(businessfiling.Agent_Email_Address__c!=oldFiling.Agent_Email_Address__c && businessfiling.Status__c=='Submitted - Agent acceptance pending'){
                   Id agentId = businessfiling.Agent_Id__c;
                    String objectName = agentId.getSObjectType().getDescribe().getName();
                    if(objectName=='Agent__c'){
                        agentUpdateList.add(new Agent__c(id=businessfiling.Agent_Id__c,Email__c=businessfiling.Agent_Email_Address__c));
                    }
                    else{
                        tempHistUpdateList.add(new Temp_History__c(id=businessfiling.Agent_Id__c,Email__c=businessfiling.Agent_Email_Address__c));
                    }
                }
            }
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(agentUpdateList, 'update');
            if(!agentUpdateList.isEmpty() && bAccessCheck){
                update agentUpdateList;
            }
            Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(tempHistUpdateList, 'update');
            if(!tempHistUpdateList.isEmpty() && bAccessCheck1){
                update tempHistUpdateList;
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateAgentEmailAddress',null,null,null,ex,ex.getMessage());
        }  
    }
public static void updateAgentCertifiedCopyURLField(Map<Id, SObject> newItems,Map<Id, SObject> oldMap){
        try{
            List<Agent__c> agentUpdateList = new List<Agent__c>();
            Map<Id,Business_filing__c> newBusinessFilings = (Map<Id,Business_filing__c>)newItems;
            for(String inst : newItems.keyset()) {
                Business_Filing__c newFiling=newBusinessFilings.get(inst);
                String filingId = String.valueOf(newFiling.get('Id'));
                String filingStatus = String.valueOf(newFiling.get('Status__c'));
                String AccountId = String.valueOf(newFiling.get('Account__c'));
                String filingType = String.valueOf(newFiling.get('Filing_Type__c'));
                String oldstatus = String.valueOf(oldMap.get(inst).get('Status__c'));
                String oldFilingType = String.valueOf(oldMap.get(inst).get('Filing_Type__c'));
                if (filingStatus==System.label.Approved && filingStatus!= oldstatus && filingType == 'Agent Resignation' && oldFilingType == 'Agent Resignation')
                {
    
                    Agent__c agentData=[Select id,Certified_Copy_URL__c from Agent__c where Business_ID__c =: AccountId With SECURITY_ENFORCED];
                        agentData.Certified_Copy_URL__c = System.Label.BRS_Base_URL+'request-for-copy?reqType=Business&businessId='+AccountId+'&id='+filingId;
                        agentUpdateList.add(agentData);         
                }
            }
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(agentUpdateList, 'update');
            if(!agentUpdateList.isEmpty() && bAccessCheck) {
                update agentUpdateList;
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateAgentCertifiedCopyURLField',null,null,null,ex,ex.getMessage());
        }  
    }
    public static void updateAnnualReportDueDateOnRejection(List<SObject> newItems,Map<Id, SObject> oldMap){
        try{
            List<Account> lisacc=new List<Account>();
            for(sObject sobj : newItems) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                if(businessfiling.Account__c !=null && businessfiling.Type__c == System.Label.Annual_Report_Label && businessfiling.Status__c == System.Label.BRS_FilingStatus_Rejected)
                {
                    Account acc2 = new Account(Id = businessfiling.Account__c);
                    acc2.Annual_Report_Due_Date__c=businessfiling.Due_Date__c;
                    acc2.Annual_report_past_due_date__c = date.newinstance(acc2.Annual_Report_Due_Date__c.year(), acc2.Annual_Report_Due_Date__c.month(), acc2.Annual_Report_Due_Date__c.day());
                    lisacc.add(acc2);
                }    
            }
            update lisacc;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateAnnualReportDueDateOnRejection',null,null,null,ex,ex.getMessage());
        }  
    }

        public static void updateFilingTimeFromWorkorder(List<SObject> newItems){
Set<ID> workorderIds = new Set<ID>();
        for(Sobject obj : newItems){
            Business_Filing__c filing  = (Business_Filing__c)obj;
            if(filing.Work_Order__c !=null  && filing.Filing_Time__c ==null){
            workorderIds.add(filing.Work_Order__c);
            }
        }


        List<Work_Order__c>  allWorkorders = [Select id,Received_Date__c From Work_Order__c where Id in : workorderIds With SECURITY_ENFORCED];

        map<ID,Datetime>  workordermap = new map<ID,Datetime> ();
        for(Work_Order__c  order : allWorkorders){
            workordermap.put(order.id,order.Received_Date__c);
        }

        for(Sobject obj : newItems){
            Business_Filing__c filing  = (Business_Filing__c)obj;
        
            if(filing.Work_Order__c !=null){
                Datetime recieivedate =workordermap.get( filing.Work_Order__c);

                if(recieivedate !=null  && filing.Filing_Time__c ==null){
                    String timezoneval= UserInfo.getTimeZone().toString();
                    String strConvertedDate = recieivedate.format('HH:mm:ss', timezoneval);
                    String[] strTimeSplit = strConvertedDate.split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                     ,Integer.valueOf(strTimeSplit[1]) //min
                                     ,0                                //sec
                                     ,0);
                   filing.Filing_Time__c = timeChange;
                }
                
            }
        }
        }
        /**********************************************************************************************
    METHOD NAME    : updatePendingFilingCheckbox
    DESCRIPTION    : Method to update the Pending Filing checkbox
    PARAMETER      : List<Business_Filing__c>
    Author         : Rabbani
    **********************************************************************************************/
    public static void updatePendingFilingCheckbox(List<SObject> newItems,Map<Id, SObject> oldMap){
        List<Business_Filing__c> listBusinessFiling=new List<Business_Filing__c>();
        try{
            for(sObject sobj : newItems) {                
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                Business_Filing__c oldFiling = (Business_Filing__c)oldMap.get(businessfiling.Id);
                if(businessfiling.Status__c == 'Approved' && oldFiling.Status__c == 'Pending Filing'){
                    businessfiling.Pending_Filing_Status__c=true;
                    listBusinessFiling.add(businessfiling);
                }
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updatePendingFilingCheckbox',null,null,null,ex,ex.getMessage());
        }  
    }

    public static void updateAdminstrativeDissolutionText(List<SObject> newItems,Map<Id, SObject> oldMap){
        List<Business_Filing__c> listBusinessFiling=new List<Business_Filing__c>();
        try{
            List<Account> updatedAccount=new List<Account>();
            List<id> accids=new List<id>();
            for(sObject sobj : newItems) {                
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                if(businessfiling.Status__c == 'Approved' && businessfiling.Type__c == 'Reinstatement'){
                    accids.add(businessfiling.Account__c);
                }
            }
                List<Account> acclist=[Select id,Reason_for_Administrative_Dissolution__c,Sub_Status__c,Annual_Report_Processing_Year__c,Annual_Report_Due_Date__c,Annual_report_past_due_date__c from Account where id IN:accids];
                if(!acclist.isEmpty())
                {
                    for(Account acc:acclist)
                    {

                        if(acc.Reason_for_Administrative_Dissolution__c !=null || acc.Sub_Status__c!=null)
                        {
                            acc.Reason_for_Administrative_Dissolution__c=null;
                            acc.Sub_Status__c=null;
                            acc.Annual_Report_Processing_Year__c=system.today().year();
                            acc.Annual_Report_Due_Date__c=null;
                            acc.Annual_report_past_due_date__c=null;
                            updatedAccount.add(acc);
                        }
                        else
                        {
                            acc.Annual_Report_Processing_Year__c=system.today().year();
                            acc.Annual_Report_Due_Date__c=null;
                            acc.Annual_report_past_due_date__c=null;
                            updatedAccount.add(acc);

                        }
                    }
                }
        update updatedAccount;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateAdminstrativeDissolutionText',null,null,null,ex,ex.getMessage());
        }  
    }

    public static void updateIsRejectedInstiatedForAnnualReport(List<SObject> newItems){
        List<Business_Filing__c> businessFilingList=new List<Business_Filing__c>();
        Map<id,String> dueYearCheckMap=new Map<id,String>();
        try{
           for(sObject sobj : newItems) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                List<id> accids=new List<id>();
                if(businessfiling.Type__c == 'Annual Report' && businessfiling.Source__c != 'Online'){
				dueYearCheckMap.put(businessfiling.Account__c,businessfiling.Due_Year__c);
                }
              }
            if(!dueYearCheckMap.isEmpty())
            {
                businessFilingList=[select id,Is_Rejected_Instantiated__c,Account__c,Type__c,Due_Date__c, Due_Year__c from Business_Filing__c where Type__c='Annual Report' and Is_Rejected_Instantiated__c=false and status__c='Rejected' and Account__r.status__c='Active' and Account__c IN:dueYearCheckMap.keySet()];
            }
            List<Business_Filing__c> businessFilingUpdatingList=new List<Business_Filing__c>();
            if(!businessFilingList.isEmpty())
            {
             for(Business_Filing__c bus:businessFilingList)
             {
	            if(dueYearCheckMap.get(bus.Account__c) == bus.Due_Year__c)
	            {
                    bus.Is_Rejected_Instantiated__c=true;
	                  businessFilingUpdatingList.add(bus);
	            }
             }
           }
         update businessFilingUpdatingList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateIsRejectedInstiatedForAnnualReport ',null,null,null,ex,ex.getMessage());
        }  
    }
    public static void updateJurdictionStateorTerritory(List<SObject> newItems,Map<Id, SObject> oldMap){
        try{
            List<Account> acclist=new List<Account>();
            List<id> accids=new List<id>();
            for(sObject sobj : newItems) {
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                if(businessfiling.Citizenship__c == 'Foreign' && businessfiling.Business_Type__c =='LLP' && (businessfiling.Source__c == 'Mail' || businessfiling.Source__c == 'Digital Mail') && businessfiling.Account__c !=null && businessfiling.Type__c=='Business Registration'){
                    accids.add(businessfiling.Account__c);
                    }
                }
                                
            for(Account acc:[select Office_Jurisdiction_BusinessStreet__c,Jurisdiction_International_address__c,Jurisdiction_StateorTerritory__c from Account where id IN:accids])
            {
                     if(acc.Office_Jurisdiction_BusinessStreet__c !=null || acc.Jurisdiction_International_address__c != null)
                    {
                        acc.Jurisdiction_StateorTerritory__c='Yes';
                        acclist.add(acc);
                    }
                    else
                    {
                        acc.Jurisdiction_StateorTerritory__c='No';
                        acclist.add(acc);
                    }
            }
            
            if(!acclist.isEmpty())
            {
                Update acclist;
            }
            }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'updateJurdictionStateorTerritory',null,null,null,ex,ex.getMessage());
        }  
    }
}