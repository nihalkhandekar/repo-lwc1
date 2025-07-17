// Class must be global for Nintex Drawloop to access it
// Class must implement the Loop.IApexDataSource Apex interface to use it in a Document Package Relationship
global with sharing class NintexFirstAnnualReportTemplateServices implements Loop.IApexDataSource {
    
    private static final String EMPTY_STRING = '';
    private static final String COMMA_SPACE_STRING = ', ';
    private static final String SPACE = ' ';
    private static final String COMMA = ',';
    private static final String NEXT_LINE = '\n';
    private static final String OBJ_TEMP_HISTORY = 'Temp_History__c';
    private static final String OBJ_PRINCIPAL = 'Principal__c';
    private static final List<String> LIST_CORPORATION_BUSINESS_TYPES = new List<String>{'Stock', 'Non-Stock', 'B Corp', 'Stock Corporation', 'Non-Stock Corporation', 'Benefit Corporation'};


    // Loop.IApexDataSource interface requires four public methods with the following signatures:
    // Set<string> getGlobalDescribe()
    // Set<string> getChildRelationships(string objectName)
    // List<ExternalData.DataObject> describeObjects(List<string> objectNames)
    // Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo)
    
    // optional, but good practice: use variables to store object names to avoid mistakes from typos
    private String acknowledgementWrapperName = 'NintexDataWrappers.AcknowledgementTemplateWrapper';
    private String businessPrimaryLocationDetailsName = 'NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper';
    private String annualCurrentPrincipalInfoName = 'NintexDataWrappers.ARCurrentPrincipalInfoWrapper';
    
    public Set<string> getGlobalDescribe() {
        // Return a set of object names that this Apex class will provide data for.
        return new Set<string>{
            acknowledgementWrapperName,
            businessPrimaryLocationDetailsName,
            annualCurrentPrincipalInfoName
        };
    }
    
    public Set<string> getChildRelationships(string objectName) {
        // Return a set of object names corresponding to the children for the objectName specified
        return new Set<string>();
    }
    
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objectNames) {
        // Describe each object in objectNames.
        
        // Declare the variable to be returned.
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>();
        
        // Loop through each object in objectNames and add to the result
        for (string objectName : objectNames) {
            // Declare variable to store field data for the object
            List<Loop.ExternalData.FieldInfo> fields = new List<Loop.ExternalData.FieldInfo>();

            if (objectName == acknowledgementWrapperName) {
                // Describe the fields for this object.
                
                Loop.ExternalData.FieldInfo principalTitle = new Loop.ExternalData.FieldInfo('principalTitle', Schema.DisplayType.String);
                principalTitle.label = 'Principal Title'; 
                fields.add(principalTitle);               
            }
            else if (objectName == businessPrimaryLocationDetailsName) {

                Loop.ExternalData.FieldInfo businessCitizenship = new Loop.ExternalData.FieldInfo('businessCitizenship', Schema.DisplayType.String);
                businessCitizenship.label = 'Business Citizenship'; 
                fields.add(businessCitizenship); 
                
                Loop.ExternalData.FieldInfo businessType = new Loop.ExternalData.FieldInfo('businessType', Schema.DisplayType.String);
                businessType.label = 'Business Type'; 
                fields.add(businessType); 
                
                Loop.ExternalData.FieldInfo businessName = new Loop.ExternalData.FieldInfo('businessName', Schema.DisplayType.String);
                businessName.label = 'Business Name'; 
                fields.add(businessName); 
                
                Loop.ExternalData.FieldInfo businessALEI = new Loop.ExternalData.FieldInfo('businessALEI', Schema.DisplayType.String);
                businessALEI.label = 'Business ALEI'; 
                fields.add(businessALEI); 
                
                Loop.ExternalData.FieldInfo dateOfOrgMeeting = new Loop.ExternalData.FieldInfo('dateOfOrgMeeting', Schema.DisplayType.String);
                dateOfOrgMeeting.label = 'Date of Organization Meeting'; 
                fields.add(dateOfOrgMeeting); 

                Loop.ExternalData.FieldInfo businessEmailOld = new Loop.ExternalData.FieldInfo('businessEmailOld', Schema.DisplayType.String);
                businessEmailOld.label = 'Business Email Address Old'; 
                fields.add(businessEmailOld); 
                
                Loop.ExternalData.FieldInfo businessEmailNew = new Loop.ExternalData.FieldInfo('businessEmailNew', Schema.DisplayType.String);
                businessEmailNew.label = 'Business Email Address New'; 
                fields.add(businessEmailNew); 
                
                Loop.ExternalData.FieldInfo naicsOld = new Loop.ExternalData.FieldInfo('naicsOld', Schema.DisplayType.String);
                naicsOld.label = 'NAICS Code Old'; 
                fields.add(naicsOld); 
                
                Loop.ExternalData.FieldInfo naicsNew = new Loop.ExternalData.FieldInfo('naicsNew', Schema.DisplayType.String);
                naicsNew.label = 'NAICS Code New'; 
                fields.add(naicsNew); 
                
                Loop.ExternalData.FieldInfo principalOffcAddrOld = new Loop.ExternalData.FieldInfo('principalOffcAddrOld', Schema.DisplayType.String);
                principalOffcAddrOld.label = 'Principal Office Address Old'; 
                fields.add(principalOffcAddrOld); 

                Loop.ExternalData.FieldInfo principalOffcAddrNew = new Loop.ExternalData.FieldInfo('principalOffcAddrNew', Schema.DisplayType.String);
                principalOffcAddrNew.label = 'Principal Office Address New'; 
                fields.add(principalOffcAddrNew); 
                
                Loop.ExternalData.FieldInfo mailingAddrOld = new Loop.ExternalData.FieldInfo('mailingAddrOld', Schema.DisplayType.String);
                mailingAddrOld.label = 'Mailing Address Old'; 
                fields.add(mailingAddrOld); 
                
                Loop.ExternalData.FieldInfo mailingAddrNew = new Loop.ExternalData.FieldInfo('mailingAddrNew', Schema.DisplayType.String);
                mailingAddrNew.label = 'Mailing Address New'; 
                fields.add(mailingAddrNew); 
                
                Loop.ExternalData.FieldInfo offcInJurisdictionAddrOld = new Loop.ExternalData.FieldInfo('offcInJurisdictionAddrOld', Schema.DisplayType.String);
                offcInJurisdictionAddrOld.label = 'Office Jurisdiction Address Old'; 
                fields.add(offcInJurisdictionAddrOld); 
                
                Loop.ExternalData.FieldInfo offcInJurisdictionAddrNew = new Loop.ExternalData.FieldInfo('offcInJurisdictionAddrNew', Schema.DisplayType.String);
                offcInJurisdictionAddrNew.label = 'Office Jurisdiction Address New'; 
                fields.add(offcInJurisdictionAddrNew); 

                Loop.ExternalData.FieldInfo mailingStateOfFormationOld = new Loop.ExternalData.FieldInfo('mailingStateOfFormationOld', Schema.DisplayType.String);
                mailingStateOfFormationOld.label = 'Mailing Address (in State of Formation) Old'; 
                fields.add(mailingStateOfFormationOld); 

                Loop.ExternalData.FieldInfo mailingStateOfFormationNew = new Loop.ExternalData.FieldInfo('mailingStateOfFormationNew', Schema.DisplayType.String);
                mailingStateOfFormationNew.label = 'Mailing Address (in State of Formation) New'; 
                fields.add(mailingStateOfFormationNew); 
            }
            else if (objectName == annualCurrentPrincipalInfoName) {
                Loop.ExternalData.FieldInfo principalName = new Loop.ExternalData.FieldInfo('principalName', Schema.DisplayType.String);
                principalName.label = 'Principal Name'; 
                fields.add(principalName); 
                
                Loop.ExternalData.FieldInfo principalDesignation = new Loop.ExternalData.FieldInfo('principalDesignation', Schema.DisplayType.String);
                principalDesignation.label = 'Principal Designation'; 
                fields.add(principalDesignation); 
                
                Loop.ExternalData.FieldInfo principalTitle = new Loop.ExternalData.FieldInfo('principalTitle', Schema.DisplayType.String);
                principalTitle.label = 'Principal Title'; 
                fields.add(principalTitle); 
                
                Loop.ExternalData.FieldInfo principalBusinessAddr = new Loop.ExternalData.FieldInfo('principalBusinessAddr', Schema.DisplayType.String);
                principalBusinessAddr.label = 'Principal Business Address'; 
                fields.add(principalBusinessAddr); 
                
                Loop.ExternalData.FieldInfo principalResidenceAddr = new Loop.ExternalData.FieldInfo('principalResidenceAddr', Schema.DisplayType.String);
                principalResidenceAddr.label = 'Principal Residence Address'; 
                fields.add(principalResidenceAddr); 
            }
            
            // Declare variable to add to results list using fields described above
            Loop.ExternalData.DataObject describeObjectResult = new Loop.ExternalData.DataObject(objectName, fields);
            
            // Add to results list
            describeObjectResults.add(describeObjectResult);
        }
        
        return describeObjectResults;
    }
    
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        // Provide data for each object in requestInfo.GetObjectNames()
        
        Id businessFilingId = requestInfo.RecordId;
        
        // Declare the variable to be returned.
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        
        // Loop through all objects requested. The QueryResultSet instance returned needs to contain a QueryResult instance for each object requested.
        for (string objectName : requestInfo.GetObjectNames()) {
            // Declare fields list for QueryResult instance
            List<string> fields = new List<string>();
            
            // Declare query result to add to QueryResultSet instance
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fields);
            
            // set up fields list and query to get data for QueryResult instance
            if (objectName == acknowledgementWrapperName) {

                fields.add('principalTitle');

                // Since we added fields to the list, update the QueryResult instance
                queryResult = new Loop.ExternalData.QueryResult(objectName, fields);

                // Add the values to the QueryResult instance rows
                String value = getPrincipalTitle(businessFilingId);
                queryResult.rows.add(new List<String> {value});
                
                // Add the QueryResult instance to the QueryResultSet instance
                // This needs to be done for every object specified in requestInfo.GetObjectNames(), regardless of whether data is required for the request.
                queryResultSet.add(queryResult);
            }
            else if (objectName == annualCurrentPrincipalInfoName) {
                fields = new List<String>{'principalName', 'principalDesignation', 'principalTitle', 'principalBusinessAddr', 'principalResidenceAddr'};
               	queryResult = new Loop.ExternalData.QueryResult(objectName, fields);

                if (String.isNotBlank(businessFilingId)) {
                    for(NintexDataWrappers.ARCurrentPrincipalInfoWrapper wrapper : getCurrentPrincipalInfo(businessFilingId)) {
                        //System.debug('currentPrincipalWrapper :: ' + JSON.serialize(wrapper));
                        
                        // Add the values to the QueryResult instance rows
                        if(wrapper != null){
                            queryResult.rows.add(new List<String> {
                                wrapper.principalName,
                                wrapper.principalDesignation,
                                wrapper.principalTitle,
                                wrapper.principalBusinessAddr,
                                wrapper.principalResidenceAddr
                                });
                        }
                    }
                }
                
                queryResultSet.add(queryResult);
            }
            else if (objectName == businessPrimaryLocationDetailsName) {
                fields = new List<String>{'businessCitizenship', 'businessType', 'businessName', 'businessALEI', 'dateOfOrgMeeting', 'businessEmailOld', 'businessEmailNew', 'naicsOld', 
                                            'naicsNew', 'principalOffcAddrOld', 'principalOffcAddrNew', 'mailingAddrOld', 'mailingAddrNew', 'offcInJurisdictionAddrOld', 'offcInJurisdictionAddrNew', 'mailingStateOfFormationOld', 'mailingStateOfFormationNew'};

                queryResult = new Loop.ExternalData.QueryResult(objectName, fields);

                for(NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper wrapper : getPrimaryAndLocationDetails(businessFilingId)) {
                    
                    // Add the values to the QueryResult instance rows
                    if(wrapper != null) {
                        queryResult.rows.add(new List<String> {
                                        wrapper.businessCitizenship, 
                                        wrapper.businessType, 
                                        wrapper.businessName, 
                                        wrapper.businessALEI, 
                                        wrapper.dateOfOrgMeeting, 
                                        wrapper.businessEmailOld, 
                                        wrapper.businessEmailNew, 
                                        wrapper.naicsOld, 
                                        wrapper.naicsNew, 
                                        wrapper.principalOffcAddrOld, 
                                        wrapper.principalOffcAddrNew, 
                                        wrapper.mailingAddrOld, 
                                        wrapper.mailingAddrNew, 
                                        wrapper.offcInJurisdictionAddrOld, 
                                        wrapper.offcInJurisdictionAddrNew, 
                                        wrapper.mailingStateOfFormationOld, 
                                        wrapper.mailingStateOfFormationNew
                        });
                    }
                }
                queryResultSet.add(queryResult);
            }
        }
        
        return queryResultSet;
    }
    @testVisible
    private static String getPrincipalTitle(String recordId) {
        String principalTitle = '';
        
        if(String.isNotBlank(recordId)) {    
            List<Business_Filing__c> lstBizFiling = [
                SELECT Id, Signatory_Name__c, Review_Selected_Principal__c, Account__c
                FROM Business_Filing__c
                WHERE Id = :recordId 
                WITH SECURITY_ENFORCED 
            ];

            if(!lstBizFiling.isEmpty()) {
                String authName = String.isNotBlank(lstBizFiling[0].Signatory_Name__c) 
                                    ? lstBizFiling[0].Signatory_Name__c 
                                    : lstBizFiling[0].Review_Selected_Principal__c;

                List<Temp_History__c> listTempHistory = [
                    SELECT Title__c 
                    FROM Temp_History__c 
                    WHERE Type__c = :System.Label.Label_Principal 
                        AND Business_Filing__c = :recordId
                        AND Name__c = :authName
                        AND Change_Type__c IN (:System.Label.brs_maintenance_tempEdited, :System.Label.Created)
                        AND Title__c != null 
                    WITH SECURITY_ENFORCED 
                    LIMIT 1
                ];

                if(!listTempHistory.isEmpty()) {
                    principalTitle = listTempHistory.get(0).Title__c;
                } else if(String.isNotBlank(lstBizFiling[0].Account__c)) {
                    List<Principal__c> listPrincipals = [
                        SELECT Principal_Title__c 
                        FROM Principal__c 
                        WHERE Business_ID__c = :String.valueOf(lstBizFiling[0].Account__c)
                            AND Name__c = :authName
                            AND Principal_Title__c != null 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1
                    ];
                
                    if(!listPrincipals.isEmpty()) {
                        principalTitle = listPrincipals.get(0).Principal_Title__c;
                    }
                }
            }
        }

        return principalTitle;
    }
    @TestVisible
    private static List<NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper> getPrimaryAndLocationDetails (String recordId){
        List<Business_Filing__c> lstBizFilings = new List<Business_Filing__c>();
        NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper primaryLocDetailsWrapper = new NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper();
        List<NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper> lstPrimaryLocDetailsWrapper = new List<NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper>();

        // fetch Business Filing details
        lstBizFilings = [SELECT Id, Name, Citizenship__c, Account__r.Date_of_Organization_Meeting__c, Business_Type__c, Filing_Type__c, Account__r.Name, Account__r.Connecticut_ALEI__c, Account__r.Business_Email_Address__c, Account__r.NAICS_Code__c,
                                Account__r.BillingStreet, Account__r.Billing_Unit__c, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Principle_Office_International_Address__c,
                                Account__r.ShippingStreet, Account__r.Shipping_Unit__c, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingPostalCode, Account__r.ShippingCountry, Account__r.Mailing_International_Address__c,
                                Account__r.Office_Jurisdiction_BusinessStreet__c, Account__r.Office_Jurisdiction_BusinessUnit__c, Account__r.Office_Jurisdiction_BusinessCity__c, Account__r.Office_Jurisdiction_BusinessState__c, Account__r.Office_Jurisdiction_BusinessZipCode__c, Account__r.Office_in_Jurisdiction_Country__c, Account__r.Jurisdiction_International_address__c,
                                Account__r.Mailing_Jurisdiction_BusinessStreet__c, Account__r.Mailing_Jurisdiction_BusinessUnit__c, Account__r.Mailing_Jurisdiction_BusinessCity__c, Account__r.Mailing_Jurisdiction_BusinessState__c, Account__r.Mailing_Jurisdiction_BusinessZipCode__c, Account__r.Mailing_Jurisdiction_Country__c, Account__r.Mail_Jurisdiction_International_address__c
                        FROM Business_Filing__c
                        WHERE Id = :recordId WITH SECURITY_ENFORCED];

        if(!lstBizFilings.isEmpty()) {
            primaryLocDetailsWrapper = (lstBizFilings[0].Filing_Type__c == 'Annual Report') 
                                            ? getARPrimaryBizInfo(recordId, lstBizFilings)
                                            : (lstBizFilings[0].Filing_Type__c == 'Organization and First Report') 
                                                    ? getFRPrimaryBizInfo(recordId, lstBizFilings)
                                                    : null;

            lstPrimaryLocDetailsWrapper.add(primaryLocDetailsWrapper);
        }
        return lstPrimaryLocDetailsWrapper;
    }
    @TestVisible
    private static NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper getARPrimaryBizInfo (String recordId, List<Business_Filing__c> lstBizFilings) {
        NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper bizPrimeLocationDetailsWrapper = new NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper();
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        String bizEmailAddr = EMPTY_STRING;
        String bizNAICS = EMPTY_STRING;
        String principalOffcAddr = EMPTY_STRING;
        String principalOffcAddrNew = EMPTY_STRING;
        String mailingAddr = EMPTY_STRING;
        String mailingAddrNew = EMPTY_STRING;
        String offcJurisAddr = EMPTY_STRING;
        String offcJurisAddrNew = EMPTY_STRING;
        String mailingStateofFormAddr = EMPTY_STRING;
        String mailingStateofFormAddrNew = EMPTY_STRING;

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ', Business_Filing__r.Citizenship__c, Business_Filing__r.Filing_Type__c, Business_Filing__r.Business_Type__c, Account__r.Name, Account__r.Connecticut_ALEI__c, Account__r.Business_Email_Address__c, Business_Filing__r.Account__c, Account__r.NAICS_Code__c, Account__r.Citizenship__c, Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Account\' AND Business_Filing__c = :recordId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';

        lstTempHistory = Database.query(sTempHistQuery);

        if(!lstTempHistory.isEmpty()) {

            // annual report primary details after updation
            bizPrimeLocationDetailsWrapper.businessCitizenship = lstTempHistory[0].Business_Filing__r.Citizenship__c;
            bizPrimeLocationDetailsWrapper.businessType = lstTempHistory[0].Business_Filing__r.Business_Type__c;
            bizPrimeLocationDetailsWrapper.businessName = lstTempHistory[0].Account__r.Name;
            bizPrimeLocationDetailsWrapper.businessALEI = lstTempHistory[0].Account__r.Connecticut_ALEI__c;

            if(String.isNotBlank(lstTempHistory[0].Business_Email_Address__c)) {
                bizEmailAddr = lstTempHistory[0].Business_Email_Address__c;
            }
            else if (lstTempHistory[0].Account__c != null && String.isNotBlank(lstTempHistory[0].Account__r.Business_Email_Address__c) && lstTempHistory[0].Account__r.Business_Email_Address__c != lstTempHistory[0].Email_New__c) {
                bizEmailAddr = lstTempHistory[0].Account__r.Business_Email_Address__c;
            }
            else {
                bizEmailAddr = 'None';
            }

            bizPrimeLocationDetailsWrapper.businessEmailOld = bizEmailAddr;
            bizPrimeLocationDetailsWrapper.businessEmailNew = (String.isNotBlank(lstTempHistory[0].Email_New__c) && lstTempHistory[0].Email_New__c != lstTempHistory[0].Business_Email_Address__c)
                                                                ? lstTempHistory[0].Email_New__c
                                                                : 'No update';

            if(String.isNotBlank(lstTempHistory[0].NAICS_Code__c)) {
                bizNAICS = lstTempHistory[0].NAICS_Code__c;
            }
            else if (lstTempHistory[0].Account__c != null && String.isNotBlank(lstTempHistory[0].Account__r.NAICS_Code__c) && lstTempHistory[0].Account__r.NAICS_Code__c != lstTempHistory[0].NAICS_Code_New__c) {
                bizNAICS = lstTempHistory[0].Account__r.NAICS_Code__c;
            }
            else {
                bizNAICS = 'None';
            }
            
            bizPrimeLocationDetailsWrapper.naicsOld = bizNAICS;
            bizPrimeLocationDetailsWrapper.naicsNew = (String.isNotBlank(lstTempHistory[0].NAICS_Code_New__c) && lstTempHistory[0].NAICS_Code_New__c != lstTempHistory[0].NAICS_Code__c)
                                                                ? lstTempHistory[0].NAICS_Code_New__c
                                                                : 'No update';

            // annual report business location details after updation
            if(lstTempHistory[0].Type_of_Update__c == 'Business Address') {

                // principal office address old
                if(String.isNotBlank(lstTempHistory[0].BillingStreet__c)) {
                    principalOffcAddr = lstTempHistory[0].BillingStreet__c;
                    principalOffcAddr += lstTempHistory[0].Business_Unit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Business_Unit__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstTempHistory[0].Billing_City__c != null ? lstTempHistory[0].Billing_City__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    principalOffcAddr += lstTempHistory[0].BillingState__c != null ? lstTempHistory[0].BillingState__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstTempHistory[0].BillingPostalCode__c != null ? lstTempHistory[0].BillingPostalCode__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstTempHistory[0].Billing_Country__c != null ? lstTempHistory[0].Billing_Country__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstTempHistory[0].Principle_Office_International_Address__c)) {
                    principalOffcAddr = lstTempHistory[0].Principle_Office_International_Address__c + COMMA + NEXT_LINE;
                    principalOffcAddr += lstTempHistory[0].Billing_Country__c != null ? lstTempHistory[0].Billing_Country__c : EMPTY_STRING;
                }
                else {
                    principalOffcAddr = 'None';
                }

                // principal office address new
                if(String.isNotBlank(lstTempHistory[0].BillingStreet_New__c) && 
                    (lstTempHistory[0].BillingStreet_New__c != lstTempHistory[0].BillingStreet__c || lstTempHistory[0].Business_Unit_New__c != lstTempHistory[0].Business_Unit__c || 
                    lstTempHistory[0].Billing_City_New__c != lstTempHistory[0].Billing_City__c || lstTempHistory[0].BillingState_New__c != lstTempHistory[0].BillingState__c || 
                    lstTempHistory[0].BillingPostalCode_New__c != lstTempHistory[0].BillingPostalCode__c)) 
                {

                    principalOffcAddrNew = lstTempHistory[0].BillingStreet_New__c;
                    principalOffcAddrNew += lstTempHistory[0].Business_Unit_New__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Business_Unit_New__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddrNew += lstTempHistory[0].Billing_City_New__c != null ? lstTempHistory[0].Billing_City_New__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    principalOffcAddrNew += lstTempHistory[0].BillingState_New__c != null ? lstTempHistory[0].BillingState_New__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddrNew += lstTempHistory[0].BillingPostalCode_New__c != null ? lstTempHistory[0].BillingPostalCode_New__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddrNew += lstTempHistory[0].Billing_Country_New__c != null ? lstTempHistory[0].Billing_Country_New__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstTempHistory[0].Principle_Office_International_Address_N__c)) {
                    principalOffcAddrNew = lstTempHistory[0].Principle_Office_International_Address_N__c + COMMA + NEXT_LINE;
                    principalOffcAddrNew += lstTempHistory[0].Billing_Country_New__c != null ? lstTempHistory[0].Billing_Country_New__c : EMPTY_STRING;
                }
                else {
                    principalOffcAddrNew = 'No update';
                }

                // mailing address old
                if(String.isNotBlank(lstTempHistory[0].ShippingStreet__c)) {
                    mailingAddr = lstTempHistory[0].ShippingStreet__c;
                    mailingAddr += lstTempHistory[0].Mailing_Unit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Mailing_Unit__c + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstTempHistory[0].ShippingCity__c != null ? lstTempHistory[0].ShippingCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    mailingAddr += lstTempHistory[0].ShippingState__c != null ? lstTempHistory[0].ShippingState__c + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstTempHistory[0].ShippingPostalCode__c != null ? lstTempHistory[0].ShippingPostalCode__c + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstTempHistory[0].Shipping_Country__c != null ? lstTempHistory[0].Shipping_Country__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstTempHistory[0].Mailing_International_Address__c)) {
                    mailingAddr = lstTempHistory[0].Mailing_International_Address__c + COMMA + NEXT_LINE;
                    mailingAddr += lstTempHistory[0].Shipping_Country__c != null ? lstTempHistory[0].Shipping_Country__c : EMPTY_STRING;
                }
                else {
                    mailingAddr = 'None';
                }

                // mailing address new
                if(String.isNotBlank(lstTempHistory[0].ShippingStreet_New__c) && 
                    (lstTempHistory[0].ShippingStreet_New__c != lstTempHistory[0].ShippingStreet__c || lstTempHistory[0].Mailing_Unit_New__c != lstTempHistory[0].Mailing_Unit__c || 
                    lstTempHistory[0].ShippingCity_New__c != lstTempHistory[0].ShippingCity__c || lstTempHistory[0].ShippingState_New__c != lstTempHistory[0].ShippingState__c || 
                    lstTempHistory[0].ShippingPostalCode_New__c != lstTempHistory[0].ShippingPostalCode__c)) 
                {

                    mailingAddrNew = lstTempHistory[0].ShippingStreet_New__c;
                    mailingAddrNew += lstTempHistory[0].Mailing_Unit_New__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Mailing_Unit_New__c + NEXT_LINE : NEXT_LINE;
                    mailingAddrNew += lstTempHistory[0].ShippingCity_New__c != null ? lstTempHistory[0].ShippingCity_New__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    mailingAddrNew += lstTempHistory[0].ShippingState_New__c != null ? lstTempHistory[0].ShippingState_New__c + NEXT_LINE : NEXT_LINE;
                    mailingAddrNew += lstTempHistory[0].ShippingPostalCode_New__c != null ? lstTempHistory[0].ShippingPostalCode_New__c + NEXT_LINE : NEXT_LINE;
                    mailingAddrNew += lstTempHistory[0].Shipping_Country_New__c != null ? lstTempHistory[0].Shipping_Country_New__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstTempHistory[0].Mailing_International_Address_New__c)) {
                    mailingAddrNew = lstTempHistory[0].Mailing_International_Address_New__c + COMMA + NEXT_LINE;
                    mailingAddrNew += lstTempHistory[0].Shipping_Country_New__c != null ? lstTempHistory[0].Shipping_Country_New__c : EMPTY_STRING;
                }
                else {
                    mailingAddrNew = 'No update';
                }

                if (lstTempHistory[0].Account__r.Citizenship__c == 'Foreign') {
                    // office in jurisdiction address old
                    if(String.isNotBlank(lstTempHistory[0].Office_Jurisdiction_BusinessStreet__c)) {
                        offcJurisAddr = lstTempHistory[0].Office_Jurisdiction_BusinessStreet__c;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Office_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_BusinessCity__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_BusinessState__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_BusinessZipCode__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_Country__c != null ? lstTempHistory[0].Office_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstTempHistory[0].Jurisdiction_International_address__c)) {
                        offcJurisAddr = lstTempHistory[0].Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                        offcJurisAddr += lstTempHistory[0].Office_Jurisdiction_Country__c != null ? lstTempHistory[0].Office_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else {
                        offcJurisAddr = 'None';
                    }

                    // office in jurisdiction address new
                    if(String.isNotBlank(lstTempHistory[0].Office_Jurisdiction_BusinessStreet_New__c) && 
                        (lstTempHistory[0].Office_Jurisdiction_BusinessStreet_New__c != lstTempHistory[0].Office_Jurisdiction_BusinessStreet__c || lstTempHistory[0].Office_Jurisdiction_BusinessUnit_New__c != lstTempHistory[0].Office_Jurisdiction_BusinessUnit__c || 
                        lstTempHistory[0].Office_Jurisdiction_BusinessCity_New__c != lstTempHistory[0].Office_Jurisdiction_BusinessCity__c || lstTempHistory[0].Office_Jurisdiction_BusinessState_New__c != lstTempHistory[0].Office_Jurisdiction_BusinessState__c || 
                        lstTempHistory[0].Office_Jurisdiction_BusinessZipCode_New__c != lstTempHistory[0].Office_Jurisdiction_BusinessZipCode__c)) 
                    {

                        offcJurisAddrNew = lstTempHistory[0].Office_Jurisdiction_BusinessStreet_New__c;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_BusinessUnit_New__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Office_Jurisdiction_BusinessUnit_New__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_BusinessCity_New__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessCity_New__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_BusinessState_New__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessState_New__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_BusinessZipCode_New__c != null ? lstTempHistory[0].Office_Jurisdiction_BusinessZipCode_New__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_Country_New__c != null ? lstTempHistory[0].Office_Jurisdiction_Country_New__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstTempHistory[0].Jurisdiction_International_address_New__c)) {
                        offcJurisAddrNew = lstTempHistory[0].Jurisdiction_International_address_New__c + COMMA + NEXT_LINE;
                        offcJurisAddrNew += lstTempHistory[0].Office_Jurisdiction_Country_New__c != null ? lstTempHistory[0].Office_Jurisdiction_Country_New__c : EMPTY_STRING;
                    }
                    else {
                        offcJurisAddrNew = 'No update';
                    }

                    // mailing address (in state of formation) old
                    if(String.isNotBlank(lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet__c)) {
                        mailingStateofFormAddr = lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet__c;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_BusinessCity__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_BusinessState__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_Country__c != null ? lstTempHistory[0].Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstTempHistory[0].Mail_Jurisdiction_International_address__c)) {
                        mailingStateofFormAddr = lstTempHistory[0].Mail_Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                        mailingStateofFormAddr += lstTempHistory[0].Mailing_Jurisdiction_Country__c != null ? lstTempHistory[0].Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else {
                        mailingStateofFormAddr = 'None';
                    }

                    // mailing address (in state of formation) new
                    if(String.isNotBlank(lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet_New__c) && 
                        (lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet_New__c != lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet__c || lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit_New__c != lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit__c || 
                        lstTempHistory[0].Mailing_Jurisdiction_BusinessCity_New__c != lstTempHistory[0].Mailing_Jurisdiction_BusinessCity__c || lstTempHistory[0].Mailing_Jurisdiction_BusinessState_New__c != lstTempHistory[0].Mailing_Jurisdiction_BusinessState__c || 
                        lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode_New__c != lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode__c)) 
                    {

                        mailingStateofFormAddrNew = lstTempHistory[0].Mailing_Jurisdiction_BusinessStreet_New__c;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit_New__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Mailing_Jurisdiction_BusinessUnit_New__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_BusinessCity_New__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessCity_New__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_BusinessState_New__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessState_New__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode_New__c != null ? lstTempHistory[0].Mailing_Jurisdiction_BusinessZipCode_New__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_Country_New__c != null ? lstTempHistory[0].Mailing_Jurisdiction_Country_New__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstTempHistory[0].Mail_JurisdictionInternationaladdress_N__c)) {
                        mailingStateofFormAddrNew = lstTempHistory[0].Mail_JurisdictionInternationaladdress_N__c + COMMA + NEXT_LINE;
                        mailingStateofFormAddrNew += lstTempHistory[0].Mailing_Jurisdiction_Country_New__c != null ? lstTempHistory[0].Mailing_Jurisdiction_Country_New__c : EMPTY_STRING;
                    }
                    else {
                        mailingStateofFormAddrNew = 'No update';
                    }
                }

                bizPrimeLocationDetailsWrapper.principalOffcAddrOld = principalOffcAddr;
                bizPrimeLocationDetailsWrapper.principalOffcAddrNew = principalOffcAddrNew;
                bizPrimeLocationDetailsWrapper.mailingAddrOld = mailingAddr;
                bizPrimeLocationDetailsWrapper.mailingAddrNew = mailingAddrNew;
                bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrOld = offcJurisAddr;
                bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrNew = offcJurisAddrNew;
                bizPrimeLocationDetailsWrapper.mailingStateOfFormationOld = mailingStateofFormAddr;
                bizPrimeLocationDetailsWrapper.mailingStateOfFormationNew = mailingStateofFormAddrNew;
            }
            else {

                // annual report business location details no updation

                // principal office address existing
                if(String.isNotBlank(lstBizFilings[0].Account__r.BillingStreet)) {
                    principalOffcAddr = lstBizFilings[0].Account__r.BillingStreet;
                    principalOffcAddr += lstBizFilings[0].Account__r.Billing_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Billing_Unit__c + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstBizFilings[0].Account__r.BillingCity != null ? lstBizFilings[0].Account__r.BillingCity + COMMA_SPACE_STRING : EMPTY_STRING;
                    principalOffcAddr += lstBizFilings[0].Account__r.BillingState != null ? lstBizFilings[0].Account__r.BillingState + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstBizFilings[0].Account__r.BillingPostalCode != null ? lstBizFilings[0].Account__r.BillingPostalCode + NEXT_LINE : NEXT_LINE;
                    principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry != null ? lstBizFilings[0].Account__r.BillingCountry : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstBizFilings[0].Account__r.Principle_Office_International_Address__c)) {
                    principalOffcAddr = lstBizFilings[0].Account__r.Principle_Office_International_Address__c + COMMA + NEXT_LINE;
                    principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry != null ? lstBizFilings[0].Account__r.BillingCountry : EMPTY_STRING;
                }
                else {
                    principalOffcAddr = 'None';
                }

                // mailing address existing
                if(String.isNotBlank(lstBizFilings[0].Account__r.ShippingStreet)) {
                    mailingAddr = lstBizFilings[0].Account__r.ShippingStreet;
                    mailingAddr += lstBizFilings[0].Account__r.Shipping_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Shipping_Unit__c + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstBizFilings[0].Account__r.ShippingCity != null ? lstBizFilings[0].Account__r.ShippingCity + COMMA_SPACE_STRING : EMPTY_STRING;
                    mailingAddr += lstBizFilings[0].Account__r.ShippingState != null ? lstBizFilings[0].Account__r.ShippingState + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstBizFilings[0].Account__r.ShippingPostalCode != null ? lstBizFilings[0].Account__r.ShippingPostalCode + NEXT_LINE : NEXT_LINE;
                    mailingAddr += lstBizFilings[0].Account__r.ShippingCountry != null ? lstBizFilings[0].Account__r.ShippingCountry : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstBizFilings[0].Account__r.Mailing_International_Address__c)) {
                    mailingAddr = lstBizFilings[0].Account__r.Mailing_International_Address__c + COMMA + NEXT_LINE;
                    mailingAddr += lstBizFilings[0].Account__r.ShippingCountry != null ?  lstBizFilings[0].Account__r.ShippingCountry : EMPTY_STRING;
                }
                else {
                    mailingAddr = 'None';
                }

                if(lstBizFilings[0].Citizenship__c == 'Foreign') {

                    // office in jurisdiction address existing
                    if(String.isNotBlank(lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessStreet__c)) {
                        offcJurisAddr = lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessStreet__c;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessCity__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessState__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessZipCode__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstBizFilings[0].Account__r.Jurisdiction_International_address__c)) {
                        offcJurisAddr = lstBizFilings[0].Account__r.Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                        offcJurisAddr += lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else {
                        offcJurisAddr = 'None';
                    }

                    // mailing address (in state of formation) existing
                    if(String.isNotBlank(lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessStreet__c)) {
                        mailingStateofFormAddr = lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessStreet__c;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessCity__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessState__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessZipCode__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else if (String.isNotBlank(lstBizFilings[0].Account__r.Mail_Jurisdiction_International_address__c)) {
                        mailingStateofFormAddr = lstBizFilings[0].Account__r.Mail_Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                        mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                    }
                    else {
                        mailingStateofFormAddr = 'None';
                    }
                }

                bizPrimeLocationDetailsWrapper.principalOffcAddrOld = principalOffcAddr;
                bizPrimeLocationDetailsWrapper.principalOffcAddrNew = 'No update';
                bizPrimeLocationDetailsWrapper.mailingAddrOld = mailingAddr;
                bizPrimeLocationDetailsWrapper.mailingAddrNew = 'No update';
                bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrOld = offcJurisAddr;
                bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrNew = 'No update';
                bizPrimeLocationDetailsWrapper.mailingStateOfFormationOld = mailingStateofFormAddr;
                bizPrimeLocationDetailsWrapper.mailingStateOfFormationNew = 'No update';
            }
        }
        else {

            // business primary details
            bizPrimeLocationDetailsWrapper.businessCitizenship = lstBizFilings[0].Citizenship__c;
            bizPrimeLocationDetailsWrapper.businessType = lstBizFilings[0].Business_Type__c;
            bizPrimeLocationDetailsWrapper.businessName = lstBizFilings[0].Account__r.Name;
            bizPrimeLocationDetailsWrapper.businessALEI = lstBizFilings[0].Account__r.Connecticut_ALEI__c;
            bizPrimeLocationDetailsWrapper.businessEmailOld = String.isNotBlank(lstBizFilings[0].Account__r.Business_Email_Address__c) ? lstBizFilings[0].Account__r.Business_Email_Address__c : 'None';
            bizPrimeLocationDetailsWrapper.businessEmailNew = 'No update';
            bizPrimeLocationDetailsWrapper.naicsOld = String.isNotBlank(lstBizFilings[0].Account__r.NAICS_Code__c) ? lstBizFilings[0].Account__r.NAICS_Code__c : 'None';
            bizPrimeLocationDetailsWrapper.naicsNew = 'No update';

            // business location details
            // principal office address existing
            if(String.isNotBlank(lstBizFilings[0].Account__r.BillingStreet)) {
                principalOffcAddr = lstBizFilings[0].Account__r.BillingStreet;
                principalOffcAddr += lstBizFilings[0].Account__r.Billing_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Billing_Unit__c + NEXT_LINE : NEXT_LINE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCity != null ? lstBizFilings[0].Account__r.BillingCity + COMMA_SPACE_STRING : EMPTY_STRING;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingState != null ? lstBizFilings[0].Account__r.BillingState + NEXT_LINE : NEXT_LINE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingPostalCode != null ? lstBizFilings[0].Account__r.BillingPostalCode + NEXT_LINE : NEXT_LINE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry != null ? lstBizFilings[0].Account__r.BillingCountry : EMPTY_STRING;
            }
            else if (String.isNotBlank(lstBizFilings[0].Account__r.Principle_Office_International_Address__c)) {
                principalOffcAddr = lstBizFilings[0].Account__r.Principle_Office_International_Address__c + COMMA + NEXT_LINE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry != null ? lstBizFilings[0].Account__r.BillingCountry : EMPTY_STRING;
            }
            else {
                principalOffcAddr = 'None';
            }

            // mailing address existing
            if(String.isNotBlank(lstBizFilings[0].Account__r.ShippingStreet)) {
                mailingAddr = lstBizFilings[0].Account__r.ShippingStreet;
                mailingAddr += lstBizFilings[0].Account__r.Shipping_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Shipping_Unit__c + NEXT_LINE : NEXT_LINE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCity != null ? lstBizFilings[0].Account__r.ShippingCity + COMMA_SPACE_STRING : EMPTY_STRING;
                mailingAddr += lstBizFilings[0].Account__r.ShippingState != null ? lstBizFilings[0].Account__r.ShippingState + NEXT_LINE : NEXT_LINE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingPostalCode != null ? lstBizFilings[0].Account__r.ShippingPostalCode + NEXT_LINE : NEXT_LINE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCountry != null ? lstBizFilings[0].Account__r.ShippingCountry : EMPTY_STRING;
            }
            else if (String.isNotBlank(lstBizFilings[0].Account__r.Mailing_International_Address__c)) {
                mailingAddr = lstBizFilings[0].Account__r.Mailing_International_Address__c + COMMA + NEXT_LINE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCountry != null ?  lstBizFilings[0].Account__r.ShippingCountry : EMPTY_STRING;
            }
            else {
                mailingAddr = 'None';
            }

            if(lstBizFilings[0].Citizenship__c == 'Foreign') {

                // office in jurisdiction address existing
                if(String.isNotBlank(lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessStreet__c)) {
                    offcJurisAddr = lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessStreet__c;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessCity__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessState__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessZipCode__c != null ? lstBizFilings[0].Account__r.Office_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstBizFilings[0].Account__r.Jurisdiction_International_address__c)) {
                    offcJurisAddr = lstBizFilings[0].Account__r.Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                    offcJurisAddr += lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Office_in_Jurisdiction_Country__c : EMPTY_STRING;
                }
                else {
                    offcJurisAddr = 'None';
                }

                // mailing address (in state of formation) existing
                if(String.isNotBlank(lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessStreet__c)) {
                    mailingStateofFormAddr = lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessStreet__c;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessUnit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessUnit__c + NEXT_LINE : NEXT_LINE;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessCity__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessCity__c + COMMA_SPACE_STRING : EMPTY_STRING;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessState__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessState__c + NEXT_LINE : NEXT_LINE;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessZipCode__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_BusinessZipCode__c + NEXT_LINE : NEXT_LINE;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                }
                else if (String.isNotBlank(lstBizFilings[0].Account__r.Mail_Jurisdiction_International_address__c)) {
                    mailingStateofFormAddr = lstBizFilings[0].Account__r.Mail_Jurisdiction_International_address__c + COMMA + NEXT_LINE;
                    mailingStateofFormAddr += lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c != null ? lstBizFilings[0].Account__r.Mailing_Jurisdiction_Country__c : EMPTY_STRING;
                }
                else {
                    mailingStateofFormAddr = 'None';
                }
            }

            bizPrimeLocationDetailsWrapper.principalOffcAddrOld = principalOffcAddr;
            bizPrimeLocationDetailsWrapper.principalOffcAddrNew = 'No update';
            bizPrimeLocationDetailsWrapper.mailingAddrOld = mailingAddr;
            bizPrimeLocationDetailsWrapper.mailingAddrNew = 'No update';
            bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrOld = offcJurisAddr;
            bizPrimeLocationDetailsWrapper.offcInJurisdictionAddrNew = 'No update';
            bizPrimeLocationDetailsWrapper.mailingStateOfFormationOld = mailingStateofFormAddr;
            bizPrimeLocationDetailsWrapper.mailingStateOfFormationNew = 'No update';
        }

        return bizPrimeLocationDetailsWrapper;
    }

    private static NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper getFRPrimaryBizInfo (String recordId, List<Business_Filing__c> lstBizFilings) {
        NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper bizPrimeLocationDetailsWrapper = new NintexDataWrappers.BusinessPrimaryLocationDetailsWrapper();
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        String principalOffcAddr = EMPTY_STRING;
        String principalOffcAddrNew = EMPTY_STRING;
        String mailingAddr = EMPTY_STRING;
        String mailingAddrNew = EMPTY_STRING;

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ', Business_Filing__r.Citizenship__c, Business_Filing__r.Filing_Type__c, Business_Filing__r.Business_Type__c, Account__r.Date_of_Organization_Meeting__c, Account__r.Name, Account__r.Connecticut_ALEI__c, Business_Filing__r.Account__c, Account__r.Business_Email_Address__c, Account__r.NAICS_Code__c, Account__r.Citizenship__c, Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Account\' AND Business_Filing__c = :recordId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1';

        lstTempHistory = Database.query(sTempHistQuery);

        if(!lstTempHistory.isEmpty()) {

            // first report primary details after updation
            bizPrimeLocationDetailsWrapper.businessName = String.isNotBlank(lstTempHistory[0].Account__r.Name) ? lstTempHistory[0].Account__r.Name : 'N/A';
            bizPrimeLocationDetailsWrapper.businessALEI = String.isNotBlank(lstTempHistory[0].Account__r.Connecticut_ALEI__c) ? lstTempHistory[0].Account__r.Connecticut_ALEI__c : 'N/A';
            bizPrimeLocationDetailsWrapper.businessEmailNew = String.isNotBlank(lstTempHistory[0].Email_New__c) ? 
                                                                        lstTempHistory[0].Email_New__c :
                                                                        (String.isNotBlank(lstTempHistory[0].Business_Email_Address__c) ? 
                                                                                    lstTempHistory[0].Business_Email_Address__c :
                                                                                    (lstTempHistory[0].Account__c != null && String.isNotBlank(lstTempHistory[0].Account__r.Business_Email_Address__c) ?
                                                                                                lstTempHistory[0].Account__r.Business_Email_Address__c : 'N/A'));

            
            bizPrimeLocationDetailsWrapper.dateOfOrgMeeting = lstTempHistory[0].Date_of_Organization_Meeting_New__c != null ? 
                                                                        dateFormatMethod(lstTempHistory[0].Date_of_Organization_Meeting_New__c) :
                                                                        (lstTempHistory[0].Date_of_Organization_Meeting__c != null ? 
                                                                                    dateFormatMethod(lstTempHistory[0].Date_of_Organization_Meeting__c) :
                                                                                    (lstTempHistory[0].Account__c != null && lstTempHistory[0].Account__r.Date_of_Organization_Meeting__c != null) ?
                                                                                                dateFormatMethod(lstTempHistory[0].Account__r.Date_of_Organization_Meeting__c) : 'N/A');


            bizPrimeLocationDetailsWrapper.naicsNew = String.isNotBlank(lstTempHistory[0].NAICS_Code_New__c) ? 
                                                                        lstTempHistory[0].NAICS_Code_New__c :
                                                                        (String.isNotBlank(lstTempHistory[0].NAICS_Code__c) ? 
                                                                                    lstTempHistory[0].NAICS_Code__c :
                                                                                    (lstTempHistory[0].Account__c != null && String.isNotBlank(lstTempHistory[0].Account__r.NAICS_Code__c) ?
                                                                                                lstTempHistory[0].Account__r.NAICS_Code__c : 'N/A'));

            // first report business location details after updation
            // principal office address new
            if(String.isNotBlank(lstTempHistory[0].BillingStreet_New__c)) {

                principalOffcAddrNew = lstTempHistory[0].BillingStreet_New__c;
                principalOffcAddrNew += lstTempHistory[0].Business_Unit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Business_Unit__c + COMMA_SPACE_STRING : COMMA_SPACE_STRING;
                principalOffcAddrNew += lstTempHistory[0].Billing_City_New__c + COMMA_SPACE_STRING;
                principalOffcAddrNew += lstTempHistory[0].BillingState_New__c + SPACE;
                principalOffcAddrNew += lstTempHistory[0].BillingPostalCode_New__c + SPACE;
                principalOffcAddrNew += lstTempHistory[0].Billing_Country_New__c;
            }
            else if (String.isNotBlank(lstTempHistory[0].Business_InternationalAddress__c)) {
                principalOffcAddrNew = lstTempHistory[0].Business_InternationalAddress__c + COMMA_SPACE_STRING;
                principalOffcAddrNew += lstTempHistory[0].Billing_Country_New__c;
            }
            else {
                principalOffcAddrNew = 'None';
            }

            // mailing address new
            if(String.isNotBlank(lstTempHistory[0].ShippingStreet_New__c)) {

                mailingAddrNew = lstTempHistory[0].ShippingStreet_New__c;
                mailingAddrNew += lstTempHistory[0].Mailing_Unit__c != null ? COMMA_SPACE_STRING + lstTempHistory[0].Mailing_Unit__c + COMMA_SPACE_STRING : COMMA_SPACE_STRING;
                mailingAddrNew += lstTempHistory[0].ShippingCity_New__c + COMMA_SPACE_STRING;
                mailingAddrNew += lstTempHistory[0].ShippingState_New__c + SPACE;
                mailingAddrNew += lstTempHistory[0].ShippingPostalCode_New__c + SPACE;
                mailingAddrNew += lstTempHistory[0].Shipping_Country_New__c;
            }
            else if (String.isNotBlank(lstTempHistory[0].Mailing_International_Address_New__c)) {
                mailingAddrNew = lstTempHistory[0].Mailing_International_Address_New__c + COMMA_SPACE_STRING;
                mailingAddrNew += lstTempHistory[0].Shipping_Country_New__c;
            }
            else {
                mailingAddrNew = 'None';
            }

            bizPrimeLocationDetailsWrapper.principalOffcAddrNew = principalOffcAddrNew;
            bizPrimeLocationDetailsWrapper.mailingAddrNew = mailingAddrNew;
        
        }
        else {

            // first report primary details

            bizPrimeLocationDetailsWrapper.businessName = String.isNotBlank(lstBizFilings[0].Account__r.Name) ? lstBizFilings[0].Account__r.Name : 'N/A';
            bizPrimeLocationDetailsWrapper.businessALEI = String.isNotBlank(lstBizFilings[0].Account__r.Connecticut_ALEI__c) ? lstBizFilings[0].Account__r.Connecticut_ALEI__c : 'N/A';
            bizPrimeLocationDetailsWrapper.businessEmailNew = String.isNotBlank(lstBizFilings[0].Account__r.Business_Email_Address__c) ?
                                                                                                lstBizFilings[0].Account__r.Business_Email_Address__c : 'N/A';

            
            bizPrimeLocationDetailsWrapper.dateOfOrgMeeting = lstBizFilings[0].Account__r.Date_of_Organization_Meeting__c != null ?
                                                                                                dateFormatMethod(lstBizFilings[0].Account__r.Date_of_Organization_Meeting__c) : 'N/A';


            bizPrimeLocationDetailsWrapper.naicsNew = String.isNotBlank(lstBizFilings[0].Account__r.NAICS_Code__c) ?
                                                                                                lstBizFilings[0].Account__r.NAICS_Code__c : 'N/A';


            // first report business location details no updation
            // principal office address
            if(String.isNotBlank(lstBizFilings[0].Account__r.BillingStreet)) {

                principalOffcAddr = lstBizFilings[0].Account__r.BillingStreet;
                principalOffcAddr += lstBizFilings[0].Account__r.Billing_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Billing_Unit__c + COMMA_SPACE_STRING : COMMA_SPACE_STRING;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCity + COMMA_SPACE_STRING;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingState + SPACE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingPostalCode + SPACE;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry;
            }
            else if (String.isNotBlank(lstBizFilings[0].Account__r.Principle_Office_International_Address__c)) {
                principalOffcAddr = lstBizFilings[0].Account__r.Principle_Office_International_Address__c + COMMA_SPACE_STRING;
                principalOffcAddr += lstBizFilings[0].Account__r.BillingCountry;
            }
            else {
                principalOffcAddr = 'None';
            }

            // mailing address
            if(String.isNotBlank(lstBizFilings[0].Account__r.ShippingStreet)) {

                mailingAddr = lstBizFilings[0].Account__r.ShippingStreet;
                mailingAddr += lstBizFilings[0].Account__r.Shipping_Unit__c != null ? COMMA_SPACE_STRING + lstBizFilings[0].Account__r.Shipping_Unit__c + COMMA_SPACE_STRING : COMMA_SPACE_STRING;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCity + COMMA_SPACE_STRING;
                mailingAddr += lstBizFilings[0].Account__r.ShippingState + SPACE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingPostalCode + SPACE;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCountry;
            }
            else if (String.isNotBlank(lstBizFilings[0].Account__r.Mailing_International_Address__c)) {
                mailingAddr = lstBizFilings[0].Account__r.Mailing_International_Address__c + COMMA_SPACE_STRING;
                mailingAddr += lstBizFilings[0].Account__r.ShippingCountry;
            }
            else {
                mailingAddr = 'None';
            }

            bizPrimeLocationDetailsWrapper.principalOffcAddrNew = principalOffcAddr;
            bizPrimeLocationDetailsWrapper.mailingAddrNew = mailingAddr;
        }

        return bizPrimeLocationDetailsWrapper;        
    }

 @TestVisible
