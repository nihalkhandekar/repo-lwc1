@isTest
public class brs_InformationRequestForm_Test {
    
    @testSetup 
    static void setup() {
        Account testAcc1 = new Account(Name = 'TestClassAcct1 LLC Co.', Citizenship__c = 'Domestic', Business_Type__c = 'Religious', Status__c='Active');
        insert testAcc1;
        Contact con1 = new Contact(FirstName = 'Test',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=testAcc1.Id);
        insert con1;
        
        Work_Order__c workOrder = new Work_Order__c(Customer__c=con1.Id, Source__c=System.Label.Online_Label, status__c=System.Label.Completed_Label);
        insert workOrder;
        
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien(System.Label.OFS_Label);
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        UCC_Filing__c uccFiling = new UCC_Filing__c();    
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable',System.Label.BRS_UCC_StatusInProgress,uccLien.Id,System.Label.Amendment_Label);
        uccFiling.Filing_Date__c = System.today();
        uccFiling.Status__c = 'Approved';
        update uccFiling;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CT Community User'];
        User u = BRS_TestDataFactory.createCommunityUser(con1, p.Id);
        Id individualUCCContactRecTypeId = Schema.getGlobalDescribe().get('UCC_Related_Info__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        
        System.runAs(u){
            UCC_Related_Info__c objRelatedInfo4 = new UCC_Related_Info__c();  
            objRelatedInfo4 = BRS_TestDataFactory.createUCCRelatedObject(System.Label.Review_MasterLabel_Type_Claimant,uccFiling.id);
            objRelatedInfo4.Type__c = 'Debtor';
            objRelatedInfo4.Deleted_Flag__c = false;
            objRelatedInfo4.Status__c = 'Completed';
            objRelatedInfo4.Individual_First_Name__c = 'FirstName';
            objRelatedInfo4.Individual_SurName__c = 'surname';
            objRelatedInfo4.RecordTypeId = individualUCCContactRecTypeId;
            objRelatedInfo4.Org_Name__c = 'Orgname';
            update objRelatedInfo4;
        }
        
        Id certRecType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByDeveloperName().get('Request_for_Information').getRecordTypeId();
        Certficate__c cert = BRS_TestDataFactory.createCertificate(certRecType, testAcc1.Id, workOrder.Id);
        Mark__c markobj = new Mark__c();
        markobj.Disclaimer__c= 'ABC';
        markobj.Description_of_Mark__c= 'ABC';
        markobj.Mark_used_for__c= 'ABC';
        markobj.Method_of_use__c= 'ABC';
        markobj.Mark_Type__c= 'Collective Mark';
        markobj.Registration_number__c= '978767836';
        markobj.Owner_Name__c= 'Bitcoin';
        markobj.Renewal_Date__c= system.today();
        markobj.Expiration_Date__c= system.today();
        markobj.Class_of_Goods_Service__c= 'Chemicals';
        markobj.Registration_Date__c= system.today();
        insert markobj;
    }
    
    
    @isTest
    static void getInformationRequestTest() {
        Work_Order__c workOrder = [Select id from Work_Order__c]; 
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c FROM Certficate__c];
        User u = [SELECT Id, Name FROM User LIMIT 1];
        System.debug('username :: '+u.Name);
        Map<ID, UCC_Related_Info__c> m = new Map<ID, UCC_Related_Info__c>([SELECT Id,UCC_Filing_Number__c,Filing_Id__c,Name__c,Filing_WorkOrder__c, Filing_Id__r.Work_Order__c,Individual_First_Name__c,
                                           			Individual_Middle_Name__c,Individual_SurName__c,Org_Name__c,Type__c, Deleted_Flag__c, Status__c, RecordTypeId 
                                           FROM UCC_Related_Info__c LIMIT 1]);
        System.debug('map :: '+JSON.serialize(m));
        
        test.startTest();
        System.runAs(u){
            try{
           // brs_InformationRequestForm.getInformationRequest('FirstName','surname','Orgname','Organization',cert.Id);
           // brs_InformationRequestForm.getInformationRequest('','surname','Orgname','Organization',cert.Id);
            //brs_InformationRequestForm.getRecordData(cert.Id);
            
            //    brs_InformationRequestForm.getRecordData('');
            }catch(Exception e){}
            
        }
        test.stopTest();
    }
    
    
    @isTest
    static void getCopyRequestTest(){
        UCC_Filing__c uccFiling = [Select id,name from UCC_Filing__c];
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien.Type__c = System.Label.OFS_Label;
        uccLien.UCC_Lien_Number__c = 'Deloitte01';
        insert uccLien;
        
        UCC_Related_Info__c objRelatedInfo4 = new UCC_Related_Info__c();  
        objRelatedInfo4 = BRS_TestDataFactory.createUCCRelatedObject(System.Label.Review_MasterLabel_Type_Claimant,uccFiling.id);
        Work_Order__c workOrder = [Select id from Work_Order__c];
        test.startTest();
        try{
            brs_InformationRequestForm.getCopyRequest(uccFiling.Name,workOrder.id); 
            brs_InformationRequestForm.getCopyRequest('','');
         }catch(Exception e){}
        test.stopTest();
    }

    @IsTest
    static void getInformationRequestforSearch(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Owner Name';
        String searchfor='ABC';
        String recordId=cert.Id;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    
    @IsTest
    static void getInformationRequestforSearch1(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Description';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    
    @IsTest
    static void getInformationRequestforSearch3(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Disclaimer';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    @IsTest
    static void getInformationRequestforSearch4(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Registration #';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    @IsTest
    static void getInformationRequestforSearch5(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Method of Use';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    @IsTest
    static void getInformationRequestforSearch6(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Mark Used For';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    
    @IsTest
    static void getInformationRequestforSearch2(){
        try{
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
            
        String searchby='Keyword';
        String searchfor='ABC';
        String recordId=cert.RecordTypeId;
            Mark__c markobj = new Mark__c();
            markobj.Keywords__c='ABC';
            insert markobj;
            List<Mark__c> mark = new List<Mark__c>();
            
        test.startTest();
            brs_InformationRequestForm.getInformationRequestforSearch(searchby, searchfor, recordId, true);
        test.stopTest();
        } catch (Exception exe){
            System.debug(exe);
        }
    }
    
    @IsTest
    static void getSearchRecordData() {
        try{
        Certficate__c cert1 = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
        String recordId1=cert1.RecordTypeId;
        test.startTest();
        brs_InformationRequestForm.getSearchRecordData(recordId1);
        test.stopTest();
        }catch (Exception e){
            System.debug(e);
        }  
    }
    
    @IsTest
    static void getSearchRecordData1(){
        Certficate__c cert = [SELECT Id, Business_Name__c, First_Name__c, Last_Name__c, Debtor_Type__c,RecordTypeId FROM Certficate__c];
        String recordId=cert.Id;
        test.startTest();
        brs_InformationRequestForm.getSearchRecordData(recordId);
        brs_InformationRequestForm.getRequestedInformation(cert);
        test.stopTest();
    }
    
}