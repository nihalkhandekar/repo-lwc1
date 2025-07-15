import { LightningElement, track } from 'lwc';
import stateSealM from '@salesforce/resourceUrl/stateSealM';
import removeHeadingStateSeal from '@salesforce/resourceUrl/removeHeadingStateSeal';
import getDistrictOptions from '@salesforce/apex/AddOfficeController.getDistrictOptions';
import getTownOffices from '@salesforce/apex/RedistrictingController.getTownOffices';
import getElectionOffices from '@salesforce/apex/RedistrictingController.getElectionOffices';
import getElectionOfficesCount from '@salesforce/apex/RedistrictingController.getElectionOfficesCount';
import updateOfficeDistrictMappings from '@salesforce/apex/RedistrictingController.updateOfficeDistrictMappings'
import publicOfficialRedistrictingModal from 'c/publicOfficialRedistrictingModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PublicOfficialRedistricting extends LightningElement {
    congressionalOptions = [];
    houseAssemblyOptions = [];
    senatorialOptions = [];
    sbtOptions = []; // Town Office options
    

    townsOffice = '';
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
    sortedBy = 'Name__c';
    sortedDirection = 'ASC';
    electionOfficeBy = 'Town';
    exportResultClicked = false;
    isEditing = false;

    connectedCallback() {
        // Load the external styles first
        Promise.all([loadStyle(this, stateSealM), loadStyle(this, removeHeadingStateSeal)])
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
        return getDistrictOptions() // Return the promise
            .then(result => {
                console.log('District Options:', result); // Log the options for debugging
                this.congressionalOptions = result.Congressional.map(item => ({ label: item.label, value: item.value }));
                this.houseAssemblyOptions = result['House Assembly'].map(item => ({ label: item.label, value: item.value }));
                this.senatorialOptions = result.Senatorial.map(item => ({ label: item.label, value: item.value }));
                
                // Force reactivity to update dropdowns
                this.congressionalOptions = [...this.congressionalOptions];
                this.houseAssemblyOptions = [...this.houseAssemblyOptions];
                this.senatorialOptions = [...this.senatorialOptions];
            })
            .catch(error => {
                console.error('Error fetching district options:', error);
            });
    }
    
    loadApplications() {
        const searchCriteria = this.buildSearchCriteria();
        console.log(searchCriteria);
        getElectionOffices(searchCriteria)
            .then(result => {
                this.paginatedResult = result.map(wrapper => ({
                    Id: wrapper.office.Id,
                    Name__c: wrapper.office.Name__c,
                    congressionalDist: wrapper.congressionalDist || '',
                    houseAssemblyDist: wrapper.houseAssemblyDist || '',
                    senatorialDist: wrapper.senatorialDist || '',
                    houseAssemblyOptions: this.computeOptions(wrapper.houseAssemblyDist, this.houseAssemblyOptions),
                    senatorialOptions: this.computeOptions(wrapper.senatorialDist, this.senatorialOptions)
                }));
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
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };
    }

    updateRecordCountOffice() {
        const searchCriteria = this.buildSearchCriteria();
        getElectionOfficesCount(searchCriteria)
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

    updateMultiSelect(row, selectedValue, distField, optionsField) {
        const selectedLabel = this[optionsField].find(option => option.value === selectedValue).label;
        let selectedDist = row[distField] ? row[distField].split(',').map(s => s.trim()).filter(s => s) : [];

        if (!selectedDist.includes(selectedLabel)) {
            selectedDist.push(selectedLabel);
        } else {
            selectedDist = selectedDist.filter(val => val !== selectedLabel);
        }

        row[distField] = selectedDist.join(', ');
        row[optionsField] = this.computeOptions(row[distField], this[optionsField]);
    }

    computeOptions(selectedValuesStr, availableOptions) {
        const selectedValues = selectedValuesStr ? selectedValuesStr.split(',').map(s => s.trim()) : [];
        return availableOptions.map(option => ({
            ...option,
            class: selectedValues.includes(option.label) ? 'selected' : ''
        }));
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

        const result = await publicOfficialRedistrictingModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });

        this.closeModal();
    }

    closeModal() {
        this.isStaffModalOpen = false;
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
    
    
    

    

    handleEditClick() {
        this.isEditing = true;
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
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
            sortedBy: this.sortedBy || 'Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };

        const excelgenerator =  this.template.querySelector('c-public-official-export-to-excel');
        if (excelgenerator) {
            console.log('generatingPDF');
            excelgenerator.exportDataToExcelReDistricts(headers, searchCriteria, fileName);
        } else {
            console.error('Excel generator component not found');
        }

    }
}