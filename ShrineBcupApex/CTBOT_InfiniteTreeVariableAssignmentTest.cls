@isTest
private class CTBOT_InfiniteTreeVariableAssignmentTest {
    @isTest
    static void testAssignVariables() {
        CTBOT_InfiniteTreeVariableAssignment.InputOutput input = new CTBOT_InfiniteTreeVariableAssignment.InputOutput();
        input.finalMenuOptions = 'Main Menu,, What is myconneCT,, Get Support';
        input.globalPhrasesCategory = 'General';
        input.isGlobalPhrases = true;
        input.midTreeMenuOptions = 'Main Menu,, Get Support';
        input.nullPercentChance = 0;
        input.randomBotPhrases = 'Which of the following applies to you?,, What other questions can I answer for you?,, What would you like to know more about?';

        List<CTBOT_InfiniteTreeVariableAssignment.InputOutput> output = CTBOT_InfiniteTreeVariableAssignment.assignVariables(new List<CTBOT_InfiniteTreeVariableAssignment.InputOutput>{input});
        System.assertEquals(input.finalMenuOptions, output[0].finalMenuOptions);
        System.assertEquals(input.globalPhrasesCategory, output[0].globalPhrasesCategory);
        System.assertEquals(input.isGlobalPhrases, output[0].isGlobalPhrases);
        System.assertEquals(input.midTreeMenuOptions, output[0].midTreeMenuOptions);
        System.assertEquals(input.nullPercentChance, output[0].nullPercentChance);
        System.assertEquals(input.randomBotPhrases, output[0].randomBotPhrases);
    }
}