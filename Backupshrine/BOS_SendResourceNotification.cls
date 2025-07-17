global with sharing class BOS_SendResourceNotification implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String query;
    global String account_SID;
    global date dateValue;
    global List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
    global Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
    
    public BOS_SendResourceNotification(String accountSID){
        account_SID = accountSID;
        query = null;
        Integer days = Integer.ValueOf(Label.rcNotificationDay);
        if(Test.isRunningTest()){
            days = 0;
        }
        dateValue = System.today().addDays(days); 
        List<Knowledge__kav> newkav = [Select ID,CreatedDate,TranslationCompletedDate, MasterVersion.CreatedDate, ArticleCreatedDate, FirstPublishedDate,LastPublishedDate,VersionNumber,Language  from Knowledge__kav where Day_Only(FirstPublishedDate) =: dateValue and IsLatestVersion = true and PublishStatus ='Online' and RecordTypeID =: BOSKnowledgeRecordTypeId  limit 1];
        
        if(newkav != Null && !newkav.isEmpty() && newkav.size()>0){
            query = 'Select ID, name,Email,Phone,Resource_Email_Notification__c,FirstName,Resource_SMS_Notification__c, (select Id, LanguageLocaleKey from Users) from contact where (Resource_Email_Notification__c = true or Resource_SMS_Notification__c = true)';
        }
        
        if(Schema.sObjectType.OrgWideEmailAddress.fields.DisplayName.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible()){
            owa = [select id, DisplayName, Address from OrgWideEmailAddress Where Address =: System.label.CT_BOS limit 1];
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query != Null){
            return Database.getQueryLocator(query);
        }
        else{
            return null;
        }
    }
    
    public void execute(Database.BatchableContext BC, List<contact> contactList) {
        try{
            Set<ID> ContactIDs = new Set<ID>();
            Map<ID,RecommendedCondition> contactWithRecommendedCondition = new Map<ID,RecommendedCondition>();
            Map<Id,String> contactLanguageMap = new Map<Id,String>();
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            Map<id,contact> contactMap = new Map<ID,Contact>();
            
            for(Contact con: contactList){
                ContactIDs.add(con.ID);
                contactMap.put(con.ID,con);
                RecommendedCondition rCond = new RecommendedCondition();            
                contactWithRecommendedCondition.put(con.ID,rCond);
                if(con.Users.size()>0){
                    contactLanguageMap.put(con.Id,con.Users[0].LanguageLocaleKey);
                }
            }
            
            //Map<ID,ID> contactQuestionnaire = new Map<ID,ID>();
            Set<ID> QuestionnaireIDs = new Set<ID>();
            RecommendedCondition tempRecCond = new RecommendedCondition();
            
            Map<ID,Contact> contactWithQuestionnaire = new Map<ID,Contact>([Select ID,(SELECT Id, Category__r.Code__c,Language__c FROM Applications__r where Status__c = 'Completed' ORDER BY LastModifiedDate DESC LIMIT 1),(SELECT Account.Name,Account.NAICS_Code__c FROM AccountContactRelations where Account.RecordType.Name = 'Business' ORDER BY SystemModStamp DESC LIMIT 1) from Contact where ID =: ContactIDs]);
            
            for(ID conID: contactWithQuestionnaire.keySet()){
                if(contactWithQuestionnaire.get(conID).Applications__r != Null && contactWithQuestionnaire.get(conID).Applications__r.size() > 0){
                    QuestionnaireIDs.add(contactWithQuestionnaire.get(conID).Applications__r[0].ID);
                }
            }
            
            Map<ID,Questionnaire__c> QuestionnaireWithResponse = new Map<ID,Questionnaire__c>([SELECT Id, Category__r.Code__c,(SELECT Given_Response_Value__c FROM QA_Question_Responses__r WHERE Question_Summary__c = 'Identified Groups' or Question_Summary__c = 'Grupos identificados') FROM Questionnaire__c WHERE Contact__c = :ContactIDs AND Status__c = 'Completed' AND ID =: QuestionnaireIDs]);
            
            
            for(ID conID: contactWithQuestionnaire.keySet()){
                if(contactWithQuestionnaire.get(conID).Applications__r != Null && contactWithQuestionnaire.get(conID).Applications__r.size() > 0){
                    //contactQuestionnaire.put(conID,contactWithQuestionnaire.get(conID).Applications__r[0].ID);
                    tempRecCond = new RecommendedCondition();
                    if(contactWithRecommendedCondition.get(conID) != Null){
                        tempRecCond = contactWithRecommendedCondition.get(conID);
                        tempRecCond.quesNaicsCode = contactWithQuestionnaire.get(conID).Applications__r[0].Category__r.Code__c.substring(0,2);
                        tempRecCond.quesLanguage = contactWithQuestionnaire.get(conID).Applications__r[0].Language__c;
                        contactWithRecommendedCondition.put(conID,tempRecCond);
                    }
                    if(contactWithRecommendedCondition.containskey(conID) != Null ){//&& QuestionnaireWithResponse.get(contactWithQuestionnaire.get(conID).Applications__r) != Null)){
                        tempRecCond = contactWithRecommendedCondition.get(conID);
                        tempRecCond.listIdentifiedGroups = !QuestionnaireWithResponse.get(contactWithQuestionnaire.get(conID).Applications__r[0].ID).QA_Question_Responses__r.isEmpty() ? QuestionnaireWithResponse.get(contactWithQuestionnaire.get(conID).Applications__r[0].ID).QA_Question_Responses__r.get(0).Given_Response_Value__c.split(System.Label.PIPELINE_SEPARATOR) : new List<String>();
                        contactWithRecommendedCondition.put(conID,tempRecCond);
                    }
                }
                if(contactWithQuestionnaire.get(conID).AccountContactRelations != Null && contactWithQuestionnaire.get(conID).AccountContactRelations.size() > 0){
                    tempRecCond = new RecommendedCondition();
                    if(contactWithRecommendedCondition.containskey(conID) != Null){
                        tempRecCond = contactWithRecommendedCondition.get(conID);
                        tempRecCond.businessNaicsCode = contactWithQuestionnaire.get(conID).AccountContactRelations[0].Account.NAICS_Code__c;
                        contactWithRecommendedCondition.put(conID,tempRecCond);
                    }
                }
            }
            
            Map<ID,Knowledge__kav> newkavMap = new Map<ID,Knowledge__kav>([Select ID,KnowledgeArticleId,Resource_Title_URL__c,Resource_Title_URL_shortened__c,title,Summary,CreatedDate,TranslationCompletedDate, MasterVersion.CreatedDate, ArticleCreatedDate, FirstPublishedDate,LastPublishedDate,VersionNumber,Language,NAICS_Code__c, Identified_Group__c  from Knowledge__kav where Day_Only(FirstPublishedDate) =: dateValue and IsLatestVersion = true and PublishStatus ='Online' and RecordTypeID =: BOSKnowledgeRecordTypeId]);    //and Day_Only(LastPublishedDate) =: dateValue
            Map<ID,Set<ID>> contactIDwithRecKAV = new Map<ID,Set<ID>>();
            Set<ID> recKAV = new Set<ID>();
            
            RecommendedCondition rCond = new RecommendedCondition();
            Map<String,String> identifiedGroupSpWithEng = new Map<String,String>();
            identifiedGroupSpWithEng.put('Propiedad de mujer','Woman Owned');
            identifiedGroupSpWithEng.put('Propiedad de minorías','Minority Owned');
            identifiedGroupSpWithEng.put('Propiedad de LGBTQI','LGBTQI Owned');
            identifiedGroupSpWithEng.put('Propiedad de veteranos','Veteran Owned');
            identifiedGroupSpWithEng.put('Propiedad de discapacidad','Disability Owned');
            
            for(ID conID: ContactIDs){
                recKAV = new Set<ID>();
                if(contactIDwithRecKAV.containsKey(conID)){
                    recKAV = contactIDwithRecKAV.get(conID);
                }
                rCond = new RecommendedCondition(); 
                rCond = contactWithRecommendedCondition.get(conID);
                //if Spanish Questionnaire
                List<String> listIdentifiedGroupsEng = new List<String>();
                if(rCond.quesLanguage == 'es'){
                    for(String s: rCond.listIdentifiedGroups){
                        listIdentifiedGroupsEng.add(identifiedGroupSpWithEng.get(s));
                    }
                }
                else{
                    listIdentifiedGroupsEng = rCond.listIdentifiedGroups;
                }
                for(Knowledge__kav kav: newkavMap.Values()){
                    if(kav.Language == contactLanguageMap.get(conID)){
                        //check business and checklist naics code
                        if(kav.NAICS_Code__c != Null && (rCond.businessNaicsCode != Null || rCond.quesNaicsCode != Null)){
                            List<String> kavNAICStemp = kav.NAICS_Code__c.split(',');
                            List<String> kavNAICS = new List<String>();
                            for(String s: kavNAICStemp){
                                kavNAICS.add(s.remove(' '));  
                            }
                            if(kavNAICS.contains(rCond.businessNaicsCode) ||  kavNAICS.contains(rCond.quesNaicsCode)){
                                recKAV.add(kav.ID);
                            }
                        }
                        //check identified group
                        if(kav.Identified_Group__c != Null && listIdentifiedGroupsEng != Null){
                            List<String> kavIdentifiedGptemp = kav.Identified_Group__c.split(';');
                            for(String s: kavIdentifiedGptemp){
                                if(listIdentifiedGroupsEng.contains(s)){ //rCond.listIdentifiedGroups.contains(s)
                                    recKAV.add(kav.ID);
                                    break;
                                } 
                            }
                        }
                        
                    }
                }
                contactIDwithRecKAV.put(conID,recKAV);
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            Integer CounterEmail = 0;
            Integer CounterSMS = 0;
            string[] to;
            for(ID conID: contactIDwithRecKAV.keySet()){
                CounterEmail = 0;
                CounterSMS = 0;
                if(contactMap.get(conID).Resource_Email_Notification__c == True && contactIDwithRecKAV.get(conID) != Null && contactIDwithRecKAV.get(conID).Size()>0){
                    for(ID kavID: contactIDwithRecKAV.get(conID)){
                        if(CounterEmail < 3){
                            email = new Messaging.SingleEmailMessage();
                            email.setOrgWideEmailAddressId(owa[0].id);
                            to = new string[] { contactMap.get(conID).Email};
                            email.setToAddresses(to);
                            email.setTargetObjectId(conId);
                            if(contactLanguageMap.get(conID) == 'es'){
                                email.setSubject('Alerta de nuevo recurso de Business.CT.gov');
                                email.setHtmlBody('<style>p{margin-top:0px; margin-bottom:0px;}</style><body class="setupTab"  style=" background-color:#FFFFFF; bEditID:b1st1; bLabel:body;"><center ><table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450" ><tr valign="top" ><td  style=" background-color:#09538B; bEditID:r1st1; bLabel:header; vertical-align:top; height:100px; text-align:left;"><img id="banner" src="'+label.rcNotificationImageURL+'" width="100%" height="90" alt=""/></img></td></tr><tr valign="top" ><td  style=" background-color:#FFFFFF; bEditID:r2st1; bLabel:accent1; height:0;"></td></tr><tr valign="top" ><td styleInsert="1" height="300"  style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;"><table border="0" cellpadding="5" width="550" cellspacing="5" height="400" ><tr valign="top" height="400" ><td tEditID="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" ><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Hola&nbsp;</span></font><font face="arial">'+contactMap.get(conID).FirstName+',</font><div><font face="arial"><br></font><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Acaba de hacerse disponible un nuevo recurso empresarial que pensamos que te interesaría. Compruébalo:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span></font></div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div><div style=""><font face="arial"><span style="font-size: 12pt;"><a href="'+newkavMap.get(kavID).Resource_Title_URL__c+'">'+newkavMap.get(kavID).Title+'</a></span></font><font face="arial"></font><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br>'+newkavMap.get(kavID).Summary+'</span><br><br><span style="font-size: 12pt;">Si deseas agregar este recurso a tu colección <span>Business.CT.gov<span></span>, <font face="arial"><span style="font-size: 12pt;"><a href="'+Label.ResourceCenterLoginPage+'">inicia sesión</a> y busca <b>'+ newkavMap.get(kavID).Title + '</b> en el Centro de Recursos.</span></font></div><div style=""><font face="arial"><br><span style="font-size: 12pt;">Gracias,</span></font><br><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br>Estado de Connecticut<br></span><font size="1" style="color: rgb(0, 0, 0); font-family: arial;"><br style="font-family: arial;"><font style="color: rgb(0, 0, 0); font-family: arial;">Por favor no respondas a este correo electrónico. Este buzón no está supervisado.</font></font></div></div></td></tr></table></td></tr></table></center>');
                            }
                            else{
                                email.setSubject('New resource alert from Business.CT.gov');
                                //email.setHtmlBody('<div ><font ><div >Hi '+contactMap.get(conID).FirstName+',</div><div><br></div><div>We just added a new business resource that we thought you\'d be interested in. Take a look:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</div><div ><br></div><div><span> </span> <a href="'+newkavMap.get(kavID).Resource_Title_URL__c+'">'+newkavMap.get(kavID).Title+'</a> </div><div><span> </span>'+newkavMap.get(kavID).Summary+'</div><div ><br></div><div ><span></span>To see all the latest updates for your business,<div ><br></div><a href="'+Label.AccountDashBoardPage+'">Sign in to your CT.gov account now</a> </div><div ><br></div><div >Thank you,</div><div ><br></div><div >State of Connecticut</div><div ><br></div><div ><font size="2">Please do not reply to this email. This mailbox is unmonitored.</font></div>');
                                email.setHtmlBody('<style>p{margin-top:0px; margin-bottom:0px;}</style><body class="setupTab"  style=" background-color:#FFFFFF; bEditID:b1st1; bLabel:body;"><center ><table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450" ><tr valign="top" ><td  style=" background-color:#09538B; bEditID:r1st1; bLabel:header; vertical-align:top; height:100px; text-align:left;"><img id="banner" src="'+label.rcNotificationImageURL+'" width="100%" height="90" alt=""/></img></td></tr><tr valign="top" ><td  style=" background-color:#FFFFFF; bEditID:r2st1; bLabel:accent1; height:0;"></td></tr><tr valign="top" ><td styleInsert="1" height="300"  style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;"><table border="0" cellpadding="5" width="550" cellspacing="5" height="400" ><tr valign="top" height="400" ><td tEditID="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" ><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Hi&nbsp;</span></font><font face="arial">'+contactMap.get(conID).FirstName+',</font><div><font face="arial"><br></font><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">We just added a new business resource that we thought you\'d be interested in. Check it out:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span></font></div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div><div style=""><font face="arial"><span style="font-size: 12pt;"><a href="'+newkavMap.get(kavID).Resource_Title_URL__c+'">'+newkavMap.get(kavID).Title+'</a></span></font><font face="arial"></font><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br>'+newkavMap.get(kavID).Summary+'</span><br><br><span style="font-size: 12pt;">If you’d like to add this resource to your <span>Business.CT.gov</span> collection, </span><font face="arial"><span style="font-size: 12pt;"><a href="'+Label.ResourceCenterLoginPage+'">sign in</a> and search for <b>' + newkavMap.get(kavID).Title + '</b> in the Resource Center.</span></font></div><div style=""><font face="arial"><br><span style="font-size: 12pt;">Thank you,</span></font><br><span style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br>State of Connecticut<br></span><font size="1" style="color: rgb(0, 0, 0); font-family: arial;"><br style="font-family: arial;"><font style="color: rgb(0, 0, 0); font-family: arial;">Please do not reply to this email. This mailbox is unmonitored.</font></font></div></div></td></tr></table></td></tr></table></center>');
                            }
                            if(contactMap.get(conID).Email != Null){
                                emailMessages.add(email);
                                CounterEmail = CounterEmail+1;
                            }
                        }
                    }
                }
                if(contactMap.get(conID).Resource_SMS_Notification__c == True && contactIDwithRecKAV.get(conID) != Null && contactIDwithRecKAV.get(conID).Size()>0){
                    for(ID kavID: contactIDwithRecKAV.get(conID)){
                        String ResourceURL = '';
                        if(newkavMap.get(kavID).Resource_Title_URL_shortened__c != Null){
                            ResourceURL = newkavMap.get(kavID).Resource_Title_URL_shortened__c;
                        }
                        else{
                            ResourceURL = newkavMap.get(kavID).Resource_Title_URL__c;
                        }
                        if(CounterSMS < 3){
                            String SMSMessageBody;
                            if(contactLanguageMap.get(conID) == 'es'){
                                SMSMessageBody = '[Business.CT.gov] Acabamos de agregar un nuevo recurso comercial que podría interesarte. Compruébalo: '+ResourceURL+'\nPara dejar de recibir mensajes de texto, actualiza tus preferencias en Business.CT.gov.'; //+newkavMap.get(kavID).Title+' '+ResourceURL+'\n\nPara dejar de recibir estos mensajes de texto, inicie sesión '+ Label.AccountDashBoardPage +' en tu cuenta de CT.gov y actualice tus preferencias de notificación.';
                            }
                            else{
                                SMSMessageBody = '[Business.CT.gov] We just added a new business resource you might be interested in. Check it out: '+ResourceURL+'\nTo stop receiving texts, update your preferences on Business.CT.gov.'; //+newkavMap.get(kavID).Title+' '+ResourceURL+'\n\nTo stop receiving these texts, log in '+ Label.AccountDashBoardPage +' to your CT.gov account and update your notification preferences. ';
                            }
                            if(SMSMessageBody!=null && contactMap.get(conID).Phone != Null){
                                BOSTwilioSMSService.sendSMS(account_SID, contactMap.get(conID).Phone, SMSMessageBody);
                                CounterSMS = CounterSMS+1;
                            }
                        }
                    }
                }
            }   
            if(!emailMessages.isEmpty()){
                Messaging.sendEmail(emailMessages);
            }
        }catch(Exception e){
            BOS_Utility.ExceptionHandlerAsync('BOS_SendResourceNotification','execute','Contact',null,'High',e,null);
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class RecommendedCondition {
        String businessNaicsCode;
        String quesNaicsCode;
        List<String> listIdentifiedGroups;
        String quesLanguage;
        public RecommendedCondition() {
            this.listIdentifiedGroups = new List<String>();
        }
    }
}