/*********************************************************************************************
* NAME:  BOS_ResourceNotificationUtility
* DESCRIPTION: Class used for managing Resource Notification
*
* @AUTHOR: Nancy Gupta
* @DATE: 04/02/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE (DD/MM/YYYY)                     DESCRIPTION
* _____________________________________________________________________________________________
* Nancy Gupta                   04/02/2021                        Created the first version
*
*************************************************************************************************/

public without sharing class BOS_ResourceNotificationUtility{
    
     /********************************************************************************************
METHOD NAME    : isResourceNotificationEnabled
DESCRIPTION    : computes notification flags
RETURN TYPE    : Boolean
PARAMETER      : NA
********************************************************************************************/
    @AuraEnabled
    public static Boolean isResourceNotificationEnabled(){
        if(userInfo.getUserType() != 'Guest'){
            Boolean result = false;
            User u =[Select ID,ContactID from User where ID=: UserInfo.getUserID()];
            Contact con;
            if(u != null && u.ContactID != Null){
                con = [Select ID, name, Resource_Email_Notification__c, Resource_SMS_Notification__c from contact where ID=: u.ContactID];
                if(con != Null && (con.Resource_Email_Notification__c == True || con.Resource_SMS_Notification__c == True)){
                    result = True;
                }
            }
            return result;
        }
        else{
            return false;
        }
    }
    
}