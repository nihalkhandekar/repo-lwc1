import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader'; 
import apostileDashboardCalender from '@salesforce/resourceUrl/apostileDashboardCalender'; // Import the CSS file

export default class ApostilleDashboardTodayButton extends LightningElement {
    connectedCallback() {
        // Load the CSS file
        // Promise.all([
            loadStyle(this, apostileDashboardCalender) // Load the CSS file
        // ]).then(() => {
        //     this.staticResourceLoaded = true;
        //     console.log('CSS file loaded successfully');
        // }).catch(error => {
        //     console.error('Error loading CSS file:', error);
        // });
    }
}