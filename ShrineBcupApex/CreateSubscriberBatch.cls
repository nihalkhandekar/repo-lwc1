/*********************************************************************************************
 * NAME:  CreateSubscriberBatch
 * DESCRIPTION: This class create subscriber records based on Business Reopen Certification record
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Faisal Mohammad                   07/01/2020                         Created the first version
 *
*************************************************************************************************/

global with sharing class CreateSubscriberBatch implements Database.Batchable<sObject>, Database.Stateful{

    //few constants to replace Restaurants (Outdoor Only), Museums and Zoos (Outdoor Only)
    global static final String PREV_REST = 'Restaurants (Outdoor Only)';
    global static final String PREV_MUES = 'Museums and Zoos (Outdoor Only)';
    global static final String CURR_REST = 'Restaurants';
    global static final String CURR_MUES = 'Museums, Zoos and Aquariums';


    //Tracking values
    global Integer brcTotalEmail;
    global Integer brcTotalPhone;
    global Integer brcTotalUpdate;
    global Integer totalSuccessfulRecords;
    global Integer totalFailedRecords;
    global Set<String> uniqueEmails;
    global Set<String> uniquePhones;
    global String failedValues;
    //get t
    global static final Datetime SIGNUP_DATE_VAL = Datetime.newInstance(2020, 7, 1, 10, 59, 59);
    //Retrieve record type
    global static final Id REC_TYPE_ID = NotificationServiceCls.getRecordTypeId('Recovery','Subscription__c');
    global Boolean useDate;
    // Batch Constructor
    global CreateSubscriberBatch(Boolean pUseDate){
        useDate = pUseDate;
        brcTotalEmail = 0;
        brcTotalPhone = 0;
        brcTotalUpdate = 0;
        totalSuccessfulRecords = 0;
        totalFailedRecords = 0;
        uniqueEmails = new Set<String>();
        uniquePhones = new Set<String>();
        failedValues = '';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Invalid_Email__c, Notification_Subscribed__c, Language__c, Email_Address__c, Contact_Phone_Number_1__c, Sector__c, Business_Type__c '
                        +' FROM Business_Reopen_Certification__c';
        if(useDate){
            query += ' where createdDate <' + SIGNUP_DATE_VAL.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        query += ' Order by Email_Address__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Business_Reopen_Certification__c> brcList) {
        //first define Sets and Maps with email and Phones
        //these phones and emails will be used to create subscriber record
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Map<String, Subscription__c> emailToSubs = new Map<String, Subscription__c>();
        Map<String, Subscription__c> phoneToSubs = new Map<String, Subscription__c>();

        //Map for emails and phones to Subscription__c for current batch
        Map<String, Subscription__c> currBtchEmailMap = new Map<String, Subscription__c>();
        Map<String, Subscription__c> currBtchPhoneMap = new Map<String, Subscription__c>();
        
        //Populate the email and phone sets
        for(Business_Reopen_Certification__c brc : brcList){       
            if(brc.Email_Address__c !=null && (!brc.Invalid_Email__c)){
                emailSet.add(brc.Email_Address__c);
                uniqueEmails.add(brc.Email_Address__c);
            }
            if(brc.Contact_Phone_Number_1__c != null){
                phoneSet.add(brc.Contact_Phone_Number_1__c);
                uniquePhones.add(brc.Contact_Phone_Number_1__c);
            }
        }

        //query Subscriber to find existing record, if exists to update
        List<Subscription__c> subsList = 
            [select Id, Email__c, Phone__c, Language__c, Email_Verified__c, Business_Sector__c, Business_Industry__c
            from Subscription__c
            where Email__c in :emailSet or Phone__c in :phoneSet];
        
        //populate email and phone map
        if(subsList !=null && subsList.size()>0){
            for(Subscription__c sbs: subsList){
                if(sbs.Email__c != null && sbs.Email__c !=''){
                    emailToSubs.put(sbs.Email__c, sbs);
                }
                if(sbs.Phone__c != null && sbs.Phone__c !=''){
                    phoneToSubs.put(sbs.Phone__c, sbs);
                }
            }
        }

        //prepare data to be created or updated
        List<Subscription__c> subsToInsert = new List<Subscription__c>();
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        Map<ID,Business_Reopen_Certification__c> brcMapUpdate = new Map<ID,Business_Reopen_Certification__c>();
        List<Business_Reopen_Certification__c> brcUpdate = new List<Business_Reopen_Certification__c>();

        //logic to combine business sector and industry
        for(Business_Reopen_Certification__c brc : brcList){
            String email = brc.Email_Address__c;
            String phone = brc.Contact_Phone_Number_1__c;
            String sectorVal = replaceOldSectorWithNew(brc.Sector__c);
            String indstrVal = brc.Business_Type__c;
            String brcLanguage = brc.Language__c;
            
            if((email != null) && (email != '') && (!brc.Invalid_Email__c)){
                Subscription__c emlSubs= returnSubscriptionFrom(email, currBtchEmailMap, emailToSubs);
                emlSubs.Email__c = email;
                emlSubs.Email_Verified__c = true;
                emlSubs.Language__c = brcLanguage;
                emlSubs.Business_Sector__c = addNonExistingStringVal(emlSubs.Business_Sector__c, sectorVal);
                emlSubs.Business_Industry__c = addNonExistingStringVal(emlSubs.Business_Industry__c, indstrVal);
                currBtchEmailMap.put(email, emlSubs);               
                brc.Notification_Subscribed__c = true;
                if(brcMapUpdate.get(brc.Id)==null){
                    brcMapUpdate.put(brc.Id,brc);
                }
                brcTotalEmail = brcTotalEmail + 1;
            }//end of if
            if(phone !=null && phone != ''){
                Subscription__c phnSubs= returnSubscriptionFrom(phone, currBtchPhoneMap, phoneToSubs);
                phnSubs.Phone__c = phone;
                phnSubs.Language__c = brcLanguage;
                phnSubs.Business_Sector__c = addNonExistingStringVal(phnSubs.Business_Sector__c, sectorVal);
                phnSubs.Business_Industry__c = addNonExistingStringVal(phnSubs.Business_Industry__c, indstrVal);
                currBtchPhoneMap.put(phone, phnSubs);
                brc.Notification_Subscribed__c = true;
                if(brcMapUpdate.get(brc.Id)==null){
                    brcMapUpdate.put(brc.Id,brc);
                }
                brcTotalPhone = brcTotalPhone + 1;
            }
        }//end of brcList for loop
        //Retrieve record type
        Id recTypeId = NotificationServiceCls.getRecordTypeId('Recovery','Subscription__c');
        //go through phone and email maps to determine which one to be created and which one to be updated
        for(String email : currBtchEmailMap.keySet()){
            Subscription__c sbs = currBtchEmailMap.get(email);
            if(sbs.Id == null){
                sbs = setSubscription(sbs, recTypeId, 'Email');
                subsToInsert.add(sbs);
            }else{
                subsToUpdate.add(sbs);
            }
        }//end of currBtchEmailMap for loop
        
        for(String phone : currBtchPhoneMap.keySet()){
            Subscription__c sbs = currBtchPhoneMap.get(phone);
            if(sbs.Id == null){
                sbs = setSubscription(sbs, recTypeId, 'SMS');
                subsToInsert.add(sbs);
            }else{
                subsToUpdate.add(sbs);
            }
        }//end of currBtchPhoneMap for loop    
        
        for(ID keyVal : brcMapUpdate.keySet()){
            Business_Reopen_Certification__c brc = brcMapUpdate.get(keyVal);
            if( brc.Id != null){
                brcUpdate.add(brc); 
                brcTotalUpdate = brcTotalUpdate + 1;
            }
        }//end of currBtchPhoneMap for loop 
        
        try {
            if((!subsToInsert.isEmpty()) && (useDate)){
                Database.SaveResult[] instRslt = Database.insert(subsToInsert, false);
                for (Database.SaveResult sResult: instRslt){
                    if(sResult.isSuccess()){
                        totalSuccessfulRecords = totalSuccessfulRecords +1;
                    }else{
                        totalFailedRecords = totalFailedRecords + 1;
                        failedValues += '\r\n';
                        for(Database.Error err : sResult.getErrors()) {
                            failedValues +='The following error has occurred.'
                            +err.getStatusCode() + ': ' + err.getMessage()+
                            'fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
            
            if(!subsToUpdate.isEmpty()){
                Database.SaveResult[] updRslt = Database.update(subsToUpdate, false);
                for (Database.SaveResult sResult: updRslt){
                    if(sResult.isSuccess()){
                        totalSuccessfulRecords = totalSuccessfulRecords +1;
                    }else{
                        totalFailedRecords = totalFailedRecords + 1;
                        failedValues += '\r\n';
                        for(Database.Error err : sResult.getErrors()) {
                            failedValues +='The following error has occurred.'
                            +err.getStatusCode() + ': ' + err.getMessage()+
                            'fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
            if(!brcUpdate.isEmpty()){
                Database.SaveResult[] updRslt = Database.update(brcUpdate, false);
                for (Database.SaveResult sResult: updRslt){
                    if(sResult.isSuccess()){
                        totalSuccessfulRecords = totalSuccessfulRecords +1;
                    }else{
                        totalFailedRecords = totalFailedRecords + 1;
                        failedValues += '\r\n';
                        for(Database.Error err : sResult.getErrors()) {
                            failedValues +='The following error has occurred.'
                            +err.getStatusCode() + ': ' + err.getMessage()+
                            'fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
        } catch(Exception e) {
            
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // Set recipients to two contact IDs.
        // Replace IDs with valid record IDs in your org.
       // message.toAddresses = new String[] { 'apshahapurkar@deloitte.com'};
        message.toAddresses = new String[] { 'apshahapurkar@deloitte.com','mifarrand@deloitte.com','demurdiya@deloitte.com'};
        //message.optOutPolicy = 'FILTER';
        message.subject = 'Subscriber Batch Process is Complete';// Put the Subject that you want
        String textBody = 'The statistics ';
            textBody += '\r\ntotal email for brc email '+brcTotalEmail;
            textBody += '\r\ntotal phone for brc phone '+brcTotalPhone;
            textBody += '\r\ntotal BRC '+brcTotalUpdate;
            textBody += '\r\nUnique Email '+uniqueEmails.size();
            textBody += '\r\nUnique Phone '+uniquePhones.size();
            textBody += '\r\ntotal successful subscriber '+totalSuccessfulRecords;
            textBody += '\r\ntotal failed subscriber '+totalFailedRecords;
            textBody += '\r\nFailed errors  '+failedValues;
            
        message.plainTextBody = textBody;
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    public static String replaceOldSectorWithNew(String sectorVal){
        String retSectorVal = (sectorVal.equalsIgnoreCase(PREV_REST)?CURR_REST:(sectorVal.equalsIgnoreCase(PREV_MUES)?CURR_MUES:sectorVal));
        return retSectorVal;
    }

    public static Subscription__c returnSubscriptionFrom(String keyVal, 
                Map<String, Subscription__c> newMap, 
                Map<String, Subscription__c> existingMap){
        
        Subscription__c retSbs = newMap.get(keyVal);
        if(retSbs==null){
            retSbs = existingMap.get(keyVal);
        }
        if(retSbs==null){
            retSbs = new Subscription__c();
        }
        return retSbs;
    }

    public static String addNonExistingStringVal(String currVal, String addValue){
        String retVal = currVal;
        if(retVal==null || retVal==''){
            retVal = addValue;
        }else if(addValue !=null && !retVal.contains(addValue)){
            retVal = retVal + ';'+ addValue;
        }
        return retVal;
    }

    /********************************************************************************************
        METHOD NAME    : setSubscription
        DESCRIPTION    : Create record list for email/SMS Subscription.
        RETURN TYPE    : Subscription__c
        PARAMETER      : Subscription__c subscriptionObj, Id recType, String channelType
    ********************************************************************************************/
    public static Subscription__c setSubscription(Subscription__c subscriptionObj, Id recType, String channelType){
        subscriptionObj.recordTypeId = recType;
        subscriptionObj.Signup_Date__c = system.today();
        subscriptionObj.Subscription_Status__c = 'Active';
        subscriptionObj.Subscription_Type__c = 'Criteria';
        subscriptionObj.Attestation_Acknowledgement__c = true;
        subscriptionObj.Communication_Channel__c = channelType;
        return subscriptionObj;
    }
}