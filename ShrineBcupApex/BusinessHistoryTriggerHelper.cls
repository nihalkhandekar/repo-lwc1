/* DESCRIPTION: Helper class for Business history object trigger
*
* @AUTHOR:  Avinash Shukla
* @DATE:    11-08-2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Avinash Shukla                  11-08-2021                   Created the first version
* Avinash Shukla                  17-08-2021                   Added fix for BRS-6804

*/
public without sharing class BusinessHistoryTriggerHelper {

    public static Final String className = 'BusinessHistoryTriggerHelper';
    /**********************************************************************************************
    METHOD NAME    : processDomesticationMergersConversionFilings
    DESCRIPTION    : Method to update/create existing business filings and account annual report due date
    PARAMETER      : Map<Id, SObject> newItems, Map<Id, SObject> oldItems
    ***********************************************************************************************/

    public static void processDomesticationMergersConversionFilings(Map<Id, SObject> newItems) {
        try {
            Set<Id> businessfilingIdsToProcess = new Set<Id>();
            For(Sobject sObj : newItems.values()) {
                If(sObj.get('Business_Filing__c') != NULL) {
                    businessfilingIdsToProcess.add((Id)sObj.get('Business_Filing__c'));
                }
            }

            Map<Id, Business_Filing__c> allBusinessFilings = new Map<Id, Business_Filing__c>([Select Id, Account__c, Account__r.Business_Type__c, Account__r.Citizenship__c, Type__c, Type_of_Merger__c, (Select Id, Merging_Business__c, Merging_Business__r.Business_Type__c, Surviving_Business__c, Surviving_Business__r.Business_Type__c, Surviving_Business__r.Citizenship__c, Surviving_Business__r.Sub_Status__c, Surviving_Business__r.annual_Report_Due_Date__c, Surviving_Business__r.Annual_report_past_due_date__c, Old_Business_Type__c from Business_Histories__r) From Business_Filing__c WHERE ID IN : businessfilingIdsToProcess]);
            Set<Id> accIdsToDeleteARbusinessFilings = new Set<Id>();
            Set<Id> accIdsToDeleteFRbusinessFilings = new Set<Id>();
            Set<Id> udtAccountLLCLLPDueDate = new Set<Id>();
            Set<Id> udtAccounttoFirstReportDue = new Set<Id>();
            Set<Id> udtAccounttoFirstReportDueDate = new Set<Id>();
            Set<Id> udtAccounttAnnualReportNull = new Set<Id>();
            List<Business_Filing__c> firstReportFilings = new List<Business_Filing__c>();
            for (Business_Filing__c oBf : allBusinessFilings.values()) {
                if (!oBf.Business_Histories__r.isEmpty()) {
                    Business_History__c oBH = oBf.Business_Histories__r.get(0); // Picking the first Business history as there will always be one per business filing.
                    // Current design implemented is Apart from D2D conversion everytime a conversion/domestication/merger are done there will always be a new account created.
                    If(oBf.Type__c == System.Label.Conversion_Label || oBF.Type__c == System.Label.Domestication_Label) {
                        If((oBH.Surviving_Business__r.Business_Type__c == System.Label.B_Corp || oBH.Surviving_Business__r.Business_Type__c == System.Label.Stock) && oBH.Surviving_Business__r.CitizenShip__c == System.Label.Domestic) {
                            // In case of moving from F2D or D2D, If the surviving business is B Corp or Stock we create new FR business filing.
                            Business_Filing__c frFiling = new Business_Filing__c();
                            frFiling.Due_Date__c = Date.today().addDays(90);
                            frFiling.Filing_Type__c = System.label.Organization_and_First_Report;
                            frFiling.Status__c = System.label.Due;
                            frFiling.Type__c = System.label.First_Report_Comparable;
                            // Conversion Case : If the merging and surviving businesses are same, then it is conversion case D2D
                            If(oBH.Surviving_Business__c == oBH.Merging_Business__c && oBH.Surviving_Business__c != NULL) {
                                // Perform the following :
                                // Delete existing Annual report business filings in(Due, In Progress, Past Due)
                                accIdsToDeleteARbusinessFilings.add(oBf.Account__c);
                                // Create new business filing(First report) with exiting account
                                frFiling.Account__c = oBf.Account__c;
                                frFiling.Business_Type__c = oBf.Account__r.Business_Type__c;
                                frFiling.Citizenship__c = oBf.Account__r.Citizenship__c;
                            } else {
                                // Create new business filing(First report) with surviving account
                                frFiling.Account__c = oBH.Surviving_Business__c;
                                frFiling.Business_Type__c = oBH.Surviving_Business__r.Business_Type__c;
                                frFiling.Citizenship__c = oBH.Surviving_Business__r.Citizenship__c;
                            }
                            udtAccounttoFirstReportDue.add(oBH.Surviving_Business__c);
                            firstReportFilings.add(frFiling);
                        } else if ((oBH.Surviving_Business__r.Business_Type__c == System.Label.Business_Type_LLC || oBH.Surviving_Business__r.Business_Type__c == System.Label.LLP || oBH.Surviving_Business__r.Business_Type__c == System.Label.Limited_Partnership) && oBH.Surviving_Business__r.CitizenShip__c == System.Label.Domestic) {
                            // Conversion Case : When businesses are moving to LLP/LP or LLC, we delete the existing First report AND annual report filings in D2D conversion.
                            If(oBH.Surviving_Business__c == oBH.Merging_Business__c && oBH.Surviving_Business__c != NULL) {
                                accIdsToDeleteARbusinessFilings.add(oBf.Account__c);
                                accIdsToDeleteFRbusinessFilings.add(oBf.Account__c);
                                //Update the substatus on account to null if 'First report due' is shown
                                udtAccounttAnnualReportNull.add(oBH.Surviving_Business__c);
                            }
                            // Since all the ARs are deleted or are not available(since new business is formed), we need to update the annual report due date(estimated) next year on account.
                            udtAccountLLCLLPDueDate.add(oBH.Surviving_Business__c);
                        }
                    } else if(oBf.Type__c == System.Label.Merger_Label && oBf.Type_of_Merger__c == System.Label.Merge_into_New_Domestic_Business && oBH.Surviving_Business__r.CitizenShip__c == System.Label.Domestic){
                        // In case of mergers if the business filing type of merger is 'Merge into New Domestic Business' then we perform the annual report due date functionality.
                        if(oBH.Surviving_Business__r.Business_Type__c == System.Label.B_Corp || oBH.Surviving_Business__r.Business_Type__c == System.Label.Stock){
                            if(oBH.Surviving_Business__r.Sub_Status__c != System.Label.First_Report_Due){
                                Business_Filing__c frFiling = new Business_Filing__c();
                                frFiling.Due_Date__c = Date.today().addDays(90);
                                frFiling.Filing_Type__c = System.label.Organization_and_First_Report;
                                frFiling.Status__c = System.label.Due;
                                frFiling.Type__c = System.label.First_Report_Comparable;
                                frFiling.Account__c = oBH.Surviving_Business__c;
                                frFiling.Business_Type__c = oBH.Surviving_Business__r.Business_Type__c;
                                frFiling.Citizenship__c = oBH.Surviving_Business__r.Citizenship__c;
                                udtAccounttoFirstReportDue.add(oBH.Surviving_Business__c);
                                firstReportFilings.add(frFiling);
                            }
                        } else {
                            if(oBH.Surviving_Business__r.annual_Report_Due_Date__c == NULL || oBH.Surviving_Business__r.Annual_report_past_due_date__c == NULL){
                                udtAccountLLCLLPDueDate.add(oBH.Surviving_Business__c);
                            }
                        }
                    }
                }
            }
            Set<String> duePastDueInProgress = new Set<String> {System.Label.Due, System.Label.PastDue, System.label.In_Progress_Label, System.Label.Submitted_Agency_review_pending, System.Label.Submitted_Agent_acceptance_pending, System.Label.BRS_FilingStatus_Rejected};
            If(!accIdsToDeleteARbusinessFilings.isEmpty() || !accIdsToDeleteFRbusinessFilings.isEmpty()) {
                delete [Select id from Business_Filing__c WHERE Status__c IN  : duePastDueInProgress AND ((Account__c IN : accIdsToDeleteARbusinessFilings AND Type__C = 'Annual Report') OR (Account__c IN : accIdsToDeleteFRbusinessFilings AND Type__C = 'First Report'))];
            }
            // Insert first reports when businesses are moved to Domestic - Stock , B Corp.(Not Non- Stock, because during conversion we do not have option to convert to Domestic - Non Stock)
            if (!firstReportFilings.isEmpty()) {
                Insert firstReportFilings;
            }
            If(!udtAccountLLCLLPDueDate.isEmpty() || !udtAccounttoFirstReportDue.isEmpty() || !udtAccounttAnnualReportNull.isEmpty()) {
                List<Account> AcList = new List<Account>();
                List<Account> AcListToUpdate = new List<Account>();
                AcList = [Select Id, Business_Type__c, annual_Report_Due_Date__c, Annual_report_past_due_date__c, Sub_Status__c, Date_Registration__c from Account WHERE ID In : udtAccountLLCLLPDueDate OR ID In : udtAccounttoFirstReportDue OR Id IN : udtAccounttAnnualReportNull];
                For(Account oAc : AcList) {
                    Boolean isModified = false;
                    if (udtAccountLLCLLPDueDate.contains(oAc.Id)) {
                        if (oAc.Business_Type__c == System.Label.Business_Type_LLC) {
                            //Set AR for LLC to next year on 31 March
                            Date arDueDate = Date.newInstance(Date.today().addYears(1).year(), 3, 31);
                            oAc.annual_Report_Due_Date__c = arDueDate;
                            oAc.Annual_report_past_due_date__c = arDueDate;
                            isModified = true;
                        } else if (oAc.Business_Type__c == System.Label.LLP || oAc.Business_Type__c == System.Label.Limited_Partnership) {
                            Date arDueDate = Date.newInstance(Date.today().addYears(1).year(), Date.today().month(), Date.today().day());
                            If(oAc.Date_Registration__c != NULL){
                                arDueDate = Date.newInstance(oAc.Date_Registration__c.addYears(1).year(), oAc.Date_Registration__c.month(), oAc.Date_Registration__c.day());
                            }
                            oAc.annual_Report_Due_Date__c = arDueDate;
                            oAc.Annual_report_past_due_date__c = arDueDate;
                            isModified = true;
                        }
                    }
                    If(udtAccounttoFirstReportDue.contains(oAc.Id) && (oAc.Sub_Status__c == System.Label.Annual_Report_Due1 || oAc.Sub_Status__c == System.Label.Annual_report_past_due || oAc.Sub_Status__c == NULL)) {
                        oAc.Sub_Status__c = System.Label.First_Report_Due;
                        oAc.annual_Report_Due_Date__c = Date.today().addDays(90);
                        oAc.Annual_report_past_due_date__c = Date.today().addDays(90);
                        isModified = true;
                    }
                    If(udtAccounttAnnualReportNull.contains(oAc.Id) && (oAc.Sub_Status__c == System.Label.First_Report_Due || oAc.Sub_Status__c == System.Label.First_report_past_due || oAc.Sub_Status__c == System.Label.Annual_Report_Due1 || oAc.Sub_Status__c == System.Label.Annual_report_past_due)) {
                        oAc.Sub_Status__c = NULL;
                        isModified = true;
                    }
                    if (isModified) {
                        AcListToUpdate.add(oAc);
                    }
                }
                if (!AcListToUpdate.isEmpty()) {
                    Update AcListToUpdate;
                }
            }
        } catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'processDomesticationMergersConversionFilings', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}