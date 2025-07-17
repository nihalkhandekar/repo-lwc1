@isTest
public class BRS_PaymentUtility_Test {
    @testSetup static void setup() {
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account accInst = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(accInst.id);
        User user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
        
        Id businessRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Id newbusinessRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id UCCRecTypeId = Schema.SObjectType.UCC_Filing__c.getRecordTypeInfosByName().get('New Lien').getRecordTypeId();

        List<Customer_Balance_Transaction__c> insertCBTList = new List<Customer_Balance_Transaction__c>();
        Customer_Balance_Transaction__c conTrans = new Customer_Balance_Transaction__c();
        conTrans.Payment_Source__c = 'Voucher';
        conTrans.Type__c = 'Credit';
        conTrans.Amount__c = 200;
        conTrans.Contact__c = con.Id;
        insertCBTList.add(conTrans);
        
        Customer_Balance_Transaction__c conTran = new Customer_Balance_Transaction__c();
        conTran.Payment_Source__c = 'Voucher';
        conTran.Type__c = 'Debit';
        conTran.Amount__c = 100;
        conTran.Contact__c = con.Id;
        insertCBTList.add(conTran);
        
        Customer_Balance_Transaction__c conTranCheck = new Customer_Balance_Transaction__c();
        conTranCheck.Payment_Source__c = 'Check';
        conTranCheck.Type__c = 'Credit';
        conTranCheck.Amount__c = 200;
        conTranCheck.Contact__c = con.Id;
        insertCBTList.add(conTranCheck);
        
        Customer_Balance_Transaction__c conTranChe = new Customer_Balance_Transaction__c();
        conTranChe.Payment_Source__c = 'Check';
        conTranChe.Type__c = 'Debit';
        conTranChe.Amount__c = 100;
        conTranChe.Contact__c = con.Id;
        insertCBTList.add(conTranChe);
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
       
        List<Work_Order__c> insertWOList = new List<Work_Order__c>();
        Work_Order__c onlineBusWorkorder = new Work_Order__c();
        onlineBusWorkorder.Status__c = 'In-Progress';
        onlineBusWorkorder.Type__c = 'Business';
        onlineBusWorkorder.Source__c = 'Online';
        onlineBusWorkorder.Customer__c = con.Id;
        onlineBusWorkorder.Received_Date__c = System.today();
        insertWOList.add(onlineBusWorkorder);

        Work_Order__c onlineUCCWorkorder = new Work_Order__c();
        onlineUCCWorkorder.Status__c = 'In-Progress';
        onlineUCCWorkorder.Type__c = 'UCC';
        onlineUCCWorkorder.Source__c = 'Online';
        onlineUCCWorkorder.Customer__c = con.Id;
        onlineUCCWorkorder.Received_Date__c = System.today();
        insertWOList.add(onlineUCCWorkorder);

        Work_Order__c otherReqWO = new Work_Order__c();
        otherReqWO.Status__c = 'In-Progress';
        otherReqWO.Type__c = 'Other Requests';
        otherReqWO.Source__c = 'Mail';
        otherReqWO.Customer__c = con.Id;
        otherReqWO.Received_Date__c = System.today();
        insertWOList.add(otherReqWO);

        Work_Order__c mainWorkorder = new Work_Order__c();
        mainWorkorder.Status__c = 'In-Progress';
        mainWorkorder.Type__c = 'UCC';
        mainWorkorder.Source__c = 'Mail';
        mainWorkorder.Customer__c = con.Id;
        mainWorkorder.Received_Date__c = System.today();
        insertWOList.add(mainWorkorder);

        insert insertWOList;

        List<Business_Filing__c> insertBFList = new List<Business_Filing__c>();
        Business_Filing__c onlineBusFiling = new Business_Filing__c();
        onlineBusFiling.Work_Order__c = onlineBusWorkorder.Id;
        onlineBusFiling.RecordTypeId = newbusinessRecTypeId;
        onlineBusFiling.Source__c = 'Online';
        onlineBusFiling.Type__c = 'Business Registration';
        insertBFList.add(onlineBusFiling);

        Business_Filing__c mainBusFiling = new Business_Filing__c();
        mainBusFiling.Work_Order__c = mainWorkorder.Id;
        mainBusFiling.RecordTypeId = newbusinessRecTypeId;
        mainBusFiling.Type__c = 'Business Formation';
        insertBFList.add(mainBusFiling);

        Insert insertBFList;

		List<UCC_Lien__c> insertUCCLList=new List<UCC_Lien__c>();
        UCC_Lien__c uccOnlineLien=new UCC_Lien__c(Name__c='OnlineUCC');
        insertUCCLList.add(uccOnlineLien);
        UCC_Lien__c uccLien=new UCC_Lien__c(Name__c='LienData');
        insertUCCLList.add(uccLien);

        insert insertUCCLList;

        List<UCC_Filing__c> insertUFList = new List<UCC_Filing__c>();
        UCC_Filing__c uccFileOnline = new UCC_Filing__c();
        uccFileOnline.Type__c = 'OFS';
        uccFileOnline.UCC_Lien_Type__c = 'OFS';
        uccFileOnline.Work_Order__c = onlineUCCWorkorder.Id;
        uccFileOnline.UCC_Lien_Id__c = uccOnlineLien.Id;
        uccFileOnline.Filing_Source__c = 'Online';
        uccFileOnline.Amount__c = 200;
        insertUFList.add(uccFileOnline);

        UCC_Filing__c mainUCC = new UCC_Filing__c();
        mainUCC.Type__c = 'OFS';
        mainUCC.RecordTypeId = UCCRecTypeId;
        mainUCC.UCC_Lien_Type__c = 'OFS';
        mainUCC.Work_Order__c = mainWorkorder.Id;
        insertUFList.add(mainUCC);
        
        UCC_Filing__c uccFileInst = new UCC_Filing__c();
        uccFileInst.Type__c = 'Amendment';
        uccFileInst.Amendment_Type__c = 'Amendment';
        uccFileInst.UCC_Lien_Type__c = 'Aircraft';
        uccFileInst.Work_Order__c = mainWorkorder.Id;
        uccFileInst.UCC_Lien_Id__c = uccLien.Id;
        uccFileInst.Amount__c = 200;
        insertUFList.add(uccFileInst);
        
        Insert insertUFList;

        List<Certficate__c> insertCertList = new List<Certficate__c>();
        Certficate__c mainCert = new Certficate__c();
        mainCert.Business__c = accInst.Id;
        mainCert.Certificate_Type__c = 'Express';
        mainCert.Type__c='Certificate of Legal Existence';
        mainCert.Work_Order__c = mainWorkorder.Id;
        insertCertList.add(mainCert);

        Certficate__c certInst = new Certficate__c();
        certInst.Business__c = accInst.Id;
        certInst.Certificate_Type__c = 'Express';
        certInst.Type__c='Certificate of Legal Existence';
        certInst.Filing_Fee__c = 80;
        certInst.Work_Order__c = otherReqWO.Id;
        insertCertList.add(certInst);
        Insert insertCertList;
        
        List<Voucher_Code_Master__c> insertVoucherList = new List<Voucher_Code_Master__c>();
        Voucher_Code_Master__c vouchMaster = new Voucher_Code_Master__c();
        vouchMaster.Amount__c = 100;
        vouchMaster.End_Date__c = Date.valueOf('2030-04-03');
        vouchMaster.Status__c = 'Pending';
        vouchMaster.Voucher_Code__c = '15101996';
        vouchMaster.Start_Date__c = Date.valueOf('2021-04-03');
        insertVoucherList.add(vouchMaster);
        
        Voucher_Code_Master__c vouchMaster2 = new Voucher_Code_Master__c();
        vouchMaster2.Amount__c = 100;
        vouchMaster2.End_Date__c = Date.valueOf('2032-04-03');
        vouchMaster2.Status__c = 'Pending';
        vouchMaster2.Voucher_Code__c = '15101997';
        vouchMaster2.Start_Date__c = Date.valueOf('2021-04-03');
        insertVoucherList.add(vouchMaster2);
        Insert insertVoucherList;
        
        Foreign_Investigation__c forInv= new Foreign_Investigation__c();
        forInv.Business__c = accInst.Id;   
        insert forInv;
        
        Customer_Balance_Transaction__c debitRecBus = new Customer_Balance_Transaction__c();
        debitRecBus.Payment_Source__c = 'Voucher';
        debitRecBus.Type__c = 'Debit';
        debitRecBus.Amount__c = 120;
        debitRecBus.Contact__c = con.Id;
        debitRecBus.Business_Filing__c=onlineBusFiling.Id;
        debitRecBus.Work_order__c = onlineBusWorkorder.Id;
        debitRecBus.Status__c = 'Refunded';
        insertCBTList.add(debitRecBus);

        Customer_Balance_Transaction__c debitRecUCC = new Customer_Balance_Transaction__c();
        debitRecUCC.Payment_Source__c = 'Voucher';
        debitRecUCC.Type__c = 'Debit';
        debitRecUCC.Amount__c = 120;
        debitRecUCC.Contact__c = con.Id;
        debitRecUCC.Work_order__c = onlineUCCWorkorder.Id;
        debitRecUCC.UCC_Filing__c=uccFileOnline.Id;
        insertCBTList.add(debitRecUCC);

        Customer_Balance_Transaction__c commConTrans = new Customer_Balance_Transaction__c();
        commConTrans.Payment_Source__c = 'Voucher';
        commConTrans.Type__c = 'Debit';
        commConTrans.Amount__c = 200;
        commConTrans.Contact__c = con.Id;
        commConTrans.Work_Order__c = mainWorkorder.Id;
        commConTrans.Start_Date__c = System.today();
        commConTrans.Transaction_Date_Time__c = System.now();
        commConTrans.Status__c='Refund In-Progress';
        insertCBTList.add(commConTrans);

        Insert insertCBTList;
        
        List<bt_stripe__Transaction__c> insertBTList = new List<bt_stripe__Transaction__c>();
        bt_stripe__Transaction__c newbtTran = new bt_stripe__Transaction__c();
        newbtTran.bt_stripe__Related_Contact__c = con.Id;
        newbtTran.Work_Order__c = mainWorkorder.Id;
        newbtTran.bt_stripe__Amount__c=100;
        newbtTran.bt_stripe__Transaction_Status__c='Completed';
        newbtTran.bt_stripe__Processed_Date__c=System.now();
        insertBTList.add(newbtTran);

        bt_stripe__Transaction__c onlineUCCWO = new bt_stripe__Transaction__c();
        onlineUCCWO.bt_stripe__Related_Contact__c = con.Id;
        onlineUCCWO.Work_Order__c = onlineUCCWorkorder.Id;
        onlineUCCWO.bt_stripe__Amount__c=100;
        onlineUCCWO.bt_stripe__Processed_Date__c=System.now();
        insertBTList.add(onlineUCCWO);

        bt_stripe__Transaction__c onlineBusWO = new bt_stripe__Transaction__c();
        onlineBusWO.bt_stripe__Related_Contact__c = con.Id;
        onlineBusWO.Work_Order__c = onlineBusWorkorder.Id;
        onlineBusWO.bt_stripe__Amount__c=100;
        onlineBusWO.bt_stripe__Processed_Date__c=System.now();
        insertBTList.add(onlineBusWO);

        bt_stripe__Transaction__c otherReqWOPayment = new bt_stripe__Transaction__c();
        otherReqWOPayment.bt_stripe__Related_Contact__c = con.Id;
        otherReqWOPayment.Work_Order__c = otherReqWO.Id;
        otherReqWOPayment.bt_stripe__Amount__c=100;
        otherReqWOPayment.bt_stripe__Processed_Date__c=System.Today();
        insertBTList.add(otherReqWOPayment);
        insert insertBTList;

        Mark__c mark =new Mark__c();
        mark=BRS_TestDataFactory.createMark();
        List<Mark_Filing__c> listMarkfiling=new List<Mark_Filing__c>();
        Mark_Filing__c markfiling=new Mark_Filing__c();
        markfiling.Filing_Type__c='Registration';
        markfiling.Ist_Expiration_Date__c=System.today();
        markfiling.Class_of_Goods_Service__c='Paints';
        markfiling.Date_of_1st_Use_Anywhere__c=System.today();
        markfiling.Date_of_1st_Use_in_CT__c=System.today();
        markfiling.Disclaimer__c='Disclamied Data';
        markfiling.Expiration_Date__c=system.today();
        markfiling.Federal_Registration_Number_s__c='Date number';
        markfiling.Federal_Registration_of_Mark__c='Yes';
        markfiling.Keywords__c='keywords';
        markfiling.Mark_Type__c='Certification Mark';
        markfiling.Mark_used_for__c='AlMark';
        markfiling.Method_of_use__c='Method used';
        markfiling.Number_of_Pages__c=23;
        markfiling.Other_Owner_Type__c='Owner Type';
        markfiling.Owner_City__c='Washington';
        markfiling.Owner_Country__c='United States';
        markfiling.Owner_Name__c='Jhon';
        markfiling.Owner_State__c='AK';
        markfiling.Owner_Street_Address__c='123 street';
        markfiling.Owner_Type__c='Corporation';
        markfiling.Owner_Unit__c='as123';
        markfiling.Owner_Zip_Code__c='12345';
        markfiling.Partner_Names__c='alex';
        markfiling.Registration_Date__c=System.today();
        markfiling.Renewal_Date__c=System.today();
        markfiling.Work_Order__c=onlineBusWorkorder.Id;
        markfiling.State_Country_of_Formation__c='AK';
        markfiling.Status__c='Approved';
        markfiling.Mark__c=Mark.id;
        insert markfiling;
        
        WRIT_Case__c wc = new WRIT_Case__c();
        wc.Work_Order__c = onlineBusWorkorder.id;
        wc.Number_of_Defendants__c = 4;
        wc.Type__c = 'WRIT Case';
        wc.Status__c = 'In-Progress';
        wc.No_Fee__c = True;
        insert wc;
    }
    
