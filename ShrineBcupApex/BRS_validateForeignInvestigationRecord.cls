/******************************************************************************************************
* NAME:  		BRS_validateForeignInvestigationRecord
* DESCRIPTION:  Class to check if required fields contain value when staff tries to generate
                Demand Letter 1, Demand Letter 2, Demand Letter 3 or Settlement Letter
*
* @AUTHOR: 		Aparna Shahpurkar
* @DATE: 		3rd August, 2021
*******************************************************************************************************/
public class BRS_validateForeignInvestigationRecord {
        
    /*************************************************************************************************
        METHOD NAME    : checkRequiredFields
        DESCRIPTION    : Method to check if required fields contain values.
        PARAMETER      : List<FlowInputs>
    ***************************************************************************************************/
	@InvocableMethod(label='Check FI Record Fields')
    public static List<Results> checkRequiredFields(List<FlowInputs> inputVariables){
        List<Results> resultLst = new List<Results>();
        Results r = new Results();
        if(!inputVariables.isEmpty() && inputVariables[0].foreignInvestigationId != null && inputVariables[0].letterType != null){
            Foreign_Investigation__c currentFI = [SELECT Id, Case_Status__c, Due_Date__c, Latest_Letter_Type__c, Reminder__c, 
                                    Payment_Plan_Established__c, Date_Began_Transacting_Business_in_CT__c, Registration_Date__c,
                                    Business_Type__c, Business_Street_Address_1__c, Business_City__c, Business_State__c, 
                                    Business_Country__c, Business_Zip_Code__c
                                    FROM Foreign_Investigation__c 
                                    WHERE id = : inputVariables[0].foreignInvestigationId];
        	
            if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Demand_Letter1) || inputVariables[0].letterType.equalsIgnoreCase(System.label.Demand_Letter2) || inputVariables[0].letterType.equalsIgnoreCase(System.label.Final_Demand_Letter) || inputVariables[0].letterType.equalsIgnoreCase(System.label.Settlement_Letter)){
                if(currentFI.Date_Began_Transacting_Business_in_CT__c == null){
                    r.returnError = true;
                    r.returnErrorMssg = System.label.ForeignInvestigationReqFieldsErr1;
                }
                else if(currentFI.Registration_Date__c == null){
                    r.returnError = true;
                    r.returnErrorMssg = System.label.ForeignInvestigationReqFieldsErr;
                }
                else if(currentFI.Business_Type__c == null){
                    r.returnError = true;
                    r.returnErrorMssg = System.label.ForeignInvestigationReqFieldsErr2;
                }
                else if(currentFI.Business_Street_Address_1__c == null || currentFI.Business_City__c == null || currentFI.Business_State__c == null || currentFI.Business_Country__c == null || currentFI.Business_Zip_Code__c == null){
                    r.returnError = true;
                    r.returnErrorMssg = System.label.ForeignInvestigationReqFieldsErr3;
                }
                else{
                    r.returnError = false;
                }               
            }
            else if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Interrogatory_Letter)){
                r.returnError = false;
            }
                resultLst.add(r);
        }
        return resultLst;
    }
    
    public class FlowInputs{
        @InvocableVariable
        public String letterType;
        @InvocableVariable
        public Id foreignInvestigationId;
    }

    public class Results {
        @InvocableVariable
        public Boolean returnError;
        @InvocableVariable
        public String returnErrorMssg;
    }
}