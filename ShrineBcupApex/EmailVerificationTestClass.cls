@isTest
public class EmailVerificationTestClass {
	@isTest
    public static void checkEmailVerification(){
        subscriptionUtilityTest testData = new subscriptionUtilityTest();
        testData.Business_Industry = 'Construction';        
        testData.Email = 'testClass@gmail.com';
        testData.Phone = '2323232323';
        testData.Email_Verified = false;
        testData.Subscription_Status = 'Pending Verification';
        testData.Signup_Date = system.today()-10;
        testData.Language = 'en_US';
        testData.Attestation_Acknowledgement = true;
        
        subscriptionUtilityTest testDataUpdate = new subscriptionUtilityTest();
        testDataUpdate.Business_Industry = 'Construction;Information';        
        testDataUpdate.Email = 'testClass@gmail.com';
        testDataUpdate.Phone = '2323232323';
        testDataUpdate.Email_Verified = true;
        testDataUpdate.Subscription_Status = 'Active';
        testDataUpdate.Signup_Date = system.today();        
        testDataUpdate.Language = 'en_US';
        testDataUpdate.Attestation_Acknowledgement = true;        
        
        subscriptionUtilityTest testDataSpanish = new subscriptionUtilityTest();
        testDataSpanish.Business_Industry = 'Utilities';        
        testDataSpanish.Email = 'testClass123@gmail.com';
        testDataSpanish.Phone = '1212121212';
        testDataSpanish.Email_Verified = false;
        testDataSpanish.Subscription_Status = 'Pending Verification';
        testDataSpanish.Signup_Date = system.today();        
        testDataSpanish.Language = 'es';
        testDataSpanish.Attestation_Acknowledgement = true;
        
        subscriptionUtilityTest testDataSpanishUpdate = new subscriptionUtilityTest();
        testDataSpanishUpdate.Business_Industry = 'Utilities;Wholesale Trade';        
        testDataSpanishUpdate.Email = 'testClass123@gmail.com';
        testDataSpanishUpdate.Phone = '1212121212';
        testDataSpanishUpdate.Language = 'es';
        testDataSpanishUpdate.Attestation_Acknowledgement = true;
        
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
        EmailTemplate emTemp = BRS_TestDataFactory.createEmailTemplate();
        EmailTemplate emTempspanish = BRS_TestDataFactory.createEmailTemplateSpanish();   
        }
        
        test.startTest();
        
        Subscription__c subObj = testData.createTestRecord();
        EmailVerificationServiceCls.ResponseWrapper resEmailVerification = EmailVerificationServiceCls.generateVerificationLink(EmailVerificationServiceCls.getSuscriptionRecord(null,subObj.Email__c.toLowerCase()));
        List<String> paramList = (resEmailVerification.url).split('id=');
        String param = paramList[paramList.size()-1];
        EmailVerificationServiceCls.retriveURLParam(param);
        recovery_EMailVerificationController.retrieveVerificationStatus(param);
                
        Subscription__c subObjUpdate = testDataUpdate.createTestRecord();
        EmailVerificationServiceCls.ResponseWrapper resEmailVerificationUpdate = EmailVerificationServiceCls.generateVerificationLink(EmailVerificationServiceCls.getSuscriptionRecord(null,subObjUpdate.Email__c.toLowerCase()));
                
        Subscription__c subObjSpanish = testDataSpanish.createTestRecord();
        EmailVerificationServiceCls.ResponseWrapper resEmailVerificationSpanish = EmailVerificationServiceCls.generateVerificationLink(EmailVerificationServiceCls.getSuscriptionRecord(null,subObjSpanish.Email__c.toLowerCase()));
        List<String> paramListSpanish= (resEmailVerificationSpanish.url).split('id=');
        String paramSpanish = paramListSpanish[paramListSpanish.size()-1];
        paramSpanish = paramSpanish + 'test'; 
        EmailVerificationServiceCls.retriveURLParam(paramSpanish);
        recovery_EMailVerificationController.retrieveVerificationStatus(paramSpanish);
                
      	Subscription__c subObjSpanishUpdate = testDataSpanishUpdate.createTestRecord();
        EmailVerificationServiceCls.ResponseWrapper resEmailVerificationSpanishUpdate = EmailVerificationServiceCls.generateVerificationLink(EmailVerificationServiceCls.getSuscriptionRecord(null,subObjSpanishUpdate.Email__c.toLowerCase()));
        List<String> paramListSpanishUpdate= (resEmailVerificationSpanishUpdate.url).split('id=');
        String paramSpanishUpdate = paramListSpanishUpdate[paramListSpanishUpdate.size()-1];
        EmailVerificationServiceCls.retriveURLParam(paramSpanishUpdate);
        subObjSpanishUpdate.Subscription_Status__c = 'Active';
        update subObjSpanishUpdate;
        EmailVerificationServiceCls.retriveURLParam(paramSpanishUpdate);
        test.stopTest();
    }
}