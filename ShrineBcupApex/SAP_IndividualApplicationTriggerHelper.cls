/**
 * DESCRIPTION: This class handles sequence generation and email notifications
 * for IndividualApplication records. It assigns unique sequence numbers based
 * on record type and current period, and sends status change emails.
 *********************************************************************************************/

public without sharing class SAP_IndividualApplicationTriggerHelper {
  public static final String className = 'SAP_IndividualApplicationTriggerHelper';
  public static final String relatedInfoObject = 'Messaging';
  public static final String severity = 'High';

  /**
   * Generates a sequence number for IndividualApplication records.
   * @param recordsToProcess List of IndividualApplication records to process.
   */
  public static void generateSequence(
    List<IndividualApplication> recordsToProcess
  ) {
    String currentPeriod =
      Date.today().year() +
      String.valueOf(Date.today().month()).leftPad(2, '0');

    Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>(
      [
        SELECT Id, Name
        FROM RecordType
        WHERE SObjectType = 'IndividualApplication'
      ]
    );

    Map<String, Integer> sequenceCounters = new Map<String, Integer>();

    for (IndividualApplication obj : recordsToProcess) {
      String prefix = '';

      if (recordTypeMap.containsKey(obj.RecordTypeId)) {
        String recordTypeName = recordTypeMap.get(obj.RecordTypeId).Name;

        if (recordTypeName == 'Apostille') {
          prefix = 'APO';
        } else if (recordTypeName == 'FinSys') {
          prefix = 'FIN';
        } else if (recordTypeName == 'State Seal') {
          prefix = 'SSL';
        } else if (recordTypeName == 'State Extraditions') {
          prefix = 'EXD';
        }
      }

      String sequenceKey = prefix + '-' + currentPeriod;

      if (!sequenceCounters.containsKey(sequenceKey)) {
        List<IndividualApplication> lastRecord = [
          SELECT SAP_Sequence_Number__c
          FROM IndividualApplication
          WHERE
            RecordTypeId = :obj.RecordTypeId
            AND SAP_Sequence_Number__c LIKE :sequenceKey + '%'
                                                          WITH SECURITY_ENFORCED
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];

        Integer currentSequence = 1;

        if (
          !lastRecord.isEmpty() && lastRecord[0].SAP_Sequence_Number__c != null
        ) {
          String lastSequenceStr = lastRecord[0]
            .SAP_Sequence_Number__c.substring(
              lastRecord[0].SAP_Sequence_Number__c.length() - 4
            );
          currentSequence = Integer.valueOf(lastSequenceStr) + 1;
        }

        sequenceCounters.put(sequenceKey, currentSequence);
      }

      Integer nextSequence = sequenceCounters.get(sequenceKey);

      String sequenceNumber =
        prefix +
        '-' +
        currentPeriod +
        '-' +
        String.valueOf(nextSequence).leftPad(4, '0');
      obj.SAP_Sequence_Number__c = sequenceNumber;

      sequenceCounters.put(sequenceKey, nextSequence + 1);
    }
  }

  /**
   * Sends status change notification emails to applicants.
   * @param newRecords List of IndividualApplication records.
   * @param isInsert/isUpdate Flags indicating insert or update operation.
   */
  public static void sendStatusChangeEmails(List<IndividualApplication> newRecords, Boolean isInsert, Boolean isUpdate) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    OrgWideEmailAddress[] orgWideEmails = [SELECT Id, Address 
                                          FROM OrgWideEmailAddress 
                                          WHERE Address = 'do-not-reply-business@notifications.ct.gov' 
                                              WITH SECURITY_ENFORCED
                                          LIMIT 1];
    Id orgWideEmailId = orgWideEmails.isEmpty() ? null : orgWideEmails[0].Id;
    
    // HTML Email Template - With inline styles for better email client compatibility
    String htmlTemplate = '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '<meta charset="UTF-8">' +
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +
    '<style>' +
    '@media screen and (max-width: 480px) {' +
    '  .mobile-padding { padding: 15px !important; }' +
    '  .mobile-header-text-large { font-size: 20px !important; }' +
    '  .mobile-header-text-small { font-size: 16px !important; }' +
    '  .mobile-section { padding: 15px !important; margin: 15px 0 !important; }' +
    '  .mobile-full-width { width: 100% !important; max-width: 100% !important; }' +
    '  .mobile-button { display: block !important; width: 100% !important; padding: 12px 15px !important; text-align: left !important; padding-left: 24px !important; }' +
    '  .mobile-button-container { text-align: left !important; }' +
    '}' +
    '</style>' +
    '</head>' +
    '<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; background-color: #ffffff; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%;">' +
    
    // Header - with inline styles
    '<div style="background-color: #22348e; padding: 25px; text-align: center;" class="mobile-padding">' +
    '    <h1 style="color: white; margin: 5px 0; font-weight: normal; font-size: 24px;" class="mobile-header-text-large">State of Connecticut</h1>' +
    '    <h2 style="color: white; margin: 5px 0; font-weight: normal; font-size: 20px;" class="mobile-header-text-small">Office of the Secretary of the State</h2>' +
    '</div>' +
    
    // Content - with inline styles
    '<div style="padding: 30px; background-color: #ffffff; width: 100%; box-sizing: border-box;" class="mobile-padding">' +
    '    <div style="margin-bottom: 20px; color: #333333;">' +
    '        Dear {customerName},' +
    '    </div>' +
    '    <div style="margin-bottom: 15px; font-weight: bold; color: #333333;">' +
    '        Your Apostille application status has been updated.' +
    '    </div>' +
    '    <div style="margin-bottom: 25px; color: #333333;">' +
    '        {statusText}' +
    '    </div>' +
    
    // Application info - with inline styles
    '    <div style="background-color: #e9ecf6; padding: 20px; margin: 25px 0; text-align: center; border-radius: 4px;" class="mobile-section">' +
    '        <div style="font-weight: normal; margin-bottom: 5px; color: #333333;">Application Reference Number</div>' +
    '        <div style="margin: 5px 0; font-size: 16px; color: #333333;">APO-{sequenceNumber}</div>' +
    '    </div>' +
    
    // Tracking section - with inline styles
    '    <div style="background-color: #fef8e8; padding: 20px; margin: 25px 0; border-left: 4px solid #f5c76c; border-radius: 0 4px 4px 0;" class="mobile-section">' +
    '        <div style="font-weight: bold; margin-bottom: 10px; color: #333333;">Track Your Application</div>' +
    '        <div style="margin-bottom: 15px; color: #333333;">' +
    '            You can monitor the current status of your application using our online tracking system. Simply click the button below to view your application status:' +
    '        </div>' +
    '        <div style="text-align: center; margin: 20px 0; width: 100%; box-sizing: border-box;" class="mobile-button-container">' +
    // Button with table-based structure for better email client compatibility
    '            <table border="0" cellpadding="0" cellspacing="0" style="margin: 0 auto;">' +
    '                <tr>' +
    '                    <td align="center" style="border-radius: 4px;" bgcolor="#22348e">' +
    '                        <a href="{trackingUrl}" target="_blank" style="color: #ffffff; text-decoration: none; font-weight: normal; display: inline-block; padding: 12px 24px; text-align: center;" class="mobile-button">Track Your Application</a>' +
    '                    </td>' +
    '                </tr>' +
    '            </table>' +
    '        </div>' +
    '    </div>' +
    
    // Assistance section - with inline styles
    '    <div style="background-color: #f5f5f5; padding: 20px; margin: 25px 0; color: #333333; border-radius: 4px;" class="mobile-section">' +
    '        <div style="font-weight: bold; margin-bottom: 10px; color: #333333;">Need Assistance?</div>' +
    '        <div>If you have questions about your application, our team is here to help:</div>' +
    '        <div style="margin-top: 10px;"><strong>Email:</strong> businessservices@ct.gov</div>' +
    '    </div>' +
    '</div>' +
    
    // Footer - with inline styles
    '<div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 12px; color: #666; margin-top: 30px;">' +
    '    © 2025 Connecticut Secretary of State. All rights reserved.' +
    '</div>' +
    
    '</body>' +
    '</html>';
    
    for (IndividualApplication app : newRecords) {
        // Check if the status is not equal to "Payment Captured" or "Payment Pending"
        if (app.Status != 'Payment Captured' && app.Status != 'Payment Pending') {
            String sequenceNumber = app.sap_Sequence_Number__c;
            String customerName = app.sap_First_Name__c + ' ' + app.sap_Last_Name__c;
            String statusText = '';
            String baseUrl = System.Label.sap_SOTSAppUrl;
            String trackingUrl = baseUrl + '/apostillerequest?workOrderNumber=' + sequenceNumber;
            String shippingType = String.isNotBlank(app.sap_Return_Mail_Type__c) ? app.sap_Return_Mail_Type__c : '';
            String fedEx = (app.sap_FedEX__c != null) ? String.valueOf(app.sap_FedEX__c.intValue()) : '';

            // Combine shippingType and fedEx dynamically
            String shippingMethod = '';

            if (String.isNotBlank(shippingType) && String.isNotBlank(fedEx)) {
                shippingMethod = shippingType + ' ' + fedEx;
            } else if (String.isNotBlank(shippingType)) {
                shippingMethod = shippingType;
            } else if (String.isNotBlank(fedEx)) {
                shippingMethod = 'FedEx ' + fedEx;
            }

            // Determine the status text based on the application status
            if (app.Status == 'Documents Received') {
                statusText = 'Your document(s) have been received by our Authentication and Apostille Unit. Regular orders are typically processed within 5-7 business days. Expedited orders are processed within 24 hours.';
            } else if (app.Status == 'Order Completed - Mail') {
                statusText = 'Your order is complete and is being returned to you via ' + (String.isNotBlank(shippingMethod) ? shippingMethod : 'the selected shipping method') + '.';
            } else if (app.Status == 'Order Completed – Pick Up') {
                statusText = 'Your order is complete and is available for pick up. Our public counter is open from 8:30 a.m. to 4:00 p.m. – 165 Capitol Avenue, Hartford, CT.';
            } else if (app.Status == 'Cancelled By Customer') {
                statusText = 'Your order has been cancelled, and we have refunded payment. You may log in to reinstate this order and resubmit payment.';
            } else if (app.Status == 'Cancelled By System') {
                statusText = 'Your order has been cancelled because the order has been pending for 60 days and we have not received your document(s). If you submitted a payment, it has been refunded. You may log in to reinstate this order and resubmit payment.';
            } else if (app.Status == 'Cancelled By Staff') {
                statusText = 'Your order has been cancelled by staff.';
            }

            // Create a list of email addresses to send the email to
            List<String> toAddresses = new List<String>();
            toAddresses.add(app.sap_Email_Address__c); // Add primary email address
            
            // Create and send email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses); 
            email.setOrgWideEmailAddressId(orgWideEmailId);
            email.setSubject('Apostille Order Update from the Connecticut Office of the Secretary of the State: ' + sequenceNumber);
            
            // Replace placeholders in the HTML template
            String emailBody = htmlTemplate
                .replace('{customerName}', customerName)
                .replace('{statusText}', statusText)
                .replace('{sequenceNumber}', sequenceNumber)
                .replace('{trackingUrl}', trackingUrl);
            
            email.setHtmlBody(emailBody);
            
            // Plain text version - simplified but covers the important information
            String plainTextBody = 'State of Connecticut - Office of the Secretary of the State\n\n' +
                'Dear ' + customerName + ',\n\n' +
                'Your Apostille application status has been updated.\n\n' +
                statusText + '\n\n' +
                'Application Reference Number: ' + sequenceNumber + '\n\n' +
                'Track Your Application:\n' +
                'You can monitor the current status of your application using our online tracking system at: ' + trackingUrl + '\n\n' +
                'Need Assistance?\n' +
                'If you have questions about your application, our team is here to help:\n' +
                'Email: bsd@ct.gov\n\n' +
                '© 2025 Connecticut Secretary of State. All rights reserved.';
            
            email.setPlainTextBody(plainTextBody);
            emails.add(email);
        }
    }
    
    // Send all emails if any exist
    if (!emails.isEmpty()) {
        try {
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            System.debug('Error sending emails: ' + e.getMessage());
        }
    }
}

  /**
   * Sends an email with attachments using Org-Wide Email Address.
   * Parses email data, constructs HTML & plain text bodies, and sends via Salesforce.
   * @param emailData JSON string containing email details and attachments.
   */
  @AuraEnabled
  public static void sendEmailWithAttachment(String emailData) {
    try {
      OrgWideEmailAddress[] orgWideEmails = [
        SELECT Id, Address
        FROM OrgWideEmailAddress
        WHERE Address = 'do-not-reply-business@notifications.ct.gov'
        LIMIT 1
      ];
      Id orgWideEmailId = orgWideEmails.isEmpty() ? null : orgWideEmails[0].Id;

      Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
        emailData
      );

      String firstName = (String) data.get('firstName');
      String lastName = (String) data.get('lastName');
      String workOrderNumber = (String) data.get('workOrderNumber');
      String emailToSend = (String) data.get('emailToSend');
      String status = (String) data.get('status');

      List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

      if (
        data.containsKey('attachments') &&
        data.get('attachments') instanceof List<Object>
      ) {
        List<Object> attachmentsList = (List<Object>) data.get('attachments');
        for (Object obj : attachmentsList) {
          if (obj instanceof Map<String, Object>) {
            Map<String, Object> attachment = (Map<String, Object>) obj;
            String attachmentName = (String) attachment.get('name');
            String pdfContent = (String) attachment.get('content');
            String mimeType = (String) attachment.get('mimeType');

            if (
              String.isNotBlank(attachmentName) && String.isNotBlank(pdfContent)
            ) {
              try {
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setFileName(attachmentName);
                emailAttachment.setBody(EncodingUtil.base64Decode(pdfContent));
                emailAttachments.add(emailAttachment);
              } catch (Exception e) {
                BOS_Utility.ExceptionHandler(
                  className,
                  'sendEmailWithAttachment',
                  relatedInfoObject,
                  null,
                  severity,
                  e,
                  null
                );
                throw new AuraHandledException(
                  'Error processing attachment: ' +
                    attachmentName +
                    ' Error: ' +
                    e.getMessage()
                );
              }
            } else {
              throw new AuraHandledException(
                'Attachment skipped due to missing name or content.'
              );
            }
          }
        }
      }

      String htmlTemplate =
        '<!DOCTYPE html>' +
        '<html>' +
        '<head>' +
        '<meta charset="UTF-8">' +
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +
        '<style>' +
        '    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; }' +
        '    .header { background-color: #002d72; padding: 25px; text-align: center; border-bottom: 5px solid #c41e3a; }' +
        '    .header h1, .header h2 { color: white; margin: 5px 0; }' +
        '    .header h1 { font-size: 24px; }' +
        '    .header h2 { font-size: 20px; }' +
        '    .content { padding: 40px 30px; background-color: #ffffff; max-width: 800px; margin: 0 auto; }' +
        '    .footer { background-color: #f5f5f5; padding: 20px; font-size: 12px; text-align: center; border-top: 1px solid #ddd; }' +
        '    .main-text { margin: 20px 0; color: #333333; }' +
        '    .main-text h3 { color: #002d72; margin-top: 30px; }' +
        '    .main-text ul { margin: 20px 0; padding-left: 20px; }' +
        '    .main-text li { margin-bottom: 10px; }' +
        '    .submit-notice { background-color: #fff3e0; padding: 25px; margin: 30px 0; border-left: 5px solid #ff9800; }' +
        '    .submit-notice h3 { color: #333333; margin-top: 0; }' +
        '    .submit-table { width: 100%; border-collapse: collapse; margin: 20px 0; background-color: #ffffff; }' +
        '    .submit-table td { padding: 20px; border: 1px solid #ddd; color: #333333; }' +
        '    .submit-table strong { color: #002d72; display: block; margin-bottom: 8px; }' +
        '    .important-notice { background-color: #f8f8f8; padding: 25px; margin: 30px 0; border: 1px solid #ddd; }' +
        '    .important-notice h3 { color: #333333; margin-top: 0; }' +
        '    .assistance-notice { background-color: #fff3e0; padding: 25px; margin: 30px 0; border-left: 5px solid #ff9800; }' +
        '    .assistance-notice h3 { color: #333333; margin-top: 0; }' +
        '    .section-content { margin: 15px 0; }' +
        '    .section-content p { margin: 10px 0; }' +
        '</style>' +
        '</head>' +
        '<body>' +
        '<div class="header">' +
        '    <h1>State of Connecticut</h1>' +
        '    <h2>Office of the Secretary of the State</h2>' +
        '</div>' +
        '<div class="content">' +
        '    <div class="main-text">' +
        '        <p>Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille of Work Order Number {sequenceNumber}</p>' +
        '        <h3>Document Submission Requirements</h3>' +
        '        <p>Documents submitted for legalization must meet certain standards. You should verify:</p>' +
        '        <ul>' +
        '            <li>The document(s) are issued by a Connecticut official or certified by a Connecticut Notary Public</li>' +
        '            <li>The document(s) must be properly notarized</li>' +
        '            <li>The document(s) contains an original signature and/or seal</li>' +
        '        </ul>' +
        '        <p>Print and include your Order Receipt. If you cannot print the receipt, please make certain to include your Work Order number with your document(s).</p>' +
        '    </div>' +
        '    <div class="submit-notice">' +
        '        <h3>How to Submit Your Documents</h3>' +
        '        <div class="section-content">' +
        '            <table class="submit-table">' +
        '                <tr>' +
        '                    <td width="50%">' +
        '                        <strong>FASTER METHOD</strong>' +
        '                        Hand Delivery, FedEx, UPS, or DHL<br>' +
        '                        remain available' +
        '                    </td>' +
        '                    <td width="50%">' +
        '                        <strong>Physical Address</strong>' +
        '                        Secretary of the State Authentications and Apostilles,<br>' +
        '                        165 Capitol Avenue, Suite 1000,<br>' +
        '                        Hartford, CT 06106' +
        '                    </td>' +
        '                </tr>' +
        '                <tr>' +
        '                    <td>' +
        '                        <strong>SLOWER METHOD</strong>' +
        '                        Mail original authentication document(s)' +
        '                    </td>' +
        '                    <td>' +
        '                        <strong>Mailing Address</strong>' +
        '                        (ONLY US Postal Service Mail)<br>' +
        '                        Secretary of the State Authentications and Apostilles,<br>' +
        '                        PO Box 150470, Hartford, CT 06115-0470' +
        '                    </td>' +
        '                </tr>' +
        '            </table>' +
        '        </div>' +
        '    </div>' +
        '    <div class="important-notice">' +
        '        <h3>Payment Information</h3>' +
        '        <div class="section-content">' +
        '            <p>Personal Check and Money Order: Make your check and/or Money Order payable to: "Secretary of the State". The amount due can be found on your Order Receipt.</p>' +
        '            <p>Remember to provide a prepaid shipping label for FedEx, UPS, DHL or the US Postal Service. We will return your legalized document(s) using that method. If you do not provide prepaid shipping, we will return your document via first class mail.</p>' +
        '        </div>' +
        '    </div>' +
        '    <div class="assistance-notice">' +
        '        <h3>Need Assistance?</h3>' +
        '        <div class="section-content">' +
        '            <p><strong>Contact Hours:</strong> 8:30 a.m. to 4:00 p.m.</p>' +
        '            <p><strong>Support Tickets:</strong> Create a Support Ticket for direct communication with our office. An agent will respond to you by email.</p>' +
        '            <p><strong>Email:</strong> bsd@ct.gov</p>' +
        '            <p>All emails receive a help desk ticket -- please email for faster customer service.</p>' +
        '        </div>' +
        '    </div>' +
        '</div>' +
        '</body>' +
        '</html>';

      String htmlBody = htmlTemplate.replace(
        '{sequenceNumber}',
        workOrderNumber
      );

      String plainTextBody =
        'Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille with Work Order: ' +
        workOrderNumber +
        '\n\n' +
        'Document Submission Requirements:\n' +
        '- The document(s) are issued by a Connecticut official or certified by a Connecticut Notary Public\n' +
        '- The document(s) must be properly notarized\n' +
        '- The document(s) contains an original signature and/or seal\n\n' +
        'How to Submit Your Documents:\n\n' +
        'FASTER METHOD: Hand Delivery, FedEx, UPS, or DHL remain available\n' +
        'Physical Address: Secretary of the State Authentications and Apostilles, 165 Capitol Avenue, Suite 1000, Hartford, CT 06106\n\n' +
        'SLOWER METHOD: Mail original authentication document(s)\n' +
        'Mailing Address: (ONLY US Postal Service Mail) Secretary of the State Authentications and Apostilles, PO Box 150470, Hartford, CT 06115-0470\n\n' +
        'Payment Information:\n' +
        'Personal Check and Money Order: Make payable to "Secretary of the State". Amount due on Order Receipt.\n\n' +
        'Contact Us:\n' +
        'Hours: 8:30 a.m. to 4:00 p.m.\n' +
        'Email: bsd@ct.gov';

      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new List<String>{ emailToSend });

      if (orgWideEmailId != null) {
        email.setOrgWideEmailAddressId(orgWideEmailId);
      }

      email.setSubject(
        'Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille with Work Order: ' +
        workOrderNumber
      );
      email.setHtmlBody(htmlBody);
      email.setPlainTextBody(plainTextBody);

      if (!emailAttachments.isEmpty()) {
        email.setFileAttachments(emailAttachments);
      }

      if (!Test.isRunningTest()){
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
      }
    } catch (Exception ex) {
      BOS_Utility.ExceptionHandler(
        className,
        'sendEmailWithAttachment',
        relatedInfoObject,
        null,
        severity,
        ex,
        null
      );
      throw new AuraHandledException(
        'Error processing email data: ' + ex.getMessage()
      );
    }
  }

  /**
   * Deletes related records for a given list of IndividualApplication records.
   * Removes associated SAP_ApostilleNotification__c and RegulatoryTrxnFee records.
   * @param applicationsToDelete List of IndividualApplication records to process.
   */
  public static void deleteRelatedRecords(
    List<IndividualApplication> applicationsToDelete
  ) {
    Set<Id> applicationIds = new Set<Id>();
    for (IndividualApplication app : applicationsToDelete) {
      if (app != null && app.Id != null) {
        applicationIds.add(app.Id);
      }
    }

    if (applicationIds.isEmpty()) {
      return;
    }

    List<SAP_ApostilleNotification__c> notificationsToDelete = [
      SELECT Id, object_Id_For_Notification__c
      FROM SAP_ApostilleNotification__c
      WHERE object_Id_For_Notification__c IN :applicationIds
    ];

    List<RegulatoryTrxnFee> feesToDelete = [
      SELECT Id, ParentRecordId
      FROM RegulatoryTrxnFee
      WHERE ParentRecordId IN :applicationIds
            WITH SECURITY_ENFORCED
    ];

    try {
      if (!notificationsToDelete.isEmpty()) {
                Database.delete(notificationsToDelete, AccessLevel.USER_MODE);
      }
      if (!feesToDelete.isEmpty()) {
                Database.delete(feesToDelete, AccessLevel.USER_MODE);
      }
    } catch (DmlException e) {
      BOS_Utility.ExceptionHandler(
        className,
        'deleteRelatedRecords',
        'SAP_ApostilleNotification__c',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Unexpected error deleting records: ' + e.getMessage()
      );
    }
  }

  public static void updateRelatedDocumentsForReceivedStatus(List<IndividualApplication> newRecords, Map<Id, IndividualApplication> oldRecords) {
    Set<Id> applicationIds = new Set<Id>();

     for (IndividualApplication app : newRecords) {
        if (oldRecords.containsKey(app.Id)) {
            IndividualApplication oldApp = oldRecords.get(app.Id);
            // Ensure status is changing to 'Documents Received'
            if (app.Status == 'Documents Received') {
                System.debug('Inside Documents Received update for record: ' + app.Id);
                applicationIds.add(app.Id);
            }else{
                System.debug('Not Documents Received update for record: ' + app.Id);
            }
        }
    }

    if (!applicationIds.isEmpty()) {
        List<DocumentChecklistItem> relatedDocuments = [
            SELECT Id, Status
            FROM DocumentChecklistItem
            WHERE ParentRecordId IN :applicationIds
        ];

        if (!relatedDocuments.isEmpty()) {
            for (DocumentChecklistItem doc : relatedDocuments) {
                doc.Status = 'Documents Received';
            }
            update relatedDocuments;
        }
    }
}
}