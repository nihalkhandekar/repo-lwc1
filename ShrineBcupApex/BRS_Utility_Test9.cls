@isTest
public class BRS_Utility_Test9 {
	@IsTest
    static void processBusinessMaintenance() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Id mainRecTypeId1 = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
		Certficate__c cert = BRS_TestDataFactory.createCertificate(mainRecTypeId1,acc.Id,WorkOrder.Id);
        
        BRS_Utility.Requests req = new BRS_Utility.Requests();
        req.certificateTypes=cert.Certificate_Type__c;
        req.accId=acc.Id;
        req.workOrderId=workOrder.Id;
        List<BRS_Utility.Requests> Requests = new List<BRS_Utility.Requests>();
        Requests.add(req);
        test.startTest();
        BRS_Utility.processBusinessMaintenance(Requests);
        test.stopTest();
    }
    
    @IsTest
    static void getOrgWideEmailAddr() {
        try{
        String emailAddr = 'abc@xyz.com';
        test.startTest();
        BRS_Utility.getOrgWideEmailAddr(emailAddr);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @IsTest
    static void wrapperTableDataPrincipal() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Principal__c pri = BRS_TestDataFactory.createPrincipalRecords(acc.Id);
        pri.Principal_Account_ID__c=acc.id;
        pri.Email__c='abc@xyz.com';
        pri.Principal_Type__c='Business';
        pri.Business_Name__c='Test Business';
        insert pri;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(pri);
    }
    
    @IsTest
    static void wrapperTableDataAgent() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        Agent__c agent1 = BRS_TestDataFactory.createAgent(acc.Id);
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(agent1);
    }
    
    @IsTest
    static void wrapperTableDataTempHistory() {
        Account acc =BRS_TestDataFactory.createAccountObject();
        Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        temp.Type__c='Principal';
        temp.Temp_Type__c='Business';
        temp.Account__c=acc.Id;
        update temp;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(temp);
    }
    
    @IsTest
    static void wrapperTableDataTempHistory1() {
        Temp_History__c temp = BRS_TestDataFactory.createTempHistoryObject();
        temp.Type__c='Agent';
        temp.Temp_Type__c='Business';
        update temp;
        BRS_Utility.wrapperTableData wrap = new BRS_Utility.wrapperTableData(temp);
    }
    
    @IsTest
    static void updateBusinessFilingChecklist() {
        try{
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        filing.Checklist_Status__c='Completed';
        test.startTest();
        BRS_Utility.updateBusinessFilingChecklist(filing.Checklist_Status__c, filing.RecordTypeId);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @IsTest
    static void updateSignatoryOnUCCFling() {
        try{
        String uccLienId;
        Boolean ackCheck;
        String signatoryName;
        test.startTest();
        BRS_Utility.updateSignatoryOnUCCFling(uccLienId,ackCheck,signatoryName);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @IsTest
    static void updateSignatoryOnUCCFling1() {
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Lien__c ucclien = BRS_TestDataFactory.createUCCLien('OFS');
        UCC_Filing__c uccfiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','Approved', ucclien.Id, 'OFS');
        uccfiling.Acknowledge__c=true;
        uccfiling.Acknowledgement_Signatory__c='Test Signatory';
        update uccfiling;
        test.startTest();
        BRS_Utility.updateSignatoryOnUCCFling(uccLien.Id,uccfiling.Acknowledge__c,uccfiling.Acknowledgement_Signatory__c);
        test.stopTest();
    }
    
    /*@IsTest
    static void getDateBasedOnUserTimeZone() {
        Date inputDate=System.today();
        test.startTest();
        BRS_Utility.getDateBasedOnUserTimeZone(inputDate);
        test.stopTest();
    }*/
    
    @IsTest
    static void getAllcerts() {
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Business_Type__c='Limited Partnership';
        update acc;
        Master_Fee__c masterfee = new Master_Fee__c();
        masterfee.Business_Type__c=acc.Business_Type__c;
        masterfee.Filing_Type__c=system.label.brs_CertficateTypeStandard;
        masterfee.Amount__c=10; 
        masterfee.Status__c='Active';
        masterfee.External_ID__c='MF-0000999999';
        insert masterfee;
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(acc);
        test.startTest();
        BRS_Utility.getAllcerts(acc.Id);
        test.stopTest();
    }
    
    @IsTest
    static void getQueryConfig() {
        BRS_online_enquiry__mdt brsmdt = new BRS_online_enquiry__mdt(DeveloperName='Test');
        test.startTest();
        BRS_Utility.getQueryConfig(brsmdt.DeveloperName);
        test.stopTest();
    }
    
    @IsTest
    static void getQueryConfig1() {
        try{
        test.startTest();
        BRS_Utility.getQueryConfig('Test');
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    /*@IsTest
    static void createAccountRelation() {
        try{
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Id p = [select id from profile where name='CT Community User'].id;
        User user1 = BRS_TestDataFactory.createCommunityUser(con,p);
        List<Id> userIds = new List<Id>();
        userIds.add(user1.id);
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(acc.id);
        test.startTest();
        BRS_Utility.createAccountRelation(accountIds);
        test.stopTest();
        } catch(Exception e){
            System.debug(e);
        }
    }*/
    
    @IsTest
    static void getPicklistLabel(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Name='Test Account';
        update acc;
        test.startTest();
        BRS_Utility.getPicklistLabel(Account.sObjectType, 'Name', acc.Name);
        test.stopTest();
    }
    
    @IsTest
    static void linkBusinessToContact(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.id);
        Id p = [select id from profile where name='CT Community User'].id;
        User user1 = BRS_TestDataFactory.createCommunityUser(con,p);
        
        List<Id> userIds = new List<Id>();
        userIds.add(user1.Id);
        
        test.startTest();
        BRS_Utility.linkBusinessToContact(acc.Id, user1.Id);
        BRS_Utility.getUsersDetail(userIds);
        test.stopTest();
    }
    
    @IsTest
    static void updateSectionNameinFiling(){
        try{
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        test.startTest();
        BRS_Utility.updateSectionNameinFiling(filing.Id, filing.Current_Screen__c, filing.Current_Section__c);
        BRS_Utility.updateSectionNameinFiling(null, filing.Current_Screen__c, filing.Current_Section__c);
        test.stopTest();
        }catch(Exception e){
            System.debug(e);
        }
    }
}