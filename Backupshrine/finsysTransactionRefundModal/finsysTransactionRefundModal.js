import { LightningElement, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';

export default class FinsysTransactionRefundModal extends LightningModal {

    @track isReadOnly = true;

    connectedCallback() {
        loadStyle(this, stateExtradition)
        .then(() => {
            console.log('First CSS file (stateExtradition) loaded successfully');
        })
        .catch(error => console.error('Error loading CSS file:', error)); 
    }

    get headerText() {
        return this.isReadOnly ? 'Refund' : 'Edit Customer';
    }

    closeModal() {
        this.close('success');
    }

}