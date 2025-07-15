import { LightningElement, track, wire } from 'lwc';
import sap_stateSealM from '@salesforce/resourceUrl/sap_stateSealM';
import sap_removeHeadingStateSeal from '@salesforce/resourceUrl/sap_removeHeadingStateSeal';
import getElectionOffices from '@salesforce/apex/SAP_ElectionOfficeController.getElectionOffices';
import getElectionOfficesCount from '@salesforce/apex/SAP_ElectionOfficeController.getElectionOfficesCount';
import getPublicOfficial from '@salesforce/apex/SAP_ElectionOfficeController.getPublicOfficial';
import getPublicOfficialsCount from '@salesforce/apex/SAP_ElectionOfficeController.getPublicOfficialsCount';
import getOfficeOptions from '@salesforce/apex/SAP_ElectionOfficeController.getOfficeOptions';
import deleteContact from '@salesforce/apex/SAP_PublicOfficialController.deleteContact';
import sap_PublicOfficialModal from 'c/sap_PublicOfficialModal';
import sap_ElectionOfficeModal from 'c/sap_ElectionOfficeModal';
import sap_DeleteConfirmationModal from 'c/sap_DeleteConfirmationModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDistrictOptions from '@salesforce/apex/SAP_AddOfficeController.getDistrictOptions';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class ElectionOffice extends NavigationMixin(LightningElement) {
    @track electionOfficeBy;
    @track electionHeldIn;
    @track congressionalDist;
    @track houseAssemblyDist;
    @track houseAssemblyDistId;
    @track senatorialDist;
    @track senatorialDistId;
    @track townsElectionOffice;
    @track stateElectionOffice;
    @track boroughCityElectionOffice;
    @track city;
    @track zip;
    @track congressionalDistId;

    @track isTown = false;
    @track isState = false;
    @track isBoroughCity = false;
    @track isLoading = true;
    @track transactionsFoundLabel = 0;


    @track buttonLabel = 'Add New ';
    @track typeofOffice = '';
    @track SearchResult = '';

    @track stateOffices = [];
    @track boroughCityOffices = [];
    @track allOffices = [];
    @track townOffices = [];


    @track paginatedResult = [];
    @track showResults = false;
    @track recordId;
    @track currentPage = 1;
    @track totalPages = 0;
    @track totalRecords = 0;
    recordsPerPage = 10;

    @track transactionFound = 0;

    @track startRange = 1;
    @track endRange = 0;

    @track sortedBy = '';
    @track sortedDirection = 'ASC';

    @track startDate;
    @track endDate;
    @track dateFilter = '';
    @track exportResultClicked;

    @track showBoroughCity = false;
    @track showState = false;
    @track showTown = false;

    @track townName = '';

    @track officialTransactionsFoundLabel = 0;
    @track officialPaginatedResult = [];
    @track isShowOfficial = false;
    @track officialRecordId;
    @track officialCurrentPage = 1;
    @track officialTotalPages = 0;
    @track officialTotalRecords = 0;
    officialRecordsPerPage = 10;
    @track officialShowResults

    @track officialTransactionFound = 0;

    @track officialStartRange = 1;
    @track officialEndRange = 0;

    @track officialSortedBy = 'CreatedDate';
    @track officialSortedDirection = 'ASC';

    @track officialSstartDate;
    @track officialEndDate;
    @track officialDateFilter = '';

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track officialBadgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track officialBadgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track officialBadgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track officialBadgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track officialBadgeClassThisYear = 'slds-badge_inverse custom-badge';






    electionOfficeByOptions = [
        { label: 'Town', value: 'Town' },
        { label: 'Borough/City', value: 'City' },
        { label: 'State', value: 'State' }
    ];

    electionHeldInOptions = [
        { label: 'Both', value: 'Both' },
        { label: 'May', value: 'May' },
        { label: 'November', value: 'Nov' }
    ];

    @track townsElectionOfficeOptions = [];
    @track stateElectionOfficeOptions = [];
    @track boroughCityElectionOfficeOptions = [];

    @track congressionalOptions = [];
    @track houseAssemblyOptions = [];
    @track senatorialOptions = [];


    connectedCallback() {

        // Push state to history when modal opens
        history.pushState({ modalOpen: true }, '');
        window.addEventListener('popstate', this.handleBackButton.bind(this));

        this.electionOfficeBy = 'State';
        this.isState = true;
        this.typeofOffice = 'State';
        this.buttonLabel = 'Add New State';
        this.SearchResult = "Search Results (Election Office by State)";

        this.loadOfficeOptions('Town', 'townsElectionOfficeOptions');
        this.loadOfficeOptions('City', 'boroughCityElectionOfficeOptions');
        this.loadOfficeOptions('State', 'stateElectionOfficeOptions');
        Promise.all([
            loadStyle(this, sap_stateSealM),
            loadStyle(this, sap_removeHeadingStateSeal)
        ]).then(() => {
            setTimeout(() => {
                this.isLoading = false;
                this.loadApplications();
            }, 1000);
            this.fetchDistrictOptions();
        }).catch(error => {
            console.error(error);

        });
    }

    disconnectedCallback() {

        window.removeEventListener('popstate', this.handleBackButton.bind(this));
    }

    handleBackButton(event) {
        if (history.state && history.state.modalOpen) {
            // Close modal and prevent default navigation
            this.closeModal();
            event.preventDefault();
        }
    }

    fetchDistrictOptions() {
        getDistrictOptions()
            .then(result => {


                this.congressionalOptions = result['Congressional'].map(item => {
                    return { label: item.label, value: item.value };
                });
                this.houseAssemblyOptions = result['House Assembly'].map(item => {
                    return { label: item.label, value: item.value };
                });
                this.senatorialOptions = result['Senatorial'].map(item => {
                    return { label: item.label, value: item.value };
                });


            })
            .catch(error => {
                console.error('Error fetching district options:', error);
            });
    }

    loadOfficeOptions(recordTypeName, optionProperty) {
        getOfficeOptions({ recordTypeName: recordTypeName })
            .then(result => {
                this[optionProperty] = result.map(name => {
                    return { label: name, value: name };
                });
            })
            .catch(error => {
                console.error('Error fetching office options:', error);
            });
    }

    toTitleCase(str) {
        return str ? str.replace(/\w\S*/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()) : '';
    }


    loadApplications() {
        const searchCriteria = {
            electionOfficeBy: this.electionOfficeBy || '',
            electionHeldIn: this.electionHeldIn || '',
            congressionalDistId: this.congressionalDistId || '',
            houseAssemblyDistId: this.houseAssemblyDistId || '',
            senatorialDistId: this.senatorialDistId || '',
            townsElectionOffice: this.townsElectionOffice || '',
            stateElectionOffice: this.stateElectionOffice || '',
            boroughCityElectionOffice: this.boroughCityElectionOffice || '',
            city: this.city || '',
            zip: this.zip || '',
            startDate: this.startDate,
            endDate: this.endDate,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || '',
            sortedDirection: this.sortedDirection || 'ASC'
        };


// Convert the search criteria into a JSON string
    const searchCriteriaJson = JSON.stringify(searchCriteria);
    console.log(searchCriteriaJson);

    getElectionOffices({ searchCriteriaJson })
            .then(result => {
                this.paginatedResult = result.map(wrapper => {

                    let sortedHouseAssemblyDist = '';
                    if (wrapper.houseAssemblyDist) {
                        sortedHouseAssemblyDist = wrapper.houseAssemblyDist.split(',')
                            .map(dist => dist.trim())
                            .map(Number)
                            .sort((a, b) => a - b)
                            .join(', ');
                    }


                    let sortedSenatorialDist = '';
                    if (wrapper.senatorialDist) {
                        sortedSenatorialDist = wrapper.senatorialDist.split(',')
                            .map(dist => dist.trim())
                            .map(Number)
                            .sort((a, b) => a - b)
                            .join(', ');
                    }


                    return {
                        Id: wrapper.office.Id,
                        SAP_Id__c: wrapper.office.SAP_Id__c != null && String(wrapper.office.SAP_Id__c).length < 3
                            ? String(wrapper.office.SAP_Id__c).padStart(3, '0')
                            : String(wrapper.office.SAP_Id__c),
                        SAP_Name__c: this.toTitleCase(wrapper.office.SAP_Name__c || ''),
                        SAP_Title__c: this.toTitleCase(wrapper.office.SAP_ROV_Name__c || ''),
                        SAP_Mailing_Address_Line_1__c: this.toTitleCase(wrapper.office.SAP_Mailing_Address_Line_1__c || ''),
                        SAP_Mailing_Address_City__c: this.toTitleCase(wrapper.office.SAP_Mailing_Address_City__c || ''),
                        SAP_Mailing_Address_State__c: wrapper.office.SAP_Mailing_Address_State__c,
                        SAP_Mailing_Address_Zip__c: wrapper.office.SAP_Mailing_Address_Zip__c != null && String(wrapper.office.SAP_Mailing_Address_Zip__c).trim() !== '' && String(wrapper.office.SAP_Mailing_Address_Zip__c).length < 5
                        ? String(wrapper.office.SAP_Mailing_Address_Zip__c).padStart(5, '0')
                        : wrapper.office.SAP_Mailing_Address_Zip__c != null && String(wrapper.office.SAP_Mailing_Address_Zip__c).trim() !== ''
                            ? String(wrapper.office.SAP_Mailing_Address_Zip__c)
                            : '',
                        SAP_Election_Held_In__c: wrapper.office.SAP_Election_Held_In__c,
                        congressionalDist: wrapper.congressionalDist || '',
                        houseAssemblyDist: sortedHouseAssemblyDist,
                        senatorialDist: sortedSenatorialDist
                    };

                });


                if (this.electionOfficeBy === 'State' && this.paginatedResult.length > 0) {
                    this.showState = true;
                    this.showBoroughCity = false;
                    this.showTown = false;
                } else if (this.electionOfficeBy === 'City') {
                    this.showBoroughCity = true;
                    this.showState = false;
                    this.showTown = false;
                } else if (this.electionOfficeBy === 'Town') {
                    this.showBoroughCity = false;
                    this.showState = false;
                    this.showTown = true;
                }

                this.updateRecordCountOffice();
                this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
                this.endRange = this.startRange + this.paginatedResult.length - 1;
            })
            .catch(error => {
                console.error('Error loading applications:', error);
            });
    }



    updateRecordCountOffice() {
        const searchCriteria = {
            electionOfficeBy: this.electionOfficeBy || '',
            electionHeldIn: this.electionHeldIn || '',
            congressionalDistId: this.congressionalDistId || '',
            houseAssemblyDistId: this.houseAssemblyDistId || '',
            senatorialDistId: this.senatorialDistId || '',
            townsElectionOffice: this.townsElectionOffice || '',
            stateElectionOffice: this.stateElectionOffice || '',
            boroughCityElectionOffice: this.boroughCityElectionOffice || '',
            city: this.city || '',
            zip: this.zip || '',
            startDate: this.startDate,
            endDate: this.endDate
        };
// Convert the object to a JSON string
    const searchCriteriaJson = JSON.stringify(searchCriteria);

    getElectionOfficesCount({ searchCriteriaJson })
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.transactionsFoundLabel = `${this.totalRecords} Found`;
                this.transactionFound = this.totalRecords;
            })
            .catch(error => {
                console.error('Error fetching record count:', error);
            });
    }




    handleInputChangeElectionOffice(event) {
        this.electionOfficeBy = event.detail.value;
        if (this.electionOfficeBy === 'Town') {
            this.isTown = true;
            this.isState = false;
            this.isBoroughCity = false;
            this.typeofOffice = 'Town';
            this.buttonLabel = 'Add New Town';
            this.SearchResult = "Search Results (Election Office by Town)";
            this.loadOfficeOptions('Town', 'townsElectionOfficeOptions');
            this.showBoroughCity = false;
                this.showState = false;
                this.showTown = true;
        } else if (this.electionOfficeBy === 'State') {
            this.isTown = false;
            this.isState = true;
            this.isBoroughCity = false;
            this.typeofOffice = 'State';
            this.buttonLabel = 'Add New State';
            this.SearchResult = "Search Results (Election Office by State)";
            this.loadOfficeOptions('State', 'stateElectionOfficeOptions');
            this.showState = true;
                this.showBoroughCity = false;
                this.showTown = false;
        } else if (this.electionOfficeBy === 'City') {
            this.isTown = false;
            this.isState = false;
            this.isBoroughCity = true;
            this.typeofOffice = 'City'
            this.buttonLabel = 'Add New Borough/City'
            this.SearchResult = "Search Results (Election Office by Borough/City)";
            this.loadOfficeOptions('City', 'boroughCityElectionOfficeOptions');
            this.showBoroughCity = true;
            this.showState = false;
            this.showTown = false;
        } else {
            this.isTown = false;
            this.isState = false;
            this.isBoroughCity = false;
        }
        this.handleClear();

        this.loadApplications();
    }
    handleKeyPress(event) {
        // Key code references
        const key = event.key;

        // Allow only numbers (0-9), backspace, arrow keys, delete, and tab
        const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
        const isNumber = /^\d$/.test(key); // Check if the pressed key is a number

        // Get the current value from the input field
        const inputField = event.target;
        const currentValue = inputField.value;

        // Block input if:
        // 1. The key is not a number and not in the list of valid keys
        // 2. The current value already contains one digit
        if ((!isNumber && !validKeys.includes(key)) || (isNumber && currentValue.length >= 1)) {
            event.preventDefault();
        }
    }


    handleKeyPressA(event) {
        // Key code references
        const key = event.key;

        // Allow only numbers (0-9), commas, backspace, arrow keys, delete, and tab
        const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
        const isNumber = /^\d$/.test(key); // Check if the pressed key is a number

        // Block any key that is not a number, comma, or one of the valid keys
        if (!isNumber && !validKeys.includes(key)) {
            event.preventDefault();
        }
    }


    handleInputChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value.trim();

        if (fieldName === 'electionHeldIn') {
            this.electionHeldIn = fieldValue;
        } else if (fieldName === 'townsElectionOffice') {
            this.townsElectionOffice = fieldValue;
        } else if (fieldName === 'stateElectionOffice') {
            this.stateElectionOffice = fieldValue;
        } else if (fieldName === 'boroughCityElectionOffice') {
            this.boroughCityElectionOffice = fieldValue;
        }
        else if (fieldName === 'city') {
            this.city = fieldValue;
        }
        else if (fieldName === 'zip') {
            this.zip = fieldValue;
        }


        if (fieldName === 'congressionalDist') {

            this.congressionalDist = fieldValue;
            this.validateCongressionalDistrict();
        }

        if (fieldName === 'houseAssemblyDist') {

            this.houseAssemblyDist = fieldValue;
            this.validateHouseAssemblyDistrict();
        }

        if (fieldName === 'senatorialDist') {

            this.senatorialDist = fieldValue;
            this.validateSenatorialDistrict();
        }
    }



    handleSearch() {
            this.currentPage = 1;
            this.loadApplications();
            this.isShowOfficial = false;

    }

    validateAndStoreDistrictIds() {
        const isCongValid = this.validateCongressionalDistrict();
        const isHouseValid = this.validateHouseAssemblyDistrict();
        const isSenatorialValid = this.validateSenatorialDistrict();



        return isCongValid && isHouseValid && isSenatorialValid;
    }

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
        return true;
    }

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
        return true;
    }

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
        return true;
    }

    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';

        this.loadApplications();
    }
    sortData(fieldName, direction) {
        const isReverse = direction === 'desc' ? -1 : 1;
        this.filteredDataList = [...this.filteredDataList].sort((a, b) => {
            const aValue = a[fieldName] ? a[fieldName].toLowerCase() : '';
            const bValue = b[fieldName] ? b[fieldName].toLowerCase() : '';
            return aValue > bValue ? isReverse : aValue < bValue ? -isReverse : 0;
        });
        this.updatePaginatedResult();
    }

    get noResults(){
        if(this.paginatedResult.length === 0){
            this.showState = false;
            this.showTown = false;
            this.showBoroughCity = false;
            return true;
        }else{
            return false;
        }
        //return this.showState &&  this.showBoroughCity && this.showTown;

    }


    get sortIcons() {
        return {
            SAP_Name__c: this.sortedBy === 'SAP_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Id__c: this.sortedBy === 'SAP_Id__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Election_Held_In__c: this.sortedBy === 'SAP_Election_Held_In__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Title__c: this.sortedBy === 'SAP_ROV_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Mailing_Address_Line_1__c: this.sortedBy === 'SAP_Mailing_Address_Line_1__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Mailing_Address_City__c: this.sortedBy === 'SAP_Mailing_Address_City__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Mailing_Address_State__c: this.sortedBy === 'SAP_Mailing_Address_State__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Mailing_Address_Zip__c: this.sortedBy === 'SAP_Mailing_Address_Zip__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',

        };
    }

    // handleKeyPress(event) {
    //     // Key code references
    //     const key = event.key;

    //     // Allow only numbers (0-9), backspace, arrow keys, delete, and tab
    //     const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
    //     const isNumber = /^\d$/.test(key); // Check if the pressed key is a number

    //     // Get the current value from the input field
    //     const inputField = event.target;
    //     const currentValue = inputField.value;

    //     // Block any key that is not a number or one of the valid keys
    //     // Also block input if the value already has 5 digits
    //     if ((!isNumber && !validKeys.includes(key)) || (isNumber && currentValue.length >= 5)) {
    //         event.preventDefault();
    //     }
    // }


    clearFilters() {
        this.dateFilter = '';
        this.startDate = null;
        this.endDate = null;

        this.updateBadgeClasses();
    }

    get sortedClassId(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Id__c' ? 'sorted' : ''}`;

    }

    get sortedClassName(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Name__c' ? 'sorted' : ''}`;

    }

    get sortedClassAddress(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Mailing_Address_Line_1__c' ? 'sorted' : ''}`;

    }
    get sortedClassCity(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Mailing_Address_City__c' ? 'sorted' : ''}`;

    }

    get sortedClassState(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Mailing_Address_State__c' ? 'sorted' : ''}`;

    }

    get sortedClassZip(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Mailing_Address_Zip__c' ? 'sorted' : ''}`;

    }

    get sortedClassTitle(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_ROV_Name__c' ? 'sorted' : ''}`;

    }

    get sortedClassElection(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Election_Held_In__c' ? 'sorted' : ''}`;

    }





    handleBadgeClick(event) {
        this.isShowOfficial = false;
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            "current-day": "CurrentDay",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
        };
        const rangeType = rangeTypeMap[clickedBadgeId];

        if (this.dateFilter === rangeType) {
            this.dateFilter = '';
            this.startDate = null;
            this.endDate = null;
        } else {
            this.dateFilter = rangeType;
            this.handleDateRange(rangeType);
        }

        this.applyFilters();
        this.updateBadgeClasses();
    }

     handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "CurrentDay":
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                startDate.setHours(0, 0, 0, 0);

                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisWeek":
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                startDate.setHours(0, 0, 0, 0);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisQuarter":
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                endDate.setHours(23, 59, 59, 999);
                break;
        }

        this.startDate = startDate ? startDate.toISOString().split("T")[0] : null;
        this.endDate = endDate ? endDate.toISOString().split("T")[0] : null;
    }

    applyFilters() {
        this.currentPage = 1;
        const searchCriteria = {
            electionOfficeBy: this.electionOfficeBy || '',
            electionHeldIn: this.electionHeldIn || '',
            congressionalDistId: this.congressionalDistId || '',
            houseAssemblyDistId: this.houseAssemblyDistId || '',
            senatorialDistId: this.senatorialDistId || '',
            townsElectionOffice: this.townsElectionOffice || '',
            stateElectionOffice: this.stateElectionOffice || '',
            boroughCityElectionOffice: this.boroughCityElectionOffice || '',
            city: this.city || '',
            zip: this.zip || '',
            startDate: this.startDate,
            endDate: this.endDate,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'SAP_Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };
        const searchCriteriaJson = JSON.stringify(searchCriteria);
        getElectionOffices({searchCriteriaJson})
        .then(result => {

          this.paginatedResult = result.map(wrapper => {
            return {
                Id: wrapper.office.Id,
                SAP_Id__c: wrapper.office.SAP_Id__c,
                SAP_Name__c: wrapper.office.SAP_Name__c,
                SAP_Mailing_Address_Line_1__c: wrapper.office.SAP_Mailing_Address_Line_1__c,
                SAP_Mailing_Address_City__c: wrapper.office.SAP_Mailing_Address_City__c,
                SAP_Mailing_Address_State__c: wrapper.office.SAP_Mailing_Address_State__c,
                SAP_Mailing_Address_Zip__c: wrapper.office.SAP_Mailing_Address_Zip__c != null && String(wrapper.office.SAP_Mailing_Address_Zip__c).trim() !== '' && String(wrapper.office.SAP_Mailing_Address_Zip__c).length < 5
                ? String(wrapper.office.SAP_Mailing_Address_Zip__c).padStart(5, '0')
                : wrapper.office.SAP_Mailing_Address_Zip__c != null && String(wrapper.office.SAP_Mailing_Address_Zip__c).trim() !== ''
                    ? String(wrapper.office.SAP_Mailing_Address_Zip__c)
                    : '',
                SAP_Election_Held_In__c: wrapper.office.SAP_Election_Held_In__c,
                congressionalDist: wrapper.congressionalDist || '',
                houseAssemblyDist: wrapper.houseAssemblyDist || '',
                senatorialDist: wrapper.senatorialDist || ''
            };
            });

            if(this.electionOfficeBy === 'State' && this.paginatedResult.length > 0){
                this.showState = true;
                this.showBoroughCity = false;
                this.showTown = false;
            }
            if (this.electionOfficeBy === 'City'){
                this.showBoroughCity = true;
                this.showState = false;
                this.showTown = false;
            }
            if (this.electionOfficeBy === 'Town'){
                this.showBoroughCity = false;
                this.showState = false;
                this.showTown = true;
            }

            this.updateRecordCountOffice();
           this.startRange = 1;
           this.endRange = this.paginatedResult.length;
            })
            .catch(error => {
                console.error(error);
            });
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === "CurrentDay" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }

    handleClear() {

        this.electionHeldIn = '';
        this.congressionalDist = '';
        this.houseAssemblyDist = '';
        this.senatorialDist = '';
        this.congressionalDistId = '';
        this.houseAssemblyDistId = '';
        this.senatorialDistId = '';
        this.townsElectionOffice = '';
        this.stateElectionOffice = '';
        this.boroughCityElectionOffice = '';
        this.city = '';
        this.zip = '';


        this.startDate = null;
        this.endDate = null;

        this.dateFilter = '';

        this.currentPage = 1;

        this.paginatedResult = [];
        this.transactionsFoundLabel = "0 Found";
        this.transactionFound = 0;
        this.sortedBy = '';
        this.sortedDirection = 'ASC';

        this.sortedBy = '';
        this.sortIcons;
        this.isShowOfficial = false;
        this.officialShowResults = false;

        this.loadApplications();

        this.updateBadgeClasses();

    }

    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = Math.min(start + this.recordsPerPage, this.totalRecords);
        this.startRange = start + 1;
        this.endRange = end;
        this.paginatedResult = this.fullDataList.slice(start, end);
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.loadApplications();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadApplications();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    async openSealAddModal() {
        this.isStaffModalOpen = true;

         await sap_ElectionOfficeModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            officeType: this.typeofOffice,
            mode: 'Add',
        });

        this.closeModal();
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        const recordId = event.target.closest('lightning-button-menu').dataset.id;
        switch (selectedAction) {
            case 'view_request':
                this.viewRequest(recordId);
                break;
            case 'edit_request':
                this.editRequest(recordId);
                break;
            case 'delete_request':
                this.deleteRequest(recordId);
                break;
            default:
                break;
        }
    }

    async viewRequest(recordId) {
        this.isStaffModalOpen = true;

         await sap_ElectionOfficeModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            mode: 'view',
            officeType: this.typeofOffice

        });

        this.closeModal();
        this.isStaffModalOpen = false;
    }

    async editRequest(recordId) {
        this.isStaffModalOpen = true;

         await sap_ElectionOfficeModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            mode: 'edit',
            officeType: this.typeofOffice
        });
        this.closeModal();
        this.isStaffModalOpen = false;
    }

    async deleteRequest(recordId){

         await sap_DeleteConfirmationModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            officeType: this.typeofOffice,
            mode: 'Add',
        });

        this.isShowOfficial = false;

        this.closeModal();

    }

    closeModal() {
        this.isStaffModalOpen = false;


        setTimeout(() => {
            this.loadApplications();
            this.loadOfficeOptions('Town', 'townsElectionOfficeOptions');
            this.loadOfficeOptions('City', 'boroughCityElectionOfficeOptions');
            this.loadOfficeOptions('State', 'stateElectionOfficeOptions');
        }, 250);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleRowClick(event) {
        const rowId = event.currentTarget.dataset.id;
        const townName = event.currentTarget.dataset.name;
        this.recordId = rowId;
        this.townName = townName;
        this.officialSortedBy = 'CreatedDate';
        this.officialSortedDirection = 'DESC';




        this.loadPublicOfficials();
        this.isShowOfficial = true;
    }

    get searchLabel(){
        return 'Officials For ' + this.townName;
    }

    @wire(CurrentPageReference)
    pageRef({ state }) {
        console.log('state dats is '+JSON.stringify(state));
        if (state.c__reloadData == true) {
            this.loadPublicOfficials(); // Fetch contact data if editing an existing record
        }
    }


    loadPublicOfficials() {
        const searchCriteria = {
            recordId: this.recordId,
            startDate: this.officialSstartDate,
            endDate: this.officialEndDate,
            pageSize: this.officialRecordsPerPage,
            pageNumber: this.officialCurrentPage,
            sortedBy: this.officialSortedBy || 'CreatedDate',
            sortedDirection: this.officialSortedDirection || 'DESC'
        };
        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getPublicOfficial({ searchCriteriaJson })
        .then(result => {
            this.officialPaginatedResult = result.map(record => {
                return {
                    ...record,
                    formattedStartDate: this.formatDate(record.SAP_Start_Term__c),
                    formattedEndDate: this.formatDate(record.SAP_End_Term__c),
                };
            });

            this.officialShowResults = this.officialPaginatedResult.length > 0;
            this.updateOfficialRecordCount();

            this.officialStartRange = (this.officialCurrentPage - 1) * this.officialRecordsPerPage + 1;
            this.officialEndRange = this.officialStartRange + this.officialPaginatedResult.length - 1;
        })
        .catch(error => {
            this.showToast('Error', 'Error fetching public officials', 'error');
            console.error('Error fetching public officials:', error);
        });
    }

    updateOfficialRecordCount() {
        const searchCriteria = {
            recordId: this.recordId,
            startDate: this.officialSstartDate,
            endDate: this.officialEndDate,
        };
        const searchCriteriaJson = JSON.stringify(searchCriteria);
        console.log(searchCriteriaJson);

        getPublicOfficialsCount({ searchCriteriaJson })
            .then(result => {
                this.officialTotalRecords = result;
                this.officialTotalPages = Math.ceil(this.officialTotalRecords / this.officialRecordsPerPage);
                this.officialTransactionsFoundLabel = `${this.officialTotalRecords} Found`;
                this.officialTransactionFound = this.officialTotalRecords;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching record count', 'error');
                console.error('Error:', error);
            });
    }




    formatDate(dateString) {
        if (!dateString) return '';


        const [year, month, day] = dateString.split('T')[0].split('-');





        const formattedDate = `${month}/${day}/${year}`;

        return formattedDate;
    }

    officialHandleBadgeClick(event){
        const clickedBadgeId = event.target.dataset.id;
        console.log('@@@@@@--', clickedBadgeId);
        const rangeTypeMap = {
            "current-day": "CurrentDay",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
        };
        const rangeType = rangeTypeMap[clickedBadgeId];


        if (this.officialDateFilter === rangeType) {
            this.officialDateFilter = '';
            this.officialSstartDate = null;
            this.officialEndDate = null;
        } else {
            this.officialDateFilter = rangeType;
            this.officialHandleDateRange(rangeType);
        }


        this.officialApplyFilters();
        this.updateOfficialBadgeClasses();

    }

    officialHandleDateRange(rangeType){
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "CurrentDay":

                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                startDate.setHours(0, 0, 0, 0);


                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisWeek":
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                startDate.setHours(0, 0, 0, 0);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisQuarter":
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                endDate.setHours(23, 59, 59, 999);
                break;
        }

        this.officialSstartDate = startDate ? startDate.toISOString().split("T")[0] : null;
        this.officialEndDate = endDate ? endDate.toISOString().split("T")[0] : null;
    }


    officialApplyFilters() {
        this.officialCurrentPage = 1;

        const searchCriteria = {
            recordId: this.recordId,
            startDate: this.officialSstartDate,
            endDate: this.officialEndDate,
            pageSize: this.officialRecordsPerPage,
            pageNumber: this.officialCurrentPage,
            sortedBy: this.officialSortedBy || 'CreatedDate',
            sortedDirection: this.officialSortedDirection || 'DESC'
        };
        const searchCriteriaJson = JSON.stringify(searchCriteria);
        getPublicOfficial({searchCriteriaJson})
        .then(result => {

            this.officialPaginatedResult = result.map(record => {
                return {
                    ...record,
                    formattedStartDate: this.formatDate(record.SAP_Start_Term__c),
                    formattedEndDate: this.formatDate(record.SAP_End_Term__c),
                };
            });

            this.officialShowResults = this.officialPaginatedResult.length > 0;
            this.updateOfficialRecordCount();


           this.officialStartRange = 1;
           this.officialEndRange = this.officialPaginatedResult.length;
        })
        .catch(error => {
            this.showToast('Error', 'Error fetching public officials', 'error');
            console.error('Error fetching public officials:', error);
        });
    }

    updateOfficialBadgeClasses() {
        this.officialBadgeClassCurrentDay = this.officialDateFilter === "CurrentDay" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.officialBadgeClassThisWeek = this.officialDateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.officialBadgeClassThisMonth = this.officialDateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.officialBadgeClassThisQuarter = this.officialDateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.officialBadgeClassThisYear = this.officialDateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }


    officialHandleNextPage() {
        if (this.officialCurrentPage < this.officialTotalPages) {
            this.officialCurrentPage += 1;
            this.loadPublicOfficials();
        }
    }

    officialHandlePreviousPage() {
        if (this.officialCurrentPage > 1) {
            this.officialCurrentPage -= 1;
            this.loadPublicOfficials();
        }
    }

    get isOfficialPreviousDisabled() {
        return this.officialCurrentPage === 1;
    }

    get isOfficialNextDisabled() {
        return this.officialCurrentPage === this.officialTotalPages || this.officialTotalPages === 0;
    }

    officialHandleSort(event) {
        this.officialSortedBy = event.currentTarget.dataset.field;
        this.officialSortedDirection = this.officialSortedDirection === 'asc' ? 'desc' : 'asc';
        this.loadPublicOfficials();
    }


    get officialsortIcons() {
        return {
            SAP_Title__c: this.officialSortedBy === 'SAP_Title__c' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Party__c: this.officialSortedBy === 'SAP_Party__c' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            LastName: this.officialSortedBy === 'LastName' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            FirstName: this.officialSortedBy === 'FirstName' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Start_Term__c: this.officialSortedBy === 'SAP_Start_Term__c' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_End_Term__c: this.officialSortedBy === 'SAP_End_Term__c' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            HomePhone: this.officialSortedBy === 'HomePhone' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Phone: this.officialSortedBy === 'Phone' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Extension__c: this.officialSortedBy === 'SAP_Extension__c' ? (this.officialSortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'

        };
    }

    get sortedClassOfficialTitle(){
        return `slds-is-sortable ${this.officialSortedBy === 'SAP_Title__c' ? 'sorted' : ''}`;

    }

    get sortedClassParty(){
        return `slds-is-sortable ${this.officialSortedBy === 'SAP_Party__c' ? 'sorted' : ''}`;

    }

    get sortedClassLastName(){
        return `slds-is-sortable ${this.officialSortedBy === 'LastName' ? 'sorted' : ''}`;

    }

    get sortedClassFirstName(){
        return `slds-is-sortable ${this.officialSortedBy === 'FirstName' ? 'sorted' : ''}`;
    }

    get sortedClassStartTerm(){
        return `slds-is-sortable ${this.officialSortedBy === 'SAP_Start_Term__c' ? 'sorted' : ''}`;
    }

    get sortedClassEndTerm(){
        return `slds-is-sortable ${this.officialSortedBy === 'SAP_End_Term__c' ? 'sorted' : ''}`;
    }

    get sortedClassHomePhone(){
        return `slds-is-sortable ${this.officialSortedBy === 'HomePhone' ? 'sorted' : ''}`;
    }

    get sortedClassPhone(){
        return `slds-is-sortable ${this.officialSortedBy === 'Phone' ? 'sorted' : ''}`;
    }

    get sortedClassExtension(){
        return `slds-is-sortable ${this.officialSortedBy === 'SAP_Extension__c' ? 'sorted' : ''}`;
    }






    async openSealAddOfficialModal(){

         await sap_PublicOfficialModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            townId: this.recordId,
            electionOfficial: true,
        });

        this.closeofficialModal();

    }

    handleNavigateToAdd(){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__sap_PublicOfficialModal' // Replace with your target component's
            },
            state: {
                c__message: 'Hello from SourceComponent!', // Custom state parameter
                c__recordId: null, // pass if there is any recordIDtownId: this.recordId,
                c__townId: this.recordId,
                c__electionOfficial: true,
                c__returnTo: 'c__sap_ElectionOfficeSearchRequest',
                c__mode: 'add' // pass if there is any recordID
            }
         });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }

    officialHandleMenuSelect(event){
        const selectedAction = event.detail.value;
        const recordId = event.target.closest('lightning-button-menu').dataset.id;
        switch (selectedAction) {
            case 'official_view_request':
                this.handleNavigateToView(recordId)
                break;
            case 'official_edit_request':
                this. handleNavigateToEdit(recordId)
                break;
            case 'official_delete_request':
                this.officialDeleteRequest(recordId);
                break;
            default:
                break;
        }



    }

    handleNavigateToView(recordId){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__sap_PublicOfficialModal' // Replace with your target component's
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__recordId: recordId, // pass if there is any recordID
            c__townId: this.recordId,
            c__electionOfficial: true,
            c__returnTo: 'c__sap_ElectionOfficeSearchRequest',
            c__mode: 'view' // pass if there is any recordID
            }
            });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }

    }

    handleNavigateToEdit(recordId){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__sap_PublicOfficialModal' // Replace with your target component's
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__recordId: recordId, // pass if there is any recordID
            c__townId: this.recordId,
            c__returnTo: 'c__sap_ElectionOfficeSearchRequest',
            c__electionOfficial: true,
            c__mode: 'edit' // pass if there is any recordID
            }
            });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }

    }
    async officialDeleteRequest(recordId){
        deleteContact({ recordId: recordId })
                .then(() => {

                    this.showToast('Success', 'Contact deleted successfully', 'success');
                    setTimeout(() => {
                        this.loadPublicOfficials();
                    }, 250);
                })
                .catch(error => {
                    console.log(error);
                });
    }

    closeofficialModal(){
        setTimeout(() => {
            this.loadPublicOfficials();
        }, 250);
    }

    handleExportResultButtonClick(){
        let headers = [];
        let officeType = this.electionOfficeBy;


        if (officeType === 'Town') {
            headers = [
                { label: 'Town ID', fieldName: 'officeId' },
                { label: 'Towns/Elections Office', fieldName: 'Office' },
                { label: 'Email Address', fieldName: 'emailAddress' },
                { label: 'ROV Name', fieldName: 'rovName' },
                { label: 'Address', fieldName: 'Address' },
                { label: 'State', fieldName: 'State' },
                { label: 'Zip Code', fieldName: 'Zip' },
                { label: 'Country', fieldName: 'Country' },
                { label: 'Election Held In', fieldName: 'ElectionHeld' },
                { label: 'Congressional District', fieldName: 'CongressionalDistrict' },
                { label: 'House Assembly District', fieldName: 'HouseAssemblyDistrict' },
                { label: 'Senatorial District', fieldName: 'SenatorialDistrict' },
            ];
        } else if (officeType === 'State') {
            headers = [
                { label: 'State ID', fieldName: 'officeId' },
                { label: 'State/Elections Office', fieldName: 'Office' },
                { label: 'Title', fieldName: 'Title' },
                { label: 'Address', fieldName: 'Address' },
                { label: 'City', fieldName: 'City' },
                { label: 'Country', fieldName: 'Country' },
                { label: 'Zip Code', fieldName: 'Zip' }
            ];
        } else if (officeType === 'City') {
            headers = [
                { label: 'City/Borough ID', fieldName: 'officeId' },
                { label: 'Borough/City/Elections Office', fieldName: 'Office' },
                { label: 'Address', fieldName: 'Address' },
                { label: 'State', fieldName: 'State' },
                { label: 'Zip Code', fieldName: 'Zip' },
                { label: 'Country', fieldName: 'Country' },
                { label: 'Election Held In', fieldName: 'ElectionHeld' }
            ];
        }


        const searchCriteria = {
            electionOfficeBy: this.electionOfficeBy || '',
            electionHeldIn: this.electionHeldIn || '',
            congressionalDist: this.congressionalDist || '',
            houseAssemblyDist: this.houseAssemblyDist || '',
            senatorialDist: this.senatorialDist || '',
            homePhone: this.homePhone || '',
            townsElectionOffice: this.townsElectionOffice || '',
            stateElectionOffice: this.stateElectionOffice || '',
            boroughCityElectionOffice: this.boroughCityElectionOffice || '',
            city: this.city || '',
            zip: this.zip || '',
            startDate: this.startDate,
            endDate: this.endDate,
            sortedBy: this.sortedBy || 'SAP_Name__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };

        const fileName = 'Election_Offices';


        this.template.querySelector('c-sap_-public-official-export-to-excel').exportDataToExcelElectionOffice(headers, searchCriteria, fileName);

    }

    handleExportResultButtonOfficialClick(){
        let headers = [
            { label: 'Title', fieldName: 'SAP_Title__c' },
            { label: 'Party', fieldName: 'SAP_Party__c' },
            { label: 'Last Name', fieldName: 'LastName' },
            { label: 'First Name', fieldName: 'FirstName' },
            { label: 'Start Term', fieldName: 'formattedStartDate' },
            { label: 'End Term', fieldName: 'formattedEndDate' },
            { label: 'Home Phone', fieldName: 'HomePhone' },
            { label: 'Business Phone', fieldName: 'Phone' },
            { label: 'Extension', fieldName: 'SAP_Extension__c' }
        ];

        const fileName = this.townName +' Officials';


        const searchCriteria = {
            recordId: this.recordId,
            startDate: this.officialSstartDate,
            endDate: this.officialEndDate,
            sortedBy: this.officialSortedBy || 'CreatedDate',
            sortedDirection: this.officialSortedDirection || 'DESC'
        };


        this.template.querySelector('c-sap_-public-official-export-to-excel').exportDataToExcelElectionOfficial(headers, searchCriteria, fileName);



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