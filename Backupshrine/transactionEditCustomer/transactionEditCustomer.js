import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import TRANSACTION_MESSAGE_CHANNEL from '@salesforce/messageChannel/transactionMessageChannel__c';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class TransactionEditCustomer extends LightningElement {
    @api editCustomer = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.editCustomer = false; // Explicitly set it to false
        this.notifyFlow();
    }

    handleClick() {
        this.editCustomer = !this.editCustomer;
        this.publishMessage();
        this.notifyFlow();
    }

    publishMessage() {
        const message = {
            editCustomer: this.editCustomer // Send the current state
        };
        publish(this.messageContext, TRANSACTION_MESSAGE_CHANNEL, message);
    }

    notifyFlow() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('editCustomer', this.editCustomer);
        this.dispatchEvent(attributeChangeEvent);
        console.log('editCustomer : ', this.editCustomer);
    }
}