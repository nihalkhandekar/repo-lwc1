/********************************************************************************************
* DESCRIPTION: Set filing fee and validations for certificates
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        24/11/2021                 BRS-6282 BRS-6799 | Filing fee updates
*********************************************************************************************/
public with Sharing class CertificateTriggerHelper {
    //Different record types for which filing fee is applicablece
    private static Set<String> setFeeTypes = new Set<String> {
        System.Label.Business_Copy_Request_RecordTypeAPI,
        System.Label.UCC_Copy_Request_RecordTypeAPI,
        System.Label.Request_for_Information_RecordTypeAPI,
        System.Label.Request_for_Search_of_Mark_RecordTypeAPI,
        'Trade_Service_Mark_Copy_Request'
    };

    /**********************************************************************************************
    METHOD NAME    : updateFilingFee
    DESCRIPTION    : Method to update the filing fee on the certificate record.
    PARAMETER      : List<Certficate__c>, Map<Id, SObject>
    ***********************************************************************************************/
    public static void updateFilingFee(List<Certficate__c> newCertList, Map<Id, Certficate__c> oldMap) {
        List<String> typeList = new List<String>();
        Set<Id> workorderIds = new Set<Id>();
        Map<Id, Schema.RecordTypeInfo> mapRecordTypes = SchemaUtility.getObject('Certficate__c').getRecordTypeInfosById();
        
        for(Certficate__c certRec : newCertList) {
            if(certRec.Work_Order__c!=null) { //1. to check WO source
                workorderIds.add(certRec.Work_Order__c);
            }

            if(
                (oldMap != null && hasFeeChanged(oldMap.get(certRec.Id), certRec))
                || oldMap == null
            ) {
                String searchKey;
                String recordTypeName = mapRecordTypes.get(certRec.RecordTypeId).getDeveloperName(); //2. to check record type
                        
                if(setFeeTypes.contains(recordTypeName)) {
                    searchKey = recordTypeName;
                } else if(System.Label.Certificate_of_Legal_Existence.equalsIgnoreCase(certRec.Type__c)) {
                    searchKey = certRec.Certificate_Type__c;
                } else {
                    searchKey = certRec.Type__c;
                }
                
                typeList.add(searchKey);
            }
        }
        
        if(!typeList.isEmpty()){
            Map<String, Decimal> mapKeyToAmount = getCertificateFilingFees(typeList);

            Map<Id,Work_Order__c> workorderMap = new Map<Id,Work_Order__c>([
                SELECT Id, Source__c 
                FROM Work_Order__c 
                WHERE Id IN :workorderIds
                    AND Source__c != :System.Label.brs_FilingOnline With SECURITY_ENFORCED
            ]);
                
            for(Certficate__c certRec : newCertList) {
                if(workorderMap.containsKey(certRec.Work_Order__c)) {
                    Work_Order__c workorderRec = workorderMap.get(certRec.Work_Order__c);
            
                    Decimal totalFilingFee = 0, filingFee = 0, expiditionFee = 0, certifiedCopyFee = 0;
                    String recordTypeName = mapRecordTypes.get(certRec.RecordTypeId).getDeveloperName(); //2. to check record type

                    //1. Expedited service
                    Set<String> setCopyRequests = new Set<String> {
                        System.Label.Business_Copy_Request_RecordTypeAPI,
                        System.Label.UCC_Copy_Request_RecordTypeAPI,
                        'Trade_Service_Mark_Copy_Request'
                    };
                    
                    if(setCopyRequests.contains(recordTypeName)) { //1.1. Copy Request
                        if(certRec.Include_Expedited_Service__c) {
                            Decimal totalCopies = 0;
                            
                            if(certRec.Total_Number_of_Plain_Copies__c != null) {
                                totalCopies+=certRec.Total_Number_of_Plain_Copies__c;
                            }
                            
                            if(certRec.Total_Number_of_Certified_Copies__c != null) {
                                totalCopies+=certRec.Total_Number_of_Certified_Copies__c;
                            }

                            expiditionFee = mapKeyToAmount.get(System.Label.CertificateExpediteFee.trim())*(totalCopies);
                        }
                        if(certRec.Total_Number_of_Plain_Copies__c != null){
                            filingFee += mapKeyToAmount.get('Plain')*certRec.Total_Number_of_Plain_Copies__c;
                        }
                        if(certRec.Total_Number_of_Certified_Copies__c!=null) {
                            filingFee += mapKeyToAmount.get('Certified')*certRec.Total_Number_of_Certified_Copies__c;
                        }

                        totalFilingFee = filingFee + expiditionFee;
                    } else { //1.2. Others
                        String searchKey = getCertificateMasterFeeMapping(mapRecordTypes, certRec);
                        totalFilingFee = filingFee = String.isNotBlank(searchKey) && mapKeyToAmount.containsKey(searchKey)
                            ? mapKeyToAmount.get(searchKey)
                            : 0;
                        
                        //i. Certified copy fee + Expedite fee
                        if(certRec.Include_Certified_Copy__c && certRec.Include_Expedited_Service__c) {
                            expiditionFee = mapKeyToAmount.containsKey(System.Label.CertificateExpediteFee)
                                ? mapKeyToAmount.get(System.Label.CertificateExpediteFee)
                                : 0;
                            totalFilingFee += (
                                mapKeyToAmount.containsKey('CertificateExpediteCertified')
                                ? mapKeyToAmount.get('CertificateExpediteCertified')
                                : 0
                            );
                        }
                        //ii. Certified copy fee
                        else if(certRec.Include_Certified_Copy__c) {
                            totalFilingFee += mapKeyToAmount.containsKey('CertificateIncludeCopy')
                                ? mapKeyToAmount.get('CertificateIncludeCopy')
                                : 0;
                        }
                        //iii. Expedite fee
                        else if(certRec.Include_Expedited_Service__c) {
                            expiditionFee = mapKeyToAmount.containsKey(System.Label.CertificateExpediteFee)
                                ? mapKeyToAmount.get(System.Label.CertificateExpediteFee)
                                : 0;
                            totalFilingFee += expiditionFee;
                        }
                    }

                    certRec.Expedited_Service_Fee__c = expiditionFee;
                    certRec.Filing_Fee__c = filingFee;
                    certRec.Total_Fee__c = totalFilingFee;
                }
            }
        }
    }

    //link certificate to master fee
    private static String getCertificateMasterFeeMapping(Map<Id, Schema.RecordTypeInfo> mapRecordTypes, Certficate__c certRec) {
        String searchKey;
        String recordTypeName = mapRecordTypes.get(certRec.RecordTypeId).getDeveloperName(); //2. to check record type
                
        if(setFeeTypes.contains(recordTypeName)) {
            searchKey = recordTypeName;
        } else if(System.Label.Certificate_of_Legal_Existence.equalsIgnoreCase(certRec.Type__c)) {
            searchKey = certRec.Certificate_Type__c + ';' + certRec.Business_Type__c;
        } else {
            searchKey = certRec.Type__c;
        }

        return searchKey;
    }

    private static Boolean hasFeeChanged(Certficate__c oldRecord, Certficate__c certRec) {
        return (oldRecord.RecordTypeId != certRec.RecordTypeId) 
            || (oldRecord.Type__c!=certRec.Type__c) 
            || (oldRecord.Certificate_Type__c != certRec.Certificate_Type__c) 
            || (oldRecord.Business__c!=certRec.Business__c) 
            || (oldRecord.Total_Number_of_Plain_Copies__c!=certRec.Total_Number_of_Plain_Copies__c) 
            || (oldRecord.Total_Number_of_Certified_Copies__c!=certRec.Total_Number_of_Certified_Copies__c) 
            || (oldRecord.Include_Expedited_Service__c != certRec.Include_Expedited_Service__c)
            || (oldRecord.Include_Certified_Copy__c != certRec.Include_Certified_Copy__c);
    }

    private static Map<String, Decimal> getCertificateFilingFees(List<String> typeList) {
        Map<String, Decimal> mapKeyToAmount = new Map<String, Decimal>();

        for(Master_Fee__c mf : [
            SELECT Id, Amount__c, Business_Type__c, Citizenship__c, End_Date__c	, Filing_Type__c, Lien_Type__c, 
                Start_Date__c, Type__c,Certificate_Copy_Type__c, Service_Type__c 
            FROM Master_Fee__c  
            WHERE 
                Status__c = :System.Label.ACTIVE
                AND
                (
                    ( 
                        Start_Date__c <= TODAY 
                        AND 
                        (
                            End_Date__c = null 
                            OR 
                            End_Date__c >= TODAY
                        ) 
                        AND
                        Filing_Type__c IN :typeList
                    ) 
                    OR
                    Service_Type__c != null
                ) 
        With SECURITY_ENFORCED ]){
            // The key if copy type is present :: 'mf.Certificate_Copy_Type__c' (for copy request records)
            // The key if copy type is not present :: 'mf.Filing_Type__c;mf.Business_Type__c' 
            String key;
            
            if(mf.Certificate_Copy_Type__c != null) {
                key = mf.Certificate_Copy_Type__c;
            } else if(mf.Business_Type__c != null ) {
                key = mf.Filing_Type__c + ';' + mf.Business_Type__c;
            } else if(mf.Service_Type__c != null) {
                key = mf.Service_Type__c;
            } else {
                key = mf.Filing_Type__c;
            }

            mapKeyToAmount.put(key, mf.Amount__c);
        }

        return mapKeyToAmount;
    }

    /**********************************************************************************************
    METHOD NAME    : checkPaymentVerification
    DESCRIPTION    : Method to restrict user from Approving Certificate before checking the 'Verify Payments' checkbox on workorder.
    PARAMETER      : List<SObject> newCertificates, Map<Id, SObject> oldCertificateMap
    ***********************************************************************************************/    
    public static void checkPaymentVerification(List<SObject> newCertificates, Map<Id, SObject> oldCertificateMap){
        Set<Id> workOrderIds = new Set<Id>();
        for(Certficate__c certRec: (List<Certficate__c>) newCertificates) {
            workOrderIds.add(certRec.Work_Order__c);
        }

        Map<Id,Work_Order__c> workOrderMap = new Map<Id,Work_Order__c>([
            SELECT Id, Payments_Verified__c, Customer__c,Source__c, Customer__r.Allow_negative_balances__c 
            FROM Work_Order__c 
            WHERE Id IN :workOrderIds With SECURITY_ENFORCED
        ]);
        
        for(Certficate__c newCert: (List<Certficate__c>) newCertificates) {
            if(
                newCert.Status__c == System.Label.BRS_FilingStatus_Approved
                && 
                (
                    (oldCertificateMap != null && !newCert.Status__c.equalsIgnoreCase(String.valueOf(oldCertificateMap.get(newCert.Id).get('Status__c')))) //Status changed
                    || 
                    oldCertificateMap == null
                )
                &&
                workOrderMap.containsKey(newCert.Work_Order__c)
            ) {
                Work_Order__c workorder = workOrderMap.get(newCert.Work_Order__c);
                
                if(
                    !workorder.Payments_Verified__c 
                    && 
                    !workorder.Customer__r.Allow_negative_balances__c
                    && 
                    workorder.Source__c != System.Label.brs_FilingOnline 
                    && 
                    workorder.Source__c != System.Label.brs_FilingAPI
                ) {
                    newCert.addError(System.Label.PaymentVerificationCheckErrorMessage);
                }
            }
        }
    }

    /**********************************************************************************************
    METHOD NAME    : checkAccountForNoRecord
    DESCRIPTION    : Method to check if an account is present with the name entered by the user for Certificate of No Record.
    PARAMETER      : List<Certficate__c> newCertList
    ***********************************************************************************************/  
    public static void checkAccountForNoRecord(List<Certficate__c> newCertList) {
        List<String> accountNameList = new List<String>();
        Map<String, Account> accountNameVsAccountMap = new Map<String, Account>();

        for(Certficate__c cert: newCertList) {
            if(System.Label.Certificate_of_No_Record.equalsIgnoreCase(cert.Type__c)) {
                accountNameList.add(cert.Business_Name__c);
            }
        }

        if(!accountNameList.isEmpty()){
            for(Account acc: [
                SELECT Id, Name 
                FROM Account 
                WHERE Name IN :accountNameList With SECURITY_ENFORCED
            ]) {
                accountNameVsAccountMap.put(acc.Name, acc);
            }
                
            if(!accountNameVsAccountMap.isEmpty()) {
                for(Certficate__c cert: newCertList) {
                    if(System.Label.Certificate_of_No_Record.equalsIgnoreCase(cert.Type__c) && accountNameVsAccountMap.containsKey(cert.Business_Name__c)) {
                        cert.addError(System.Label.Certificate_of_No_Record_ErrorMessage);
                    }
                }
            }
        }
    }

    /**
     * @update: BRS-6282 | Do not copy mailing address for Special Documents
    */
    public static void updateRegistertionDateandMailingAddress(List<SObject> newItems){        
        List<Certficate__c> filings = [
            SELECT Id, Requested_On__c,Mailing_City__c,Mailing_Country__c,Mailing_State__c,Mailing_Street__c,Mailing_Zip_Code__c,
                Work_Order__c,Work_Order__r.Source__c,Work_Order__r.Received_Date__c,
                Work_Order__r.Customer__r.MailingCity,Work_Order__r.Customer__r.MailingCountry, Work_Order__r.Customer__r.MailingPostalCode,
                Work_Order__r.Customer__r.MailingState, Work_Order__r.Customer__r.MailingStreet
            FROM Certficate__c 
            WHERE Id IN :newItems
                AND Work_Order__c != null
                AND RecordType.Name != 'Special Documents' //BRS-6282
                AND Work_Order__r.Source__c != 'Online' With SECURITY_ENFORCED
        ];

        for(Certficate__c newCert: filings) {
            newCert.Requested_On__c = newCert.Work_Order__r.Received_Date__c.date();
            
            newCert.Mailing_City__c = newCert.Work_Order__r.Customer__r.MailingCity;
            newCert.Mailing_Country__c = newCert.Work_Order__r.Customer__r.MailingCountry;
            newCert.Mailing_State__c = newCert.Work_Order__r.Customer__r.MailingState;
            newCert.Mailing_Street__c = newCert.Work_Order__r.Customer__r.MailingStreet;
            newCert.Mailing_Zip_Code__c = newCert.Work_Order__r.Customer__r.MailingPostalCode;
        }
    
        Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(filings, 'update');
        if(!filings.isEmpty() && bAccessCheck) {
            update filings;
        }
    }

    public static void validateCertificateype(List<Certficate__c> newItems, Map<ID, Sobject> oldItems) {
        for (Certficate__c certificate: newItems) {
            if (
                (
                    System.Label.brs_CertficateTypeLongform.equalsIgnoreCase(certificate.Certificate_Type__c)
                    || 
                    System.Label.brs_CertificateofNoRecord.equalsIgnoreCase(certificate.Type__c)
                ) 
                &&
                certificate.Include_Expedited_Service__c
            ) {
                certificate.addError(System.Label.brs_CertificateExpiditeServiceError);
            }
        }
    }
	
	/**********************************************************************************************
    METHOD NAME    : refundRejectedOnlineFilings
    DESCRIPTION    : Method to create refund transaction
    PARAMETER      : List<Certficate__c>
    ***********************************************************************************************/
    public static void refundRejectedOnlineFilings(List<Certficate__c> newCertList, Map<Id, SObject> mapOfOldCerts) {
        Set<Id> setOfCertificateIds = new Set<Id>();
        for (Certficate__c newCert : newCertList) {
            Certficate__c oldCert = (Certficate__c) mapOfOldCerts.get(newCert.Id);
            if (newCert.Status__c != null && newCert.Status__c == System.Label.BRS_FilingStatus_Rejected && oldCert.Status__c != newCert.Status__c){
                setOfCertificateIds.add(newCert.Id);
            }
        }
		
        List<Certficate__c> otherReqWithCBTList = [select Id,Work_Order__c, Status__c,Include_Expedited_Service__c,Expedited_Service_Fee__c,Filing_Fee__c,
        (SELECT Id,Amount__c,Contact__c,Payment_Method__c,Payment_Source__c,Refund_Date__c,Status__c,Type__c,UCC_Filing__c,Work_Order__c,Start_Date__c,Transaction_Date_Time__c 
        FROM Customer_Balance_Transactions__r WHERE Type__c=:System.Label.BRS_Transaction_Type_Debit) from Certficate__c where Id IN :setOfCertificateIds With SECURITY_ENFORCED];

        Map<Id, Decimal> woIdWithAmountRetained = new Map<Id, Decimal>();
        for(Certficate__c otherR: otherReqWithCBTList){
            Decimal totalDebits = 0;
            Decimal amountToRetain = 0;
            if(!otherR.Customer_Balance_Transactions__r.IsEmpty()){
                for(Customer_Balance_Transaction__c cbt: otherR.Customer_Balance_Transactions__r){
                    totalDebits+=cbt.Amount__c;
                }
            }
            if(otherR.Include_Expedited_Service__c==true){
                if(totalDebits<otherR.Expedited_Service_Fee__c){
                    amountToRetain = otherR.Expedited_Service_Fee__c - totalDebits;
                }
            }
            woIdWithAmountRetained.put(otherR.Work_Order__c, amountToRetain);   
        }
        if (!setOfCertificateIds.isEmpty() && !woIdWithAmountRetained.keySet().isEmpty()) {
            processBTRefundforOtherRequest(setOfCertificateIds,woIdWithAmountRetained);
        }
    }

	/**********************************************************************************************
	METHOD NAME    : processBlackthornRefund
	DESCRIPTION    : Method to process refund transactions
	PARAMETER      : Set<Id>, Map<Id,Decimal>
	***********************************************************************************************/

	public static void processBTRefundforOtherRequest(Set<Id> setOfCertificateIds, Map<Id,Decimal> woIdWithAmountRetained) {
		List<OnOff_Filing_Auto_Refund__c> onOffSwich = OnOff_Filing_Auto_Refund__c.getall().values();
		if (!onOffSwich.isEmpty() && !onOffSwich[0].Auto_Refund_Business_Filing__c) {
			return;
		}
		Set<Id> workOrderIds = new Set<id>();
		for(Certficate__c cert:[Select Id, Work_Order__c from Certficate__c where Id IN:setOfCertificateIds With SECURITY_ENFORCED] ){
            workOrderIds.add(cert.Work_Order__c);
        }
		List<bt_stripe__Transaction__c> transactions2Insert = new List<bt_stripe__Transaction__c>();

		for (Work_Order__c wo: [SELECT Id, Total_Hold_Amount__c, Final_Amount_Payable__c,
								(SELECT Id,Include_Expedited_Service__c,Expedited_Service_Fee__c,Work_Order__c from Certficates__r), 
								(SELECT Id, bt_stripe__Payment_Status__c, bt_stripe__Transaction_Status__c, bt_stripe__Transaction_Type__c,
								 bt_stripe__Amount__c, bt_stripe__Payment_Gateway__c, bt_stripe__Stripe_Customer__c, bt_stripe__Related_Contact__c,
								 bt_stripe__Related_Account__c, bt_stripe__Payment_Method__c 
								 FROM Transactions__r) 
								FROM Work_Order__c 
								WHERE Id IN: workOrderIds AND
								Source__c = 'Online' With SECURITY_ENFORCED]) {
								if(!wo.Transactions__r.isEmpty()){	
									Boolean validTransaction = false;
									Boolean alreadyRefunded = false;
									Decimal totalCapturedAmt = 0;
									Decimal totalRefundedAmt = 0;
									bt_stripe__Transaction__c transactionToRefund = new bt_stripe__Transaction__c();
									List<bt_stripe__Transaction__c> lstOfCapturedTxn = new List<bt_stripe__Transaction__c>();
									List<bt_stripe__Transaction__c> lstOfRefundedTxn = new List<bt_stripe__Transaction__c>();
									
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
											if(woIdWithAmountRetained.containsKey(wo.Id)){
												Decimal amtToRetain = woIdWithAmountRetained.get(wo.Id);
												refundTransaction.bt_stripe__Amount__c = (-1 * (totalCapturedAmt - totalRefundedAmt - amtToRetain));
											}else{
												refundTransaction.bt_stripe__Amount__c = (-1 * (totalCapturedAmt - totalRefundedAmt));
											}
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
}