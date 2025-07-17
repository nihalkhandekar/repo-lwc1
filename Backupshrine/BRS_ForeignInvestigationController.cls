/* DESCRIPTION: This class contains methods to get Foreign Investigation Data.
*
* @AUTHOR:  Tamkanat
* @DATE:    28/6/2021
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Tamkanat                         28/6/2021                           Created the first version
*********************************************************************************************/

public with sharing class BRS_ForeignInvestigationController {
    public static Final String className = 'brs_ForeignInvestigationController';
    public static Final String getForeignInvestigation = 'getVoucher';
    public static Final String sSeverity = 'High';
	
    /**********************************************************************************************
        METHOD NAME    : getForeignInvestigation
        DESCRIPTION    : Method to get Foreign Investigation data.
        PARAMETER      : String fIRecId
    ***********************************************************************************************/
    @AuraEnabled
    public static ForeignInvsWrapper getForeignInvestigation(String fIRecId) {
        try{
            ForeignInvsWrapper foreignInvWrapper = new ForeignInvsWrapper();
            if(fIRecId!=null){
                Foreign_Investigation__c foreignInvs = [select Id,Case_Status__c,Name,Due_Date__c,Total_Amount__c,Negotiated_Amount__c,Outstanding_Amount_Due__c,Monthly_Payable__c from Foreign_Investigation__c where Id=:fIRecId WITH SECURITY_ENFORCED];
                if(foreignInvs!=null){
                    foreignInvWrapper.Id=foreignInvs.Id;
                    foreignInvWrapper.fIName = foreignInvs.Name;
                    //foreignInvWrapper.dueDate = foreignInvs.Due_Date__c;
                    foreignInvWrapper.fIStatus = foreignInvs.Case_Status__c;
                    foreignInvWrapper.totalAmount = foreignInvs.Total_Amount__c;
                    foreignInvWrapper.outstandingAmount = foreignInvs.Outstanding_Amount_Due__c;
                    if(foreignInvs.Negotiated_Amount__c!=null){
                        foreignInvWrapper.negotiatedAmount = foreignInvs.Negotiated_Amount__c;
                        foreignInvWrapper.showNegotiatedAmt = true;
                    }
                    Date dt =  foreignInvs.Due_Date__c;
                    if(dt!=null){
                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                        String fieldValue = dtime.format('MM/dd/yyyy');
                        foreignInvWrapper.dueDate = fieldValue;
                    }
                    if(foreignInvs.Monthly_Payable__c!=null){
                        foreignInvWrapper.monthlyPlanPresent = true;
                    }
                }
            }
            return foreignInvWrapper;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getForeignInvestigation, 'Foreign_Investigation__c', fIRecId, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**********************************************************************************************
        METHOD NAME    : getFIForConfirmation
        DESCRIPTION    : Method to get Foreign Investigation data for confirmation screen in flow.
        PARAMETER      : String fIRecId, Integer noOfMonths
    ***********************************************************************************************/
    @AuraEnabled
    public static ForeignInvsWrapper getFIForConfirmation(String fIRecId, Integer noOfMonths) {
        try{
            ForeignInvsWrapper foreignInvWrapper = new ForeignInvsWrapper();
            User currentUserDetails;
            System.debug('months: '+noOfMonths);
            if(UserInfo.getUserId()!=null){
                currentUserDetails = [select Id,Contact_Email_Address__c, Contact.Phone from User where Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            }
            if(fIRecId!=null){
                Foreign_Investigation__c foreignInvs = [select Id,Case_Status__c,Name,Due_Date__c,Total_Amount__c,Negotiated_Amount__c,
                                                        Outstanding_Amount_Due__c,Monthly_Payable__c,Business__r.Business_Email_Address__c from Foreign_Investigation__c where Id=:fIRecId WITH SECURITY_ENFORCED];
                if(foreignInvs!=null){
                    foreignInvWrapper.Id=foreignInvs.Id;
                    foreignInvWrapper.fIName = foreignInvs.Name;
                    foreignInvWrapper.outstandingAmount = foreignInvs.Outstanding_Amount_Due__c;
                    foreignInvWrapper.businessEmail = foreignInvs.Business__r.Business_Email_Address__c;
                    Date dt =  foreignInvs.Due_Date__c;
                    if(dt!=null){
                        System.debug('dt: '+dt);
                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                        System.debug('dtime: '+dtime);
                        String fieldValue = dtime.format('dd MMMM, yyyy');
                        foreignInvWrapper.nextInstallmentDate = fieldValue;
                    }
                    if(foreignInvs.Monthly_Payable__c!=null && foreignInvs.Outstanding_Amount_Due__c>0){
                        foreignInvWrapper.monthlyPlanPresent = true;
                        foreignInvWrapper.monthlyPayableAmount = foreignInvs.Monthly_Payable__c;
                    }
                }
            }
            if(currentUserDetails!=null){
                foreignInvWrapper.contactEmail = currentUserDetails.Contact_Email_Address__c;
                foreignInvWrapper.contactPhone = currentUserDetails.Contact.Phone;
            }
            return foreignInvWrapper;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getForeignInvestigation, 'Foreign_Investigation__c', fIRecId, sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public without sharing class ForeignInvsWrapper {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String fIName {get; set;}
        @AuraEnabled public String dueDate {get; set;}
        @AuraEnabled public String fIStatus {get; set;}
        @AuraEnabled public Decimal totalAmount {get; set;}
        @AuraEnabled public Decimal negotiatedAmount {get; set;}
        @AuraEnabled public Decimal outstandingAmount {get; set;}
        @AuraEnabled public Decimal monthlyPayableAmount {get; set;}
        @AuraEnabled public Boolean showNegotiatedAmt {get; set;}
        @AuraEnabled public Boolean monthlyPlanPresent {get; set;}
        @AuraEnabled public String nextInstallmentDate {get; set;}
        @AuraEnabled public String contactEmail {get; set;}
        @AuraEnabled public String contactPhone {get; set;}
        @AuraEnabled public String businessEmail {get; set;}
    }
}