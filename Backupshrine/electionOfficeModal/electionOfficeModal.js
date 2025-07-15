import { track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import modalStateSealRequest from '@salesforce/resourceUrl/modalStateSealRequest';
import { loadStyle } from 'lightning/platformResourceLoader';
import SotsCss from '@salesforce/resourceUrl/SotsCss';
import upsertOffice from '@salesforce/apex/AddOfficeController.upsertOffice';
import fetchOfficeAndDistrictData from '@salesforce/apex/AddOfficeController.fetchOfficeAndDistrictData';
import getDistrictOptions from '@salesforce/apex/AddOfficeController.getDistrictOptions';
import getNextMaxId from '@salesforce/apex/AddOfficeController.getNextMaxId';

export default class ElectionOfficeModal extends LightningModal {
    @track formData = {
        id: '',
        name: '',
        electionHeldIn: '',
        congDist: '',
        congDistId: '',
        houseDist: '',       // String to hold comma-separated House Assembly Districts
        houseDistIds: [],    // Array to hold House Assembly District IDs
        senatorialDist: '',  // String to hold comma-separated Senatorial Districts
        senatorialDistIds: [],  // Array to hold Senatorial District IDs
        email: '',
        rovName: '',
        rovOffice: '',
        title: '',
        address1: '',
        address2: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
        recordId: '',
        mode: '',
        officeType: ''
    };

    @api officeType = '';
    @api mode = '';
    @api recordId;
    @track districtValid = true;

    @track headerText;
    @track isReadOnly = false;
    @track isTownAdd = false;
    @track isCityAdd = false;
    @track isStateAdd = false;
    AddStateClicked='Save' ;

    @track congressionalOptions = [];
    @track houseAssemblyOptions = [];
    @track senatorialOptions = [];

    electionHeldInOptions = [
        { label: 'Both', value: 'Both' },
        { label: 'May', value: 'May' },
        { label: 'November', value: 'Nov' }
    ];

    connectedCallback() {

        history.pushState({ modalOpen: true }, '');
        window.addEventListener('popstate', this.handleBackButton.bind(this));

        Promise.all([
            loadStyle(this, modalStateSealRequest),
            loadStyle(this, SotsCss)
        ]).then(() => {
            console.log('Both CSS files loaded successfully');
        }).catch(error => {
            console.error('Error loading CSS files:', error);
        });
        this.formData.officeType = this.officeType;

        // Determine which form to display based on officeType
        if (this.officeType === 'Town') {
            this.isTownAdd = true;
        } else if (this.officeType === 'City') {
            this.isCityAdd = true;
        } else if (this.officeType === 'State') {
            this.isStateAdd = true;
        }

        // Fetch office details if recordId is provided
        if (this.recordId) {
            this.formData.recordId = this.recordId;
            this.fetchOfficeDetails();
        }

        // Determine the mode (view/edit) based on inputs
        if (this.mode === 'view') {
            this.isReadOnly = true;
        } else if (!this.recordId) {
            this.isReadOnly = false;
        }
        if (this.mode === 'Add') {
            // Call the Apex function to get the next max ID
            getNextMaxId()
                .then((result) => {
                    // Assign the result to this.formdata.id
                    this.formData.id = result;
                })
                .catch((error) => {
                    console.error('Error fetching max ID:', error);
                });
        }



        // Set the initial header text
        this.updateHeaderText();

        // Fetch the available district options
        this.fetchDistrictOptions();
    }

    disconnectedCallback() {
        // Remove the listener for `popstate` event
        window.removeEventListener('popstate', this.handleBackButton.bind(this));
    }

    handleBackButton(event) {
        if (history.state && history.state.modalOpen) {
            // Close modal and prevent default navigation
            this.closeModal();
            event.preventDefault();
        }
    }

    get isOfficeType(){
        return this.mode === 'view' || this.mode === 'edit';
    }

    get viewEditDisable(){
        if(this.mode === 'view' || this.mode === 'edit'){
            return true;
        }else{
            return false;
        }
    }

    get istownAdd(){
        if(this.officeType === 'Town'){
            return true;
        }else{
            return false;
        }
    }

    fetchDistrictOptions() {
        getDistrictOptions()
            .then(result => {
                // Populate the options for each district type

                this.congressionalOptions = result['Congressional'].map(item => {
                    return { label: item.label, value: item.value };
                });
                this.houseAssemblyOptions = result['House Assembly'].map(item => {
                    return { label: item.label, value: item.value };
                });
                this.senatorialOptions = result['Senatorial'].map(item => {
                    return { label: item.label, value: item.value };
                });

                console.log(this.congressionalOptions, this.houseAssemblyOptions, this.senatorialOptions);
            })
            .catch(error => {
                console.error('Error fetching district options:', error);
            });
    }

    updateHeaderText() {
        if (this.mode === 'view') {
            this.headerText = `View Election Office by ${this.officeType}`;
        } else if (this.formData.recordId) {
            this.headerText = `Edit Election Office by ${this.officeType}`;
            this.AddStateClicked='Save';
        } else {
            this.headerText = `Add ${this.officeType}`;
            this.AddStateClicked = `Add ${this.officeType}`;
        }
    }

    fetchOfficeDetails() {
        fetchOfficeAndDistrictData({ recordId: this.recordId })
            .then(data => {
                if (data) {
                    // Ensure field mappings are correct, and update the formData accordingly
                    this.formData = {
                        ...this.formData,
                        id: data.office.Id__c,
                        name: this.toTitleCase(data.office.Name__c || ''),
                        electionHeldIn: data.office.Election_Held_In__c,
                        email: data.office.Business_Email__c,
                        rovName: data.office.ROV_Name__c,
                        title: this.toTitleCase(data.office.Title__c || ''),
                        address1: this.toTitleCase(data.office.Mailing_Address_Line_1__c || ''),
                        address2: data.office.Mailing_Address_Line_2__c || '',
                        city: this.toTitleCase(data.office.Mailing_Address_City__c || ''),
                        state: data.office.Mailing_Address_State__c,
                        zipCode: data.office.Mailing_Address_Zip__c,
                        country: data.office.Mailing_Address_Country__c,
                        congDist: data.congDistLabel,
                        congDistId: data.congDistId,
                        houseDist: data.houseDistLabels.join(', '),
                        houseDistIds: data.houseDistIds,
                        senatorialDist: data.senatorialDistLabels.join(', '),
                        senatorialDistIds: data.senatorialDistIds
                    };
                }
            })
            .catch(error => {
                console.error('Error fetching office and district data:', error);
            });
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

    // Function to restrict input for Congressional District (Allow only numbers and spaces)
restrictCongressionalKeyInput(event) {
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

// Function to restrict input for House Assembly and Senatorial Districts (Allow numbers, commas, and spaces)
restrictHouseSenatorialKeyInput(event) {
    // Key code references
    const key = event.key;

    // Allow only numbers (0-9), commas, spaces, backspace, arrow keys, delete, and tab
    const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', ','];
    const isNumber = /^\d$/.test(key);  // Check if the pressed key is a number

    // Block any key that is not a number, comma, or space, or one of the valid keys
    if (!isNumber && key !== ' ' && !validKeys.includes(key)) {
        event.preventDefault();
    }
}


    // Utility function to capitalize the first letter of each word (title case)
    toTitleCase(str) {
        if(!str) return '';
        return str.replace(/\w\S*/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase());
    }


    handleInputChange(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value.trim();

        // Apply title case to specific fields
        if (['name', 'title', 'address1', 'city'].includes(fieldName)) {
            fieldValue = this.toTitleCase(fieldValue);
        }

        // Update form data for the relevant field
        this.formData[fieldName] = fieldValue;
    }




    handleEditClick() {
        this.isReadOnly = false;
        this.mode = 'edit';
        this.updateHeaderText();
    }

    closeModal() {
        //history.back();
        this.close();
    }

    handleAdd() {
        console.log('In add');
        // Step 1: Validate form inputs
        const isValidForm = this.validateInputs();

        // Step 2: Validate and store district IDs
        if(this.officeType === 'Town'){
        const isValidDistricts = this.validateAndStoreDistrictIds();
        this.districtValid = isValidDistricts;
        console.log(this.districtValid);
        }

        // Step 3: Check if all validations passed
        if (isValidForm && this.districtValid) {
            this.formData.officeType = this.officeType;

            console.log(this.formData);

            // Proceed with saving the record since all validations passed
            upsertOffice({ formData: this.formData })
                .then((result) => {
                    this.formData.recordId = result;
                    this.updateHeaderText();
                    this.showToast('Success', 'Record saved successfully.', 'success');
                    this.close();
                })
                .catch((error) => {
                    console.error('Error upserting office:', error);
                    this.showToast('Error', 'Error saving record.', 'error');
                });
        }
    }

    validateInputs() {
        let allValid = true;
        let missingFields = [];

        // Collect all input and address components for validation
        const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-input-address');

        inputComponents.forEach(inputCmp => {
            inputCmp.reportValidity();
            if (!inputCmp.checkValidity()) {
                allValid = false;
                missingFields.push(inputCmp.label); // Track missing or invalid fields
            }
        });

        // Show a toast with the list of missing or invalid fields
        if (!allValid) {
            const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
            console.log('message'+message);


            //this.showToast('Error', message, 'error');
        }
        console.log('Return balid');

        return allValid; // Return whether all inputs are valid
    }

    // Step 2: Validate District fields
    validateAndStoreDistrictIds() {
        const isCongValid = this.validateCongressionalDistrict();
        const isHouseValid = this.validateHouseAssemblyDistrict();
        const isSenatorialValid = this.validateSenatorialDistrict();
        console.log(isCongValid,isHouseValid,isSenatorialValid);

        let errorMessage =  'Invalid ';
        if(!isCongValid){
            errorMessage += 'Congressional District, ';
        }
        if(!isHouseValid){
            errorMessage += 'Assembly District, ';
        }
        if(!isSenatorialValid){
            errorMessage += 'Senatorial District ';
        }

        errorMessage += 'Please enter a valid value.'

        if(!isCongValid || !isHouseValid  || !isSenatorialValid){
            this.showToast('Error', errorMessage, 'error');
            return false;
        }
        // Return true only if all district validations are successful
        return isCongValid && isHouseValid && isSenatorialValid;
    }

   // Validate Congressional District
    validateCongressionalDistrict() {
        if (this.formData.congDist) {
            const matchingCongOption = this.congressionalOptions.find(option => option.label === this.formData.congDist);
            if (matchingCongOption) {
                this.formData.congDistId = matchingCongOption.value;
                return true;
            } else {
                //this.showToast('Error', 'Invalid Congressional District. Please enter a valid value.', 'error');
                return false;
            }
        }
        return true; // If field is not required or empty, return true by default
    }

    // Validate House Assembly Districts
    validateHouseAssemblyDistrict() {
        const houseDistIds = [];
        const invalidHouseDistricts = [];

        // Split input string, sort it numerically, and join back to the formData
        const houseDistricts = this.formData.houseDist.split(',').map(district => district.trim()).map(Number).sort((a, b) => a - b);
        this.formData.houseDist = houseDistricts.join(', ');

        // Validate each sorted district against the available options
        houseDistricts.forEach(district => {
            const matchingOption = this.houseAssemblyOptions.find(option => option.label === String(district));
            if (matchingOption) {
                houseDistIds.push(matchingOption.value);
            } else {
                invalidHouseDistricts.push(district);
            }
        });

        if (invalidHouseDistricts.length > 0) {
            //this.showToast('Error', `Invalid House Assembly District(s): ${invalidHouseDistricts.join(', ')}. Please enter valid values.`, 'error');
            return false;
        }

        this.formData.houseDistIds = houseDistIds;
        return true;
    }


    // Validate Senatorial Districts
    // Validate Senatorial Districts
    validateSenatorialDistrict() {
        const senatorialDistIds = [];
        const invalidSenatorialDistricts = [];

        // Split input string, sort it numerically, and join back to the formData
        const senatorialDistricts = this.formData.senatorialDist.split(',').map(district => district.trim()).map(Number).sort((a, b) => a - b);
        this.formData.senatorialDist = senatorialDistricts.join(', ');

        // Validate each sorted district against the available options
        senatorialDistricts.forEach(district => {
            const matchingOption = this.senatorialOptions.find(option => option.label === String(district));
            if (matchingOption) {
                senatorialDistIds.push(matchingOption.value);
            } else {
                invalidSenatorialDistricts.push(district);
            }
        });

        if (invalidSenatorialDistricts.length > 0) {
            //this.showToast('Error', `Invalid Senatorial District(s): ${invalidSenatorialDistricts.join(', ')}. Please enter valid values.`, 'error');
            return false;
        }

        this.formData.senatorialDistIds = senatorialDistIds;
        return true;
    }



   // Utility method to show toast messages
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
}