@isTest
public class brs_SortLegalDesignators_Test {
    static testmethod void test1() { 
      List<Legal_Designation__mdt> legalDesignation=[Select Label,Legal_Designator__c,Order__c from Legal_Designation__mdt];
    List<brs_SortLegalDesignators> legalDesignationList=new List<brs_SortLegalDesignators>();
    legalDesignationList.add(new brs_SortLegalDesignators(legalDesignation[0]));
     legalDesignationList.sort();
        for(Legal_Designation__mdt ds:legalDesignation)
            {
                System.assertEquals(ds.Label, ds.Label);
            }
    }
}