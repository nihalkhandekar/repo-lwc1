@isTest
public class FormattedDateTimeController_Test {
    testmethod static void test1(){
        FormattedDateTimeController fd = new FormattedDateTimeController();
        test.startTest();
        fd.getFormattedDatetime();
        test.stopTest();
    }
    
    testmethod static void test2(){
        FormattedDateTimeController fd = new FormattedDateTimeController();
        test.startTest();
        fd.valueToFormat= System.Now();
        fd.getFormattedDatetime();
        test.stopTest();
    }
    
    testmethod static void test3(){
        FormattedDateTimeController fd = new FormattedDateTimeController();
        test.startTest();
        fd.valueToFormat=System.now();
        fd.definedFormat='MM/dd/yyyy h:mm a';
        fd.definedTimeZone='America/New_York';
        fd.getFormattedDatetime();
        test.stopTest();
    }
}