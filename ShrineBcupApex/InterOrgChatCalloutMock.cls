@isTest
public class InterOrgChatCalloutMock implements HttpCalloutMock {
    @TestVisible
    private static Boolean createContact = false;
    public static Boolean testAgentAvailability = false;
    public static Boolean testQueueSize = false;
    public static Boolean testBusinessHours = false;
    public static Boolean testBlankBusinessHours_ForSunday = false;

    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        if (testAgentAvailability) {
            response.setBody(
                '{"messages":[{"type":"Availability", "message":{"results":[{"estimatedWaitTime":35,"id":"5734S00000009qm","isAvailable":true}]}}]}'
            );
        } else if (testBlankBusinessHours_ForSunday) {
            response.setBody(
                '{"totalSize" : 1,"done" : true,"records" : [ {"attributes" : {"type" : "BusinessHours","url" : "/services/data/v56.0/sobjects/BusinessHours/01mt0000000GoOGAA0"},"Id" : "01mt0000000GoOGAA0","IsActive" : true,"TimeZoneSidKey" : "America/New_York","SundayStartTime" : null,"SundayEndTime" : null,"MondayStartTime" : "07:00:00.000Z","MondayEndTime" : "17:00:00.000Z","TuesdayStartTime" : "07:00:00.000Z","TuesdayEndTime" : "17:00:00.000Z","WednesdayStartTime" : "07:00:00.000Z","WednesdayEndTime" : "17:00:00.000Z","ThursdayStartTime" : "07:00:00.000Z","ThursdayEndTime" : "17:00:00.000Z","FridayStartTime" : "07:00:00.000Z","FridayEndTime" : "17:00:00.000Z","SaturdayStartTime" : null,"SaturdayEndTime" : null} ]}'
            );
        } else if (testBusinessHours) {
            response.setBody(
                '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"BusinessHours","url":"/services/data/v51.0/sobjects/BusinessHours/01m5w000000SFmaAAG"},"Id":"01m5w000000SFmaAAG","IsActive":true,"TimeZoneSidKey":"America/New_York","FridayEndTime":"21:00:00.000Z","FridayStartTime":"09:00:00.000Z","MondayEndTime":"21:00:00.000Z","MondayStartTime":"09:00:00.000Z","SaturdayEndTime":"21:00:00.000Z","SaturdayStartTime":"09:00:00.000Z","SundayEndTime":"00:00:00.000Z","SundayStartTime":"00:00:00.000Z","ThursdayEndTime":"21:00:00.000Z","ThursdayStartTime":"09:00:00.000Z","TuesdayEndTime":"21:00:00.000Z","TuesdayStartTime":"09:00:00.000Z","WednesdayEndTime":"21:30:00.000Z","WednesdayStartTime":"09:00:00.000Z"}]}'
            );
        } else if (!createContact && !testQueueSize) {
            response.setBody(
                '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Contact","url":"/services/data/v51.0/sobjects/Contact/0034S000003NS1hQAG"},"Id":"0034S000003NS1hQAG"}]}'
            );
        } else {
            response.setBody('{"totalSize":0,"done":true,"records":[]}');
        }
        response.setStatusCode(200);
        return response;
    }
}