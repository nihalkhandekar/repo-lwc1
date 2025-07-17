/********************************************************************************************
* DESCRIPTION: Handle special chars in SOQL for Sdoc
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
* Shreya                        6/4/2021                   Handle special chars in SOQL for Sdoc
* Dharan                        6/4/2021                   BRS-4152 | BRS-4153 | Maintenance & Business Acknowledgement Templates
* Shreya                        7/6/2021                   BRS-2958 | Mark Search & Copy Reques on Certificate obj
*********************************************************************************************/
global without sharing class SdocTemplateServices implements Callable {
	private static final String AUTHORIZER_TITLE = 'authorizerTitle'; //response
    private static final String DATE_OF_NOTICE_PLUS_30 = 'dateOfNoticePlus30'; //response
	private static final String ACCOUNTID = 'account'; //request
	private static final String AUTHORIZER_NAME = 'authorizerName'; //request
	private static final String INCO_NAME = 'incorporatorName'; //request
	
	/**
	 * Callable interface for sdoc templates to call apex methods
	 */
	public Object call(String action, Map<String,Object> args) {
        switch on action {
            when 'getPrincipalTitle' {
                return this.getPrincipalTitle(args);
            }
            /*when 'getMarkSearches' {
                return this.getMarkSearches(args);
            }*/
            when 'getNoticeDatePlusThirtyDays' {
                return this.getNoticeDatePlusThirtyDays();
            }
           /* when 'getCopyRequestDetails' {
                return this.getCopyRequestDetails(args);
            }*/
            when 'getlongFormRejectReasonWRIT' {
                return this.getlongFormRejectReasonWRIT(args);
            }
        }

        return null;
    }

    /**
     * @desc: Get Principal Title - handling for special chars
     * @created: for Maintenance Acknowledgement
     */
	@TestVisible
    public Map<String,String> getPrincipalTitle(Map<String, Object> mapRecordIds) {
        Map<String,String> principalTitles = new Map<String,String>();
        
        if(!mapRecordIds.isEmpty()) {
            List<String> listAuthorizers = new List<String>();
            if(mapRecordIds.containsKey(AUTHORIZER_NAME)) {
				listAuthorizers.add(String.valueOf(mapRecordIds.get(AUTHORIZER_NAME)));
            } 
            if(mapRecordIds.containsKey(INCO_NAME)) {
				listAuthorizers.add(String.valueOf(mapRecordIds.get(INCO_NAME)));
            }
        
            List<Temp_History__c> listTempHistory = [
                SELECT Title__c 
                FROM Temp_History__c 
                WHERE Type__c = 'Principal' 
                    AND Business_Filing__c = :String.valueOf(mapRecordIds.get('recordId'))
                    AND Name__c IN :listAuthorizers
                    AND 
                    (
                        Change_Type__c = 'Edited' 
                        OR 
                        Change_Type__c = 'Created'
                    ) 
                    AND Title__c != null 
                LIMIT 1
            ];

            if(!listTempHistory.isEmpty()) {
                principalTitles.put(AUTHORIZER_TITLE, listTempHistory.get(0).Title__c);
            } else {
                List<Principal__c> listPrincipals = [
                    SELECT Principal_Title__c 
                    FROM Principal__c 
                    WHERE Business_ID__c = :String.valueOf(mapRecordIds.get(ACCOUNTID))
                        AND Name__c IN :listAuthorizers
                        AND Principal_Title__c != null 
                    LIMIT 1
                ];
            
                if(!listPrincipals.isEmpty()) {
                    principalTitles.put(AUTHORIZER_TITLE, listPrincipals.get(0).Principal_Title__c);
                }
            }
        }

        return principalTitles;
    }

    /**
     * @desc: Get search results for search of mark - SOSL and SQL on diff field matching criteria
     *  [Should have had picklist value as fieldAPI name to make solution generic & extendible]
     * @usage: Request for Search of Mark Template
     * @created: BRS-2958
     */
    /*@TestVisible
    private SDOC.SDUtil.SDocTable getMarkSearches(Map<String, Object> args) {
        SDOC.SDUtil.SDocTable table = new SDOC.SDUtil.SDocTable();
        
        if(args != null && !args.isEmpty()) {
            Integer index = 1;

            for(brs_InformationRequestForm.DataWrapper wrapper :brs_InformationRequestForm.getInformationRequestforSearch(
                String.valueOf(args.get('searchBy')), String.valueOf(args.get('searchFor')), String.valueOf(args.get('recordId')), false)
            ) {
                String renewalDate = wrapper.lapseDate != null 
                    ? wrapper.lapseDate.format()
                    : (wrapper.registerationDate != null ? wrapper.registerationDate.format() : '');

                SDOC.SDUtil.SDocTableRow row = new SDOC.SDUtil.SDocTableRow();
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.SNo.name(), ''+index));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.Description_of_Mark.name(), wrapper.description));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.Registration_number.name(), wrapper.filingNumber));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.Owner_Name.name(), wrapper.contactName));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.Renewal_Date.name(), renewalDate));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(MarkSearchHeaders.Class_of_Goods_Service.name(), wrapper.goodsClass));
                
                table.rows.add(row);
                index++;
            }
        }

        return table;
    }*/

    private enum MarkSearchHeaders {
        SNo, //index
        Description_of_Mark, //description
        Registration_number, //filingNumber
        Owner_Name, //contactName //contactName
        Renewal_Date, //lapseDate
        Class_of_Goods_Service //goodsClass
    }

    /**
     * @usage: Other Request Acceptance Letter
     * @desc: Permission issue across diff PS for BO agent
     */
    /*@TestVisible
    private SDOC.SDUtil.SDocTable getCopyRequestDetails(Map<String, Object> args) {
        SDOC.SDUtil.SDocTable table = new SDOC.SDUtil.SDocTable();
        
        if(args != null && !args.isEmpty()) {
            Integer index = 1;

            for(Copy_Request_Details__c requestDetail : [
                SELECT Number_of_Copies__c, Copy_Type__c,
                    Business_Filing__c, Business_Filing__r.Sdoc_Filing_Number__c, Business_Filing__r.Volume_Type__c, Business_Filing__r.Volume__c, Business_Filing__r.Start_Page__c, Business_Filing__r.Pages__c, //Business Filing
                    Mark_Filing__c, Mark_Filing__r.Sdoc_Filing_Number__c, Mark_Filing__r.Volume_Type__c, Mark_Filing__r.Volume__c, Mark_Filing__r.Start_Page__c, Mark_Filing__r.Pages__c, //Mark Filing
                    UCC_Filing__c, UCC_Filing__r.Sdoc_Filing_Number__c, UCC_Filing__r.Microfilm_volume_number__c, UCC_Filing__r.Start_Page__c, UCC_Filing__r.Pages__c //UCC
                FROM Copy_Request_Details__c
                WHERE Other_Request__c = :String.valueOf(args.get('filingId'))
            ]) {
                sObject lookupObj;    
                if(requestDetail.Business_Filing__c != null) {
                    lookupObj = requestDetail.Business_Filing__r;
                } else if(requestDetail.Mark_Filing__c != null) {
                    lookupObj = requestDetail.Mark_Filing__r;
                } else if(requestDetail.UCC_Filing__c != null) {
                    lookupObj = requestDetail.UCC_Filing__r;
                }

                String volumeType = requestDetail.UCC_Filing__c != null
                    ? ''
                    : String.valueOf(lookupObj.get('Volume_Type__c'));
                String volume = requestDetail.UCC_Filing__c != null
                    ? String.valueOf(lookupObj.get('Microfilm_volume_number__c'))
                    : String.valueOf(lookupObj.get('Volume__c'));
                

                SDOC.SDUtil.SDocTableRow row = new SDOC.SDUtil.SDocTableRow();
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Filing_Number.name(), String.valueOf(lookupObj.get('Sdoc_Filing_Number__c'))));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Copy_Type.name(), requestDetail.Copy_Type__c));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.No_Of_Copies.name(), requestDetail.Number_of_Copies__c != null ? String.valueOf(requestDetail.Number_of_Copies__c) : '1'));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Volume_Type.name(), volumeType));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Volume.name(), volume));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Start_Page.name(), String.valueOf(lookupObj.get('Start_Page__c'))));
                row.cells.add(new SDOC.SDUtil.SDocTableCell(CopyRequestHeader.Pages.name(), String.valueOf(lookupObj.get('Pages__c'))));
                            
                table.rows.add(row);
                index++;
            }
        }

        return table;
    }*/
    
    private enum CopyRequestHeader {
        Filing_Number,
        Copy_Type,
        No_Of_Copies,
        Volume_Type,
        Volume,
        Start_Page,
        Pages
    }

    /**
        @desc: BRS-4958 | ReqInfo File generation
     */
    @InvocableMethod(label='Generate Request for Information template')
    public static void generateRequestInformation(List<SdocTemplateServices.RequestWrapper> listRequests) {
        if(listRequests != null && !listRequests.isEmpty()) {
            PageReference pdf = Page.RequestInfoToPDF;
            pdf.setRedirect(false);
            pdf.getParameters().put('id', listRequests.get(0).requestId);

            Attachment attchmnt = new Attachment();
            attchmnt.ParentId = listRequests.get(0).requestId;
            attchmnt.Name = System.Label.Request_For_Information_Comparable + System.Label.PDF_Type_Extension;
            attchmnt.IsPrivate = false;
            Blob body = pdf.getContent();
            attchmnt.Body = body;
            insert attchmnt;
        }
    }

    public class RequestWrapper {
        @InvocableVariable(label='Other Request Id')
        public String requestId;
        @InvocableVariable(label='Sdoc Template Type')
        public String filingType;

        public RequestWrapper() {}

        public RequestWrapper(String requestId, String filingType) {
            this.requestId = requestId;
            this.filingType = filingType;
        }
    }

    
    /**
     * @desc: Show Date of Notice + 30days
     */
    @TestVisible
    private Map<String, String> getNoticeDatePlusThirtyDays() {
        return new Map<String, String> {
            DATE_OF_NOTICE_PLUS_30 => System.now().addDays(30).format()
        };
    }

    public Map<String,String> nintexRejectReasonWrit(Map<String,Object> mapRequest) {
        return getlongFormRejectReasonWRIT(mapRequest);
    }
	
	@TestVisible
    private Map<String,String> getlongFormRejectReasonWRIT(Map<String, Object> mapRecordIds) {
        String rejectReason = String.valueOf(mapRecordIds.get('Reason'));
        String customRejectReason = String.valueOf(mapRecordIds.get('CustomReason'));
        
        Map<String,String> response = new Map<String,String>();
        String val = '';
        List<String> rejReasonList = new List<String>();
        for(String rejReason: rejectReason.Split(';')){
            if(rejReason == 'Agent of record'){val += '<li> Service should be made on the agent of record (see enclosed printout). </li>';}
            if(rejReason == 'Check not signed'){val += '<li> The check enclosed with the service was not signed. </li>';}
            if(rejReason == 'Fee omitted'){val += '<li> The filing fee was omitted. The fee for each service is $50.00. </li>';}
            if(rejReason == 'Insufficient address'){val += '<li> The address of the defendant is insufficient. Please provide a complete address consisting of a P.O.Box or street number, if any, street, town, state and if necessary a country. </li>';}
            if(rejReason == 'Motion for default'){val += '<li> In some cases motions for default, small claim writs, appearances, mechanics liens, etc. may be filed in this office. Please see the Connecticut General Statutes for further information. Also, be advised that all submissions must meet the criteria required of a writ summons and complaint, i.e 1 ) proper fee, 2 ) defendant name & address clearly indicated, 3 ) proper number of copies, 4 ) attestation. </li>';}
            if(rejReason == 'Need attestation'){val += '<li> Service must have attestation with signature by serving officer or other person lawfully empowered to make service. </li>';}
            if(rejReason == 'Only 1 copy req'){val += '<li> This particular service of process requires only one copy of the service. This Office has accepted the service and is returning the extra copy that you submitted. Please check the statutes for situations when two copies of the service are required. </li>';}
            if(rejReason == 'Specify Def'){val += '<li> Please specify the defendant being served through this Office. </li>';}
            if(rejReason == 'Attempting to make service'){val += '<li> Please specify pursuant to what statute you are attempting to make service. </li>';}
            if(rejReason == 'Def address omitted'){val += '<li> The address of the defendant was omitted. </li>';}
            if(rejReason == 'Incorrect fee'){val += '<li> An incorrect filing fee was enclosed with the service. The fee for each service is $50.00. </li>';}
            if(rejReason == 'Long-arm statute'){val += '<li> This action arose in a jurisdiction other than Connecticut. Consult the "long-arm statute" of the jurisdiction where you are commencing the action to determine the proper method of service. Provide us with a Connecticut cite should you wish this Office to accept the service. </li>';} 
            if(rejReason == 'Need 2 copies'){val += '<li> Two true and attested copies of the service are required. </li>';}
            if(rejReason == 'No affidavit'){val += '<li> The service does not contain an affidavit from the serving officer, or other person lawfully empowered to make service, stating that a diligent search was made, and the agent and/or defendant could not be located. </li>';}
            if(rejReason == 'Pay to SOTS'){val += '<li> The check must be made payable to the Secretary of the State of Connecticut. </li>';}
            if(rejReason == 'Subpoena on behalf of a corp'){val += '<li> Our office cannot be served with a subpoena on behalf of any entity e.g corporation, limited partnership, limited liability company.. because we cannot serve as a clearinghouse for the appearance fee. Please check the appropriate Connecticut General Statute for service procedures. </li>';}
            
        }
            if(customRejectReason != '') {val += '<li> '+customRejectReason+' </li>';}
        response.put('reject_Reason', val );
        return response ;
    }
}