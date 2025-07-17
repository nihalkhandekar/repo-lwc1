/**
 * @desc    : All utility methods for schema class
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------------------------
 * Shreya Bordia                    26/08/2020                         CTBOS-3650 | Changes in English flow must be reflected to other lang
 **/

public with sharing class SchemaUtility {
    private static final String SPACE = ' ';

    //get object schema
    public static Schema.DescribeSObjectResult getObject(String objName) {
        return Schema.getGlobalDescribe().get(objName).getDescribe();
    }

    public static Map<String, Id> getRecordTypes(String objName) {
        Map<String, Id> mapRecordTypes = new Map<String, Id>();

        for(Schema.RecordTypeInfo recordType :getObject(objName).getRecordTypeInfos()) {
            mapRecordTypes.put(recordType.getDeveloperName(), recordType.getRecordTypeId());
        }

        return mapRecordTypes;
    }

    //record recordtype id from object & record type name
    public static Id getRecordTypeId(String objName, String recordTypeName) {
        return getObject(objName).getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    //get object api name from it's recordId
    public static Schema.DescribeSObjectResult getObjectFromId(Id recordId) {
        return recordId.getSObjectType().getDescribe();
    }

    public static Schema.DescribeSObjectResult getObjectFromId(sObject record) {
        return record.getSObjectType().getDescribe();
    }

    public static sObject getGenericRecord(String objName) {
        return Schema.getGlobalDescribe().get(objName).newSObject();
    }

    //get map<ApiName, Label> for all fields for an obj
    public static Map<String, String> getFields(String objName) {
        Map<String, String> mapFields = new Map<String, String>();

        for(Schema.SObjectField fld :getObject(objName).fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();

            mapFields.put(field.getName(), field.getLabel());
        }

        return mapFields;
    }

    public static Map<String, Schema.DescribeFieldResult> getCustomNonTextFields(Schema.DescribeSObjectResult obj) {
        Map<String, Schema.DescribeFieldResult> mapFieldSchema = new Map<String, Schema.DescribeFieldResult>();

        for(Schema.SObjectField fld : obj.fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();

            //No text, textarea, formula or reference
            if(field.isCustom() && Schema.DisplayType.String != field.getType() && Schema.DisplayType.TextArea != field.getType() && !field.isCalculated()) {
                mapFieldSchema.put(field.getName(), field);
            }
        }

        return mapFieldSchema;
    }

    public static Map<String, Schema.DescribeFieldResult> getCustomTextFields(Schema.DescribeSObjectResult obj) {
        Map<String, Schema.DescribeFieldResult> mapFieldSchema = new Map<String, Schema.DescribeFieldResult>();

        for(Schema.SObjectField fld : obj.fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();

            //No standard, formula or external ID fields
            //CTBOS-3650 | Do not get KEYWORDS field
            if(field.isCustom() && !field.isCalculated() && !field.isExternalID() && field.getName() != TranslateTriggerHelper.KEYWORDS
                && (Schema.DisplayType.String == field.getType() || Schema.DisplayType.TextArea == field.getType())) {
                mapFieldSchema.put(field.getName(), field);
            }
        }

        return mapFieldSchema;
    }

    public static Map<String, Schema.DescribeFieldResult> getCustomLookupFields(Schema.DescribeSObjectResult obj) {
        Map<String, Schema.DescribeFieldResult> mapFieldSchema = new Map<String, Schema.DescribeFieldResult>();

        for(Schema.SObjectField fld : obj.fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();

            //No standard, formula or external ID fields
            if(field.isCustom() && Schema.DisplayType.Reference == field.getType()) {
                mapFieldSchema.put(field.getName(), field);
            }
        }

        return mapFieldSchema;
    }

    //Get field details for a field
    public static Schema.DescribeFieldResult getField(String objName, String fieldName) {
        return getObject(objName).fields.getMap().get(fieldName).getDescribe();
    }

    //if picklist field, get map<Api, Label> of all picklist values
    public static Map<String, String> getPicklistValues(String objName, String fieldName) {
        Map<String, String> mapPicklistValues = new Map<String, String>();

        for(Schema.PicklistEntry field :getField(objName, fieldName).getPicklistValues()) {
            mapPicklistValues.put(field.getValue(), field.getLabel());
        }

        return mapPicklistValues;
    }

    public static String getAllFieldsQuery(String objName) {
        return System.Label.SELECT + SPACE + String.join(new List<String>(getFields(objName).keySet()), ',') + SPACE
            + System.Label.FROM + SPACE + objName + SPACE;
    }
}