Global with sharing class brs_PaymentVerificationforFlow {
    

    global without sharing class Requests {
        @InvocableVariable
        global string recordid;
        global string workorderid;
    } 
    global without sharing class Results {
        @InvocableVariable
        global string message;
        @InvocableVariable
        global List<string> records;
    }
    
@InvocableMethod
public static List<Results> getPaymentVerificationStatusFlow(List<Requests> Requests) {
    List<String> ids = new List<String>();
    String message = 'error';
 try{

    String recordId = Requests[0].recordid;
 
    if(String.isNotBlank(recordId))
     {
    List<Work_Order__c>  filings = [Select id,Payments_Verified__c,Total_Balance__c, Status__c,Source__c,Total_Hold_Amount__c,Total_Payment__c from Work_Order__c where id =:recordId];
   List<Payment_Method__c> pmethods= [Select id,Payment_Source__c from Payment_Method__c where Work_Order__c = :recordId];
     if(filings!=null && !filings.isEmpty())
     {

        Decimal totalBalance = filings[0].Total_Balance__c;
        Decimal totalpayment = filings[0].Total_Payment__c;
        Decimal totalfilingdfee = filings[0].Total_Hold_Amount__c;
if((totalBalance+totalpayment)  >= totalfilingdfee){
    message = 'success';
    filings[0].Payments_Verified__c = true;
    update filings;
    
}
if(filings[0].Status__c == 'Intake pending' && filings[0].Source__c  == 'Digital Mail'){
    message = 'success';  
    filings[0].Payments_Verified__c = true;
    update filings;
}

if(pmethods!=null && pmethods.size()>0 && message !='success' && pmethods[0].Payment_Source__c =='Insufficient payment'){
    message = 'infs';  
    filings[0].Payments_Verified__c = true;
    update filings;
}
     }
    }
       }catch(Exception e){}
       List<Results> lstResults = new List<Results>();
    Results r = new Results();
    r.message =message;
 
    lstResults.add(r);

    system.debug('lstResults'+lstResults);    
    return lstResults;
}


}