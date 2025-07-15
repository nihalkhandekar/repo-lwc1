import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class LastComponent extends LightningElement {
    @api sharedValue; // Flow variable input-output
    @api showError = false;

    handleButtonClick() {
        // Set the shared value to something new
        this.sharedValue = 'New Value from Last Component';

        // Dispatch event to update flow variable
        const attributeChangeEvent = new FlowAttributeChangeEvent('sharedValue', this.sharedValue);
        this.dispatchEvent(attributeChangeEvent);
    }
}