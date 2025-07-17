@isTest
public class brs_genericSearchClass_Test {
    @testSetup static void setup() {
        
    }
    testmethod static void getAllFiltersMet() {
        List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
        brs_genericSearchClass.sendEmailApex(strAdr,'Link','searchtype');
        brs_genericSearchClass.getAllFilters('Business Search Status');
        
        
        List<String> selectedOpt = new List<String>();
        selectedOpt.add('Include_Lapsed_Liens');
        
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapper wrapInstObj = new brs_genericSearchBusinessClass.searchObjFromUIWrapper();
        wrapInstObj.searchString = searchInst;
        wrapInstObj.type = '';
        wrapInstObj.filters = filters;
        
        
        brs_genericSearchBusinessClass.filterWrapper wrapInst = new brs_genericSearchBusinessClass.filterWrapper();
        wrapInst.type = 'Type__c';
        wrapInst.selectedOptions = selectedOpt;
        String myJSON = JSON.serialize(wrapInstObj);
        brs_genericSearchClass.getAllFilters('Business Search Status');
    }
    testmethod static void getAllFiltersMetInd() {
        brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        List<string> selOptions = new List<string>();
        selOptions.add('OFS');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Type__c';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
        brs_genericSearchClass.sendEmailApex(strAdr,'Link','searchtype');
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapper wrapInstObj = new brs_genericSearchBusinessClass.searchObjFromUIWrapper();
        wrapInstObj.searchString = searchInst;
        wrapInstObj.type = 'DebtorSearchIndividual';
        wrapInstObj.filters = filters;
        
        String myJSON = JSON.serialize(wrapInstObj);
          try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
       try{
         brs_genericSearchClass.getInfoForCSV(myJSON);
           }catch(Exception e){System.debug(e);}
    }
    /*testmethod static void getAllFiltersMet2() {
     
     List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
     UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
     objRelatedInfo.City__c = 'City';   
     objRelatedInfo.Country__c = 'country';
     objRelatedInfo.isAuthorizer__c = true;
     objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
     objRelatedInfo.Org_Name__c = 'Orgname';
     objRelatedInfo.Type__c = 'Secured Party';
     objRelatedInfo.Street__c = 'Street';
     objRelatedInfo.Zip_Code__c = '11111';
     objRelatedInfo.Suffix__c = 'Suffix';   
     lstRelatedInfo.add(objRelatedInfo);
     
     insert lstRelatedInfo;
        brs_genericSearchClass.SearchString searchInst= new brs_genericSearchClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = '';
        List<brs_genericSearchClass.filterWrapper> filters = new List<brs_genericSearchClass.filterWrapper>();
        
        List<string> selOptions = new List<string>();
        selOptions.add('OFS');
        
        List<String> selOptionsStr = new List<String>();
        selOptionsStr.add('Include_Lapsed_Liens');
        
        brs_genericSearchClass.filterWrapper filter1 = new brs_genericSearchClass.filterWrapper();
        filter1.type = 'Lien_Status';
        filter1.selectedOptions = selOptionsStr;
        filters.add(filter1);

        
        brs_genericSearchClass.filterWrapper filter = new brs_genericSearchClass.filterWrapper();
        filter.type = 'Type__c';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
        brs_genericSearchClass.sendEmailApex(strAdr,'Link','searchtype');
        
        brs_genericSearchClass.searchObjFromUIWrapper wrapInstObj = new brs_genericSearchClass.searchObjFromUIWrapper();
        wrapInstObj.searchString = searchInst;
        wrapInstObj.type = 'DebtorSearchIndividual';
        wrapInstObj.filters = filters;
        
        String myJSON = JSON.serialize(wrapInstObj);
        brs_genericSearchClass.getAllRecords(myJSON);
        brs_genericSearchClass.getInfoForCSV(myJSON);
    }*/
    testmethod static void getAllFiltersMetLien() {
        test.starttest();
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        List<string> selOptions = new List<string>();
        selOptions.add('OFS');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Type__c';
        filter.selectedOptions = selOptions;
        filters.add(filter);
        
        List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
        brs_genericSearchClass.sendEmailApex(strAdr,'Link','Lien');
        brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd indWrapInst = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
        indWrapInst.searchString = '000111';
        indWrapInst.type = 'LienSearch';
        indWrapInst.filters = filters;
        String myJSON = JSON.serialize(indWrapInst);
          try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
       try{
         brs_genericSearchClass.getInfoForCSV(myJSON);
           }catch(Exception e){System.debug(e);}
      List<brs_genericSearchBusinessClass.filterOptionWrapper> wrapList = new List<brs_genericSearchBusinessClass.filterOptionWrapper>();
      brs_genericSearchBusinessClass.filterTypeWrapper brsWrap = new brs_genericSearchBusinessClass.filterTypeWrapper();
      //brsWrap.Id = 'Id';
      brsWrap.MasterLabel = 'Label';
      brsWrap.apiName = 'apiName';
      brsWrap.filterIcon = 'icon';
      brsWrap.dataType = 'type';
      brsWrap.searchType = 'type';
      brsWrap.filterOptions = wrapList;
        test.stoptest();
    }
    testmethod static void getAllFiltersMetBusiness() {
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        try{
            brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd indWrapInst = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
            indWrapInst.searchString = '000111';
            indWrapInst.type = 'Business_Search';
            indWrapInst.filters = filters;
            String myJSON = JSON.serialize(indWrapInst);
              try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
        }
        catch(Exception e){
           System.assertEquals('Script-thrown exception',e.getMessage());
            brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd indWrapInst = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
            indWrapInst.searchString = '000111';
            indWrapInst.type = 'Business_Search';
            indWrapInst.filters = filters;
        }
       
    }
    
