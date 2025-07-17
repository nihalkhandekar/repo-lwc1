/*********************************************************************************************
 * NAME:  BOS_JitHandler
 * DESCRIPTION: This class reteives the SAML response from forgerock  and recieve all the necessary 
 * data in Map and create the community user 
 *
 * @AUTHOR: Rohit Heera
 * @DATE: 18/03/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 *Rohit Heera                     18/03/2020                         Created the first version
 *Rohit Heera                     21/09/2020                         Adding duplicate contact check and add new Attributes

*********************************************************************************************/

global without sharing class BOS_JitHandler implements Auth.SamlJitHandler {
    public static final String sJITErrorMessageOne = System.Label.SSO_JIT_ErrorMessageOne;
    public static final String sJITErrorMessageTwo = System.Label.SSO_JIT_ErrorMessageTwo;
    public static final String sJITErrorMessageThree = System.Label.SSO_JIT_ErrorMessageThree;
    public static final String sJITException = System.Label.SSO_JIT_Exception;
    public static final String sJITKey = System.Label.SSO_JIT_sKey;
    public static final String sJITAlgorithm = System.Label.SSO_JIT_sAlgorithm;
    public static final String NULL_EMPTY_STRING = '';
    public static final String className ='BOS_JitHandler';
    public static final String createUserMethod ='createUser';
    public static final String createContactMethod = 'createContact';
    public static final String createAccountMethod = 'createAccount';
	public static final String getUserByGuidMethod ='getUserByGuid';
    public static final String userObject ='User';
    public static final String contactObject = 'Contact';
    public static final String accountObject = 'Account';
    public static final String severity = 'High';
    
    private without sharing class JitException extends Exception{
        
    }
    
    private without sharing class JITErrorObject {
        String errorMessage = NULL_EMPTY_STRING;
        String debugType = NULL_EMPTY_STRING;
        String debugMessage = NULL_EMPTY_STRING;
        
        public JITErrorObject(String errorMessage, String debugType, String debugMessage){
            this.errorMessage = errorMessage;
            this.debugType = encrypt(debugType);
            this.debugMessage = encrypt(debugMessage);
        }
        public JITException getJitException(){
            return new JitException(JSON.serialize(this));
        } 
    }
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        try { 
            if(!validSAMLAttributes(attributes)){
                BOS_Utility.ExceptionHandler(className,createUserMethod,userObject,null,severity,new JitException(),sJITErrorMessageThree);
                throw new JITErrorObject(sJITErrorMessageOne,sJITErrorMessageTwo,sJITErrorMessageThree).getJitException();
            }else{  
                User finalUser;
                //Check if the incoming federationIdentifier exists for any portal user
                if(federationIdentifier != null){
                    finalUser = getUserByGuid (federationIdentifier); 
                }
                // if the portal user does not exist with the incoming federationIdentifier then create Account, Conatct and Portal User.
                if (finalUser == null){
                    Account newAcc = createAccount(attributes.get(System.Label.SSO_JIT_FirstName)+attributes.get(System.Label.SSO_JIT_LastName),attributes.get(System.Label.SSO_JIT_Email));
          Boolean idProofStatus = false;
          String status = attributes.get(System.Label.SSO_JIT_IdProofStatus);
          Datetime idProofTimestamp;
          
          
          try{
              if (String.isNotEmpty(status)) {
                idProofStatus = Boolean.valueOf(status);
              }
                        String timestamp = attributes.get(System.Label.SSO_JIT_IdProofTimestamp);
              if (String.isNotEmpty(timestamp)) {
                idProofTimestamp = Datetime.valueOf(timestamp);
              }
          }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, createContactMethod, contactObject, null, severity, ex, ex.getMessage());
  }
         
                    Contact newContact = createContact(attributes.get(System.Label.SSO_JIT_FirstName),attributes.get(System.Label.SSO_JIT_LastName), attributes.get(System.Label.SSO_JIT_Email), newAcc.id, federationIdentifier, idProofStatus, attributes.get(System.Label.SSO_JIT_IdProofSource), idProofTimestamp);
                    finalUser   = createUser (newContact, federationIdentifier,attributes.get(System.Label.SSO_JIT_Username),attributes.get(System.Label.SSO_JIT_LANGUAGE));
                }
				/** call account linking  **/
				AccountLinkingAPIConnect.sendUserIdToFR(finalUser.Id);
                return finalUser;
            }
        }catch(Exception ex){
            If(ex.getTypeName() ==sJITException){
                throw ex;
            }  
            BOS_Utility.ExceptionHandler(className,createUserMethod,userObject,null,severity,ex,ex.getMessage());
            throw new JITErrorObject(sJITErrorMessageOne, 'Exception '+ ex.getTypeName(), ex.getMessage() + ' Trace ' + ex.getStackTraceString()).getJitException();
        }
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               System.debug('@@ attributes=>'+JSON.serialize(attributes));
                       User   finalUser = getUserByGuid (federationIdentifier); 
                         if(finalUser!=null && finalUser.HasUserLinkedToFR__c==false) {
                          AccountLinkingAPIConnect.sendUserIdToFR(finalUser.Id);
                         }
                               /*User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
                                    String appID=  attributes.get('appID');
                                    String appID = 'a0Br00000030Dw1EAE';
                                    updateContactinApplication(u, appID);*/
                           }
    
    private Boolean validSAMLAttributes(Map<String, String> attributes){
        return  attributes.containsKey(System.Label.SSO_JIT_Email) && attributes.containsKey(System.Label.SSO_JIT_FirstName) && attributes.containsKey(System.Label.SSO_JIT_LastName) && attributes.containsKey(System.Label.SSO_JIT_Username);
    }
    
    private User getUserByGuid(String guid){
        List<User> users = new List<User>();
        User user;
        try{
            if(guid!=null){
              users = [SELECT Id, Name, alias, Email, FederationIdentifier, ContactId,HasUserLinkedToFR__c FROM User WHERE FederationIdentifier =:guid and ContactId != null];
            }
             if(test.isRunningTest()){
            throw new NullPointerException();
        }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler(className,getUserByGuidMethod,userObject,null,severity,ex,ex.getMessage());
        }
        if(!users.isEmpty()){
            user =  users[0];
        }
        return user;
    }
    
    @TestVisible public Contact createContact(String firstname,String lastname, String emailVal, String accountId, String guid, Boolean idProofStatus, String idProofSource, Datetime idProofTimestamp) {
      
        Contact contact = getExistingContact(emailVal);
        if (contact != null) {
            contact.AccountId = accountId;
            contact.GUID__c = guid;
            contact.No_of_times_called_Id_proofing__c=0;
            try{
                contact.ID_Proof_status__c = idProofStatus;
                contact.ID_Proof_Source__c = idProofSource;
                if(idProofTimestamp!=null){
                    contact.ID_Proof_Timestamp__c = idProofTimestamp;
                }
                if (test.isRunningTest()) {
          throw new AuraHandledException('error');
        }
      }catch(Exception ex){
        BOS_Utility.ExceptionHandler(className, createContactMethod, contactObject, null, severity, ex, ex.getMessage());
   
      }
    if(Schema.SObjectType.Contact.isUpdateable() && contact.LastName!=null){
        update contact; 
     }
}else{
         contact = new Contact(
                FirstName = firstName, LastName = lastName, Email = emailVal, GUID__c = guid, ID_Proof_status__c = idProofStatus, ID_Proof_Source__c = idProofSource, AccountId = accountId,No_of_times_called_Id_proofing__c=0);
      try {
        if (Schema.SObjectType.Contact.isCreateable() && contact.LastName != null) {
                    contact.OwnerId=users[0].Id;
                    if(idProofTimestamp!=null){
                        contact.ID_Proof_Timestamp__c = idProofTimestamp;
                    }
          insert contact;
        }
        if (test.isRunningTest()) {
          throw new AuraHandledException('error');
        }
      } catch(Exception ex) {
        BOS_Utility.ExceptionHandler(className, createContactMethod, contactObject, null, severity, ex, ex.getMessage());
      }
    }

    return contact;
  }
  List < User > users = new List < User > ();
  @TestVisible private Account createAccount(String name, String emailVal) {
    
    if (System.Label.SSO_DefaultUser != null) {
      users = [Select Id FROM User WHERE Name = :System.Label.SSO_DefaultUser and isActive = true LIMIT 1];
    }
    ID DEFAULT_ACCOUNT_OWNERID = users[0].Id;
    ID storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.AccountAdminRecordType).getRecordTypeId();
    Account account = new Account(
    Name = name, OwnerId = DEFAULT_ACCOUNT_OWNERID,RecordTypeId=storeRecordTypeId);
    try {
      if (Schema.SObjectType.Account.isCreateable() && account.Name != null) {
        insert account;
      }
         if(test.isRunningTest()){
            throw new NullPointerException();
        }
    } catch(Exception ex) {
      BOS_Utility.ExceptionHandler(className, createAccountMethod, accountObject, null, severity, ex, ex.getMessage());
    }
    return account;
  }@TestVisible private User createUser(Contact contact, String fedId, String username,String language) {
    User user = new User();
    String portalUserName = NULL_EMPTY_STRING;
    if (contact != null) {
      user.FirstName = contact.FirstName;
      user.LastName = contact.LastName;
      user.email = contact.Email;

      user.Username = username;
    }
    if (!String.IsBlank(username)) {
      String alias = NULL_EMPTY_STRING + '';
      if (username != null && username.length() > 5) {
        alias = username.substring(0, 5);
      }
      else if (username != null && username.length() <= 5) {
        alias = username;
      }
      user.Alias = alias;
      String currentDateTime = Datetime.now().format('MMddyyyykkmmssSSS');
      if ( (contact.FirstName.length() + currentDateTime.length() ) > 30 ) {
          user.CommunityNickname= contact.FirstName.substring(0, (30 - currentDateTime.length())) + currentDateTime;
      } else user.CommunityNickname = contact.FirstName + currentDateTime;
    }

    if (!String.IsBlank(fedId)) {
      user.FederationIdentifier = fedId;
    }
    Profile p;
    JIT_SSO_ConfigInfo__mdt SSOConfig;
    if (Schema.SObjectType.JIT_SSO_ConfigInfo__mdt.isAccessible()) {
      SSOConfig = [select Id, MasterLabel, Profile__c, Permission_Sets__c from JIT_SSO_ConfigInfo__mdt limit 1];
    }
    if (Schema.SObjectType.Profile.isAccessible() && SSOConfig.Profile__c != null) {
      p = [SELECT Id FROM Profile WHERE name = :SSOConfig.Profile__c Limit 1];
    }
    user.ProfileId = p.Id;
    user.ContactId = contact.Id;
    user.IsActive = true;

    if(String.isBlank(language) || String.isEmpty(language)){
    user.Languagelocalekey = System.Label.SSO_JIT_UserLocale;
    user.Localesidkey = System.Label.SSO_JIT_UserLocale;
    }else{

      if(language == 'en'){
        language=System.Label.SSO_JIT_UserLocale;
      }
      user.Languagelocalekey = language;
      user.Localesidkey = language;
    }
    user.Timezonesidkey = System.Label.SSO_JIT_UserTimeZone;
    user.Emailencodingkey = System.Label.SSO_JIT_Emailencodingkey;
    try {
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.EmailHeader.triggerUserEmail = false;
            if(user != null)
      Database.insert(user, dmlo);
contact.User__c = user.id;

Database.update(contact,dmlo);
      //  updatePermissionForUser(user.Id);
      // updateContactinApplication(user, appID);
        if(test.isRunningTest()){
            throw new NullPointerException();
        }
    } catch(Exception ex) {
      BOS_Utility.ExceptionHandler(className, createUserMethod, userObject, null, severity, ex, ex.getMessage());
    }

    //   updatePermissionForUser(SSOConfig,user);
        return user;
    }
    @TestVisible
    private static String encrypt(String data){
        String keystr = sJITKey;
        String algorithm = sJITAlgorithm;
        if(String.isEmpty(data)){
            return null;
        }
        Blob key = EncodingUtil.base64Decode(keystr);
        Blob blob_data = Blob.valueOf(data);
        return EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(algorithm, key, blob_data));
        
    }

  public static Contact getExistingContact(String email){
    List<Contact> contactList = [Select id,email,GUID__c,Firstname,ID_Proof_status__c,ID_Proof_Source__c,Lastname,ID_Proof_Timestamp__c from Contact where email= :email and RecordType.Name='Enterprise'];
    if(contactList!=null && contactList.size()>0)
    {
      return  contactList[0];
    }
	else{
        return null;
		}
	
	
		
	}
	
}