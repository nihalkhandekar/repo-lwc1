public class brs_PaymentSubflowWOCheck {
        public without sharing class Requests {
        @InvocableVariable
        public string refrenceRecordid;
        }
    public without sharing class Response {
             @InvocableVariable
        public boolean isWorkorderPresent;
        @InvocableVariable
        public string WorkorderId;
    }

    @InvocableMethod
    public static List<Response> checkWorkorder(List<Requests> requestparams) {
        Response responedata=new Response();
        List<Response> responselist=new List<Response>();
        String recordid=requestparams[0].refrenceRecordid;
        Boolean workorderpresent=fetchworder(recordid);
        string workorderidpresent=fetchworkorderID(recordid);
        responedata.isWorkorderPresent=workorderpresent;
        responedata.WorkorderId=workorderidpresent;
        responselist.add(responedata);
        return responselist;
    }
        public static Boolean fetchworder(string filingid){
            boolean isWorkorderPresent;
            id owneridinfo=UserInfo.getUserId();
            List<work_order__c> workorderinfo=[select id from work_order__c where Reference_Record_Id__c=:filingid and OwnerId=:owneridinfo limit 1];
            if(!workorderinfo.isEmpty())
            {
               isWorkorderPresent=true;
            }
            else
            {
               isWorkorderPresent= false; 
            }
            System.debug('isWorkorderPresent@@@@ '+isWorkorderPresent);
            return isWorkorderPresent;
        }
            public static string fetchworkorderID(string filingid){
            string WorkorderId;
            id owneridinfo=UserInfo.getUserId();
            List<work_order__c> workorderinfo=[select id from work_order__c where Reference_Record_Id__c=:filingid and OwnerId=:owneridinfo limit 1];
            if(!workorderinfo.isEmpty())
            {
               WorkorderId=workorderinfo[0].id;
            }
            else
            {
               WorkorderId= null; 
            }
            return WorkorderId;
        }

}