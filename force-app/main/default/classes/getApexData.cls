public class getApexData {
   //query contact records//
   @AuraEnabled(Cacheable=true)
   public static list<Contact> getContactData(String name){
    if(name=='')
    {
    return [select Name from Contact limit 5];
    }
    else{
    String searchkey ='%'+name+'%';
    return [select Name from Contact where name like:searchkey];
    }
  }
}