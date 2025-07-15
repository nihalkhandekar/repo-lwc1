import { LightningElement } from 'lwc';
import sap_stateSealM from '@salesforce/resourceUrl/sap_stateSealM';
import sap_removeHeadingStateSeal from '@salesforce/resourceUrl/sap_removeHeadingStateSeal';
import getDistrictOptions from '@salesforce/apex/SAP_AddOfficeController.getDistrictOptions';
import getTownOffices from '@salesforce/apex/SAP_RedistrictingController.getTownOffices';
import getElectionOffices from '@salesforce/apex/SAP_RedistrictingController.getElectionOffices';
import getElectionOfficesCount from '@salesforce/apex/SAP_RedistrictingController.getElectionOfficesCount';
import updateOfficeDistrictMappings from '@salesforce/apex/SAP_RedistrictingController.updateOfficeDistrictMappings'
import sap_PublicOfficialRedistrictingModal from 'c/sap_PublicOfficialRedistrictingModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PublicOfficialRedistricting extends LightningElement {
    congressionalOptions = [];
    houseAssemblyOptions = [];
    senatorialOptions = [];
    sbtOptions = []; // Town Office options
    

    townsOffice = '';
    phoneNumber = '';
    congressionalDistId = '';
    houseAssemblyDistId = '';
    senatorialDistId = '';
    congressionalDist = '';
    houseAssemblyDist = '';
    senatorialDist = '';
    transactionsFoundLabel = '0';
    paginatedResult = [];
    originalData = []; // Store original data for undo/cancel
    showResults = false;
    currentPage = 1;
    totalPages = 0;
    totalRecords = 0;
    recordsPerPage = 10;
    startRange = 1;
    endRange = 0;
    sortedBy = 'SAP_Name__c';
    sortedDirection = 'ASC';
    electionOfficeBy = 'Town';
    exportResultClicked = false;
    isEditing = false;

    connectedCallback() {
        // Load the external styles first

        // Push state to history when modal opens
        history.pushState({ modalOpen: true }, '');
        window.addEventListener('popstate', this.handleBackButton.bind(this));


        document.addEventListener('click', this.handleOutsideClick.bind(this));
        Promise.all([loadStyle(this, sap_stateSealM), loadStyle(this, sap_removeHeadingStateSeal)])
            .then(() => {
                // After styles are loaded, fetch both district options and town offices
                return Promise.all([this.fetchDistrictOptions(), this.fetchTownOffices()]);
            })
            .then(() => {
                // After both district options and town offices are loaded, load the application data
                this.loadApplications();
            })
            .catch(error => {
                console.error('Error loading styles or fetching data:', error);
            });
    }

    disconnectedCallback() {
       document.removeEventListener('click', this.handleOutsideClick.bind(this));

        window.removeEventListener('popstate', this.handleBackButton.bind(this));
    }

    handleBackButton(event) {
        if (history.state && history.state.modalOpen) {
            // Close modal and prevent default navigation
            this.closeModal();
            event.preventDefault();
        }
    }
    

    fetchTownOffices() {
        return getTownOffices() // Return the promise
            .then(result => {
                this.sbtOptions = result.map(item => ({ label: item.label, value: item.value }));
            })
            .catch(error => {
                console.error('Error fetching town offices:', error);
            });
    }
    

    fetchDistrictOptions() {
        getDistrictOptions() // Assuming this is the Apex method
            .then(result => {
                if (result && result.Congressional && result['House Assembly'] && result.Senatorial) {
                    // Sort the options numerically by label for each district type
                    this.congressionalOptions = result.Congressional
                        .map(item => ({ label: item.label, value: item.value, selected: false }))
                        .sort((a, b) => Number(a.label) - Number(b.label)); // Sort numerically
                    
                    this.houseAssemblyOptions = result['House Assembly']
                        .map(item => ({ label: item.label, value: item.value, selected: false }))
                        .sort((a, b) => Number(a.label) - Number(b.label)); // Sort numerically
                    
                    this.senatorialOptions = result.Senatorial
                        .map(item => ({ label: item.label, value: item.value, selected: false }))
                        .sort((a, b) => Number(a.label) - Number(b.label)); // Sort numerically
                } else {
                    console.error('District options are missing expected data.');
                }
            })
            .catch(error => {
                console.error('Error fetching district options:', error);
            });
    }
    
    
    
    
    
    loadApplications() {
        const searchCriteria = this.buildSearchCriteria();
        console.log(searchCriteria);

        const searchCriteriaJson = JSON.stringify(searchCriteria);
        
        getElectionOffices({searchCriteriaJson})
            .then(result => {
                this.paginatedResult = result.map(wrapper => {
                    // Sorting House Assembly Districts numerically
                    const sortedHouseAssemblyDist = (wrapper.houseAssemblyDist || '').split(',')
                        .map(dist => dist.trim()) // Trim whitespace
                        .map(Number) // Convert to numbers
                        .sort((a, b) => a - b) // Sort numerically
                        .join(', '); // Join back to a string
    
                    // Sorting Senatorial Districts numerically
                    const sortedSenatorialDist = (wrapper.senatorialDist || '').split(',')
                        .map(dist => dist.trim()) // Trim whitespace
                        .map(Number) // Convert to numbers
                        .sort((a, b) => a - b) // Sort numerically
                        .join(', '); // Join back to a string
    
                    return {
                        Id: wrapper.office.Id,
                        PhoneNumber: wrapper.phoneNumber || '',
                        SAP_Name__c: wrapper.office.SAP_Name__c,
                        congressionalDist: wrapper.congressionalDist || '',
                        houseAssemblyDist: sortedHouseAssemblyDist || '',
                        senatorialDist: sortedSenatorialDist || '',
                        
                        // Ensure the options for each district are computed and sorted numerically
                        congressionalOptions: this.computeOptions(wrapper.congressionalDist, this.congressionalOptions),
                        houseAssemblyOptions: this.computeOptions(wrapper.houseAssemblyDist, this.houseAssemblyOptions),
                        senatorialOptions: this.computeOptions(wrapper.senatorialDist, this.senatorialOptions)
                    };
                });
                this.originalData = JSON.parse(JSON.stringify(this.paginatedResult)); // Deep copy of the data
                this.updateRecordCountOffice();
                this.showResults = true;
                // Set the range for the current page
                this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
                this.endRange = this.startRange + this.paginatedResult.length - 1;
            })
            .catch(error => {
                console.error('Error loading applications:', error);
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
    
    
    

    // Method to handle input change for lightning-input and lightning-combobox
    handleInputChange(event) {
        const fieldName = event.target.name; // Get the name of the field that triggered the event
        const fieldValue = event.target.value; // Get the value from the input

        // Update the corresponding field value based on the name
        if (fieldName === 'townsOffice') {
            this.townsOffice = fieldValue;
        }
        // Validation for Congressional District: Only numeric values allowed
        if (fieldName === 'congressionalDist') {
            if (!/^\d+$/.test(fieldValue)) {
                this.showToast('Error', 'Please enter a valid numeric Congressional District.', 'error');
                return;
            }
            this.congressionalDist = fieldValue;
            this.validateCongressionalDistrict();
        }
    
        // Validation for House Assembly District: Numbers and commas only
        if (fieldName === 'houseAssemblyDist') {
            if (!/^\d+$/.test(fieldValue)) {
                this.showToast('Error', 'Please enter valid House Assembly District(s), separated by commas.', 'error');
                return;
            }
            this.houseAssemblyDist = fieldValue;
            this.validateHouseAssemblyDistrict();
        }
    
        // Validation for Senatorial District: Numbers and commas only
        if (fieldName === 'senatorialDist') {
            if (!/^\d+$/.test(fieldValue)) {
                this.showToast('Error', 'Please enter valid Senatorial District(s), separated by commas.', 'error');
                return;
            }
            this.senatorialDist = fieldValue;
            this.validateSenatorialDistrict();
        }

        if(fieldName === 'phoneNumber'){
            this.phoneNumber = this.formatPhoneNumber(fieldValue);
        }
    }
    formatPhoneNumber(phoneNumberString) {
        let cleaned = phoneNumberString.replace(/\D/g, '');
        
        cleaned = cleaned.substring(0, 10);
        
        if (cleaned.length >= 6) {
            return `${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
        } else if (cleaned.length >= 3) {
            return `${cleaned.substring(0, 3)}-${cleaned.substring(3)}`;
        } else if (cleaned.length > 0) {
            return `${cleaned}`;
        }
        return '';
    }

    // Validate Congressional District
    validateCongressionalDistrict() {
        if (this.congressionalDist) {
            const matchingCongOption = this.congressionalOptions.find(option => option.label === this.congressionalDist);
            if (matchingCongOption) {
                this.congressionalDistId = matchingCongOption.value;
                return true;
            } else {
                this.showToast('Error', 'Invalid Congressional District. Please enter a valid value.', 'error');
                return false;
            }
        }
        return true; // If field is not required or empty, return true by default
    }

    // Validate House Assembly Districts
    validateHouseAssemblyDistrict() {

        if (this.houseAssemblyDist) {
            const matchingCongOption = this.houseAssemblyOptions.find(option => option.label === this.houseAssemblyDist);
            if (matchingCongOption) {
                this.houseAssemblyDistId = matchingCongOption.value;
                return true;
            } else {
                this.showToast('Error', 'Invalid House Assembly District. Please enter a valid value.', 'error');
                return false;
            }
        }
        return true; // If field is not required or empty, return true by default
    }

    // Validate Senatorial Districts
    validateSenatorialDistrict() {
        if (this.senatorialDist) {
            const matchingCongOption = this.senatorialOptions.find(option => option.label === this.senatorialDist);
            if (matchingCongOption) {
                this.senatorialDistId = matchingCongOption.value;
                return true;
            } else {
                this.showToast('Error', 'Invalid House Assembly District. Please enter a valid value.', 'error');
                return false;
            }
        }
        return true; // If field
    }

    buildSearchCriteria() {
        return {
            electionOfficeBy: this.electionOfficeBy || '',
            congressionalDistId: this.congressionalDistId || '',
            houseAssemblyDistId: this.houseAssemblyDistId || '',
            senatorialDistId: this.senatorialDistId || '',
            townsElectionOffice: this.townsOffice || '',
            phoneNumber: this.phoneNumber || '',
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'SAP_Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };
    }

    updateRecordCountOffice() {
        const searchCriteria = this.buildSearchCriteria();
        const searchCriteriaJson = JSON.stringify(searchCriteria);
        
        getElectionOfficesCount({searchCriteriaJson})
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.transactionsFoundLabel = `${this.totalRecords} Found`;
            })
            .catch(error => {
                console.error('Error fetching record count:', error);
            });
    }

    // Handle selection from the dropdown menu
    handleMenuSelect(event) {
        const selectedValue = event.detail.value;
        const rowId = event.target.dataset.rowId;
        const districtType = event.target.dataset.type;
        const rowIndex = this.paginatedResult.findIndex(row => row.Id === rowId);
        if (rowIndex !== -1) {
            const row = this.paginatedResult[rowIndex];
            if (districtType === 'congressional') {
                const selectedLabel = this.congressionalOptions.find(option => option.value === selectedValue).label;
                row.congressionalDist = selectedLabel;
            } else if (districtType === 'houseAssembly') {
                this.updateMultiSelect(row, selectedValue, 'houseAssemblyDist', 'houseAssemblyOptions');
            } else if (districtType === 'senatorial') {
                this.updateMultiSelect(row, selectedValue, 'senatorialDist', 'senatorialOptions');
            }
            this.paginatedResult = [...this.paginatedResult];  // Force reactivity
        }
    }
    
    toggleDropdown(event) {
        event.stopPropagation();
        const buttonElement = event.target;
        const rowId = buttonElement.dataset.rowId;
        const dropdownType = buttonElement.dataset.type;

        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isCongressionalDropdownOpen: dropdownType === 'congressional' && row.Id === rowId ? !row.isCongressionalDropdownOpen : false,
                isHouseAssemblyDropdownOpen: dropdownType === 'houseAssembly' && row.Id === rowId ? !row.isHouseAssemblyDropdownOpen : false,
                isSenatorialDropdownOpen: dropdownType === 'senatorial' && row.Id === rowId ? !row.isSenatorialDropdownOpen : false
            };
        });

        //this.positionDropdown(buttonElement);
    }

    preventDropdownClose(event) {
        event.stopPropagation(); // Prevent this click from triggering handleOutsideClick
    }
    

    handleOutsideClick(event) {
        try {
            // Ensure event.target exists and is a valid node
            if (!event.target || !(event.target instanceof Node)) {
                console.warn('Event target is not valid:', event.target);
                return; // Safeguard against invalid event targets
            }
    
            // If the click is inside a dropdown or the component, ignore it
            if (event.target.closest('[data-dropdown]')) {
                return;
            }
    
            // Click happened outside the component, close all dropdowns
            this.closeAllDropdowns();
        } catch (error) {
            console.error('Error in handleOutsideClick:', error);
        }
    }
    
    

    closeAllDropdowns() {
        this.paginatedResult = this.paginatedResult.map(row => ({
            ...row,
            isCongressionalDropdownOpen: false,
            isHouseAssemblyDropdownOpen: false,
            isSenatorialDropdownOpen: false
        }));
        this.isDropdownOpen = false;
    }


    positionDropdown(buttonElement) {
        const dropdownList = buttonElement.nextElementSibling;
    
        // Ensure the dropdownList exists before accessing its properties
        if (!dropdownList) {
            console.error('Dropdown list not found for positioning');
            return;
        }
    
        // Get button dimensions
        const buttonRect = buttonElement.getBoundingClientRect();
        const parentRect = buttonElement.closest('.button-cell').getBoundingClientRect();
    
        // Reset initial dropdown styles for positioning
        dropdownList.style.position = 'absolute';
        dropdownList.style.minWidth = `${parentRect.width}px`;  // Ensure dropdown fits the button width
        dropdownList.style.left = `${parentRect.left}px`;  // Align dropdown to the left of the button
    
        // Calculate available space below and above the button
        const spaceBelow = window.innerHeight - buttonRect.bottom;
        const spaceAbove = buttonRect.top;
        
        // Adjust dropdown position based on available space
        if (spaceBelow > dropdownList.scrollHeight) {
            // If enough space is below, display dropdown below the button
            dropdownList.style.top = `${buttonRect.bottom + window.scrollY}px`;  // Include scroll position
            dropdownList.classList.remove('dropdown-above');
        } else if (spaceAbove > dropdownList.scrollHeight) {
            // If enough space is above, display dropdown above the button
            dropdownList.style.top = `${buttonRect.top - dropdownList.scrollHeight + window.scrollY}px`;  // Include scroll position
            dropdownList.classList.add('dropdown-above');
        } else {
            // Default: Display below if no other options are available
            dropdownList.style.top = `${buttonRect.bottom + window.scrollY}px`;
            dropdownList.classList.remove('dropdown-above');
        }
        
        // Handle positioning for overflow situations (right and left alignment)
        const dropdownRightEdge = parentRect.left + dropdownList.offsetWidth;
        if (dropdownRightEdge > window.innerWidth) {
            // If dropdown overflows beyond the right edge, align it to the right
            dropdownList.style.left = `${window.innerWidth - dropdownList.offsetWidth - 10}px`;  // Adjust to fit within the window
        } else {
            // Align dropdown left to parent by default
            dropdownList.style.left = `${parentRect.left}px`;
        }
    }
    
    
    
    
    
    
    handleCheckboxChange(event) {
        const selectedValue = event.target.value;
        const rowId = event.target.dataset.rowId;
        const districtType = event.target.dataset.type;
        const isChecked = event.target.checked;
    
        const rowIndex = this.paginatedResult.findIndex(row => row.Id === rowId);
        if (rowIndex !== -1) {
            const row = this.paginatedResult[rowIndex];
            console.log(`Handling checkbox change for rowId: ${rowId}, districtType: ${districtType}, checked: ${isChecked}`);
    
            // Update the selected values based on the type of dropdown
            if (districtType === 'congressional') {
                this.updateSingleSelect(row, selectedValue, isChecked, 'congressionalDist', 'congressionalOptions');
            } else if (districtType === 'houseAssembly') {
                this.updateMultiSelect(row, selectedValue, isChecked, 'houseAssemblyDist', 'houseAssemblyOptions');
            } else if (districtType === 'senatorial') {
                this.updateMultiSelect(row, selectedValue, isChecked, 'senatorialDist', 'senatorialOptions');
            }
    
            // Force reactivity to update UI
            this.paginatedResult = [...this.paginatedResult];
        }
    }

    // Method to handle radio change events
    handleRadioChange(event) {
        const selectedValue = event.target.value;
        const rowId = event.target.dataset.rowId;

        const rowIndex = this.paginatedResult.findIndex(row => row.Id === rowId);
        if (rowIndex !== -1) {
            const row = this.paginatedResult[rowIndex];
            row.congressionalDist = this.congressionalOptions.find(option => option.value === selectedValue)?.label || '';
            row.congressionalOptions = row.congressionalOptions.map(option => ({
                ...option,
                selected: option.value === selectedValue
            }));
            this.paginatedResult = [...this.paginatedResult];
        }
    }
    
    
    
    updateSingleSelect(row, selectedValue, isChecked, distField, optionsField) {
        // Check if the options array is defined
        const options = this[optionsField];
        if (!options || !Array.isArray(options)) {
            console.error(`Options field ${optionsField} is not defined or is not an array.`);
            return;
        }
    
        const selectedOption = options.find(option => option.value === selectedValue);
        if (selectedOption) {
            const selectedLabel = selectedOption.label;
    
            if (isChecked) {
                row[distField] = selectedLabel;  // Set selected value
            } else {
                row[distField] = '';  // Deselect the option
            }
    
            // Update the options list to reflect the selected state
            row[optionsField] = this.computeOptions(row[distField], options);
        }
    }
    
    
    updateMultiSelect(row, selectedValue, isChecked, distField, optionsField) {
        // Check if the options array is defined
        const options = this[optionsField];
        if (!options || !Array.isArray(options)) {
            console.error(`Options field ${optionsField} is not defined or is not an array.`);
            return;
        }
    
        const selectedOption = options.find(option => option.value === selectedValue);
        if (selectedOption) {
            const selectedLabel = selectedOption.label;
            let selectedDist = row[distField] ? row[distField].split(',').map(s => s.trim()).filter(s => s) : [];
    
            // Add or remove the selected option based on the checkbox state
            if (isChecked && !selectedDist.includes(selectedLabel)) {
                selectedDist.push(selectedLabel);
            } else if (!isChecked) {
                selectedDist = selectedDist.filter(val => val !== selectedLabel);
            }
    
            row[distField] = selectedDist.join(', ');
    
            // Update the options list to reflect the selected state
            row[optionsField] = this.computeOptions(row[distField], options);
        }
    }
    
    computeOptions(selectedValuesStr, availableOptions) {
        const selectedValues = selectedValuesStr ? selectedValuesStr.split(',').map(s => s.trim()) : [];
        
        // Sort options numerically by label before returning
        return availableOptions
            .map(option => ({
                ...option,
                selected: selectedValues.includes(option.label)  // Checkbox checked state based on selection
            }))
            .sort((a, b) => Number(a.label) - Number(b.label)); // Sort numerically by label
    }
    
    



    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadApplications();
            this.updateRange();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadApplications();
            this.updateRange();
        }
    }

    updateRange() {
        this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
        this.endRange = Math.min(this.startRange + this.paginatedResult.length - 1, this.totalRecords);
    }

    handleSearch() {
        this.currentPage = 1;
        this.loadApplications();
        this.updateRange();
    }

    handleClear() {
        this.congressionalDist = '';
        this.houseAssemblyDist = '';
        this.senatorialDist = '';
        this.senatorialDistId = '';
        this.houseAssemblyDistId = '';
        this.townsOffice = '';
        this.phoneNumber = '';
        this.congressionalDistId = '';
        this.currentPage = 1;
        this.loadApplications();
        this.updateRange();
    }

    handleCancelClick() {
        this.paginatedResult = JSON.parse(JSON.stringify(this.originalData)); // Restore original data
        this.isEditing = false; // Exit edit mode
        this.showToast('Info', 'Changes have been discarded', 'info');
    }

    handleUndoClick() {
        this.paginatedResult = JSON.parse(JSON.stringify(this.originalData)); // Restore original data
    }

    get isEditingValue() {
        return !this.isEditing;
    }

    handleSaveChanges() {
        let changedRecords = this.getChangedRecords();
        console.log('Changed Records:', JSON.stringify(changedRecords));  // Log the data being sent
    
        if (changedRecords.length === 0) {
            this.showToast('Info', 'Office District Mappings No Changes made', 'info');
            this.isEditing = false;  // Exit edit mode if no changes
            return;
        }
    
        // Serialize the changedRecords to JSON format before sending to Apex
        let jsonData = JSON.stringify(changedRecords);
    
        // Call Apex method with serialized JSON data
        updateOfficeDistrictMappings({ officeMappingsJson: jsonData })
            .then(() => {
                this.showToast('Success', 'Office District Mappings updated successfully', 'success');
                this.isEditing = false;  // Exit edit mode
                this.handleClear();  // Refresh the data
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                console.error('Error saving changes:', error);
            });
    }
    

    async openSealAddModal() {
        this.isStaffModalOpen = true; 

        await sap_PublicOfficialRedistrictingModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });

        this.closeModal();
    }

    closeModal() {
        this.isStaffModalOpen = false;
        // history.back(); // Moves the browser state back
        setTimeout(() => {
            this.loadApplications();
        }, 250);
    }
    
    
    getChangedRecords() {
        let changedRecords = [];
    
        for (let i = 0; i < this.paginatedResult.length; i++) {
            let updatedRow = this.paginatedResult[i];
            let originalRow = this.originalData[i];
    
            // Fetch actual values (IDs) for districts based on selected labels and trim any whitespace
            let updatedCongressionalDist = this.getDistrictValuesFromLabels(updatedRow.congressionalDist, this.congressionalOptions);
            let updatedHouseAssemblyDist = this.getDistrictValuesFromLabels(updatedRow.houseAssemblyDist, this.houseAssemblyOptions);
            let updatedSenatorialDist = this.getDistrictValuesFromLabels(updatedRow.senatorialDist, this.senatorialOptions);
    
            let originalCongressionalDist = this.getDistrictValuesFromLabels(originalRow.congressionalDist, this.congressionalOptions);
            let originalHouseAssemblyDist = this.getDistrictValuesFromLabels(originalRow.houseAssemblyDist, this.houseAssemblyOptions);
            let originalSenatorialDist = this.getDistrictValuesFromLabels(originalRow.senatorialDist, this.senatorialOptions);
    
            // Compare original and updated values using deep equality check for arrays
            if (
                updatedRow.Id !== originalRow.Id || // Office ID change (edge case)
                !this.areArraysEqual(updatedCongressionalDist, originalCongressionalDist) || 
                !this.areArraysEqual(updatedHouseAssemblyDist, originalHouseAssemblyDist) ||
                !this.areArraysEqual(updatedSenatorialDist, originalSenatorialDist)
            ) {
                // Push updated row with district IDs to changedRecords and ensure they are arrays
                changedRecords.push({
                    officeId: updatedRow.Id,
                    congressionalDist: updatedCongressionalDist.length ? updatedCongressionalDist : null,  // Array or null
                    houseAssemblyDist: updatedHouseAssemblyDist.length ? updatedHouseAssemblyDist : null,  // Array or null
                    senatorialDist: updatedSenatorialDist.length ? updatedSenatorialDist : null  // Array or null
                });
            }
        }
    
        return changedRecords;
    }

    areArraysEqual(arr1, arr2) {
        if (arr1.length !== arr2.length) {
            return false;
        }
        // Check if every element in arr1 is in arr2
        return arr1.every((value, index) => value === arr2[index]);
    }
    
    
    
    getDistrictValuesFromLabels(selectedLabels, districtOptions) {
        if (!selectedLabels || selectedLabels.trim() === '') {
            return [];  // Return an empty array if no labels are selected
        }
    
        let selectedLabelArray = selectedLabels.split(',').map(label => label.trim());  // Convert labels into array
    
        // Find corresponding values (IDs) for the selected labels
        let selectedValues = selectedLabelArray.map(label => {
            let foundOption = districtOptions.find(option => option.label === label);
            return foundOption ? foundOption.value : null;  // Return the value (ID) if found, else null
        });
    
        // Filter out nulls and return the values as an array
        return selectedValues.filter(value => value !== null);
    }

    get dropdownClass(){
        if(this.isEditing === true){
            return 'dropdown-toggle'
        }
        else{
            return 'dropdown-toggle disabled-dropdown'
        }
    }

    
    

    

    handleEditClick() {
        this.isEditing = true;
    }

    get isPreviousDisabled() {
        return this.isEditing || this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.isEditing || this.currentPage === this.totalPages || this.totalPages === 0;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }


    handleMenuClose(event) {
        // Reopen the menu
        event.preventDefault(); // prevent default close behavior
        this.template.querySelector('lightning-button-menu').focus(); // refocus on the menu
    }

    handleExportResultButtonClick(){
        let headers = [
            { label: 'Town', fieldName: 'Office' }, // Name of the office
            { label: 'Congressional District', fieldName: 'CongressionalDistrict' }, // Wrapper field for Congressional District
            { label: 'House Assembly District', fieldName: 'HouseAssemblyDistrict' }, // Wrapper field for House Assembly District
            { label: 'Senatorial District', fieldName: 'SenatorialDistrict' }, // Wrapper field for Senatorial District
        ];
        let fileName = 'ReDistricts';

        const searchCriteria = {
            electionOfficeBy: this.electionOfficeBy || '',
            congressionalDistId: this.congressionalDistId || '',
            houseAssemblyDistId: this.houseAssemblyDistId || '',
            senatorialDistId: this.senatorialDistId || '',
            townsElectionOffice: this.townsOffice || '',
            phoneNumber: this.phoneNumber || '',
            sortedBy: this.sortedBy || 'SAP_Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };

        const excelgenerator =  this.template.querySelector('c-sap_-public-official-export-to-excel');
        if (excelgenerator) {
            console.log('generatingPDF');
            excelgenerator.exportDataToExcelReDistricts(headers, searchCriteria, fileName);
        } else {
            console.error('Excel generator component not found');
        }

    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadApplications();
    }
}