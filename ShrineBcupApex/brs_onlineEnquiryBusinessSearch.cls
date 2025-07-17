/* DESCRIPTION: This class contains methods to search businesses for online enquiry.
*
* @AUTHOR:  Priyanka
* @DATE:    2/1/2021
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka                         2/1/2021                           Created the first version
*********************************************************************************************/
public with sharing class brs_onlineEnquiryBusinessSearch {
    
    @AuraEnabled    
    public static brs_onlineEnquiryBusinessSearchBusCls.results getBusiness(String searchString,String type, List<brs_genericSearchBusinessClass.filterWrapper> filterList,Boolean isExportClicked, String name) {
          return brs_onlineEnquiryBusinessSearchBusCls.getBusiness(searchString,type,filterList,isExportClicked,name);   
    }
    
   
    /********************************************************************************************
    METHOD NAME    : getBusinessDetails
    DESCRIPTION    : to Get details of the select business in online enquiry search
    RETURN TYPE    : wrapper of business details
    Author         : Priyanka
    ********************************************************************************************/
    @AuraEnabled
    public static brs_onlineEnquiryBusinessSearchBusCls.businessDetails getBusinessDetails(String accountId){
        return brs_onlineEnquiryBusinessSearchBusCls.getBusinessDetails(accountId);      
    }
	
	
    /********************************************************************************************
    METHOD NAME    : getFilingDetails
    DESCRIPTION    : to Get details of the select busines filings in online enquiry search with the converted/domesticated and merged business details
    RETURN TYPE    : wrapper of business details
    Author         : Avinash
    *******************************************************************************************/
        
    @AuraEnabled
    public static brs_onlineEnquiryBusinessSearchBusCls.filingDetails getFilingDetails(Id businessFilingId) {
       return brs_onlineEnquiryBusinessSearchBusCls.getFilingDetails(businessFilingId);
    }
}