    testmethod static void getVoucher(){
        List<Work_Order__c> workOrderLst = new List<Work_Order__c>([Select id,Type__c,Total_Check_Balance__c,Customer__r.Total_Check_Balance__c,Customer__r.Total_Voucher_Balance__c,Total_Voucher_Balance__c from Work_Order__c where Type__c = 'UCC']);
        List<UCC_Filing__c> uccFiling = new List<UCC_Filing__c>([select id,Type__c,Amount__c,UCC_Lien_Id__c,UCC_Lien_Id__r.Id,Work_Order__c from UCC_Filing__c where UCC_Lien_Id__r.Name__c = 'LienData' and Work_Order__c IN:workOrderLst ]);
        User commUser = [Select Id,ContactId,Contact.Total_Voucher_Balance__c,IsActive from User where IsActive=true and username='testerbrs@noemail.com' LIMIT 1];
        Test.startTest();
        System.runAs(commUser){
            BRS_PaymentUtility.redeemVoucher('15101997',workOrderLst[0].Id,uccFiling[0].Id);
            BRS_PaymentUtility.redeemVoucher('00018736',workOrderLst[0].Id,uccFiling[0].Id);
        }
        try{
            BRS_PaymentUtility.redeemVoucher('15101997',workOrderLst[0].Id,uccFiling[0].Id);
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Script-Thrown Exception'));
        }
        Test.stopTest();
    }
	
