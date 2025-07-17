public with sharing class CTBOT_InfiniteTreeVariableAssignment {
    
    @InvocableMethod(label='Assign infinite tree variables' description='Assigns variables for infinite tree dialog')
    public static List<InputOutput> assignVariables(List<InputOutput> inputOutput) {
        return inputOutput;
    }

    public class InputOutput {
        @InvocableVariable(label='Random Bot Phrases')
        public String randomBotPhrases;

        @InvocableVariable(label='Mid Tree Menu Options')
        public String midTreeMenuOptions;

        @InvocableVariable(label='Final Menu Options')
        public String finalMenuOptions;

        @InvocableVariable(label='Chance (%) Of No Bot Message In Tree')
        public Integer nullPercentChance;

        @InvocableVariable(label='Global Bot Phrases Category')
        public String globalPhrasesCategory;

        @InvocableVariable(label='Use Global Bot Phrases')
        public Boolean isGlobalPhrases;
    }
}