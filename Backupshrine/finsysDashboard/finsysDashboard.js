import { LightningElement,track } from 'lwc';
import {loadStyle } from 'lightning/platformResourceLoader'; 
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
export default class FinsysDashboard extends LightningElement {


    @track openBatchCode;
    @track closeBatchCode;
    
    @track batchCodeOptions = [
        { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
        { label: 'Board of Accountancy', value: 'Board of Accountancy' },
        { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
        { label: 'Notary Public', value: 'Notary Public' },
        { label: 'Sales', value: 'Sales' },
        { label: 'Trademarks', value: 'Trademarks' }
    ];

    connectedCallback() {
        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('First CSS file (stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));
    }



}