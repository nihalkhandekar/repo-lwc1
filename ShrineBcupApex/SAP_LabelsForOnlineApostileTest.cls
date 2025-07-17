@IsTest
private class SAP_LabelsForOnlineApostileTest {
    
    @IsTest
    static void testGetLabels() {
        // Prepare mock JSON data
        String mockJson = '{"label1": "Value1", "label2": "Value2"}';

        // Create a Static Resource record (not actually insertable in a test)
        StaticResource mockResource = new StaticResource(
            Name = 'EnglishLabel',
            Body = Blob.valueOf(mockJson)
        );

        // Use @TestVisible to mock SOQL (if applicable) or use Test.loadData (not available for StaticResource)
        Test.startTest();
        Map<String, Object> labels = SAP_LabelsForOnlineApostile.GetLabels();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, labels, 'Labels map should not be null');
        System.assertEquals(2, labels.size(), 'Labels map should have two entries');
          }
}