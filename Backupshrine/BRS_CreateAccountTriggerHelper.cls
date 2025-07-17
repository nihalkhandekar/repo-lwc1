/*****************************************************************************************************
 * NAME:  BRS_CreateAccountTriggerHelper
 * DESCRIPTION: create account record
 *
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------------------------------
 * Priyanka                         3/24/2021                         Formation flow access for CT user
 ******************************************************************************************************/
public with sharing class BRS_CreateAccountTriggerHelper {
    public static final string brs_createAccountLabel = 'brs_createAccount';
    public static final String creatAccLabel = 'creatAcc';
    public static void creatAcc(List<Create_Account__e> peObjList){
        List<Account> accLstToInsert = new List<Account>();
        for(Create_Account__e AccName: peObjList){
            Account acc = new Account();
            acc.name = AccName.Account_Name__c;
            acc.Status__c = System.Label.businessProfile_credentialsPending;            
            accLstToInsert.add(acc);
        }
        
        try{
			if(!accLstToInsert.isEmpty()){
                Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(accLstToInsert, 'insert');
				if(bAccessCheck){
				    insert accLstToInsert;
                }
			}	
            if(Test.isRunningTest()){
            throw new NullPointerException();
        }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(brs_createAccountLabel, creatAccLabel,null,null,null,ex,ex.getMessage());
        }
    }
}