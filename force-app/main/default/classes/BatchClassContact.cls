public class BatchClassContact implements database.Batchable<sobject> {
	
    public database.QueryLocator start(database.BatchableContext BC){
    String query='select id, name, Phone from Contact';
    return database.getQueryLocator(query);
	}
    
    public void execute (database.BatchableContext BC, List<Contact> conList){
        for(Contact con : conList){
            if(con.Phone == null){
                con.Phone = '123123123';
            }
        }
        update conList;
    }
    
    public void finish (database.BatchableContext BC){
        
    }
}