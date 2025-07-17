/**********************************************************************************************
 NAME: ctds_flowStages
 DESCRIPTION: This class is used for creating side navigation and flow object
 @AUTHOR:Nate Shilling
 @DATE: 10-October-2020

 MODIFICATION LOG:
 DEVELOPER                         DATE: 19-October-2020         DESCRIPTION
 _____________________________________________________________________________________________
 Nate Shilling                                                  Created the first version  
 Sushri Sarita Nayak                                            Added Comparable Interface                                                                                                              updated framework logic
***********************************************************************************************/


public class ctds_flowStage implements Comparable{
    @AuraEnabled public String status;
    @AuraEnabled public String label;
    @AuraEnabled public String showWhen;
    @AuraEnabled public boolean show;
    @AuraEnabled public Integer order;
    @AuraEnabled public String pageNameRef;
    @AuraEnabled public boolean IsActive;
    @AuraEnabled public String lienType;
    @AuraEnabled public String flowName;
    @AuraEnabled public String masterLabel;
    @AuraEnabled public ctds_flowStage[] subsections;

    public ctds_flowStage(String status,string label,boolean show,Integer order,string pageNameRef,
    boolean IsActive,string lienType, String flowName,ctds_flowStage[] subsections){
        this.status = status;
        this.label = label;
        this.showWhen = showWhen;
        this.show = show;
        this.order =order;
        this.pageNameRef=pageNameRef;
        this.IsActive = IsActive;
        this.lienType = lienType;
        this.subsections = subsections;
        this.flowName = flowName;
    }
    /* The logic for sorting the object as per the order in Flowstages class */
    
    public Integer compareTo(Object compareTo) {
        ctds_flowStage varflowStage = (ctds_flowStage)compareTo;
        if (order == varflowStage.order) {
            return 0;
        }
        else if (order > varflowStage.order) {
            return 1;
        }
        else{
            return -1;
        }     
    } 
}