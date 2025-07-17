public with sharing class ForeignInvestigationTriggerHelper {
    public static Final String className = 'ForeignInvestigationTriggerHelper';
	
    /*************************************************************************************************
        METHOD NAME    : duplicateFICheck
        DESCRIPTION    : Method to check if an FI already exists for same business.
        PARAMETER      : List<Foreign_Investigation__c> and Map<ID, Foreign_Investigation__c>
    ***************************************************************************************************/
    public static void duplicateFICheck(List<Foreign_Investigation__c> newTriggerList, Map<Id,SObject> oldTriggerMap){
        Boolean checkRecord = false;
        Set<Id> businessIdsSet = new Set<Id>();
        Map<Id,Foreign_Investigation__c> existingFIMap = new Map<Id,Foreign_Investigation__c>();

        try{
            for(Foreign_Investigation__c newFI : newTriggerList){
                if(newFI.Business__c != null){
                    if(oldTriggerMap!=null){
                        Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                        if(newFI.Business__c != oldFI.Business__c){
                            businessIdsSet.add(newFI.Business__c);
                        }
                    }
                    else{
                        businessIdsSet.add(newFI.Business__c);
                    }
                }
            }

            if(!businessIdsSet.isEmpty()){
                for(Foreign_Investigation__c existingFI : [
                    SELECT Id, Business__c 
                    FROM Foreign_Investigation__c 
                    WHERE Business__c IN: businessIdsSet
                        AND Closed_Date__c != null WITH SECURITY_ENFORCED //only check with open FI
                ]){
                    existingFIMap.put(existingFI.Business__c,existingFI);
                }
            }

            for(Foreign_Investigation__c newFI: newTriggerList){
                if(newFI.Business__c != null){
                    if(oldTriggerMap!=null){
                        Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                        if(newFI.Business__c != oldFI.Business__c){
                            checkRecord = true;
                        }
                    }
                    else{
                        checkRecord = true;
                    }
                    if(checkRecord && existingFIMap.containsKey(newFI.Business__c)){
                        newFI.Business__c.addError(System.label.FIAlreadyExistsMessage);
                    }
                }
            }
        
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'duplicateFICheck', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }
    }

    /*************************************************************************************************
        METHOD NAME    : updateCaseStatus
        DESCRIPTION    : Method to update case status.
        PARAMETER      : List<Foreign_Investigation__c> and Map<ID, Foreign_Investigation__c>
    ***************************************************************************************************/
    public static void updateCaseStatus(List<Foreign_Investigation__c> newTriggerList, Map<Id,SObject> oldTriggerMap){
        Boolean recordToBeUpdated = false;
        Boolean updateClosedDate = false;

        try{
            for(Foreign_Investigation__c newFI : newTriggerList){
                if(oldTriggerMap!=null){
                    Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                    if(newFI.Payments_Made_to_Date__c != oldFI.Payments_Made_to_Date__c){
                        recordToBeUpdated = true;
                    }
                    if(newFI.Case_Status__c != oldFI.Case_Status__c){
                        updateClosedDate = true;
                    }
                }
                else{
                    recordToBeUpdated = true;
                    updateClosedDate = true;                  
                }
                                
                if(recordToBeUpdated && newFI.Payments_Made_to_Date__c > 0 ){
                	if((!newFI.Case_Status__c.equalsIgnoreCase(System.label.OpenPartiallyPaid)) && (newFI.Payments_Made_to_Date__c != newFI.Total_Amount__c && newFI.Payments_Made_to_Date__c != newFI.Negotiated_Amount__c)){
                        newFI.Case_Status__c = System.label.OpenPartiallyPaid;
                    }
                    else if((!newFI.Case_Status__c.equalsIgnoreCase(System.label.ClosedPaidinFull)) && (newFI.Payments_Made_to_Date__c == newFI.Total_Amount__c || newFI.Payments_Made_to_Date__c == newFI.Negotiated_Amount__c)){
                        newFI.Case_Status__c = System.label.ClosedPaidinFull;
                        newFI.Closed_Date__c = Date.today();
                        newFI.Due_Date__c = null;
                    }
                }
                if(updateClosedDate){
                    if(newFI.Case_Status__c.equalsIgnoreCase(System.label.ClosedWithdrawn) || newFI.Case_Status__c.equalsIgnoreCase(System.label.ClosedPaidinFull) || newFI.Case_Status__c.equalsIgnoreCase(System.label.ClosedRevoked) || newFI.Case_Status__c.equalsIgnoreCase(System.label.ClosedRevocationInitiated)){
                        newFI.Closed_Date__c = Date.today();
                    }
                    else{
                        newFI.Closed_Date__c = null;
                    }
                }
            }
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'updateCaseStatus', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }
    }

    /*************************************************************************************************
        METHOD NAME    : updateBusinessFields
        DESCRIPTION    : Method to update Business related fields from account lookup.
        PARAMETER      : List<Foreign_Investigation__c> and Map<ID, Foreign_Investigation__c>
    ***************************************************************************************************/
    public static void updateBusinessFields(List<Foreign_Investigation__c> newTriggerList, Map<Id,SObject> oldTriggerMap){
        Map<Id,Id> FIMapToUpdate = new Map<Id,Id>();
        Set<Id> businessIDsSet = new Set<Id>();

        try{
            for(Foreign_Investigation__c newFI : newTriggerList){
                if(newFI.Business__c != null){
                    if(oldTriggerMap!=null){
                        Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                        if(newFI.Business__c != oldFI.Business__c){
                            businessIDsSet.add(newFI.Business__c);
                        }
                        else if((newFI.Date_Began_Transacting_Business_in_CT__c != null && newFI.Registration_Date__c != null) && ((newFI.Date_Began_Transacting_Business_in_CT__c != oldFI.Date_Began_Transacting_Business_in_CT__c) || (newFI.Registration_Date__c != oldFI.Registration_Date__c)) && newFI.Date_Began_Transacting_Business_in_CT__c.daysBetween(newFI.Registration_Date__c) <= 90){
                            newFI.addError(System.label.ForeignInvestigationDaysErrorMssg);
                        }
                    }
                    else if(newFI.Date_Began_Transacting_Business_in_CT__c != null && newFI.Registration_Date__c != null && newFI.Date_Began_Transacting_Business_in_CT__c.daysBetween(newFI.Registration_Date__c) <= 90){
                        newFI.addError(System.label.ForeignInvestigationDaysErrorMssg);
                    }
                    else{
                        businessIDsSet.add(newFI.Business__c);
                    }
                }
                else{
                    if(oldTriggerMap != null){
                        Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                        if((newFI.Date_Began_Transacting_Business_in_CT__c != null && newFI.Registration_Date__c != null) && ((newFI.Date_Began_Transacting_Business_in_CT__c != oldFI.Date_Began_Transacting_Business_in_CT__c) || (newFI.Registration_Date__c != oldFI.Registration_Date__c)) && newFI.Date_Began_Transacting_Business_in_CT__c.daysBetween(newFI.Registration_Date__c) <= 90){
                            newFI.addError(System.label.ForeignInvestigationDaysErrorMssg);
                        }
                    }

                    else if(oldTriggerMap==null){
                        if(newFI.Case_Initiated_By__c == null){
                            newFI.Case_Initiated_By__c.addError(System.label.ErrMsgGeneric);
                        }
                        else if(newFI.Business_Name__c == null){
                            newFI.Business_Name__c.addError(System.label.ErrMsgGeneric);
                        }
                    }
                }          
            }

            Map<Id, Account> businessMap = new Map<Id, Account>([
                SELECT Id, Name, ShippingStreet, ShippingCity, ShippingCountry, 
                    ShippingState, ShippingPostalCode, Business_Type__c, Began_Transacting_in_CT__c, Business_Email_Address__c,
                    Shipping_Unit__c,Principle_Office_International_Address__c, Date_Registration__c 
                FROM Account 
                WHERE Id in : businessIDsSet WITH SECURITY_ENFORCED
            ]);

            for(Foreign_Investigation__c newFI : newTriggerList){
                if(businessMap.containsKey(newFI.Business__c)) {
                    Account business = businessMap.get(newFI.Business__c);

                    if(business.Began_Transacting_in_CT__c != null){
                        newFI.Date_Began_Transacting_Business_in_CT__c = business.Began_Transacting_in_CT__c;
                    }
                    if(business.Date_Registration__c != null){
                        newFI.Registration_Date__c = business.Date_Registration__c;
                    }
                    if(business.Name != null){
                        newFI.Business_Name__c = business.Name;
                    }
                    if(business.Business_Type__c != null){
                        newFI.Business_Type__c = business.Business_Type__c;
                    }
                    
                    //BRS-6372, BRS-7785 | Get account mailing address on FI | Only on create
                    if(oldTriggerMap == null) {
                        newFI.Business_Street_Address_1__c = business.ShippingStreet;
                        newFI.Business_Street_Address_2__c=business.Shipping_Unit__c;
                        newFI.Business_City__c = business.ShippingCity;
                        newFI.Business_State__c = business.ShippingState;
                        newFI.Business_Country__c = business.ShippingCountry;
                        newFI.Business_Zip_Code__c = business.ShippingPostalCode;
                        newFI.International_Address__c = business.Principle_Office_International_Address__c;
                    }

                    
                }
                //BRS-6372, BRS-7785 | for domestic => populate country as USA
                if(String.isBlank(newFI.International_Address__c) && String.isNotBlank(newFI.Business_Street_Address_1__c) && String.isBlank(newFI.Business_Country__c)) {
                    newFI.Business_Country__c = 'USA';
                }
            }

        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'updateBusinessFields', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }
    }

    /*************************************************************************************************
        METHOD NAME    : createPaymentLineItems
        DESCRIPTION    : Method to create penalty and license fee records in Payment Line Items Table.
        PARAMETER      : List<Foreign_Investigation__c> and Map<ID, Foreign_Investigation__c>
    ***************************************************************************************************/
    public static void createPaymentLineItems(List<Foreign_Investigation__c> newTriggerList, Map<Id,SObject> oldTriggerMap){
        List<Payment_Line_Item__c> newLineItemsLst = new List<Payment_Line_Item__c>();
        List<Foreign_Investigation_Fee_Table__mdt> lstOfFeeRecords = [Select Id, Label, Statue_Fee_Period__c, Fee_Amount__c, Fee_Notes__c, Fee_Type__c, From_Month__c, From_Year__c, Is_Monthly_Fee__c, To_Month__c, To_Year__c from Foreign_Investigation_Fee_Table__mdt ORDER BY Label];
        Set<Id> updatedFI = new Set<Id>();
        Boolean isStockCorp = false;
        Boolean isRecordUpdated = false;

        try{
            for(Foreign_Investigation__c newFI : newTriggerList){
                if(oldTriggerMap!=null){
                    Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                    if((newFI.Date_Began_Transacting_Business_in_CT__c!=oldFI.Date_Began_Transacting_Business_in_CT__c) || (newFI.Registration_Date__c != oldFI.Registration_Date__c || newFI.Business_Type__c != oldFI.Business_Type__c)){
                        updatedFI.add(newFI.Id);
                    }
                }
            }

            if(updatedFI.size() > 0){
                List<Payment_Line_Item__c> PaymentsToDeleteLst =  [SELECT Id FROM Payment_Line_Item__c WHERE Case_Number__c IN : updatedFI WITH SECURITY_ENFORCED];
                 Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(PaymentsToDeleteLst, 'delete');
                if(PaymentsToDeleteLst.size() > 0 && accessCheck){
                    Delete PaymentsToDeleteLst;
                }
            }

            for(Foreign_Investigation__c newFI : newTriggerList){
                if(oldTriggerMap!=null){
                    Foreign_Investigation__c oldFI = (Foreign_Investigation__c)oldTriggerMap.get(newFI.Id);
                    if((newFI.Date_Began_Transacting_Business_in_CT__c!=oldFI.Date_Began_Transacting_Business_in_CT__c) || (newFI.Registration_Date__c != oldFI.Registration_Date__c || newFI.Business_Type__c != oldFI.Business_Type__c)){
                        isRecordUpdated = true;
                    }
                }
                if(newFI.Business_Type__c!= null && newFI.Business_Type__c.equalsIgnoreCase(System.label.Stock)){
                    isStockCorp = true;
                }
                else{
                    isStockCorp = false;
                }

                if((newFI.Date_Began_Transacting_Business_in_CT__c != null && newFI.Registration_Date__c != null)&& (isRecordUpdated || oldTriggerMap == null )){
                    for(Foreign_Investigation_Fee_Table__mdt feeRec : lstOfFeeRecords){
                        if(feeRec.Fee_Type__c.equalsIgnoreCase(System.label.Penalty_Fee) || (feeRec.Fee_Type__c.equalsIgnoreCase(System.label.License_Fee) && isStockCorp)){
                            if(feeRec.To_Year__c == null){
                                feeRec.To_Year__c = String.valueOf(system.today().year());
                            }
                            if(feeRec.To_Month__c == null){
                                feeRec.To_Month__c = (system.today().month());
                            }

                            Date fromDate = date.newinstance(Integer.valueof(feeRec.From_Year__c.trim()), Integer.valueof(feeRec.From_Month__c), 1);
                            Date toDate = date.newinstance(Integer.valueof(feeRec.To_Year__c.trim()), Integer.valueof(feeRec.To_Month__c), 1);
                                
                            if((newFI.Date_Began_Transacting_Business_in_CT__c >= fromDate && newFI.Date_Began_Transacting_Business_in_CT__c <= toDate) 
                            || (newFI.Registration_Date__c >= fromDate && newFI.Registration_Date__c <= toDate)
                            || (newFI.Registration_Date__c >= fromDate && newFI.Date_Began_Transacting_Business_in_CT__c <= toDate)){
                                Boolean noInsert = false;
                                Payment_Line_Item__c newLI = new Payment_Line_Item__c();
                                newLI.Case_Number__c = newFI.Id;
                                newLI.Fee_Type__c = feeRec.Fee_Type__c;
                                newLI.Start_Year__c = (newFI.Date_Began_Transacting_Business_in_CT__c >= fromDate && newFI.Date_Began_Transacting_Business_in_CT__c <= toDate) ? String.valueOf(newFI.Date_Began_Transacting_Business_in_CT__c.Year()) : feeRec.From_Year__c;
                                newLI.End_Year__c = (newFI.Registration_Date__c >= fromDate && newFI.Registration_Date__c <= toDate) ? String.valueOf(newFI.Registration_Date__c.Year()) : feeRec.To_Year__c;
                                newLI.Start_Month__c = (newFI.Date_Began_Transacting_Business_in_CT__c >= fromDate && newFI.Date_Began_Transacting_Business_in_CT__c <= toDate) ? (newFI.Date_Began_Transacting_Business_in_CT__c.Month()) : feeRec.From_Month__c;
                                newLI.End_Month__c = (newFI.Registration_Date__c >= fromDate && newFI.Registration_Date__c <= toDate) ? (newFI.Registration_Date__c.Month()) : feeRec.To_Month__c;
                                if((feeRec.Fee_Type__c.equalsIgnoreCase(System.label.License_Fee)) && (Integer.valueof(newLI.End_Year__c) == newFI.Registration_Date__c.Year())){
                                    if(newLI.End_Year__c == newLI.Start_Year__c){
                                        noInsert = true;
                                    }
                                    newLI.End_Year__c = String.valueOf(Integer.valueof(newLI.End_Year__c) - 1);
                                    newLI.End_Month__c  = 12;                                   
                                }
                                newLI.Penalty_Notes__c = feeRec.Fee_Notes__c;
                                newLI.Statue_Fee_Period__c = feeRec.Statue_Fee_Period__c;

                                Date startDate = date.newinstance(Integer.valueof(newLI.Start_Year__c.trim()), Integer.valueof(newLI.Start_Month__c), 1);
                                Date endDate = date.newinstance(Integer.valueof(newLI.End_Year__c.trim()), Integer.valueof(newLI.End_Month__c), 1);

                                if(!feeRec.Is_Monthly_Fee__c){
                                    newLI.Fee_Amount__c = (Integer.valueof(feeRec.Fee_Amount__c) * (Integer.valueof(newLI.End_Year__c) - Integer.valueof(newLI.Start_Year__c) + 1));
                                    newLI.Time__c = (Integer.valueof(newLI.End_Year__c) - Integer.valueof(newLI.Start_Year__c) + 1) + ' year';
                                    if((Integer.valueof(newLI.End_Year__c) - Integer.valueof(newLI.Start_Year__c) + 1) > 1){
                                        newLI.Time__c = newLI.Time__c + '(s)' ;
                                    }
                                }
                                else{
                                    newLI.Fee_Amount__c = (Integer.valueof(feeRec.Fee_Amount__c) * (startDate.monthsBetween(endDate) + 1));
                                    newLI.Time__c = (startDate.monthsBetween(endDate) + 1) + ' month';
                                    if((startDate.monthsBetween(endDate) + 1) > 1){
                                        newLI.Time__c = newLI.Time__c + '(s)' ;
                                    }
                                }
                                if(!noInsert){
                                    newLineItemsLst.add(newLI);
                                }
                            }
                        }
                    }
                }
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(newLineItemsLst, 'insert');
            if(!newLineItemsLst.IsEmpty() && accessCheck){
                insert newLineItemsLst;
            }
        }catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'createPaymentLineItems', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }     
    }

    /*************************************************************************************************
        METHOD NAME    : createBTPaymentSchedule
        DESCRIPTION    : Method to create Blackthorn Payment Schedule on Foreign Investigation that 
                         is marked for an Auto-pay after, the First Payment is made
        PARAMETER      : Map<Id,SObject>, Map<Id,SObject>
    ***************************************************************************************************/
    public static void createBTPaymentSchedule(Map<Id,SObject> newTriggerMap, Map<Id,SObject> oldTriggerMap) {
        Set<Id> setOfForeignInvIds = new Set<Id>();
        List<bt_stripe__Payment_Schedule__c> lstNewPaySchedule = new List<bt_stripe__Payment_Schedule__c>();
               
        try{
            List<Foreign_Investigation__c> lstNewTrigger = (List<Foreign_Investigation__c>) newTriggerMap.values();
            for(Foreign_Investigation__c fi : lstNewTrigger) {
                Foreign_Investigation__c oldFI = (Foreign_Investigation__c) oldTriggerMap.get(fi.Id);
                if (fi.Auto_payment_plan__c && fi.First_Payment_Done__c && 
                    (fi.Auto_payment_plan__c != oldFI.Auto_payment_plan__c || fi.First_Payment_Done__c != oldFI.First_Payment_Done__c)) {

                        setOfForeignInvIds.add(fi.Id);
                }
            }

            if(!setOfForeignInvIds.isEmpty()) {
                List<Work_Order__c> lstRelatedWO = [SELECT Id, (SELECT Id, bt_stripe__Related_Account__c, CreatedDate, bt_stripe__Related_Contact__c, 
                                                                        bt_stripe__Payment_Method__c, bt_stripe__Payment_Gateway__c 
                                                                FROM Transactions__r ORDER BY CreatedDate DESC LIMIT 1)
                                                    FROM Work_Order__c
                                                    WHERE Foreign_Investigation__c IN :setOfForeignInvIds
                                                    WITH SECURITY_ENFORCED
                                                    ORDER BY CreatedDate DESC
                                                    LIMIT 1];

                if(lstRelatedWO[0].Transactions__r.size() > 0) {
                    for(Id forInvId : setOfForeignInvIds) {
                        Foreign_Investigation__c newFI = (Foreign_Investigation__c) newTriggerMap.get(forInvId);
                        bt_stripe__Payment_Schedule__c newPaySchedule = new bt_stripe__Payment_Schedule__c();
                        newPaySchedule.bt_stripe__Preset__c = System.Label.Monthly_comparable;
                        newPaySchedule.bt_stripe__Status__c = System.Label.Generate_Comparable;
                        newPaySchedule.bt_stripe__Currency__c = 'USD';
                        newPaySchedule.bt_stripe__Each_Amount__c = newFI.Monthly_Payable__c;                    
                        newPaySchedule.bt_stripe__Count__c = newFI.Payment_Duration__c;
                        newPaySchedule.bt_stripe__Start_Date__c = newFI.Due_Date__c;
                        newPaySchedule.bt_stripe__Account__c = lstRelatedWO[0].Transactions__r[0].bt_stripe__Related_Account__c;             
                        newPaySchedule.bt_stripe__Contact__c = lstRelatedWO[0].Transactions__r[0].bt_stripe__Related_Contact__c;             
                        newPaySchedule.bt_stripe__Payment_Gateway__c = lstRelatedWO[0].Transactions__r[0].bt_stripe__Payment_Gateway__c;     
                        newPaySchedule.bt_stripe__Payment_Method__c = lstRelatedWO[0].Transactions__r[0].bt_stripe__Payment_Method__c;
                        newPaySchedule.Foreign_Investigation__c = forInvId;
                        newPaySchedule.bt_stripe__Auto_Capture__c = true; 
                        lstNewPaySchedule.add(newPaySchedule);
                    }
                    Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(lstNewPaySchedule, 'insert');
                    if(!lstNewPaySchedule.isEmpty() && bt_stripe__Payment_Schedule__c.SObjectType.getDescribe().isCreateable() && accessCheck) {
                        insert lstNewPaySchedule;
                    }
                } 
            }
        }
        catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'createBTPaymentSchedule', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }
    }

    /*************************************************************************************************
        METHOD NAME    : cancelPaymentSchedule
        DESCRIPTION    : Cancel Payment Schedule if Outstanding amount to be paid is zero or
                         outstanding amount is less than the scheduled monthly transaction amount.
        PARAMETER      : List<Foreign_Investigation__c>
    ***************************************************************************************************/
    public static void cancelPaymentSchedule(List<Foreign_Investigation__c> lstNewTrigger) {
        Set<Id> setOfForeignInvIds = new Set<Id>();
                                     
        try {
            for(Foreign_Investigation__c fi : lstNewTrigger) {
                if ((fi.Outstanding_Amount_Due__c == 0 && fi.Case_Status__c == System.Label.ClosedPaidinFull) || (fi.Outstanding_Amount_Due__c < fi.Monthly_Payable__c)) {
                    setOfForeignInvIds.add(fi.Id);
                }
            }

            if(!setOfForeignInvIds.isEmpty()) {
                List<bt_stripe__Payment_Schedule__c> lstPaymentSched = [SELECT Id, bt_stripe__Cancel_Payment_Schedule__c, Foreign_Investigation__c
                                                                        FROM bt_stripe__Payment_Schedule__c
                                                                        WHERE Foreign_Investigation__c IN :setOfForeignInvIds AND
                                                                            bt_stripe__Status__c != 'Canceled'
                                                                        WITH SECURITY_ENFORCED
                                                                        ORDER BY CreatedDate DESC
                                                                        LIMIT 1];

                if(!lstPaymentSched.isEmpty()) {
                    for(bt_stripe__Payment_Schedule__c paySch : lstPaymentSched) {
                        paySch.bt_stripe__Cancel_Payment_Schedule__c = true;
                    }
                    Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(lstPaymentSched, 'update');
                    if(bt_stripe__Payment_Schedule__c.SObjectType.getDescribe().isUpdateable() && accessCheck) {
                        update lstPaymentSched;
                    }
                } 
            }
        }
        catch (Exception ex) {
            BOS_Utility.ExceptionHandler(className, 'cancelPaymentSchedule', 'Foreign_Investigation__c', null, null, ex, ex.getMessage());
        }
    }
}