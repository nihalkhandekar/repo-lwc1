/* DESCRIPTION: This class is used to sort the List of Legal designators received from Metadata by comparing the length of characters 
				in each element. Implements Comparable.
*
* @AUTHOR: 	Aparna Shahapurkar
* @DATE: 	04/9/2021 
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                              DESCRIPTION
* -----------------------------------------------------------------------------------------------------------------------------------
* Aparna Shahapurkar               04/09/2021                   Created the first version
*************************************************************************************************************************************/

public with sharing class brs_SortLegalDesignators implements Comparable {
    public String Label {get;set;}

	// Constructor
    public brs_SortLegalDesignators(Legal_Designation__mdt designatorLabel) {
        this.Label = designatorLabel.Label;
    }
    
	// compareTo method implemented as part of the Comparable Interface to compare the elements in Metadata list
    public Integer compareTo(Object obj) {
        brs_SortLegalDesignators sortList = (brs_SortLegalDesignators)(obj);
        if (this.Label.length() < sortList.Label.length()) {                
            return 1;
        }
        if (this.Label.length() == sortList.Label.length()) {
            return 0;
        }        
        return -1;
    }
    
	/********************************************************************************************
        METHOD NAME    : getSortedList
        DESCRIPTION    : Method to retrieve sorted List of legal designators
        Return Type    : List<brs_SortLegalDesignators>
    ********************************************************************************************/
    public static List<brs_SortLegalDesignators> getSortedList() {        
        List<brs_SortLegalDesignators> sortedResult = new List<brs_SortLegalDesignators>();
        for (Legal_Designation__mdt legalDesignator :  BRS_Utility.getLegalDesignators()) {
            sortedResult.add(new brs_SortLegalDesignators(legalDesignator));
        }
        sortedResult.sort();
        return sortedResult;
    }
}