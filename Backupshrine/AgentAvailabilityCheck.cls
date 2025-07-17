public without sharing class AgentAvailabilityCheck {

    public class AgentAvailabilityWrapper {
        @InvocableVariable public String isAvailable = 'false';
        @InvocableVariable public String estimatedWaitTime;
        @InvocableVariable public String queueSize;

        public AgentAvailabilityWrapper(HttpResponse waitTimeResponse, HttpResponse queueSizeResponse) {
            setEstimatedWaitTimeAndAvailability(waitTimeResponse.getBody());
            setQueueSize(queueSizeResponse.getBody());
        }

        private void setEstimatedWaitTimeAndAvailability(String JSONBody) {

            JSONParser parser = JSON.createParser(JSONBody);
    
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'messages') {
                    while (parser.nextToken() != JSONToken.END_OBJECT) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'results') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'estimatedWaitTime') {
                                    parser.nextValue();
                                    
                                    Integer estimatedWaitTimeInSeconds = Integer.valueOf(parser.getText());
                                    Decimal estimatedWaitTimeInMinutes = (Decimal)(Math.abs(estimatedWaitTimeInSeconds)/60.00).round(System.RoundingMode.CEILING);
                                    this.estimatedWaitTime = String.valueOf(estimatedWaitTimeInMinutes);
                                } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'isAvailable') {
                                    parser.nextValue();
                                    this.isAvailable = parser.getText();
                                    break;
                                }
                            }
                        }
                    }
                } 
            }
        }

        private void setQueueSize(String JSONBody) {

            JSONParser parser = JSON.createParser(JSONBody);
    
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'totalSize') {
                    parser.nextValue();
                    this.queueSize = parser.getText();
                } 
            }    
        }
    }

    @InvocableMethod(label='Check Agent Availability' description='Checks the availability of agents in a destination org')
    public static List<AgentAvailabilityWrapper> checkAgentAvailability(List<String> orgs) {
        
        // N.B. A remote site setting must be set up for this as the base URL is different
        InterOrgChatCallout.beginInterOrgChatCallout(orgs[0], 'GET', '/rest/Visitor/Availability', null);
        InterOrgChatCallout.queries = '?org_id=' + InterOrgChatCallout.metadataRecord.Org_ID__c
            + '&deployment_id=' + InterOrgChatCallout.metadataRecord.deploymentId__c
            + '&Availability.ids=' + InterOrgChatCallout.metadataRecord.buttonId__c
            + '&Availability.needEstimatedWaitTime=1';
        InterOrgChatCallout.useLiveAgentApiEndpoint = true;
        HttpResponse availabilityResponse = InterOrgChatCallout.sendRequest();

        if (Test.isRunningTest()) {
            InterOrgChatCalloutMock.testAgentAvailability = false;
            InterOrgChatCalloutMock.testQueueSize = true;
        }

        InterOrgChatCallout.beginInterOrgChatCallout(orgs[0], 'GET', 
            '/services/data/v51.0/query/?q=SELECT+COUNT()+FROM+AgentWork+WHERE+Status+=+\'Assigned\'', null);
        InterOrgChatCallout.useLiveAgentApiEndpoint = false;
        InterOrgChatCallout.queries = null;
        HttpResponse queueSizeResponse = InterOrgChatCallout.sendRequest();

        AgentAvailabilityWrapper wrapper = new AgentAvailabilityWrapper(availabilityResponse, queueSizeResponse);
        return new List<AgentAvailabilityWrapper>{ wrapper };
    }
}