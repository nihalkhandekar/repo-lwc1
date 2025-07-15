import { LightningElement,track,api } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import modalPrintCss from '@salesforce/resourceUrl/modalPrintCss';
import getDocDetails from '@salesforce/apex/ApostillePrintSubmissionDocController.getDocDetails';


export default class ApostillePrintRejectionDocument extends LightningModal {
   
    @track isLoading = true;

    connectedCallback() {
        // Load the CSS file
        loadStyle(this, modalPrintCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

            console.log('record id is '+ this.recordId);
        this.fetchData();
    }

    fetchData() {
        // Simulate an asynchronous data fetch with a timeout
        setTimeout(() => {
            // Fetch data here and set it to this.data
            this.data = [
                // Your data goes here
            ];
    
            // Once data is fetched, hide the loader
            this.isLoading = false;
        }, 2000); // Simulate a 2-second loading time
    }

     // Method to handle cancel action
     handleCancel() {
        this.close();
    }

}