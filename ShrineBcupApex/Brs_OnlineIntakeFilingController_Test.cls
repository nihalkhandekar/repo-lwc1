@IsTest
public with sharing class Brs_OnlineIntakeFilingController_Test {
    
    testmethod static void test1(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        
        test.startTest();
        
        Brs_OnlineIntakeFilingController.Requests req1 = new Brs_OnlineIntakeFilingController.Requests();
        req1.category = 'Register a business';
        req1.Customer = con.Id;
        req1.businesstype = 'Domestic';
        req1.legalStructure = 'LLC';
        req1.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests.add(req1);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests);
        
        
        
        Brs_OnlineIntakeFilingController.Requests req2 = new Brs_OnlineIntakeFilingController.Requests();
        req2.category = 'Update business information';
        req2.Customer = con.Id;
        req2.businesstype = 'Amendment';
        req2.accountId = acc.Id;
        req2.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests1 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests1.add(req2);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests1);
        
        Brs_OnlineIntakeFilingController.Requests req3 = new Brs_OnlineIntakeFilingController.Requests();
        req3.category = 'Update agent information';
        req3.Customer = con.Id;
        req3.businesstype = 'Agent Resignation';
        req3.accountId = acc.Id;
        req3.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests2 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests2.add(req3);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests2);
        
        
        Brs_OnlineIntakeFilingController.Requests req4 = new Brs_OnlineIntakeFilingController.Requests();
        req4.category = 'Other';
        req4.Customer = con.Id;
        req4.businesstype = 'Miscellaneous';
        req4.accountId = acc.Id;
        req4.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests3 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests3.add(req4);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests3);
        
        Brs_OnlineIntakeFilingController.Requests req5 = new Brs_OnlineIntakeFilingController.Requests();
        req5.category = 'Merger';
        req5.Customer = con.Id;
        req5.businesstype = 'Domestic';
        req5.legalStructure = 'LLC';
        req5.citizenship = 'Merge into Existing Business';
        req5.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests4 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests4.add(req5);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests4);
        
        Brs_OnlineIntakeFilingController.Requests req6 = new Brs_OnlineIntakeFilingController.Requests();
        req6.category = 'Conversion';
        req6.Customer = con.Id;
        req6.businesstype = 'Domestic';
        req6.legalStructure = 'LLC';
        req6.citizenship = 'Domestic';
        req6.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests5 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests5.add(req6);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests5);
        
        
        
        Brs_OnlineIntakeFilingController.Requests req7 = new Brs_OnlineIntakeFilingController.Requests();
        req7.category = 'Domestication';
        req7.Customer = con.Id;
        req7.businesstype = 'Foreign';
        req4.accountId = acc.Id;
        req7.legalStructure = 'LLC';
        req7.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests6 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests6.add(req7);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests6);
        
        
        try{  
            Brs_OnlineIntakeFilingController.Requests req8 = new Brs_OnlineIntakeFilingController.Requests();
            req8.category = 'Close or reinstate your business';
            req8.Customer = con.Id;
            req8.businesstype = 'Dissolution';
            req8.accountId = acc.Id;
            req8.wrkOrderReceivedDate = System.now();
            List<Brs_OnlineIntakeFilingController.Requests> Requests7 = new List<Brs_OnlineIntakeFilingController.Requests>();
            Requests7.add(req8);
            Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests7);
        }catch(Exception e ){
            
            System.debug(e);
            
        }
        
        Brs_OnlineIntakeFilingController.Requests req9 = new Brs_OnlineIntakeFilingController.Requests();
        req9.category = 'NameReservation';
        req9.Customer = con.Id;
        req9.businesstype = 'Registration of Name';
        req9.accountId = acc.Id;
        req9.wrkOrderReceivedDate = System.now();
        List<Brs_OnlineIntakeFilingController.Requests> Requests8 = new List<Brs_OnlineIntakeFilingController.Requests>();
        Requests8.add(req9);
        Brs_OnlineIntakeFilingController.createWorkorderandBusinessFiling(Requests8);
        
        test.stopTest();
    }
}