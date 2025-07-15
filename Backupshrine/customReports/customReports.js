import { LightningElement, track } from 'lwc';

export default class CustomReports extends LightningElement {
    // Base report URL without filters (replace with your actual Salesforce report URL)
    baseUrl = 'https://ctds--sapdev001.sandbox.lightning.force.com/lightning/r/Report/00O3S000000miKdUAI/view';
    // baseUrl = 'https://ctds--sapdev001.sandbox.lightning.force.com/lightning/r/Report/00O3S000000miKdUAI/view?queryScope=userFolders';
    // baseUrl = 'https://ctds--sapdev001.sandbox.lightning.force.com/00O3S000000miKdUAI?embed=true';

    // Current report URL, dynamic with the filter applied

    @track referrerPolicy = 'no-referrer';
    @track
    @track reportUrl = this.baseUrl;

    // Track the filter input value
    @track filterValue = '';

    // Handle the change in the input field
    handleFilterChange(event) {
        this.filterValue = event.target.value;
    }

    // Apply the filter to the report URL
    applyFilter() {
        if (this.filterValue) {
            // Append the filter parameter to the base report URL
            this.reportUrl = `${this.baseUrl}fv0=${encodeURIComponent(this.filterValue)}`;
        } else {
            // Reset to the base URL if no filter is applied
            this.reportUrl = this.baseUrl;
        }
    }
}