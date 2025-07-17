public with sharing class NintexAddPSBatch implements Database.Batchable<sObject>{
    List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
    List<User> lstUser = new List<User>();
	PermissionSet psUser;
	String query;
    String profileCT = 'CT Community User';
	public static final String className='NintexAddPSBatch';
    public static final String methodName='execute';
    public static final String severity='Low';
    public NintexAddPSBatch() {
        query = 'select id from user where  isActive = true AND profile.name =:profileCT';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator(query);	
    }
    
    public void execute(Database.BatchableContext bc, List<User> lstUser){
	try{
			psUser = [SELECT Id FROM PermissionSet WHERE Name = 'DDP_User_All'].get(0);
		
			for(User u :lstUser) {
				lpsa.add(new PermissionSetAssignment(PermissionSetId = psUser.Id, AssigneeId = u.Id));
			}
			System.debug('Users:' + lpsa.size());
			for (Database.SaveResult r :Database.insert(lpsa, false)) {
			if(!r.isSuccess()) {
				System.debug('failed:' + r.getErrors().get(0).getMessage());
				} 
			}
		}
		catch(Exception e){
            BOS_Utility.ExceptionHandler(className,methodName,'execute',null,severity,e,null);
        }
	}

    public void finish(Database.BatchableContext bc) {
    }
}