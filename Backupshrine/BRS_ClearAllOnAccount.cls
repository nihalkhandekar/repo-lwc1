/* DESCRIPTION: This class is used to fetch the reserved names associated with a user.
*
* @AUTHOR:  Priyanka Sharma
* @DATE:    10/27/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka Sharma                   10/27/2020                   Created the first version
*********************************************************************************************/
global with sharing class BRS_ClearAllOnAccount {
    global static Final String className='BRS_ClearAllOnAccount';
    
    @InvocableMethod()
    global static List<Results> clearAllFields(List<Requests> Requests) {
        try {
            if (Requests.size() > 0) {
                String sAccountID = Requests[0].accId;
                List<SObject> lstDeleteRecords = new List<SObject>();
                List<Account> lstAccount = [SELECT Id, SicDesc, Annual_Report_Due_Date__c, Began_Transacting_in_CT__c, 
                                        Business_Customer_ID__c, Business_Email_Address__c, Business_Sub_Type__c, Business_Type__c, Citizenship__c, 
                                        Date_Registration__c, Date_of_Formation__c, External_ID__c, Filing_DateTime__c, Formation_Place__c, Latest_Report__c, 
                                        NAICS_Code__c, NAICS_Sub_Code__c, bt_stripe__Active_ARR__c, bt_stripe__Active_MRR__c, bt_stripe__Active_QRR__c, 
                                        bt_stripe__Active_Subscription_Names__c, bt_stripe__Create_Stripe_Customer__c, bt_stripe__Default_Payment_Method__c, 
                                        bt_stripe__Historical_Account_Value__c, bt_stripe__Last_Finalized_ARR__c, bt_stripe__Last_Finalized_MRR__c, 
                                        bt_stripe__Last_Finalized_QRR__c, bt_stripe__Last_Finalized_Sum_All_ARR__c, bt_stripe__Subscription_Status__c, 
                                        bt_stripe__Sum_All_ARR__c, Account_Name_Without_Designators__c, Annual_Report_Processing_Year__c, 
                                        Annual_report_past_due_date__c, Billing_Unit__c, Business_Address_Format__c, Business_Address__c, 
                                        Business_End_Date__c, Business_Name_in_state_country__c, Business_Registration_ID__c, Business_Unique_Number__c, 
                                        Business_structure_is_organized_profit__c, CEO_Address_City__c, CEO_Address_State__c, CEO_Address_Street__c, 
                                        CEO_Address_Unit__c, CEO_Address_ZipCode__c, Category_Survey_Email_Address__c, Class_of_Member__c, 
                                        Classification_Description__c, ClientAccountNum__c, Copy_Address__c, Corporation_Membership_Type__c, 
                                        Country_Formation__c, Country__c, Date_of_Organization_Meeting__c, Dissolution_date__c,
                                        Doing_Business_As__c, Duration_of_Business_In_CT__c, Election_of_Bcorp_Status__c, Email_Address__c, Foreign_ALEI__c, 
                                        Has_Business_Name_Reservation_No__c, I_Acknowledge__c, IsOrganizedForProfit__c, Jurisdiction_International_address__c, 
                                        Jurisdiction_StateorTerritory__c, Legal_Structure_Acknowledgement__c, Mail_Jurisdiction_International_address__c, 
                                        Mailing_Address_Format__c, Mailing_Address__c, Mailing_International_Address__c,  
                                        Mailing_Jurisdiction_BusinessCity__c, Mailing_Jurisdiction_BusinessState__c, Mailing_Jurisdiction_BusinessStreet__c, 
                                        Mailing_Jurisdiction_BusinessUnit__c, Mailing_Jurisdiction_BusinessZipCode__c, Mailing_Jurisdiction_Country__c, 
                                        Minority_Owned_Organization__c, Name_of_Applicant__c, Nature_of_Activities_Conducted__c, No_address_found__c, 
                                        None_of_the_listed_Organizations__c,  Office_Jurisdiction_BusinessCity__c, 
                                        Office_Jurisdiction_BusinessState__c, Office_Jurisdiction_BusinessStreet__c, Office_Jurisdiction_BusinessUnit__c, 
                                        Office_Jurisdiction_BusinessZipCode__c, Office_in_Jurisdiction_Country__c, Opt_Out_of_Survey_Email_Notification__c, 
                                        Optional_Business_Description__c, Org_Owned_by_Person_s_with_disabilities__c, Organization_is_LGBTQI_Owned__c, Origin__c, 
                                        Other_Provisions__c, Partnership_is_a_Foreign_Registered_LLP__c, Pin__c, Prefer_not_to_answer__c,  
                                        Principal_Office_City__c, Principal_Office_State__c, Principal_Office_Street__c, Principal_Office_Unit__c, 
                                        Principal_Office_ZipCode__c, Principle_Office_International_Address__c, Professional_Corporation__c, Purpose_of_Business__c, 
                                        Purpose_of_Co_op_Association__c, Reason_for_Administrative_Dissolution__c, Record_Address__c, Records_Address_City__c, 
                                        Records_Address_Country__c, Records_Address_State__c, Records_Address_Street__c, Records_Address_Unit__c, 
                                        Records_Address_Zip_Code__c, Reservation_Expiration_Date__c, Reserved_Name_Used__c, Reserved_User__c, 
                                        Self_Nomination_as_Agent__c, Shipping_Unit__c, Signatory_Name__c, Signatory_Title__c, Signatory_Type__c, 
                                        State_or_Territory_Formation__c, Status_changed_on__c, Sub_status__c, Total_Authorized_Shares__c,  
                                        Veteran_Owned_Organization__c, Woman_Owned_Organization__c, Work_Order__c, Most_Recent_Filing_Date__c, 
                                        CONCORD_Applicant_Name__c, Survey_Date__c, Billing_City_Indexed__c, 
                                        Surviving_Account__c,(SELECT Id FROM Agents1__r), (SELECT Id FROM Agents__r), (SELECT Id FROM Principals__r), 
                                        (SELECT Id FROM Stock_Classifications_del__r), AccountNumber, Status__c FROM Account WHERE Id =:sAccountID];
                
                //List<Account> lstAccount = [SELECT Id,(SELECT Id FROM Agents1__r), (SELECT Id FROM Agents__r), (SELECT Id FROM Principals__r), 
                //                            (SELECT Id FROM Stock_Classifications_del__r), AccountNumber, Status__c FROM Account WHERE Id =:sAccountID];
                if (lstAccount.size() > 0) {
                    lstAccount[0].Date_Registration__c = null;
                    lstAccount[0].Other_Provisions__c = null;
                    lstAccount[0].Business_Sub_Type__c = null;
                    lstAccount[0].Business_Email_Address__c = null;
                    lstAccount[0].Business_Customer_ID__c = null;
                    lstAccount[0].Annual_Report_Due_Date__c = null;
                    lstAccount[0].Began_Transacting_in_CT__c = null;
                    lstAccount[0].NAICS_Sub_Code__c = null;
                    lstAccount[0].NAICS_Code__c = null;
                    lstAccount[0].Latest_Report__c = null;
                    lstAccount[0].Formation_Place__c = null;
                    lstAccount[0].Filing_DateTime__c = null;
                    lstAccount[0].Date_of_Formation__c = null;
                    lstAccount[0].Business_Registration_ID__c = null;
                    lstAccount[0].Business_Name_in_state_country__c = null;
                    lstAccount[0].Business_End_Date__c = null;
                    lstAccount[0].Annual_report_past_due_date__c = null;
                    lstAccount[0].Billing_Unit__c = null;
                    lstAccount[0].Business_Address_Format__c = null;
                    lstAccount[0].Business_Address__c = null;
                    lstAccount[0].Annual_Report_Processing_Year__c = null;
                    lstAccount[0].Account_Name_Without_Designators__c = null;
                    lstAccount[0].Classification_Description__c = null;
                    lstAccount[0].Category_Survey_Email_Address__c = null;
                    lstAccount[0].CEO_Address_ZipCode__c = null;
                    lstAccount[0].CEO_Address_Unit__c = null;
                    lstAccount[0].CEO_Address_Street__c = null;
                    lstAccount[0].CEO_Address_State__c = null;
                    lstAccount[0].CEO_Address_City__c = null;
                    lstAccount[0].Date_of_Organization_Meeting__c = null;
                    lstAccount[0].Country__c = null;
                    lstAccount[0].Country_Formation__c = null;
                    lstAccount[0].Corporation_Membership_Type__c = null;
                    lstAccount[0].ClientAccountNum__c = null;
                    lstAccount[0].Dissolution_date__c = null;
                    lstAccount[0].Doing_Business_As__c = null;
                    lstAccount[0].Duration_of_Business_In_CT__c = null;
                    lstAccount[0].Email_Address__c = null;
                    lstAccount[0].Foreign_ALEI__c = null;
                    lstAccount[0].Has_Business_Name_Reservation_No__c = false;
                    lstAccount[0].Jurisdiction_International_address__c = null;
                    lstAccount[0].Jurisdiction_StateorTerritory__c = null;
                    lstAccount[0].Mail_Jurisdiction_International_address__c = null;
                    lstAccount[0].Mailing_Address__c = null;
                    lstAccount[0].Mailing_Jurisdiction_BusinessCity__c = null;
                    lstAccount[0].Mailing_Jurisdiction_BusinessState__c = null;
                    lstAccount[0].Mailing_Jurisdiction_BusinessStreet__c = null;
                    lstAccount[0].Mailing_Jurisdiction_BusinessUnit__c = null;
                    lstAccount[0].Mailing_Jurisdiction_BusinessZipCode__c = null;
                    lstAccount[0].Mailing_Jurisdiction_Country__c = null;
                    lstAccount[0].Minority_Owned_Organization__c = false;
                    lstAccount[0].Name_of_Applicant__c = null;
                    lstAccount[0].No_address_found__c = false;
                    lstAccount[0].None_of_the_listed_Organizations__c = false;
                    lstAccount[0].Office_Jurisdiction_BusinessCity__c = null;
                    lstAccount[0].Office_Jurisdiction_BusinessState__c = null;
                    lstAccount[0].Office_Jurisdiction_BusinessStreet__c = null;
                    lstAccount[0].Office_Jurisdiction_BusinessUnit__c = null;
                    lstAccount[0].Office_Jurisdiction_BusinessZipCode__c = null;
                    lstAccount[0].Office_in_Jurisdiction_Country__c = null;
                    lstAccount[0].Opt_Out_of_Survey_Email_Notification__c = false;
                    lstAccount[0].Optional_Business_Description__c = null;
                    lstAccount[0].Org_Owned_by_Person_s_with_disabilities__c = false;
                    lstAccount[0].Organization_is_LGBTQI_Owned__c = false;
                    lstAccount[0].Origin__c = null;
                    lstAccount[0].Partnership_is_a_Foreign_Registered_LLP__c = false;
                    lstAccount[0].Pin__c = null;
                    lstAccount[0].Prefer_not_to_answer__c = false;
                    lstAccount[0].Principal_Office_City__c = null;
                    lstAccount[0].Principal_Office_State__c = null;
                    lstAccount[0].Principal_Office_Street__c = null;
                    lstAccount[0].Principal_Office_Unit__c = null;
                    lstAccount[0].Principal_Office_ZipCode__c = null;
                    lstAccount[0].Professional_Corporation__c = null;
                    lstAccount[0].Reason_for_Administrative_Dissolution__c = null;
                    lstAccount[0].Records_Address_City__c = null;
                    lstAccount[0].Records_Address_Country__c = null;
                    lstAccount[0].Records_Address_State__c = null;
                    lstAccount[0].Records_Address_Street__c = null;
                    lstAccount[0].Records_Address_Unit__c = null;
                    lstAccount[0].Records_Address_Zip_Code__c = null;
                    lstAccount[0].Reservation_Expiration_Date__c = null;
                    lstAccount[0].Reserved_Name_Used__c = false;
                    lstAccount[0].Reserved_User__c = null;
                    lstAccount[0].Self_Nomination_as_Agent__c = false;
                    lstAccount[0].Shipping_Unit__c = null;
                    lstAccount[0].Annual_Report_Due_Date__c = null;
                    lstAccount[0].Surviving_Account__c = null;
                    lstAccount[0].Billing_City_Indexed__c = null;
                    lstAccount[0].Survey_Date__c = null;
                    lstAccount[0].CONCORD_Applicant_Name__c = null;
                    lstAccount[0].Most_Recent_Filing_Date__c = null;
                    lstAccount[0].Work_Order__c = null;
                    lstAccount[0].Woman_Owned_Organization__c = false;
                    lstAccount[0].Veteran_Owned_Organization__c = false;
                    lstAccount[0].Sub_status__c = null;
                    lstAccount[0].Status_changed_on__c = null;
                    lstAccount[0].State_or_Territory_Formation__c = null;
                    lstAccount[0].Signatory_Type__c = null;
                    lstAccount[0].Signatory_Title__c = null;
                    lstAccount[0].Signatory_Name__c = null;
                    update lstAccount;
                    // getRelated Lists
                    for (SObject obj : lstAccount[0].Agents1__r) {
                        lstDeleteRecords.add(obj);
                    }
                    for (SObject obj : lstAccount[0].Agents__r) {
                        lstDeleteRecords.add(obj);
                    }
                    for (SObject obj : lstAccount[0].Principals__r) {
                        lstDeleteRecords.add(obj);
                    }
                    for (SObject obj : lstAccount[0].Stock_Classifications_del__r) {
                        lstDeleteRecords.add(obj);
                    }
                    delete lstDeleteRecords;
                }
            }
            List<Results> lstResults = new List<Results>();
            
            Results r = new Results();
            r.isSucess =true;
            lstResults.add(r);
            return lstResults;
                 
        }
        catch (Exception ex){
            BOS_Utility.ExceptionHandler(className, 'clearAllFields', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    global without sharing class Requests {
        @InvocableVariable
        global string accId;
    }    
    global without sharing class Results {
        @InvocableVariable
        global Boolean isSucess;
    }
}