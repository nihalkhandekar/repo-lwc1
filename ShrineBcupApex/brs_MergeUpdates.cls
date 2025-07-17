Global with sharing class brs_MergeUpdates {
       
    @InvocableMethod
    public static void mergeUpdate(List<String> Requests) {
		try{
			String filingId = Requests[0];
			List<String>   accIds = new List<String> ();
			List<String>   accIdsSurviving = new List<String> ();
			List<Account> accList = new List<Account>();
			Decimal totalShares = 0;
			List<Business_Filing__c> bsFiling = new List<Business_Filing__c>();
			bsFiling = [Select id,Status__c,Filing_Date__c,Type_of_Merger__c,Effective_Date__c from Business_Filing__c where id = :filingId];
			if(bsFiling[0].Effective_Date__c!=null && bsFiling[0].Effective_Date__c>System.today()){
				bsFiling[0].Status__c = 'Pending Filing';
			}else{
				bsFiling[0].Status__c = 'Approved';
			}
			if(!bsFiling.isEmpty()){
				update bsFiling;
			}
			List<Business_History__c> lstBsHsToUpdate = new List<Business_History__c>();
			
			List<Business_History__c> lstBsHs = [SELECT Id,Merging_Business__c,Status__c,Name,Surviving_Business__c,Business_Filing__c FROM Business_History__c where Business_Filing__c =:filingId and Status__c!='Merged'];
			
			for(Business_History__c bsHs : lstBsHs){
				accIds.add(bsHs.Merging_Business__c);
				accIdsSurviving.add(bsHs.Surviving_Business__c);
				bsHs.Status__c = 'Merged';
				lstBsHsToUpdate.add(bsHs);
			}
			List<Account> lstAccs = [SELECT id,Status__c,Citizenship__c,Total_Authorized_Shares__c,Business_Type__c	 FROM Account where id IN:accIds];
			List<Account> lstAccsSurviving = [SELECT id,Status__c,Citizenship__c,Date_Registration__c,Total_Authorized_Shares__c	,Business_Type__c FROM Account where id IN:accIdsSurviving];

			for(Account acc : lstAccs){
				if(bsFiling[0].Status__c == 'Approved' && acc.Status__c!=null && (acc.Status__c == 'Active') || (acc.Status__c == 'Recorded')){
					acc.Status__c = 'Merged';
					accList.add(acc);
				}
			}

			if(!lstAccs.isEmpty() && bsFiling[0].Status__c == 'Approved'){
				for(Account acc : lstAccs){
					if(acc.Total_Authorized_Shares__c!=null && totalShares!=null){
						totalShares = totalShares + acc.Total_Authorized_Shares__c	;
					}
				}
			}

			
			if(!lstAccsSurviving.isEmpty()){
				if(totalShares!=null && totalShares>0){
					lstAccsSurviving[0].Total_Authorized_Shares__c = totalShares;
				}
				if(lstAccsSurviving[0].Business_Type__c == 'General Partnerships'){
					lstAccsSurviving[0].Status__c = 'Recorded';
				}else if(lstAccsSurviving[0].Business_Type__c == 'Unauthorized'){
					lstAccsSurviving[0].Status__c = '';
				}else{
					lstAccsSurviving[0].Status__c = 'Active';
				}
				
				if( bsFiling[0].Type_of_Merger__c!='Merge into Existing Business'){
					lstAccsSurviving[0].Date_Registration__c = bsFiling[0].Filing_Date__c;
				}
				accList.add(lstAccsSurviving[0]);
			}
	

			if(!accList.isEmpty()){
				update accList;
			}
			if(!lstBsHsToUpdate.isEmpty()){
				update lstBsHsToUpdate;
			}
    	}
		catch(Exception e) {
			BOS_Utility.handleException(e);
		}
	}
}