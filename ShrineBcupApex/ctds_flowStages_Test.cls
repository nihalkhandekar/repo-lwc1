@isTest
private class ctds_flowStages_Test {
    @isTest
    static void getSideNavigationSectionTest(){
       
       List<ctds_flowStages.Requests> lstRequests = new List<ctds_flowStages.Requests>();
       ctds_flowStages.Requests objReq = new ctds_flowStages.Requests();
       objReq.flowName = 'UCC-3 Lien';
       lstRequests.add(objReq);
        
       Test.startTest();
       List<ctds_flowStages.Results> lstResult = ctds_flowStages.getSideNavigationSection(lstRequests);
       System.assertNotEquals(0,lstResult.size());    
       Test.stopTest();
        
    }
}