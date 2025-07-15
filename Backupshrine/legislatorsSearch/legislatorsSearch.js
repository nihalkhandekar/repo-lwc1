import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEGISLATORS_RECORD_CONTACT_OBJECT from '@salesforce/schema/Contact';
import TITLE_FIELD from '@salesforce/schema/Contact.Legislator_Title__c';
import PARTY_FIELD from '@salesforce/schema/Contact.Party__c';
import DISTRICT_FIELD from '@salesforce/schema/Contact.District__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateSealM from '@salesforce/resourceUrl/stateSealM';
import removeHeadingStateSeal from '@salesforce/resourceUrl/removeHeadingStateSeal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import legislativeData from '@salesforce/apex/LegislativeController.legislativeData';
import getlegislativeDataCount from '@salesforce/apex/LegislativeController.getlegislativeDataCount';
import { NavigationMixin } from 'lightning/navigation';

export default class LegislatorsSearch extends  NavigationMixin(LightningElement) {

    @track title;
    @track party;
    @track lastName;
    @track firstName;
    @track middlename;
    @track district;
    @track titleOptions = [];
    @track partyOptions = [];
    @track districtOptions = [];

    @track paginatedResult = [];
    @track showResults = false;

    @track recordId;
    @track currentPage = 1;
    @track totalPages = 0;
    @track totalRecords = 0;
    @track isLoading = true;
    @track isRecordsLoading = true;
    recordsPerPage = 10;
    @track transactionsFoundLabel = "0 Found";

    @track transactionFound = 0;

    @track startRange = 1;
    @track endRange = 0;

    @track sortedBy = 'LastName'; // Empty initially
    @track sortedDirection = 'asc'; // Empty initially

    @track exportResultClicked;

    @track sbtOptions = [];

    fullDataList = [];
    @track searchLegislativeData = [];