       testmethod static void getAllFiltersLapsed() {
        brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        List<string> selOptions = new List<string>();
        selOptions.add('Include_Lapsed_Liens');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Lien_Status';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapper wrapInstObj = new brs_genericSearchBusinessClass.searchObjFromUIWrapper();
        wrapInstObj.searchString = searchInst;
        wrapInstObj.type = 'DebtorSearchIndividual';
        wrapInstObj.filters = filters;
        
        String myJSON = JSON.serialize(wrapInstObj);
           try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
      try{
         brs_genericSearchClass.getInfoForCSV(myJSON);
           }catch(Exception e){System.debug(e);}
    }
    testmethod static void getAllFiltersLapsedForLien() {
        brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        List<string> selOptionsType= new List<string>();
        selOptionsType.add('OFS');
        
        brs_genericSearchBusinessClass.filterWrapper filter1 = new brs_genericSearchBusinessClass.filterWrapper();
        filter1.type = 'Type__c';
        filter1.selectedOptions = selOptionsType;
        filters.add(filter1);
        
        List<string> selOptions = new List<string>();
        selOptions.add('Include_Lapsed_Liens');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Lien_Status';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd indWrapInst = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
        indWrapInst.searchString = '000111';
        indWrapInst.type = 'LienSearch';
        indWrapInst.filters = filters;
        
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='000111',Lapse_Date__c=System.today().addYears(-1)));
        uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2', Lapse_Date__c=System.today().addYears(1)));
        insert uccLien;
        
        
        String myJSON = JSON.serialize(indWrapInst);
           try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
        try{
            brs_genericSearchClass.getInfoForCSV(myJSON);
        }catch(Exception ex){}
        
    }
    testmethod static void getAllFiltersOrg() {
       brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        List<string> selOptions = new List<string>();
        selOptions.add('Include_Lapsed_Liens');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Lien_Status';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        List<string> selOptionsType= new List<string>();
        selOptionsType.add('OFS');
        
        brs_genericSearchBusinessClass.filterWrapper filter1 = new brs_genericSearchBusinessClass.filterWrapper();
        filter1.type = 'Type__c';
        filter1.selectedOptions = selOptionsType;
        filters.add(filter1);
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd wrapInstObj = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
        wrapInstObj.searchString = 'Test org';
        wrapInstObj.type = 'DebtorSearchOrganisation';
        wrapInstObj.filters = filters;
        
        List<brs_genericSearchBusinessClass.relatedFilingWrapper> relatedWrap = new List<brs_genericSearchBusinessClass.relatedFilingWrapper>();
        
        Set<String> LienIDs = new Set<String>();
        
        brs_genericSearchBusinessClass.objWrapper wrapObj = new brs_genericSearchBusinessClass.objWrapper();
        wrapObj.debtorName = 'Debtor';
        wrapObj.LienIDs = LienIDs;
        wrapObj.lienCountForDebtor = 2;
        wrapObj.lienType = 'OFS';
        wrapObj.lapseDate = String.valueOf(System.today());
        wrapObj.lienNumber = '12334';
        //wrapObj.IRSNumber = '12345';
        //wrapObj.lienSfId = '';
        wrapObj.relatedFilingLst = relatedWrap;
        wrapObj.activeLien = true;
        wrapObj.LapsedLien = false;
        //wrapObj.filingNumber = '1235';
        //wrapObj.filingType = 'OFS';
        //wrapObj.debtorNameIndexed = 'test';
        Set<String> orgInx = new Set<String>{'test1','test2'};
        wrapObj.LienIDsForOrgIndexed = orgInx;
        String myJSON = JSON.serialize(wrapInstObj);
          try{
        brs_genericSearchClass.getAllRecords(myJSON);
           }catch(Exception e){System.debug(e);}
        
 try{
         brs_genericSearchClass.getInfoForCSV(myJSON);
           }catch(Exception e){System.debug(e);}
        
    }
    testmethod static void getAllLiensMet() {
        test.startTest();
        List<UCC_Lien__c> uccLien = new List<UCC_Lien__c>();
        uccLien.add(new UCC_Lien__c(Name__c='LienData1',UCC_Lien_Number__c='TestData1',Lapse_Date__c=null));
         uccLien.add(new UCC_Lien__c(Name__c='LienData2',UCC_Lien_Number__c='TestData2',Lapse_Date__c=System.today()));
        insert uccLien;
        uccLien[0].Lapse_Date__c=System.today()-100;
        uccLien[1].Lapse_Date__c=System.today()+100;
        update uccLien;
        Id fileRecTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();
        UCC_Lien__c lienInst = BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onOff2 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c filingInst = BRS_TestDataFactory.createUCCFiling('As a transmitting utility','Approved',uccLien[0].Id,'OFS');
        filingInst.Filing_Date__c=System.today()-101;
        update filingInst;
        List<String> uccLienIds = new List<String>();
        Set<String> lienIds = new Set<String>();
        Set<ID> LienIdsUniq = new Set<ID>();
        for(UCC_Lien__c uccInst : uccLien){
            uccLienIds.add(uccInst.Id);
            lienIds.add(uccInst.Id);
            LienIdsUniq.add(uccInst.Id);
        }
        brs_genericSearchBusinessClass.objWrapper objWrap = new brs_genericSearchBusinessClass.objWrapper();
        brs_genericSearchClass.getAllLiens(uccLienIds);
        List<brs_genericSearchBusinessClass.relatedFilingWrapper> relatedWrap = new List<brs_genericSearchBusinessClass.relatedFilingWrapper>();
        brs_genericSearchBusinessClass.objWrapper wrapObjC = new brs_genericSearchBusinessClass.objWrapper('12334','OFS',String.valueOf(System.today()), filingInst);
        brs_genericSearchBusinessClass.objWrapper wrapObj = new brs_genericSearchBusinessClass.objWrapper();
        wrapObj.debtorName = 'Debtor';
        wrapObj.LienIDs = lienIds;
        wrapObj.lienCountForDebtor = 2;
        wrapObj.lienType = 'OFS';
        wrapObj.lapseDate = String.valueOf(System.today());
        wrapObj.lienNumber = '12334';
        //wrapObj.IRSNumber = '12345';
        //wrapObj.lienSfId = '';
        wrapObj.relatedFilingLst = relatedWrap;
        wrapObj.activeLien = true;
        wrapObj.LapsedLien = false;
        //wrapObj.filingNumber = '1235';
        //wrapObj.filingType = 'OFS';
        
        brs_genericSearchBusinessClass.relatedFilingWrapper relatedWrapInst = new brs_genericSearchBusinessClass.relatedFilingWrapper();
        relatedWrapInst.filingNumber = '87658746';
        relatedWrapInst.filingDate = String.valueOf(System.today());
        relatedWrapInst.filingType = 'OFS';
        //relatedWrapInst.filingSfId = 'test';
        
        test.stopTest();
    }
    
     testmethod static void getAllFiltersMetInd2() {
        brs_genericSearchBusinessClass.SearchString searchInst= new brs_genericSearchBusinessClass.SearchString();
        searchInst.surName = 'Surname';
        searchInst.firstName = 'fisrtName';
        List<brs_genericSearchBusinessClass.filterWrapper> filters = new List<brs_genericSearchBusinessClass.filterWrapper>();
        
        List<string> selOptions = new List<string>();
        selOptions.add('OFS');
        
        brs_genericSearchBusinessClass.filterWrapper filter = new brs_genericSearchBusinessClass.filterWrapper();
        filter.type = 'Type__c';
        filter.selectedOptions = selOptions;
        
        filters.add(filter);
        
        List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
        brs_genericSearchClass.sendEmailApex(strAdr,'Link','searchtype');
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapper wrapInstObj = new brs_genericSearchBusinessClass.searchObjFromUIWrapper();
        wrapInstObj.searchString = searchInst;
        wrapInstObj.type = 'DebtorSearchIndividual';
        wrapInstObj.filters = filters;
        
        String myJSON = JSON.serialize(wrapInstObj);
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        
        
             test.startTest();
             
             /******************************/
             UCC_Lien__c lienInst1 = BRS_TestDataFactory.createUCCLien('OFS');
            lienInst1.Status__c='Completed';
         lienInst1.Lapse_Date__c=System.today();
            update lienInst1;
             UCC_Filing__c filingInst = BRS_TestDataFactory.createUCCFiling('As a transmitting utility','Approved',lienInst1.Id,'OFS');
             BRS_online_enquiry__mdt oe = [SELECT Download_Limit__c, Include_Filters__c, Inner_Query_Limit__c, Search_Limit__c, Search_Object__c, Search_Object_fields__c, SOQL_Query__c FROM BRS_online_enquiry__mdt WHERE DeveloperName = 'LienSearch' LIMIT 1];   
             brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd indWrapInst = new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
             indWrapInst.searchString =lienInst1.UCC_Lien_Number__c ;
             indWrapInst.type = 'LienSearch';
             indWrapInst.filters = filters;
             List<String> filterTypes = new List<String>{system.label.brs_uccFilingStatus,System.label.In_Progress_Label,System.label.Rejected};
             List<UCC_Lien__c> lstlien= [SELECT Type__c,UCC_Lien_Number__c ,Status__c,(select id,Status__c from UCC_Filings__r ) from UCC_Lien__c ];
              //' + '  ' +oe.Search_Object_fields__c + ' '+ 'FROM' + ' '+ oe.Search_Object__c +' '+'where Status__c!=\''+System.Label.BRS_Archived+'\'' + 'AND Status__c!=\'' + System.label.In_Progress_Label+'\'' ;
             //queryString += ' ' + 'and UCC_Lien_Number__c = \''+ '12345'+'\' and Type__c in: selOptions';
             //List<Sobject> sObjList = Database.query(queryString);
              system.debug('@@@@@@@@@@@lstlien'+lstlien);
              system.debug('@@@@@@@@@@@lstlien'+lstlien[0].getSObjects('UCC_Filings__r'));
             brs_genericSearchBusinessClass.retrieveLienRecord(myJSON,oe,indWrapInst);
             /******************************/
            //brs_genericSearchClass.getInfoForCSV(myJSON);
             test.stopTest();   
            
           
    }
    
     testmethod static void getExportRecordsTest(){

 List<UCC_Related_Info__c> lstRelatedInfo = new List<UCC_Related_Info__c>();
     UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c();  
     objRelatedInfo.International_Address__c = 'International address';
     //objRelatedInfo.Address__c = 'Mailing aaddress';
     objRelatedInfo.City__c = 'City';   
     objRelatedInfo.Country__c = 'country';
     objRelatedInfo.isAuthorizer__c = true;
     objRelatedInfo.RecordTypeId=Schema.SObjectType.UCC_Related_Info__c.getRecordTypeInfosByDeveloperName().get(System.Label.Organization_Label).getRecordTypeId();
     objRelatedInfo.Org_Name__c = 'Orgname';
     objRelatedInfo.Type__c = 'Secured Party';
     objRelatedInfo.Street__c = 'Street';
     objRelatedInfo.Zip_Code__c = '11111';
     objRelatedInfo.Suffix__c = 'Suffix';   
     lstRelatedInfo.add(objRelatedInfo);
     
     insert lstRelatedInfo;
                List<String> strList = new List<String>();
        List<String> strList1 = new List<String>();
        List<String> strList2 = new List<String>();
        strList.add('OFS');
        strList1.add('Approved');
        strList2.add('Rejected');
        List<brs_myFilingsClass.filterWrapper> wrapList = new List<brs_myFilingsClass.filterWrapper>();
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Customer_Balance_Transaction__c customerBal = new Customer_Balance_Transaction__c();
        customerBal=BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Credit',4000);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'online','In-Progress');
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod=BRS_TestDataFactory.genericPaymentMethod(workOrder.id);
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
        RecordType recordTypeId =[select id,Name,developername from RecordType where developername='New_Lien'];
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling=BRS_TestDataFactory.createUCCFiling2('Not Applicable',recordTypeId.id,'OFS',workOrder.id,'Approved',uccLien.id,'OFS');
        UCC_Filing__c uccFiling1 = new UCC_Filing__c();
         List<String> strAdr = new List<String>();
        strAdr.add('abc@abc.com');
         test.startTest();
         try{
        	brs_genericSearchClass.sendEmailApex(strAdr,'Link','Trade And Service Marks');
        	brs_genericSearchBusinessClass.retrieveExportRecords(lstRelatedInfo);
          	brs_genericSearchClass.getUCCDates();
         }catch(Exception ex){
            System.debug('error'+ex);
         }
         test.stopTest();
	 
}
    testmethod static void getDebtorInfoTest() {
        
        BRS_online_enquiry__mdt onlineEnquiry = [
                    SELECT Search_Object__c,Search_Limit__c,Include_Filters__c,Download_Limit__c,Search_Object_fields__c,DeveloperName
                    FROM BRS_online_enquiry__mdt
                    WHERE DeveloperName ='DebtorSearchIndividual'
                ];
        
        try{
        
        
        brs_genericSearchBusinessClass.searchObjFromUIWrapper sw= new brs_genericSearchBusinessClass.searchObjFromUIWrapper();
        //sw.orgName = '';
        //sw.lastName = 'test1';
        //sw.firstName = '';
        sw.type = 'DebtorSearchIndividual';
        sw.filters = null;
        sw.isStartsWithSearch=true;
        brs_genericSearchBusinessClass.LienSearchWrapper swp = new brs_genericSearchBusinessClass.LienSearchWrapper(sw);
        
           
        brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd sw1= new brs_genericSearchBusinessClass.searchObjFromUIWrapperNONDebtorInd();
        /*sw1.orgName = '';
        sw1.lastName = 'test3431';
        sw1.firstName = 'wiufhresw';*/
        sw1.type = 'DebtorSearchIndividual';
        sw1.filters = null;
        sw1.isStartsWithSearch=true;
        brs_genericSearchBusinessClass.LienSearchWrapper swp1 = new brs_genericSearchBusinessClass.LienSearchWrapper(sw1);
        
        
                    Test.startTest();
        brs_genericSearchBusinessClass.retrieveDebtorInfo(onlineEnquiry, swp, true);
        brs_genericSearchBusinessClass.retrieveDebtorInfo(onlineEnquiry, swp1, true);
        test.stopTest();
        } catch(Exception e){}

        
    } 
    
    testmethod static void wrapperTest(){
        brs_genericSearchBusinessClass.RelatedInfoWrapper ri= new brs_genericSearchBusinessClass.RelatedInfoWrapper();
        ri.AssignorName='test';
        ri.Name='test name';
        ri.City='test city';
        ri.Country='test country';
        ri.InternationalAddress='test in add';
        ri.State='test state';
        ri.Street='test street';
        ri.Type='type';
        ri.Unit='unit';
        ri.Zipcode='234567';
        
        brs_genericSearchBusinessClass.FilingRecordWrapper frw = new brs_genericSearchBusinessClass.FilingRecordWrapper();
        frw.FilingDate= system.today();
        frw.FilingNumber='1124';
        frw.IRSNumber='678';
        frw.LapseDate=system.today();
        frw.LienType='type';
        frw.Page='1';
        frw.StartPage=1;
        frw.Type='Type';
        frw.VolumeNumber='9';
        //frw.relatedList=ri;
        
        brs_genericSearchBusinessClass.filingRelatedInfoWrap fr= new brs_genericSearchBusinessClass.filingRelatedInfoWrap();
        fr.FilingRec=frw;
        fr.publicLink='Test';
        

        
        brs_genericSearchBusinessClass.GenericSearchWrapper gsw= new brs_genericSearchBusinessClass.GenericSearchWrapper();
        gsw.actualCount=1;
        
            
        
    }
    
    
    testmethod static void fetchInterfaceConfigTest(){
        
        brs_genericSearchBusinessClass.InterfaceConfigWrapper icf= new brs_genericSearchBusinessClass.InterfaceConfigWrapper();
        icf.endUrl='test';
        icf.forgeRockEndUrl='tesr forgerockendurl';
        
        Interface_Configuration__mdt interfaceConfig = new  Interface_Configuration__mdt ();
        interfaceConfig.Current_Environment__c='SAT';
        interfaceConfig.MasterLabel='Test';
        
        try{
        Test.startTest();
        brs_genericSearchBusinessClass.fetchInterfaceConfig('Test');
        Test.stopTest();
        } catch(exception e){}
        
    }
    
    
    testmethod static void retrieveUCCRelatedRecordTest(){
        
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling.Lien_Filing_Type__c = 'Not Applicable';
        uccFiling.Amount__c = 50;
        uccFiling.Status__c = 'In-Progress';
        uccFiling.Lapse_Date__c=system.today();
        uccFiling.Type__c = 'OFS';
        UCCfiling.Amendment_Type__c='Amendment';
        UCCfiling.Filing_Number__c='1234';
        insert uccFiling;
        BRS_TestDataFactory.createUCCRelatedObject('Debtor',uccFiling.id);
        
        
        test.startTest();
         brs_genericSearchClass.getUCCRelatedRecords('1234');
        brs_genericSearchBusinessClass.retrieveUCCRelatedRecord('1234');
        test.stopTest();
    }
  
    
    testmethod static void encryptdecryptTest(){
        try{
        BRS_Encryption_Key_Setting__c EncryptSetting = new BRS_Encryption_Key_Setting__c();
        EncryptSetting.Crypto_Key__c = 'eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=';
        insert EncryptSetting;
        String myString = 'eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=';
        Blob myBlob = Blob.valueof(myString);
        
        Test.startTest();
      brs_genericSearchBusinessClass.encrypt('eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=');
            brs_genericSearchClass.encrypt('eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=');
        brs_genericSearchBusinessClass.decrypt('eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=');
            brs_genericSearchClass.decrypt('eDjHXXFK+q0Cs3+mgAp5jv22OAOQcjb4o6ISFRSTIEo=');
        Test.stopTest();
            
        }catch(exception e){}
    }
}