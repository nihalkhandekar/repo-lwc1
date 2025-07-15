import { LightningElement, api, wire ,track } from 'lwc';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';
import ADDRESS_MESSAGE_CHANNEL from '@salesforce/messageChannel/AddressMessageChannel__c';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import sap_SotsCss from "@salesforce/resourceUrl/sap_SotsCss";
import HIDE_SHIPPING_CHANNEL from '@salesforce/messageChannel/hideShippingComponent__c';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';

const LANGUAGE_TEXT = 'Language';

export default class ShippingAddressForm extends LightningElement {
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
    @api isValid = false;
    @api formId = 'form1';
    @api isValidValue = '';
    isLoading = true;
    isVisible = true;

    hasUserEnteredData = false;  // Flag to track if user has entered data
    lastReceivedMessage = null;


     /**
     * Check if the component is running in Experience Sites context
     */
     isCommunityContext() {
        return window.location.pathname.includes("/eApostille/");
    }
//labels
@track CurrentLanguage = true; // True means Spanish
 labels={};
 JsonLanguageData;



    // cityOptions = [];
    // stateOptions = [];
    // countryOptions = [];

    provinceOptions = [
        { label: 'California', value: 'CA' },
        { label: 'Texas', value: 'TX' },
        { label: 'Washington', value: 'WA' },
    ];

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