    @wire(getObjectInfo, { objectApiName: LEGISLATORS_RECORD_CONTACT_OBJECT })
    legislatorsObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$legislatorsObjectInfo.data.defaultRecordTypeId', fieldApiName: TITLE_FIELD })
    wiredTitlePicklist({ error, data }) {
        if (data) {
            this.titleOptions = data.values;
        } else if (error) {
            console.error('Error fetching Title picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$legislatorsObjectInfo.data.defaultRecordTypeId', fieldApiName: PARTY_FIELD })
    wiredPartyPicklist({ error, data }) {
        if (data) {
            this.partyOptions = data.values;
        } else if (error) {
            console.error('Error fetching Party picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$legislatorsObjectInfo.data.defaultRecordTypeId', fieldApiName: DISTRICT_FIELD })
    wiredDistrictPicklist({ error, data }) {
        if (data) {
            this.districtOptions = data.values;
        } else if (error) {
            console.error('Error fetching Title picklist values:', error);
        }
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, stateSealM),
            loadStyle(this, removeHeadingStateSeal)
        ]).then(() => {
            setTimeout(() => {
                this.isLoading = false;
                this.loadLegislativeData();
            }, 1000);
        }).catch(error => {
            console.error('Error loading styles:', error);
        });
    }

    handleTitleChange(event) {
        this.title = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleFirstNameChange(event) {
        this.firstName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleDistrictChange(event) {
        this.district = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handlePartyChange(event) {
        this.party = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    loadLegislativeData() {
        this.isRecordsLoading = true;
        const searchCriteria = {
            firstname:this.firstName || '',
            lastname:this.lastName || '',
            title:this.title || '',
            district:this.district || '',
            party:this.party || '',
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'LastName',
            sortedDirection: this.sortedDirection || 'asc'
        };
        // console.log(searchCriteria);
        const selectionCriteriaJson = JSON.stringify(searchCriteria);
        legislativeData({selectionCriteriaJson})
        .then(result => {
            // Directly use the result as the paginated data
            this.paginatedResult = result.map(record => {
                return {
                    ...record
                };
            });

            this.showResults = this.paginatedResult.length > 0;

            // Update the record count (if not already updated)

                this.updateRecordCount(); // Only fetch the total record count on the first page


            // Set the range for the current page
            this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
            this.endRange = this.startRange + this.paginatedResult.length - 1;

            this.isRecordsLoading = false;
        })
        .catch(error => {
            this.showToast('Error', 'Error fetching applications', 'error');
            console.error(error);
            this.isRecordsLoading = false;
        });
    }

    updateRecordCount() {
        const searchCriteria = {
            firstname:this.firstName || '',
            lastname:this.lastName || '',
            title:this.title || '',
            district:this.district || '',
            party:this.party || ''
        };
        const selectionCriteriaJson = JSON.stringify(searchCriteria);

        getlegislativeDataCount({selectionCriteriaJson} )
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.transactionsFoundLabel = `${this.totalRecords} Found`;
                this.transactionFound = this.totalRecords;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching record count', 'error');
                console.error('Error:', error);
            });
    }

    handleSearch() {

        this.isLoading = true; // Show loader
        this.currentPage = 1;
        this.loadLegislativeData();

        this.isLoading = false;

    }


    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        console.log(this.sortedBy, this.sortedDirection);
        this.loadLegislativeData();
        console.log(this.sortedBy, this.sortedDirection);
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

    // Generate sorting icons dynamically
    get sortIcons() {
        return {
            Legislator_Title__c: this.sortedBy === 'Legislator_Title__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            LastName: this.sortedBy === 'LastName' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            FirstName: this.sortedBy === 'FirstName' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            MiddleName: this.sortedBy === 'MiddleName' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Party__c: this.sortedBy === 'Party__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            DistrictID__c: this.sortedBy === 'DistrictID__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'

        };
    }

    get sortedClassOfficialTitle(){
        return `slds-is-sortable ${this.sortedBy === 'Legislator_Title__c' ? 'sorted' : ''}`;

    }

    get sortedClassParty(){
        return `slds-is-sortable ${this.sortedBy === 'Party__c' ? 'sorted' : ''}`;

    }

    get sortedClassLastName(){
        return `slds-is-sortable ${this.sortedBy === 'LastName' ? 'sorted' : ''}`;

    }

    get sortedClassFirstName(){
        return `slds-is-sortable ${this.sortedBy === 'FirstName' ? 'sorted' : ''}`;
    }

    get sortedClassMiddleName(){
        return `slds-is-sortable ${this.sortedBy === 'MiddleName' ? 'sorted' : ''}`;
    }

    get sortedClassDistrict(){
        return `slds-is-sortable ${this.sortedBy === 'DistrictID__c' ? 'sorted' : ''}`;
    }

    applyFilters() {
        this.currentPage = 1; // Reset to the first page when applying new filters

        const searchCriteria = {
            firstname:this.firstName || '',
            lastname:this.lastName || '',
            title:this.title || '',
            district:this.district || '',
            party:this.party || '',
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'LastName',
            sortedDirection: this.sortedDirection || 'asc'
        };
        const selectionCriteriaJson = JSON.stringify(searchCriteria);
        legislativeData({selectionCriteriaJson})
        .then(result => {
            // Directly use the result as the paginated data
            this.paginatedResult = result.map(record => {
                return {
                    ...record
                };
            });

                this.showResults = this.paginatedResult.length > 0;
                this.updateRecordCount();

                // Set the range for the current page
                this.startRange = 1;
                this.endRange = this.paginatedResult.length;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching applications', 'error');
                console.error(error);
            });
    }


    handleClear() {
        // Reset search filters
        this.firstName = '',
        this.lastName = '',
        this.title = '',
        this.district = '',
        this.party = ''


        // Reset pagination
        this.currentPage = 1;

        // Clear paginated results and reload applications with default values
        this.paginatedResult = [];
        //this.showResults = false;
        this.transactionsFoundLabel = "0 Found";
        this.transactionFound = 0;

        this.sortedBy = 'LastName';
        this.sortIcons;

        // Call loadApplications to fetch the full list with default values
        this.loadLegislativeData();

        this.isLoading = false; // Hide loader after data is fetched

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
            this.loadLegislativeData();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadLegislativeData();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }


    handleExportResultButtonClick() {
        let headers = [
            { label: 'Title', fieldName: 'Title' },
            { label: 'Party', fieldName: 'Party' },
            { label: 'Last Name', fieldName: 'LastName' },
            { label: 'First Name', fieldName: 'FirstName' },
            { label: 'Middle Name', fieldName: 'MiddleName' },
            { label: 'District', fieldName: 'District' },
        ];
        let fileName = 'Legislative';

        const searchCriteria = {
            firstname: this.firstName || '',
            lastname: this.lastName || '',
            middlename: this.middlename || '',
            title: this.title || '',
            district: this.district || '',
            party: this.party || '',
            sortedBy: this.sortedBy || 'LastName',
            sortedDirection: this.sortedDirection || 'asc'
        };

        const excelgenerator =  this.template.querySelector('c-public-official-export-to-excel');
        if (excelgenerator) {
            excelgenerator.exportDataToExcelLegislative(headers, searchCriteria, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        const recordId = event.target.closest('lightning-button-menu').dataset.id;
        switch (selectedAction) {
            case 'view_request':
                //this.viewRequest(recordId);
                this.handleNavigateToView(recordId)
                break;
            case 'edit_request':
                //this.editRequest(recordId);
                this.handleNavigateToEdit(recordId)
                break;
            default:
                break;
        }
    }

    handleNavigateToView(recordId){
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__legislativeModal' // Replace with your target component's name
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__recordId: recordId, // pass if there is any recordID
            c__mode: 'view'
            }
        });
    }

    handleNavigateToEdit(recordId){
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__legislativeModal' // Replace with your target component's name
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__recordId: recordId, // pass if there is any recordID
            c__mode: 'edit'
            }
        });
    }

    // async viewRequest(recordId) {
    //     const result = await legislativeModal.open({
    //         size: 'small',
    //         description: 'Accessible description of modal\'s purpose',
    //         recordId: recordId,
    //         mode: 'view'
    //     });
    //     this.closeModal();
    // }



    // async editRequest(recordId) {
    //     const result = await legislativeModal.open({
    //         size: 'small',
    //         description: 'Accessible description of modal\'s purpose',
    //         recordId: recordId
    //     });
    //     this.closeModal();
    // }

    closeModal() {
        this.isStaffModalOpen = false;
        setTimeout(() => {
            this.loadLegislativeData();
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

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadLegislativeData();
    }
}