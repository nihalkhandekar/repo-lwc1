/* DESCRIPTION: This class contains methods to send email and text message to agent.
*
* @AUTHOR:  Priyanka
* @DATE:    3/9/2021 
*s
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Priyanka                         3/9/2021                           Created the first version
* Tamkanat
*********************************************************************************************/
global without sharing class BRS_SendNotificationtoAgent {
	public static final string BRS_SendNotificationtoAgentLabel = 'BRS_SendNotificationtoAgent';
    public static final String sendMessageLabel = 'sendMessage';
    
    public class accObjWrapper{
        String accId;
        String accName;
        String citizenship;
        String businessType;
        String agentPhnNo;
        Boolean isConfReq;
        String agentType;
        Boolean isPOAddressOutOfCT;
    }
    global with sharing class Requests {
        @InvocableVariable
        global Id accId;
        @InvocableVariable
        global Business_filing__c busFilObj;
        
    }  
    public class AgentDetaisWrapper{
        @AuraEnabled public Agent__c agentRec {get; set;}
		@AuraEnabled public Temp_History__c tempRec {get; set;}
        @AuraEnabled public String agentSelection {get; set;}
		@AuraEnabled public String filingUpdated {get; set;}
		@AuraEnabled public Boolean isTempRec {get; set;}
        @AuraEnabled public Boolean isLinkValid {get; set;}
    }
    
        
    @InvocableMethod 
    public static void sendMessage(List<Requests> results){
        try{
            if(results.size()>0 && results[0].busFilObj!=null){
                User userDetails = [select Id, firstname,lastname from User where Id = :UserInfo.getUserId()];
                String loggedInUserName = userDetails.firstname +' '+userDetails.lastname;
                Business_filing__c busFiObj = results[0].busFilObj;
                Account accObj = [Select id,name,Business_Type__c,Self_Nomination_as_Agent__c,citizenship__c,BillingState,(Select id, type__c,Name__c,Email__c,Agent_Phone__c,User_Contact_ID__c ,Business_ID__c from Agents1__r limit 1),(Select id, type__c,Name__c,Email__c,Agent_Phone__c, User_Contact_ID__c ,Business_ID__c from Agents__r limit 1) from Account where id=: results[0].busFilObj.Account__c];
                Agent__c agentObj = new Agent__c();
                if(accObj.Agents1__r.size()>0){
                    agentObj = (Agent__c)accObj.Agents1__r;
                }
                else if(accObj.Agents__r.size()>0){
                    agentObj = (Agent__c)accObj.Agents__r;
                }
                Boolean updateStatusAndSendNotification = false;
                Boolean updateStatustoAgencyReview = false;
                Boolean agentChanged = false;
                Boolean agentSelfAcceptance=false;
                Boolean containsKeyword = false;
                Boolean isDomesticLLC = false;
                Boolean isSOTSAgent = false;
                Boolean isNameHasDBA=false;
                if(accObj.Name != null){
                    String BusinessName=accObj.Name;
                    String BusinessNameRemoveSpace=BusinessName.replaceAll('[^\\w\\s]', '');
                    Pattern cooPattern = Pattern.compile('(?i)(\\W|^)dba(\\W|\\z)');
                    Pattern cooPattern1 = Pattern.compile('(?i)(\\W|^)d b a(\\W|\\z)');
                    Pattern cooPattern2 = Pattern.compile('(?i)(\\W|^)dbas(\\W|\\z)');
                    Pattern cooPattern3 = Pattern.compile('(?i)(\\W|^)doing business as(\\W|\\z)');
                    if(cooPattern.matcher(BusinessNameRemoveSpace).find() || cooPattern1.matcher(BusinessNameRemoveSpace).find() || cooPattern2.matcher(BusinessNameRemoveSpace).find() ||cooPattern3.matcher(BusinessNameRemoveSpace).find())
                    {
                        isNameHasDBA=true;
                    }
                    List<String> keywordsLst = (System.label.brs_BusinessApprovalLogicKeywords).split(';');
                    for(String word : keywordsLst) {
                        if((accObj.Name).containsIgnoreCase(word)){
                            containsKeyword = true;
                            break;
                        }        
                    }
                }
                if(busFiObj.Self_Nomination_as_Agent__c !=null && busFiObj.Self_Nomination_as_Agent__c==true){
                    agentSelfAcceptance= true;
                }
                List<Temp_History__c> tempHistoryAgentChange = new  List<Temp_History__c>();
                if((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==System.label.First_Report || busFiObj.Type__c==System.label.Label_Change_Agent)){
                    tempHistoryAgentChange = [select Id,Business_ID__c,createddate,Type__c,Email__c,Phone__c,name__c from Temp_History__c where Business_ID__c=:accObj.Id and Business_Filing__c =:busFiObj.Id and Type__c=: System.Label.Agent and Change_Type__c= :System.Label.Created order by createddate limit 1];
                    if(!tempHistoryAgentChange.isEmpty()){
                        if(loggedInUserName==tempHistoryAgentChange[0].name__c && busFiObj.Self_Nomination_as_Agent__c !=null && busFiObj.Self_Nomination_as_Agent__c==true){
                            agentChanged=false;
                        }
                        else{
                            agentChanged=true;
                            if(tempHistoryAgentChange[0].name__c == System.label.Secretary_Of_State){
                                isSOTSAgent = true;
                            }
                        }
                    }
                }
                if(((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==system.Label.First_Report || busFiObj.Type__c==system.Label.Label_Change_Agent) && agentChanged==true) || (busFiObj.Type__c != system.Label.Annual_Report && busFiObj.Type__c !=system.Label.First_Report) || (busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label)){
                    if(!isSOTSAgent){
                        if((accObj.Citizenship__c == system.Label.Domestic_Label_Comparable && (accObj.Business_Type__c==system.Label.Stock || accObj.Business_Type__c==system.Label.Non_Stock || accObj.Business_Type__c==System.label.B_Corp || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable)) || (  accObj.Citizenship__c ==system.Label.Foreign_Label_Comparable && (accObj.Business_Type__c==system.Label.LLP || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable))){
                            updateStatusAndSendNotification=true;
                        }
                        if(accObj.Citizenship__c ==system.Label.Foreign_Label_Comparable && ((accObj.Business_Type__c==system.Label.Stock || accObj.Business_Type__c==system.Label.Non_Stock|| accObj.Business_Type__c==system.Label.LLC || accObj.Business_Type__c==system.Label.LLP || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable) && (agentObj.Type__c!=System.label.Secretary_of_the_State_Comparable || (!tempHistoryAgentChange.isEmpty() && tempHistoryAgentChange[0].Type__c!=System.label.Secretary_of_the_State_Comparable))) ){ 
                            updateStatusAndSendNotification=true;
                        } 
                        if(accObj.Citizenship__c == system.Label.Domestic_Label_Comparable && accObj.Business_Type__c==system.Label.LLC && ( ((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==system.Label.First_Report || busFiObj.Type__c==system.Label.Label_Change_Agent) && agentChanged==true) || (busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label))  ){ 
                            
                            updateStatusAndSendNotification=true;
                        }
                           if((accObj.Citizenship__c == system.Label.Domestic_Label_Comparable && (accObj.Business_Type__c==system.Label.LLP ) && accObj.BillingState!=system.Label.CT) || (accObj.Citizenship__c == system.Label.Foreign_Label_Comparable && (accObj.Business_Type__c==system.Label.LLP || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable) && agentChanged==true)){ 
                            updateStatusAndSendNotification=true;
                        }                  
                    if((accObj.Citizenship__c == system.Label.Domestic_Label_Comparable && (accObj.Business_Type__c==system.Label.LLP || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable || accObj.Business_Type__c==system.Label.Stock || accObj.Business_Type__c==system.Label.Non_Stock || accObj.Business_Type__c==system.Label.B_Corp )) || (accObj.Citizenship__c == system.Label.Foreign_Label_Comparable && (accObj.Business_Type__c==system.Label.LLP || accObj.Business_Type__c==system.Label.Limited_Partnership_Comparable || accObj.Business_Type__c==system.Label.Stock || accObj.Business_Type__c==system.Label.Non_Stock || accObj.Business_Type__c==system.Label.LLC ))){
                        updateStatustoAgencyReview = true;
                    }
                      }
                    if(accObj.Citizenship__c == system.Label.Domestic_Label_Comparable && accObj.Business_Type__c==system.Label.LLC){
                        isDomesticLLC = true;
                    }
                }
                
                if((updateStatusAndSendNotification == true && !agentSelfAcceptance) || (isDomesticLLC && containsKeyword)){
                    
                /*    if(busFiObj.Agent_Confirmation_Hours_Left__c!=null){
                        if(busFiObj.Agent_Confirmation_Hours_Left__c==24 || busFiObj.Agent_Confirmation_Hours_Left__c==48){                            
                            if((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==system.Label.First_Report || busFiObj.Type__c==system.Label.Label_Change_Agent)&& !tempHistoryAgentChange.isEmpty()){
                                BRS_SendNotificationtoAgent.callSendMessage(null,String.valueOf(tempHistoryAgentChange[0].Phone__c),tempHistoryAgentChange[0].Id, busFiObj.Id,accObj.Name);
                                BRS_SendNotificationtoAgent.sendEmail(agentObj,busFiObj,tempHistoryAgentChange[0],true);
                            }
                            else{
                                BRS_SendNotificationtoAgent.callSendMessage(null,String.valueOf(agentObj.Agent_Phone__c),agentObj.Id, busFiObj.Id,accObj.Name);
                                BRS_SendNotificationtoAgent.sendEmail(agentObj,busFiObj,null,true);
                            }
                        }
                    }*/
                //    else{
                        
						if(busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label){
							accObj.Status__c = System.label.Pending;
							if(accObj!=null){
								update accObj;
							}
						}
                        if((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==system.Label.First_Report || busFiObj.Type__c==system.Label.Label_Change_Agent)&& !tempHistoryAgentChange.isEmpty()){
                            busFiObj.Agent_Email_Address__c = tempHistoryAgentChange[0].Email__c;
                            busFiObj.Agent_Name__c = tempHistoryAgentChange[0].name__c;
							busFiObj.Status__c = System.Label.Submitted_Agent_acceptance_pending;
                            busFiObj.Agent_Confirmation_Notification__c = System.now();
                            busFiObj.Agent_Confirmation_Hours_Left__c = 72;
                            busFiObj.Agent_Id__c =  tempHistoryAgentChange[0].Id;
                            busFiObj.Agent_Phone_Number_Formatted__c =  tempHistoryAgentChange[0].Phone__c;
							update busFiObj;
                            BRS_SendNotificationtoAgent.callSendMessage(null,String.valueOf(tempHistoryAgentChange[0].Phone__c),tempHistoryAgentChange[0].Id, busFiObj.Id,accObj.Name);
                            BRS_SendNotificationtoAgent.sendEmail(agentObj,busFiObj,tempHistoryAgentChange[0],false);
                        }
                        else{
                            busFiObj.Agent_Email_Address__c = agentObj.Email__c;
                            busFiObj.Agent_Name__c = agentObj.Name__c;
                            busFiObj.Status__c = System.Label.Submitted_Agent_acceptance_pending;
                            busFiObj.Agent_Confirmation_Notification__c = System.now();
                            busFiObj.Agent_Confirmation_Hours_Left__c = 72;
                            busFiObj.Agent_Id__c =  agentObj.Id;
                            busFiObj.Agent_Phone_Number_Formatted__c = agentObj.Agent_Phone__c;
                            update busFiObj;
                            BRS_SendNotificationtoAgent.callSendMessage(null,String.valueOf(agentObj.Agent_Phone__c),agentObj.Id, busFiObj.Id,accObj.Name);
                            BRS_SendNotificationtoAgent.sendEmail(agentObj,busFiObj,null,false);
                        }
                        
                //    }
                }
                else{
                    if((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==system.Label.First_Report || busFiObj.Type__c==system.Label.Label_Change_Agent)&& !tempHistoryAgentChange.isEmpty()){
                        busFiObj.Agent_Email_Address__c = tempHistoryAgentChange[0].Email__c;
                        busFiObj.Agent_Name__c = tempHistoryAgentChange[0].name__c;
                        busFiObj.Agent_Phone_Number_Formatted__c =  tempHistoryAgentChange[0].Phone__c;
                    }
                    if((isDomesticLLC && agentSelfAcceptance && containsKeyword) || (updateStatustoAgencyReview && !agentSelfAcceptance) || (agentSelfAcceptance && isNameHasDBA)){
                        busFiObj.Status__c = System.label.Submitted_Agency_review_pending;
                        update busFiObj;
                        if(busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label){
                            accObj.Status__c = System.label.Pending;
                            if(accObj!=null){
                                update accObj;
                                
                            }
                        } 
                    }
                    else{
                        busFiObj.Status__c = System.label.Approved;
                        if(busFiObj.Type__c == System.Label.Annual_Report || busFiObj.Type__c == System.Label.First_Report) {
                            busFiObj.isAutoApproved__c = true;
                        }
                        if(busFiObj!=null){
                            update busFiObj;
                            if(busFiObj.Type__c == System.Label.Annual_Report || busFiObj.Type__c == System.Label.First_Report){
                                brs_ActionItemUtility.completeActionItem(new List<Business_Filing__c>{busFiObj});
                            }
                        }
                        if(busFiObj.Type__c == System.label.Business_Formation_Label || busFiObj.Type__c ==System.label.Business_Registration_Label){
                            accObj.Status__c = System.label.Active;
                            if(accObj!=null){
                                update accObj;
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            BOS_Utility.ExceptionHandler(BRS_SendNotificationtoAgentLabel, sendMessageLabel,null,null,null,ex,ex.getMessage());
        }
    } 
    
    @future(callout=true)
    public static void callSendMessage(String accSID, String phNo, String agentId,String filingId,String accName){
       try{
            String encryptedAgentId = BRS_SendNotificationtoAgent.encrypt(agentId);
            String encryptedFilingId = BRS_SendNotificationtoAgent.encrypt(filingId);
            String encrytAccepted = BRS_SendNotificationtoAgent.encrypt(System.Label.Accepted);
            String encrytDeclined = BRS_SendNotificationtoAgent.encrypt(System.Label.Declined);
            String pageURL = System.label.Current_Env_Community_URL+'?AgentId='+encryptedAgentId+'&FilingId='+encryptedFilingId;
            String acceptedURL = pageURL+'&Selection='+encrytAccepted;
            String declinedURL = pageURL+'&Selection='+encrytDeclined;
        
            
            String SMSMessageBody = accName +' '+ System.Label.Accept_Appointment+' ' +acceptedURL+'\n'+'\n' +System.Label.Decline_appointment+' ' +declinedURL;
            String phoneNumber = system.label.US_Region_code+ phNo;
            Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
            String account_SID = accountInfo.API_Key__c;
            BOSTwilioSMSService.WrapperResult resultWrap = BOSTwilioSMSService.sendSMS(account_SID,phoneNumber, SMSMessageBody);
       }
       catch(Exception ex){
           BOS_Utility.ExceptionHandler(BRS_SendNotificationtoAgentLabel, sendMessageLabel,null,null,null,ex,ex.getMessage());
       }
        
    }

    public static void sendEmail(Agent__c agentRec, Business_filing__c filingRec,Temp_History__c tempHistoryObj,Boolean sendReminder){
        try{
            OrgWideEmailAddress owa = BRS_Utility.getOrgWideEmailAddr(System.Label.BRS_sotsOrgWideEmailAddr);
            String templateName;
            if(sendReminder){
                templateName='BRS_Agent_Appointment_Reminder';
            }else{
                templateName='BRS_Agent_Appointment_Confirmation';
            }
            
            EmailTemplate emailTemplateRec =  [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName=:templateName];

            Messaging.SingleEmailMessage email =  Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, filingRec.Id);
            String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
            String htmlBody = email.getHtmlBody();
            if(tempHistoryObj!=null && tempHistoryObj.Email__c!=null){
                    string[] to = new string[] {tempHistoryObj.Email__c};
                        email.setToAddresses(to);
                }
                else{
                    if(agentRec.Email__c!=null){
                        string[] to = new string[] {agentRec.Email__c};
                            email.setToAddresses(to);
                    }
                }
            
            if(owa!=null){
                email.setOrgWideEmailAddressId(owa.Id);
            }
            email.setTemplateId(emailTemplateRec.Id);
            
            String encryptedAgentId;
            if(tempHistoryObj==null){
                encryptedAgentId = BRS_SendNotificationtoAgent.encrypt(agentRec.id);
            }else{
                encryptedAgentId = BRS_SendNotificationtoAgent.encrypt(tempHistoryObj.id);
            }
            
            String encryptedFilingId = BRS_SendNotificationtoAgent.encrypt(filingRec.id);
            String encrytAccepted = BRS_SendNotificationtoAgent.encrypt(System.Label.Accepted);
            String encrytDeclined = BRS_SendNotificationtoAgent.encrypt(System.Label.Declined);
            String pageURL = System.label.Current_Env_Community_URL+'?AgentId='+encryptedAgentId+'&FilingId='+encryptedFilingId;
            String acceptedURL = pageURL+'&Selection='+encrytAccepted;
            String declinedURL = pageURL+'&Selection='+encrytDeclined;
            htmlBody = htmlBody.replace(System.Label.Accept,System.Label.URL_Prefix+acceptedURL+System.Label.Accept_Suffix);
            htmlBody = htmlBody.replace(System.Label.Decline,System.Label.URL_Prefix+declinedURL+System.Label.Decline_Suffix);
            email.setHtmlBody(htmlBody);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.setWhatId(filingRec.id);
            email.setSaveAsActivity(false);
            if(filingRec.Agent_Email_Address__c!=null && email.getToAddresses().size()>0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
        catch(Exception ex){
           BOS_Utility.ExceptionHandler(BRS_SendNotificationtoAgentLabel, sendMessageLabel,null,null,null,ex,ex.getMessage());
        }
        
    }

    @AuraEnabled
    public static String encrypt(String toEncrypt){
        BRS_Encryption_Key_Setting__c setting = BRS_Encryption_Key_Setting__c.getInstance();
        Blob cryptoKey = EncodingUtil.base64Decode(setting.Crypto_Key__c);
        
        Blob data = Blob.valueOf(toEncrypt);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        String encryptedDataStr = EncodingUtil.base64Encode(encryptedData);
        
        return encryptedDataStr;
    }

    @AuraEnabled
    public static String decrypt(String toDecrypt){
        Blob encryptedData = EncodingUtil.base64Decode(toDecrypt);
        BRS_Encryption_Key_Setting__c setting = BRS_Encryption_Key_Setting__c.getInstance();
        Blob cryptoKey = EncodingUtil.base64Decode(setting.Crypto_Key__c);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
        return decryptedData.toString();
    }
 
    @AuraEnabled
    public static AgentDetaisWrapper getAgentDetails(String enAgentId,String enAgentSelection,String enFilingId){
        try {
			enAgentId = enAgentId.replaceAll(' ','+'); 
			enAgentSelection = enAgentSelection.replaceAll(' ','+');
            String agentId = BRS_SendNotificationtoAgent.decrypt(enAgentId);
            String selection = BRS_SendNotificationtoAgent.decrypt(enAgentSelection);
			enFilingId = enFilingId.replaceAll(' ','+'); 
			String filingId = BRS_SendNotificationtoAgent.decrypt(enFilingId);
			String filingUpdated;
            Boolean isLinkValid = true;
			Business_filing__c filingRec= [Select Id,Agent_Selection__c,Agent_Confirmation_Hours_Left__c, Status__c from Business_filing__c where Id=:filingId];
			if(filingRec!=null){
                if(filingRec.Agent_Selection__c!=null){
                    filingUpdated =  filingRec.Agent_Selection__c;
                } 
                if(filingRec.Agent_Confirmation_Hours_Left__c!=null && filingRec.Agent_Confirmation_Hours_Left__c<=0 && filingRec.Status__c != System.Label.Submitted_Agent_acceptance_pending){ 
                    isLinkValid = false;
                }
			}
            AgentDetaisWrapper agentDetails = new AgentDetaisWrapper();
            Id decryptedId = (Id)agentId;
            String sObjName = decryptedId.getSObjectType().getDescribe().getName();
            if(sObjName==System.Label.Agent_API_Name){
                Agent__c agentObj= [Select id, Type__c,Name__c,Email__c,Agent_Phone__c, User_Contact_ID__c ,Business_ID__c,Business_ID__r.Name from Agent__c where Id=:agentId];
                agentDetails.agentRec = agentObj;
                agentDetails.isTempRec=false;
            }else{
                Temp_History__c tempHistory = [select Id,Business_ID__c,createddate,Type__c,Email__c,Phone__c,name__c,Business_ID__r.Name,Temp_Type__c from Temp_History__c where Id=:agentId];
                agentDetails.tempRec = tempHistory;
                agentDetails.isTempRec=true;
            }
            
            agentDetails.agentSelection = selection;
            agentDetails.filingUpdated = filingUpdated;
            agentDetails.isLinkValid = isLinkValid;
            return agentDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @update : BRS-4262 | Shreya 
     *  When agent rejects, and auto rejection - create rejection notice
     * @update : BRS-4647 | Run in anonymous user context
     */
    @AuraEnabled
    public static Boolean updateFiling(String selection,String enFilingId,String electronicSignature,String title){
        Boolean isAutoRejected = false;
        enFilingId = enFilingId.replaceAll(' ','+'); 
        String filingId = BRS_SendNotificationtoAgent.decrypt(enFilingId);
        
        Business_filing__c filingRec = [
            SELECT Id, Status__c,Agent_Selection__c,Type__c,Name_Electronic_signature__c,Agent_Title__c,Account__c,
                Account__r.Citizenship__c,Account__r.Business_Type__c,Effective_Date__c
            FROM Business_filing__c 
            WHERE Id=:filingId
        ];
        
        if(selection!=null && selection == System.label.I_Accept){
            if(filingRec.Type__c == 'Change of Agent' && filingRec.Account__r.Business_Type__c == 'LLC' && filingRec.Effective_Date__c > System.Today())
            {
                if(filingRec.Status__c != 'Pending Filing')
                {
                    filingRec.Status__c='Pending Filing';
                }   
            }
            else
            {
                filingRec.Status__c=System.Label.Submitted_Agency_review_pending;
            }
            filingRec.Agent_Selection__c = System.Label.accepted;
            filingRec.Agent_Title__c = title;
            filingRec.Name_Electronic_signature__c = electronicSignature;
        }else if(selection == System.Label.I_Decline) {
            if(filingRec.Type__c == System.label.Label_Change_Agent || filingRec.Type__c==System.label.Annual_Report || filingRec.Type__c==System.label.First_Report || (filingRec.Account__r.Citizenship__c == system.Label.Domestic_Label_Comparable && filingRec.Account__r.Business_Type__c==system.Label.LLC)){
                isAutoRejected = true;

                filingRec.Status__c=System.Label.Rejected; //BRS-4262 | Generate Nintex doc
                filingRec.Reason_for_Rejection__c = System.Label.RejectionReasonAgent;
                filingRec.Agent_Selection__c = System.Label.Declined;
                filingRec.Agent_Title__c = title;
                filingRec.Name_Electronic_signature__c = electronicSignature;
            } else if(filingRec.Account__r.Citizenship__c == System.Label.Foreign_Label_Comparable || ((filingRec.Account__r.Business_Type__c==System.label.LLP || filingRec.Account__r.Business_Type__c==System.label.Limited_Partnership_Comparable || filingRec.Account__r.Business_Type__c==System.label.Non_Stock || filingRec.Account__r.Business_Type__c==System.label.Stock|| filingRec.Account__r.Business_Type__c==System.label.B_Corp) && filingRec.Account__r.Citizenship__c ==system.Label.Domestic_Label_Comparable) ){
                filingRec.Agent_Selection__c = System.Label.Declined;
                filingRec.Status__c=System.Label.Submitted_Agency_review_pending;
                filingRec.Agent_Title__c = title;
                filingRec.Name_Electronic_signature__c = electronicSignature;
            }
        }

        //added empty check as part of code review activity
        if(filingRec!=null){
            update filingRec;
        }

        //BRS-4262 | BRS-4647 | Create rejection notice to be emailed
        if(isAutoRejected) {
            if(System.Label.brs_CertficateTypeStandard.equalsIgnoreCase(UserInfo.getUserType()) &&  !test.isRunningTest()) {  //comm user
                Database.executeBatch(new NintexBatchGeneration(new List<Id> { filingRec.Id }, UCCFilingAcknowledgement.Operation.REJECTION));
            } else { //guest user
                AutoRejectOnAgentDecline__e agentDecline = new AutoRejectOnAgentDecline__e(
                    FilingId__c = filingRec.Id
                );
                 if( !test.isRunningTest()){
                // Call method to publish events
                Database.SaveResult sr = EventBus.publish(agentDecline);
                }
            }
        }

        return true;
    }

    /**********************************************************************************************
    METHOD NAME    : resendNotificationToAgent
    DESCRIPTION    : Method to resend notification to agent
    PARAMETER      : recId
    Author         : Priyanka Sharma
    ***********************************************************************************************/
    @AuraEnabled
    public static void resendNotificationToAgent(Id recId){
        try{
            if(recId!=null){
                Agent__c agentObj = new Agent__c();
                Temp_History__c tempAgentObj = new Temp_History__c();
                Boolean isTemp = false;
                Business_Filing__c busFiObj = [Select id,type__c,Agent_Phone_Number_Formatted__c,Account__r.name,Agent_Id__c,Agent_Email_Address__c from business_filing__c where id =:recId Limit 1];
                
                if((busFiObj.Type__c == system.Label.Annual_Report || busFiObj.Type__c ==System.label.First_Report || busFiObj.Type__c==System.label.Label_Change_Agent))
                {
                    tempAgentObj = [select Id,Business_ID__c,createddate,Type__c,Email__c,Phone__c,name__c from Temp_History__c where Business_Id__c=:busFiObj.Account__c and Business_Filing__c =:busFiObj.Id and Type__c=: System.Label.Agent and Change_Type__c= :System.Label.Created order by createddate limit 1];
                    isTemp = true;
                }
                if(busFiObj!=null && !isTemp){
                    agentObj = [Select id, Agent_Phone__c,Email__c from agent__c where id=:busFiObj.Agent_Id__c Limit 1];
                }
                if(busFiObj!=null && (agentObj!=null || tempAgentObj!=null)){
                    String agentPhone = agentObj!=null ? String.valueOf(agentObj.Agent_Phone__c) : String.valueOf(tempAgentObj.Phone__c);
                    Id agentId = agentObj!=null ? agentObj.Id : tempAgentObj.Id;

                    BRS_SendNotificationtoAgent.callSendMessage(null,agentPhone,agentId, busFiObj.Id,busFiObj.Account__r.Name);
                    BRS_SendNotificationtoAgent.sendEmail(agentObj,busFiObj,isTemp?tempAgentObj:null,false);
                }                
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}