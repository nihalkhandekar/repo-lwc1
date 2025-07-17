public class SAP_LabelsForOnlineApostile {
     @AuraEnabled
    public static Map<String, Object> GetLabels(){
        // Fetch the static resource
        StaticResource labels = [SELECT Id, Body FROM StaticResource WHERE Name = 'EnglishLabel' WITH SECURITY_ENFORCED LIMIT 1]; 
        
        // Convert the body to a string
        String body = labels.Body.toString();
        
        // Option 1: Deserialize to a generic Map<String, Object>
        Map<String, Object> JsonData = (Map<String, Object>) JSON.deserializeUntyped(body);
        
        // Option 2: Deserialize to a typed object (if you have a class to map the structure)
        // MyLabelClass JsonData = (MyLabelClass) JSON.deserialize(body, MyLabelClass.class);
        
        // Debug the parsed JSON
        system.debug('Body String: ' + body);
        system.debug('Parsed JSON: ' + JsonData);
        
        // Return the parsed JSON data
        return JsonData;
    }    
}