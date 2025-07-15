import { track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import sap_SotsCss from '@salesforce/resourceUrl/sap_SotsCss';
import sap_deleteModal from '@salesforce/resourceUrl/sap_deleteModal';
import sap_FinsysSendEmailModal from 'c/sap_FinsysSendEmailModal';
import createWorkOrder from '@salesforce/apex/SAP_FinsysWorkOrderController.createWorkOrder';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class DeleteConfirmationModal extends NavigationMixin(LightningModal) {
  @api workOrderData;
  @track isSucess = false;
  @track recordId = '';
  @track sqNumber = '';
  @track workOrderDetails = {};
  @track saveTheData = false;

  // Load styles when the component is loaded
  connectedCallback() {
    Promise.all([loadStyle(this, sap_deleteModal), loadStyle(this, sap_SotsCss)])
      .then(() => {
        console.log('Both CSS files loaded successfully');
        console.log('work order data is ' + this.workOrderData);
      })
      .catch((error) => {
        console.error('Error loading CSS files:', error);
      });
  }

  sucessMode(sequenceNumber, workOrderDetails) {
    this.sqNumber = sequenceNumber;
    this.workOrderDetails = workOrderDetails;
    this.isSucess = true;
  }

  handlePrintPaymentReceipt() {
    try {
      const pdfgenerator = this.template.querySelector('c-sap_-finsys-pdf-generator');
      if (pdfgenerator) {
        const blob = pdfgenerator.generatePaymentInvoice(this.recordId, '');
        console.log(blob);
      } else {
        console.error('PDF generator component not found.');
      }
    } catch (error) {
      console.error('Error generating payment document:', error);
    }
  }

  handleSendEmail() {
    console.log('Send Email Modal');
    sap_FinsysSendEmailModal.open({
      size: 'small',
      description: "Accessible description of modal's purpose",
      recordId: this.recordId
    });
    this.closeModal();
  }

  handleSave() {
    try {
      // Parse work order data passed from the parent
      const workOrderData = JSON.parse(this.workOrderData);
      console.log('@@@', this.workOrderData);
      this.saveTheData = true;
      // Call Apex to create the work order
      createWorkOrder({ workOrderDataJson: JSON.stringify(workOrderData) })
        .then((result) => {
          console.log('Work Order Created Successfully:', result);

          // Extract required data from the result
          const sequenceNumber = result.sequenceNumber;
          const workOrderId = result.id;
          this.recordId = workOrderId;

          if (result.sequenceNumber && result.id) this.saveTheData = false;

          // Update internal modal state (optional)
          this.sucessMode(sequenceNumber);

          // Show a success toast message
          this.showToast('Success', `Work Order #${sequenceNumber} created successfully!`, 'success');
        })
        .catch((error) => {
          console.error('Error saving record:', error);
          let errorMessage = 'Error processing the request. Please try again.';

          if (error && error.body) {
            if (error.body.message) {
              // Standard error message
              errorMessage = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
              // Extract first page error message
              errorMessage = error.body.pageErrors[0].message;
            } else if (error.body.fieldErrors) {
              // Extract first field error message if available
              for (let field in error.body.fieldErrors) {
                if (error.body.fieldErrors[field].length > 0) {
                  errorMessage = error.body.fieldErrors[field][0].message;
                  break;
                }
              }
            } else if (error.body.actions && error.body.actions.length > 0) {
              let actionError = error.body.actions[0].error;
              if (actionError && actionError.length > 0) {
                // Extract 'exceptionType' error messages
                if (actionError[0].message) {
                  errorMessage = actionError[0].message;
                } else if (actionError[0].pageErrors && actionError[0].pageErrors.length > 0) {
                  errorMessage = actionError[0].pageErrors[0].message;
                }
              }
            }
          }

          this.showToast('Work Order ', errorMessage, 'error');
        });
    } catch (error) {
      // Handle errors during data parsing or other logic
      console.error('Error processing work order data:', error);

      // Show an error toast message
      this.showToast('Error', 'Failed to process the work order data.', 'error');
    }
  }

  // Close the modal
  closeModal() {
    this.close(this.isSucess);
  }
  // Show Toast Message Utility Method
  showToast(title, message, variant) {
    const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
    if (toast) {
      toast.showToast({
        title: title,
        message: message,
        variant: variant
      });
    }
  }
}