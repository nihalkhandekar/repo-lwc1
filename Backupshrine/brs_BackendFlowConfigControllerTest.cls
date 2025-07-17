@istest
public class brs_BackendFlowConfigControllerTest {
    TestMethod static void getPageLayoutFields(){
        Test.startTest();
        Map<String,String> parentRecordDetail = new Map<String,String>();
        string objectname;
        string flowName;
        string recordType;
        String parentRecordMap;
        String recordTypename;
        String type;
        String btype;
        Boolean readonlypage;
        
        Account testAcc1 = new Account(Name = 'TestClassAcct1 LLC Co.', Citizenship__c = 'Domestic', Business_Type__c = 'Religious', Status__c='Active');
        insert testAcc1;
        Contact con1 = new Contact(FirstName = 'Test',LastName = 'Contact123',Email = 'testConBrs@test.com',AccountId=testAcc1.Id);
        insert con1;
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c = con1.Id;
        insert workOrder1;
       
        
        RecordType testrec1 = [select id, name from RecordType where (sobjectType = 'Account' AND name = 'Administrator') ];
        
        List<brs_BackendFlowConfigutaionController.ParentRecord> ParentRecordwrapperlist = new List<brs_BackendFlowConfigutaionController.ParentRecord>();
        
       brs_BackendFlowConfigutaionController.ParentRecord ParentRecordwrapper = new brs_BackendFlowConfigutaionController.ParentRecord();
        ParentRecordwrapper.FieldApiname = 'Name';
        ParentRecordwrapper.RecordId = testAcc1.Id;
        //ParentRecordwrapper.isReadonly = false; 
         
        String ParentRecord = JSON.serialize(ParentRecordwrapperlist); 
       
        system.debug(ParentRecord);
        
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        Datetime conformationdate;
        Decimal lefthours;
        String recordTypeId;
        for(Integer i=0;i<2;i++)
        {
        Business_Filing__c filing = new Business_Filing__c();
        //filing.recordtypeid=recordTypeId;
        filing.Account__c=testAcc1.Id;
        filing.status__c='Submitted - Agent acceptance pending';
        filing.Agent_Confirmation_Notification__c=conformationdate;
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
        //filing.Agent_Phone_Number__c=1234567890;
            filing.Agent_Confirmation_Hours_Left__c=lefthours;
            //filing.Business_Type__c='Religious';
            filingList.add(filing);
        }
        insert filingList;
        
         List<brs_BackendFlowConfigutaionController.Requests> reqlist = new List<brs_BackendFlowConfigutaionController.Requests>();
         brs_BackendFlowConfigutaionController.Requests req = new brs_BackendFlowConfigutaionController.Requests();
          req.recordid = filingList[0].Id;
          req.workorderid = workOrder1.Id;
        reqlist.add(req);
        
        String BusinessFilingList;
        BusinessFilingList=JSON.serialize(new List<String>{filingList[0].Id});
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,'Account-Online Filing Review Layout - Domestic LLC', testrec1.Id, ParentRecord,System.Label.AccountAdminRecordType,System.Label.Domestic,System.Label.Business_Type_LLC,False,'Annual Report',null);
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,'Account-Online Filing Review Layout - Domestic LLC', '', ParentRecord,System.Label.AccountAdminRecordType,System.Label.Domestic,System.Label.Business_Type_LLC,False,'Annual Report',null);
        brs_BackendFlowConfigutaionController.findRecordTypes(System.Label.Account);
        brs_BackendFlowConfigutaionController.fetchParentRecord(System.Label.Account,'Name',  testAcc1.Id );
        brs_BackendFlowConfigutaionController.getFieldDependencies(System.Label.Account,'Name');
        brs_BackendFlowConfigutaionController.getFilingforAnualFirstFlow(reqlist);
        brs_BackendFlowConfigutaionController.getFilingforAnualFirstReport(testAcc1.Id,workorder1.Id,BusinessFilingList);
        brs_BackendFlowConfigutaionController.getAllPickList();
        brs_BackendFlowConfigutaionController.updateWorkorder(testAcc1.Id,'Business Filing');
        brs_BackendFlowConfigutaionController.updateWorkorder(testAcc1.Id,'Label');
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,'Account-Online Filing Review Layout - Domestic LLC', '', ParentRecord,System.Label.AccountAdminRecordType,System.Label.Domestic,null,False,'Annual Report',null);
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,'Account-Online Filing Review Layout - Domestic LLC', '', ParentRecord,System.Label.AccountAdminRecordType,null,null,False,'Annual Report',null);
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,'Account-Online Filing Review Layout - Domestic LLC', '', ParentRecord,System.Label.AccountAdminRecordType,null,null,False,null,null);
        brs_BackendFlowConfigutaionController.getPageLayoutFields(System.Label.Account,null, '', ParentRecord,System.Label.AccountAdminRecordType,null,null,False,null,null);
        brs_BackendFlowConfigutaionController.getPageLayoutFields('Business_History__c','Account-Online Filing Review Layout - Domestic LLC', '', ParentRecord,System.Label.AccountAdminRecordType,null,null,False,null,null);
        Test.stopTest();
    }
}