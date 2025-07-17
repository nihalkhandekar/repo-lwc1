/**
 * Simple service to make http callout to Bitly url shortener service.
 */
public class BitlyService {
    /**
     * Given a long URL will return the shortened version.
     * https://dev.bitly.com/api-reference#createBitlink
     */
    public String shorten(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Bitly/v4/shorten');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, Object>{
            'group_guid' => '{!$Credential.UserName}',
            'long_url' => url
        }));

        HttpResponse res = new Http().send( req );
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        return (String) response.get('link');
    }
}