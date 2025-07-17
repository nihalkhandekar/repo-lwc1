public without sharing class brs_ActionItemUtility {
    public static void completeActionItem(List<Business_filing__c> bfilings){
        List<Action_Item__c> actionItemsToUpdate = [Select Id,Status__c,Business_Filing__c from Action_Item__c where Business_Filing__c IN:bfilings AND Status__c != 'Completed'];
        if(!actionItemsToUpdate.isEmpty()){
            for(Action_Item__c actItem:actionItemsToUpdate){
                actItem.Status__c = 'Completed';
            }
            update actionItemsToUpdate;
        }
    }
    public static void deleteAccountActionitems(Set<Id> accIds){
        List<Action_Item__c> actitems = [Select Id,Account__c from Action_Item__c where Account__c=:accIds];
        if(!actitems.isEmpty()){
            delete actitems;
        }
    }
    public static void createActionItem(List<Business_Filing__c> bfilings){
        List<Action_Item__c> actItemList = new List<Action_Item__c>();
        Map<Id,List<Business_Filing__c>> filingMap = new Map<Id,List<Business_Filing__c>>();
        for(Business_Filing__c bf:bfilings){
            if(filingMap.containsKey(bf.Account__c)){
                List<Business_Filing__c> bfList = filingMap.get(bf.Account__c);
                bfList.add(bf);
                filingMap.put(bf.Account__c, bfList);
            }else{
                filingMap.put(bf.Account__c, new List<Business_Filing__c>{bf});
            }
        }
        if(!filingMap.isEmpty()){
            List<AccountContactRelation> acrList = [Select Id,AccountId,ContactId from AccountContactRelation where AccountId IN: filingMap.keyset()];
            if(!acrList.isEmpty()){
                for(AccountContactRelation acr:acrList){
                    if(filingMap.containskey(acr.AccountId)){
                        for(Business_Filing__c bf:filingMap.get(acr.AccountId)){
                            actItemList.add(new Action_Item__c(Action_Item_Name__c = bf.Type__c,
                                                               Account__c = bf.Account__c,
                                                               Contact__c = acr.ContactId,
                                                               Business_Filing__c = bf.Id,
                                                               Status__c = 'Open',
                                                               Due_Date__c = bf.Due_Date__c));
                        } 
                    }
                }
            }
            if(!actItemList.isEmpty()){
                insert actItemList;
            }
        }
        
    }
    public static void createActionItemOnBusinessLinking(List<AccountContactRelation> acrList){
        Set<Id> accIds = new Set<Id>();
        Map<Id,List<Business_Filing__c>> accFilings = new Map<Id,List<Business_Filing__c>>();
        List<Action_Item__c> actItemList = new List<Action_Item__c>();
        for(AccountContactRelation acr:acrList){
            accIds.add(acr.AccountId);  
        }       
        for(Business_Filing__c bf:[Select Id,Type__c,Due_Date__c,Account__c from Business_Filing__c where Account__c IN:accIds AND (Type__c='Annual Report' OR Type__c='First Report') AND (Status__c ='Due' OR Status__c ='Past Due')]){			
            if(accFilings.containsKey(bf.Account__c)){
                List<Business_Filing__c> bfList = accFilings.get(bf.Account__c);
                bfList.add(bf);
                accFilings.put(bf.Account__c,bfList);
            }else{
                accFilings.put(bf.Account__c,new List<Business_Filing__c>{bf});
            }
        }
        if(!accFilings.isEmpty()){
            for(AccountContactRelation acr:acrList){
                if(accFilings.containskey(acr.AccountId)){
                    for(Business_Filing__c bf:accFilings.get(acr.AccountId)){
                        actItemList.add(new Action_Item__c(Action_Item_Name__c = bf.Type__c,
                                                           Account__c = bf.Account__c,
                                                           Contact__c = acr.ContactId,
                                                           Business_Filing__c = bf.Id,
                                                           Status__c = 'Open',
                                                           Due_Date__c = bf.Due_Date__c					
                                                          ));
                    }
                }
            }
            if(!actItemList.isEmpty()){
                System.debug('@@@@@@@'+actItemList);
                insert actItemList;
            }
        }        
    }
}