import { LightningElement, api, wire } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
//import DISPOSITIONS_CHANNEL from '@salesforce/messageChannel/DispositionsMessageChannel__c'; // New message channel

export default class SotsUseStateSeal extends LightningElement {
    // Public properties exposed for Flow and other components
    @api letterText = '';
    @api enclosure = '';
    @api proposedUse = '';
    @api requestFor = '';
    @api disposition = '';
    @api approvedFor = '';
    @api responseDate = '';
    @api sotsDate = null;
    @api reason = '';
    @api isReadOnly = false; // Property to control read-only fields
    @api showError = false;

    subscription = null;

    // Wire the MessageContext for Lightning Message Service
    // @wire(MessageContext)
    // messageContext;

    // Subscribe to the message channel when the component is initialized
    connectedCallback() {
        this.responseDate = this.sotsDate;
    }



    // Handle input changes and update fields
    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'responseDate') {
            // Convert the input value to a Date object
            this.sotsDate = new Date(event.target.value);
        } else {
            this[field] = event.target.value;
        }

        // if (field === 'disposition') {
        //     this.publishDispositionChange();
        // }

        // Dispatch a custom event to notify parent components of the change
    }

    // Dynamically determine which radio button should be checked based on the reason value
    get isEducationalChecked() {
        return this.reason === 'Educational';  // Check if reason is Educational
    }

    get isMemorialChecked() {
        return this.reason === 'Memorial';  // Check if reason is Memorial
    }

    get isOfficialBusinessChecked() {
        return this.reason === 'Official Business';  // Check if reason is Official Business
    }

    get isConstitutionChecked() {
        return this.reason === 'Constitution & Laws';  // Check if reason is Constitution & Laws
    }

    // Publish the disposition change to the message channel
    // publishDispositionChange() {
    //     const payload = {
    //         disposition: this.disposition
    //     };
    //     publish(this.messageContext, DISPOSITIONS_CHANNEL, payload);
    // }

    // Options for comboboxes
    get requestForOptions() {
        return [
            { label: 'Arms', value: 'Arms' },
            { label: 'Arms and Seal', value: 'Arms and Seal' },
            { label: 'Seal', value: 'Seal' },
            { label: 'None', value: 'None' }
        ];
    }

    get dispositionOptions() {
        return [
            { label: 'Approved', value: 'Approved' },
            { label: 'Denied', value: 'Denied' },
            { label: 'Pending', value: 'Pending' },
            { label: 'Notice', value: 'Notice' }
        ];
    }

    get approvedForOptions() {
        return [
            { label: 'Arms', value: 'Arms' },
            { label: 'Arms and Seal', value: 'Arms and Seal' },
            { label: 'Seal', value: 'Seal' },
            { label: 'None', value: 'None' }
        ];
    }

    // Options for the radio button group
    get reasonOptions() {
        return [
            { label: 'Educational', value: 'educational' },
            { label: 'Memorial', value: 'memorial' },
            { label: 'Official Business', value: 'officialBusiness' },
            { label: 'Constitution & Laws', value: 'constitutionAndLaws' }
        ];
    }

    // Get method to control the read-only state of the fields dynamically
    get isFieldReadOnly() {
        return this.isReadOnly;
    }

    get isLetterTextInvalid() {
        return !this.letterText && this.showError;
    }

    get letterTextErrorClass() {
        return this.isLetterTextInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isRequestedForInvalid() {
        return !this.requestFor && this.showError;
    }

    get requestedForClass() {
        return this.isRequestedForInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isDispositionInvalid() {
        return !this.disposition && this.showError;
    }

    get dispositionClass() {
        return this.isDispositionInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isDateOfResponseInvalid() {
        return !this.sotsDate && this.showError;
    }

    get dateOfResponseClass() {
        return this.isDateOfResponseInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }
}