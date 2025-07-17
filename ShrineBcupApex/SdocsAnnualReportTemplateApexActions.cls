/******************************************************************************************************
* NAME:  		SdocsAnnualReportTemplateApexActions
* DESCRIPTION:  This class is called from Annual Report S-Docs template to fetch data of 
*               Principals added, removed or existing on the Business
*
* @AUTHOR: 		Dharan Shah
* @DATE: 		12th June, 2021
*******************************************************************************************************/

global without sharing class SdocsAnnualReportTemplateApexActions implements Callable {
    private static final String EMPTY_STRING = '';
    private static final String COMMA_SPACE_STRING = ', ';
    private static final String SPACE = ' ';
    private static final String COMMA = ',';
    private static final String NEXT_LINE = '\n';
    private static final String HEADER_NAME = 'Name';
    private static final String HEADER_DESIGNATION = 'Designation';
    private static final String HEADER_TITLE = 'Title';
    private static final String HEADER_BUSINESS_ADDRESS = 'BusinessAddress';
    private static final String HEADER_RESIDENCE_ADDRESS = 'ResidenceAddress';
    private static final String MESSAGE_NO_NEW_PRINCIPAL = 'No new principals added';
    private static final String MESSAGE_NO_PRINCIPAL_REMOVED = 'No principals removed';
    private static final String OBJ_TEMP_HISTORY = 'Temp_History__c';
    private static final String OBJ_PRINCIPAL = 'Principal__c';
    private static final List<String> LIST_CORPORATION_BUSINESS_TYPES = new List<String>{'Stock', 'Non-Stock', 'B Corp', 'Stock Corporation', 'Non-Stock Corporation', 'Benefit Corporation'};

    public Object call(String action, Map<String,Object> args) {
        /*switch on action {
            when 'getLineItemsAsSDocTable' {
                return this.getLineItemsAsSDocTable((String)args.get('recordId'), (String)args.get('accId'));
            }
            when 'getLineItemsAsSDocTableNewPrincipal' {
                return this.getLineItemsAsSDocTableNewPrincipal((String)args.get('recordId'));
            }
            when 'getLineItemsAsSDocTableDeletedPrincipal' {
                return this.getLineItemsAsSDocTableDeletedPrincipal((String)args.get('recordId'));
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }*/
        return null;
    }

    public class ExtensionMalformedCallException extends Exception {}

    /**********************************************************************************************
     METHOD NAME    : getLineItemsAsSDocTable

     DESCRIPTION    : This method was made because Annual Report filing data is updated on related 
                      objects of Business Filing in a @future method.
                      This method fetches Principals present on the Account after an Annual Report
                      is filed. Data is fetched from Temp History records on Business Filing
                      and Principals on Account, to compare and identify the final set of 
                      Principals after the filing is approved, and sends it to the S-Docs template.

     PARAMETER      : String (Business_Filing__c Id), String (Account Id)
    ***********************************************************************************************/
    /*public SDOC.SDUtil.SDocTable getLineItemsAsSDocTable (String recordId, String accId){
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        List<Principal__c> lstPrincipals = new List<Principal__c>();
        List<Principal__c> lstEditedPrincipalsOldValues = new List<Principal__c>();
        List<Principal__c> lstDeletedPrincipals = new List<Principal__c>();
        List<Principal__c> lstPrincipalsOnAcc = new List<Principal__c>();
        List<Principal__c> lstPrincipalsPreviouslyExisting = new List<Principal__c>();
        List<Principal__c> tmpListDesOfficer = new List<Principal__c>();
        List<Principal__c> tmpListDesDir = new List<Principal__c>();
        List<Principal__c> tmpListDesOfficerDir = new List<Principal__c>();
        List<Principal__c> tmpListDesNull = new List<Principal__c>();
        String businessType = EMPTY_STRING;

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ',Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Principal\' AND Business_Filing__c = :recordId LIMIT 500';

        lstTempHistory = Database.query(sTempHistQuery);

        // fetch all Principals from Account
        String sPrincipalQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_PRINCIPAL).keySet()), ',') + ',Business_ID__r.Business_Type__c ';
        sPrincipalQuery += 'FROM Principal__c WHERE Business_ID__c = :accId LIMIT 500';

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
            lstPrincipals.addAll(lstPrincipalsOnAcc);
        }

        // sort principals by their designation
        if(!lstPrincipals.isEmpty()) {
            for(Principal__c pr : lstPrincipals){
                if(pr.Designation__c == 'Officer'){
                    tmpListDesOfficer.add(pr);
                }
                else if(pr.Designation__c == 'Director'){
                    tmpListDesDir.add(pr);
                }
                else if(pr.Designation__c == 'Officer;Director'){
                    pr.Designation__c = 'Officer &amp; Director';
                    tmpListDesOfficerDir.add(pr);
                }
                else if(pr.Designation__c == null){
                    tmpListDesNull.add(pr);
                }
            }
            lstPrincipals.clear();
            lstPrincipals.addAll(tmpListDesOfficer);
            lstPrincipals.addAll(tmpListDesDir);
            lstPrincipals.addAll(tmpListDesOfficerDir);
            lstPrincipals.addAll(tmpListDesNull);
        }

        List<String> lstHeaders = new List<String>{ HEADER_NAME, HEADER_DESIGNATION, HEADER_TITLE, HEADER_BUSINESS_ADDRESS, HEADER_RESIDENCE_ADDRESS };
        
        SDOC.SDUtil.SDocTable table = new SDOC.SDUtil.SDocTable();

        for(Principal__c pr : lstPrincipals) {
            String value = EMPTY_STRING;
            SDOC.SDUtil.SDocTableRow row = new SDOC.SDUtil.SDocTableRow();

            // set name details
            value = String.isNotBlank(pr.Name__c) ? pr.Name__c.escapeHtml4() : EMPTY_STRING;
            row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_NAME, value));
            
            // set designation details
            if(LIST_CORPORATION_BUSINESS_TYPES.contains(businessType)) {
                value = String.isNotBlank(pr.Designation__c) ? pr.Designation__c.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_DESIGNATION, value));
            }      

            // set title details
            value = String.isNotBlank(pr.Principal_Title__c) ? pr.Principal_Title__c.escapeHtml4() : EMPTY_STRING;
            row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_TITLE, value));

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
            row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_BUSINESS_ADDRESS, value));
            
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
            row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_RESIDENCE_ADDRESS, value));

            table.rows.add(row);
        }
        return table;
    }*/

    /**********************************************************************************************
     METHOD NAME    : getLineItemsAsSDocTableNewPrincipal

     DESCRIPTION    : This method was made to reduce SOQLs in Annual Report S-Docs template. 
                      The method fetches newly created Principals from Temp History records.
                      
     PARAMETER      : String (Business_Filing__c Id)
    ***********************************************************************************************/
    /*public SDOC.SDUtil.SDocTable getLineItemsAsSDocTableNewPrincipal (String recordId){
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        List<Temp_History__c> lstPrincipals = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesOfficer = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesDir = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesOfficerDir = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesNull = new List<Temp_History__c>();
        String businessType = EMPTY_STRING;
        List<String> lstHeaders = new List<String>{ HEADER_NAME, HEADER_DESIGNATION, HEADER_TITLE, HEADER_BUSINESS_ADDRESS, HEADER_RESIDENCE_ADDRESS };

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ',Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Principal\' AND Business_Filing__c = :recordId AND Change_Type__c = \'Created\' LIMIT 100';

        lstTempHistory = Database.query(sTempHistQuery);

        SDOC.SDUtil.SDocTable table = new SDOC.SDUtil.SDocTable();

        if(!lstTempHistory.isEmpty()){
            businessType = lstTempHistory[0].Business_ID__r.Business_Type__c;

            // sort the temp history records as per designation
            for(Temp_History__c pr : lstTempHistory){
                if(pr.Designation__c == 'Officer'){
                    tmpListDesOfficer.add(pr);
                }
                else if(pr.Designation__c == 'Director'){
                    tmpListDesDir.add(pr);
                }
                else if(pr.Designation__c == 'Officer;Director'){
                    pr.Designation__c = 'Officer &amp; Director';
                    tmpListDesOfficerDir.add(pr);
                }
                else if(pr.Designation__c == null){
                    tmpListDesNull.add(pr);
                }
            }
            lstPrincipals.addAll(tmpListDesOfficer);
            lstPrincipals.addAll(tmpListDesDir);
            lstPrincipals.addAll(tmpListDesOfficerDir);
            lstPrincipals.addAll(tmpListDesNull);

            for(Temp_History__c pr : lstPrincipals) {
                String value = EMPTY_STRING;
                SDOC.SDUtil.SDocTableRow row = new SDOC.SDUtil.SDocTableRow();

                // set name details
                value = String.isNotBlank(pr.Name__c) ? pr.Name__c.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_NAME, value));
                
                // set designation details
                if(LIST_CORPORATION_BUSINESS_TYPES.contains(businessType)) {
                    value = String.isNotBlank(pr.Designation__c) ? pr.Designation__c.escapeHtml4() : EMPTY_STRING;
                    row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_DESIGNATION, value));
                }  

                // set title details
                value = String.isNotBlank(pr.Title__c) ? pr.Title__c.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_TITLE, value));

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
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_BUSINESS_ADDRESS, value));
                
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
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_RESIDENCE_ADDRESS, value));

                table.rows.add(row);
            }
        }

        return table;
    }*/

    /**********************************************************************************************
     METHOD NAME    : getLineItemsAsSDocTableDeletedPrincipal

     DESCRIPTION    : This method was made to reduce SOQLs in Annual Report S-Docs template. 
                      The method fetches deleted Principals from Temp History records.
                      
     PARAMETER      : String (Business_Filing__c Id)
    ***********************************************************************************************/
    /*public SDOC.SDUtil.SDocTable getLineItemsAsSDocTableDeletedPrincipal (String recordId){
        List<Temp_History__c> lstTempHistory = new List<Temp_History__c>();
        List<Temp_History__c> lstPrincipals = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesOfficer = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesDir = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesOfficerDir = new List<Temp_History__c>();
        List<Temp_History__c> tmpListDesNull = new List<Temp_History__c>();
        String businessType = EMPTY_STRING;

        // fetch Temp History records on the Business Filing
        String sTempHistQuery = 'SELECT ' + String.join(new List<String>(SchemaUtility.getFields(OBJ_TEMP_HISTORY).keySet()), ',') + ',Business_ID__r.Business_Type__c ';
        sTempHistQuery += 'FROM Temp_History__c WHERE Type__c = \'Principal\' AND Change_Type__c = \'Deleted\' AND Business_Filing__c = :recordId LIMIT 100';

        lstTempHistory = Database.query(sTempHistQuery);

        SDOC.SDUtil.SDocTable table = new SDOC.SDUtil.SDocTable();

        if(!lstTempHistory.isEmpty()){
            businessType = lstTempHistory[0].Business_ID__r.Business_Type__c;
            
            // sort the temp history records as per designation
            for(Temp_History__c pr : lstTempHistory){
                if(pr.Designation_Old__c == 'Officer'){
                    tmpListDesOfficer.add(pr);
                }
                else if(pr.Designation_Old__c == 'Director'){
                    tmpListDesDir.add(pr);
                }
                else if(pr.Designation_Old__c == 'Officer;Director'){
                    pr.Designation_Old__c = 'Officer &amp; Director';
                    tmpListDesOfficerDir.add(pr);
                }
                else if(pr.Designation_Old__c == null){
                    tmpListDesNull.add(pr);
                }
            }
            lstPrincipals.addAll(tmpListDesOfficer);
            lstPrincipals.addAll(tmpListDesDir);
            lstPrincipals.addAll(tmpListDesOfficerDir);
            lstPrincipals.addAll(tmpListDesNull);

            List<String> lstHeaders = new List<String>{ HEADER_NAME, HEADER_DESIGNATION, HEADER_TITLE, HEADER_BUSINESS_ADDRESS, HEADER_RESIDENCE_ADDRESS };
            
            for(Temp_History__c pr : lstPrincipals) {
                String value = EMPTY_STRING;
                SDOC.SDUtil.SDocTableRow row = new SDOC.SDUtil.SDocTableRow();

                // set name details
                value = String.isNotBlank(pr.Name_Old__c) ? pr.Name_Old__c.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_NAME, value));
                
                // set designation details
                if(LIST_CORPORATION_BUSINESS_TYPES.contains(businessType)) {
                    value = String.isNotBlank(pr.Designation_Old__c) ? pr.Designation_Old__c.escapeHtml4() : EMPTY_STRING;
                    row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_DESIGNATION, value));
                }

                // set title details
                value = String.isNotBlank(pr.Principal_Title__c) ? pr.Principal_Title__c.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_TITLE, value));

                // set business address details
                if(pr.Business_Street_Address_1_Old__c != null) {
                    value = pr.Business_Street_Address_1_Old__c;
                    value += pr.Business_Street_Address_2_Old__c != null ? SPACE + pr.Business_Street_Address_2_Old__c + COMMA + NEXT_LINE : COMMA_SPACE_STRING + NEXT_LINE;
                    value += pr.Business_City_Old__c + COMMA_SPACE_STRING;
                    value += pr.Business_State_Old__c + COMMA + NEXT_LINE;
                    value += pr.Business_Zip_Code_Old__c + COMMA + NEXT_LINE;
                    value += pr.Business_Country_Old__c;
                }
                else if(pr.Business_InternationalAddress_Old__c != null) {
                    value = pr.Business_InternationalAddress_Old__c + COMMA + NEXT_LINE;
                    value += pr.Business_Country_Old__c;
                }
                else {
                    value = 'None';
                }
                value = String.isNotBlank(value) ? value.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_BUSINESS_ADDRESS, value));
                
                // set residence address details
                if(pr.Residence_Street_Address1_Old__c != null) {
                    value = pr.Residence_Street_Address1_Old__c;
                    value += pr.Residence_Street_Address_2_Old__c != null ? SPACE + pr.Residence_Street_Address_2_Old__c + COMMA + NEXT_LINE : COMMA_SPACE_STRING + NEXT_LINE;
                    value += pr.Residence_City_Old__c + COMMA_SPACE_STRING;
                    value += pr.Residence_State_Old__c + COMMA + NEXT_LINE;
                    value += pr.Residence_Zip_Code_Old__c + COMMA + NEXT_LINE;
                    value += pr.Residence_Country_Old__c;
                }
                else if(pr.Residence_InternationalAddress_Old__c != null) {
                    value = pr.Residence_InternationalAddress_Old__c + COMMA + NEXT_LINE;
                    value += pr.Residence_Country_Old__c;
                }
                else {
                    value = 'None';
                }
                value = String.isNotBlank(value) ? value.escapeHtml4() : EMPTY_STRING;
                row.cells.add(new SDOC.SDUtil.SDocTableCell(HEADER_RESIDENCE_ADDRESS, value));

                table.rows.add(row);
            }
        }

        return table;
    }*/

    /**********************************************************************************************
     METHOD NAME    : comparePrincipals

     DESCRIPTION    : This method compares if two Principal records are identical or not.
                      
     PARAMETER      : SObject (Principal__c), SObject (Principal__c), String
    ***********************************************************************************************/
    public Boolean comparePrincipals (Principal__c p1, Principal__c p2, String businessType){
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
    public static String fetchResidenceAddrStr (Principal__c pr){
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
    public static String fetchBusinessAddrStr (Principal__c pr){
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
}