/* DESCRIPTION: For Nintex template mappings for UCC1 and UCC3
*
* @AUTHOR:  Shreya Bordia
* @DATE:    02/10/2021 
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ------------------------------------------------------------------------------------------------
* Shreya                            02/10/2021                         R6 | UCC1 & UCC3
**************************************************************************************************/
global without sharing class NintexUCCTemplateServices implements Loop.IApexDataSource {
    private String debtorAdd = 'debtorAdd';
    private String debtorUpdate = 'debtorUpdate';
    private String debtorDelete = 'debtorDelete';

    private String securedPartyAdd = 'securedPartyAdd';
    private String securedPartyUpdate = 'securedPartyUpdate';
    private String securedPartyDelete = 'securedPartyDelete';
    
    private static List<String> listDebtorTypes = new List<String>{
        System.Label.BRS_UCC_Debtor_Label, 
        System.Label.BRS_UCC_JudgmentDebtor, 
        System.Label.Review_MasterLabel_Type_Owner, 
        System.Label.BRS_UCC_Defendant_Label
    };
    private static List<String> listSecuredPartyTypes = new List<String>{
        System.Label.BRS_UCC_Secured_Party_Label, 
        System.Label.Judgment_Creditor_Label, 
        System.Label.Review_MasterLabel_Type_Claimant, 
        System.Label.BRS_UCC_Plaintiff_Label
    };

    //to-do
    Map<String, String> mapTypeQuery = new Map<String, String>{
        debtorAdd => ' AND Type__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Add\''
            + ' AND isCloned__c = false',
        debtorUpdate => ' AND Type__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Change Existing\''
            + ' AND UCC_Related_Info__c = null'
            + ' AND isCloned__c = false',
        debtorDelete => ' AND Type__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listDebtorTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Delete Existing\''
            + ' AND Deleted_Flag__c = true',

        
        securedPartyAdd => ' AND Type__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Add\''
            + ' AND isCloned__c = false',
        securedPartyUpdate => ' AND Type__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Change Existing\''
            + ' AND UCC_Related_Info__c = null'
            + ' AND isCloned__c = false',
        securedPartyDelete => ' AND Type__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Entity__c IN :listSecuredPartyTypes'
            + ' AND Filing_Id__r.Amendment_Type__c = \'Amendment\''
            + ' AND Filing_Id__r.Type_of_Update__c = \'Delete Existing\''
            + ' AND Deleted_Flag__c = true'
    };

    /**
     * @desc: Return a set of object/wrapper class that this Apex class will provide data for.
     */
    public Set<string> getGlobalDescribe() {
        return new Set<string> {
            debtorAdd,
            debtorUpdate,
            debtorDelete,

            securedPartyAdd,
            securedPartyUpdate,
            securedPartyDelete
        };
    }
    
    /**
     * @desc: Return a set of object names corresponding to the children for the objectName specified
     */
    public Set<string> getChildRelationships(string objectName) {
        return new Set<string>();
    }
    
    /**
     * @desc: describe fields required
     */
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objectNames) {
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>();
        
        for(String objectName : objectNames) {    
            switch on objectName {
                when 'debtorAdd', 'debtorUpdate', 'debtorDelete', 
                    'securedPartyAdd', 'securedPartyUpdate', 'securedPartyDelete' 
                {
                    describeObjectResults.add(getUCContactSchema(objectName));
                }
            }
        }

        return describeObjectResults;
    }
    
    /**
     * @desc: get records and map to wrapper
     * [Note: The QueryResultSet instance returned needs to contain a QueryResult instance for each object requested.]
     */
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        
        for(String objectName : requestInfo.GetObjectNames()) {
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, new List<String>());
        
            switch on objectName {
                when 'debtorAdd', 'debtorUpdate', 'debtorDelete', 
                    'securedPartyAdd', 'securedPartyUpdate', 'securedPartyDelete' 
                {
                    queryResult = getUCCContacts(requestInfo, objectName);
                }
            }

            // This needs to be done for every object specified in requestInfo.GetObjectNames(), 
            //regardless of whether data is required for the request.
            queryResultSet.add(queryResult);
        }
        
        return queryResultSet;
    }

    //-------------- UCC Contact Schema -----------------
    @TestVisible
    private Loop.ExternalData.DataObject getUCContactSchema(String obj) {
        List<Loop.ExternalData.FieldInfo> listFields = new List<Loop.ExternalData.FieldInfo>();

        for(Schema.SObjectField fld :Schema.SObjectType.UCC_Related_Info__c.Fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();
            
            Loop.ExternalData.FieldInfo fieldInfo = new Loop.ExternalData.FieldInfo(field.getName(), field.getType());
            fieldInfo.label = field.getLabel();

            if (!field.getReferenceTo().isEmpty()) {
                // referenceTo is needed to define a relationship between parent and child objects
                fieldInfo.referenceTo = string.valueOf(field.getReferenceTo()[0]);
            }

            listFields.add(fieldInfo);
        }
        
        return new Loop.ExternalData.DataObject(obj, listFields);
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getUCCContacts(Loop.ExternalData.QueryRequestInfo requestInfo, String type) {
        List<String> fields = new List<String>(Schema.SObjectType.UCC_Related_Info__c.Fields.getMap().keySet());
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(type, fields);

        String query =  System.Label.SELECT + ' ' + String.join(fields, ',') + ' '
        + System.Label.FROM + ' UCC_Related_Info__c'
        + ' WHERE Filing_Id__c = \''+ requestInfo.recordId + '\''
        + mapTypeQuery.get(type)
        + ' WITH SECURITY_ENFORCED';
        System.debug('Query:' + query);

        for(UCC_Related_Info__c relatedInfo : (List<UCC_Related_Info__c>)Database.query(
           query
        )) {
            // Store the values (as strings) from the record in the same order of the fields defined in the QueryResult instance
            List<string> recordValues = new List<string>();
            for (string field : fields) {
                recordValues.add(getFieldValue(relatedInfo, field));
            }
            
            // Add the values to the QueryResult instance rows
            queryResult.rows.add(recordValues);
        }

        return queryResult;
    }

    // This method properly retrieves a field value from an SObject for fields used through lookup relationships, 
    // e.g. PricebookEntry.Product2.ProductCode on the OpportunityLineItem object.
    @TestVisible
    private string getFieldValue(sObject obj, string field) {
        if (obj == null) return '';
        string[] fieldParts = field.split('\\.');
        if (fieldParts.size() == 3) {
            sObject sobj = obj.getSObject(fieldParts[0]);
            if (sobj == null) return '';
            sobj = sobj.getSObject(fieldParts[1]);
            if (sobj == null) return '';
            return string.valueOf(sobj.get(fieldParts[2]));
        }
        else if (fieldParts.size() == 2) {
            sObject sobj = obj.getSObject(fieldParts[0]);
            if (sobj == null) return '';
            return string.valueOf(sobj.get(fieldParts[1]));
        }
        return string.valueOf(obj.get(field));
    }
}