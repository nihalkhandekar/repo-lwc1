public class brsOrgUrl {
    
    @AuraEnabled(cacheable=true)
    public static String getOrgUrl(){
    //    String vUrl = 'https://' + Url.getSalesforceBaseUrl().getHost();
    //    ctds--brsdev001.my.salesforce.com
        String vUrl = Url.getSalesforceBaseUrl().getHost();
        String[] vURLsplit = vUrl.split('\\.');
        String vURLsplit1 = vURLsplit[0]; 
		System.debug('vURL is: ' + vUrl);
        return vURLsplit1;
   

    }
    

}