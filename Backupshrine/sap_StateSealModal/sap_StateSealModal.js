import { LightningElement, track, api, wire} from 'lwc';
import sap_modalStateSealRequest from '@salesforce/resourceUrl/sap_modalStateSealRequest';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_SendEmailModalSS from 'c/sap_SendEmailModalSS';
import upsertApplicationStateSealArm from '@salesforce/apex/SAP_StateSealApplicationController.upsertApplicationStateSealArm';
import fetchApplicationData from '@salesforce/apex/SAP_StateSealApplicationController.fetchApplicationData';
import getStateSealStaffData from '@salesforce/apex/SAP_StateSealApplicationController.getStateSealStaffData';
import {NavigationMixin} from 'lightning/navigation'
import { CurrentPageReference } from "lightning/navigation";
//import sap_SotsCss from "@salesforce/resourceUrl/sap_SotsCss";


export default class sap_StateSealModal extends NavigationMixin(LightningElement) {
    @track isLoading= true ;
    @track formData = {
        prefix: '',
        lastName: '',
        middleInitial: '',
        firstName: '',
        suffix: '',
        //dob: '',
        title: '',
        entity: '',
        email: '',
        phoneNumber: '',
        esq: false,
        address1: '',
        address2: '',
        city: '',
        state: '',
        country: '',
        zipCode: '',
        letterText: '',
        enclosure: '',
        proposedUse: '',
        requestedFor: '',
        disposition: '',
        approvedFor: '',
        dateOfResponse: '',
        reason: '',
        signedBy: '',
        letterType: '',
        wetSign: '',
        recordId: ''
    };


    @track signedByOptions = [];
    @track letterTypeOptions = [];
    @api mode = '';

    @track isReadOnly = false;
    @track letterTypeNR = true;

    @track type = '';
    @track validationError = '';


    @track isGenerateLetterSectionEnabled = false; // Control the "Generate Letter" section
    @api recordId; // Store the newly created or updated record ID
    @track isDropdownOpen = false;


    @wire(CurrentPageReference)
    pageRef({ state }) {
        if (state && state.c__record) {
            this.recordId = state.c__record;
            this.mode = state.c__mode;
            console.log('checking for existing ');

        }
        if(!state.c__record){
            this.mode = 'addnew';
            this.recordId= null;
            console.log('checking for add new');
        }
        this.fetchData();
        console.log('state dats is '+JSON.stringify(state));

    }

    connectedCallback() {
        loadStyle(this, sap_modalStateSealRequest)
        .then(() => {
            console.log('First CSS file (sap_modalStateSealRequest) loaded successfully');
        })
        .catch(error => console.error('Error loading CSS file:', error));

        this.fetchData();
        this.fetchStaffData();  // Fetch the staff data from Apex
    }

    fetchData(){
        this.isLoading = true;
        setTimeout(() => {
            this.refreshData();
            this.isLoading = false;
            //this.loadApplications();
            console.log('loading data is : '+this.isLoading);

        }, 1000);
    }

    refreshData(){

        if (this.recordId) {
            this.idofrecord = this.recordId;
            this.fetchExistingData();

        } else {
            // No recordId present, set dateOfResponse to the current date
            this.formData.dateOfResponse = this.getCurrentDate();
        }
        if(!this.recordId){
            this.idofrecord = null;
            this.resetFields();
        }
        console.log('----idofrecord---' + this.idofrecord);
        if (this.mode === 'view') {
            this.isReadOnly = true;
        } else if (!this.recordId) {
            this.isReadOnly = false;
        }else{
            this.isReadOnly = false;
        }
    }

    resetFields() {
        this.formData = {
            prefix: '',
            lastName: '',
            middleInitial: '',
            firstName: '',
            suffix: '',
            //dob: '',
            title: '',
            entity: '',
            email: '',
            phoneNumber: '',
            esq: false,
            address1: '',
            address2: '',
            city: '',
            state: '',
            country: '',
            zipCode: '',
            letterText: '',
            enclosure: '',
            proposedUse: '',
            requestedFor: '',
            disposition: '',
            approvedFor: '',
            dateOfResponse: '',
            reason: '',
            signedBy: '',
            letterType: '',
            wetSign: '',
            recordId: ''
        };
    }




