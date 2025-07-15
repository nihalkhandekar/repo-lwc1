import { LightningElement, api, wire  } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FLOW_PROGRESS_CHANNEL from '@salesforce/messageChannel/flowStepperMessageChannel__c';

export default class Sap_FlowScreenControllerLWC extends LightningElement {
    @api step; // This attribute should be set in the Flow for each screen (1, 2, 3, 4, etc.)
    @api isVisible = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.publishProgress();
    }

    publishProgress() {
        if (typeof this.step !== 'undefined' && this.step !== null) {
            const message = {
                progressValue: this.step.toString(), // Convert to string safely
                isVisibleStepper: this.isVisible
            };
            publish(this.messageContext, FLOW_PROGRESS_CHANNEL, message);
            console.log('Published step:', this.step); // Debug log
        } else {
            console.error('Step is undefined or null:', this.step);
        }
    }
}