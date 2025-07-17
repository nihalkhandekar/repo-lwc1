public without sharing class ChatbotValidateAuthStatus {
  static final String AUTH_MESSAGE_SUB = '[SIGNIN-STATUS]';

  @InvocableMethod(label='Check authentication status')
  public static List<ResponsesOutput> validateAuthStatus(List<ResponsesInput> responsesInput) {
    ResponsesOutput output = new ResponsesOutput();
    List<ResponsesOutput> outputList = new List<ResponsesOutput>();
    if (!responsesInput.isEmpty() && !String.isBlank(responsesInput[0].lastCustomerInput)) {
    // Get last customer input
    String lastInput = responsesInput[0].lastCustomerInput;
    if (!String.isBlank(lastInput)) {
      lastInput = lastInput.replace('\'', '');
      // Check to see if message came from auto authentication event
      if (lastInput.contains(AUTH_MESSAGE_SUB)) {
        // Deserialize message from site
        Object result = JSON.deserializeUntyped(lastInput);

        if (result instanceof Map<String, Object>) {
          Map<String, Object> resultMap = (Map<String, Object>) result;
          Map<String, Object> data = (Map<String, Object>) resultMap.get(
            AUTH_MESSAGE_SUB
          );
//          System.debug('resultMap: ' + resultMap);
//          System.debug('data: ' + data);

          String token = (String) data.get('AltCustId');
          String contactName = token == null
            ? null
            : EncodingUtil.base64Decode(token).toString();
          String chatKey = (String) resultMap.get('ChatKey');
          String actionType = (String) data.get('ActionType');
          Boolean greetUser = false;

          if (actionType == 'login' && contactName != null && chatKey != null) {
            greetUser = updateTranscript(contactName, chatKey);
          }

          output.token = token;
          output.isAuthEvent = true;
          output.greetUser = greetUser;
        }
      } else {
        output.isAuthEvent = false;
      }

      //      System.debug('output: ' + output);

      outputList.add(output);
    }
  }
    return outputList;
  }

  private static Boolean updateTranscript(String contactName, String chatKey) {
    Boolean greetUser = true;
    LiveChatTranscript transcript = [
      SELECT User_Authenticated__c, ContactId
      FROM LiveChatTranscript
      WHERE ChatKey = :chatKey
      LIMIT 1
    ];

    List<Contact> contacts = [
        SELECT Id
        FROM Contact
        WHERE Name = :contactName
    ];

//    System.debug('transcript: ' + transcript);
//    System.debug('contacts: ' + contacts);

    if (contacts.size() == 1 && transcript.ContactId == null) {
      transcript.ContactId = contacts[0].Id;
    } else if (transcript.ContactId != null || contacts.size() != 1)
      greetUser = false;

    // Make sure we can update the database before even trying
    if (Schema.sObjectType.LiveChatTranscript.fields.ContactId.isUpdateable() &&
        Schema.sObjectType.LiveChatTranscript.fields.User_Authenticated__c.isUpdateable() ) {
        transcript.User_Authenticated__c = true;
        update transcript;
    }
    return greetUser;
  }

  public class ResponsesInput {
    @InvocableVariable(required=true)
    public String lastCustomerInput;
  }

  public class ResponsesOutput {
    @InvocableVariable(required=true)
    public Boolean greetUser;
    @InvocableVariable(required=false)
    public String token;
    @InvocableVariable(required=false)
    public Boolean isAuthEvent;
  }
}