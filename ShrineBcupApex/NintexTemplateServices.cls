/* DESCRIPTION: For Nintex template mappings 
*
* @AUTHOR: 	Shreya Bordia
* @DATE: 	02/10/2021 
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ------------------------------------------------------------------------------------------------
* Sonika                            02/10/2021                          Other Request Mark Search Report
* Rabbani                           02/24/2021                          Other Request Longform Certificate
**************************************************************************************************/
global with sharing class NintexTemplateServices implements Loop.IApexDataSource {
    private string markWrapperName = 'MarkSearchWrapper';
    private string ChangeHistoryWrapperName = 'ChangeHistoryWrapper';
    private string CopyDetailsName = 'CopyRequestDetails';
    private string latModifiedWrapperName = 'LastModifiedWrapper';
    private string filingDateTimeData = 'FilingDateTimeformat';
    private string businessAdressChangeWrapper = 'BusinessAdressChangeWrapper';
    private String bizAcknowledgement = 'BusinessAcknowledgementWrapper';
    private String longformRejectReasonWRIT = 'LongformRejectReasonWRIT';
    private String filingDescription = 'FilingDescriptionValueInfo';
    /**
     * @desc: Return a set of object/wrapper class that this Apex class will provide data for.
     */
    public Set<string> getGlobalDescribe() {
        return new Set<string> {
            markWrapperName,
            ChangeHistoryWrapperName,
            CopyDetailsName,
            latModifiedWrapperName,
            filingDateTimeData,
            businessAdressChangeWrapper,
            bizAcknowledgement,
            longformRejectReasonWRIT,
            filingDescription
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
            if(objectName == markWrapperName) {
				describeObjectResults.add(getMarkSearchInfo(objectName));
            }else if(objectName == filingDescription) {
				describeObjectResults.add(getFilingDescription(objectName));
            }else if(objectName == ChangeHistoryWrapperName){
				describeObjectResults.add(getChangeHistoryInformation(objectName));
            }
            else if(objectName == CopyDetailsName){
				describeObjectResults.add(getCopyRequestDetailsInformation(objectName));
            }
            else if(objectName == latModifiedWrapperName){
				describeObjectResults.add(getLastModifiedProfileInfo(objectName));
            }
            else if(objectName == filingDateTimeData){
				describeObjectResults.add(getFilingDateAndTime(objectName));
            }else if(objectName == businessAdressChangeWrapper){
				describeObjectResults.add(getBusinessAdressChange(objectName));
            }
            else if(objectName == bizAcknowledgement){
                describeObjectResults.add(getBizAcknowledgementFieldInfo(objectName));
            }
            else if(objectName == longformRejectReasonWRIT) {
                describeObjectResults.add(getLongformRejectReasonWRIT(objectName));
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
            
            if(objectName == markWrapperName) {
                queryResult = getMarkSearchRecords(requestInfo, objectName, new List<String> {
                    'index',
                    'description',
                    'filingNumber',
                    'contactName',
                    'renewalDate',
                    'goodsClass'
                });
            }
            else if(objectName == filingDescription) {
                queryResult = getFilingDescriptionRecords(requestInfo, objectName, new List<String> {
                    'filingDescription',
                    'filingValue'
                });
            }
            else if(objectName == ChangeHistoryWrapperName) {
                queryResult = getLongformFilingHistory(requestInfo, objectName, new List<string> {
                    'filingType',
                    'filingDate',
                    'effectiveDate',
                    'changeHistoryOldValue',
                    'changeHistoryNewValue'
                });
            }

            else if(objectName == CopyDetailsName) {
                queryResult = getCopyDetails(requestInfo, objectName, new List<String>{
                    'Filing_Number',
                    'Copy_Type',
                    'No_Of_Copies',
                    'Volume_Type',
                    'Volume',
                    'Start_Page',
                    'Pages'
                });
            }

            else if(objectName == latModifiedWrapperName) {
                queryResult = getProfileName(requestInfo, objectName, new List<String> {
                    'profileName'
                });
            }

            else if(objectName == filingDateTimeData) {
                queryResult = getFilingValue(requestInfo, objectName, new List<String> {
                    'FilingDateTime'
                });
            }
            else if(objectName == businessAdressChangeWrapper) {
                queryResult = getEmailAddressChangeInfo(requestInfo, objectName, new List<String> {
                    'authorizerName','authorizerTitle','filerName','filerSignature','executionDate'
                });
            }
            else if (objectName == bizAcknowledgement) {
                queryResult = getBusinessAcknowledgement(requestInfo, objectName);
            }
            else if (objectName == longformRejectReasonWRIT) {
                queryResult = getRejectReasonWRIT(requestInfo, objectName);
            }
            // This needs to be done for every object specified in requestInfo.GetObjectNames(), 
            //regardless of whether data is required for the request.
            queryResultSet.add(queryResult);
        }
        
        return queryResultSet;
    }

    //-------------- Mark Search Report -----------------
    @TestVisible
    private Loop.ExternalData.DataObject getMarkSearchInfo(String obj) {
        Loop.ExternalData.FieldInfo index = new Loop.ExternalData.FieldInfo('index', Schema.DisplayType.String);
        index.label = 'Index';
        Loop.ExternalData.FieldInfo description = new Loop.ExternalData.FieldInfo('description', Schema.DisplayType.String);
        description.label = 'Description of Mark';
        Loop.ExternalData.FieldInfo filingNumber = new Loop.ExternalData.FieldInfo('filingNumber', Schema.DisplayType.String);
        filingNumber.label = 'Registration #';
        Loop.ExternalData.FieldInfo contactName = new Loop.ExternalData.FieldInfo('contactName', Schema.DisplayType.String);
        contactName.label = 'Owner Name';
        Loop.ExternalData.FieldInfo renewalDate = new Loop.ExternalData.FieldInfo('renewalDate', Schema.DisplayType.String);
        renewalDate.label = 'Date of Registration or Latest Renewal';
        Loop.ExternalData.FieldInfo goodsClass = new Loop.ExternalData.FieldInfo('goodsClass', Schema.DisplayType.String);
        goodsClass.label = 'Class of Goods or Services';
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            index,
            description,
            filingNumber,
            contactName,
            renewalDate,
            goodsClass
        });
    }
    @TestVisible
    private Loop.ExternalData.DataObject getFilingDescription(String obj) {
        Loop.ExternalData.FieldInfo filingDescription = new Loop.ExternalData.FieldInfo('filingDescription', Schema.DisplayType.String);
        filingDescription.label = 'Filing Description';
        Loop.ExternalData.FieldInfo filingValue = new Loop.ExternalData.FieldInfo('filingValue', Schema.DisplayType.String);
        filingValue.label = 'Filing Value';
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            filingDescription,
            filingValue
        });
    }
    // map results to nintex wrapperx
    @TestVisible
    private Loop.ExternalData.QueryResult getMarkSearchRecords(Loop.ExternalData.QueryRequestInfo requestInfo, String obj , List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
        
        Integer index = 1;
        Certficate__c request = [
            SELECT Search_by__c, Search_for__c
            FROM Certficate__c
            WHERE Id = :requestInfo.RecordId WITH SECURITY_ENFORCED
        ];
        String searchBy = request.Search_by__c, searchFor = request.Search_for__c;
        
        for(brs_InformationRequestForm.DataWrapper wrapper :brs_InformationRequestForm.getInformationRequestforSearch(searchBy, searchFor,requestInfo.RecordId, false)) {
            String renewalDate = wrapper.lapseDate != null 
                    ? wrapper.lapseDate.format()
                    : (wrapper.registerationDate != null ? wrapper.registerationDate.format() : '');
            
            List<String> listFieldValues = new List<String> {
                index + '',
                wrapper.description,
                wrapper.filingNumber,
                wrapper.contactName,
                renewalDate,
                wrapper.goodsClass
            };
                
            queryResult.rows.add(listFieldValues);
            index++;
        }

        return queryResult;
    }
