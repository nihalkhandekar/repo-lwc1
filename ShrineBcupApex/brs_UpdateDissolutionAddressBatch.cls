public class brs_UpdateDissolutionAddressBatch implements Database.Batchable<sObject>,Database.Stateful {
    public List<Id> listFilingIds=new List<Id>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select Id, Name,Account__c,Account__r.Name,Account__r.Status__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.ShippingStreet,Account__r.ShippingCity,Account__r.ShippingState,Account__r.ShippingPostalCode,Account__r.ShippingCountry,Account__r.Admin_Dissolution_Address__c,Account__r.Admin_Dissolution_City__c,Account__r.Admin_Dissolution_State__c,Account__r.Admin_Dissolution_Zip_Code__c,Account__r.Admin_Dissolution_Country__c From Business_Filing__c where Filing_Type__c=\'Certificate of Dissolution/Revocation\' and Filing_Date__c >= 2021-10-26 and Account__r.Status__c !=\'Active\' and Account__r.BillingStreet=\'No Information Provided\'';
        return Database.getQueryLocator(query);
    } 
    public void execute(Database.BatchableContext BC, List<sObject> lstScope) {
        List<Business_Filing__c> newTriggerList = (List<Business_Filing__c>) lstScope;
        List<Account> accToUpdate = new List<Account>();
        List<Id> AccountIdList=new List<Id>();
         //Process Filing Type
         Map<Id,Business_Filing__c> mapdata=new Map<Id,Business_Filing__c>(newTriggerList);
         //Delete Attachments File to Records
         List<Attachment> linkedAttachments = [SELECT Id,ParentId FROM Attachment WHERE ParentId in: mapdata.keySet()];
         System.debug('###2 Delete Batch Attachment'+linkedAttachments);
         if(!linkedAttachments.isEmpty()){
             delete linkedAttachments;
         }
         
         List<id> ContentDocumentListId=new List<id>();
         List<ContentDocumentLink> documentDetails=  [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.ContentSize , ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileExtension  FROM ContentDocumentLink where LinkedEntityId in:mapdata.keySet()];
         if(!documentDetails.isEmpty()){
             for(ContentDocumentLink documentLink:documentDetails)
             {
                 ContentDocumentListId.add(documentLink.ContentDocumentId);
             }
             List<ContentDocument> ContentDocumentListData=[SELECT Id FROM ContentDocument WHERE Id in:ContentDocumentListId];
             delete ContentDocumentListData;
         }
        listFilingIds.addAll(mapdata.keySet());
        
        
        for(Business_Filing__c bus:newTriggerList)
        {
	        AccountIdList.add(bus.Account__c);
        }
        
        Map<id,Agent__c> mapAccidAgents = new Map<id,Agent__c>();
        List<Agent__c> lstAgent = [Select id, Residence_Street_Address_1__c,Residence_Street_Address_2__c,Residence_Street_Address_3__c,Residence_City__c,Residence_State__c,Residence_Country__c,Residence_Zip_Code__c,Mailing_Street_Address_1__c,Mailing_Street_Address_2__c,Mailing_Street_Address_3__c,Mailing_City__c,Mailing_State__c,Mailing_Country__c,Mailing_Zip_Code__c,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_Street_Address_3__c,Business_City__c,Business_State__c,Business_Country__c,Business_Zip_Code__c , Business_ID__c from Agent__c where Business_ID__c IN:AccountIdList];
        if(lstAgent!=null && !lstAgent.isEmpty()){
            for(Agent__c agent : lstAgent){
                mapAccidAgents.put(agent.Business_ID__c,agent);
            }
        }
        
        for(Business_Filing__c bus:newTriggerList)
        {
            if(bus.Account__r.BillingStreet!=null && bus.Account__r.BillingCity!=null && bus.Account__r.BillingState!=null && bus.Account__r.BillingPostalCode!=null){
                bus.Account__r.Admin_Dissolution_Address__c = bus.Account__r.BillingStreet;
                bus.Account__r.Admin_Dissolution_City__c = bus.Account__r.BillingCity;
                bus.Account__r.Admin_Dissolution_State__c = bus.Account__r.BillingState;
                bus.Account__r.Admin_Dissolution_Zip_Code__c = bus.Account__r.BillingPostalCode;
                bus.Account__r.Admin_Dissolution_Country__c = bus.Account__r.BillingCountry;
                accToUpdate.add(bus.Account__r);
            }
            else if(bus.Account__r.ShippingStreet!=null && bus.Account__r.ShippingCity!=null && bus.Account__r.ShippingState!=null && bus.Account__r.ShippingPostalCode!=null){
                bus.Account__r.Admin_Dissolution_Address__c = bus.Account__r.ShippingStreet;
                bus.Account__r.Admin_Dissolution_City__c = bus.Account__r.ShippingCity;
                bus.Account__r.Admin_Dissolution_State__c = bus.Account__r.ShippingState;
                bus.Account__r.Admin_Dissolution_Zip_Code__c = bus.Account__r.ShippingPostalCode;
                bus.Account__r.Admin_Dissolution_Country__c = bus.Account__r.ShippingCountry;
                accToUpdate.add(bus.Account__r);
            }
            else if(mapAccidAgents!=null && !mapAccidAgents.isEmpty() && mapAccidAgents.get(bus.Account__c)!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Residence_City__c!=null && mapAccidAgents.get(bus.Account__c).Residence_State__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Zip_Code__c!=null){
                if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c + ' , '+ mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c!=null && mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_1__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Residence_Street_Address_3__c;
                }
                
                bus.Account__r.Admin_Dissolution_City__c = mapAccidAgents.get(bus.Account__c).Residence_City__c;
                bus.Account__r.Admin_Dissolution_State__c = mapAccidAgents.get(bus.Account__c).Residence_State__c;
                bus.Account__r.Admin_Dissolution_Zip_Code__c = mapAccidAgents.get(bus.Account__c).Residence_Zip_Code__c;
                bus.Account__r.Admin_Dissolution_Country__c = mapAccidAgents.get(bus.Account__c).Residence_Country__c;
                 accToUpdate.add(bus.Account__r);
            }
            else if(mapAccidAgents!=null && !mapAccidAgents.isEmpty() && mapAccidAgents.get(bus.Account__c)!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_City__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_State__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Zip_Code__c!=null){
                System.debug('Entered 222');
                if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c + ' , '+ mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c!=null && mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_1__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Mailing_Street_Address_3__c;
                }
                bus.Account__r.Admin_Dissolution_City__c = mapAccidAgents.get(bus.Account__c).Mailing_City__c;
                bus.Account__r.Admin_Dissolution_State__c = mapAccidAgents.get(bus.Account__c).Mailing_State__c;
                bus.Account__r.Admin_Dissolution_Zip_Code__c = mapAccidAgents.get(bus.Account__c).Mailing_Zip_Code__c;
                bus.Account__r.Admin_Dissolution_Country__c = mapAccidAgents.get(bus.Account__c).Mailing_Country__c;
                accToUpdate.add(bus.Account__r);
            }
            else if(mapAccidAgents!=null && !mapAccidAgents.isEmpty() &&  mapAccidAgents.get(bus.Account__c)!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Business_City__c!=null && mapAccidAgents.get(bus.Account__c).Business_State__c!=null && mapAccidAgents.get(bus.Account__c).Business_Zip_Code__c!=null){
                if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c + ' , '+ mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c!=null && mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c+ ' , '+ mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_1__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_2__c;
                }else if(mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c!=null){
                    bus.Account__r.Admin_Dissolution_Address__c = mapAccidAgents.get(bus.Account__c).Business_Street_Address_3__c;
                }
                bus.Account__r.Admin_Dissolution_City__c = mapAccidAgents.get(bus.Account__c).Business_City__c;
                bus.Account__r.Admin_Dissolution_State__c = mapAccidAgents.get(bus.Account__c).Business_State__c;
                bus.Account__r.Admin_Dissolution_Zip_Code__c = mapAccidAgents.get(bus.Account__c).Business_Zip_Code__c;
                bus.Account__r.Admin_Dissolution_Country__c = mapAccidAgents.get(bus.Account__c).Business_Country__c;
                accToUpdate.add(bus.Account__r);
            }
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
    }
    } 
    public void finish(Database.BatchableContext BC) {
        if(!listFilingIds.IsEmpty() && !test.isRunningTest()){
            Database.executeBatch(new NintexBatchGeneration(listFilingIds, UCCFilingAcknowledgement.Operation.ADMIN_DISSOLUTION), 10);
        }
    } 
}