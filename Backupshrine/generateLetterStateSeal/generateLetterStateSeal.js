import { LightningElement, api, wire } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import EDIT_MODE_CHANNEL from '@salesforce/messageChannel/EditModeMessageChannel__c'; // Import the message channel
//import DISPOSITIONS_CHANNEL from '@salesforce/messageChannel/DispositionsMessageChannel__c'; // New message channel
import VALIDATION_STATUS_CHANNEL from '@salesforce/messageChannel/ValidationStatusMessageChannel__c'; // Use the new channel
import getStateSealStaffData from '@salesforce/apex/MaintainStaffDataController.getStateSealStaffData';

export default class GenerateLetterStateSeal extends LightningElement {
    // Public properties for Flow
    @api signedByOptions = [];
    @api letterTypeOptions = [];
    @api signedBy = '';
    @api letterType = '';
    @api wetSignature = '';
    @api disposition = ''; // New property for "Disposition"
    @api disposition_new = '';
    @api isReadOnly = false; // Property to control read-only fields
    @api signedbyError = false;

    subscription = null;

    // Wire the MessageContext for Lightning Message Service
    @wire(MessageContext)
    messageContext;

    // Subscribe to the message channel when the component is initialized
    connectedCallback() {
        this.fetchStaffData();  // Fetch the staff data from Apex
        this.subscribeToMessageChannel(); // Subscribe to the EditModeMessageChannel
        this.setLetterTypeOptions();
        this.publishInitialData(); // Publish initial values for all fields
    }

    // Method to fetch staff data from Apex and set options
    fetchStaffData() {
        getStateSealStaffData()
            .then((result) => {
                this.signedByOptions = result.map(staff => {
                    return {
                        label: `${staff.LastName} ${staff.FirstName}, ${staff.Staff_Title__c}`,
                        value: staff.Id
                    };
                });
            })
            .catch((error) => {
                console.error('Error fetching staff data: ', error);
            });
    }

   // Publish initial values to the ValidationStatusMessageChannel
    publishInitialData() {
        // Check if all fields have values before publishing
        const isValid = this.signedBy && this.letterType && (this.wetSignature === 'Yes' || this.wetSignature === 'No');

        if (isValid) {
            const initialData = {
                signedBy: this.signedBy,
                letterType: this.letterType,
                wetSignature: this.wetSignature,
                isValid: true // The form is valid
            };

            // Publish the initial data
            publish(this.messageContext, VALIDATION_STATUS_CHANNEL, initialData);
        } else {
            console.warn('Form not complete; data not published.');
        }
    }



    setLetterTypeOptions() {
        if (this.disposition_new === 'Approved') {
            this.letterTypeOptions = [
                { label: 'Official Business', value: 'Official Business' },
                { label: 'Non-Standard', value: 'Non-Standard' }
            ];
        } else if (this.disposition_new === 'Denied') {
            this.letterTypeOptions = [
                { label: 'Denial (short)', value: 'Denial (short)' },
                { label: 'Denial (long)', value: 'Denial (long)' }
            ];
        } else if (this.disposition_new === 'Notice') {
            this.letterTypeOptions = [
                { label: 'Non-Standard', value: 'Non-Standard' }
            ];
        } else if (this.disposition_new === 'Pending') {
            this.letterTypeOptions = [];
        }
    }

    // Update the Letter Type options based on Disposition selection
    // updateLetterTypeOptions() {
    //     if (this.disposition === 'Approved') {
    //         this.letterTypeOptions = [
    //             { label: 'Official Business', value: 'official_business' },
    //             { label: 'Non-Standard Letter', value: 'non_standard' }
    //         ];
    //     } else if (this.disposition === 'Denied') {
    //         this.letterTypeOptions = [
    //             { label: 'Denial (short)', value: 'denial_short' },
    //             { label: 'Denial (long)', value: 'denial_long' }
    //         ];
    //     } else if (this.disposition === 'Notice') {
    //         this.letterTypeOptions = [
    //             { label: 'Non-Standard Letter', value: 'non_standard' }
    //         ];
    //     } else if (this.disposition === 'Pending') {
    //         this.letterTypeOptions = [];
    //     }
    // }

    // Subscribe to the message channel to receive isReadOnly state
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                EDIT_MODE_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }

        // Subscribe to the DispositionsMessageChannel
        // if (!this.subscriptionDisposition) {
        //     this.subscriptionDisposition = subscribe(
        //         this.messageContext,
        //         DISPOSITIONS_CHANNEL,
        //         (message) => this.handleDispositionChange(message)
        //     );
        // }
    }

    // Handle disposition change from SotsUseStateSeal component
    // handleDispositionChange(message) {
    //     if (message.disposition) {
    //         this.disposition = message.disposition;
    //         this.updateLetterTypeOptions(); // Update letter type options based on the disposition
    //     }
    // }

    // Handle the message from the EditModeMessageChannel
    handleMessage(message) {
        if (message.isReadOnly !== undefined) {
            this.isReadOnly = !message.isReadOnly; // Update isReadOnly based on the message
        }
    }

    // Publish the field changes to the new validation status message channel
    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value;

        // Check if all fields have valid values
        const isValid = this.signedBy && this.letterType && (this.wetSignature === 'Yes' || this.wetSignature === 'No');

        // Publish only if all fields are valid
        if (isValid) {
            const payload = {
                field: name,
                value: value,
                isValid: true // Send overall form validity status
            };

            // Publish the change to the ValidationStatusMessageChannel
            publish(this.messageContext, VALIDATION_STATUS_CHANNEL, payload);
        } else {
            console.warn('Form data not valid, not publishing.');
        }
    }

    // Get method to control the read-only state of the fields dynamically
    get isFieldReadOnly() {
        return this.isReadOnly; // Use this to bind fields' read-only state in the template
    }

    // Dynamically determine which radio button should be checked for Wet Signature (Yes/No)
    get isWetSignatureYes() {
        return this.wetSignature === 'Yes'; // Check if wetSignature is 'Yes'
    }

    get isWetSignatureNo() {
        return this.wetSignature === 'No'; // Check if wetSignature is 'No'
    }

    get isSignedByInvalid() {
        return !this.signedBy && this.signedbyError;
    }

    get signedByErrorClass() {
        return this.isSignedByInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isLetterTypenvalid() {
        return !this.letterType && this.signedbyError;
    }

    get letterTypeErrorClass() {
        return this.isLetterTypenvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isWetSignInvalid() {
        return !this.wetSignature && this.signedbyError;
    }

    get wetSignErrorClass() {
        return this.isWetSignInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

}