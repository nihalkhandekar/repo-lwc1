import { LightningElement, track, api, wire } from 'lwc';
import sap_modalStateSealRequest from '@salesforce/resourceUrl/sap_modalStateSealRequest';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_removeHeadingStateSeal from '@salesforce/resourceUrl/sap_removeHeadingStateSeal';
import sap_stateSealM from '@salesforce/resourceUrl/sap_stateSealM';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import TITLE_FIELD from '@salesforce/schema/Contact.SAP_Title__c';
import PARTY_FIELD from '@salesforce/schema/Contact.SAP_Party__c';
import PREFIX_FIELD from '@salesforce/schema/Contact.SAP_Prefix__c';
import SUFFIX_FIELD from '@salesforce/schema/Contact.SAP_Suffix__c';
import ELECTED_FIELD from '@salesforce/schema/Contact.SAP_Elected__c'; // Import SAP_Elected__c field
import upsertContact from '@salesforce/apex/SAP_AddOfficialContactController.upsertContact'; // Import upsertContact method
import fetchContactData from '@salesforce/apex/SAP_AddOfficialContactController.fetchContactData'; // Import fetchContactData method
import fetchOffices from '@salesforce/apex/SAP_AddOfficialContactController.fetchOffices'; // Import fetchOffices method
import {NavigationMixin} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class PublicOfficialModal extends NavigationMixin(LightningElement) {
    @track formData = {
        prefix: '',
        lastName: '',
        firstName: '',
        middleInitial: '',
        suffix: '',
        personalName: '',
        title: '',
        sbt: '',
        party: '',
        apo: false,
        email: '',
        fax: '',
        homePhone: '',
        businessPhone: '',
        extension: '',
        address1: '',
        address2: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
        elected: '',
        startTerm: '',
        endTerm: '',
        recordId: '',
        indefiniteTerm: false,
    };

    @api mode = '';
    @api electionOfficial = false;
    @api recordId;
    @track isReadOnly = false;
    @track titleOptions = [];
    @track partyOptions = [];
    @track electedOptions = [];
    @track sbtOptions = [];
    @api townId = '';
    @track stateTitleDisable = false;
    @track buttonLabel = "Add Official";

    @track prefixSelectOptions = [];
    @track suffixSelectOptions = [];

    @track isindefiniteTerm = false;
    @track isDateRequired = true;

    @wire(CurrentPageReference)
    pageRef({ state }) {
      console.log('state dats is '+JSON.stringify(state));
      if (state.c__recordId != null) {
        this.recordId = state.c__recordId;
        this.formData.recordId = this.recordId;
        this.loadContactData(); // Fetch contact data if editing an existing record
    }
    if(state.c__townId){
        this.formData.sbt = state.c__townId;
    }
      
    if (state) {     
        this.electionOfficial =  state.c__electionOfficial     
        this.returnTo = state.c__returnTo; 
        this.mode = state.c__mode;
        console.log('record id is and mode is  '+ this.recordId +' '+this.mode);
        if(this.formData.indefiniteTerm){
            this.formData.endTerm = null;
        }


        if(this.mode === 'view' || this.mode === 'edit' && this.townId){
            this.stateTitleDisable = true;
            this.isTownIDPresent;
        }

        if(this.mode === 'view' || this.mode === 'edit' || this.formData.recordId){
            this.buttonLabel = 'Save';
        }

            if (this.mode === 'view') {
            this.isReadOnly = true;
        } else if (!this.recordId) {
            this.isReadOnly = false;
        }

        if(this.townId){
            this.formData.sbt = this.townId;
        }
        console.log(this.formData.sbt);

        //  this.mode = JSON.parse(state.mode);
    }
    }

    goBackModal() {
        if(this.mode ==='edit'){
            this.mode = 'view';
            this.isReadOnly = true;
        }else{

        
        this.recordId = '';
        this.mode = '';
        this.isReadOnly = false;
        this.formData.recordId = '';
        this.formData = {
            prefix: '',
            lastName: '',
            firstName: '',
            middleInitial: '',
            suffix: '',
            personalName: '',
            title: '',
            sbt: '',
            party: '',
            apo: false,
            email: '',
            fax: '',
            homePhone: '',
            businessPhone: '',
            extension: '',
            address1: '',
            address2: '',
            city: '',
            state: '',
            zipCode: '',
            country: '',
            elected: '',
            startTerm: '',
            endTerm: '',
            recordId: '',
            indefiniteTerm: false,
        };

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: this.returnTo  // The target component name
                },
                state: {
                    c__reloadData: true
                  }
            });
            
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }
      }

    connectedCallback() {
        Promise.all([
            loadStyle(this, sap_modalStateSealRequest),
            loadStyle(this, sap_removeHeadingStateSeal),
            loadStyle(this, sap_stateSealM)
        ])
        .then(() => {
            console.log('Both CSS files loaded successfully');
        })
        .catch(error => {
            console.error('Error loading CSS files:', error);
        });

        // if (this.recordId) {
        //     this.formData.recordId = this.recordId;
        //     this.loadContactData(); // Fetch contact data if editing an existing record
        // }

        // if(this.formData.indefiniteTerm){
        //     this.formData.endTerm = null;
        // }

        fetchOffices()
        .then((data) => {
            this.sbtOptions = data.map(office => {
                return { label: office.SAP_Name__c, value: office.Id };
            });

            if (this.townId) {
                this.formData.sbt = this.townId;
            }
        })
        .catch((error) => {
            console.error('Error fetching office records:', error);
        });

        // if(this.mode === 'view' || this.mode === 'edit' && this.townId){
        //     this.stateTitleDisable = true;
        //     this.isTownIDPresent;
        // }

        // if(this.mode === 'view' || this.mode === 'edit' || this.formData.recordId){
        //    this.buttonLabel = 'Save';
        // }

        //  if (this.mode === 'view') {
        //     this.isReadOnly = true;
        // } else if (!this.recordId) {
        //     this.isReadOnly = false;
        // }

        // if(this.townId){
        //     this.formData.sbt = this.townId;
        // }
        // console.log(this.formData.sbt);
    }

    handleEditClick() {
        this.isReadOnly = false;
        this.mode = 'edit'
    }

    get isTownIDPresent(){
        if(this.mode === 'add'){
            return true;
        } else if(this.formData.sbt){
            this.stateTitleDisable = true;
            return true;
        } else {
            return false;
        }
    }

    get endTermDisable(){
        if(this.formData.indefiniteTerm){
            return true;
        } else if(this.mode === 'view'){
            return true;
        } else {
            return false;
        }
    }

    get noEditField(){
        if(this.mode === 'view' || this.mode === 'edit'){
            return true;
        } else {
            return false;
        }
    }

    get noEditFieldSBT(){
        if(this.mode === 'view' || this.mode === 'edit' || this.electionOfficial){
            return true;
        } else {
            return false;
        }
    }

    get headerText() {
        if (!this.formData.recordId) {
            return 'Add Official';
        }
        return this.isReadOnly ? 'View Official  |  ' : 'Edit Official';
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: TITLE_FIELD })
    wiredTitlePicklist({ error, data }) {
        if (data) {
            this.titleOptions = data.values;
        } else if (error) {
            console.error('Error fetching Title picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: PARTY_FIELD })
    wiredPartyPicklist({ error, data }) {
        if (data) {
            this.partyOptions = data.values;
        } else if (error) {
            console.error('Error fetching Party picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: ELECTED_FIELD })
    wiredElectedPicklist({ error, data }) {
        if (data) {
            this.electedOptions = data.values;
        } else if (error) {
            console.error('Error fetching Elected picklist values:', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PREFIX_FIELD
    })
    prefixPicklistValues({ error, data }) {
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

    



    loadContactData() {
        fetchContactData({ recordId: this.recordId })
            .then((contact) => {
                // Apply title case to the relevant fields
                this.formData = {
                    ...this.formData,
                    prefix: contact.Salutation || '',
                    lastName: this.toTitleCase(contact.LastName || ''),
                    firstName: this.toTitleCase(contact.FirstName || ''),
                    middleInitial: this.toTitleCase(contact.MiddleName || ''),
                    suffix: contact.Suffix || '',
                    personalName: this.toTitleCase(contact.SAP_Personal_Name__c || ''),
                    title: contact.SAP_Title__c || '',
                    party: contact.SAP_Party__c || '',
                    apo: contact.SAP_Authorized_Public_Official__c || false,
                    sbt: contact.SAP_Office__c || '',
                    email: contact.Email || '',
                    fax: contact.Fax || '',
                    homePhone: contact.HomePhone || '',
                    businessPhone: contact.Phone || '',
                    extension: contact.SAP_Extension__c || '',
                    address1: this.toTitleCase(contact.MailingStreet || ''),
                    address2: this.toTitleCase(contact.SAP_MailingAddress2__c || ''),
                    city: (contact.MailingCity || '').toUpperCase(),
                    state: (contact.MailingState || '').toUpperCase(),
                    zipCode: contact.MailingPostalCode || '',
                    country: contact.MailingCountry || '',
                    elected: contact.SAP_Elected__c || '',
                    startTerm: contact.SAP_Start_Term__c || '',
                    endTerm: contact.SAP_End_Term__c || '',
                    indefiniteTerm: contact.SAP_Indefinite_Term__c || false,
                };
                console.log(this.formData);
            })
            .catch((error) => {
                let errorMessage = 'An error occurred while fetching contact data.';
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (error.message) {
                    errorMessage = error.message;
                }
                console.error('Error fetching contact data:', error);
                this.showToast('Error', 'Error fetching contact data: ' + errorMessage, 'error');
            });
    }
    

    // Utility function to capitalize the first letter of each word (title case)
    toTitleCase(str) {
        // Convert str to a string if it's not already
        return String(str || '').replace(/\w\S*/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase());
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
    

    handleInputChange(event) {
        const field = event.target.name;
        let value = event.target.type === 'checkbox' ? event.target.checked : event.detail.value;
    
        // Apply title case for specific fields
        if (['firstName', 'lastName', 'middleInitial', 'personalName', 'address1'].includes(field)) {
            value = this.toTitleCase(value);
        }
    
        // Convert to uppercase for specific fields
        if (['city', 'state'].includes(field)) {
            value = value.toUpperCase();
        }
    
        // Format phone number if the field is 'phone'
        if (['homePhone', 'businessPhone', 'fax'].includes(field)) {
            value = this.formatPhoneNumber(value); // Format the phone number
        }
    
        // Update the formData object with the processed value
        this.formData = { ...this.formData, [field]: value };
    
        // Handle indefinite term logic
        if (field === 'indefiniteTerm') {
            if (value) {
                // If indefiniteTerm is checked, reset the start and end dates
                this.formData.startTerm = null;
                this.formData.endTerm = null;
                this.isindefiniteTerm = true;
                this.isDateRequired = false;
            } else {
                // If indefiniteTerm is unchecked
                this.isindefiniteTerm = false;
                this.isDateRequired = true;
            }
        }
    
        // Validate the date range if startTerm or endTerm is being updated
        if (field === 'endTerm' || field === 'startTerm') {
            const startDate = new Date(this.formData.startTerm);
            const endDate = new Date(this.formData.endTerm);
    
            if (this.formData.startTerm && this.formData.endTerm && endDate < startDate) {
                this.formData.endTerm = '';
                this.showToast('Error', 'End date cannot be before the start date.', 'error');
            }
        }
    }
    

    get isTermDateRequired(){
        if(this.formData.indefiniteTerm === true){
            return false;
        }else{
            return true;
        }
    }

    get isDateindefiniteTerm(){
        if(this.formData.indefiniteTerm === true){
            return true;
        }else{
            return false;
        }
    }
    

    handleAddressChange(event) {
        // Apply title case to address1 and city
        this.formData.address1 = this.toTitleCase(event.detail.street);
        this.formData.city = this.toTitleCase(event.detail.city);
        this.formData.address2 = event.detail.subpremise;
        this.formData.state = event.detail.province;
        this.formData.zipCode = event.detail.postalCode;
        this.formData.country = event.detail.country;
    }

    handleAdd() {
        const isValid = this.validateInputs();
        if (isValid) {
            upsertContact({ formData: this.formData })
                .then((contactId) => {
                    if (this.formData.recordId) {
                        this.showToast('Official', 'Official updated successfully!', 'success');
                    } else {
                        this.showToast('Official', 'Official created successfully!', 'success');
                    }
                    this.formData.recordId = contactId;
                    this.goBackModal()
                })
                .catch((error) => {
                    console.log(error);
                    this.showToast('Error', 'Error saving contact: ' + error.body.message, 'error');
                });
        } else {
            console.error('Form is not valid');
        }
    }

    get endTermRequired() {
        return !this.formData.indefiniteTerm;
    }

    validateInputs() {
        let allValid = true;
        let missingFields = [];

        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-input-address');

        inputComponents.forEach(inputCmp => {
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

    closeModal() {
        this.close();
    }
}