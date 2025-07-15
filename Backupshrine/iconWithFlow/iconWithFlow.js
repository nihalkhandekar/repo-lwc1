import { LightningElement, api, wire } from 'lwc';
// import { publish, MessageContext } from 'lightning/messageService';
// import FLOW_PROGRESS_CHANNEL from '@salesforce/messageChannel/flowStepperMessageChannel__c';

export default class IconWithFlow extends LightningElement {
    @api iconName;
    @api alternativeText;
    @api title;
    @api heading;
    @api description;
    @api iconColor;

    // @wire(MessageContext)
    // messageContext;

    // publishProgress() {
    //     const message = {
    //         progressValue: 'test-1'
    //     };
    //     console.log('Publishing message:', message);
    //     publish(this.messageContext, FLOW_PROGRESS_CHANNEL, message);
    //     console.log('Message published');
    // }

    // connectedCallback() {
    //     this.publishProgress(); // Automatically publish when the component is initialized
    // }
}