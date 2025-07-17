public without sharing class ContactTriggerHelper {
    /**********************************************************************************************************************
METHOD NAME    : validateGovernmentUser
DESCRIPTION    : Method to 
PARAMETER      : List<Contact> newTriggerList
Owner          : Rabbani
***********************************************************************************************************************/
public static void validateGovernmentUser(List<SObject> newItems,Map<Id, sObject> oldItems){    
    Set<id> contactIds=new Set<id>();
    Map<id,Boolean> MappingGovernment=new Map<id,Boolean>();    
        for(sObject sobj:newItems){
            Contact newcontact = (Contact)sobj;
            Contact oldcontact = (Contact)oldItems.get(newcontact.id);
            if(newcontact.isGovernmentUser__c != oldcontact.isGovernmentUser__c) 
            {
                contactIds.add(newcontact.id);
                MappingGovernment.put(newcontact.id,newcontact.isGovernmentUser__c);
            }
        }
        List<User> Userinfolist=[select id, name,isGovernmentUser__c,profile.name,ContactId from user where ContactId IN:contactIds and profile.name='CT Community User'];
        List<User> newUserList=new List<User>();
    if(!Userinfolist.isempty())
    {
        for(User userinfo:Userinfolist)
        {
            userinfo.isGovernmentUser__c=MappingGovernment.get(userinfo.ContactId);
            newUserList.add(userinfo);
        }
        if(!Test.isRunningTest())
        {
            update newUserList; 
        }     
    }     
    }
}