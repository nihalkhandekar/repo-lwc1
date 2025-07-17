/******************************************************************************************************
* NAME:  		BRS_OnlinePayments
* DESCRIPTION:  This class hosts an Invocable method called from a flow & used to create debit records 
				when a customer uses only voucher/checks for complete payment(without blackthorn terminal involvement).
*
* @AUTHOR: 		Tamkanat Fatima
* @DATE: 		5th April, 2021
*******************************************************************************************************/
global with sharing class BRS_OnlinePayments {
	global with sharing class Requests {
        @InvocableVariable global Id workorderId;
        @InvocableVariable global Id filingId;
        @InvocableVariable global Id contactId;
        @InvocableVariable global Decimal deductedAmount;
    }  
    
    /**********************************************************************************************
     METHOD NAME    : createDebitRecords (Invocable Method)
     DESCRIPTION    : Method gets the baalncededucted and creates Voucher/Check debit records.
     PARAMETER      : List<Requests> (Custom Wrapper)
    ***********************************************************************************************/
    @InvocableMethod
    public static void createDebitRecords(List<Requests> inputList){
        if(!inputList.isEmpty() && !String.isBlank(inputList[0].contactId)){
            List<Customer_Balance_Transaction__c> insertCBTList = new List<Customer_Balance_Transaction__c>();
            Id workorderId;
            Id filingId;
            Contact customer = [select Id,Total_Balance__c,Total_Check_Balance__c,Total_Voucher_Balance__c,Direct_Balance__c,Card_Balance__c,Trademark_Balance__c,ACH_Payment_Balance__c  from Contact where Id=:inputList[0].contactId WITH SECURITY_ENFORCED];
            if(inputList[0].deductedAmount!=null && inputList[0].deductedAmount>0){
                if(inputList[0].workorderId!=null){
                    workorderId = inputList[0].workorderId;
                }
                if(inputList[0].filingId!=null){
                    filingId = inputList[0].filingId;
                }
                
                Decimal balance = inputList[0].deductedAmount;
                /** *Case 1: If Voucher Balance is present deduct amount from voucher.
                    *Case 2: If balance is still present after deducting from voucher balance, deduct from Trademark Balance.
                    *Case 3: If balance is still present after deducting from Trademark balance, deduct from Direct Balance.
                    *Case 4: If balance is still present after deducting from Direct balance, deduct from Check Balance.
                    *Case 5: If balance is still present after deducting from Check balance, deduct from Card Balance.
                 */
                    // Case 1
                    if(balance>0 && customer.Total_Voucher_Balance__c>0){
                        if(balance>customer.Total_Voucher_Balance__c){
                            Customer_Balance_Transaction__c voucherDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Voucher,customer.Total_Voucher_Balance__c);
                            if(voucherDebit!=null){
                                insertCBTList.add(voucherDebit);
                            }
                            balance = balance-customer.Total_Voucher_Balance__c;
                        }
                        else{
                            Customer_Balance_Transaction__c onlyVoucherDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Voucher,balance);
                            if(onlyVoucherDebit!=null){
                                insertCBTList.add(onlyVoucherDebit);
                            }
                            balance = 0;
                        }                       
                    }

                    // Case 2
                    if(balance>0 && customer.Trademark_Balance__c>0){
                        if(balance>customer.Trademark_Balance__c){
                            Customer_Balance_Transaction__c trademarkDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Trademark,customer.Trademark_Balance__c);
                            if(trademarkDebit!=null){
                                insertCBTList.add(trademarkDebit);
                            }
                            balance = balance-customer.Trademark_Balance__c;
                        }
                        else{
                            Customer_Balance_Transaction__c onlyTrademarkDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Trademark,balance);
                            if(onlyTrademarkDebit!=null){
                                insertCBTList.add(onlyTrademarkDebit);
                            }
                            balance = 0;
                        } 
                    }
                    // Case 3
                    if(balance>0 && customer.Direct_Balance__c>0){
                        if(balance>customer.Direct_Balance__c){
                            Customer_Balance_Transaction__c directDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Direct,customer.Direct_Balance__c);
                            if(directDebit!=null){
                                insertCBTList.add(directDebit);
                            }
                            balance = balance-customer.Direct_Balance__c;
                        }
                        else {
                            Customer_Balance_Transaction__c onlyDirectDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Direct,balance);
                            if(onlyDirectDebit!=null){
                                insertCBTList.add(onlyDirectDebit);
                            }
                            balance = 0;
                        }
                    }
                    // Case 4
                    if(balance>0 && customer.Total_Check_Balance__c>0){
                        if(balance>customer.Total_Check_Balance__c){
                            Customer_Balance_Transaction__c checkDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Check,customer.Total_Check_Balance__c);
                            if(checkDebit!=null){
                                insertCBTList.add(checkDebit);
                            }
                            balance = balance-customer.Total_Check_Balance__c;
                        }
                        else{
                            Customer_Balance_Transaction__c onlyCheckDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Check,balance);
                            if(onlyCheckDebit!=null){
                                insertCBTList.add(onlyCheckDebit);
                            }
                            balance = 0;
                        }  
                    }
                    // Case 5
                    if(balance>0 && customer.Card_Balance__c>0){
                        if(balance>customer.Card_Balance__c){
                            Customer_Balance_Transaction__c cardDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Card,customer.Card_Balance__c);
                            if(cardDebit!=null){
                                insertCBTList.add(cardDebit);
                            }
                            balance = balance-customer.Card_Balance__c;
                        }                       
                        else{
                            Customer_Balance_Transaction__c onlyCardDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit, System.Label.BRS_PaymentSource_Card,balance);
                            if(onlyCardDebit!=null){
                                insertCBTList.add(onlyCardDebit);
                            }
                            balance = 0;
                        }
                    }
                    if(balance>0 && customer.ACH_Payment_Balance__c>0){
                        if(balance>customer.ACH_Payment_Balance__c){
                            Customer_Balance_Transaction__c achDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit,'ACH Payment',customer.ACH_Payment_Balance__c);
                            if(achDebit!=null){
                                insertCBTList.add(achDebit);
                            }
                            balance = balance-customer.ACH_Payment_Balance__c;
                        }                       
                        else{
                            Customer_Balance_Transaction__c onlyachDebit = BRS_PaymentUtility.createTransaction(workorderId, filingId, null,System.Label.BRS_Transaction_Type_Debit,'ACH Payment',balance);
                            if(onlyachDebit!=null){
                                insertCBTList.add(onlyachDebit);
                            }
                            balance = 0;
                        }
                    }
                }
                if(insertCBTList.size()>0){
                    Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(insertCBTList, 'insert');
                    if(bAccessCheck){
                        insert insertCBTList;
                    }
                }
        }
            
    }
    
}