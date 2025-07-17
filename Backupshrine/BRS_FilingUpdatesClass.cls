/********************************************************************************************
* DESCRIPTION: Bulk filer operations
*
* MODIFICATION LOG:
* DEVELOPER                     DATE                       DESCRIPTION
* ----------------------------------------------------------------------------
*	
*********************************************************************************************/
global without sharing class BRS_FilingUpdatesClass {
    @InvocableMethod
    public static void updateFilingRecordType(List<Request> FilingList){
    UCC_Filing__c fileInst = new UCC_Filing__c();
    UCC_Lien__c lienInst = new UCC_Lien__c();
    if(FilingList[0].FilingID != null){
        fileInst = [Select Id,Lien_Filing_Type__c,Status__c,UCC_Lien_Id__r.Type__c from UCC_Filing__c where Id =: FilingList[0].FilingID WITH SECURITY_ENFORCED];
    } 
    if(FilingList[0].UCCLIenID != null){
        lienInst = [Select Id,Type__c from UCC_Lien__c where Id =: FilingList[0].UCCLIenID WITH SECURITY_ENFORCED]; 
    }   

    List<UCC_Filing__c> uccfileListupdated = new List<UCC_Filing__c>();
    List<UCC_Lien__c> lienList = new List<UCC_Lien__c>();
    List<BRS_Update_Filing__mdt> filingMDtList = new  List<BRS_Update_Filing__mdt>([Select Filing_Lien_Type__c,Filing_Type_Update_Value__c,Lien_is__c,LienType__c,Lien_Type_Update_Value__c from BRS_Update_Filing__mdt]);        
    for(BRS_Update_Filing__mdt metdataObj : filingMDtList){
		if(metdataObj.Lien_is__c != null){
			if(metdataObj.Lien_is__c == fileInst.Lien_Filing_Type__c && metdataObj.LienType__c == lienInst.Type__c){
				fileInst.Type__c =  metdataObj.Filing_Type_Update_Value__c;
				fileInst.UCC_Lien_Type__c =  metdataObj.Filing_Lien_Type__c;
				lienInst.Type__c = metdataObj.Lien_Type_Update_Value__c;
				uccfileListupdated.add(fileInst);
				lienList.add(lienInst);
			}
		}
		else{
		   if(metdataObj.LienType__c == lienInst.Type__c){
				fileInst.Type__c =  metdataObj.Filing_Type_Update_Value__c;
				fileInst.UCC_Lien_Type__c =  metdataObj.Filing_Lien_Type__c;
				lienInst.Type__c = metdataObj.Lien_Type_Update_Value__c;  
				uccfileListupdated.add(fileInst);
				lienList.add(lienInst);
		   } 
		} 
            
        }
        if(!uccfileListupdated.isEmpty() && Schema.SObjectType.UCC_Filing__c.isUpdateable())
        update uccfileListupdated;
        if(!lienList.isEmpty() && Schema.SObjectType.UCC_Lien__c.isUpdateable())
        update lienList;
         
    }
    global class Request {
        @InvocableVariable global String FilingID;
        @InvocableVariable global String UCCLIenID;
    }
}