    testmethod static void wrapMet(){
        Test.startTest();
        User commUser = [Select Id,ContactId,Contact.Total_Voucher_Balance__c,IsActive from User where IsActive=true and username='testerbrs@noemail.com' LIMIT 1];
        System.runAs(commUser){
            BRS_PaymentUtility.getPaymentHistoryData(null,null);
            BRS_PaymentUtility.getPaymentHistoryData(System.today().addDays(-1),null);
            BRS_PaymentUtility.getPaymentHistoryData(null,System.today());
            BRS_PaymentUtility.getPaymentHistoryData(System.today().addDays(-1),System.today());
        }
        
        Test.stopTest();
    }
    
    testmethod static void getFilingFees(){
        List<UCC_Filing__c> uccFiling = new List<UCC_Filing__c>([select id,Type__c,Amendment_Type__c,UCC_Lien_Type__c,Work_Order__c,UCC_Lien_Id__c,Amount__c from UCC_Filing__c ]);
        Contact con = [Select id from contact where LastName = 'Contact123'];
        List<Work_Order__c> workOrderList =[select Id,Total_Payment__c,Source__c,Customer__c,Customer__r.Allow_negative_balances__c, (select Id,Filing_Type__c,Type__c from Business_Filings__r),
                                                (select Id,Type__c,UCC_Lien_Type__c,Amendment_Type__c ,UCC_Lien_Id__c,UCC_Lien_Id__r.Type__c from UCC_Filings__r where UCC_Lien_Id__r.Name__c = 'LienData') from Work_Order__c where Type__c = 'UCC' AND Source__c = 'Online'];
        BRS_PaymentUtility.getFilingFees(uccFiling[0].id, con.Id, workOrderList[0].id, 200.00);
    }
    