   // Utility method to get the current date in 'mm/dd/yyyy' format
    getCurrentDate() {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        const day = String(today.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    handleEditClick() {
        this.isReadOnly = false;
        this.mode = 'edit';
    }

    // Options for the dropdowns and radio groups
    prefixOptions = [
        { label: 'Mr.', value: 'Mr' },
        { label: 'Ms.', value: 'Ms' },
        { label: 'Mrs.', value: 'Mrs' },
        { label: 'Dr.', value: 'Dr' }
    ];

    suffixOptions = [
        { label: 'Jr.', value: 'Jr' },
        { label: 'Sr.', value: 'Sr' },
        { label: 'II', value: 'II' },
        { label: 'III', value: 'III' }
    ];

    titleOptions = [
        { label: 'Manager', value: 'Manager' },
        { label: 'Director', value: 'Director' },
        { label: 'VP', value: 'VP' },
        { label: 'CEO', value: 'CEO' }
    ];

    entityOptions = [
        { label: 'Corporation', value: 'Corporation' },
        { label: 'Non-Profit', value: 'NonProfit' },
        { label: 'Government', value: 'Government' },
        { label: 'Private', value: 'Private' }
    ];

    cityOptions = [
        { label: 'New York', value: 'New York' },
        { label: 'Los Angeles', value: 'Los Angeles' },
        { label: 'Chicago', value: 'Chicago' },
        { label: 'Houston', value: 'Houston' }
    ];

    stateOptions = [
        { label: 'New York', value: 'NY' },
        { label: 'California', value: 'CA' },
        { label: 'Illinois', value: 'IL' },
        { label: 'Texas', value: 'TX' }
    ];

    countryOptions = [
        { label: 'United States', value: 'US' },
        { label: 'Canada', value: 'CA' },
        { label: 'United Kingdom', value: 'UK' },
        { label: 'Australia', value: 'AU' }
    ];

    requestedForOptions = [
        { label: 'Arms', value: 'Arms' },
        { label: 'Arms and Seal', value: 'Arms and Seal' },
        { label: 'Seal', value: 'Seal' },
        { label: 'None', value: 'None' }
    ];

    dispositionOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Pending', value: 'Pending' },
        { label: 'Denied', value: 'Denied' },
        { label: 'Notice', value: 'Notice' }
    ];

    approvedForOptions = [
        { label: 'Arms', value: 'Arms' },
        { label: 'Arms and Seal', value: 'Arms and Seal' },
        { label: 'Seal', value: 'Seal' },
        { label: 'None', value: 'None' }
    ];

    wetSignOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    reasonOptions = [
        { label: 'Educational', value: 'Educational' },
        { label: 'Memorial', value: 'Memorial' },
        { label: 'Official Business', value: 'Official Business' },
        { label: 'Constitution and Laws', value: 'Constitution and Laws' }
    ];

    // Update letter type options based on the disposition
    updateLetterTypeOptions() {
        const disposition = this.formData.disposition;
        const reason = this.formData.reason;
        this.letterTypeOptions = []; // Clear the current options

        if (disposition === 'Approved' && reason) {
            // Set letter types to the reason selected
            this.letterTypeOptions = [
                { label: reason, value: reason },
                { label: 'Non-Standard', value: 'Non-Standard' }
            ];
        } else if (disposition === 'Denied') {
            // Set letter types for Denied
            this.letterTypeOptions = [
                { label: 'Denial (short)', value: 'Denial (short)' },
                { label: 'Denial (long)', value: 'Denial (long)' }
            ];
        } else if (disposition === 'Notice') {
            // Set letter types for Notice
            this.letterTypeOptions = [{ label: 'Non-Standard', value: 'Non-Standard' }];
        } else if (disposition === 'Pending') {
            // Clear the letter type field for Pending
            this.letterTypeOptions = [];
            this.formData.letterType = ''; // Clear the selected letter type

            this.letterTypeNR = false;
        }
    }

    // Calculate today's date in YYYY-MM-DD format
    get maxDate() {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        const day = String(today.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    get headerText() {
        if (!this.formData.recordId) {
            return 'Add New Request to use State Arms/Seal';
        }
        return this.isReadOnly ? 'View Request to use State Arms/Seal ' : 'Edit Request to use State Arms/Seal';
    }

    // Utility function to capitalize the first letter of each word (title case)
    toTitleCase(str) {
        return str.replace(/\w\S*/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase());
    }


    async fetchExistingData() {
      return  fetchApplicationData({ recordId: this.recordId })
            .then((data) => {
                // Map the fields from the Apex response to your formData
                this.formData = {
                    ...this.formData,
                    prefix: data.SAP_Prefix__c,
                    lastName: this.toTitleCase(data.SAP_Last_Name__c || ''),
                    middleInitial: this.toTitleCase(data.SAP_Middle_Name__c || ''),
                    firstName: this.toTitleCase(data.SAP_First_Name__c || ''),
                    address1: this.toTitleCase(data.SAP_Address_Line_1__c || ''),
                    city: this.toTitleCase(data.SAP_City__c || ''),
                    suffix: data.SAP_Suffix__c,
                    //dob: data.SAP_Date_Of_Birth__c,
                    title: data.SAP_Title__c,
                    entity: data.SAP_Organization_Name__c,
                    email: data.SAP_Email_Address__c,
                    phoneNumber: data.SAP_Cell_Phone_Number__c,
                    esq: data.SAP_ESQ__c,
                    address2: data.SAP_Suite_Apartment_Floor__c,
                    state: data.SAP_State__c,
                    country: data.SAP_Country__c,
                    zipCode: data.SAP_Zip_Code__c,
                    letterText: data.SAP_Letter_Text__c,
                    enclosure: data.SAP_Enclosure__c,
                    proposedUse: data.SAP_Proposed_Use__c,
                    requestedFor: data.SAP_Requested_For__c,
                    disposition: data.SAP_Disposition__c,
                    approvedFor: data.SAP_Approved_For__c,
                    dateOfResponse: data.SAP_Date_of_SOTS_Response__c,
                    reason: data.SAP_Reason__c,
                    letterType: data.SAP_Letter_Type__c,
                    signedBy: data.Signedby__c,
                    wetSign: data.SAP_Wet_Signature__c,
                    recordId: this.recordId // Ensure the record ID is set
                };

                this.updateLetterTypeOptions();

                this.isGenerateLetterSectionEnabled = true; // Enable the "Generate Letter" section
                //console.log(this.formData); // Log the populated formData for debugging
            })
            .catch((error) => {
                console.error('Error fetching data:', error);
            });
    }

    get isPrintEnabled(){
        if (this.mode === 'view' && this.formData.disposition !== 'Pending'){
            return false;
        }
            return true;

    }

    // Method to fetch staff data from Apex and set options
    fetchStaffData() {
        // Call the updated Apex method (no parameters required)
        getStateSealStaffData()
            .then((result) => {
                // Map the result to signedByOptions in the required format
                this.signedByOptions = result.map(staff => ({
                    label: `${staff.LastName} ${staff.FirstName}, ${staff.SAP_Staff_Title__c}`,
                    value: staff.Id
                }));

                // Optional: Log the options for debugging
                console.log('SignedBy options:', this.signedByOptions);
            })
            .catch((error) => {
                // Log any error in case of failure
                console.error('Error fetching staff data: ', error);
            });
    }

    handleKeyPress(event) {
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


    handleInputChange(event) {
        const field = event.target.name;
        let value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        if (['firstName', 'lastName', 'address1', 'city'].includes(field)) {
            value = this.toTitleCase(value);
        }

        if (field === 'phoneNumber') {
            const formattedNumber = this.formatPhoneNumber(event.target.value);
            this[field] = formattedNumber;
            value = formattedNumber;
        }

        this.formData = { ...this.formData, [field]: value };

        if (field === 'disposition' || field === 'reason') {
            this.updateLetterTypeOptions(); // Update letter type options based on disposition or reason change
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
        this.formData.address1 = this.toTitleCase(event.detail.street);
        this.formData.city = this.toTitleCase(event.detail.city);
        this.formData.address2 = event.detail.subpremise;
        this.formData.state = event.detail.province;
        this.formData.country = event.detail.country;

        const zipCode = event.detail.postalCode;
        const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

        if (!zipCodePattern.test(zipCode)) {
            this.validationError = 'Invalid Zipcode Format';
            this.formData.zipCode = '';
        } else {
            this.validationError = '';
            this.formData.zipCode = zipCode;
        }
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

    handleAdd() {
        const isValid = this.validateInputs();  // Validate form before proceeding

        if (isValid && (!this.validationError || this.validationError.trim() === '')) {
            console.log(this.formData);
            upsertApplicationStateSealArm({ formData: this.formData })
                .then(result => {
                    // Store the newly created or updated record ID
                    this.formData.recordId = result;

                    // Show toast based on the operation (create or update)
                    if (this.formData.recordId) {
                        this.showToast('State Seal/Arms', 'Request updated successfully!', 'success');
                    } else {
                        this.showToast('State Seal/Arms', 'Request created successfully!', 'success');
                    }

                    // Enable the "Generate Letter" section
                    this.isGenerateLetterSectionEnabled = true;

                    // Check if we can switch to view mode after letter data is saved
                    if (this.formData.recordId &&
                        (this.formData.signedBy != null && this.formData.signedBy !== '') &&
                        (this.formData.letterType != null && this.formData.letterType !== '') &&
                        (this.formData.wetSign != null && this.formData.wetSign !== '')) {
                        this.mode = 'view';  // Switch to view mode
                        this.isReadOnly = true; // Switch to read-only mode
                    }

                })
                .catch(error => {
                    this.showToast('State Seal/Arms', 'Error processing the request. Please try again.', 'error');
                    console.error('Error updating record:', error);
                });
        } else {
            console.log('Validation failed or form has errors');
            this.showToast('State Seal/Arms', 'Error processing the request. Please review the form', 'error');
        }
    }


    validateInputs() {
        let allValid = true;
        let missingFields = [];

        const inputComponents = this.template.querySelectorAll(
            'lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group'
        );

        inputComponents.forEach((inputCmp) => {
            inputCmp.reportValidity();
            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label);
            }
        });

        const addressCmp = this.template.querySelector('lightning-input-address');
        if (addressCmp) {
            const addressFields = [
                { field: 'street', label: 'Address Line 1' },
                { field: 'city', label: 'City' },
                { field: 'province', label: 'State' },
                { field: 'postalCode', label: 'Zip Code' },
                { field: 'country', label: 'Country' },
            ];

            addressFields.forEach(({ field, label }) => {
                const value = addressCmp[field];
                if (!value) {
                    allValid = false;
                    missingFields.push(label);
                }
            });
        }

        if (!allValid) {
            const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
            this.showToast('Error', message, 'error');
        }

        return allValid;
    }

    // Close modal
    cloeModels() {
        if(this.mode === 'edit'){
             this.mode = 'view'
             this.refreshData();
         }
         else{
             console.log('into this go to parent code');
             try {
                 // Navigate to the RecordDetail component and pass the recordId
                 this[NavigationMixin.Navigate]({
                     type: 'standard__component',
                     attributes: {
                         componentName: 'c__sap_StateSealArmsRequest'  // The target component name
                     }
                 });

             } catch (error) {
                 console.error("Error navigating to RecordDetail:", error);
             }
         }

     }

        // Handle print letter action
    async handlePrintLetter() {
        const isValid = this.validateInputs();
        if (isValid) {
            console.log('Printing Letter');

            // Call Apex method to create or update the record
            upsertApplicationStateSealArm({ formData: this.formData })
                .then(result => {
                    // Store the newly created or updated record ID
                    this.formData.recordId = result;
                    this.isGenerateLetterSectionEnabled = true; // Enable the "Generate Letter" section
                    console.log('Record upserted with ID:', this.formData.recordId);
                    this.type = 'print'
                    console.log(this.formData);

                    // Delay the PDF generation by 500ms
                    setTimeout(() => {
                        if (this.formData.recordId) {
                            const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
                            if (pdfgenerator) {
                                pdfgenerator.generateLetter(this.formData.recordId, this.formData.letterType, this.formData.wetSign, this.formData.signedBy, this.type);
                            } else {
                                console.error('PDF generator component not found');
                            }
                        } else {
                            console.error('Record update failed, cannot proceed with PDF generation');
                        }
                    }, 100); // 500ms delay
                })
                .catch(error => {
                    console.error('Error upserting record:', error);
                    // Optionally, show a toast or a message to the user here
                });
        } else {
            console.error('Form is not valid');
            // Optionally, show a toast or a message to the user here
        }
    }

    handlePrintEnvelope() {
        console.log('Printing Envelope');

        // Handle PDF generation
        const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.generateEnvelope(this.formData.recordId); // Pass the recordId to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

    async handleSendEmail() {
        console.log('Inside handleSendEmail');
        this.type = 'email';

        const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
        if (!pdfgenerator) {
            console.error('PDF generator component not found');
            this.showToast('Error', 'PDF generator component not found.', 'error'); // Show error toast
            return;
        }

        try {
            // Show toast message to notify the user that the email is being generated
            this.showToast('Generating Email', 'Please wait while we generate the email for you...', 'info');

            console.log('Attempting to generate and upload PDF...');
            const contentDocumentId = await pdfgenerator.generateLetter(
                this.formData.recordId,
                this.formData.letterType,
                this.formData.wetSign,
                this.formData.signedBy,
                this.type
            );

            if (contentDocumentId) {
                console.log('PDF uploaded successfully with ContentDocumentId:', contentDocumentId);
                console.log('Opening email modal...');

                const result = await sap_SendEmailModalSS.open({
                    size: 'small',
                    description: 'Accessible description of modal\'s purpose',
                    toEmail: this.formData.email,
                    attachments: [{
                        name: `${this.formData.firstName}_${this.formData.lastName}_Letter.pdf`,
                        contentVersionId: contentDocumentId // Correctly pass contentVersionId
                    }]
                });
                console.log('Email modal closed with result:', result);

            } else {
                console.error('PDF upload failed.');
                this.showToast('Error', 'PDF upload failed. Please try again.', 'error'); // Show error toast
            }
        } catch (error) {
            console.error('Error in handleSendEmail:', error);
            this.showToast('Error', 'An error occurred while generating the email. Please try again.', 'error'); // Show error toast
        }
    }



}