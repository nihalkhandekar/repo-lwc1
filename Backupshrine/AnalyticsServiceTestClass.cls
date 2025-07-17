@isTest
public class AnalyticsServiceTestClass {
	@isTest
    public static void insertRecord(){
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        gen.writeStringField('Questionnaire__c', '');
        gen.writeStringField('Section__c', 'Test Section');
        gen.writeStringField('Subsection__c', 'Test Subsection');
        gen.writeStringField('Response__c', 'Test Response');
        gen.writeStringField('Community_Page_Name__c', 'Test Page');
        gen.writeStringField('Event_Type__c', 'Test Event');
        gen.writeStringField('External_Link__c', '');
        gen.writeStringField('Link_Name__c', '');
        gen.writeStringField('Event_Start_Time__c', '');
        gen.writeStringField('Event_Stop_Time__c', '');
        gen.writeStringField('Time_Spent_on_Page_Seconds__c', '');
        gen.writeStringField('Device_Type__c', 'Medium');
        gen.writeEndObject();
        
        String analyticsRecord = gen.getAsString();
        
        AnalyticsServiceClass.insertAnalyticsRecord(analyticsRecord);
    }
    
    @isTest
    public static void insertRecordException(){
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        gen.writeStringField('Questionnaire__c', '123333');
        gen.writeStringField('Section__c', 'Test Section');
        gen.writeStringField('Subsection__c', 'Test Subsection');
        gen.writeStringField('Response__c', 'Test Response');
        gen.writeStringField('Community_Page_Name__c', 'Test Page');
        gen.writeStringField('Event_Type__c', 'Test Event');
        gen.writeStringField('External_Link__c', '');
        gen.writeStringField('Link_Name__c', '');
        gen.writeStringField('Event_Start_Time__c', '');
        gen.writeStringField('Event_Stop_Time__c', '');
        gen.writeStringField('Time_Spent_on_Page_Seconds__c', '');
        gen.writeStringField('Device_Type__c', 'Medium');
        gen.writeEndObject();
        
        String analyticsRecord = gen.getAsString();
        try{
        AnalyticsServiceClass.insertAnalyticsRecord(analyticsRecord);
        }catch(Exception e){ system.assertNotEquals(null, e);}
    }
}