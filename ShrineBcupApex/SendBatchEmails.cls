/********************************************************************************************
* DESCRIPTION: Everyday batch to handle nintex failure & resend email
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        15/01/2022                  R7 | BRS-8589 | Batch generation for UCC, Biz & OtherRequest
*********************************************************************************************/
public with sharing class SendBatchEmails implements Schedulable, Database.Batchable<sObject>,Database.Stateful {
    private Set<String> setFilingIds;
    private String obj;
    Map<Id,String> copyTypeMap=new Map<Id,String>();

    public SendBatchEmails(String obj, Set<String> setFilingIds) {
        this.obj = obj;
        this.setFilingIds = setFilingIds;
    }

    //--------- SCHEDULER -------------
    /**
     * @desc: SF allows max 10 emails in 1 transactions
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SendBatchEmails(this.obj, this.setFilingIds), 10);
    }

    

    // ---------------- BATCH ----------------
    private List<String> businessFilingTemplates = new List<String> {
        System.Label.Business_Registration_Acceptance_Email_with_link,
        System.Label.Business_Registration_Acceptance_Email,
        System.Label.Business_Registration_Rejectance_Email
    };

    private List<String> uccFilingTemplates = new List<String> {
        System.Label.BRS_FilingStatus_ApprovedEmailTemplate,
        System.Label.BRS_FilingStatus_RejectedEmailTemplate
    };

    private List<String> otherRequestTemplates = new List<String> {
        System.Label.Certificate_of_Legal_Existence_Template,
        'BRS_Copy_Request_Acceptance_template',
        'BRS_Copy_Request_Rejection_template',
        'BRS_Certificate_request_template',
        'BRS_Request_For_Information',
        'Service_Mark_Acceptance_BO',
        'Service_Mark_Rejection_BO',
        'Request_For_Copy_Email',
        'BRS_Request_For_Information'
    };
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        if(this.setFilingIds != null && !this.setFilingIds.isEmpty()) {
            return Database.getQueryLocator(
                'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',') 
                    + ',Work_Order__r.Source__c, RecordType.Name, RecordType.DeveloperName, Work_Order__r.Customer__r.Email, Work_Order__r.Customer__r.Name'
                    + (this.obj == 'Business_Filing__c' ? ',Account__r.Business_Email_Address__c' : '')
                    + (this.obj == 'Certficate__c' 
                        ? (
                            ', Business__r.Name, ('
                            + ' SELECT ' + String.join(new List<String>(SchemaUtility.getFields('Copy_Request_Details__c').keySet()), ',')
                            + ' FROM Copy_Request_Details__r'
                            + ')'
                        )
                        : ''
                    )
                + ' FROM ' + this.obj
                + ' WHERE Id IN :setFilingIds'
            );   
        }

        return null;
    }

    public void execute(Database.BatchableContext bc, List<sObject> records) {
        switch on this.obj {
            when 'Business_Filing__c' {
                sendBusinessFilingEmails((List<Business_Filing__c>) records);
            }

            when 'UCC_Filing__c' {
                sendUCCFilingEmails((List<UCC_Filing__c>) records);
            }

            when 'Certficate__c' {
                sendOtherRequestEmails((List<Certficate__c>) records);
            }
        }
    }

    /**
     * Run email batch job only once
     */
    public void finish(Database.BatchableContext bc) {
        String jobName = this.obj + ' Batch Email%';

        for(CronTrigger job : [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :jobName
        ]) {
            System.abortJob(job.Id);
        }
    }

    /**
     * @desc: Send bulk emails for failed records
     *  NOTE: Cloned from BRS_Utility.sendBulkEmails() to add support for rejection
     */
    private void sendBusinessFilingEmails(List<Business_Filing__c> listFilings) {
        //1. Creating a map of EmailTemplate Name and Id -- correct Template Id can be picked based on the template name.
        Map<String,Id> tempNameVSTemplateMap = getEmailTemplates(businessFilingTemplates);

        Map<Id, String> mapFilingOutputName = new Map<Id, String>();
        //2. Creating a map of Business Filing Id and Template Id -- Correct Template Id can be picked for any given filing id.
        Map<Id,Id> filingIdVSTemplateMap = new Map<Id,Id>();

        for(Business_Filing__c filing: listFilings) {
            if(filing.Status__c == System.Label.BRS_FilingStatus_Approved) {
                if( //Biz Formation + Dom Corp
                    filing.Type__c == System.Label.Business_Formation_Comparable 
                    && 
                    (
                        filing.Business_Type__c == System.Label.Stock 
                        || 
                        filing.Business_Type__c == System.Label.Non_Stock 
                        ||
                        filing.Business_Type__c == System.Label.B_Corp
                    )
                ) {
                    filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(System.Label.Business_Registration_Acceptance_Email_with_link));
                } else {
                    filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(System.Label.Business_Registration_Acceptance_Email)); 
                }
            } else if(System.Label.Rejected.equalsIgnoreCase(filing.Status__c)) {
                filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(System.Label.Business_Registration_Rejectance_Email));
            }
            
            mapFilingOutputName.put(filing.Id, UCCFileMerge.getFilingOutputName(filing));
        }

        //3. get attachments for this filing
        Map<Id, List<Messaging.EmailFileAttachment>> mapFilingAttachments = getAttachments(listFilings, mapFilingOutputName);
        
        //4. Creating an email instance to be sent.
        sendEmail(listFilings, filingIdVSTemplateMap, mapFilingAttachments);
    }

    /**
     * @desc: Bulk UCC emails
     *  Note: for Online & BO
     */
    private void sendUCCFilingEmails(List<UCC_Filing__c> listFilings) {
        //1. Creating a map of EmailTemplate Name and Id -- correct Template Id can be picked based on the template name.
        Map<String,Id> tempNameVSTemplateMap = getEmailTemplates(uccFilingTemplates);

        Map<Id, String> mapFilingOutputName = new Map<Id, String>();
        //2. Creating a map of Business Filing Id and Template Id -- Correct Template Id can be picked for any given filing id.
        Map<Id,Id> filingIdVSTemplateMap = new Map<Id,Id>();

        for(UCC_Filing__c filing: listFilings) {
            switch on filing.Status__c {
                
                when 'Approved' {
                    filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(System.Label.BRS_FilingStatus_ApprovedEmailTemplate));
                }

                when 'Rejected' {
                    filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(System.Label.BRS_FilingStatus_RejectedEmailTemplate));
                }
            }
            
            mapFilingOutputName.put(filing.Id, UCCFileMerge.getFilingOutputName(filing));
        }

        //3. get attachments for this filing
        Map<Id, List<Messaging.EmailFileAttachment>> mapFilingAttachments = getAttachments(listFilings, mapFilingOutputName);

        //4. Creating an email instance to be sent.
        sendEmail(listFilings, filingIdVSTemplateMap, mapFilingAttachments);
    }

    // ----------------- OTHER REQUEST -----------
    private void sendOtherRequestEmails(List<Certficate__c> listFilings) {
        Map<String,Id> tempNameVSTemplateMap = getEmailTemplates(otherRequestTemplates);
        Map<Id, String> mapFilingOutputName = new Map<Id, String>(); //filing output
        Map<Id,Id> filingIdVSTemplateMap = new Map<Id,Id>(); //template map
        List<sObject> listFilingsForAttachment = new List<sObject>(); //for copy request

        for(Certficate__c filing: listFilings) {
            String templateName = getOtherRequestTemplate(filing);

            filingIdVSTemplateMap.put(filing.Id, tempNameVSTemplateMap.get(templateName));
            mapFilingOutputName.put(filing.Id, UCCFileMerge.getFilingOutputName(filing));
            listFilingsForAttachment.add(filing);

            if(filing.Copy_Request_Details__r != null && !filing.Copy_Request_Details__r.isEmpty()) { //has certified copy requests
                for(Copy_Request_Details__c copyDetail :filing.Copy_Request_Details__r) {
                    copyTypeMap.put(copyDetail.Id,copyDetail.Copy_Type__c);
                    mapFilingOutputName.put(copyDetail.Id, UCCFileMerge.getFilingOutputName(copyDetail));
                    listFilingsForAttachment.add(copyDetail);
                }
            }
        }

        //3. get attachments for this filing
        Map<Id, List<Messaging.EmailFileAttachment>> mapFilingAttachments = getAttachments(listFilingsForAttachment, mapFilingOutputName);

        //4. Creating an email instance to be sent.
        sendEmail(listFilings, filingIdVSTemplateMap, mapFilingAttachments);
    }

    /**
     * @desc: Select template based on record type
     *  1. Certificate Request & 1.5 Special Legal Existence
        2. Copy Request
        3. RFI
        4. Mark Search
        
     * [Note: using DeveloperName to support '&' in Trademark RT
     * switch doesnt support labels]
     */
    @TestVisible
    private String getOtherRequestTemplate(Certficate__c filing) {
        String templateName = '';

        switch on filing.RecordType.DeveloperName {
            //1. Certificate request & Special Legal Existence
            when 'Certificate_Request', 'Special_Certificate_of_Legal_Existence' {
                templateName = 'BRS_Certificate_request_template'; //** add check for lang
            }

            //2. Copy Request
            when 'Business_Copy_Request', 'UCC_Copy_Request', 'Trade_Service_Mark_Copy_Request' {
                //2.1. based on approved/rejected
                switch on filing.Status__c {
                    when 'Approved' {
                        templateName = 'BRS_Copy_Request_Acceptance_template';
                    }

                    when 'Rejected' {
                        templateName = 'BRS_Copy_Request_Rejection_template';
                    }
                } 
            }

            //3. RFI
            when 'Request_for_Information' {
                templateName = 'BRS_Request_For_Information';
            }

            //4. Mark Search
            when 'Request_for_Search_of_Mark' {
                //4.1. Approved/Rejected
                switch on filing.Status__c {
                    when 'Approved' {
                        templateName = 'Service_Mark_Acceptance_BO';
                    }

                    when 'Rejected' {
                        templateName = 'Service_Mark_Rejection_BO';
                    }
                }
            }
        }

        return templateName;
    }

    /**
     * BRS_Certificate_request_template 
     * To-Do | Diff for Online & BO
     */
    private void setOtherRequestEmailBody(Certficate__c filing, Messaging.SingleEmailMessage email) {
        String htmlValue = email.getHtmlBody();
        
        //1. set business name
        if(htmlValue.contains(System.Label.BRS_Certificate_template_busines)) {
            if (filing.Business__c != null || filing.Business_Name__c != null) {
                String businessName = filing.Business__c != null 
                    ? filing.Business__r.Name 
                    : filing.Business_Name__c; //get business name
                htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_busines, 'for ' + businessName);
            } else {
                htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_busines, '');
            }
        }

        //2. set customer name
        if (filing.Work_Order__c != null && htmlValue.contains(System.Label.BRS_Certificate_template_firstName)) {
            htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_firstName, filing.Work_Order__r.Customer__r.Name);
        }

        //3. create certificate table
        if(htmlValue.contains(System.Label.BRS_Certificate_template_cert)) {
            String emailBody = (filing.RecordType.Name.endswith('Copy Request'))
                ? getCopyRequestBody(filing) //if copy request
                : getCertificateRequestBody(filing); //if legal existence

            htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_cert, emailBody);
        }

        email.setHtmlBody(htmlValue); //Set HTML Body
    }

    //email body for copy request
    private String getCopyRequestBody(Certficate__c filing) {
        String emailBody = System.Label.BRS_CopyRequest_internal_table_header;
            
        if (filing.Copy_Request_Details__r != null) {
            Map<String, Decimal> copiesMap = new Map<String, Decimal>();

            for (Copy_Request_Details__c copyDetail: filing.Copy_Request_Details__r) {
                String filingNo = '';

                if (copyDetail.Filing_Number__c != null) { //biz
                    filingNo = copyDetail.Filing_Number__c;
                } else if(copyDetail.Mark_Filing_Number__c != null) { //mark
                    filingNo = copyDetail.Mark_Filing_Number__c;
                } else if(copyDetail.UCC_Filing_Number__c != null) { //ucc
                    filingNo = copyDetail.UCC_Filing_Number__c;
                }

                if(!copiesMap.containsKey(filingNo)) {
                    copiesMap.put(filingNo, 0);
                }

                copiesMap.put(filingNo, (copiesMap.get(filingNo) + copyDetail.Number_of_Copies__c));
            }

            if (!copiesMap.isEmpty()) {
                for(String copyCount: copiesMap.keySet()) {
                    String firstRow = System.Label.BRS_CopyRequest_internal_table_row.replace(System.Label.BRS_CopyRequest_internal_table_row_number, copyCount);
                    firstRow = firstRow.replace(
                        System.Label.BRS_CopyRequest_internal_table_row_copies, 
                        String.valueOf(copiesMap.get(copyCount))
                    );
                    emailBody += firstRow;
                }
                emailBody += '</table>';
            }
        }

        return emailBody;
    }

    //for legal existence
    private String getCertificateRequestBody(Certficate__c filing) {
        String emailBody = System.Label.BRS_Obtian_cert_internal_table_header;
        String certType = filing.Certificate_Type__c != null 
            ? filing.Certificate_Type__c 
            : filing.Type__c;
        
        String firstRow = System.Label.BRS_Obtian_cert_internal_table_row.replace(System.Label.BRS_Obtian_cert_internal_table_row_type, certType);
        firstRow = firstRow.replace(System.Label.BRS_Obtian_cert_internal_table_row_fee, 
            String.valueOf(filing.Total_Fee__c != null ? filing.Total_Fee__c : filing.Filing_Fee__c));
        emailBody += firstRow + '</table>';   
        
        return emailBody;
    }

    //------------ HELPER METHODS ---------------
    private Map<String, Id> getEmailTemplates(List<String> listTemplateNames) {
        Map<String,Id> tempNameVSTemplateMap = new Map<String,Id>();
        
        for(EmailTemplate temp: [
            SELECT Id, DeveloperName 
            FROM EmailTemplate 
            WHERE DeveloperName IN :listTemplateNames
        ]) {
            tempNameVSTemplateMap.put(temp.DeveloperName, temp.Id);
        }

        return tempNameVSTemplateMap;
    }

    private Map<Id, List<Messaging.EmailFileAttachment>> getAttachments(List<sObject> listFilings, Map<Id, String> mapFilingOutputName) {
        Map<Id, List<Messaging.EmailFileAttachment>> mapFilingAttachments = new Map<Id,List<Messaging.EmailFileAttachment>>();

        //body cannot be queried in inner query
        for(Attachment attachment: [
            SELECT Id, Name, ParentId, Body, ContentType
            FROM Attachment
            WHERE ParentId IN :listFilings
        ]) {
            if(attachment.Name == mapFilingOutputName.get(attachment.ParentId) + System.Label.PDF_Type_Extension
                ||
                attachment.Name.endsWith(System.Label.BRS_Acceptance_Notice + System.Label.PDF_Type_Extension)
                ||
                attachment.Name.endsWith(System.Label.brs_RejectionNotice + System.Label.PDF_Type_Extension)
            ) { //filing output OR AN/RN
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(attachment.Name);
                efa.setBody(attachment.body);
                efa.setContentType(attachment.ContentType);
                efa.setInline(false);
                
                if(!mapFilingAttachments.containsKey(attachment.ParentId)) {
                    mapFilingAttachments.put(attachment.ParentId, new List<Messaging.EmailFileAttachment>());
                }

                mapFilingAttachments.get(attachment.ParentId).add(efa);
            }
        }

        return mapFilingAttachments;
    }

    private void sendEmail(List<sObject> listFilings, Map<Id, Id> filingIdVSTemplateMap, Map<Id, List<Messaging.EmailFileAttachment>> mapFilingAttachments) {
        List<Error_Log__c> listErrorLogs = new List<Error_Log__c>();
        
        //4. Creating an email instance to be sent.
        for(sObject filing: listFilings) {
            //4.1. Email address
            List<String> toAddresses = getEmailAddresses(filing);

            if(!toAddresses.isEmpty()) {
                Id emailTemplateId = filingIdVSTemplateMap.get(filing.Id);
            
                //4.1. Set email details
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateId, null, filing.Id);
                String emailSubject = email.getSubject();
                email.setSubject(emailSubject);
                email.setWhatId(filing.Id);
                email.setTemplateId(emailTemplateId);
                email.setSaveAsActivity(false);

                //4.1.1. for CertRequest, Special Legal, RFI
                if(filing instanceof Certficate__c) {
                    setOtherRequestEmailBody((Certficate__c) filing, email);
                } else {
                    String emailTextBody = email.getPlainTextBody();
                    email.setPlainTextBody(emailTextBody);
                }

                OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
                if(owa != null) {
                    email.setOrgWideEmailAddressId(owa.Id);
                }
            
                //4.2. Attachments    
                if(mapFilingAttachments.containsKey(filing.Id)) {
                    List<Messaging.EmailFileAttachment> listAttachments = mapFilingAttachments.get(filing.Id);
                    
                    //4.2.1. for copy request
                    if(filing instanceof Certficate__c
                        &&
                        filing.getSobjects('Copy_Request_Details__r') != null
                        &&
                        !filing.getSobjects('Copy_Request_Details__r').isEmpty()
                    ) {
                        for(sObject copyDetail :filing.getSobjects('Copy_Request_Details__r')) {
                            if(copyTypeMap.get(copyDetail.Id) != 'Plain')
                            {
                                listAttachments.addAll(mapFilingAttachments.get(copyDetail.Id));
                            }
                        }
                    }

                    email.setFileAttachments(listAttachments);
                } 
                //Nintex error handling
                else {
                    listErrorLogs.add(new Error_Log__c(
                        Source_of_error__c = 'Nintex Error Processing',
                        Class_Name__c = 'SendBatchEmails',
                        Error_Message__c = 'No attachments found for ' + filing.get('Name') + '('+ filing.Id + ')' + ' at ' + System.now().format(),
                        Additional_Error_Information__c = 'Email to be sent to: ' + toAddresses
                    ));
                }

                //------ Send email ---
                System.debug('Sending email for:' + filing.Id + ' to:' + toAddresses + ' with ' + mapFilingAttachments.get(filing.Id).size() +' attachments.');
                
                email.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }

        if(!listErrorLogs.isEmpty()) {
            insert listErrorLogs;
        }
    }

    //4. Get email addresses
    private List<String> getEmailAddresses(sObject filing) {
        List<String> toAddresses = new List<String>();

        //4.1.1. Online
        if(filing instanceof Business_Filing__c && filing.getSobject('Work_Order__r').get('Source__c') == System.Label.brs_FilingOnline) {
            if(filing.getSobject('Account__r').get('Business_Email_Address__c') != null) {
                toAddresses.add(String.valueOf(filing.getSobject('Account__r').get('Business_Email_Address__c')));
            }
            if(filing.getSobject('Work_Order__r').getSobject('Customer__r').get('Email') != null) {
                toAddresses.add(String.valueOf(filing.getSobject('Work_Order__r').getSobject('Customer__r').get('Email')));
            }
        } 
        //4.1.2 BO Biz, UCC, Other Request
        else if(filing.getSobject('Work_Order__r').getSobject('Customer__r').get('Email') != null) {
            toAddresses.add(String.valueOf(filing.getSobject('Work_Order__r').getSobject('Customer__r').get('Email')));
        }

        return toAddresses;
    }
}