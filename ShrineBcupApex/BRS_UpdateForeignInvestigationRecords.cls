public with sharing class BRS_UpdateForeignInvestigationRecords {
	public static final string CLASSNAME = 'BRS_UpdateForeignInvestigationRecords';
    
    @AuraEnabled
    public static String validateNewRecord(String foreignInvestigationId, String letterType){
        String returnMessage = '';
		        
        if(foreignInvestigationId != null && (letterType != null || letterType != '')){
            Integer recordCount = [SELECT COUNT() FROM Foreign_Investigation_Mail_Tracking__c WHERE Foreign_Investigation__c = :foreignInvestigationId and Type__c = :letterType WITH SECURITY_ENFORCED];
            if(recordCount > 0){
                returnMessage = System.label.brs_alreadySelectedLetterTypeMssg;
            }
        }
        return returnMessage;
    }

	@InvocableMethod(label='Update Due Date and Status')
    public static void updateFIDueDate(List<FlowInputs> inputVariables){
        if(!inputVariables.isEmpty() && inputVariables[0].foreignInvestigationId != null && inputVariables[0].letterType != null){
            Foreign_Investigation__c currentFI = [SELECT Id, Case_Status__c, Due_Date__c, Latest_Letter_Type__c, Reminder__c, Payment_Plan_Established__c 
                                    FROM Foreign_Investigation__c WHERE id = : inputVariables[0].foreignInvestigationId WITH SECURITY_ENFORCED];
        	
            if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Demand_Letter1)){
                if(currentFI.Case_Status__c.equalsIgnoreCase(System.label.Pending) || currentFI.Case_Status__c.equalsIgnoreCase(System.label.Open_DL1)){
                    currentFI.Case_Status__c = System.label.Open_DL1;
                    if(inputVariables[0].dateMailed !=null)
                    {
                        currentFI.Due_Date__c = inputVariables[0].dateMailed.addDays(30);
                    }
                    /*if(currentFI.Due_Date__c == null){
                       currentFI.Due_Date__c = Date.today().addDays(135);
                    }*/
                }
                currentFI.Latest_Letter_Type__c = System.label.Demand_Letter1;
            }
            else if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Demand_Letter2)){
                if(currentFI.Case_Status__c.equalsIgnoreCase(System.label.Open_DL1) || currentFI.Case_Status__c.equalsIgnoreCase(System.label.Open_DL2)){
                    currentFI.Case_Status__c = System.label.Open_DL2;
                        if(inputVariables[0].dateMailed !=null)
                        {
                        currentFI.Due_Date__c = inputVariables[0].dateMailed.addDays(30);
                       }
                }
                currentFI.Latest_Letter_Type__c = System.label.Demand_Letter2;
            }
            else if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Final_Demand_Letter)){
                if(currentFI.Case_Status__c.equalsIgnoreCase(System.label.Open_DL2) || currentFI.Case_Status__c.equalsIgnoreCase(System.label.Open_DL3)){
                    currentFI.Case_Status__c = System.label.Open_DL3;
                        if(inputVariables[0].dateMailed !=null)
                       {
                        currentFI.Due_Date__c = inputVariables[0].dateMailed.addDays(30);
                       }
                }
                currentFI.Latest_Letter_Type__c = System.label.Final_Demand_Letter;
            }
            else if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Interrogatory_Letter)){
                currentFI.Latest_Letter_Type__c = System.label.Interrogatory_Letter;
            }
            else if(inputVariables[0].letterType.equalsIgnoreCase(System.label.Settlement_Letter)){
                currentFI.Case_Status__c = System.label.OpenSettlementLetter;
                currentFI.Latest_Letter_Type__c = System.label.Settlement_Letter;
            }
            try{
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{currentFI}, 'update');
				if(bAccessCheck){
                    update currentFI;
                }
            }catch (Exception ex) {
                BOS_Utility.ExceptionHandler(CLASSNAME, 'updateFIDueDate', 'GenerateDoc Flow', null, BOS_Utility.sSeverity, ex, null);
            }
        }
    }
        
    public class FlowInputs{                
        @InvocableVariable
        public String letterType;
        @InvocableVariable
        public Id foreignInvestigationId;
        @InvocableVariable
        public Date dateMailed;
    }
}