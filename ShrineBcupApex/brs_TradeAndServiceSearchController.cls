/* DESCRIPTION: This class contains methods to search Marks for online enquiry.
*
* @AUTHOR:  Avinash Shukla
* @DATE:    25-06-2021
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Avinash Shukla                    25-06-2021                          Created the first version
*********************************************************************************************/
public with sharing class brs_TradeAndServiceSearchController {
   
    @AuraEnabled
    public static brs_TradeAndServiceSearchCntrlBusCls.results getMarkSearchList(String searchString, List<brs_genericSearchBusinessClass.filterWrapper> filterList, Boolean isExportClicked) {
      return brs_TradeAndServiceSearchCntrlBusCls.getMarkSearchLists(searchString,filterList,isExportClicked);
        
    }

    @AuraEnabled
    public static brs_TradeAndServiceSearchCntrlBusCls.searchData getSelectedTradeAndServiceMarkDetails(String markId) {
        return brs_TradeAndServiceSearchCntrlBusCls.getSelectedTradeAndServiceMarkDetails(markId);
        
    }

    @AuraEnabled
    public static string retFormattedDate(Date dateVal) {
       return brs_TradeAndServiceSearchCntrlBusCls.retFormattedDate(dateVal);
    }
        
}