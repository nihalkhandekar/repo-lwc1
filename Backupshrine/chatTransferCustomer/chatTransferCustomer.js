import { LightningElement, api } from 'lwc';
import getMetadataRecords from '@salesforce/apex/ChatTransferCustomerHelper.getMetadataRecords';

const DOMAIN = window.location.hostname;

export default class ChatTransferCustomer extends LightningElement {

    metadataRecords;
    @api errors;

    connectedCallback() {
        getMetadataRecords({ domain: DOMAIN })
            .then(result => {
                this.metadataRecords = result;
            })
            .catch(error => {
                this.errors = error;
            });
    }

    transferCustomer(event) {
        let org = { org: event.currentTarget.value };
        const sendToChatEvent = new CustomEvent('transferCustomer', { detail: org });
        this.dispatchEvent(sendToChatEvent);
    }
}