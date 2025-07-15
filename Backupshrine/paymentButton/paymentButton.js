import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PAYPAL_SCRIPT = 'https://www.paypal.com/sdk/js?client-id=test&currency=USD';

export default class PaymentButton extends LightningElement {
    @track scriptLoaded = false;
    @track isProcessing = false;

    connectedCallback() {
        if (!this.scriptLoaded) {
            this.loadPaypalScript();
        }
    }

    loadScript(scriptUrl) {
        return new Promise((resolve, reject) => {
            if (document.querySelector(`script[src="${scriptUrl}"]`)) {
                console.log('PayPal script already loaded');
                resolve();
                return;
            }

            const script = document.createElement('script');
            script.src = scriptUrl;
            script.type = 'text/javascript';
            script.async = true;

            script.onload = () => {
                console.log('PayPal SDK loaded successfully');
                resolve();
            };

            script.onerror = (error) => {
                console.error('Error loading PayPal SDK:', error);
                reject(new Error(`Failed to load script from ${scriptUrl}`));
            };

            document.body.appendChild(script);
        });
    }

    async loadPaypalScript() {
        try {
            await this.loadScript(PAYPAL_SCRIPT);
            this.scriptLoaded = true;
            this.initializePaypalButtons();
        } catch (error) {
            console.error('Error loading PayPal SDK:', error);
            this.showToast('Error', 'Failed to load PayPal SDK. Please try again later.', 'error');
        }
    }

    initializePaypalButtons() {
        if (!window.paypal) {
            console.error('PayPal SDK is not loaded.');
            return;
        }

        paypal.Buttons({
            createOrder: (data, actions) => {
                console.log('CreateOrder called:', data); // Ensure this isn't logging the event object
                return actions.order.create({
                    purchase_units: [{
                        amount: { value: '10.00' }
                    }]
                });
            },
            onApprove: (data, actions) => {
                console.log('onApprove called:', data); // Inspect what is logged here
                return actions.order.capture().then(details => {
                    console.log('Transaction details:', details);
                });
            },
            onError: (err) => {
                console.error('PayPal Error:', err); // Ensure only relevant errors are logged
            }
        }).render('#paypal-button-container');
        
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}