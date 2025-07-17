@isTest
public class FinsysExcelController_Test {
    @isTest
    static void testAgingReport() {
        String jsonInput = '{"Name": "Doe", "Date": "' + Date.today().format() + '"}';
        Test.startTest();
        // List<Map<String, Object>> result = FinsysExcelController.agingReport('');
        // List<Map<String, Object>> result1 = FinsysExcelController.agingReport(jsonInput);
        Test.stopTest();
    }
}