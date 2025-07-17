@isTest
public class BosAccCOVIDGuidelineLWCControllerTest {
    @isTest
    public static void getPicklistValue(){
        sObject bosReopen  = new Business_Reopen_Certification__c();
        List<BosAccCOVIDGuidelineLWCController.FatchValueWrapper> fatchWrapperList = new List<BosAccCOVIDGuidelineLWCController.FatchValueWrapper>();
        List<String> fieldApiName = new List<String>{'Business_Type__c','Business_Address_County__c'};
        test.starttest();
        fatchWrapperList = BosAccCOVIDGuidelineLWCController.fatchPickListValue(bosReopen,fieldApiName);
        test.stoptest();
    } 
    @isTest
    public static void createBusinessReopenCertificationRecord(){
        EmailTemplate emTemp = BRS_TestDataFactory.createEmailTemplate();
          User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
           Subscription__c subs = BRS_TestDataFactory.createSubscription();
        Business_Reopen_Certification__c busreCert = BRS_TestDataFactory.createBusinessReopenCertification();
        }
       
        BosAccCOVIDGuidelineLWCController.ResponseWrapper response= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        BosAccCOVIDGuidelineLWCController.ResponseWrapper responseBothUpdate= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        BosAccCOVIDGuidelineLWCController.ResponseWrapper responseEmailUpdate= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        BosAccCOVIDGuidelineLWCController.ResponseWrapper responsePhoneUpdate= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        BosAccCOVIDGuidelineLWCController.ResponseWrapper responseCatchBlock= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        String record ='{"Sector__c":"Amusement Parks","Business_Type__c":"Construction","Email_Address__c":"testClass@gmail.com","Contact_Phone_Number_1__c":"2323232323","Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User","Date__c":"2019-06-27"}';
		String recordBothUpdate ='{"Sector__c":"Restaurants","Business_Type__c":"Construction","Email_Address__c":"testClass@gmail.com","Contact_Phone_Number_1__c":"2323232323","Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User","Date__c":"2019-07-27"}';
        String recordEmailUpdate ='{"Sector__c":"Offices","Business_Type__c":"Construction","Email_Address__c":"testClass123@gmail.com","Contact_Phone_Number_1__c":"2323232323","Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User","Date__c":"2019-06-27"}';
        String recordPhoneUpdate ='{"Sector__c":"Libraries","Business_Type__c":"Construction","Email_Address__c":"testClass123@gmail.com","Contact_Phone_Number_1__c":"3444222324","Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User","Date__c":"2019-06-27"}';
        String recordCatchBlock ='{"Business_Name__c":"test","Representative_First_Name__c":"Test","Representative_last_Name__c":"User"}';
        test.starttest();
        System.RunAs(usr){
        response = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(record,true);
        responseBothUpdate = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(recordBothUpdate,true);
        responseEmailUpdate = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(recordEmailUpdate,true);
        responsePhoneUpdate = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(recordPhoneUpdate,true);
        responseCatchBlock = BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord(recordCatchBlock,true);
        }
        test.stoptest();
    }
    @isTest
    public static void getSectorPdfLink(){
        COVID_Sector__mdt sectorMdt = new COVID_Sector__mdt(developername='test',masterlabel='test',pdf_link__c='https://google.com');
        //insert sectorMdt;
        test.starttest();
        Map<String,String> sectorMap = BosAccCOVIDGuidelineLWCController.getSector('en_US');
        test.stoptest();
    }
     @isTest
    public static void createFeedbackRecord(){
        BosAccCOVIDGuidelineLWCController.ResponseWrapper response= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        BosAccCOVIDGuidelineLWCController.ResponseWrapper responseCatchBlock= new BosAccCOVIDGuidelineLWCController.ResponseWrapper();
        String record ='{"Your_business_industry__c":"Construction","Your_business_sector__c":"Amusement Parks","safety_guidelines_complete__c":"Yes","Feedback__c":"Construction","Business_Name__c":"test"}';
        String recordCatchBlock ='{"Your_business_industry__c":"Construction","Your_business_sector__c":"Amusement Parks","safety_guidelines_complete__c":"true","Feedback__c":"Construction","Business_Name__c":"test"}';
        test.starttest();
        response = BosAccCOVIDGuidelineLWCController.createFeedbackRecord(record);
        responseCatchBlock = BosAccCOVIDGuidelineLWCController.createFeedbackRecord(recordCatchBlock);
        test.stoptest();
    } 
    
}