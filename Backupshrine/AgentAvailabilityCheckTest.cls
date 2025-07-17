@isTest
public with sharing class AgentAvailabilityCheckTest {
    
    @isTest
    static void testCheckAgentAvailability() {
        InterOrgChatCalloutMock.testAgentAvailability = true;
        InterOrgChatCallout.isTest = true;
        Test.setMock(HttpCalloutMock.class, new InterOrgChatCalloutMock());

        List<AgentAvailabilityCheck.AgentAvailabilityWrapper> results = AgentAvailabilityCheck.checkAgentAvailability(new List<String>{'Test'});
        System.assertEquals('true', results[0].isAvailable);
        System.assertEquals('1', results[0].estimatedWaitTime);
        System.assertEquals('0', results[0].queueSize);
    }
}