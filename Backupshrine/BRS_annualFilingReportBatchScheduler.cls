global with sharing class BRS_annualFilingReportBatchScheduler implements Schedulable {
      
    global void execute(SchedulableContext SC) {
        Date datedata = System.today();

    BRS_annualFilingReportBatch updateBatch = new BRS_annualFilingReportBatch (datedata.year()+1,true);
     
          Database.executeBatch(updateBatch);
     }
  }