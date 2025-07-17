@isTest
public class BRS_Utility_TestMock {
    
     @isTest 
    static void updateRecordsFromTempTest() {
        
        Id profileId = [select id from profile where name='System Administrator'].id;
          User user = QnA_TestDataFactory.createAdminUser(profileId);
         
         
         system.runAs(user){
             
             try{
      Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Agent__c agent = BRS_TestDataFactory.createAgent(testAcc1.id);
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance ,testAcc1.Id,'',System.label.Name_Change_Amendment,'Completed');
       Principal__c principal = BRS_TestDataFactory.createPrincipal();
             
        Temp_History__c tmpHistory = BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,testAcc1.id,'Principal','Deleted');
        
        BRS_Utility.updateRecordsFromTemp(testAcc1.Id, 'Principal', filing.Id);
         tmpHistory.Change_Type__c = system.label.brs_maintenance_tempEdited;
         Update tmpHistory;
         BRS_Utility.updateRecordsFromTemp(testAcc1.Id, 'Principal', filing.Id); 
         }
         
        catch(exception e){
            system.debug('catch exception-->'+e);
        }

}
}
    
     @isTest 
    static void updateRecordsFromTempTest2() {
        
        Id profileId = [select id from profile where name='System Administrator'].id;
          User user = QnA_TestDataFactory.createAdminUser(profileId);
         
         
         system.runAs(user){
             
             try{
        
         Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Agent__c agent = BRS_TestDataFactory.createAgent(testAcc1.id);
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance ,testAcc1.Id,'',System.label.Name_Change_Amendment,'Completed');
      
        Principal__c principal = BRS_TestDataFactory.createPrincipal();
       
             
        Temp_History__c tmpHistory = BRS_TestDataFactory.createTempHistoryObject2(filing.Id,principal.id,testAcc1.id,'Agent','Deleted');
      
        BRS_Utility.updateRecordsFromTemp(testAcc1.Id, 'Agent', filing.Id);
         tmpHistory.Change_Type__c = system.label.brs_maintenance_tempEdited;
         Update tmpHistory;
         BRS_Utility.updateRecordsFromTemp(testAcc1.Id, 'Agent', filing.Id); 
         }
         
        catch(exception e){
            system.debug('catch exception-->'+e);
        }

}
}
    
    /*@isTest
    static void sendMailByBodyTest() {
        
        Id profileId = [select id from profile where name='System Administrator'].id;
          User user = QnA_TestDataFactory.createAdminUser(profileId);
         
         
         system.runAs(user){
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con1 = BRS_TestDataFactory.createContactObject(testAcc1.Id);
             
        Work_Order__c workOrder = BRS_TestDataFactory.createWorkOrderObject(con1.Id, 'Online', 'Completed');
       
         Id certRecType = Schema.SObjectType.Certficate__c.getRecordTypeInfosByDeveloperName().get('Request_for_Information').getRecordTypeId();
        Certficate__c cert = BRS_TestDataFactory.createCertificate(certRecType, testAcc1.Id, workOrder.Id);
   
       
             Map<Id,Certficate__c> certificateMap = new Map<Id,Certficate__c>();
             
             List<Attachment> docs = [SELECT Id, Name, Body, ContentType 
                            FROM Attachment 
                            WHERE parentId =: certificateMap.keyset()];
             
        List<String> stringTolist = new List<String>();
             stringTolist.add('abcd@gmail.com');
        List<String> stringCClist = new List<String>();
              stringCClist.add('efgh@gmail.com');
             
        List<Messaging.EmailFileAttachment> listAttach = new List<Messaging.EmailFileAttachment>();
            for(Attachment doc: docs){
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType(doc.ContentType);
                    attach.setFileName(doc.Name);
                    attach.setInline(false);
                    attach.Body = doc.Body;
                listAttach.add(attach);
            }
             
          
         BRS_Utility.sendMailByBody(stringTolist , stringCClist, 'test subject','test body', 'orgWideEmailName', listAttach);
         }

}*/
}