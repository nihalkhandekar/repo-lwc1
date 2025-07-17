@isTest
public with sharing class BRS_Utility2_Test {
    @IsTest
    static void getDataForReportFiling() {
        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c currentBf = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
        
        List<Temp_History__c> tempIsert = new List<Temp_History__c>();
        List<Principal__c> PrincipalIsert = new List<Principal__c>();
        List<Agent__c> AgentIsert = new List<Agent__c>();
        Account accSObj = [Select id ,Citizenship__c,Business_Type__c from Account limit 1];
        currentBf.Account__c=accSObj.Id;
        update currentBf;
        Principal__c P = new Principal__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        Principal__c P2 = new Principal__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        Principal__c P3 = new Principal__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        Principal__c P4 = new Principal__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        Agent__c A2 = new Agent__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        Agent__c A3 = new Agent__c(Business_ID__c = accSObj.Id, Name__c = 'Test Name');
        AgentIsert.add(A2);
        AgentIsert.add(A3);
        PrincipalIsert.add(P);
        PrincipalIsert.add(P2);
        PrincipalIsert.add(P3);
        PrincipalIsert.add(P4);
        Temp_History__c otemp = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Agent', Change_Type__c = 'Created');
        Temp_History__c otemp1 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Agent', Change_Type__c = 'Deleted', Agent__c = A3.Id);
        Temp_History__c otemp12 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Agent', Change_Type__c = 'Edited', Agent__c = A3.Id);
        Temp_History__c otemp13 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Agent', Change_Type__c = 'Edited', Agent__c = A3.Id);
        Temp_History__c otemp2 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Created');
        Temp_History__c otemp3 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Created');
        Temp_History__c otemp4 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Deleted', Principal__c = p.id);
        Temp_History__c otemp5 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Deleted', Principal__c = p2.id);
        Temp_History__c otemp6 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Edited', Principal__c = p3.id);
        Temp_History__c otemp7 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Principal', Change_Type__c = 'Edited', Principal__c = p4.id);
        Temp_History__c otemp8 = new Temp_History__c(Business_filing__c = currentBf.Id, Account__c = accSObj.Id, Name__c = 'test', Type__c = 'Account', Change_Type__c = 'Edited', Principal__c = p4.id);

        tempIsert.add(otemp);
        tempIsert.add(otemp1);
        tempIsert.add(otemp2);
        tempIsert.add(otemp3);
        tempIsert.add(otemp4);
        tempIsert.add(otemp5);
        tempIsert.add(otemp6);
        tempIsert.add(otemp7);
        tempIsert.add(otemp8);
        tempIsert.add(otemp12);
        tempIsert.add(otemp13
        );
        Insert AgentIsert;
        Insert PrincipalIsert;
        insert tempIsert;
        String flowName='';
        Boolean isOverView=false;
        test.startTest();
        BRS_Utility.getDataForReportFiling(currentBf,accSObj,flowName,isOverView);
        BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '12:30 PM');
        BRS_Utility.udtEffectiveDateTime(currentBf, accSObj, Date.today().addDays(1), '');
        test.stopTest();
    }
}