@TestVisible
 private Loop.ExternalData.QueryResult getFilingDescriptionRecords(Loop.ExternalData.QueryRequestInfo requestInfo, String obj , List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
        NintexDataWrappers.filingDescriptionValueInfo wrapper = new NintexDataWrappers.filingDescriptionValueInfo();
        String objName = SchemaUtility.getObjectFromId(requestInfo.RecordId).getName();
        if(objName == 'Mark_Filing__c'){
            Mark_Filing__c request = [
                SELECT Description_of_Mark__c,Mark__r.Description_of_Mark__c,Filing_Type__c
                FROM Mark_Filing__c
                WHERE Id = :requestInfo.RecordId WITH SECURITY_ENFORCED
            ];
            if(request.Filing_Type__c == 'Registration')
            {
                if(request.Description_of_Mark__c !=null)
            {
                wrapper.filingDescription=request.Description_of_Mark__c;
            }
            else{
                wrapper.filingDescription='N/A';
            }
            }
            else if(request.Filing_Type__c == 'Renewal' || request.Filing_Type__c == 'Assignment' || request.Filing_Type__c == 'Owner Name Change' || request.Filing_Type__c== 'Owner Address Change' || request.Filing_Type__c == 'State of Formation Change')
            {
                 if(request.Mark__r.Description_of_Mark__c !=null)
            {
                wrapper.filingDescription=request.Mark__r.Description_of_Mark__c;
            }
            else{
                wrapper.filingDescription='N/A';
            }
            }        
        }else if(objName == 'UCC_Filing__c'){
            UCC_Filing__c uccFiling = [Select Id,Type__c, Description__c,Collateral_Information__c,Type_of_Collateral_Update__c,Assignment_Type__c from UCC_Filing__c where Id =: requestInfo.RecordId WITH SECURITY_ENFORCED];
            if(uccFiling.Type__c == 'Amendment' && (uccFiling.Type_of_Collateral_Update__c !=null || uccFiling.Assignment_Type__c =='Partial assignment'))
            {
                if(uccFiling.Collateral_Information__c != null)
                {
                    wrapper.filingValue='This financing statement covers the following collateral:';
                    wrapper.filingDescription = uccFiling.Collateral_Information__c;
                }
                else{
                wrapper.filingValue='This financing statement covers the following collateral:';
                wrapper.filingDescription = 'Attachment of collateral has been included with filing.';
            }
            }
            else
            {
                if(uccFiling.Description__c != null){
                wrapper.filingDescription = uccFiling.Description__c;
            }else{
                wrapper.filingDescription = 'Attachment of collateral has been included with filing.';
            }
            }       
        }
            List<String> listFieldValues = new List<String> {
                wrapper.filingDescription,
                 wrapper.filingValue
            };   
            queryResult.rows.add(listFieldValues);
        return queryResult;
    }



    // --------------- Last Modifier for acceptance/rejection letters -----------
    @TestVisible
    private Loop.ExternalData.DataObject getLastModifiedProfileInfo(String obj) {
        Loop.ExternalData.FieldInfo profileName = new Loop.ExternalData.FieldInfo('profileName', Schema.DisplayType.String);
        profileName.label = 'Profile Name';
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            profileName
        });
    }

    // -------------- Name Change history for Certificate longform ---------
    @TestVisible
    private Loop.ExternalData.DataObject getChangeHistoryInformation(String obj) {
        Loop.ExternalData.FieldInfo filingType = new Loop.ExternalData.FieldInfo('filingType', Schema.DisplayType.String);
        filingType.label = 'Filing Type';
        Loop.ExternalData.FieldInfo filingDate = new Loop.ExternalData.FieldInfo('filingDate', Schema.DisplayType.String);
        filingDate.label = 'Filing Date';
        Loop.ExternalData.FieldInfo effectiveDate = new Loop.ExternalData.FieldInfo('effectiveDate', Schema.DisplayType.String);
        effectiveDate.label = 'Effective Date';
        
        Loop.ExternalData.FieldInfo changeHistoryOldValue = new Loop.ExternalData.FieldInfo('changeHistoryOldValue', Schema.DisplayType.String);
        changeHistoryOldValue.label = 'Chnage History Old Value';
        Loop.ExternalData.FieldInfo changeHistoryNewValue = new Loop.ExternalData.FieldInfo('changeHistoryNewValue', Schema.DisplayType.String);
        changeHistoryNewValue.label = 'Change History New Value';
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            filingType,
            filingDate,
            effectiveDate,
            changeHistoryOldValue,
            changeHistoryNewValue
        });
    }

    // --------- Copy Request details on Other Request Acceptance letter -----------
    @TestVisible
    private Loop.ExternalData.DataObject getCopyRequestDetailsInformation(String obj) {
        Loop.ExternalData.FieldInfo Filing_Number = new Loop.ExternalData.FieldInfo('Filing_Number', Schema.DisplayType.String);
        Filing_Number.label = 'Filing Number';
        Loop.ExternalData.FieldInfo Copy_Type = new Loop.ExternalData.FieldInfo('Copy_Type', Schema.DisplayType.String);
        Copy_Type.label = 'Copy Type';
        Loop.ExternalData.FieldInfo No_Of_Copies = new Loop.ExternalData.FieldInfo('No_Of_Copies', Schema.DisplayType.String);
        No_Of_Copies.label = 'Number of Copies';
        
        Loop.ExternalData.FieldInfo Volume_Type = new Loop.ExternalData.FieldInfo('Volume_Type', Schema.DisplayType.String);
        Volume_Type.label = 'Volume Type';
        Loop.ExternalData.FieldInfo Volume = new Loop.ExternalData.FieldInfo('Volume', Schema.DisplayType.String);
        Volume.label = 'Volume';
        Loop.ExternalData.FieldInfo Start_Page = new Loop.ExternalData.FieldInfo('Start_Page', Schema.DisplayType.String);
        Start_Page.label = 'Start Page';
        Loop.ExternalData.FieldInfo Pages = new Loop.ExternalData.FieldInfo('Pages', Schema.DisplayType.String);
        Pages.label = 'Pages';
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            Filing_Number,
            Copy_Type,
            No_Of_Copies,
            Volume_Type,
            Volume,
            Start_Page,
            Pages
        });
    }

    @TestVisible
    private Loop.ExternalData.DataObject getFilingDateAndTime(String obj) {
        Loop.ExternalData.FieldInfo FilingDateTime = new Loop.ExternalData.FieldInfo('FilingDateTime', Schema.DisplayType.String);
        FilingDateTime.label = 'Filing Date Time';
        
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            FilingDateTime
        });
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getCopyDetails(Loop.ExternalData.QueryRequestInfo requestInfo, String obj, List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
		
		for(brs_InformationRequestForm.CopyRequestDetails wrapper :brs_InformationRequestForm.getCopyDetailsData(requestInfo.RecordId)) {
            queryResult.rows.add(new List<String> {
                wrapper.Filing_Number,
                wrapper.Copy_Type,
                wrapper.No_Of_Copies,
                wrapper.Volume_Type,
                wrapper.Volume,
                wrapper.Start_Page,
                wrapper.Pages
            });
        }

        return queryResult;
    }

    // ------------ Get last modifier's profile for all acceptance/rejection letters 
    @TestVisible
    private Loop.ExternalData.QueryResult getProfileName(Loop.ExternalData.QueryRequestInfo requestInfo, String obj, List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
		
        String objName = SchemaUtility.getObjectFromId(requestInfo.recordId).getName();
		sObject record = Database.query(
            'SELECT LastModifiedBy.Profile.Name'
            +' FROM ' + objName
            +' WHERE Id = \'' + requestInfo.recordId + '\''
        );

        //get last modifier's profile
        queryResult.rows.add(new List<String> {
            String.valueOf(record.getSobject('lastmodifiedby').getSobject('profile').get('name'))
        });

        return queryResult;
    }
    
    //----------- for other request longform certificate --------------
    @TestVisible
    private Loop.ExternalData.QueryResult getLongformFilingHistory(Loop.ExternalData.QueryRequestInfo requestInfo, String obj , List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
		
		for(brs_InformationRequestForm.ChangeHistoryWrapper wrapper :brs_InformationRequestForm.getChangeHistoryData(requestInfo.RecordId)) {
            queryResult.rows.add(new List<String> {
                wrapper.filingType,
                wrapper.filingDate,
                wrapper.effectiveDate,
                wrapper.changeHistoryOldValue,
                wrapper.changeHistoryNewValue
            });
        }

        return queryResult;
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getFilingValue(Loop.ExternalData.QueryRequestInfo requestInfo, String obj , List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
		
		for(brs_InformationRequestForm.FilingDateTimeformat wrapper :brs_InformationRequestForm.getFilingDateTimeformat(requestInfo.RecordId)) {
            queryResult.rows.add(new List<String> {
                wrapper.FilingDateTime
            });
        }

        return queryResult;
    }

    @TestVisible
    private Loop.ExternalData.DataObject getBusinessAdressChange(String obj) {
        Loop.ExternalData.FieldInfo authorizerName = new Loop.ExternalData.FieldInfo('authorizerName', Schema.DisplayType.String);
        authorizerName.label = 'authorizerName';
        Loop.ExternalData.FieldInfo authorizerTitle = new Loop.ExternalData.FieldInfo('authorizerTitle', Schema.DisplayType.String);
        authorizerTitle.label = 'authorizerTitle';
        Loop.ExternalData.FieldInfo filerName = new Loop.ExternalData.FieldInfo('filerName', Schema.DisplayType.String);
        filerName.label = 'filerName';
        Loop.ExternalData.FieldInfo filerSignature = new Loop.ExternalData.FieldInfo('filerSignature', Schema.DisplayType.String);
        filerSignature.label = 'filerSignature';
        Loop.ExternalData.FieldInfo executionDate = new Loop.ExternalData.FieldInfo('executionDate', Schema.DisplayType.String);
        executionDate.label = 'executionDate';
        
        
        return new Loop.ExternalData.DataObject(obj, new List<Loop.ExternalData.FieldInfo> {
            authorizerName,authorizerTitle,filerName,filerSignature,executionDate
        });
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getEmailAddressChangeInfo(Loop.ExternalData.QueryRequestInfo requestInfo, String obj , List<string> fields) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj,fields);
        List<Business_Filing__c> lstBusinessFiling = new List<Business_Filing__c>();
        Map<String, Object> mapRecordIds = new Map<String, Object>();
        Map<String,String> mapAuthTitle = new Map<String,String>();
		if(requestInfo.RecordId!=null){
            lstBusinessFiling = [Select id ,Account__c, Work_Order__r.Customer__r.Name , Filing_Date__c , Signatory_Name__c , Signatory_Title__c, Review_Selected_Principal__c from Business_Filing__c where id =: requestInfo.RecordId WITH SECURITY_ENFORCED];
            mapRecordIds.put('recordId',requestInfo.RecordId);
        }
        if(!lstBusinessFiling.isEmpty() && lstBusinessFiling[0].Review_Selected_Principal__c!=null){
            mapRecordIds.put('authorizerName',lstBusinessFiling[0].Review_Selected_Principal__c);
            mapRecordIds.put('account',lstBusinessFiling[0].Account__c);
        }
        SdocTemplateServices sdoc = new SdocTemplateServices();
        mapAuthTitle = sdoc.getPrincipalTitle(mapRecordIds);
        
		for(Business_Filing__c busFile :lstBusinessFiling) {
            BusinessAdressChangeWrapper wrapper = new BusinessAdressChangeWrapper();
            if(busFile.Signatory_Name__c!=null){
                wrapper.authorizerName = busFile.Signatory_Name__c;
            }else if(busFile.Review_Selected_Principal__c!=null){
                wrapper.authorizerName = busFile.Review_Selected_Principal__c;
            }else{
                wrapper.authorizerName = 'N/A';
            }
            if(busFile.Signatory_Title__c!=null){
                wrapper.authorizerTitle =  busFile.Signatory_Title__c;
            }else if(mapAuthTitle!=null && mapAuthTitle.get('authorizerTitle')!=null){
                wrapper.authorizerTitle =  mapAuthTitle.get('authorizerTitle');
            }
            
            if(busFile.Work_Order__c!=null && busFile.Work_Order__r.Customer__c!=null && busFile.Work_Order__r.Customer__r.Name!=null){
                wrapper.filerSignature = busFile.Work_Order__r.Customer__r.Name;
                wrapper.filerName = busFile.Work_Order__r.Customer__r.Name;
            }else{
                wrapper.filerSignature = 'N/A';
                wrapper.filerName = 'N/A';
            }
            if(busFile.Filing_Date__c!=null){
                wrapper.executionDate = string.valueOf(busFile.Filing_Date__c);
            }else{
                wrapper.executionDate = 'N/A';
            }
        
            queryResult.rows.add(new List<String> {
                wrapper.authorizerName,
                wrapper.authorizerTitle,
                wrapper.filerSignature,
                wrapper.filerName,
                wrapper.executionDate
            });
        }

        return queryResult;
    }

   
    public without sharing class BusinessAdressChangeWrapper {
        public String authorizerName;
        public String authorizerTitle;
        public String filerName;
        public String filerSignature;
        public String executionDate;
    }

    /**
     * Start - Dharan Shah - Business Acknowledgement fields info
     */
     @TestVisible
    private Loop.ExternalData.DataObject getBizAcknowledgementFieldInfo(String objectName) {
        Loop.ExternalData.FieldInfo designatorsNameLabel = new Loop.ExternalData.FieldInfo('designatorsNameLabel', Schema.DisplayType.String);
        designatorsNameLabel.label = 'designatorsNameLabel';

        Loop.ExternalData.FieldInfo designatorsName = new Loop.ExternalData.FieldInfo('designatorsName', Schema.DisplayType.String);
        designatorsName.label = 'designatorsName';

        Loop.ExternalData.FieldInfo designatorsTitleLabel = new Loop.ExternalData.FieldInfo('designatorsTitleLabel', Schema.DisplayType.String);
        designatorsTitleLabel.label = 'designatorsTitleLabel';

        Loop.ExternalData.FieldInfo designatorsTitle = new Loop.ExternalData.FieldInfo('designatorsTitle', Schema.DisplayType.String);
        designatorsTitle.label = 'designatorsTitle';
        
        return new Loop.ExternalData.DataObject(
            objectName, 
            new List<Loop.ExternalData.FieldInfo> { designatorsNameLabel, designatorsName, designatorsTitleLabel, designatorsTitle });
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getBusinessAcknowledgement(Loop.ExternalData.QueryRequestInfo requestInfo, String objectName) {
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, new List<String>{'designatorsNameLabel', 'designatorsName', 'designatorsTitleLabel', 'designatorsTitle'});
        NintexDataWrappers.BusinessAcknowledgementWrapper bizAcknowledgeWrapper = new NintexDataWrappers.BusinessAcknowledgementWrapper();
        SdocTemplateServices sdocServices = new SdocTemplateServices();
        Map<String, Object> mapRecordIds = new Map<String, Object>();
        Map<String, String> mapAuthTitle = new Map<String, String>();
        String businessFilingId = (String) requestInfo.RecordId;

        if(String.isNotBlank(businessFilingId)) {
            List<Business_Filing__c> lstBizFiling = [SELECT Id, Account__c, Citizenship__c, Business_Type__c, Type__c, Signatory_Name__c, Organizer_Name__c, Name_of_Incorporator__c, Review_Selected_Principal__c, 
                                                            Choose_Principal_or_Incorporator__c, Signatory_Title__c, Organizer_Title__c, Title_of_Incorporator__c
                                                    FROM Business_Filing__c
                                                    WHERE Id = :businessFilingId WITH SECURITY_ENFORCED];

            if(!lstBizFiling.isEmpty()) {
                mapRecordIds.put('recordId', businessFilingId);
                mapRecordIds.put('authorizerName', lstBizFiling[0].Review_Selected_Principal__c);
                mapRecordIds.put('account', lstBizFiling[0].Account__c);
                mapRecordIds.put('incorporatorName', lstBizFiling[0].Choose_Principal_or_Incorporator__c);
                mapAuthTitle = sdocServices.getPrincipalTitle(mapRecordIds);

                bizAcknowledgeWrapper.designatorsNameLabel = (lstBizFiling[0].Citizenship__c == 'Domestic' && lstBizFiling[0].Business_Type__c == 'LLC') ? 'Name of Organizer:' : (
                                                                lstBizFiling[0].Citizenship__c == 'Foreign' || (lstBizFiling[0].Citizenship__c == 'Domestic' && lstBizFiling[0].Business_Type__c == 'LLP') ? 'Name of Signatory:' : (
                                                                    lstBizFiling[0].Citizenship__c == 'Domestic' && (lstBizFiling[0].Business_Type__c == 'B Corp' || lstBizFiling[0].Business_Type__c == 'Stock' || lstBizFiling[0].Business_Type__c == 'Non-Stock') ? 'Name of Incorporator:' : ''
                                                                )
                                                            );

                bizAcknowledgeWrapper.designatorsName = String.isNotBlank(lstBizFiling[0].Signatory_Name__c) ? lstBizFiling[0].Signatory_Name__c : (
                                                            String.isNotBlank(lstBizFiling[0].Organizer_Name__c) ? lstBizFiling[0].Organizer_Name__c : (
                                                                String.isNotBlank(lstBizFiling[0].Name_of_Incorporator__c) ? lstBizFiling[0].Name_of_Incorporator__c : (
                                                                    String.isNotBlank(lstBizFiling[0].Review_Selected_Principal__c) ? lstBizFiling[0].Review_Selected_Principal__c : (
                                                                        String.isNotBlank(lstBizFiling[0].Choose_Principal_or_Incorporator__c) ? lstBizFiling[0].Choose_Principal_or_Incorporator__c : 'N/A'
                                                                    )
                                                                )
                                                            )
                                                        );

                bizAcknowledgeWrapper.designatorsTitleLabel = (lstBizFiling[0].Type__c == 'Business Formation' && lstBizFiling[0].Business_Type__c == 'LLC') ? 'Organizer Title:' : (
                                                                lstBizFiling[0].Citizenship__c == 'Foreign' || (lstBizFiling[0].Citizenship__c == 'Domestic' && lstBizFiling[0].Business_Type__c == 'LLP') ? 'Signatory Title:' : (
                                                                    lstBizFiling[0].Type__c == 'Business Formation' && (lstBizFiling[0].Business_Type__c == 'B Corp' || lstBizFiling[0].Business_Type__c == 'Stock' || lstBizFiling[0].Business_Type__c == 'Non-Stock') ? 'Incorporator Title:' : ''
                                                                )
                                                            );

                bizAcknowledgeWrapper.designatorsTitle = String.isNotBlank(lstBizFiling[0].Signatory_Title__c) ? lstBizFiling[0].Signatory_Title__c : (
                                                            String.isNotBlank(lstBizFiling[0].Organizer_Title__c) ? lstBizFiling[0].Organizer_Title__c : (
                                                                String.isNotBlank(lstBizFiling[0].Title_of_Incorporator__c) ? lstBizFiling[0].Title_of_Incorporator__c : (
                                                                    !mapAuthTitle.isEmpty() ? mapAuthTitle.get('authorizerTitle') : 'N/A'
                                                                )
                                                            )
                                                        );                                                        
            }
        }

        queryResult.rows.add(new List<String> {
            bizAcknowledgeWrapper.designatorsNameLabel,
            bizAcknowledgeWrapper.designatorsName,
            bizAcknowledgeWrapper.designatorsTitleLabel,
            bizAcknowledgeWrapper.designatorsTitle
        });

        return queryResult;
    }
    /**
     * End - Dharan Shah - Business Acknowledgement fields info
     */

    // ---------------------------Start - WRIT Rejection Reason----------------------------------- //
    @TestVisible
    private Loop.ExternalData.DataObject getLongformRejectReasonWRIT(String objectName) {
        Loop.ExternalData.FieldInfo sResponse = new Loop.ExternalData.FieldInfo('sResponse', Schema.DisplayType.String);
        sResponse.label = 'sResponse';
        
        return new Loop.ExternalData.DataObject(
            objectName, 
            new List<Loop.ExternalData.FieldInfo> { sResponse });
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getRejectReasonWRIT(Loop.ExternalData.QueryRequestInfo requestInfo, String objectName) {
        List<String> lstRejectReasons = new List<String>();
        Map<String,String> mapResponse = new Map<String,String>();
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, new List<String>{'sResponse'});

        String recordId = (String)requestInfo.RecordId;
        if(String.isNotBlank(recordId)) {
            List<Defendants__c> lstDefendants = [SELECT Id, Rejection_Reason__c, Rejection_custom_reason__c
                                                FROM Defendants__c
                                                WHERE Id = :recordId WITH SECURITY_ENFORCED];

            if(!lstDefendants.isEmpty()) {
                Map<String,Object> mapRequest = new Map<String,Object>();
                mapRequest.put('Reason', lstDefendants[0].Rejection_Reason__c != null ? lstDefendants[0].Rejection_Reason__c : '');
                mapRequest.put('CustomReason', lstDefendants[0].Rejection_custom_reason__c != null ? lstDefendants[0].Rejection_custom_reason__c : '');
                SdocTemplateServices serviceClass = new SdocTemplateServices();
                mapResponse = serviceClass.nintexRejectReasonWrit(mapRequest);
                String s = mapResponse.get('reject_Reason').replace('<li> ','');
                lstRejectReasons = s.split(' </li>');

                for(String rejectReason : lstRejectReasons) {
                    NintexDataWrappers.LongformRejectReasonWRIT writRejectReasonWrapper = new NintexDataWrappers.LongformRejectReasonWRIT();
                    if(String.isNotBlank(rejectReason)) {
                        writRejectReasonWrapper.sResponse = rejectReason;
                        queryResult.rows.add(new List<String> {
                            writRejectReasonWrapper.sResponse
                        });
                    }
                }
            }
        }

        return queryResult;
    }
    
    // ---------------------------End - WRIT Rejection Reason----------------------------------- //

}