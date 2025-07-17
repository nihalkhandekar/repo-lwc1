@isTest
public class brs_businessReservation_Test {
    @testSetup 
    static void setup() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i,Has_Business_Name_Reservation_No__c = true,Reserved_Name_Used__c = false));
        }
        insert testAccts;        
    }
    
    @isTest
    static void getReservedNamesTest() {
        Test.startTest();
        Account acc = new Account(Name = 'TestAcct',Has_Business_Name_Reservation_No__c = true,Reserved_Name_Used__c = false,Status__c='Reserved',Reservation_Expiration_Date__c= (System.today() + 5),Reserved_User__c = UserInfo.getUserId());
        insert acc;
        List<brs_businessReservation> brsReservationList = brs_businessReservation.getReservedNames();
        Test.stopTest();
        System.assertNotEquals(null, brsReservationList);
        brs_businessReservation brs = new brs_businessReservation();
        brs.label = 'label';
        brs.id = 'name';
        brs.shortValue = 'name';
        brs.question = 'name';
        brs.businessId = 'name';
        brs.name = 'name';
    }
    @isTest
     static void setReservedAccountDetailsTest() {
        Test.startTest();
        try {
            Account acc = new Account(Name = 'TestAcct',Has_Business_Name_Reservation_No__c = true,Reserved_Name_Used__c = false,Status__c='Reserved',Reservation_Expiration_Date__c= (System.today() + 5));
            insert acc;
            Account acc1 = new Account(Name = 'TestAcct1',Has_Business_Name_Reservation_No__c = true,Reserved_Name_Used__c = true,Status__c='Reserved',Reservation_Expiration_Date__c= (System.today() + 5));
            insert acc1;
            Boolean isUpdated = brs_businessReservation.setReservedAccountDetails('TestAcct');
            Boolean isUpdated1 = brs_businessReservation.setReservedAccountDetails('TestAcct1');
            //System.assertEquals(true,brs_businessReservation.setReservedAccountDetails('TestAcct0')) ;
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            
        }
        Test.stopTest();
    }
    @isTest
    static void getReservedNamesInvTest() {
        Account accId  = [Select id from Account Limit 1];
        brs_businessReservation.Requests sa=new brs_businessReservation.Requests();
        sa.accId=accId.Id;
        List<brs_businessReservation.Requests> sa1=new List<brs_businessReservation.Requests>();
        sa1.add(sa);
        Test.startTest();
        Account acc = new Account(Name = 'TestAcct',Has_Business_Name_Reservation_No__c = true,Reserved_Name_Used__c = false,Status__c='Reserved',Pin__c='123456',Reservation_Expiration_Date__c= (System.today() + 5), Reserved_User__c = UserInfo.getUserId());
        insert acc;
        brs_businessReservation.getBusinessNameUsingPIN('123456');
        List<brs_businessReservation.Results> results = brs_businessReservation.getReservedNamesInv();
        //System.assertNotEquals(0, results.size()) ;
        delete accId;
        delete [Select id, Name from Account where Has_Business_Name_Reservation_No__c=true and Reserved_Name_Used__c=false and createdbyId =: UserInfo.getUserId()];
        System.debug('****brs_businessReservation.getReservedNamesInv().size()'+brs_businessReservation.getReservedNamesInv().size());
        System.assertEquals(0, brs_businessReservation.getReservedNamesInv().size()) ;
        Test.stopTest();
    }
}