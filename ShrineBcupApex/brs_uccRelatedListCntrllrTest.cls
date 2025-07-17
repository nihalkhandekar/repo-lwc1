@isTest
private class brs_uccRelatedListCntrllrTest {
    
    @testSetup static void setup() {
        List<UCC_Lien__c> lstUCCLien = new List<UCC_Lien__c>(); 
        List<UCC_Filing__c> lstUCCFiling = new List<UCC_Filing__c>();          
        UCC_Lien__c uccLien1=new UCC_Lien__c(Name__c='LienData1',Type__c='IRS');
        lstUCCLien.add(uccLien1) ;
        UCC_Lien__c uccLien2=new UCC_Lien__c(Name__c='LienData1',Type__c=System.label.Aircraft_Label);
        lstUCCLien.add(uccLien2) ;
        UCC_Lien__c uccLien3=new UCC_Lien__c(Name__c='LienData1',Type__c=System.label.JudgmentTypeLabel);
        lstUCCLien.add(uccLien3) ;
        UCC_Lien__c uccLien4=new UCC_Lien__c(Name__c='LienData1',Type__c=System.label.JudgmentPersonalPropertyLabel);
        lstUCCLien.add(uccLien4) ;
        UCC_Lien__c uccLien5=new UCC_Lien__c(Name__c='LienData1',Type__c=System.label.Vessel_Label);
        lstUCCLien.add(uccLien5) ; 
        UCC_Lien__c uccLien6=new UCC_Lien__c(Name__c='LienData6',Type__c=System.label.JudgmentPersonalPropertyLabel);
        lstUCCLien.add(uccLien6) ; 
        UCC_Lien__c uccLien7=new UCC_Lien__c(Name__c='LienData7' , Type__c = System.label.JudgmentTypeLabel);
        lstUCCLien.add(uccLien7) ; 
        UCC_Lien__c uccLien8=new UCC_Lien__c(Name__c='LienData8' ,Type__c = 'Municipal' );
        lstUCCLien.add(uccLien8) ; 

        insert lstUCCLien;
        OnOff_Filing_Auto_Refund__c onOff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccObj1 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Type__c='IRS');
        lstUCCFiling.add(uccObj1);
        UCC_Filing__c uccObj2 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Type__c=System.label.Aircraft_Label,UCC_Lien_Id__c = lstUCCLien[1].id);
        lstUCCFiling.add(uccObj2);
        system.debug('uccObj2:::'+uccObj2);
        UCC_Filing__c uccObj3 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Type__c=System.label.JudgmentTypeLabel,UCC_Lien_Id__c = lstUCCLien[2].id);
        lstUCCFiling.add(uccObj3);
        UCC_Filing__c uccObj4 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Type__c=System.label.JudgmentPersonalPropertyLabel,UCC_Lien_Id__c = lstUCCLien[3].id);
        lstUCCFiling.add(uccObj4);      
        UCC_Filing__c uccObj5 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Id__c = lstUCCLien[0].id, Lien_Filing_Type__c = 'Not Applicable');
        lstUCCFiling.add(uccObj5);
        UCC_Filing__c uccObj6 =  new UCC_Filing__c(Status__c = 'In-Progress',UCC_Lien_Id__c = lstUCCLien[4].id, Pages__c = '5th lien');
        lstUCCFiling.add(uccObj6);
        UCC_Filing__c uccObj7 =  new UCC_Filing__c(Status__c = 'In-Progress' ,UCC_Lien_Id__c = lstUCCLien[5].id , Pages__c = '6th lien');
        lstUCCFiling.add(uccObj7); 
        UCC_Filing__c uccObj8 =  new UCC_Filing__c(Status__c = 'In-Progress' ,UCC_Lien_Id__c = lstUCCLien[6].id , Pages__c = '7th lien');
        lstUCCFiling.add(uccObj8); 
         UCC_Filing__c uccObj9 =  new UCC_Filing__c(Status__c = 'In-Progress' ,UCC_Lien_Id__c = lstUCCLien[7].id , Pages__c = '8th lien');
        lstUCCFiling.add(uccObj9); 
        
        insert lstUCCFiling;
        
        List<UCC_Related_Info__c> uccContacts = new List<UCC_Related_Info__c>();
        UCC_Related_Info__c objRelatedInfo = new UCC_Related_Info__c(); 
        objRelatedInfo.Filing_Id__c = lstUCCFiling[0].id;
        objRelatedInfo.Type__c = System.label.BRS_UCC_Debtor_Label;
		objRelatedInfo.International_Address__c = 'Test';
        objRelatedInfo.Country__c ='USA';
        uccContacts.add(objRelatedInfo);
        
        UCC_Related_Info__c objRelatedInfo2 = new UCC_Related_Info__c(); 
        objRelatedInfo2.Filing_Id__c = lstUCCFiling[1].id;
        objRelatedInfo2.Type__c = System.label.BRS_UCC_Assignor_Label;
		objRelatedInfo2.International_Address__c = 'Test';
        objRelatedInfo2.Country__c ='USA';
        uccContacts.add(objRelatedInfo2);
		
		insert uccContacts;
    }
    
    @isTest
    static void testme(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where UCC_Lien_Type__c='IRS'];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
    @isTest
    static void testAircraft(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where UCC_Lien_Type__c=:System.label.Aircraft_Label];        
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
    @isTest
    static void testJudgmentPersonal(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where UCC_Lien_Type__c=:System.label.JudgmentPersonalPropertyLabel];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
    @isTest
    static void testJudgment(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where UCC_Lien_Type__c=:System.label.JudgmentTypeLabel];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
    @isTest
    static void testNotApplicable(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where Lien_Filing_Type__c='Not Applicable' ];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
     @isTest
    static void testNotApplicable2(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where Pages__c = '5th lien'];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
     @isTest
    static void testNotApplicable3(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where Pages__c = '6th lien'];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
     @isTest
    static void testNotApplicable4(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where Pages__c = '7th lien'];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
     @isTest
    static void testNotApplicable5(){
        OnOff_Filing_Auto_Refund__c onOff =[SELECT Id, Name, Auto_Refund_UCC_Filing__c, Auto_Refund_Business_Filing__c FROM OnOff_Filing_Auto_Refund__c limit 1];
        UCC_Filing__c uccFilingObj = [Select id,UCC_Lien_Type__c from UCC_Filing__c where Pages__c = '8th lien'];
        test.startTest();
        brs_uccRelatedListCntrllr.getUCCContactRecords(uccFilingObj.id);
        test.stopTest();
    }
    
}