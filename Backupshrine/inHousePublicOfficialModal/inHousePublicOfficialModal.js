import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import TOWN_FIELD from '@salesforce/schema/Contact.Town__c';
import JUDICIAL_DISTRICT_FIELD from '@salesforce/schema/Contact.Judicial_District__c';
import fetchPublicOfficialData from '@salesforce/apex/InHousePublicOfficialController.fetchPublicOfficialData';
import updatePublicOfficialData from '@salesforce/apex/InHousePublicOfficialController.updatePublicOfficialData';
import processNameFieldHistory from '@salesforce/apex/InHousePublicOfficialController.processNameFieldHistory';
import processTermFieldHistory from '@salesforce/apex/InHousePublicOfficialController.processTermFieldHistory';
import {NavigationMixin} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';



export default class InHousePublicOfficialModal extends NavigationMixin(LightningElement) {
    @track isReadOnly = false;
    @api showError = false;
    @api mode = '';
    @track idofrecord;
    @api recordId;
    @api signedBy = '';
    @track isGeneratepdfSectionEnabled = false;
    @track townOption =[];
    @api town;
    @api lastName;
    @api middleInitial;
    @api firstName;
    @api position;
    @api judicialDistrict;
    @api termstartDate;
    @api termendDate;
    @api isIndefiniteTerm = false;

