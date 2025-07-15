import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class AddContactButton extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;

    handleAddContact() {
        // Logic for adding a contact goes here
        console.log('Add Contact button clicked');
        this.isModalOpen = true;
        console.log('model is '+this.isModalOpen);
        
    }

    closeModal() {
        // Close the modal by setting isModalOpen to false
        this.isModalOpen = false;
    }

    handleStatusChange(event) {
        console.log('flow is started');
        
        // Close the modal when the flow finishes
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            this.closeModal();
        }
    }
}