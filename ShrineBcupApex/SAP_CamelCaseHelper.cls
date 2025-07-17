public class SAP_CamelCaseHelper {

    // This method processes all text fields of the records and converts them to capital case
    public static void convertTextFieldsToCamelCase(List<SObject> records) {
        if (records.isEmpty()) return;  // If no records, exit early
        
        // Get the object type dynamically from the first record
        SObjectType objType = records[0].getSObjectType();
        
        // Get the field descriptions for the object
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        // Iterate over each record in the list
        for (SObject record : records) {
            // Iterate through each field of the object
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                
                // Check if the field is of type Text (String)
                if (fieldDescribe.getType() == Schema.DisplayType.String && !fieldDescribe.isCalculated() && fieldDescribe.isUpdateable() && fieldName!='SAP_Sequence_Number__c') {
                    // Get the current value of the text field
                    String fieldValue = (String) record.get(fieldName);
                    
                    // If the field has a value, convert it to capital case
                    if (!String.isBlank(fieldValue)) {
                        String capitalCaseValue = convertToCapitalCase(fieldValue);
                        // Assign the capital-cased value back to the record field
                        record.put(fieldName, capitalCaseValue);
                    }
                }
            }
        }
    }
    
    // Method to convert a string to capital case
    private static String convertToCapitalCase(String input) {
        if (String.isBlank(input)) return input;

        // Split the input string into words based on spaces
        String[] words = input.split(' ');

        // Initialize a new string for the capital case result
        String result = '';

        // Loop through each word and capitalize the first letter
        for (String word : words) {
            if (!String.isBlank(word)) {
                result += word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase() + ' ';
            } else {
                result += ' ';  // Preserve multiple spaces between words
            }
        }

        // Return the capital-cased result, trimming the extra space at the end
        return result.trim();
    }
}