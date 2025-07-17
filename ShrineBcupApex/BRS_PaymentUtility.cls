/******************************************************************************************************
* NAME:         BRS_PaymentUtility
* DESCRIPTION:  Utility class for Payment related functionalities.
*
* @AUTHOR:      Tamaknat
* @DATE:        25th March 2021
*******************************************************************************************************/
public without sharing class BRS_PaymentUtility {
    
    public static Final String className = 'BRS_PaymentUtility';
    public static Final String getVoucherMethod = 'getVoucher';
    public static Final String checkBalanceForFiling = 'checkBalanceForFiling';
    public static Final String getFilingFees = 'getFilingFees';
    public static Final String createVoucherTransaction ='createTransaction';
    public static Final String getPaymentHistoryData ='getPaymentHistoryData';
    public static Final String sSeverity = 'High';
    public static final String EMPTY_STRING = '';
    
    
    /**********************************************************************************************
        METHOD NAME    : getVoucher
        DESCRIPTION    : Method to redeem existing voucher records by fetching and adding it in Customer Balance Transaction.
        PARAMETER      : String voucherCode
    ***********************************************************************************************/
    @AuraEnabled
    public static Voucher_Code_Master__c getVoucher(String voucherCode){
        List<Voucher_Code_Master__c> voucherDetailsList = new List<Voucher_Code_Master__c>();
        String voucherId;
        try{
            voucherDetailsList = [select Id,Name,Amount__c,End_Date__c,Status__c,Voucher_Code__c,Start_Date__c from Voucher_Code_Master__c 
                                  where Voucher_Code__c=: String.escapeSingleQuotes(voucherCode) and Status__c!=:System.Label.BRS_VoucherStatus_Redeemed and End_Date__c>Today WITH SECURITY_ENFORCED limit 1];
            if(voucherDetailsList.size()>0){
                voucherId=voucherDetailsList[0].Id;
                return voucherDetailsList[0];
            }else{
                voucherId=null;
                return null;
            }
            
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getVoucherMethod, 'Voucher_Code_Master__c', voucherId, BRS_PaymentUtility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**********************************************************************************************
    METHOD NAME    : redeemVoucher
    DESCRIPTION    : Method to redeem a voucher by adding a credit record in the customer balance trancsaction.
    PARAMETER      : String voucherCode,String workorderId, String filingId
    ***********************************************************************************************/
    @AuraEnabled
    public static String redeemVoucher(String voucherCode,String workorderId, String filingId){
        try {
            Customer_Balance_Transaction__c customerbalance = new Customer_Balance_Transaction__c();
            Voucher_Code_Master__c voucher = getVoucher(String.escapeSingleQuotes(voucherCode));
            if(voucher!=null){
                customerbalance = createTransaction(String.escapeSingleQuotes(workorderId), String.escapeSingleQuotes(filingId), voucher.Id,System.Label.BRS_Transaction_Type_Credit, System.Label.BRS_PaymentSource_Voucher,voucher.Amount__c);
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {customerbalance}, 'insert');
                if(customerbalance!=null && customerbalance.Amount__c!=0 && accessCheck){             
                	insert customerbalance;
                }
            }
            Voucher_Code_Master__c updatedVoucher = new Voucher_Code_Master__c();
            if(customerbalance.Id!=null){
                updatedVoucher = updateRedeemedVoucher(voucher);
                Boolean accessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {updatedVoucher}, 'update');
                if(updatedVoucher.Id!=null && accessCheck1){
                    update updatedVoucher;
                }
            }
            if(updatedVoucher.Id!=null){
                return updatedVoucher.Id;
            }else{
                return null;
            }
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'redeemVoucher', 'Work_order__c', workorderId, BRS_PaymentUtility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************************************************************
    METHOD NAME    : updateRedeemedVoucher
    DESCRIPTION    : Method to update Status and Date of the redeemed voucher.
    PARAMETER      : Voucher_Code_Master__c voucher
    ***********************************************************************************************/
    public static Voucher_Code_Master__c updateRedeemedVoucher(Voucher_Code_Master__c voucher){
        try {
            if(voucher!=null){
                voucher.Status__c = System.Label.BRS_VoucherStatus_Redeemed;
                voucher.End_Date__c = System.today();
            }
        } catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'updateRedeemedVoucher', 'Voucher_Code_Master__c', voucher.Id, BRS_PaymentUtility.sSeverity, e, null);
        }
        return voucher;
    }
    
    /**********************************************************************************************
    METHOD NAME    : getFilingFees
    DESCRIPTION    : Method to fetch current balance and applicable filing fees for Filing Fees screen.
    PARAMETER      : Id filingId, Id customerId, Id workorderId
    ***********************************************************************************************/
    @AuraEnabled
    public static FilingFeeWrapper getFilingFees(Id filingId, Id customerId, Id workorderId, Decimal feeAmount){
        try{
            Master_Fee__c masterFee = new Master_Fee__c();
            FilingFeeWrapper filingWrapper = new FilingFeeWrapper();
            filingWrapper.filingId = String.escapeSingleQuotes(filingId);
            String sObjName;
            if(filingId!=null){
                sObjName = filingId.getSObjectType().getDescribe().getName();
            }
            if(customerId!=null){
                Contact customer = [select Id,Total_Balance__c,Total_Voucher_Balance__c from Contact where Id=:String.escapeSingleQuotes(customerId) WITH SECURITY_ENFORCED];
                filingWrapper.customerBalance = customer.Total_Balance__c;
            }
            
            if(sObjName==System.Label.Business_Filing_API_Name){
                Business_Filing__c businessfiling = [SELECT Id,Type__c,Account__c,Filing_Fee__c,Franchise_Tax__c,Include_Expedited_Service__c,Expedited_Service_Fee__c,Account__r.Franchise_Tax__c,Work_Order__c FROM Business_Filing__c WHERE Id=: String.escapeSingleQuotes(filingId) WITH SECURITY_ENFORCED]; 
                if(businessfiling!=null){
                    filingWrapper.filingFee = businessfiling.Filing_Fee__c;
                    filingWrapper.showExpeditedFees = businessfiling.Include_Expedited_Service__c;
                    filingWrapper.expeditedFees = businessfiling.Include_Expedited_Service__c ? businessfiling.Expedited_Service_Fee__c.setScale(2):0;
                    if((businessfiling.Type__c==System.Label.Business_Formation_Label || businessfiling.Type__c==System.Label.Business_Registration_Label ||  businessfiling.Type__c== 'Conversion' || businessfiling.Type__c == System.Label.Domestication_Label) && (businessfiling.Account__r.Franchise_Tax__c!=null || businessfiling.Franchise_Tax__c !=null ) ){
                        Decimal frTax;
                        if(businessfiling.Account__r.Franchise_Tax__c!=null )
                        {
                        frTax= businessfiling.Account__r.Franchise_Tax__c;

                        filingWrapper.franchiseTax = frTax.setScale(2);
                        filingWrapper.showFranchiseTax = true;
                        Decimal totalfees = businessfiling.Include_Expedited_Service__c ?businessfiling.Filing_Fee__c + businessfiling.Account__r.Franchise_Tax__c+ businessfiling.Expedited_Service_Fee__c :businessfiling.Filing_Fee__c + businessfiling.Account__r.Franchise_Tax__c;
                        filingWrapper.totalfee = totalfees.setScale(2);
                        
                        }
                        else{
                            frTax= businessfiling.Franchise_Tax__c;

                            filingWrapper.franchiseTax = frTax.setScale(2);
                            filingWrapper.showFranchiseTax = true;
                            Decimal totalfees = businessfiling.Include_Expedited_Service__c ?businessfiling.Filing_Fee__c + businessfiling.Franchise_Tax__c+ businessfiling.Expedited_Service_Fee__c :businessfiling.Filing_Fee__c + businessfiling.Franchise_Tax__c;
                            filingWrapper.totalfee = totalfees.setScale(2);
                        }
                    }else{
                        filingWrapper.totalfee = businessfiling.Include_Expedited_Service__c ? businessfiling.Filing_Fee__c +  businessfiling.Expedited_Service_Fee__c : businessfiling.Filing_Fee__c ;
                    }
                    
                }
            }
            else if(sObjName==System.Label.BRS_Certficate_API_Name){
                Certficate__c certObj = [select id, Expedited_Service_Fee__c, Filing_Fee__c from Certficate__c where id =:filingId WITH SECURITY_ENFORCED Limit 1];
                if(certObj!=null){
                    
                    filingWrapper.filingFee = certObj.Filing_Fee__c.setScale(2);
                    Decimal totalfees =filingWrapper.filingFee;
                    if(certObj.Expedited_Service_Fee__c!=null && certObj.Expedited_Service_Fee__c!=0){
                        filingWrapper.showExpeditedFees = true;
                        filingWrapper.expeditedFees = certObj.Expedited_Service_Fee__c.setScale(2);
                        totalfees = totalfees + certObj.Expedited_Service_Fee__c;
                        
                    }
                    filingWrapper.totalfee = totalfees.setScale(2);
                    
                }
            }else{
                    filingWrapper.filingFee = feeAmount;
                    filingWrapper.totalfee = feeAmount;

            } 
            
            if(filingWrapper.customerBalance>=filingWrapper.totalfee){
                filingWrapper.balancededucted = filingWrapper.totalfee;
                filingWrapper.balanceremaining = filingWrapper.customerBalance - filingWrapper.totalfee;
                filingWrapper.finalAmount=0;
            }else if(filingWrapper.customerBalance<filingWrapper.totalfee){
                filingWrapper.balancededucted = filingWrapper.customerBalance;
                filingWrapper.balanceremaining =0;
                filingWrapper.finalAmount = filingWrapper.totalfee - filingWrapper.customerBalance;
            }
            
            if(workorderId!=null){
                Work_Order__c workorderRec = [select Id,Final_Amount_Payable__c,Total_Hold_Amount__c from Work_Order__c where Id=:String.escapeSingleQuotes(workorderId) WITH SECURITY_ENFORCED];
                workorderRec.Final_Amount_Payable__c = filingWrapper.finalAmount;
                workorderRec.Total_Hold_Amount__c = filingWrapper.totalfee;
                Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(new List<sobject> {workorderRec}, 'update');
                if(workorderRec.Id!=null && accessCheck){
                    update workorderRec;
                }
            }
            return filingWrapper;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getFilingFees, 'Filing', filingId, BRS_PaymentUtility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************************************************************
    METHOD NAME    : createTransaction
    DESCRIPTION    : Generic method to create transaction records in Customer Balance Transaction object.
    PARAMETER      : Id workorderId, Id filingId, Id voucherId, String transactionType, String source, Decimal amount
    ***********************************************************************************************/
    public static Customer_Balance_Transaction__c createTransaction(Id workorderId, Id filingId, Id voucherId, String transactionType, String source, Decimal amount){
        Customer_Balance_Transaction__c customerbalance = new Customer_Balance_Transaction__c();
        try{
            User currentUser =[select Id, ContactId from User where Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            customerbalance.Amount__c = amount;
            customerbalance.Payment_Source__c = source;
            customerbalance.Contact__c=currentUser.ContactId;
            customerbalance.Type__c=transactionType;
            customerbalance.Status__c=System.Label.BRS_Transaction_Status;
            customerbalance.Start_Date__c = System.today();
            customerbalance.Transaction_Date_Time__c = System.now();
            if(voucherId!=null){
                customerbalance.Voucher__c=voucherId;
            }
            if(workorderId!=null){
            customerbalance.Work_Order__c = workorderId;
            }
            if(filingId!=null){
                Schema.SObjectType objType = filingId.getSObjectType();
                if(objType == Schema.UCC_Filing__c.getSObjectType()){
                    customerbalance.UCC_Filing__c = filingId;
                }else if(objType == Schema.Business_Filing__c.getSObjectType()){
                    customerbalance.Business_Filing__c = filingId;
                }else if(objType == Schema.Certficate__c.getSObjectType()){
                    customerbalance.Certificate__c = filingId;
                }else if(objType == Schema.Foreign_Investigation__c.getSObjectType()){
                    customerbalance.Foreign_Investigation__c = filingId;
                }
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, createVoucherTransaction, 'Work_order__c', workorderId, BRS_PaymentUtility.sSeverity, e, null);
        }
        
        return customerbalance;
    }
    
     /**********************************************************************************************
    METHOD NAME    : createDebitRecordsForOnlineFiling
    DESCRIPTION    : Create debit records for online filing after the payment through terminal is succesful.
    PARAMETER      : Id workorderId, Id filingId
    ***********************************************************************************************/
    @AuraEnabled
    public static void createDebitRecordsForOnlineFiling(Id workorderId, Id filingId){
        string workOrder = String.escapeSingleQuotes(workorderId);
        string filingIdString = String.escapeSingleQuotes(filingId);
        try{
            List<Customer_Balance_Transaction__c> insertCBTList = new List<Customer_Balance_Transaction__c>();
            Work_Order__c workorderRec = new Work_Order__c();
            if(workOrderId!=null){
                workorderRec=[select Id,Final_Amount_Payable__c,Total_Hold_Amount__c,Total_Check_Balance__c,Total_Voucher_Balance__c,Total_Direct_Balance__c,Total_Card_Balance__c,Trademark_Balance__c,Total_ACH_Balance__c  from Work_Order__c where Id=:workOrder WITH SECURITY_ENFORCED];
            }
            if(workorderRec.Total_Voucher_Balance__c>0){
                Customer_Balance_Transaction__c voucherDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Voucher,workorderRec.Total_Voucher_Balance__c);
                if(voucherDebit!=null){
                    insertCBTList.add(voucherDebit);
                }
            }
            if(workorderRec.Total_Check_Balance__c>0){
                Customer_Balance_Transaction__c checkDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Check,workorderRec.Total_Check_Balance__c);
                if(checkDebit!=null){
                    insertCBTList.add(checkDebit);
                }
            }
			if(workorderRec.Total_Direct_Balance__c>0){
                Customer_Balance_Transaction__c directDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Direct,workorderRec.Total_Direct_Balance__c);
                if(directDebit!=null){
                    insertCBTList.add(directDebit);
                }
            }
            if(workorderRec.Total_Card_Balance__c>0){
                Customer_Balance_Transaction__c cardDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Card,workorderRec.Total_Card_Balance__c);
                if(cardDebit!=null){
                    insertCBTList.add(cardDebit);
                }
            }
            if(workorderRec.Trademark_Balance__c>0){
                Customer_Balance_Transaction__c trademarkDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Trademark,workorderRec.Trademark_Balance__c);
                if(trademarkDebit!=null){
                    insertCBTList.add(trademarkDebit);
                }
            }
            if(workorderRec.Total_ACH_Balance__c>0){
                Customer_Balance_Transaction__c achDebit = createTransaction(workOrder, filingIdString, null,System.Label.BRS_Transaction_Type_Debit, 'ACH Payment',workorderRec.Total_ACH_Balance__c);
                if(achDebit!=null){
                    insertCBTList.add(achDebit);
                }
            }
            Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(insertCBTList, 'insert');   
            if(insertCBTList.size()>0 && accessCheck){
                insert insertCBTList;
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, 'createDebitRecordsForOnlineFiling', 'Work_order__c', workOrder, BRS_PaymentUtility.sSeverity, e, null);
        }
    }
    
    /**********************************************************************************************
        METHOD NAME    : getPaymentHistoryData
        DESCRIPTION    : Method to fetch the transactions of the user to be displayed on payment history page.
        PARAMETER      : N/A
    ***********************************************************************************************/
    @AuraEnabled
    public static DataTable getPaymentHistoryData(Date fromDate, Date toDate){
        Map<String,String>  labelMaps =ctds_flowStages.getAppLabels();
        Set<Id> workorderIds = new Set<Id>();
        Map<Id,String> workorderFilingTypeMap = new Map<Id,String>();
        Map<Id,String> workorderFilingNumberMap = new Map<Id,String>();
        User currentUser =[select Id, ContactId,Contact.Total_Voucher_Balance__c,Contact.Total_Balance__c  from User where Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        try{
            List<BRS_Utility.ColumnsWrapper> paymentHistoryColumns = new List<BRS_Utility.ColumnsWrapper>();
            List<TableDataWrapper> paymentHistoryList = new List<TableDataWrapper>();
            List<Customer_Balance_Transaction__c> transactionList = [SELECT Id, Name, Payment_Source__c, Amount__c, Status__c, Start_Date__c,Transaction_Date_Time__c, Type__c, Work_Order__c,Work_Order__r.Name, Contact__c, Voucher__c, Payment_Method__c,Business_Filing__c,Business_Filing__r.Name, UCC_Filing__c,UCC_Filing__r.Name, Certificate__c,Certificate__r.Name, Foreign_Investigation__c, Foreign_Investigation__r.Name, Filing_Type__c,Filing_Number__c FROM Customer_Balance_Transaction__c where Contact__c=:currentUser.ContactId  WITH SECURITY_ENFORCED order by Transaction_Date_Time__c DESC limit 10000];
            List<bt_stripe__Transaction__c> btTransactionList=[select Id,Work_Order__c,Work_Order__r.Name,bt_stripe__Refund__c,bt_stripe__Amount__c,bt_stripe__Transaction_Status__c,bt_stripe__Processed_Date__c,bt_stripe__Payment_Status__c
                                                               from bt_stripe__Transaction__c where bt_stripe__Related_Contact__c =:currentUser.ContactId  WITH SECURITY_ENFORCED order by bt_stripe__Processed_Date__c DESC limit 10000];
            List<BRS_Payment_History_Table_Column__mdt> tableColumnsList = [select Id,MasterLabel,DeveloperName,Type__c,Order__c from BRS_Payment_History_Table_Column__mdt Order By Order__c limit 100];
            
            if(btTransactionList.size()>0){
                for(bt_stripe__Transaction__c bttran: btTransactionList){
                    workorderIds.add(bttran.Work_Order__c);
                }
            }
            if(!transactionList.isEmpty()){
                for(Customer_Balance_Transaction__c cbt: transactionList){
                    workorderIds.add(cbt.Work_Order__c);
                }
            }
                
                if(workorderIds.size()>0){
                    List<Work_Order__c> workOrderList = [select Id,Total_Hold_Amount__c,(select Id,Name,Filing_Number__c from Business_Filings__r),(select Id,Name,Filing_Number__c from UCC_Filings__r), (SELECT Id, Name FROM Certficates__r) from Work_Order__c where Id IN :workOrderIds WITH SECURITY_ENFORCED];
                    if(workOrderList.size()>0){
                        for(Work_Order__c workorder: workOrderList){
                            if(workorder.Business_Filings__r.size()>0){
                                workorderFilingTypeMap.put(workorder.Id,System.Label.Business_Label);
                                String filingNumber = workorder.Business_Filings__r[0].Filing_Number__c.stripHtmlTags();
                                workorderFilingNumberMap.put(workorder.Id,filingNumber);
                            }else if(workorder.UCC_Filings__r.size()>0){
                                workorderFilingTypeMap.put(workorder.Id,System.Label.UCC_Label);
                                workorderFilingNumberMap.put(workorder.Id,workorder.UCC_Filings__r[0].Filing_Number__c);
                            }else if(workorder.Certficates__r.size()>0){
                                workorderFilingTypeMap.put(workorder.Id,System.Label.Certificate_Label);
                                String certificates;
                                List<String> certNames = new List<String>();
                                for(Certficate__c cert:workorder.Certficates__r){
                                    certNames.add(cert.Name);
                                }
                                certificates = String.join(certNames,', ');
                                workorderFilingNumberMap.put(workorder.Id,certificates);
                            }
                        }
                    }
                }
            
            
            for(Customer_Balance_Transaction__c transactionRec: transactionList){
                    TableDataWrapper tableRow = new TableDataWrapper();
                    Date dt =  transactionRec.Start_Date__c;
                    if(dt!=null){
                        DateTime dtime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                        String fieldValue = dtime.format('MM/dd/yyyy');
                        tableRow.transactionDate = fieldValue;
                    }
                    tableRow.transactionDateFinal = transactionRec.Start_Date__c;
                    tableRow.transactionDateTime = transactionRec.Transaction_Date_Time__c;
                    tableRow.transactionType =transactionRec.Payment_Source__c +' '+ transactionRec.Type__c;
                    tableRow.workorderId = transactionRec.Work_Order__r.Name;
                    tableRow.amount=transactionRec.Amount__c;
                    if(transactionRec.Status__c ==System.Label.Complete_Comparable){
                        tableRow.status=System.Label.BRS_Transaction_Status_Complete;
                        System.debug('@Complete '+tableRow.status);
                    }
                    else
                    {
                        tableRow.status=transactionRec.Status__c;
                    }
                    if(transactionRec.Status__c==System.Label.BRS_Transaction_Status_RefundProgress){
                        tableRow.status=System.Label.In_Progress_Label;
                        tableRow.transactionType =System.Label.BRS_Transaction_Type_Refund;
                    }else if(transactionRec.Status__c==System.Label.BRS_Transaction_Status_Refunded){
                        tableRow.status=System.Label.BRS_Transaction_Status_Complete;
                        tableRow.transactionType =System.Label.BRS_Transaction_Type_Refund;
                    }
                    if(transactionRec.Filing_Number__c!=null){
                        tableRow.filingType =transactionRec.Filing_Type__c;
                        tableRow.filingNumber =transactionRec.Filing_Number__c;
                    }else if(workorderFilingNumberMap.keySet().contains(transactionRec.Work_Order__c) && workorderFilingTypeMap.keySet().contains(transactionRec.Work_Order__c)){
                        tableRow.filingType =workorderFilingTypeMap.get(transactionRec.Work_Order__c);
                        tableRow.filingNumber =workorderFilingNumberMap.get(transactionRec.Work_Order__c);
                    }
                    if(tableRow.status == System.Label.In_Progress_Label){
                        tableRow.status = System.Label.accountDashboard_InProgress;
                    }
                    if(tableRow.filingType == System.Label.FR_Comparable){
                        tableRow.filingType = System.Label.First_Report_Filing;
                    }
                    if(tableRow.filingType == System.Label.FI_Penalty_Comparable){
                        tableRow.filingType = System.Label.FI_Penalty;
                    }
                if(fromDate==null && toDate==null) {
                    paymentHistoryList.add(tableRow);
                }else if(fromDate!=null && toDate!=null){
                    if(tableRow.transactionDateFinal>=Date.valueOf(fromDate) && tableRow.transactionDateFinal<=Date.valueOf(toDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }else if(fromDate!=null){
                    if(tableRow.transactionDateFinal>=Date.valueOf(fromDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }else if(toDate!=null){
                    if(tableRow.transactionDateFinal<=Date.valueOf(toDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }
            }
            for(bt_stripe__Transaction__c bttransaction: btTransactionList){
                
                    TableDataWrapper tableRow = new TableDataWrapper();

                    tableRow.transactionDateFinal = Date.valueOf(bttransaction.bt_stripe__Processed_Date__c);
                    tableRow.transactionDateTime = bttransaction.bt_stripe__Processed_Date__c;
                    if(bttransaction.bt_stripe__Processed_Date__c!=null){
                        String fieldValue = bttransaction.bt_stripe__Processed_Date__c.format('MM/dd/yyyy');
                        tableRow.transactionDate = fieldValue;
                    }
                    tableRow.transactionType =System.Label.BRS_Card_Payment;
                    tableRow.workorderId = bttransaction.Work_Order__r.Name;
                    tableRow.amount=bttransaction.bt_stripe__Amount__c;
                    tableRow.status=bttransaction.bt_stripe__Transaction_Status__c; 
                    if(bttransaction.bt_stripe__Transaction_Status__c ==System.Label.BRS_Transaction_Status_Completed){
                        tableRow.status=System.Label.BRS_Transaction_Status_Complete;
                    }
                    if(bttransaction.bt_stripe__Payment_Status__c==System.Label.BRS_Transaction_Status_Refunded){
                        tableRow.status=System.Label.BRS_Transaction_Status_Complete;
                        tableRow.transactionType =System.Label.BRS_Transaction_Type_Refund;
                    }
                    if(workorderFilingTypeMap.keySet().contains(bttransaction.Work_Order__c)){
                        tableRow.filingType =workorderFilingTypeMap.get(bttransaction.Work_Order__c);
                    }
                    if(workorderFilingNumberMap.keySet().contains(bttransaction.Work_Order__c)){
                        tableRow.filingNumber =workorderFilingNumberMap.get(bttransaction.Work_Order__c);
                    }
                if(fromDate==null && toDate==null) {
                    paymentHistoryList.add(tableRow);
                }else if(fromDate!=null && toDate!=null){
                    if(tableRow.transactionDateFinal>=Date.valueOf(fromDate) && tableRow.transactionDateFinal<=Date.valueOf(toDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }else if(fromDate!=null){
                    if(tableRow.transactionDateFinal>=Date.valueOf(fromDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }else if(toDate!=null){
                    if(tableRow.transactionDateFinal<=Date.valueOf(toDate)){
                        paymentHistoryList.add(tableRow);
                    }
                }
            }
            for(BRS_Payment_History_Table_Column__mdt columnMtd: tableColumnsList){
                BRS_Utility.ColumnsWrapper column = new BRS_Utility.ColumnsWrapper();
                column.fieldName = columnMtd.DeveloperName;
                //column.label=columnMtd.MasterLabel;
                column.label = labelMaps.containsKey(columnMtd.MasterLabel)?labelMaps.get(columnMtd.MasterLabel):columnMtd.MasterLabel;
                column.type =columnMtd.Type__c;
                paymentHistoryColumns.add(column);
            }

            DataTable dtable = new DataTable();
            dtable.tableColumns = paymentHistoryColumns;
            dtable.tableData = paymentHistoryList;
            dtable.currentBalance = currentUser.Contact.Total_Balance__c;
            return dtable;
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, getPaymentHistoryData, 'Contact', currentUser.ContactId, BRS_PaymentUtility.sSeverity, e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************************************************************
    METHOD NAME    : rollUpFilingFees
    DESCRIPTION    : Method to sum up all the filing fees on work order.
    PARAMETER      : List<sObject> newFilings -- List of new filings(UCC/Business Filings)
    ***********************************************************************************************/
    public static void rollUpFilingFees(List<sObject> newFilings){
        List<Work_Order__c> workOrderUpdateList = new List<Work_Order__c>();
        Set<Id> workOrderIds = new Set<Id>();
        Boolean isMCD = false;

        try{ 
        for(SObject sobj : newFilings) {
            switch on sobj {
                when Business_Filing__c businessFiling {
                    if(sobj.get('Status__c') !='Submitted - Agent acceptance pending' && sobj.get('Status__c') !='Rejected'){
                        workOrderIds.add(businessfiling.Work_Order__c);
                    }
                }

                when UCC_Filing__c uccFiling {
                    workOrderIds.add(uccfiling.Work_Order__c);
                }

                when Certficate__c otherRequest {
                    workOrderIds.add(otherRequest.Work_Order__c);
                }

                when Mark_Filing__c markFiling {
                    workOrderIds.add(markFiling.Work_Order__c);
                }

                when WRIT_Case__c writ {
                    workOrderIds.add(writ.Work_Order__c);
                }
            }
        }
        if(!workOrderIds.isEmpty()){
            Decimal totalFeePayable=0;
            
            for(Work_Order__c workorder : [
                SELECT Id,Total_Hold_Amount__c,Source__c,
                    (
                        SELECT Id,Total_Fee__c,Status__c,Type__c,Source__c
                        FROM Business_Filings__r
                    ),
                    (
                        SELECT Id,Amount__c,Status__c,Filing_Source__c
                        FROM UCC_Filings__r
                    ), 
                    (

                        SELECT id,Total_Fee__c, Filing_Fee__c ,Status__c 

                        FROM Certficates__r
                    ), 
                    (
                        SELECT id, Filing_Fee__c,Status__c 
                        FROM Mark_Filings__r
                    ), 
                    (
                        SELECT id, Filing_Fee__c,Status__c 
                        FROM WRIT_Cases__r
                    ) 
                FROM Work_Order__c 
                WHERE Id IN :workOrderIds WITH SECURITY_ENFORCED
            ]) {
                Decimal totalFilingFee=0;
                Decimal businessFilingAmt =0;
                Decimal uccAmt =0;
                
                for(UCC_Filing__c filing:workorder.UCC_Filings__r){
                    if(filing.Amount__c!=null){
                        totalFilingFee+=filing.Amount__c;
                        if(filing.Status__c==System.Label.Approved) {
                            totalFeePayable+=filing.Amount__c;
                        }
                    }
                }
                
                for(Business_Filing__c filing:workorder.Business_Filings__r) {
                    if(filing.Type__c.containsIgnoreCase(System.label.MassAgentChangeLabel)) {
                        totalFilingFee = workorder.Total_Hold_Amount__c;
                        if(filing.Status__c==System.Label.Approved){
                            totalFeePayable = workorder.Total_Hold_Amount__c;
                        }
                    }
                    else if(filing.Total_Fee__c!=null){
                        totalFilingFee+=filing.Total_Fee__c;
                        if(filing.Status__c==System.Label.Approved){
                            totalFeePayable+=filing.Total_Fee__c;
                        }
                    }

                    if(filing.Type__c != null && filing.Type__c== System.Label.Domestication_Label || filing.Type__c== System.Label.Conversion_Label || filing.Type__c== System.Label.Merger_Label){
                        isMCD = true;
                    }
                }
                
                for(Certficate__c filing:workorder.Certficates__r) {
                    if(filing.Total_Fee__c != null) {
                        totalFilingFee += filing.Total_Fee__c;
                        if(filing.Status__c == System.Label.Approved) {
                            totalFeePayable += filing.Total_Fee__c;
                        }
                    }
                }
                
                for(Mark_Filing__c filing:workorder.Mark_Filings__r) {
                    if(filing.Filing_Fee__c!=null){
                        totalFilingFee+=filing.Filing_Fee__c;
                        if(filing.Status__c==System.Label.Approved){
                            totalFeePayable+=filing.Filing_Fee__c;
                        }
                    }
                }
                
                for(WRIT_Case__c filing: workorder.WRIT_Cases__r) {
                    if(filing.Filing_Fee__c!=null){
                        totalFilingFee+=filing.Filing_Fee__c;
                        totalFeePayable+=filing.Filing_Fee__c;
                    }
                }
                
                workorder.Total_Hold_Amount__c=totalFilingFee;
                if(workorder.Source__c!=System.Label.brs_FilingOnline && workorder.Source__c!=System.Label.brs_FilingAPI && workorder.Source__c != System.Label.Source_Digital_Mail_Comparable){
                    workorder.Final_Amount_Payable__c=totalFeePayable;
                }
                workOrderUpdateList.add(workorder);
            }
        }
        Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(workOrderUpdateList, 'update');
        if(workOrderUpdateList.size()>0 && accessCheck){
            update workOrderUpdateList;
            if(isMCD == true)
                QnA_CheckRecursive.setrunWorkorderOnce();
        }

        } catch(Exception e){
            
            BOS_Utility.ExceptionHandler(className, 'rollUpFilingFees', 'Work_Order__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }
    }
    
    /**********************************************************************************************
    METHOD NAME    : refundForRejectedFilings
    DESCRIPTION    : Method to refund voucher/check for online payments
    PARAMETER      : List<SObject> newFilings, Map<Id,SObject> oldFilings
    ***********************************************************************************************/
    
    public static void refundForRejectedFilings(List<SObject> newFilings, Map<Id,SObject> oldFilings){
        Set<Id> businessFilingIds = new Set<Id>();
        Set<Id> uccFilingIds = new Set<Id>();
        Set<Id> otherReqIds = new Set<Id>();
        Map<Id,List<Customer_Balance_Transaction__c>> filingIdVstransactionMap = new Map<Id,List<Customer_Balance_Transaction__c>>();
        List<Customer_Balance_Transaction__c> cloneRecords = new List<Customer_Balance_Transaction__c>();
        List<Customer_Balance_Transaction__c> insertTransactions = new List<Customer_Balance_Transaction__c>();
        List<Customer_Balance_Transaction__c> partialReundRecordsBF = new List<Customer_Balance_Transaction__c>();
        List<Customer_Balance_Transaction__c> partialReundRecordsOtherReq = new List<Customer_Balance_Transaction__c>();

        for(sObject sobj: newFilings){
            String objName = sobj.getSObjectType().getDescribe().getName();
            if(sobj.get('Status__c') == 'Rejected'){
            if(objName==System.Label.BRS_UCCFilingObject){
                UCC_Filing__c uccfiling = (UCC_Filing__c)sobj;
                uccFilingIds.add(uccfiling.Id);
            }else if(objName== System.Label.Business_Filing_API_Name){
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                businessFilingIds.add(businessfiling.Id);
            }else if(objName== System.Label.Other_Request_API_Name){
                Certficate__c othReq = (Certficate__c)sobj;
                otherReqIds.add(othReq.Id);
            }
        }
        }
		
		Map<Id,String> otherReqSourceMap = new Map<Id,String>();
        if(!otherReqIds.isEmpty()){
            List<Certficate__c> otherReqWithWOList = [Select Id, Work_Order__c, Work_Order__r.Source__c from Certficate__c where Id In:otherReqIds WITH SECURITY_ENFORCED];
            for(Certficate__c otr: otherReqWithWOList){
                otherReqSourceMap.put(otr.Id,otr.Work_Order__r.Source__c);
            }
        }

        if(!businessFilingIds.isEmpty() ||!uccFilingIds.isEmpty() ||!otherReqIds.isEmpty()  ){
        List<Customer_Balance_Transaction__c> debitTransactionList = [SELECT Id,Amount__c,Business_Filing__c,Contact__c,Payment_Method__c,Certificate__c,
        Payment_Source__c,Refund_Date__c,Status__c,Type__c,UCC_Filing__c,Work_Order__c,Start_Date__c,Transaction_Date_Time__c FROM Customer_Balance_Transaction__c 
        WHERE Type__c=:System.Label.BRS_Transaction_Type_Debit and (Business_Filing__c IN:businessFilingIds OR UCC_Filing__c IN:uccFilingIds OR Certificate__c IN:otherReqIds) WITH SECURITY_ENFORCED];

        for(Customer_Balance_Transaction__c cbt: debitTransactionList){
            if(filingIdVstransactionMap.keySet().contains(cbt.Business_Filing__c)){
                filingIdVstransactionMap.get(cbt.Business_Filing__c).add(cbt);
            }else if(filingIdVstransactionMap.keySet().contains(cbt.UCC_Filing__c)){
                filingIdVstransactionMap.get(cbt.UCC_Filing__c).add(cbt);
            }else if(filingIdVstransactionMap.keySet().contains(cbt.Certificate__c)){
                filingIdVstransactionMap.get(cbt.Certificate__c).add(cbt);
            }else{
                if(cbt.Business_Filing__c!=null){
                    filingIdVstransactionMap.put(cbt.Business_Filing__c, new List<Customer_Balance_Transaction__c>{cbt});
                }else if(cbt.UCC_Filing__c!=null){
                    filingIdVstransactionMap.put(cbt.UCC_Filing__c, new List<Customer_Balance_Transaction__c>{cbt});
                }
                else if(cbt.Certificate__c!=null){
                    filingIdVstransactionMap.put(cbt.Certificate__c, new List<Customer_Balance_Transaction__c>{cbt});
                }
            }
        }

        for(sObject sobj: newFilings){
            String objName = sobj.getSObjectType().getDescribe().getName();
            if(objName==System.Label.BRS_UCCFilingObject){
                UCC_Filing__c uccfiling = (UCC_Filing__c)sobj;
                UCC_Filing__c oldFiling = (UCC_Filing__c)oldFilings.get(uccfiling.Id);
                if(uccfiling.Status__c!=oldFiling.Status__c && uccfiling.Status__c==System.Label.Rejected && uccfiling.Filing_Source__c==System.Label.brs_FilingOnline){
                    if(filingIdVstransactionMap.keySet().contains(uccfiling.Id)){
                        List<Customer_Balance_Transaction__c> debitTransactions = filingIdVstransactionMap.get(uccfiling.Id);
                        cloneRecords.addAll(debitTransactions);
                    }
                }
            }else if(objName== System.Label.Business_Filing_API_Name){
                Business_Filing__c businessfiling = (Business_Filing__c)sobj;
                Business_Filing__c oldBusinessFiling = (Business_Filing__c)oldFilings.get(businessfiling.Id);
                if(businessfiling.Status__c!=oldBusinessFiling.Status__c && businessfiling.Status__c==System.Label.Rejected && (businessfiling.Source__c==System.Label.brs_FilingOnline || businessfiling.Source__c=='Digital Mail')){
                    if(filingIdVstransactionMap.keySet().contains(businessfiling.Id)){
                        List<Customer_Balance_Transaction__c> debitTransactions = filingIdVstransactionMap.get(businessfiling.Id);
                        Decimal sumDebited = 0;
                        if(businessfiling.Include_Expedited_Service__c==true && !debitTransactions.isEmpty()){
                            Decimal expeditedFeeToRetain = businessfiling.Expedited_Service_Fee__c;
                            partialReundRecordsBF = createPartialRefunds(expeditedFeeToRetain, debitTransactions);
                        }
                        else if(!debitTransactions.isEmpty()){
                            cloneRecords.addAll(debitTransactions);
                        }
                    }
                }
            }else if(objName== System.Label.Other_Request_API_Name){
                Certficate__c otherReq = (Certficate__c)sobj;
                Certficate__c oldOtherReq = (Certficate__c)oldFilings.get(otherReq.Id);
                if(otherReq.Status__c!=oldOtherReq.Status__c && otherReq.Status__c==System.Label.Rejected && (otherReqSourceMap.keySet().contains(otherReq.Id) && otherReqSourceMap.get(otherReq.Id)==System.Label.brs_FilingOnline)){
                    if(filingIdVstransactionMap.keySet().contains(otherReq.Id)){
                        List<Customer_Balance_Transaction__c> debitTransactions = filingIdVstransactionMap.get(otherReq.Id);
                        Decimal sumDebited = 0;
                        if(otherReq.Include_Expedited_Service__c==true && !debitTransactions.isEmpty()){
                            Decimal expeditedFeeToRetain = otherReq.Expedited_Service_Fee__c;
                            partialReundRecordsOtherReq = createPartialRefunds(expeditedFeeToRetain, debitTransactions);
                        }
                        else if(!debitTransactions.isEmpty()){
                            cloneRecords.addAll(debitTransactions);
                        }
                    }
                }
            }
        }
		
		if(!partialReundRecordsBF.isEmpty()){
            insertTransactions.addAll(partialReundRecordsBF);
        }
        if(!partialReundRecordsOtherReq.isEmpty()){
            insertTransactions.addAll(partialReundRecordsOtherReq);
        }

        if(cloneRecords.size()>0){
            for(Customer_Balance_Transaction__c cbt: cloneRecords){
                Customer_Balance_Transaction__c cbtClone = cbt.clone();
                cbtClone.Start_Date__c=System.today();
                cbtClone.Transaction_Date_Time__c=System.now();
                cbtClone.Type__c=System.Label.BRS_Transaction_Type_Credit;
                cbtClone.Status__c=System.label.BRS_PaymentStatus_Refunded;
                insertTransactions.add(cbtClone);
            }
        }
        if(insertTransactions!=null && !insertTransactions.isEmpty()){
            insert insertTransactions;
        }
    }
    }
	
	/**********************************************************************************************
    METHOD NAME    : createPartialRefunds
    DESCRIPTION    : Method to create credit records for partial refunds based on the amount to be retained 
                    in case of Expedited service fee.
    PARAMETER      : Decimal expeditedFeeToRetain, List<Customer_Balance_Transaction__c> existingDebitTransactions
    ***********************************************************************************************/
    public static List<Customer_Balance_Transaction__c> createPartialRefunds(Decimal expeditedFeeToRetain, List<Customer_Balance_Transaction__c> debitTransactions){
        List<Customer_Balance_Transaction__c> insertTransactions = new List<Customer_Balance_Transaction__c>();
        for(Customer_Balance_Transaction__c balDeducted: debitTransactions){
            Customer_Balance_Transaction__c refundRecords = new Customer_Balance_Transaction__c();
            refundRecords.Start_Date__c=System.today();
            refundRecords.Transaction_Date_Time__c=System.now();
            refundRecords.Type__c=System.Label.BRS_Transaction_Type_Credit;
            refundRecords.Status__c=System.label.BRS_PaymentStatus_Refunded;
            refundRecords.Work_Order__c = balDeducted.Work_Order__c;
            refundRecords.Contact__c = balDeducted.Contact__c;
            refundRecords.Payment_Source__c = balDeducted.Payment_Source__c;
            if(balDeducted.Business_Filing__c!=null){
                refundRecords.Business_Filing__c = balDeducted.Business_Filing__c;
            }else if(balDeducted.Certificate__c!=null){
                refundRecords.Certificate__c = balDeducted.Certificate__c;
            }
            
            if(balDeducted.Payment_Source__c=='Trademark Balance'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){                                        
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }
            if(balDeducted.Payment_Source__c=='Voucher'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }
            if(balDeducted.Payment_Source__c=='Direct'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }
            if(balDeducted.Payment_Source__c=='Check'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }
            if(balDeducted.Payment_Source__c=='Card'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }
            if(balDeducted.Payment_Source__c=='ACH Payment'){
                if(balDeducted.Amount__c>expeditedFeeToRetain){                                        
                    refundRecords.Amount__c = balDeducted.Amount__c-expeditedFeeToRetain;
                    expeditedFeeToRetain = 0;
                }else{
                    expeditedFeeToRetain = expeditedFeeToRetain - balDeducted.Amount__c;
                }
            }

            if( refundRecords.Amount__c>0){
                insertTransactions.add(refundRecords);
            } 
        }
        return insertTransactions;
    }

    
/**********************************************************************************************
    METHOD NAME    : refundForRejectedFilings
    DESCRIPTION    : Method to refund voucher/check for online payments
    PARAMETER      : List<SObject> newFilings, Map<Id,SObject> oldFilings
    ***********************************************************************************************/
    
   /* public static void refundForRejectedMarkFilings(List<SObject> newFilings, Map<Id,SObject> oldFilings){
        Set<Id> rejectedRegistrationMarkIds = new Set<Id>();
        Set<Id> markFilingIds = new Set<Id>();
        List<Mark_Filing__c> rejectedRegistration = new List<Mark_Filing__c>();
        Map<Id,List<Customer_Balance_Transaction__c>> filingIdVstransactionMap = new Map<Id,List<Customer_Balance_Transaction__c>>();
        List<Customer_Balance_Transaction__c> cloneRecords = new List<Customer_Balance_Transaction__c>();
        List<Customer_Balance_Transaction__c> insertTransactions = new List<Customer_Balance_Transaction__c>();

        for(sObject sobj: newFilings){
        
            Mark_Filing__c  markfiling = (Mark_Filing__c)sobj;
                 Mark_Filing__c oldFiling = (Mark_Filing__c)oldFilings.get(markfiling.Id);
if(markfiling.Filing_Type__c == 'Registration' && markfiling.Status__c == 'Rejected' && oldFiling.status__c != markfiling.Status__c){
    rejectedRegistration.add(markfiling);
    rejectedRegistrationMarkIds.add(markfiling.Id);
}else if( markfiling.Status__c == 'Rejected' && oldFiling.status__c != markfiling.Status__c){

                markFilingIds.add(markfiling.Id);
}
        }

        List<Customer_Balance_Transaction__c> debitTransactionList = [select Id,Amount__c,Business_Filing__c,Contact__c,Payment_Method__c,Mark_Filing__c,
        Payment_Source__c,Refund_Date__c,Status__c,Type__c,UCC_Filing__c,Voucher__c,Work_Order__c,Start_Date__c,Transaction_Date_Time__c from Customer_Balance_Transaction__c 
        where Type__c=:System.Label.BRS_Transaction_Type_Debit AND  Mark_Filing__c IN :markFilingIds];

        for(Customer_Balance_Transaction__c cbt: debitTransactionList){
            if(filingIdVstransactionMap.keySet().contains(cbt.Mark_Filing__c)){
                filingIdVstransactionMap.get(cbt.Mark_Filing__c).add(cbt);
            }else{
                if(cbt.Mark_Filing__c!=null){
                    filingIdVstransactionMap.put(cbt.Mark_Filing__c, new List<Customer_Balance_Transaction__c>{cbt});
                }
                
            }
        }

        for(sObject sobj: newFilings){
           
                Mark_Filing__c businessfiling = (Mark_Filing__c)sobj;
                Mark_Filing__c oldBusinessFiling = (Mark_Filing__c)oldFilings.get(businessfiling.Id);
                if(businessfiling.Status__c!=oldBusinessFiling.Status__c && businessfiling.Status__c==System.Label.Rejected ){
                    if(filingIdVstransactionMap.keySet().contains(businessfiling.Id)){
                        List<Customer_Balance_Transaction__c> debitTransactions = filingIdVstransactionMap.get(businessfiling.Id);
                        cloneRecords.addAll(debitTransactions);
                    }
                }
           
        }

        if(cloneRecords.size()>0){
            for(Customer_Balance_Transaction__c cbt: cloneRecords){
                Customer_Balance_Transaction__c cbtClone = cbt.clone();
                cbtClone.Start_Date__c=System.today();
                cbtClone.Transaction_Date_Time__c=System.now();
                cbtClone.Type__c=System.Label.BRS_Transaction_Type_Credit;
                cbtClone.Status__c=System.label.BRS_PaymentStatus_Refunded;
                insertTransactions.add(cbtClone);
            }
        }
        if(insertTransactions!=null && !insertTransactions.isEmpty()){
            insert insertTransactions;
        }

if(rejectedRegistration !=null && rejectedRegistration.size()>0){
    createBalanceforRejectedMarkFilings(rejectedRegistration,rejectedRegistrationMarkIds);

}


    } */


/**********************************************************************************************
    METHOD NAME    : refundForRejectedFilings
    DESCRIPTION    : Method to refund voucher/check for online payments
    PARAMETER      : List<SObject> newFilings, Map<Id,SObject> oldFilings
    ***********************************************************************************************/
    
    public static void createBalanceforRejectedMarkFilings(List<Mark_Filing__c> newFilings,Set<Id> rejectedRegistrationMarkIds){
      
      
        Map<Id,List<Customer_Balance_Transaction__c>> filingIdVstransactionMap = new Map<Id,List<Customer_Balance_Transaction__c>>();
        List<Customer_Balance_Transaction__c> cloneRecords = new List<Customer_Balance_Transaction__c>();
        List<Customer_Balance_Transaction__c> insertTransactions = new List<Customer_Balance_Transaction__c>();

        

        List<Customer_Balance_Transaction__c> debitTransactionList = [select Id,Amount__c,Business_Filing__c,Contact__c,Payment_Method__c,Mark_Filing__c,
        Payment_Source__c,Refund_Date__c,Status__c,Type__c,UCC_Filing__c,Voucher__c,Work_Order__c,Start_Date__c,Transaction_Date_Time__c from Customer_Balance_Transaction__c 
        where Type__c=:System.Label.BRS_Transaction_Type_Debit and Mark_Filing__c IN :rejectedRegistrationMarkIds WITH SECURITY_ENFORCED];

        for(Customer_Balance_Transaction__c cbt: debitTransactionList){
            if(filingIdVstransactionMap.keySet().contains(cbt.Mark_Filing__c)){
                filingIdVstransactionMap.get(cbt.Mark_Filing__c).add(cbt);
            }else{
                if(cbt.Mark_Filing__c!=null){
                    filingIdVstransactionMap.put(cbt.Mark_Filing__c, new List<Customer_Balance_Transaction__c>{cbt});
                }
                
            }
        }

        for(sObject sobj: newFilings){
           
                Mark_Filing__c businessfiling = (Mark_Filing__c)sobj;
              
                 if(filingIdVstransactionMap.keySet().contains(businessfiling.Id)){
                        List<Customer_Balance_Transaction__c> debitTransactions = filingIdVstransactionMap.get(businessfiling.Id);
                        cloneRecords.addAll(debitTransactions);
                    }
                
           
        }

        if(cloneRecords.size()>0){
            for(Customer_Balance_Transaction__c cbt: cloneRecords){
                Customer_Balance_Transaction__c cbtClone = cbt.clone();
                cbtClone.Start_Date__c=System.today();
                cbtClone.Transaction_Date_Time__c=System.now();
                cbtClone.Type__c=System.Label.BRS_Transaction_Type_Credit;
                cbtClone.Payment_Source__c=System.label.BRS_PaymentSource_Trademark;
              //  cbtClone.Status__c=System.label.BRS_PaymentStatus_Refunded;
                insertTransactions.add(cbtClone);
            }
        }
        Boolean accessCheck = BRS_SecurityUtility.checkDMLAccess(insertTransactions, 'insert');
        if(insertTransactions!=null && !insertTransactions.isEmpty() && accessCheck){
            insert insertTransactions;
        }

 }

    @AuraEnabled
    public static String paymentWrapperFetchTxnErr(String txnId) {
        List<bt_stripe__Transaction__c> lstTxn = [SELECT Id, bt_stripe__Error_Message__c FROM bt_stripe__Transaction__c WHERE Id = :String.escapeSingleQuotes(txnId) WITH SECURITY_ENFORCED];
        if(!lstTxn.isEmpty()) {
            return lstTxn[0].bt_stripe__Error_Message__c;
        }
        return EMPTY_STRING;
    }


    public without sharing class FilingFeeWrapper {
        @AuraEnabled public String filingId {get; set;}
        @AuraEnabled public Decimal customerBalance {get; set;}
        @AuraEnabled public Decimal filingFee {get; set;}
        @AuraEnabled public Boolean showFranchiseTax {get; set;}
        @AuraEnabled public Decimal franchiseTax {get; set;}
        @AuraEnabled public Decimal totalFee {get; set;}
        @AuraEnabled public Decimal balancededucted {get; set;}
        @AuraEnabled public Decimal balanceremaining {get; set;}
        @AuraEnabled public Decimal finalAmount {get; set;}
        @AuraEnabled public Decimal expeditedFees {get; set;}
        @AuraEnabled public Boolean showExpeditedFees {get; set;}
    }
    
    public without sharing class TableDataWrapper{
        @AuraEnabled public String transactionDate {get; set;}
        @AuraEnabled public Date transactionDateFinal{get; set;}
        @AuraEnabled public DateTime transactionDateTime{get; set;}
        @AuraEnabled public String transactionType {get; set;}
        @AuraEnabled public String filingType {get; set;}
        @AuraEnabled public String workorderId {get; set;}
        @AuraEnabled public String filingNumber {get; set;}
        @AuraEnabled public Decimal amount {get; set;}
        @AuraEnabled public String status {get; set;}
    }
    
    public without sharing class DataTable{
        @AuraEnabled public List<BRS_Utility.ColumnsWrapper> tableColumns {get; set;}
        @AuraEnabled public List<TableDataWrapper> tableData {get; set;}
        @AuraEnabled public Decimal currentBalance {get; set;}
    }
    
}