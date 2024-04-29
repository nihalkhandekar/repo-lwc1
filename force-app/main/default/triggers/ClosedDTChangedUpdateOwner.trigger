trigger ClosedDTChangedUpdateOwner on Opportunity (after update) {
    
    for(Opportunity oppNew : Trigger.new){
        List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
        Opportunity oppOld = Trigger.oldMap.get(oppNew.id);
        
        if(oppNew.CloseDate != oppOld.CloseDate){
            Messaging.SingleEmailMessage emailObj = New Messaging.SingleEmailMessage ();
            List<String> emailAddress = new List<String> ();
            emailAddress.add(userInfo.getUserEmail());
            emailObj.setToAddresses(emailAddress);
            emailObj.setSubject('Closed Date Has Changed');
            emailObj.setPlainTextBody('Closed Date Has Changed from '+oppOld.CloseDate+ 'to '+oppNew.CloseDate);
            emailObjList.add(emailObj);
        }
        Messaging.sendEmail(emailObjList);
    }
}