/*********************************************************************************************
* NAME:  Brs_CompleteIntakeButton_Test
* DESCRIPTION: Test class for Brs_CompleteIntakeButton
*          
*
* @AUTHOR: Mousumi Patro
* @DATE: 12/09/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
Mousumi Patro                   12/09/2021                             
*********************************************************************************************/
@istest
public with sharing class Brs_CompleteIntakeButton_Test {
    @testSetup
    private static void setup() {
        
        contact con=new contact();
        con.FirstName='F1';
        con.LastName='L1';
        con.bt_stripe__Primary_Stripe_Customer__c=true;
        insert con;
        
        Work_Order__c order = new  Work_Order__c();
        order.Type__c='Business';
        order.Source__c='Mail';
        order.Customer__c=con.id;
        insert order;
        
        
        RecordType rt =[select id,Name,developername from RecordType where developername='Business'];
        Account acc=new Account();
        acc.name='testbusinessname';
        acc.Account_Name_Without_Designators__c='testbusinessname';
        acc.Has_Business_Name_Reservation_No__c=false;
        //acc.Name_of_Applicant__c=cus.id;
        acc.RecordTypeId=rt.id;
        acc.Status__c='Pending';
        acc.Is_Intake_Filing__c=false;
        insert acc;
        
        Business_Filing__c filing = new Business_Filing__c();
        //filing.Type__c='Withdrawal';
        filing.Account__c=acc.id;
        filing.Status__c='In-Progress';
        filing.Source__c='Mail';
        insert filing;
        
        
    }
    
    @istest public static void testupdateStatus(){
        
        try{
            Test.startTest();
            
            List<Work_Order__c> w=[Select id from Work_Order__c];
            List<Business_Filing__c> b=[Select id from Business_Filing__c];
            Brs_CompleteIntakeButton.updateStatus(w[0].id,b[0].id,true,'businessfilingnametest');
            List<Account>acclist=[select id,name from account where name='businessfilingnametest'];
            System.assertEquals(1, acclist.size());
            
        } catch (Exception e){}
        
        Test.stopTest();
    }
    
    
}