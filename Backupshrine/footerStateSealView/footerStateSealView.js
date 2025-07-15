import { LightningElement, api, wire, track } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { subscribe, MessageContext } from 'lightning/messageService';
import VALIDATION_STATUS_CHANNEL from '@salesforce/messageChannel/ValidationStatusMessageChannel__c'; // Import the new channel


export default class FooterStateSeal extends LightningElement {
  @api availableActions = []; // This is required for Flow navigation
  @api recordId; // Existing record ID for the Individual Application
  @api buttonsEnable = false;
  @api requestFor;
  @api previousEnabled = false;

  @track isFlowModalOpen = false; // Tracks the modal state
  @track flowInputVariables = []; // Stores flow input variables

  // Variables to store field values
  signedBy = '';
  letterType = '';
  wetSignature = '';
  isValid = false; // Track form validity

  // Track the subscription to the message channel
  subscription = null;

  // Wire the MessageContext for Lightning Message Service
  @wire(MessageContext)
  messageContext;

  // Subscribe to the message channel when the component is initialized
  connectedCallback() {
      this.subscribeToFieldChanges();
  }

  // Subscribe to the new message channel to receive field change data
  subscribeToFieldChanges() {
      if (!this.subscription) {
          this.subscription = subscribe(
              this.messageContext,
              VALIDATION_STATUS_CHANNEL,
              (message) => this.handleFieldChange(message)
          );
      }
  }

  // Handle the field changes when received
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

      // Store the form validity status
      this.isValid = isValid;

      // Enable or disable the buttons based on form validity
      this.buttonsEnable = this.isValid;

      console.log(`Stored Field: ${field}, Value: ${value}, Valid: ${isValid}`);
  }

    // Handle print letter action
    handlePrintLetter() {
        console.log('Printing Letter');

        const pdfgenerator = this.template.querySelector('c-pdf-generator');
            if (pdfgenerator) {
                pdfgenerator.viewGenerateLetter(this.recordId);  // Pass the recordId to the child component
            } else {
                console.error('PDF generator component not found');
            }
    }


  handlePrintEnvelope() {
      console.log('Printing Envelope');
            // Handle PDF generation
      const pdfgenerator = this.template.querySelector('c-pdf-generator');
      if (pdfgenerator) {
          pdfgenerator.viewGenerateEnvelope(this.recordId);  // Pass the recordId to the child component
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
      }

      if (this.availableActions.find((action) => action === "FINISH")) {
        const navigateFinishEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(navigateFinishEvent);
    }
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

  get isPreviousDisabled(){
    return this.previousEnabled; // Disable buttons if form is in first step
  }
}