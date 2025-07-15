import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PUBLIC_OFFICIALS_OBJECT from '@salesforce/schema/Contact';
import PREFIX_FIELD from '@salesforce/schema/Contact.Prefix__c';
import SUFFIX_FIELD from '@salesforce/schema/Contact.Suffix__c';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import LETTERTYPE_FIELD from '@salesforce/schema/Contact.letterType__c';
import WETSIGN_FIELD from '@salesforce/schema/Contact.Wet_Signature__c';
import JUDICIAL_DISTRICT_FIELD from '@salesforce/schema/Contact.Judicial_District__c';
import getLatestHistoryRecords from '@salesforce/apex/HistoryTrackerController.getLatestHistoryRecords';
import fetchPublicOfficialData from '@salesforce/apex/ExtraditionPublicOfficialController.fetchPublicOfficialData';
import updatePublicOfficialData from '@salesforce/apex/ExtraditionPublicOfficialController.updatePublicOfficialData';
import getStateSealStaffData from '@salesforce/apex/StateSealApplicationController.getStateSealStaffData';
import processNameFieldHistory from '@salesforce/apex/InHousePublicOfficialController.processNameFieldHistory';
import processTermFieldHistory from '@salesforce/apex/InHousePublicOfficialController.processTermFieldHistory';
import {NavigationMixin} from 'lightning/navigation'
import { CurrentPageReference } from "lightning/navigation";


export default class StateExtraditionModal extends NavigationMixin(LightningModal) {

    @track isReadOnly = false;
    @api showError = false;
    @api mode = '';
    @api modeSubtab = '';
    @track idofrecord;
    @api recordId;
    @api recordIdSubTab;
    @track signedByOptions = [];
    @track letterTypeOptions = [];
    @track wetSignOptions = [];
    @api signedBy = '';
    @api letterType = '';
    @track wetSign = 'No';
    @track isGeneratepdfSectionEnabled = false;
    @track isLoading= true ;
    // @api fullName;
    @api country;
    @track historyTermRecords = [];
    @track historyNameRecords = [];

    
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
        

        // if (this.recordId) {
        //     this.idofrecord = this.recordId;
        //     this.fetchExistingData();
        //     this.fetchNameHistory();
        //     this.fetchTermHistory();
        // }
        // console.log('----idofrecord---' + this.idofrecord);
        // if (this.mode === 'view') {
        //     this.isReadOnly = true;
        // } else if (!this.recordId) {
        //     this.isReadOnly = false;
        // }
        this.fetchData();
        this.fetchStaffData();  
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


    async fetchExistingData() {
     return  fetchPublicOfficialData({ recordId: this.idofrecord })
            .then((data) => {
                console.log('Data coming from Apex:', JSON.stringify(data));
                    this.lastName = data.records[0]?.LastName;
                    this.prefix = data.records[0]?.Prefix__c,
                    this.middleInitial = data.records[0]?.MiddleName,
                    this.esq = data.records[0]?.Esquire__c,
                    this.firstName = data.records[0]?.FirstName;
                    this.suffix = data.records[0]?.Suffix,
                    this.termstartDate = data.records[0]?.Start_Term__c,
                    this.termendDate = data.records[0]?.End_Term__c,
                    this.position = data.records[0]?.Position__c,
                    this.GA = data.records[0]?.GA__c,
                    this.isIndefiniteTerm = data.records[0]?.Indefinite_Term__c,
                    this.judicialDistrict = data.records[0]?.Judicial_District__c,
                    this.SealStampof = data.records[0]?.Seal_Stramp_of__c,
                    this.Notes = data.records[0]?.Notes__c, 
                    this.letterType = data.records[0]?.letterType__c,
                    this.signedBy = data.records[0]?.SignedBy__c

            })
            .catch((error) => {
                console.error('Error fetching data:', error);
            });
    }

    resetFields() {
        this.lastName = null;
        this.prefix = null;
        this.middleInitial = null;
        this.esq = null;
        this.firstName = null;
        this.suffix = null;
        this.termstartDate = null;
        this.termendDate = null;
        this.position = null;
        this.GA = null;
        this.isIndefiniteTerm = null;
        this.judicialDistrict = null;
        this.SealStampof = null;
        this.Notes = null;
        this.letterType = null;
        this.signedBy = null;
        this.wetSign = null;
    }


