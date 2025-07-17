public class DynamicReportController {
    @AuraEnabled(cacheable=true)
    public static String getIdReport(String reportName) {
        try {
            List<sObject> reports = [
                SELECT Id, Name
                FROM Report 
                WHERE Name = :reportName 
                LIMIT 1
            ];
            
            if (!reports.isEmpty()) {
                return (String)reports[0].get('Id');
            } else {
                throw new AuraHandledException('Report not found: ' + reportName);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving report: ' + e.getMessage());
        }
    }
    
 public String reportId { get; set; }
    public Blob pdfContent { get; set; }
    public String pdfContentAsString { get; set; } // New property for String representation of PDF content

    public void init() {
        reportId = ApexPages.currentPage().getParameters().get('reportId');
        renderPDF();
    }

    public void renderPDF() {
        try {
            if (String.isNotBlank(reportId)) {
                // Create the report export URL
                String instanceUrl = System.Url.getOrgDomainUrl().toExternalForm();
                String reportUrl = instanceUrl + '/' + reportId + '?csv=0&exp=1&enc=UTF-8&isdtp=p1';

                // Get the report content
                PageReference reportPage = new PageReference(reportUrl);

                // Maintain session
                String sessionId = UserInfo.getSessionId();
                if (String.isNotBlank(sessionId)) {
                    Cookie sessionCookie = new Cookie('sid', sessionId, null, -1, false);
                    reportPage.setCookies(new Cookie[]{ sessionCookie });
                }

                pdfContent = reportPage.getContent();
                pdfContentAsString = pdfContent.toString(); // Convert Blob to String
            } else {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 'Report ID is required'
                ));
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error generating PDF: ' + e.getMessage()
            ));
        }
    }

   
    
}