public with sharing class CTBOT_InterOrgTransferOptions {

    private static Map<String, String> originations = new Map<String, String>();
    static {
        List<String> labels = Label.CTBOT_AgencyOrigination.split('\n');
        for (String s : labels) {
            List<String> keyValue = s.split('=');
            originations.put(keyValue[0].trim(), keyValue[1].trim());
        }
    }

    @InvocableMethod(label='Get inter-org transfer options')
    public static List<List<String>> getInterOrgTransferOptions(List<String> origination) {
        switch on origination[0] {
            when 'CTPL' {
                return new List<List<String>>{ new List<String>{ originations.get('BOS Acronym'), 
                    originations.get('DCP Acronym') }};
            }
            when 'BOS' {
                return new List<List<String>>{ new List<String>{ originations.get('DCP Acronym') }};
            }
            when 'DCP' {
                return new List<List<String>>{ new List<String>{ originations.get('BOS Acronym') }};
            }
            when else {
                return new List<List<String>>{ new List<String>{ originations.get('BOS Acronym'), 
                    originations.get('DCP Acronym') }};
            }
        }
    }
}