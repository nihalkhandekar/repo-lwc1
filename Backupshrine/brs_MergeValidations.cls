Global with sharing class brs_MergeValidations {

    global without sharing class Results {
        @InvocableVariable
        global string message;
        @InvocableVariable
        global string messageEff;
    }
       
    @InvocableMethod
    public static List<Results> mergeValidations(List<String> Requests) {
        List<Results> lstResults = new List<Results>();
        try{
            String filingId = Requests[0];
            String message = 'error';
            String messageEff = 'correct';
            List<String>   accIds = new List<String> ();
            List<String>   accIdsSurviving = new List<String> ();
            Decimal totalShares = 0;
            List<Account> accList = new List<Account>();
            List<Business_Filing__c> bsFiling = new List<Business_Filing__c>();
            bsFiling = [Select id,Status__c,Effective_Date__c from Business_Filing__c where id = :filingId];
            List<Business_History__c> lstBsHs = [SELECT Id,Merging_Business__c,Name,Surviving_Business__c,Business_Filing__c FROM Business_History__c where Business_Filing__c =:filingId and  Status__c!='Merged'];
            
            for(Business_History__c bsHs : lstBsHs){
                accIds.add(bsHs.Merging_Business__c);
                accIdsSurviving.add(bsHs.Surviving_Business__c);
            }
            List<Account> lstAccs = [SELECT id,Status__c,Citizenship__c,Total_Authorized_Shares__c,Business_Type__c	 FROM Account where id IN:accIds];
            
            List<Account> lstAccsSurviving = [SELECT id,Status__c,Citizenship__c,Total_Authorized_Shares__c,Business_Type__c	 FROM Account where id IN:accIdsSurviving];
            if(!lstAccsSurviving.isEmpty()){
                if(lstAccs[0].Total_Authorized_Shares__c!=null)
                    totalShares = lstAccsSurviving[0].Total_Authorized_Shares__c;
            }
            if(!lstAccsSurviving.isEmpty()){
            
                if(lstAccsSurviving[0].Citizenship__c == 'Domestic'){
                    message = 'success';
                }else{
                    if(!lstAccs.isEmpty()){
                        for(Account acc : lstAccs){
                            if(acc.Citizenship__c == 'Domestic'){
                                message = 'success';
                                break;
                            }else{
                                continue;
                            }
                        }
                    }
                }

            }

            if(!bsFiling.isEmpty() && !lstAccsSurviving.isEmpty() && !lstAccs.isEmpty()){

                for(Account acc : lstAccs){
                    Integer effDate = 0;
                    if(bsFiling[0].Effective_Date__c!=null){
                        effDate = (System.today()).daysBetween(bsFiling[0].Effective_Date__c);

                    }
                    Boolean abc = false;
                    if(effDate>90){
                        abc = true;
                    }
                    if(acc.Business_Type__c!=null 
                    && lstAccsSurviving[0].Business_Type__c!=null 
                    && acc.Business_Type__c !=lstAccsSurviving[0].Business_Type__c
                    && abc){
                        System.debug('Entered messageEff'+messageEff);
                        messageEff = 'incorrect';
                        break;
                    }else{
                        System.debug('Entered messageEff'+messageEff);
                        continue;
                    }
                }
            }
            
            Results r = new Results();
            r.message =message;
            r.messageEff =messageEff;
            lstResults.add(r);
            
        }catch(Exception e) {
            BOS_Utility.handleException(e);
        }
        return lstResults;
    }

}