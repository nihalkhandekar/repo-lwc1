public class brs_annualReportDataFix implements Database.Batchable<sObject>{
    public List<String> accIdList = new List<String>();
    public brs_annualReportDataFix(List<String> accIds){
        accIdList = accIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> BusinessTypes=new List<String>{'Non-Stock','Stock','B Corp','Limited Partnership','LLC','LLP'};
            String Query =  'Select Id, Name,Annual_Report_Due_date__c,Status__c,Citizenship__c,Business_Type__c,Date_Registration__c,(Select Id,Name,Filing_Date__c,Due_Date__c,Type__c,Due_Year__c,Status__c From Business_Filings__r where Type__c IN(\'First Report\',\'Annual Report\') AND Status__c!=\'Rejected\') from Account where Status__c=\'Active\' and Annual_Report_Due_date__c=NULL AND Business_Type__c IN:BusinessTypes AND ID IN:accIdList';
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        List<Business_Filing__c> updateListFiling = new List<Business_Filing__c>();       
        for(Account acc:scope){
            Boolean hasAnnualReport = false;
            if(acc.Business_Type__c=='LLC'){
                acc.Annual_Report_Due_date__c= DATE.newInstance(acc.Date_Registration__c.year()+1, 3, 31);                
            }
            else if(acc.Business_Type__c=='LLP' || acc.Business_Type__c=='Limited Partnership'){
                acc.Annual_Report_Due_date__c= DATE.newInstance(acc.Date_Registration__c.year()+1,acc.Date_Registration__c.month(), acc.Date_Registration__c.day());
            }
            else if(acc.Citizenship__c=='Domestic' && (acc.Business_Type__c=='Stock' || acc.Business_Type__c=='Non-Stock' || acc.Business_Type__c=='B Corp')){
                acc.Annual_Report_Due_date__c= DATE.newInstance(acc.Date_Registration__c.year()+1,acc.Date_Registration__c.month(), acc.Date_Registration__c.day());
                if(!acc.Business_Filings__r.isEmpty()){
                    for(Business_Filing__c bf:acc.Business_Filings__r){
                        if(bf.Type__c=='First Report'){
                            if(bf.Status__c=='Approved' && bf.Filing_Date__c.year()>2019){
                                acc.Annual_Report_Due_date__c= DATE.newInstance(bf.Filing_Date__c.year()+1,bf.Filing_Date__c.month(),bf.Filing_Date__c.day());
                            }
                            else if(bf.Status__c=='Due'){
                                acc.Annual_Report_Due_date__c= DATE.newInstance(bf.Due_Date__c.year(),bf.Due_Date__c.month(),bf.Due_Date__c.day());
                            }
                            break;
                        }
                    } 
                }
            }
            else if(acc.Citizenship__c=='Foreign' && (acc.Business_Type__c=='Stock' || acc.Business_Type__c=='Non-Stock' || acc.Business_Type__c=='B Corp') && acc.Date_Registration__c!=null){
                acc.Annual_Report_Due_date__c= DATE.newInstance(acc.Date_Registration__c.year()+1,acc.Date_Registration__c.month(), acc.Date_Registration__c.day());
            } 
            //For Annual Report Creation
            System.debug('@@@'+acc.Annual_Report_Due_date__c);
            if(!acc.Business_Filings__r.isEmpty()){
                for(Business_Filing__c bf:acc.Business_Filings__r){
                    if(Integer.valueOf(bf.Due_Year__c)>=Integer.valueOf(System.today().year())){
                        hasAnnualReport = true;
                    }
                }
            }
            if(!hasAnnualReport){
                updateListFiling.add(new Business_Filing__c(Type__c = System.Label.Annual_Report_Label,Account__c = acc.Id,Business_Type__c  = acc.Business_Type__c,Filing_Type__c = System.Label.Annual_Report_Label,Status__c = System.Label.Due,Citizenship__c = acc.Citizenship__c,Due_Date__c=acc.Annual_Report_Due_date__c,RecordTypeId=annualFirstrecTypeId));
                acc.Sub_status__c=system.label.Annual_Report_Due1;
                acc.Annual_Report_Processing_Year__c = system.today().year();
            }
        }
        
        update scope;
        insert updateListFiling;
    }
    public void finish(Database.BatchableContext BC) { 
    }
}