import { api,track,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_SotsCss from '@salesforce/resourceUrl/sap_SotsCss';
import sap_modalStateSealRequest from '@salesforce/resourceUrl/sap_modalStateSealRequest';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import TITLE_FIELD from '@salesforce/schema/Contact.SAP_Legislator_Title__c';
import PARTY_FIELD from '@salesforce/schema/Contact.SAP_Party__c';
import DISTRICT_FIELD from '@salesforce/schema/Contact.SAP_District__c';
import SUFFIX from '@salesforce/schema/Contact.SAP_Suffix_values__c';
import SALUTATION_FIELD from '@salesforce/schema/Contact.SAP_prefix_values__c';
import fetchLegislativeData from '@salesforce/apex/SAP_LegislatorController.fetchLegislativeData';
import updateLegislativeData from '@salesforce/apex/SAP_LegislatorController.updateLegislativeData';
import { CurrentPageReference } from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';

export default class LegislativeModal extends NavigationMixin(LightningModal) {

@track isReadOnly= false;
@api mode = '';
@api recordId;
@track idofrecord;

@api title;
@track titleSelectOptions = [];
@api party;
@track partySelectOptions = [];
@api district;
@track districtSelectOptions = [];
@api prefix;
@track prefixSelectOptions = [];
@api suffix;
@track suffixSelectOptions = [];
@api lastName;
@api firstName;
@api middleName;
@api personalName;
@api email;
@track isInvalidEmail = false;
@api address1 = '';
@api address2;
@api city;
@api state;
@api zipCode;
@api country;
@api fax;
@api telephone;
@api extension;

@track homeAddress1 = '';
@track homeAddress2 = '';
@track homeCity = '';
@track homeState = '';
@track homeZipCode = '';
@track homeCountry = '';
@track homeFax = '';
@track homeTelephone = '';
@track homeExtension = '';

@track businessAddress1 = '';
@track businessAddress2 = '';
@track businessCity = '';
@track businessState = '';
@track businessZipCode = '';
@track businessCountry = '';
@track businessFax = '';
@track businessTelephone = '';
@track businessExtension = '';

@track isLOBSelected = false;
@track isBusinessSelected = false;
@track isHomeSelected = false;
@track selectedType = '';

@track isSameBusinessAddress = false;
@track isSameHomeAddress = false;

@track isHomeLob = false;
@track isBusinessLob = false;

@track boolAssembly = false;
@track boolSenat= false;
@track boolDist= false;
@track districtName = '';

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        if (pageRef) {
            this.mode = pageRef.state.c__mode; // Access state parameter 'c__message'
            this.recordId = pageRef.state.c__recordId; // Access state parameter recordId
        }

        if (this.recordId) {
            this.idofrecord = this.recordId;
            this.fetchExistingData(); // Fetch contact data if editing an existing record
        }

        if (this.mode === 'view') {
            this.isReadOnly = true;
        } else if (!this.recordId) {
            this.isReadOnly = false;
        }
    }

connectedCallback() {
    Promise.all([
        loadStyle(this, sap_modalStateSealRequest),
        loadStyle(this, sap_SotsCss)
    ])
    .then(() => {
        console.log('Both CSS files loaded successfully');
    })
    .catch(error => {
        console.error('Error loading CSS files:', error);
    });





}

async fetchExistingData() {
    fetchLegislativeData({ recordId: this.idofrecord })
        .then((data) => {
            console.log('Legislative Data coming from Apex:', JSON.stringify(data));
            this.prefix = data.records[0]?.SAP_prefix_values__c || '';
            this.suffix = data.records[0]?.SAP_Suffix_values__c || '';
            this.title = data.records[0]?.SAP_Legislator_Title__c || '';
            this.party = data.records[0]?.SAP_Party__c || '';
            this.district = data.records[0]?.SAP_DistrictID__c || '';
            this.lastName = data.records[0]?.LastName || '';
            this.firstName = data.records[0]?.FirstName || '';
            this.middleName = data.records[0]?.MiddleName || '';
            this.personalName = data.records[0]?.SAP_Personal_Name__c || '';
            this.email = data.records[0]?.Email || '';
            this.address1 = data.records[0]?.MailingStreet || '';
            this.address2 = data.records[0]?.SAP_MailingAddress2__c || '';
            this.city = data.records[0]?.MailingCity || '';
            this.state = data.records[0]?.MailingState || '';
            this.country = data.records[0]?.MailingCountry || '';
            this.zipCode = data.records[0]?.MailingPostalCode || '';
            this.fax = data.records[0]?.Fax || '';
            this.extension = data.records[0]?.SAP_Extension__c || '';
            this.telephone = data.records[0]?.Phone || '';
            this.selectedType = data.records[0]?.SAP_Preffered_address__c || '';

            this.homeAddress1 = data.records[0]?.SAP_Residence_Street_Address_1__c || '';
            this.homeAddress2 = data.records[0]?.SAP_Residence_Street_Address_2__c || '';
            this.homeCity = data.records[0]?.SAP_Residence_City__c || '';
            this.homeState = data.records[0]?.SAP_Residence_State__c || '';
            this.homeCountry = data.records[0]?.SAP_Residence_Country__c || '';
            this.homeZipCode = data.records[0]?.SAP_Residence_Zip_Code__c || '';
            this.homeTelephone = data.records[0]?.SAP_Residential_Phone__c || '';
            this.homeFax = data.records[0]?.SAP_Residential_Fax__c || '';
            this.homeExtension = data.records[0]?.SAP_Residential_Extension__c || '';

            this.businessAddress1 = data.records[0]?.OtherStreet || '';
            this.businessAddress2 = data.records[0]?.SAP_Other_Address2__c || '';
            this.businessCity = data.records[0]?.OtherCity || '';
            this.businessState = data.records[0]?.OtherState || '';
            this.businessCountry = data.records[0]?.OtherCountry || '';
            this.businessZipCode = data.records[0]?.OtherPostalCode || '';
            this.businessTelephone = data.records[0]?.OtherPhone || '';
            this.businessFax = data.records[0]?.SAP_Other_Fax__c || '';
            this.businessExtension = data.records[0]?.SAP_Other_Extension__c || '';

            this.updatePreferredType();
            // Add the logic for setting boolSenat, boolDist, and boolAssembly
            if (this.title === 'Senator') {
                this.boolSenat = true;
                this.boolDist = false;
                this.boolAssembly = false;
            } else if (this.title === 'US Representative') {
                this.boolSenat = false;
                this.boolDist = true;
                this.boolAssembly = false;
            } else if (this.title === 'Representative') {
                this.boolSenat = false;
                this.boolDist = false;
                this.boolAssembly = true;
            } else {
                this.boolSenat = false;
                this.boolDist = false;
                this.boolAssembly = false;
            }
        })
        .catch((error) => {
            console.error('Error fetching data:', error);
        });


    }

    async handleAdd() {
        const isValid = this.validateInputs();
        if (isValid) {
            try {
                const data = {
                    prefix: this.prefix ? this.prefix : '',
                    firstname: this.firstName ? this.firstName : '',
                    middlename: this.middleName ? this.middleName : '',
                    lastname: this.lastName ? this.lastName : '',
                    suffix: this.suffix ? this.suffix : '',
                    title: this.title ? this.title : '',
                    email: this.email ? this.email : '',
                    party: this.party ? this.party : '',
                    address1: this.address1 ? this.address1 : '',
                    address2: this.address2 ? this.address2 : '',
                    city: this.city ? this.city : '',
                    state: this.state ? this.state : '',
                    pincode: this.zipCode ? this.zipCode : '',
                    country: this.country ? this.country : '',
                    telephone: this.telephone ? this.telephone : '',
                    judicialdistrict: this.district ? this.district : '',
                    districtName: this.districtName? this.districtName : '',

                    fax: this.fax ? this.fax : '',
                    extension: this.extension ? this.extension : '',
                    personalname: this.personalName ? this.personalName : '',
                    preferredaddress: this.selectedType ? this.selectedType : '',
                    recordId: this.idofrecord ? this.idofrecord : '',

                    resaddress1: this.businessAddress1 ? this.businessAddress1 : '',
                    resaddress2: this.businessAddress2 ? this.businessAddress2 : '',
                    rescity: this.businessCity ? this.businessCity : '',
                    resstate: this.businessState ? this.businessState : '',
                    respincode: this.businessZipCode ? this.businessZipCode : '',
                    rescountry: this.businessCountry ? this.businessCountry : '',
                    resphone: this.businessTelephone ? this.businessTelephone : '',
                    resfax: this.businessFax ? this.businessFax : '',
                    resextension: this.businessExtension ? this.businessExtension : '',

                    otheraddress1: this.homeAddress1 ? this.homeAddress1 : '',
                    otheraddress2: this.homeAddress2 ? this.homeAddress2 : '',
                    othercity: this.homeCity ? this.homeCity : '',
                    otherstate: this.homeState ? this.homeState : '',
                    otherpincode: this.homeZipCode ? this.homeZipCode : '',
                    othercountry: this.homeCountry ? this.homeCountry : '',
                    otherphone: this.homeTelephone ? this.homeTelephone : '',
                    otherfax: this.homeFax ? this.homeFax : '',
                    otherextension: this.homeExtension ? this.homeExtension : ''
                };
                console.log('data sent to apex for update', data);
                await updateLegislativeData({data});
                console.log('Legislative Data going for update Apex:', JSON.stringify(data));
                console.log('Record saved successfully');
                if (this.idofrecord) {
                    this.showToast('Legislative', 'Request updated successfully!', 'success');
                    this.isReadOnly = true;
                }
            } catch (error) {
                console.error('Error saving record:', error);
                this.showToast('Legislative', 'Error processing the request. Please try again.', 'error');
            }
        } else {
            console.error('Form is not valid');
        }
    }


           // Validate input fields
           validateInputs() {
            let allValid = true;
            let missingFields = [];

            // Get all input components
            const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea,lightning-input-address');

            inputComponents.forEach(inputCmp => {
                // Check each input's validity
                inputCmp.reportValidity();

                if (!inputCmp.checkValidity()) {
                    allValid = false;
                    missingFields.push(inputCmp.label); // Collect labels of invalid fields
                }
            });

            if (!allValid) {
                const message = `Please fill in the required fields`;
                this.showToast('Error', message, 'error');
            }

            return allValid;
        }


    get headerText() {
        return this.isReadOnly ? 'View Legislators  |  ' : 'Edit Legislators';
    }

    handleEditClick() {
        this.isReadOnly = false; // Enable editing
    }

    goBackModal() {
        this.mode = '';
        this.recordId = '';
        this.isReadOnly = false;

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__sap_LegislatorsSearch'  // The target component name
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
      }

    closeModal() {
        this.close();
    }

    // closeModalAfterSave() {
    //     setTimeout(() => {
    //         this.closeModal();
    //     }, 2000);
    // }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: TITLE_FIELD
    })
    titlePicklistValues({ error, data }) {
        if (data) {
            this.titleSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.titleSelectOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SUFFIX
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

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PARTY_FIELD
    })
    partyPicklistValues({ error, data }) {
        if (data) {
            this.partySelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.partySelectOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: DISTRICT_FIELD
    })
    districtPicklistValues({ error, data }) {
        if (data) {
            this.districtSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.districtSelectOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SALUTATION_FIELD
    })
    salutationPicklistValues({ error, data }) {
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

handleFieldChange(event) {
    const field = event.target.name;
    if(field === 'telephone' || field === 'businessTelephone' || field === 'homeTelephone'){
        const formattedNumber = this.formatPhoneNumber(event.target.value);
            this[field] = formattedNumber;
    }else{
    this[field] = event.target.value;
    }
    this.syncInputs();
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

handleTitleChange(event) {
    this.title = event.target.value;
    if(this.title === 'Senator'){
        this.boolSenat= true;
        this.boolDist= false;
        this.boolAssembly = false;
        this.districtName = 'Senatorial District';

    }else if(this.title === 'US Representative'){

        this.boolSenat= false;
        this.boolDist= true;
        this.boolAssembly = false;
        this.districtName = 'District';

    }else if(this.title === 'Representative'){
        this.boolSenat= false;
        this.boolDist= false;
        this.boolAssembly = true;
        this.districtName = 'Assembly District';
    }else{
        this.boolSenat= false;
        this.boolDist= false;
        this.boolAssembly = false;
        this.districtName = '';
    }
}

handlePrefixChange(event) {
    this.prefix = event.target.value;
}

handleSuffixChange(event) {
    this.suffix = event.target.value;
}

handleemailChange(event) {
    this.email = event.target.value;
    this.isInvalidEmail = false;
    this.syncInputs();
}

validateEmailAddress() {
    this.isInvalidEmail = !this.validateEmail(this.email);
}

validateEmail(email) {
    // Simple regex for email validation
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

handleAddressChange(event) {
    this.address1 = event.detail.street ? event.detail.street : '';
    this.city = event.detail.city;
    this.address2= event.detail.subpremise;
    this.state = event.detail.province;
    this.zipCode = event.detail.postalCode;
    this.country = event.detail.country;
    this.syncInputs();
}

handlePrefferedAddressChange(event) {
    const type = event.target.dataset.type;
    if (type === 'LOB') {
        this.isLOBSelected = true;
        this.isBusinessSelected = false;
        this.isHomeSelected = false;
        this.selectedType = 'LOB';
    } else if (type === 'Business') {
        this.isLOBSelected = false;
        this.isBusinessSelected = true;
        this.isHomeSelected = false;
        this.selectedType = 'Business';
    }
    else if (type === 'Home') {
        this.isLOBSelected = false;
        this.isBusinessSelected = false;
        this.isHomeSelected = true;
        this.selectedType = 'Home';
    }
}

updatePreferredType(){
    if (this.selectedType == 'LOB') {
        this.isLOBSelected = true;
        this.isBusinessSelected = false;
        this.isHomeSelected = false;
    } else if (this.selectedType == 'Business') {
        this.isLOBSelected = false;
        this.isBusinessSelected = true;
        this.isHomeSelected = false;
    }
    else if (this.selectedType == 'Home') {
        this.isLOBSelected = false;
        this.isBusinessSelected = false;
        this.isHomeSelected = true;
    }
}

syncInputs() {
    if (this.isSameBusinessAddress) {
        this.businessAddress1 = this.address1;
        this.businessAddress2 = this.address2;
        this.businessCity = this.city;
        this.businessState = this.state;
        this.businessZipCode = this.zipCode;
        this.businessCountry = this.country;
        this.businessFax = this.fax;
        this.businessTelephone = this.telephone;
        this.businessExtension = this.extension;
    }
    if (this.isSameHomeAddress) {
        this.homeAddress1 = this.address1;
        this.homeAddress2 = this.address2;
        this.homeCity = this.city;
        this.homeState = this.state;
        this.homeZipCode = this.zipCode;
        this.homeCountry = this.country;
        this.homeFax = this.fax;
        this.homeTelephone = this.telephone;
        this.homeExtension = this.extension;
    }
}

get isDisabledBusiness() {
    return this.isReadOnly || this.isBusinessLob;
}

get isDisabledHome() {
    return this.isReadOnly || this.isHomeLob;
}

handleLobBusinessAddressChange(event) {
    let isValueCkecked = false;
    isValueCkecked = event.target.checked;
    this.isSameBusinessAddress = isValueCkecked;
    if (this.isSameBusinessAddress) {
        this.syncInputs();
        this.isBusinessLob = true;
    } else {
        this.isBusinessLob = false;
        this.businessAddress1 = '';
        this.businessAddress2 = '';
        this.businessCity = '';
        this.businessState = '';
        this.businessZipCode = '';
        this.businessCountry = '';
        this.businessFax = '';
        this.businessTelephone = '';
        this.businessExtension = '';
    }
}


handleLobHomeAddressChange(event) {
    let isValueCkecked = false;
    isValueCkecked = event.target.checked;
    this.isSameHomeAddress = isValueCkecked;
    if (this.isSameHomeAddress) {
        this.syncInputs();
        this.isHomeLob = true;
    } else {
        this.isHomeLob = false;
        this.homeAddress1 = '';
        this.homeAddress2 = '';
        this.homeCity = '';
        this.homeState = '';
        this.homeZipCode = '';
        this.homeCountry = '';
        this.homeFax = '';
        this.homeTelephone = '';
        this.homeExtension = '';
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

}