    @track judicialSelectOptions = [];
    @track positionOptions = [];
    @api SealStampof;
    @api Notes;
    @track historyNameRecords = [];
    @track historyTermRecords = [];
    @track isLoading= true ;
    @track isEndDateBeforeStart = false;


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
        loadStyle(this, stateExtradition)
        .then(() => {
            console.log('First CSS file (stateExtradition) loaded successfully');
        })
        .catch(error => console.error('Error loading CSS file:', error));

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
            // this.fetchExistingData();
            // this.fetchNameHistory();
            // this.fetchTermHistory();
            this.fetchExistingData()
            .then(() => {
                console.log('fetchExistingData completed');
                 this.fetchNameHistory();
                 this.fetchTermHistory();
            })
        }
        if(!this.recordId){
            this.idofrecord = null;
            this.resetFields();
            this.historyNameRecords = [];
            this.historyTermRecords = [];
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


     fetchExistingData() {
       return fetchPublicOfficialData({ recordId: this.idofrecord })
            .then((data) => {
                console.log('Data coming from Apex:', JSON.stringify(data));
                    this.lastName = data.records[0]?.LastName;
                    this.middleInitial = data.records[0]?.MiddleName,
                    this.firstName = data.records[0]?.FirstName;
                    this.position = data.records[0]?.Position__c,
                    this.termstartDate = data.records[0]?.Start_Term__c,
                    this.termendDate = data.records[0]?.End_Term__c,
                    this.town = data.records[0]?.Town__c,
                    this.isIndefiniteTerm = data.records[0]?.Indefinite_Term__c,
                    this.judicialDistrict = data.records[0]?.Judicial_District__c,
                    this.SealStampof = data.records[0]?.Seal_Stramp_of__c,
                    this.Notes = data.records[0]?.Notes__c
            })
            .catch((error) => {
                console.error('Error fetching data:', error);
            });
    }

    resetFields() {
        // Reset all fields to null or default values
        this.lastName = null;
        this.middleInitial = null;
        this.firstName = null;
        this.position = null;
        this.termstartDate = null;
        this.termendDate = null;
        this.town = null;
        this.isIndefiniteTerm = null;
        this.judicialDistrict = null;
        this.SealStampof = null;
        this.Notes = null;
    }

     fetchNameHistory() {
        processNameFieldHistory({ contactId: this.idofrecord }) // Pass the contactId dynamically
        .then(result => {
            console.log('Name History Result:', result);

            // Now, process the result
            this.historyNameRecords = result.map(record => {
                return {
                    changeDate: record.changeDate, // Formatted date
                    firstName: record.FirstName || '',
                    middleName: record.MiddleName || '',
                    lastName: record.LastName || ''
                };
            });
        })
            .catch((error) => {
                console.error('Error fetching history:', error);
            });
    }

     fetchTermHistory() {
        processTermFieldHistory({ contactId: this.idofrecord }) // Pass the contactId dynamically
        .then(result => {
            console.log('Apex Result:', result);

            // Now, process the result
            this.historyTermRecords = result.map(record => {
                return {
                    changeDate: record.changeDate, // Formatted date
                    endTerm: record.End_Term__c || '',
                    startTerm: record.Start_Term__c || '',
                    startTermClass: record.Start_Term__c === 'Indefinite Term' ? 'indefinite-term spacing' : 'spacing',
                    endTermClass: record.End_Term__c === 'Indefinite Term' ? 'indefinite-term spacing' : 'spacing'
                };
            });
        })
            .catch((error) => {
                console.error('Error fetching history:', error);
            });
    }

    get displayHistoryRecords() {
        return this.historyNameRecords;
    }

    get displayTermHistoryRecords(){
        return this.historyTermRecords;
    }

    get disabledTerms(){
        return this.isReadOnly || this.isIndefiniteTerm;
    }


    async handleAdd() {
        const isValid = this.validateInputs();
        if (isValid && !this.isEndDateEarlier) {
            const data = {
                FirstName: this.firstName,
                MiddleName: this.middleInitial,
                LastName: this.lastName,
                Position__c: this.position,
                Start_Term__c: this.termstartDate,
                End_Term__c: this.termendDate,
                Town__c: this.town,
                Indefinite_Term__c: this.isIndefiniteTerm,
                Judicial_District__c: this.judicialdistrict,
                Seal_Stramp_of__c: this.SealStampof,
                Notes__c: this.Notes,
                Id: this.idofrecord
            };
            console.log('--data--'+JSON.stringify(data));
            console.log(data);

            try {
                const result = await updatePublicOfficialData({ newRecord: data });
                this.recordId = result;

                // Show toast message based on the operation (create or update)
                if (this.idofrecord) {
                    this.showToast('Public Officials', 'Request updated successfully!', 'success');
                  //  this.isReadOnly = true;
                } else {
                    this.showToast('Public Officials', 'Request created successfully!', 'success');
                }
                this.mode = 'view';
                this.refreshData();
            } catch (error) {
                console.error('Error upserting record:', error);
                this.showToast('State Seal/Arms', 'Error processing the request. Please try again.', 'error');
                return 'error';
            }
        } else {
            this.showToast('Apostille/in-house', 'Please review before '+this.footerText, 'error');
            console.error('Form is not valid');
            return 'error';
        }
    }

    get headerText() {
        if (!this.idofrecord) {
            return 'Add Official';
        }
        return this.isReadOnly ? 'View Official' : 'Edit Official';
    }
    get footerText(){
        if(!this.idofrecord)
            return 'Add Official';
        else
        return 'Save';
    }


    handleEditClick() {
        this.mode = 'edit'
        this.isReadOnly = false; // Enable editing
        console.log('now it is into editing');
        console.log('mode is '+ this.mode);
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
                        componentName: 'c__inHousePublicOfficial'  // The target component name
                    }
                });

            } catch (error) {
                console.error("Error navigating to RecordDetail:", error);
            }
        }

    }

    // Validate input fields
    validateInputs() {
        let allValid = true;
        let missingFields = [];

        // Get all input components
        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group,lightning-input-address');

        inputComponents.forEach(inputCmp => {
            // Check each input's validity
            inputCmp.reportValidity();

            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label); // Collect labels of invalid fields
            }
        });

        if (!allValid) {
            const message = `Please fill in the required: ${missingFields.join(', ')}`;
            console.error(message);

         //   this.showToast('Error', message, 'error');
        }

        return allValid;
    }

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


    /***************************************************
       THIS IS THE SECTION OF THE PERSONAL INFORMATION
    ***************************************************/


    handlelastnameChange(event) {
        this.lastName = event.target.value;
    }

    handlemiddleChange(event) {
        this.middleInitial = event.target.value;
    }

    handlefirstChange(event) {
        this.firstName = event.target.value;
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


    get istermstartInvalid(){
        return !this.termstartDate && this.showError;
    }

    get termstartErrorClass() {
        return this.istermstartInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get istermendInvalid(){
        return !this.termendDate && this.showError;
    }

    get termendErrorClass() {
        return (this.istermendInvalid || this.isEndDateEarlier) ?  'slds-form-element slds-has-error' : 'slds-form-element';
    }

    get isEndDateEarlier() {
        return this.termstartDate && this.termendDate && new Date(this.termendDate) < new Date(this.termstartDate);
    }


    /***************************************************
       THIS IS THE SECTION OF THE SEARCH OFFICIALS
    ***************************************************/



    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.positionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.positionOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: JUDICIAL_DISTRICT_FIELD
    })
    judicialPicklistValues({ error, data }) {
        if (data) {
            this.judicialSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.judicialSelectOptions = [];
        }
    }

     // Get Town Values
     @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: TOWN_FIELD
    })
    townPicklistValues({ error, data }) {
        if (data) {
            this.townOption = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching town  values', error);
            this.townOption = [];
        }
    }


    handlePositionChange(event) {
        this.position = event.target.value;
    }


    handletermstartChange(event) {
        this.termstartDate = event.target.value;
    }

    handletermendChange(event) {
        this.termendDate = event.target.value;
    }

    handleIndefiniteTermChange(event) {
        this.isIndefiniteTerm = event.target.checked;
           if(this.isIndefiniteTerm){
            this.termstartDate = null;
            this.termendDate = null;
        }
        console.log('value of isIndefiniteTerm is ===>>'+ this.isIndefiniteTerm);

    }

    handleTownOption(event){
        this.town = event.target.value;
    }

    handlejudicialChange(event) {
        this.judicialDistrict = event.target.value;
    }




    /***************************************************
       THIS IS THE SECTION OF THE ACCOUNT SECTION
    ***************************************************/



    handlesealstateChange(event) {
        this.SealStampof = event.target.value;
    }

    handlenoteChange(event) {
        this.Notes = event.target.value;
    }
    /***************************************************
       THIS IS THE SECTION OF THE GENERATE LETTER
    ***************************************************/



    /***************************************************
       THIS IS THE SECTION OF THE TERM & NAME HISTORY
    ***************************************************/
    // @api prevfirstName = '';
    // @api prevmiddleName = '';
    // @api prevlastName = '';
    // @api termStartPrev = '';
    // @api termEndPrev = '';


    // @wire(getLatestHistoryRecords, { recordId: '$recordId' })
    // wiredHistoryRecords({ data, error }) {
    //     if (data) {
    //         console.log('Data returned from Apex:', JSON.stringify(data));
    //         this.prevfirstName = data.First_Name__c?.OldValue || '';
    //         this.prevlastName = data.Last_Name__c?.OldValue || '';
    //         this.prevmiddleName = data.Middle_Name__c?.OldValue || '';
    //         this.termStartPrev = data.Term_Start__c?.OldValue || '';
    //         this.termEndPrev = data.Term_End__c?.OldValue || '';
    //     } else if (error) {
    //         console.error('Error fetching history records:', error);
    //     }
    // }




}