/**
 * @name        : CTBOT_ChatbotGetAgencyOrigination
 * @description :
 * @depends     :
 * @author      : Slalom
 * @createddate : 11/2020
 * @Modification log:
 * 2/2022 (GL) - Refactored to use CMT instead of custom labels
 * 3/2022 (GL) - Refactored logic to enable conditional render of widget based on origination
 **/
public with sharing class CTBOT_ChatbotGetAgencyOrigination {
    private static final String UNKNOWN_ORIGINATION = 'Unknown';

    @InvocableMethod(label='Get agency origination')
    public static List<ResponsesOutput> getAgencyOrigination(List<ResponsesInput> responsesInput) {
        List<ResponsesOutput> toReturn = new List<ResponsesOutput>();
        LiveChatTranscript theTranscript = new LiveChatTranscript();
        AgencyDto agencyDto = new AgencyDto();

        if (!String.isBlank(responsesInput[0].chatKey)) {
            theTranscript = [
                SELECT Id, Origination__c, Agency_ID__c, Division_URL__c, DCP_Division__c
                FROM LiveChatTranscript
                WHERE ChatKey = :responsesInput[0].chatKey
                WITH USER_MODE
            ];

            agencyDto = parseOrigination(theTranscript.Origination__c);
            theTranscript.DCP_Division__c = agencyDto.divisionName;
            theTranscript.Division_URL__c = agencyDto.divisionUrl;
            theTranscript.Agency_ID__c = agencyDto.agencyName;
            update as user theTranscript;

            // Call for mid tree an final menu option override values
            Bot_Agency_Origination__mdt menuOptionsList = Bot_Agency_Origination__mdt.getInstance(
                theTranscript.Agency_ID__c
            );

            // Set the values for mid tree and final menu options
            String midTreeMenuValues = null;
            String finalMenuValues = null;
            if (menuOptionsList != null) {
                midTreeMenuValues = menuOptionsList.Mid_Tree_Menu_Option_Overrides__c;
                finalMenuValues = menuOptionsList.Final_Menu_Option_Overrides__c;
            }

            // If menu options field contains a value, assign it that value. If not, assign the default options.
            String midTreeMenuOptionOverrides = midTreeMenuValues != null
                ? midTreeMenuValues
                : 'Main Menu,, Get Support';
            String finalMenuOptionOverrides = finalMenuValues != null ? finalMenuValues : 'Main Menu,, Get Support';

            // Adding InvocableVariables and their values to the Output class
            ResponsesOutput theOutput = new ResponsesOutput();
            theOutput.midTreeMenuOptionOverrides = midTreeMenuOptionOverrides;
            theOutput.finalMenuOptionOverrides = finalMenuOptionOverrides;
            theOutput.agencyOrigination = agencyDto.agencyName;
            theOutput.sitecoreEntityName = agencyDto.sitecoreEntityName;
            theOutput.DCP_Division = agencyDto.divisionName;
            toReturn.add(theOutput);
        }
        return toReturn;
    }

    @AuraEnabled
    public static AgencyDto parseOrigination(String originationUrl) {
        AgencyDto agencyDto = new AgencyDto();
        String mdtBaseUrl = '';
        String matchedBaseUrl = '';

        if (String.isNotBlank(originationUrl)) {
            Map<String, Bot_Agency_Origination__mdt> mapUrlToAgency = new Map<String, Bot_Agency_Origination__mdt>();
            Integer matchCounter = 0;

            // Loop through Agency CMDT to see if the originating URL is a valid bot page
            for (Bot_Agency_Origination__mdt agencyMdt : Bot_Agency_Origination__mdt.getAll().values()) {
                if (
                    String.isNotBlank(agencyMdt.Origination_Test_Url__c) &&
                    String.isNotBlank(agencyMdt.Origination_Url__c)
                ) {
                    mdtBaseUrl = System.Label.CTBOT_Chatbot_Environment != 'PROD'
                        ? agencyMdt.Origination_Test_Url__c
                        : agencyMdt.Origination_Url__c;
                    mapUrlToAgency.put(mdtBaseUrl, agencyMdt);
                    if (originationUrl.containsIgnoreCase(mdtBaseUrl)) {
                        matchedBaseUrl = mdtBaseUrl;
                        matchCounter++;
                        if (matchCounter > 1) {
                            break;
                        }
                    }
                }
            }

            // Remove base url and create list of subdirectories to process later
            List<String> urlSplitList = originationUrl.removeStartIgnoreCase(matchedBaseUrl)
                .removeStart('/')
                .split('/');
            String agencyOrDivSubdir = urlSplitList[0].split('\\?')[0].toLowerCase();
            urlSplitList.remove(0);

            if (matchCounter > 0) {
                // Find agency and child divisions (if any)
                String strAgencyQuery =
                    'SELECT Id, MasterLabel, Sitecore_Entity_Name__c, Mid_Tree_Menu_Option_Overrides__c, Final_Menu_Option_Overrides__c,' +
                    ' (SELECT Id, Division_Name__c, Division_URL__c, Agency__r.MasterLabel, Agency__r.Sitecore_Entity_Name__c FROM Bot_Agency_Divisions__r)' +
                    ' FROM Bot_Agency_Origination__mdt' +
                    ' WHERE';
                if (matchCounter > 1 && String.isNotBlank(agencyOrDivSubdir)) {
                    strAgencyQuery += ' Agency_Subdirectory__c = :agencyOrDivSubdir';
                } else if (matchCounter == 1) {
                    String mdtLabel = mapUrlToAgency.get(matchedBaseUrl).MasterLabel;
                    strAgencyQuery += ' MasterLabel = :mdtLabel';
                } else {
                    strAgencyQuery = '';
                }

                List<Bot_Agency_Origination__mdt> lstMatchingAgencies = String.isNotBlank(strAgencyQuery)
                    ? Database.query(strAgencyQuery)
                    : new List<Bot_Agency_Origination__mdt>();
                if (lstMatchingAgencies.size() > 0) {
                    // Agency is found
                    // If there are child divisions, guest is on a division page so go find a match
                    if (lstMatchingAgencies[0].Bot_Agency_Divisions__r.size() > 0) {
                        agencyDto = parseDivision(
                            lstMatchingAgencies[0].Bot_Agency_Divisions__r,
                            agencyDto,
                            urlSplitList
                        );
                        // If there are no child divisions, guest is on an agency page
                    } else {
                        agencyDto.agencyName = lstMatchingAgencies[0].MasterLabel;
                        agencyDto.sitecoreEntityName = lstMatchingAgencies[0].Sitecore_Entity_Name__c;
                    }
                }
            }
        }
        return agencyDto;
    }

    public static AgencyDto parseDivision(
        List<Bot_Agency_Division__mdt> lstChildDivisions,
        AgencyDto agencyDto,
        List<String> urlSplitList
    ) {
        Map<String, Bot_Agency_Division__mdt> mapUrlToDivision = new Map<String, Bot_Agency_Division__mdt>();
        for (Bot_Agency_Division__mdt div : lstChildDivisions) {
            mapUrlToDivision.put(div.Division_URL__c, div);
        }

        // Loop through origination url to find a match with the Division CMDT
        for (String subdir : urlSplitList) {
            String lcSubdir = subdir.split('\\?')[0].toLowerCase();
            if (mapUrlToDivision.get(lcSubdir) != null) {
                agencyDto.divisionName = mapUrlToDivision.get(lcSubdir).Division_Name__c;
                agencyDto.divisionUrl = lcSubdir;
                agencyDto.agencyName = mapUrlToDivision.get(lcSubdir).Agency__r.MasterLabel;
                agencyDto.sitecoreEntityName = mapUrlToDivision.get(lcSubdir).Agency__r.Sitecore_Entity_Name__c;
                break;
            }
        }
        return agencyDto;
    }

    public class AgencyDto {
        @AuraEnabled
        public String agencyName;
        @AuraEnabled
        public String sitecoreEntityName;
        @AuraEnabled
        public String divisionName;
        @AuraEnabled
        public String divisionUrl;
    }

    public class ResponsesInput {
        @InvocableVariable
        public String chatKey;
    }

    public class ResponsesOutput {
        @InvocableVariable
        public String midTreeMenuOptionOverrides;
        @InvocableVariable
        public String finalMenuOptionOverrides;
        @InvocableVariable
        public String agencyOrigination;
        @InvocableVariable
        public String sitecoreEntityName;
        @InvocableVariable
        public String DCP_Division;
    }
}