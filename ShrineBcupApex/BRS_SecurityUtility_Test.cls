@isTest
public class BRS_SecurityUtility_Test {
    
    @isTest private static void checkDMLAccessTest() {
        
        try{
        
        List<Account> Acclist = new List<Account>();
        Account testAcc1 = new Account(Name = 'Check Name LLC', Mailing_International_Address__c = 'Mailing address', Citizenship__c = 'Domestic',Business_Type__c = 'Religious',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington');
        Acclist.add(testAcc1);
        insert Acclist;
            
            Test.startTest();
            BRS_SecurityUtility.checkDMLAccess(Acclist,'insert');
            BRS_SecurityUtility.checkDMLAccess(Acclist,'update');
            BRS_SecurityUtility.checkDMLAccess(Acclist,'upsert');
            BRS_SecurityUtility.checkDMLAccess(Acclist,'delete');
            Test.stopTest();
            
        } catch(Exception e){
             system.debug('Error occured in BRS_securityutility class');
            
        }

    }
    
    @isTest private static void throwExceptionsTest(){
        
        try{
            
        Test.startTest();
        BRS_SecurityUtility.throwException('insert','Account','Name');
        Test.stopTest();
        } 
        
        Catch(Exception e){
            
            system.debug('Error occured in BRS_securityutility class');
        }
        

        
    }
    
 @isTest private static void checkFieldAccessTest(){
        
        try{
            
        Test.startTest();
        BRS_SecurityUtility.checkFieldAccess(null,'insert','Account',null,null);
        Test.stopTest();
        } 
        
        Catch(Exception e){
            
            system.debug('Error occured in BRS_securityutility class');
        }
        

        
    }
    
    @isTest private static void checkDMLAccessTest1() {
        
        try{
            
                    List<Account> Acclist = new List<Account>();
        Account testAcc1 = new Account(Name = 'Check Name LLC', Mailing_International_Address__c = 'Mailing address', Citizenship__c = 'Domestic', Business_Type__c = 'Religious',  Mailing_Address__c='221B Baker Street, London',Mail_Jurisdiction_International_address__c='221B Baker Street, London', Mailing_Jurisdiction_BusinessCity__c='London',
                                       Mailing_Jurisdiction_BusinessState__c='Washington', Mailing_Jurisdiction_BusinessStreet__c='Baker Street',
                                       Mailing_Jurisdiction_BusinessUnit__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345',
                                       Mailing_Jurisdiction_Country__c='India'
                                       ,BillingStreet = 'Baker Street', BillingCity = 'London', BillingCountry = 'India', BillingState = 'Washington',
                                       BillingPostalCode = '12345', ShippingStreet = 'Baker Street', ShippingCity = 'Mumbai',
                                       ShippingCountry = 'India',ShippingState = 'Maharashtra', ShippingPostalCode = '12345',State_or_Territory_Formation__c='Washington');
            Acclist.add(testAcc1);
            insert Acclist;
            
            Test.startTest();
            BRS_SecurityUtility.checkDMLAccess(Acclist,'insert');
            Test.stopTest();
            
        }
        
        catch(Exception e){
            
            system.debug('Error occured in BRS_securityutility class');
        }
    }
    

}