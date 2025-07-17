/***************************************************************************************************************
@Name         :  ConsolteTabCtrl
@Description  :  Depends on Console Tab Setting metadata, fetches rules defined to control lightning console tabs
**************************************************************************************************************/
public with sharing class ConsoleTabCtrl {

    @AuraEnabled
    public static List<Console_Tab_Setting__mdt> getSettings(){
        return [SELECT Active__c, Chat_Event_Type__c, Color__c, Tab_Icon__c, Tab_Label__c, Pulse__c, Critical_Wait_Time_Seconds__c
                FROM Console_Tab_Setting__mdt
                WHERE Active__c = true];
    }
}