    testmethod static void getFilingFees1(){
        List<Business_Filing__c> bussfillings = new List<Business_Filing__c>([select id,Account__c,Work_Order__c,RecordTypeId,Type__c,Total_Fee__c,Account__r.Franchise_Tax__c,Filing_Fee__c,Include_Expedited_Service__c,Expedited_Service_Fee__c,Franchise_Tax__c from Business_Filing__c WHERE Type__c='Business Formation']);   
        bussfillings[0].Filing_Fee__c=0;
       bussfillings[0].Franchise_Tax__c=0;
        bussfillings[0].Expedited_Service_Fee__c = 0;
        update bussfillings[0];
        Contact con = [Select id from contact where LastName = 'Contact123'];
        List<Work_Order__c> workOrderList =[select Id,Total_Payment__c,Source__c,Customer__c,Customer__r.Allow_negative_balances__c, (select Id,Filing_Type__c,Type__c from Business_Filings__r),
                                                (select Id,Type__c,UCC_Lien_Type__c,Amendment_Type__c ,UCC_Lien_Id__c,UCC_Lien_Id__r.Type__c from UCC_Filings__r where UCC_Lien_Id__r.Name__c = 'LienData') from Work_Order__c where Type__c = 'UCC' AND Source__c = 'Online'];
        Test.startTest();
        BRS_PaymentUtility.getFilingFees(bussfillings[0].id, con.Id, workOrderList[0].id, 200.00);
        Test.stopTest();
    }
    
