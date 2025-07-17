global with sharing class brs_RelatedListVerification {
   
    global without sharing class Requests {
        @InvocableVariable
        global string objectList;
        @InvocableVariable
        global string recordList;
        @InvocableVariable
        global String accountID;

        @InvocableVariable
        global String workorderID;
    } 
    global without sharing class Results {
        @InvocableVariable
        global string message;
        
    }

    class RecordDetail{
        public String objectname;
        public String record;
    }
   
@InvocableMethod
public static List<Results> getRelatedVerificationStatusFlow(List<Requests> Requests) {
    List<String> ids = new List<String>();
    String message = 'error';
    String accRec = 'not present';
    Map<String,String>  detailList = new Map<String,String>();
 try{

    String objList = Requests[0].objectList;
    String recordList = Requests[0].recordList;
    String accountID = Requests[0].accountID;
    String workorderID = Requests[0].workorderID;
    Boolean isAgentSkipped=false;
    Boolean isPrincipalSkipped=false;
Account accData;

List<Work_Order__c>  filings = [Select id,Payments_Verified__c,Total_Balance__c, Status__c,Source__c,Total_Hold_Amount__c,Total_Payment__c from Work_Order__c where id =:workorderID];
if(filings !=null && !filings.isEmpty()  && filings[0].Status__c == 'Intake pending' && filings[0].Source__c  == 'Digital Mail'){
message = 'success';

}else{


      if(String.isNotBlank(accountID))
      {
    
            accData = [Select id,Business_Type__c,Citizenship__c,BillingState from Account where id =:accountID];
            if(accData!=null && accData.Business_Type__c == 'LLP' && 
            (accData.BillingState.equalsIgnoreCase('CT') || accData.BillingState.equalsIgnoreCase('Connecticut'))){
             isAgentSkipped = true;
             isPrincipalSkipped= true;
            }
            if(accData.Business_Type__c == 'LLP')
            {
               isPrincipalSkipped= true;
            }
      }
    
             List<RecordDetail> detail ;
             List<String> objects = (List<String>) JSON.deserialize(objList, String[].class);
             if(String.isNotBlank(recordList))
             {
                detail = (List<RecordDetail> ) JSON.deserialize(recordList, RecordDetail[].class);
                for(RecordDetail det :detail)
                {
                    detailList.put(det.objectname, det.record);
                }
                for(String key  : detailList.keySet()){
                     if(key == 'Account'){
                     detailList.remove(key);
                    }
                }

            }
            for(Integer i=0;i<objects.size();i++){
               if(objects[i]=='Account'){
               objects.remove(i);
            }
            } 

if(detail!=null && !detail.isEmpty() && objects!=null && !objects.isEmpty()){
    for(String singleitem :objects){
   
       if(singleitem == 'Agent__c'  && isAgentSkipped)
        {
          message = 'success';  
        }
        else 
        {
            if(singleitem == 'Principal__c' && isPrincipalSkipped)
            {
                message = 'success';
            }
            else
            {
                if(String.isBlank(detailList.get(singleitem))  ){
                    message = 'error';
                    break;
                }else{
                     message = 'success';
                    } 
            }   
        }
    }
}
else if((detail==null || detail.isEmpty()) && objects!=null && !objects.isEmpty()){
         
    for(String singleitem :objects){
        
        if(singleitem == 'Agent__c' && isAgentSkipped)
        {
            message = 'success';  
        }
        else{
            if(singleitem == 'Principal__c' && isPrincipalSkipped)
            {
                message = 'success';  
            }
            else
            {
                message = 'error';
            }
            }
    }
}
}
       }catch(Exception e){}
    List<Results> lstResults = new List<Results>();
    Results r = new Results();
    r.message =message;
    lstResults.add(r);
  
    return lstResults;
}
}