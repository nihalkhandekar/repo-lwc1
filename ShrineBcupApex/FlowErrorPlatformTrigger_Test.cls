@isTest
public class FlowErrorPlatformTrigger_Test {
    @isTest static void testValidEvent() {
        Flow_Error_Handling__e Event = new Flow_Error_Handling__e(Component_Name__c ='MN-123', 
                                             Error_Message__c ='test', 
                                             Object_Name__c='Account');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(Event);
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess());
      }
}