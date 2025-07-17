@isTest
public with sharing class CTBOT_InterOrgTransferOptionsTest {
    
    @isTest
    static void testGetInterOrgTransferOptions() {
        List<List<String>> results1 = CTBOT_InterOrgTransferOptions.getInterOrgTransferOptions(new List<String>{ 'CTPL' });
        System.assert(results1[0].contains('BOS'));
        List<List<String>> results2 = CTBOT_InterOrgTransferOptions.getInterOrgTransferOptions(new List<String>{ 'BOS' });
        System.assert(results2[0].contains('DCP'));
        List<List<String>> results3 = CTBOT_InterOrgTransferOptions.getInterOrgTransferOptions(new List<String>{ 'DCP' });
        System.assert(results3[0].contains('BOS'));
        List<List<String>> results4 = CTBOT_InterOrgTransferOptions.getInterOrgTransferOptions(new List<String>{ 'OTHER' });
        System.assert(results4[0].contains('BOS'));
        System.assert(results4[0].contains('DCP'));
    }
}