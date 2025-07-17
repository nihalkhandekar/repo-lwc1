@RestResource(urlMapping='/apostilleNotification/*')
global with sharing class ApostilleNotificationService {
    @HttpPost
    global static void sendNotification() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Parse JSON request body
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            
            // Extract necessary fields
            Id userId = (Id) requestBody.get('userId');
            Id apostilleRecordId = (Id) requestBody.get('apostilleRecordId');
            
            // Validate input
            if (userId == null || apostilleRecordId == null) {
                throw new ApostilleServiceException('Invalid input: userId and apostilleRecordId are required.');
            }
            
            // Set success response
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message":"Notification sent successfully"}');
        } catch (ApostilleServiceException e) {
            // Handle custom exceptions
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"' + e.getMessage() + '"}');
        } catch (Exception e) {
            // Handle unexpected exceptions
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"An unexpected error occurred: ' + e.getMessage() + '"}');
        }
    }
    
    // Custom exception class for ApostilleNotificationService
    public class ApostilleServiceException extends Exception {}
}