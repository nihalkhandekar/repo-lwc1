// modalFlow.js
import { LightningElement, api } from 'lwc';

export default class ModalFlow extends LightningElement {
    @api flowName;
    @api showOpen = false;
    @api flowTitle;

    @api open() {
        this.showOpen = true;
    }

    close() {
        this.showOpen = false;
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.close();
        }
    }

}