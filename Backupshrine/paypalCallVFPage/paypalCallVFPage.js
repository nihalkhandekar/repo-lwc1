import { LightningElement,api } from 'lwc';

export default class PaypalCallVFPage extends LightningElement {
  
    @api vfPageUrl = 'https://ctds--sapdev001--c.sandbox.vf.force.com/apex/braintreePaymentVf?core.apexpages.request.devconsole=1'; // VF page URL passed from the flow


    
    connectedCallback() {
        // Listen for messages from the VF page
        window.addEventListener('message', this.handleVFMessage.bind(this));
    }

    handleVFMessage(event) {
        if (event.origin !== 'https://ctds--sapdev001--c.sandbox.vf.force.com') {
            console.error('Message from unexpected origin:', event.origin);
            return;
        }

        console.log('Message from VF page:', event.data);
        // Add your logic to handle the message here
    }

    sendMessageToVF() {
        const iframe = this.template.querySelector('iframe');
        iframe.contentWindow.postMessage({ action: 'triggerPayPal' }, this.vfPageUrl);
    }
}