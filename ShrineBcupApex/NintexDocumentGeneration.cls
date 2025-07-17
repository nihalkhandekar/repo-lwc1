/********************************************************************************************
* DESCRIPTION: Nintex document generation
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Rabbani                       15/9/2021                   R4 | BRS-7223 | Generate docs through Nintex
* Sonika                                                    R5 | Certified Copy Request
* Himanshi                                                  R7 | WRIT
* Shreya                        03/01/2022                  R7 | BRS-7226 | Foreign Investigation
*********************************************************************************************/
public with sharing class NintexDocumentGeneration {
    /**
     * @desc: Generate nintex documents
     * * @update: BRS-2798 | Handle for ObtainCertificate Online flow
     */
    @InvocableMethod(label='Generate Filing outputs')
    public static void generateFilingOutput(List<NintexWrapper> listNintexDetails) {
        Id recordValue=listNintexDetails.get(0).filingId;
        String objnamevalue;
        if(recordValue !=null)
        {
            objnamevalue=recordValue.getSObjectType().getDescribe().getName();
        }
        Business_Filing__c business= new Business_Filing__c();
        if(objnamevalue == 'Business_Filing__c')
        {
            business=[Select id,Status__c,Pending_Filing_Status__c from Business_Filing__c where id =: recordValue];
             if(String.isNotBlank(listNintexDetails.get(0).filingId) && System.Label.Approved.equalsIgnoreCase(listNintexDetails.get(0).status) && !business.Pending_Filing_Status__c && !Test.isRunningTest()) {
            convertFileToAttachment(listNintexDetails.get(0).filingId);
        }
            generateDocument(JSON.serialize(listNintexDetails));
        }
        else
        {
              if(String.isNotBlank(listNintexDetails.get(0).filingId) && System.Label.Approved.equalsIgnoreCase(listNintexDetails.get(0).status) && !Test.isRunningTest()) {
              convertFileToAttachment(listNintexDetails.get(0).filingId);
        }

            generateDocument(JSON.serialize(listNintexDetails));
        }    
    }
    /**
     * @desc: Only for Copy Request type = Certified
     * Get all certified copy requests and create document
     */

    
    // WRIT and Defendant templates
    public static void generateDocumentWritNotice(List<NintexWrapper> listNintexDetails) {
        generateFilingOutputNoticeOfWrit(JSON.serialize(listNintexDetails));
    }

    @future(callout=true)
    public static void generateFilingOutputNoticeOfWrit(String nintexDetails) {
        Boolean writApproved = false;
        Loop.loopMessage lm = new Loop.LoopMessage();
        List<NintexWrapper> listNintexDetails = (List<NintexWrapper>) JSON.deserialize(nintexDetails, List<NintexWrapper>.class);

        List<WRIT_Case__c> lstWrits = [
            SELECT Id, 
                (
                    SELECT Id, RecordType.Name, Mailing_Status__c 
                    FROM Defendants__r
                ) 
            FROM WRIT_Case__c 
            WHERE Id = :listNintexDetails.get(0).filingId
        ];

        if(!lstWrits.isEmpty() && lstWrits.get(0).getSObjects('Defendants__r') != null && !lstWrits.get(0).getSObjects('Defendants__r').isEmpty()) {
            Map<String, List<Loop__DDP__c>> mapNintexDefTemplate = getBulkTemplates('Defendants__c');
            Set<String> setMailingStatus = new Set<String> {
                'SOS Agent',
                'Foreign unauthorized', 
                'Insurance Company',
                'Affidavit of due diligent search'
            };
            
            for(Defendants__c record :lstWrits.get(0).getSObjects('Defendants__r')) {
                NintexWrapper nWrapper = new NintexWrapper();
                nWrapper.type = System.Label.Notice_of_WRIT;
                nWrapper.status = record.RecordType.Name;

                if(System.Label.Approved.equalsIgnoreCase(nWrapper.status)) {
                    writApproved = true;
                    
                    if(setMailingStatus.contains(record.Mailing_Status__c)) {
                        lm.requests.addAll(
                            getLoopRequests(
                                mapNintexDefTemplate, 
                                record,
                                nWrapper
                            )
                        );
                    }
                }
                else if(System.Label.Rejected.equalsIgnoreCase(nWrapper.status)) {
                    lm.requests.addAll(
                        getLoopRequests(
                            mapNintexDefTemplate, 
                            record,
                            nWrapper
                        )
                    );
                }
            }
        }

        if(writApproved) {
            Map<String, List<Loop__DDP__c>> mapNintexWritTemplates = getBulkTemplates('WRIT_Case__c');
            
            NintexWrapper nWrapper = new NintexWrapper();
            nWrapper.type = System.Label.WRIT_Acceptance_Notice;
            nWrapper.status = System.Label.Approved;

            lm.requests.addAll(
                getLoopRequests(
                    mapNintexWritTemplates, 
                    lstWrits.get(0),
                    nWrapper
                )
            );
        }

        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {
            String response = lm.sendAllRequests(); 
        }
    }

    /**
     * @desc: Only for Copy Request type = Certified
     * Get all certified copy requests and create document
     */
    public static void generateFilingOutputDigitalCertified(List<NintexWrapper> listNintexDetails) {
        List<Id> lstFilingIds = new List<Id>();
        
        for(Copy_Request_Details__c copyRec : [
            SELECT Id, Business_Filing__c, UCC_Filing__c, Mark_Filing__c
            FROM Copy_Request_Details__c
            WHERE Copy_Type__c = 'Certified'
                AND Other_Request__c = :listNintexDetails.get(0).filingId
        ]) {
            if(copyRec.Business_Filing__c != null) {
                lstFilingIds.add(copyRec.Business_Filing__c);
            } else if(copyRec.UCC_Filing__c != null) {
                lstFilingIds.add(copyRec.UCC_Filing__c);
            } else if(copyRec.Mark_Filing__c != null) {
                lstFilingIds.add(copyRec.Mark_Filing__c);
            }
        }
    
        if(!lstFilingIds.isEmpty()){
            convertFileToAttachmentDigital(lstFilingIds);
        }

        generateDocumentDigital(JSON.serialize(listNintexDetails));
    }

    /**
     * Convert filing output to attachment [only certified copy]
     * [Note for backward compatility w/ s-docs, we cannot pick the attachment version]
     */
    public static void convertFileToAttachmentDigital(List<Id> lstCopyDetails) {
        Map<Id,Id> docIdParentId = new  Map<Id,Id>();
        
        for(ContentDocumentLink contentInst : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :lstCopyDetails WITH SECURITY_ENFORCED
        ]) {
            docIdParentId.put(contentInst.ContentDocumentId,contentInst.LinkedEntityId);
        }
        Map<Id,List<String>> attachmentMap = new Map<Id,List<String>>();
        for(Attachment attach : [
            SELECT Id, Name, Body,ParentId 
            FROM Attachment 
            WHERE ParentId IN: lstCopyDetails 
                AND 
                (NOT Name LIKE :System.Label.Rejection_N_Comparable) 
                AND 
                (NOT Name LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED
        ]) {
            if(!attachmentMap.containsKey(attach.ParentId)) {
                attachmentMap.put(attach.ParentId, new List<String>());
            }

            attachmentMap.get(attach.ParentId).add(attach.Name);
        }

        List<Attachment> attachmentsList = new List<Attachment>();
        for(ContentVersion conVer : [
            SELECT Title, VersionData,ContentDocumentId 
            FROM ContentVersion 
            WHERE ContentDocumentId IN: docIdParentId.keySet() 
                AND FileExtension = 'pdf' WITH SECURITY_ENFORCED
        ]) {
            String finalTitle = conVer.Title.endswith('.pdf') ? conver.Title : conver.Title + System.Label.PDF_Type_Extension;
            
            if(!attachmentMap.isEmpty() && attachmentMap.containsKey(docIdParentId.get(conVer.ContentDocumentId))) {
                if(!attachmentMap.get(docIdParentId.get(conVer.ContentDocumentId)).contains(finalTitle)) { //if parentid's attachments' name does not match
                    attachmentsList.add(new Attachment(
                        ParentId = docIdParentId.get(conVer.ContentDocumentId),
                        Name = finalTitle,
                        Body = conVer.VersionData
                    ));
                }
            } else {
                attachmentsList.add(new Attachment(
                    ParentId = docIdParentId.get(conVer.ContentDocumentId),
                    Name = finalTitle,
                    Body = conVer.VersionData
                ));
            }
        }
        
         Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(attachmentsList, 'insert');
        if(!attachmentsList.isEmpty() && bAccessCheck) {
            insert attachmentsList;
        }
        
    }

    /**
     * @desc: create documents for certified copy request
     */
    @future(callout=true)
    public static void generateDocumentDigital(String nintexDetails) {
        List<NintexWrapper> listNintexDetails = (List<NintexWrapper>)
            JSON.deserialize(nintexDetails, List<NintexWrapper>.class);
        
        List<Copy_Request_Details__c> lstCopyDetails = [
            SELECT Copy_Type__c, Business_Filing__c, Business_Filing__r.Type__c, Business_Filing__r.Sdoc_Filing_Number__c, Business_Filing__r.Filing_Type__c,
                UCC_Filing__c, UCC_Filing__r.Type__c, UCC_Filing__r.Sdoc_Filing_Number__c, UCC_Filing__r.Amendment_Type__c, UCC_Filing__r.Other_File_Type_Name__c,
                Mark_Filing__c, Mark_Filing__r.Filing_Type__c, Mark_Filing__r.Sdoc_Filing_Number__c
            FROM Copy_Request_Details__c
            WHERE Copy_Type__c = :System.Label.Certified
                AND Other_Request__c = :listNintexDetails.get(0).filingId WITH SECURITY_ENFORCED
        ];

        Loop.loopMessage lm = new Loop.LoopMessage();
        Map<String, List<Loop__DDP__c>> mapNintexTemplates = getBulkTemplates('Copy_Request_Details__c');
        
        //2. Certified Copy Request
        for(Copy_Request_Details__c copyDetail : lstCopyDetails) {
            lm.requests.addAll(
                getCertifiedRequests(copyDetail, mapNintexTemplates.get(copyDetail.Copy_Type__c).get(0))
            );
        }
        
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {
            String response = lm.sendAllRequests(); 
        }
    }

    /**
     * @desc: For all Online/BO flow - generate Filing output & AN/RN
     */
    @future(callout=true)
    public static void generateDocument(String nintexDetails) {
        List<NintexWrapper> listNintexDetails = (List<NintexWrapper>)
            JSON.deserialize(nintexDetails, List<NintexWrapper>.class);

        Loop.loopMessage lm = new Loop.LoopMessage();
        NintexWrapper wrapper = listNintexDetails.get(0);
        
        if(String.isNotBlank(wrapper.certificateResponse)) { //certificates
            List<BRS_Utility.MaintennaceResponce> listMaintenanceResponse = (List<BRS_Utility.MaintennaceResponce>) 
                JSON.deserialize(wrapper.certificateResponse, List<BRS_Utility.MaintennaceResponce>.class);
            
            List<Id> listCertificateIds = new List<Id>(listMaintenanceResponse.get(0).mapCertificateIds.keySet());
            Map<String, List<Loop__DDP__c>> mapNintexTemplates = getBulkTemplates('Certficate__c');
            
            for(sObject certificate : getRecords(listCertificateIds)) {
                lm.requests.addAll(
                    getLoopRequests(
                        mapNintexTemplates, 
                        certificate, 
                        wrapper
                    )
                );
            }
        } else { //ucc, biz, other request, FI
            String obj = SchemaUtility.getObjectFromId(wrapper.filingId).getName();
            if(obj == 'Business_Filing__c')
            {
                Business_Filing__c bus=[Select id,Type__c from Business_Filing__c where id =:wrapper.filingId WITH SECURITY_ENFORCED];
                if(bus.Type__c == 'Annual Report')
                {
                    System.debug('Sa@@@'+bus.Type__c);
                    Loop.loopMessage.loopUrl = System.label.brs_Nintex_Server;
                }
            }
            lm.requests.addAll(
                getLoopRequests(
                    getBulkTemplates(obj), 
                    getRecords(new List<Id> { wrapper.filingId }).get(0), 
                    wrapper
                )
            );
        }
        
        if(!Test.isRunningTest() && !lm.requests.isEmpty()) {
            String response = lm.sendAllRequests(); 
        }
    }

    //----------- HELPER METHODS ------------
    /**
     * @desc: for converting uploaded file to attachment | 1 record
     */
    public static void convertFileToAttachment(Id recordId) {
        //1. If has uploaded file
        Set<Id> setContentIds = new Set<Id>();
        for(ContentDocumentLink contentLink : [	
            SELECT ContentDocumentId	
            FROM ContentDocumentLink 	
            WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED
        ]) {	
            setContentIds.add(contentLink.ContentDocumentId);	
        }	
    
        if(!setContentIds.isEmpty()) {
            //2. Check if attachment version pre-exists
            List<String> listAttachmentNames = new List<String>();
        
            for(Attachment attach : [
                SELECT Id, Name, Body, ParentId
                FROM Attachment
                WHERE ParentId = :recordId 
                    AND 
                    (NOT Name LIKE :System.Label.Rejection_N_Comparable) 
                    AND 
                    (NOT Name LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED
            ]) {
                listAttachmentNames.add(attach.Name);
            }	
            
            sObject record = getRecords(new List<Id> { recordId }).get(0);
            Integer limitVar;
            String objname=record.id.getSObjectType().getDescribe().getName();
			if(objname !='Foreign_Investigation__c')
            {
                String source = record instanceof Defendants__c
                ? ''
                : record.getSobject('Work_Order__r') != null ? String.valueOf(record.getSobject('Work_Order__r').get('Source__c')) : '';
            limitVar = 'Digital Mail'.equalsIgnoreCase(source)
                ? 1
                : 10;
            }
            else{
                limitVar=10;
            }

            
            List<Attachment> listAttachments = new List<Attachment>();
            for(ContentVersion conVer : [
                SELECT Title, VersionData 	
                FROM ContentVersion
                WHERE ContentDocumentId IN: setContentIds 
                    AND FileExtension = 'pdf' WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC 
                LIMIT :limitVar 
            ]) {
                String fileTitle = conVer.Title.endswith('.pdf') 
                    ? conver.Title 
                    : conver.Title + System.Label.PDF_Type_Extension;	
        
                if(!listAttachmentNames.contains(fileTitle)) {
                    listAttachments.add(new Attachment(
                        ParentId = recordId,	
                        Name = fileTitle,
                        Body = conVer.VersionData
                    ));
                }
            }
            
             Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(listAttachments, 'insert');
            if(!listAttachments.isEmpty() && bAccessCheck) {	
                insert listAttachments;	
            }
        }	
    }

    /**
     * @desc: Get all active Nintex templates for associated object
     *          & delivery options
     * @update: BRS-6282 | To support multiple filing outputs
     */
    public static Map<String, List<Loop__DDP__c>> getBulkTemplates(String obj) {
        Map<String, List<Loop__DDP__c>> mapFilingTypeTemplates = new Map<String, List<Loop__DDP__c>>();
        
        for(Loop__DDP__c template : [
            SELECT Id, Filing__c, Status__c,
                (
                    SELECT Id, Name
                    FROM Loop__Custom_Integration_Options__r
                ) 
            FROM Loop__DDP__c
            WHERE Is_Active__c = true
                AND Loop__Object_Name__c = :obj WITH SECURITY_ENFORCED
        ]) {
            //1. Filing output templates
            if(String.isNotBlank(template.Filing__c)) {
                for(String filingType : template.Filing__c.split(';')) {
                    if(!mapFilingTypeTemplates.containsKey(filingType)) {
                        mapFilingTypeTemplates.put(filingType, new List<Loop__DDP__c>());
                    }

                    mapFilingTypeTemplates.get(filingType).add(template);
                }
            }
            //2. Get Approval/Rejection template
            if(String.isNotBlank(template.Status__c)) {
                for(String filingType : template.Status__c.split(';')) {
                    if(!mapFilingTypeTemplates.containsKey(filingType)) {
                        mapFilingTypeTemplates.put(filingType, new List<Loop__DDP__c>());
                    }

                    mapFilingTypeTemplates.get(filingType).add(template);
                }
            }
        }

        return mapFilingTypeTemplates;
    }

    /**
     * Note: Certified Copy Request is exception to all common logic | Move to its own class
     * @update: BRS-6372 | Handle for FI
     */
    private static List<Loop.loopMessage.loopMessageRequest> getLoopRequests(Map<String, List<Loop__DDP__c>> mapNintexTemplates, sObject record, NintexWrapper wrapper) {
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        
        String status = String.isNotBlank(wrapper.status)
            ? wrapper.status
            : String.valueOf(record.get('Status__c'));

        String type = String.isNotBlank(wrapper.type)
            ? wrapper.type
            : UCCFileMerge.getFilingType(record);

        //1. WRIT
        if((System.Label.Notice_of_WRIT.equalsIgnoreCase(type) || System.Label.WRIT_Acceptance_Notice.equalsIgnoreCase(type))
            && mapNintexTemplates.containsKey(type)
        ) {
            listRequests.addAll(getFilingOutputRequests(record, mapNintexTemplates.get(type)));
        }
        //4. Other Filing Outputs + Acceptance/Rejection letter
        else if (System.Label.Approved.equalsIgnoreCase(status) || System.Label.Rejected.equalsIgnoreCase(status)) {
            if(System.Label.Approved.equalsIgnoreCase(status) && mapNintexTemplates.containsKey(type)) {
                listRequests.addAll(getFilingOutputRequests(record, mapNintexTemplates.get(type)));
            }

            //4. if not FI | Acceptance/Rejection Letter
            if(mapNintexTemplates.containsKey(status)) {
                listRequests.addAll(getNoticeRequest(record, mapNintexTemplates.get(status).get(0)));
            }
        }

        //5. In Progress = Nop
        return listRequests;
    }

    public static List<Loop.loopMessage.loopMessageRequest> getFilingOutputRequests(sobject record, List<Loop__DDP__c> listFilingOutputs) {
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        List<String> listAttachmentIds = new List<String>(); //issue with conversion from id to string, hence the long route
        
        for(Attachment attachment: [
            SELECT Id
            FROM Attachment
            WHERE ParentId = :record.Id
            AND 
            (NOT Name LIKE :System.Label.Rejection_N_Comparable) 
            AND 
            (NOT Name LIKE :System.Label.Acceptance_N_Comparable) WITH SECURITY_ENFORCED
        ]) {
            listAttachmentIds.add(attachment.Id);
        }
        
        for(Loop__DDP__c filingOutput :listFilingOutputs) {
            //1. Get available delivery options
            Map<String, Id> mapDeliveryOptions = new Map<String, Id>();
            for(Loop__DDP_Integration_Option__c option : filingOutput.Loop__Custom_Integration_Options__r) {
                mapDeliveryOptions.put(option.Name, option.Id);
            }

            Map<String, String> mapNintexParams = new Map<String, String>();
            //2. If template supports merge, add the attachment ids
            if(mapDeliveryOptions.containsKey(DeliveryOption.hasUpload.name()) && !listAttachmentIds.isEmpty()) {
                mapNintexParams.put('deploy', mapDeliveryOptions.get(DeliveryOption.hasUpload.name()));
                mapNintexParams.put('attachIds', String.join(listAttachmentIds, '|'));
            } 
            //3. no attachment, then no merge
            else if(mapDeliveryOptions.containsKey(DeliveryOption.hasNoUpload.name())) {
                mapNintexParams.put('deploy', mapDeliveryOptions.get(DeliveryOption.hasNoUpload.name()));
            }
            if(!mapNintexParams.isEmpty())
            {
                listRequests.add(new Loop.LoopMessage.loopMessageRequest(
                record.Id,
                filingOutput.Id,
                mapNintexParams
            ));
            }
        }
        
        return listRequests;
    }

    /**
     * @desc: Certified Copy Requests
     * @author: Sonika
     */
    public static List<Loop.loopMessage.loopMessageRequest> getCertifiedRequests(Copy_Request_Details__c copyReq, Loop__DDP__c filingOutput) {
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        Id filingId;
        String filingOutputName;
        if(copyReq.Business_Filing__c!=null) {
            filingOutputName = UCCFileMerge.getFilingOutputName(copyReq.Business_Filing__r);
            filingId = copyReq.Business_Filing__c;
        } else if(copyReq.UCC_Filing__c!=null) {
            filingOutputName = UCCFileMerge.getFilingOutputName(copyReq.UCC_Filing__r);
            filingId = copyReq.UCC_Filing__c;
        } else if(copyReq.Mark_Filing__c!=null) {
            filingOutputName = UCCFileMerge.getFilingOutputName(copyReq.Mark_Filing__r);
            filingId = copyReq.Mark_Filing__c;
        }
        
        List<Attachment> lstAttachmentsToOverlay = [
            SELECT Id, Name, Body
            FROM Attachment
            WHERE ParentId = :filingId 
                AND Name = :(filingOutputName + System.Label.PDF_Type_Extension) WITH SECURITY_ENFORCED
            LIMIT 1 
        ];
        
        if(!lstAttachmentsToOverlay.isEmpty()) {
            listRequests.add(new Loop.LoopMessage.loopMessageRequest(
                copyReq.Id,
                filingOutput.Id,
                
                new Map<String, String> {
                    'deploy' => filingOutput.Loop__Custom_Integration_Options__r[0].Id,
                    'attachIds' => lstAttachmentsToOverlay[0].id
                }
            ));
        }

        return listRequests;
    }

    public static List<Loop.loopMessage.loopMessageRequest> getNoticeRequest(sobject record, Loop__DDP__c filingNotice) {
        List<Loop.loopMessage.loopMessageRequest> listRequests = new List<Loop.loopMessage.loopMessageRequest>();
        
        if(filingNotice!=null) {
            listRequests.add(new Loop.LoopMessage.loopMessageRequest(
                record.Id,
                filingNotice.Id,
                new Map<String, String> {
                    'deploy' => filingNotice.Loop__Custom_Integration_Options__r[0].Id
                }
            ));
        }

        return listRequests;
    }

    private static List<sObject> getRecords(List<Id> listFilingIds) {
        String obj = SchemaUtility.getObjectFromId(listFilingIds.get(0)).getName();
        System.debug('Object Name-->'+obj);
        String query = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(obj).keySet()), ',');
        
        if(obj == 'WRIT_Case__c') {
            query += ',Work_Order__r.Source__c';
        } else if(obj == 'Foreign_Investigation__c') {
            //no fields
        } else {
            query += ',Work_Order__r.Source__c,RecordType.Name';
        }

        query += ' FROM ' + obj
            + ' WHERE Id IN :listFilingIds WITH SECURITY_ENFORCED';
        
        return Database.query(query);
    }

    /**
     * @desc: If criteria matches, create document
     * @update: BRS-7781 | No insert-update if no uploaded file 
     */
    enum DeliveryOption {
        hasUpload,
        hasNoUpload
    }

    public class NintexWrapper {
		@InvocableVariable(label = 'Filing Id')
        public String filingId;
        @InvocableVariable(label = 'Filing Status')
        public String status;
        @InvocableVariable(label = 'Certificate Wrapper')
        public String certificateResponse;
        
        @InvocableVariable(label = 'Type') //for specific mappings
        public String type;  
        
        public NintexWrapper() {}

        public NintexWrapper(String filingId, String status) {
            this.filingId = filingId;
            this.status = status;
        }

        public NintexWrapper(String filingId, String status, String type) {
            this.filingId = filingId;
            this.status = status;
            this.type = type;
        }
    }
}