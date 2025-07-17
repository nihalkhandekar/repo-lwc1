public with sharing class BRS_SecurityUtility {
    
    public static Boolean checkDMLAccess(List<SObject> lstForUpdate, String sAction) {
        Map<String, Object> fieldsToValue = new Map<String, Object>();
        if(!lstForUpdate.isEmpty()){
            fieldsToValue = lstForUpdate[0].getPopulatedFieldsAsMap();
            Map<String, SObjectField> fields = new Map<String, SObjectField>();
            List<String> lstFieldNamesInDmlList = new List<String>();
            List<String> lstOfNoAccessFields = new List<String>();
            if(!fieldsToValue.isEmpty())
            lstFieldNamesInDmlList.addAll(fieldsToValue.keySet());
            Schema.SObjectType objType = lstForUpdate.get(0).getSObjectType();
            Schema.DescribeSObjectResult objectDescription = objType.getDescribe();
            String objName = objectDescription.getName();
            fields = objType.getDescribe().fields.getMap();
            switch on sAction {
                when 'update'
                {
                  // Strip fields that are not updateable by user and stored it to map objUpdateDecision.getRemovedFields().
                   //object acces will be check by SObjectAccessDecision itself 
                    SObjectAccessDecision objUpdateDecision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        lstForUpdate);
                        if (!objUpdateDecision.getRemovedFields().isEmpty() && objUpdateDecision.getRemovedFields().get(objName)!= Null){
                            lstOfNoAccessFields.addAll(objUpdateDecision.getRemovedFields().get(objName));
                            checkFieldAccess(fields, 'update', objName, lstFieldNamesInDmlList, lstOfNoAccessFields);
                        }
                }
                when 'insert' {
                    // Strip fields that are not creatable by user and stored it to map objInsertDecision.getRemovedFields().
                    //object acces will be check by SObjectAccessDecision itself 
                    SObjectAccessDecision objInsertDecision = Security.stripInaccessible(
                        AccessType.CREATABLE,
                        lstForUpdate);
                        if (!objInsertDecision.getRemovedFields().isEmpty() && objInsertDecision.getRemovedFields().get(objName)!= Null){
                            lstOfNoAccessFields.addAll(objInsertDecision.getRemovedFields().get(objName));
                            checkFieldAccess(fields, 'insert', objName, lstFieldNamesInDmlList, lstOfNoAccessFields);
                        }
                        //
                }
                when 'upsert'  {
                    SObjectAccessDecision objInsertDecision = Security.stripInaccessible(
                        AccessType.CREATABLE,
                        lstForUpdate);

                        if (!objInsertDecision.getRemovedFields().isEmpty() && objInsertDecision.getRemovedFields().get(objName)!= Null){
                            lstOfNoAccessFields.addAll(objInsertDecision.getRemovedFields().get(objName));
                           
                        }
                        SObjectAccessDecision objUpdateDecision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        lstForUpdate);

                        if (!objUpdateDecision.getRemovedFields().isEmpty() && objUpdateDecision.getRemovedFields().get(objName)!= Null){
                            lstOfNoAccessFields.addAll(objUpdateDecision.getRemovedFields().get(objName));
                        }
                        if(!lstOfNoAccessFields.isEmpty()){
                            checkFieldAccess(fields, 'Upsert', objName, lstFieldNamesInDmlList, lstOfNoAccessFields);
                        }

                }
                when 'delete'   {
                    if(!objectDescription.isDeletable()){
                        throwException('DELETE', objName, '');
                    }
                }
            }
                
            
        }
    
    return true;
    }

    public static void checkFieldAccess(Map<String, SObjectField> fields, String sAction, String objName, 
                                        List<String> lstFieldNamesInDmlList, List<String> lstOfNoAccessFields){
        DescribeFieldResult fieldDescribe;
        for(String sFieldName : lstOfNoAccessFields){
            if(lstFieldNamesInDmlList.contains(sFieldName)){
                fieldDescribe = fields.get(sFieldName).getDescribe();
                if(fieldDescribe.isPermissionable() && !fieldDescribe.isCalculated() && !fieldDescribe.isAutoNumber()) {
                    throwException(sAction, objName, sFieldName);
                }
            }   
        }
    }

    public static void throwException(String sAction, String sObjName, String sFldName) {
        String sFirstName = UserInfo.getFirstName(); 
        String sLastName = UserInfo.getLastName();
        String sError = 'Exception Occurred as ' + sFirstName+' '+sLastName+ ' does not have ' + sAction;
        sError += ' access to the ';
        if(String.isNotBlank(sFldName)) {
            sError += 'Field: ' + sFldName + ' in the Object: ' + sObjName;
        }
        else   {
            sError += 'Object: ' + sObjName;
        }
        AuraHandledException e = new AuraHandledException(sError);
        e.setMessage(sError);
        throw e;
    } 
}