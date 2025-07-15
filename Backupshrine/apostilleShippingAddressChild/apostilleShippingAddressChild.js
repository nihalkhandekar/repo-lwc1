import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SotsCss from "@salesforce/resourceUrl/SotsCss";

export default class ApostilleShippingAddressChild extends LightningElement {
    @api sameAsContactAddress = false;
    @api sameAsContactAddressString = 'No'; // Default value
    @api businessName = '';
    @api firstName = '';
    @api lastName = '';
    @api addressLine1 = '';
    @api suite = '';
    @api city = '';
    @api state = '';
    @api zipCode = '';
    @api country = '';
    @api readOnly = false;
    @api showError = false;
    isLoading = true;

    hasUserEnteredData = false;  // Flag to track if user has entered data
    lastReceivedMessage = null;

    cityOptions = [];
    stateOptions = [];
    countryOptions = [];

    // Dropdown options
    countryOptions = [
        { label: 'United States', value: 'United States' }
    ];

    stateOptions = [
        { label: 'Alabama', value: 'AL' },
        { label: 'Alaska', value: 'AK' },
        { label: 'California', value: 'CA' },
        { label: 'Florida', value: 'FL' },
        { label: 'Texas', value: 'TX' }
    ];

    cityOptions = [
        { label: 'New York', value: 'New York' },
        { label: 'Los Angeles', value: 'Los Angeles' },
        { label: 'Chicago', value: 'Chicago' },
        { label: 'Houston', value: 'Houston' },
        { label: 'Phoenix', value: 'Phoenix' }
    ];


     connectedCallback() {
        Promise.all([ // Load the CSS file
            loadStyle(this,SotsCss)
        ]).then(() => {
            this.isLoading = false; 
            console.log('CSS file loaded successfully');
        }).catch(error => {
            this.isLoading = false; 
            console.error('Error loading CSS file:', error);
        });
        // Check if the fields should be populated or cleared based on the sameAsContactAddressString value
        if (this.sameAsContactAddressString === 'Yes' && this.lastReceivedMessage) {
            // If the message was received, populate the fields
            this.updateAddressFields(this.lastReceivedMessage);
        } else if (this.sameAsContactAddressString === 'No' && !readOnly) {
            // If the user chooses 'No', clear the fields
            this.clearAddressFields();
         } 
        
         
       
    }

    get businessNamePlaceholder() {
        return this.readOnly ? '' : 'e.g., Acme Corporation';
    }
    get addressLine1Placeholder(){
        return this.readOnly ? '' : '123 Main St';
    }
    get suitePlaceholder() {
        return this.readOnly ? '' : 'e.g., Apt 4B, Suite 200, 2nd Floor';
    }
    get ZipPlaceholder(){
        return this.readOnly ? '' : 'e.g., 10001';
    }



    validateForm() {
        const allInputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
        console.log('allInput....',allInputs);
        
        let isValid = true;
    
        allInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });
    
        return isValid;
    }
    

    handleSameAddress(event) {
        this.sameAsContactAddressString = event.target.value;  // Update the value based on the user's selection
    
        if (this.sameAsContactAddressString === 'Yes' && this.lastReceivedMessage) {
            // If the user selects 'Yes' and we have received an address from the message channel
        } else if (this.sameAsContactAddressString === 'No') {
            // If "No" is selected
            if (this.hasUserEnteredData) {
                // Clear fields only if user has entered data
                this.clearAddressFields();
            } 
        }
    }
    

    clearAddressFields() {
        this.firstName = '';
        this.lastName = '';
        this.addressLine1 = '';
        this.suite = '';
        this.city = '';
        this.state = '';
        this.zipCode = '';
        this.country = '';
        this.businessName = '';

        this.hasUserEnteredData = false; // Reset the flag indicating no data has been entered
    }

    get issameAsContactAddressStringChecked() {
        return this.sameAsContactAddressString === 'Yes';
        //return this.sameAsContactAddress;
    }

    get isNotsameAsContactAddressStringChecked() {
        return this.sameAsContactAddressString === 'No';
        //return !this.sameAsContactAddress;
    }

    get isFieldReadOnly() {
        // Fields are read-only if either `readOnly` is true or "Yes" is selected
        return this.readOnly || this.sameAsContactAddressString === 'Yes';
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field) {
            this[field] = event.target.value;
            this.hasUserEnteredData = true; // Mark data as entered when input changes
            console.log('field  == ' + field + ' value is -- ' + this[field]);
            this.dispatchFormChangeEvent();
        }
    }

    dispatchFormChangeEvent() {
        const formData = {
            firstName: this.firstName,
            lastName: this.lastName,
            businessName: this.businessName,
            addressLine1: this.addressLine1,
            suite: this.suite,
            city: this.city,
            state: this.state,
            zipCode: this.zipCode,
            country: this.country,
            sameAsContactAddress: this.sameAsContactAddress,
            sameAsContactAddressString: this.sameAsContactAddressString
        };
        this.dispatchEvent(new CustomEvent('formchange', { detail: formData }));
    }

}