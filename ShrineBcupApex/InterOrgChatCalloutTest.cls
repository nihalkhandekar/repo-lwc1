@isTest
public with sharing class InterOrgChatCalloutTest {

    @isTest
    static void testBeginInterOrgChatCallout() {
        InterOrgChatCallout.JSONRequest testRequest = new InterOrgChatCallout.JSONRequest();
        
        try {
            InterOrgChatCallout.beginInterOrgChatCallout('Test', 'PATCH', 'Test', testRequest);
        } catch (InterOrgChatCallout.InterOrgException e) {
            System.assert(e.getMessage() == 'Invalid method specified for callout');
        }

        try {
            InterOrgChatCallout.beginInterOrgChatCallout('Test', 'GET', null, null);
        } catch (InterOrgChatCallout.InterOrgException e) {
            System.assert(e.getMessage() == 'No URL path specified for callout');
        }

        try {
            InterOrgChatCallout.beginInterOrgChatCallout(null, 'GET', 'Test', null);
        } catch (InterOrgChatCallout.InterOrgException e) {
            System.assert(e.getMessage() == 'No org specified for callout');
        }
        
        try {
            InterOrgChatCallout.beginInterOrgChatCallout('Test', 'GET', 'Test', testRequest);
        } catch (InterOrgChatCallout.InterOrgException e) {
            System.assert(e.getMessage().contains('There was an error retrieving the metadata record'));
        }

    }

    @isTest
    static void testCallout() {
        InterOrgChatCallout.JSONRequest testRequest = new InterOrgChatCallout.JSONRequest();
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());

        InterOrgChatCallout.isTest = true;
        InterOrgChatCallout.beginInterOrgChatCallout('Test', 'GET', 'Test', testRequest);
        HttpResponse response = InterOrgChatCallout.sendRequest();

        System.assertEquals(200, response.getStatusCode());
    }
}