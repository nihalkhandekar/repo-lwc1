@isTest
public with sharing class CTBOT_SitecoreAPIService_MOCK implements HttpCalloutMock {

    public Boolean returnError = false;
    public Boolean returnRelatedItems = true;
    
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().contains('callout:Sitecore')) {
            response.setStatusCode(returnError ? 404 : 200);
        } else if (request.getEndpoint().contains('confused') || request.getEndpoint().contains('ContentId')) {
            response.setBody(generateIdResponse());
            response.setStatusCode(200);
        } else response.setStatusCode(200);
        return response;
    }

    public String generateIdResponse() {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('Items');
        generator.writeStartArray();
        generator.writeStartObject();

        // Test article content
        generator.writeStringField('TagDescription', '<h4>Test body content</h4>');
        generator.writeStringField('ChatbotTitle', 'Test Article Title');
        generator.writeStringField('ChatbotContent', '<h4>Test chatbot content</h4>');

        // Test buttons
        if (returnRelatedItems) {
            generator.writeFieldName('RelatedItems');
            generator.writeStartArray();
            generator.writeStartObject();
            generator.writeStringField('ID', 'a094eb99-a2fa-4c40-8609-f4c258e0388c');
            generator.writeStringField('ChatbotTitle', 'Test Related Article Title 1');
            generator.writeEndObject();
            generator.writeStartObject();
            generator.writeStringField('ID', '945eba5c-fa2c-4769-9c64-70042bffe27f');
            generator.writeStringField('ChatbotTitle', 'Test Related Article Title 2');
            generator.writeEndObject();
            generator.writeEndArray();
        }

        generator.writeStringField('ID', 'eeb72f59-8689-4af7-a0fa-3c7ed7f6fe5d');
        generator.writeEndObject();
        generator.writeEndArray();
        generator.writeEndObject();

        return generator.getAsString();
    }
}