@isTest
public class CTBOT_TestDataFactory {

    public static List<Knowledge__kav> createArticles(Integer numArticles){

        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<Knowledge__kav> insertedArticles = new List<Knowledge__kav>();
        List<Id> fixedSearchResults = new List<Id>();

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i, URLName = 'Apex-Test-URLName-' + i); 
            articles.add(k);
        }
        insert articles;
        for(Knowledge__kav kba : articles){
            fixedSearchResults.add(kba.Id);
        }
        insertedArticles = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE ID IN :articles];
        publishTestArticles(insertedArticles);

        Test.setFixedSearchResults(fixedSearchResults);
        return articles;

    }

    public static List<Knowledge__kav> createArticlesWithDialogTags(Integer numArticles){

        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<Knowledge__kav> insertedArticles = new List<Knowledge__kav>();
        List<Id> fixedSearchResults = new List<Id>();

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i, URLName = 'Apex-Test-URLName-' + i, DialogTag__c = 'Apex Test Dialog Tag'); 
            articles.add(k);
        }

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i + 'addtl', URLName = 'Apex-Test-URLName-' + i + 'addtl', DialogTag__c = 'Another dialog tag'); 
            articles.add(k);
        }
        insert articles;
        for(Knowledge__kav kba : articles){
            fixedSearchResults.add(kba.Id);
        }
        insertedArticles = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE ID IN :articles];
        publishTestArticles(insertedArticles);

        Test.setFixedSearchResults(fixedSearchResults);
        return articles;

    }

    public static List<Knowledge__kav> createArticlesWithRelatedArticleTags(Integer numArticles){

        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<Knowledge__kav> insertedArticles = new List<Knowledge__kav>();
        List<Id> fixedSearchResults = new List<Id>();

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i, URLName = 'Apex-Test-URLName-' + i, DialogTag__c = 'Apex Test Dialog Tag'); 
            articles.add(k);
        }

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i + 'addtl', URLName = 'Apex-Test-URLName-' + i + 'addtl', DialogTag__c = 'Apex Test ' + i); 
            articles.add(k);
        }
        insert articles;
        for(Knowledge__kav kba : articles){
            fixedSearchResults.add(kba.Id);
        }
        insertedArticles = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE ID IN :articles];
        publishTestArticles(insertedArticles);

        Test.setFixedSearchResults(fixedSearchResults);
        return articles;

    }

    public static List<Knowledge__kav> createGetSupportArticles(Integer numArticles){

        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<Knowledge__kav> insertedArticles = new List<Knowledge__kav>();
        List<Id> fixedSearchResults = new List<Id>();

        for(Integer i=0; i < numArticles; i++) {
            Knowledge__kav k = new Knowledge__kav(Title='Apex Test ' + i, URLName = 'Apex-Test-URLName-' + i); 
            articles.add(k);
        }

        Knowledge__kav kSupport = new Knowledge__kav(Title='Get Support TEST', URLName = 'Apex-Test-URLName-GetSupport');
        
        insert articles;
        for(Knowledge__kav kba : articles){
            fixedSearchResults.add(kba.Id);
        }
        insertedArticles = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE ID IN :articles];
        publishTestArticles(insertedArticles);

        Test.setFixedSearchResults(fixedSearchResults);
        return articles;

    }

    public static String createTestChatTranscript(String originationURL){
        LiveChatVisitor visitor = new LiveChatVisitor();
        
        insert visitor;

        LiveChatTranscript tx = new LiveChatTranscript(
            chatKey = 'TEST' + String.valueOf(Integer.valueOf(math.rint(math.random()*1000000))),
            liveChatVisitorId = visitor.id,
            Origination__c = originationURL
        );
        
        insert tx;

        String chatKey = [SELECT Id, ChatKey FROM LiveChatTranscript WHERE Id = :tx.Id].ChatKey;
        
        return chatKey;
    }

    public static List<Account> createAccounts(Integer numberOfAccts, List<Integer> annualReportDaysFromNow, String status, Boolean doInsert) {

        List<Account> acctList = new List<Account>();
        for (Integer i = 0; i < numberOfAccts; i++) {
            Integer annualReportDueDate = annualReportDaysFromNow.get(Math.mod(i, annualReportDaysFromNow.size()));
            Account testAccount = new Account(
                Name = 'Test Account ' + i,
                Citizenship__c = 'Domestic',
                Business_Type__c = 'LLC',
                Status__c = status,
                Annual_Report_Due_Date__c = Date.today().addDays(annualReportDueDate),
                BillingStreet = 'Test St. ' + i,
                BillingCity = 'Test City',
                BillingCountry = 'USA',
                BillingState = 'CT',
                BillingPostalCode = '1234' + i,
                ShippingStreet = 'Test St.',
                ShippingCity = 'Test City',
                ShippingCountry = 'USA',
                ShippingState = 'CT',
                ShippingPostalCode = '1234' + i
            );  
            acctList.add(testAccount);
        }

        if(doInsert && !acctList.isEmpty()){
            insert acctList;
        }
        return acctList;
    }

    public static List<Contact> createContacts(Integer numberOfContacts) {
        System.debug('test');
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact newContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + generateRandomString(5),
                Email = 'test@gmail.com'
            );
            testContacts.add(newContact);
        }
        insert testContacts;
        return testContacts;
    }

    public static List<User> createUsers(Integer numberofUsers, Boolean doInsert){

        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;

        for(Integer i = numberofUsers; i > 0; i--){
            User newUser = new User(
                FirstName = 'Test',
                LastName = 'User' + generateRandomString(5),
                Email = 'test' + generateRandomString(5) + '@domain.com',
                Username = 'test' + generateRandomString(5) + '@domain.com',
                Alias = 't' + generateRandomString(3),
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                ProfileId = profileId,
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                PortalRole = 'Worker',
                IsActive = true,
                CommunityNickname = 'test' + generateRandomString(5) + '@domain.com'
            );

            userList.add(newUser);
        }

        if(doInsert){
            insert userList;
        }

        return userList;
    }

    public static List<Bot_Article_Feedback__c> createBotFeedbackRecords(Integer numberOfRecords) {
        List<Bot_Article_Feedback__c> testFeedbackRecords = new List<Bot_Article_Feedback__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Bot_Article_Feedback__c record = new Bot_Article_Feedback__c();
            record.Chat_Key__c = '123';
            record.Sitecore_ID__c = 'a094eb99-a2fa-4c40-8609-f4c258e0388c';
            record.Value__c = i;
            testFeedbackRecords.add(record);
        }
        return testFeedbackRecords;
    }

    private static void publishTestArticles(List<Knowledge__kav> articles){
        for(Knowledge__kav kba : articles){
            KbManagement.PublishingService.publishArticle(kba.KnowledgeArticleId, true);
        }
    }

    //If you need contacts on your work orders for testing, don't insert.  Instead insert after adding the contacts in the test class.
    public static List<Work_Order__c> createWorkOrders(Integer numberOfWorkOrders, Boolean doInsert){
        
        List<Work_Order__c> workOrdersToInsert = new List<Work_Order__c>();

        for(Integer i = numberOfWorkOrders; i > 0; i--){
            Work_Order__c workOrder = new Work_Order__c();
            workOrder.IsInsufficientPayment__c = false;
            workOrder.IsInsufficientPayment__c = false;
            workOrder.Payments_Verified__c = true;

            workOrdersToInsert.add(workOrder);
        }

        if(doInsert && !workOrdersToInsert.isEmpty()){
            insert workOrdersToInsert;
        }

        return workOrdersToInsert;
    }

    //If you need contacts on your work orders for testing, don't insert.  Instead insert after adding the contacts in the test class.
    public static List<Business_Filing__c> createBusinessFilings(Integer numberOfBusinessFilings, Boolean doInsert, Boolean isExpedited){

        List<Business_Filing__c> businessFilingsToInsert = new List<Business_Filing__c>();

        for(Integer i = numberOfBusinessFilings; i > 0; i--){
            Business_Filing__c businessFiling = new Business_Filing__c();
            businessFiling.Business_Filing_Processed__c = true;
            businessFiling.I_Acknowledge__c = true;
            businessFiling.Include_Expedited_Service__c = isExpedited;
            businessFiling.Is_Rejected_Instantiated__c = false;
            businessFiling.Payment_Acknowledgement__c = false;
            businessFiling.Physical_Filing__c = false;
            businessFiling.ReviewScreenAcknowledgement__c = false;
            businessFiling.Review_Add_Authorizer_Option_Choosen__c = false;
            businessFiling.Review_Select_Principal_Option_Choosen__c = false;
            businessFiling.Self_Nomination_as_Agent__c = false;
            businessFiling.isTempHistoryAgentPresent__c = false;
            businessFiling.isTempHistoryPrincipalPresent__c = false;
            businessFiling.isFromMassAgentChange__c = false;
            businessFiling.isAutoApproved__c = false;
            businessFiling.Batch_Created__c = false;
            businessFiling.Pending_Filing_Status__c = false;

            businessFilingsToInsert.add(businessFiling);
        }

        if(doInsert && !businessFilingsToInsert.isEmpty()){
            insert businessFilingsToInsert;
        }

        return businessFilingsToInsert;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static String createAccount(String accountName){
        Id RecordTypeIdAccount = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'Administrator' LIMIT 1].Id;
        Account account = new Account(Name = accountName,RecordTypeId = RecordTypeIdAccount);
        insert account;
        return String.valueOf(account.Id);
    }
    
    public static String createContact(String contactName,String accountId,Integer randomInt){
        Id RecordTypeIdContact = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Contact' and Name = 'Enterprise' LIMIT 1].Id;
        Contact contact = new Contact(LastName = contactName, AccountId = accountId, Email = 'test' + randomInt + '@community.com', RecordTypeId = RecordTypeIdContact);
        insert contact;
        return String.valueOf(contact.Id);
    }

    public static User createCommunityUsr_PermissionSet(String accountName,String contactName){
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String accountId = createAccount(accountName);
        String contactId = createContact(contactName, accountId, randomInt);

        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        
        User communityUser = new User(
            FirstName = 'Test',
            LastName = contactName,
            email = 'test' + randomInt + '@example.com',
            username = 'test' + randomInt + '@example.com',
            EmailEncodingkey = 'ISO-8859-1',
            Alias = 'test',
            FederationIdentifier = '11111111-aaaa-2222-bbbb-3333333' + randomInt,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = communityUserProfile.Id,
            ContactId = contactId
        );
        insert communityUser;
        
        List<PermissionSet> permissionSetList = [SELECT Id, Label FROM PermissionSet WHERE Name = 'CT_Community_User'];
        if (!permissionSetList.isEmpty()){        
            PermissionSetAssignment permissionSetAssignmentRecord = new PermissionSetAssignment(
                PermissionSetId = permissionSetList[0].id,
                AssigneeId = communityUser.Id
            );
            insert permissionSetAssignmentRecord;
        }
        return communityUser;
    }
}