public class AccTrialTrigger {
    public static void method1(List<Account> AccList){
        for(Account a : AccList){
            if(a.Active__c == 'Yes'){
              a.CustomerPriority__c = 'High'; 
            } 
            else if(a.industry == 'Banking'){
              a.rating = 'Cold'; 
            }
        }        
    }
    
    public static void method2(List<Account> AccList2){
        List<Contact> conList = new List<Contact>();
        Set<Id> ConIds = new Set<Id>();
        for(Account ac: AccList2 ){
            for(Integer i=1; i<=3; i++){
            Contact con = new Contact();
            con.LastName = ac.Name;
            con.Email = ac.Email__c;
            con.Description = ac.Description;
            con.Phone = ac.Phone;
            con.AccountId = ac.Id;
            conList.add(con);
            }
        }
        If(conList.size()>0){
        insert conList;
           
        }
     }
    public static void method3(List<Account> accList, Map<id,Account> oldAccMap){
        for(Account accc:accList){
            if( oldAccMap != null && accc.phone != oldAccMap.get(accc.id).phone){
              accc.Description = 'Hey!! Your phone no. has changed from - '+oldAccMap.get(accc.id).phone+' to - '+accc.phone;  
            }
            else if (oldAccMap != null && accc.Website != null && accc.Website != oldAccMap.get(accc.id).Website){
                List<Messaging.SingleEmailMessage> EmailToAccList = new  List<Messaging.SingleEmailMessage>();
                
                    Messaging.SingleEmailMessage EmailObj = new Messaging.SingleEmailMessage();
                    List<String> emailAddress = new List<String> ();
                    emailAddress.add(Userinfo.getUserEmail());
                    EmailObj.setToAddresses(emailAddress);
                    EmailObj.setSubject('Your Website Name Has Changed from '+oldAccMap.get(accc.id).Website+' to - '+accc.Website);
                	EmailObj.setPlainTextBody('Hello Dear User, Kindly check Subject for your reference');
                	EmailToAccList.add(EmailObj);
              		if( EmailToAccList.size() > 0){
                	Messaging.sendEmail(EmailToAccList);
                }
            }
        }
    }
}