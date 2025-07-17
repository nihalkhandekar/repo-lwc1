@isTest
public class BRS_UpdateForeignInvestRecordsTest {
    
    @isTest
    public static void testvalidateNewRecord() {
        List<Foreign_Investigation__c> lstFI = new List<Foreign_Investigation__c>();
        Foreign_Investigation__c fi = new Foreign_Investigation__c();
       // fi.Business__c = testAcc.id;
        fi.Case_Status__c = 'Pending';
		fi.Case_Initiated_By__c = 'Complaint';
        fi.Latest_Letter_Type__c = 'Demand Letter';
        fi.Payment_Plan_Established__c = true;
        fi.Business_Type__c = 'Stock';
        fi.Date_Began_Transacting_Business_in_CT__c = System.today().addDays(-120);
        fi.Registration_Date__c = System.today();
        fi.Business_Name__c = 'Test Business';
        fi.Business_Street_Address_1__c = '221B Baker\'s Street';
        fi.Business_City__c = 'Stamford';
        fi.Business_State__c = 'Connecticut';
        fi.Business_Zip_Code__c = '85487';
        fi.Business_Country__c = 'United States';  
        fi.Monthly_Payable__c = 100;
        fi.Due_Date__c = System.Today()+5;
             // System.debug('****pmfi1**'+pmfi1);
        //insert fi;        
        lstFI.add(fi);
        BRS_TestDataFactory.insertSObject(lstFI);
        
        List<Foreign_Investigation_Mail_Tracking__c> lstFIMail = new List<Foreign_Investigation_Mail_Tracking__c>();
        Foreign_Investigation_Mail_Tracking__c fiMail1 = BRS_TestDataFactory.setForeignInvestigationMailTrackingRecords('Demand Letter #1', lstFI[0].Id);lstFIMail.add(fiMail1);
        BRS_TestDataFactory.insertSObject(lstFIMail);
        
        Test.startTest();
        
        List<BRS_UpdateForeignInvestigationRecords.FlowInputs> lstFlowVar = new List<BRS_UpdateForeignInvestigationRecords.FlowInputs>();
        BRS_UpdateForeignInvestigationRecords.FlowInputs flowVar = new BRS_UpdateForeignInvestigationRecords.FlowInputs();
        flowVar.letterType = lstFI[0].Latest_Letter_Type__c;
        flowVar.foreignInvestigationId = lstFI[0].Id;
        lstFlowVar.add(flowVar);
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        String str1 = BRS_UpdateForeignInvestigationRecords.validateNewRecord(lstFI[0].Id, lstFI[0].Latest_Letter_Type__c);
        
        Test.stopTest();
    }
    
	@isTest
    public static void testUpdateFIDueDate() {
        List<Foreign_Investigation__c> lstFI = new List<Foreign_Investigation__c>();
        Foreign_Investigation__c fi1 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #1', 'Open - DL1', System.today()); lstFI.add(fi1);
        Foreign_Investigation__c fi2 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #2', 'Open - DL2', System.today()); lstFI.add(fi2);
        Foreign_Investigation__c fi3 = BRS_TestDataFactory.setForeignInvestigationRecords('Final Demand Letter', 'Pending', System.today()); lstFI.add(fi3);
        Foreign_Investigation__c fi4 = BRS_TestDataFactory.setForeignInvestigationRecords('Interrogatory Letter', 'Pending', System.today()); lstFI.add(fi4);
        Foreign_Investigation__c fi5 = BRS_TestDataFactory.setForeignInvestigationRecords('Settlement Letter', 'Pending', null); lstFI.add(fi5);
        Foreign_Investigation__c fi6 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #1', 'Pending', null); lstFI.add(fi6);
        Foreign_Investigation__c fi7 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #2', 'Open - DL1', null); lstFI.add(fi7);
        Foreign_Investigation__c fi8 = BRS_TestDataFactory.setForeignInvestigationRecords('Final Demand Letter', 'Open - DL2', null); lstFI.add(fi8);
        BRS_TestDataFactory.insertSObject(lstFI);
        Test.startTest();
        List<BRS_UpdateForeignInvestigationRecords.FlowInputs> lstFlowVar = new List<BRS_UpdateForeignInvestigationRecords.FlowInputs>();
        BRS_UpdateForeignInvestigationRecords.FlowInputs flowVar = new BRS_UpdateForeignInvestigationRecords.FlowInputs();
        flowVar.letterType = lstFI[0].Latest_Letter_Type__c;
        flowVar.foreignInvestigationId = lstFI[0].Id;
        lstFlowVar.add(flowVar);
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[1].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[1].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[2].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[2].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);        
        
        lstFlowVar[0].letterType = lstFI[3].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[3].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[4].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[4].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[5].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[5].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[6].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[6].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[7].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[7].Id;
        BRS_UpdateForeignInvestigationRecords.updateFIDueDate(lstFlowVar);
        
