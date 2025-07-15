import { LightningElement, wire, track  } from 'lwc';
import getIdReport from '@salesforce/apex/ReportDownloadController.getIdReport';

export default class ReportDownload extends LightningElement {

    @track selectedReport;
    @track isDownloadDisabled = true;

    @track reportOptions = [
        {label: "CORE-CT Deposit Summary", value:  "CORE-CT Deposit Summary"},
        {label: "Cumulative Deposit Summary", value:  "Cumulative Deposit Summary"},
        {label: "Daily Transaction Listing", value:  "Daily Transaction Listing"},
        {label: "Deposit Summary", value:  "Deposit Summary"},
        {label: "Credit Card Summary", value: "Credit Card Summary" },
        {label: "Aging Report", value: "Aging Report" },
        {label: "Returned Checks Summary", value: "Returned Checks Summary" },
        {label: "Credit Balance", value: "Credit Balance"},
        {label: "Refunded Request History", value: "Refunded Request History" },
        {label: "User Closeout Report", value: "User Closeout Report" },
        {label: "Settlement Report", value:  "Settlement Report"},
        {label: "Daily Settlement Report", value:  "Daily Settlement Report"},
        {label: "Notary Public Reconciliation Report", value:  "Notary Public Reconciliation Report"},
    ];


    handleReportChange(event) {
        this.selectedReport = event.detail.value;
        this.isDownloadDisabled = !this.selectedReport;
    }

    async handleDownload() {
        if (this.selectedReport) {
            try {
                const reportId = await getIdReport({ reportName: this.selectedReport });
                window.open(`/apex/ReportPDF?reportId=${reportId}&reportName=${encodeURIComponent(this.selectedReport)}`, '_blank');
            } catch (error) {
                console.error('Error downloading report:', error);
                // Add error handling UI feedback here
            }
        }
    }

}