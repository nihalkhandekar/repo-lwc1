public with sharing class CTBOT_RandomPhraseGenerator {
    
    @InvocableMethod(label='Generate random phrases for infinite tree')
    public static List<String> generatePhrase(List<Input> inputs) {
        List<String> parsedPhrases = new List<String>();
        Decimal randomInt = Math.random();
        Decimal percentage = 1 - Decimal.valueOf(inputs[0].hideQuestionChance) / 100;
        if (inputs[0].isGlobalPhrases == true) {
            parsedPhrases = getGlobalPhrases(inputs[0].globalPhrasesCategory);
        } else {
            parsedPhrases = inputs[0].phrases.split(',,');
        }
        String randomPhrase = parsedPhrases.get(getRandomNumber(parsedPhrases.size()));

        return randomInt < percentage ? new List<String>{ randomPhrase.trim() } : new List<String>{ 'HIDE_QUESTION~' };
    }

    private static Integer getRandomNumber(Integer max) {
        return Integer.valueOf(Math.floor(Math.random() * max));
    }

    private static List<String> getGlobalPhrases(String category) {
        List<String> lstGlobalPhrases = new List<String>();
        for (Infinite_Tree_Global_Phrase__mdt mdt : [SELECT Id, Phrase__c
                                                     FROM Infinite_Tree_Global_Phrase__mdt
                                                     WHERE Type__c = :category])
        {
            lstGlobalPhrases.add(mdt.Phrase__c);
        }

        return lstGlobalPhrases;
    }

    public class Input {
        @InvocableVariable(label='Random Bot Phrases' description='Predetermined phrases for the bot to return' required=false)
        public String phrases;

        @InvocableVariable(label='No Phrase Chance (%)' description='The likelihood the bot says nothing' required=true)
        public Integer hideQuestionChance;

        @InvocableVariable(label='Global Bot Phrases Category' description='Specify a set of generic phrases' required=false)
        public String globalPhrasesCategory;

        @InvocableVariable(label='Use Global Bot Phrases' description='Use global phrases' required=true)
        public Boolean isGlobalPhrases;
    }
}