public class DefendantsTriggerHandler{
    public static void beforeInsert(List<Defendants__c> triggerNew){
        try{
        Set<ID> AccountIDs = new Set<ID>();
        Set<ID> WritCaseIDs = new Set<ID>();
        Id approvedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Approved').getRecordTypeId();
        Id rejectedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Rejected').getRecordTypeId();
        Map<ID,Integer> WritCaseAppDefMap = new Map<ID,Integer>();
        Map<ID,Integer> WritCaseRejDefMap = new Map<ID,Integer>();
        Map<ID,WRIT_Case__c> WritCaseMap = new Map<ID,WRIT_Case__c>();
        Map<ID,Account> AccMap = new Map<ID,Account>();
        for(Defendants__c def: triggerNew){
            if(def.Account__c != Null){
                AccountIDs.add(def.Account__c);
            }
            if(def.WRIT_Case__c != Null){
                WritCaseIDs.add(def.WRIT_Case__c);
            }
        }
        if(!AccountIDs.isEmpty()){
            AccMap = new Map<ID,Account>([Select ID,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from Account where ID =: AccountIDs]);
        }
        if(!WritCaseIDs.isEmpty()){
            WritCaseMap = new Map<ID,WRIT_Case__c>([Select ID,Approved_Defendants__c,Rejected_Defendants__c from WRIT_Case__c where ID=:WritCaseIDs]);
        }
        for(Defendants__c def: triggerNew){
            if(def.Account__c != Null && AccMap.containsKey(def.Account__c) !=  Null){
                def.Address_Street_1__c = AccMap.get(def.Account__c).BillingStreet;
                def.City__c = AccMap.get(def.Account__c).BillingCity;
                def.State__c = AccMap.get(def.Account__c).BillingState;
                def.Zip_Code__c = AccMap.get(def.Account__c).BillingPostalCode;
                def.Country__c = AccMap.get(def.Account__c).BillingCountry;
            }
            if(def.RecordTypeID == approvedRecordTypeId){
                if(!WritCaseAppDefMap.containskey(def.WRIT_Case__c)){
                    WritCaseAppDefMap.put(def.WRIT_Case__c,Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Approved_Defendants__c));
                }
                if(WritCaseAppDefMap.containskey(def.WRIT_Case__c)){
                    def.Defendant_Number_Tag__c = 'A ' + String.valueOf(Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Approved_Defendants__c + 1)).leftPad(3, '0');
                    WritCaseAppDefMap.put(def.WRIT_Case__c,Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Approved_Defendants__c + 1));
                }
            }
            if(def.RecordTypeID == rejectedRecordTypeId){
                if(!WritCaseRejDefMap.containskey(def.WRIT_Case__c)){
                    WritCaseRejDefMap.put(def.WRIT_Case__c,Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Rejected_Defendants__c));
                }
                if(WritCaseRejDefMap.containskey(def.WRIT_Case__c)){
                    def.Defendant_Number_Tag__c = 'R ' + String.valueOf(Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Rejected_Defendants__c + 1)).leftPad(3, '0');
                    WritCaseRejDefMap.put(def.WRIT_Case__c,Integer.ValueOF(WritCaseMap.get(def.WRIT_Case__c).Rejected_Defendants__c + 1));
                }
            }
        }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('DefendantsTriggerHandler','beforeInsert', 'Defendants__c',null, 'High',ex,null);
        }
    }
    
    public static void beforeUpdate(List<Defendants__c> triggerNew, Map<ID,Defendants__c> triggerOldMap){
        try{
        Set<ID> AccountIDs = new Set<ID>();
        for(Defendants__c def: triggerNew){
            if(def.Account__c != Null && triggerOldMap.get(def.id).Account__c != def.Account__c){
                AccountIDs.add(def.Account__c);
            }
        }
        if(!AccountIDs.isEmpty()){
            Map<ID,Account> AccMap = new Map<ID,Account>([Select ID,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from Account where ID =: AccountIDs]);
            for(Defendants__c def: triggerNew){
                if(def.Account__c != Null && triggerOldMap.get(def.id).Account__c != def.Account__c && AccMap.get(def.Account__c) !=  Null){
                    def.Address_Street_1__c = AccMap.get(def.Account__c).BillingStreet;
                    def.City__c = AccMap.get(def.Account__c).BillingCity;
                    def.State__c = AccMap.get(def.Account__c).BillingState;
                    def.Zip_Code__c = AccMap.get(def.Account__c).BillingPostalCode;
                    def.Country__c = AccMap.get(def.Account__c).BillingCountry;
                }
            }
        }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('DefendantsTriggerHandler','beforeUpdate', 'Defendants__c',null, 'High',ex,null);
        }
    }
    public static void afterDelete(List<Defendants__c> triggerOld){
        try{
        Set<ID> WritCaseIDs = new Set<ID>();
        Map<ID,WRIT_Case__c> WritCaseMap = new Map<ID,WRIT_Case__c>();
        Id approvedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Approved').getRecordTypeId();
        Id rejectedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Rejected').getRecordTypeId();
        Set<ID> WCApprovedDefendantDeletedID = new Set<ID>();
        Set<ID> WCRejectedDefendantDeletedID = new Set<ID>();
        Map<ID,Integer> WritCaseAppDefMap = new Map<ID,Integer>();
        Map<ID,Integer> WritCaseRejDefMap = new Map<ID,Integer>();
        Set<ID> deletedDefendantID = new Set<ID>();
        for(Defendants__c def: triggerOld){
            if(def.WRIT_Case__c != Null){
                WritCaseIDs.add(def.WRIT_Case__c);
                if(def.RecordTypeID == approvedRecordTypeId){
                    WCApprovedDefendantDeletedID.add(def.WRIT_Case__c);
                }
                if(def.RecordTypeID == rejectedRecordTypeId ){
                    WCRejectedDefendantDeletedID.add(def.WRIT_Case__c);
                }
                deletedDefendantID.add(def.ID);
            }
        }
        if(!WritCaseIDs.isEmpty()){
            WritCaseMap = new Map<ID,WRIT_Case__c>([Select ID,Approved_Defendants__c,Rejected_Defendants__c,(Select ID,createddate,recordtype.name from Defendants__r order by createddate) from WRIT_Case__c where ID=:WritCaseIDs]);
        }
        List<Defendants__c> defendantsToUpdate = new List<Defendants__c>();
        for(WRIT_Case__c wc: WritCaseMap.values()){
            Integer approvedCounter = 0;
            Integer rejectedCounter = 0;
            for(Defendants__c def: wc.Defendants__r){
                if(!deletedDefendantID.contains(def.id)){
                    if(def.RecordTypeID == approvedRecordTypeId && WCApprovedDefendantDeletedID.contains(wc.id)){
                        approvedCounter = approvedCounter + 1;
                        def.Defendant_Number_Tag__c = 'A ' + String.valueOf(Integer.ValueOF(approvedCounter)).leftPad(3, '0');
                        defendantsToUpdate.add(def);
                    }
                    if(def.RecordTypeID == rejectedRecordTypeId && WCRejectedDefendantDeletedID.contains(wc.id)){
                        rejectedCounter = rejectedCounter + 1;
                        def.Defendant_Number_Tag__c = 'R ' + String.valueOf(Integer.ValueOF(rejectedCounter)).leftPad(3, '0');
                        defendantsToUpdate.add(def);
                    }
                }
            }
        }
        if(!defendantsToUpdate.isEmpty()){
            update defendantsToUpdate;
        }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('DefendantsTriggerHandler','afterDelete', 'Defendants__c',null, 'High',ex,null);
        }
    }
}