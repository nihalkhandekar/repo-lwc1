public with sharing class SAP_ApplicationEmailService {
    @AuraEnabled
    public static void sendEmail(String emailData) {
        System.debug('Received email data: ' + emailData);
        
        try {

            //Get the org-wide email address
            OrgWideEmailAddress[] orgWideEmails = [SELECT Id, Address 
            FROM OrgWideEmailAddress 
            WHERE Address = 'do-not-reply-business@notifications.ct.gov' WITH SECURITY_ENFORCED
            LIMIT 1];
            Id orgWideEmailId = orgWideEmails.isEmpty() ? null : orgWideEmails[0].Id;

            // Parse the JSON string into a Map
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(emailData);
            
            // Extract fields from the JSON data
            String toEmail = (String) data.get('toEmail');
            String ccEmail = (String) data.get('ccEmail');
            String subject = (String) data.get('subject');
            String description = '';

                        if (data.containsKey('description')) {
                            Object descObj = data.get('description');
                            if (descObj instanceof String) {
                                description = (String) descObj;
                            } else if (descObj instanceof Map<String, Object>) {
                                // If description is a map, extract a specific field, e.g., 'value'
                                if (((Map<String, Object>) descObj).containsKey('value')) {
                                    description = (String) ((Map<String, Object>) descObj).get('value');
                                }
                            }
                        }
            System.debug('Extracted fields - To: ' + toEmail + ', CC: ' + ccEmail + ', Subject: ' + subject + description);

            // Create a list to hold email attachments
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

            if (data.containsKey('attachments') && data.get('attachments') instanceof List<Object>) {
                List<Object> attachmentsList = (List<Object>) data.get('attachments');
                for (Object obj : attachmentsList) {
                    if (obj instanceof Map<String, Object>) {
                        Map<String, Object> attachment = (Map<String, Object>) obj;
                        String contentVersionId = '';
                        
                        if (attachment.containsKey('contentVersionId')) {
                            Object contentVersionObj = attachment.get('contentVersionId');
                            
                            if (contentVersionObj instanceof String) {
                                contentVersionId = (String) contentVersionObj;
                            } else if (contentVersionObj instanceof Map<String, Object>) {
                                // Extract the correct contentVersionId
                                if (((Map<String, Object>) contentVersionObj).containsKey('contentVersionId')) {
                                    contentVersionId = (String) ((Map<String, Object>) contentVersionObj).get('contentVersionId');
                                }
                            }
                        }
                        
                        String fileName = (String) attachment.get('name');

                        if (String.isNotBlank(contentVersionId)) {
                            try {
                                // Fetch the ContentVersion using contentVersionId
                                ContentVersion contentVersion = [
                                    SELECT VersionData, Title 
                                    FROM ContentVersion 
                                    WHERE Id = :contentVersionId WITH SECURITY_ENFORCED
                                    ORDER BY CreatedDate DESC 
                                    LIMIT 1
                                ];
                                if (contentVersion != null) {
                                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                                    emailAttachment.setFileName(fileName);
                                    emailAttachment.setBody(contentVersion.VersionData);
                                    emailAttachments.add(emailAttachment);
                                } else {
                                    System.debug('ContentVersion not found for Id: ' + contentVersionId);
                                }
                            } catch (Exception e) {
                                System.debug('Failed to fetch attachment for contentVersionId: ' + contentVersionId + ' due to error: ' + e.getMessage());
                            }
                        } else {
                            System.debug('Attachment skipped due to missing contentVersionId.');
                        }
                    }
                }
            }


            if (data.containsKey('paymentAttachments') && data.get('paymentAttachments') instanceof List<Object>) {
                List<Object> paymentAttachments = (List<Object>) data.get('paymentAttachments');
                for (Object obj : paymentAttachments) {
                    if (obj instanceof Map<String, Object>) {
                        Map<String, Object> document = (Map<String, Object>) obj;
                        String fileName = (String) document.get('name');
                        String fileContent = (String) document.get('content'); // Base64 content from client-side upload

                        // Create an email attachment if fileName and content are valid
                        if (String.isNotBlank(fileName) && String.isNotBlank(fileContent)) {
                            try {
                                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                                emailAttachment.setFileName(fileName);
                                emailAttachment.setBody(EncodingUtil.base64Decode(fileContent));
                                emailAttachments.add(emailAttachment);
                            } catch (Exception e) {
                                System.debug('Failed to process seal/arm document: ' + fileName + ' due to error: ' + e.getMessage());
                            }
                        } else {
                            System.debug('Seal/Arm document skipped due to missing fileName or content.');
                        }
                    }
                }
            }

            // Extract and process sealArmDocuments as before
            if (data.containsKey('sealArmDocuments') && data.get('sealArmDocuments') instanceof List<Object>) {
                List<Object> sealArmDocumentsList = (List<Object>) data.get('sealArmDocuments');
                for (Object obj : sealArmDocumentsList) {
                    if (obj instanceof Map<String, Object>) {
                        Map<String, Object> document = (Map<String, Object>) obj;
                        String fileName = (String) document.get('name');
                        String fileContent = (String) document.get('content'); // Base64 content from client-side upload

                        // Create an email attachment if fileName and content are valid
                        if (String.isNotBlank(fileName) && String.isNotBlank(fileContent)) {
                            try {
                                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                                emailAttachment.setFileName(fileName);
                                emailAttachment.setBody(EncodingUtil.base64Decode(fileContent));
                                emailAttachments.add(emailAttachment);
                            } catch (Exception e) {
                                System.debug('Failed to process seal/arm document: ' + fileName + ' due to error: ' + e.getMessage());
                            }
                        } else {
                            System.debug('Seal/Arm document skipped due to missing fileName or content.');
                        }
                    }
                }
            }

            // Create the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{toEmail});
            
            if (String.isNotBlank(ccEmail)) {
                email.setCcAddresses(new List<String>{ccEmail});
            }
            
            // Set the org-wide email address
            if (orgWideEmailId != null) {
                email.setOrgWideEmailAddressId(orgWideEmailId);
            }

            email.setSubject(subject);
            email.setHtmlBody(description); // Assuming description is HTML; use setPlainTextBody for plain text
            email.setFileAttachments(emailAttachments);

            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            System.debug('Email sent successfully.');
        } catch (Exception ex) {
            System.debug('Error processing email data: ' + ex.getMessage());
            throw new AuraHandledException('Error processing email data: ' + ex.getMessage());
        }
    }
}