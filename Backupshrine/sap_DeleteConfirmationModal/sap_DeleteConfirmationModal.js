import {  api} from 'lwc';
import LightningModal from 'lightning/modal';
import sap_SotsCss from '@salesforce/resourceUrl/sap_SotsCss';
import sap_deleteModal from '@salesforce/resourceUrl/sap_deleteModal';
import deleteOffice from '@salesforce/apex/SAP_ElectionOfficeController.deleteOffice';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class DeleteConfirmationModal extends LightningModal {
    @api officeType;  // Type of office passed into the modal (e.g., 'District', 'Office', etc.)
    @api recordId;    // ID of the record to be deleted (passed from parent component)


    // Method to run when the component is loaded
    connectedCallback() {
        Promise.all([
            loadStyle(this, sap_deleteModal),
            loadStyle(this, sap_SotsCss)
        ])
        .then(() => {
            console.log('Both CSS files loaded successfully');
        })
        .catch(error => {
            console.error('Error loading CSS files:', error);
        });

    }

    handleDelete(){
        deleteOffice({ recordId: this.recordId })
        .then(() => {
            // Handle successful deletion, e.g., show a toast message
            this.showToast('Success', 'Record deleted successfully', 'success');
            this.close();
        })
        .catch(error => {
            // Handle error
            console.log(error);
        });

    }

    closeModal(){
        this.close();
    }

   // Show Toast Message Utility Method
   showToast(title, message, variant) {
    const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
    if (toast) {
        toast.showToast({
            title: title,
            message: message,
            variant: variant,
        });
    }
}
}