        Test.stopTest();
    }

    @isTest
    public static void testUpdateFIReqFields() {
        List<Foreign_Investigation__c> lstFI = new List<Foreign_Investigation__c>();
        Foreign_Investigation__c fi1 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #1', 'Open - DL1', System.today()); lstFI.add(fi1);
        Foreign_Investigation__c fi2 = BRS_TestDataFactory.setForeignInvestigationRecords('Demand Letter #2', 'Open - DL2', null); lstFI.add(fi2);
        Foreign_Investigation__c fi3 = new Foreign_Investigation__c();
        fi3.Case_Status__c = 'Pending';
        fi3.Case_Initiated_By__c = 'Complaint';
        fi3.Latest_Letter_Type__c = 'Demand Letter #1';
        fi3.Payment_Plan_Established__c = true;
        fi3.Business_Type__c = 'Stock';
        fi3.Registration_Date__c = System.today();
        fi3.Business_Name__c = 'Test Business';
        fi3.Business_Street_Address_1__c = '221B Baker\'s Street';
        fi3.Business_City__c = 'Stamford';
        fi3.Business_State__c = 'Connecticut';
        fi3.Business_Zip_Code__c = '85487';
        fi3.Business_Country__c = 'United States';  
        fi3.Monthly_Payable__c = 100;
        fi3.Due_Date__c = System.Today()+5;
        lstFI.add(fi3);
        
        Foreign_Investigation__c fi4 = new Foreign_Investigation__c();
        fi4.Case_Status__c = 'Pending';
        fi4.Case_Initiated_By__c = 'Complaint';
        fi4.Latest_Letter_Type__c = 'Demand Letter #1';
        fi4.Payment_Plan_Established__c = true;
        fi4.Business_Type__c = 'Stock';
        fi4.Registration_Date__c = System.today();
        fi4.Date_Began_Transacting_Business_in_CT__c = System.today().addDays(-120);
        fi4.Business_Name__c = 'Test Business';
        fi4.Business_Street_Address_1__c = '221B Baker\'s Street';
        fi4.Business_City__c = 'Stamford';
        fi4.Business_State__c = 'Connecticut';
        fi4.Business_Zip_Code__c = '85487';
        fi4.Monthly_Payable__c = 100;
        fi4.Due_Date__c = System.Today()+5;
        lstFI.add(fi4);
        
        Foreign_Investigation__c fi5 = new Foreign_Investigation__c();
        fi5.Case_Status__c = 'Pending';
        fi5.Case_Initiated_By__c = 'Complaint';
        fi5.Latest_Letter_Type__c = 'Demand Letter #1';
        fi5.Payment_Plan_Established__c = true;
        fi5.Registration_Date__c = System.today();
        fi5.Date_Began_Transacting_Business_in_CT__c = System.today().addDays(-120);
        fi5.Business_Name__c = 'Test Business';
        fi5.Business_Street_Address_1__c = '221B Baker\'s Street';
        fi5.Business_City__c = 'Stamford';
        fi5.Business_State__c = 'Connecticut';
        fi5.Business_Zip_Code__c = '85487';
        fi5.Business_Country__c = 'United States';  
        fi5.Monthly_Payable__c = 100;
        fi5.Due_Date__c = System.Today()+5;
        lstFI.add(fi5);
        
        Foreign_Investigation__c fi6 = new Foreign_Investigation__c();
        fi6.Case_Status__c = 'Pending';
        fi6.Case_Initiated_By__c = 'Complaint';
        fi6.Latest_Letter_Type__c = 'Interrogatory Letter';
        fi6.Business_Name__c = 'Test Business';
        lstFI.add(fi6);
        
        BRS_TestDataFactory.insertSObject(lstFI);
        
        Test.startTest();
        
        List<BRS_validateForeignInvestigationRecord.FlowInputs> lstFlowVar = new List<BRS_validateForeignInvestigationRecord.FlowInputs>();
        BRS_validateForeignInvestigationRecord.FlowInputs flowVar = new BRS_validateForeignInvestigationRecord.FlowInputs();
        flowVar.letterType = lstFI[0].Latest_Letter_Type__c;
        flowVar.foreignInvestigationId = lstFI[0].Id;
        lstFlowVar.add(flowVar);
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[1].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[1].Id;
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[2].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[2].Id;
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[3].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[3].Id;
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[4].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[4].Id;
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        lstFlowVar[0].letterType = lstFI[5].Latest_Letter_Type__c;
        lstFlowVar[0].foreignInvestigationId = lstFI[5].Id;
        BRS_validateForeignInvestigationRecord.checkRequiredFields(lstFlowVar);
        
        Test.stopTest();
    }
}