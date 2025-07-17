public class CreateBatchDaily implements Schedulable {
   public void execute(SchedulableContext context) {
        createNewBatchRecord();
    }       
    private void createNewBatchRecord() {
        List<Batch__c> newBatches = new List<Batch__c>();
        Date today = Date.today();
        
		List<Batch_staff_member__mdt> results = [SELECT Name__c, Start_Date__c, End_Date__c FROM Batch_staff_member__mdt
												WHERE Start_Date__c <= :today AND End_Date__c > :today];

		for (Batch_staff_member__mdt record : results) {
            Batch__c newBatch = new Batch__c();
			newBatch.Name = record.Name__c;
            newBatches.add(newBatch);
			}
        
        try {
            insert newBatches;
        } catch (DmlException e) {
            System.debug('Error inserting Batch record: ' + e.getMessage());
        }  
    }    
}

//String cronExp = '1 1 0 * * ?';
//System.schedule('Creation Batch Daily', cronExp, new CreateBatchDaily());