import {  track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import SotsCss from '@salesforce/resourceUrl/SotsCss';
import deleteModal from '@salesforce/resourceUrl/deleteModal';
import finsysSendEmailModal from 'c/finsysSendEmailModal';
import createWorkOrder from '@salesforce/apex/FinsysWorkOrderController.createWorkOrder';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class DeleteConfirmationModal extends NavigationMixin(LightningModal) {
    @api workOrderData; // JSON string of work order data passed from parent
    @track isSucess = false;
    @track recordId = '';
    @track sqNumber = '';
    @track workOrderDetails = {}; // Store returned work order data
    @track saveTheData = false;

    // Load styles when the component is loaded
    connectedCallback() {
        Promise.all([
            loadStyle(this, deleteModal),
            loadStyle(this, SotsCss)
        ])
        .then(() => {
            console.log('Both CSS files loaded successfully');
            console.log('work order data is '+ this.workOrderData);

        })
        .catch(error => {
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
          const pdfgenerator = this.template.querySelector(
            "c-finsys-pdf-generator"
          );
          if (pdfgenerator) {
            const blob = pdfgenerator.generatePaymentInvoice(this.recordId, "");
            console.log(blob);

          } else {
            console.error("PDF generator component not found.");
          }
        } catch (error) {
          console.error("Error generating payment document:", error);
        }
      }

    handleSendEmail() {
        console.log('Send Email Modal');
         finsysSendEmailModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: this.recordId
        });
        this.closeModal();
    }

    handleSave() {
        try {
            // Parse work order data passed from the parent
            const workOrderData = JSON.parse(this.workOrderData);
            this.saveTheData = true;
            // Call Apex to create the work order
            createWorkOrder({ workOrderDataJson: JSON.stringify(workOrderData) })
                .then((result) => {
                    console.log('Work Order Created Successfully:', result);

                    // Extract required data from the result
                    const sequenceNumber = result.sequenceNumber;
                    const workOrderId = result.id;
                    this.recordId = workOrderId;

                    if(result.sequenceNumber && result.id)
                        this.saveTheData = false;


                    // Update internal modal state (optional)
                    this.sucessMode(sequenceNumber);


                    // Show a success toast message
                    this.showToast('Success', `Work Order #${sequenceNumber} created successfully!`, 'success');
                })
                .catch((error) => {
                    // Handle errors from the Apex method
                    console.error('Error creating work order:', error);

                    // Extract the error message
                    const errorMessage = error.body?.message || 'An unknown error occurred.';

                    this.saveTheData= false;

                    // Show an error toast message
                    this.showToast('Error', errorMessage, 'error');
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
        const toast = this.template.querySelector('c-toast-message-state-modal');
        if (toast) {
            toast.showToast({
                title: title,
                message: message,
                variant: variant,
            });
        }
    }
}