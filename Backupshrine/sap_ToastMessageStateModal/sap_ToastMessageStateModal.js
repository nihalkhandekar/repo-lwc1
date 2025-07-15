import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastMessage extends LightningElement {
    @api
    showToast(toastMessageDetails) {
        this.dispatchEvent(new ShowToastEvent(toastMessageDetails));
    }
}