    async fetchNameHistory() {
        processNameFieldHistory({ contactId: this.idofrecord }) 
        .then(result => {
            console.log('Name History Result:', result);
            this.historyNameRecords = result.map(record => {
                return {
                    changeDate: record.changeDate, 
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

    async fetchTermHistory() {
        processTermFieldHistory({ contactId: this.idofrecord }) 
        .then(result => {
            console.log('Apex Result:', result);
            this.historyTermRecords = result.map(record => {
                return {
                    changeDate: record.changeDate, 
                    endTerm: record.End_Term__c || '',
                    startTerm: record.Start_Term__c || ''
                };
            });
        })
            .catch((error) => {
                console.error('Error fetching history:', error);
            });
    }

    get disabledTerms(){
        if(this.mode == 'view'){ 
            this.positionErrorMessage = '';
            this.startDateErrorMessage = '';
            this.endDateErrorMessage = '';           
            return this.isReadOnly;
        }
        if(this.isIndefiniteTerm == true)
            {
                this.startDateErrorMessage = '';
                this.endDateErrorMessage = ''; 
                this.termstartDate = '';
                this.termendDate = '';
                return true;
            }
        return false;
    }

    get displayTermHistoryRecords(){
        return this.historyTermRecords;
    }
    get displayHistoryRecords() {
        return this.historyNameRecords;
    }
    
    async handleAdd() {
        const isValid = this.validateInputs(); 
        const isValidMsg = this.validateFieldsMsg();
        if (isValid && !this.showError && isValidMsg) {
            const data = {
                Prefix__c: this.prefix,
                FirstName: this.firstName,
                MiddleName: this.middleInitial,
                LastName: this.lastName,
                Suffix__c: this.suffix,
                Start_Term__c: this.termstartDate,
                End_Term__c: this.termendDate,
                Position__c: this.position,
                GA__c: this.GA,
                Indefinite_Term__c: this.isIndefiniteTerm,
                Judicial_District__c: this.judicialDistrict,
                Seal_Stramp_of__c: this.sealstamp,
                Notes__c: this.notes,
                letterType__c: this.letterType,
                SignedBy__c: this.signedBy,
                Wet_Signature__c : this.wetSign,
                Esquire__c : this.esq,
                Id: this.idofrecord
            };
    
            console.log('--data--' + JSON.stringify(data));
            console.log(data);
    
            updatePublicOfficialData({ newRecord: data })
                .then(result => {

                    this.recordId = result;
                    this.idofrecord = result;
                    console.log(this.recordId, this.idofrecord);
                    if (this.idofrecord) {
                        this.showToast('Public Officials', 'Official information is updated successfully!', 'success');
                    } else {
                        this.showToast('Public Officials', 'Official information is created successfully!', 'success');
                    }

                    this.switchToViewMode(this.idofrecord);
                })
                .catch(error => {
                    console.error('Error upserting record:', error);
                    this.showToast('State Seal/Arms', 'Error processing the request. Please try again.', 'error');
                });
        } else {
            // const errorMessage = `Form validation failed. Please address the required fields and errors indicated.`;
            // this.showToast('Error', errorMessage, 'error');
        }
    }

    handleNameKeyDown(event) {
        const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab']; 
    
        // Allow Ctrl+A or Command+A for select all
        if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
            return;
        }
    
        // Allow specific keys like navigation and deletion
        if (allowedKeys.includes(event.key)) {
            return;
        }
    
        // Prevent if key is not a valid letter
        if (!/^[A-Za-z]$/.test(event.key)) {
            event.preventDefault(); 
        }
    }
    


    cloeModels() {
        if(this.mode === 'edit'){
             this.mode = 'view'
             this.refreshData();
         }
         else{
             console.log('into this go to parent code');
             try {
                this.positionErrorMessage='';
                this.startDateErrorMessage='';
                this.endDateErrorMessage='';
                 // Navigate to the RecordDetail component and pass the recordId
                 this[NavigationMixin.Navigate]({
                     type: 'standard__component',
                     attributes: {
                         componentName: 'c__searchOfficials'  // The target component name
                     }
                 });
                 
             } catch (error) {
                 console.error("Error navigating to RecordDetail:", error);
             }
         }
 
     }


    @api
switchToViewMode(recordId) {
    this.isReadOnly = true;
    this.mode = 'view';
    console.log('record id of saved: ', recordId);
    

    if (this.recordId) {
        this.idofrecord = this.recordId;
        this.fetchExistingData();
        this.fetchNameHistory();
        this.fetchTermHistory();
        this.headerText;
    } else {
        console.error('No record ID found for fetching data.');
    }
}

    get headerText() {
        if (!this.idofrecord) {
            return 'Add New Official';
        }
        return this.isReadOnly ? 'View Official' : 'Edit Official';
    }

    get isGenerateButtonDisabled() {        
        return !this.validateInputs(false);
    }

    handleEditClick() {
        this.isReadOnly = false; 
        this.mode = 'edit';
    }

    closeModal() {
        this.close('success');
    }

    validateInputs(showErrors = true) {
        let allValid = true;
        let missingFields = [];
    
        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group, lightning-input-address');
    
        inputComponents.forEach(inputCmp => {
            if (showErrors) {
                inputCmp.reportValidity();
            }
    
            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label); 
            }
        });
    
        if (showErrors && !allValid) {
            const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
            this.showToast('Error', message, 'error');
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

    wetSignOptions(event) {
        this.wetSign = event.target.value;
    }
 
    fetchStaffData() {
        getStateSealStaffData()
            .then((result) => {
                const allowedTitles = ['Deputy Secretary of the State', 'Secretary of the State']; 
                this.signedByOptions = result
                .filter(staff => allowedTitles.includes(staff.Staff_Title__c))
                .map(staff => ({
                    label: `${staff.LastName} ${staff.FirstName}, ${staff.Staff_Title__c}`,
                    value:  staff.Id
                }));
                console.log('SignedBy options:', this.signedByOptions);
            })
            .catch((error) => {
                console.error('Error fetching staff data: ', error);
            });
    }

    get fullName() {
        let name = '';
        if (this.prefix) name += `${this.prefix} `;
        if (this.firstName) name += `${this.firstName} `;
        if (this.middleInitial) name += `${this.middleInitial} `;
        if (this.lastName) name += `${this.lastName}`;
        if (this.suffix) name += ` ${this.suffix}`;
        if (this.esq) name += ', Esq.';
        return name.trim();
    }

    handledownloadLetter() {
        const childComponent = this.template.querySelector('[data-id="pdfgenerator"]');
        if (childComponent) {
            console.log('Child component found:', childComponent);
            const config = {
                recordId: this.recordId,
                fullName: this.fullName,
                signedBy: this.signedBy,
                judicialDistrict: this.judicialDistrict,
                letterType: this.letterType,
                wetSign: this.wetSign,
                position: this.position,
                country: this.country
            };
            childComponent.stateExtraditionPdfGenerator(config);
        } else {
            console.error('Child component not found');
        }
    }


    /***************************************************
       THIS IS THE SECTION OF THE PERSONAL INFORMATION
    ***************************************************/
    @api prefix;
    @api lastName;
    @api middleInitial;
    @api firstName;
    @api suffix;
    @api esq;
    @track prefixSelectOptions = [];
    @track suffixSelectOptions = [];


    @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
    publicOfficialsObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
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
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
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

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        console.log(`Field: ${field}, Value: ${value}`);
        this[field] = value;
    
        if (field === 'termstartDate' || field === 'termendDate') {
            if (this.termstartDate && this.termendDate) {
                if (new Date(this.termendDate) < new Date(this.termstartDate)) {
                    this.isTermEndEarlier = true;
                    this.showError = true;  
                } else {
                    this.isTermEndEarlier = false;
                    this.showError = false;
                }
            }
        }
    }
    

    get termendErrorClass() {
        return this.isTermEndEarlier ? 'slds-form-element slds-has-error' : 'slds-form-element';
    }
    
    get istermendInvalid() {
        return this.isTermEndEarlier && this.showError ;
    }
    


    /***************************************************
       THIS IS THE SECTION OF THE SEARCH OFFICIALS
    ***************************************************/

    @api position;
    @api judicialDistrict = '';
    @api GA;
    @api termstartDate;
    @api termendDate;
    @api isIndefiniteTerm = false;

    @track judicialSelectOptions = [];
    @track positionOptions = [];

    // @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
    // publicOfficialsObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
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
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: LETTERTYPE_FIELD
    })
    letterPicklistValues({ error, data }) {
        if (data) {
            this.letterTypeOptions = data.values.map(letterTypeOptions => ({
                label: letterTypeOptions.label,
                value: letterTypeOptions.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.letterTypeOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: WETSIGN_FIELD
    })
    wetSignPicklistValues({ error, data }) {
        if (data) {
            this.wetSignOptions = data.values.map(wetSignOptions => ({
                label: wetSignOptions.label,
                value: wetSignOptions.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.wetSignOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: JUDICIAL_DISTRICT_FIELD
    })
    judicialPicklistValues({ error, data }) {
        if (data) {
            this.judicialSelectOptions = data.values.map(judicialSelectOptions => ({
                label: judicialSelectOptions.label,
                value: judicialSelectOptions.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.judicialSelectOptions = [];
        }
    }

    /***************************************************
       THIS IS THE SECTION OF THE ACCOUNT SECTION
    ***************************************************/

    @api SealStampof;
    @api Notes;

    /***************************************************
       THIS IS THE SECTION OF THE GENERATE LETTER
    ***************************************************/



    /***************************************************
       THIS IS THE SECTION OF THE TERM & NAME HISTORY
    ***************************************************/
    @api prevfirstName = '';
    @api prevmiddleName = '';
    @api prevlastName = '';
    @api termStartPrev = '';
    @api termEndPrev = '';


    @wire(getLatestHistoryRecords, { recordId: '$recordId' })
    wiredHistoryRecords({ data, error }) {
        if (data) {
            console.log('Data returned from Apex:', JSON.stringify(data));
            this.prevfirstName = data.First_Name__c?.OldValue || '';
            this.prevlastName = data.Last_Name__c?.OldValue || '';
            this.prevmiddleName = data.Middle_Name__c?.OldValue || '';
            this.termStartPrev = data.Term_Start__c?.OldValue || '';
            this.termEndPrev = data.Term_End__c?.OldValue || '';
        } else if (error) {
            console.error('Error fetching history records:', error);
        }
    }

    get displayFirstName() {
        return this.prevfirstName || '-';
    }

    get displayMiddleName() {
        return this.prevmiddleName || '-';
    }

    get displayLastName() {
        return this.prevlastName || '-';
    }

    get displayTermStart() {
        return this.termStartPrev || '-';
    }

    get displayTermEnd() {
        return this.termEndPrev || '-';
    }

    handleShowErrorMessage(event){
        const fieldName = event.target.label;
        this.validateField(fieldName);
    }

    positionErrorMessage='';
    startDateErrorMessage='';
    endDateErrorMessage='';

    validateField(fieldName){
        if (fieldName === 'Position' && !this.position) {
            this.positionErrorMessage = 'Complete this field.';
        } else if (fieldName === 'Term Start Date' && !this.termstartDate) {
            this.startDateErrorMessage = 'Complete this field.';
        } else if (fieldName === 'Term End Date' && !this.termendDate) {
            this.endDateErrorMessage = 'Complete this field.';
        }else{
            this.positionErrorMessage = '';
            this.startDateErrorMessage = '';
            this.endDateErrorMessage = '';
        }
    }

    validateFieldsMsg(){
        let isValidMsg = true;

        if (!this.position) {
            this.positionErrorMessage = 'Complete this field.';
            isValidMsg = false;
        }
        if (!this.termstartDate) {
            this.startDateErrorMessage = 'Complete this field.';
            isValidMsg = false;
        }
        if (!this.termendDate) {
            this.endDateErrorMessage = 'Complete this field.';
            isValidMsg = false;
        }
        return isValidMsg;
    }

}