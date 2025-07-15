import { LightningElement, track } from 'lwc';

export default class FilterReport extends LightningElement {

    @track status;
    @track paymentType;

    @track generatedUrl;

    @track fromDate;
    
    @track toDate;


    handleFromDateChange(event) {
        this.fromDate = event.target.value;
    }

    
    handleToDateChange(event) {
        this.toDate = event.target.value;
    }


    // Handle changes for each input field
    handleNameChange(event) {
        this.status = event.target.value;
    }

    handlePaymentChange(event) {
        this.paymentType = event.target.value;
    }

    // Handle Search button click to generate the report URL
    handleSearch() {
        const reportId = '00Oep0000002IAXEA2';  // Your report ID
        let url = `https://ctds--sapdev001.sandbox.lightning.force.com/lightning/r/Report/${reportId}/view?queryScope=userFolders`;

        // Append filters to the URL
        if (this.fromDate) {
            url += `&fv0=${encodeURIComponent(this.fromDate)}`;
        }

        if (this.toDate) {
            url += `&fv1=${encodeURIComponent(this.toDate)}`;
        }


        this.generatedUrl = url;  // Set the URL to display to the user
    }
}