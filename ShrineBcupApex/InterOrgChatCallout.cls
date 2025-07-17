public with sharing class InterOrgChatCallout {

    public static Inter_Org_Transfer_Detail__mdt metadataRecord;
    public static HttpRequest request;
    public static String queries;
    public static Boolean useLiveAgentApiEndpoint = false;
    private static String method;
    private static JSONRequest body;
    private static String path;
    @TestVisible private static Boolean isTest = false;
    private static List<String> validMethods = new List<String>{'GET', 'POST'};

    public static void beginInterOrgChatCallout(String org, String httpMethod, String urlPath, JSONRequest jsonBody) {

        if (!validMethods.contains(httpMethod)) {
            throw new InterOrgException('Invalid method specified for callout');
        } else method = httpMethod;

        if (jsonBody != null) body = jsonBody;

        if (String.isNotBlank(urlPath)) {
            path = urlPath;
        } else throw new InterOrgException('No URL path specified for callout');

        if (String.isBlank(org)) throw new InterOrgException('No org specified for callout');

        getMetadataRecord(org);
    }

    public static HttpRequest getRequest() {
        request = new HttpRequest();
        if (metadataRecord != null) {
            String endpoint = path == null ? metadataRecord.Endpoint__c.trim() : metadataRecord.Endpoint__c.trim() + path;
            endpoint = useLiveAgentApiEndpoint && path != null ? metadataRecord.baseLiveAgentURL__c + path : endpoint;
            endpoint += queries == null ? '' : queries;
            request.setEndpoint(endpoint);
            request.setMethod(method);
            if (useLiveAgentApiEndpoint) request.setHeader('X-LIVEAGENT-API-VERSION', '50');
            if (body != null) {
                request.setHeader('Content-Type', 'application/json');
                request.setBody(JSON.serialize(body, true).replace('_customFieldEnd', '__c'));
            }
        }
        return request;
    }

    public static HttpResponse sendRequest() {
        Http http = new Http();
        request = getRequest();
        return http.send(request);
    }

    private static void getMetadataRecord(String org) {
        try {
            List<Inter_Org_Transfer_Detail__mdt> records = [
                SELECT Endpoint__c, Org_ID__c, deploymentId__c, buttonId__c, baseLiveAgentURL__c
                FROM Inter_Org_Transfer_Detail__mdt
                WHERE MasterLabel = :org
                LIMIT 1
            ];
            if (records.size() > 0 || isTest) {
                metadataRecord = !isTest ? records[0] : new Inter_Org_Transfer_Detail__mdt(
                    MasterLabel = 'Test Metadata',
                    Endpoint__c = 'https://www.test.com',
                    Org_ID__c = '0Xx5w0000002FjH',
                    deploymentId__c = '0Xx5w0000002FjH',
                    buttonId__c = '0Xx5w0000002FjH'
                );
            } else if (records.size() == 0) {
                throw new InterOrgException('No metadata records found for InterOrgChatCallout');
            }
        } catch (Exception e) {
            throw new InterOrgException('There was an error retrieving the metadata record for the InterOrgChatCallout. '
                + 'Error: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString());
        }
    }

    public class JSONRequest {
        public Boolean allOrNone;
        public List<JSONCompositeRequest> compositeRequest;
    }
    
    public class JSONBody {
        // Transcript fields
        public String Body;
        public String ChatKey;
        public String Status;
        public Datetime RequestTime;
        public Datetime StartTime;
        public Datetime EndTime;
        public String EndedBy;
        public Integer WaitTime;
        public Integer ChatDuration;
        public String Visitor_URL_customFieldEnd;
        public String Location;
        public String Browser;
        public String IpAddress;
        public String BrowserLanguage;
        public String Platform;
        public String ReferrerUri;
        public String ScreenResolution;
        public String VisitorNetwork;
        public String UserAgent;
        public Integer AverageResponseTimeVisitor;
        public Integer AverageResponseTimeOperator;
        public Integer MaxResponseTimeVisitor;
        public Integer MaxResponseTimeOperator;
        public Integer VisitorMessageCount;
        public Integer OperatorMessageCount;
        public String ContactId;
        public String LiveChatVisitorId;
        public String CaseId;

        // Contact fields
        public String FirstName;
        public String LastName;
        public String Email;

        // Case fields
        public String SuppliedEmail;
        public String SuppliedName;
    }

    public class JSONCompositeRequest {
        public String method;
        public String referenceId;
        public String url;
        public JSONBody body;
    }

    public class InterOrgException extends Exception {}
}