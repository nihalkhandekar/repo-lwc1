public with sharing class CTBOT_DynamicDialog {
    
    @InvocableMethod(label='Retrieve Sitecore article ID based on origination' description='Gets the ID of an article to retrieve from Sitecore based off the parsed origination')
    public static List<Output> retrieveArticle(List<Input> inputs) {
        Output output = new Output();
        List<Robin_Dynamic_Dialog__mdt> recordsFilteredByOrigination = new List<Robin_Dynamic_Dialog__mdt>();
        String fallbackId;

        List<Robin_Dynamic_Dialog__mdt> articleIdRecords = [
            SELECT MasterLabel, Fallback_ID__c, Bot_Agency_Origination__r.MasterLabel, Bot_Agency_Division__r.Division_Name__c
            FROM Robin_Dynamic_Dialog__mdt
            WHERE Dialog_Name__c = :inputs[0].dialogName
        ];

        for (Robin_Dynamic_Dialog__mdt idRecord : articleIdRecords) {
            if (idRecord.Bot_Agency_Origination__r.MasterLabel == inputs[0].origination) {
                recordsFilteredByOrigination.add(idRecord);
            }
            if (fallbackId == null && idRecord.Fallback_ID__c != null) {
                fallbackId = idRecord.Fallback_ID__c;
            }
        }

        if (recordsFilteredByOrigination.size() == 1) {
            output.dynamicArticleId = recordsFilteredByOrigination[0].MasterLabel;
        }

        // Fall back to any ID for the given dialog since all fallback IDs should be the same for a given agency
        output.dynamicArticleId = output.dynamicArticleId == null ? fallbackId : output.dynamicArticleId;

        return new List<Output>{ output };

    }

    public class Input {
        @InvocableVariable(label='Origination' description='The agency to filter CMT records by')
        public String origination;

        @InvocableVariable(label='DCP Division' description='The division for DCP')
        public String dcpDivision;

        @InvocableVariable(label='Dialog Name' description='The name of the current dialog')
        public String dialogName;
    }

    public class Output {
        @InvocableVariable(label='Dynamic Article ID' description='The retrieved article ID')
        public String dynamicArticleId;
    }
}