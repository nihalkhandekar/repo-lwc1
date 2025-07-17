global class Latest_Filing_Date Implements Schedulable
{    
	global static void execute(SchedulableContext sc)
	{
		process();
	}
    public static void process()
    {
        RequestInformation_LatestFillingDate__c latestFilingDate = RequestInformation_LatestFillingDate__c.getall().values()[0];
        
        UCC_Filing__c filingLien = [SELECT Id, Name, Filing_Date__c 
                                FROM UCC_Filing__c 
                                WHERE Filing_Source__c!='Online' 
                                AND Status__c = 'Approved' 
                                AND RecordType.Name = 'New Lien'
                                AND Filing_Date__c!= null 
                                ORDER BY Filing_Date__c DESC 
                                LIMIT 1];
        
        
        UCC_Filing__c filingIRS = [SELECT Filing_Date__c 
                                 FROM UCC_Filing__c 
                                 WHERE Status__c = 'Approved' 
                                 AND RecordType.Name = 'IRS' 
                                 AND Filing_Date__c != null 
                                 ORDER BY Filing_Date__c DESC 
                                 LIMIT 1
                                ];
        
        
        latestFilingDate.New_Lien_Filling_Number__c = filingLien.Name;
        latestFilingDate.New_Lien_Date__c = filingLien.Filing_Date__c;
        latestFilingDate.IRS_Filling_Number__c = filingLien.Name;
        latestFilingDate.IRS_Date__c = filingIRS.Filing_Date__c;
		
        
        update latestFilingDate;
        
    }
}