    get getProvinceOptions() {
        return this.provinceOptions;
    }
    get getCountryOptions() {
        return this.countryOptions;
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
        //|| this.sameAsContactAddressString === 'Yes'
        return this.readOnly;
    }

    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
        }).catch(error => console.error('error is there', error));

        // fetch(labelsResourceForLocal)
        //     .then((response) => {
        //         if (response.ok) {
        //             return response.json(); // Parse JSON data
        //         }
        //         throw new Error("Failed to load JSON");
        //     })
        //     .then((data) => {
        //         this.JsonLanguageData = data;
        //         this.labels = this.JsonLanguageData["English"];

        //         // Check if in community context and fetch cached language preference
        //         if (this.isCommunityContext()) {
        //     getCacheValue({ key: LANGUAGE_TEXT })
        //                 .then((result) => {
        //         this.handleLanguageChange(result);
        //     })
        //                 .catch((error) => {
        //                     console.error("Error fetching cached language:", error);
        //     });
        //         }
        //     })
        //     .catch((error) => {
        //         console.error("Error fetching labels:", error);
        //     });



        Promise.all([ // Load the CSS file
            loadStyle(this,sap_SotsCss)
        ]).then(() => {
            this.isLoading = false;
            console.log('CSS file loaded successfully');
        }).catch(error => {
            this.isLoading = false;
            console.error('Error loading CSS file:', error);
        });
        this.subscribeToAddressChannel();
        this.subscribeToValidationChannel();
        this.subscribeForLanguageChangeThrewLMS();
        this.subscribeForHideShippingComponent();
       

        // Check if the fields should be populated or cleared based on the sameAsContactAddressString value
        if (this.sameAsContactAddressString === 'Yes' && this.lastReceivedMessage) {
            // If the message was received, populate the fields
            this.updateAddressFields(this.lastReceivedMessage);
        } else if (this.sameAsContactAddressString === 'No' && !this.readOnly) {
            // If the user chooses 'No', clear the fields
            this.clearAddressFields();
         }




    }

    subscribeForLanguageChangeThrewLMS(){
 // Subscribe to the language message channel
 subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
    this.handleLanguageChange(message);
  });
    }

    subscribeForHideShippingComponent() {
        subscribe(this.messageContext, HIDE_SHIPPING_CHANNEL, (message) => {
            this.handleMessage(message);
          });
    }

    subscribeToValidationChannel() {
        subscribe(
            this.messageContext,
            VALIDATION_CHANNEL,
            (message) => this.handleValidationMessage(message)
        );
    }

    handleMessage(message) {
        if (message.hideShipping !== undefined) {
            this.isVisible = !message.hideShipping;
        }
    }

    // Handle language change
    handleLanguageChange(message) {
        let language;
        if (message.language) {
            language = message.language;

            if(message.language=='English'){
                this.CurrentLanguage=false;
            }
            else if(message.language=='Spanish'){
                this.CurrentLanguage=true;
            }
        }else{
            language = message;

            if(message=='English'){
                this.CurrentLanguage=false;
            }
            else if(message=='Spanish'){
                this.CurrentLanguage=true;
            }
        }
  this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }

    handleValidationMessage(message) {
        if (message.action === 'validate') {
            const isValid = this.validateForm();
            // Publish the validation result back to the navigation buttons
            publish(this.messageContext, VALIDATION_CHANNEL, {
                action: 'validationResult',
                source: this.formId,
                isValid: isValid
            });
        }
    }


    subscribeToAddressChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ADDRESS_MESSAGE_CHANNEL,
            (message) => this.handleAddressMessage(message)
        );
    }

    handleAddressMessage(message) {
        this.lastReceivedMessage = { ...message };

        // Only update the fields if "Yes" is selected
        if (this.sameAsContactAddressString === 'Yes') {
            this.updateAddressFields(message);
        }
    }

    clearValidationErrors() {
        const allInputs = this.template.querySelectorAll('lightning-input, lightning-input-address');
        allInputs.forEach(input => {
            input.setCustomValidity('');
            input.reportValidity();
        });
    }

    handleSameAddress(event) {
        this.sameAsContactAddressString = event.target.value;  // Update the value based on the user's selection

        if (this.sameAsContactAddressString === 'Yes' && this.lastReceivedMessage) {
            // If the user selects 'Yes' and we have received an address from the message channel
            this.updateAddressFields(this.lastReceivedMessage);
            this.clearValidationErrors();
            this.validateForm();
        } else if (this.sameAsContactAddressString === 'No') {
            // If "No" is selected
            if (this.hasUserEnteredData) {
                // Clear fields only if user has entered data
                this.clearAddressFields();
                this.clearValidationErrors();
                this.validateForm();
            }
        }
    }

    updateAddressFields(addressDetails) {
        this.firstName = addressDetails.firstName?.toUpperCase() || '';
        this.lastName = addressDetails.lastName?.toUpperCase() || '';
        this.addressLine1 = addressDetails.addressLine1?.toUpperCase() || '';
        this.suite = addressDetails.suite?.toUpperCase() || '';
        this.city = addressDetails.city?.toUpperCase() || '';
        this.state = addressDetails.state?.toUpperCase() || '';
        this.zipCode = addressDetails.zipCode?.toUpperCase() || '';
        this.country = addressDetails.country?.toUpperCase() || '';
        this.businessName = addressDetails.businessName?.toUpperCase() || '';
        this.hasUserEnteredData = true;
        this.clearValidationErrors();
        this.validateForm();
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

    @api
    validateForm() {
        let isValid = true;

        const inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        // Validate lightning-input-address if present
        const addressInput = this.template.querySelector('lightning-input-address');
        if (addressInput) {
            const addressValid = this.validateAddress(addressInput);
            if (!addressValid) {
                isValid = false;
            }
        }


        this.isValid = isValid;
        return isValid;
    }

    validateAddress(addressInput) {
        const required = ['street', 'city', 'province', 'postalCode', 'country'];
        let isValid = true;

        required.forEach(field => {
            if (!addressInput[field]) {
                isValid = false;
                addressInput.setCustomValidityForField(`Please fill the ${field} field.`, field);
            } else {
                addressInput.setCustomValidityForField('', field);
            }
        });

        if (!isValid) {
            addressInput.reportValidity();
        }

        return isValid;
    }

    @api
    validate() {
        return {
            isValid: this.validateForm(),
            errorMessage: this.validateForm() ? undefined : 'Please fill all required fields.'
        };
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field) {
            // Convert input value to uppercase before setting
            this[field] = event.target.value?.toUpperCase() || '';
            this.hasUserEnteredData = true;
        }
    }

    // handleAddressChange(event) {
    //     this.addressLine1 = event.detail.street?.toUpperCase() || '';
    //     this.city = event.detail.city?.toUpperCase() || '';
    //     this.street = event.detail.subpremise?.toUpperCase() || '';
    //     this.state = event.detail.province?.toUpperCase() || '';
    //     this.zipCode = event.detail.postalCode?.toUpperCase() || '';
    //     this.country = event.detail.country?.toUpperCase() || '';
    // }

    handleAddressChange(event) {

        this.addressLine1 = event.detail.street ? event.detail.street.toUpperCase() : '';
        this.city = event.detail.city ? event.detail.city.toUpperCase() : '';
        this.suite = event.detail.subpremise ? event.detail.subpremise.toUpperCase() : '';
        this.state = event.detail.province ? event.detail.province.toUpperCase() : '';
        this.zipCode = event.detail.postalCode;
        this.country = event.detail.country ? event.detail.country.toUpperCase() : '';

    }

}