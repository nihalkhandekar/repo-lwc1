import { LightningElement, api, wire,track } from 'lwc';
import getUserDetailsCityStateCountryOptions from '@salesforce/apex/SAP_LoggedInUserController.getUserDetailsCityStateCountryOptions';
import { MessageContext, createMessageContext, publish, subscribe, unsubscribe, releaseMessageContext } from 'lightning/messageService';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';
import ADDRESS_MESSAGE_CHANNEL from '@salesforce/messageChannel/AddressMessageChannel__c';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import iconCss from "@salesforce/resourceUrl/iconCss";
import sap_SotsCss from "@salesforce/resourceUrl/sap_SotsCss";
import ADDRESS_STYLES from '@salesforce/resourceUrl/sap_addressStyles';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class ApostilleRequestForm extends LightningElement {
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
    @api formId = 'form2';
    @api isValid = false;
    @api validationCheck;
    isLoading = true;
    publishDebounceTimeout;

    //labels
 @track CurrentLanguage = false; // True means Spanish
 labels={};
 JsonLanguageData;

    provinceOptions = [
        { label: 'California', value: 'CA' },
        { label: 'Texas', value: 'TX' },
        { label: 'Washington', value: 'WA' },
    ];

    countryOptions = [
        { label: 'United States', value: 'US' },
        { label: 'Japan', value: 'JP' },
        { label: 'China', value: 'CN' },
    ];

    get getProvinceOptions() {
        return this.provinceOptions;
    }

    get getCountryOptions() {
        return this.countryOptions;
    }

    connectedCallback() {
        this.validationCheck = 'some string value';
        // if (!this.country) {
        //     this.country = 'US';
        // }
        window.scrollTo(0,0);

        Promise.all([
            loadStyle(this, iconCss),
            loadStyle(this, sap_SotsCss),
            loadStyle(this, ADDRESS_STYLES)
        ]).then(() => {
            this.isLoading = false;
            console.log('CSS files loaded successfully');
        }).catch(error => {
            this.isLoading = false;
            console.error('Error loading CSS files:', error);
        });

        // Initial publish with debouncing
        this.debouncedPublishAddressDetails();

        setTimeout(() => {
            this.subscribeToValidationChannel();
        }, 1000);


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




    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
        this.handleLanguageChange(message);
      });
    }

    @wire(MessageContext)
    messageContext;

    // Debounced publish function with cancellation of previous timeouts
    debouncedPublishAddressDetails() {
        // Clear any existing timeout
        if (this.publishDebounceTimeout) {
            clearTimeout(this.publishDebounceTimeout);
        }

        // Set new timeout
        this.publishDebounceTimeout = setTimeout(() => {
            const addressDetails = {
                firstName: this.firstName?.toUpperCase() || '',
                lastName: this.lastName?.toUpperCase() || '',
                addressLine1: this.addressLine1?.toUpperCase() || '',
                suite: this.suite?.toUpperCase() || '',
                city: this.city?.toUpperCase() || '',
                state: this.state?.toUpperCase() || '',
                zipCode: this.zipCode,
                country: this.country?.toUpperCase() || '',
                businessName: this.organizationName?.toUpperCase() || '',
                email: this.email?.toUpperCase() || '',
                phone: this.phone || ''
            };

            publish(this.messageContext, ADDRESS_MESSAGE_CHANNEL, addressDetails);
        }, 50); // 500ms debounce delay
    }

    subscribeToValidationChannel() {
        console.log('subscribe..............');
        subscribe(
            this.messageContext,
            VALIDATION_CHANNEL,
            (message) => this.handleValidationMessage(message)
        );
    }

    handleValidationMessage(message) {
        if (message.action === 'validate') {
            console.log('check...........');
            const isValid = this.validateForm();

            let source = this.formId; // Default source
            if (message.source === 'Stepper') {
                source = `${this.formId}stepper`; // Append "stepper" if source is "Stepper"
            }

            publish(this.messageContext, VALIDATION_CHANNEL, {
                action: 'validationResult',
                source: source,
                isValid: isValid
            });
        }
    }


    @wire(getUserDetailsCityStateCountryOptions, { recordId: '$recordId' })
    wiredUserAndCityData({ error, data }) {
        if (data && !this.recordId) {
            const userDetails = data.userDetails;
            const toUpperCase = (value) => value ? value.toUpperCase() : '';

            const formatPhoneNumberUSA = (phone) => {
                if (!phone) return ''; // Return empty if no phone number is provided
            
                let cleaned = phone.replace(/\D/g, ''); // Remove non-numeric characters
            
                // Remove country code if it starts with '1' (US country code)
                if (cleaned.startsWith('1') && cleaned.length === 11) {
                    cleaned = cleaned.substring(1);
                }
            
                // Format only if it's a valid 10-digit US number
                if (cleaned.length === 10) {
                    return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
                }
            
                // Return the original value if not a valid US number
                return phone;
            };
            


            // Handle text fields that should be uppercase
            if (!this.firstName) {
                this.firstName = toUpperCase(userDetails.Contact.Account.FirstName || '');
            }
            if (!this.lastName) {
                this.lastName = toUpperCase(userDetails.Contact.Account.LastName || '');
            }
            if (!this.organizationName) {
                this.organizationName = toUpperCase(userDetails.Contact.Account.Name || '');
            }
            if (!this.addressLine1) {
                this.addressLine1 = toUpperCase(userDetails.Contact.Account.BillingStreet | '');
            }
            if (!this.city) {
                this.city = toUpperCase(userDetails.Contact.Account.BillingCity || '');
            }
            if (!this.state) {
                this.state = toUpperCase(userDetails.Contact.Account.BillingState || '');
            }
            if (!this.country) {
                this.country = toUpperCase(userDetails.Contact.Account.BillingCountry || '');
            }
            if (!this.email) {
                this.email = toUpperCase(userDetails.Contact.Account.SAP_Business_Email_Address__c || '');
            }
            if (!this.phone) {
                this.phone = formatPhoneNumberUSA(userDetails.Contact.Account.Phone || '');
            }
            if (!this.zipCode) {
                this.zipCode = userDetails.Contact.Account.BillingPostalCode || '';
            }

            // Use debounced publish for initial data
            this.debouncedPublishAddressDetails();
        } else if (error) {
            console.error('Error fetching user details and city options:', error);
        }
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
            // Convert input to uppercase for text fields
            const value = event.target.type === 'text' || field === 'email' ?
                event.target.value.toUpperCase() :
                event.target.value;

            this[field] = value;
            if (field === 'phone') {
                const formattedNumber = this.formatPhoneNumber(event.target.value);
                this[field] = formattedNumber;
                event.target.value = formattedNumber;
            }

            // If it's a text input, update the input field's value to uppercase
            if (event.target.type === 'text' || field === 'email') {
                event.target.value = value;
            }

            // Use debounced publish for input changes
            this.debouncedPublishAddressDetails();
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
                this.handleInputChange({
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

                this.handleInputChange({
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
                this.handleInputChange({
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




    handleAddressChange(event) {
        this.addressLine1 = event.detail.street ? event.detail.street.toUpperCase() : '';
        this.city = event.detail.city ? event.detail.city.toUpperCase() : '';
        this.suite = event.detail.subpremise ? event.detail.subpremise.toUpperCase() : '';
        this.state = event.detail.province ? event.detail.province.toUpperCase() : '';
        this.zipCode = event.detail.postalCode;
        this.country = event.detail.country ? event.detail.country.toUpperCase() : '';

        this.validateForm();

        // Use debounced publish for address changes
        this.debouncedPublishAddressDetails();

        setTimeout(() => {
        //    this.country = 'USA';
            
            // Publish the final state after the timeout
            this.debouncedPublishAddressDetails();
        }, 5000);
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



    disconnectedCallback() {
        // Clear any remaining timeout when component is destroyed
        if (this.publishDebounceTimeout) {
            clearTimeout(this.publishDebounceTimeout);
        }
    }
}