/* DESCRIPTION: This class is used to update UCC Filing status on click of 'Approve' or 'Reject'.
*
* @AUTHOR: 	Aparna Shahapurkar
* @DATE: 	02/10/2021 
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ------------------------------------------------------------------------------------------------
* Aparna Shahapurkar               02/10/2021                   Created the first version
* Shreya                            02/24/2020                          BRS-2468 | Approve/Reject a filing
**************************************************************************************************/
global without sharing class brs_FilingStatusAuraHelper {
    public static Final String className = 'brs_FilingStatusAuraHelper';
    public static Final String objectName = 'UCC_Filing__c/Business_Filing__c';    
    
    @AuraEnabled(cacheable=true)
    public static sObject getFilingRecord(Id recordId) {
        String obj = SchemaUtility.getObjectFromId(recordId).getName();
        String queryStr = '';
        if(obj == 'WRIT_Case__c'){
            queryStr = 'SELECT ' + 'Work_Order__r.Source__c,Work_Order__r.IsInsufficientPayment__c,Work_Order__r.Payments_Verified__c,Work_Order__r.Customer__r.Allow_negative_balances__c, '
            + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
            +' FROM ' + obj
            +' WHERE Id = :recordId';
        }
        else if(obj == 'Mass_Agent_Change__c'){
            queryStr = 'SELECT ' + 'Work_Order__r.Source__c, '
            + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
            +' FROM ' + obj
            +' WHERE Id = :recordId';
        }
        else{
            queryStr = 'SELECT ' + 'Work_Order__r.Source__c,Work_Order__r.IsInsufficientPayment__c,Work_Order__r.Payments_Verified__c,Work_Order__r.Customer__r.Allow_negative_balances__c,RecordType.Name,Work_Order__r.Received_Date__c, '
            + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',')
            +' FROM ' + obj
            +' WHERE Id = :recordId';
        }
        return Database.query(
            queryStr
        )[0];
    }

    /********************************************************************************************
        METHOD NAME    : generateFilingOutput | Only call for sdocs
        DESCRIPTION    : generates rejection notice
        RETURN TYPE    : Void
        PARAMETER      : sObject,String
    ********************************************************************************************/
    @AuraEnabled
    public static List<Id> generateFilingOutput(sObject filing, String status) {
        List<Id> listSdocIds;
        //1. Filing output
        if(String.isBlank(status)) {
           // listSdocIds = UCCFileMerge.generateFilingNotice(filing);
        } 
        //2. Acceptance Notice
        if(System.Label.Approved.equalsIgnoreCase(status)) {
            //listSdocIds = UCCFileMerge.generateNotice(filing, status);
        }
        //3. Rejection Notice
        if(System.Label.Rejected.equalsIgnoreCase(status)) {
            update filing; //insert rejection reason, for sdocs to pick
           // listSdocIds = UCCFileMerge.generateNotice(filing, status);
        }
        
        return listSdocIds;
    }

    /**
     * Nintex: Only for Certs  filing output
     */
    public static void generateNintexOutput(Id filingId, String status) {
        String obj = SchemaUtility.getObjectFromId(filingId).getName();
        
        //1. Filing output & AN/RN
         
            NintexDocumentGeneration.generateFilingOutput(new List<NintexDocumentGeneration.NintexWrapper> {
                new NintexDocumentGeneration.NintexWrapper(
                    filingId,
                    status
                )
            }); 
    }

    @AuraEnabled
    public static void generateFilingAttachment(String filingId, List<String> listSdocIds) {
        if(String.isNotBlank(filingId) && listSdocIds != null && !listSdocIds.isEmpty()) {
            UCCFileMerge.generateSdocAttachments(filingId, listSdocIds);
        }
    }

    @AuraEnabled
    public static void generateRequestForInfo(String filingId, String filingType) {
        if(String.isNotBlank(filingId) && String.isNotBlank(filingType)) {
            SdocTemplateServices.generateRequestInformation(new List<SdocTemplateServices.RequestWrapper> {
                new SdocTemplateServices.RequestWrapper(filingId, filingType)
            });
        }
    }

    /********************************************************************************************
        METHOD NAME    : getCustomerDisplayMssg
        DESCRIPTION    : Return display messages
        RETURN TYPE    : String
        PARAMETER      : Id,String
            @update    : BRS-5171 | UCC Office Correct Approval message
    ********************************************************************************************/
    @AuraEnabled //to remove
    public static String getCustomerDisplayMssg(Id recordId, String status) {
        String displayMessage;

        if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.BRS_UCCFilingObject) {
            UCC_Filing__c filingRec = [
                SELECT Id, Type__c, Work_Order__c, Work_Order__r.Customer__r.Email
                FROM UCC_Filing__c
                WHERE id =: recordId
                WITH SECURITY_ENFORCED
            ]; //can pass filing from aura.

            if ('Office Correct'.equalsIgnoreCase(filingRec.Type__c)) {
                displayMessage = 'Filing successfully approved';
            } else if (String.isNotBlank(filingRec.Work_Order__r.Customer__r.Email)) {
                displayMessage = (status.equalsIgnoreCase(System.label.UCC_FILING_STATUS) ? System.label.brs_ApprovalEmailMessage : System.label.brs_RejectedEmailMessage  ) + ' ' + System.label.brs_EmailedCustomer;
            } else {
                displayMessage = status.equalsIgnoreCase(System.label.UCC_FILING_STATUS) ? System.label.brsApprove_SuccessMssg : System.label.brsReject_SuccessMssg;
            }
        } else if (SchemaUtility.getObjectFromId(recordId).getName() == System.label.Business_Filing_API_Name) {
            Business_Filing__c businessFilingRec = [SELECT Id, Work_Order__c, Work_Order__r.Customer__r.Email FROM Business_Filing__c WHERE id =: recordId WITH SECURITY_ENFORCED];
            if (businessFilingRec.Work_Order__r.Customer__r.Email != null) {
                displayMessage = (status.equalsIgnoreCase(System.label.UCC_FILING_STATUS) ? System.label.brs_ApprovalEmailMessage : System.label.brs_RejectedEmailMessage);
                displayMessage = displayMessage + ' ' + System.label.brs_EmailedCustomer;
            } else {
                displayMessage = (status.equalsIgnoreCase(System.label.UCC_FILING_STATUS) ? System.label.brsApprove_BFilingSuccessMssg : System.label.brsReject_SuccessMssg);
            }
        }
        return displayMessage;
    }
    @TestVisible
    private static String getDisplayMssg(sObject record) {
        String displayMessage;

        if (record instanceof UCC_Filing__c) {
            UCC_Filing__c filingRec = (UCC_Filing__c) record;
            String status = filingRec.Status__c;

            if ('Office Correct'.equalsIgnoreCase(filingRec.Type__c)) {
                displayMessage = 'Filing successfully approved';
            } else if (String.isNotBlank(filingRec.Work_Order__r.Customer__r.Email)) {
                displayMessage = (System.label.UCC_FILING_STATUS.equalsIgnoreCase(filingRec.Status__c) ? System.label.brs_ApprovalEmailMessage : System.label.brs_RejectedEmailMessage ) + ' ' + System.label.brs_EmailedCustomer;
            } else {
                displayMessage = status.equalsIgnoreCase(System.label.UCC_FILING_STATUS) 
                    ? System.label.brsApprove_SuccessMssg 
                    : System.label.brsReject_SuccessMssg;
            }
        } else if (record instanceof Business_Filing__c) {
            Business_Filing__c businessFilingRec = (Business_Filing__c) record;

            if (businessFilingRec.Work_Order__r.Customer__r.Email != null) {
                if(businessFilingRec.Type__c !='Merger' && businessFilingRec.Type__c !='Conversion' && businessFilingRec.Type__c !='Domestication')
                {
                    displayMessage = (
                        System.label.UCC_FILING_STATUS.equalsIgnoreCase(businessFilingRec.Status__c) ? System.label.brs_ApprovalEmailMessage : System.label.brs_RejectedEmailMessage) + ' ' + System.label.brs_EmailedCustomer;
                        System.debug('displayMessage@@@'+displayMessage);
                }
            } else {
                displayMessage = System.label.UCC_FILING_STATUS.equalsIgnoreCase(businessFilingRec.Status__c) ? System.label.brsApprove_BFilingSuccessMssg : System.label.brsReject_SuccessMssg;
            }
        }
        
        return displayMessage;
    }

    /********************************************************************************************
        METHOD NAME    : approveFiling
        DESCRIPTION    : Performs post approval actions
        RETURN TYPE    : Boolean
        PARAMETER      : Id,String
    ********************************************************************************************/
    @AuraEnabled
    public static String approveFiling(Id recordId, Boolean confirmFile) {
        String toastMsg = '';
        String obj = SchemaUtility.getObjectFromId(recordId).getName();
        
        try{
            if (System.label.BRS_UCCFilingObject.equalsIgnoreCase(obj)) {
                toastMsg = updateUCCFiling(recordId, confirmFile);
            } else if (System.Label.Business_Filing_API_Name.equalsIgnoreCase(obj)) {
                toastMsg = updateBusinessFiling(recordId);
            } else if (System.label.Other_Request_API_Name.equalsIgnoreCase(obj)) {
                updateOtherRequestFiling(recordId);
            } else if ('Mark_Filing__c'.equalsIgnoreCase(obj)) {
                updateMarkFiling(recordId);
            }
        } catch(DmlException ex) {
            toastMsg = 'ERROR';
            BOS_Utility.handleException(ex);
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return toastMsg;
    }

    private static String updateUCCFiling(Id recordId, Boolean confirmFile) {
        Map<String, Id> mapRecordTypesLien = SchemaUtility.getRecordTypes('UCC_Lien__c');
        Id ofsLien = mapRecordTypesLien.get(System.label.OFS_Value);
        Id aircraftLien = mapRecordTypesLien.get(System.label.AircraftRecordType_Label);
        Id judgementLien = mapRecordTypesLien.get(System.label.JudgementsRecordTypeLabel);
        Id irsLien = mapRecordTypesLien.get(System.label.lien_Type_Irs);

        Map<String, Id> mapRecordTypesFiling = SchemaUtility.getRecordTypes('UCC_Filing__c');
        Id newFiling = mapRecordTypesFiling.get(System.label.NewLienRecordType_Label);
        Id newIRSFiling = mapRecordTypesFiling.get(System.label.lien_Type_Irs);

        UCC_Filing__c filingRec = [
            SELECT Id, Confirm_File_Validation__c, RecordTypeId, Name, Status__c, Type__c, IRS_SLID_Number__c, Filing_Number__c, UCC_Lien_Id__c, UCC_Lien_Type__c,
                Work_Order__r.Customer__r.Email
            FROM UCC_Filing__c 
            WHERE id =: recordId 
            WITH SECURITY_ENFORCED
        ];

        if ((filingRec.RecordTypeId == newFiling || (filingRec.RecordTypeId == newIRSFiling)) && filingRec.UCC_Lien_Id__c == null) {
			List<String> releaseFilings = new List<String>{'IRS Release','IRS Release Corr','IRS Release Orig','IRS Release RFIL','IRS Revocation'};
            UCC_Lien__c newLienRec = new UCC_Lien__c();
            newLienRec.Name = filingRec.Name.substringAfter('UCC-');
            newLienRec.UCC_Lien_Number__c = filingRec.Name.substringAfter('UCC-');
            newLienRec.IRS_Number__c = filingRec.IRS_SLID_Number__c;
			
            if(filingRec.UCC_Lien_Type__c!=null){
                newLienRec.Type__c = filingRec.UCC_Lien_Type__c;
            }else if(filingRec.RecordTypeId == newIRSFiling){
                newLienRec.Type__c = 'IRS';
            }
			
            if(filingRec.Type__c=='IRS Discharge'){
                             newLienRec.Status__c='Discharge';
            }else if(releaseFilings.contains(filingRec.Type__c)){
                         newLienRec.Status__c='Released';
            }else if(filingRec.Type__c=='IRS Withdrawal Notice'){
                         newLienRec.Status__c='Withdrawn';
            }else{
                newLienRec.Status__c = 'Active';
            }
			
            if (filingRec.Type__c == System.label.Aircraft_Label || filingRec.Type__c == System.label.Vessel_Label) {
                newLienRec.RecordTypeId = aircraftLien;
            } else if (filingRec.Type__c == System.label.Judgement_Label || filingRec.Type__c == System.label.JudgmentPersonalPropertyLabel) {
                newLienRec.RecordTypeId = judgementLien;
            } else if ((filingRec.Type__c == System.label.OFS_Value && filingRec.UCC_Lien_Type__c == System.label.lien_Type_Irs) || (filingRec.RecordTypeId == newIRSFiling)) {
                newLienRec.RecordTypeId = irsLien;
            } else if (filingRec.Type__c == System.label.OFS_Value || filingRec.Type__c == System.label.NoticeOfAttachmentLabel) {
                newLienRec.RecordTypeId = ofsLien;
            }
            if (Schema.SObjectType.UCC_Lien__c.isCreateable()) {
                if (newLienRec != null) {
                    insert newLienRec;
                }
            }
            filingRec.UCC_Lien_Id__c = newLienRec.Id;
        }
        filingRec.Status__c = System.label.UCC_FILING_STATUS;
        if (confirmFile != null) {
            filingRec.Confirm_File_Validation__c = confirmFile;
        }
        if (Schema.SObjectType.UCC_Filing__c.isUpdateable() && filingRec != null) {
            update filingRec;
        }
        
        generateNintexOutput(recordId, filingRec.Status__c);

        return getDisplayMssg(filingRec);
    }

    private static String updateBusinessFiling(Id recordId) {
        Business_Filing__c busFilingRec = [
            SELECT Id, Work_Order__r.Customer__r.Email, Effective_Date__c,Work_Order__c, Total_Authorized_Shares__c, Type__c, Filing_Type__c, Business_Type__c, Citizenship__c, 
                Status__c, Account__c, Account__r.Status__c, Account__r.Total_Authorized_Shares__c,Filing_Date__c,Sub_Type__c, Source__c, Sdoc_Filing_Number__c
            FROM Business_Filing__c 
            WHERE id=:recordId 
            WITH SECURITY_ENFORCED
        ];
        
        //added empty check as part of code review activity
        if(busFilingRec != null && busFilingRec.Type__c != system.label.Domestication_Label && busFilingRec.Type__c != system.label.Conversion_Label  && busFilingRec.Type__c != 'Merger'){
            busFilingRec.Status__c = System.label.UCC_FILING_STATUS;
            if(busFilingRec.Account__c != null){
                Account account = [Select Id, Status__c, Reservation_Expiration_Date__c, Total_Authorized_Shares__c,Date_Registration__c,Citizenship__c,Business_Type__c,(Select Id, Due_Date__c, Type__c, Filing_Date__c, Status__c from Business_Filings__r WHERE Type__c ='First Report' AND Due_Date__c != NULL Order By Due_Date__c DESC LIMIT 1)  from Account where id=:busFilingRec.Account__c];
                    Account annualReportAccount;                     
                if(account != null){
                    if(busFilingRec.Type__c == System.label.brs_Cancellation){
                        account.Status__c = System.label.Cancelled;
                    }
                    else  if(busFilingRec.Type__c == System.label.BRS_Name_Reservation_Flow){
                        account.Status__c=System.label.brs_BusinessReservationStatus;
                        account.Reservation_Expiration_Date__c = Datetime.newInstance(busFilingRec.Filing_Date__c.year(), busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day(), 23, 59, 00).addDays(120);
                        account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                        account.Has_Business_Name_Reservation_No__c=true;
                    }
                    else if(busFilingRec.Type__c == System.label.Amendment_Label && ((busFilingRec.Citizenship__c == System.label.Domestic && busFilingRec.Business_Type__c == System.label.Stock) || (busFilingRec.Business_Type__c == System.label.B_Corp))){
                                                account.Total_Authorized_Shares__c = busFilingRec.Total_Authorized_Shares__c;
                    }
                    else if((busFilingRec.Type__c == System.label.brs_Reinstatement || busFilingRec.Type__c == System.label.RevocationDissolution_Header_Question) && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                        account.Status__c = System.label.ACTIVE;
                        if(busFilingRec.Type__c == System.label.brs_Reinstatement){
                            annualReportAccount=new Account(Id=account.Id);
                            account.Latest_Report__c=datetime.newinstance(date.today().year(), date.today().month(), date.today().day());
                        if(busFilingRec.Sub_Type__c== System.label.With_First_Report || busFilingRec.Sub_Type__c == System.label.With_FirstReport_and_Name_Change){
                            if(account.Citizenship__c == System.label.Domestic && (account.Business_Type__c == System.label.Label_Stock_Comparable || account.Business_Type__c == System.label.Label_NonStock_Comparable || account.Business_Type__c == System.label.B_Corp)){
                                annualReportAccount.Annual_Report_Due_Date__c = date.newinstance(busFilingRec.Filing_Date__c.year() + 1, busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day());
                                annualReportAccount.Sub_status__c='';
                            }
                        }
                        else if(busFilingRec.Sub_Type__c== System.label.With_Annual_Report || busFilingRec.Sub_Type__c == System.label.With_Annual_Report_Name_Change){
                            if(account.Business_Type__c == System.Label.Label_Stock_Comparable || account.Business_Type__c == System.label.Label_NonStock_Comparable || account.Business_Type__c == System.label.B_Corp){
                                Date firstReportDate;
                                if(!account.Business_Filings__r.isEmpty()){
                                    if( account.Business_Filings__r[0].Filing_Date__c!=Null){
                                    firstReportDate=account.Business_Filings__r[0].Filing_Date__c;
                                    }
                                }
                                if(firstReportDate!=null){
                                annualReportAccount.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + 1, firstReportDate.month(),firstReportDate.day());
                                annualReportAccount.Sub_status__c='';
                                }else{
                                annualReportAccount.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + 1, account.Date_Registration__c.month(), account.Date_Registration__c.day());
                                annualReportAccount.Sub_status__c='';

                                }
                            }
                        else if(account.Business_Type__c == System.label.LLP  || account.Business_Type__c == System.label.Limited_Partnership){
                            annualReportAccount.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + 1, account.Date_Registration__c.month(), account.Date_Registration__c.day());
                            annualReportAccount.Sub_status__c='';

                        }else if(account.Business_Type__c == System.label.Business_Type_LLC){
                            annualReportAccount.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + 1 , 3, 31);
                            annualReportAccount.Sub_status__c='';

                        }
                        }
                    }
                    }
                    else if(busFilingRec.Type__c == System.label.brs_registrationNameLabel){
                        account.Status__c=System.label.brs_BusinessReservationStatus;
                        account.Reservation_Expiration_Date__c = Datetime.newInstance(busFilingRec.Filing_Date__c.year(), busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day(), 23, 59, 00).addDays(365);
                        account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                        account.Has_Business_Name_Reservation_No__c=true;
                    }
                    else if(busFilingRec.Type__c == System.label.brs_registrationCorpNameLabel){
                        account.Status__c=System.label.brs_BusinessReservationStatus;
                        account.Reservation_Expiration_Date__c=Datetime.newInstance(busFilingRec.Filing_Date__c.year(), 12, 31, 23, 59, 00); 
                        account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                        account.Has_Business_Name_Reservation_No__c=true;
                    }
                    else if(busFilingRec.Type__c == System.label.brs_RenewCorpNameRegistration || busFilingRec.Type__c == System.label.brs_RenewNameRegistration){
                                                 account.Reservation_Expiration_Date__c = account.Reservation_Expiration_Date__c.addYears(1);
                    }
                    else if(busFilingRec.Type__c == System.label.brs_NameReserCancellationLabel){
                        account.Status__c = System.label.brsStatus_ReservedCancel;
                    }
                    else if(busFilingRec.Type__c == System.label.Transfer_of_Name_Reservation){
                        account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                    }
                    else if(busFilingRec.Type__c == System.label.Transfer_of_Registration_of_Name){
                                                 account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                    }
                    else if(busFilingRec.Type__c == System.label.Business_Formation_Label && busFilingRec.Business_Type__c == System.label.brs_GeneralPartnership){
                                                 account.Status__c = System.label.brsStatus_Recorded;
                    }
                    else if(busFilingRec.Type__c == System.label.Business_Registration_Label && busFilingRec.Business_Type__c == System.label.brs_GeneralPartnership){
                        account.Status__c = System.label.brsStatus_Recorded;
}
                    else if(busFilingRec.Type__c == System.label.Dissolution_Label && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                                 account.Status__c=System.label.DISSOLVED_STATUS;
                    }
                    else if(busFilingRec.Type__c == System.label.Withdrawal_Label && busFilingRec.Business_Type__c == system.label.LLC && (busFilingRec.Effective_Date__c > System.today() && busFilingRec.Effective_Date__c !=null)){
                                                 account.Status__c=System.label.Pending_Withdrawal_Label;
                    }
                    else if(busFilingRec.Type__c == System.label.Withdrawal_Label){
                                                 account.Status__c=System.label.Withdrawn;
                    }
                    else if(busFilingRec.Type__c == System.label.brs_Cancellation && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                                 account.Status__c=System.label.Cancelled;
                    }
                    else if(busFilingRec.Type__c == System.label.Renunciation_Status_Report && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                                 account.Status__c=System.label.Renunciated;
                    }
                    else{
                        if(busFilingRec.Type__c != System.Label.brs_AgentResignation)
                        {
                            account.Status__c = System.label.ACTIVE;
                        }
                    } 
                        if(busFilingRec.Type__c == System.label.Business_Formation_Label || busFilingRec.Type__c == System.label.Business_Registration_Label){
                                                     account.Date_Registration__c= busFilingRec.Filing_Date__c;
                    }                            
                }
                
                if(busFilingRec.Type__c != System.label.Withdrawal_Label || (busFilingRec.Type__c == System.label.Withdrawal_Label && busFilingRec.Business_Type__c != system.label.LLC))
                    update busFilingRec;
                update account;
                if(busFilingRec.Type__c == System.label.Withdrawal_Label && busFilingRec.Business_Type__c == system.label.LLC)
                    update busFilingRec;
                if(annualReportAccount!=null && annualReportAccount.Annual_Report_Due_Date__c!=null){
                    update annualReportAccount;
                }

            }
        }
         if((busFilingRec.Type__c == System.Label.Annual_Report || busFilingRec.Type__c == System.Label.First_Report ) && busFilingRec.Status__c =='Approved'){
            brs_ActionItemUtility.completeActionItem(new List<Business_Filing__c>{busFilingRec});
        }
        generateNintexOutput(recordId, busFilingRec.Status__c);

        return getDisplayMssg(busFilingRec);
    }

    private static void updateOtherRequestFiling(Id recordId) {
        Certficate__c certificateRecord = [
            SELECT Id, Status__c, RecordType.Name, Certificate_Type__c, Type__c 
            FROM Certficate__c 
            WHERE id =: recordId
        ];
        certificateRecord.Status__c = System.label.UCC_FILING_STATUS;
        //Search of Mark & Trade & Service Mark Copy Request
        if (certificateRecord.RecordType.Name == 'Request for Search of Mark' 
            || certificateRecord.RecordType.Name == 'Trade & Service Mark Copy Request') {
            Set<Id> setContentDocumentIds = new Set<Id> ();

            for (ContentDocumentLink uploadedFile: [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId =: certificateRecord.Id
                    ORDER BY SystemModStamp DESC
                ]) {
                setContentDocumentIds.add(uploadedFile.ContentDocumentId);
            }
            List<ContentVersion> listFiles = [
                SELECT Title
                FROM ContentVersion
                WHERE ContentDocumentId IN: setContentDocumentIds
                ORDER BY SystemModStamp DESC
            ];
            listFiles[0].Title = certificateRecord.RecordType.Name;
            update listFiles;
        }
        //Special Certificate of Legal Existence
        else if (certificateRecord.RecordType.Name == 'Special Certificate of Legal Existence') {
            Set<Id> setContentDocumentIds = new Set<Id> ();

            for (ContentDocumentLink uploadedFile: [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId =: certificateRecord.Id
                    ORDER BY SystemModStamp DESC
                ]) {
                setContentDocumentIds.add(uploadedFile.ContentDocumentId);
            }
            List<ContentVersion> listFiles = [
                SELECT Title
                FROM ContentVersion
                WHERE ContentDocumentId IN: setContentDocumentIds
                ORDER BY SystemModStamp DESC
            ];
            listFiles[0].Title = 'Special ' + certificateRecord.Certificate_Type__c + ' ' + certificateRecord.Type__c;
            update listFiles;
        }
        update certificateRecord;

        
        if(certificateRecord.RecordType.Name == 'Business Copy Request' 
            || certificateRecord.RecordType.Name == 'Trade & Service Mark Copy Request' 
            || certificateRecord.RecordType.Name == 'UCC Copy Request'
        ) {
            generateNintexOutputDigitalCopyReq(recordId, certificateRecord.Status__c);
        }

        generateNintexOutput(recordId, certificateRecord.Status__c);
    }

    public static void generateNintexOutputDigitalCopyReq(Id filingId, String status) {
        //1. Filing output w/ sdocs
        NintexDocumentGeneration.generateFilingOutputDigitalCertified(new List<NintexDocumentGeneration.NintexWrapper> {
            new NintexDocumentGeneration.NintexWrapper(
                filingId,
                status,
                'Certified' //type
            )
        });
    }

    //Added as part of BRS-6407
    private static void updateMarkFiling(Id recordId) {
        Mark_Filing__c Mark_Filing_Record = [
            SELECT Registration_Number__c, Name, Class_of_Goods_Service__c,
                Date_of_1st_Use_Anywhere__c, Date_of_1st_Use_in_CT__c, Description_of_Mark__c,
                Disclaimer__c, Expiration_Date__c, Federal_Registration_Number_s__c,
                Federal_Registration_of_Mark__c, Filing_Date__c, Filing_Fee__c, Filing_number__c,
                Filing_Type__c, Id, Ist_Expiration_Date__c, Keywords__c, Mark_Type__c,
                Mark_used_for__c, Mark__c, Method_of_use__c, Number_of_Pages__c, Other_Assignee_Type__c,
                Other_Owner_Type__c, Owner_City__c, Owner_Country__c, Owner_Name__c,
                Owner_State__c, Owner_Street_Address__c, Owner_Type__c, Owner_Unit__c,
                Owner_Zip_Code__c, Partner_Names__c, Registration_Date__c, Renewal_Date__c,
                State_Country_of_Formation__c, Status__c, Image_Path__c, Sdoc_Filing_Number__c,
                Assignee_City__c, Assignee_Country__c, Assignee_Name__c, Assignee_State__c,
                Assignee__c, Assignee_Street_Address__c, Assignee_Type__c, Assignee_Unit__c,
                Assinee_Zip_Code__c
            FROM Mark_Filing__c 
            WHERE id =: recordId
        ];

        Mark_Filing_Record.Status__c = System.label.UCC_FILING_STATUS;
        /** Generate filing number **/
        String filingno = Mark_Filing_Record.Name.substringAfter('M-');
        Mark_Filing_Record.Filing_number__c = filingno;
        Mark_Filing_Record.Registration_Number__c = filingno;

        if (Mark_Filing_Record.Filing_Type__c == 'Registration') {
            Date regDate = Mark_Filing_Record.Registration_Date__c;
            Mark_Filing_Record.Expiration_Date__c = regDate.addYears(5);

            Date renewalDate = regDate.addYears(5);
            Mark_Filing_Record.Renewal_Date__c = regDate.addYears(5).addMonths(-6);
            Mark_Filing_Record.Ist_Expiration_Date__c = regDate.addYears(5);
            
            if (String.isBlank(Mark_Filing_Record.Mark__c)) {
                String MarkRecordId = createMarkObject(Mark_Filing_Record);
                Mark_Filing_Record.Mark__c = MarkRecordId;
            }
        } else if (Mark_Filing_Record.Filing_Type__c == 'Renewal') {
            updateMarkObjectonRenewal(Mark_Filing_Record);
        } else if (Mark_Filing_Record.Filing_Type__c == 'Assignment') {
            //Added as part of BRS-6407
            updateOwnerDetailsOnAssignment(Mark_Filing_Record);
        } else if (Mark_Filing_Record.Filing_Type__c == 'Cancellation') {
            Mark__c markdata = [Select id, status__c from Mark__c where id =: Mark_Filing_Record.Mark__c];

            markdata.status__c = 'Cancelled';
            update markdata;
            //  updateMarkObjectonRenewal(Mark_Filing_Record);
        } else if (Mark_Filing_Record.Filing_Type__c == 'Owner Address Change') {
            updateMarkObjectwithOwnerAddress(Mark_Filing_Record);
        } else if (Mark_Filing_Record.Filing_Type__c == 'Owner Name Change') {
            updateMarkObjectwithOwnerName(Mark_Filing_Record);
        } else if (Mark_Filing_Record.Filing_Type__c == 'State of Formation Change') {
            updateMarkObjectwithStateCountryofFormation(Mark_Filing_Record);
        }
		//Adding logic to add Specimen of Mark through pdf stamps into Nintex template - 6462
        String imgName = Mark_Filing_Record.Sdoc_Filing_Number__c + ' - Mark Image';
        List <ContentVersion> fileVersion = [SELECT id, VersionData, Title, FileExtension FROM ContentVersion WHERE Title = :imgName LIMIT 1];
        List <Folder> f = [SELECT Id, Name, DeveloperName, AccessType FROM Folder where Type = 'Document' and Name ='Mark Images' LIMIT 1];
        Document docImg = new Document();
        if(fileVersion.size()>0 && f.size()>0){
        
        docImg.Body = fileVersion[0].VersionData ; 
        docImg.Name = fileVersion[0].Title; 
        docImg.IsPublic = true; 
        docImg.ContentType = 'image/' + fileVersion[0].FileExtension;
        docImg.Type = fileVersion[0].FileExtension;//extension type png
        docImg.FolderId = f[0].id;
        insert docImg;
        }
        Mark_Filing_Record.MarkImageDocId__c = docImg.id;
        update Mark_Filing_Record;

        generateNintexOutput(recordId, Mark_Filing_Record.Status__c);
    }

     /********************************************************************************************
        METHOD NAME    : rejectFiling
        DESCRIPTION    : Updates Record for Rejected status
        RETURN TYPE    : Boolean
        PARAMETER      : sObject,Boolean
    ********************************************************************************************/
    @AuraEnabled
    public static String rejectFiling(sObject record, Boolean confirmFile) {
        String toastMsg =  ''; 
        record.put('Status__c', System.label.UCC_FILING_STATUS_Rejected);
        
        try {
            if(record instanceof UCC_Filing__c && confirmFile != null){
                record.put('Confirm_File_Validation__c', confirmFile);
            }
        
            //rename uploaded collateral
            if(
                (record instanceof UCC_Filing__c && !System.Label.Online_label.equalsIgnoreCase(String.valueOf(record.get('Filing_Source__c'))))
                || (record instanceof Business_Filing__c && !System.Label.Online_label.equalsIgnoreCase(String.valueOf(record.get('Source__c'))))
                || (record instanceof Mark_Filing__c)
				|| (record instanceof Certficate__c)
            ) {
                renameBOUpload(record);
            }

            update record;
            toastMsg = getDisplayMssg(record);
            generateNintexOutput(record.Id, System.label.UCC_FILING_STATUS_Rejected);
        }
        catch(DmlException e) {
            toastMsg = 'ERROR';
            BOS_Utility.handleException(e);
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return toastMsg;
    }

    /********************************************************************************************
        METHOD NAME    : getFiles
        DESCRIPTION    : Fetches document, checks file size. If file size greater than a limit,
                         the uploaded doc is deleted.
        RETURN TYPE    : List<ContentDocument>
    ********************************************************************************************/
    @AuraEnabled
    public static List<ContentDocument> getFiles(String recordId, String docId,Boolean isMicroFilm){
        Set<Id> recordIds = new Set<Id>{recordId};
            List<ContentDocument> cdocs = new List<ContentDocument>(); 
            Integer permissibleFileSize;
        String sObjectName = SchemaUtility.getObjectFromId(recordId).getName();
       if(isMicroFilm){ permissibleFileSize =  10485760 ;
    }else{
        permissibleFileSize = (sObjectName == 'Certficate__c') ? 10485760 : ((sObjectName == 'UCC_Filing__c') ? 8388608 : 4194304); // if Certficate__c ? 10 MB : if UCC ? 8MB : 4 MB(for others) 6172

    }
        if(!recordIds.isEmpty() && String.isNotBlank(docId)){  
            cdocs = [SELECT Id, ContentSize, Title, FileType FROM ContentDocument WHERE Id = :docId];
            
            if (!cdocs.isEmpty()) {
                if (cdocs[0].ContentSize > permissibleFileSize) {
                    delete cdocs;
                    return null;
                }
                else if(sObjectName == 'Mass_Agent_Change__c'){
                    cdocs[0].Title = System.label.MassAgentChangeLabel;
                    update cdocs;
                }
            }
        }
        return cdocs;
    }

    /********************************************************************************************
        METHOD NAME    : deleteFiles
        DESCRIPTION    : Deletes Documents 
        RETURN TYPE    : void
        PARAMETER      : String
    ********************************************************************************************/
    @AuraEnabled  
    public static void deleteFiles(sObject filing, string sdocumentId){ 
        String mssg = brs_fileUploaderController.deleteDocuments(sdocumentId);
    }

    global without sharing class Requests {
        @InvocableVariable
        global string recordid;
    } 
    global without sharing class Results {
        @InvocableVariable
        global string message;
    }

    @InvocableMethod
    public static List<Results> approveFilingfromFlow(List<Requests> Requests ) {
        Boolean isSuccess = false;        
         Boolean confirmFile=true;
         String message;
        try{  
           
            Id recordId = Requests[0].recordid;
            if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.BRS_UCCFilingObject){
				Map<String, Id> mapRecordTypesLien = SchemaUtility.getRecordTypes('UCC_Lien__c');
				Id ofsLien = mapRecordTypesLien.get(System.label.OFS_Value);
				Id aircraftLien = mapRecordTypesLien.get(System.label.AircraftRecordType_Label);
				Id judgementLien = mapRecordTypesLien.get(System.label.JudgementsRecordTypeLabel);
				Id irsLien = mapRecordTypesLien.get(System.label.lien_Type_Irs);
				
				Map<String, Id> mapRecordTypesFiling = SchemaUtility.getRecordTypes('UCC_Filing__c');
				Id newFiling = mapRecordTypesFiling.get(System.label.NewLienRecordType_Label);
				Id newIRSFiling = mapRecordTypesFiling.get(System.label.lien_Type_Irs);
				
				UCC_Filing__c filingRec = [SELECT Id, Confirm_File_Validation__c, RecordTypeId, Name, Status__c, Type__c, IRS_SLID_Number__c, Filing_Number__c, UCC_Lien_Id__c, UCC_Lien_Type__c FROM UCC_Filing__c WHERE id=:recordId WITH SECURITY_ENFORCED];

				if((filingRec.RecordTypeId == newFiling || (filingRec.RecordTypeId == newIRSFiling && filingRec.Type__c.equalsIgnoreCase(System.label.OFS_Value))) && filingRec.UCC_Lien_Id__c == null){				
					UCC_Lien__c newLienRec = new UCC_Lien__c();
					newLienRec.Name = filingRec.Name.substringAfter('UCC-');
					newLienRec.UCC_Lien_Number__c = filingRec.Name.substringAfter('UCC-');
					newLienRec.IRS_Number__c = filingRec.IRS_SLID_Number__c;
					newLienRec.Type__c = filingRec.UCC_Lien_Type__c;
					
					if(filingRec.Type__c == System.label.Aircraft_Label || filingRec.Type__c == System.label.Vessel_Label){
                         						newLienRec.RecordTypeId = aircraftLien;
					}
					else if(filingRec.Type__c == System.label.Judgement_Label || filingRec.Type__c == System.label.JudgmentPersonalPropertyLabel){
                         						newLienRec.RecordTypeId = judgementLien;
					}
					else if(filingRec.Type__c == System.label.OFS_Value && filingRec.UCC_Lien_Type__c == System.label.lien_Type_Irs){
                         						newLienRec.RecordTypeId = irsLien;
					}
					else if(filingRec.Type__c == System.label.OFS_Value || filingRec.Type__c == System.label.NoticeOfAttachmentLabel){ 
                        						newLienRec.RecordTypeId = ofsLien;
					}                   
					if(Schema.SObjectType.UCC_Lien__c.isCreateable()){
						if(newLienRec != null){
							insert newLienRec;
						}
					}
					filingRec.UCC_Lien_Id__c = newLienRec.Id;             
				}
				filingRec.Status__c = System.label.UCC_FILING_STATUS;
				filingRec.Confirm_File_Validation__c = confirmFile;
				if(Schema.SObjectType.UCC_Filing__c.isUpdateable()){
					if(filingRec != null){
						update filingRec;
					}
				}
			}
			
			else if(SchemaUtility.getObjectFromId(recordId).getName() == System.label.Business_Filing_API_Name){
                Business_Filing__c busFilingRec = [SELECT Id, Effective_Date__c,Work_Order__c, Total_Authorized_Shares__c, Type__c, Filing_Type__c, Business_Type__c, Citizenship__c, Status__c, Account__c, Account__r.Status__c, Account__r.Total_Authorized_Shares__c,Filing_Date__c,Sub_Type__c FROM Business_Filing__c WHERE id=:recordId WITH SECURITY_ENFORCED];
                //added empty check as part of code review activity
                if(busFilingRec != null){
                    busFilingRec.Status__c = System.label.UCC_FILING_STATUS;
                    if(busFilingRec.Account__c != null){
                        Account account = [Select Id, Status__c, Reservation_Expiration_Date__c, Total_Authorized_Shares__c,Date_Registration__c,Annual_Report_Due_Date__c,Citizenship__c,Business_Type__c,(Select Id, Due_Date__c, Type__c, Filing_Date__c, Status__c from Business_Filings__r WHERE Type__c ='First Report' AND Due_Date__c != NULL Order By Due_Date__c DESC LIMIT 1)  from Account where id=:busFilingRec.Account__c];
                                              
                        if(account != null){
                            if(busFilingRec.Type__c == System.label.brs_Cancellation){
                                                 account.Status__c = System.label.Cancelled;
                            }
                            else  if(busFilingRec.Type__c == System.label.BRS_Name_Reservation_Flow){
                                account.Status__c=System.label.brs_BusinessReservationStatus;
                                account.Reservation_Expiration_Date__c = Datetime.newInstance(busFilingRec.Filing_Date__c.year(), busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day(), 23, 59, 00).addDays(120);
                                account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                                account.Has_Business_Name_Reservation_No__c=true;
                            }
                            else if(busFilingRec.Type__c == System.label.Amendment_Label && ((busFilingRec.Citizenship__c == System.label.Domestic && busFilingRec.Business_Type__c == System.label.Stock) || (busFilingRec.Business_Type__c == System.label.B_Corp))){
                                                                 account.Total_Authorized_Shares__c = busFilingRec.Total_Authorized_Shares__c;
                            }
                            else if((busFilingRec.Type__c == System.label.brs_Reinstatement || busFilingRec.Type__c == System.label.RevocationDissolution_Header_Question) && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                account.Status__c = System.label.ACTIVE;
                             if(busFilingRec.Type__c == System.label.brs_Reinstatement){
                                 account.Latest_Report__c=datetime.newinstance(date.today().year(), date.today().month(), date.today().day());
                                if(busFilingRec.Sub_Type__c== System.label.With_First_Report || busFilingRec.Sub_Type__c == System.label.With_FirstReport_and_Name_Change){
                                    if(account.Citizenship__c == System.label.Domestic && (account.Business_Type__c == System.label.Label_Stock_Comparable || account.Business_Type__c == System.label.Label_NonStock_Comparable || account.Business_Type__c == System.label.B_Corp)){
                                        account.Annual_Report_Due_Date__c = date.newinstance(busFilingRec.Filing_Date__c.year() + 1, busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day());
                                    }
                                }
                                else if(busFilingRec.Sub_Type__c== System.label.With_Annual_Report || busFilingRec.Sub_Type__c == System.label.With_Annual_Report_Name_Change){
                                    if(account.Business_Type__c == System.Label.Label_Stock_Comparable || account.Business_Type__c == System.label.Label_NonStock_Comparable || account.Business_Type__c == System.label.B_Corp){
                                       Date firstReportDate;
                                        if(!account.Business_Filings__r.isEmpty()){
                                           if( account.Business_Filings__r[0].Filing_Date__c!=Null){
                                            firstReportDate=account.Business_Filings__r[0].Filing_Date__c;
                                           }
                                       }
                                       if(firstReportDate!=null){
                                        account.Annual_Report_Due_Date__c = date.newinstance(firstReportDate.year() + 1, firstReportDate.month(),firstReportDate.day());

                                       }else{
                                        account.Annual_Report_Due_Date__c = date.newinstance(account.Date_Registration__c.year() + 1, account.Date_Registration__c.month(), account.Date_Registration__c.day());
                                       }
                                    }
                                }else if(account.Business_Type__c == System.label.LLP){
                                    account.Annual_Report_Due_Date__c = date.newinstance(account.Date_Registration__c.year() + 1, account.Date_Registration__c.month(), account.Date_Registration__c.day());

                                }else if(account.Business_Type__c == System.label.Business_Type_LLC){
                                    account.Annual_Report_Due_Date__c = date.newinstance(Date.Today().year() + 1 , 3, 31);

                                }
                             }
                            }
                            else if(busFilingRec.Type__c == System.label.brs_registrationNameLabel){
                                account.Status__c=System.label.brs_BusinessReservationStatus;
                                account.Reservation_Expiration_Date__c = Datetime.newInstance(busFilingRec.Filing_Date__c.year(), busFilingRec.Filing_Date__c.month(), busFilingRec.Filing_Date__c.day(), 16, 30, 00).addDays(365);
                                account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                                account.Has_Business_Name_Reservation_No__c=true;
                            }
                            else if(busFilingRec.Type__c == System.label.brs_registrationCorpNameLabel){
                                account.Status__c=System.label.brs_BusinessReservationStatus;
                                account.Reservation_Expiration_Date__c=Datetime.newInstance(busFilingRec.Filing_Date__c.year(), 12, 31, 23, 59, 00); 
                                account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                                account.Has_Business_Name_Reservation_No__c=true;
                            }
                            else if(busFilingRec.Type__c == System.label.brs_RenewCorpNameRegistration || busFilingRec.Type__c == System.label.brs_RenewNameRegistration){
                                                     account.Reservation_Expiration_Date__c = account.Reservation_Expiration_Date__c.addYears(1);
                            }
                            else if(busFilingRec.Type__c == System.label.brs_NameReserCancellationLabel){
                                account.Status__c = System.label.brsStatus_ReservedCancel;
                            }
                            else if(busFilingRec.Type__c == System.label.Transfer_of_Name_Reservation){   
                                                             account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                            }
                            else if(busFilingRec.Type__c == System.label.Transfer_of_Registration_of_Name){
                                account.Pin__c=brs_businessPinGeneration.generateReservationPin(account.Id,6);
                            }
                            else if(busFilingRec.Type__c == System.label.Business_Formation_Label && busFilingRec.Business_Type__c == System.label.brs_GeneralPartnership){
                                                           account.Status__c = System.label.brsStatus_Recorded;
                            }
                            else if(busFilingRec.Type__c == System.label.Dissolution_Label && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){  
                                                 account.Status__c=System.label.DISSOLVED_STATUS;
                            }
                            else if(busFilingRec.Type__c == System.label.Withdrawal_Label && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){  
                                                  account.Status__c=System.label.Withdrawn;
                            }
                            else if(busFilingRec.Type__c == System.label.brs_Cancellation && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                                    account.Status__c=System.label.Cancelled;
                            }
                            else if(busFilingRec.Type__c == System.label.Renunciation_Status_Report && (busFilingRec.Effective_Date__c <= System.today() || busFilingRec.Effective_Date__c ==null)){
                                          account.Status__c=System.label.Renunciated;
                            }
                            /**
                            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: Adding functionality to move data from AR/FR when approve is clicked.
                            * Change(s)/Modification(s) Description : Adding functionality to move data from AR/FR when approve is clicked.
                            * Change(s)/Modification(s) Made on : 2021-04-22
                            * Change(s)/Modification(s) Made by : Avinash Shukla
                            */
                            else if(busFilingRec.Type__c == System.Label.First_Report || busFilingRec.Type__c == System.Label.Annual_Report){
                                busFilingRec.Status__c  = 'Approved';                               
                                brs_UpdateAccountFromFilingUtlity.updateAccountFromFiling(new List<Business_filing__c>{busFilingRec});
                            }
                            else{
                                account.Status__c = System.label.ACTIVE;
                            }  
                             if(busFilingRec.Type__c == System.label.Business_Formation_Label || busFilingRec.Type__c == System.label.Business_Registration_Label){                              account.Date_Registration__c= busFilingRec.Filing_Date__c;
                            }                           
                        }
                        update busFilingRec;
                        update account;
                    }
                }
            }
            isSuccess = true;   

            message =  'Approval is successful';
        }

        catch(DmlException ex){
            isSuccess = false;
            message= ex.getMessage();
            BOS_Utility.ExceptionHandler(className, 'approveFiling', objectName, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        List<Results> lstResults = new List<Results>();
       Results r = new Results();
        r.message =message;
        lstResults.add(r);
        system.debug('lstResults'+lstResults);
        return lstResults;
    }

    @AuraEnabled
    public static Boolean rejectFilingfromFlow(sObject record, Boolean confirmFile) {  
        record.put('Status__c', System.label.UCC_FILING_STATUS_Rejected);
        Boolean isSuccess = String.isNotBlank(String.valueOf(record.get('Reason_for_Rejection__c')));
      //  Boolean confirmFile=true;
        try {
            if(record instanceof UCC_Filing__c)
                record.put('Confirm_File_Validation__c', confirmFile);

            //rename uploaded collateral
            if(
                (record instanceof UCC_Filing__c && !System.Label.Online_label.equalsIgnoreCase(String.valueOf(record.get('Filing_Source__c'))))
                ||
                (record instanceof Business_Filing__c && !System.Label.Online_label.equalsIgnoreCase(String.valueOf(record.get('Source__c'))))
            ) {
                renameBOUpload(record);
            }

            update record;
        }
        catch(Exception ex){
            isSuccess = false;
            BOS_Utility.ExceptionHandler(className, 'rejectFiling', objectName, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
        return isSuccess;
    }

    /********************************************************************************************
        METHOD NAME    : generateEmailAttachment
        DESCRIPTION    : sends email with Attachment for BO
        RETURN TYPE    : Void
        PARAMETER      : sObject
    ********************************************************************************************/
	@AuraEnabled
    public static void generateEmailAttachment(UCC_Filing__c filing) {
        if(filing!=null){
            BRS_UCC_EmailNotification.Requests emailRequest = new BRS_UCC_EmailNotification.Requests();
            emailRequest.filingRec = filing;

            BRS_UCC_EmailNotification.sendUCCEmail(new List<BRS_UCC_EmailNotification.Requests>{emailRequest});
        }
        
    }

    /**
        @desc: BRS-4082 | Rename rejection collateral to Rejected - <filingType>
     */
     @TestVisible
    private static void renameBOUpload(sObject filing) {
        String obj = SchemaUtility.getObjectFromId(filing.Id).getName();
        Set<Id> setContentDocumentIds = new Set<Id>(); 
        List<ContentVersion> listContentVersions = new List<ContentVersion>();
        
        for(ContentDocumentLink ContentDoc :[
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :filing.Id
        ]) {
            setContentDocumentIds.add(contentDoc.ContentDocumentId);
        }

        if(!setContentDocumentIds.isEmpty()) {
            for(ContentVersion contentVersion :[
                SELECT Title
                FROM ContentVersion
                WHERE ContentDocumentId IN :setContentDocumentIds
            ]) {
                 if(filing instanceof Mark_Filing__c){
                                          contentVersion.Title = System.Label.Rejected + ' - ' + filing.get('Filing_Type__c');
                }
				else if(filing instanceof Certficate__c && (filing.getSObject('RecordType').get('Name') == 'Request for Search of Mark' || filing.getSObject('RecordType').get('Name') == 'Trade & Service Mark Copy Request')){ 
                                      contentVersion.Title = System.Label.Rejected + ' - ' + filing.getSObject('RecordType').get('Name');
                }
                else
                {
                    contentVersion.Title = System.Label.Rejected + ' - ' + filing.get('Type__c');
                }
                listContentVersions.add(contentVersion);
            }
            
            update listContentVersions;
        }
    }

  /********************************************************************************************
        METHOD NAME    : generacheckMarkFilingsteFilingOutput
        DESCRIPTION    : Check mark mandatory fields
        RETURN TYPE    : String
        PARAMETER      : String
        owner          : Rohit
    ********************************************************************************************/
    @AuraEnabled
    public static String checkMarkFilings(String record) {
        String message;
        try{
            if(String.isNotBlank(record)){
                List<Mark_Filing__c> filing = [Select id,Mark__r.Status__c,Mark__r.Renewal_Date__c,Mark__r.Expiration_Date__c,Filing_Type__c,Federal_Registration_Number_s__c,Mark_Type__c,Class_of_Goods_Service__c,Description_of_Mark__c,Mark_used_for__c,Method_of_use__c,
                Owner_Name__c,Owner_Type__c,State_Country_of_Formation__c , Owner_Street_Address__c,Owner_Country__c,Owner_State__c,Mark__c,
                Owner_City__c,Owner_Zip_Code__c,Registration_Date__c,Date_of_1st_Use_in_CT__c,Date_of_1st_Use_Anywhere__c,Federal_Registration_of_Mark__c,Number_of_Pages__c 
                ,Assignee_Name__c,Assignee_Type__c,Assignee_Street_Address__c,Assignee_Country__c,Assignee_State__c,
                Assignee_City__c,Assignee__c,Assignee_Unit__c,Assinee_Zip_Code__c, Image_Path__c,Previous_Name_State__c, Sdoc_Filing_Number__c
                From Mark_Filing__c where id =:record];

if(filing!=null && !filing.isEmpty()){


    Mark_Filing__c markfiling = filing[0];
      if(markfiling.Filing_Type__c == 'Registration'){

         if((markfiling.Mark_Type__c == 'Service Mark' || markfiling.Mark_Type__c == 'Trade Mark')  && (String.isBlank(markfiling.Class_of_Goods_Service__c) ||
        String.isBlank(markfiling.Description_of_Mark__c) ||String.isBlank(markfiling.Mark_used_for__c) ||String.isBlank(markfiling.Method_of_use__c))){
                      message = System.Label.MarkInformationError;
        }
        else if((markfiling.Mark_Type__c == 'Service Mark' || markfiling.Mark_Type__c == 'Trade Mark')  && String.isBlank(markfiling.Owner_Type__c)|| String.isBlank(markfiling.Owner_Name__c)||String.isBlank(markfiling.Owner_Street_Address__c)
       ||String.isBlank(markfiling.Owner_Country__c) ||(String.isBlank(markfiling.Owner_State__c) && markfiling.Owner_Country__c!='Canada')||String.isBlank(markfiling.Owner_City__c) 
       ||String.isBlank(markfiling.Owner_Zip_Code__c)  ){
                    message = System.Label.MarkOwnerInformationError;
       }
       else if(String.isNotBlank(markfiling.Owner_Type__c) && markfiling.Owner_Type__c != 'Individual' && String.isBlank(markfiling.State_Country_of_Formation__c))
      {
     message = System.Label.MarkStateofFormationInformationError;
      }
      
     else if(markfiling.Registration_Date__c ==null|| markfiling.Date_of_1st_Use_in_CT__c ==null||markfiling.Date_of_1st_Use_Anywhere__c ==null){
     message = System.Label.MarkDateInformationError;
      }
    else if(String.isBlank(markfiling.Federal_Registration_of_Mark__c) ||markfiling.Number_of_Pages__c==0){
     message = System.Label.MarkFederalRegistrationInfoError;
      }
         else if((String.isNotBlank(markfiling.Federal_Registration_of_Mark__c)&& markfiling.Federal_Registration_of_Mark__c == 'Yes')
       && String.isBlank(markfiling.Federal_Registration_Number_s__c)){
       message = System.Label.MarkFederalRegistrationNumberError;
     }
	 else if(String.isBlank(markfiling.Image_Path__c))
     {
        message = System.Label.Mark_Image_Error;
     }
else{
    message = 'Success';
}
    }
    
    else if(markfiling.Filing_Type__c == 'Renewal' ){
        date RenewalDate =Date.today();
        RenewalDate = RenewalDate.addMonths(-6);
        if(markfiling.Mark__c == null){
            message = System.label.MarkObjectError;
        }
        else if( (markfiling.Mark__r.Expiration_Date__c == null && markfiling.Mark__r.Expiration_Date__c < System.today()&& 
        markfiling.Mark__r.Renewal_Date__c == null || markfiling.Mark__r.Renewal_Date__c > System.today())){
                     message = System.Label.MarkObjectRenewalError;
        }
		else if(String.isBlank(markfiling.Image_Path__c))
		{
			message = System.Label.Mark_Image_Error;
		}
        else{
            message = 'Success';
        }
        }
        else if(markfiling.Filing_Type__c == 'Assignment' ){
            if(markfiling.Mark__c == null){
                                 message = System.label.MarkObjectAssignmentError;
            }
            else if( markfiling.Mark__r.Status__c == null || markfiling.Mark__r.Status__c !=System.label.ACTIVE){
                message = System.label.MarkObjectAssinmentActiveError; 
            }
            else if(String.isBlank(markfiling.Assignee_Name__c)|| String.isBlank(markfiling.Assignee_Type__c) ||String.isBlank(markfiling.Assignee_Street_Address__c) ||String.isBlank(markfiling.Assignee_Country__c) ||String.isBlank(markfiling.Assignee_State__c) 	||String.isBlank(markfiling.Assignee_City__c) ||String.isBlank(markfiling.Assinee_Zip_Code__c)){
                 				message = System.Label.AssigneeInformationError;
            }
            else if(String.isNotBlank(markfiling.Assignee_Type__c) && markfiling.Assignee_Type__c != System.label.Agent_Individual_Option && String.isBlank(markfiling.Assignee__c)){
             message = System.Label.AssigneeFormationError;
            }
			else if(String.isBlank(markfiling.Image_Path__c))
			{
				message = System.Label.Mark_Image_Error;
			}
            else{
                message = 'Success';
            }
        }
        else if(markfiling.Filing_Type__c == 'Cancellation' ){
            if(markfiling.Mark__c == null){
                message = System.label.MarkObjectCancellationError;
            }
            else if( markfiling.Mark__r.Status__c == null || markfiling.Mark__r.Status__c !=System.label.ACTIVE){
                message = System.label.MarkObjectCancellationActiveError; 
            }
            
            else{
                message = 'Success';
            }
        }

        else if(markfiling.Filing_Type__c == 'Owner Address Change' ){
            if(markfiling.Mark__c == null){
                message = System.label.MarkObjectCancellationError;
            }
            else if( markfiling.Mark__r.Status__c == null || markfiling.Mark__r.Status__c !=System.label.ACTIVE){
                message = System.label.MarkObjectAddresschangeError; 
            }
            else if(String.isBlank(markfiling.Owner_Street_Address__c)
       ||String.isBlank(markfiling.Owner_Country__c) ||(String.isBlank(markfiling.Owner_State__c) && markfiling.Owner_Country__c!='Canada')||String.isBlank(markfiling.Owner_City__c) 
       ||String.isBlank(markfiling.Owner_Zip_Code__c)  ){
        message = System.Label.MarkOwnerInformationError;
       }
            else{
                message = 'Success';
            }
        }

        else if(markfiling.Filing_Type__c == 'Owner Name Change' ){
            if(markfiling.Mark__c == null){
                message = System.label.MarkObjectCancellationError;
            }
            else if( markfiling.Mark__r.Status__c == null || markfiling.Mark__r.Status__c !=System.label.ACTIVE){
                message = System.label.MarkObjectNameChangeError; 
            }
            else if(String.isBlank(markfiling.Previous_Name_State__c))
            {
                message= System.Label.Trade_Service_Previous_Name_State;
            }
            else if(String.isBlank(markfiling.Owner_Name__c) ){
        message = System.Label.MarkOwnerInformationError;
			}
			else if(String.isBlank(markfiling.Image_Path__c))
			{
				message = System.Label.Mark_Image_Error;
			}
            else{
                message = 'Success';
            }
        }
        else if(markfiling.Filing_Type__c == 'State of Formation Change' ){
            if(markfiling.Mark__c == null){
                                 message = System.label.MarkObjectCancellationError;
            }
            else if( markfiling.Mark__r.Status__c == null || markfiling.Mark__r.Status__c !=System.label.ACTIVE){
                message = System.label.MarkObjectFOrmationChangeError; 
            }
            else if(String.isBlank(markfiling.Previous_Name_State__c)){
                                 message= System.Label.Trade_Service_Previous_Name_State;
            }
            else if(String.isBlank(markfiling.State_Country_of_Formation__c) ){
        message = System.Label.MarkStateofFormationInformationError;
			}
			else if(String.isBlank(markfiling.Image_Path__c))
			{
				message = System.Label.Mark_Image_Error;
			}
            else{
                message = 'Success';
            }
        }
    else{
        message = 'Success';
    }
}
            }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'checkMarkFilings', null, null, BOS_Utility.sSeverity, ex, null);
 
        }
        return message;    
    }

    
  /********************************************************************************************
        METHOD NAME    : createMarkObject
        DESCRIPTION    : Check mark object after approval
        RETURN TYPE    : String
        PARAMETER      : Mark_Filing__c
        owner          : Rohit
    ********************************************************************************************/

public static String createMarkObject(Mark_Filing__c filing){
    try{
Mark__c markData = new Mark__c();

markData.Class_of_Goods_Service__c=filing.Class_of_Goods_Service__c;
markData.Date_of_1st_Use_Anywhere__c=filing.Date_of_1st_Use_Anywhere__c;
markData.Date_of_1st_Use_in_CT__c=filing.Date_of_1st_Use_in_CT__c;
markData.Disclaimer__c=filing.Disclaimer__c;
markData.Expiration_Date__c=filing.Expiration_Date__c;
markData.Federal_Registration_Number_s__c=filing.Federal_Registration_Number_s__c;
markData.Federal_Registration_of_Mark__c=filing.Federal_Registration_of_Mark__c;
markData.Keywords__c=filing.Keywords__c;
markData.Mark_Type__c=filing.Mark_Type__c;
markData.Mark_used_for__c=filing.Mark_used_for__c;
markData.Method_of_use__c=filing.Method_of_use__c;
markData.Number_of_Pages__c=filing.Number_of_Pages__c;
markData.Other_Owner_Type__c=filing.Other_Owner_Type__c;
markData.Owner_City__c=filing.Owner_City__c;
markData.Owner_Country__c=filing.Owner_Country__c;
markData.Owner_Name__c=filing.Owner_Name__c;
markData.Owner_State__c=filing.Owner_State__c;
markData.Owner_Street_Address__c=filing.Owner_Street_Address__c;
markData.Owner_Type__c=filing.Owner_Type__c;
markData.Owner_Unit__c=filing.Owner_Unit__c;
markData.Owner_Zip_Code__c=filing.Owner_Zip_Code__c;
markData.Partner_Names__c=filing.Partner_Names__c;
markData.Registration_Date__c=filing.Registration_Date__c;
markData.Registration_number__c=filing.Registration_Number__c;
markData.Renewal_Date__c=filing.Renewal_Date__c;
markData.Description_of_Mark__c=filing.Description_of_Mark__c;
markData.State_Country_of_Formation__c=filing.State_Country_of_Formation__c;
markData.Status__c=System.label.ACTIVE;
markData.X1st_Expiration_Date__c=filing.Ist_Expiration_Date__c;
markData.Name = filing.Filing_number__c;
markData.Image_Path__c = filing.Image_Path__c;
Insert markData;

//Update Image of mark on Mark object
String fileTitle = filing.Sdoc_Filing_Number__c + ' - ' + 'Mark Image';
Set<Id> setFileId = new Set<Id>();
List<ContentDocumentLink> docLinkList = [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :filing.id order by Id desc]; 
for(ContentDocumentLink contentDoclink : docLinkList)
{
    setFileId.add(contentDoclink.ContentDocumentId);
}
ContentVersion version = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :setFileId AND Title=:fileTitle LIMIT 1]; 
ContentDocumentLink contentDocLinkMark = new ContentDocumentLink(
                		ContentDocumentId = version.ContentDocumentId,
                    	LinkedEntityId = markData.Id
                	);
insert contentDocLinkMark;


return markData.id;
    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'createMarkObject', null, null, BOS_Utility.sSeverity, ex, null);
 
    }
    return null;
}


  /********************************************************************************************
        METHOD NAME    : updateMarkObjectonRenewal
        DESCRIPTION    : update mark object after renewal
        RETURN TYPE    : void
        PARAMETER      : Mark_Filing__c
        owner          : Rohit
    *******************************************************************************************/

public static void updateMarkObjectonRenewal(Mark_Filing__c filing){
    try{
Mark__c markData = [Select id,Renewal_Date__c,Expiration_Date__c,Owner_City__c,Owner_Country__c,Owner_State__c,Owner_Street_Address__c,
Owner_Unit__c,Owner_Zip_Code__c,Owner_Name__c from Mark__c where id =:filing.Mark__c];

if(markData.Expiration_Date__c!=null){
markData.Expiration_Date__c=markData.Expiration_Date__c.addYears(5);
}else{
    Date newDate = System.today();
    markData.Expiration_Date__c = newDate.addYears(5)  ;
}
filing.Expiration_Date__c  =markData.Expiration_Date__c ;
if(String.isNotBlank(filing.Owner_Country__c)){
markData.Owner_Country__c=filing.Owner_Country__c;
}
if(String.isNotBlank(filing.Owner_Name__c)){
markData.Owner_Name__c=filing.Owner_Name__c;
}
if(String.isNotBlank(filing.Owner_State__c)){
markData.Owner_State__c=filing.Owner_State__c;
}
if(String.isNotBlank(filing.Owner_Street_Address__c)){
markData.Owner_Street_Address__c=filing.Owner_Street_Address__c;
}
if(String.isNotBlank(filing.Owner_Unit__c)){
markData.Owner_Unit__c=filing.Owner_Unit__c;
}
if(String.isNotBlank(filing.Owner_Zip_Code__c)){
markData.Owner_Zip_Code__c=filing.Owner_Zip_Code__c;
}

if(String.isNotBlank(filing.Owner_City__c)){
    markData.Owner_City__c=filing.Owner_City__c;
    }
    markData.Renewal_Date__c=filing.Expiration_Date__c.addMonths(-6);
    filing.Renewal_Date__c  =markData.Renewal_Date__c ;
update markData;

    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'updateMarkObjectonRenewal', null, null, BOS_Utility.sSeverity, ex, null);
 
    }
    
}

