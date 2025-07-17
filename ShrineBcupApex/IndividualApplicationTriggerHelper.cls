public class IndividualApplicationTriggerHelper {
    
    public static void generateSequence(List<IndividualApplication> recordsToProcess) {
        // Get the current year and month in YYYYMM format
        String currentPeriod = Date.today().year() + String.valueOf(Date.today().month()).leftPad(2, '0');
        
        // Create a Date object for the desired date
        //Date currentPeriodDate = Date.newInstance(2025, 11, 11);
        
        // Format the Date as a String in YYYYMM format
        //String currentPeriod = currentPeriodDate.year() + String.valueOf(currentPeriodDate.month()).leftPad(2, '0');
        
        
        
        // Map RecordTypeId to RecordType Name
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SObjectType = 'IndividualApplication']);
        
        // Map to track the highest sequence number for each record type and period
        Map<String, Integer> sequenceCounters = new Map<String, Integer>();
        
        for (IndividualApplication obj : recordsToProcess) {
            String prefix = '';
            
            // Get the RecordType name based on RecordTypeId
            if (recordTypeMap.containsKey(obj.RecordTypeId)) {
                String recordTypeName = recordTypeMap.get(obj.RecordTypeId).Name;
                
                // Determine the prefix based on the record type
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
            
            // Create a unique key based on record type and current period
            String sequenceKey = prefix + '-' + currentPeriod;
            
            // Query the last record of the same type and period to get the last sequence number
            if (!sequenceCounters.containsKey(sequenceKey)) {
                List<IndividualApplication> lastRecord = [SELECT Sequence_Number__c 
                                                          FROM IndividualApplication 
                                                          WHERE RecordTypeId = :obj.RecordTypeId 
                                                          AND Sequence_Number__c LIKE :sequenceKey + '%'
                                                          WITH SECURITY_ENFORCED
                                                          ORDER BY CreatedDate DESC 
                                                          LIMIT 1];
                
                Integer currentSequence = 1;
                
                // If there is a previous record, extract the last sequence number
                if (!lastRecord.isEmpty() && lastRecord[0].Sequence_Number__c != null) {
                    // Extract the numeric part of the last sequence number and increment it
                    String lastSequenceStr = lastRecord[0].Sequence_Number__c.substring(lastRecord[0].Sequence_Number__c.length() - 4);
                    currentSequence = Integer.valueOf(lastSequenceStr) + 1;
                }
                
                // Store the starting sequence number for the key
                sequenceCounters.put(sequenceKey, currentSequence);
            }
            
            // Get the next sequence number for the key
            Integer nextSequence = sequenceCounters.get(sequenceKey);
            
            // Format the sequence number with zero-padded counter
            String sequenceNumber = prefix + '-' + currentPeriod + '-' + String.valueOf(nextSequence).leftPad(4, '0');
            obj.Sequence_Number__c = sequenceNumber;
            
            // Increment the sequence counter for the next record
            sequenceCounters.put(sequenceKey, nextSequence + 1);
        }
    }
    
    public static void sendStatusChangeEmails(List<IndividualApplication> newRecords, Boolean isInsert, Boolean isUpdate) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] orgWideEmails = [SELECT Id, Address 
                                              FROM OrgWideEmailAddress 
                                              WHERE Address = 'do-not-reply-business@notifications.ct.gov' 
                                              WITH SECURITY_ENFORCED
                                              LIMIT 1];
        Id orgWideEmailId = orgWideEmails.isEmpty() ? null : orgWideEmails[0].Id;
        
        // HTML Email Template
        String htmlTemplate = '<!DOCTYPE html>' +
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
            '        <p>Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille.</p>' +
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
        
        for (IndividualApplication app : newRecords) {
            String sequenceNumber = app.Sequence_Number__c;
            String name = app.First_Name__c + ' ' + app.Last_Name__c;
            
            // Create and send email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{app.Email_Address__c, app.Email_Address_For_Receiving_Apostille__c});
            email.setOrgWideEmailAddressId(orgWideEmailId);
            email.setSubject('Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille');
            email.setHtmlBody(htmlTemplate);
            
            // Plain text version - unchanged
            String plainTextBody = 'Thank you for submitting an order with the Connecticut Secretary of the State for an Apostille.\n\n' +
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
            
            email.setPlainTextBody(plainTextBody);
            emails.add(email);
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

    // Method to delete related records for IndividualApplication
    public static void deleteRelatedRecords(List<IndividualApplication> applicationsToDelete) {
        Set<Id> applicationIds = new Set<Id>();
        for (IndividualApplication app : applicationsToDelete) {
            if (app != null && app.Id != null) {
                applicationIds.add(app.Id);
            }
        }
        
        if (applicationIds.isEmpty()) {
            System.debug('No valid application IDs found.');
            return;
        }
        
        // Query related apostilleNotification__c records with a lookup to IndividualApplication
        List<apostilleNotification__c> notificationsToDelete = [
            SELECT Id, object_Id_For_Notification__c
            FROM apostilleNotification__c 
            WHERE object_Id_For_Notification__c IN :applicationIds
            WITH SECURITY_ENFORCED
        ];
        
        // Query related RegulatoryTrxnFee records where ParentRecordId is in applicationsToDelete
        List<RegulatoryTrxnFee> feesToDelete = [
            SELECT Id, ParentRecordId 
            FROM RegulatoryTrxnFee 
            WHERE ParentRecordId IN :applicationIds
            WITH SECURITY_ENFORCED
        ];
        
        // Debug logs to confirm query results
        System.debug('Fees to Delete: ' + feesToDelete);
        System.debug('Notifications to Delete: ' + notificationsToDelete);
        
        // Delete related records in bulk
        try {
            if (!notificationsToDelete.isEmpty()) {
                Database.delete(notificationsToDelete, AccessLevel.USER_MODE);
            }
            if (!feesToDelete.isEmpty()) {
                Database.delete(feesToDelete, AccessLevel.USER_MODE);
            }
            System.debug('Deleted related records for IndividualApplication: ' + notificationsToDelete.size() + ' Notifications and ' + feesToDelete.size() + ' RegulatoryTrxnFees.');
        } catch (DmlException e) {
            System.debug('Error deleting related records: ' + e.getMessage());
        }
    }
    
}