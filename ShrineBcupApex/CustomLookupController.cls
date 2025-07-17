public with sharing class CustomLookupController {
     public CustomLookupController() { 

} 

@AuraEnabled(cacheable = true)
 public static List<SearchWrapper> findRecords(String searchKey, String objectName, String searchField,Boolean isNameReservation)
 { 
List<SearchWrapper> result = new List<SearchWrapper>();

String key = '%' + searchKey + '%'; 
String QUERY;
if(isNameReservation == true)
{QUERY = 'Select Id, '+searchField+',	AccountNumber,Business_Type__c,Citizenship__c,Status__c From '+objectName +' Where (Name LIKE :key or Pin__c like :key)  and Status__c = \'Reserved\' and Reserved_Name_Used__c = false Limit 10'; }
else{
QUERY = 'Select Id, '+searchField+',	AccountNumber,Business_Type__c,Citizenship__c,Status__c From '+objectName +' Where '+searchField +' LIKE :key Limit 10'; 
}
System.debug(System.LoggingLevel.DEBUG, QUERY); 
List<SObject> sObjectList = Database.query(QUERY);

Integer count =0;
for(SObject obj: sObjectList){
     SearchWrapper wrap = new SearchWrapper();

     wrap.Id = (String) obj.get('Id');
     wrap.key = ''+count;
     wrap.Name = (String)  obj.get(searchField);
     wrap.bId = (String) obj.get('AccountNumber');
     wrap.btype = (String)  obj.get('Business_Type__c');
     wrap.status = (String)  obj.get('Status__c');
     wrap.citizenship = (String)  obj.get('Citizenship__c');
     result.add(wrap);
     count++;
}

 return result; 
} 


@AuraEnabled(cacheable = true)
 public static List<SearchWrapper> getRecords(String objectName, String searchField,String sid)
 { 
List<SearchWrapper> result = new List<SearchWrapper>();


String QUERY = 'Select Id, '+searchField+',	AccountNumber,Business_Type__c,Citizenship__c,Status__c From '+objectName +' Where id =:sid Limit 1'; 


List<SObject> sObjectList = Database.query(QUERY);

Integer count =0;
for(SObject obj: sObjectList){
     SearchWrapper wrap = new SearchWrapper();

     wrap.Id = (String) obj.get('Id');
     wrap.key = ''+count;
     wrap.Name = (String)  obj.get(searchField);
     wrap.bId = (String) obj.get('AccountNumber');
     wrap.btype = (String)  obj.get('Business_Type__c');
     wrap.status = (String)  obj.get('Status__c');
     wrap.citizenship = (String)  obj.get('Citizenship__c');
     result.add(wrap);
     count++;
}

 return result; 
} 



class SearchWrapper{
@AuraEnabled
public  string Id;
@AuraEnabled
public  string Name;
@AuraEnabled
public  string key;
@AuraEnabled
public  string bId;
@AuraEnabled
public  string btype;
@AuraEnabled
public  string status;
@AuraEnabled
public  string citizenship;
}
}