//Added as part of BRS-6407
public static void updateOwnerDetailsOnAssignment(Mark_Filing__c filing){
    try{
        Mark__c markData = [Select id, Other_Owner_Type__c, Owner_City__c, Owner_Country__c, Owner_Name__c, Owner_State__c, Owner_Street_Address__c, Owner_Type__c, Owner_Unit__c, Owner_Zip_Code__c,State_Country_of_Formation__c,Partner_Names__c from Mark__c where id =:filing.Mark__c];
        markData.Owner_Type__c=filing.Assignee_Type__c;
        markData.Owner_Name__c=filing.Assignee_Name__c;
        markData.Owner_Street_Address__c=filing.Assignee_Street_Address__c;
        markData.Owner_Unit__c=filing.Assignee_Unit__c;
        markData.Owner_City__c=filing.Assignee_City__c;
        markData.Owner_State__c=filing.Assignee_State__c;
        markData.Owner_Zip_Code__c=filing.Assinee_Zip_Code__c;
        markData.Owner_Country__c=filing.Assignee_Country__c;
        markData.Other_Owner_Type__c=filing.Other_Assignee_Type__c;
        markData.State_Country_of_Formation__c=filing.Assignee__c;
        markData.Partner_Names__c=filing.Partner_Names__c;

        update markData;
    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'updateOwnerDetailsOnAssignment', null, null, BOS_Utility.sSeverity, ex, null);
    }
}


