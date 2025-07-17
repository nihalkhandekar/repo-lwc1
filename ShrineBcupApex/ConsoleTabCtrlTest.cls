/***************************************************************************************************************
@Name         :  ConsolteTabCtrlTest 
@Description  :  Test class for ConsoleTabCtrl, must be at least one active rule
**************************************************************************************************************/
@isTest
private class ConsoleTabCtrlTest{

    static testmethod void testConsoleTabSettingsFetch(){
        List<Console_Tab_Setting__mdt> tabSettings = ConsoleTabCtrl.getSettings();
        system.assert(tabSettings.size() > 0);
    }
}