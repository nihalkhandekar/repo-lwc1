import { LightningElement, api, wire } from 'lwc';
import getUserDetailsCityStateCountryOptions from '@salesforce/apex/LoggedInUserController.getUserDetailsCityStateCountryOptions';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import iconCss from "@salesforce/resourceUrl/iconCss";
import SotsCss from "@salesforce/resourceUrl/SotsCss";

export default class ApostilleRequestFormchild extends LightningElement {

    @api recordId = '';
    @api firstName = '';
    @api lastName = '';
    @api organizationName = '';
    @api email = '';
    @api phone = '';
    @api addressLine1 = '';
    @api suite = '';
    @api city = '';
    @api state = '';
    @api zipCode = '';
    @api country = '';
    @api showError = '';
    @api readOnly = false;
    @api showErrora = false;
  
    isLoading = true;
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

  
    // isFormValid() {
    //     // All required fields must be filled out
    //     return this.firstName && this.lastName && this.email && this.phone &&
    //         this.addressLine1 && this.city && this.state && this.zipCode && this.country;
    // }

    connectedCallback() {
        // Load the CSS file
        Promise.all([
            loadStyle(this,iconCss), // Load the CSS file
            loadStyle(this,SotsCss)
        ]).then(() => {
            this.isLoading = false; 
            console.log('CSS file loaded successfully');
        }).catch(error => {
            this.isLoading = false; 
            console.error('Error loading CSS file:', error);
        });

    }


    @wire(getUserDetailsCityStateCountryOptions, { recordId: '$recordId' })
    wiredUserAndCityData({ error, data }) {
        if (data && !this.recordId) {
            // Extracting user details from the wrapper
            const userDetails = data.userDetails;
            if (this.firstName == '') {
                this.firstName = userDetails.Contact.Account.FirstName;
            }
            if (this.lastName == '') {
                this.lastName = userDetails.Contact.Account.LastName;
            }
            if (this.email == '') {
                this.email = userDetails.Contact.Account.Business_Email_Address__c;
            }
            if (this.phone == '') {
                this.phone = userDetails.Contact.Account.Phone;
            }
            if (this.organizationName == '') {
                this.organizationName = userDetails.Contact.Account.Name;
            }
            if (this.addressLine1 == '') {
                this.addressLine1 = userDetails.Contact.Account.BillingStreet;
            }
            if (this.city == '') {
                this.city = userDetails.Contact.Account.BillingCity;
            }
            if (this.state == '') {
                this.state = userDetails.Contact.Account.BillingState;
            }
            if (this.zipCode == '') {
                this.zipCode = userDetails.Contact.Account.BillingPostalCode;
            }
            if (this.country == '') {
                this.country = userDetails.Contact.Account.BillingCountry;
            }            

        } else if (error) {
            console.error('Error fetching user details and city options:', error);
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field) {
            this[field] = event.target.value;

        }
    }


    get isFirstNameInvalid() {
        return !this.firstName && this.showErrora;
    }

    get isLastNameInvalid() {
        return !this.lastName && this.showErrora;
    }

    get isOrganizationNameInvalid() {
        return !this.organizationName && this.showErrora;
    }

    get isEmailInvalid() {
        return !this.email && this.showErrora;
    }

    get isPhoneInvalid() {
        return !this.phone && this.showErrora;
    }

    get isAddressLine1Invalid() {
        return !this.addressLine1 && this.showErrora;
    }

    get isCityInvalid() {
        return !this.city && this.showErrora;
    }

    get isStateInvalid() {
        return !this.state && this.showErrora;
    }

    get isZipCodeInvalid() {
        return !this.zipCode && this.showErrora;
    }

    get isCountryInvalid() {
        return !this.country && this.showErrora;
    }

    get firstNameErrorClass() {
        return this.isFirstNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get lastNameErrorClass() {
        return this.isLastNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get organizationNameErrorClass() {
        return this.isOrganizationNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get emailErrorClass() {
        return this.isEmailInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get phoneErrorClass() {
        return this.isPhoneInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get addressLine1ErrorClass() {
        return this.isAddressLine1Invalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get zipCodeErrorClass() {
        return this.isZipCodeInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get countryErrorClass() {
        return this.isCountryInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

}