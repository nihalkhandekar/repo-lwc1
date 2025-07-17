global class NintexPackageServices implements Loop.IApexDataSource {
    /**
     * Return a set of object names that this Apex class will provide data for.
     * [All wrapper/apex logic goes here]
     */
    private static final String REQUEST_FOR_INFO = 'RequestForInformation';
    private static final String ANNUAL_REPORT = 'AnnualReport'; //to-do
    private static final String MARK_SEARCH = 'MarkSearchReport';
    
    public Set<String> getGlobalDescribe() {
        // In this example, we will provide data for a single Opportunity.
        return new Set<String> {
            REQUEST_FOR_INFO,
            MARK_SEARCH //,
            //'UCC_Filing__c',
            //'UCC_Related_Info__c'
        };
    }
    
    /**
     * Return a set of object names corresponding to the children for the objectName specified
     */
    public Set<String> getChildRelationships(String obj) {
        Set<String> listChildObjs = new Set<String>();

        switch on obj {
            when 'RequestForInformation' {//1. For Request For Information
            }
            
            /*
            when ANNUAL_REPORT { //2. For Annual Report
                //to-do
            }
            when MARK_SEARCH { //3. For Mark Search Report
                //
            }
            when else { //4. For SF object
                //nop   
            }
            */
        } 

        return listChildObjs;
    }
    
    /**
     * All fields in obj/wrapper
     */
    public List<Loop.ExternalData.DataObject> describeObjects(List<String> listObjects) {
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>(); //schema mapping

        for(String obj :listObjects) {
            switch on obj {
                when 'RequestForInformation' {//1. For Request For Information
                    describeObjectResults.add(getRequestForInfo(obj));
                }
            }   
        }

        return describeObjectResults;
    }
    
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        //1. Provide data for each object in requestInfo.GetObjectNames()
        
        //2. Get record id in reqest

        //3. Return resultSet
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        
        for(String obj : requestInfo.getObjectNames()) {
            Loop.ExternalData.QueryResult queryResult;

            switch on obj {
                when 'RequestForInformation' {//1. For Request For Information
                    queryResult = getRequestForInfoRecords(requestInfo, obj);
                }
            }  

            queryResultSet.add(queryResult);
        }
        
        return queryResultSet;
    }
    
    // Helper method
    
    // This method properly retrieves a field value from an SObject for fields used through lookup relationships, 
    // e.g. PricebookEntry.Product2.ProductCode on the OpportunityLineItem object.
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

    /**
     * Store info for each property in wrapper as field
     */
    @TestVisible
    private Loop.ExternalData.DataObject getRequestForInfo(String obj) {
        Loop.ExternalData.FieldInfo filingNumber = new Loop.ExternalData.FieldInfo('filingNumber', Schema.DisplayType.String);
        filingNumber.label = 'filingNumber';
        Loop.ExternalData.FieldInfo filingType = new Loop.ExternalData.FieldInfo('filingType', Schema.DisplayType.String);
        filingType.label = 'filingType';
        Loop.ExternalData.FieldInfo lapseDate = new Loop.ExternalData.FieldInfo('lapseDate', Schema.DisplayType.Date);
        lapseDate.label = 'lapseDate';
        Loop.ExternalData.FieldInfo filingDate = new Loop.ExternalData.FieldInfo('filingDate', Schema.DisplayType.DateTime);
        filingDate.label = 'filingDate';
        
        List<Loop.ExternalData.FieldInfo> fields = new List<Loop.ExternalData.FieldInfo> {
            filingNumber,
            filingType,
            lapseDate,
            filingDate
        };
        System.debug('fields added: '+ fields);
        
        // Declare variable to add to results list using fields described above
        return new Loop.ExternalData.DataObject(obj, fields);
    }

    @TestVisible
    private Loop.ExternalData.QueryResult getRequestForInfoRecords(Loop.ExternalData.QueryRequestInfo requestInfo, String obj) {
        List<String> fields = new List<String> {
            'filingNumber',
            'filingType',
            'lapseDate',
            'filingDate'
        };
        System.debug('fields added: '+ fields);
    
        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(obj, fields);
        RequestForInformationController requestInfoCntrl = new RequestForInformationController(requestInfo.RecordId);

        for(RequestForInformationController.FilingWrapper wrapper : requestInfoCntrl.filings) {
            queryResult.rows.add(new List<String> {
                wrapper.filing.Sdoc_Filing_Number__c,
                wrapper.filing.Type__c,
                wrapper.filing.UCC_Lien_Id__r.Lapse_Date__c.format(),
                wrapper.filing.Filing_Date__c.format()
            });
        }

        return queryResult;
    }
}