private static List<NintexDataWrappers.ARCurrentPrincipalInfoWrapper> getCurrentPrincipalInfo (String recordId){
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        List<Principal__c> lstPrincipals = new List<Principal__c>();
        List<Principal__c> lstEditedPrincipalsOldValues = new List<Principal__c>();
        List<Principal__c> lstDeletedPrincipals = new List<Principal__c>();
        List<Principal__c> lstPrincipalsOnAcc = new List<Principal__c>();
        List<Principal__c> lstPrincipalsPreviouslyExisting = new List<Principal__c>();
    	List<Principal__c> lstCreatedPrincipals = new List<Principal__c>();
        List<NintexDataWrappers.ARCurrentPrincipalInfoWrapper> lstCurrentPrincipalWrapper = new List<NintexDataWrappers.ARCurrentPrincipalInfoWrapper>();
        String businessType = EMPTY_STRING;
        String accId = EMPTY_STRING;

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ', Business_Filing__r.Account__c, Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Principal\' AND Business_Filing__c = :recordId WITH SECURITY_ENFORCED LIMIT 500';

        lstTempHistory = Database.query(sTempHistQuery);

        accId = [SELECT Id, Account__c FROM Business_Filing__c WHERE Id = :recordId WITH SECURITY_ENFORCED].Account__c;
		System.debug('Account ID:: '+accId);
        
        // fetch all Principals from Account
        String sPrincipalQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_PRINCIPAL).keySet()), ',') + ', Business_ID__r.Business_Type__c ';
        sPrincipalQuery += 'FROM Principal__c WHERE Business_ID__c = :accId WITH SECURITY_ENFORCED LIMIT 500';

        lstPrincipalsOnAcc = Database.query(sPrincipalQuery);

        if(!lstTempHistory.isEmpty()){
            businessType = lstTempHistory[0].Business_ID__r.Business_Type__c;

            // sort Temp History records as per the Change Type
            for(Temp_History__c tmpRec : lstTempHistory){
                if(tmpRec.Change_Type__c == 'Created'){
                    Principal__c principalRec = new Principal__c();
                    principalRec.Business_City__c = tmpRec.Business_City__c;
                    principalRec.Business_Street_Address_1__c = tmpRec.Business_Street_Address_1__c;
                    principalRec.Business_Street_Address_2__c = tmpRec.Business_Street_Address_2__c;
                    principalRec.Business_Zip_Code__c = tmpRec.Business_Zip_Code__c;
                    principalRec.Business_State__c = tmpRec.Business_State__c;
                    principalRec.Business_Country__c = tmpRec.Business_Country__c;
                    principalRec.Business_InternationalAddress__c = tmpRec.Business_InternationalAddress__c;
                    principalRec.Principal_Title__c = tmpRec.Title__c;
                    principalRec.FirstName__c = tmpRec.FirstName__c;
                    principalRec.LastName__c = tmpRec.LastName__c;
                    principalRec.Name__c = tmpRec.Name__c;
                    principalRec.Email__c = tmpRec.Email__c;
                    principalRec.Residence_City__c = tmpRec.Residence_City__c;
                    principalRec.Residence_Street_Address_1__c = tmpRec.Residence_Street_Address_1__c;
                    principalRec.Residence_Street_Address_2__c = tmpRec.Residence_Street_Address_2__c;
                    principalRec.Residence_Zip_Code__c = tmpRec.Residence_Zip_Code__c;
                    principalRec.Residence_State__c = tmpRec.Residence_State__c;
                    principalRec.Residence_Country__c = tmpRec.Residence_Country__c;
                    principalRec.Residence_InternationalAddress__c = tmpRec.Residence_InternationalAddress__c;
                    principalRec.Principal_Account_ID__c = tmpRec.Account__c;
                    principalRec.Business_ID__c = tmpRec.Business_Id__c;
                    principalRec.Designation__c = tmpRec.Designation__c;
                    principalRec.Business_Name__c = tmpRec.Temp_Type__c != null && tmpRec.Temp_Type__c == System.Label.Agent_Business_Option ? tmpRec.Name__c : '';
                    principalRec.Principal_Type__c = tmpRec.Temp_Type__c;
                   lstPrincipals.add(principalRec);
                }

                if(tmpRec.Change_Type__c == 'Edited'){
                    //Add the old values to a separate list
                    Principal__c principalRecOldValue = new Principal__c();
                    principalRecOldValue.Name__c = tmpRec.Name_Old__c;
                    principalRecOldValue.FirstName__c = tmpRec.FirstName_Old__c;
                    principalRecOldValue.LastName__c = tmpRec.LastName_Old__c;
                    principalRecOldValue.Principal_Type__c = tmpRec.Temp_Type__c;
                    principalRecOldValue.Principal_Title__c = tmpRec.Principal_Title__c;
                    principalRecOldValue.Designation__c = tmpRec.Designation_Old__c;
                    principalRecOldValue.Email__c = tmpRec.Email_Old__c;
                    principalRecOldValue.Residence_Street_Address_1__c = tmpRec.Residence_Street_Address1_Old__c;
                    principalRecOldValue.Residence_Street_Address_2__c = tmpRec.Residence_Street_Address_2_Old__c;
                    principalRecOldValue.Residence_City__c = tmpRec.Residence_City_Old__c;
                    principalRecOldValue.Residence_Country__c = tmpRec.Residence_Country_Old__c;
                    principalRecOldValue.Residence_State__c = tmpRec.Residence_State_Old__c;
                    principalRecOldValue.Residence_Zip_Code__c = tmpRec.Residence_Zip_Code_Old__c;
                    principalRecOldValue.Residence_InternationalAddress__c = tmpRec.Residence_InternationalAddress_Old__c;
                    principalRecOldValue.Business_InternationalAddress__c = tmpRec.Business_InternationalAddress_Old__c;
                    principalRecOldValue.Business_City__c = tmpRec.Business_City_Old__c;
                    principalRecOldValue.Business_Country__c = tmpRec.Business_Country_Old__c;
                    principalRecOldValue.Business_State__c = tmpRec.Business_State_Old__c;
                    principalRecOldValue.Business_Street_Address_1__c = tmpRec.Business_Street_Address_1_Old__c;
                    principalRecOldValue.Business_Street_Address_2__c = tmpRec.Business_Street_Address_2_Old__c;
                    principalRecOldValue.Business_Zip_Code__c = tmpRec.Business_Zip_Code_Old__c;
                    lstEditedPrincipalsOldValues.add(principalRecOldValue);

                    //Add the new values to a separate list
                    Principal__c principalRecNewValue = new Principal__c();
                    principalRecNewValue.Business_City__c = tmpRec.Business_City__c;
                    principalRecNewValue.Business_Street_Address_1__c = tmpRec.Business_Street_Address_1__c;
                    principalRecNewValue.Business_Street_Address_2__c = tmpRec.Business_Street_Address_2__c;
                    principalRecNewValue.Business_Zip_Code__c = tmpRec.Business_Zip_Code__c;
                    principalRecNewValue.Business_State__c = tmpRec.Business_State__c;
                    principalRecNewValue.Business_Country__c = tmpRec.Business_Country__c;
                    principalRecNewValue.Business_InternationalAddress__c = tmpRec.Business_InternationalAddress__c;
                    principalRecNewValue.Principal_Title__c = tmpRec.Title__c;
                    principalRecNewValue.FirstName__c = tmpRec.FirstName__c;
                    principalRecNewValue.LastName__c = tmpRec.LastName__c;
                    principalRecNewValue.Name__c = tmpRec.Name__c;
                    principalRecNewValue.Email__c = tmpRec.Email__c;
                    principalRecNewValue.Residence_City__c = tmpRec.Residence_City__c;
                    principalRecNewValue.Residence_Street_Address_1__c = tmpRec.Residence_Street_Address_1__c;
                    principalRecNewValue.Residence_Street_Address_2__c = tmpRec.Residence_Street_Address_2__c;
                    principalRecNewValue.Residence_Zip_Code__c = tmpRec.Residence_Zip_Code__c;
                    principalRecNewValue.Residence_State__c = tmpRec.Residence_State__c;
                    principalRecNewValue.Residence_Country__c = tmpRec.Residence_Country__c;
                    principalRecNewValue.Residence_InternationalAddress__c = tmpRec.Residence_InternationalAddress__c;
                    principalRecNewValue.Principal_Account_ID__c = tmpRec.Account__c;
                    principalRecNewValue.Business_ID__c = tmpRec.Business_Id__c;
                    principalRecNewValue.Designation__c = tmpRec.Designation__c;
                    principalRecNewValue.Business_Name__c = tmpRec.Temp_Type__c != null && tmpRec.Temp_Type__c == System.Label.Agent_Business_Option ? tmpRec.Name__c : '';
                    principalRecNewValue.Principal_Type__c = tmpRec.Temp_Type__c;
                    lstPrincipals.add(principalRecNewValue);
                }

                if(tmpRec.Change_Type__c == 'Deleted'){
                    Principal__c principalRec = new Principal__c();
                    principalRec.Name__c = tmpRec.Name_Old__c;
                    principalRec.FirstName__c = tmpRec.FirstName_Old__c;
                    principalRec.LastName__c = tmpRec.LastName_Old__c;
                    principalRec.Principal_Type__c = tmpRec.Temp_Type__c;
                    principalRec.Principal_Title__c = tmpRec.Principal_Title__c;
                    principalRec.Designation__c = tmpRec.Designation_Old__c;
                    principalRec.Email__c = tmpRec.Email_Old__c;
                    principalRec.Residence_Street_Address_1__c = tmpRec.Residence_Street_Address1_Old__c;
                    principalRec.Residence_Street_Address_2__c = tmpRec.Residence_Street_Address_2_Old__c;
                    principalRec.Residence_City__c = tmpRec.Residence_City_Old__c;
                    principalRec.Residence_Country__c = tmpRec.Residence_Country_Old__c;
                    principalRec.Residence_State__c = tmpRec.Residence_State_Old__c;
                    principalRec.Residence_Zip_Code__c = tmpRec.Residence_Zip_Code_Old__c;
                    principalRec.Residence_InternationalAddress__c = tmpRec.Residence_InternationalAddress_Old__c;
                    principalRec.Business_InternationalAddress__c = tmpRec.Business_InternationalAddress_Old__c;
                    principalRec.Business_City__c = tmpRec.Business_City_Old__c;
                    principalRec.Business_Country__c = tmpRec.Business_Country_Old__c;
                    principalRec.Business_State__c = tmpRec.Business_State_Old__c;
                    principalRec.Business_Street_Address_1__c = tmpRec.Business_Street_Address_1_Old__c;
                    principalRec.Business_Street_Address_2__c = tmpRec.Business_Street_Address_2_Old__c;
                    principalRec.Business_Zip_Code__c = tmpRec.Business_Zip_Code_Old__c;
                    lstDeletedPrincipals.add(principalRec);
                }
            }

            if(!lstPrincipalsOnAcc.isEmpty()){
                Boolean isSame = false;
                Boolean isDeletedPrSame = false;
                // Find the principals before annual filing
                if(!lstPrincipals.isEmpty()){
                    for(Principal__c prOnAcc : lstPrincipalsOnAcc){
                        // compare the list of principals on account with the newly created principals and edited principals' new values
                        for(Principal__c prFromTmpRec : lstPrincipals){
                            isSame = comparePrincipals(prOnAcc, prFromTmpRec, businessType);
                            if(isSame) {
                                break;
                            }
                        }
                        if(isSame){
                            continue;
                        }
                        else if(!isSame){
                            // compare the list of principals on account with the edited principals' old values
                            for(Principal__c prFromTmpRec : lstEditedPrincipalsOldValues){
                                isSame = comparePrincipals(prOnAcc, prFromTmpRec, businessType);
                                if(isSame) {
                                    break;
                                }
                            }
                            if(isSame){
                                continue;
                            }
                            else {
                                lstPrincipalsPreviouslyExisting.add(prOnAcc);
                            }                           
                        }
                    }
                }
                else{
                    lstPrincipalsPreviouslyExisting.addAll(lstPrincipalsOnAcc);
                }

                // From the list, remove the principals that were deleted in annual filing
                if(!lstPrincipalsPreviouslyExisting.isEmpty() && !lstDeletedPrincipals.isEmpty()){
                    for(Integer i = 0; i < lstPrincipalsPreviouslyExisting.size(); i++){
                        for(Principal__c delPr : lstDeletedPrincipals){
                            isDeletedPrSame = comparePrincipals(lstPrincipalsPreviouslyExisting[i], delPr, businessType);
                            if (isDeletedPrSame) {
                                break;
                            }
                        }
                        if(isDeletedPrSame){
                            lstPrincipalsPreviouslyExisting.remove(i);
                        }
                    }
                }
                if(!lstPrincipalsPreviouslyExisting.isEmpty()){
                    lstPrincipals.addAll(lstPrincipalsPreviouslyExisting);
                }
            }
        }
        else if(!lstPrincipalsOnAcc.isEmpty()) {
            businessType = lstPrincipalsOnAcc[0].Business_ID__r.Business_Type__c;
            lstPrincipalsPreviouslyExisting.addAll(lstPrincipalsOnAcc);
        }

        
        for(Principal__c pr : lstPrincipalsPreviouslyExisting) {
            String value = EMPTY_STRING;
            NintexDataWrappers.ARCurrentPrincipalInfoWrapper currentPrincipalWrapper = new NintexDataWrappers.ARCurrentPrincipalInfoWrapper();

            // set name details
            value = String.isNotBlank(pr.Name__c) ? pr.Name__c : EMPTY_STRING;
            currentPrincipalWrapper.principalName = value;
            
            // set designation details
            value = String.isNotBlank(pr.Designation__c) ? pr.Designation__c.escapeHtml4() : EMPTY_STRING;
            currentPrincipalWrapper.principalDesignation = value;
            
            // set title details
            value = String.isNotBlank(pr.Principal_Title__c) ? pr.Principal_Title__c.escapeHtml4() : EMPTY_STRING;
            currentPrincipalWrapper.principalTitle = value;

            // set business address details
            if(pr.Business_Street_Address_1__c != null) {
                value = pr.Business_Street_Address_1__c;
                value += pr.Business_Street_Address_2__c != null ? SPACE + pr.Business_Street_Address_2__c + COMMA + NEXT_LINE : COMMA_SPACE_STRING + NEXT_LINE;
                value += pr.Business_City__c + COMMA_SPACE_STRING;
                value += pr.Business_State__c + COMMA + NEXT_LINE;
                value += pr.Business_Zip_Code__c + COMMA + NEXT_LINE;
                value += pr.Business_Country__c;
            }
            else if(pr.Business_InternationalAddress__c != null) {
                value = pr.Business_InternationalAddress__c + COMMA + NEXT_LINE;
                value += pr.Business_Country__c;
            }
            else {
                value = 'None';
            }
            value = String.isNotBlank(value) ? value.escapeHtml4() : EMPTY_STRING;
            currentPrincipalWrapper.principalBusinessAddr = value;
            
            // set residence address details
            if(pr.Residence_Street_Address_1__c != null) {
                value = pr.Residence_Street_Address_1__c;
                value += pr.Residence_Street_Address_2__c != null ? SPACE + pr.Residence_Street_Address_2__c + COMMA + NEXT_LINE : COMMA_SPACE_STRING + NEXT_LINE;
                value += pr.Residence_City__c + COMMA_SPACE_STRING;
                value += pr.Residence_State__c + COMMA + NEXT_LINE;
                value += pr.Residence_Zip_Code__c + COMMA + NEXT_LINE;
                value += pr.Residence_Country__c;
            }
            else if(pr.Residence_InternationalAddress__c != null) {
                value = pr.Residence_InternationalAddress__c + COMMA + NEXT_LINE;
                value += pr.Residence_Country__c;
            }
            else {
                value = 'None';
            }
            value = String.isNotBlank(value) ? value.escapeHtml4() : EMPTY_STRING;
            currentPrincipalWrapper.principalResidenceAddr = value;

            lstCurrentPrincipalWrapper.add(currentPrincipalWrapper);
        }
        return lstCurrentPrincipalWrapper;
    }
    
    /**********************************************************************************************
     METHOD NAME    : comparePrincipals

     DESCRIPTION    : This method compares if two Principal records are identical or not.
                      
     PARAMETER      : SObject (Principal__c), SObject (Principal__c), String
    ***********************************************************************************************/
    @TestVisible
    private static Boolean comparePrincipals (Principal__c p1, Principal__c p2, String businessType){
        if(p1.Principal_Type__c == p2.Principal_Type__c && p1.Name__c == p2.Name__c) {
            Boolean isSame = true;
            isSame = isSame & p1.Email__c == p2.Email__c;
            isSame = isSame & (LIST_CORPORATION_BUSINESS_TYPES.contains(businessType) ? p1.Designation__c == p2.Designation__c : true);
            isSame = isSame & p1.Principal_Title__c == p2.Principal_Title__c;
            isSame = isSame & (p1.Principal_Type__c == 'Business' ? 
                                    fetchBusinessAddrStr(p1) == fetchBusinessAddrStr(p2) : 
                                    fetchResidenceAddrStr(p1) == fetchResidenceAddrStr(p2) && fetchBusinessAddrStr(p1) == fetchBusinessAddrStr(p2));
            return isSame;
        }
        else {
            return false;
        }
    }

    /**********************************************************************************************
     METHOD NAME    : fetchResidenceAddrStr

     DESCRIPTION    : This method fetches Residence Address from a Principal record
                      
     PARAMETER      : SObject (Principal__c)
    ***********************************************************************************************/
    @TestVisible
    private static String fetchResidenceAddrStr (Principal__c pr){
        String residenceAddr = EMPTY_STRING;
        if(String.isNotBlank(pr.Residence_InternationalAddress__c)) {
            residenceAddr = pr.Residence_InternationalAddress__c + (String.isNotBlank(pr.Residence_Country__c) ? COMMA_SPACE_STRING + pr.Residence_Country__c : EMPTY_STRING);
        }
        else if(String.isNotBlank(pr.Residence_Street_Address_1__c)){
            residenceAddr =  pr.Residence_Street_Address_1__c;
            residenceAddr += String.isNotBlank(pr.Residence_Street_Address_2__c) ? COMMA_SPACE_STRING + pr.Residence_Street_Address_2__c : EMPTY_STRING;
            residenceAddr += String.isNotBlank(pr.Residence_City__c) ? COMMA_SPACE_STRING + pr.Residence_City__c : EMPTY_STRING;
            residenceAddr += String.isNotBlank(pr.Residence_State__c) ? COMMA_SPACE_STRING + pr.Residence_State__c : EMPTY_STRING;
            residenceAddr += String.isNotBlank(pr.Residence_Zip_Code__c) ? COMMA_SPACE_STRING + pr.Residence_Zip_Code__c : EMPTY_STRING;
            residenceAddr += String.isNotBlank(pr.Residence_Country__c) ? COMMA_SPACE_STRING + pr.Residence_Country__c : EMPTY_STRING;
        }
        return String.isNotBlank(residenceAddr) ? residenceAddr.toLowerCase() : EMPTY_STRING;
    }

    /**********************************************************************************************
     METHOD NAME    : fetchBusinessAddrStr

     DESCRIPTION    : This method fetches Business Address from a Principal record
                      
     PARAMETER      : SObject (Principal__c)
    ***********************************************************************************************/
    @TestVisible
    private static String fetchBusinessAddrStr (Principal__c pr){
        String businessAddr = EMPTY_STRING;
        if(String.isNotBlank(pr.Business_InternationalAddress__c)) {
            businessAddr = pr.Business_InternationalAddress__c  + (String.isNotBlank(pr.Business_Country__c) ? COMMA_SPACE_STRING + pr.Business_Country__c : EMPTY_STRING);
        }
        else if(String.isNotBlank(pr.Business_Street_Address_1__c)){
            businessAddr =  pr.Business_Street_Address_1__c;
            businessAddr += String.isNotBlank(pr.Business_Street_Address_2__c) ? COMMA_SPACE_STRING + pr.Business_Street_Address_2__c : EMPTY_STRING;
            businessAddr += String.isNotBlank(pr.Business_City__c) ? COMMA_SPACE_STRING + pr.Business_City__c : EMPTY_STRING;
            businessAddr += String.isNotBlank(pr.Business_State__c) ? COMMA_SPACE_STRING + pr.Business_State__c : EMPTY_STRING;
            businessAddr += String.isNotBlank(pr.Business_Zip_Code__c) ? COMMA_SPACE_STRING + pr.Business_Zip_Code__c : EMPTY_STRING;
            businessAddr += String.isNotBlank(pr.Business_Country__c) ? COMMA_SPACE_STRING + pr.Business_Country__c : EMPTY_STRING;
        }
        return String.isNotBlank(businessAddr) ? businessAddr.toLowerCase() : EMPTY_STRING;
    }
    @TestVisible
    private static String dateFormatMethod(Date d) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        string strDate = dt.format('MM/dd/yyyy');
        return strDate;
    }
}