import { LightningElement, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import TRANSACTION_MESSAGE_CHANNEL from '@salesforce/messageChannel/transactionMessageChannel__c';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class TransactionViewHeader extends LightningElement {
    @api isReadOnly = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.isReadOnly = true; // Set it to true after initialization
        this.notifyFlow();
        this.subscribeToMessageChannel();
    }
    handleEditClick() {
        this.isReadOnly = false;
        this.notifyFlow();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            TRANSACTION_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if (message.hasOwnProperty('editCustomer')) {
            this.isReadOnly = !message.editCustomer;
            this.notifyFlow();
        }
    }

    notifyFlow() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('isReadOnly', this.isReadOnly);
        this.dispatchEvent(attributeChangeEvent);
        console.log('ReadOnlymode : ', this.isReadOnly);
    }
}