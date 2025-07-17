/* DESCRIPTION: This class is used to fetch the legal designation associated with an account business type.
*
* @AUTHOR: 	Priyanka Sharma
* @DATE: 	10/30/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka Sharma                   10/30/2020                   Created the first version
*********************************************************************************************/

global without sharing class brs_legalDesignation {
    public static Final String className='brs_legalDesignation';
    @AuraEnabled
    public static List<SObject> getLegalDesignations(Id accId){
        try{
            List<String> legalDesignationList = new List<String>();
            List<SObject> legalDesgMdtList = new List<SObject>();
            String legalDesgName = [Select Business_Type__c from Account where id=: accId].Business_Type__c;
            if(!String.isBlank(legalDesgName)){
                legalDesgMdtList = [Select Label, Legal_Designator__c from Legal_Designation__mdt where Legal_Designator__c =:legalDesgName];
            }
            return legalDesgMdtList;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getLegalDesignations', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @InvocableMethod
    public static List<Results> getLegalDesignationsInv(List<Requests> Requests){
        try{
            List<Results> lstResults = new List<Results>();
            List<String> legalDesignationList = new List<String>();
            List<SObject> legalDesgMdtList = new List<SObject>();
            if(!Requests.isEmpty() && Requests[0].accId!=null){
                Account accRec = [Select Business_Type__c,Professional_Corporation__c,citizenship__c from Account where id=: Requests[0].accId];
                if(accRec!=null){
                    List<String> labelList = new List<String>();
                    labelList.add(System.Label.ProfessionalCorp);
                    labelList.add(System.Label.P_C);
                    labelList.add(System.Label.PC);
					//Same query call reduction as part of code review activity
					list<Legal_Designation__mdt> legalDesgMdtListResult = [Select Label,order__c, Legal_Designator__c from Legal_Designation__mdt where Legal_Designator__c =:accRec.Business_Type__c and order__c!=null order by order__c asc ];
                    
                    /*if(accRec.Business_Type__c ==System.Label.Stock && accRec.citizenship__c==System.Label.brs_maintenance_domestic && accRec.Professional_Corporation__c==System.Label.Professional_Corp_Yes){
                        //legalDesgMdtList = [Select Label, Legal_Designator__c,order__c from Legal_Designation__mdt where Legal_Designator__c =:accRec.Business_Type__c and Label in : labelList order by order__c asc ];
						for(Legal_Designation__mdt legal : legalDesgMdtListResult){
							if(labelList.contains(legal.label)){
								legalDesgMdtList.add(legal);
							}
						}
                    }
                    else if (accRec.Business_Type__c ==System.Label.Stock && accRec.citizenship__c==System.Label.brs_maintenance_domestic && accRec.Professional_Corporation__c==System.Label.Professional_Corp_No)
                    {
                        for(Legal_Designation__mdt legal : legalDesgMdtListResult){
							if(!labelList.contains(legal.label)){
								legalDesgMdtList.add(legal);
							}
						}
                    }
                    else{*/
                        legalDesgMdtList.addAll(legalDesgMdtListResult);
                    //}
                }
                if(!legalDesgMdtList.isEmpty()){
                    Results r = new Results();
                    r.records = Json.serialize(legalDesgMdtList);
                    lstResults.add(r);
                }
            }
            return lstResults;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getLegalDesignations', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    global without sharing class Requests {
        @InvocableVariable
        global string accId;
    }    
      global without sharing class Results {
        @InvocableVariable
        global string records;
    }
	    @AuraEnabled
    public static String getAccountName(Id accId){
        try{
            String accountname=QnA_Constants.EMPTY_STRING;
            if(accId!=null){
                accountname = [Select name from Account where id=: accId].name;
            }
            
            return accountname;
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(className, 'getAccountName', 'Account', null, BOS_Utility.sSeverity, ex, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}