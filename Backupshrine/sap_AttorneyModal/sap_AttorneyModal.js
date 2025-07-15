import { LightningElement,api,track,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import SUFFIX_FIELD from '@salesforce/schema/Contact.SAP_Suffix__c';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
import fetchAttorneyData from '@salesforce/apex/SAP_AttorneyController.fetchAttorneyData';
import updateAttorneyData from '@salesforce/apex/SAP_AttorneyController.updateAttorneyData';

export default class AttorneyModal extends LightningModal {

@track isReadOnly= false;
@api mode = '';
@api recordId;
@track idofrecord;

@api prefix;
@track prefixSelectOptions = [];
@api lastName;
@api firstName;
@api middleName;
@api suffix;
@api phone;

@api address1 = '';
@api address2;
@api city;
@api state;
@api zipCode;
@api country;
addressFieldError = false; // To track if there's an error
@track validationError;
@track suffixSelectOptions = [];

connectedCallback() {
    loadStyle(this, sap_stateExtradition)
        .then(() => {
            console.log('First CSS file (sap_stateExtradition) loaded successfully');
        })
        .catch(error => console.error('Error loading CSS file:', error));

    if (this.recordId) {
        this.idofrecord = this.recordId;
        this.fetchExistingData(); // Fetch contact data if editing an existing record
    }

    if (this.mode === 'view') {
        this.isReadOnly = true;
    } else if (!this.recordId) {
        this.isReadOnly = false;
    }

}

async fetchExistingData() {
    fetchAttorneyData({ recordId: this.idofrecord })
        .then((data) => {
            console.log('Attorney Data coming from Apex:', JSON.stringify(data));
            this.prefix = data.records[0]?.Salutation || ''; 
            this.suffix = data.records[0]?.Suffix || ''; 
            
            this.lastName = data.records[0]?.LastName || ''; 
            this.firstName = data.records[0]?.FirstName || ''; 
            this.middleName = data.records[0]?.MiddleName || ''; 
            this.phone = data.records[0]?.Phone || ''; 
            
            this.address1 = data.records[0]?.MailingStreet || ''; 
            this.address2 = data.records[0]?.SAP_MailingAddress2__c || ''; 
            this.city = data.records[0]?.MailingCity || '';  
            this.state = data.records[0]?.MailingState || '';  
            this.country = data.records[0]?.MailingCountry || '';  
            this.zipCode = data.records[0]?.MailingPostalCode || '';  
            
        })
        .catch((error) => {
            console.error('Error fetching data:', error);
        });
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SUFFIX_FIELD
    })
    suffixPicklistValues({ error, data }) {
        if (data) {
            this.suffixSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.suffixSelectOptions = [];
        }
    }

    async handleAdd() {
        const isValid = this.validateInputs();
        if (isValid) {
            try {
                const data = {
                    prefix: this.prefix,
                    firstname: this.firstName,
                    middlename: this.middleName,
                    lastname: this.lastName,
                    suffix: this.suffix,
                    phone: this.phone,
                    address1: this.address1,
                    address2: this.address2,
                    city: this.city,
                    state: this.state,
                    pincode: this.zipCode,
                    country: this.country,
                    recordId: this.idofrecord
                };
                await updateAttorneyData({data});
                
                console.log('Record saved successfully');
                if (this.idofrecord) {
                    this.showToast('Attorney Inspector', 'Request updated successfully!', 'success');
                }
                this.switchToViewMode(this.recordId);

                if (!this.idofrecord) {
                    this.showToast('Attorney Inspector', 'Request created successfully!', 'success');
                }
                this.switchToViewMode(this.recordId);

            } catch (error) {
                console.error('Error saving record:', error);
                this.showToast('Attorney Inspector', 'Error processing the request. Please try again.', 'error');
            }
        } else {
            console.error('Form is not valid');
        }
    }
    


    @api
switchToViewMode(recordId) {
    this.isReadOnly = true;
    this.mode = 'view';
    console.log('record id of saved: ', recordId);
    

    if (this.recordId) {
        this.idofrecord = this.recordId;
    } else {
        console.error('No record ID found for fetching data.');
    }
    this.fetchExistingData();
}
    
           // Validate input fields
           validateInputs() {
            let allValid = true;
            let missingFields = [];
        
            // Get all input components
            const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group,lightning-input-address');
        
             // Get the address input component
            const addressComponent = this.template.querySelector('lightning-input-address');
            if (!addressComponent.street) {
                allValid = false;
                missingFields.push('Address Line 1 is required');
            }
        
            if (!addressComponent.city) {
                allValid = false;
                missingFields.push('City is required');
            }
        
            if (!addressComponent.province) {
                allValid = false;
                missingFields.push('State is required');
            }
        
            if (!addressComponent.postalCode) {
                allValid = false;
                missingFields.push('Zip Code is required');
            }
            else {
                // Validate ZIP Code format
                const zipCodePattern = /^\d+$/; // Adjust pattern as necessary
                if (!zipCodePattern.test(addressComponent.postalCode)) {
                    allValid = false;
                    missingFields.push('Zip Code can only contain digits');
                }
            }
        
            if (!addressComponent.country) {
                allValid = false;
                missingFields.push('Country is required');
            }
            




            inputComponents.forEach(inputCmp => {
                // Check each input's validity
                inputCmp.reportValidity();
        
                if (!inputCmp.checkValidity()) {
                    allValid = false;
                    missingFields.push(inputCmp.label); 
                }
            });
        
            if (!allValid) {
                // const message = `Please fill in the required fields`;

                const message = missingFields.join('. ');
            
                this.showToast('Error', message, 'error');
                this.addressFieldError = true; // Show error message
            }
            this.addressFieldError = false; // No error

            return allValid;
        }

    get headerText() {
        if (!this.idofrecord) {
            return 'Add New State Attorney Inspector';
        }
        return this.isReadOnly ? 'View State Attorney Inspector  |  ' : 'Edit State Attorney Inspector';
    }

    handleEditClick() {
        this.isReadOnly = false; // Enable editing
    }

    closeModal() {
        this.close();
    }

    closeModalAfterSave() {
        setTimeout(() => {
            this.closeModal();
        }, 1000); 
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SALUTATION_FIELD
    })
    salutationPicklistValues({ error, data }) {
        if (data) {
            this.prefixSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.prefixSelectOptions = [];
        }
    }

