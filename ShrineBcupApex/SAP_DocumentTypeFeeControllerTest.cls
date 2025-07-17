@IsTest
public class SAP_DocumentTypeFeeControllerTest {
    
     @IsTest
    static void testGetDocumentTypesAndFees(){
        
        Test.startTest();
        List<SAP_DocumentTypeAndFee__mdt> feeRecords = SAP_DocumentTypeFeeController.getDocumentTypesAndFees();
        Test.stopTest();
        
        // Assert that the retrieved records are not empty (assuming CMDT records exist)
        System.assertNotEquals(0, feeRecords.size(), 'Fee records should not be empty');
         
    }
    
     @IsTest
    static void testGetCountryHagueMappings(){
        
        Test.startTest();
        List<SAP_Country_Hague_Mapping__mdt> mappingRecords = SAP_DocumentTypeFeeController.getCountryHagueMappings();
        Test.stopTest();
        
        // Assert that the retrieved records are not empty (assuming CMDT records exist)
        System.assertNotEquals(0, mappingRecords.size(), 'Mapping records should not be empty');
        
        
    }
}