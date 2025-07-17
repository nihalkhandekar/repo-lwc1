public class MarkFilingTriggerHelper {
 public static Final String className = 'MarkFilingTriggerHelper';

    /**********************************************************************************************
    METHOD NAME    : updateFilingFee
    DESCRIPTION    : Method to update the filing fee on the certificate record.
    PARAMETER      : List<Certficate__c>, Map<Id, SObject>
    ***********************************************************************************************/
    public static void updateFilingFee(List<Mark_Filing__c> newfilingsList,Map<Id, SObject> oldMap){
        try{
            List<String> typeList = new List<String>();
            List<Master_Fee__c> lstMasterFee = new List<Master_Fee__c>();
            Date processingDate = System.today();
            Map<String, Decimal> mapKeyToAmount = new Map<String, Decimal>();
            List<String> recordtypeList = new List<String>();
            Set<Id> workorderIds = new Set<Id>();
     
            
            for(Mark_Filing__c filings : newfilingsList){
                if(filings.Work_Order__c!=null){
                    workorderIds.add(filings.Work_Order__c);
                }
            typeList.add(filings.Mark_Type__c);
                
            }
            
            if(!typeList.isEmpty()){
                Map<Id,Work_Order__c> workorderMap = new Map<Id,Work_Order__c>([select Id, Source__c from Work_Order__c where Id IN :workorderIds]);
                
                lstMasterFee = [SELECT Id, Amount__c, Mark_Type__c, End_Date__c	, Start_Date__c, Mark_Filing_Type__c
                                FROM Master_Fee__c  WHERE Status__c =:System.Label.ACTIVE AND Start_Date__c <= :processingDate AND (End_Date__c = null OR End_Date__c >= :processingDate)
                               AND Mark_Type__c in : typeList];
                if(!lstMasterFee.isEmpty()){
                    for(Master_Fee__c mf : lstMasterFee){
                        // The key if copy type is present :: 'mf.Certificate_Copy_Type__c' (for copy request records)
                        // The key if copy type is not present :: 'mf.Filing_Type__c;mf.Business_Type__c' 
                        String key;
                        if(mf.Mark_Filing_Type__c!=null){
                         key = mf.Mark_Filing_Type__c + ';' + mf.Mark_Type__c;
                        }
                        mapKeyToAmount.put(key, mf.Amount__c);
                    }
                    
                    for(Mark_Filing__c certRec : newfilingsList){
                        if(workorderMap.keySet().contains(certRec.Work_Order__c)){
                            Work_Order__c workorderRec = workorderMap.get(certRec.Work_Order__c);
                            if(workorderRec.Source__c!=System.Label.brs_FilingOnline ){
                           certRec.Filing_Fee__c =mapKeyToAmount.get((certRec.Filing_Type__c + ';' + certRec.Mark_Type__c));
                            }
                        }
                    }
                }
            }
            /*if(Test.isRunningTest()){
                throw new NullPointerException();
            }*/
        }catch(Exception e){
            BOS_Utility.ExceptionHandler(className, 'updateFilingFee', 'Mark_Filing__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }
        
    }

    /**********************************************************************************************
    METHOD NAME    : checkPaymentVerification
    DESCRIPTION    : Method to restrict user from Approving Certificate before checking the 'Verify Payments' checkbox on workorder.
    PARAMETER      : List<SObject> newCertificates, Map<Id, SObject> oldCertificateMap
    ***********************************************************************************************/    
    public static void checkPaymentVerification(List<SObject> newCertificates, Map<Id, SObject> oldCertificateMap){
        try{
            Set<Id> workOrderIds = new Set<Id>();
            for(SObject sobj: newCertificates){
                Mark_Filing__c certRec = (Mark_Filing__c)sobj;
                workOrderIds.add(certRec.Work_Order__c);
            }
            Map<Id,Work_Order__c> workOrderMap= new Map<Id,Work_Order__c>([select Id, Payments_Verified__c, Customer__c,Source__c, Customer__r.Allow_negative_balances__c from Work_Order__c where Id IN :workOrderIds]);
            Boolean statusChanged = false;
            for(SObject sobj: newCertificates){
                Mark_Filing__c newCert = (Mark_Filing__c)sobj;
                if(oldCertificateMap!=null){
                    Mark_Filing__c oldCert = (Mark_Filing__c)oldCertificateMap.get(newCert.Id);
                    if(newCert.Status__c!=oldCert.Status__c){
                        statusChanged=true;
                    }
                }
				
                if((newCert.Status__c==System.Label.BRS_FilingStatus_Approved) && ((oldCertificateMap!=null && statusChanged==true) || oldCertificateMap==null)){
                    if(workOrderMap.keySet().contains(newCert.Work_Order__c)){
                        Work_Order__c workorder = workOrderMap.get(newCert.Work_Order__c);
                        if(workorder.Payments_Verified__c==false && workorder.Customer__r.Allow_negative_balances__c==false && workorder.Source__c!=System.Label.brs_FilingOnline && workorder.Source__c!=System.Label.brs_FilingAPI){
                            newCert.addError(System.Label.PaymentVerificationCheckErrorMessage);
                        }
                    }
                }
            }
            /*if(Test.isRunningTest()){
                throw new NullPointerException();
            }*/
        }catch (Exception e) {
            BOS_Utility.ExceptionHandler(className, 'checkPaymentVerification', 'Work_Order__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }
    }


 /*   public static void validatePaymentmethodSource(List<SObject> newItems){
        Set<ID>  workorderMap = new Set<ID>();
        Map<ID,Mark_Filing__c>  workorderObjectMap = new Map<ID,Mark_Filing__c>();
          for(SObject sobj: newItems){
                Mark_Filing__c newCert = (Mark_Filing__c)sobj;
                if(newCert.filing_Type__c == 'Registration')
                {
              workorderMap.add(newCert.Work_Order__c);
              workorderObjectMap.put(newCert.Work_Order__c,newCert);
                }
          }
        List<Payment_Method__c> filings = [Select id ,Payment_Source__c,Work_Order__c from Payment_Method__c where Work_Order__c in :workorderMap];
  if(filings!=null && filings.size()>0){
      for(Payment_Method__c payment: filings) {
          if(payment.Payment_Source__c!='Check'){
              Mark_Filing__c filing = workorderObjectMap.get(payment.Work_Order__c);
              filing.addError(System.Label.MarkFilingPaymentTypeError);
          }
      }
  }

    } */
     public static void updateFilingNumberandDate(List<SObject> newItems){
         Set<ID>  workorderMap = new Set<ID>();
         
           for(SObject sobj: newItems){
                 Mark_Filing__c newCert = (Mark_Filing__c)sobj;
               workorderMap.add(newCert.id);
           }
         List<Mark_Filing__c> filings = [Select id ,Filing_Type__c,Status__c, Name,Filing_number__c,Filing_Time__c,Registration_Number__c,Filing_Date__c,
                                        Work_Order__r.Received_Date__c From Mark_Filing__c where id in :workorderMap];
        for(Mark_Filing__c newCert: filings){
              
             String filingno = newCert.Name.substringAfter('M-');

                   
                    newCert.Filing_number__c = 'T-'+filingno;
           
                    newCert.Registration_Number__c = 'T-'+filingno;
            
            newCert.Status__c = 'In Progress';
            if(newCert.Work_Order__r.Received_Date__c !=null){
                
                Datetime rDate = newCert.Work_Order__r.Received_Date__c;
                newCert.Filing_Date__c = rDate.date();
                newCert.Filing_Time__c=rDate.time();
                newCert.Registration_Date__c = rDate.date();
            }
        }
         update filings;
    }
    public static void previousNameState(List<Mark_Filing__c> markfilings)
    {
       try
        {
        Set<id> markIds=new Set<id>();
        for(Mark_Filing__c markfiling:markfilings)
        {
          markIds.add(markfiling.Mark__c);
        }
        Map<id,Mark__c> MarkInformation=new Map<id,Mark__c>([Select id,Owner_Name__c,State_Country_of_Formation__c,Registration_Number__c from Mark__c]);
        for(Mark_Filing__c markfiling:markfilings)
        {
        If(markfiling.Status__c=='In Progress' && markfiling.Filing_Type__c=='Owner Name Change')
        {
            markfiling.Previous_Name_State__c=MarkInformation.get(markfiling.Mark__c).Owner_Name__c;
        }
         If(markfiling.Status__c=='In Progress' && markfiling.Filing_Type__c =='State of Formation Change')
        {
            markfiling.Previous_Name_State__c=MarkInformation.get(markfiling.Mark__c).State_Country_of_Formation__c;
       if(String.isBlank( markfiling.Previous_Name_State__c)){
        markfiling.Previous_Name_State__c ='NA';
       }
       
        }

        if(markfiling.Filing_Type__c !='Registration'){
            markfiling.Registration_Number__c=MarkInformation.get(markfiling.Mark__c).Registration_Number__c;

        }
        }
            /*if(Test.isRunningTest()){
                throw new NullPointerException();
            }*/
        }
        catch(Exception e)
        {
            BOS_Utility.ExceptionHandler(className, 'previousNameState', 'Mark_Filing__c', null, BRS_PaymentUtility.sSeverity, e, null);
        }   
    }
    public static void updateClassofGoods(List<Mark_Filing__c> markfilings){
        Set<Id> markIds = new Set<Id>();
         Id regRecordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        for(Mark_Filing__c mfile:markfilings){
            if(!String.isBlank(mfile.Mark__c) && mfile.recordTypeId != regRecordTypeId){
            markIds.add(mfile.Mark__c);
            }
        }
        if(!markIds.isEmpty()){
        Map<Id,Mark__c> markMap = new Map<Id,Mark__c>([Select Id,Name,Class_of_Goods_Service__c from Mark__c where Id IN:markIds AND Class_of_Goods_Service__c!=NULL]);
        for(Mark_Filing__c mfile:markfilings){
            if(!String.isBlank(mfile.Mark__c) && markMap.containsKey(mfile.Mark__c) && mfile.recordTypeId != regRecordTypeId){
                mfile.Class_of_Goods_Service__c = markMap.get(mfile.Mark__c).Class_of_Goods_Service__c;
            }
        }
        }
    }
}