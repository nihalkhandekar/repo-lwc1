import { track } from 'lwc';
import LightningModal from 'lightning/modal';
import getDistrictRecordTypes from '@salesforce/apex/RedistrictingController.getDistrictRecordTypes';
import SotsCss from '@salesforce/resourceUrl/SotsCss';
import modalStateSealRequest from '@salesforce/resourceUrl/modalStateSealRequest';
import addDistrict from '@salesforce/apex/RedistrictingController.addDistrict';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PublicOfficialRedistrictingModal extends LightningModal {
    @track districtOptions = [];  // Holds the record type options for District
    @track formData = {           // Holds the form data
        district: '',             // Selected District Type
        districtNumber: ''        // Entered District Number
    };
    @track isReadOnly = true;     // To disable the 'Add Official' button initially

    connectedCallback() {
        // Push state to history when modal opens
        history.pushState({ modalOpen: true }, '');
        window.addEventListener('popstate', this.handleBackButton.bind(this));

        // Load external styles
        Promise.all([
            loadStyle(this, modalStateSealRequest),
            loadStyle(this, SotsCss)
        ])
            .then(() => console.log('CSS loaded successfully'))
            .catch(error => console.error('Error loading CSS:', error));

        this.fetchDistrictRecordTypes();
    }

    disconnectedCallback() {
        // Remove the listener for `popstate` event
        window.removeEventListener('popstate', this.handleBackButton.bind(this));
    }

    handleBackButton(event) {
        if (history.state && history.state.modalOpen) {
            // Close modal and prevent default navigation
            this.closeModal();
            event.preventDefault();
        }
    }

    closeModal() {
        // Go back in history and close the modal
        //history.back(); // Moves the browser state back
        this.close(); // Closes the Lightning Modal
    }

    // Fetch Record Types for District__c from the Apex controller
    fetchDistrictRecordTypes() {
        getDistrictRecordTypes()
            .then(result => {
                // Map the result to label-value pairs for combobox options
                this.districtOptions = result.map(rtName => {
                    return { label: rtName, value: rtName };
                });
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load district types', 'error');
                console.error('Error fetching district types:', error);
            });
    }

    // Handle input change from the form fields
    handleInputChange(event) {
        const { name, value } = event.target;
        this.formData[name] = value;

        // Enable the "Add Official" button only when all fields are filled
        this.isReadOnly = !(this.formData.district && this.formData.districtNumber);
    }

    validateInputs() {
        let allValid = true;
        let missingFields = [];
        
        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-input-address');
    
        inputComponents.forEach(inputCmp => {
            // Skip validation for 'endTerm' and 'startTerm' if 'indefiniteTerm' is checked
            if ((inputCmp.name === 'endTerm' || inputCmp.name === 'startTerm') && this.formData.indefiniteTerm) {
                return;
            }
            
            inputCmp.reportValidity();
            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label);
            }
        });
        
        if (!allValid) {
            const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
            this.showToast('Error', message, 'error');
        }
        
        return allValid;
    }

    // Handle the submission of the form when 'Add Official' is clicked
    handleAdd() {
        const isValid = this.validateInputs();


        // Validate the form first
        if (isValid) {
            const { district, districtNumber } = this.formData;

            // Call the Apex method to add the district
            addDistrict({ districtNumber, recordTypeName: district })
                .then(result => {
                    if (result === 'Already Exists') {
                        this.showToast('Error', 'District already exists', 'error');
                    } else if (result === 'Success') {
                        this.showToast('Success', 'District added successfully', 'success');
                        this.closeModal(); // Close the modal after successful addition
                    } else {
                        this.showToast('Error', result, 'error'); // Any other error message from the server
                    }
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to add district', 'error');
                    console.error('Error adding district:', error);
                });
        }


       
    }

    restrictCongressionalKeyInput(event) {
        // Key code references
        const key = event.key;
    
        // Allow only numbers (0-9), spaces, backspace, arrow keys, delete, and tab
        const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
        const isNumber = /^\d$/.test(key);  // Check if the pressed key is a number
    
        // Block any key that is not a number or space, or one of the valid keys
        if (!isNumber && key !== ' ' && !validKeys.includes(key)) {
            event.preventDefault();
        }
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