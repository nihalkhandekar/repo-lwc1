public with sharing class BRS_CopyRequestEmailNotification {
    public static final String className='BRS_CopyRequestEmailNotification';
    public static final String severity='Medium';
    public static final String objectNameOtherRequest='Certficate__c';

    @InvocableMethod
    public static void sendCopyRequestEmail(List<RequestsInfo> RequestsInfo) {
        Set<Id> ORIds = new Set<Id>();
        if(!RequestsInfo.isEmpty()){
            for(RequestsInfo info: RequestsInfo){
                ORIds.add(info.otherReq.Id);
            }
        }
		try{

            List<Id> contentDocumentIds = new List<Id>();
            List<Id> contentVersionIds = new List<Id>();
            List<String> fileTitles = new List<String>();
            Map<Id,Id> contentDocIdVSOtherReqIdMap = new Map<Id,Id>();  
            Map<Id,List<Id>> otherReqIdVSContentVersionIdsMap = new Map<Id,List<Id>>();
            Map<Id,List<String>> otherReqIdVSContentVersionTitlesMap = new Map<Id,List<String>>(); 
            Map<Id,List<Messaging.EmailFileAttachment>> otherReqIdVSEFAsMap = new Map<Id,List<Messaging.EmailFileAttachment>>();

            Map<Id, String> recIdEmailTemplateMap = new Map<Id, String>();
            Map<String,EmailTemplate> tempNameVSTemplateMap = new Map<String,EmailTemplate>();
            Map<Id,EmailTemplate> otherReqIdVSTemplateMap = new Map<Id,EmailTemplate>();
            List<String> copyRequestRecordTypeList = new List<String>{'Business_Copy_Request','Trade_Service_Mark_Copy_Request','UCC_Copy_Request'};
            List<String> certReqRecordTypeList = new List<String>{'Certificate_Request','Special_Certificate_of_Legal_Existence'};
            List<String> emailTemplateNames = new List<String>{'BRS_Copy_Request_Acceptance_template','BRS_Copy_Request_Rejection_template','BRS_Certificate_request_template','BRS_Request_For_Information','Service_Mark_Acceptance_BO','Service_Mark_Rejection_BO'};
            Map<Id,Certficate__c> otherReqMap = new Map<Id,Certficate__c>();

			List<Certficate__c> otherRequestList = [select Id,Status__c,Work_Order__r.Source__c, Work_Order__r.Customer__r.Name, Work_Order__r.Customer__r.Email,
            RecordType.Name,RecordType.DeveloperName,Business__r.Name,Total_Fee__c,Filing_Fee__c,Certificate_Type__c,Business__c,Type__c,Business_Name__c,
            (select Id,Number_of_Copies__c, Business_Filing__c,Filing_Number__c, Copy_Type__c, Mark_Filing__c,Mark_Filing_Number__c, UCC_Filing__c,UCC_Filing_Number__c from Copy_Request_Details__r) 
            from Certficate__c where Id IN:ORIds WITH SECURITY_ENFORCED];

            List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName IN:emailTemplateNames];
            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            for(EmailTemplate et : emailTemplateList){
                tempNameVSTemplateMap.put(et.DeveloperName,et);
            }

                                                     
            for(Certficate__c otherRequestRec: otherRequestList){
                String templateName;
                if(otherRequestRec.Work_Order__r.Source__c!='API' && otherRequestRec.Work_Order__r.Customer__r.Email!=null){
                    if(copyRequestRecordTypeList.contains(otherRequestRec.RecordType.DeveloperName)){
                        if(otherRequestRec.Status__c == System.Label.Approved){
                            templateName='BRS_Copy_Request_Acceptance_template';
                        }else if(otherRequestRec.Status__c == System.Label.Rejected){
                            templateName='BRS_Copy_Request_Rejection_template';
                        }
                    }else if(otherRequestRec.Work_Order__r.Source__c!='Online'){
                        if(certReqRecordTypeList.contains(otherRequestRec.RecordType.DeveloperName)){
                            templateName='BRS_Certificate_request_template';
                        }else if(otherRequestRec.RecordType.DeveloperName == 'Request_for_Information'){
                            templateName='BRS_Request_For_Information';
                        }else if(otherRequestRec.RecordType.DeveloperName == 'Request_for_Search_of_Mark'){
                            if(otherRequestRec.Status__c == System.Label.Approved){
                                templateName='Service_Mark_Acceptance_BO';
                            }else if(otherRequestRec.Status__c == System.Label.Rejected){
                                templateName='Service_Mark_Rejection_BO';
                            }
                        }
                    }
                    otherReqIdVSTemplateMap.put(otherRequestRec.Id, tempNameVSTemplateMap.get(templateName));
                    otherReqMap.put(otherRequestRec.Id,otherRequestRec);
                }
            }    
            
            for(ContentDocumentLink  contentLink: [SELECT LinkedEntityId, Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:ORIds]){
                contentDocumentIds.add(contentLink.ContentDocumentId);
                contentDocIdVSOtherReqIdMap.put(contentLink.ContentDocumentId,contentLink.LinkedEntityId);
            }

            List<ContentVersion> contVersionList = [SELECT ContentDocumentId, Id, Title FROM ContentVersion where ContentDocumentId IN :contentDocumentIds  Order By CreatedDate DESC];
            /**Creating two maps:
             * 1. otherReqIdVSContentVersionIdsMap --> Key = Filing Id, Value = List of all content version Ids -- to get all the content version ids related to a filing.
             * 2. otherReqIdVSContentVersionTitlesMap --> Key = Filing Id, Value = List of all content version Titles -- to check later if the same Titles are present as attachments for the filing. 
             */
            for(ContentVersion contentVer : contVersionList){
                if(contentDocIdVSOtherReqIdMap.keySet().contains(contentVer.ContentDocumentId)){
                    Id filingId = contentDocIdVSOtherReqIdMap.get(contentVer.ContentDocumentId);
                    Certficate__c cert = otherReqMap.get(filingId);
                    if((certReqRecordTypeList.contains(cert.RecordType.DeveloperName) || (cert.RecordType.DeveloperName == 'Request_for_Search_of_Mark' && (contentVer.Title!=cert.RecordType.Name && !contentVer.Title.contains('Rejected')))) || (contentVer.Title.contains(System.Label.AcceptanceLabel) || contentVer.Title.contains(System.Label.RejectionLabel))){
                        if(otherReqIdVSContentVersionIdsMap.keySet().contains(filingId)){
                            otherReqIdVSContentVersionIdsMap.get(filingId).add(contentVer.Id);
                        }else{
                            otherReqIdVSContentVersionIdsMap.put(filingId,new List<Id>{contentVer.Id});
                        }
    
                        if(otherReqIdVSContentVersionTitlesMap.keySet().contains(filingId)){
                            otherReqIdVSContentVersionTitlesMap.get(filingId).add(contentVer.Title);
                        }else{
                            otherReqIdVSContentVersionTitlesMap.put(filingId,new List<String>{contentVer.Title});
                        }
                    }
                }
            }

            Map<Id,List<Attachment>> attachMap = getAttachments(ORIds);
            for(Id orId: attachMap.keySet()){
                if(attachMap.keySet().contains(orId)){
                    List<Attachment> attachedFiles = attachMap.get(orId);
                    for(Attachment att:attachedFiles){
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(att.Name);
                        efa.setBody(att.body);
                        efa.setContentType(att.ContentType);
                        efa.setInline(false);
                        if((otherReqIdVSContentVersionTitlesMap.keySet().contains(att.ParentId) && !otherReqIdVSContentVersionTitlesMap.get(att.ParentId).contains(att.Name)) || otherReqIdVSContentVersionTitlesMap.isEmpty() || !otherReqIdVSContentVersionTitlesMap.keySet().contains(att.ParentId)){
                            if(otherReqIdVSEFAsMap.keySet().contains(att.ParentId)){
                                for(Messaging.EmailFileAttachment efaObj : otherReqIdVSEFAsMap.get(att.ParentId))
                                {
                                    if(efaObj.fileName!=att.Name){
                                        otherReqIdVSEFAsMap.get(att.ParentId).add(efa);
                                    }
                                }                                              
                            }else{
                                otherReqIdVSEFAsMap.put(att.ParentId,new List<Messaging.EmailFileAttachment>{efa});
                            }
                            if(otherReqIdVSContentVersionTitlesMap.keySet().contains(att.ParentId)){
                                otherReqIdVSContentVersionTitlesMap.get(att.ParentId).add(att.Name);
                            }else{
                                otherReqIdVSContentVersionTitlesMap.put(att.ParentId, new List<String>{att.Name});
                            }
                        }
                    }
                }
            }
			
                    Map<Id,List<Id>> otherReqIdVSdetailsReqIdMap = new  Map<Id,List<Id>>();
                    Set<Id> crtiReqIds = new  Set<Id>();
                    Set<Id> certDetailReqIds = new  Set<Id>();
                    for(Certficate__c otherRequestRec: otherRequestList){
                       
                        if(otherRequestRec.Status__c == 'Approved' && copyRequestRecordTypeList.contains(otherRequestRec.RecordType.DeveloperName)){
                            for(Copy_Request_Details__c detail : otherRequestRec.Copy_Request_Details__r) {
                                if(detail.Copy_Type__c == 'Plain'){
                                    if(detail.Business_Filing__c!=null){
                                        if(otherReqIdVSdetailsReqIdMap.keySet().contains(otherRequestRec.Id)){
                                            otherReqIdVSdetailsReqIdMap.get(otherRequestRec.Id).add(detail.Business_Filing__c);
                                        }else{
                                            otherReqIdVSdetailsReqIdMap.put(otherRequestRec.Id, new List<Id>{detail.Business_Filing__c});
                                        }
                                        certDetailReqIds.add(detail.Business_Filing__c);
                                    }else if(detail.Mark_Filing__c!=null){
                                        if(otherReqIdVSdetailsReqIdMap.keySet().contains(otherRequestRec.Id)){
                                            otherReqIdVSdetailsReqIdMap.get(otherRequestRec.Id).add(detail.Mark_Filing__c);
                                        }else{
                                            otherReqIdVSdetailsReqIdMap.put(otherRequestRec.Id, new List<Id>{detail.Mark_Filing__c});
                                        }
                                        certDetailReqIds.add(detail.Mark_Filing__c);
                                    }else if(detail.UCC_Filing__c!=null){
                                        if(otherReqIdVSdetailsReqIdMap.keySet().contains(otherRequestRec.Id)){
                                            otherReqIdVSdetailsReqIdMap.get(otherRequestRec.Id).add(detail.UCC_Filing__c);
                                        }else{
                                            otherReqIdVSdetailsReqIdMap.put(otherRequestRec.Id, new List<Id>{detail.UCC_Filing__c});
                                        }
                                        certDetailReqIds.add(detail.UCC_Filing__c);
                                    }
                                }else{
                                     if(otherReqIdVSdetailsReqIdMap.keySet().contains(otherRequestRec.Id)){
                                            otherReqIdVSdetailsReqIdMap.get(otherRequestRec.Id).add(detail.Id);
                                        }else{
                                            otherReqIdVSdetailsReqIdMap.put(otherRequestRec.Id, new List<Id>{detail.Id});
                                        }
                                    crtiReqIds.add(detail.Id);
                                    certDetailReqIds.add(detail.Id);
                                }
                            }
                        }
                    }
                    

                    Map<Id,List<ContentVersion>> otherReqIdVSContentVersion = new Map<Id,List<ContentVersion>>();
                    Map<Id,List<Attachment>> otherReqIdVSAttachment = new Map<Id,List<Attachment>>();
                    List<Attachment> attachedFilescopyreq = new List<Attachment>();
                    Map<Id, Attachment> parentIdAttachmentMap = new Map<Id, Attachment>();
                    if(!certDetailReqIds.isEmpty()){
                        Map<Id, ContentVersion> parentIdContentVersionMap = BRS_ReqCopyController.getRelatedFiles(certDetailReqIds);
                        attachedFilescopyreq = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId =:certDetailReqIds and  ContentType = 'application/pdf' and (NOT Name  like '%Acceptance%')];   
                        for(Attachment att: attachedFilescopyreq){
                            parentIdAttachmentMap.put(att.ParentId,att);
                        }

                        for(Id otherRId: otherReqIdVSdetailsReqIdMap.keySet()){
                            for(Id filingId: otherReqIdVSdetailsReqIdMap.get(otherRId)){
                                if(parentIdContentVersionMap.keySet().contains(filingId)){
                                    ContentVersion contentVer = parentIdContentVersionMap.get(filingId);
                                    if(otherReqIdVSContentVersion.keySet().contains(otherRId)){
                                        otherReqIdVSContentVersion.get(otherRId).add(contentVer);
                                    }else{
                                        otherReqIdVSContentVersion.put(otherRId,new List<ContentVersion>{contentVer});
                                    }
                                }
                                if(parentIdAttachmentMap.keySet().contains(filingId)){
                                    Attachment attach = parentIdAttachmentMap.get(filingId);
                                    if(otherReqIdVSAttachment.keySet().contains(otherRId)){
                                        otherReqIdVSAttachment.get(otherRId).add(attach);
                                    }else{
                                        otherReqIdVSAttachment.put(otherRId,new List<Attachment>{attach});
                                    }
                                }
                            }
                        }

                        for(Id otherReqId : otherReqIdVSContentVersion.keySet()){
                            for(ContentVersion doc: otherReqIdVSContentVersion.get(otherReqId)) {
                                if(!otherReqIdVSContentVersionTitlesMap.keySet().contains(otherReqId) || !otherReqIdVSContentVersionTitlesMap.get(otherReqId).contains(doc.Title)) {
                                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                    List<String> donNameList = new List<String>();
                                    if(doc.Title.contains('.pdf')){
                                        attach.setFileName(doc.Title);
                                    }else{
                                        attach.setFileName(doc.Title+'.pdf');
                                    }
                                    attach.setInline(false);
                                    attach.Body = doc.versiondata;
                                    if(otherReqIdVSEFAsMap.keySet().contains(otherReqId)){
                                        otherReqIdVSEFAsMap.get(otherReqId).add(attach);
                                    }else{
                                        otherReqIdVSEFAsMap.put(otherReqId, new List<Messaging.EmailFileAttachment>{attach});
                                    }
                                    if(otherReqIdVSContentVersionTitlesMap.keySet().contains(otherReqId)){
                                        otherReqIdVSContentVersionTitlesMap.get(otherReqId).add(doc.Title);
                                    }else{
                                        otherReqIdVSContentVersionTitlesMap.put(otherReqId, new List<String>{doc.Title});
                                    }
                                }
                            }
                        }

                        for(Id otherReqId: otherReqIdVSAttachment.keySet()){
                            if(otherReqIdVSAttachment.keySet().contains(otherReqId)){
                                for(Attachment attRec: otherReqIdVSAttachment.get(otherReqId)){
                                    if(!otherReqIdVSContentVersionTitlesMap.keySet().contains(otherReqId) || !otherReqIdVSContentVersionTitlesMap.get(otherReqId).contains(attRec.Name)) {
                                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                        attach.setFileName(attRec.Name);
                                        attach.setBody(attRec.body);
                                        attach.setContentType(attRec.ContentType);
                                        attach.setInline(false);
                                        if(otherReqIdVSEFAsMap.keySet().contains(otherReqId)){
                                            otherReqIdVSEFAsMap.get(otherReqId).add(attach);
                                        }else{
                                            otherReqIdVSEFAsMap.put(otherReqId, new List<Messaging.EmailFileAttachment>{attach});
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    for(Certficate__c otherRequestRec: otherRequestList){
                        String emailTemplateName;
                        EmailTemplate emailTemplateRec;
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(otherReqIdVSTemplateMap.keySet().contains(otherRequestRec.Id)){
                            emailTemplateName = otherReqIdVSTemplateMap.get(otherRequestRec.Id).DeveloperName;
                            emailTemplateRec = otherReqIdVSTemplateMap.get(otherRequestRec.Id);
                        }
                        
                        if(emailTemplateName!=null){
                            if(emailTemplateName == 'BRS_Copy_Request_Acceptance_template' || emailTemplateName == 'BRS_Certificate_request_template'){
                                email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, null);
                            }else{
                                email = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, otherRequestRec.Id);
                            }

                            string htmlValue = email.getHtmlBody();
                            Map<String,Decimal> copiesMap = new Map<String,Decimal>();
                            String body;

                            if(emailTemplateName=='BRS_Copy_Request_Acceptance_template'){
                                body = System.label.BRS_CopyRequest_internal_table_header;
                                if(otherRequestRec.Copy_Request_Details__r!=null){
                                    for(Copy_Request_Details__c copyDetail : otherRequestRec.Copy_Request_Details__r){
                                        if(copyDetail.Filing_Number__c!=null){
                                            if(copiesMap.keySet().contains(copyDetail.Filing_Number__c)){
                                                Decimal numberOfCopies = copiesMap.get(copyDetail.Filing_Number__c)+copyDetail.Number_of_Copies__c;
                                                copiesMap.put(copyDetail.Filing_Number__c,numberOfCopies);
                                            }else{
                                                copiesMap.put(copyDetail.Filing_Number__c,copyDetail.Number_of_Copies__c);
                                            }
                                        }else if(copyDetail.Mark_Filing_Number__c!=null){
                                            if(copiesMap.keySet().contains(copyDetail.Mark_Filing_Number__c)){
                                                Decimal numberOfCopies = copiesMap.get(copyDetail.Mark_Filing_Number__c)+copyDetail.Number_of_Copies__c;
                                                copiesMap.put(copyDetail.Mark_Filing_Number__c,numberOfCopies);
                                            }else{
                                                copiesMap.put(copyDetail.Mark_Filing_Number__c,copyDetail.Number_of_Copies__c);
                                            }
                                        }else if(copyDetail.UCC_Filing_Number__c!=null){
                                            if(copiesMap.keySet().contains(copyDetail.UCC_Filing_Number__c)){
                                                Decimal numberOfCopies = copiesMap.get(copyDetail.UCC_Filing_Number__c)+copyDetail.Number_of_Copies__c;
                                                copiesMap.put(copyDetail.UCC_Filing_Number__c,numberOfCopies);
                                            }else{
                                                copiesMap.put(copyDetail.UCC_Filing_Number__c,copyDetail.Number_of_Copies__c);
                                            }
                                        }
                                    }
                                }

                                if(!copiesMap.isEmpty()){
                                    for(String recordNumber: copiesMap.keySet()){
                                        string firstRow = System.label.BRS_CopyRequest_internal_table_row.replace(System.label.BRS_CopyRequest_internal_table_row_number, recordNumber);
                                        firstRow = firstRow.replace(System.label.BRS_CopyRequest_internal_table_row_copies,string.valueOf(copiesMap.containsKey(recordNumber) ? copiesMap.get(recordNumber) : 0));
                                        body +=firstRow;
                                    }
                                    body+='</table>';
                                }
                            }
                           
                            else if(emailTemplateName=='BRS_Certificate_request_template'){
                                body = System.Label.BRS_Obtian_cert_internal_table_header;
                                String certType = otherRequestRec.Certificate_Type__c!=null?otherRequestRec.Certificate_Type__c:otherRequestRec.Type__c;
                                String firstRow = System.Label.BRS_Obtian_cert_internal_table_row.replace(System.Label.BRS_Obtian_cert_internal_table_row_type, certType);
                                firstRow = firstRow.replace(System.Label.BRS_Obtian_cert_internal_table_row_fee, 
                                String.valueOf(otherRequestRec.Total_Fee__c!=null ? otherRequestRec.Total_Fee__c : otherRequestRec.Filing_Fee__c));
                                body += firstRow +'</table>';
                                if(otherRequestRec.Business__c!=null || otherRequestRec.Business_Name__c!=null){
                                    String businessName = otherRequestRec.Business__r.Name!=null?otherRequestRec.Business__r.Name : otherRequestRec.Business_Name__c; //get business name
                                    htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_busines, 'for '+businessName);
                                }else{
                                    htmlValue = htmlValue.replace(System.Label.BRS_Certificate_template_busines, '');
                                }
                            }else{
                                email.setWhatId(otherRequestRec.Id);
                            }

                            if(otherRequestRec.Work_Order__r.Customer__r.Name!=null && htmlValue.contains(system.label.BRS_Certificate_template_firstName)){
                                htmlValue = htmlValue.replace(system.label.BRS_Certificate_template_firstName, otherRequestRec.Work_Order__r.Customer__r.Name);
                            }
                            if(htmlValue.contains(system.label.BRS_Certificate_template_cert)){
                                htmlValue = htmlValue.replace(system.label.BRS_Certificate_template_cert, body);
                            }

                            email.setHtmlBody(htmlValue);//Set HTML Body

                            if(otherRequestRec.Work_Order__r.Customer__r.Email!=null){
                                string[] to = new string[] {otherRequestRec.Work_Order__r.Customer__r.Email};
                                email.setToAddresses(to);
                            }
                            if(owa!=null){
                                email.setOrgWideEmailAddressId(owa.Id);
                            }
                            email.setSubject(emailTemplateRec.Subject);
                            email.setTemplateId(emailTemplateRec.Id);
                            email.setSaveAsActivity(false);

                            if(otherReqIdVSContentVersionIdsMap.keySet().contains(otherRequestRec.Id)){
                                email.setEntityAttachments(otherReqIdVSContentVersionIdsMap.get(otherRequestRec.Id));
                            }
                            if(otherReqIdVSEFAsMap.keySet().contains(otherRequestRec.Id)){
                                email.setFileAttachments(otherReqIdVSEFAsMap.get(otherRequestRec.Id));
                            }

                            if(email.getToAddresses()!=null && email.getToAddresses().size()>0){
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                            }
                        }
                        
                    }
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className,'sendCopyRequestEmail',objectNameOtherRequest,null,severity,e,null);
        }
    }

    public without sharing class RequestsInfo {
        @InvocableVariable
        public Certficate__c otherReq;
    } 

    public static Map<Id, List<Attachment>> getAttachments(Set<Id> certificateIds) {
        try{
            Map<Id, List<Attachment>> mapCertIdAttachmentId = new Map<Id, List<Attachment>>();
            
            for(Attachment attachment : [
                SELECT Id, ParentId, Body,Name,ContentType
                FROM Attachment
                WHERE ParentId IN :certificateIds
            ]) {
                String sObjName = attachment.ParentId.getSObjectType().getDescribe().getName();
                System.debug('attach name** '+attachment.Name);
                if(sObjName=='Certficate__c' && (attachment.Name.Contains(System.Label.BRS_Acceptance_Notice) || attachment.Name.Contains(System.Label.brs_RejectionNotice) || attachment.Name.Contains(System.Label.Request_For_Information_Comparable))){
                    System.debug('attach name222** '+attachment.Name);
                    if(mapCertIdAttachmentId.containsKey(attachment.ParentId)){
                        mapCertIdAttachmentId.get(attachment.ParentId).add(attachment);
                    }else{
                        mapCertIdAttachmentId.put(attachment.ParentId, new List<Attachment>{attachment});
                    }
                }
            }
            System.debug('mapCertIdAttachmentId** '+mapCertIdAttachmentId);
            return mapCertIdAttachmentId;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getAttachments', null, null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}