    testmethod static void createTransaction(){
        List<UCC_Filing__c> uccFiling = new List<UCC_Filing__c>([select id,Type__c,Amendment_Type__c,UCC_Lien_Type__c,Work_Order__c,UCC_Lien_Id__c,Amount__c from UCC_Filing__c ]);
        List<Work_Order__c> workOrderList =new List<Work_Order__c>([select Id,Total_Payment__c,Source__c,Customer__c,Customer__r.Allow_negative_balances__c, (select Id,Filing_Type__c,Type__c from Business_Filings__r),
                                                (select Id,Type__c,UCC_Lien_Type__c,Amendment_Type__c ,UCC_Lien_Id__c,UCC_Lien_Id__r.Type__c from UCC_Filings__r where UCC_Lien_Id__r.Name__c = 'LienData') from Work_Order__c ]);   
        List<Voucher_Code_Master__c> voucherDetailsList = [select Id,Name,Amount__c,End_Date__c,Status__c,Voucher_Code__c,Start_Date__c from Voucher_Code_Master__c 
                                  where Voucher_Code__c= '15101996' Limit 1];
        List<Business_Filing__c> sobjList = new List<Business_Filing__c>([select id,work_order__c from Business_Filing__c]);
        List<Certficate__c> certList = new List<Certficate__c>([SELECT Id,work_order__c from Certficate__c]);
        List<Foreign_Investigation__c> forInvList = new List<Foreign_Investigation__c>([SELECT ID ,Business__c FROM Foreign_Investigation__c]);
        Test.startTest();
         User commUser = [Select Id,ContactId,Contact.Total_Voucher_Balance__c,IsActive from User where IsActive=true and username='testerbrs@noemail.com' LIMIT 1];
        System.runAs(commUser){
        BRS_PaymentUtility.createTransaction(workOrderList[0].Id, uccFiling[0].id, voucherDetailsList[0].Id, 'Credit', 'Voucher', 200.00);
        BRS_PaymentUtility.createTransaction(workOrderList[0].Id, sobjList[0].id, voucherDetailsList[0].Id, 'Credit', 'Voucher', 200.00);
        BRS_PaymentUtility.createTransaction(workOrderList[0].Id, certList[0].id, voucherDetailsList[0].Id, 'Credit', 'Voucher', 200.00);
        BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Credit', 'Voucher', 200.00);
                     Customer_Balance_Transaction__c cbt=BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Debit', 'Voucher', 200.00);
            Customer_Balance_Transaction__c cbt1=BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Debit', 'Trademark Balance', 200.00);
            Customer_Balance_Transaction__c cbt2=BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Debit', 'Direct', 200.00);
             Customer_Balance_Transaction__c cbt3=BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Debit', 'Check', 200.00);
             Customer_Balance_Transaction__c cbt4=BRS_PaymentUtility.createTransaction(workOrderList[0].Id, forInvList[0].id, voucherDetailsList[0].Id, 'Debit', 'Card', 200.00);
            BRS_PaymentUtility.createPartialRefunds(10, new List<Customer_Balance_Transaction__c> {cbt,cbt2,cbt3,cbt4,cbt1});
        }
        Test.stopTest();

    }
    
