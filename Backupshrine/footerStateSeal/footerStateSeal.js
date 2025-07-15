import { LightningElement, api, wire, track } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import VALIDATION_STATUS_CHANNEL from '@salesforce/messageChannel/ValidationStatusMessageChannel__c'; // Import the new channel
import CLOSE_MODAL_CHANNEL from '@salesforce/messageChannel/CloseModalMessageChannel__c'; // New LMS Channel
import updateIndividualApplication from '@salesforce/apex/StateSealApplicationController.updateIndividualApplication'; // Import the updated Apex method

export default class FooterStateSeal extends LightningElement {
    @api availableActions = []; // This is required for Flow navigation
    @api recordId; // Existing record ID for the Individual Application
    @api buttonsEnable = false;
    @api previousEnabled = false;
    @api requestFor;
    @api isAddRequestAction = false;
    @api isLastScreen = false;
    // Variables to store field values
    @api signedBy = '';
    @api letterType = '';
    @api wetSignature = '';
    isValid = false; // Track form validity

    @track isFlowModalOpen = false; // Tracks the modal state
    @track flowInputVariables = []; // Stores flow input variables

    // Track the subscription to the message channel
    subscription = null;

    // Wire the MessageContext for Lightning Message Service
    @wire(MessageContext)
    messageContext;

    // Subscribe to the message channel when the component is initialized
    connectedCallback() {
        this.subscribeToFieldChanges();
    }

   // Subscribe to the new message channel to receive field change data (including initial load)
    subscribeToFieldChanges() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                VALIDATION_STATUS_CHANNEL,
                (message) => this.handleFieldChange(message) // Will handle both initial load and field changes
            );
        }
    }

    // Handle the field changes (including initial values on load)
    handleFieldChange(message) {
        const { field, value, isValid } = message;

        // Store the field values for future use
        if (field === 'signedBy') {
            this.signedBy = value;
        } else if (field === 'letterType') {
            this.letterType = value;
        } else if (field === 'wetSignature') {
            this.wetSignature = value;
        }

        // Store the form validity status (initial load or change)
        this.isValid = isValid;

        // Enable or disable the buttons based on form validity
        this.buttonsEnable = this.isValid;

        console.log(`Stored Field: ${field}, Value: ${value}, Valid: ${isValid}`);
    }

    // Update existing record on button click
    async updateApplicationData() {
        try {
            // Wait for the record to be updated before proceeding
            await updateIndividualApplication({
                recordId: this.recordId, // Existing record ID to update
                signedBy: this.signedBy,
                letterType: this.letterType,
                wetSignature: this.wetSignature
            });

            console.log('Record updated successfully');
            return true;
        } catch (error) {
            console.error('Error updating record:', error);
            return false;
        }
    }

    // Handle print letter action
    async handlePrintLetter() {
        console.log('Printing Letter');

        // First, update the application record and wait for it to complete
        const isUpdated = await this.updateApplicationData();

        console.log(this.signedBy);

        // If the record was updated successfully, proceed with PDF generation
        if (isUpdated) {
            const pdfgenerator = this.template.querySelector('c-pdf-generator');
            if (pdfgenerator) {
                pdfgenerator.generateLetter(this.recordId, this.letterType, this.wetSignature, this.signedBy); // Pass the recordId to the child component
            } else {
                console.error('PDF generator component not found');
            }
        } else {
            console.error('Record update failed, cannot proceed with PDF generation');
        }
    }

    handlePrintEnvelope() {
        console.log('Printing Envelope');

        // Handle PDF generation
        const pdfgenerator = this.template.querySelector('c-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.generateEnvelope(this.recordId); // Pass the recordId to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

    handleSendEmail() {
        console.log('Send Email button clicked');
        
        // Set flow input variables
        this.flowInputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
        
        // Open the modal for the flow
        this.isFlowModalOpen = true;
    }
    handleFlowStatusChange(event) {
        // Handle flow status changes (e.g., close the modal when the flow finishes)
        if (event.detail.status === 'FINISHED') {
            this.isFlowModalOpen = false;
        }
    }

    handleCloseFlowModal() {
        this.isFlowModalOpen = false; // Close the modal
    }

    handleNext() {
        if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            console.log('before Step');
        }
        else if (this.availableActions.find((action) => action === "FINISH")) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);

            console.log('Final Step');
        }
    }

    handleNextAndClose(){
        if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            console.log('before Step');
        }

        if (this.isLastScreen) {
            this.closeModal();
        }
    }

    // Close the modal by publishing a message via LMS
    closeModal() {
        const payload = { closeModal: true };
        publish(this.messageContext, CLOSE_MODAL_CHANNEL, payload);
        console.log('Close modal message sent');
    }

    handleBack() {
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    handlePrevious() {
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    // Getters to control button enable/disable state
    get isActionDisabled() {
        return !this.buttonsEnable; // Disable buttons if form is invalid
    }

    get isPreviousDisabled() {
        return this.previousEnabled; // Disable buttons if form is in the first step
    }
}