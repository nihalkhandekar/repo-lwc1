import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import finsys_slidderButton from '@salesforce/resourceUrl/finsys_slidderButton';

export default class FinsysWorkOrder extends LightningElement {
    @track activeView = 'workOrderTransaction';

    get showWorkOrderTransaction() {
        return this.activeView === 'workOrderTransaction';
    }

    get showRefunds() {
        return this.activeView === 'refunds';
    }

    get showReturnedChecksProcessing() {
        return this.activeView === 'returnedCheck';
    }

    get transactionClass() {
        return `slds-m-left_x-small Transaction ${this.activeView === 'workOrderTransaction' ? 'activeTransaction-button' : ''}`;
    }

    get refundClass() {
        return `slds-m-left_x-small refund ${this.activeView === 'refunds' ? 'active-button' : ''}`;
    }

    get returnCheckClass() {
        return `slds-m-left_x-small returnCheck ${this.activeView === 'returnedCheck' ? 'activeReturned-button' : ''}`;
    }

    handleNavigation(event) {
        this.activeView = event.target.title;
    }

    connectedCallback() {
        loadStyle(this, finsys_slidderButton)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));
    }
}