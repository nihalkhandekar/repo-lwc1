/*********************************************************************************************
* NAME:  CredentialResponse_Test
* DESCRIPTION: Test class for CredentialResponse
* 				 
*
* @AUTHOR: Himanshi Mayal
* @DATE: 3/10/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Himanshi Mayal				  3/10/2021                              Created
*********************************************************************************************/
@isTest
public class CredentialResponse_Test {
    @isTest
    public static void parseDatatest() {
        
        String credentialData = '{"credentials": [{"eLicense_Credential_ID": "468998","eLicense_Contact_ID": "153924","eLicense_SOTS_ID": null,"Full_Credential_Code": "HIC.0615952","Business_Individual_Name": "JOHN KEEFER","Expiration_Date": "11/30/2011","Credential_Type": "HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status": "INACTIVE","Credential_Public_Status_Reason": "EXPIRED MORE THAN 3 YEARS - MUST REAPPLY","Display_Category_Status": "Inactive","Display_Category_Value": "-1","MainAddress": "904 WHALLEY AVENUE  #4 NEW HAVEN, CT 06515","MailingAddress": "904 WHALLEY AVENUE  #4 NEW HAVEN, CT  06515","Doing_Business_As": "","Cust_ID": "KEEF153924","Cust_Email": "johnkkeefer@yahoo.com","ActionItems": []},{"eLicense_Credential_ID": "1217651","eLicense_Contact_ID": "153924","eLicense_SOTS_ID": null,"Full_Credential_Code": "HIC.0639573","Business_Individual_Name": "JOHN KEEFER","Expiration_Date": "11/30/2015","Credential_Type": "HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status": "INACTIVE","Credential_Public_Status_Reason": "EXPIRED MORE THAN 3 YEARS - MUST REAPPLY","Display_Category_Status": "Inactive","Display_Category_Value": "-1","MainAddress": "904 WHALLEY AVENUE  #4 NEW HAVEN, CT 06515","MailingAddress": "904 WHALLEY AVENUE  #4 NEW HAVEN, CT  06515","Doing_Business_As": "","Cust_ID": "KEEF153924","Cust_Email": "johnkkeefer@yahoo.com","ActionItems": []}]}';
            //'{"credentials":[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}}]';
	Test.startTest();
        CredentialResponse credResponse = CredentialResponse.parseData(credentialData);
        
    Test.stopTest();
        System.debug('credResponse --> '+credResponse);
	}
	
    
    public static void ActionItemsTest() {
        Credential__c cred1 = new Credential__c();
        cred1.Credential_Id__c = '123456';
        cred1.External_Id__c = 'test2';
        insert cred1;
        
        Account ac = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='Grazitti',
            Status__c = System.Label.ACTIVE
        );
        insert ac;
        
        Action_Item__c newActionItem = QnA_TestDataFactory.createActionItem('Open',ac.Id,cred1.Id);
        CredentialResponse.ActionItems ObjectId = new CredentialResponse.ActionItems(); 
        ObjectId.eLicense_SOTS_ID = newActionItem.ExternalId__c;
        ObjectId.Credential= newActionItem.Credential__c;
        ObjectId.Name=newActionItem.Action_Item_Name__c;
        ObjectId.eLicense_Credential_Action_Due_Date=string.ValueOf(newActionItem.Due_Date__c);
        ObjectId.Description=newActionItem.Description__c;
        ObjectId.Link_Text=newActionItem.Link_Text__c;
        ObjectId.Link_URL=newActionItem.Link_URL__c;
        ObjectId.Activity_ID=newActionItem.Account__c;
    }

    @isTest
    public static void testCredentialDetails() {
        String credentialData = '[{"value":"4376","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":false,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":true,"Full_Credential_Code":"HIC.0548674","Expiration_Date":"11/30/2020","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":null,"eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"44kHwq2jxORaO6CsN+PA7G1DDHO/Ls58aX9EtFJ+myU=","Cust_Email":"MGdDfeFUqOrB3OX2UIk3UeImzy4wYxj9ZfMJ1aWK5NtFMBfxs3jNvpyC5s/MmTPh","Credential_Type":"HOME IMPROVEMENT CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]},{"value":"220617","MainAddress":"1065 Paper Street SUFFIELD, CT 06078","MailingAddress":"1065 Paper Street SUFFIELD, CT  06078","linkValueNotSelected":true,"isEmailVerified":true,"isCredIdVerified":true,"isContactCred":false,"Full_Credential_Code":"NHC.0000519","Expiration_Date":"09/30/2021","errorMsg":"","eLicense_SOTS_ID":null,"eLicense_Dupcred_ID":"4376","eLicense_Credential_ID":"4376","eLicense_Contact_ID":"22763","Doing_Business_As":"BEGIN HOMES INC","Display_Category_Value":"1","Display_Category_Status":"Active","Cust_ID":"oC16Rdiisd0+IHi+gGo4BNhkk+T9E/8PQ2W955Bq1TY=","Cust_Email":"3ZNc8VEwTKOmNHHYa1X1b5+eZ/3FAxs26vzyH4HFn0wHzaOkFmeLH/xgkNDY/JPu","Credential_Type":"NEW HOME CONSTRUCTION CONTRACTOR","Credential_Public_Status_Reason":"CURRENT","Credential_Public_Status":"ACTIVE","credAlreadyLinked":false,"checked":true,"businessRecordID":null,"Business_Individual_Name":"BEGIN HOMES INC","ActionItems":[]}]';
		Test.startTest();
        CredentialResponse.CredentialDetail cd = new CredentialResponse.CredentialDetail();
        List<CredentialResponse.CredentialDetail> credetnials = (List<CredentialResponse.CredentialDetail> ) JSON.deserializeStrict(credentialData, CredentialResponse.CredentialDetail[].class);
        Test.stopTest();
    }
}