handleFieldChange(event) {
    
    const field = event.target.name;
    this[field] = event.target.value;
    this.cellPhone = event.target.value;
    if(field === 'phone') {
        // this.cellPhone = event.target.value;
        const formattedNumber = this.formatPhoneNumber(event.target.value);
        this[field] = formattedNumber;
        event.target.value = formattedNumber;
    }
    
}

handlePhoneKeyDown(event) {
    const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab']; 
    
    // Handle backspace and delete
    if (event.key === 'Backspace' || event.key === 'Delete') {
        const input = event.target;
        const selectionStart = input.selectionStart;
        const selectionEnd = input.selectionEnd;
        const value = input.value;
        const digitsOnly = value.replace(/\D/g, '');

        // Case 1: All text is selected (including Ctrl+A case)
        if (selectionStart === 0 && selectionEnd === value.length) {
            event.preventDefault();
            this.handleFieldChange({
                target: {
                    name: 'phone',
                    value: ''
                }
            });
            return;
        }

        // Case 2: A portion of text is selected
        if (selectionStart !== selectionEnd) {
            event.preventDefault();
            const beforeSelection = value.slice(0, selectionStart).replace(/\D/g, '');
            const afterSelection = value.slice(selectionEnd).replace(/\D/g, '');
            const newValue = beforeSelection + afterSelection;
            
            this.handleFieldChange({
                target: {
                    name: 'phone',
                    value: newValue
                }
            });
            return;
        }

        // Case 3: Regular backspace at a position
        if (event.key === 'Backspace') {
            event.preventDefault();
            const newDigits = digitsOnly.slice(0, -1);
            this.handleFieldChange({
                target: {
                    name: 'phone',
                    value: newDigits
                }
            });
        }
    }
    // Handle non-numeric keys
    else if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
        // Allow Ctrl+A
        if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
            return;
        }
        event.preventDefault(); 
    }
    // Handle numeric input length restriction
    else {
        const currentValue = event.target.value.replace(/\D/g, '');
        if (currentValue.length >= 10 && !allowedKeys.includes(event.key) && !/[0-9]/.test(event.key)) {
            event.preventDefault();
        }
    }
}


formatPhoneNumber(phoneNumberString) {
    let cleaned = phoneNumberString.replace(/\D/g, '');
    cleaned = cleaned.substring(0, 10);
    if (cleaned.length >= 6) {
        return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
    } else if (cleaned.length >= 3) {
        return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
    } else if (cleaned.length > 0) {
        return `(${cleaned}`;
    }
    return '';
}



validateNumericInput(event) {
    const inputValue = String.fromCharCode(event.charCode);
    if (!/^[0-9 ()\-]*$/.test(inputValue) && event.charCode !== 0) {
        event.preventDefault(); 
    }
}



handleAddressChange(event) {
    this.address1 = event.detail.street ? event.detail.street : '';
    this.city = event.detail.city;
    this.address2= event.detail.subpremise;
    this.state = event.detail.province;
    this.zipCode = event.detail.postalCode;
    this.country = event.detail.country;

    const zipCode = event.detail.postalCode;
    const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

        if (!zipCodePattern.test(zipCode)) {
            this.validationError = 'Zipcode format is invalid';
        }else {
            // Clear error and update ZIP Code
            this.validationError = null;
            this.zipCode = zipCode;
        }
}

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