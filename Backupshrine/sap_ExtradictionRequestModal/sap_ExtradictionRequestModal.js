import {  api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import sap_stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import {loadStyle } from 'lightning/platformResourceLoader';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import INDIVIDUAL_APPLICATION__OBJECT from '@salesforce/schema/IndividualApplication';
import INDVIDUALAPP_SUFFIX_FIELD from '@salesforce/schema/IndividualApplication.SAP_Suffix__c';
import EXTRADITED_FROM_FIELD from '@salesforce/schema/IndividualApplication.SAP_ExtraditedFrom__c';
import upsertNewRequestData from '@salesforce/apex/SAP_ExtraditionRequestController.upsertNewRequestData';
import fetchExtradictionrequestData from '@salesforce/apex/SAP_ExtraditionRequestController.fetchExtradictionrequestData';
import getAttorneyInspectorOptions from '@salesforce/apex/SAP_MaintainStaffDataController.getAttorneyInspectorOptions';
import ExtraditionRequestEmailOption from 'c/sap_ExtraditionRequestEmailOption';
import {NavigationMixin} from 'lightning/navigation'
import { CurrentPageReference } from "lightning/navigation";



export default class ExtradictionRequestModal extends NavigationMixin(LightningModal) {

    @track akaList = [];
    @track isReadOnly = false;
    @api showError = false;
    @api mode = '';
    @track idofrecord;
    @api recordId;
    @track requestDate;
    @track responseDate;
    @track extradictionpc;
    @track extradictionAuth;
    @track notes;
    @track sap_AttorneyInspectorOptions = [];
    // @track officeOptions = [];
    @track receivedForFillingDate;
    @track extractedFileNumber;
    @track sap_AttorneyInspector;
    @track office;
    @api comments;
    @track location = '';
    @track address2 = '';
    @track city = '';
    @track state = '';
    @track zipCode = '';
    @track country = '';
    @track extradictedFrom;
    @track esq = false;
    @track lastName;
    @track middleInitial;
    @track firstName;
    @track suffix;
    @track suffixSelectOptions=[];
    @track akalastName;
    @track akamiddleInitial;
    @track akafirstName;
    @track akasuffix;
    recordTypeId = '';
    accountId = '';
    licenseTypeId = '';
    destination = 'test';
    @api extradictionRequestId;
    @api type ='';
    @track extraditedFromOptions = [];
    @track isLoading= true ;


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
       // this.fetchData();
        console.log('state dats is '+JSON.stringify(state));

    }

    connectedCallback() {
        console.log('this.recordId', this.recordId);
        loadStyle(this, sap_stateExtradition)
        .then(() => {
            console.log('First CSS file (sap_stateExtradition) loaded successfully');
        })
        .catch(error => console.error('Error loading CSS file:', error));


        // if (this.recordId) {
        //     this.idofrecord = this.recordId;
        //     this.fetchExistingData();
        // }
        // console.log('----idofrecord---' + this.idofrecord);
        // if (this.mode === 'view') {
        //     this.isReadOnly = true;
        // } else if (!this.recordId) {
        //     this.isReadOnly = false;
        // }

        this.fetchData();
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


    @wire(getAttorneyInspectorOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.attorneyInspectorOptions = data;
        } else if (error) {
            console.error('Error fetching attorney inspector options: ', error);
        }
    }

    officeOptions = [
        { label: "Chief State's Attorney's Office", value: "Chief State's Attorney's Office" },
        { label: 'Division of Criminal Justice', value: 'Division Of Criminal Justice' },
        { label: "Danbury State's Attorney's Office", value: "Danbury State's Attorney's Office" },
        { label: "Fairfield State's Attorney Office", value: "Fairfield State's Attorney Office" },
        { label: "Hartford States Attorney", value: "Hartford States Attorney" },
        { label: "Hartford State's Attorney's Office", value: "Hartford State's Attorney's Office" },
        { label: 'New Britain JD', value: 'New Britain JD'},
        { label: "New Britain State's Attys Office", value: "New Britain State's Attys Office" },
        { label: "New Britain State's Attorney's Office", value: "New Britain State's Attorney's Office" },
        { label: "New Haven State's Attorney", value: "New Haven State's Attorney" },
        { label: "New Haven State's Attorney's Office", value: "New Haven State's Attorney's Office" },
        { label: "New London State's Attorney's Office", value: "New London State's Attorney's Office" },
        { label: "Office of the Chief State's Attorney", value: "Office Of The Chief State's Attorney" },
        { label: "Office of the State's Attorney", value: "Office Of The State's Attorney" },
        { label: "Office of the Tolland State's Attorney", value: "Office Of The Tolland State's Attorney" },
        { label: "State's Attorney's Office", value: "State's Attorney's Office" },
        { label: "Stamford/Norwalk State's Attorney", value: "Stamford/Norwalk State's Attorney" },
        { label: "Windham State's Attorney's Office", value: "Windham State's Attorney's Office" },
        { label: "Waterbury State's Attorney's Office", value: "Waterbury State's Attorney's Office" }
    ];

    @wire(getObjectInfo, { objectApiName: INDIVIDUAL_APPLICATION__OBJECT })
    individualApplicationObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$individualApplicationObjectInfo.data.defaultRecordTypeId',
        fieldApiName: INDVIDUALAPP_SUFFIX_FIELD
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

    // Fetch picklist values for SAP_ExtraditedFrom__c
    @wire(getPicklistValues, {
        recordTypeId: '$individualApplicationObjectInfo.data.defaultRecordTypeId', // Dynamic record type
        fieldApiName: EXTRADITED_FROM_FIELD,
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.extraditedFromOptions = data.values; // Assign picklist values
            this.error = undefined;
        } else if (error) {
            this.error = error; // Capture any errors
            this.extraditedFromOptions = [];
        }
    }

    get isLastNameInvalid() {
        return !this.lastName && this.showError;

    }

    get lastNameErrorClass() {
        return this.isLastNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isFirstNameInvalid() {
        return !this.firstName && this.showError;

    }

    get firstNameErrorClass() {
        return this.isFirstNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }



    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this[field] = value;
    }

    // formatDate(dateString) {
    //     const date = new Date(dateString);
    //     const month = String(date.getMonth() + 1).padStart(2, '0');
    //     const day = String(date.getDate()).padStart(2, '0');
    //     const year = date.getFullYear();

    //     return `${month}/${day}/${year}`;
    // }

    handleEsqChange() {
        this.esq = !this.esq;
        console.log(this.esq);
    }

    handleAddressChange(event) {
        this.location = event.detail.street ? event.detail.street : '';
        this.city = event.detail.city;
        this.address2 = event.detail.subpremise;
        this.state = event.detail.province;
        this.zipCode = event.detail.postalCode;
        this.country = event.detail.country;

        const zipCode = event.detail.postalCode;
        const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

        if (!zipCodePattern.test(zipCode)) {
            this.validationError = 'Invalid Zipcode Format';
        }else {
            // Clear error and update ZIP Code
            this.validationError = null;
            this.zipCode = zipCode;
        }
    }

    handleAkaFieldChange(event) {
        const fieldName = event.target.name;  // Field name (e.g., akaesq)
        const index = event.target.dataset.index;  // Index in akaList
        const isCheckbox = event.target.type === 'checkbox';  // Check if the field is a checkbox

        // Update the field based on the input type
        if (fieldName === 'akaesq' && isCheckbox) {
            // Set akaesq to true only if the checkbox is checked
            this.akaList[index][fieldName] = event.target.checked ? true : false;
        } else {
            // Handle other fields normally
            this.akaList[index][fieldName] = event.target.value;
        }

        // Set id to null if it doesn't exist (if needed)
        if (!this.akaList[index].id) {
            this.akaList[index].id = null;
        }

        console.log(this.akaList);  // Log to verify the updated akaList
    }



    handleAddMoreAKA() {
        this.akaList.push({
            id: null,
            akalastName: '',
            akamiddleInitial: '',
            akafirstName: '',
            akasuffix: '',
            akaesq: false
        });
    }



    handleRemoveAKA(event) {
        const index = event.target.dataset.index;
        this.akaList.splice(index, 1);
    }

    toTitleCase(str) {
        return str.replace(/\w\S*/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase());
    }

    async fetchExistingData() {
      return  fetchExtradictionrequestData({ recordId: this.idofrecord })
            .then((data) => {
                console.log('Data coming from Apex:', JSON.stringify(data));

                if (data) {
                    this.receivedForFillingDate = data.Received_for_filling_with_Governor_s_Act__c;
                    this.extractedFileNumber = data.SAP_Extradicted_File_Number__c;
                    this.attorneyInspector = data.SAP_Attorney_Inspector__c;
                    this.office = this.toTitleCase(data.SAP_Office__c || ''),
                    this.location = data.SAP_Address_Line_1__c || '';
                    this.address2 = data.SAP_Suite_Apartment_Floor__c;
                    this.city = data.SAP_City__c;
                    this.state = data.SAP_State__c;
                    this.zipCode = data.SAP_Zip_Code__c;
                    this.country = data.SAP_Country__c;
                    this.comments = data.SAP_Comments_for_SOTS_use_only__c;
                    this.extradictedFrom = data.SAP_Extradicted_From__c;
                    this.esq = data.SAP_ESQ__c ? 'true' : 'false';
                    this.lastName = data.SAP_Last_Name__c;
                    this.middleInitial = data.SAP_Middle_Name__c;
                    this.firstName = data.SAP_First_Name__c;
                    this.suffix = data.SAP_Suffix__c;
                    this.requestDate = data.SAP_Request_Date__c;
                    this.responseDate = data.SAP_Response_Date__c;
                    this.extradictionpc = data.SAP_Extradiction_PC__c;
                    this.extradictionAuth = data.SAP_Extradiction_Auth__c;
                    this.notes = data.SAP_Notes_on_Receipt__c;
                    this.recordTypeId = data.RecordTypeId;
                    this.accountId = data.AccountId;
                    this.licenseTypeId = data.LicenseTypeId;
                    this.destination = data.SAP_Destination__c;
                    if (data.Persons_AKA__r) {
                        this.akaList = data.Persons_AKA__r.map(aka => ({
                            id: aka.Id,
                            akalastName: aka.Name || '',
                            akamiddleInitial: aka.SAP_Middle_Name__c || '',
                            akafirstName: aka.SAP_First_Name__c || '',
                            akasuffix: aka.SAP_Suffix__c || '',
                            akaesq: aka.SAP_ESQ__c || false
                        }));
                    }
                } else {
                    console.warn('No record found');
                }
            })
            .catch((error) => {
                console.error('Error fetching data:', error);
            });
    }

    resetFields() {
        this.receivedForFillingDate = null;
        this.extractedFileNumber = null;
        this.attorneyInspector = null;
        this.office = null;
        this.location = null;
        this.address2 = null;
        this.city = null;
        this.state = null;
        this.zipCode = null;
        this.country = null;
        this.comments = null;
        this.extradictedFrom = null;
        this.esq = null;
        this.lastName = null;
        this.middleInitial = null;
        this.firstName = null;
        this.suffix = null;
        this.requestDate = null;
        this.responseDate = null;
        this.extradictionpc = null;
        this.extradictionAuth = null;
        this.notes = null;
        this.recordTypeId = null;
        this.accountId = null;
        this.licenseTypeId = null;
        this.destination = null;
        this.akaList = [];
    }


    validateInputs() {
        let allValid = true;
        let missingFields = [];

        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group, lightning-input-address');

        inputComponents.forEach(inputCmp => {
            inputCmp.reportValidity();

            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label);
            }

            if (inputCmp.tagName.toLowerCase() === 'lightning-input-address') {
                const streetValue = (inputCmp.street || '').trim();
                const cityValue = (inputCmp.city || '').trim();
                const provinceValue = (inputCmp.province || '').trim();
                const postalCodeValue = (inputCmp.postalCode || '').trim();
                const countryValue = (inputCmp.country || '').trim();

                const validateField = (value, label) => {
                    if (!value) {
                        allValid = false;
                        if (!missingFields.includes(label)) {
                            missingFields.push(label);
                        }
                    }
                };

                validateField(streetValue, inputCmp.streetLabel || 'Address Line 1');
                validateField(cityValue, inputCmp.cityLabel || 'City');
                validateField(provinceValue, inputCmp.provinceLabel || 'State');
                validateField(postalCodeValue, inputCmp.postalCodeLabel || 'Zip Code');
                validateField(countryValue, inputCmp.countryLabel || 'Country');

                const zipCodePattern = /^\d+$/; // Adjust pattern as necessary
                if (!zipCodePattern.test(postalCodeValue)) {
                    allValid = false;
                    missingFields.push('Zip Code can only contain digits');
                }

            }
        });

        if (!allValid) {
            const message = `Please fill in the required fields: ${missingFields.length > 0 ? missingFields.join(', ') : 'all fields'}`;
            this.showToast('Error', message, 'error');
        }

        return allValid;
    }


    async handleAdd() {
        const isValid = this.validateInputs();
        if(isValid){
            try {
                const requestData = {
                    idofrecord: this.idofrecord,
                    receivedForFillingDate: this.receivedForFillingDate,
                    extractedFileNumber: this.extractedFileNumber,
                    sap_AttorneyInspector: this.attorneyInspector,
                    office: this.office,
                    location: this.location,
                    address2: this.address2,
                    city: this.city,
                    state: this.state,
                    zipCode: this.zipCode,
                    country: this.country,
                    comments: this.comments,
                    extradictedFrom: this.extradictedFrom,
                    esq: Boolean(this.esq),
                    // esq: this.esq,
                    lastName: this.lastName,
                    middleInitial: this.middleInitial,
                    firstName: this.firstName,
                    suffix: this.suffix,
                    requestDate: this.requestDate,
                    responseDate: this.responseDate,
                    extradictionpc: this.extradictionpc,
                    extradictionAuth: this.extradictionAuth,
                    notes: this.notes,
                    destination: this.destination,
                    akaList: this.akaList
                };

                // console.log('@@W@->',JSON.stringify(this.akaList));

                // const result = await upsertNewRequestData({
                //     requestData,
                //     akaList: this.akaList // Pass akaList directly
                // });
                const requestDataString = JSON.stringify(requestData);

                const result = await upsertNewRequestData({
                   requestDataString
                });
                // console.log('@@W@ resutl->',result);

                if (this.idofrecord) {
                    this.showToast('Extradition Request', 'Request updated successfully!', 'success');
                } else {
                    this.showToast('Extradition Request', 'Request created successfully!', 'success');
                    this.idofrecord = result; // Assign the new record ID
                }

                const passer = this.template.querySelector('c-sap_-event-passer');
                passer.passEvent(new CustomEvent('confirmevent', {
                    bubbles: true,
                    composed: true,
                    detail: { 'message': 'confirm' },
                }));

                // this.switchToViewMode();
            } catch (error) {
                console.error('Error upserting record:', error);
                this.showToast('Extradition Request', 'Error processing the request. Please try again.', 'error');
            }
        }
    }


    get headerText() {
        if (!this.idofrecord) {
            return 'Add New Request';
        }
        return this.isReadOnly ? 'View Request' : 'Edit Request';
    }



    handleEditClick() {
        this.isReadOnly = false;
        this.mode = 'edit';
    }

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
                         componentName: 'c__sap_StateExtraDictionsRequests'  // The target component name
                     }
                 });

             } catch (error) {
                 console.error("Error navigating to RecordDetail:", error);
             }
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


    handleReceiptForwardToCSP(){
        const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
        if (pdfgenerator) {
        pdfgenerator.generateReceiptPdf(this.idofrecord, false, 'print');
        } else {
            console.error('PDF generator component not found');
        }
    }

    handleReceiptPickupbyAttorny(){
        const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
        if (pdfgenerator) {
        pdfgenerator.generateReceiptPdf(this.idofrecord, true, 'print');
        } else {
            console.error('PDF generator component not found');
        }
    }

    handleCSPMailingLabel(){
        const pdfgenerator = this.template.querySelector('c-sap_-pdf-generator');
        if (pdfgenerator) {
        pdfgenerator.cspMailingLabelPdf();
        } else {
            console.error('PDF generator component not found');
        }
    }

    async handleSendEmail() {
        try {
            const selectedOption = await ExtraditionRequestEmailOption.open({
                size: 'small',
                description: 'Select Email Option',
                extradictionRequestId: this.idofrecord
            });

            if (selectedOption) {
                // Do something with the selected option
                console.log('Selected email option:', selectedOption);
            }
        } catch (error) {
            console.error('Error in email option modal:', error);
        }
    }

}