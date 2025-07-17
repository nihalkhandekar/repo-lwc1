@isTest
private class CTBOT_RandomPhraseGeneratorTest {
    @isTest
    static void testGeneratePhrase() {
        CTBOT_RandomPhraseGenerator.Input input = new CTBOT_RandomPhraseGenerator.Input();
        input.phrases = 'Main Menu,, Get Support';
        input.hideQuestionChance = 0;
        input.globalPhrasesCategory = 'General';
        input.isGlobalPhrases = true;

        // Test global phrases
        Map<String, Infinite_Tree_Global_Phrase__mdt> mapGlobalPhrases = new Map<String, Infinite_Tree_Global_Phrase__mdt>();
        for (Infinite_Tree_Global_Phrase__mdt mdt : [SELECT Id, Phrase__c
                                                     FROM Infinite_Tree_Global_Phrase__mdt
                                                     WHERE Type__c = 'General'])
        {
            mapGlobalPhrases.put(mdt.Phrase__c, mdt);
        }
        List<String> globalPhrasesString = CTBOT_RandomPhraseGenerator.generatePhrase(new List<CTBOT_RandomPhraseGenerator.Input>{input});
        System.assert(mapGlobalPhrases.containsKey(globalPhrasesString[0]));

        // Test random phrases
        input.isGlobalPhrases = false;
        List<String> randomPhrasesString = CTBOT_RandomPhraseGenerator.generatePhrase(new List<CTBOT_RandomPhraseGenerator.Input>{input});
        System.assert(input.phrases.contains(randomPhrasesString[0]));
    }
}