public static void updateMarkObjectwithOwnerAddress(Mark_Filing__c filing){
    try{
Mark__c markData = [Select id,Expiration_Date__c,Owner_City__c,Owner_Country__c,Owner_State__c,Owner_Street_Address__c,
Owner_Unit__c,Owner_Zip_Code__c from Mark__c where id =:filing.Mark__c];


    if(String.isNotBlank(filing.Owner_Country__c)){
    markData.Owner_Country__c=filing.Owner_Country__c;
    }
    
    if(String.isNotBlank(filing.Owner_State__c)){
    markData.Owner_State__c=filing.Owner_State__c;
    }
    if(String.isNotBlank(filing.Owner_Street_Address__c)){
    markData.Owner_Street_Address__c=filing.Owner_Street_Address__c;
    }
    if(String.isNotBlank(filing.Owner_Unit__c)){
    markData.Owner_Unit__c=filing.Owner_Unit__c;
    }
    if(String.isNotBlank(filing.Owner_Zip_Code__c)){
    markData.Owner_Zip_Code__c=filing.Owner_Zip_Code__c;
    }
    
    if(String.isNotBlank(filing.Owner_City__c)){
        markData.Owner_City__c=filing.Owner_City__c;
        }

update markData;

    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'updateMarkObjectwithOwnerAddress', null, null, BOS_Utility.sSeverity, ex, null);
 
    }
    
}

