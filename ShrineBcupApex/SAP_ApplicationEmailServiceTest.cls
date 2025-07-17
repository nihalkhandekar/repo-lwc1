@IsTest
public class SAP_ApplicationEmailServiceTest {
    
    @testSetup
    static void setupTestData() {
       
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestDocument',
            VersionData = Blob.valueOf('Sample file content'),
            PathOnClient = 'TestDocument.pdf'
        );
        insert contentVersion;
        
        contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
    }
    
    
    @IsTest
    static void testSendEmail_Success() {
        
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Map<String, Object> emailData = new Map<String, Object>{
            'toEmail' => 'test@example.com',
            'ccEmail' => 'cc@example.com',
            'subject' => 'Test Subject',
            'description' => 'Test Description',
            'attachments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'TestDoc.pdf',
                    'contentVersionId' => cv.Id
                }
            },
            'paymentAttachments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'Payment.pdf',
                    'content' => EncodingUtil.base64Encode(Blob.valueOf('Test Payment Content'))
                }
            },
            'sealArmDocuments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'Seal.pdf',
                    'content' => EncodingUtil.base64Encode(Blob.valueOf('Test Seal Content'))
                }
            }
        };
            
        Test.startTest();
        Integer emailInvocationsBefore = Limits.getEmailInvocations();
        
        SAP_ApplicationEmailService.sendEmail(JSON.serialize(emailData));
        
        Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assert(emailInvocationsAfter > emailInvocationsBefore, 'Email should have been sent.');
    }
    
    
    @IsTest
    static void testSendEmail_InvalidAttachment() {
       
        Map<String, Object> emailData = new Map<String, Object>{
            'toEmail' => 'test@example.com',
            'subject' => 'Test Subject',
            'description' => 'Test Description',
            'attachments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'TestDoc.pdf',
                    'contentVersionId' => '068000000000000AAA' // Invalid ID
                }
            }
        };
        Test.startTest();
        Integer emailInvocationsBefore = Limits.getEmailInvocations();

        Boolean exceptionThrown = false; 
        try {
             SAP_ApplicationEmailService.sendEmail(JSON.serialize(emailData));
        } catch (Exception e) {
             exceptionThrown = true;
    }

    Integer emailInvocationsAfter = Limits.getEmailInvocations();
    Test.stopTest();

    
    System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'Email should still be sent, but without attachments.');
    System.assertEquals(false, exceptionThrown, 'The method should gracefully handle an invalid attachment without throwing an exception.');

    }
    
    @IsTest
    static void testSendEmail_NoAttachments() {
        
        Map<String, Object> emailData = new Map<String, Object>{
            'toEmail' => 'test@example.com',
            'subject' => 'Test Subject',
            'description' => 'Test Description'
        };
        
        Test.startTest();
        Integer emailInvocationsBefore = Limits.getEmailInvocations();
        
        SAP_ApplicationEmailService.sendEmail(JSON.serialize(emailData));
        
        Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assert(emailInvocationsAfter > emailInvocationsBefore, 'Email should have been sent.');
    }
    
    @IsTest
    static void testSendEmail_InvalidJSON() {
        
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            
            SAP_ApplicationEmailService.sendEmail('invalid json');
            
        } catch (AuraHandledException e) {
            
            exceptionThrown = true;
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for invalid JSON input.');

    }
}