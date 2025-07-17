public class BusinessFilingValidationController {
    
    @AuraEnabled
 //   public static BusinessFilingWrapper getBusinessFiling(String recordId){
     public static Business_Filing__c getBusinessFiling(String recordId){
       
        Business_Filing__c filing = [Select Id, Status__c, Work_Order__c from Business_Filing__c where Id =: recordId];
        System.debug('Before if clause BizFilings work order: ' + filing.Work_Order__c);
        
   //     BusinessFilingWrapper wrapper = new BusinessFilingWrapper();
        
  //      wrapper.filingRecord = filing;
        
     //   Work_Order__c  work = [Select Id, Assigned_To__c, Assigned_To__r.Name from Work_Order__c where Id =: workerOrderId]; 
        
   //     List<BusinessFilingWrapper> wrapperList = new List<BusinessFilingWrapper>();
   //     wrapperList.add(wrapper);

        
        if(filing.Work_Order__c != null){
     //   System.debug('BizFilings work order: ' + filing.Work_Order__c);
        getWorkOrder(filing.Work_Order__c);    
        }
         return filing;
    }
    
    @AuraEnabled
    public static Work_Order__c getWorkOrder(Id workerOrderId){
        
        System.debug('Passed in workorder Id: ' + workerOrderId);
		Work_Order__c work;
        if(workerOrderId != null){
        work = [Select Id, Assigned_To__c, Assigned_To__r.Name from Work_Order__c where Id =: workerOrderId]; 
        }
        
  //     update work;
       return work;

        
    }
    /*
        @AuraEnabled
    public static void updateWorker(Id workerOrderId, Id assignToId){
        System.debug('Passed in assignTo Id: ' + assignToId);
		Work_Order__c work;
        if(workerOrderId != null){
        work = [Select Id, Assigned_To__c, Assigned_To__r.Name from Work_Order__c where Assigned_To__c =: workerOrderId];
        work.Assigned_To__c = assignToId;
        }
        
       update work;    

        
    }
    */
    
    public class BusinessFilingWrapper{
        
        @AuraEnabled 
        public Business_Filing__c filingRecord{get;set;}
        
        @AuraEnabled 
        public Work_Order__c workerOrderrecord{get;set;}
    }
    

}