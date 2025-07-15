import { LightningElement, api, track, wire } from 'lwc';


export default class PersonalInformationStateSeal extends LightningElement {
    // Public properties exposed to Flow
    @api prefix = '';
    @api lastName = '';
    @api middleInitial = '';
    @api firstName = '';
    @api suffix = '';
    @api dob = null;
    @api title = '';
    @api entity = '';
    @api phoneNumber = '';
    @api email = '';
    @api esq = false; // Add esq checkbox API property
    @api showError = false;

    // Property to control read-only fields
    @api isReadOnly = false;

    

    // Handle input change and update field values dynamically
    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;

        // Update value for the checkbox based on checked attribute
        if (field === 'esq') {
            this[field] = event.target.checked;
        } else {
            this[field] = event.target.value;
        }
    }
    handleKeyPress(event) {
        // Only allow numeric input (0-9)
        const charCode = event.which ? event.which : event.keyCode;
    
        // Allow only numbers (key codes 48-57 for digits)
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();  // Prevent the keypress if it's not a number
        }
    }

    // Combobox options for Prefix and Suffix
    get prefixOptions() {
        return [
            { label: 'Mr.', value: 'Mr' },
            { label: 'Mrs.', value: 'Mrs' },
            { label: 'Ms.', value: 'Ms' },
            { label: 'Dr.', value: 'Dr' }
        ];
    }

    get suffixOptions() {
        return [
            { label: 'Jr.', value: 'Jr' },
            { label: 'Sr.', value: 'Sr' },
            { label: 'II', value: 'II' },
            { label: 'III', value: 'III' }
        ];
    }

    // Options for ESQ checkbox
    get esqOption() {
        return [
            { label: 'ESQ.', value: 'esq' }
        ];
    }

    // Get method to control the read-only state of the fields dynamically
    get isFieldReadOnly() {
        return this.isReadOnly;
    }
    //field validation

    get isFirstNameInvalid() {
        return !this.firstName && this.showError;

    }

    get isLastNameInvalid() {
        return !this.lastName && this.showError;
    }

    get isDobInvalid(){
        return !this.dob && this.showError;
    }

    get isEmailInvalid() {
        return !this.email && this.showError;
    }

    get isPhoneNumberInvalid() {
        return !this.phoneNumber && this.showError;
    }

    get firstNameErrorClass() {
        return this.isFirstNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get lastNameErrorClass() {
        return this.isLastNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get dobErrorClass(){
        return this.isDobInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get emailErrorClass() {
        return this.isEmailInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get phoneNumberErrorClass() {
        return this.isPhoneNumberInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

}