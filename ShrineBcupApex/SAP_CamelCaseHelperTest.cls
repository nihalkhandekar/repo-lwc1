@isTest
public class SAP_CamelCaseHelperTest {
    
    @isTest
    public static void testConvertTextFieldsToCamelCase() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        System.debug('licenseType: ' + licenseType);

   
        IndividualApplication indApp = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_Sequence_Number__c = 'SEQ123', 
            SAP_First_Name__c = 'john', 
            SAP_Last_Name__c = 'doe', 
            Category = 'license',
            Description = 'this is a test',
            SAP_Adopt_Apostille__c = 'apostille example',
            SAP_Adopt_Authentication__c = 'authentication example',
            SAP_Cert_Dep__c = 'certificate department'
        );
        insert indApp;

        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('IndividualApplication').getDescribe().fields.getMap();
        List<String> textFields = new List<String>();

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.String) {
                textFields.add(fieldName);
            }
        }

       
        if (!textFields.contains('Category')) {
            textFields.add('Category');
        }

        
        String query = 'SELECT Id, ' + String.join(textFields, ', ') + ' FROM IndividualApplication WHERE Id = \'' + indApp.Id + '\'';


       
        IndividualApplication indAppRecord = (IndividualApplication) Database.query(query);

        
        List<SObject> records = new List<SObject>{indAppRecord};

        
        SAP_CamelCaseHelper.convertTextFieldsToCamelCase(records);

       
        update records;

        
        IndividualApplication updatedIndApp = (IndividualApplication) Database.query(query);
        
        System.assert(
                 updatedIndApp.SAP_First_Name__c == 'John' &&
                 updatedIndApp.SAP_Last_Name__c == 'Doe' &&
                 updatedIndApp.Category == 'License',
                'Text fields should be converted to capital case correctly'
        );

        
    }
}