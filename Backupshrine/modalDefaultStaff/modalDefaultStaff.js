import { track } from 'lwc';
import LightningModal from 'lightning/modal';
import modalDefaultStateStaff from '@salesforce/resourceUrl/modalDefaultStateStaff';
import {loadStyle } from 'lightning/platformResourceLoader';
import searchContacts from '@salesforce/apex/MaintainStaffDataController.searchContacts';
import updateContact from '@salesforce/apex/MaintainStaffDataController.updateContact';

export default class ModalDefaultStaff extends LightningModal {
    @track searchTerm = '';
    @track contacts = [];
    @track error;
    @track selectedContactId = '';
    @track selectedOption = 'State Seal';

    connectedCallback() {

        loadStyle(this, modalDefaultStateStaff)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

  }
    handleCancel() {
        this.close();
    }

    handleStaffNameChange(event) {
        this.searchTerm = event.target.value;

        if (this.searchTerm.length >= 2) {
            searchContacts({ searchTerm: this.searchTerm })
                .then((result) => {
                    this.contacts = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.contacts = [];
                });
        } else {
            this.contacts = [];
        }
    }

    handleApplicationChange(event) {
        this.selectedOption = event.target.value;
        console.log('this.selectedOption', this.selectedOption);
    }

    // Method to handle when a contact is selected
    handleContactSelect(event) {
        this.selectedContactId = event.target.dataset.id;
        const selectedContactName = event.target.dataset.name;
        this.searchTerm = selectedContactName;
        this.contacts = [];
    }

    handleAdd() {

        if (this.selectedContactId && this.selectedOption) {

            // Call the Apex method to update the contact
            updateContact({ contactId: this.selectedContactId, selectedOption: this.selectedOption })
                .then(() => {
                    console.log('Contact updated successfully.');
                    const passer = this.template.querySelector('c-event-passer');
                    passer.passEvent(new CustomEvent('confirmevent', {
                        bubbles: true,
                        composed: true,
                        detail: { 'message': 'confirm' },
                    }));
                    this.close(); // Close the modal after updating
                })
                .catch(error => {
                    console.error('Error updating contact:', error);
                });
        } else {
            console.error('Please select a contact and an option.');
            console.log('selectedContactId:', this.selectedContactId, 'selectedOption:', this.selectedOption);
        }
    }

    dispatchConfirmEvent() {
        const passer = this.template.querySelector('c-event-passer');
        passer.passEvent(new CustomEvent('confirmevent', {
            bubbles: true,
            composed: true,
            detail: { 'message': 'confirm' },
        }));

        this.handleCancel();
    }
}