    testmethod static void createDebitRecordsForOnlineFiling(){
        List<UCC_Filing__c> uccFiling = new List<UCC_Filing__c>([select id,Type__c,Amendment_Type__c,UCC_Lien_Type__c,Work_Order__c,UCC_Lien_Id__c,Amount__c from UCC_Filing__c ]);
        List<Work_Order__c> workOrderList =new List<Work_Order__c>([select Id,Total_Voucher_Balance__c,Total_Check_Balance__c,Total_Payment__c,Source__c,Customer__c,Customer__r.Allow_negative_balances__c,Customer__r.Check_Credit__c,Customer__r.Check_Debit__c,Customer__r.Voucher_Credit__c,Customer__r.Voucher_Debit__c,Customer__r.Total_Check_Balance__c,Customer__r.Total_Voucher_Balance__c from Work_Order__c WHERE Type__c ='Business' AND Source__c='Online']);    
        BRS_PaymentUtility.createDebitRecordsForOnlineFiling(workOrderList[0].Id, uccFiling[0].id);
    }
    
    testmethod static void refundForRejectedFilings(){
     Map<Id,UCC_Filing__c> oldUCCMap = new Map<Id,UCC_Filing__c>([SELECT Id,Type__c,Amendment_Type__c ,UCC_Lien_Type__c ,Work_Order__c ,UCC_Lien_Id__c ,Amount__c ,Status__c ,Filing_Source__c FROM UCC_Filing__c WHERE Type__c = 'OFS' and Filing_Source__c = 'Online' LIMIT 1]);  
     List<UCC_Filing__c> newUCCList = new List<UCC_Filing__c>(); 
     List<UCC_Filing__c> oldUCCList = new List<UCC_Filing__c>(); 
        for(UCC_Filing__c ucc: oldUCCMap.values()){
            ucc.Status__c='Rejected';  
            newUCCList.add(ucc);
        }
        Test.startTest();
        update newUCCList;
        List<Sobject> oldSobjectList = oldUCCList;
        List<Sobject> newSobjectList = newUCCList;
        BRS_PaymentUtility.refundForRejectedFilings(newUCCList, oldUCCMap);
        Test.stopTest();
    }
    
    testmethod static void refundForRejectedFilings1(){
        
        Business_Filing__c businessFiling = [SELECT Id, Account__c, Work_Order__c , Type__c , Total_Fee__c , Source__c ,Status__c FROM Business_Filing__c WHERE Type__c='Business Registration' limit 1];
        businessFiling.Status__c='Rejected'; 
        test.startTest();
        update businessFiling;
        test.stopTest();
    }

    testmethod static void refundForRejectedMarkFilingsTest(){
        
        Mark_Filing__c markFiling = [SELECT Id, Filing_Type__c , Work_Order__c ,Status__c,Mark__c FROM Mark_Filing__c WHERE Filing_Type__c ='Registration' limit 1];
        markFiling.Status__c='Rejected'; 
        test.startTest();
        update markFiling;
        test.stopTest();
    }
    testmethod static void createBalanceforRejectedMarkFilingsTest(){
        
        Mark_Filing__c markFiling = [SELECT Id, Filing_Type__c , Work_Order__c ,Status__c,Mark__c FROM Mark_Filing__c WHERE Filing_Type__c ='Registration' limit 1];
        markFiling.Status__c='Rejected'; 
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn.Work_Order__c = markFiling.Work_Order__c;
        txn.bt_stripe__Amount__c = 90;
        txn.bt_stripe__Transaction_Status__c = 'Completed';
        txn.bt_stripe__Payment_Status__c = 'Captured';
        //txn.bt_stripe__Related_Contact__c = con.Id;
        txn.bt_stripe__Processed_Date__c = System.today();
        //txn.bt_stripe__Payment_Schedule__c = lstNewPaySchedule[0].Id;
        insert txn;
         Contact con = [Select id from contact LIMIT 1];
        Customer_Balance_Transaction__c customerBal = BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.Id,System.Label.BRS_Transaction_Type_Debit ,100);
        customerBal.Mark_Filing__c=markFiling.Id;
        update customerBal;
        
        test.startTest();
        update markFiling;
      
        BRS_PaymentUtility.createBalanceforRejectedMarkFilings(new list<Mark_Filing__c> {markFiling}, new Set<Id>{markFiling.Id});
        
        BRS_PaymentUtility.paymentWrapperFetchTxnErr(txn.Id);
        test.stopTest();
    }
    
}