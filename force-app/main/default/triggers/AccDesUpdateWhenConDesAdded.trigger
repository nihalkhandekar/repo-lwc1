trigger AccDesUpdateWhenConDesAdded on Contact (after insert, after update, after delete, after undelete) {
    List<Account> accListToUpdate = new List<Account>();
    Set<Id> AccIdSet = new Set<Id>();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            for(Contact con : trigger.new){
                if(con.AccountId != null){
                   AccIdSet.add(con.AccountId); 
                }  
            }
        }
        else if(trigger.isDelete){
            for(Contact con : trigger.old){
                if(con.AccountId != null){
                  AccIdSet.add(con.AccountId);  
                }
            }
        }
        else if(trigger.isUpdate){
            for(Contact con : trigger.new){
                if(trigger.oldMap.get(con.id).AccountId != con.AccountId){
                  AccIdSet.add(trigger.OldMap.get(con.id).AccountId);  
                }
                AccIdSet.add(con.AccountId);
            }
        }
        List<Account> AccConList = [select id, Description, (select id, Description from Contacts) from Account where id =: AccIdSet];
        List<String> Detail = new List<String>();
        
        for(Account acc : AccConList){
            for(Contact c : acc.Contacts){
                Detail.add(c.Description);
            }
            acc.Description = String.join(Detail, ', ');
            accListToUpdate.add(acc);
        }
    }
    update accListToUpdate;
}