import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import EDIT_MODE_CHANNEL from '@salesforce/messageChannel/EditModeMessageChannel__c';

export default class StateSealViewHeader extends LightningElement {
    @api isReadOnly; // Set the default value for isReadOnly

    // Get the message context for LMS
    @wire(MessageContext)
    messageContext;

    // Publish the initial state when the component loads
    connectedCallback() {
        this.isReadOnly = true;
        this.publishEditMode(); // Publish the current isReadOnly state
    }

    // Handle click on the "Edit" button
    handleEditClick() {
        this.isReadOnly = false; // Switch to edit mode
        this.publishEditMode(); // Publish the new state
    }

    // Function to publish the current isReadOnly state via LMS
    publishEditMode() {
        const message = {
            isReadOnly: this.isReadOnly
        };
        publish(this.messageContext, EDIT_MODE_CHANNEL, message);
    }
}