public static void updateMarkObjectwithOwnerName(Mark_Filing__c filing){
    try{
Mark__c markData = [Select id,Expiration_Date__c,Owner_City__c,Owner_Country__c,Owner_State__c,Owner_Street_Address__c,
Owner_Unit__c,Owner_Zip_Code__c,Owner_Name__c from Mark__c where id =:filing.Mark__c];


    if(String.isNotBlank(filing.Owner_Name__c)){
    markData.Owner_Name__c=filing.Owner_Name__c;
    }
    
update markData;

    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'updateMarkObjectwithOwnerName', null, null, BOS_Utility.sSeverity, ex, null);
 
    }
    
}
public static void updateMarkObjectwithStateCountryofFormation(Mark_Filing__c filing){
    try{
Mark__c markData = [Select id,State_Country_of_Formation__c from Mark__c where id =:filing.Mark__c];


    if(String.isNotBlank(filing.State_Country_of_Formation__c)){
    markData.State_Country_of_Formation__c=filing.State_Country_of_Formation__c;
    }
    
update markData;

    }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, 'updateMarkObjectwithStateCountryofFormation', null, null, BOS_Utility.sSeverity, ex, null);
       
    }
}
    
    /********************************************************************************************
        METHOD NAME    : ValidateAndCompleteWRITCase
        DESCRIPTION    : Validations when WRIT Case is marked Completed and update status
        RETURN TYPE    : String
        PARAMETER      : WRIT_Case__c
        owner          : Nancy
    *******************************************************************************************/
    @AuraEnabled
    public static String ValidateAndCompleteWRITCase(Id recordId) {
        Boolean isSuccess = false; 
        String message;
        try{
            List<WRIT_Case__c> writCase = [Select ID,Defendants_Total__c,Approved_Defendants__c,Rejected_Defendants__c,Number_of_Defendants__c,Work_Order__c,Work_Order__r.Payments_Verified__c,Status__c,(Select ID,createddate,recordtype.name from Defendants__r order by createddate) from WRIT_Case__c where ID=:recordId];
            if(!writCase.isEmpty()){
                if(writCase[0].Status__c != System.Label.In_Progress_Label){
                    message = System.Label.WRIT_Case_In_Progress_Error;
                }
                else if(writCase[0].Number_of_Defendants__c == Null || writCase[0].Number_of_Defendants__c == 0){
                    message = System.Label.Validate_number_of_defendants;
                }
                else if(writCase[0].Defendants_Total__c != writCase[0].Number_of_Defendants__c){
                    message = System.Label.Enter_all_defendants_error;
                }
                else if(writCase[0].Work_Order__r.Payments_Verified__c == False && writCase[0].Approved_Defendants__c > 0){
                    message = System.Label.Verify_Payments_Error;
                }
                else {
                    writCase[0].Status__c = System.Label.BRS_Transaction_Status;
				    update writCase;
                    //Work_Order__c workOrder = new Work_Order__c(id=writCase[0].Work_Order__c);
                    //workOrder.Status__c = System.Label.Completed_Label;
                    //Update workOrder;    //BRS-5936
                    message = 'Success';
                }
            }
            isSuccess = true;
        }
        catch(DmlException ex){
            isSuccess = false;
            BOS_Utility.handleException(ex);
            message = ex.getDmlMessage(0);
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return message;
    }

    /********************************************************************************************
        METHOD NAME    : completeMassAgentChange
        DESCRIPTION    : Method to update Mass agent change status to completed 
        RETURN TYPE    : void
        PARAMETER      : Mass_Agent_Change__c
        owner          : Aparna
    *******************************************************************************************/
    @AuraEnabled
    public static Boolean completeMassAgentChange(sObject record) { 
        Boolean isSuccess = false; 
        record.put('Status__c', System.label.BRS_Status_Value_Completed);
        try {            
            update record;
            isSuccess = true;
        }
        catch(Exception ex){
            isSuccess = false;
            BOS_Utility.ExceptionHandler(className, 'completeMassAgentChange', 'Mass Agent Change', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
        return isSuccess;
    }

    /********************************************************************************************
        METHOD NAME    : completeWRIT
        DESCRIPTION    : Method to call Nintex for WRIT and defendant object templates
        RETURN TYPE    : void
        PARAMETER      : WRIT_Case__c
        owner          : Priyanka
    *******************************************************************************************/
    @AuraEnabled
    public static void completeWRIT(WRIT_Case__c writObj) {
        try{
            if(writObj != null){
                NintexDocumentGeneration.NintexWrapper nWrapper = new NintexDocumentGeneration.NintexWrapper(writObj.Id,'');
                List<NintexDocumentGeneration.NintexWrapper> listNintexDetails = new List<NintexDocumentGeneration.NintexWrapper>{nWrapper};
                NintexDocumentGeneration.generateDocumentWritNotice(listNintexDetails);
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'completeWRIT', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class writDefWrapperClass{
        @TestVisible
        Map<Id,List<string>> rejDefMap{get;set;}
    }
    /********************************************************************************************
        METHOD NAME    : createWRITNotices
        DESCRIPTION    : Method to generate SDOCs for WRIT and defendant object 
        RETURN TYPE    : void
        PARAMETER      : String
        owner          : Priyanka
    *******************************************************************************************/

    @future(callout=true)
    public static void createWRITNotices(String rejectDefSDocIdStr) {
        try{
            brs_FilingStatusAuraHelper.writDefWrapperClass writDefWrapper = (brs_FilingStatusAuraHelper.writDefWrapperClass) JSON.deserializeStrict(rejectDefSDocIdStr,brs_FilingStatusAuraHelper.writDefWrapperClass.class);
            Map<Id,List<String>> rejectDefSDocIdMap = (Map<Id,List<String>>) writDefWrapper.rejDefMap;
            for(Id rejDef : rejectDefSDocIdMap.keySet()){
                brs_FilingStatusAuraHelper.generateFilingAttachment(String.valueOf(rejDef),rejectDefSDocIdMap.get(rejDef));
            }        
        }
        Catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'createWRITNotices', null, null, BOS_Utility.sSeverity, ex, null);
        }        
    }

    //Removed BRS-6365
   /* @AuraEnabled
    public static Boolean UCC_BackOfficeValidations(String uccfilingId){
        try {
            UCC_Filing__c filing=[Select Id,Type__c from UCC_Filing__c where Id=:uccfilingId];
            List<String> statusesList=new List<String>();
            List<UCC_Related_Info__c> uccContacts=[Select Id,Name,Type__c,Filing_Id__c from UCC_Related_Info__c where Filing_Id__c =:uccfilingId];
            for(UCC_Related_Info__c uccCon:uccContacts){
                statusesList.add(uccCon.Type__c);
            }
            if(statusesList.isEmpty() || ((filing.Type__c == System.label.OFS_Label && (!statusesList.contains(System.label.BRS_UCC_Debtor_Label) || !statusesList.contains(System.label.BRS_UCC_Secured_Party_Label))) ||
            ((filing.Type__c == System.label.Aircraft_Label || filing.Type__c == System.label.Vessel_Label || filing.Type__c == System.label.NoticeOfAttachmentLabel) && (!statusesList.contains(System.label.OwnerMemberType) || !statusesList.contains(System.label.Review_MasterLabel_Type_Claimant))) ||
            (filing.Type__c == System.label.JudgmentPersonalPropertyLabel && (!statusesList.contains(System.label.Judgment_Debtor_Label) || !statusesList.contains(System.label.BRS_UCC_Judgment_Creditor))) ||
            (filing.Type__c == System.label.Judgement_Label && (!statusesList.contains(System.label.BRS_UCC_Defendant_Label) || !statusesList.contains(System.label.BRS_UCC_Plaintiff_Label))) 
            )){
                return true;
            }
            return false;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    /********************************************************************************************
METHOD NAME    : renameUploadedMicrofilm
DESCRIPTION    : Method to update microfilm document name 
RETURN TYPE    : void
PARAMETER      : sObject
owner          : Priyanka
*******************************************************************************************/
    @AuraEnabled
    public static void renameUploadedMicrofilm(sObject filing, String uploadedFileId){
        try{
            String obj = SchemaUtility.getObjectFromId(filing.Id).getName();
            Set<Id> setContentDocumentIds = new Set<Id>(); 
            List<ContentVersion> listContentVersions = new List<ContentVersion>();
            
            /*for(ContentDocumentLink ContentDoc :[
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :filing.Id 
            ]) {
                setContentDocumentIds.add(contentDoc.ContentDocumentId);*/
                
                for(ContentVersion contentVersion :[
                    SELECT Title
                    FROM ContentVersion
                    WHERE ContentDocumentId =:uploadedFileId
                ]) {
                    {
						String getTitle = UCCFileMerge.getFilingOutputName(filing);
                        String finalTitle = getTitle.endswith('.pdf') ? getTitle : getTitle + System.Label.PDF_Type_Extension;
                        contentVersion.Title = finalTitle;
                    } 
                    listContentVersions.add(contentVersion);
                }
                update listContentVersions;
            //}
        }
        Catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /********************************************************************************************
    METHOD NAME    : otherRequestValidations
    DESCRIPTION    : Method to validate other request records
    RETURN TYPE    : void
    PARAMETER      : sObject
    owner          : Priyanka
    *******************************************************************************************/
    @AuraEnabled
    public static String otherRequestValidations(sObject filing){
        try{
            Set<Id> relatedFilingIds = new Set<Id>();
            String errorMsg;
            String acceptanceLetterLabel = '%'+System.Label.AcceptanceLabel+'%';
            Integer countFilingDocs = 0;
            for (Copy_Request_Details__c copyReqDetObj : [Select id,Copy_Type__c,RecordType.name, Business_Filing__c,Business_Filing__r.Pages__c ,UCC_Filing__c,UCC_Filing__r.Pages__c,Mark_Filing__c,Mark_Filing__r.Number_of_Pages__c from Copy_Request_Details__c where Other_Request__c =: filing.Id])
            {	
                
                if(copyReqDetObj.RecordType.name =='Business Filling Request'){
                    if(copyReqDetObj.Copy_Type__c=='Certified' && (copyReqDetObj.Business_Filing__r.Pages__c==null  || copyReqDetObj.Business_Filing__r.Pages__c=='')){
                        errorMsg = 'Please add the Number of Pages of the copy on the filing.'; 
                        break;
                    }
                    relatedFilingIds.add(copyReqDetObj.Business_Filing__c);
                }
                if(copyReqDetObj.RecordType.name =='UCC Filling Request'){
                    if(copyReqDetObj.Copy_Type__c=='Certified' && (copyReqDetObj.UCC_Filing__r.Pages__c==null  || copyReqDetObj.UCC_Filing__r.Pages__c=='')){
                        errorMsg = 'Please add the Number of Pages of the copy on the filing.'; 
                        break;
                    }
                    relatedFilingIds.add(copyReqDetObj.UCC_Filing__c);
                }
                if(copyReqDetObj.RecordType.name =='Trade and Service Mark Filling Request'){
                    if(copyReqDetObj.Copy_Type__c=='Certified' && (copyReqDetObj.Mark_Filing__r.Number_of_Pages__c==null  || copyReqDetObj.Mark_Filing__r.Number_of_Pages__c==0)){
                        errorMsg = 'Please add the Number of Pages of the copy on the filing.'; 
                        break;
                    }
                    relatedFilingIds.add(copyReqDetObj.Mark_Filing__c);
                }
                
            }
            if(!relatedFilingIds.isEmpty()){
                Integer countFiDocNo = [Select Count() FROM ContentDocumentLink  WHERE LinkedEntityId in :relatedFilingIds and (not  ContentDocument.title like :acceptanceLetterLabel)];
                Integer countAttachNo =[Select count() FROM Attachment where parentId in :relatedFilingIds and (not name like :acceptanceLetterLabel)];
                Map<Id,Boolean> isContentDocPresent = new Map<Id,Boolean>();
                for(ContentDocumentLink contLink : [Select id,LinkedEntityId,LinkedEntity.name,ContentDocument.title FROM ContentDocumentLink  WHERE LinkedEntityId in :relatedFilingIds and (not  ContentDocument.title like :acceptanceLetterLabel)]){
                   if(contLink.ContentDocument.title.contains(contLink.LinkedEntity.name.subStringAfter('-'))){
                        
                        isContentDocPresent.put(contLink.LinkedEntityId,true);
                    } 
                }
                for(Attachment attachObj : [Select id,ParentId,Name, Parent.name FROM Attachment where parentId in :relatedFilingIds and (not name like :acceptanceLetterLabel)]){
                    if(attachObj.Name.contains( attachObj.Parent.name.subStringAfter('-'))){
                        isContentDocPresent.put(attachObj.ParentId,true);
                    } 
                }
                for(Id filingId : relatedFilingIds){
                    
                    if(isContentDocPresent.get(filingId)==null){
                        errorMsg ='Copy is missing on the requested filing, please upload the copy.';
                    }
                }
            }
            return errorMsg;
        }
        catch(Exception e){
             throw new AuraHandledException(e.getMessage());
        }
    }
	
	/********************************************************************************************
    METHOD NAME    : getFileDetails
    DESCRIPTION    : Method to get file details to check for password proptected file.
    RETURN TYPE    : List<String> -- list of encoded VersionData of related files.
    PARAMETER      : String recId, String fileValue
    *******************************************************************************************/
    @AuraEnabled
    public static List<String> getFileDetails(String recId){
        try {
            List<String> fileDetailsList = new List<String>();
            if(recId!=null){
                List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.ContentSize,ContentDocument.Title , 
                LinkedEntityId,ContentDocument.FileExtension,ContentDocument.LatestPublishedVersionId  FROM ContentDocumentLink 
                where LinkedEntityId =:recId];
                Set<ID> ContentDocumentIds = new Set<ID>();
                if(!documentDetails.isEmpty()){
                    for(ContentDocumentLink contentInst : documentDetails){
                        ContentDocumentIds.add(contentInst.ContentDocumentId);
                    }
                }

                for(ContentVersion conVer : [Select ContentDocumentId,Title,File_Type_fileupload__c,VersionData FROM ContentVersion where ContentDocumentId IN: ContentDocumentIds AND FileExtension = 'pdf']){
                    String base64String = EncodingUtil.base64Encode(conVer.VersionData);
                    fileDetailsList.add(base64String);
                }
            }
            return fileDetailsList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}